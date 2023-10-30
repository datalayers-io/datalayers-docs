# InfluxDB Line Protocol
DataLayers 兼容 InfluxDB Line Protocol。


## 兼容协议版本
[InfluxDB Line Protocol V1](https://docs.influxdata.com/influxdb/v1/write_protocols/line_protocol_tutorial/)  
[InfluxDB Line Protocol V2](https://docs.influxdata.com/influxdb/v2/reference/syntax/line-protocol/)  


## 路径

### Line Protocol V1  
```SHELL
HTTP://<HOST>:<PORT>/influxdb/v1/write

```


### Line Protocol V2  
```SHELL
HTTP://<HOST>:<PORT>/influxdb/v2/write

```

## 注意事项
由于 DataLayers 底层存储结构与 InfluxDB 有差异，为了实现最佳的性能，你需要了解以下内容：
* 行协议中，Tag 第一个字段会默认作为数据分区键
* TAG + TIMESTAMP 会建立唯一索引，用该索引表示数据库中唯一记录
* 该协议仅针对 DataLayers 的时序引擎，其他表引擎使用该协议写入会被拒绝