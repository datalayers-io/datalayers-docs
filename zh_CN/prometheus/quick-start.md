# Remote Write

通过 Prometheus Remote Write 协议，可以将 Prometheus 中的数据快速导入 Datalayers。为此，您需要在 Prometheus 的配置文件中增加以下内容，将 Datalayers 设置为 Remote Write 端点：

```
remote_write:
- url: https://<host>:<port>/api/v1/write
  basic_auth:
    username: <username>
    password: <password>
  headers:
    database: <dbname>
```

其中：

- `<host>` 和 `<port>` 分别表示 Datalayers 的 IP 地址和 HTTP 端口号
- `<dbname>` 表示数据将要导入的数据库名称，该数据库需要预先创建
- `<username>` 和 `<password>` 表示用于认证的用户名和密码

# HTTP API

导入 Datalayers 的数据可以通过以下 Prometheus HTTP API 进行查询：

- Instant queries: `/api/v1/query`
- Range queries: `/api/v1/query_range`
- Series: `/api/v1/series`
- Label names: `/api/v1/labels`
- Label values: `/api/v1/label/<label_name>/values`

这些接口的输入和输出与 Prometheus 保持一致，可以作为其直接替换。例如，您可以通过如下请求查询指标 `up` 在 `2025-07-22T10:00:00Z` 时刻的数据：

```
curl -v \
  -u admin:public \
  -H "database:prom" \
  -d "query=up&time=2025-07-22T10:00:00Z" \
  "http://localhost:9090/api/v1/query"
```

收到的响应形式如下：

```
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

更多关于 HTTP API 的内容可参考![官方文档](https://prometheus.io/docs/prometheus/latest/querying/api/)。

## 注意事项

相较于 Prometheus，Datalayers 有额外的数据库的概念，每个 metric 都归属于某个数据库，因此在查询时需要显式指明数据库的名称。

您可以通过两种方式指定数据库：

1. 在 HTTP 请求的 header 中增加 `database: <dbname>`，之后查询的 metric 都会默认归属该数据库
2. 或者通过标签 `__database__` 指定数据库，如 `up{__database__="dbname"}`。通过这种方式可以覆盖 HTTP header 中指定的数据库。

# Grafana

您可以直接将 Datalayers 作为 Prometheus 数据源添加到 Grafana 中，具体步骤如下：

1. 在 Grafana 中 点击 Add new data source，选择 Prometheus 作为数据源

2. 在 Remote server URL 中填入 Datalayers 的地址 `http://<host>:<port>`

3. 在 Authentication method 中选择 Basic authentication，填入用户名和密码

4. 在 Http headers 中增加 header `database: <dbname>`

5. 点击 Save & Test 进行连通性测试，通过后进入面板编写 PromQL 进行查询
