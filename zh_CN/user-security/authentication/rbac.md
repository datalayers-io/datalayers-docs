# RBAC（基于角色的访问控制）

## 概述

RBAC 提供完整的身份认证和权限管理体系，支持多用户、多角色的细粒度权限控制。

## 核心特性
**角色管理**：定义不同权限级别的角色  
**用户分配**：将用户分配到特定角色  
**权限控制**：精确控制数据访问和操作权限  

## 配置说明

```toml
# The configurations of authorization.
[server.auth]
# 认证类型，可选：static/rbac
# 默认: "static"
type = "rbac" 

# The provided JSON Web Token.
# Default: "871b3c2d706d875e9c6389fb2457d957".
jwt_secret = "871b3c2d706d875e9c6389fb2457d957"
```

## 初始化用户
安装 Datalayers 后，首次使用 rbac认证模式启动时，系统默认没有预置管理员账户。您需要手动初始化第一个管理员账户。本文提供两种初始化方法。

### 基于 Peer 认证初始化
Peer 认证是一种基于操作系统进程间通信（IPC）的本地认证机制，它通过 Unix Domain Socket 进行身份验证，仅允许在同一台机器上运行的进程进行访问。

Datalayers 提供 peer 的认证方式来管理帐号，通过该能力，可对帐号进行初始化、修改密码、查看用户等功能。该能力集成在 dlsql 中。

**典型使用场景** 
- **系统初始化**：首次创建管理员账户  
- **密码重置**：忘记密码时的恢复操作  

如需通过此种方式来初始化帐号，需通过以下两步

1. 配置 peer 服务（默认未启用）

```toml
[server]
# The unix socket file of peer server.
# Don't support peer server by default.
# Default: ""
peer_addr = "run/datalayers.sock"
```

配置好后需重启服务

2. 执行初始化指令
```shell
dlsql admin init-root --user admin@% --password public

# 更多指令可通过 dlsql admin --help 查看
```
通过上术命令即可创建一个用户名为 admin、密码为 public，可从任意 IP 地址登录的管理员账户。

**注意事项**
- Peer 认证仅限本地访问，确保操作在服务器本地执行
- 初始化完成后，可根据实际需求决定是否禁用 peer 服务
- 如遇到连接问题，请检查 socket 文件路径权限及服务状态

### 基于静态认证初始化
基于静态认证，通过相应的授权语句进行创建用户来初始化系统用户。
- 配置为[静态认证](static.md)，配置好后重启系统
- 参考 `rbac` 中的[用户管理](../rbac/user.md),并创建好帐号
- 创建好后将认证 `server.auth.type`修改为 `rbac` 并重启系统
- 使用创建的帐号进行登陆

## 详细说明

关于 RBAC 的完整功能说明请参考：[访问控制](../rbac/overview.md)


::: tip
启用 `RBAC` 认证，需将 `server.auth.type` 设置为 `rbac` 
:::
