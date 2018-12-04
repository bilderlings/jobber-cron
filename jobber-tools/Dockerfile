ARG FROM_IMAGE=bilderlings/jobber
ARG JOBBER_VERSION=1.3.4
FROM ${FROM_IMAGE}:${JOBBER_VERSION}
MAINTAINER Nikolay Arhipov <nikolajs.arhipovs@gmail.com>

RUN apk add --update \
      gpgme \
      gnupg1 \
      wget \
      jq \
      curl \
      tar \
      gzip \
      zip \
      unzip \
      rsync \
      libedit \
      libpq \
      postgresql \
      git \
      mercurial && \
    # Keep only psql, pg_dump, and pg_restore
    cp /usr/bin/psql /usr/local/bin && \
    cp /usr/bin/pg_dump /usr/local/bin && \
    cp /usr/bin/pg_restore /usr/local/bin && \
    # Remove obsolete packages
    apk del \
      ca-certificates \
      postgresql &&  \
    # Clean caches and tmps
    rm -rf /var/cache/apk/* && \
    rm -rf /tmp/* && \
    rm -rf /var/log/*

COPY imagescripts /opt/jobber-tools
ENTRYPOINT ["/opt/jobber-tools/docker-entrypoint.sh"]
