# 概述

Datalayers Key-Value 存储服务是一个分布式、支持事务、强一致性的高性能键值存储系统。该服务完全兼容 Redis 协议，为用户提供企业级的键值存储解决方案。

## 核心特性

* 完全兼容 Redis 协议，可使用 Redis 客户端接入。
* 支持常用 Redis 数据结构，参见：[Redis兼容性](./redis-compatibility.md)。
* 支持 TB 级别的 key-value 存储，能够极大降低服务器资源成本与运维成本。
* 迁移简单，不用修改代码即可从 Redis 迁移至 Datalayers。

::: tip
Datalayers 的键值存储服务仅在集群模式下支持。  
Key-Value 数据模型在 Datalayers 2.1.8 版本中发布，使用 Key-Value 时， Datalayers 的版本必须 >= 2.1.8。
:::
