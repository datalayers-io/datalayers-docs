---
title: "Datalayers TLS 连接加密配置指南"
description: "介绍如何为 Datalayers 配置 TLS 加密连接，包括服务端证书配置、服务重启与 dlsql 客户端访问方式。"
---
# Datalayers TLS 连接加密配置指南

Datalayers 支持 TLS（Transport Layer Security）加密连接，用于保护客户端与服务端之间的网络通信安全。启用 TLS 后，可以降低明文传输凭据和数据内容带来的安全风险。

## 配置

### 服务端配置

在配置文件中启用 TLS（包括 HTTPS 与 Arrow Flight SQL）：

```toml
[server.tls]
# 服务端私钥文件路径
key = "/etc/datalayers/certs/server.key"

# 服务端证书文件路径  
cert = "/etc/datalayers/certs/server.crt"
```

### 重启服务

配置完成后重启 Datalayers 服务使更改生效。

## 适用范围

- HTTPS 接口访问
- Arrow Flight SQL 加密连接
- 需要满足传输加密要求的生产环境部署

## 通过 dlsql 访问

### 机构签发证书

```shell
# 机构签发证书（系统自动验证）
dlsql -h 127.0.0.1 -P 8360 -u admin -p public --tls
```

### 自签证书

```shell
# 自签证书（指定CA证书路径）
dlsql -h 127.0.0.1 -P 8360 -u admin -p public --tls /path/to/ca.crt
```

## 相关文档

- 了解认证方式，请参考 [Datalayers 连接认证概述](./authentication/overview.md)
- 了解配置项细节，请参考 [TLS 配置字段](../admin/configuration-fields/server.md)
