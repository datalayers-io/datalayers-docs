# 配置文件字段

## [server]

### standalone

启动 Datalayers 服务的模式，默认为集群模式，你可能需要关注`storage.fdb.cluster_file`和`node`相关设置项。

若需要以单机模式启动，请设置`standalone=true`。

对应环境变量为`DATALAYERS_SERVER__STANDALONE`

### addr

用户通过 Arrow FlightSql 协议与服务端通信的地址和端口设置。

对应环境变量为`DATALAYERS_SERVER__ADDR`

### http

Datalayers 的 HTTP 服务端口设置。

对应环境变量为`DATALAYERS_SERVER__HTTP`

### session_timeout

连接 Datalayers 服务端超时时间设置。

对应环境变量为`DATALAYERS_SERVER__SESSION_TIMEOUT`

### timezone

Datalayers 服务端所在时区设置。

对应环境变量为`DATALAYERS_SERVER__TIMEZONE`

### pid

Datalayers 进程 pid 路径设置。

对应环境变量为`DATALAYERS_SERVER__PID`

### enable_influxdb_schemaless

是否开启 InfluxDB 的`influxdb schemaless`功能。默认为`true`

对应环境变量为`DATALAYERS_SERVER__ENABLE_INFLUXDB_SCHEMALESS`

## [server.auth]

### username

认证用户名。

对应环境变量为`DATALAYERS_SERVER__AUTH__USERNAME`

### password

认证密码。

对应环境变量为`DATALAYERS_SERVER__AUTH__PASSWORD`

### token

认证 token。

对应环境变量为`DATALAYERS_SERVER__AUTH__TOKEN`

### jwt_secret

JSON Web Token。

对应环境变量为`DATALAYERS_SERVER__AUTH__JWT_SECRET`


## [ts_engine]

### worker_channel_size

单线程最大请求通道数量设置。

对应环境变量为`DATALAYERS_TS_ENGINE__WORKER_CHANNEL_SIZE`

### flush_on_exit

系统退出之前是否刷新 memtable。

对应环境变量为`DATALAYERS_TS_ENGINE__FLUSH_ON_EXIT`

## [ts_engine.wal]

### type

WAL 日志类型，默认为本地支持。

对应环境变量为`DATALAYERS_TS_ENGINE__WAL__TYPE`

### disable

是否禁用写入 WAL 和从 WAL 回放。如果需要强一致性，生产环境中必须将其设置为 false。

对应环境变量为`DATALAYERS_TS_ENGINE__WAL__DISABLE`

### skip_replay

重启时是否跳过 WAL 回放。

该配置仅用于开发阶段。

对应环境变量为`DATALAYERS_TS_ENGINE__WAL__SKIP_REPLAY`

### path

WAL 文件目录设置。

对应环境变量为`DATALAYERS_TS_ENGINE__WAL__PATH`

### flush_interval

WAL 缓存持久化的间隔时间，设置为 0 则立刻触发。

注：仅当`type=local`时该配置有效。

对应环境变量为`DATALAYERS_TS_ENGINE__WAL__FLUSH_INTERVAL`

### max_file_size

WAL 文件最大尺寸。

注：仅当`type=local`时该配置有效。

对应环境变量为`DATALAYERS_TS_ENGINE__WAL__MAX_FILE_SIZE`

## [storage]

## [storage.local]

### path

本地存储目录设置。

对应环境变量为`DATALAYERS_STORAGE__LOCAL__LOCAL`

## [storage.fdb]

### cluster_file

连接 FoundationDB 的 cluster 文件路径设置。

注：该配置项仅在集群模式下生效。

对应的环境变量为`DATALAYERS_STORAGE__FDB__CLUSTER_FILE`

### namespace

用于隔离 Datalayers 键值的命名空间设置。

对应的环境变量为`DATALAYERS_STORAGE__FDB__NAMESPACE`

## [storage.object_store.s3]

### buket

s3 对象存储相关设置。

对应的环境变量为`DATALAYERS_STORAGE__OBJECT__STORE__S3__BUKET`

### root

s3 对象存储相关设置。

