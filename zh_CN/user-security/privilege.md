# 用户账户管理

## 创建用户

用户账户由主机名和用户名构成，可以通过如下命令创建账户并设置密码：

```sql
CREATE USER [IF NOT EXISTS] user [IDENTIFIED BY 'password'];
```

- `user`：格式为`'user_name'@'host_name'`，例如 `'alice'@'localhost'`
- `password`：账户密码，最长为32位字符

用户账户创建以后，可以在客户端启动时传递如下参数登录账户：

```shell
dlsql --host xxx --port xxx --username xxx --password xxx
```

## 修改密码

用户创建成功后，可以通过如下命令修改账户密码：

```sql
ALTER USER [IF EXISTS] user IDENTIFIED BY 'password';
```

## 删除用户

用户创建成功后，可以通过如下命令删除用户：

```sql
DROP USER [IF EXISTS] user;
```

# 权限管理

权限是指角色或用户访问数据库对象的能力。

## 权限类型

Datalayers 中的静态权限包括：

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

## 查看当前用户

可以通过如下指令查看当前会话中登录用户：

```sql
SELECT USER();
```

# 角色

角色是一系列权限的集合，可以视为不可登录的用户。

## 创建角色

可以通过如下命令创建角色：

```sql
CREATE ROLE [IF NOT EXISTS] role [, role ] ...
```

- `role`：角色名，如`admin`，`developer`。此外，主机名也可以作为角色名的一部分，如`'admin'@'localhost'`，但主机名不具有实际含义，仅作为字面量存储，不可用于登录，缺省值为`%`。

## 授予角色权限

授予角色权限的操作与授予用户权限相同。

示例：

授予角色 `manager` 对数据库 `sales_db` 中所有表的查询权限：

```sql
GRANT SELECT ON sales_db.* TO 'manager'@'%';
```

授予角色 `admin` 对 `inventory_db` 中 `products` 表的插入和更新权限，并允许该角色将权限授予其他用户：

```sql
GRANT INSERT, UPDATE ON inventory_db.products TO 'admin' WITH GRANT OPTION;
```

## 收回角色权限

收回角色权限的操作与收回用户权限相同。

示例：

从角色 `readonly` 收回对数据库 `hr_db` 中所有表的查询权限：

```sql
REVOKE SELECT ON hr_db.* FROM 'readonly';
```

从角色 `editor` 收回对数据库 `content_db` 中 `articles` 表的所有权限：

```sql
REVOKE ALL ON content_db.articles FROM 'editor';
```

## 将角色授予给用户

角色可以作为一个权限的集合体授予给用户或其他角色，被授予者将继承授予者的权限。

角色的授予可以通过如下命令实现：

```sql
GRANT user_or_role [, user_or_role] ...
    TO user_or_role [, user_or_role] ...
    [WITH GRANT OPTION]
```

授予者与被授予者之间不得形成权限继承环，因此在执行该命令前，系统会检查是否会导致循环依赖关系，若存在则拒绝执行。

继承的权限不会立刻生效，需要通过 `SET ROLE` 命令激活。

## 将角色从用户处收回

通过如下命令解除角色或用户间的权限继承关系：

```sql
REVOKE user_or_role [, user_or_role] ...
    FROM user_or_role [, user_or_role] ...
```

## 启用角色

继承的角色权限需要启用才能生效，可以通过如下命令在当前会话中启用角色，该角色必须已经被授予给了当前用户：

```sql
SET ROLE {
    DEFAULT
  | NONE
  | ALL
  | ALL EXCEPT role [, role ] ...
  | role [, role ] ...
}
```

- `DEFAULT`：启用当前用户默认启用的角色
- `NONE`：清除所有已启用的角色
- `ALL`：启用当前用户被授予的所有角色
- `ALL EXCEPT role [, role ] ...`：启用除指定角色外所有被授予的角色

通过 `SET ROLE` 命令启用的角色仅在当前会话生效，重新启动会话后需要重新启用。

## 默认角色

通过如下命令为用户设置默认角色：

```sql
SET DEFAULT ROLE
    {NONE | ALL | role [, role ] ...}
    TO user [, user ] ...
```

之后该用户创建的会话将自动启用默认角色，默认角色必须已经被授予给了该用户。

## 查看当前启用的角色

通过如下命令查看当前会话中启用的角色：

```sql
SELECT CURRENT_ROLE();
```

# 各操作需要的权限

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
|FLUSH| RELOAD 权限     |
| GRANT                 | GRANT 权限以及 GRANT 所赋予的权限|
| INCLUDE NODE          | SUPER 权限 |
| REBALANCE             | SUPER 权限 |
| REVOKE                | GRANT 权限以及 REVOKE 所撤销的权限|
| SET DEFAULT ROLE      | CREATE USER 权限或者 `information_schema.default_roles` 表的 UPDATE 权限（为当前用户启用角色则无需权限） |
| SHOW CREATE TABLE     | 表的任意一种权限 |
| SHOW DATABASES        | 数据库的任意一种权限或 SHOW DATABASES 权限 |
| SHOW GRANTS           | `information_schema` 数据库的 SELECT 权限（查看当前用户则无需权限） |
| SHOW TABLES           | 表的任意一种权限 |
|TRIM DATABASE          | 数据库的 DROP 权限|
| TRUNCATE TABLE        | 表的 DROP 权限 |
| USE                   | 数据库或其中数据对象的任意一种权限 |
