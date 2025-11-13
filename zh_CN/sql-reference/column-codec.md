# 列级编码与压缩配置指南

## 概述

Datalayers 采用 **列式存储**，列存专门针对分析型工作负载进行了优化，能够显著提高分析效率、降低存储成本。在列式存储中，表的每一列会独立存储，这为压缩技术的应用提供了便利，从而提高了存储效率。Datalayers 支持为每个列单独配置编码和压缩算法，用户可以根据工作负载的需求，选择合适的编码方式与压缩算法来优化存储和查询性能。

## 为什么需要压缩

- **存储效率提升**：数据压缩技术能够显著减少物理存储空间需求，使得在同等硬件资源条件下可以存储更大规模的数据集。这种空间效率的提升直接转化为成本节约，特别适合大数据量的分析场景。
- **查询性能优化**：压缩后的数据体积更小，查询时需要的 I/O 操作与网络传输更少，从而加速查询响应时间。

## 配置编码方式与压缩算法

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

**注意事项**：

- 当前版本不支持直接修改列的编码压缩算法。
- Datalayers 不区分 `ENCODING`、`COMPRESSION` 关键词的大小写。
- Datalayers 不区分编码和压缩算法的大小写。例如 `RLE`、`rLE`、`rle` 都视为合法的输入。
- 编码和压缩算法可以用双引号、单引号包裹，也可以不带引号。

## 查看编码和压缩算法

我们目前提供两种方式查看列的编码和压缩算法：

1. 通过 `SHOW CREATE TABLE <table_name>` 语法可以查看某个表的建表语句，其中包括每个列的编码和压缩算法（如果显式设置了）。
2. 通过 `SELECT <codec> FROM information_schema.columns where table = "<table_name>"` 可以从 `information_schema.columns` 系统表中查询某个表的列元信息。其中 `codec` 为 `encoding` 或 `compression`。注意，这里的 `encoding`、`compression` 必须为小写。

## 编码和压缩算法

### 列编码

Datalayers 支持的编码算法如下：

- `PLAIN`：无特殊编码。例如 Boolean 类型编码为 1 个 byte、INT32 类型编码为 4 个 bytes。
- `RLE`
- `DELTA_BINARY_PACKED`
- `DELTA_LENGTH_BYTE_ARRAY`
- `DELTA_BYTE_ARRAY`
- `RLE_DICTIONARY`
- `BYTE_STREAM_SPLIT`

关于每个编码算法的定义，参考 [Apache Parquet Encoding](https://parquet.apache.org/docs/file-format/data-pages/encodings/)。

如果没有显式指定编码算法，不同数据类型的默认编码算法为：

- `Boolean`：`RLE`。
- `Int32`：`DLETA_BINARY_PACKED`。
- `Int64`：`DELTA_BINARY_PACKED`。
- `BYTE_ARRAY`：`DELTA_BYTE_ARRAY`。
- 其他类型：`PLAIN`。

每个编码算法兼容的类型是一定的。此处列出每个编码算法**不兼容**的类型：

- `RLE`：不兼容 `String`、`Binary` 类型。
- `DELTA_BINARY_PACKED`：不兼容 `Boolean`、`Real`、`Double`、`String`、`Binary`。
- `DELTA_LENGTH_BYTE_ARRAY`：不兼容 `Boolean`。
- `DELTA_BYTE_ARRAY`：不兼容 `Boolean`。
- `BYTE_STREAM_SPLIT`：不兼容 `Boolean`、`String`、`Binary`。

### 压缩算法

Datalayers 支持的压缩算法包括：

- `UNCOMPRESSED`：无压缩。
- `SNAPPY`
- `GZIP(gzip_level)`：其中 `gzip_level` 为 `GZIP` 的压缩级别，可选值的范围为 [0, 10]。
- `BROTLI(brotli_level)`：其中 `brotli_level` 为 `BROTLI` 的压缩级别，可选值的范围为 [0, 11]。
- `ZSTD(zstd_level)`：其中 `zstd_level` 为 `ZSTD` 的压缩级别，可选值的范围为 [1, 22]。
- `LZ4_RAW`

关于每个压缩算法的定义，参考 [Apache Parquet Compression](https://parquet.apache.org/docs/file-format/data-pages/compression/)。

## 影响压缩率的因素

数据压缩率不仅受所选编码与压缩算法的影响，更直接由数据本身的特征决定。主要影响因素包括以下几个方面：

### 数据有序性

数据的排列顺序对压缩效率至关重要。高序列性的数据（如按时间排序的时间戳、连续递增的ID）包含大量规律模式，使压缩算法能更高效地识别和编码重复信息，从而显著提升压缩比。

### 数据重复度

列中数据的重复值比例是影响压缩率的关键因素。重复值越高的列（如状态码、类别标签），越适合使用字典编码等压缩技术，能获得极佳的压缩效果。反之，随机或唯一性高的数据列，其压缩空间则相对有限。

### 数据的类型

数据的类型也会影响压缩效果。通常，数值类型的数据比字符串类型的数据更容易压缩。

### 列的长度

列中数据的长度也会影响压缩效果。较短的列通常比长列更容易压缩，因为压缩算法在较短数据块上能够更高效地找到重复模式。

### 空值

当列中包含大量空值（NULL）时，压缩效率会得到提升。压缩算法可以将空值统一识别为一种特殊的、极简的模式进行编码，从而有效减少存储空间占用。

## 如何选择压缩算法

选择合适的压缩算法需根据工作负载特性：

- 对于 **高性能实时分析** 场景，推荐使用 LZ4_RAW 或 SNAPPY。
- 对于 **存储效率优先** 的场景，推荐使用 ZSTD。
- 对于 **冷数据存储** 场景，建议使用 BROTLI。
