# TRUNCATE TABLE 语句详解

## 功能概述
TRUNCATE TABLE 是一种用于快速清空表中所有数据的 DDL 语句。与 DELETE 语句不同，TRUNCATE 通过直接重置表数据的方式实现高效清理，特别适用于需要快速清空大表的场景。

## 语法

```sql
TRUNCATE TABLE table_name;
```
* `table_name` 指定需要清空的表名

## 注意事项

* `TRUNCATE TABLE Statements` 实现是通过 `drop table` + `create table` 实现，这一操作并非原子操作，在执行的过程中如有请求持续写入，如此时新的 table 还未准备就绪前，写入、查询请求会失败。
* 执行 `TRUNCATE TABLE Statements` 后，表中的一些基础信息会被重置，如：version、created_time、updated_time。
