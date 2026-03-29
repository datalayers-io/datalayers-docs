---
title: "HTTP Connector"
description: "介绍 HTTP source connector 的配置方式、轮询模式和示例。"
---

# HTTP Connector

HTTP connector 通过单次或持续轮询 HTTP endpoint，将返回内容作为 source 输入。

## 适用场景

- 第三方 HTTP API 数据接入
- 内部服务接口轮询采集
- 没有消息队列时的轻量级持续拉取

## 配置项

| 配置项 | 类型 | 默认值 | 必选 | 说明 |
| --- | --- | --- | --- | --- |
| `connector` | STRING | 无 | Yes | 固定为 `http` |
| `endpoint` | STRING | 无 | Yes | 轮询地址，支持 `${...}` 时间变量 |
| `method` | STRING | `get` | No | HTTP 方法，支持 `GET` 和 `POST` |
| `poll` | STRING | `once` | No | 轮询模式，支持 `once` 或 `interval(<millis>)` |
| `timeout` | INT | 无 | No | 请求超时时间，单位秒 |
| `headers` | STRING | 无 | No | 请求头，格式为 `k1:v1;k2:v2` |
| `auth_type` | STRING | `none` | No | 鉴权类型，支持 `none` 和 `basic_auth` |
| `username` | STRING | 无 | No | Basic Auth 用户名 |
| `password` | STRING | 无 | No | Basic Auth 密码 |

鉴权约束如下：

- `auth_type='none'`：表示不使用鉴权。此时不能输入 `username`、`password`，否则会报错。
- `auth_type='basic_auth'`：表示使用 Basic Auth。此时必须同时输入 `username` 和 `password`。

Format 相关配置请参考 [Formats](./format.md)。其中 `parquet` 目前仅支持 `http` connector。

## endpoint 支持的时间变量

| 变量 | 说明 |
| --- | --- |
| `${now_ts}` | 当前 UTC 毫秒时间戳 |
| `${now_ts_sec}` | 当前 UTC 秒级时间戳 |
| `${now_iso}` | 当前 UTC RFC3339 时间 |
| `${now_date}` | 当前 UTC 日期，格式 `YYYY-MM-DD` |
| `${now_datetime}` | 当前 UTC 日期时间，格式 `YYYY-MM-DD HH:MM:SS` |
| `${now_compact}` | 当前 UTC 紧凑时间，格式 `YYYYMMDDHHMMSS` |

这些时间变量只能出现在 `endpoint` 中。对于 `poll='interval(...)'` 的 source，系统会在每次发起 HTTP 请求前重新计算这些变量，常用于：

- 传递时间窗口参数
- 构造带时间戳的查询串
- 访问按日期分区的 HTTP 路径

### 时间变量使用示例

下面是几个常见的 `endpoint` 模板：

```sql
-- 用毫秒时间戳作为查询参数
endpoint='http://127.0.0.1:18080/poll?ts=${now_ts}'

-- 用秒级时间戳作为查询参数
endpoint='http://127.0.0.1:18080/poll?ts_sec=${now_ts_sec}'

-- 传递 RFC3339 时间字符串
endpoint='http://127.0.0.1:18080/poll?time=${now_iso}'

-- 按日期访问分区路径
endpoint='http://127.0.0.1:18080/data/${now_date}/metrics.csv'

-- 构造紧凑时间格式的文件名
endpoint='http://127.0.0.1:18080/export_${now_compact}.csv'
```

如果上游接口会根据时间参数返回不同结果，建议将时间变量与 `poll='interval(...)'` 组合使用。

## 示例

### 1. 启动一个简单的本地 HTTP 服务

下面的 Python 示例会启动一个本地 HTTP 服务，并提供两个 endpoint：

- `http://127.0.0.1:18080/once`
- `http://127.0.0.1:18080/poll`

其中：

- `/once` 每次返回一行固定 CSV 数据
- `/poll` 每次访问都会返回一行新的 CSV 数据

```python
from http.server import BaseHTTPRequestHandler, HTTPServer
from datetime import datetime, timedelta, timezone
from urllib.parse import urlparse

HOST = "127.0.0.1"
PORT = 18080

poll_counter = 0
POLL_BASE_TIME = datetime(2025, 1, 1, 0, 0, 10, tzinfo=timezone.utc)


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        global poll_counter

        path = urlparse(self.path).path
        if path == "/once":
            body = "2025-01-01T00:00:03Z,sid-once,101\n"
        elif path == "/poll":
            poll_counter += 1
            ts = (POLL_BASE_TIME + timedelta(seconds=poll_counter)).strftime(
                "%Y-%m-%dT%H:%M:%SZ"
            )
            body = (
                f"{ts},sid-poll-{poll_counter},{200 + poll_counter}\n"
            )
        else:
            self.send_response(404)
            self.end_headers()
            return

        body_bytes = body.encode("utf-8")
        self.send_response(200)
        self.send_header("Content-Type", "text/csv; charset=utf-8")
        self.send_header("Content-Length", str(len(body_bytes)))
        self.end_headers()
        self.wfile.write(body_bytes)

    def log_message(self, format, *args):
        return


HTTPServer((HOST, PORT), Handler).serve_forever()
```

可以把这段脚本保存为 `simple_http_service.py`，然后在终端运行：

```bash
python3 simple_http_service.py
```

### 2. once 模式

```sql
CREATE DATABASE stream_demo_http;
USE stream_demo_http;

CREATE TABLE sink_http_once (
  ts TIMESTAMP(9),
  sid STRING,
  value FLOAT64,
  TIMESTAMP KEY(ts)
) ENGINE=TimeSeries
PARTITION BY HASH(sid) PARTITIONS 1;

CREATE SOURCE src_http_once (
  ts TIMESTAMP(9),
  sid STRING,
  value FLOAT64
) WITH (
  connector='http',
  endpoint='http://127.0.0.1:18080/once',
  method='GET',
  poll='once',
  format='csv'
);

CREATE PIPELINE p_http_once
SINK TO sink_http_once
AS
SELECT ts, sid, value
FROM src_http_once;
```

查询结果：

```sql
SELECT ts, sid, value FROM sink_http_once ORDER BY ts;
```

### 3. interval 模式

```sql
CREATE TABLE sink_http_poll (
  ts TIMESTAMP(9),
  sid STRING,
  value FLOAT64,
  TIMESTAMP KEY(ts)
) ENGINE=TimeSeries
PARTITION BY HASH(sid) PARTITIONS 1;

CREATE SOURCE src_http_poll (
  ts TIMESTAMP(9),
  sid STRING,
  value FLOAT64
) WITH (
  connector='http',
  endpoint='http://127.0.0.1:18080/poll?ts=${now_ts}',
  method='GET',
  poll='interval(200)',
  format='csv'
);

CREATE PIPELINE p_http_poll
SINK TO sink_http_poll
AS
SELECT ts, sid, value
FROM src_http_poll
WHERE value >= 201.0;
```

等待一段时间后查询：

```sql
SELECT ts, sid, value FROM sink_http_poll ORDER BY ts;
```

## 注意事项

- 当前 HTTP connector 仅支持作为 source，不支持作为 sink
- `poll='once'` 适合一次性抓取，`poll='interval(...)'` 适合持续轮询
- `format='parquet'` 目前仅支持 `http` connector，且按整个 payload 解码一份完整 Parquet 文件
