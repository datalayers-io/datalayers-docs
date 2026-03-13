---
title: "Datalayers SQL Hints 使用指南"
description: "介绍 Datalayers SQL Hints 的使用方式和适用场景，帮助你在特定查询中手动调整优化策略。"
---
# SQL Hints 使用指南

## 概述

SQL Hints 是嵌入在 SQL 中的特殊注释指令，用于向优化器提供执行策略建议。当默认优化策略无法达到预期效果时，可以通过 Hints 对并行度、索引选择等行为进行显式控制。

目前 Datalayers 支持以下 SQL Hints：

- 查询并行度(parallel_degree)控制
- Index Hints

## 相关文档

- 了解并行度控制，请参考 [查询并行度优化指南](./parallel-degree.md)
- 了解索引提示，请参考 [Index Hints 使用指南](./index.md)
