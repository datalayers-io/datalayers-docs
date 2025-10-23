# 数据库连接
Datalayers 使用 SQL 作为查询语言，SQL 是一种相对简单的语言，易于学习和使用。

Datalayers 提供多种连接协议，如下：

- Arrow Flight SQL：Arrow Flight SQL 是一种使用 Arrow 内存格式和 Flight RPC 框架与 SQL 数据库交互的协议。部份场景相比 REST API 性能提升百倍。因此对于性能有要求的场景优化使用该协议进行接入。
- REST API：通过 REST API协议，使用 SQL 与数据库进行交互。
- InfluxDB 行协议： 支持 InfluxDB 行协议数据写入。注：该协议仅支持写入。

