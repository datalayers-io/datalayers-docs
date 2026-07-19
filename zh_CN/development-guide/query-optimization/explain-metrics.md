---
title: "查询性能指标说明"
description: "说明 Datalayers EXPLAIN ANALYZE 输出中各类 metrics 的名称、含义与典型值，解释查询性能指标。"
---

# 查询性能指标

Datalayers 提供 `EXPLAIN ANALYZE` 功能，用于在执行查询的同时收集并展示查询计划中每个算子的运行时指标。在这些算子中，`PartitionedScanExec` 和 `PartitionScanExec` 是最重要的两个算子，它们分别对应查询计划的前端和后端阶段。本文档将详细说明这两个算子的指标，同时说明基础指标和文件扫描指标的含义与典型值。

---

## 1. 前端性能指标（PartitionedScanExec）

PartitionedScanExec 算子的指标反映查询前端节点（负责汇总每个 partition 的查询结果）的性能指标。

| Metric 名称 | 含义 | 典型值 |
|---|---|---|
| `partition_count` | 参与本次查询扫描的数据分区数量 | 取决于表的分区数，通常 1~N，值越大说明查询的分区数越多 |
| `elapsed_plan_transform` | 前端进行逻辑计划分析、逻辑优化、物理计划生成、物理优化的总耗时 | 毫秒级，简单查询 <10ms，复杂多级查询可达几十ms |
| `elapsed_find_pipelines` | 拆分出可分布式执行的计划的耗时 | 微秒~毫秒级 |
| `elapsed_prune_partitions` | 根据查询谓词（时间范围、分区键）裁剪不相关分区的耗时 | 微秒~毫秒级，分区越多耗时越高 |
| `elapsed_pull_partitions` | 从各分区拉取结果流的总耗时，反映分布式查询的传输开销，对于集群版则包含额外的网络传输延迟和数据编解码开销 | 毫秒~百毫秒级，受数据量、分区数、网络延迟影响 |

---

## 2. 后端性能指标（PartitionScanExec）

PartitionScanExec 算子的指标反映查询后端节点（负责扫描单个数据分区的源数据）的性能指标。后端指标主要关注单个分区内部的查询处理细节，包括内存表扫描、SST 文件扫描、裁剪效率等。

| Metric 名称 | 含义 | 典型值 |
|---|---|---|
| `memtable_count` | 扫描的 Memtable 的数量，格式为 `pruned/total`，`pruned` 为被裁剪了的数量，`total` 为经过简单时间范围过滤后的数量 | 例如 2/10 表示 10 个 Memtable 位于查询时间范围内，其中 2 个被裁剪掉 |
| `sst_file_count` | 扫描的 SST 文件的数量，格式为 `pruned/total`，`pruned` 为被裁剪了的数量，`total` 为经过简单时间范围过滤后的数量 | 例如 2/10 表示 10 个 SST 文件位于查询时间范围内，其中 2 个被裁剪掉 |
| `range_count` | 扫描的数据分组的数量。在 overwrite 写入模式下，时间重叠的数据源（Memtable 或 SST）会被合并为一个 range；在追加写入模式下每个源独立为一个 range | 通常等于或小于源总数 |
| `elapsed_query_handling` | 该分区整体查询处理的总耗时，包括计划解码、分区扫描、源扫描的全部时间 | 毫秒~秒级，取决于数据量和查询复杂度 |
| `elapsed_partition_scan` | 创建 `PartitionScanExec` 算子的耗时，包含列出数据源、构建扫描上下文等 | 毫秒级，通常在几十ms以内 |
| `elapsed_plan_decode` | 对前端通过网络发送过来的逻辑计划执行反序列化的耗时 | 微秒~毫秒级，通常较小。只对于集群版有意义 |
| `elapsed_plan_transform` | 后端执行物理优化的耗时 | 微秒~毫秒级，通常较小 |
| `elapsed_scan_memtables` | 扫描 Memtable 中数据的实际耗时 | 微秒~毫秒级，受 Memtable 内数据行数影响 |
| `elapsed_scan_sst_files` | 扫描 SST 文件的耗时，包括文件列表、元数据读取、数据读取等 | 毫秒~秒级，受文件数量和数据量影响，通常是查询中最耗时的部分 |

