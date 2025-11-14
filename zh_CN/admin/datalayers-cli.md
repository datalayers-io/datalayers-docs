# 交互终端概述

Datalayers CLI 交互终端（dlsql）是与 Datalayers 数据库进行交互的命令行工具。该工具已包含在 Datalayers 的镜像和安装包中，提供 SQL 执行和系统管理功能。

Datalayers CLI 支持两种连接认证方式，用户可根据实际场景选择。

## 基于帐号密码认证

适用于远程或本地 TCP/IP 连接，提供灵活的身份验证。在终端中执行以下命令进入交互式界面：

```shell
dlsql -h 127.0.0.1 -u admin -p public -P 8360
```

## 基于 Peer 认证

Linux 的 Peer 认证（Peer Credentials Authentication）是基于内核级别的进程身份验证机制，通过 `Unix Domain Socket` 通信为连接方提供可靠的身份验证。

Datalayers 集成 Peer 认证能力，为数据库账号管理提供安全便捷的解决方案，通过 Peer 认证的连接，将获得系统最高权限。使用 Peer 认证需依赖 `Unix Socket` 服务，因此需确保该服务已启用，如下：

```toml
# The configurations of the unix domain socket server.
[server.uds]
# The path of the unix domain socket, relative to `base_dir`.
# DONOT configure this options means do not support uds server by default.
# Recommend: "run/datalayers.sock"
path = "run/datalayers.sock"
```

通过以下命令即可进入交互终端：

```shell
# 以 deb/rpm 安装场景为例
sudo -u datalayers dlsql
```

**Peer 认证注意事项**：

- **认证限制**
  - 仅限本地访问：Peer 认证仅支持通过 Unix Socket 的本地连接
- **连接端权限要求**：连接端账号必须满足以下条件之一：
  - 具备超级管理员权限（root 用户）
  - 用户的 UID 与数据库服务运行时的 UID 完全一致
- **权限**：通过 Peer 认证建立的连接将获得系统级最高权限
- 配置 `Unix Socket` 服务后，需重启 Datalayers，以确保服务生效

## 连接参数详解

| 参数                | 简写     | 描述                                                                                                |
| ----------         | -------  | ----------------------------------------------------------------------------------------------    |
| --host             | -h       | 设置连接 Datalayers 服务器地址, 默认为本地路径通过 Unix Socket 方式连接: /var/lib/datalayers/run/datalayers.sock |
| --username         | -u       | 设置连接 Datalayers 使用的用户名                                                                      |
| --password         | -p       | 设置连接 Datalayers 使用的密码                                                                        |
| --port             | -P       | 设置连接 Datalayers 的端口                                                                           |
| --database         | -d       | 设置连接 Datalayers 时使用的数据库                                                                    |
| --execute          | -e       | 运行一次 SQL STATEMENT后退出                                                                         |
| --load-file        |          | 执行指定的 SQL 脚本文件                                                                               |
| --version          | -V       | 显示 CLI 工具的版本                                                                                  |
| --tls              |          | 通过 TLS 加密方式与数据库进行交互。自签证书则需指定 root ca，如：--tls /etc/datalayers/datalayers.crt       |
| --max-display-rows |          | 在使用 `dlsql` 查询数据时最多显示多少条记录，缺省值为： `40`，如需显示更多记录，则需通过该参数进行指定（`0` 表示无限制）         |
| --help             |          | show this help, then exit                                                                          |
