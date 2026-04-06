#!/usr/bin/env python3
"""Check Utah CloudLab availability for selected node types.

This script queries the same ReservationInfo endpoint used by the web UI and
reports:
  - the minimum available count in the next forecast window
  - any zero-availability intervals
  - the best full one-week start window per instance type

Environment:
  CLOUDLAB_COOKIE: required cookie header value copied from a logged-in browser

Optional environment:
  CLOUDLAB_CLUSTER: defaults to "Utah"
  CLOUDLAB_TZ: defaults to "America/Denver"
"""

from __future__ import annotations

import json
import os
import sys
import urllib.error
import urllib.parse
import urllib.request
from dataclasses import dataclass
from datetime import datetime, timedelta
from typing import Dict, Iterable, List, Optional, Sequence, Tuple
from zoneinfo import ZoneInfo


DEFAULT_TYPES = ("c6525-100g", "c6525-25g", "c6620", "d6515")
DEFAULT_CLUSTER = os.environ.get("CLOUDLAB_CLUSTER", "Utah")
DEFAULT_TZ = os.environ.get("CLOUDLAB_TZ", "America/Denver")
WEEK = timedelta(days=7)
FORECAST_DAYS = 14
ENDPOINT = "https://www.cloudlab.us/server-ajax.php"


@dataclass(frozen=True)
class Event:
    ts: datetime
    free: int
    unavailable: int
    held: int
    unapproved: int


@dataclass(frozen=True)
class Interval:
    start: datetime
    end: datetime
    free: int


def load_cookie() -> str:
    cookie = os.environ.get("CLOUDLAB_COOKIE")
    if cookie:
        return cookie
    raise SystemExit("Missing CLOUDLAB_COOKIE environment variable")


def fetch_forecast(cookie: str, cluster: str) -> Dict[str, List[dict]]:
    payload = urllib.parse.urlencode(
        {
            "ajax_route": "reserve",
            "ajax_method": "ReservationInfo",
            "ajax_args[cluster]": cluster,
        }
    ).encode("utf-8")
    request = urllib.request.Request(
        ENDPOINT,
        data=payload,
        headers={
            "Accept": "application/json, text/javascript, */*; q=0.01",
            "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8",
            "Origin": "https://www.cloudlab.us",
            "Referer": "https://www.cloudlab.us/resinfo.php",
            "User-Agent": (
                "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
                "AppleWebKit/537.36 (KHTML, like Gecko) "
                "Chrome/146.0.0.0 Safari/537.36"
            ),
            "X-Requested-With": "XMLHttpRequest",
            "Cookie": cookie,
        },
        method="POST",
    )
    try:
        with urllib.request.urlopen(request, timeout=30) as response:
            raw = response.read().decode("utf-8")
    except urllib.error.URLError as exc:
        raise SystemExit(f"Failed to fetch CloudLab forecast: {exc}") from exc

    try:
        data = json.loads(raw)
    except json.JSONDecodeError as exc:
        raise SystemExit("CloudLab response was not valid JSON") from exc

    if data.get("code") != 0:
        raise SystemExit(f"CloudLab returned error code: {data.get('code')}")

    forecast = data.get("value", {}).get("forecast")
    if not isinstance(forecast, dict):
        raise SystemExit("CloudLab response did not contain a forecast map")
    return forecast


def dedupe_events(raw_events: Sequence[dict], tz: ZoneInfo) -> List[Event]:
    # The API can repeat a timestamp several times; keep the last one seen.
    by_ts: Dict[datetime, Event] = {}
    ordered_ts: List[datetime] = []
    for item in raw_events:
        ts = datetime.fromtimestamp(int(item["t"]), tz)
        if ts not in by_ts:
            ordered_ts.append(ts)
        by_ts[ts] = Event(
            ts=ts,
            free=int(item["free"]),
            unavailable=int(item["unavailable"]),
            held=int(item["held"]),
            unapproved=int(item["unapproved"]),
        )
    return [by_ts[ts] for ts in sorted(ordered_ts)]


def build_intervals(
    events: Sequence[Event], start: datetime, end: datetime
) -> List[Interval]:
    intervals: List[Interval] = []
    if not events:
        return intervals

    for idx, event in enumerate(events):
        interval_start = max(event.ts, start)
        interval_end = events[idx + 1].ts if idx + 1 < len(events) else end
        interval_end = min(interval_end, end)
        if interval_start < interval_end:
            intervals.append(
                Interval(start=interval_start, end=interval_end, free=event.free)
            )
    return intervals


def min_available(intervals: Sequence[Interval]) -> Optional[int]:
    if not intervals:
        return None
    return min(interval.free for interval in intervals)


def zero_windows(intervals: Iterable[Interval]) -> List[Tuple[datetime, datetime]]:
    return [
        (interval.start, interval.end)
        for interval in intervals
        if interval.free == 0 and interval.start < interval.end
    ]


def best_week_window(
    events: Sequence[Event], intervals: Sequence[Interval], start: datetime, end: datetime
) -> Optional[Tuple[datetime, datetime, int]]:
    candidate_starts = sorted({start} | {event.ts for event in events if start <= event.ts <= end})
    best: Optional[Tuple[int, datetime]] = None
    for candidate_start in candidate_starts:
        candidate_end = candidate_start + WEEK
        if candidate_end > end:
            continue

        floor: Optional[int] = None
        for interval in intervals:
            if interval.end <= candidate_start or interval.start >= candidate_end:
                continue
            floor = interval.free if floor is None else min(floor, interval.free)

        if floor is None or floor <= 0:
            continue

        if best is None or floor > best[0] or (floor == best[0] and candidate_start < best[1]):
            best = (floor, candidate_start)

    if best is None:
        return None
    floor, candidate_start = best
    return candidate_start, candidate_start + WEEK, floor


def fmt_ts(ts: datetime) -> str:
    return ts.strftime("%Y-%m-%d %H:%M %Z")


def main(argv: Sequence[str]) -> int:
    types = tuple(argv[1:]) if len(argv) > 1 else DEFAULT_TYPES
    cookie = load_cookie()
    tz = ZoneInfo(DEFAULT_TZ)

    forecast = fetch_forecast(cookie, DEFAULT_CLUSTER)
    fetch_time = datetime.now(tz)
    forecast_end = fetch_time + timedelta(days=FORECAST_DAYS)

    print(f"Cluster: {DEFAULT_CLUSTER}")
    print(f"Forecast window: {fmt_ts(fetch_time)} to {fmt_ts(forecast_end)}")
    print("")

    missing = [node_type for node_type in types if node_type not in forecast]
    if missing:
        print("Missing node types in forecast:", ", ".join(missing))
        print("")

    for node_type in types:
        raw_events = forecast.get(node_type)
        if not raw_events:
            continue

        events = dedupe_events(raw_events, tz)
        intervals = build_intervals(events, fetch_time, forecast_end)
        overall_min = min_available(intervals)
        best = best_week_window(events, intervals, fetch_time, forecast_end)

        print(f"{node_type}:")
        print(f"  minimum available: {overall_min if overall_min is not None else 'n/a'}")

        zeros = zero_windows(intervals)
        if zeros:
            print("  zero availability:")
            for start, end in zeros:
                print(f"    {fmt_ts(start)} -> {fmt_ts(end)}")
        else:
            print("  zero availability: none")

        if best:
            best_start, best_end, floor = best
            print("  best 1-week window:")
            print(f"    {fmt_ts(best_start)} -> {fmt_ts(best_end)}")
            print(f"    guaranteed floor: {floor}")
        else:
            print("  best 1-week window: none with strictly positive availability")
        print("")

    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
