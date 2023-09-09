# Database

## 创建数据库
与主流数据库一致，DataLayers 使用标准 SQL 来创建数据库，同时针对具体业务场景做了相应的扩展，具体语法如下：
```SQL
CREATE DATABASE [IF NOT EXISTS] database_name [database_options]

```


### Options 说明
* TTL: 指定数据库中存储数据的保留时间， 如不配置默认则永久保存。value 为字符串，支持 m（分钟）、h（小时）和 d（天）三个单位，不加时间单位时默认单位为天。如: TTTL = 90, 则表示该 database 中的数据保留90天。
* FLUSH: xxxxxxx 
* CACHE: xxxxx


### 示例
```SQL
CREATE DATABASE hello_datalayers .........
```
表示创建了一个名为 `hello_datalayers` 的数据库，保留时间为.....    压缩...... 

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

## show database

## show create database

## 限制

