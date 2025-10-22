# 命令行

本节向您介绍 Datalayers 支持的各类启动、管理命令 与 Datalayers CLI 交互式工具的使用。

## 启动与管理命令

Datalayers 支持一些基本的启动和管理命令，您可以通过 `datalayers -h` 进行查看。如：

```shell
datalayers -h
```

以下是常用的管理命令：

| 参数             | 简写     | 描述                                                       |
| ----------      | -------  | ------------------------------------------------------    |
| --config        | -c       | 指定配置文件 (默认: /etc/datalayers/datalayers.toml)         |
| --verbose       | -v       | 打印解析、修正后的配置文件信息                                 |
| --verbose       | -V       | 显示版本号并退出                                             |
| --help          | -h       | 命令行使用帮助信息                                           |

### 示例

```shell
-- 指定配置文件启动集群模式。
datalayers -c /etc/datalayers/cluster.toml

-- 指定配置文件启动单机模式，注意 -c 选项必须在后面。
datalayers standalone -c /etc/datalayers/standalone.toml

-- 默认配置文件启动单机模式。
datalayers standalone
```

## Datalayers CLI

在 Datalayers的 镜像/安装包 中已经包含 CLI 交互式工具 `dlsql`。

### 启动

在终端下执行 `dlsql` 即可进行 Datalayers CLI 交互式界面。

```shell
dlsql -h 127.0.0.1 -u admin -p public -d sensor_info -P 8360
```

相关参数：

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
