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
* Python
* 基于Arrow Flight SQL 的 JDBC
* 基于Arrow Flight SQL 的 ODBC


::: code-group
```Go [Go]
package main

import (
	"context"
	"fmt"

	"github.com/apache/arrow/go/v16/arrow"
	"github.com/apache/arrow/go/v16/arrow/array"
	"github.com/apache/arrow/go/v16/arrow/flight/flightsql"
	"github.com/apache/arrow/go/v16/arrow/memory"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

func main() {
	addr := "127.0.0.1:8360"
	var dialOpts = []grpc.DialOption{
		grpc.WithTransportCredentials(insecure.NewCredentials()),
	}
	cl, err := flightsql.NewClient(addr, nil, nil, dialOpts...)
	if err != nil {
		fmt.Println(err)
		return
	}
	ctx, err := cl.Client.AuthenticateBasicToken(context.Background(), "admin", "public")
	if err != nil {
		fmt.Print(err)
		return
	}

	// create database
	db_create_info, err := cl.Execute(ctx, "create database test;")
	if err != nil {
		fmt.Println(err)
		return
	}
	_, err = cl.DoGet(ctx, db_create_info.GetEndpoint()[0].Ticket)
	if err != nil {
		fmt.Println(err)
		return
	}

	// create table	test
	table_create_info, err := cl.Execute(ctx, "CREATE TABLE test.sx1 (" +
	              "ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP," +
	              "sid INT32," +
	              "value REAL," +
	              "flag INT8,"  +
	              "timestamp key(ts)" +
	              ")" +
	              "PARTITION BY HASH(sid) PARTITIONS 32" +
	              "ENGINE=TimeSeries")
	if err != nil {
		fmt.Println(err)
		return
	}
	_, err = cl.DoGet(ctx, table_create_info.GetEndpoint()[0].Ticket)
	if err != nil {
		fmt.Println(err)
		return
	}

	// insert some value
	insert_info, err := cl.Execute(ctx, "INSERT INTO test.sx1 (sid, value, flag) VALUES (1, 1.1, 1);")
	if err != nil {
		fmt.Println(err)
		return
	}
	_, err = cl.DoGet(ctx, insert_info.GetEndpoint()[0].Ticket)
	if err != nil {
		fmt.Println(err)
		return
	}

	insert_info, err = cl.Execute(ctx, "INSERT INTO test.sx1 (sid, value, flag) VALUES (2, 1.1, 1);")
	if err != nil {
		fmt.Println(err)
		return
	}
	_, err = cl.DoGet(ctx, insert_info.GetEndpoint()[0].Ticket)
	if err != nil {
		fmt.Println(err)
		return
	}

	{
		info, err := cl.Execute(ctx, "SELECT count(*) from test.sx1;")
		if err != nil {
			fmt.Println(err)
			return
		}
		rdr, err := cl.DoGet(ctx, info.GetEndpoint()[0].Ticket)
		if err != nil {
			fmt.Println(err)
			return
		}
		defer rdr.Release()

		n := 0
		for rdr.Next() {
			record := rdr.Record()
			for i, col := range record.Columns() {
				fmt.Printf("Normal request: rec[%d][%q]: %v\n", n, record.ColumnName(i), col)
			}
			n++
			if n == 10 {
				break
			}
		}
	}

	{
		prp, err := cl.Prepare(ctx, "SELECT count(*) from test.sx1 where sid = ?;")
		if err != nil {
			fmt.Println(err)
			return
		}
		defer prp.Close(ctx)
		alloc := memory.NewGoAllocator()

		// only sid in the statment
		prepared_schema := arrow.NewSchema([]arrow.Field{
			{Name: "sid", Type: arrow.PrimitiveTypes.Uint32},
		}, nil)

		bldr := array.NewRecordBuilder(alloc, prepared_schema)
		defer bldr.Release()

		sid_builder := bldr.Field(0).(*array.Uint32Builder)
		sid_builder.Append(1)

		binding := bldr.NewRecord()
		defer binding.Release()

		prp.SetParameters(binding)
		info, err := prp.Execute(ctx)
		if err != nil {
			fmt.Println(err)
			return
		}
		rdr, err := cl.DoGet(ctx, info.GetEndpoint()[0].Ticket)
		if err != nil {
			fmt.Println(err)
			return
		}
		defer rdr.Release()
		n := 0
		for rdr.Next() {
			record := rdr.Record()
			for i, col := range record.Columns() {
				fmt.Printf("prepared_statment: rec[%d][%q]: %v\n", n, record.ColumnName(i), col)
			}
			n++
			if n == 10 {
				break
			}
		}
	}
}
```

