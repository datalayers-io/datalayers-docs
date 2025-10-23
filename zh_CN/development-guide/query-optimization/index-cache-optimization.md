# 索引缓存调优

查询的过程中，会读取存储引擎中的索引数据用于查询优化，频繁的 IO 会增加查询过程中额外的开销，因此将索引数据缓存到内存中能极大的提升查询效率。如将所有索引数据都进行缓存的话，则需配置为存储文件大小的 2% 左右。当然，对于正常情况下，我们只需将热数据（高频查询的数据，如：近 7 天的数据）的索引数据进行缓存即可，因此可根据热数据的大小预估来配置缓存大小，当内存不够时，会根据 LFU 策略进行淘汰。

## 配置

通过修改 Datalayers 配置文件中的以下项。配置文件默认路径为：`/etc/datalayers/datalayers.toml`。

```toml
[ts_engine]

# Cache size for SST file metadata. Setting it to 0 to disable the cache.
# Default: 128M
meta_cache_size = "256M"

# Whether or not to preload parquet metadata on startup.
# This config only takes effect if the `ts_engine.meta_cache_size` is greater than 0.
# Default: true.
preload_parquet_metadata = true
```

**注**：
- 当内存过小，缓存被高频换入、换出，可能会导致查询变慢。
- 配置文件修改后，需重启 Datalayers 生效。
