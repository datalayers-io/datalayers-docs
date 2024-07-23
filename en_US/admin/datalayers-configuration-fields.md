# Config fields

## [server]

### standalone

`DATALAYERS_SERVER__STANDALONE`

### addr

`DATALAYERS_SERVER__ADDR`

### http

`DATALAYERS_SERVER__HTTP`

### session_timeout

`DATALAYERS_SERVER__SESSION_TIMEOUT`

### timezone

`DATALAYERS_SERVER__TIMEZONE`

### pid

`DATALAYERS_SERVER__PID`

### enable_influxdb_schemaless

`DATALAYERS_SERVER__ENABLE_INFLUXDB_SCHEMALESS`

## [server.auth]

### username

`DATALAYERS_SERVER__AUTH__USERNAME`

### password

`DATALAYERS_SERVER__AUTH__PASSWORD`

### token

`DATALAYERS_SERVER__AUTH__TOKEN`

### jwt_secret

`DATALAYERS_SERVER__AUTH__JWT_SECRET`


## [ts_engine]

### worker_channel_size

`DATALAYERS_TS_ENGINE__WORKER_CHANNEL_SIZE`

### flush_on_exit

`DATALAYERS_TS_ENGINE__FLUSH_ON_EXIT`

## [ts_engine.wal]

### type

`DATALAYERS_TS_ENGINE__WAL__TYPE`

### disable

`DATALAYERS_TS_ENGINE__WAL__DISABLE`

### skip_replay

`DATALAYERS_TS_ENGINE__WAL__SKIP_REPLAY`

### path

`DATALAYERS_TS_ENGINE__WAL__PATH`

### flush_interval

`DATALAYERS_TS_ENGINE__WAL__FLUSH_INTERVAL`

### max_file_size

`DATALAYERS_TS_ENGINE__WAL__MAX_FILE_SIZE`

## [storage]

## [storage.local]

### path

`DATALAYERS_STORAGE__LOCAL__LOCAL`

## [storage.fdb]

### cluster_file

`DATALAYERS_STORAGE__FDB__CLUSTER_FILE`

### namespace

`DATALAYERS_STORAGE__FDB__NAMESPACE`

## [storage.object_store.s3]

### buket

`DATALAYERS_STORAGE__OBJECT__STORE__S3__BUKET`

### root

`DATALAYERS_STORAGE__OBJECT__STORE__S3__ROOT`

### access_key

`DATALAYERS_STORAGE__OBJECT__STORE__S3__ACCESS_KEY`

### secret_key

`DATALAYERS_STORAGE__OBJECT__STORE__S3__SECRET_KEY`

### endpoint

`DATALAYERS_STORAGE__OBJECT__STORE__S3__ENDPOINT`

### region

`DATALAYERS_STORAGE__OBJECT__STORE__S3__REGION`

## [node]

### name

`DATALAYERS_NODE__NAME`

### connect_timeout

`DATALAYERS_NODE__CONNECT_TIMEOUT`

### timeout

`DATALAYERS_NODE__TIMEOUT`

### retry_count

`DATALAYERS_NODE__RETRY_COUNT`

### data_path

`DATALAYERS_NODE__DATA_PATH`

### rpc_max_conn

`DATALAYERS_NODE__RPC_MAX_CONN`

### rpc_min_conn

`DATALAYERS_NODE__RPC_MIN_CONN`

## [scheduler]

## [scheduler.flush]

### concurrence_limit

`DATALAYERS_SCHEDULER__FLUSH__CONCURRENCE_LIMIT`

### queue_limit

`DATALAYERS_SCHEDULER__FLUSH__QUEUE_LIMIT`

## [scheduler.gc]

### concurrence_limit

`DATALAYERS_SCHEDULER__GC__CONCURRENCE_LIMIT`

### queue_limit

`DATALAYERS_SCHEDULER__GC__QUEUE_LIMIT`

## [scheduler.cluster_compact_inactive]

### concurrence_limit

`DATALAYERS_SCHEDULER__CLUSTER_COMPACT_INACTIVE__CONCURRENCE_LIMIT`

## [license]

### key

`DATALAYERS_LICENSE__KEY`

## [log]

### dir

`DATALAYERS_LOG__DIR`

### level

`DATALAYERS_LOG__LEVEL`

### rotation

`DATALAYERS_LOG__ROTATION`

### enable_stdout

`DATALAYERS_LOG__ENABLE_STDOUT`

### enable_file

`DATALAYERS_LOG__ENABLE_FILE`

### enable_err_file

`DATALAYERS_LOG__ENABLE_ERR_FILE`

### verbose

`DATALAYERS_LOG__VERBOSE`
