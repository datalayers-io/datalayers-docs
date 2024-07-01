# 配置文件字段

## [server]

### standalone

启动 Datalayers 服务的模式，默认为集群模式，需要关注`storage.fdb.cluster_file`和`node`相关设置项。

若需要以单机模式启动，请设置`standalone=true`（或者通过命令行参数进行指定。 如：`datalayers standalone`）。

### addr

配置 Arrow FlightSql 协议的服务端通信的地址与端口。

### http

Datalayers 的 HTTP 服务端口配置。

### session_timeout

连接 Datalayers 服务端超时时间设置。

### timezone

Datalayers 服务端所在时区设置。

### enable_influxdb_schemaless

是否开启 InfluxDB 的`influxdb schemaless`功能。默认为`true`

## [server.auth]

### username

认证用户名。

### password

认证密码。

### token

认证 token。

### jwt_secret

JSON Web Token。


## [ts_engine]

### worker_channel_size

单线程最大请求通道数量设置。

### flush_on_exit

`datalayers` 退出之前是否将 memtable 中的数据进行刷盘，默认为: `true`。
```tips
设置为true，退出时会增加相应的时间开销，但在系统重启时，则可更快的启动（重启时不需要将 wal 中的数据进行重放到内存）。
设置为false时，退出则更为快速，但是系统重新启动时将花费更长的时间（需将`wal`中的数据重放到内存）。
```

## [ts_engine.wal]

### type

wal 日志类型，默认为本地支持。

### disable

是否禁用写入 wal 和从 wal 回放。如果需要强一致性，生产环境中必须将其设置为 false，缺省值为: false。

### path

指定 `wal` 文件存储的目录。

### max_file_size

wal 文件最大尺寸。

注：仅当`type=local`时该配置有效。

## [storage]

## [storage.local]

### path

本地存储目录设置。

## [storage.fdb]

### cluster_file

连接 FoundationDB 的 cluster 文件路径设置。

注：该配置项仅在集群模式下生效。

### namespace

用于隔离 Datalayers 键值的命名空间设置。

## [storage.object_store.s3]

### buket

s3 对象存储相关设置。

### root

s3 对象存储相关设置。

### access_key

s3 对象存储相关设置。

### secret_key

s3 对象存储相关设置。

### endpoint

s3 对象存储相关设置。

### region

s3 对象存储相关设置。

## [node]

### name

节点的名称，群集中节点的唯一标识符。

### connect_timeout

连接到集群超时时间设置。

### timeout

请求超时时间。

### retry_count

最大重连次数设置。

### data_path

集群节点数据存储目录设置。

### rpc_max_conn

RPC 端口间最大并发连接数设置。

### rpc_min_conn

RPC 端口间最小并发连接数设置。

## [scheduler]

## [scheduler.flush]

### concurrence_limit

同时进行刷盘的最大作业数量设置。

### queue_limit

刷盘的最大队列数量设置。

## [scheduler.gc]

### concurrence_limit

同时运行 gc 作业的最大数量设置。

### queue_limit

gc 作业的最大队列数量设置。

## [scheduler.cluster_compact_inactive]

### concurrence_limit

同时运行“cluster compact inactive”作业的最大数量设置。

## [license]

### key

配置 License。

## [log]

### dir

Datalayers 日志目录设置。

### level

Datalayers 日志等级设置。

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

### more_verbose

日志信息中是否包含文件名和行号，默认为`true`
