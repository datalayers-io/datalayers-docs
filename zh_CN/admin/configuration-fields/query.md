# 查询配置

`query` 配置组用于管理 Datalayers 的查询行为。主要包括 `内存资源控制` 和 `慢查询日志记录`。

## 配置示例

```toml
# 查询相关配置
[query]

# 内存池大小，用于限制查询操作的总内存使用量
# 建议设置为系统可用内存的 60% ~ 80%
# 默认值：主机可用内存的 60%
# 示例：memory_pool_size = "8GB"
# memory_pool_size = "8GB"

# 慢查询日志配置
[query.slow_query]

# 是否启用慢查询日志记录功能
# 默认值：false
# enable = true

# 慢查询时间阈值，执行时间超过此阈值的查询将被记录
# 默认值："5s"（5秒）
# 支持的时间单位：ns（纳秒）、us（微秒）、ms（毫秒）、s（秒）、m（分钟）、h（小时）
# 示例：threshold = "1s"、threshold = "500ms"、threshold = "2m"
# threshold = "5s"

# 慢查询采样比例，用于控制记录的慢查询数量
# 默认值：1.0（记录所有慢查询）
# 有效范围：(0.0, 1.0]
# 示例：sample_ratio = 0.1（记录10%的慢查询）
# sample_ratio = 1.0
```
