## 使用教程


### 一：Docker环境部署
- 1.更新系统软件包
```
apt update && apt upgrade -y
```
- 2.安装必要的工具
```
apt install -y curl nano
```
- 3.纯IPv6机器，请设置NAT64,可执行下方命令
```
sed -i "1i\nameserver 2a00:1098:2b::1\nnameserver 2a00:1098:2c::1\nnameserver 2a01:4f8:c2c:123f::1\nnameserver 2a01:4f9:c010:3f02::1" /etc/resolv.conf
```
- 4.安装docker：
```
curl -fsSL https://get.docker.com | bash
```
- 5.安装docker-compose
```
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose
```
- docker阿里云加速镜像
```
curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
```


### 二：Docker-compose配置

```yml      
services:
  xray:
    image: ghcr.io/caojiaxia/xray-npm-docker:latest
    container_name: xray
    restart: always
    environment:
      UUID: "xxxxxx"     
      XPATH: "/xxxxxx"
      DOMAIN_STRATEGY: UseIPv6        # IPv6优先  （可选） 
    networks:
      - xray_net
    # 限制日志大小
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  npm:
    image: jc21/nginx-proxy-manager:latest
    container_name: npm
    restart: always
    ports:
      - "80:80"
      - "81:81"
      - "443:443"
    volumes:
      - ./npm/data:/data
      - ./npm/letsencrypt:/etc/letsencrypt
    networks:
      - xray_net
    depends_on:
      - xray  # NPM 依赖 Xray，确保后端先启动
    # 限制日志大小
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

# 网络配置部分
networks:
  # 定义自定义网络
  xray_net:
    name: xray_net  # 强制物理名也不带前缀
    driver: bridge     # 使用桥接网络模式，使容器间可以相互通信
    enable_ipv6: true  # 开启 IPv6 支持
    ipam:
      driver: default
      config:
        # IPv4 子网（保持默认或自定义）
        - subnet: 172.25.0.0/16
        # IPv6 子网（使用私有地址段 fd00::/8 中的任意一段）
        - subnet: fd00:1234:5678::/64
```
**如果你不止一个容器运行，同时想让它运行在同一个网络下，请将networks替换成如下：**

```
networks:
  # 定义自定义网络
  xray_net:        #已有的网络
    external: true   # 引用外部已存在的网络，实现跨项目容器通信,防止 Compose 自动创建带文件夹前缀的新网络
```


### 三：启动命令

- 1
```
docker compose pull
```
- 2
```
docker compose up -d
```

### 四：NPM面板设置   
**为了数据安全，请自行去[cloudflare](https://www.cloudflare.com)部署端口回源** 
   - 为你的NPM面板解析一个域名（你的服务器IP）域名的SSL/TLS配置为灵活 然后创建一个规则 把端口转发到：81
   - 路径：Rules→ Overview→ Origin Rules

| 选项        | 说明                                                                      |
| ----------- | --------------------------------------------------------------------      |
| Domain Names | 解析到你主机的域名 SSL/TLS配置必须为 `完全（严格） `（解析到`Cloudflare`的域名请打开小黄云）                   |
| Scheme | http                                                                           |
| Forward Hostname / IP   | xray                                                           |
| Forward Port   | 10000                                                                     |
| Cache Assets   |   可选（建议打开）                                                          |
| Block Common Exploits  |   可选（建议打开）                                                  |
| Websockets Support | 必须打开                                                             |
| Force SSL | 必须打开                                                                     |
| HTTP/2 Support | 必须打开                                                                     |

### 五：客户端参数配置
**请严格对照以下参数修改你的客户端（如 v2rayN, Clash Meta 等）**

|选项      | 说明                                                        |
|----------|-------------------------------------------------------------|
|  协议 (Protocol) | VLESS                                                |
| 地址（address) | 你的域名/优选IP                                                   |
| 端口（port）  | 443                                                            |
| UUID  | 你设置的环境变量 UUID                                             |
| 传输协议 (network) | xhttp                                            |
| 伪装域名（host)     |你的域名                                                 |
| 路径 (Path)|   你设置的环境变量路径 (注意：如果变量是 abc，路径通常填 /abc)   |
| TLS  | 开启 (ON)                                                           |
| SNI  | 你的域名                                                         |
| 指纹(Fingerprint)  |chrome    (或者其它你自己喜爱的和使用的浏览器）         |
| ALPN  | h2或者h2,http/1.1                                               |
| 跳过证书验证(allowlnsecure) |false                                      |


