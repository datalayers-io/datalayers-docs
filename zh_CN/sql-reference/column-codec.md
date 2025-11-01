# 列级编码与压缩配置指南

## 概述
Datalayers 支持为每个列单独配置编码和压缩算法，以优化存储效率和查询性能。通过合理的算法选择，可以在数据压缩率、读写速度之间达到最佳平衡。

## SQL 语法示例

### 建表时指定编码和压缩

在 CREATE TABLE 语句中，可以为每个列设置 `ENCODING` 和 `COMPRESSION` 参数：

``` sql
CREATE TABLE `sx1`
(
    ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    sid INT32 ENCODING RLE COMPRESSION SNAPPY,
    value REAL,
    flag INT8,
    timestamp key (ts),
)
PARTITION BY HASH(sid) PARTITIONS 8
ENGINE=TimeSeries
```

**示例说明**：上述语句为 `sid` 列配置了 `RLE` 编码算法和 `SNAPPY` 压缩算法。

**注意事项**
- 当前版本不支持直接修改列的编码压缩算法。
- Datalayers 不区分 `ENCODING`、`COMPRESSION` 关键词的大小写。
- Datalayers 不区分编码和压缩算法的大小写。例如 `RLE`、`rLE`、`rle` 都视为合法的输入。
- 编码和压缩算法可以用双引号、单引号包裹，也可以不带引号。

### 查看编码和压缩

我们目前提供两种方式查看列的编码和压缩算法：

1. 通过 `SHOW CREATE TABLE <table_name>` 语法可以查看某个表的建表语句，其中包括每个列的编码和压缩算法（如果显式设置了）。
2. 通过 `SELECT <codec> FROM information_schema.columns where table = "<table_name>"` 可以从 `information_schema.columns` 系统表中查询某个表的列元信息。其中 `codec` 为 `encoding` 或 `compression`。注意，这里的 `encoding`、`compression` 必须为小写。

## 支持的编码和压缩算法

### 编码

Datalayers 支持的编码算法如下：

- `PLAIN`：无特殊编码。例如 Boolean 类型编码为 1 个 byte、INT32 类型编码为 4 个 bytes。
- `RLE`
- `DELTA_BINARY_PACKED`
- `DELTA_LENGTH_BYTE_ARRAY`
- `DELTA_BYTE_ARRAY`
- `RLE_DICTIONARY`
- `BYTE_STREAM_SPLIT`

关于每个编码算法的定义，参考 [Apache Parquet Encoding](https://parquet.apache.org/docs/file-format/data-pages/encodings/)。

#### 默认的编码

如果没有显式指定编码算法，不同数据类型的默认编码算法为：

- `Boolean`：`RLE`。
- `Int32`：`DLETA_BINARY_PACKED`。
- `Int64`：`DELTA_BINARY_PACKED`。
- `BYTE_ARRAY`：`DELTA_BYTE_ARRAY`。
- 其他类型：`PLAIN`。

#### 类型兼容性

每个编码算法兼容的类型是一定的。此处列出每个编码算法**不兼容**的类型：

- `RLE`：不兼容 `String`、`Binary` 类型。
- `DELTA_BINARY_PACKED`：不兼容 `Boolean`、`Real`、`Double`、`String`、`Binary`。
- `DELTA_LENGTH_BYTE_ARRAY`：不兼容 `Boolean`。
- `DELTA_BYTE_ARRAY`：不兼容 `Boolean`。
- `BYTE_STREAM_SPLIT`：不兼容 `Boolean`、`String`、`Binary`。

### 压缩

Datalayers 支持的压缩算法包括：

- `UNCOMPRESSED`：无压缩。
- `SNAPPY`
- `GZIP(gzip_level)`：其中 `gzip_level` 为 `GZIP` 的压缩级别，可选值的范围为 [0, 10]。
- `BROTLI(brotli_level)`：其中 `brotli_level` 为 `BROTLI` 的压缩级别，可选值的范围为 [0, 11]。
- `LZ4`
- `ZSTD(zstd_level)`：其中 `zstd_level` 为 `ZSTD` 的压缩级别，可选值的范围为 [1, 22]。
- `LZ4_RAW`

关于每个压缩算法的定义，参考 [Apache Parquet Compression](https://parquet.apache.org/docs/file-format/data-pages/compression/)。

::: tip
- 压缩算法作用于 byte 级别，因此与数据类型无关，Datalayers 的所有数据类型都支持配置以上任意一种压缩算法。
- 不同的压缩算法具有不同的压缩指标，包括压缩率、压缩与解压缩耗时、压缩与解压缩资源占用等。需要根据具体的场景权衡各项指标，选择合适的压缩算法。
- 通常来说，压缩级别越高，压缩后数据文件越小，即压缩率越高。但是请注意，高压缩级别会增加压缩、解压缩时的资源开销与耗时。
:::
