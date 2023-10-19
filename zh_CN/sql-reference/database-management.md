# Database

## 创建数据库
在 DataLayers 中数据库可看为一个集合，该集合中包含了一种或者多种数据模型的table。与主流数据库一致，DataLayers 使用标准 SQL 来创建数据库，同时针对具体业务场景做了相应的扩展，具体语法如下：
```SQL
CREATE DATABASE [IF NOT EXISTS] database_name [database_options]

```



### 示例
```SQL
CREATE DATABASE hello_datalayers .........
```
表示创建了一个名为 `hello_datalayers` 的数据库......

## 删除数据库
```SQL
DROP DATABASE [IF EXISTS] database_name
```
该行为属于高危行为，请谨慎操作。

## 修改数据库
```SQL
ALTER DATABASE database_name database_options...
```
## 查看数据库

## show create database

## 限制

