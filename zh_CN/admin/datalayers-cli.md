# 交互终端概述

Datalayers CLI 交互终端（dlsql）是与 Datalayers 数据库进行交互的命令行工具。该工具已包含在 Datalayers 的镜像和安装包中，提供 SQL 执行和系统管理功能。

## SQL 交互终端

**基本连接方式**

在终端中执行以下命令进入交互式界面：
```shell
dlsql -h 127.0.0.1 -u admin -p public -d sensor_info -P 8360
```

**连接参数详解**

| 参数                | 简写     | 描述                                                                                                |
| ----------         | -------  | ----------------------------------------------------------------------------------------------    |
| --host             | -h       | 设置连接 Datalayers 服务器地址, 默认:127.0.0.1                                                         |
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


## 管理工具

Datalayers 通过 Peer 认证提供本地账户管理功能。该机制基于 Unix Domain Socket 进行进程间认证，仅限服务器本地访问。使用该功能时需确保服务端已经启用 peer 服务。

**启用 Peer 服务**
```toml
[server]
# The unix socket file of peer server.
# Don't support peer server by default.
# Default: ""
peer_addr = "run/datalayers.sock"
```
配置后需要重启 Datalayers 服务生效。

**管理命令使用**

通过执行以下指令，查看相应功能说明：
```shell
dlsql admin --help
```

**子命令说明**

| 子命令             |  描述                                                     |
| ----------        |  ------------------------------------------------------    |
| init-root         |  初始化管理员帐号，详细参数可通过 --help 查看                 |
| list-user         |  列出系统的帐号信息，详细参数可通过 --help 查看               |
| reset-password    |  重置指定帐号的密码，详细参数可通过 --help 查看               |

**详细帮助查看**

```shell
# 查看 init-root 的参数说明
dlsql admin init-root --help
# 查看 list-user 的参数说明
dlsql admin list-user --help
# 查看 reset-password 的参数说明
dlsql admin reset-password --help
```
