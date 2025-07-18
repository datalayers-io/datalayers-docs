# 快速上手

本教程介绍如何使用 Datalayers 数据库执行向量存储和向量检索。

我们创建一个含有向量列的表。

```sql
CREATE TABLE t(
    ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id INT32,
    tag STRING,
    embed VECTOR(3),
    timestamp key (ts)
)
PARTITION BY HASH(id) PARTITIONS 4
ENGINE=TimeSeries
```

其中，`embed VECTOR(3)` 表示创建一个名为 `embed` 的向量列，该列中每个向量的维度为 3。

向该表写入一些数据：

```sql
INSERT INTO t (id, tag, embed) VALUES
(1, 'cat', [1.0, 1.1. 1.2]),
(2, 'rat', [4.3, 12.1. 5.5]),
(3, 'mouse', [6.4, 9.1. 7.8]);
```

查询该表，应该得到如下数据：

```sql
> SELECT * FROM t ORDER BY id;
+---------------------------+----+-------+------------------+
| ts                        | id | tag   | embed            |
+---------------------------+----+-------+------------------+
| 2024-09-03T18:00:00+08:00 | 1  | cat   | [1.0, 1.1, 1.2]  |
| 2024-09-03T18:05:00+08:00 | 2  | rat   | [4.3, 12.1, 5.5] |
| 2024-09-03T18:10:00+08:00 | 3  | mouse | [6.4, 9.1, 7.8]  |
+---------------------------+----+-------+------------------+
```

使用 ORDER BY + LIMIT 语句，构造出向量检索所对应的 SQL。例如搜索与目标向量最近的一个向量所对应的 tag：

```sql
> SELECT tag FROM t ORDER BY l2_distance(embed, [6.0, 7.0, 8.0]) LIMIT 1;
+-------+
| tag   |
+-------+
| mouse |
+-------+
```

这里我们使用 L2 距离函数来计算向量距离。Datalayers 提供了许多[向量函数](../sql-reference/vector-functions.md)供用户使用。
