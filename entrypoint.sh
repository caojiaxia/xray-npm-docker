#!/bin/bash

# 探测是否存在全局 IPv6 地址 (排除回环地址和链路本地地址)
if [ -z "$(ip -6 addr show scope global)" ]; then
    echo "检测到当前环境不支持 IPv6，自动回落至 AsIs 模式..."
    export DOMAIN_STRATEGY="AsIs"
else
    # 如果环境支持，且用户没指定变量，则维持 UseIPv6
    export DOMAIN_STRATEGY=${DOMAIN_STRATEGY:-UseIPv6}
fi

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
