# Prometheus 协议

## 概述

Datalayers 兼容 Prometheus 的远程写入协议（Remote Write Protocol） 与 PromQL（Prometheus Query Language）查询语言，支持与 Prometheus 原生生态工具的无缝集成。
这意味着您可以：

- 继续使用现有的 Prometheus 数据采集配置（如 Prometheus Server、vmagent、Exporter 等），仅需调整数据写入目标，即可将监控数据推送至 Datalayers；
- 使用 Grafana 等可视化工具直接查询 Datalayers 中的监控数据，无需重写查询语句；
- 在不改变现有监控体系架构的前提下，逐步将 Datalayers 作为 Prometheus 的补充存储层，或直接作为替代方案，以满足更高性能、更大规模、更优成本等需求。

## 主要优势

- **无缝集成**  
  支持 Prometheus 原生 Remote Write 协议，无需修改现有采集配置，即可将数据推送至 Datalayers。
- **查询兼容**  
  全面支持标准的 PromQL（Prometheus Query Language），您可以使用与 Prometheus 完全一致的查询语法，对监控数据进行实时检索、聚合与分析，学习与迁移成本极低。
- **生态兼容**  
  与 Prometheus 原生生态工具（如 Grafana）天然兼容，无需额外适配或开发，即可快速对接现有监控体系，大幅降低迁移与使用门槛。
- **集群支持**  
  原生分布式支持，可通过水平扩展实现计算与存储能力的扩展。
- **低存储成本**  
   Datalayers 支持与主流云厂商的对象存储服务（Object Storage）无缝集成，包括：
  - 阿里云 OSS
  - 华为云 OBS
  - 腾讯云 COS
  - AWS S3
  - Azure Blob Storage
  - Google Cloud Storage (GCS)

  同时，对于兼容 S3 协议的第三方对象存储服务（如 MinIO），支持零代码接入，帮助您以极低的成本实现监控数据的长期、安全、高效存储。
