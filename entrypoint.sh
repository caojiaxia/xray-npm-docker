#!/bin/bash

# 如果环境变量未设置，则生成随机值
export UUID=${UUID:-$(cat /proc/sys/kernel/random/uuid)}
export XPATH=${XPATH:-/$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 12)}

echo "------------------------------------------"
echo "Xray Starting with:"
echo "UUID: $UUID"
echo "PATH: $XPATH"
echo "------------------------------------------"

# 替换模板中的变量并生成最终 config.json
envsubst '${UUID},${XPATH}' < /etc/xray/config.template.json > /etc/xray/config.json

# 启动服务
exec /usr/bin/xray -config /etc/xray/config.json
