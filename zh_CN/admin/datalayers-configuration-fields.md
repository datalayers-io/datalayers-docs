# 配置文件字段

## server

### standalone

启动 Datalayers 服务的模式，默认为集群模式，需要关注`storage.fdb.cluster_file`和`node`相关设置项。

若需要以单机模式启动，请设置`standalone=true`（或者通过命令行参数进行指定。 如：`datalayers standalone`）。

### addr

配置 Arrow FlightSql 协议的服务端通信的地址与端口，推荐使用该协议进行交互。
注： 如禁用该配置项 `dlsql` 也将不能使用（dlsql 使用该协议与 Datalayers 进行交互）。

### http

Datalayers 的 HTTP 服务端口配置，如不需 HTTP 服务，将该项注释掉即可。

### redis
配置 key-value 服务，该服务使用 Redis 进行交互，该配置项默认关闭。
注：只有在集群模式下才支持 key-value 存储模型。

### session_timeout

连接 Datalayers 服务端超时时间设置。

### timezone

设置 Datalayers 时区。


## server.auth

### username

认证用户名。

### password

认证密码。

### token

认证 token。

### jwt_secret

JSON Web Token。


## schemaless
### auto_alter_table

schemaless 写入时，是否允许自动改表。默认为`true`，生产环境建议为 `false`。

## ts_engine
时序引擎相关的配置项。

### flush_on_exit

`datalayers` 退出之前是否将 memtable 中的数据进行刷盘，默认为: `true`。
```tips
设置为true，退出时会增加相应的时间开销，但在系统重启时，则可更快的启动（重启时不需要将 wal 中的数据进行重放到内存）。
设置为false时，退出则更为快速，但是系统重新启动时将花费更长的时间（需将`wal`中的数据重放到内存）。
生产环境中请设置为 `true`。
```

## ts_engine.wal
时序引擎中， wal 相关的配置项。
### type

wal 日志类型，缺省值为：`local`，目前仅支持 `local`。

### path

指定 `wal` 文件存储的目录。

### max_file_size

wal 文件最大尺寸。

## storage
存储相关的配置项。
## storage.local

### path

本地存储目录设置。

## storage.fdb

### cluster_file

连接 FoundationDB 的 cluster 文件路径设置。

注：该配置项仅在集群模式下生效。

### namespace

用于隔离 Datalayers 键值的命名空间设置。

### max_flush_speed
限制 FDB 的写入速度，该配置仅作用于当前节点。

## storage.object_store.s3
对象存储的配置项，配置该项后，在建表时可通过指定`STORAGE_TYPE=S3`，将数据存储到 `S3` 中。
### bucket

指定 S3 的 bucket。

### access_key

指定 s3 的 access_key。

### secret_key

指定 s3 的 secret_key。

### endpoint

指定 s3 的 endpoint。

### region

指定 s3 的 region。

## node
集群的配置项，当`server.standalone = false` 时，以下配置会生效。
### name

集群内节点的通讯地址（集群地该名称必须是唯一的），推荐使用 FQDN。

### connect_timeout

连接到集群超时时间。

### timeout

集群间通信请求超时时间。

### retry_count

集群间通讯时连接最大重试次数设置。

### data_path

节点数据存储目录设置。

### rpc_max_conn

RPC 端口间最大活动连接数设置。

### rpc_min_conn

RPC 端口间最小活动连接数设置。

## scheduler
后台任务相关配置项。
## scheduler.flush

### concurrence_limit

设置同时进行 flush 的最大并行数量。

### queue_limit

设置 flush 的最大队列数。

## scheduler.gc

### concurrence_limit

同时运行 gc 作业的最大数量设置。

### queue_limit

gc 作业的最大队列数量设置。

## scheduler.cluster_compact_inactive

### concurrence_limit

配置集群中 `compact` 作业的最大并行数量。

## runtime
Datalayers 支持前台线程（用户读、写）与后台线程（compaction、gc等）分离，即：从 CPU 物理核上进行隔离，从而保证后台任务不影响用户请求（读写）。默认情况下，前后台线程均在一个 runtime 中，共享当前系统所有 CPU 资源，如需要分离，则需通过以下配置。
### default
#### cpu_cores
浮点值。设置后台任务的工作线程数量  
* 0 表未对于该 runtime 不进行限制
* 大于 1 表示 CPU 的约数数量  
* 0-1 之间表示该运行时占 CPU 核心的百分比，如：0.2 表示20%

### background
如设置了 background 的值，在 default 不配置的情况下，default runtime 会默认使用剩下的 CPU CORE。
#### cpu_cores
与 default 相同。




## log

### path

指定 Datalayers 日志的存储路径，缺省值为：`/var/log/datalayers/`。

### level

设置 Datalayers 日志等级。

可选值为：
- default（默认）
- trace
- debug
- info
- warn
- error

### rotation

切换到新日志文件的时间设置。

可选值为：
- "MINUTELY" or "M"
- "HOURLY" or "H"（默认）
- "DAILY" or "D"
- "NEVER" or "N"

### enable_stdout

是否启用日志标准输出，默认为`true`

### enable_file

是否启用日志输出到文件，默认为`false`

### enable_err_file

是否启用专用的错误日志文件，默认为`false`

### verbose

日志信息中是否包含文件名和行号，默认为`true`

## license

### key

配置 License，将 License 的内容复制到此处。
