# STREAMING Table Engine

## 创建表
```SQL
CREATE TABLE [IF NOT EXISTS] [database.]table_name 
(
    name1 [type1] [DEFAULT expr1],
    name2 [type2] [DEFAULT expr2],
    ...
    INDEX index_name1 expr1,
    INDEX index_name2 expr2,
    ...
    [PRIMARY KEY expr]
) ENGINE = STREAMING() 
[SETTINGS name=value, ...]
```

### 参数说明
* PRIMARY/PARTITION: 该设置用于数据分区。设置后数据将按该key进行分区组织数据。在时序场景合理设置分区多键有利于提升写入与查询效率，建议将 设备ID 作为数据分区KEY。

## 修改表

## 删除表

## 限制

