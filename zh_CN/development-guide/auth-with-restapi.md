# 认证

DataLayers 支持 HTTP/HTTPS 协议进行交互。 当连接到数据库时会进行身份验证。 DataLayers 提供了以下两种的内置身份验证机制，允许用户配置一个固定的 用户名与密码进行认证。
如下：
```toml
# ...
[server]
# ...
[server.auth]
username = "admin"
password = "public"
# ...
```
详细配置请参考 [DataLayers 配置手册](../admin/datalayers-configuration.md) 章节。  

**注：** *以下示例均使用 [时序表引擎](../sql-reference/table-management-timeseries.md) 进行演示，如使用其他类型的表引擎，请参考[表引擎](../sql-reference/table-engine.md)。
DataLayers REST API 支持以下两种认证方式，可根据使用场景自由选择。配置参见 [DataLayers 配置](../admin/datalayers-configuration.md)章节。*


## HTTP BASIC 认证
DataLayers 的 REST API 使用 [`HTTP BASIC 认证`](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Authentication#basic) 认证 携带认证凭据。

**示例：**
```
curl -u"<username>:<password>" -X POST \
http://<HOST>:<PORT>/api/v1/write?db=<database_name> \
-H 'Content-Type: <content-type>' \
-d '<SQL STATEMENT>'
```

## HTTP Bearer 认证
即将支持。   
参考： [`HTTP Bearer 认证`](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Authentication#bearer)

