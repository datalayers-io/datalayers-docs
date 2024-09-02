# 错误码说明

## HTTP 响应状态码

Datalayers 遵循 [HTTP响应状态码](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status) 标准，可能的状态码如下：

|  HTTP CODE   | 描述                                                                              |
|  ----        | ----                                                                              |
| 200          |  请求成功，返回的 JSON 数据将提供更多信息                                         |
| 201          |  创建成功，新建的对象将在 Body 中返回                                             |
| 204          |  请求成功，常用于删除与更新操作，Body 不会返回内容                                |
| 400          |  请求无效，例如请求体或参数错误                                                   |
| 401          |  未通过服务端认证，API 密钥过期或不存在时可能会发生                               |
| 403          |  无权操作，检查操作对象是否正在使用或有依赖约束                                   |
| 404          |  找不到请求路径或请求的对象不存在，可参照 Body 中的 message 字段判断具体原因      |
| 405          |  Method Not Allowed                                                               |
| 409          |  请求的资源已存在或数量超过限制                                                   |
| 500          |  服务端处理请求时发生内部错误，可通过 Body 返回内容与日志判断具体原因             |

## 返回报文

当你发送一条错误的SQL语句后，Datalayers 会返回一个 JSON 格式的错误信息，如下所示：

```json
{
  "error": "Only support execute one statement"
}
```
