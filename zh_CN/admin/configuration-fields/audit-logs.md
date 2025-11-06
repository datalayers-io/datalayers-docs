# 审计日志

Datalayers 提供数据库操作审计能力，可记录用户对数据库的查询、修改等操作。审计日志以文件形式存储，便于后续查询与分析。

## 配置示例

```toml
# 审计日志配置
[audit]
# 是否启用审计日志功能
# 默认值：false
enable = true

# 审计日志文件存储目录
# 路径相对于 `base_dir` 配置项
# 默认值："audit"
path = "audit"

# 审计日志文件最大保留数量
# 系统每日生成新的日志文件
# 默认值：30
max_files = 30

# 需要记录的审计日志类型，多个类型用逗号分隔
# 支持的类型："read", "write", "ddl", "dql", "admin", "misc"
# 特殊值："all" 表示记录所有类型
# 默认值："ddl,admin"
kinds = "ddl,admin"

# 需要记录的审计操作类型，多个操作用逗号分隔
# 支持的操作："update", "delete", "create", "alter", "drop", "truncate", "trim", 
# "desc", "show", "create_user", "drop_user", "set_password", "grant", "revoke", 
# "flush", "cluster", "migrate", "compact", "export", "misc",
# 特殊值："all" 表示记录所有操作
# 默认值："all"
actions = "all"
```

## 配置说明

- **enable**: 设置为 true 以启用审计日志功能
- **path**: 指定日志存储路径，支持相对路径（基于 base_dir）或绝对路径
- **max_files**: 控制日志文件轮转数量，避免磁盘空间过度占用
- **kinds**: 精细化控制需要记录的日志类型，减少不必要的日志记录
- **actions**: 根据实际安全需求，选择需要审计的具体数据库操作
- 同时满足 **kinds** 和 **actions** 条件的日志才会被记录
