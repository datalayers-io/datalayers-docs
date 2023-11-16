
## CREATE DATABASE

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
## CREATE TABLE

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

## CREATE INDEX
**语法**
```SQL
-- Create index 's_idx' that allows for duplicate values on column revenue of table films.
CREATE INDEX s_idx ON films (revenue);
-- Create compound index 'gy_idx' on genre and year columns.
CREATE INDEX gy_idx ON films (genre, year);
```

**说明**
|Name       | Description                                                          |
|------     | ------------------------------                                       |
|name       | The name of the index to be created.                                 |
|table      | The name of the table to be indexed.                                 |
|column     | The name of the column to be indexed.                                |
|expression | An expression based on one or more columns of the table. The expression usually must be written with surrounding parentheses, as shown in the syntax. However, the parentheses can be omitted if the expression has the form of a function call.|