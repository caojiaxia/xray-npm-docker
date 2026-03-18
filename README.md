## 使用教程


***手动安装流程***

**一：Docker环境部署**
- 1.更新系统软件包
```
apt update && apt upgrade -y
```
- 2.安装必要的工具
```
apt install -y curl nano
```
- 3.安装docker：
```
bash <(curl -sSL https://cdn.jsdelivr.net/gh/SuperManito/LinuxMirrors@main/DockerInstallation.sh)
```
- 4.安装docker-compose
```
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose
```
- 加速镜像
```
curl -L "https://hub.gitmirror.com/https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose
```

### Xray+NPM

**Docker-compose配置**

```yml      
services:
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

  xray:
    image: ghcr.io/caojiaxia/xray-docker:latest
    container_name: xray
    restart: always
    environment:
      UUID: xxxxxx     #你的UUID
      XPATH: /xxxxxx   #你的路径
    networks:
      - xray_net
    depends_on:
      - npm

networks:
  xray_net:
    driver: bridge
```

### 启动命令

- 1
```
docker compose pull
```
- 2
```
docker compose up -d
```

###   NPM设置   
**为了数据安全，请自行去[cloudflare](https://www.cloudflare.com)做端口转发** 
   - 为你的NPM面板解析一个域名（你的服务器IP）域名的SSL/TLS配置为灵活 然后创建一个规则 把端口转发到：81
   - 路径：Rules→ Overview→ Origin Rules

| 选项        | 说明                                                                      |
| ----------- | --------------------------------------------------------------------      |
| Domain Names | 解析到你主机的域名 SSL/TLS配置必须为 `完全（严格） `（解析到`Cloudflare`的域名请打开小黄云）                   |
| Scheme | http                                                                           |
| Forward Hostname / IP   | 你的xray镜像名称或者直接填xray                                  |
| Forward Port   | 默认10000  也可以自己设置  打开`config.template.json`修改`"port": 10000`  |
| Websockets Support | 必须打开                                                             |
| Force SSL | 必须打开                                                                     |
| HTTP/2 Support | 必须打开                                                                     |

## 客户端参数配置
**请严格对照以下参数修改你的客户端（如 v2rayN, Clash Meta 等）**

- 协议 (Protocol): VLESS
- 地址: 你的域名/优选IP
- 端口: 443
- UUID: 你设置的环境变量 UUID
- 传输协议 (Transport): xhttp
- 路径 (Path): 你设置的环境变量路径 (注意：如果变量是 abc，路径通常填 /abc)
- TLS: 开启 (ON)
- SNI: 你的域名
- ALPN: h2或者h2,http/1.1
- 跳过证书验证(allowlnsecure)：false


