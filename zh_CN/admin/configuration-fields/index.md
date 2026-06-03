---
title: "索引配置"
description: "Datalayers 索引配置说明：介绍索引相关的配置方式。"
---
# 索引配置

`index` 部分管理 Datalayers 的索引参数。

## 配置示例  

```toml
# The configurations of index.
[index]

# 使用 tantivy 引擎时的配置项
[index.tantivy]
# 使用 tantivy 建索引时的内存容量限制，限定只会使用单线程，所以这就是单线程的内容使用量。
# 建议不小于 100MB。
# Default: "100MB".
build_memory = "100MB"

# 索引查询过程使用的缓存配置
[index.cache]
# 内存缓存容量
# 设置为 0 表示关闭内存缓存。
# Default: "0MB"
memory = "10GB"

```
