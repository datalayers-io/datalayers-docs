---
title: "查询性能调优概述"
description: "Datalayers 查询性能调优概述：介绍数据建模、索引与配置优化等关键方法，帮助你在时序与分析场景中提升查询性能。"
---
# 查询性能调优概述

查询性能调优是一个系统工程，需要从数据模型、索引设计、缓存策略、并行度和执行计划等多个维度综合优化。除数据建模与索引外，合理的系统配置同样会显著影响查询延迟与吞吐。

本文用于概览 Datalayers 常见的查询优化方向，适合作为调优入口页使用。

## 常见优化方向

- 数据建模与分区设计
- 倒排索引、向量索引和普通索引的使用策略
- 查询并行度与 SQL Hints 调优
- 元数据缓存、数据缓存和 LAST CACHE 配置

## 相关文档

- 了解 SQL Hints，请参考 [SQL Hints 使用指南](./query-optimization/hints/overview.md)
- 了解索引缓存，请参考 [索引缓存调优指南](./query-optimization/index-cache-optimization.md)
- 了解混合数据缓存，请参考 [数据缓存优化指南](./query-optimization/hybrid-cache-optimization.md)
- 了解最新值查询优化，请参考 [LAST CACHE 优化指南](./query-optimization/last-cache-optimization.md)
