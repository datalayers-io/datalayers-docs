# 聚合函数详解

## 功能概述
SQL聚合函数用于对一组数据执行计算并返回单一结果，主要用于数据统计和数据分析。

## 函数列表

| Function          | Input Type                           | Return Type                          | Description                               |
| ----------------- | ------------------------------------ | ------------------------------------ | ------------------------------------------------------------------------------ |
| avg(expression)         | 数值类型 | DOUBLE   | 计算表达式结果集的平均值 |
| bit\_and(expression)    | 数值类型 | 输入类型 | 计算表达式结果集非 null 结果的按位与 |
| bit\_or(expression)     | 数值类型 | 输入类型 | 计算表达式结果集非 null 结果的按位或 |
| bit\_xor(expression)    | 数值类型 | 输入类型 | 计算表达式结果集非 null 结果的按位异或 |
| bool\_and(expression)   | BOOL     | BOOL     | 表达式结果集所有非 null 结果为 true 则返回 true 否则返回 false |
| bool\_or(expression)    | BOOL     | BOOL     | 表达式结果集任一非 null 结果为 true 则返回 true 否则返回 false |
| count(expression)       | 任意类型 | INTEGER  | 计算表达式结果集包含 null 结果在内的所有行的行数 |
| max(expression)         | 数值类型 | 输入类型 | 计算表达式结果集的最大值 |
| mean(expression)        |          |          | 同 avg |
| median(expression)      | 数值类型 | 输入类型 | 计算表达式结果集的中位数值 |
| min(expression)         | 数值类型 | 输入类型 | 计算表达式结果集的最小值 |
| sum(expression)         | 数值类型 | 输入类型 | 计算表达式结果集的所有值求和 |
| array\_agg(expression [ORDER BY expression])    | 任意类型 | 输入类型的数组 | 表达式结果集聚合成一个数组输出，如果指定了顺序则按照指定的顺序插入到数组中 |
| first\_value(expression [ORDER BY expression])  | 任意类型 | 输入类型 | 表达式结果集排序后的第一个结果，如果没有指定顺序则可能返回其中任意一个 |
| last\_value(expression [ORDER BY expression])   | 任意类型 | 输入类型 | 表达式结果集排序后的最后一个结果，如果没有指定顺序则可能返回其中任意一个 |

::: tip
当某种数据类型可以隐式转换到聚合函数支持的类型时，会转换并执行。
:::

## 示例

```SQL
-- 查询 sensor_info 记录的总行数
SELECT count(*) FROM sensor_info;

-- 计算 sn = 20230629 最近7天的平均速度
SELECT avg(speed) FROM sensor_info WHERE sn = '20230629' and ts > NOW() - interval 7 day;

-- 获取最大温度值
SELECT max(temperature) FROM weather_data;

-- 计算特定设备的总运行时间
SELECT sum(duration) FROM device_logs WHERE device_id = 'device123';

-- 找出特定分组中年龄的中位数
SELECT median(age) FROM user_profiles GROUP BY user_group;

-- 计算 sn = 20230629 最新 speed 的值
SELECT last_value(speed order by ts) FROM sensor_info WHERE sn = '20230629' ;
```
