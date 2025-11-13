# 快速开始

Datalayers 完全兼容 Prometheus Remote Write 协议，可无缝承接 Prometheus 数据流。本指南将帮助您快速完成数据接入和查询配置。

## 数据写入配置

### 配置 Prometheus Remote Write

通过 Prometheus Remote Write 协议，可以将 Prometheus 中的数据快速导入 Datalayers。为此，您需要在 Prometheus 的配置文件中增加以下内容，将 Datalayers 设置为 Remote Write 端点：

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

这些接口的输入和输出与 Prometheus 保持一致。例如，您可以通过如下请求查询指标 `up` 在 `2025-07-22T10:00:00Z` 时刻的数据：

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

相较于 Prometheus，Datalayers 有额外的数据库的概念，每个 metric 都归属于某个数据库，因此在查询时需要显式指明数据库的名称。可通过以下两种方式指定数据库：

1. 在 HTTP 请求的 header 中增加 `database: <dbname>`，之后查询的 metric 都会默认归属该数据库
2. 或者通过标签 `__database__` 指定数据库，如 `up{__database__="dbname"}`。通过这种方式可以覆盖 HTTP header 中指定的数据库。

## Grafana 集成配置

您可以直接将 Datalayers 作为 Prometheus 数据源添加到 Grafana 中，具体步骤如下：

- 在 Grafana 中 点击 Add new data source，选择 Prometheus 作为数据源
- 在 Remote server URL 中填入 Datalayers 服务中配置的 Prometheus 协议地址 `http://<host>:<port>`
- 在 Authentication method 中选择 Basic authentication，填入用户名和密码
- 在 Http headers 中增加 header `database: <dbname>`
- 点击 Save & Test 进行连通性测试，通过后进入面板编写 PromQL 进行查询
