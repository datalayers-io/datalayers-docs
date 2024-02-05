# WHERE

`WHERE` 子句在 SQL 中用于过滤记录，确保满足特定条件的记录被选中或包含在结果集中。它在执行数据库查询时非常有用，可以用来限制哪些行应该被包括在查询结果中，从而提高查询效率和准确性。

`WHERE` 子句可以与比较运算符（如 `=`, `<>`, `>`, `<`, `>=`, `<=`）、逻辑运算符（如 `AND`, `OR`, `NOT`）以及其他函数（如 `BETWEEN`, `IN`, `LIKE`, `IS NULL`）一起使用，以构建复杂的条件表达式。

**语法**
```sql
SELECT column1, column2, ...
FROM table_name
WHERE condition;
```

**示例**

```sql
-- 选择 `Employees` 表中 `LastName` 为 'Doe' 的所有记录
SELECT * FROM Employees
WHERE LastName = 'Doe';

-- 选择 `Employees` 表中 `Salary` 大于 50000 且 `Department` 为 'IT' 的所有记录
SELECT * FROM Employees
WHERE Salary > 50000 AND Department = 'IT';

-- 选择 `Employees` 表中 `Ts` 在 2020-01-01 至 2020-12-31 之间的所有记录
SELECT * FROM Employees
WHERE Ts BETWEEN '2020-01-01' AND '2020-12-31';

```