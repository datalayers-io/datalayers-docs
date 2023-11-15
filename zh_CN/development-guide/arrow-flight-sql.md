# Arrow Flight SQL

Arrow Flight SQL 是一种使用 Arrow 内存格式和 Flight RPC 框架与 SQL 数据库交互的协议。DataLayers 支持 [Arrow Flight SQL](https://arrow.apache.org/docs/format/FlightSql.html#arrow-flight-sql) 协议，可使用支持 Arrow Flight SQL 的相关 SDK 进行接入。

## Arrow Flight SQL 优势
**高性能数据交互**：Arrow Flight SQL 基于 Arrow 数据格式和 Flight RPC 框架，可实现高性能的数据交互。Arrow 格式的内存表示和优化的网络通信使数据传输更加高效。  
**SQL 查询支持**：Arrow Flight SQL 提供了用于执行 SQL 查询的命令，允许与 SQL 数据库进行交互。这使得在分析和查询数据时更加方便，同时利用 SQL 强大的查询功能。  
**协议化**：Arrow Flight SQL 使用 Protobuf 定义了一组 RPC 方法和消息格式，这提供了协议化的数据传输和交互。这有助于实现与不同系统和编程语言的互操作性。  
**数据格式一致性**：通过使用 Arrow 数据格式，Arrow Flight SQL 可以确保数据在不同系统之间的一致性。这有助于避免数据转换和格式问题，简化了数据交换过程。  
**灵活性**：Arrow Flight SQL 提供了执行 SQL 查询和管理预编译语句的命令，使应用程序能够根据需要执行灵活的数据操作。  
**数据元数据支持**：Arrow Flight SQL 还提供了命令来获取数据库服务器的目录元数据，如列出可用的表、架构、主键等。这有助于了解数据库结构和元数据信息。  

## 接入
目前我们支持Arrow Flight SQL 客户端的环境有：
* Go
* C++
* Rust
* Java
* 基于Arrow Flight SQL 的 JDBC
* 基于Arrow Flight SQL 的 ODBC

// todo , 链接到 github 代码示例。