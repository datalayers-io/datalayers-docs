---
title: "KV 存储快速开始"
description: "通过一个最小示例快速启用 Datalayers 的 Redis 兼容键值存储服务，并完成连接、认证与读写验证。"
---
# KV 存储快速开始

本文介绍如何启用 Datalayers 的 Redis 兼容键值存储服务，并通过 `redis-cli` 完成最基本的连接与读写验证。

## 配置 Redis 服务

Datalayers 中的键值存储服务默认处于禁用状态。通过以下配置可开启 Redis 兼容服务。

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

其中，`addr` 决定 Redis 兼容服务监听的地址和端口。后续使用 `redis-cli` 连接时，请以这里配置的端口为准。

## 启动 Datalayers

注意：键值存储服务仅在集群模式下支持。

```bash
# 使用 systemd
sudo systemctl restart datalayers

# 或者命令行
./target/debug/datalayers -c ./config/config.toml
```

## 使用 redis-cli 连接

1. 如果系统尚未安装 Redis，可以按照 [Install Redis | Docs](https://redis.io/docs/latest/operate/oss_and_stack/install/install-redis/) 中的说明安装 `redis-cli`。
2. 安装完成后，使用以下命令连接到 Datalayers 键值存储服务：

```bash
redis-cli -p 6379
```

## 验证读写

连接成功后，可执行以下命令验证基础读写是否正常：

```text
SET demo:key "hello datalayers"
GET demo:key
DEL demo:key
```

如果 `GET` 返回 `"hello datalayers"`，说明键值存储服务已经可以正常使用。

## 相关文档

- 想了解键值存储能力与适用场景，请参考 [Key-Value 键值存储概述](./overview.md)
- 想查看支持的数据结构和命令，请参考 [Redis 兼容性](./redis-compatibility.md)
