# SELECT STATEMENT

使用 SELECT STATEMENT 从数据库中检索行数据。

## 语法

```SQL
-- select the rows from tbl
SELECT j FROM table_name WHERE i=3;
-- perform an aggregate grouped by the column "i"
SELECT i, sum(j) FROM table_name GROUP BY i;
```

更多函数说明：

* [聚合函数](../aggregation.md)
* [时间与日期函数](../date.md)
* [数据函数](../math.md)
