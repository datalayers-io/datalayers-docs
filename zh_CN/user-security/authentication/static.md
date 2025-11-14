# 静态认证

## 概述

静态认证通过预配置的用户名和密码进行身份验证。此模式仅提供基本的连接认证功能，​​不具备权限控制能力​​。认证成功的用户将获得系统最高权限。

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

::: tip

- 静态认证模式下，通过认证的用户将拥有系统最高权限
- 将配置文件中 `server.auth.type` 设置为 `static` 启用静态认证
:::
