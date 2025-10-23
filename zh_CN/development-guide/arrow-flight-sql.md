# Arrow Flight SQL

Arrow Flight SQL 是一种使用 Arrow 内存格式和 Flight RPC 框架与 SQL 数据库交互的协议。Datalayers 支持 [Arrow Flight SQL](https://arrow.apache.org/docs/format/FlightSql.html#arrow-flight-sql) 协议，可使用支持 Arrow Flight SQL 的 SDK 进行接入。 Arrow Flight SQL 还提供了通用的 [JDBC](https://mvnrepository.com/artifact/org.apache.arrow/flight-sql-jdbc-driver) 驱动，支持与遵循 Arrow Flight SQL 协议的数据库无缝交互。

Datalayers 基于 Arrow Flight SQL 构建了高速数据传输链路，目前主流编译语言已支持使用 Arrow Flight SQL 客户端 从 Datalayers 高速读取海量数据，极大提升了其他系统与 Datalayers 间数据传输效率。同时在传输过程中使用 Arrow 的列存格式，在数据传输过程将完全避免序列化/反序列化操作，可彻底消除序列化/反序列化带来时间及性能损耗、提升系统的吞吐能力。

## 接入

目前我们支持Arrow Flight SQL 客户端的环境有（详见下面接入示例）：

* [Go](https://github.com/datalayers-io/examples/tree/main/go)
* [Rust](https://github.com/datalayers-io/examples/tree/main/rust)
* [Java](https://github.com/datalayers-io/examples/tree/main/java)
* [Python](https://github.com/datalayers-io/examples/tree/main/python)
* 基于 [Arrow Flight SQL JDBC](https://mvnrepository.com/artifact/org.apache.arrow/flight-sql-jdbc-driver)

更多接入介绍参考：[arrow-adbc](https://github.com/apache/arrow-adbc)
