---
title: "索引配置"
description: "Datalayers 索引配置说明：介绍索引相关的配置方式。"
---
# 索引配置

`index` 部分管理 Datalayers 的索引参数。

## 配置示例  

```toml
[index]

[index.tantivy]
# Memory budget for index building.
# More memory could make the building process faster.
# Only used when building index, and will be released after building.
# Only one building process is allowed at a time, so this memory budget is global for the whole server.
# Default: "200MB".
build_memory = "200MB"

# Index cache settings.
[index.cache]
# Setting to 0 will disable memory cache.
# Default: "0MB".
# memory = "10GB"

# Setting to 0 will disable disk cache.
# Default: "0MB".
# disk = "20GB"

# Relative paths are resolved against `base_dir`.
# Set to an absolute path to place index cache files in a different directory.
# Default: "cache/index".
# path = "cache/index"
```
