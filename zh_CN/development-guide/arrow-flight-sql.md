# Arrow Flight SQL 的高速数据传输协议

Datalayers 完整实现了 [Arrow Flight SQL](https://arrow.apache.org/docs/format/FlightSql.html#arrow-flight-sql) 协议，基于该协议实现高性能数据链路。该协议结合了 Apache Arrow 的内存列式格式与 gRPC 的高效通信框架，专为大规模数据分析场景设计，实现高速的数据传输。

## 核心优势
- **极致性能**：直接在 Arrow 列式内存格式上进行传输，完全避免了序列化与反序列化开销，从而显著降低延迟、提升吞吐量。
- **跨语言兼容**：提供多语言原生客户端支持，并与标准的 JDBC 驱动兼容，便于不同技术栈的系统集成。

## 接入指南

Datalayers 支持多种语言的 Arrow Flight SQL 客户端接入，具体示例见下文

* [Go](https://github.com/datalayers-io/examples/tree/main/go)
* [Rust](https://github.com/datalayers-io/examples/tree/main/rust)
* [Java](https://github.com/datalayers-io/examples/tree/main/java)
* [Python](https://github.com/datalayers-io/examples/tree/main/python)
* [JDBC](https://mvnrepository.com/artifact/org.apache.arrow/flight-sql-jdbc-driver) 基于 Arrow Flight SQL JDBC 驱动

更多接入介绍参考：[arrow-adbc](https://github.com/apache/arrow-adbc)
