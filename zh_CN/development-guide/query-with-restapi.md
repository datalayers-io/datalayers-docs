# 数据查询

Datalayers 支持通过 HTTP/HTTPS 进行交互，`SQL STATEMENT` 通过 `HTTP BODY` 的方式进行传递。SQL 相关语法请参考：[SQL Reference](../sql-reference/data-type.md)

## 语法

```shell
curl -u"<username>:<password>" -X POST \
http://127.0.0.1:8361/api/v1/sql?db=<database_name> \
-H 'Content-Type: application/binary' \
-d '<SQL STATEMENT>'
```

## 示例

### 查询数据

执行请求：

```shell
curl -u"admin:public" -X POST \
http://127.0.0.1:8361/api/v1/sql?db=demo \
-H 'Content-Type: application/binary' \
-d 'SELECT * FROM events WHERE user_id=1'
```

返回值：

```json
{
  "result": {
    "columns": [
      "ts",
      "user_id",
      "message"
    ],
    "types": [
      "Timestamp(Millisecond, Asia/Shanghai)",
      "UInt64",
      "Utf8"
    ],
    "values": [
      [
        "2024-09-02T20:59:18.180+08:00",
        "1",
        "Click"
      ]
    ]
  }
}
```

其中，`result`表示这是一条查询的结果,`columns` 为列名，`types` 为列类型，`values` 为查询到的行数组。需要注意的是，类型中时间戳的表示为`Timestamp(TimeUnit, Timezone)`，当某列类型是时区未被指定的时间戳时，Timezone为None。例如`Timestamp(Millisecond, None)`。

## 编程语言示例

::: code-group

```go
package main

import (
 "bytes"
 "encoding/base64"
 "fmt"
 "io"
 "net/http"
)

func main() {

 username := "admin"
 password := "public"

 auth := username + ":" + password
 authHeader := "Basic " + base64.StdEncoding.EncodeToString([]byte(auth))

 sql := "select * from sensor_info limit 10"

 url := "http://127.0.0.1:8361/api/v1/sql?db=demo"
 req, err := http.NewRequest("POST", url, bytes.NewBuffer([]byte(sql)))
 if err != nil {
  fmt.Println("Error creating request:", err)
  return
 }

 req.Header.Set("Content-Type", "application/binary")
 req.Header.Set("Authorization", authHeader)

 client := &http.Client{}
 resp, err := client.Do(req)
 if err != nil {
  fmt.Println("Error sending request:", err)
  return
 }
 defer resp.Body.Close()

 body, err := io.ReadAll(resp.Body)
 if err != nil {
  fmt.Println("Error reading response:", err)
  return
 }

 fmt.Println("Response Status:", resp.Status)
 fmt.Println("Response Body:", string(body))
}
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
