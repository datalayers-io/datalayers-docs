# 数据查询
Datalayers 支持通过 HTTP/HTTPS 进行交互，`SQL STATEMENT` 通过 `HTTP BODY` 的方式进行传递。SQL 相关语法请参考：[SQL Reference](../sql-reference/data-type.md)

## 查询数据

**执行请求**
```shell
curl -u"<username>:<password>" -X POST \
http://127.0.0.1:3308/api/v1/query?db=test \
-H 'Content-Type: application/binary' \
-d 'SELECT speed from vehicle_info where ts > NOW() - interval "1h" and sn = 88888888'
```
**返回值**
```json
{
  "code": "SUCCESS",
  "reason": "",
  "data":[]
}
```
