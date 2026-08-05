---
title: "Datalayers 查询并行度优化指南"
description: "介绍如何通过 parallel_degree Hint 调整 Datalayers 查询并行度，以平衡单查询性能与整体吞吐。"
---
# Datalayers 查询并行度优化指南

## 概述

在查询执行过程中，Datalayers 会结合服务端资源情况和查询特征，自动选择合适的并行度，以平衡单条查询性能与系统整体资源利用率。当默认优化策略无法满足性能目标或验证需求时，可以通过 `parallel_degree` Hint 对单条查询的并行执行度进行显式控制。

## 语法

通过 SQL Hint 指定当前查询的并行度：

```sql
SELECT /*+ SET_VAR(parallel_degree=1) */ * FROM table;
```

## 使用建议

- 大范围扫描、复杂聚合等重型查询，通常更适合较高并行度
- 高频、低延迟的小查询场景，可适当降低并行度以提升整体吞吐
- 调整 `parallel_degree` 时，建议结合压测结果、执行计划和实际资源使用情况综合评估
- 如果没有明确的性能目标或观测依据，建议优先使用系统默认并行策略

## 相关文档

- 了解 SQL Hints 总体能力，请参考 [SQL Hints 使用指南](./overview.md)
