---
title: "用户管理指南"
description: "介绍 Datalayers 用户账户模型、用户创建与删除、密码管理及常见用户操作语法。"
---
# 用户管理指南

本文介绍 Datalayers 的用户账户模型与常见管理操作，适用于 RBAC 场景下的账户创建、维护和安全治理。

## 用户账户概述

Datalayers 数据库采用 `用户名`@`主机名` 的复合账户体系，实现基于网络位置的精细化访问控制。每个用户账户包含两个关键要素：

- 用户名：标识用户身份
- 主机名：限定允许连接的客户端IP范围

## 用户生命周期管理

### 创建用户

**语法**：

```sql
CREATE USER [IF NOT EXISTS] user IDENTIFIED BY 'password';
```

**说明**：

- `user`：格式为`'user_name'@'host_name'`，例如 `'alice'@'127.0.0.1'`。
- 主机名 `host_name` 支持使用 `%` 通配符，表示匹配任意网段。例如 `'bob'@'%'` 表示允许用户 bob 从任意 IP 地址连接，`'bob'@'192.168.%'` 表示只允许从 `192.168.*.*` 网段连接
- `password`：账户密码，最长为32位字符。

**示例**：

```sql
CREATE USER 'alice'@'%' IDENTIFIED BY '123456';
```

用户账户创建以后，可以在客户端启动时传递如下参数登录账户：

```shell
dlsql -h 127.0.0.1 --username xxx --password xxx
```

**示例**：

```shell
dlsql -h 127.0.0.1 --username alice --password 123456
```

### 密码管理

**语法**：

```sql
SET PASSWORD FOR user = 'password';
```

**示例**：

```sql
SET PASSWORD FOR 'alice'@'%' = '567890';
```

### 删除用户

**语法**：

```sql
DROP USER [IF EXISTS] user;
```

**示例**：

```sql
DROP USER 'alice'@'%';
```

## 查看当前用户

可以通过如下指令查看当前会话中登录用户：

```sql
SELECT USER();
```

## 密码强度管理

通过修改 [server 配置](../../admin/configuration-fields/server.md)中的 `password_strength` 参数来设置密码强度要求。

## 防暴力破解密码

通过修改 [server 配置](../../admin/configuration-fields/server.md)中的 `password_lockout` 参数来设置防暴力破解密码的策略。

## 相关文档

- 了解访问控制模型，请参考 [Datalayers 访问控制概述](./overview.md)
- 了解角色授权方式，请参考 [角色管理指南](./role.md)
- 了解权限授予与回收，请参考 [权限管理](./privilege.md)
