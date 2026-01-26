# PromQL 兼容性

## 概述

Datalayers 提供高度兼容的 PromQL 查询能力，支持绝大多数常用的选择器、运算符和函数，确保从 Prometheus 平滑迁移。

## 选择器

Datalayers 支持 Instant 选择器和 Range 选择器。

**标签匹配支持**：

|匹配运算符      | 普通标签    |  特殊标签 `__name__`  |  特殊标签 `__database__`  |
| :---          | :---       | :---                  | :---                     |
| =             | ✅ 支持     |✅ 支持                |✅ 支持                   |
| !=            | ✅ 支持     |✖ 不支持               |✖ 不支持                   |
| =~            | ✅ 支持     |✖ 不支持               |✖ 不支持                   |
| !~            | ✅ 支持     |✖ 不支持               |✖ 不支持                   |

**注**：Datalayers 支持 `offset` 修饰符，但不支持 `@` 修饰符。

## 运算符

以下内容基于 Prometheus 官方 PromQL 运算符说明整理，示例仅用于展示语法。

### 一元与二元运算符

| 类别 | 运算符 | 说明 | 示例 |
| :--- | :--- | :--- | :--- |
| 一元 | `-` | 一元取反，可作用于标量或 Instant 向量 | `-up` |
| 算术二元 | `+`, `-`, `*`, `/`, `%`, `^` | 标量/向量的加减乘除、取模、幂运算 | `http_requests_total + 1` |
| 三角二元 | `atan2` | 基于两个序列的反正切，支持向量匹配 | `atan2(node_load1, node_load5)` |
| 比较二元 | `==`, `!=`, `>`, `<`, `>=`, `<=` | 默认作为过滤；加 `bool` 返回 0/1 | `up == 1`, `up > bool 0` |
| 逻辑/集合 | `and`, `or`, `unless` | 向量集合运算：交集/并集/差集 | `up{job="api"} unless up{job="api",instance="node-1"}` |

以上运算符语义参考 Prometheus 文档。

**向量匹配与分组修饰**：向量与向量运算可使用 `on()` / `ignoring()` 指定匹配标签，并通过 `group_left` / `group_right` 进行多对一/一对多匹配。

### 聚合运算符

| 运算符 | 说明 | 示例 |
| :--- | :--- | :--- |
| `sum` | 对向量求和 | `sum(rate(http_requests_total[5m]))` |
| `avg` | 对向量求平均值 | `avg(node_cpu_seconds_total)` |
| `min` | 取最小值 | `min(node_memory_MemFree_bytes)` |
| `max` | 取最大值 | `max(node_memory_MemFree_bytes)` |
| `stddev` | 标准差 | `stddev(node_load1)` |
| `stdvar` | 方差 | `stdvar(node_load1)` |
| `topk` | 取前 k 个最大值 | `topk(5, rate(http_requests_total[5m]))` |
| `bottomk` | 取前 k 个最小值 | `bottomk(5, rate(http_requests_total[5m]))` |
| `count` | 统计样本数 | `count(up)` |
| `count_values` | 按值计数并写入新标签 | `count_values("value", up)` |
| `quantile` | 计算分位数 | `quantile(0.95, node_load5)` |

以上聚合运算符语义参考 Prometheus 文档。

**聚合分组**：聚合运算可结合 `by()` / `without()` 指定分组标签（旧文档中的 `grouping` 指此类能力）。

**不支持**：`limitk`, `limit_ratio`。

## 函数

以下内容基于 Prometheus 官方函数说明整理，示例仅用于展示语法。

### Instant 函数

