# Server

`server` 部分包含用于启动和管理 Datalayers 服务器的配置设置。

## 配置服务器模式

- **`standalone`**:  
  确定服务器是以单机模式还是集群模式运行。  
  - `true`：服务器以单机模式运行。  
  - `false`：服务器以集群模式运行。  
  - **默认值**：`true`。

## 配置通信端点

这些设置定义了 Datalayers 服务器用于不同协议的通信端口。

- **`addr`**:  
  指定服务器的 Arrow FlightSql 端点。客户端通过该端点连接以使用 Arrow FlightSql 协议进行通信。  
  - **默认值**：`"0.0.0.0:8360"`。
  
- **`http`**:  
  指定服务器的 HTTP 端点。  
  - **默认值**：`"0.0.0.0:8361"`。

- **`redis`**:  
  指定 Redis 服务端点，仅在集群模式下可用。  
  - **默认值**：`"0.0.0.0:8362"`。  
  - 注：此选项被注释掉，默认情况下被禁用。取消注释以启用。

## 会话管理

- **`session_timeout`**:  
  确定会话在超时之前可以不活动多长时间。  
  - **默认值**：`"10s"`（10 秒的非活动时间）。

## 配置时区

- **`timezone`**:  
  定义服务器操作的时区。如果未提供，将使用本地机器的时区。  
  - **默认值**：`"Asia/Shanghai"`。

## TLS

`server.tls` 部分提供了配置 TLS 以保护与服务器通信的选项。

- **`key`**:  
  TLS 加密服务（用于 HTTPS 和 FlightSql）的私钥文件路径。  
  - 示例：`"/etc/datalayers/certs/server.key"`。  
  - **默认值**：未提供（用户需自行配置）。

- **`cert`**:  
  TLS 加密服务的证书文件路径。  
  - 示例：`"/etc/datalayers/certs/server.crt"`。  
  - **默认值**：未提供（用户需自行配置）。

## 身份验证

`server.auth` 部分用于配置访问 Datalayers 服务器的用户身份验证。

- **`username`**:  
  访问 Datalayers 服务器的用户名。  
  - **默认值**：`"admin"`。

- **`password`**:  
  访问 Datalayers 服务器的密码。  
  - **默认值**：`"public"`。

- **`token`**:  
  预定义的身份验证令牌，作为替代方法使用。  
  - **默认值**：`"c720790361da729344983bfc44238f24"`。

- **`jwt_secret`**:  
  用于生成和验证 JSON Web 令牌（JWT）的秘密密钥。  
  - **默认值**：`"871b3c2d706d875e9c6389fb2457d957"`。
