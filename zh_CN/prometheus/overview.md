# Prometheus 协议兼容

## 概述

Datalayers 兼容 Prometheus 的远程写入协议（Remote Write Protocol） 与 PromQL（Prometheus Query Language）查询语言，支持与 Prometheus 原生生态工具的无缝集成。
这意味着您可以：

- 继续使用现有的 Prometheus 数据采集配置，仅需调整数据写入目标，即可将数据推送至 Datalayers，实现大规模数据长期低成本存储；
- 使用 Grafana 等可视化工具直接查询 Datalayers 中的监控数据，无需重写查询语句；
- 在不改变现有监控体系架构的前提下，将 Datalayers 作为 Prometheus 的替代方案，以满足高性能、大规模、低存储成本等需求。

## 主要优势

- **无缝集成**  
  支持 Prometheus Remote Write 协议，可接收 Prometheus 的实时数据推送。
- **生态兼容**  
  兼容标准的 PromQL（Prometheus Query Language） 与 HTTP API，可直接对接 Grafana 等生态组件对接。
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

  ```text
  同时，对于兼容 S3 协议的第三方对象存储服务（如 MinIO），支持零代码接入，帮助您以极低的成本实现监控数据的长期、安全、高效存储。
  ```

- **高性能/长期存储**：利用 Datalayers 的存储优势，解决原生 Prometheus 在大规模或长期存储场景下的性能和容量瓶颈。  