对应的环境变量为`DATALAYERS_STORAGE__OBJECT__STORE__S3__ROOT`

### access_key

s3 对象存储相关设置。

对应的环境变量为`DATALAYERS_STORAGE__OBJECT__STORE__S3__ACCESS_KEY`

### secret_key

s3 对象存储相关设置。

对应的环境变量为`DATALAYERS_STORAGE__OBJECT__STORE__S3__SECRET_KEY`

### endpoint

s3 对象存储相关设置。

对应的环境变量为`DATALAYERS_STORAGE__OBJECT__STORE__S3__ENDPOINT`

### region

s3 对象存储相关设置。

对应的环境变量为`DATALAYERS_STORAGE__OBJECT__STORE__S3__REGION`

## [node]

### name

节点的名称，群集中节点的唯一标识符。

对应的环境变量为`DATALAYERS_NODE__NAME`

### connect_timeout

连接到集群超时时间设置。

对应的环境变量为`DATALAYERS_NODE__CONNECT_TIMEOUT`

### timeout

发送到集群的请求超时时间设置。

对应的环境变量为`DATALAYERS_NODE__TIMEOUT`

### retry_count

最大重连次数设置。

对应的环境变量为`DATALAYERS_NODE__RETRY_COUNT`

### data_path

集群节点数据存储目录设置。

对应的环境变量为`DATALAYERS_NODE__DATA_PATH`

### rpc_max_conn

RPC 端口间最大并发连接数设置。

对应的环境变量为`DATALAYERS_NODE__RPC_MAX_CONN`

### rpc_min_conn

RPC 端口间最小并发连接数设置。

对应的环境变量为`DATALAYERS_NODE__RPC_MIN_CONN`

## [scheduler]

## [scheduler.flush]

### concurrence_limit

同时进行刷盘的最大作业数量设置。

对应的环境变量为`DATALAYERS_SCHEDULER__FLUSH__CONCURRENCE_LIMIT`

### queue_limit

刷盘的最大队列数量设置。

对应的环境变量为`DATALAYERS_SCHEDULER__FLUSH__QUEUE_LIMIT`

## [scheduler.gc]

### concurrence_limit

同时运行 gc 作业的最大数量设置。

对应的环境变量为`DATALAYERS_SCHEDULER__GC__CONCURRENCE_LIMIT`

### queue_limit

gc 作业的最大队列数量设置。

对应的环境变量为`DATALAYERS_SCHEDULER__GC__QUEUE_LIMIT`

## [scheduler.cluster_compact_inactive]

### concurrence_limit

同时运行“cluster compact inactive”作业的最大数量设置。

对应的环境变量为`DATALAYERS_SCHEDULER__CLUSTER_COMPACT_INACTIVE__CONCURRENCE_LIMIT`

## [license]

### key

许可证密钥设置。

对应的环境变量为`DATALAYERS_LICENSE__KEY`

## [log]

### dir

Datalayers 日志目录设置。

对应的环境变量为`DATALAYERS_LOG__DIR`

### level

Datalayers 日志等级设置。

可选值为：
- default（默认）
- trace
- debug
- info
- warn
- error

对应的环境变量为`DATALAYERS_LOG__LEVEL`

### rotation

切换到新日志文件的时间设置。

可选值为：
- "MINUTELY" or "M"
- "HOURLY" or "H"（默认）
- "DAILY" or "D"
- "NEVER" or "N"

对应的环境变量为`DATALAYERS_LOG__ROTATION`

### enable_stdout

是否启用日志标准输出，默认为`true`

对应的环境变量为`DATALAYERS_LOG__ENABLE_STDOUT`

### enable_file

是否启用日志输出到文件，默认为`false`

对应的环境变量为`DATALAYERS_LOG__ENABLE_FILE`

### enable_err_file

是否启用专用的错误日志文件，默认为`false`

对应的环境变量为`DATALAYERS_LOG__ENABLE_ERR_FILE`

### more_verbose

日志信息中是否包含文件名和行号，默认为`true`

对应的环境变量为`DATALAYERS_LOG__MORE_VERBOSE`