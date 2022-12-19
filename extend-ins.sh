#!/bin/bash

hoursSinceEpoch=$(($(date +'%s / 60 / 60')))

# if [[ $(($hoursSinceEpoch % 25)) -ne 0 ]]; then
if [[ $(wc -l </tmp/extend_cnt.txt) -ge 4 ]]; then
	curl 'https://www.cloudlab.us/server-ajax.php' \
	  -H 'Accept: application/json, text/javascript, */*; q=0.01' \
	  -H 'Accept-Language: en,zh-CN;q=0.9,zh;q=0.8,zh-TW;q=0.7' \
	  -H 'Connection: keep-alive' \
	  -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' \
	  -H 'Cookie: ' \
	  -H 'DNT: 1' \
	  -H 'Origin: https://www.cloudlab.us' \
	  -H 'Referer: https://www.cloudlab.us/status.php?uuid=970f728e-3ea4-11ed-b318-e4434b2381fc' \
	  -H 'Sec-Fetch-Dest: empty' \
	  -H 'Sec-Fetch-Mode: cors' \
	  -H 'Sec-Fetch-Site: same-origin' \
	  -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/106.0.0.0 Safari/537.36' \
	  -H 'X-Requested-With: XMLHttpRequest' \
	  --data-raw '1231232' \
	  --compressed

	echo 0 > /tmp/extend_cnt.txt
	echo extended >> /tmp/`date +\%Y\%m\%d\%H\%M\%S`-frpcron.log 2>&1
	exit 0
fi

echo 1 >> /tmp/extend_cnt.txt
