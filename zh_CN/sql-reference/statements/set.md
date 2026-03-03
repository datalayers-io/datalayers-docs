---
title: "SET 语句详解 | Datalayers 文档"
description: "Datalayers SQL 语句 - SET 语句用于更改连接中或全局的某些配置项。"
---
# SET 语句详解

SET 语句用于更改连接中或全局的某些配置项。

## 语法

```SQL
-- 将连接会话中的时区设置为 Asia/Shanghai
SET session timezone = 'Asia/Shanghai' ;
```

## 可用配置项

|名称| 描述| 输入类型| 默认值| 示例|
| ---- | ---- | ---- | ---- | ---- |
| timezone | 当前时区 | VARCHAR | 系统 (服务端当地) 时区 / 服务端配置时区 | ```SET session timezone = 'Asia/Shanghai';``` |

:::warning
针对于SET语句，目前只开放session级别的配置设置，所以需要显示的增加 'session' 以注明。如果未注明 'session' 或SET设置其他不可用选项将会被拒绝请求。
:::
