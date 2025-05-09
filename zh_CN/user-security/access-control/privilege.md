# 权限管理

权限是指角色或用户访问数据库对象的能力。

## 权限类型

Datalayers 中支持的权限包括：

| 权限名称           | 权限类型         | 描述                                 |
| ------------------ | ---------------- | ------------------------------------ |
| ALL \[PRIVILEGES\] | 全局             | 授予所有权限，通常用于管理员账户     |
| CREATE ROLE        | 全局             | 允许创建新的角色                     |
| CREATE USER        | 全局             | 允许创建新用户                       |
| DROP ROLE          | 全局             | 允许删除角色                         |
| RELOAD             | 全局             | 允许重新加载系统表或配置文件         |
| SHOW DATABASES     | 全局             | 允许查看数据库列表                   |
| SUPER              | 全局             | 允许执行高权限操作                   |
| USAGE              | 全局             | 表示没有权限，通常表示默认权限       |
| ALTER              | 全局、表         | 允许修改表结构，如添加、删除列等     |
| DELETE             | 全局、表         | 允许删除表中的数据                   |
| INDEX              | 全局、表         | 允许创建和删除索引                   |
| INSERT             | 全局、表         | 允许向表中插入数据                   |
| SELECT             | 全局、表         | 允许查询表中的数据                   |
| UPDATE             | 全局、表         | 允许更新表中的数据                   |
| CREATE             | 全局、数据库、表 | 允许创建数据库、表或索引等数据库对象 |
| DROP               | 全局、数据库、表 | 允许删除数据库、表或视图             |
| GRANT              | 全局、数据库、表 | 允许将权限授予其他用户               |

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

- `WITH GRANT OPTION`：可选选项，表示是否顺带授予 GRANT 权限，以使得被授权者可将权限再授予他人

示例：

授予用户 `'username'` 在 `test_db` 数据库中的查询权限，且只能从 `192.168.1.%` 网段的主机上查询：

```sql
GRANT SELECT ON test_db.* TO 'username'@'192.168.1.%';
```

授予 `admin` 角色对数据库 `sales_db` 中 `orders` 表的插入和更新权限，并允许 `admin` 将这些权限再授予其他用户：

```sql
GRANT INSERT, UPDATE ON sales_db.orders TO 'admin'@'127.0.0.1' WITH GRANT OPTION;
```

授予 `developer` 用户对所有数据库、表的所有权限：

```sql
GRANT ALL PRIVILEGES ON *.* TO 'developer'@'127.0.0.1';
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
REVOKE INSERT, UPDATE ON sales_db.orders FROM 'developer'@'127.0.0.1';
```

从 `admin` 用户收回对 `production_db` 数据库的所有权限：

```sql
REVOKE ALL PRIVILEGES ON production_db.* FROM 'admin'@'127.0.0.1';
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

## 权限变更生效时机

服务器启动时如果添加了 `--skip-grant-tables` 选项，则启动后不进行访问控制，任何用户都可以执行任意操作。如果没有使用 `--skip-grant-tables` 选项，服务器会在启动后会缓存权限信息到内存，并开启访问控制。

正常情况下，通过权限管理语句（如 `GRANT`、`REVOKE`、`CREATE USER` 等）修改权限信息时，变更会立即在集群中生效。但如果网络或其他设施出现异常，变更可能只在部分节点上生效。不过，系统会周期性地更新节点的缓存，保证变更最终会生效，通常这个时间不超过15分钟。

此外，用户还可以通过 `FLUSH PRIVILEGES` 命令触发缓存更新，如果该命令执行成功，之前的变更将立刻生效。


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
| GRANT                 | 如果是授予权限，需要 GRANT 权限以及 GRANT 所赋予的权限；<br> 如果是授予角色，需要满足以下条件之一：（1）具有SUPER 权限（2）已经被授予过该角色，且 `WITH_GRANT_OPTION = true`|
| INCLUDE NODE          | SUPER 权限 |
| REBALANCE             | SUPER 权限 |
| REVOKE                | 如果是收回权限，需要 GRANT 权限以及 REVOKE 所撤销的权限；<br> 如果是收回角色，需要 `SUPER` 权限|
| SET DEFAULT ROLE      | CREATE USER 权限或者 `information_schema.default_roles` 表的 UPDATE 权限（为当前用户启用角色则无需权限） |
| SHOW CREATE TABLE     | 表的任意一种权限 |
| SHOW DATABASES        | 能查看至少有一种权限的数据库，若具有 SHOW DATABASES 权限，则能查看所有数据库 |
| SHOW GRANTS           | `information_schema` 数据库的 SELECT 权限（查看当前用户则无需权限） |
| SHOW TABLES           | 能查看至少有一种权限的表 |
| TRIM DATABASE         | 数据库的 DROP 权限|
| TRUNCATE TABLE        | 表的 DROP 权限 |
| USE                   | 数据库或其中数据对象的任意一种权限 |
