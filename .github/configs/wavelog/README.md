# [wavelog](https://github.com/wavelog/wavelog)

Wavelog 是一个开源的业余无线电通联日志管理系统，业余无线电爱好者们(HAMs)可以借助Wavelog轻松管理通联记录，并与QRZ.com、LoTW等平台一键同步。

本镜像基于官方镜像构建，在官方镜像的基础上支持使用环境变量预先设置数据库连接信息。

| 环境变量          | 值                                          |
| ----------------- | ------------------------------------------- |
| DB_HOST           | 数据库服务名 \| 容器名 \| 主机名 \| IP 地址 |
| DATABASE          | 数据库名                                    |
| DATABASE_USERNAME | 数据库用户名                                |
| DATABASE_PASSWORD | 数据库密码                                  |

获取当前最新版本

```shell
docker pull ghcr.io/pooneyy/wavelog:2.2.2
```
```shell
docker pull ghcr.io/pooneyy/wavelog:latest
```
