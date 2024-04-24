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

// todo , 链接到 github 代码示例。

::: code-group
```Go [Go]
package main

import (
	"context"
	"fmt"

	"github.com/apache/arrow/go/v16/arrow/flight/flightsql"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
	"google.golang.org/grpc/metadata"
)

type customClientInterceptor struct {
}

// use the Interceptor to 
func (i *customClientInterceptor) UnaryInterceptor(
	ctx context.Context,
	method string,
	req, reply interface{},
	cc *grpc.ClientConn,
	invoker grpc.UnaryInvoker,
	opts ...grpc.CallOption,
) error {
	md := metadata.Pairs(
		"database", "demo",
	)
	ctx = metadata.NewOutgoingContext(ctx, md)
	return invoker(ctx, method, req, reply, cc, opts...)
}

func (i *customClientInterceptor) StreamInterceptor(
	ctx context.Context,
	desc *grpc.StreamDesc,
	cc *grpc.ClientConn,
	method string,
	streamer grpc.Streamer,
	opts ...grpc.CallOption,
) (grpc.ClientStream, error) {
	md := metadata.Pairs(
		"database", "demo",
	)
	ctx = metadata.NewOutgoingContext(ctx, md)
	return streamer(ctx, desc, cc, method, opts...)
}

func main() {
	addr := "127.0.0.1:5360"

	interceptor := &customClientInterceptor{}
	var dialOpts = []grpc.DialOption{
		grpc.WithUnaryInterceptor(interceptor.UnaryInterceptor),
		grpc.WithStreamInterceptor(interceptor.StreamInterceptor),
		grpc.WithTransportCredentials(insecure.NewCredentials()),
	}
	cl, err := flightsql.NewClient(addr, nil, nil, dialOpts...)
	if err != nil {
		fmt.Println(err)
		return
	}

	ctx := context.Background()
	info, err := cl.Execute(ctx, "SELECT 1;")
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
			fmt.Printf("rec[%d][%q]: %v\n", n, record.ColumnName(i), col)
		}
		record.Column(0)
		n++
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

```

```rust [Rust-code]
use arrow_array::RecordBatch;
use arrow_cast::pretty::pretty_format_batches;
use arrow_flight::sql::client::FlightSqlServiceClient;
use arrow_schema::Schema;
use futures::TryStreamExt;
use std::{sync::Arc, time::Duration};

use anyhow::{bail, Context, Result};
use tokio::sync::Mutex;
use tonic::transport::{Channel, Endpoint};
pub struct Ctx {
    pub host: String,
    pub port: u16,
    pub username: Option<String>,
    pub password: Option<String>,
    pub database: Option<String>,
    pub _timezone: Option<String>,
}
use prost::Message;
pub struct Executor {
    ctx: Arc<Mutex<Ctx>>,
    client: FlightSqlServiceClient<Channel>,
}

impl Executor {
    pub async fn new(ctx: Arc<Mutex<Ctx>>) -> anyhow::Result<Executor> {
        let protocol = "http";

        let ctx_cp = ctx.clone();

        let ctx = ctx.lock().await;

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

        Ok(Executor {
            ctx: ctx_cp,
            client,
        })
    }

    pub async fn execute_flight(&mut self, sql: String) -> Result<Vec<RecordBatch>> {
        let ctx = self.ctx.clone();
        let session = ctx.lock().await;
        if session.database.is_some() {
            self.client
                .set_header("database", session.database.clone().unwrap());
            println!("database is : {}", session.database.clone().unwrap());
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
}

#[tokio::main]
async fn main() {
    let ctx = Ctx {
        host: "localhost".to_string(),
        port: 5360,
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
    let ctx = Arc::new(Mutex::new(ctx));
    let mut executor = Executor::new(ctx).await.unwrap();

    // change the sql what you want
    let some = executor.execute_flight(format!("select 1")).await.unwrap();

    // print the formated results
    let res = pretty_format_batches(some.as_slice())
        .context("format results")
        .unwrap();
    println!("{}", res.to_string());
}
```

```java [Java]
//todo

```

:::

完整示例参考：https://github.com/datalayers-io/datalayers/tree/main/examples
