# SELECT Statements

SELECT 语句是数据库查询操作中最常用的一种，用于从数据库中检索数据。通过 SELECT 语句，你可以指定要查询的列、表以及相关的条件，甚至进行复杂的数据聚合、排序和分组。

## 语法

```SQL
[ WITH with_query [, …] ]
SELECT [ ALL | DISTINCT ] select_expr [, …]
[ FROM from_item [, …] ]
[ JOIN join_item [, …] ]
[ WHERE condition ]
[ GROUP BY grouping_element [, …] ]
[ HAVING condition]
[ UNION [ ALL | select ] ]
[ ORDER BY expression [ ASC | DESC ][, …] ]
[ LIMIT count ]
```

更多函数说明：

* [聚合函数](../aggregation.md)
* [时间与日期函数](../date.md)
* [数学函数](../math.md)
* [插值函数](../gap_fill.md)
* [Json 函数](../json.md)
* [流式窗口函数](../streaming-window.md)
