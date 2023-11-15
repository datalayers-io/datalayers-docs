# 系统监控

本系统采用 Datalayers Exporter 采集相关指标，并通过 Prometheus 获取并存储系统监控指标，采用 Grafana 可视化展示监控的指标数据，可监控 FoundationDB 和 Datalayers 的指标。


## 获取 Datalayers Exporter

```shell
docker run  ghcr.io/datalayers-io/datalayers-exporter:latest
```

Exporter 容器暴露端口为 `9555`

## 配置 Prometheus

获取 prometheus 官方镜像，并启动。

```shell
docker run -p 9090:9090 prom/prometheus
```

容器运行后，进入容器，在 `/etc/prometheus/prometheus.yml` 配置文件中增加一个任务，定时拉取 FoundationDB 指标数据：

``` yml
global:
  scrape_interval: 5s
  scrape_timeout: 5s
  evaluation_interval: 1m

- job_name: foundationdb
  honor_timestamps: true
  scrape_interval: 5s
  scrape_timeout: 5s
  metrics_path: /metrics-fdb
  scheme: http
  follow_redirects: true
  enable_http2: true
  static_configs:
  - targets:
    - datalayers-exporter:9555
```

再增加一个任务，定时拉取 Datalayers 指标数据：

``` yml
global:
  scrape_interval: 5s
  scrape_timeout: 5s
  evaluation_interval: 1m

- job_name: foundationdb
  honor_timestamps: true
  scrape_interval: 5s
  scrape_timeout: 5s
  metrics_path: /metrics-fdb
  scheme: http
  follow_redirects: true
  enable_http2: true
  static_configs:
  - targets:
    - datalayers-exporter:9555

- job_name: datalayers
  honor_timestamps: true
  scrape_interval: 5s
  scrape_timeout: 5s
  metrics_path: /metrics-dtls
  scheme: http
  follow_redirects: true
  enable_http2: true
  static_configs:
  - targets:
    - datalayers-exporter:9555
```


修改配置文件后，重新启动 Prometheus。


## Grafana 配置

### 添加 Prometheus 数据源

找到 Grafana 菜单 `Configuration - Data sources` ，或访问 `/datasources/new` 页面，选择 Prometheus 分类，进入页面后，填入 Prometheus Server 地址，根据需求填写其他配置，保存并通过测试后生效。

### 添加指标面板

添加 Prometheus 数据源后，可在 `Grafana - Dashboards` 手动添加指标面板，或通过以下 json 文件快速导入模版：

``` json
{

}
```



