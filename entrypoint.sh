#!/bin/bash

# 默认 IPv6 优先，如果环境变量没设，则使用 UseIPv6
export DOMAIN_STRATEGY=${DOMAIN_STRATEGY:-UseIPv6}

# 如果环境变量未设置，则生成随机值
export UUID=${UUID:-$(cat /proc/sys/kernel/random/uuid)}
export XPATH=${XPATH:-/$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 12)}

echo "------------------------------------------"
echo "Xray Starting with:"
echo "UUID: $UUID"
echo "PATH: $XPATH"
echo "Domain Strategy: $DOMAIN_STRATEGY"
echo "------------------------------------------"

# 替换模板中的变量并生成最终 config.json
# 注意：这里必须把 ${DOMAIN_STRATEGY} 加入到 envsubst 的替换列表中
envsubst '${UUID},${XPATH},${DOMAIN_STRATEGY}' < /etc/xray/config.template.json > /etc/xray/config.json

# 启动服务
exec /usr/bin/xray -config /etc/xray/config.json
