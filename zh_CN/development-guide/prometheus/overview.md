---
title: "Datalayers Prometheus 协议兼容"
description: "介绍 Datalayers 对 Prometheus Remote Write 与 PromQL 的兼容能力，适用于监控数据接入、查询与 Grafana 集成。"
---
# Datalayers Prometheus 协议兼容

## 概述

Datalayers 兼容 Prometheus 的 Remote Write 协议与 PromQL 查询语言，可直接接入现有 Prometheus 与 Grafana 生态，用于承接监控指标写入、查询与可视化。

## 适用场景

- 将现有 Prometheus 指标写入 Datalayers
- 复用 PromQL 查询已有监控数据
- 与 Grafana 配合构建统一监控与分析看板

这意味着你可以：

- 继续使用现有的 Prometheus 采集配置，只需调整 Remote Write 目标地址，即可将监控数据写入 Datalayers；
- 使用 Grafana 等可视化工具直接查询 Datalayers 中的监控数据，无需重写 PromQL；
- 在不大幅改动现有监控体系的前提下，将 Datalayers 作为 Prometheus 的长期存储层或替代方案。

## 相关文档

- 了解完整能力介绍，请参考 [Datalayers Prometheus 协议兼容](../../prometheus/overview.md)
- 了解写入配置与查询示例，请参考 [Prometheus 快速开始](../../prometheus/quick-start.md)
