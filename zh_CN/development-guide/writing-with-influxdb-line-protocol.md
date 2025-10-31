# InfluxDB 行协议接入指南

## 概述

Datalayers 完全兼容 [InfluxDB Line Protocol V1](https://docs.influxdata.com/influxdb/v1/write_protocols/line_protocol_tutorial/) 协议，为时序数据提供高效写入能力。该协议特别适合从现有 InfluxDB 系统迁移的场景。

## 示例
### 单条写入
```shell
curl -u"admin:public" -i -XPOST "http://127.0.0.1:8361/write?db=demo&precision=ns" \
  -d 'sensor,device_id=temp_sensor_001 temperature=23.5,humidity=45.2 1699429527000000000'
```
### 批量写入
```shell
curl -u"admin:public" -i -XPOST "http://127.0.0.1:8361/write?db=demo&precision=ns" \
  -d 'sensor,device_id=device_001 temperature=22.1,humidity=45.2 1699429527100000000
      sensor,device_id=device_002 temperature=23.4,humidity=45.3 1699429528000000000
      sensor,device_id=device_001 temperature=22.3,humidity=45.4 1699429530000000000'
```

## 注意事项

由于 Datalayers 底层存储结构与 InfluxDB 有差异，为了实现最佳的性能，你需要了解以下内容：

* 行协议中，每个 TAG 被转化为表中的一列，并且所有的 tag 会作为表的分区键
* TAG + TIMESTAMP 会建立唯一索引，用该索引表示数据库中唯一记录
* TAG 不能为空，一条记录中应至少有一个 tag
* 该协议仅针对 Datalayers 的时序引擎，其他表引擎使用该协议写入会被拒绝
