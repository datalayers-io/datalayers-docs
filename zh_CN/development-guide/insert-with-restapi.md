# 数据写入

Datalayers 支持通过 HTTP/HTTPS 进行交互，`SQL STATEMENT` 通过 `HTTP BODY` 的方式进行传递。SQL 相关语法请参考：[SQL Reference](../sql-reference/data-type.md)

## 语法

```shell
curl -u"<username>:<password>" -X POST \
http://127.0.0.1:8361/api/v1/sql?db=<database_name> \
-H 'Content-Type: application/binary' \
-d '<SQL STATEMENT>'
```

## 示例

### 创建数据库

```shell
curl -u"admin:public" -X POST \
http://127.0.0.1:8361/api/v1/sql \
-H 'Content-Type: application/binary' \
-d 'create database demo'
```

### 创建表

```shell
curl -u"admin:public" -X POST \
http://127.0.0.1:8361/api/v1/sql?db=demo \
-H 'Content-Type: application/binary' \
-d 'CREATE TABLE sensor_info (
  ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  sn INT32 NOT NULL,
  speed int,
  longitude float,
  latitude float,
  timestamp KEY (ts)) PARTITION BY HASH(sn) PARTITIONS 2 ENGINE=TimeSeries;'
```

返回值

```json
{"affected_rows":1}
```

### 插入数据

插入命令：

```shell
curl -u"admin:public" -X POST \
http://127.0.0.1:8361/api/v1/sql?db=demo \
-H 'Content-Type: application/binary' \
-d 'INSERT INTO sensor_info(sn, speed, longitude, latitude) VALUES(1, 120, 104.07, 30.59),(2, 120, 104.07, 30.59)'
```

返回值：

```json
{"affected_rows":2}
```

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
