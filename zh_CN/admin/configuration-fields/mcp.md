---
title: "MCP 配置"
description: "Datalayers MCP 配置说明：介绍 Model Context Protocol 服务的关键配置项。"
---
# MCP 配置

当前版本的 MCP 服务通过 HTTP 服务上的 `/mcp` 路径对外提供，传输方式为 Streamable HTTP。

## 配置示例

```toml
# The configurations of the MCP (Model Context Protocol) server.
[server.mcp]
# Whether to enable MCP over Streamable HTTP.
# Default: false.
enable = false

# Whether to enable auth middleware for MCP endpoints.
# Default: true.
enable_auth = true

# Whether to enable stateful mode.
# Default: true.
stateful_mode = true
```

## 配置项说明

- `enable`：是否启用 MCP 服务。未启用时，`/mcp` 路径不会注册。
- `enable_auth`：是否对 MCP 请求启用鉴权中间件。开启后，访问 MCP 需要通过 Datalayers 的认证校验。
- `stateful_mode`：是否启用有状态会话模式。当前默认值为 `true`。

## 当前能力范围

当前代码版本中的 MCP 服务主要提供面向只读元数据查询和只读 SQL 查询的能力：

- `show_databases`
- `show_tables`
- `desc_table`
- `query_data`

其中 `query_data` 明确限制为只读查询，不允许通过 MCP 执行 `INSERT`、`UPDATE`、`DELETE`、`DDL` 等写操作。

## 相关说明

- MCP 服务挂载在 HTTP 服务之下，因此仍需先正确配置 `server.http`。
- 如果启用了 TLS，则 MCP 也会跟随 HTTP 服务使用 HTTPS。
- 当前代码中还实现了 MCP 的工具列表、提示词列表和资源列表接口，但资源读取能力目前只返回“资源不存在”。
