# 数据查询
Datalayers 支持通过 HTTP/HTTPS 进行交互，`SQL STATEMENT` 通过 `HTTP BODY` 的方式进行传递。SQL 相关语法请参考：[SQL Reference](../sql-reference/data-type.md)

## 查询数据

**执行请求**
```shell
curl -u"<username>:<password>" -X POST \
http://127.0.0.1:8361/api/v1/sql?db=test \
-H 'Content-Type: application/binary' \
-d 'SELECT speed from sensor_info where sn = "abc"'
```
**返回值**
```json
[{"speed":1}]
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