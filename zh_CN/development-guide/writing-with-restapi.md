# REST API

DataLayers 支持 HTTP 协议，使用 `JSON` 格式进行交互。 本章节重要介绍 DataLayers 相关 API， 其他兼容协议请参考：  

[InfluxDB Line Protocol](./writing-with-influxdb-line-protocol.md)

以下示例均使用 [时序表引擎](../sql-reference/table-management-timeseries.md)进行演示，如使用其他类型的表引擎，请参考[表引擎](../sql-reference/table-engine.md)。

## 认证
DataLayers 的 REST API 使用 [`HTTP Basic`](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Authentication#通用的_http_认证框架) 认证 携带认证凭据，API 密钥位置 `.......config.yaml` 中进行配置，详细信息请参考 [DataLayers 配置](../operation-guide/datalayers-configuration.md) 章节。

## 写入数据

### 语法
```shell
curl -X POST \
http://<HOST>:<PORT>/api/v1/write?db=<database_name> \
-H 'Content-Type: application/json' \
-H 'Authorization: <token>' \
-d '<SQL STATEMENT>'
```

### 创建表
```shell
curl -X POST \
http://127.0.0.1:3308/api/v1/write?db=test \
-H 'Content-Type: application/json' \
-H 'Authorization: 62142d26f55fd8e42c24da7d772accb9' \
-d 'CREATE TABLE vehicle_info (
  ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  sn char(20) NOT NULL,
  speed int,
  longitude float,
  latitude float,
  PRIMARY KEY (sn, ts),
  PARTITION KEY (sn)
)
TableEngine = TimeSeries
TTL=30d'
```
返回值
```
todo
```

### 写入数据
```shell
curl -X POST \
http://127.0.0.1:3308/api/v1/query?db=test \
-H 'Content-Type: application/json' \
-H 'Authorization: 62142d26f55fd8e42c24da7d772accb9' \
-d 'INSERT INTO vehicle_info(`ts`, `sn`, `speed`, `longitude`, `latitude`) VALUES(NOT(), 88888888, 120, 104.07, 30.59)'
```
返回值
```
todo
```

## 查询数据
### 语法
```shell
curl -X POST \
http://<HOST>:<PORT>/api/v1/query?db=<database_name> \
-H 'Content-Type: application/json' \
-H 'Authorization: <token>' \
-d '<SQL STATEMENT>'
```
### 示例 
```shell
curl -X POST \
http://127.0.0.1:3308/api/v1/query?db=test \
-H 'Content-Type: application/json' \
-H 'Authorization: 62142d26f55fd8e42c24da7d772accb9' \
-d 'SELECT speed from vehicle_info where ts > NOW() - 1h and sn = 88888888'
```
返回值
```
todo
```

## 状态码说明
|  HTTP CODE   | 描述  |
|  ----  | ----  |
| 200  | 请求成功 |
| 403  | 没有权限 |
| 404  | 数据不存在 |