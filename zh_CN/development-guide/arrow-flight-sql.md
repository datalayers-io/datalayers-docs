# Arrow Flight SQL

Arrow Flight SQL 是一种使用 Arrow 内存格式和 Flight RPC 框架与 SQL 数据库交互的协议。Datalayers 支持 [Arrow Flight SQL](https://arrow.apache.org/docs/format/FlightSql.html#arrow-flight-sql) 协议，可使用支持 Arrow Flight SQL 的相关 SDK 进行接入。

## Arrow Flight SQL 优势

**高性能数据交互**：Arrow Flight SQL 基于 Arrow 数据格式和 Flight RPC 框架，可实现高性能的数据交互。
**协议化**：Arrow Flight SQL 使用 Protobuf 定义了一组 RPC 方法和消息格式，这提供了协议化的数据传输和交互。这有助于实现与不同系统和编程语言的互操作性。  
**数据格式一致性**：通过使用 Arrow 数据格式，Arrow Flight SQL 可以确保数据在不同系统之间的一致性。这有助于避免数据转换和格式问题，简化了数据交换过程。  

## 接入

目前我们支持Arrow Flight SQL 客户端的环境有：

* Go
* Rust
* Java
* Python

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
```

```rust [Rust]

// [dependencies]
// tonic = { version = "*", features = ["transport", "codegen", "prost"] }
// arrow-array = "51.0.0"
// arrow-cast = { version = "*", features = ["prettyprint"] }
// arrow-flight = { version = "*", features = ["flight-sql-experimental", "tls"] }
// arrow-schema = "51.0.0"
// tokio = "*"
// futures = "*"
// anyhow = "1.0.82"
// prost = "0.12"
// prost-types = "0.12"

use arrow_array::{Array, Int32Array, RecordBatch};
use arrow_cast::pretty::pretty_format_batches;
use arrow_flight::sql::client::FlightSqlServiceClient;
use arrow_schema::{DataType, Field, Schema};
use futures::{StreamExt, TryStreamExt};
use std::{sync::Arc, time::Duration};

use anyhow::{bail, Context, Result};
use tokio::sync::Mutex;
use tonic::{
    transport::{Channel, Endpoint},
    IntoRequest,
};

#[derive(Clone)]
pub struct Ctx {
    pub host: String,
    pub port: u16,
    pub username: Option<String>,
    pub password: Option<String>,
    pub database: Option<String>,
    pub _timezone: Option<String>,
}
pub struct Executor {
    ctx: Ctx,
    client: FlightSqlServiceClient<Channel>,
}

impl Executor {
    pub async fn new(ctx: Ctx) -> anyhow::Result<Executor> {
        let protocol = "http";

        let endpoint = Endpoint::new(format!("{}://{}:{}", protocol, ctx.host, ctx.port))
            .context("create endpoint")?
            .connect_timeout(Duration::from_secs(20))
            .timeout(Duration::from_secs(20))
            .tcp_nodelay(true) // Disable Nagle's Algorithm since we don't want packets to wait
            .tcp_keepalive(Option::Some(Duration::from_secs(3600)))
            .http2_keep_alive_interval(Duration::from_secs(300))
            .keep_alive_timeout(Duration::from_secs(20))
            .keep_alive_while_idle(true);

        let channel = endpoint.connect().await.context("connect to endpoint")?;

        let mut client = FlightSqlServiceClient::new(channel);

        if let Some(database) = &ctx.database {
            client.set_header("database", database);
        }

        match (ctx.username.clone(), ctx.password.clone()) {
            (None, None) => {}
            (Some(username), Some(password)) => {
                client
                    .handshake(&username, &password)
                    .await
                    .context("handshake")?;
            }
            (Some(_), None) => {
                bail!("when username is set, you also need to set a password")
            }
            (None, Some(_)) => {
                bail!("when password is set, you also need to set a username")
            }
        }

        Ok(Executor { ctx: ctx, client })
    }

    pub async fn execute_flight(&mut self, sql: String) -> Result<Vec<RecordBatch>> {
        let ctx = self.ctx.clone();
        if ctx.database.is_some() {
            self.client
                .set_header("database", ctx.database.clone().unwrap());
        }

        let flight_info = self.client.execute(sql, None).await?;

        let schema = Arc::new(Schema::try_from(flight_info.clone()).context("valid schema")?);
        let mut batches = Vec::with_capacity(flight_info.endpoint.len() + 1);
        batches.push(RecordBatch::new_empty(schema));

        for endpoint in flight_info.endpoint {
            let Some(ticket) = &endpoint.ticket else {
                bail!("did not get ticket");
            };

            let mut flight_data = self.client.do_get(ticket.clone()).await?;

            let endpoint_batches: std::prelude::v1::Result<
                Vec<_>,
                arrow_flight::error::FlightError,
            > = (&mut flight_data).try_collect().await;

            if endpoint_batches.is_err() {
                let err = endpoint_batches.err().unwrap();
                println!("Datalayers connection error: {:?}", err);
                bail!(err);
            }

            batches.append(&mut endpoint_batches.unwrap());
        }

        Ok(batches)
    }

    pub async fn execute_prepared_statement(
        &mut self,
        sql: String,
        batch: RecordBatch,
    ) -> Result<Vec<RecordBatch>> {
        let ctx = self.ctx.clone();
        if ctx.database.is_some() {
            self.client
                .set_header("database", ctx.database.clone().unwrap());
        }

        let mut channel = self.client.prepare(sql, None).await.unwrap();
        channel.set_parameters(batch)?;

        let mut info = channel.execute().await?;
        let ticket = info.endpoint.remove(0).ticket.unwrap();
        let batches = self
            .client
            .do_get(ticket)
            .await?
            .try_collect()
            .await
            .unwrap();
        Ok(batches)
    }
}

#[tokio::main]
async fn main() {
    let ctx = Ctx {
        host: "localhost".to_string(),
        port: 8360,
        username: Some("admin".to_string()),
        password: Some("public".to_string()),
        database: Some("test".to_string()),
        _timezone: Some("UTC+8".to_string()),
    };

    println!("host: {}", ctx.host);
    println!("port: {}", ctx.port);
    match ctx.username {
        Some(ref username) => println!("username: {}", username),
        None => println!("username: None"),
    }
    match ctx.password {
        Some(ref password) => println!("password: {}", password),
        None => println!("password: None"),
    }
    match ctx.database {
        Some(ref database) => println!("database: {}", database),
        None => println!("database: None"),
    }
    match ctx._timezone {
        Some(ref timezone) => println!("timezone: {}", timezone),
        None => println!("timezone: None"),
    }

    // construct the executor
    let mut executor = Executor::new(ctx).await.unwrap();

    // create database
    {
        let some: Vec<RecordBatch> = executor
            .execute_flight(format!("create database test;"))
            .await
            .unwrap();
        let res = pretty_format_batches(some.as_slice())
            .context("format results")
            .unwrap();
        println!("{}", res.to_string());
    }

    // create table
    {
        let some: Vec<RecordBatch> = executor
            .execute_flight(format!(
                "CREATE TABLE test.sx1 (
                 ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                 sid INT32,
                 value REAL,
                 flag INT8,
                 timestamp key(ts)
                 )
                 PARTITION BY HASH(sid) PARTITIONS 32
                 ENGINE=TimeSeries"
            ))
            .await
            .unwrap();
        let res = pretty_format_batches(some.as_slice())
            .context("format results")
            .unwrap();
        println!("{}", res.to_string());
    }

    // insert some data
    {
        let some: Vec<RecordBatch> = executor
            .execute_flight(format!(
                "INSERT INTO test.sx1 (sid, value, flag) VALUES (1, 1.1, 1);"
            ))
            .await
            .unwrap();
        let res = pretty_format_batches(some.as_slice())
            .context("format results")
            .unwrap();
        println!("{}", res.to_string());
    }

    // run normal query
    {
        let some: Vec<RecordBatch> = executor
            .execute_flight(format!("SELECT count(*) from test.sx1;"))
            .await
            .unwrap();
        let res = pretty_format_batches(some.as_slice())
            .context("format results")
            .unwrap();
        println!("{}", res.to_string());
    }

    // run prepared statement
    {
        // declare a RecordBatch
        let schema = Arc::new(Schema::new(vec![Field::new("t", DataType::Int32, false)]));
        // int32 array
        let array = Int32Array::from(vec![1]);
        let columns = vec![Arc::new(array) as Arc<dyn Array>];
        let batch = RecordBatch::try_new(schema, columns).unwrap();

        let some: Vec<RecordBatch> = executor
            .execute_prepared_statement(
                format!("SELECT count(*) from test.sx1 where sid = ?;"),
                batch,
            )
            .await
            .unwrap();

        let res = pretty_format_batches(some.as_slice())
            .context("format results")
            .unwrap();
        println!("{}", res.to_string());
    }
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

    public static void main(String[] args) {
        BufferAllocator allocator = new RootAllocator(Integer.MAX_VALUE);
        final Location clientLocation = Location.forGrpcInsecure("127.0.0.1", 8360);

        FlightClient client = FlightClient.builder(allocator, clientLocation).build();
        FlightSqlClient sqlClient = new FlightSqlClient(client);

        Optional<CredentialCallOption> credentialCallOption = client.authenticateBasicToken("admin", "public");
        final CallHeaders headers = new FlightCallHeaders();
        Set<CallOption> options = new HashSet<>();
        headers.insert("database", "test");

        credentialCallOption.ifPresent(options::add);
        options.add(new HeaderCallOption(headers));
        CallOption[] callOptions = options.toArray(new CallOption[0]);

        try {
            final FlightInfo info = sqlClient.execute("create database test", callOptions);
            final Ticket ticket = info.getEndpoints().get(0).getTicket();
            try (FlightStream stream = sqlClient.getStream(ticket, callOptions)) {
                int n = 0;
                while (stream.next()) {
                    System.out.println("create database result:");
                    List<FieldVector> vectors = stream.getRoot().getFieldVectors();
                    for (int i = 0; i < vectors.size(); i++) {
                        System.out.printf("%d %d %s\n", n, i , vectors.get(i));
                    }
                    n++;
                }
            } catch (Exception e) {
                throw new RuntimeException(e);
            }
        } catch (Exception e){
           throw new RuntimeException(e);
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
            final FlightInfo info = sqlClient.execute(query, callOptions);
            final Ticket ticket = info.getEndpoints().get(0).getTicket();
            try (FlightStream stream = sqlClient.getStream(ticket, callOptions)) {
                int n = 0;
                while (stream.next()) {
                    System.out.println("create table result:");
                    List<FieldVector> vectors = stream.getRoot().getFieldVectors();
                    for (int i = 0; i < vectors.size(); i++) {
                        System.out.printf("%d %d %s\n", n, i , vectors.get(i));
                    }
                    n++;
                }
            } catch (Exception e) {
                throw new RuntimeException(e);
            }
        } catch (Exception e){
            throw new RuntimeException(e);
        }

        try {
            String query = "INSERT INTO test.sx1 (sid, value, flag) VALUES (1, 1.1, 1);";
            final FlightInfo info = sqlClient.execute(query, callOptions);
            final Ticket ticket = info.getEndpoints().get(0).getTicket();
            try (FlightStream stream = sqlClient.getStream(ticket, callOptions)) {
                int n = 0;
                while (stream.next()) {
                    System.out.println("insert result:");
                    List<FieldVector> vectors = stream.getRoot().getFieldVectors();
                    for (int i = 0; i < vectors.size(); i++) {
                        System.out.printf("%d %d %s\n", n, i , vectors.get(i));
                    }
                    n++;
                }
            } catch (Exception e) {
                throw new RuntimeException(e);
            }
        } catch (Exception e){
            throw new RuntimeException(e);
        }

        try {
            String query = "SELECT count(*) from test.sx1;";
            final FlightInfo info = sqlClient.execute(query, callOptions);
            final Ticket ticket = info.getEndpoints().get(0).getTicket();
            try (FlightStream stream = sqlClient.getStream(ticket, callOptions)) {
                int n = 0;
                while (stream.next()) {
                    System.out.println("select result:");
                    List<FieldVector> vectors = stream.getRoot().getFieldVectors();
                    for (int i = 0; i < vectors.size(); i++) {
                        System.out.printf("%d %d %s\n", n, i , vectors.get(i));
                    }
                    n++;
                }
            } catch (Exception e) {
                throw new RuntimeException(e);
            }
        } catch (Exception e){
            throw new RuntimeException(e);
        }

        // prepared statement insert in java
        // `insert into table sx1 (sid, value, flag) values(?, ?, ?);`
        // The ? is a placeholder for the actual value that will be inserted.
        // The actual value is set using the setParameters method.
        // please make sure each col has same length

        // need callOptions argument here~
        try (final FlightSqlClient.PreparedStatement preparedStatement = sqlClient.prepare("insert into table sx1 (sid, value, flag) values(?, ?, ?);", callOptions)) {
            IntVector sids = new IntVector("sid",allocator);
            sids.allocateNew();
            Float4Vector values = new Float4Vector("value",allocator);
            values.allocateNew();
            TinyIntVector flags = new TinyIntVector("flag",allocator);

            sids.setSafe(0,1);
            values.setSafe(0, 1.0F);
            flags.setSafe(0, (byte)1);

            List<Field> fields = Arrays.asList(sids.getField(), values.getField(), flags.getField());
            List<FieldVector> fieldVectors = Arrays.asList(sids, values, flags);
            VectorSchemaRoot vectorSchemaRoot = new VectorSchemaRoot(fields, fieldVectors);
            vectorSchemaRoot.setRowCount(1);
            preparedStatement.setParameters(vectorSchemaRoot);
            
            // need callOptions argument here~
            final FlightInfo info = preparedStatement.execute(callOptions);
            final Ticket ticket = info.getEndpoints().get(0).getTicket();
            
            // need callOptions argument here~
            try (FlightStream stream = sqlClient.getStream(ticket, callOptions)) {
                int n = 0;
                while (stream.next()) {
                    System.out.println("prepared statement get result:");
                    List<FieldVector> vectors = stream.getRoot().getFieldVectors();
                    for (int i = 0; i < vectors.size(); i++) {
                        System.out.printf("%d %d %s\n", n, i , vectors.get(i));
                    }
                    n++;
                }
            } catch (Exception e) {
                throw new RuntimeException(e);
            }

            // need callOptions argument here~
            preparedStatement.close(callOptions);
        }
        // batch prepared statement insertion
        try (final FlightSqlClient.PreparedStatement preparedStatement = sqlClient.prepare("insert into table sx1 (sid, value, flag) values(?, ?, ?);", callOptions)) {
            IntVector sids = new IntVector("sid",allocator);
            sids.allocateNew();
            Float4Vector values = new Float4Vector("value",allocator);
            values.allocateNew();
            TinyIntVector flags = new TinyIntVector("flag",allocator);

            for (int i = 0;i < 100;i ++){
                sids.setSafe(i, i);
                values.setSafe(i, (float) i);
                flags.setSafe(i, (byte)i);
            }

            List<Field> fields = Arrays.asList(sids.getField(), values.getField(), flags.getField());
            List<FieldVector> fieldVectors = Arrays.asList(sids, values, flags);
            VectorSchemaRoot vectorSchemaRoot = new VectorSchemaRoot(fields, fieldVectors);
            // remember set right row count
            vectorSchemaRoot.setRowCount(100);
            preparedStatement.setParameters(vectorSchemaRoot);
            final FlightInfo info = preparedStatement.execute(callOptions);
            final Ticket ticket = info.getEndpoints().get(0).getTicket();
            try (FlightStream stream = sqlClient.getStream(ticket, callOptions)) {
                int n = 0;
                while (stream.next()) {
                    System.out.println("prepared batch insert statement get result:");
                    List<FieldVector> vectors = stream.getRoot().getFieldVectors();
                    for (int i = 0; i < vectors.size(); i++) {
                        System.out.printf("%d %d %s\n", n, i , vectors.get(i));
                    }
                    n++;
                }
            } catch (Exception e) {
                throw new RuntimeException(e);
            }
            preparedStatement.close(callOptions);
        }

        // need callOptions argument here~
        try (final FlightSqlClient.PreparedStatement preparedStatement = sqlClient.prepare("select count(*) from test.sx1 where sid = ?;", callOptions)) {
            IntVector sids = new IntVector("sid",allocator);
            sids.allocateNew();

            sids.setSafe(0,1);
            List<Field> fields = Arrays.asList(sids.getField());
            List<FieldVector> fieldVectors = Arrays.asList(sids);
            VectorSchemaRoot vectorSchemaRoot = new VectorSchemaRoot(fields, fieldVectors);
            vectorSchemaRoot.setRowCount(1);
            preparedStatement.setParameters(vectorSchemaRoot);

            // need callOptions argument here~
            final FlightInfo info = preparedStatement.execute(callOptions);
            final Ticket ticket = info.getEndpoints().get(0).getTicket();

            // need callOptions argument here~
            try (FlightStream stream = sqlClient.getStream(ticket, callOptions)) {
                int n = 0;
                while (stream.next()) {
                    System.out.println("prepared statement get result:");
                    List<FieldVector> vectors = stream.getRoot().getFieldVectors();
                    for (int i = 0; i < vectors.size(); i++) {
                        System.out.printf("%d %d %s\n", n, i , vectors.get(i));
                    }
                    n++;
                }
            } catch (Exception e) {
                throw new RuntimeException(e);
            }
            preparedStatement.close(callOptions);
        }
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
    <dependency>
      <groupId>org.projectlombok</groupId>
      <artifactId>lombok</artifactId>
      <version>1.18.32</version>
      <scope>provided</scope>
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
  </dependencies>
</project>
*/

```

``` Python [Python]
# Install dependencies:
# pip install pyarrow flightsql-dbapi pandas protobuf

from flightsql import FlightSQLClient, FlightSQLCallOptions
from flightsql.client import PreparedStatement
from typing import Dict, Optional, Any
from google.protobuf import any_pb2
import flightsql.flightsql_pb2 as flightsql_pb
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

        #! Since the flightsql-dbapi library misses setting options for do_put, we have to manually pass in the options.
        #! We have filed a pull request to fix this issue. When the PR is merged, the codes could be simplified to:
        #! ``` Python
        #! flight_info = prepared_stmt.execute(binding)
        #! ticket = flight_info.endpoints[0].ticket
        #! reader = self.inner.do_get(ticket)
        #! df = reader.read_pandas()
        #! return df
        #! ```

        cmd = flightsql_pb.CommandPreparedStatementQuery(
            prepared_statement_handle=prepared_stmt.handle)
        desc = make_flight_descriptor(cmd)

        if binding is not None and binding.num_rows > 0:
            writer, reader = self.inner.client.do_put(
                desc, binding.schema, prepared_stmt.options)
            writer.write(binding)
            writer.done_writing()
            reader.read()

        flight_info = self.inner.client.get_flight_info(
            desc, prepared_stmt.options)
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
