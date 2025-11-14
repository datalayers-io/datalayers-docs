# Datalayers Redis 兼容性说明

## 概述

Datalayers Key-Value 服务兼容大部分常用的 Redis 命令，详见下表。

## 支持命令总览

| <div style="width:150px">命令类别</div>        | 命令      | <div style="width:100px">支持级别</div>     | 备注 |
| ---           | ---       | ---         | --- |
| **连接管理**    | PING     | 完全支持      |     |
|                | SELECT   | 完全支持      | 支持 [0, 65535] 范围内的 index   |
| **通用命令**    | KEYS     | 完全支持      |     |
|                | DEL      | 完全支持      |     |
| **事务**       | MULTI     | 完全支持      |     |
|               | EXEC       | 完全支持     | 如果事务中的键与另一个节点上的事务发生冲突，将返回错误。此行为与Redis有所不同，但我们提供了重试事务的选项。 |
|               | DISCARD   | 完全支持       |     |
| **字符串**     | GET       | 完全支持       |           |
|               | SET       | 部分支持       | 支持语法: `SET key value` |
|               | INCR      | 完全支持       |     |
|               | INCRBY    | 完全支持       |     |
|               | DECR      | 完全支持       |     |
|               | DECRBY    | 完全支持       |     |
| **哈希**       | HSET      | 完全支持       |     |
|               | HGET      | 完全支持       |     |
|               | HDEL      | 完全支持       |     |
|               | HLEN      | 完全支持       |     |
| **集合**      | SADD       | 完全支持       |     |
|              | SMEMBERS   | 完全支持       |     |
|              | SCARD      | 完全支持       |     |
|              | SREM       | 完全支持       |     |
| **有序集合**   | ZADD      | 部分支持       | 支持语法: `ZADD key score member` |
|              | ZRANGE     | 部分支持       | 支持语法: `ZRANGE key start stop`。注意：时间复杂度为O(stop)，而非O(stop-start)。 |
|              | ZREM       | 完全支持       |     |
|              | ZCARD      | 完全支持       |     |

## 注意事项

- **完全支持**: 该命令得到了完全支持。尽管语法和行为应与Redis非常接近，但可能存在细微差异。具体细节请参见备注。
- **部分支持**: 该命令得到了部分支持。仅支持某些语法或功能。具体细节请参见备注。
