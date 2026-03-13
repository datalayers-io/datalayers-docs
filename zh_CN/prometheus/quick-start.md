---
title: "Prometheus 快速开始"
description: "通过 Prometheus Remote Write 与 PromQL API 快速验证 Datalayers 的监控数据接入、查询和 Grafana 集成能力。"
---
# Prometheus 快速开始

本文演示如何通过 Prometheus Remote Write 将监控数据写入 Datalayers，并通过 PromQL API 与 Grafana 完成查询验证。

## 数据写入配置

### 配置 Prometheus Remote Write

通过 Prometheus Remote Write 协议，可以将 Prometheus 采集到的指标直接写入 Datalayers。为此，需要在 Prometheus 配置文件中增加以下内容，将 Datalayers HTTP 服务地址设置为 Remote Write 端点：

```yaml
remote_write:
- url: https://<host>:<port>/api/v1/write
  basic_auth:
    username: <username>
    password: <password>
  headers:
    database: <dbname>
```

**参数说明**：

- `<host>` 和 `<port>`：Datalayers 服务地址和 HTTP 端口
- `<username>` 和 `<password>`：认证凭据（默认：admin/public）
- `<dbname>`：目标数据库名称（需预先创建）

### 配置示例

```yaml
# 实际配置示例
remote_write:
  - url: "http://localhost:9090/api/v1/write"
    basic_auth:
      username: admin
      password: public
    headers:
      database: prometheus_metrics
```

## 数据查询 API

Datalayers 提供完整的 Prometheus HTTP API 兼容接口：

- Instant queries: `/api/v1/query`
- Range queries: `/api/v1/query_range`
- Series: `/api/v1/series`
- Label names: `/api/v1/labels`
- Label values: `/api/v1/label/<label_name>/values`

### 查询示例

这些接口的输入和输出与 Prometheus 保持一致。例如，可以通过如下请求查询指标 `up` 在 `2025-07-22T10:00:00Z` 时刻的数据：

```shell
curl -v \
  -u admin:public \
  -H "database:prom" \
  -d "query=up&time=2025-07-22T10:00:00Z" \
  "http://localhost:9090/api/v1/query"
```

### 响应格式

```json
{
  "status": "success",
  "data": {
    "resultType": "vector",
    "result": [
      { "metric": { "__name__": "up", "sid": "s1", "flag": "ok" }, "value": [ 1753178400.0, "1" ] },
      { "metric": { "__name__": "up", "sid": "s2", "flag": "fail" }, "value": [ 1753178400.0, "0" ] },
      { "metric": { "__name__": "up", "sid": "s3", "flag": "ok" }, "value": [ 1753178400.0, "2" ] }
    ]
  }
}
```

更多关于 API 的内容可参考 [Prometheus 官方文档](https://prometheus.io/docs/prometheus/latest/querying/api/)。

### 注意事项

相较于 Prometheus，Datalayers 额外引入了数据库的概念，每个 metric 都归属于某个数据库，因此查询时需要显式指定数据库名称。可通过以下两种方式指定：

1. 在 HTTP 请求的 header 中增加 `database: <dbname>`，之后查询的 metric 都会默认归属该数据库
2. 或者通过标签 `__database__` 指定数据库，如 `up{__database__="dbname"}`。通过这种方式可以覆盖 HTTP header 中指定的数据库。

## Grafana 集成配置

您可以直接将 Datalayers 作为 Prometheus 数据源添加到 Grafana 中，具体步骤如下：

- 在 Grafana 中 点击 Add new data source，选择 Prometheus 作为数据源
- 在 Remote server URL 中填入 Datalayers HTTP 服务地址 `http://<host>:<port>`
- 在 Authentication method 中选择 Basic authentication，填入用户名和密码
- 在 Http headers 中增加 header `database: <dbname>`
- 点击 Save & Test 进行连通性测试，通过后进入面板编写 PromQL 进行查询