---

## 3. 基础指标

我们给几乎所有算子提供了一系列基础指标，用于衡量算子执行的计算耗时、输出行数和内存使用情况。

| Metric 名称 | 含义 | 典型值 |
|---|---|---|
| `elapsed_compute` | 算子执行计算的总时间，是该算子所有协程计算时间的总和 | 毫秒~秒级，通常是该算子体感耗时的主要参考 |
| `output_rows` | 该算子输出的总行数 | 取决于查询谓词选择性和数据量，0~百万+ |
| `mem_used` | 该算子输出 RecordBatch 所占用的内存总量（字节） | 取决于输出行数和列宽，KB~GB |

---

## 4. 文件扫描指标

这些指标仅在查询实际涉及 SST 文件扫描时出现。

| Metric 名称 | 含义 | 典型值 |
|---|---|---|
| `files_ranges_pruned` | 通过文件级统计信息（分区值、文件 Min/Max 等）裁剪掉的文件/文件段数量。文件裁剪通常在规划阶段完成，但当存在动态过滤器（如 Join 产生的运行时过滤条件）时也可能在执行阶段裁剪 | `pruned/total`，单次 SST 扫描 `total` 恒为 1，`pruned` 为 0（扫描）或 1（完全裁剪），多文件聚合后 `pruned` 可 > 0 |
| `row_groups_pruned` | 通过 Row Group 级别的列 Min/Max 和 Null Count 统计信息裁剪掉的 Row Group 数量 | `pruned/total`，`total` 等于文件中 Row Group 总数，`pruned` 越多说明统计信息过滤效果越好 |
| `limit_pruned_row_groups` | 由于 LIMIT 下推导致的 Row Group 裁剪（满足所需行数后提前停止读取后续 Row Group） | `pruned/total`，仅在包含 LIMIT 的查询中出现，`pruned` 越大说明提前终止得越早 |
| `page_index_pages_pruned` | 通过 Page Index 级别的统计信息裁剪掉的 Page 数量 | `pruned/total`，仅在文件包含 Page Index 时有效，`pruned` 越多 I/O 节省越多 |
| `page_index_rows_pruned` | 通过 Page Index 级别的统计信息裁剪掉的行数 | `pruned/total`，仅在文件包含 Page Index 时有效，`pruned` 越大说明页级过滤效果越好 |
| `bytes_scanned` | 实际从对象存储物理读取的字节数 | 取决于查询过滤条件和文件大小，KB~GB |
| `pushdown_rows_pruned` | 被行级谓词下推（Parquet 解码期间的 Row Filter）过滤掉的行数 | 取决于谓词选择性和数据分布 |
| `pushdown_rows_matched` | 通过行级谓词下推的行数 | `pushdown_rows_matched + pushdown_rows_pruned` = 谓词下推评估的总行数 |
| `row_pushdown_eval_time` | 行级谓词下推过滤的评估耗时（纳秒，显示为 ms） | 毫秒级，受影响行数影响 |
| `statistics_eval_time` | Row Group 级别统计信息过滤的评估耗时（纳秒，显示为 ms） | 毫秒级，通常远小于 I/O 时间 |
| `page_index_eval_time` | Page Index 级别过滤的评估耗时（纳秒，显示为 ms） | 毫秒级，仅在使用了 Page Index 时有值 |
| `metadata_load_time` | 读取和解析 Parquet 文件 Footer 元数据的耗时（纳秒，显示为 ms） | 毫秒级，单个文件通常 <10ms |
| `scan_efficiency` | 扫描效率百分比 = `bytes_scanned / total_bytes * 100%`。`total_bytes` 为文件未压缩总大小，`bytes_scanned` 为实际读取的字节数 | 0%~100%，越高说明扫描越"浪费"（读取了更多不需要的数据），越低说明列裁剪和谓词下推效果越好 |

### 说明

文件扫描指标包含一系列裁剪类指标：

- `files_ranges_pruned`
- `row_groups_pruned`
- `limit_pruned_row_groups`
- `page_index_pages_pruned`
- `page_index_rows_pruned`

它们的格式均为 `pruned/total`，其中 `pruned` 为被裁剪掉的数量，`total = pruned + matched` 为总数。
