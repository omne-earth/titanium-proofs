FROM docker.io/library/ubuntu:24.04

WORKDIR /app
RUN id -u titanium >/dev/null 2>&1 || useradd -m -s /bin/bash titanium
ENV UV_CONCURRENT_DOWNLOADS=3
