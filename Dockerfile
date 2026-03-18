FROM alpine:latest

# 安装必要工具：gettext 提供 envsubst 命令进行变量替换
RUN apk add --no-cache ca-certificates bash curl gettext

# 下载最新版 Xray
RUN set -ex && \
    latest_version=$(curl -s https://api.github.com/repos/XTLS/Xray-core/releases/latest | grep tag_name | cut -d '"' -f 4) && \
    wget -O /tmp/xray.zip "https://github.com/XTLS/Xray-core/releases/download/${latest_version}/Xray-linux-64.zip" && \
    unzip /tmp/xray.zip -d /usr/bin/ && \
    chmod +x /usr/bin/xray && \
    rm /tmp/xray.zip

# 复制模板和启动脚本
COPY config.template.json /etc/xray/config.template.json
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
