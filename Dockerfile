FROM golang:1.11.2-alpine3.8 as builder

ARG JOBBER_VERSION=1.3.4-security

RUN apk add --no-cache git make tzdata rsync
RUN mkdir -p /jobber && \
    mkdir -p /src/github.com/dshearer && \
    cd /src/github.com/dshearer && \
    git clone git://github.com/bilderlings/jobber.git && \
    cd ./jobber && \
    if  [ "v${JOBBER_VERSION}" != "latest" ]; then \
        git checkout tags/v${JOBBER_VERSION}; true; \
    fi && \
    make install DESTDIR=/jobber

FROM alpine:3.8
MAINTAINER Nikolay Arhipov <nikolajs.arhipovs@gmail.com>

RUN apk add --update --no-cache \
    python curl tini jq tar gzip zip unzip rsync which bash openssh sshpass

ENV CLOUDSDK_INSTALL_DIR /gcloud/
RUN curl -sSL https://sdk.cloud.google.com | bash
ENV PATH $PATH:/gcloud/google-cloud-sdk/bin

COPY --from=builder /jobber/usr/local/bin /usr/bin
COPY --from=builder /jobber/usr/local/libexec /usr/libexec

RUN addgroup -g 1000 -S jobber && \
    adduser -u 1000 -S jobber -G jobber

RUN mkdir -p /var/jobber/1000 && \
    chown -R jobber:jobber /var/jobber/1000 && \
    touch /etc/jobber.conf && \
    chown jobber:jobber /etc/jobber.conf

USER 1000:1000

COPY jobber-entrypoint.sh /jobber-entrypoint.sh
ENTRYPOINT ["/sbin/tini", "--", "/jobber-entrypoint.sh"]
CMD ["/usr/libexec/jobberrunner", "/etc/jobber.conf"]