| 函数 | 说明 | 示例 |
| :--- | :--- | :--- |
| `abs(v)` | 绝对值 | `abs(up - 1)` |
| `ceil(v)` | 向上取整 | `ceil(3.14)` |
| `exp(v)` | e 的幂 | `exp(1)` |
| `ln(v)` | 自然对数 | `ln(10)` |
| `log2(v)` | 以 2 为底对数 | `log2(8)` |
| `log10(v)` | 以 10 为底对数 | `log10(1000)` |
| `sqrt(v)` | 平方根 | `sqrt(9)` |
| `acos(v)` | 反余弦 | `acos(1)` |
| `asin(v)` | 反正弦 | `asin(0.5)` |
| `atan(v)` | 反正切 | `atan(1)` |
| `sin(v)` | 正弦 | `sin(pi() / 2)` |
| `cos(v)` | 余弦 | `cos(0)` |
| `tan(v)` | 正切 | `tan(1)` |
| `acosh(v)` | 反双曲余弦 | `acosh(2)` |
| `asinh(v)` | 反双曲正弦 | `asinh(1)` |
| `atanh(v)` | 反双曲正切 | `atanh(0.5)` |
| `sinh(v)` | 双曲正弦 | `sinh(1)` |
| `cosh(v)` | 双曲余弦 | `cosh(1)` |
| `tanh(v)` | 双曲正切 | `tanh(1)` |
| `sgn(v)` | 符号函数（-1/0/1） | `sgn(up - 1)` |
| `pi()` | 圆周率常量 | `pi()` |
| `deg(v)` | 弧度转角度 | `deg(3.14159)` |
| `rad(v)` | 角度转弧度 | `rad(180)` |
| `floor(v)` | 向下取整 | `floor(3.99)` |
| `clamp(v, min, max)` | 将值限制到区间 | `clamp(up, 0, 1)` |
| `clamp_max(v, max)` | 限制最大值 | `clamp_max(up, 1)` |
| `clamp_min(v, min)` | 限制最小值 | `clamp_min(up, 0)` |
| `scalar(v)` | 将单元素向量转为标量 | `scalar(up{instance="node-1"})` |
| `timestamp(v)` | 返回样本时间戳 | `timestamp(up)` |
| `sort(v)` | 升序排序 | `sort(up)` |
| `sort_desc(v)` | 降序排序 | `sort_desc(up)` |
| `histogram_quantile(q, v)` | 基于直方图估算分位数 | `histogram_quantile(0.95, sum by (le) (rate(http_request_duration_seconds_bucket[5m])))` |
| `predict_linear(v, t)` | 线性预测未来 t 秒后的值 | `predict_linear(node_filesystem_free_bytes[1h], 3600)` |
| `absent(v)` | 输入为空时返回 1 | `absent(up{job="api"})` |

以上 Instant 函数语义参考 Prometheus 文档。

**不支持**：其它 `histogram_<aggr>` 函数。

### Range 函数

| 函数 | 说明 | 示例 |
| :--- | :--- | :--- |
| `idelta(v[range])` | 相邻两点差值 | `idelta(node_memory_MemFree_bytes[5m])` |
| `count_over_time(v[range])` | 统计样本数 | `count_over_time(http_requests_total[5m])` |
| `stddev_over_time(v[range])` | 标准差 | `stddev_over_time(node_load1[10m])` |
| `stdvar_over_time(v[range])` | 方差 | `stdvar_over_time(node_load1[10m])` |
| `changes(v[range])` | 值变化次数 | `changes(up[10m])` |
| `delta(v[range])` | 首尾差值（适合 gauge） | `delta(node_memory_MemFree_bytes[10m])` |
| `rate(v[range])` | 平均每秒增长率（适合 counter） | `rate(http_requests_total[5m])` |
| `deriv(v[range])` | 基于线性回归的导数 | `deriv(node_load1[10m])` |
| `increase(v[range])` | 总增量（rate × 时间窗） | `increase(http_requests_total[1h])` |
| `irate(v[range])` | 近似瞬时每秒增长率 | `irate(http_requests_total[5m])` |
| `resets(v[range])` | 计数器重置次数 | `resets(http_requests_total[1h])` |

以上 Range 函数语义参考 Prometheus 文档。

### 其他函数

| 函数 | 说明 | 示例 |
| :--- | :--- | :--- |
| `label_join(v, dst, sep, src...)` | 将多个标签拼成新标签 | `label_join(up, "instance_job", "/", "instance", "job")` |
| `label_replace(v, dst, repl, src, regex)` | 按正则替换标签 | `label_replace(up, "instance", "$1", "instance", "(.*):\\d+")` |
| `sort_by_label(v, label...)` | 按标签值升序排序 | `sort_by_label(up, "instance")` |
| `sort_by_label_desc(v, label...)` | 按标签值降序排序 | `sort_by_label_desc(up, "instance")` |

以上标签与排序函数语义参考 Prometheus 文档。

## PromQL 查询示例

| 场景 | 查询 |
| :--- | :--- |
| 按作业统计 QPS | `sum by (job) (rate(http_requests_total[1m]))` |
| 按方法与状态码聚合 | `sum by (method, status) (rate(http_requests_total[5m]))` |
| 5xx 错误率 | `sum(rate(http_requests_total{status="500"}[5m])) / sum(rate(http_requests_total[5m]))` |
| GET 请求量（窗口内样本数） | `count_over_time(http_requests_total{method="GET"}[2m])` |
| Top N 实例吞吐 | `topk(3, sum by (instance) (rate(http_requests_total[2m])))` |
| P95 请求耗时（直方图） | `histogram_quantile(0.95, sum by (le) (rate(request_duration_seconds_bucket[5m])))` |
| 平滑后的平均 QPS | `avg_over_time(rate(http_requests_total{job="web"}[30s])[5m:30s])` |
| 缺失目标探测 | `absent(http_requests_total{job="missing"})` |
