FROM docker.io/library/alpine:3.22
RUN apk add --no-cache bash squid apache2-utils ca-certificates
COPY start-squid.sh /usr/local/bin/start-squid.sh
RUN chmod +x /usr/local/bin/start-squid.sh
CMD ["bash", "/usr/local/bin/start-squid.sh"]
