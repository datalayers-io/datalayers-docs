---
title: "全文检索概述"
description: "介绍 Datalayers 基于倒排索引的全文检索能力，包括适用范围、核心函数、索引机制与典型使用流程。"
---
# 全文检索概述

## 什么是全文检索

Datalayers 的全文检索能力基于倒排索引，面向 `STRING` 列中的文本内容提供关键词、短语和布尔表达式检索。相比直接对整列文本做扫描，全文检索更适合日志、事件、审计记录等文本密集型场景，可在海量数据中更快定位目标记录。

## 适用范围

全文检索当前主要用于以下类型的数据：

- 日志正文、错误信息、异常堆栈等运维数据
- 事件描述、告警内容、审计说明等文本字段
- 需要按关键词、短语或布尔条件进行检索的业务文本

待检索列建议使用 `STRING` 类型，并在该列上创建倒排索引，以获得稳定的检索性能与相关性排序能力。

## 核心能力

- 支持 `MATCH`：适合关键词检索和简单多词匹配
- 支持 `QUERY`：适合短语检索、布尔表达式和更复杂的查询条件
- 支持 `SCORE()`：返回命中结果的相关性评分，用于排序
- 支持在 `STRING` 列上创建 `INVERTED INDEX` 以加速全文检索
- 支持通过 `tokenizer`、`filters`、`with_position` 配置索引行为

## 使用约束

- `MATCH` 和 `QUERY` 只能出现在 `WHERE` 子句中
- 单条查询中最多只能使用一个全文检索函数：`MATCH` 或 `QUERY`
- `SCORE()` 必须与 `MATCH` 或 `QUERY` 一起使用
- 如果索引创建前已经存在历史数据，需要执行 `REFRESH INDEX` 补建索引

## 典型使用流程

1. 在表中准备待检索的 `STRING` 列，例如 `message`
2. 在该列上创建倒排索引，并按文本语言选择合适的分词器
3. 如有历史数据，执行 `REFRESH INDEX` 构建存量索引
4. 使用 `MATCH` 或 `QUERY` 发起检索，并可通过 `ORDER BY SCORE() DESC` 按相关性排序

## 应用场景

### 日志与事件检索

- 按关键词快速定位错误日志、超时日志或特定异常
- 结合短语检索和布尔条件缩小排查范围

### 审计与问题排查

- 从审计记录、操作说明或事件描述中检索关键文本
- 使用相关性评分优先查看最可能命中的结果

### 向量混合检索

- 向量与关键词的混合检索（RAG 场景）

## 相关文档

- 全文索引函数：[全文索引函数](../sql-reference/fulltext-functions.md)
- 创建索引：[CREATE 语句（含 CREATE INVERTED INDEX / CREATE VECTOR INDEX）](../sql-reference/statements/create.md)
- 刷新索引：[REFRESH 语句详解](../sql-reference/statements/refresh.md)
- 删除索引：[DROP 语句详解](../sql-reference/statements/drop.md)
- 快速开始：[全文检索快速开始](./quick-start.md)
