# 日志检索概述

## 什么是日志检索

日志检索是基于日志文本内容进行快速查询、过滤与排序的能力。Datalayers 通过全文检索函数与倒排索引，为日志场景提供低延迟检索体验。

## 核心能力

- 支持 `MATCH` / `QUERY` 两类全文查询表达式
- 支持 `SCORE()` 相关性评分与排序
- 支持在 `STRING` 列上创建倒排索引进行加速

## 典型流程

1. 设计日志表结构（日志内容列使用 `STRING` 类型）
2. 为日志内容列创建倒排索引
3. 对历史数据执行 `REFRESH INDEX`（如果索引创建前已有数据）
4. 使用 `MATCH` 或 `QUERY` 执行日志检索

## 相关文档

- 全文函数：[全文索引函数](../sql-reference/fulltext-functions.md)
- 创建索引：[CREATE 语句（含 CREATE INVERTED INDEX / CREATE VECTOR INDEX）](../sql-reference/statements/create.md)
- 刷新索引：[REFRESH 语句详解](../sql-reference/statements/refresh.md)
- 删除索引：[DROP 语句详解](../sql-reference/statements/drop.md)
- 快速开始：[日志检索快速开始](./quick-start.md)
