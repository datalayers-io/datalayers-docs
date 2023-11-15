
## DATABASE

在 DataLayers 中数据库可看为一个集合，该集合中包含了一种或者多种数据模型的table  
**语法**
```SQL
CREATE DATABASE [IF NOT EXISTS] database_name
```

**示例**
```SQL
CREATE DATABASE hello_datalayers
```
表示创建了一个名为 `hello_datalayers` 的数据库。
## TABLE

**语法**
```SQL
CREATE TABLE [IF NOT EXISTS] [database.]table_name 
(
    name1 type1 [ DEFAULT default_expr ],
    name2 type2 [ DEFAULT default_expr ] ,
    ...
    PRIMARY KEY expr,
    ...
)
```

**示例**
```SQL
CREATE TABLE sensor_info (
     ts TIMESTAMP NOT NULL,
     sn BIGINT NOT NULL,
     region VARCHAR(10) NOT NULL,
     speed DOUBLE,
     temperature REAL,
     direction REAL,
     PRIMARY KEY (ts,sn)
)
```