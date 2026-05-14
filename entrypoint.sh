#!/bin/bash

# --- 1. 环境自检测逻辑 (加强版) ---
# 解释：grep -E '^[0-9a-f]{2,4}:' 是为了只匹配真正的全球 IPv6 开头 (如 2001:, 2408: 等)
# 排除掉 fe80: (链路本地) 和 ::1 (回环)
HAS_GLOBAL_IPV6=$(ip -6 addr show scope global | grep -v "temporary" | grep "inet6 " | awk '{print $2}' | grep -vE "^fe80|^::1")

if [ -z "$HAS_GLOBAL_IPV6" ]; then
    echo "Check: No valid Global IPv6 address found. Switched to AsIs mode."
    # 纯 IPv4 或只有内网 IPv6 的环境下，强制设为 AsIs
    export DOMAIN_STRATEGY="AsIs"
else
    echo "Check: Global IPv6 detected ($HAS_GLOBAL_IPV6). Using UseIPv6 mode."
    # 如果环境支持，且你没在 compose 里手动指定，则用 UseIPv6
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
