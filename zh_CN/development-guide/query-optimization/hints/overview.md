# 概述
SQL Hints 是一种在 SQL 查询中嵌入的特殊指令，用于指导数据库优化器选择特定的执行计划，从而提升查询性能或解决优化器的决策偏差。Datalayers 在 v2.3.9 开始支持该特性。

目前 Datalayers 支持以下 SQL Hints
- 查询并行度(parallel_degree)
- Index Hits
