# GROUP BY 

GROUP BY子句指定应该使用哪些组列来执行SELECT子句中的聚合(对数据进行分组)，通常配合聚合函数使用。如果指定了GROUP BY子句，则查询始终是聚合查询，即使SELECT子句中不存在聚合函数。

**语法**
```SQL
... GROUP BY expr
```

**示例**
```SQL
SELECT max(ts) FROM car GROUP BY zone;
```
表示根据列‘zone’对数据进行分组，投影出每组最大的‘ts’。