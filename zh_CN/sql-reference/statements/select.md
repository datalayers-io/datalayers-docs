# SELECT
使用 SELECT STATEMENT 从数据库中检索行数据。

## SELECT STATEMENT

```SQL
-- select the rows from tbl
SELECT j FROM table_name WHERE i=3;
-- perform an aggregate grouped by the column "i"
SELECT i, sum(j) FROM table_name GROUP BY i;
```

相关函数参数：[函数](../sql-functions.md)