# SELECT 语句参考指南

## 概述
SELECT 语句是 SQL 中最核心的数据检索操作，用于从数据库中查询和提取数据。Datalayers 提供完整的 SELECT 语法支持，包括复杂查询、聚合分析、多表关联等高级功能。

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
