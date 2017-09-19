FROM alpine:3.6

MAINTAINER Athenahealth LMM Team <donotsendemail@athenahealth.com>

EXPOSE 9093
EXPOSE 9090

ENV PROMETHEUS_VERSION 2.0.0-beta.4
ENV PROMETHEUS_DIST_PREFIX https://github.com/prometheus/prometheus/releases/download
ENV PROMETHEUS_DIST $PROMETHEUS_DIST_PREFIX/v$PROMETHEUS_VERSION/prometheus-$PROMETHEUS_VERSION.linux-amd64.tar.gz
ENV ALERTMANAGER_VERSION 0.8.0
ENV ALERTMANAGER_DIST_PREFIX https://github.com/prometheus/alertmanager/releases/download
ENV ALERTMANAGER_DIST $ALERTMANAGER_DIST_PREFIX/v$ALERTMANAGER_VERSION/alertmanager-$ALERTMANAGER_VERSION.linux-amd64.tar.gz

ADD prometheus.yml /etc/prometheus/
ADD prometheus.rules /etc/prometheus/
ADD mkalertmanagercfg /bin/mkalertmanagercfg
ADD startup /
ADD startup-alertmanager /
ADD https://github.com/lloesche/prometheus-dcos/releases/download/0.1/srv2file_sd /bin/srv2file_sd

RUN apk --no-cache add \
      dumb-init \
      tzdata \
      curl \
      git \
      openssh-client \
    && curl -fSL $PROMETHEUS_DIST | gzip -d | tar -xf - \
    && mv /prometheus-$PROMETHEUS_VERSION.linux-amd64/prometheus /bin/ \
    && mv /prometheus-$PROMETHEUS_VERSION.linux-amd64/promtool /bin/ \
    && mkdir -p /usr/share/prometheus \
    && mv /prometheus-$PROMETHEUS_VERSION.linux-amd64/console_libraries/ /usr/share/prometheus/ \
    && mv /prometheus-$PROMETHEUS_VERSION.linux-amd64/consoles/ /usr/share/prometheus/ \
    && ln -s /usr/share/prometheus/console_libraries /usr/share/prometheus/consoles/ /etc/prometheus/ \
    && curl -fSL $ALERTMANAGER_DIST | gzip -d | tar -xf - \
    && mv /alertmanager-$ALERTMANAGER_VERSION.linux-amd64/alertmanager /bin/ \
    && mv /alertmanager-$ALERTMANAGER_VERSION.linux-amd64/amtool /bin/ \
    && chmod +x /startup /startup-alertmanager /bin/srv2file_sd

ENTRYPOINT [ "dumb-init", "--" ]
CMD ["/startup"]
