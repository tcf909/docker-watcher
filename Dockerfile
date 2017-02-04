FROM tcf909/ubuntu-slim:latest
MAINTAINER T.C. Ferguson <tcf909@gmail.com>

ARG DEBUG=true
ENV DEBUG=${DEBUG:-false}

RUN \
    apt-get update && \
    apt-get upgrade && \

#RSYNC
    apt-get install \
        inotify-tools && \

#CLEANUP
    apt-get autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN \
    if [ "${DEBUG}" = "true" ]; then \
        apt-get update && \
        apt-get install iptables net-tools iputils-ping mtr && \
        apt-get autoremove && \
        apt-get clean && \
        rm -rf /var/lib/apt/lists/* /tmp/*; \
    fi

COPY rootfs/ /