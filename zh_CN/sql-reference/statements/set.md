# SET
SET 语句用于更改连接中或全局的某些配置项。

## SET STATEMENT
```SQL
-- 将连接会话中的时区设置为 Asia/Shanghai
SET session timezone = 'Asia/Shanghai' ;
```

## AVAILABLE SET CONFIG
|Name|	Description|	Input type|	Default value| Example|
| ---- | ---- | ---- | ---- | ---- |
| timezone | 当前时区 | VARCHAR | 系统 (服务端当地) 时区 / 服务端配置时区 | ```SET session timezone = 'Asia/Shanghai';``` |
| calendar | 当前日历 | VARCHAR | 系统 (服务端当地) 日历 | ```SET session calendar = 'japanese';``` |
| default_null_order / null_order | 当排序未显式指定时，null值默认在排序中的位置(NULLS_FIRST或NULLS_LAST) | VARCHAR | NULLS_LAST | ```SET session null_order = 'NULLS_LAST';``` |
| default_order | 当排序未显式指定时，默认的排序顺序 (ASC 或 DESC)| VARCHAR | ASC | ```SET session default_order = 'ASC';``` |
| max_expression_depth | 解析器中的最大表达式深度限制。警告:提高深度限制并使用嵌套层数非常深的表达式可能导致堆栈溢出错误。 | UBIGINT | 1000 | ```SET session max_expression_depth = 100;``` |

:::warning
针对于SET语句，目前只开放session级别的配置设置，所以需要显示的增加 'session' 以注明。如果未注明 'session' 或SET设置其他不可用选项将会被拒绝请求。
:::