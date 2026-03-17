---
title: "Datalayers 连接认证概述"
description: "介绍 Datalayers 的静态认证与 RBAC 认证方式，帮助你根据安全要求选择合适的连接认证方案。"
---
# Datalayers 连接认证概述

Datalayers 提供 [静态认证](./static.md) 与 [RBAC](../rbac/overview.md) 两种连接认证方式，分别适用于不同的部署规模、权限模型和安全要求。

## 认证方式概览

下面是两种认证方式的核心差异，可根据环境复杂度和权限粒度要求进行选择：

| 特性 | 静态认证 | RBAC |
| --- | --- | --- |
| 认证机制 | 配置文件预置凭证 | 基于角色的访问控制 |
| 权限粒度 | 所有权限 | 细粒度权限控制 |
| 管理复杂度 | 简单 | 中等 |

## 下一步

- 了解静态认证配置，请参考 [静态认证](./static.md)
- 了解角色和权限模型，请参考 [Datalayers 访问控制概述](../rbac/overview.md)
- 了解传输加密，请参考 [Datalayers TLS 连接加密配置指南](../tls.md)
