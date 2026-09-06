---
title: "Datalayers SQL Hints 使用指南"
description: "介绍 Datalayers SQL Hints 的使用方式和适用场景，帮助你在特定查询中手动调整优化策略。"
---
# SQL Hints 使用指南

## 概述

SQL Hints 是嵌入在 SQL 语句中的特殊注释指令，用于向查询优化器提供额外的执行策略建议。对于大多数查询，Datalayers 会自动选择合适的执行方案；当默认策略无法满足性能目标或验证需求时，可以通过 Hints 对单条查询的优化行为进行显式控制。

目前 Datalayers 支持以下 SQL Hints：

- 查询并行度控制：使用 `parallel_degree` 调整单条查询的并行执行度
- 混合缓存控制：使用 `hybrid_cache` 指定当前查询是否使用 Hybrid Cache
- Index Hints：引导优化器选择更合适的索引访问路径

## 适用场景

SQL Hints 更适合用于以下场景：

- 查询性能调优，需要针对特定 SQL 做定向优化
- 基准测试或问题排查，需要固定某类执行策略以便对比结果
- 已经明确了解查询特征，希望在局部场景中覆盖默认优化决策

## 注意事项

- 用户手动指定的 Hint 具有更高优先级，会覆盖优化器对当前查询的默认决策
- SQL Hints 应优先用于局部优化，不建议将其作为替代系统级调优的常规手段
- 在生产环境中使用 Hint 前，建议结合执行计划和压测结果验证实际收益

## 相关文档

- 了解并行度控制，请参考 [查询并行度优化指南](./parallel-degree.md)
- 了解混合缓存控制，请参考 [混合缓存控制使用指南](./hybrid-cache.md)
- 了解 Index Hints，请参考 [Index Hints 使用指南](./index.md)
