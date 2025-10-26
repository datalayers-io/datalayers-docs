# TLS 连接加密配置指南
Datalayers 支持 TLS（Transport Layer Security）加密连接，确保客户端与服务器之间的通信安全。本文档介绍如何配置和使用 TLS 加密功能。

## 快速配置

### 服务端配置

在配置文件中启用 TLS（包括 HTTPS 与 Flight SQL）：

```toml
[server.tls]
# 服务端私钥文件路径
key = "/etc/datalayers/certs/server.key"

# 服务端证书文件路径  
cert = "/etc/datalayers/certs/server.crt"
```

### 重启服务
配置完成后重启 Datalayers 服务使更改生效。

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
