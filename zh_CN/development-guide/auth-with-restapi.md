# 认证

DataLayers 支持 HTTP 协议，使用 `JSON` 格式进行交互。 本章节重要介绍 DataLayers 相关 API， 其他兼容协议请参考：  

[InfluxDB Line Protocol](./writing-with-influxdb-line-protocol.md)

以下示例均使用 [时序表引擎](../sql-reference/table-management-timeseries.md)进行演示，如使用其他类型的表引擎，请参考[表引擎](../sql-reference/table-engine.md)。

DataLayers REST API 支持以下两种认证方式，可根据使用场景自由选择。配置参见 [DataLayers 配置](../operation-guide/datalayers-configuration.md)章节。


## HTTP BASIC 认证
DataLayers 的 REST API 使用 [`HTTP BASIC 认证 `](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Authentication#basic) 认证 携带认证凭据，API 密钥位置 `.......config.yaml` 中进行配置，详细信息请参考 [DataLayers 配置](../operation-guide/datalayers-configuration.md) 章节。

##  HTTP Bearer 认证
//todo 需支持 [`HTTP Bearer 认证`](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Authentication#bearer)

