# TRIM Statements

用于指示数据库立即开始清理垃圾数据，例如过期的数据、被 drop 的 table 尚未清理的数据等。  
```tip
注：该指令仅支持时序引擎。
```

## TRIM DATABASE

```sql
TRIM DATABASE test
```

指示数据库立即开始清理 `test` 数据库的垃圾数据。注意，trim 操作并不是阻塞的，当 `TRIM DATABASE test` 命令执行后，数据库会立即在后台创建任务来执行清理工作。
