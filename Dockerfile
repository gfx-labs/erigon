# syntax=docker/dockerfile:1
FROM docker.io/library/golang:1.17-alpine3.14 AS builder

RUN apk --no-cache add make gcc g++ linux-headers git bash ca-certificates libgcc libstdc++

WORKDIR /app
ADD . .

# expect that host run `git submodule update --init`
RUN make erigon rpcdaemon integration sentry txpool downloader hack db-tools

FROM docker.io/library/alpine:3.14

RUN apk add --no-cache ca-certificates libgcc libstdc++ tzdata
COPY --from=builder /app/build/bin/* /usr/local/bin/

RUN adduser -H -u 1000 -g 1000 -D erigon
RUN mkdir -p /home/erigon
RUN mkdir -p /home/erigon/.local/share/erigon
RUN chown -R erigon:erigon /home/erigon

USER erigon

EXPOSE 8545 8546 30303 30303/udp 30304 30304/udp 8080 9090 6060
