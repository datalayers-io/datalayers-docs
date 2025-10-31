# SQL Hints 使用指南

## 概述
SQL Hints 是一种在 SQL 查询中嵌入的特殊注释指令，用于向数据库优化器提供执行策略建议。当优化器无法自动选择最优执行计划时，通过 Hints 可以手动干预查询执行方式，从而提升查询性能或纠正优化器的决策偏差。

目前 Datalayers 支持以下 SQL Hints
- 查询并行度(parallel_degree)控制
- Index Hits
