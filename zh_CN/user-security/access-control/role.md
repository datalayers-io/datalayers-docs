# 角色

角色是一系列权限的集合，也可以视为不可登录的特殊用户。

## 创建角色

可以通过如下命令创建角色：

```sql
CREATE ROLE [IF NOT EXISTS] role [, role ] ...
```

- `role`：角色名，如`admin`，`developer`。此外，主机名也可以作为角色名的一部分，如`'admin'@'127.0.0.1'`，但主机名不具有实际含义，仅作为字面量存储，不可用于登录，缺省值为`%`。

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
    [WITH ADMIN OPTION]
```

授予者与被授予者之间不得形成权限继承环，因此在执行该命令前，系统会检查是否会导致循环依赖关系，若存在则拒绝执行。

角色授予给用户后将立即生效，用户可以直接使用角色的权限。

## 将角色从用户处收回

通过如下命令解除角色或用户间的权限继承关系：

```sql
REVOKE user_or_role [, user_or_role] ...
    FROM user_or_role [, user_or_role] ...
```

收回后，用户将无法再使用该角色的权限。
