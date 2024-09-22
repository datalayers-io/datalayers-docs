# OpenTelemetry
Datalayers 支持 InfluxDB 的行协议，因此可以通过 OpenTelemetry Collector 的 InfluxDB Exporter 插件与 Datalayers 实现集成。

![architecture diagram](../assets/architecture-diagram.png)

## OpenTelemetry Collector
OpenTelemetry Collector 官方提供了 [Core](https://hub.docker.com/r/otel/opentelemetry-collector/tags)、 [Contrib](https://hub.docker.com/r/otel/opentelemetry-collector-contrib)   两个不同的版本。 其中前者只包基础的插件， 后者包含了所有的插件。Core 版本中没有 influxdb exporter 插件，而 Contrib 版本中有。也可以按需自己构建镜像， 只包含自己需要的插件， 建议生产环境采用这种方式， 参考：[Building a custom collector](https://opentelemetry.io/docs/collector/custom-collector)

InfluxDB Exporter 详细文档参考：[influxdb-exporter](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/exporter/influxdbexporter)

### 配置项说明


The following configuration options are supported:

* `endpoint` (required) HTTP/S destination for line protocol
  - if path is set to root (/) or is unspecified, it will be changed to /api/v2/write.
* `timeout` (default = 5s) Timeout for requests
* `headers`: (optional) additional headers attached to each HTTP request
  - header `User-Agent` is `OpenTelemetry -> Influx` by default
  - if `token` (below) is set, then header `Authorization` will overridden with the given token
* `org` (required) Name of InfluxDB organization that owns the destination bucket
* `bucket` (required) name of InfluxDB bucket to which signals will be written
* `token` (optional) The authentication token for InfluxDB
* `v1_compatibility` (optional) Options for exporting to InfluxDB v1.x
  * `enabled` (optional) Use InfluxDB v1.x API if enabled
  * `db` (required if enabled) Name of the InfluxDB database to which signals will be written
  * `username` (optional) Basic auth username for authenticating with InfluxDB v1.x
  * `password` (optional) Basic auth password for authenticating with InfluxDB v1.x
* `span_dimensions` (default = service.name, span.name) Span attributes to use as dimensions (InfluxDB tags)
* `log_record_dimensions` (default = service.name) Log Record attributes to use as dimensions (InfluxDB tags)
* `payload_max_lines` (default = 10_000) Maximum number of lines allowed per HTTP POST request
* `payload_max_bytes` (default = 10_000_000) Maximum number of bytes allowed per HTTP POST request
* `metrics_schema` (default = telegraf-prometheus-v1) The chosen metrics schema to write; must be one of:
  * `telegraf-prometheus-v1`
  * `telegraf-prometheus-v2`
* `sending_queue` [details here](https://github.com/open-telemetry/opentelemetry-collector/blob/v0.25.0/exporter/exporterhelper/README.md#configuration)
  * `enabled` (default = true)
  * `num_consumers` (default = 10) The number of consumers from the queue
  * `queue_size` (default = 1000) Maximum number of batches allowed in queue at a given time
* `retry_on_failure` [details here](https://github.com/open-telemetry/opentelemetry-collector/blob/v0.25.0/exporter/exporterhelper/README.md#configuration)
  * `enabled` (default = true)
  * `initial_interval` (default = 5s) Time to wait after the first failure before retrying
  * `max_interval` (default = 30s) Upper bound on backoff interval
  * `max_elapsed_time` (default = 120s) Maximum amount of time (including retries) spent trying to send a request/batch


详见: [influxdb-exporter configuration](https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/main/exporter/influxdbexporter/README.md)


## 最简 OpenTelemetry Collector 配置示例

```yaml
receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
      http:
        endpoint: 0.0.0.0:4318
exporters:
  influxdb:
    endpoint: http://172.31.104.77:8361
    v1_compatibility:
      enabled: true
      db: demo
      username: admin
      password: public
service:
  extensions: []
  pipelines:
    traces:
      receivers: [otlp]
      processors: []
      exporters: [influxdb]
```

配置中 Exporter 的 endpoint 需要替换成自己的 Datalayers 地址。由于当前 Datalayers 默认只支持 v1 版本的 InfluxDB Line Protocol，所以需要将 v1_compatibility 设置为 true。要使用的数据库名称需要提前在 Datalayers 中创建。 在 receivers 中选择一个协议，比如 otlp，和协议对应的 endpoint 配置。 从 receivers 中收到的数据会被 processor 处理，这里没有配置，所以直接发送到 exporters， 即为 Datalayers。当 Datalayers 收到数据后，会根据配置的数据库名称，将数据写入到对应的数据库中， 如果没有对应的表， 则会自动创建(如果关闭了 Datalayers 的自动创建表功能， 则需要提前在 Datalayers 中创建表)。





