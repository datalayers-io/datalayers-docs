---
title: "Datalayers 认证链"
description: "介绍 Datalayers 认证链的工作机制、配置方式与适用场景，帮助你在保留静态认证的同时接入 RBAC 认证。"
---
# Datalayers 认证链

## 概述

认证链用于将静态认证与 RBAC 认证串联起来。当 `server.auth.type` 配置为 `chain` 时，Datalayers 会先尝试使用静态认证；如果静态认证失败，再继续尝试使用 RBAC 认证。

这种模式适合以下场景：

- 需要保留固定运维账号，同时允许业务用户通过 RBAC 登录
- 正在从静态认证迁移到 RBAC，希望在过渡期兼容两种登录方式
- 需要为紧急运维保留兜底账号，但日常访问仍由 RBAC 管理

## 认证流程

认证链的处理顺序如下：

1. 客户端提交用户名和密码
2. 系统优先按静态认证配置校验账号
3. 如果静态认证成功，则认证通过，并以静态认证用户身份访问系统
4. 如果静态认证失败，则继续按 RBAC 认证流程校验
5. 如果 RBAC 认证成功，则以对应的 RBAC 用户身份访问系统；如果 RBAC 认证也失败，则登录失败

## 配置说明

```toml
# The configurations of authorization.
[server.auth]
# 认证类型，可选：static/rbac/chain
# 默认: "static"
type = "chain"

# 静态认证账号。chain 模式下优先使用该账号进行认证。
username = "admin"

# 静态认证密码。
password = "public"

# The provided JSON Web Token.
# Default: "871b3c2d706d875e9c6389fb2457d957".
jwt_secret = "871b3c2d706d875e9c6389fb2457d957"
```

修改配置后，需要重启 Datalayers 服务使其生效。

## 使用建议

- 启用认证链前，请先确认静态认证账号与 RBAC 用户体系都已准备完成
- 静态认证成功后获得的是系统高权限，建议仅将该账号用于运维或应急场景，并妥善保管凭据
- 如果环境已经完全切换到多用户和细粒度权限管理，建议直接使用 RBAC 模式，减少高权限静态账号的暴露面

## 相关文档

- 了解静态认证配置，请参考 [Datalayers 静态认证](./static.md)
- 了解 RBAC 认证与初始化方式，请参考 [Datalayers RBAC 认证与授权](./rbac.md)
- 了解完整的访问控制模型，请参考 [Datalayers 访问控制概述](../rbac/overview.md)
