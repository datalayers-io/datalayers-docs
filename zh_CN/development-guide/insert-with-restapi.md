# 数据写入
Datalayers 支持通过 HTTP/HTTPS 进行交互，`SQL STATEMENT` 通过 `HTTP BODY` 的方式进行传递。SQL 相关语法请参考：[SQL Reference](../sql-reference/data-type.md)

## 语法
```shell
curl -u"<username>:<password>" -X POST \
http://<HOST>:<PORT>/api/v1/sql?db=<database_name> \
-H 'Content-Type: <content-type>' \
-d '<SQL STATEMENT>'
```

## 创建表
```shell
curl -u"<username>:<password>" -X POST \
http://127.0.0.1:3308/api/v1/sql?db=test \
-H 'Content-Type: application/binary' \
-d 'CREATE TABLE sensor_info (
  ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  sn char(20) NOT NULL,
  speed int,
  longitude float,
  latitude float,
  PRIMARY KEY (sn, ts)
)
```
返回值
```json
{
  "code": "SUCCESS",
  "reason": "",
}
```


## 数据插入
```shell
curl -u"<username>:<password>" -X POST \
http://127.0.0.1:3308/api/v1/sql?db=test \
-H 'Content-Type: application/binary' \
-d 'INSERT INTO sensor_info(`ts`, `sn`, `speed`, `longitude`, `latitude`) VALUES(NOT(), 88888888, 120, 104.07, 30.59)'
```
返回值
```json
{
  "code": "SUCCESS",
  "reason": "",
  "data": ""
}
```

## 编程语言示例


::: code-group

```go
/**
 * @type {import('vitepress').UserConfig}
 */
const config = {
  // ...
}

export default config
```

```java [JAVA]
import type { UserConfig } from 'vitepress'

const config: UserConfig = {
  // ...
}

export default config
```

```rust [Rust]
import type { UserConfig } from 'vitepress'

const config: UserConfig = {
  // ...
}

export default config
```

:::