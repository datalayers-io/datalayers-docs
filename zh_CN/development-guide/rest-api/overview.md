# HTTP REST API 接入指南

## 概述

Datalayers 提供标准的 HTTP 协议接口，支持通过简单的 RESTful 请求直接与数据库交互（如执行 SQL 语句、管理数据库对象等）。本指南将介绍如何快速接入 API，包括认证方式、基础用法、常见操作示例及错误处理规范。

通过 HTTP REST API，您可以使用任意支持 HTTP 请求的工具（如 curl、Postman 或自定义代码）与 Datalayers 通信，无需依赖特定客户端库。该接口设计遵循 RESTful 原则，以 SQL 语句为核心操作载体，通过 HTTP 方法提交 SQL 请求，并返回结构化结果（JSON 格式）与操作状态码。

## 认证方式

Datalayers REST API 默认使用 `HTTP BASIC` 认证 认证方式，认证凭据通过 HTTP 头部传递。帐户信息参考：[认证与权限](../../user-security/authentication/overview.md)


## 基本用法

```shell
curl -u"<username>:<password>" -X POST \
http://<HOST>:<PORT>/api/v1/sql?db=<database_name> \
-H 'Content-Type: application/binary' \
-d '<SQL STATEMENT>'
```

**参数说明**：
- `<username>:<password>`：Datalayers 的认证凭据（如 admin:public）。
- `<HOST>:<PORT>`：Datalayers 服务的 HTTP API 地址（示例中为 127.0.0.1:8361，实际以您的部署配置为准）。
- `db=<database_name>`：目标数据库名称（通过 ?db=参数指定，若操作不涉及数据库可省略）。
- `<SQL STATEMENT>`：待执行的 SQL 语句（如建库、建表、插入数据等，需用单引号包裹）。

## 示例

### 创建数据库

```shell
curl -u"admin:public" -X POST \
http://127.0.0.1:8361/api/v1/sql \
-H 'Content-Type: application/binary' \
-d 'create database demo'
```

返回值：

```json
{"affected_rows":0}
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

### 写入数据

```shell
curl -u"admin:public" -X POST \
http://127.0.0.1:8361/api/v1/sql?db=demo \
-H 'Content-Type: application/binary' \
-d 'INSERT INTO sensor_info(sn, speed, longitude, latitude) VALUES(1, 120, 104.07, 30.59),(2, 120, 104.07, 30.59)'
```

### 查询数据

```shell
curl -u"admin:public" -X POST \
http://127.0.0.1:8361/api/v1/sql?db=demo \
-H 'Content-Type: application/binary' \
-d 'SELECT * FROM sensor_info'
```

## HTTP 状态码

Datalayers 遵循标准的 [HTTP状态码](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status) 规范，提供清晰的错误信息帮助用户快速定位和解决问题。本文详细说明各类错误码的含义和相应的处理建议。

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

**错误报文**

```json
{
  "error": "Only support execute one statement"
}
```
