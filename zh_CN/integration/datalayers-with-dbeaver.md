---
title: "Datalayers 集成 DBeaver 使用指南"
description: "介绍如何在 DBeaver 中通过 PostgreSQL 或 Arrow Flight SQL 协议连接 Datalayers，包括驱动配置、连接参数设置和基础 SQL 操作。"
---
# Datalayers 集成 DBeaver 使用指南

[DBeaver](https://github.com/dbeaver/dbeaver) 是一款常用的开源数据库管理工具，可用于连接数据库、浏览对象、执行 SQL 查询以及进行基础数据管理。

Datalayers 支持 PostgreSQL 协议和 Arrow Flight SQL 协议。你可以根据实例配置与使用场景，在 DBeaver 中选择对应协议连接并访问 Datalayers。

## 使用 PostgreSQL 协议接入

### PostgreSQL 接入条件

- 已安装 Datalayers，版本不低于 `v2.4.1`
- 已安装 DBeaver，可参考 [DBeaver 安装文档](https://github.com/dbeaver/dbeaver/wiki/Installation)
- Datalayers 实例已启用 PostgreSQL 协议监听服务
- 已获取 Datalayers 实例地址、PostgreSQL 协议端口、用户名和密码

### 如何接入

在 DBeaver 中新建数据库连接时，选择内置的 **PostgreSQL** 驱动，并填写 Datalayers 实例地址、端口、用户名和密码。连接成功后，即可在 DBeaver 中浏览数据库对象并执行 SQL 查询。

## 使用 Arrow Flight SQL 接入

### Arrow Flight SQL 接入条件

- 已安装 Datalayers，版本不低于 `v2.2.4`
- 已安装 DBeaver，可参考 [DBeaver 安装文档](https://github.com/dbeaver/dbeaver/wiki/Installation)
- 已下载 [Arrow Flight SQL JDBC Driver](https://mvnrepository.com/artifact/org.apache.arrow/flight-sql-jdbc-driver/19.0.0)
- 已获取 Datalayers 实例地址、Arrow Flight SQL 协议端口、用户名和密码

### 配置 DBeaver

DBeaver 默认不内置 Arrow Flight SQL 驱动，需要先通过驱动管理器添加自定义 JDBC 驱动。

1. 启动 DBeaver，在顶部菜单中选择 **数据库 > 驱动管理器**。

   ![DBeaver](../assets/dbeaver/new.png)

2. 在驱动管理器中点击 **新建**，创建自定义驱动。
3. 在驱动配置页面填写以下信息：
   - 驱动名称：例如 `Datalayers`
   - 驱动类型：选择 `Generic`
   - 类名：`org.apache.arrow.driver.jdbc.ArrowFlightJdbcDriver`
   - URL 模板：`jdbc:arrow-flight-sql://{host}:{port}?useEncryption=false`
   - 默认端口：`8360`，即 Datalayers 默认的 Arrow Flight SQL 协议端口

   ![DBeaver](../assets/dbeaver/config.png)

   以上 URL 模板适用于未启用 TLS 的连接；如果实例启用了加密连接，请根据实际 TLS 配置调整 JDBC 连接参数。

4. 切换至 **库** 标签页，添加已下载的 [Arrow Flight SQL JDBC Driver](https://mvnrepository.com/artifact/org.apache.arrow/flight-sql-jdbc-driver)。添加完成后点击 **查找类**，确认类名识别成功后点击 **OK** 保存驱动配置。

   ![DBeaver](../assets/dbeaver/lib.png)

5. 在顶部菜单中选择 **窗口 > 首选项**，在左侧导航中进入 **编辑器 > 数据编辑器 > 数据格式**，勾选 **禁用日期/时间格式**。

   ![DBeaver](../assets/dbeaver/date-format.png)

   该设置可避免 DBeaver 对时间类型结果进行额外格式化，便于查看 Datalayers 返回的原始时间值。

6. 点击 **应用并关闭**，完成 DBeaver 驱动配置。

### 连接 Datalayers

1. 在顶部菜单中选择 **数据库 > 新建数据库连接**。
2. 搜索前面添加的驱动名称，例如 `Datalayers`，双击该驱动进入连接配置页面。
3. 填写 Datalayers 实例地址、端口、用户名和密码。
4. 点击 **Finish** 保存连接配置并建立连接。
5. 连接成功后，即可在左侧导航中浏览数据库对象，并在 SQL 编辑器中执行查询、建表、写入等操作。

![DBeaver](../assets/dbeaver/datalayers-with-dbeaver.png)

## 相关文档

- 如需通过命令行连接和操作 Datalayers，请参考 [Datalayers 命令行工具 dlsql 使用指南](../getting-started/command-line-tool.md)
- 如需通过 REST API 接入 Datalayers，请参考 [Datalayers HTTP REST API 接入指南](../development-guide/rest-api/overview.md)
