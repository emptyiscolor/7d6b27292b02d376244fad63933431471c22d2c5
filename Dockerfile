FROM alpine:latest as builder

ENV ARCH amd64

run wget -O /NeverIdle "https://github.com/layou233/NeverIdle/releases/latest/download/NeverIdle-linux-$ARCH" \
         && chmod +x /NeverIdle

FROM scratch

COPY --from=builder /NeverIdle /NeverIdle
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt

ENTRYPOINT ["/NeverIdle"]
CMD ["-c","1h","-m","1","-n","8h"]
