# DISTINCT Statement

`DISTINCT` 关键字在 SQL 中用于返回唯一不同的值。当你从一个数据库表中选择列时，可能会有重复的值。如果你只想列出不同（唯一的）值，可以使用 `DISTINCT` 关键字。

`DISTINCT` 关键字用于 `SELECT` 语句中，紧跟在 `SELECT` 关键字之后。其基本语法如下：

## 语法

```sql
SELECT DISTINCT column1, column2, ...
FROM table_name;
```

`column1`, `column2`, ... 表示想从 `table_name` 表中选择的列，且结果集将不包含重复的行。

## 示例

```sql
SELECT DISTINCT department FROM employees;
```

TODO(niebayes): more distinct.
