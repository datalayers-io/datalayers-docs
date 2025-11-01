# 认证与安全

## 概述
Datalayers 支持基于 HTTP/HTTPS 协议的身份认证机制，确保数据库连接的安全性。系统提供内置的身份验证方式，允许管理员配置固定的用户名和密码进行访问控制。

## 认证配置
在 Datalayers 配置文件（默认路径：/etc/datalayers/datalayers.toml）中设置认证参数：
```toml
# ...
[server]
# ...
[server.auth]
username = "admin"
password = "public"
# ...
```
详细配置请参考 [Datalayers 配置手册](../admin/datalayers-configuration.md) 章节。  

**注：** *以下示例均使用 [时序表引擎](../sql-reference/table-engine/timeseries.md) 进行演示，如使用其他类型的表引擎，请参考[表引擎](../sql-reference/table-engine.md)。
Datalayers REST API 支持以下两种认证方式，可根据使用场景自由选择。配置参见 [Datalayers 配置](../admin/datalayers-configuration.md)章节。*


## HTTP BASIC 认证
Datalayers REST API 默认使用 [`HTTP BASIC 认证`](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Authentication#basic) 认证方式，认证凭据通过 HTTP 头部传递。

**基本用法**
```shell
curl -u"<username>:<password>" -X POST \
http://<HOST>:<PORT>/api/v1/sql?db=<database_name> \
-H 'Content-Type: application/binary' \
-d '<SQL STATEMENT>'
```

**示例**

```shell
curl -u"admin:public" -i -XPOST "http://127.0.0.1:8361/api/v1/sql" \
  -d 'show databases'
```
