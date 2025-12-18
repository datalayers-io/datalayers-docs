# 数据库连接指南

## 概述

Datalayers 提供多种协议支持，满足不同场景下的数据库连接和交互需求。用户可根据性能要求、开发生态和集成复杂度等因素选择合适的连接协议。

## 用户与权限

Datalayers 支持多种认证机制与细粒度的权限控制。默认为静态认证，初始帐号密码为：`admin/public`。  
更多介绍参考 [连接认证与权限](../user-security/authentication/overview.md)

## 端口说明

下表列出 Datalayers 支持的协议及其对应的默认端口号，您可以在配置文件中按需修改这些端口：

| 协议类型                              | 默认端口          |   用途简述​                                                  |  是否默认开启​ |
| -------------                        | -----------       | -----------------------------------------------------      |  --------    |
| **Arrow Flight SQL 高速传输协议**     | 8360              | 高性能、低延迟的 SQL 查询传输协议（基于 Arrow 格式）           |  ✅ 是       |
| **PostgreSQL 连接协议**               | 5342              | 标准 PostgreSQL 连接协议（如 JDBC/ODBC 使用）                 | ✖ 否        |
| **Prometheus 协议**                  | 9090              | 兼容 PromQL 与 Remote-Write协议，可用于 Prometheus 补充或替换  | ✖ 否        |
| **REST API**                        | 8361               | 基于 HTTP 的通用接口，用于查询、管理、元数据获取等              | ✅ 是       |
| **InfluxDB 行协议**                  | 8361               | 用于写入 InfluxDB 格式的时序数据                              | ✅ 是       |
| **Redis 协议**                      | 6379                | 兼容 Redis 协议的访问（如使用 redis-cli 连接）                | ✖ 否        |

## 支持的协议

### Arrow Flight SQL（推荐用于高性能场景）

- **协议特点**：基于 Apache Arrow 内存格式和 Flight RPC 框架的高性能 SQL 交互协议
- **性能优势**：在数据传输场景下，相比 JDBC/ODBC 等驱动数据传输方案，性能提升可达百倍
- **适用场景**：对性能有高要求的数据写入与查询场景

### PostgreSQL 协议（Beta）

- **兼容性**：完整兼容 PostgreSQL 网络连接协议
- **工具生态**：支持 PostgreSQL 生态的命令行工具、JDBC/ODBC 驱动及各类可视化工具
- **当前状态**：该协议正在开发中，计划近期正式发布

### Prometheus 协议

- **兼容性**：兼容 `PromQL` 查询语言以及 `Remote-Write` 协议
- **工具生态**： 可使用 Prometheus 生态相关工具、组件快速集成

### REST API

- **交互方式**：通过标准的 RESTful API 接口执行 SQL 操作
- **适用场景**：适合需要 HTTP 协议集成的应用场景

### InfluxDB 行协议

- **功能特性**：专为时序数据写入优化的行协议
- **使用限制**：该协议仅支持数据写入操作
- **适用场景**：InfluxDB 兼容的时序数据摄入

### Redis 协议

- **兼容性**：完全兼容 Redis 协议
- **适用场景**：分布式、海量键值存储需求

## 协议选择建议

| 特性                                 |  适用场景                       |  功能支持           | 备注                 |
| -------------                        | -----------------------       | --------------------| -------------------  |
| **Arrow Flight SQL 高速传输协议**     | 高性能写入、查询与大数据量传输   | 完整读写            | 完整功能              |
| **PostgreSQL 连接协议（Beta）**      | PostgreSQL 生态集成             | 完整读写            | 认证与 SQL 执行       |
| **Prometheus 协议**                 | Prometheus 生态集成             | 完整读写            | Prometheus 为单值模型，使用上存在细微差异  |
| **REST API**                         | HTTP 集成、简单查询             | 完整读写            | 完整读写              |
| **InfluxDB 行协议**                  | 替换 InfluxDB 场景              | 仅支持写入          | 仅支持写入             |
| **Redis 协议**                      | 键值存储场景                     | 完整读写            | 仅支持 key-value 操作             |

## 推荐选择

- 对于性能敏感的生产环境，建议使用 Arrow Flight SQL 协议
- 如需使用现有 PostgreSQL 工具链，可使用 PostgreSQL 协议（目前该协议处于 Beta 阶段）
- 如需使用现有 Prometheus 工具链，可使用 Prometheus 协议
- 如需使用现有 InfluxDB 工具链写入，可使用 InfluxDB 行协议
- 键值存储需求场景，可使用 Redis 协议接入
- 如上述相关协议均不能满足的情况，可使用 REST API 协议
