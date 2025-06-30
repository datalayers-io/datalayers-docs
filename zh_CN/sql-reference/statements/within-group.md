# Within Group Statement

`Within Group` 用于有序集合聚合函数（Ordered-set Aggregate Function），即那些需要数据有序才能正确计算的聚合函数，例如求中位数、求百分位数等。`Within Group` 用来对数据的某一列指定排序规则，然后对排序后的这一列应用聚合函数。

## 示例

计算工资的中位数

```sql
SELECT median(0.5) WITHIN GROUP (ORDER BY salary)
FROM employees;
```
