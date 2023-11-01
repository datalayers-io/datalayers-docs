# 数据写入
Datalayers 支持通过 HTTP/HTTPS 进行交互，`SQL STATEMENT` 通过 `HTTP BODY` 的方式进行传递。SQL 相关语法请参考：[SQL Reference](../sql-reference/data-type.md)

## 语法
```shell
curl -X POST \
http://<HOST>:<PORT>/api/v1/write?db=<database_name> \
-H 'Content-Type: <content-type>' \
-H 'Authorization: <token>' \
-d '<SQL STATEMENT>'
```

## 创建表
```shell
curl -X POST \
http://127.0.0.1:3308/api/v1/write?db=test \
-H 'Content-Type: application/binary' \
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
```json
{
  "code": "SUCCESS",
  "reason": "",
}
```


## 数据插入
```shell
curl -X POST \
http://127.0.0.1:3308/api/v1/query?db=test \
-H 'Content-Type: application/binary' \
-H 'Authorization: 62142d26f55fd8e42c24da7d772accb9' \
-d 'INSERT INTO vehicle_info(`ts`, `sn`, `speed`, `longitude`, `latitude`) VALUES(NOT(), 88888888, 120, 104.07, 30.59)'
```
返回值
```json
{
  "code": "SUCCESS",
  "reason": "",
  "data": ""
}
```



