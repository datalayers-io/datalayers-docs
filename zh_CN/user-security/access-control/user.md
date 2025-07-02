# 用户管理

## 创建用户

用户账户由主机名和用户名构成，可以通过如下命令创建账户并设置密码：

```sql
CREATE USER [IF NOT EXISTS] user IDENTIFIED BY 'password';
```

- `user`：格式为`'user_name'@'host_name'`，例如 `'alice'@'127.0.0.1'`。
  - 其中，主机名 `host_name` 支持使用 `%` 通配符，表示匹配任意网段。例如 `bob'@'%'` 表示允许用户 bob 从任意 IP 地址连接，`'bob'@'192.168.%'` 表示只允许从 `192.168.*.*` 网段连接
- `password`：账户密码，最长为32位字符。

用户账户创建以后，可以在客户端启动时传递如下参数登录账户：

```shell
dlsql --username xxx --password xxx
```

或者简写为：

```shell
dlsql -u xxx -p xxx
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

## 查看当前用户

可以通过如下指令查看当前会话中登录用户：

```sql
SELECT USER();
```
