# 快速开始

Datalayers 提供兼容 Redis 协议的键值存储服务，本节将指导您快速启用并连接该服务，完成从配置到验证的全流程操作。

## 配置 Redis 服务

Datalayers 中的键值存储服务默认处于禁用状态，通过以下配置可开启 Datalayers 的 Key-Value 存储服务。

配置文件默认路径为：`/etc/datalayers/datalayers.toml`

```toml
# The configurations of the Redis service.
[server.redis]
# Users can start this service only when Datalayers server starts in cluster mode.
# Do not support redis service by default.
# Default: "".
addr = "0.0.0.0:6379"

# The username.
# Default: "admin".
username = "admin"

# The password.
# Default: "public".
password = "public"
```

## 启动 Datalayers

```bash
# 使用 systemd
sudo systemctl restart datalayers

# 或者命令行
./target/debug/datalayers -c ./config/config.toml
```

## 使用 Redis-cli 连接

1. 如果您的系统尚未安装Redis，可以按照 [Install Redis | Docs](https://redis.io/docs/latest/operate/oss_and_stack/install/install-redis/) 中的说明下载并安装Redis。
2. 安装完成后，使用以下命令连接到 Datalayers 键值存储服务：

```bash
redis-cli -p 8362
```
