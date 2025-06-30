# INSERT Statement

INSERT 语句用于向数据库表中插入新记录。

## 语法

```SQL
-- 指定列名写入数据
INSERT INTO table_name (column1,column2,column3,...) VALUES (value1,value2,value3,...)
```

## 示例

```SQL
-- 指定列名写入数据
INSERT INTO sensor_info(sn, speed, temperature) VALUES('100', 22.12, 30.8), ('101', 34.12, 40.6), ('102', 56.12, 52.3);
```
