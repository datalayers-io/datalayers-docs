# Arrow Flight SQL

Arrow Flight SQL 是一种使用 Arrow 内存格式和 Flight RPC 框架与 SQL 数据库交互的协议。Datalayers 支持 [Arrow Flight SQL](https://arrow.apache.org/docs/format/FlightSql.html#arrow-flight-sql) 协议，可使用支持 Arrow Flight SQL 的相关 SDK 进行接入。

## Arrow Flight SQL 优势

**高性能数据交互**：Arrow Flight SQL 基于 Arrow 数据格式和 Flight RPC 框架，可实现高性能的数据交互。
**协议化**：Arrow Flight SQL 使用 Protobuf 定义了一组 RPC 方法和消息格式，这提供了协议化的数据传输和交互。这有助于实现与不同系统和编程语言的互操作性。  
**数据格式一致性**：通过使用 Arrow 数据格式，Arrow Flight SQL 可以确保数据在不同系统之间的一致性。这有助于避免数据转换和格式问题，简化了数据交换过程。  

## 接入

目前我们支持Arrow Flight SQL 客户端的环境有：

* [Go](https://github.com/datalayers-io/examples/tree/main/go)
* [Rust](https://github.com/datalayers-io/examples/tree/main/rust)
* [Java](https://github.com/datalayers-io/examples/tree/main/java)
* [Python](https://github.com/datalayers-io/examples/tree/main/python)

更多接入介绍参考：[arrow-adbc](https://github.com/apache/arrow-adbc)

::: code-group

```Go [Go]
package main

import (
    "context"
    "fmt"
    "os"
    "text/tabwriter"
    "time"

    "github.com/apache/arrow/go/v17/arrow"
    "github.com/apache/arrow/go/v17/arrow/array"
    "github.com/apache/arrow/go/v17/arrow/flight"
    "github.com/apache/arrow/go/v17/arrow/flight/flightsql"
    "github.com/apache/arrow/go/v17/arrow/memory"
    "google.golang.org/grpc"
    "google.golang.org/grpc/credentials/insecure"
    "google.golang.org/grpc/metadata"
)

type Executor struct {
    client *flightsql.Client
    ctx    context.Context
}

// Creates an executor for executing SQLs on the Datalayers server.
func makeExecutor(host string, port uint32, username, password string) (*Executor, error) {
    addr := fmt.Sprintf("%s:%v", host, port)

    // Creates a FlightSQL client to connect to Datalayers.
    // The TLS is disabled by default.
    var dialOpts = []grpc.DialOption{
        grpc.WithTransportCredentials(insecure.NewCredentials()),
    }
    client, err := flightsql.NewClient(addr, nil, nil, dialOpts...)
    if err != nil {
        return nil, err
    }

    // Authenticates with the server using the basic authorization.
    ctx, err := client.Client.AuthenticateBasicToken(context.Background(), username, password)
    if err != nil {
        return nil, err
    }

    executor := &Executor{
        client,
        ctx,
    }
    return executor, nil
}

// Executes the sql on Datalayers and returns the result as a slice of arrow records.
func (exec *Executor) execute(sql string) ([]arrow.Record, error) {
    flightInfo, err := exec.client.Execute(exec.ctx, sql)
    if err != nil {
        return nil, err
    }
    return exec.doGet(flightInfo.GetEndpoint()[0].GetTicket())
}

// Creates a prepared statement.
func (exec *Executor) prepare(sql string) (*flightsql.PreparedStatement, error) {
    return exec.client.Prepare(exec.ctx, sql)
}

// Binds the record to the prepared statement and executes it on the server.
func (exec *Executor) executePrepared(preparedStmt *flightsql.PreparedStatement, binding arrow.Record) ([]arrow.Record, error) {
    defer binding.Release()

    preparedStmt.SetParameters(binding)
    flightInfo, err := preparedStmt.Execute(exec.ctx)
    if err != nil {
        return nil, err
    }
    return exec.doGet(flightInfo.GetEndpoint()[0].GetTicket())
}

// Calls the `DoGet` method of the FlightSQL client.
func (exec *Executor) doGet(ticket *flight.Ticket) ([]arrow.Record, error) {
    reader, err := exec.client.DoGet(exec.ctx, ticket)
    if err != nil {
        return nil, err
    }
    defer reader.Release()

    var records []arrow.Record
    for reader.Next() {
        record := reader.Record()
        // Increments ref count for each record to not let it release immediately.
        record.Retain()
        records = append(records, record)
    }
    return records, nil
}

// Sets the database header for each request to the given database.
func (exec *Executor) useDatabase(database string) {
    exec.ctx = metadata.AppendToOutgoingContext(exec.ctx, "database", database)
}

// Assumes the records contain the affected rows and prints the affected rows.
func printAffectedRows(records []arrow.Record) {
    if len(records) == 0 {
        panic("Unexpected empty records")
    }
    defer releaseRecords(records)

    // By Datalayers' design, the affected rows is the value at the first row and the first column.
    affectedRows := records[0].Column(0).(*array.String).Value(0)
    fmt.Println("Affected rows: ", affectedRows)
}

// Helper function to print records as a table
func printRecordsAsTable(records []arrow.Record) {
    if len(records) == 0 {
        return
    }
    defer releaseRecords(records)

    // Creates a tabwriter to format output into a table
    writer := tabwriter.NewWriter(os.Stdout, 0, 0, 3, ' ', tabwriter.AlignRight)

    // Gets schema and prints column headers
    schema := records[0].Schema()
    for _, field := range schema.Fields() {
        fmt.Fprintf(writer, "%s\t", field.Name)
    }
    fmt.Fprintln(writer)

    // Prints rows
    for _, record := range records {
        numRows := int(record.NumRows())
        numCols := int(record.NumCols())
        for rowIndex := 0; rowIndex < numRows; rowIndex++ {
            for colIndex := 0; colIndex < numCols; colIndex++ {
                switch arr := record.Column(colIndex).(type) {
                //! Adds more array types if necessary.
                case *array.Timestamp:
                    fmt.Fprintf(writer, "%v\t", arr.Value(rowIndex).ToTime(arrow.Millisecond).Local())
                case *array.Int8:
                    fmt.Fprintf(writer, "%d\t", arr.Value(rowIndex))
                case *array.Int32:
                    fmt.Fprintf(writer, "%d\t", arr.Value(rowIndex))
                case *array.Float32:
                    fmt.Fprintf(writer, "%.2f\t", arr.Value(rowIndex))
                default:
                    panic(fmt.Sprintf("Unknown typed array: %v", arr.DataType()))
                }
            }
            fmt.Fprintln(writer)
        }
    }
    writer.Flush()
}

func releaseRecords(records []arrow.Record) {
    for _, record := range records {
        record.Release()
    }
}

func makeTestRecord() arrow.Record {
    // Sets the timezone to UTC+8.
    loc, err := time.LoadLocation("Asia/Shanghai")
    if err != nil {
        panic(fmt.Sprintf("Failed to load location: %v", err))
    }

    schema := arrow.NewSchema([]arrow.Field{
        {Name: "ts", Type: &arrow.TimestampType{Unit: arrow.Millisecond, TimeZone: "Asia/Shanghai"}, Nullable: false},
        {Name: "sid", Type: arrow.PrimitiveTypes.Int32, Nullable: true},
        {Name: "value", Type: arrow.PrimitiveTypes.Float32, Nullable: true},
        {Name: "flag", Type: arrow.PrimitiveTypes.Int8, Nullable: true},
    }, nil)

    memAllocator := memory.NewGoAllocator()
    tsBuilder := array.NewTimestampBuilder(memAllocator, &arrow.TimestampType{Unit: arrow.Millisecond, TimeZone: "Asia/Shanghai"})
    sidBuilder := array.NewInt32Builder(memAllocator)
    valueBuilder := array.NewFloat32Builder(memAllocator)
    flagBuilder := array.NewInt8Builder(memAllocator)

    tsData := []time.Time{
        time.Date(2024, 9, 2, 10, 0, 0, 0, loc),
        time.Date(2024, 9, 2, 10, 5, 0, 0, loc),
        time.Date(2024, 9, 2, 10, 10, 0, 0, loc),
        time.Date(2024, 9, 2, 10, 15, 0, 0, loc),
        time.Date(2024, 9, 2, 10, 20, 0, 0, loc),
    }
    sidData := []int32{1, 2, 3, 4, 5}
    valueData := []float32{12.5, 15.3, 9.8, 22.1, 30.0}
    flagData := []int8{0, 1, 0, 1, 0}

    for _, ts := range tsData {
        tsBuilder.AppendTime(ts)
    }
    valid := []bool{true, true, true, true, true}
    sidBuilder.AppendValues(sidData, valid)
    valueBuilder.AppendValues(valueData, valid)
    flagBuilder.AppendValues(flagData, valid)

    tsArray := tsBuilder.NewArray()
    sidArray := sidBuilder.NewArray()
    valueArray := valueBuilder.NewArray()
    flagArray := flagBuilder.NewArray()
    record := array.NewRecord(schema, []arrow.Array{tsArray, sidArray, valueArray, flagArray}, int64(len(tsData)))

    tsBuilder.Release()
    sidBuilder.Release()
    valueBuilder.Release()
    flagBuilder.Release()

    return record
}

func makeQueryBinding(sid int32) arrow.Record {
    sidBuilder := array.NewInt32Builder(memory.NewGoAllocator())
    defer sidBuilder.Release()

    sidBuilder.Append(sid)
    sidArray := sidBuilder.NewArray()

    schema := arrow.NewSchema([]arrow.Field{
        {Name: "sid", Type: arrow.PrimitiveTypes.Int32, Nullable: true},
    }, nil)
    record := array.NewRecord(schema, []arrow.Array{sidArray}, 1)
    return record
}

func main() {
    // Creates an executor for executing SQLs on the Datalayers server.
    host := "127.0.0.1"
    port := uint32(8360)
    username := "admin"
    password := "public"
    executor, err := makeExecutor(host, port, username, password)
    if err != nil {
        fmt.Println("Failed to create an executor: ", err)
        return
    }

    // Creates a database `test`.
    sql := "CREATE DATABASE test;"
    result, err := executor.execute(sql)
    if err != nil {
        fmt.Println("Failed to create database: ", err)
        return
    }
    // The result should be:
    // Affected rows: 0
    printAffectedRows(result)

    // Optional: sets the database header for each outgoing request to `test`.
    // The Datalayers server uses this header to identify the associated table of a request.
    // This setting is optional since the following SQLs contain the database context
    // and the server could parse the database context from SQLs.
    executor.useDatabase("test")

    // Creates a table `demo` within the database `test`.
    sql = `
    CREATE TABLE test.demo (
        ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        sid INT32,
        value REAL,
        flag INT8,
        timestamp key(ts)
    )
    PARTITION BY HASH(sid) PARTITIONS 8
    ENGINE=TimeSeries;`
    result, err = executor.execute(sql)
    if err != nil {
        fmt.Println("Failed to create table: ", err)
        return
    }
    // The result should be:
    // Affected rows: 0
    printAffectedRows(result)

    // Inserts some data into the `demo` table.
    sql = `
        INSERT INTO test.demo (ts, sid, value, flag) VALUES
            ('2024-09-01T10:00:00+08:00', 1, 12.5, 0),
            ('2024-09-01T10:05:00+08:00', 2, 15.3, 1),
            ('2024-09-01T10:10:00+08:00', 3, 9.8, 0),
            ('2024-09-01T10:15:00+08:00', 4, 22.1, 1),
            ('2024-09-01T10:20:00+08:00', 5, 30.0, 0);`
    result, err = executor.execute(sql)
    if err != nil {
        fmt.Println("Failed to insert data: ", err)
        return
    }
    // The result should be:
    // Affected rows: 5
    printAffectedRows(result)

    // Queries the inserted data.
    sql = "SELECT * FROM test.demo"
    result, err = executor.execute(sql)
    if err != nil {
        fmt.Println("Failed to scan data: ", err)
        return
    }
    // The result should be:
    //                               ts   sid   value   flag
    //    2024-09-01 10:15:00 +0800 CST     4   22.10      1
    //    2024-09-01 10:00:00 +0800 CST     1   12.50      0
    //    2024-09-01 10:05:00 +0800 CST     2   15.30      1
    //    2024-09-01 10:10:00 +0800 CST     3    9.80      0
    //    2024-09-01 10:20:00 +0800 CST     5   30.00      0
    printRecordsAsTable(result)

    // Inserts some data into the `demo` table with prepared statement.
    sql = "INSERT INTO test.demo (ts, sid, value, flag) VALUES (?, ?, ?, ?);"
    preparedStmt, err := executor.prepare(sql)
    if err != nil {
        fmt.Println("Failed to create a insert prepared statement: ", err)
        return
    }
    binding := makeTestRecord()
    result, err = executor.executePrepared(preparedStmt, binding)
    if err != nil {
        fmt.Println("Failed to execute a insert prepared statement: ", err)
        return
    }
    // The result should be:
    // Affected rows: 5
    printAffectedRows(result)

    // Queries the inserted data with prepared statement.
    sql = "SELECT * FROM test.demo WHERE sid = ?"
    preparedStmt, err = executor.prepare(sql)
    if err != nil {
        fmt.Println("Failed to create a select prepared statement: ", err)
        return
    }
    binding = makeQueryBinding(1)
    result, err = executor.executePrepared(preparedStmt, binding)
    if err != nil {
        fmt.Println("Failed to execute a select prepared statement: ", err)
        return
    }
    // The result should be:
    //                               ts   sid   value   flag
    //    2024-09-01 10:00:00 +0800 CST     1   12.50      0
    //    2024-09-02 10:00:00 +0800 CST     1   12.50      0
    printRecordsAsTable(result)

    binding = makeQueryBinding(2)
    result, err = executor.executePrepared(preparedStmt, binding)
    if err != nil {
        fmt.Println("Failed to execute a select prepared statement: ", err)
        return
    }
    // The result should be:
    //                               ts   sid   value   flag
    //    2024-09-01 10:05:00 +0800 CST     2   15.30      1
    //    2024-09-02 10:05:00 +0800 CST     2   15.30      1
    printRecordsAsTable(result)
}

// go.mod
//
// module example.com/demo

// go 1.22.3

// require (
//     github.com/apache/arrow/go/v17 v17.0.0
//     google.golang.org/grpc v1.67.0
// )

// require (
//     github.com/goccy/go-json v0.10.3 // indirect
//     github.com/google/flatbuffers v24.3.25+incompatible // indirect
//     github.com/klauspost/compress v1.17.9 // indirect
//     github.com/klauspost/cpuid/v2 v2.2.8 // indirect
//     github.com/pierrec/lz4/v4 v4.1.21 // indirect
//     github.com/zeebo/xxh3 v1.0.2 // indirect
//     golang.org/x/exp v0.0.0-20240222234643-814bf88cf225 // indirect
//     golang.org/x/mod v0.18.0 // indirect
//     golang.org/x/net v0.28.0 // indirect
//     golang.org/x/sync v0.8.0 // indirect
//     golang.org/x/sys v0.24.0 // indirect
//     golang.org/x/text v0.17.0 // indirect
//     golang.org/x/tools v0.22.0 // indirect
//     golang.org/x/xerrors v0.0.0-20231012003039-104605ab7028 // indirect
//     google.golang.org/genproto/googleapis/rpc v0.0.0-20240814211410-ddb44dafa142 // indirect
//     google.golang.org/protobuf v1.34.2 // indirect
// )

```

```rust [Rust]
// Required dependencies:
//
// [dependencies]
// anyhow = "1.0"
// arrow-array = { version = "52.2", features = ["chrono-tz"] }
// arrow-cast = { version = "52.2", features = ["prettyprint"] }
// arrow-flight = { version = "52.2", features = [
//     "flight-sql-experimental",
//     "tls",
// ] }
// arrow-schema = "52.2"
// chrono = "0.4"
// futures = "0.3"
// regex = "1.10"
// tokio = { version = "1.40", features = ["full"] }
// tonic = "0.11"

use std::process::exit;
use std::str::FromStr;
use std::sync::Arc;
use std::time::Duration;

use anyhow::{bail, Context, Result};
use arrow_array::{
    Float32Array, Int32Array, Int8Array, RecordBatch, StringArray, TimestampMillisecondArray,
};
use arrow_cast::pretty::pretty_format_batches;
use arrow_flight::{
    sql::client::{FlightSqlServiceClient, PreparedStatement},
    Ticket,
};
use arrow_schema::{DataType, Field, Schema, TimeUnit};
use chrono::TimeZone;
use futures::TryStreamExt;
use regex::Regex;
use tonic::transport::{Certificate, Channel, ClientTlsConfig, Endpoint};

#[tokio::main]
async fn main() -> Result<()> {
    // Creates a client configured for Datalayers.
    let config = ClientConfig {
        host: "127.0.0.1".to_string(),
        port: 8360,
        username: "admin".to_string(),
        password: "public".to_string(),
        // Sets the `tls_cert` to the path to the certificate file
        // if you want to use TLS.
        tls_cert: None,
    };
    let mut client = Client::try_new(&config).await?;

    // Creates a database `test`.
    let mut sql = "CREATE DATABASE test";
    let mut result = client.execute(sql).await?;
    // The result should be:
    // Affected rows: 0
    print_affected_rows(&result);

    // Optional: sets the database header for each outgoing request to `test`.
    // The Datalayers server uses this header to identify the associated table of a request.
    //
    // This setting is optional since the following SQLs contain the database context
    // and the server could parse the database context from SQLs.
    client.use_database("test");

    // Creates a table `demo` within the database `test`.
    sql = r#"
        CREATE TABLE test.demo (
            ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            sid INT32,
            value REAL,
            flag INT8,
            timestamp key(ts)
        )
        PARTITION BY HASH(sid) PARTITIONS 8
        ENGINE=TimeSeries;
    "#;
    result = client.execute(sql).await?;
    // The result should be:
    // Affected rows: 0
    print_affected_rows(&result);

    // Inserts some data.
    sql = r#"
        INSERT INTO test.demo (ts, sid, value, flag) VALUES
            ('2024-09-01T10:00:00+08:00', 1, 12.5, 0),
            ('2024-09-01T10:05:00+08:00', 2, 15.3, 1),
            ('2024-09-01T10:10:00+08:00', 3, 9.8, 0),
            ('2024-09-01T10:15:00+08:00', 4, 22.1, 1),
            ('2024-09-01T10:20:00+08:00', 5, 30.0, 0);
    "#;
    result = client.execute(sql).await?;
    // The result should be:
    // Affected rows: 5
    print_affected_rows(&result);

    // Queries the inserted data
    sql = "SELECT * FROM test.demo";
    result = client.execute(sql).await?;
    // The result should be:
    // +---------------------------+-----+-------+------+
    // | ts                        | sid | value | flag |
    // +---------------------------+-----+-------+------+
    // | 2024-09-01T10:15:00+08:00 | 4   | 22.1  | 1    |
    // | 2024-09-01T10:10:00+08:00 | 3   | 9.8   | 0    |
    // | 2024-09-01T10:05:00+08:00 | 2   | 15.3  | 1    |
    // | 2024-09-01T10:20:00+08:00 | 5   | 30.0  | 0    |
    // | 2024-09-01T10:00:00+08:00 | 1   | 12.5  | 0    |
    // +---------------------------+-----+-------+------+
    print_batches(&result);

    // Inserts some data with prepared statement.
    sql = "INSERT INTO test.demo (ts, sid, value, flag) VALUES (?, ?, ?, ?);";
    let mut prepared_stmt = client.prepare(sql).await?;
    let mut binding = make_insert_binding();
    result = client.execute_prepared(&mut prepared_stmt, binding).await?;
    // The result should be:
    // Affected rows: 5
    print_affected_rows(&result);

    // Queries the inserted data with prepared statement.
    sql = "SELECT * FROM test.demo WHERE sid = ?";
    prepared_stmt = client.prepare(sql).await?;
    binding = make_query_binding(1);
    result = client.execute_prepared(&mut prepared_stmt, binding).await?;
    // The result should be:
    // +---------------------------+-----+-------+------+
    // | ts                        | sid | value | flag |
    // +---------------------------+-----+-------+------+
    // | 2024-09-01T10:00:00+08:00 | 1   | 12.5  | 0    |
    // | 2024-09-02T10:00:00+08:00 | 1   | 12.5  | 0    |
    // +---------------------------+-----+-------+------+
    print_batches(&result);

    binding = make_query_binding(2);
    result = client.execute_prepared(&mut prepared_stmt, binding).await?;
    // The result should be:
    // +---------------------------+-----+-------+------+
    // | ts                        | sid | value | flag |
    // +---------------------------+-----+-------+------+
    // | 2024-09-01T10:05:00+08:00 | 2   | 15.3  | 1    |
    // | 2024-09-02T10:05:00+08:00 | 2   | 15.3  | 1    |
    // +---------------------------+-----+-------+------+
    print_batches(&result);

    Ok(())
}

/// The configuration for the client connecting to the Datalayers server via Arrow Flight SQL protocol.
pub struct ClientConfig {
    /// The hostname of the Datalayers database server.
    pub host: String,
    /// The port number on which the Datalayers database server is listening.
    pub port: u32,
    /// The username for authentication when connecting to the database.
    pub username: String,
    /// The password for authentication when connecting to the database.
    pub password: String,
    /// The optional TLS certificate for secure connections.
    /// The certificate is self-signed by Datalayers and is used as the pem file by the client to certify itself.
    pub tls_cert: Option<String>,
}

pub struct Client {
    /// The Arrow Flight SQL client.
    inner: FlightSqlServiceClient<Channel>,
}

impl Client {
    pub async fn try_new(config: &ClientConfig) -> Result<Self> {
        let protocol = config.tls_cert.as_ref().map(|_| "https").unwrap_or("http");
        let uri = format!("{}://{}:{}", protocol, config.host, config.port);
        let mut endpoint = Endpoint::from_str(&uri)
            .context(format!("Failed to create an endpoint with uri {}", uri))?
            .connect_timeout(Duration::from_secs(5))
            .keep_alive_while_idle(true);

        // Configures TLS if a certificate is provided.
        if let Some(tls_cert) = &config.tls_cert {
            let cert = std::fs::read_to_string(tls_cert)
                .context(format!("Failed to read the TLS cert file {}", tls_cert))?;
            let cert = Certificate::from_pem(cert);
            let tls_config = ClientTlsConfig::new()
                .domain_name(&config.host)
                .ca_certificate(cert);
            endpoint = endpoint
                .tls_config(tls_config)
                .context("failed to configure TLS")?;
        }

        let channel = endpoint
            .connect()
            .await
            .context(format!("Failed to connect to server with uri {}", uri))?;
        let mut flight_sql_client = FlightSqlServiceClient::new(channel);

        // Performs authorization with the Datalayers server.
        let _ = flight_sql_client
            .handshake(&config.username, &config.password)
            .await
            .inspect_err(|e| {
                println!("Failed to do handshake: {}", filter_message(&e.to_string()));
                exit(1)
            });

        Ok(Self {
            inner: flight_sql_client,
        })
    }

    fn use_database(&mut self, database: &str) {
        self.inner.set_header("database", database);
    }

    pub async fn execute(&mut self, sql: &str) -> Result<Vec<RecordBatch>> {
        let flight_info = self
            .inner
            .execute(sql.to_string(), None)
            .await
            .inspect_err(|e| {
                println!(
                    "Failed to execute a sql: {}",
                    filter_message(&e.to_string())
                );
                exit(1)
            })?;
        let ticket = flight_info
            .endpoint
            .first()
            .context("No endpoint in flight info")?
            .ticket
            .clone()
            .context("No ticket in endpoint")?;
        let batches = self.do_get(ticket).await?;
        Ok(batches)
    }

    pub async fn prepare(&mut self, sql: &str) -> Result<PreparedStatement<Channel>> {
        let prepared_stmt = self
            .inner
            .prepare(sql.to_string(), None)
            .await
            .inspect_err(|e| {
                println!(
                    "Failed to execute a sql: {}",
                    filter_message(&e.to_string())
                );
                exit(1)
            })?;
        Ok(prepared_stmt)
    }

    pub async fn execute_prepared(
        &mut self,
        prepared_stmt: &mut PreparedStatement<Channel>,
        binding: RecordBatch,
    ) -> Result<Vec<RecordBatch>> {
        prepared_stmt
            .set_parameters(binding)
            .context("Failed to bind a record batch to the prepared statement")?;
        let flight_info = prepared_stmt.execute().await.inspect_err(|e| {
            println!(
                "Failed to execute the prepared statement: {}",
                filter_message(&e.to_string())
            );
            exit(1)
        })?;
        let ticket = flight_info
            .endpoint
            .first()
            .context("No endpoint in flight info")?
            .ticket
            .clone()
            .context("No ticket in endpoint")?;
        let batches = self.do_get(ticket).await?;
        Ok(batches)
    }

    async fn do_get(&mut self, ticket: Ticket) -> Result<Vec<RecordBatch>> {
        let stream = self.inner.do_get(ticket).await.inspect_err(|e| {
            println!(
                "Failed to perform do_get: {}",
                filter_message(&e.to_string())
            );
            exit(1)
        })?;
        let batches = stream.try_collect::<Vec<_>>().await.inspect_err(|e| {
            println!(
                "Failed to consume flight record batch stream: {}",
                filter_message(&e.to_string())
            );
            exit(1)
        })?;
        if batches.is_empty() {
            bail!("Unexpected empty batches");
        }
        Ok(batches)
    }
}

/// Applies a message filter on the input error to only retain the `message` field.
/// This function is meant to be used to filter error messages from the Datalayers server.
fn filter_message(err: &str) -> String {
    let mut err = err
        .replace(['\n', '\r'], " ")
        .replace("\\\"", "[ESCAPED_QUOTE]");
    let regex = Regex::new(r#"message: "(.*?)(?: at src/dbserver/src.*?)?""#).unwrap();
    if let Some(capture) = regex.captures(&err) {
        err = capture[1]
            .replace("[ESCAPED_QUOTE]", "\\\"")
            .replace('\\', "");
    }
    err
}

fn print_affected_rows(batches: &[RecordBatch]) {
    let affected_rows = batches
        .first()
        .unwrap()
        .column(0)
        .as_any()
        .downcast_ref::<StringArray>()
        .unwrap()
        .value(0)
        .to_string()
        .parse::<u32>()
        .unwrap();
    println!("Affected rows: {}", affected_rows);
}

fn print_batches(batches: &[RecordBatch]) {
    let formatted = pretty_format_batches(batches)
        .inspect_err(|e| {
            println!("Failed to print batches: {}", e);
            exit(1)
        })
        .unwrap();
    println!("{}", formatted);
}

fn make_insert_binding() -> RecordBatch {
    let schema = Arc::new(Schema::new(vec![
        Field::new(
            "ts",
            DataType::Timestamp(TimeUnit::Millisecond, Some("Asia/Shanghai".into())),
            false,
        ),
        Field::new("sid", DataType::Int32, true),
        Field::new("value", DataType::Float32, true),
        Field::new("flag", DataType::Int8, true),
    ]));

    // Sets the timezone to UTC+8.
    let loc = chrono::FixedOffset::east_opt(8 * 60 * 60).unwrap();
    let ts_data = [
        loc.with_ymd_and_hms(2024, 9, 2, 10, 0, 0),
        loc.with_ymd_and_hms(2024, 9, 2, 10, 5, 0),
        loc.with_ymd_and_hms(2024, 9, 2, 10, 10, 0),
        loc.with_ymd_and_hms(2024, 9, 2, 10, 15, 0),
        loc.with_ymd_and_hms(2024, 9, 2, 10, 20, 0),
    ]
    .map(|x| x.unwrap().timestamp_millis())
    .to_vec();
    let sid_data = [1, 2, 3, 4, 5].map(Some);
    let value_data = [12.5, 15.3, 9.8, 22.1, 30.0].map(Some);
    let flag_data = [0, 1, 0, 1, 0].map(Some);

    let ts_array =
        Arc::new(TimestampMillisecondArray::from(ts_data).with_timezone("Asia/Shanghai")) as _;
    let sid_array = Arc::new(Int32Array::from(sid_data.to_vec())) as _;
    let value_array = Arc::new(Float32Array::from(value_data.to_vec())) as _;
    let flag_array = Arc::new(Int8Array::from(flag_data.to_vec())) as _;

    RecordBatch::try_new(
        schema,
        [ts_array, sid_array, value_array, flag_array].into(),
    )
    .inspect_err(|e| {
        println!("Failed to build a record batch: {}", e);
        exit(1)
    })
    .unwrap()
}

fn make_query_binding(sid: i32) -> RecordBatch {
    let schema = Arc::new(Schema::new(vec![Field::new("sid", DataType::Int32, true)]));
    let sid_array = Arc::new(Int32Array::from(vec![Some(sid)])) as _;
    RecordBatch::try_new(schema, [sid_array].into())
        .inspect_err(|e| {
            println!("Failed to build a record batch: {}", e);
            exit(1)
        })
        .unwrap()
}
```

```java [Java]
package org.example;

import org.apache.arrow.flight.*;
import org.apache.arrow.flight.grpc.CredentialCallOption;
import org.apache.arrow.flight.sql.FlightSqlClient;
import org.apache.arrow.memory.BufferAllocator;
import org.apache.arrow.memory.RootAllocator;
import org.apache.arrow.vector.*;
import org.apache.arrow.vector.types.pojo.Field;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.*;

public class SqlRunner {

    private static final Logger log = LoggerFactory.getLogger(SqlRunner.class);

    static void run_flight_sql() throws Exception {
        try (BufferAllocator allocator = new RootAllocator(Integer.MAX_VALUE)) {
            final Location clientLocation = Location.forGrpcInsecure("127.0.0.1", 8360);
            try (FlightClient client = FlightClient.builder(allocator, clientLocation).build();
                 FlightSqlClient sqlClient = new FlightSqlClient(client)) {

                Optional<CredentialCallOption> credentialCallOption = client.authenticateBasicToken("admin", "public");
                CallHeaders headers = new FlightCallHeaders();
                headers.insert("database", "test");

                Set<CallOption> options = new HashSet<>();
                credentialCallOption.ifPresent(options::add);
                options.add(new HeaderCallOption(headers));
                try {
                    String query = "create database test";
                    executeQuery(sqlClient, query, options);
                } catch (Exception e){
                    e.printStackTrace();
                    throw e;
                }

                try {
                    String query = "CREATE TABLE test.sx1 (" +
                    "ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP," +
                    "sid INT32," +
                    "value REAL," +
                    "flag INT8,"  +
                    "timestamp key(ts)" +
                    ")" +
                    "PARTITION BY HASH(sid) PARTITIONS 32" +
                    "ENGINE=TimeSeries";
                    executeQuery(sqlClient, query, options);
                } catch (Exception e){
                    e.printStackTrace();
                    throw e;
                }


                try {
                    String query = "INSERT INTO test.sx1 (sid, value, flag) VALUES (1, 1.1, 1);";
                    executeQuery(sqlClient, query, options);
                } catch (Exception e){
                    e.printStackTrace();
                    throw e;
                }

                // insert with multiple values
                try {
                    String query = "INSERT INTO test.sx1 (sid, value, flag) VALUES (1, 1.1, 1), (1, 1.1, 1), (1, 1.1, 1), (1, 1.1, 1);";
                    executeQuery(sqlClient, query, options);
                } catch (Exception e){
                    e.printStackTrace();
                    throw e;
                }

                try {
                    String query = "SELECT count(*) from test.sx1;";
                    executeQuery(sqlClient, query, options);
                } catch (Exception e){
                    e.printStackTrace();
                    throw e;
                }
            }
        }
    }

    private static void executeQuery(FlightSqlClient sqlClient, String query, Set<CallOption> options) throws Exception {
        final FlightInfo info = sqlClient.execute(query, options.toArray(new CallOption[0]));
        final Ticket ticket = info.getEndpoints().get(0).getTicket();
        try (FlightStream stream = sqlClient.getStream(ticket, options.toArray(new CallOption[0]))) {
            while (stream.next()) {
                try (VectorSchemaRoot schemaRoot = stream.getRoot()) {
//                    // How to get single element
//                    // You can cast the FieldVector class to some class Like TinyIntVector and so on.
//                    // You can get the type mapping from arrow official website
//                    List<FieldVector> vectors = schemaRoot.getFieldVectors();
//                    for (int i = 0; i < vectors.size(); i++) {
//                        System.out.printf("Col :%d %s\n", i, vectors.get(i));
//                    }
                    log.info(schemaRoot.contentToTSVString());
                }
            }
        }
    }

    public static void main(String[] args) throws Exception {
        run_flight_sql();
    }
}

// deps
/* 
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <build>
    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-jar-plugin</artifactId>
        <version>3.2.0</version>
        <configuration>
          <archive>
            <manifest>
              <addClasspath>true</addClasspath>
              <classpathPrefix>libs/</classpathPrefix>
              <mainClass>org.example.SqlRunner</mainClass>
            </manifest>
          </archive>
        </configuration>
      </plugin>
    </plugins>
  </build>
  <groupId>org.example</groupId>
  <artifactId>ArrowFilghtSqlTest</artifactId>
  <version>1.0-SNAPSHOT</version>
  <packaging>jar</packaging>

  <name>ArrowFilghtSqlTest</name>
  <url>http://maven.apache.org</url>

  <properties>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    <arrow.version>16.0.0</arrow.version>
  </properties>

  <dependencies>
    <dependency>
      <groupId>junit</groupId>
      <artifactId>junit</artifactId>
      <version>3.8.1</version>
      <scope>test</scope>
    </dependency>

    <!-- https://mvnrepository.com/artifact/org.apache.arrow/arrow-flight -->
    <dependency>
      <groupId>org.apache.arrow</groupId>
      <artifactId>arrow-flight</artifactId>
      <version>${arrow.version}</version>
      <type>pom</type>
    </dependency>

    <!-- https://mvnrepository.com/artifact/org.apache.arrow/flight-sql -->
    <dependency>
      <groupId>org.apache.arrow</groupId>
      <artifactId>flight-sql</artifactId>
      <version>${arrow.version}</version>
    </dependency>

    <!-- https://mvnrepository.com/artifact/org.slf4j/slf4j-simple -->
    <dependency>
      <groupId>org.slf4j</groupId>
      <artifactId>slf4j-api</artifactId>
      <version>2.0.5</version>
    </dependency>

    <!-- https://mvnrepository.com/artifact/org.apache.arrow/flight-core -->
    <dependency>
      <groupId>org.apache.arrow</groupId>
      <artifactId>arrow-memory-netty</artifactId>
      <version>${arrow.version}</version>
    </dependency>

    <!-- https://mvnrepository.com/artifact/org.apache.arrow/flight-core -->
    <dependency>
      <groupId>org.apache.arrow</groupId>
      <artifactId>flight-core</artifactId>
      <version>${arrow.version}</version>
    </dependency>
    
    <!-- Add it for example logging, you can remove it when you wanna use your own logger -->
    <dependency>
      <groupId>org.slf4j</groupId>
      <artifactId>slf4j-simple</artifactId>
      <version>2.0.9</version>
      <scope>runtime</scope>
    </dependency>

  </dependencies>
</project>
*/

```

``` Python [Python]
# Install dependencies:
# pip install pyarrow flightsql-dbapi pandas

from flightsql import FlightSQLClient, FlightSQLCallOptions
from flightsql.client import PreparedStatement
from typing import Dict, Optional, Any
import pyarrow as pa
import pyarrow.flight as flight
import datetime
import pandas


class Client:
    def __init__(self, host: str, port: int, username: str, password: str, metadata: Optional[Dict[str, str]] = None):
        '''
        Instantiates a FlightSQLClient configured for Datalayers.
        '''

        self.inner = FlightSQLClient(
            host=host,
            port=port,
            user=username,
            password=password,
            metadata=metadata,
            # Http is used if `insecure` is True. Https is used if otherwise.
            insecure=True,
        )

    def execute(self, sql: str, options: Optional[FlightSQLCallOptions] = None) -> pandas.DataFrame:
        '''
        Executes the sql on Datalayers and returns the result as a pandas Dataframe.
        '''

        # Requests the server to execute the given sql.
        # The server replies with a flight into containing tickets for retrieving the response.
        flight_info = self.inner.execute(sql, options)
        # By Datalayers' design, there's always a single returned no matter of the Datalayers is in standalone mode or cluster mode.
        ticket = flight_info.endpoints[0].ticket
        # Retrieves the response from the server.
        reader = self.inner.do_get(ticket)
        # Reads the response as a pandas Dataframe.
        df = reader.read_pandas()
        return df

    def prepare(self, sql: str, options: Optional[FlightSQLCallOptions] = None) -> PreparedStatement:
        '''
        Creates a prepared statement.
        You must provide an options with headers containing the `database` key.
        '''

        return self.inner.prepare(sql)

    def execute_prepared(self, prepared_stmt: PreparedStatement, binding: pa.RecordBatch) -> pandas.DataFrame:
        '''
        Binds the `binding` record batch with the prepared statement and requests the server to execute the statement.
        '''

        flight_info = prepared_stmt.execute(binding)
        ticket = flight_info.endpoints[0].ticket
        reader = self.inner.do_get(ticket)
        df = reader.read_pandas()
        return df

    def close(self):
        self.inner.close()


def print_affected_rows(df: pandas.DataFrame) -> int:
    print("Affected rows: {}".format(df["Count"][0]))


def make_flight_descriptor(command: Any) -> flight.FlightDescriptor:
    any = any_pb2.Any()
    any.Pack(command)
    return flight.FlightDescriptor.for_command(any.SerializeToString())


def make_test_batch() -> pa.RecordBatch:
    tzinfo = datetime.timezone(datetime.timedelta(hours=8))
    ts_data = [
        datetime.datetime(2024, 9, 2, 10, 0, tzinfo=tzinfo),
        datetime.datetime(2024, 9, 2, 10, 5, tzinfo=tzinfo),
        datetime.datetime(2024, 9, 2, 10, 10, tzinfo=tzinfo),
        datetime.datetime(2024, 9, 2, 10, 15, tzinfo=tzinfo),
        datetime.datetime(2024, 9, 2, 10, 20, tzinfo=tzinfo)
    ]
    sid_data = [1, 2, 3, 4, 5]
    value_data = [12.5, 15.3, 9.8, 22.1, 30.0]
    flag_data = [0, 1, 0, 1, 0]

    ts_column = pa.array(ts_data, type=pa.timestamp('ms'))
    sid_column = pa.array(sid_data, type=pa.int32())
    value_column = pa.array(value_data, type=pa.float32())
    flag_column = pa.array(flag_data, type=pa.int8())

    batch = pa.RecordBatch.from_arrays(
        [ts_column, sid_column, value_column, flag_column],
        ['ts', 'sid', 'value', 'flag']
    )
    return batch


def main():
    # The `database` key is set to 'test' throughout the demo.
    #
    # You can alternatively set the `database` key for a specific request
    # using the FlightSQLCallOptions from `flightsql`. For example:
    # ``` Python
    # options = FlightSQLCallOptions(headers=[(b"database", b"test")])
    # result = client.execute(sql, options)
    # print(result)
    # ```
    client = Client(host='127.0.0.1',
                    port=8360,
                    username="admin",
                    password="public",
                    metadata={"database": "test"}
                    )

    # Creates a database `test`.
    sql = "create database test;"
    result = client.execute(sql)
    # The result should be:
    # Affected rows: 0
    print_affected_rows(result)

    # Creates a table `demo` within the database `test`.
    sql = '''
        CREATE TABLE test.demo (
                ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                sid INT32,
                value REAL,
                flag INT8,
                timestamp key(ts)
        )
        PARTITION BY HASH(sid) PARTITIONS 8
        ENGINE=TimeSeries;
        '''
    result = client.execute(sql)
    # The result should be:
    # Affected rows: 0
    print_affected_rows(result)

    # Inserts some data into the `demo` table.
    sql = '''
        INSERT INTO test.demo (ts, sid, value, flag) VALUES
            ('2024-09-01T10:00:00+08:00', 1, 12.5, 0),
            ('2024-09-01T10:05:00+08:00', 2, 15.3, 1),
            ('2024-09-01T10:10:00+08:00', 3, 9.8, 0),
            ('2024-09-01T10:15:00+08:00', 4, 22.1, 1),
            ('2024-09-01T10:20:00+08:00', 5, 30.0, 0);
        '''
    result = client.execute(sql)
    # The result should be:
    # Affected rows: 5
    print_affected_rows(result)

    # Queries the inserted data.
    sql = "SELECT * FROM test.demo"
    result = client.execute(sql)
    # The result should be:
    #                             ts  sid  value  flag
    # 0 2024-09-01 10:00:00+08:00    1   12.5     0
    # 1 2024-09-01 10:05:00+08:00    2   15.3     1
    # 2 2024-09-01 10:15:00+08:00    4   22.1     1
    # 3 2024-09-01 10:20:00+08:00    5   30.0     0
    # 4 2024-09-01 10:10:00+08:00    3    9.8     0
    print(result)

    # Inserts some data into the `demo` table with prepared statement.
    #
    # The with block is used to manage the life cycle of the prepared statement automatically.
    # Otherwise, you have call the `close` method of the prepared statement manually.
    sql = "INSERT INTO test.demo (ts, sid, value, flag) VALUES (?, ?, ?, ?);"
    with client.prepare(sql) as prepared_stmt:
        binding = make_test_batch()
        result = client.execute_prepared(prepared_stmt, binding)
        # The result should be:
        # Affected rows: 5
        print_affected_rows(result)

    # Queries the inserted data with prepared statement.
    sql = "SELECT * FROM test.demo WHERE sid = ?"
    with client.prepare(sql) as prepared_stmt:
        # Retrieves all rows with `sid` == 1.
        sid_values = pa.array([1], type=pa.int32())
        binding = pa.RecordBatch.from_arrays([sid_values], ['sid'])
        result = client.execute_prepared(prepared_stmt, binding)
        # The result should be:
        #                                  ts  sid  value  flag
        # 0 2024-09-01 10:00:00+08:00    1   12.5     0
        # 1 2024-09-02 10:00:00+08:00    1   12.5     0
        print(result)

        # Retrieves all rows with `sid` == 2.
        sid_values = pa.array([2], type=pa.int32())
        binding = pa.RecordBatch.from_arrays([sid_values], ['sid'])
        result = client.execute_prepared(prepared_stmt, binding)
        # The result should be:
        #                                  ts  sid  value  flag
        # 0 2024-09-01 10:05:00+08:00    2   15.3     1
        # 1 2024-09-02 10:05:00+08:00    2   15.3     1
        print(result)


if __name__ == "__main__":
    main()
```

:::
