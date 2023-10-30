# 数据写入




## 语法
```shell
curl -X POST \
http://<HOST>:<PORT>/api/v1/write?db=<database_name> \
-H 'Content-Type: application/json' \
-H 'Authorization: <token>' \
-d '<SQL STATEMENT>'
```

## 创建表
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

## 数据插入
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


