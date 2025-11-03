# 快速开始

本文档介绍如何在 Datalayers 数据库中进行向量数据的存储和检索操作。

## 创建向量表

首先创建一个包含向量列的数据表：
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

## 插入向量数据

向表中插入示例数据：
```sql
INSERT INTO t (id, tag, embed) VALUES
(1, 'cat', [1.0, 1.1, 1.2]),
(2, 'rat', [4.3, 12.1, 5.5]),
(3, 'mouse', [6.4, 9.1, 7.8]);
```

## 查询数据

查看表中所有数据：
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

## 向量相似度检索
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

## 注意事项

- 向量的维度必须为 `[1, 16383]` 范围内的数。
- 向量列可以包含空元素，但是每个向量中的元素不能为 Null。
- 向量列仅支持单精度浮点数。
- 向量列无法作为主键、分区键、唯一索引。
- 一个表可以包含多个向量列。
- 不支持将向量列修改为其他数据类型。
- 向量检索在 Datalayers v2.3.6 中引入，如使用该功能请确保使用版本不低于 v2.3.6。
