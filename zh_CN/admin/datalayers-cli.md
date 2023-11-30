# 命令行

本节向您介绍 DataLayers 支持的各类启动、管理命令 与 DataLayers CLI 交互式工具的使用。

## 启动与管理命令

DataLayers 支持一些基本的启动和管理命令，您可以通过 `datalayers -h` 进行查看。如：
```shell
datalayers -h
```

以下是常用的管理命令：

| 参数            | 描述                                                              |
| ----------     | ------------------------------------------------------------      |
| -h             | this help                                                         |
| -v             | show version and exit                                             |
| -t             | test configuration and exit                                       |
| -s             | send signal to a master process: stop, reload                     |
| -d             | daemon                                                            |
| -c filename    | set configuration file (default: /etc/datalayers/datalayers.toml) |

## DataLayers CLI
在 DataLayers 的镜像中已经包含 CLI 交互式工具。如在其他环境中运行，则需单独安装该工具，具体请参考：todo  


### 启动
在终端下执行 `dlsql` 即可进行 DataLayers CLI 交互式界面。
```shell
dlsql -h 127.0.0.1 -u datalayers -p 123456 -d sensor_info -P 3098
```

相关参数：
| 参数             | 简写     | 描述                                                             |
| ----------      | -------  | ------------------------------------------------------------    |
| --host          | -h       | 设置连接 DataLayers 服务器地址, 默认:127.0.0.1                      |
| --username      | -u       | 设置连接 DataLayers 使用的用户名                                   |
| --password      | -p       | 设置连接 DataLayers 使用的密码                                     |
| --port          | -P       | 设置连接 DataLayers 的端口                                        |
| --dbname        | -d       | 设置连接 DataLayers 时使用的数据库                                  |
| --command       | -c       | 运行一次 SQL STATEMENT后退出                                      |
| --version       | -V       | 显示 CLI 工具的版本                                               |
| --help          | -?       | show this help, then exit                                       |

### 示例 
//todo  gif 显示一个交互过程



使用 `dlsql` 可快速进行数据的导入、导出。请参考[数据导入](./data-import.md)、 [数据导出](./data-export.md)。