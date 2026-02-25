# [Squid](https://github.com/squid-cache/squid)

Squid是一个开源的代理服务器，支持HTTP、HTTPS等多种协议。Squid提供广泛的访问控制和安全功能，适用于互联网服务提供商、企业网络等场景。

容器会在启动时根据环境变量创建配置文件，已经存在的配置文件不会被覆盖，修改配置文件后重启容器生效。

```yaml
services:
  squid:
    image: ghcr.io/pooneyy/squid:latest
    container_name: squid
    pull_policy: always
    ports:
      - 3128:3128
    volumes:
      - ./conf:/etc/squid
      - ./cert:/etc/squid-ssl
      - ./logs:/var/log/squid
      - /etc/localtime:/etc/localtime:ro
    restart: no
    environment:
      # SQUID_AUTH_USER 和 SQUID_AUTH_PASS 都存在时, Squid 将启用认证
      # 启用认证: 重启/重建容器时 SQUID_AUTH_USER 的密码将会重置为 SQUID_AUTH_PASS
      SQUID_AUTH_USER: squid_username
      SQUID_AUTH_PASS: squid_password
      # true|false 默认 false, 若为 true, 3128 端口只允许 HTTPS 访问
      SQUID_ONLY_HTTPS: true
```

获取当前最新版本

```shell
docker pull ghcr.io/pooneyy/squid:7.4
```
