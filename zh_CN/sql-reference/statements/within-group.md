# Within Group 语句详解

## 功能概述
WITHIN GROUP 语句是用于有序集合聚合函数（Ordered-set Aggregate Functions）的关键语法，它允许在聚合计算前对数据进行排序。这些函数需要数据按特定顺序排列才能正确计算，如百分位数、中位数等统计指标。

## 示例

计算工资的中位数

```sql
SELECT median(0.5) WITHIN GROUP (ORDER BY salary)
FROM employees;
```
