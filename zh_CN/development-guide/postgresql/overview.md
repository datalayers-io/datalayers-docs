---
title: "Datalayers PostgreSQL 协议兼容"
description: "介绍 Datalayers 对 PostgreSQL 网络连接协议的兼容能力、适用工具、使用约束与当前限制。"
---
# Datalayers PostgreSQL 协议兼容

Datalayers 兼容 PostgreSQL 网络连接协议，可对接 PostgreSQL 生态中的命令行工具、驱动和可视化客户端，方便在现有工具链中接入 Datalayers。

## 适用场景

- 希望使用 PostgreSQL 生态中的客户端工具连接 Datalayers
- 希望复用 PostgreSQL JDBC、连接池或 SQL IDE 进行开发调试
- 希望在不改动过多连接方式的前提下快速接入数据库

## 使用说明

- 使用 PostgreSQL 连接协议时，需使用 PostgreSQL 方言。
- 该协议仅为兼容 PostgreSQL 连接协议与 SQL 方言，函数需使用 Datalayers 中定义的函数。
- 支持 PostgreSQL 的连接、认证与 SQL 执行。
- 该协议暂不支持 TLS 连接。
- 该协议目前处于 Beta 状态。

## 相关文档

- 想了解 Datalayers 支持的连接方式，请参考 [连接方式总览](../connection.md)
- 想通过命令行工具直接操作数据库，请参考 [Datalayers 命令行工具 dlsql 使用指南](../../getting-started/command-line-tool.md)
