# Database

## 创建数据库
在 DataLayers 中数据库可看为一个集合，该集合中包含了一种或者多种数据模型的table。与主流数据库一致，DataLayers 使用标准 SQL 来创建数据库，同时针对具体业务场景做了相应的扩展，具体语法如下：
```SQL
CREATE DATABASE [IF NOT EXISTS] database_name 
```

**示例**
```SQL
CREATE DATABASE hello_datalayers 
```
表示创建了一个名为 `hello_datalayers` 的数据库......
## 查看数据库
```SQL
show DATABASES 
```
## 删除数据库
```SQL
DROP DATABASE [IF EXISTS] database_name
```
该行为属于高危行为，会同时删除 Database 中所有数据，请谨慎操作。


## 限制

