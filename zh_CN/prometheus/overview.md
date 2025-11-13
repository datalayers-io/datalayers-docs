# 概述
Datalayers 支持 Prometheus 的 HTTP API 和 Remote Write 协议。通过这一特性，用户可以将现有的 Prometheus 生态工具无缝接入 Datalayers，无需修改代码即可实现数据写入和查询。

# 主要特性
- 兼容 Prometheus HTTP API，可直接对接 Grafana 等生态组件。
- 兼容 Prometheus Remote Write 协议，可接收 Prometheus 的实时数据推送。
- 支持 PromQL (Prometheus Query Language)，兼容主流查询语法与函数。

# 核心价值
- 平滑迁移： 无需修改现有的数据采集和可视化工具链。
- 高性能/长期存储： 利用 Datalayers 的存储优势，解决原生 Prometheus 在大规模或长期存储场景下的性能和容量瓶颈。