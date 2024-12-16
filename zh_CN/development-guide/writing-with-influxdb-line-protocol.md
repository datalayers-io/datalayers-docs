# InfluxDB Line Protocol

Datalayers 兼容 InfluxDB Line Protocol。  
[InfluxDB Line Protocol V1](https://docs.influxdata.com/influxdb/v1/write_protocols/line_protocol_tutorial/)  

## API 参考

```SHELL
HTTP://<HOST>:<PORT>/write

```

## 示例

```shell
curl -i -XPOST "http://127.0.0.1:8361/write?db=db_name&u=admin&p=public&precision=ns" -d 'weather,location=us-midwest temperature=82 1699429527'
```

## 注意事项

由于 Datalayers 底层存储结构与 InfluxDB 有差异，为了实现最佳的性能，你需要了解以下内容：

* 行协议中，每个 TAG 被转化为表中的一列，并且所有的 tag 会作为表的分区键
* TAG + TIMESTAMP 会建立唯一索引，用该索引表示数据库中唯一记录
* TAG 不能为空，一条记录中应至少有一个 tag
* 该协议仅针对 Datalayers 的时序引擎，其他表引擎使用该协议写入会被拒绝
