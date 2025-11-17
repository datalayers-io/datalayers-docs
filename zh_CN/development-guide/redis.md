# 键值存储使用指南

## 概述

Datalayers 支持兼容 Redis 协议的高性能分布式键值存储服务，支持直接通过标准 Redis 客户端、命令行工具（如 redis-cli）及生态工具无缝接入，无需额外适配。详见[键值存储](../key-value-data-model/overview.md)

## 注意事项
- 通过该协议连接仅支持 key-value 相关操作
- 目前 key-value 存储的数据暂不能通过  SQL 互通
- key-value 存储能力仅在集群模式下支持
