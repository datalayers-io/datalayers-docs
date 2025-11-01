# 数据查询指南

## 概述


Datalayers 提供基于 HTTP/HTTPS 协议的 SQL 查询接口，支持通过 REST API 执行各类数据检索操作。查询结果以结构化 JSON 格式返回，包含完整的元数据信息。SQL 相关语法请参考：[SQL Reference](../sql-reference/data-type.md)。

## 基础语法
**通用请求格式**
```shell
curl -u"<username>:<password>" -X POST \
http://127.0.0.1:8361/api/v1/sql?db=<database_name> \
-H 'Content-Type: application/binary' \
-d '<SQL STATEMENT>'
```

## 查询数据示例

执行请求：

```shell
curl -u"admin:public" -X POST \
http://127.0.0.1:8361/api/v1/sql?db=demo \
-H 'Content-Type: application/binary' \
-d 'SELECT * FROM sensor_info'
```

返回值：

```json
{
	"result": {
		"columns": ["ts", "sn", "speed", "longitude", "latitude"],
		"types": ["TIMESTAMP(3)", "INT32", "INT32", "REAL", "REAL"],
		"values": [
			["2024-09-22T17:30:56.349+08:00", 1, 120, 104.07, 30.59],
			["2024-09-22T17:30:56.349+08:00", 2, 120, 104.07, 30.59]
		]
	}
}
```

其中，`result`表示这是一条查询的结果,`columns` 为列名，`types` 为列类型，`values` 为查询到的行数组。需要注意的是，类型中时间戳的表示为`Timestamp(TimeUnit, Timezone)`，当某列类型是时区未被指定的时间戳时，Timezone为None。例如`Timestamp(Millisecond, None)`。

