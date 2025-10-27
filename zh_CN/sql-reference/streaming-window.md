# 流式窗口函数

流计算指实时地对流式数据进行分析、transform（例如 ETL）。在分析时，我们通常需要将“没有边界的”流式数据划分为一个个“有边界的”窗口（Window），然后在每个窗口中进行聚合分析。很多书籍将针对“有边界的”历史数据的窗口计算，也称为（广义的）流式计算。

不管是狭义、还是广义的流计算，窗口都是流计算中的核心概念之一。我们给出窗口的一种简洁的定义：窗口是数据的一种划分方式，它决定了某行数据属于哪个窗口，以支持基于窗口的聚合计算。

Datalayers 目前支持 5 种窗口：

- **固定时间窗口**：又称翻滚窗口（tumbling window），表示在时间轴上以固定步长（固定时间间隔）移动窗口，且该步长总是等于窗口大小，因此窗口总是连续的，相互之间没有缝隙，且互不重叠。
- **滑动时间窗口**：sliding window，又称 rolling window。它与固定窗口相似，只是它允许窗口的移动步长小于、等于、大于窗口大小。因此窗口之间可能有重叠，且可能有缝隙。
- **会话窗口**：根据时间的邻近度来划分窗口。连续的、时间相近的行被划分一个窗口。当遇到一个时间间隙较大的行时，退出当前窗口，进入下一个新窗口。
- **计数窗口**：按固定的行数来划分窗口。例如给定窗口大小 3，则连续的 3 行总是被划分为同一个窗口，且窗口之间一定连续、互不重叠。
- **状态窗口**：根据状态划分窗口。连续的、相同状态的行被划为一个窗口。当状态改变时，退出当前窗口，进入下一个新窗口。

## 语法

```sql
SELECT <select_expr>
FROM <table_name>
GROUP BY <window_expr>

window_expr:
  - tumble_window(<timestamp_col>, <window_width>)
  - slide_window(<timestamp_col>, <window_width>, <slide_step>)
  - session_window(<timestamp_col>, <max_gap>)
  - count_window([<timestamp_col>, ] <count>)
  - state_window([<timestamp_col>, ] <expr>)
```

在使用流式窗口函数时，我们有如下限制：

- 一个 SELECT 语句中，只能出现最多一个窗口函数。
- 窗口函数只能作为 GROUP BY 的列。
- GROUP BY 语句中可以同时包含窗口函数和其他合法的表达式。

## 示例

固定时间窗口：

```sql
-- 按 1 分钟为间隔划分固定时间窗口
SELECT sum(value) FROM t GROUP BY tumble_window(ts, interval 1 minute)
```

滑动时间窗口：

```sql
-- 将窗口宽度设为 1 小时，以 15 分钟为间隔滑动窗口
SELECT sum(value) FROM t GROUP BY slide_window(ts, interval 1 hour, interval 15 minute)
```

会话窗口：

```sql
-- 将会话不间断的最大间隔设为 10 minute，超过 10 minute 的连续两个事件被划分为不同的会话，反之则划分为同一个会话
SELECT sum(value) FROM t GROUP BY session_window(ts, interval 10 minute)
```

计数窗口：

```sql
-- 将连续的 4 个事件划分到同一个计数窗口
SELECT sum(value) FROM t GROUP BY count_window(4)

-- 首先对数据按 ts 列进行升序排序，然后将连续的 4 个事件划分到同一个计数窗口
SELECT sum(value) FROM t GROUP BY count_window(ts, 4)
```

状态窗口：

```sql
-- flag 值相同的、连续的事件，被划分到同一个状态窗口
SELECT sum(value) FROM t GROUP BY state_window(flag)

-- 满足 `flag > 0` 条件的、连续的事件，被划分到同一个状态窗口
SELECT sum(value) FROM t GROUP BY state_window(flag > 0)

-- CASE 结果相同的、连续的事件，被划分到同一个状态窗口
SELECT sum(value) FROM t GROUP BY state_window(case when flag > 0 then 1 else 0 end)

-- 首先对数据按 ts 列进行升序排序，然后将 flag 值相同的、连续的事件划分到同一个状态窗口
SELECT sum(value) FROM t GROUP BY state_window(ts, flag)
```

## 输出窗口的元信息

有些时候，我们不仅需要获取每个窗口的聚合计算结果，还需要输出每个窗口的元信息：窗口起始时间戳（window start）、窗口结束时间戳（window end）、窗口持续时间（window duration）。为此，Datalayers 提供了一些聚合函数来打印这些元信息：

- `window_start`：输出窗口内第一个事件的时间戳。
- `window_end`：输出窗口内最后一个事件的时间戳。
- `window_duration`：输出窗口内从第一个事件到最后一个事件的时间跨度。

在使用这些聚合函数时，我们有如下限制：

- 当且仅当窗口是根据时间戳列进行划分时，才能使用这些函数打印窗口元信息。
- 这些聚合函数中指定的时间戳列必须与用于窗口划分的时间戳列一致。

示例：

```sql
SELECT window_start(ts), window_end(ts), window_duration(ts), sum(value)
FROM t
GROUP BY tumble_window(ts, interval 10 minute)
```
