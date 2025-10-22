# 概述

Key-Value 数据模型是 `Datalayers` 的核心能力之一，提供一个分布式的、具备事务性和强一致性保证的Key-Value存储系统，Datalayers 的 Key-Value 存储模型在使用上完全兼容 Redis 协议，并支持常用的数据数据结构，详见：[Redis 兼容](./redis-compatibility.md) 章节。

注：Key-Value 模型仅集群模式下支持。

## 要求
Key-Value 数据模型在 Datalayers 2.1.8 版本中发布，使用 Key-Value 时， Datalayers 的版本必须 >= 2.1.8。

## Features

* 完全兼容 Redis 协议，可使用 Redis 客户端接入。
* 支持常用 Redis 数据结构，参见：[Redis兼容性](./redis-compatibility.md)。
* 支持 TB 级别的 key-value 存储，能够极大降低服务器资源成本与运维成本。
* 迁移简单，不用修改代码即可从 Redis 迁移至 Datalayers。
