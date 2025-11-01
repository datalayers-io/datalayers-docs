# GROUP BY 语句参考指南

## 概述
GROUP BY 子句是 SQL 中用于数据分组和聚合分析的核心语句，它根据指定的列或表达式对数据进行分组，然后对每个组应用聚合函数进行计算。GROUP BY 是数据分析、报表生成和统计计算的基础工具。

## 语法

```SQL
... GROUP BY expr
```

## 示例

```SQL
SELECT max(ts) FROM car GROUP BY zone;
```

表示根据列`zone`对数据进行分组，投影出每组最大的`ts`。
