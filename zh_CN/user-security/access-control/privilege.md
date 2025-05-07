# 权限管理

权限是指角色或用户访问数据库对象的能力。

## 权限类型

Datalayers 中支持的权限包括：

| 权限名称           | 操作的数据对象 | 描述                                 |
| ------------------ | -------------- | ------------------------------------ |
| ALL \[PRIVILEGES\] | 服务器管理     | 授予所有权限，通常用于管理员账户     |
| ALTER              | 表             | 允许修改表结构，如添加、删除列等     |
| CREATE             | 数据库、表     | 允许创建数据库、表或索引等数据库对象 |
| CREATE ROLE        | 服务器管理     | 允许创建新的角色                     |
| CREATE USER        | 服务器管理     | 允许创建新用户                       |
| DELETE             | 表             | 允许删除表中的数据                   |
| DROP               | 数据库、表     | 允许删除数据库、表或视图             |
| DROP ROLE          | 服务器管理     | 允许删除角色                         |
| GRANT              | 数据库、表     | 允许将权限授予其他用户               |
| INDEX              | 表             | 允许创建和删除索引                   |
| INSERT             | 表             | 允许向表中插入数据                   |
| RELOAD             | 服务器管理     | 允许重新加载系统表或配置文件         |
| SELECT             | 表             | 允许查询表中的数据                   |
| SHOW DATABASES     | 服务器管理     | 允许查看数据库列表                   |
| SUPER              | 服务器管理     | 允许执行高权限操作                   |
| UPDATE             | 表             | 允许更新表中的数据                   |
| USAGE              | 服务器管理     | 表示没有权限，通常表示默认权限       |

## 授予权限

可以通过如下命令授予用户或角色权限：

```sql
GRANT priv_type [, priv_type] ...
    ON priv_level
    TO user_or_role [, user_or_role] ...
    [WITH GRANT OPTION]
```

- `priv_type`：权限类型，如 SELECT, INSERT, UPDATE 等。

- `priv_level`：权限级别，表明权限的作用范围
  - `*.*`：全局权限，针对数据库中所有数据对象
  - `db_name.*`：数据库级权限，针对某数据库下所有对象
  - `db_name.tbl_name`：表级权限，针对某数据库中的某表

- `user_or_role`：用户账户或角色名，其中的主机名部分支持通配符`%`，例如`'alice'@'%'`可以匹配从任意主机登录的`alice`

- `WITH GRANT OPTION`：可选选项，表示被授权者可将权限再授予他人

示例：

授予用户 `'username'` 在 `test_db` 数据库中的查询权限，且只能从 `192.168.1.*` 网段的主机上查询：
```sql
GRANT SELECT ON test_db.* TO 'username'@'192.168.1.%';
```

授予 `admin` 角色对数据库 `sales_db` 中 `orders` 表的插入和更新权限，并允许 `admin` 将这些权限再授予其他用户：

```sql
GRANT INSERT, UPDATE ON sales_db.orders TO 'admin'@'localhost' WITH GRANT OPTION;
```

授予 `developer` 用户对所有数据库、表的所有权限：

```sql
GRANT ALL PRIVILEGES ON *.* TO 'developer'@'localhost';
```

## 收回权限

可以通过如下命令收回用户或角色的权限：

```sql
REVOKE [IF EXISTS]
    priv_type [, priv_type] ...
    ON priv_level
    FROM user_or_role [, user_or_role] ...
```

- `user_or_role`：用户账户或角色名，其中的主机名部分不支持通配符，必须使用完整名称

示例：

从 `developer` 用户收回对数据库 `sales_db` 中 `orders` 表的插入和更新权限：

```sql
REVOKE INSERT, UPDATE ON sales_db.orders FROM 'developer'@'localhost';
```

从 `admin` 用户收回对 `production_db` 数据库的所有权限：

```sql
REVOKE ALL PRIVILEGES ON production_db.* FROM 'admin'@'localhost';
```

## 查看权限

通过如下命令查看用户或角色的权限：

```sql
SHOW GRANTS
    [FOR user_or_role
    [USING role [, role] ...]]
```

- `user_or_role`：指定查看某个用户或角色的权限，若省略，则查看当前用户
- `USING role [, role] ...`: 指定查看该用户或角色在启用特定角色时，所获得的权限

通过如下命令查看系统中所有支持的权限：

```sql
SHOW PRIVILEGES;
```

## 各操作需要的权限

| 操作                  | 需要的权限 |
|-----------------------|------------|
| ALTER TABLE           | ALTER TABLE ... DROP 需要表的 ALTER, DROP 权限；<br> ALTER TABLE ... RENAME 需要旧表的 ALTER 和 DROP 权限，以及新表的 ALTER，CREATE 和 INSERT 权限；<br> 其余 ALTER TABLE 操作需要表的 ALTER，CREATE 和 INSERT 权限；|
| ANALYZE TABLE         | 表的 INSERT 和 SELECT 权限 |
| ALTER USER            | CREATE USER 权限 |
| COMPACT TABLE         | 表的 INSERT 权限|
| CREATE DATABASE       | 全局 CREATE 权限 |
| CREATE INDEX          | 表的 INDEX 权限 |
| CREATE TABLE          | 数据库的 CREATE 权限|
| CREATE ROLE           | CREATE ROLE 权限 |
| CREATE USER           | CREATE USER 权限 |
| DESC TABLE            | 表的 SELECT 权限 |
| DROP DATABASE         | 数据库的 DROP 权限 |
| DROP INDEX            | 表的 INDEX 权限 |
| DROP TABLE            | 表的 DROP 权限 |
| DROP ROLE             | DROP ROLE 权限 |
| DROP USER             | CREATE USER 权限 |
| EXCLUDE NODE          | SUPER 权限 | 
| EXPLAIN               | 需要与 EXPLAIN 要分析的语句相同的权限 |
| FLUSH                 | RELOAD 权限     |
| GRANT                 | GRANT 权限以及 GRANT 所赋予的权限|
| INCLUDE NODE          | SUPER 权限 |
| REBALANCE             | SUPER 权限 |
| REVOKE                | GRANT 权限以及 REVOKE 所撤销的权限|
| SET DEFAULT ROLE      | CREATE USER 权限或者 `information_schema.default_roles` 表的 UPDATE 权限（为当前用户启用角色则无需权限） |
| SHOW CREATE TABLE     | 表的任意一种权限 |
| SHOW DATABASES        | 数据库的任意一种权限或 SHOW DATABASES 权限 |
| SHOW GRANTS           | `information_schema` 数据库的 SELECT 权限（查看当前用户则无需权限） |
| SHOW TABLES           | 表的任意一种权限 |
| TRIM DATABASE         | 数据库的 DROP 权限|
| TRUNCATE TABLE        | 表的 DROP 权限 |
| USE                   | 数据库或其中数据对象的任意一种权限 |
