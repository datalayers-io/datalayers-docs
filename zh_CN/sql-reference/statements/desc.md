
## DESC TABLE
查看 table 的定义。如：
```shell
demo> desc table t1
+-------+--------------+------+-------------------+---------------+
| Field | Type         | Null | Default           | Timestamp Key |
+-------+--------------+------+-------------------+---------------+
| ts    | TIMESTAMP(3) | NO   | CURRENT_TIMESTAMP | YES           |
| c1    | TINYINT      | NO   | NULL              | NO            |
| c2    | SMALLINT     | NO   | NULL              | NO            |
| c3    | INT          | NO   | NULL              | NO            |
| c4    | BIGINT       | NO   | NULL              | NO            |
| c5    | UINT8        | NO   | NULL              | NO            |
| c6    | UINT16       | NO   | NULL              | NO            |
| c7    | UINT32       | NO   | NULL              | NO            |
| c8    | UINT64       | NO   | NULL              | NO            |
| c9    | FLOAT        | NO   | NULL              | NO            |
| c10   | DOUBLE       | NO   | NULL              | NO            |
| c11   | BOOLEAN      | NO   | NULL              | NO            |
| c12   | STRING       | NO   | NULL              | NO            |
+-------+--------------+------+-------------------+---------------+
```
