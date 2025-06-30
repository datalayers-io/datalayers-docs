# 窗口函数

窗口函数将数据的每一行划分到一个窗口，然后对该窗口应用聚合函数。这个聚合函数的计算结果就作为结果集中该行的值。

## 语法

```sql
function([expr])
  OVER(
    [PARTITION BY expr[, …]]
    [ORDER BY expr [ ASC | DESC ][, …]]
    [ frame_clause ]
    )

frame_clause: 
  { RANGE | ROWS | GROUPS } frame_start
  { RANGE | ROWS | GROUPS } BETWEEN frame_start AND frame_end
```

## 示例

查询每个员工的工资与其所在的 department 的平均工资。

```sql
> SELECT depname, empno, salary, avg(salary) OVER (PARTITION BY depname) FROM empsalary;

+-----------+-------+--------+-------------------+
| depname   | empno | salary | avg               |
+-----------+-------+--------+-------------------+
| personnel | 2     | 3900   | 3700.0            |
| personnel | 5     | 3500   | 3700.0            |
| develop   | 8     | 6000   | 5020.0            |
| develop   | 10    | 5200   | 5020.0            |
| develop   | 11    | 5200   | 5020.0            |
| develop   | 9     | 4500   | 5020.0            |
| develop   | 7     | 4200   | 5020.0            |
| sales     | 1     | 5000   | 4866.666666666667 |
| sales     | 4     | 4800   | 4866.666666666667 |
| sales     | 3     | 4800   | 4866.666666666667 |
+-----------+-------+--------+-------------------+
```

窗口函数支持指定窗口内数据的排序。

```sql
> SELECT depname, empno, salary,
       rank() OVER (PARTITION BY depname ORDER BY salary DESC)
  FROM empsalary;

+-----------+-------+--------+--------+
| depname   | empno | salary | rank   |
+-----------+-------+--------+--------+
| personnel | 2     | 3900   | 1      |
| develop   | 8     | 6000   | 1      |
| develop   | 10    | 5200   | 2      |
| develop   | 11    | 5200   | 2      |
| develop   | 9     | 4500   | 4      |
| develop   | 7     | 4200   | 5      |
| sales     | 1     | 5000   | 1      |
| sales     | 4     | 4800   | 2      |
| personnel | 5     | 3500   | 2      |
| sales     | 3     | 4800   | 2      |
+-----------+-------+--------+--------+
```

窗口函数还支持指定 Window Frame（窗口帧），使得只针对窗口内的部分行进行聚合计算，而不是默认的所有行。

```sql
> SELECT depname, empno, salary,
    avg(salary) OVER(ORDER BY salary ASC ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) AS avg,
    min(salary) OVER(ORDER BY empno ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cum_min
  FROM empsalary
  ORDER BY empno ASC;

+-----------+-------+--------+--------------------+---------+
| depname   | empno | salary | avg                | cum_min |
+-----------+-------+--------+--------------------+---------+
| sales     | 1     | 5000   | 5000.0             | 5000    |
| personnel | 2     | 3900   | 3866.6666666666665 | 3900    |
| sales     | 3     | 4800   | 4700.0             | 3900    |
| sales     | 4     | 4800   | 4866.666666666667  | 3900    |
| personnel | 5     | 3500   | 3700.0             | 3500    |
| develop   | 7     | 4200   | 4200.0             | 3500    |
| develop   | 8     | 6000   | 5600.0             | 3500    |
| develop   | 9     | 4500   | 4500.0             | 3500    |
| develop   | 10    | 5200   | 5133.333333333333  | 3500    |
| develop   | 11    | 5200   | 5466.666666666667  | 3500    |
+-----------+-------+--------+--------------------+---------+
```

使用 `WINDOW window AS` 语句来复用窗口：

```sql
SELECT sum(salary) OVER w, avg(salary) OVER w
FROM empsalary
WINDOW w AS (PARTITION BY depname ORDER BY salary DESC);
```
