# Index Hints 使用指南

## 概述
Index Hints（索引提示）是一种在 SQL 查询中显式指定索引使用策略的技术。通过 Index Hints，可以强制查询优化器在执行时使用或忽略特定的索引，主要用于性能优化和对比测试场景。


## 语法

```sql
select * from t [[use|ignore] index (index_list)]
```

## 适用场景
- 默认优化器索引选择不佳（不符合预期）时
- 评估不同索引的性能差异
