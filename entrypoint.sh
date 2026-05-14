#!/bin/bash

# --- 1. 环境自检测逻辑 ---
# 探测是否存在全局 IPv6 地址 (排除回环地址和链路本地地址)
if [ -z "$(ip -6 addr show scope global)" ]; then
    echo "Check: No Global IPv6 detected. Switched to AsIs mode."
    # 纯 IPv4 环境下，强制回落到 AsIs 确保进程不崩溃
    export DOMAIN_STRATEGY=${DOMAIN_STRATEGY:-AsIs}
else
    echo "Check: IPv6 detected. Enabling high-performance UseIPv6 mode."
    # 双栈环境下，默认维持你想要的高性能 IPv6 优先策略
    export DOMAIN_STRATEGY=${DOMAIN_STRATEGY:-UseIPv6}
fi

# --- 2. 默认变量预设 ---
# 如果环境变量未设置，则生成随机值
export UUID=${UUID:-$(cat /proc/sys/kernel/random/uuid)}
export XPATH=${XPATH:-/$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 12)}

echo "------------------------------------------"
echo "Xray Starting with:"
echo "UUID: $UUID"
echo "PATH: $XPATH"
echo "Domain Strategy: $DOMAIN_STRATEGY"
echo "------------------------------------------"

# --- 3. 配置文件生成 ---
# 关键修复：去掉单引号限制，直接替换所有匹配的环境变量，防止 JSON 解析失败
envsubst < /etc/xray/config.template.json > /etc/xray/config.json

# (可选) 调试用：打印生成的配置以确认变量已替换
# cat /etc/xray/config.json

# --- 4. 启动服务 ---
# 使用 exec 确保 Xray 成为容器主进程，能正确处理停止信号
exec /usr/bin/xray -config /etc/xray/config.json
