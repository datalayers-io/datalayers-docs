
# DESC Statement

DESC 是一种用于查询数据库对象（如表或视图）结构的 SQL 语句。通过 DESC，用户可以查看表中列的名称、数据类型、约束以及其他元数据。

## DESC TABLE

### 语法

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
