# InfluxDB Line Protocol
DataLayers 兼容 InfluxDB Line Protocol。  
[InfluxDB Line Protocol V1](https://docs.influxdata.com/influxdb/v1/write_protocols/line_protocol_tutorial/)  
**注**： InfluxDB Line Protocol 兼容，认证统一使用 DataLayers REST API 的[认证](./auth-with-restapi.md)。

## API 参考

```SHELL
HTTP://<HOST>:<PORT>/write

```

## 示例 
```shell
curl -u"admin:public" -i -XPOST "http://127.0.0.1:3333/write?db=db_name" -d 'weather,location=us-midwest temperature=82 1699429527'
```

## 注意事项
由于 DataLayers 底层存储结构与 InfluxDB 有差异，为了实现最佳的性能，你需要了解以下内容：
* 行协议中，Tag 第一个字段会默认作为数据分区键
* TAG + TIMESTAMP 会建立唯一索引，用该索引表示数据库中唯一记录
* 该协议仅针对 DataLayers 的时序引擎，其他表引擎使用该协议写入会被拒绝
* TAG Value 将使用字符串进行存储
