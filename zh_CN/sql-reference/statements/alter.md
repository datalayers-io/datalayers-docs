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

`ALTER TABLE` 用于修改已有表的结构、表选项或表名，支持在一条语句中组合多个操作，多个操作之间使用逗号分隔。

### 语法

```sql
ALTER TABLE table_name alter_action [, alter_action ...];

alter_action:
  ADD COLUMN column_definition
| DROP COLUMN column_name
| RENAME COLUMN old_column_name TO new_column_name
| MODIFY OPTIONS option_name = option_value [, option_name = option_value ...]
| RENAME new_table_name
```

### ADD COLUMN

ADD COLUMN子句可用于向表中添加指定类型的新列。

```sql
-- 在表 `table_name` 中添加一个新列 `k`, 类型为 INT 
ALTER TABLE table_name ADD COLUMN k INT;
-- 在表 `table_name` 中添加一个新列 `l`，类型为 INT，默认值为 10
ALTER TABLE table_name ADD COLUMN l INT DEFAULT 10;
```

如需一次新增多个列，需要重复编写 `ADD COLUMN` 子句：
```sql
ALTER TABLE table_name
	ADD COLUMN length INT32,
	ADD COLUMN city STRING;
```

不支持以下在一个子句中添加多列的写法：
```sql
ALTER TABLE table_name ADD COLUMN (length INT32, city STRING);
```

### DROP COLUMN

DROP COLUMN子句可用于从表中删除列。

```sql
-- 从 `table_name` 中删除列 k 
ALTER TABLE table_name DROP column k;
```

如需一次删除多个列，需要重复编写 `DROP COLUMN` 子句：
```sql
ALTER TABLE table_name
	DROP COLUMN length,
	DROP COLUMN city;
```

不支持以下在一个子句中删除多列的写法：
```sql
ALTER TABLE table_name DROP COLUMN length, city;
```

::: tip
列只有在没有任何索引依赖时才能被删除。如：PRIMARY KEY、UNIQUE等。
:::

### RENAME COLUMN

`RENAME COLUMN` 子句可用于重命名单个列。

```sql
ALTER TABLE table_name RENAME COLUMN old_sid TO new_sid;
```

### MODIFY OPTIONS

修改 Table Options。

```sql
-- Modify options of a table
ALTER TABLE table_name MODIFY OPTIONS ttl='10d', memtable_size='64M';
```

`MODIFY OPTIONS` 内部也使用逗号分隔多个选项，因此它既可以单独使用，也可以与其他 `ALTER TABLE` 子句组合。

### RENAME

修改 Table 的名字。

```sql
-- Modify name of a table
ALTER TABLE table_name rename new_name;
```

### 多操作示例

以下写法在一个 `ALTER TABLE` 语句中同时执行多个变更：

```sql
ALTER TABLE sx1
	ADD COLUMN sid INT32,
	DROP COLUMN flag,
	RENAME sx2;

ALTER TABLE sx1
	MODIFY OPTIONS ttl = '10d', memtable_size = '32M',
	ADD COLUMN sid INT32;

ALTER TABLE sx1
	ADD COLUMN sid INT32,
	ADD COLUMN city STRING,
	DROP COLUMN flag,
	RENAME COLUMN old_sid TO next_sid,
	MODIFY OPTIONS ttl = '10d';
```

### 多操作的优先级

当一个 `ALTER TABLE` 语句中包含可能存在冲突的多个变更时，遵照以下的优先级策略：

- 先执行所有的 `DROP COLUMN` 操作；
- 再执行所有的 `RENAME COLUMN` 操作；
- 最后执行所有的 `ADD COLUMN` 操作；

下面列举了几个可能存在冲突的场景示例，实际可能冲突场景更多，使用时请参考最佳建议和使用限制：

```sql
-- 原表中包含列 a, b, c

-- 同时增加同名的列
ALTER TABLE ADD COLUMN d int32, ADD COLUMN d real;

-- 同时增加并删除同名的列
-- 失败，因为先 DROP 时找不到列 d
ALTER TABLE ADD COLUMN d int32, DROP COLUMN d;
-- 成功，因为先 DROP 原列 c 再创建新的列 c
ALTER TABLE ADD COLUMN c int32, DROP COLUMN c;

-- 同时增加并重命名列
-- 失败，因为先 RENAME 时找不到列 d
ALTER TABLE ADD COLUMN d int 32, RENAME COLUMN d to e;
-- 失败，因为先 RENAME 得到重复的列 d
ALTER TABLE ADD COLUMN d int 32, RENAME COLUMN c to d;
```

::: tip
最佳建议是避免出现冲突，不要依赖优先级策略来解决逻辑顺序问题，这类场景建议拆分成多条 SQL。
:::

### 使用限制

- 多个操作之间必须显式写出操作关键字，例如 `ADD COLUMN ... , ADD COLUMN ...`。不能省略第二个操作的关键字；
- 不要依赖语句中各个操作的书写顺序来推断底层执行顺序，建议让每个操作彼此独立、避免互相依赖；
- 时序表引擎支持在一条语句中组合 `ADD COLUMN`、`DROP COLUMN`、`RENAME COLUMN`、`MODIFY OPTIONS` 和 `RENAME`；
- 关系引擎当前不支持 `RENAME COLUMN`，也不支持在单条 `ALTER TABLE` 语句中混合多种不同类型的操作；这类场景建议拆分为多条 SQL。

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
- 如需删除一个正在运行的 pipeline，请先执行 `ALTER PIPELINE ... STOP`。
