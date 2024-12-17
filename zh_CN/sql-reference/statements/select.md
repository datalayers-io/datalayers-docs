# SELECT Statements

SELECT 语句是数据库查询操作中最常用的一种，用于从数据库中检索数据。通过 SELECT 语句，你可以指定要查询的列、表以及相关的条件，甚至进行复杂的数据聚合、排序和分组。

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
