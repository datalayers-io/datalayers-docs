# Prometheus 协议

## 概述

Datalayers 兼容 Prometheus 的远程写入协议（Remote Write Protocol） 与 PromQL（Prometheus Query Language）查询语言，支持与 Prometheus 原生生态工具的无缝集成。
这意味着您可以：

- 继续使用现有的 Prometheus 数据采集配置，仅需调整数据写入目标，即可将监控数据推送至 Datalayers；
- 使用 Grafana 等可视化工具直接查询 Datalayers 中的监控数据，无需重写查询语句；
- 在不改变现有监控体系架构的前提下，可将 Datalayers 作为 Prometheus 的补充存储层，或直接作为替代方案，以满足更高性能、更大规模、更优成本的需求。

详见 [Prometheus 兼容](../../prometheus/overview.md)
