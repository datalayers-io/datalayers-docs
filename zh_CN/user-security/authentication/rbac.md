# RBAC（基于角色的访问控制）

## 概述

RBAC 提供完整的身份认证和权限管理体系，支持多用户、多角色的细粒度权限控制。

## 核心特性
​**​角色管理​​**：定义不同权限级别的角色  
​**​用户分配​​**：将用户分配到特定角色  
​​**权限控制​**​：精确控制数据访问和操作权限  
​​**审计支持**​​：完整的操作日志和审计跟踪  

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

## 详细说明

关于 RBAC 的完整功能说明和配置指南，请参考：[访问控制](../access-control/overview.md)


注：
- server.auth.type 需设置为 `rbac` 方可启用静态认证
