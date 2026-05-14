#!/bin/bash

# --- 1. 环境自检测 (只认 2 或 3 开头的公网 IPv6) ---
GLOBAL_IPV6=$(ip -6 addr show scope global | grep -E 'inet6 [23]' | awk '{print $2}')

if [ -z "$GLOBAL_IPV6" ]; then
    echo "Check: No Real Global IPv6 found."
    # 如果没找到 IPv6，且用户没手动设值，则强制设为 AsIs
    export DOMAIN_STRATEGY=${DOMAIN_STRATEGY:-AsIs}
else
    echo "Check: Real Global IPv6 detected: $GLOBAL_IPV6"
    # 如果找到了，且用户没手动设值，则默认用高性能 UseIPv6
    export DOMAIN_STRATEGY=${DOMAIN_STRATEGY:-UseIPv6}
fi

# --- 2. 默认变量预设 ---
# (这部分保持不变)
export UUID=${UUID:-$(cat /proc/sys/kernel/random/uuid)}
export XPATH=${XPATH:-/$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 12)}

echo "------------------------------------------"
echo "Xray Starting with:"
echo "UUID: $UUID"
echo "PATH: $XPATH"
echo "Domain Strategy: $DOMAIN_STRATEGY"
echo "------------------------------------------"

# --- 3. 配置文件生成 ---
# 确保 envsubst 能够读取到上面 export 的 DOMAIN_STRATEGY
envsubst < /etc/xray/config.template.json > /etc/xray/config.json

# --- 4. 启动服务 ---
exec /usr/bin/xray -config /etc/xray/config.json
