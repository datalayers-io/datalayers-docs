# USE Statement

设置当前会话的数据库，目前仅支持在命令行工具 `dlsql` 下使用。 关于 dlsql 工具使用，请查看[命令行工具](../../admin/datalayers-cli.md#datalayers-cli)章节。

## 语法

```SQL
use database
```

**注**: 使用HTTP协议时不能进行此查询，因为没有会话的概念。
