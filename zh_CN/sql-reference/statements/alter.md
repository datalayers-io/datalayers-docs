---
title: "ALTER 语句详解"
description: "Datalayers ALTER 语句详解 - 介绍 ALTER TABLE 和 ALTER PIPELINE 的使用方式，用于修改表结构或控制流计算任务状态。"
---

# ALTER TABLE 语句详解

## 功能概述

ALTER 语句用于修改已有对象。当前主要包括：

- `ALTER TABLE`：修改表结构或表选项
- `ALTER PIPELINE`：控制流计算 pipeline 的运行状态

## ALTER TABLE

### ADD COLUMN

ADD COLUMN子句可用于向表中添加指定类型的新列。

```SQL
-- 在表 `table_name` 中添加一个新列 `k`, 类型为 INT 
ALTER TABLE table_name ADD COLUMN k INT;
-- 在表 `table_name` 中添加一个新列 `l`，类型为 INT，默认值为 10
ALTER TABLE table_name ADD COLUMN l INT DEFAULT 10;
```

### DROP COLUMN

DROP COLUMN子句可用于从表中删除列。

```SQL
-- 从 `table_name` 中删除列 k 
ALTER TABLE table_name DROP column k;
```

::: tip
列只有在没有任何索引依赖时才能被删除。如：PRIMARY KEY、UNIQUE等。
:::

### MODIFY OPTIONS

修改 Table Options。

```SQL
-- Modify options of a table
ALTER TABLE table_name MODIFY OPTIONS ttl='10d', memtable_size='64M';
```

### RENAME

修改 Table 的名字。

```SQL
-- Modify name of a table
ALTER TABLE table_name rename new_name;
```

## ALTER PIPELINE

当前流计算相关的 `ALTER` 语句只支持 pipeline 生命周期管理。

### STOP

停止一个运行中的 pipeline。

```SQL
ALTER PIPELINE pipeline_name STOP;
```

### RESTART

重启一个 pipeline。

```SQL
ALTER PIPELINE pipeline_name RESTART;
```

说明

- 目前不支持 `ALTER SOURCE`。
- 目前不支持修改 pipeline 的 SQL、source 或 sink 定义；如需调整这类内容，请重新创建对象。
