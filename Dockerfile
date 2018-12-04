FROM golang:1.11.2-alpine3.8 as builder

ARG JOBBER_VERSION=1.3.4

RUN apk add --no-cache git make tzdata rsync
RUN mkdir -p /jobber && \
    go get github.com/dshearer/jobber;true && \
    cd src/github.com/dshearer/jobber && \
    if  [ "v${JOBBER_VERSION}" != "latest" ]; then \
        git checkout tags/v${JOBBER_VERSION}; true; \
    fi && \
    make install DESTDIR=/jobber

FROM alpine:3.8
MAINTAINER Nikolay Arhipov <nikolajs.arhipovs@gmail.com>

RUN apk add --no-cache curl tini

COPY --from=builder /jobber/usr/local/bin /usr/bin
COPY --from=builder /jobber/usr/local/libexec /usr/libexec
RUN mkdir -p /var/jobber/0

COPY docker-entrypoint.sh /opt/jobber/docker-entrypoint.sh
ENTRYPOINT ["/sbin/tini","--","/opt/jobber/docker-entrypoint.sh"]
CMD ["/usr/libexec/jobberrunner", "/etc/jobber.conf"]
