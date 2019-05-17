# usage:
#   docker pull hvariant/ansible:latest

FROM alpine:3.8

LABEL maintainer="lizhansong@hvariant.com"

RUN apk update && \
    apk add python3 py3-pip ca-certificates openssl && \
    apk add --virtual build-dependencies python3-dev libffi-dev openssl-dev build-base && \
    pip3 install --upgrade pip cffi && \
    pip3 install ansible==2.7.1 pywinrm && \
    apk del build-dependencies && \
    rm -rf /var/cache/apk/* && \
    rm -rf /root/.cache

RUN apk add cdrkit && \
    rm -rf /var/cache/apk/*

RUN ln -s /usr/bin/python3 /usr/bin/python

RUN mkdir -p /root/packer
WORKDIR /root/packer
