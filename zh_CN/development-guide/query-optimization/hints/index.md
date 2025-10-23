# Index Hints
通过 Index Hints，可强制 SQL 在执行时，使用哪些索引、不使用哪些索引，以实现优化或者进行对比测试。


## 语法

```sql
select * from t [[use|ignore] index (index_list)]
```