```c++ [C++]
//todo

```

```toml [Rust-dependencies]
[package]
name = "datalayers-rust-example"
version = "0.1.0"
edition = "2021"

# See more keys and their definitions at https://doc.rust-lang.org/cargo/reference/manifest.html

[dependencies]
tonic = { version = "*", features = ["transport", "codegen", "prost"] }
arrow-array = "51.0.0"
arrow-cast = { version = "*", features = ["prettyprint"] }
arrow-flight = { version = "*", features = ["flight-sql-experimental", "tls"] }
arrow-schema = "51.0.0"
tokio = "*"
futures = "*"
anyhow = "1.0.82"
prost = "0.12"
prost-types = "0.12"

[workspace]

```

```rust [Rust-code]
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
                println!("DataLayers connection error: {:?}", err);
                bail!(err);
            }

            batches.append(&mut endpoint_batches.unwrap());
        }

        Ok(batches)
    }

    pub async fn execute_prepared_statment(
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

    // run prepared statment
    {
        // declare a RecordBatch
        let schema = Arc::new(Schema::new(vec![Field::new("t", DataType::Int32, false)]));
        // int32 array
        let array = Int32Array::from(vec![1]);
        let columns = vec![Arc::new(array) as Arc<dyn Array>];
        let batch = RecordBatch::try_new(schema, columns).unwrap();

        let some: Vec<RecordBatch> = executor
            .execute_prepared_statment(
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
import org.apache.arrow.vector.FieldVector;
import org.apache.arrow.vector.IntVector;
import org.apache.arrow.vector.VectorSchemaRoot;
import org.apache.arrow.vector.types.pojo.Field;

import java.util.*;


public class SqlRunner {
    public static void main(String[] args) {
        BufferAllocator allocator = new RootAllocator(Integer.MAX_VALUE);
        final Location clientLocation = Location.forGrpcInsecure("127.0.0.1", 8360);

        FlightClient client = FlightClient.builder(allocator, clientLocation).build();
        FlightSqlClient sqlClinet = new FlightSqlClient(client);

        Optional<CredentialCallOption> credentialCallOption = client.authenticateBasicToken("admin", "public");
        final CallHeaders headers = new FlightCallHeaders();
        Set<CallOption> options = new HashSet<>();

        credentialCallOption.ifPresent(options::add);
        options.add(new HeaderCallOption(headers));
        CallOption[] callOptions = options.toArray(new CallOption[0]);

        try {
            final FlightInfo info = sqlClinet.execute("create database test", callOptions);
            final Ticket ticket = info.getEndpoints().get(0).getTicket();
            try (FlightStream stream = sqlClinet.getStream(ticket, callOptions)) {
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
            final FlightInfo info = sqlClinet.execute(query, callOptions);
            final Ticket ticket = info.getEndpoints().get(0).getTicket();
            try (FlightStream stream = sqlClinet.getStream(ticket, callOptions)) {
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
            final FlightInfo info = sqlClinet.execute(query, callOptions);
            final Ticket ticket = info.getEndpoints().get(0).getTicket();
            try (FlightStream stream = sqlClinet.getStream(ticket, callOptions)) {
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
            final FlightInfo info = sqlClinet.execute(query, callOptions);
            final Ticket ticket = info.getEndpoints().get(0).getTicket();
            try (FlightStream stream = sqlClinet.getStream(ticket, callOptions)) {
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




        try (final FlightSqlClient.PreparedStatement preparedStatement = sqlClinet.prepare("select count(*) from test.sx1 where sid = ?;", callOptions)) {
            IntVector sids = new IntVector("sid",allocator);
            sids.allocateNew();

            sids.setSafe(0,1);
            List<Field> fields = Arrays.asList(sids.getField());
            List<FieldVector> fieldVectors = Arrays.asList(sids);
            VectorSchemaRoot vectorSchemaRoot = new VectorSchemaRoot(fields, fieldVectors);
            vectorSchemaRoot.setRowCount(1);
            preparedStatement.setParameters(vectorSchemaRoot);
            final FlightInfo info = preparedStatement.execute(callOptions);
            final Ticket ticket = info.getEndpoints().get(0).getTicket();
            try (FlightStream stream = sqlClinet.getStream(ticket)) {
                int n = 0;
                while (stream.next()) {
                    System.out.println("prepared statment get result:");
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

```

:::

完整示例参考：https://github.com/datalayers-io/datalayers/tree/main/examples
