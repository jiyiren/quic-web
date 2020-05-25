# basic image
FROM jiyirepo/http-base-quic:v1.0.0

# author and team
MAINTAINER jiyiren TEAM <jiyi@1459050189@gmail.com>

WORKDIR /opt

COPY libs /opt

RUN cat /opt/httpd_config.conf > /usr/local/lsws/conf/httpd_config.conf \
    && cat /opt/nginx.conf > /etc/nginx/nginx.conf \
    && cp /opt/supervisord.conf /etc/supervisord.conf

EXPOSE 80

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf", "-n"]
