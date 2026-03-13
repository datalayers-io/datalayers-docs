---
title: "Datalayers 审计日志"
description: "介绍 Datalayers 审计日志能力，包括启用方式、日志存储位置和审计日志在安全合规中的使用建议。"
---
# Datalayers 审计日志

Datalayers 提供数据库操作审计能力，可记录用户对数据库的查询、修改等操作。审计日志以文件形式存储，每条记录采用 `JSON` 格式，便于后续查询与分析。

审计日志适用于安全合规、操作追踪、问题排查和高风险行为审计等场景。

## 开启审计日志

审计日志功能默认关闭，需要在配置文件中启用并配置。具体配置方法可参考 [审计日志配置字段](../admin/configuration-fields/audit-logs.md)。

## 查看审计日志

审计日志文件默认存储在以下目录：

``` text
/var/lib/datalayers/audit
```

您可以通过查看该目录下的日志文件来获取详细的审计信息。系统会按日期自动分割日志文件，便于管理和查询。

在生产环境中，建议根据实际安全合规要求，合理配置 kinds 和 actions 参数，平衡审计需求与系统性能。

## 相关文档

- 了解审计日志配置项，请参考 [审计日志配置字段](../admin/configuration-fields/audit-logs.md)
- 了解认证与访问控制，请参考 [Datalayers 连接认证概述](./authentication/overview.md)
