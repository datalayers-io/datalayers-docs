
# DESC 语句详解

## 功能概述
DESC（DESCRIBE）语句是用于快速查看表结构的元数据查询命令。它提供了一种简洁的方式来获取表的列定义、数据类型、约束等结构信息，是数据库开发和维护的常用工具。

## 语法

```sql
DESC table table_name;
```

查看 table 的定义。如：

```sql
demo> desc table t1
+-------+--------------+------+-------------------+---------------+
| Field | Type         | Null | Default           | Timestamp Key |
+-------+--------------+------+-------------------+---------------+
| ts    | TIMESTAMP(3) | NO   | CURRENT_TIMESTAMP | YES           |
| c1    | INT8         | NO   | NULL              | NO            |
| c2    | INT16        | NO   | NULL              | NO            |
| c3    | INT32        | NO   | NULL              | NO            |
| c4    | INT64        | NO   | NULL              | NO            |
| c5    | UINT8        | NO   | NULL              | NO            |
| c6    | UINT16       | NO   | NULL              | NO            |
| c7    | UINT32       | NO   | NULL              | NO            |
| c8    | UINT64       | NO   | NULL              | NO            |
| c9    | REAL         | NO   | NULL              | NO            |
| c10   | DOUBLE       | NO   | NULL              | NO            |
| c11   | BOOLEAN      | NO   | NULL              | NO            |
| c12   | STRING       | NO   | NULL              | NO            |
+-------+--------------+------+-------------------+---------------+
13 rows in set (0.001 sec)
```
