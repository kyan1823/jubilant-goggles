FROM alpine:3.23.3

LABEL version="1.1" \
      description="A Docker image for clawcloud Free-Plan-Compatible" \
      maintainer="kyan1823"

ENV XRAY_VERSION=v26.2.6
ENV FRP_VERSION=v0.67.0

RUN apk update \
    && apk add --no-cache tini curl bash tar unzip ca-certificates \
    && update-ca-certificates || true

WORKDIR /root

RUN set -eux; \
    curl -fSL -o /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/download/${XRAY_VERSION}/Xray-linux-64.zip; \
    curl -fSL -o /tmp/frp.tar.gz https://github.com/fatedier/frp/releases/download/${FRP_VERSION}/frp_${FRP_VERSION#v}_linux_amd64.tar.gz; \
    unzip /tmp/xray.zip -d /tmp/xray; \
    mkdir -p /tmp/frp; \
    tar -zxf /tmp/frp.tar.gz -C /tmp/frp --strip-components=1; \
    mv /tmp/frp/frps /tmp/frp/frpc /tmp/xray/xray /usr/local/bin/; \
    mkdir -p /usr/local/share/xray; \
    mv /tmp/xray/*.dat /usr/local/share/xray/ 2>/dev/null || true; \
    mkdir -p /root/xray /root/frp; \
#    touch /root/xray/config.json; \
    rm /tmp/xray/ /tmp/frp/ /tmp/xray.zip /tmp/frp.tar.gz

RUN curl -fSL -o /usr/local/share/xray/geoip.dat https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geoip.dat \
    && curl -fSL -o /usr/local/share/xray/geosite.dat https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/geosite.dat

COPY --chown=0:0 --chmod=755 ./start.sh .

ARG TZ=Asia/Shanghai
ENV TZ=${TZ}
EXPOSE 7000

ENTRYPOINT [ "/sbin/tini", "--" ]
CMD [ "/root/start.sh" ]