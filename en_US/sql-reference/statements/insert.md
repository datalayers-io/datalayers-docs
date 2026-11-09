# INSERT Statement

INSERT 语句用于向数据库表中插入新记录。

## 语法

```SQL
-- 指定列名写入数据
INSERT INTO table_name (column1,column2,column3,...) VALUES (value1,value2,value3,...)
```

## 示例

```SQL
-- 指定列名写入数据
INSERT INTO sensor_info(sn, speed, temperature) VALUES('100', 22.12, 30.8), ('101', 34.12, 40.6), ('102', 56.12, 52.3);
```

## Insert from a Table Function

The query part of `INSERT INTO ... SELECT ...` can use a [table function](../table-functions.md) as its row source. A table function is not a physical table and does not need to be created in advance. Its `value` column can be used to build the target table columns.

The examples below assume that `source` and `sink` are time-series tables with compatible `ts`, `sid`, and `value` columns.

The target table must be a time-series table. The source can be a time-series table, a table function, or a join of both.

```SQL
INSERT INTO sink
SELECT CAST(1000 + value AS TIMESTAMP(3)) AS ts,
       CAST(value AS INT) AS sid,
       CAST(value AS FLOAT) AS value
FROM generate_series(0, 9);
```

Table functions can also be joined with a time-series table before inserting into the target table:

```SQL
INSERT INTO sink
SELECT CAST(g.value AS TIMESTAMP(3)) AS ts,
       CAST(s.sid AS INT) AS sid,
       s.value
FROM generate_series(0, 2) AS g
JOIN source AS s ON s.sid = g.value;
```
