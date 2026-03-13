---
title: "Datalayers 静态认证"
description: "介绍 Datalayers 静态认证的配置方式、适用场景与使用限制，帮助你快速启用基础连接认证。"
---
# Datalayers 静态认证

## 概述

静态认证通过预配置的用户名和密码进行身份验证。该模式仅提供基础连接认证能力，不包含细粒度权限控制。认证成功的用户将获得系统高权限，因此更适合开发测试、单用户环境或初始接入场景。

## 配置说明

```toml
# The configurations of authorization.
[server.auth]
# 认证类型，可选：static/rbac
# 默认: "static"
type = "static" 

# The username.
# Default: "admin".
username = "admin"

# The password.
# Default: "public".
password = "public"

# The provided JSON Web Token.
# Default: "871b3c2d706d875e9c6389fb2457d957".
jwt_secret = "871b3c2d706d875e9c6389fb2457d957"
```

## 注意事项

- 静态认证模式下，通过认证的用户将拥有系统高权限
- 需要将配置文件中的 `server.auth.type` 设置为 `static` 才能启用静态认证
- 如果环境中存在多用户隔离或权限分级需求，建议改用 RBAC 认证

## 相关文档

- 了解认证方式选择，请参考 [Datalayers 连接认证概述](./overview.md)
- 了解 RBAC 认证，请参考 [RBAC（基于角色的访问控制）](./rbac.md)
