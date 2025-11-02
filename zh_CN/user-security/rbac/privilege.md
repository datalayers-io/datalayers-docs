# 权限管理

权限是指角色或用户访问数据库对象的能力。

## 权限类型

Datalayers 中支持的权限包括：

| 权限名称           | 作用域        | 描述                                   |
| ------------------ | ---------------- | ----------------------------------|
| CREATE ROLE        | 全局             | 允许创建新的角色                    |
| CREATE USER        | 全局             | 允许创建新用户                      |
| DROP ROLE          | 全局             | 允许删除角色                        |
| RELOAD             | 全局             | 允许重新加载系统表或配置文件         |
| SHOW DATABASES     | 全局             | 允许查看数据库列表                  |
| SUPER              | 全局             | 允许执行高权限操作                  |
| ALL \[PRIVILEGES\] | 全局、数据库、表  | 对应级别的所有权限                  |
| USAGE              | 全局、数据库、表  | 无权限                             |
| ALTER              | 全局、数据库、表  | 允许修改表结构，如添加、删除列等     |
| DELETE             | 全局、数据库、表  | 允许删除表中的数据                  |
| INDEX              | 全局、数据库、表  | 允许创建和删除索引                  |
| INSERT             | 全局、数据库、表  | 允许向表中插入数据                  |
| SELECT             | 全局、数据库、表  | 允许查询表中的数据                  |
| UPDATE             | 全局、数据库、表  | 允许更新表中的数据                  |
| CREATE             | 全局、数据库、表  | 允许创建数据库、表                  |
| DROP               | 全局、数据库、表  | 允许删除数据库、表                  |
| GRANT              | 全局、数据库、表  | 允许授予或撤销权限                  |

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

- `user_or_role`：用户账户或角色名，必须已在系统中创建过

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
REVOKE priv_type [, priv_type] ...
    ON priv_level
    FROM user_or_role [, user_or_role] ...
```

- `user_or_role`：用户账户或角色名，必须已在系统中创建过

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
SHOW GRANTS [FOR user_or_role]
```

- `user_or_role`：指定查看某个用户或角色的权限，若省略，则查看当前用户

通过如下命令查看系统中所有支持的权限：

```sql
SHOW PRIVILEGES;
```

## 权限变更生效时机

正常情况下，通过权限管理语句（如 `GRANT`、`REVOKE`、`CREATE USER` 等）修改权限信息时，变更会立即在集群中生效。但如果网络或其他设施出现异常，变更可能只在部分节点上生效。

用户可以通过 `FLUSH PRIVILEGES` 命令触发缓存更新，如果该命令执行成功，之前的变更将立刻生效。


## 各操作需要的权限

| 操作                  | 需要的权限 |
|-----------------------|------------|
| SELECT                | 表的 SELECT 权限 |
| INSERT                | 表的 INSERT 权限 |
| UPDATE                | 表的 UPDATE 权限 |
| DELETE                | 表的 DELETE 权限 |
| ALTER TABLE           | 表的 ALTER 权限|
| COMPACT TABLE         | 表的 INSERT 权限|
| CREATE DATABASE       | 全局 CREATE 权限 |
| CREATE INDEX          | 表的 ALTER 权限 |
| CREATE TABLE          | 数据库的 CREATE 权限|
| CREATE ROLE           | CREATE ROLE 权限 |
| CREATE USER           | CREATE USER 权限 |
| DESC TABLE            | 表的 SELECT 权限 |
| DROP DATABASE         | 数据库的 DROP 权限 |
| DROP INDEX            | 表的 ALTER 权限 |
| DROP NODE             | SUPER 权限 |
| DROP TABLE            | 表的 DROP 权限 |
| DROP ROLE             | DROP ROLE 权限 |
| DROP USER             | CREATE USER 权限 |
| EXCLUDE NODE          | SUPER 权限 |
| EXPLAIN               | 需要与 EXPLAIN 要分析的语句相同的权限 |
| EXPORT PARTITION      | 表的 SELECT 权限 |
| FLUSH                 | RELOAD 权限 |
| GRANT                 | 如果是授予权限，需要 GRANT 权限以及 GRANT 所赋予的权限；<br> 如果是授予角色，需要满足以下条件之一：（1）具有 SUPER 权限（2）已经被授予过该角色，且 `WITH_GRANT_OPTION = true`|
| INCLUDE NODE          | SUPER 权限 |
| REBALANCE             | SUPER 权限 |
| REVOKE                | 如果是收回权限，需要 GRANT 权限以及 REVOKE 所撤销的权限；<br> 如果是收回角色，需要 `SUPER` 权限|
| SET PASSWORD          | CREATE USER 权限 |
| SHOW CLUSTER          | 无权限要求 |
| SHOW CURRENT NODE     | 无权限要求 |
| SHOW CREATE DATABASE  | 数据库的 SELECT 权限 |
| SHOW CREATE TABLE     | 表的 SELECT 权限 |
| SHOW DATABASES        | 能查看至少有一种数据库权限或数据库内表权限，若具有 SHOW DATABASES 权限，则能查看所有数据库 |
| SHOW GRANTS           | SUPER 权限（查看当前用户则无需权限） |
| SHOW LICENSE          | SUPER 权限 |
| SHOW MIGRATION        | SUPER 权限 |
| SHOW PARTITIONS       | 如果指定了 `ON TABLE` 选项，则需要该表的 SELECT 权限；<br> 否则能够查看所有具备 `SELECT` 权限的表的 parititons |
| SHOW PRIVILEGES       | 无权限要求 |
| SHOW TABLES           | 能查看至少有一种权限的表 |
| SHOW TASKS            | SUPER 权限 |
| SHOW VERSION          | SUPER 权限 |
| STOP MIGRATION        | SUPER 权限 |
| TRIM DATABASE         | 数据库的 DROP 权限|
| TRUNCATE TABLE        | 表的 DROP 权限 |

## 特定权限

### INFORMATION SCHEMA 数据库的权限

所有用户都直接获得对 `information_schema` 数据库的 `SELECT` 权限。

不能通过 `REVOKE` 回收该数据库的权限。

访问 `information_schema` 数据库中的表数据时，会根据用户具备的权限来展示数据，以 `tables` 表为例，用户只能查看到自己有权限访问表的信息。

::: tip
可以通过 `GRANT` 授予该数据库的权限，但授权操作没有实际作用，不建议这样做。
:::
