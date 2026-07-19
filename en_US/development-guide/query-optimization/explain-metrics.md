---
title: "EXPLAIN ANALYZE Metrics Reference"
description: "A detailed reference for all metrics in Datalayers EXPLAIN ANALYZE output, including names, meanings, and typical values."
---
# EXPLAIN ANALYZE Metrics Reference

`EXPLAIN ANALYZE` executes a query while collecting and displaying runtime metrics for each operator in the query plan. This document covers all metrics from `PartitionedScanExec`, `PartitionScanExec`, and their child operators, including both DataFusion native metrics and Datalayers extended metrics.

---

## 1. Frontend Metrics (PartitionedScanExec)

Frontend-level metrics reflect the query distribution phase on the coordinator node.

| Metric | Description | Typical Values |
|---|---|---|
| `partition_count` | Number of data partitions involved in the scan | Depends on table partition count, typically 1~N. Larger values indicate broader coverage |
| `elapsed_plan_transform` | Total time for frontend logical analysis, logical optimization, physical planning, and physical optimization | Milliseconds. Simple queries <10ms, complex queries up to tens of ms |
| `elapsed_find_pipelines` | Time spent finding execution pipelines, i.e., matching query constraints to backend pipelines | Microseconds to milliseconds. Usually much smaller than `elapsed_plan_transform` |
| `elapsed_prune_partitions` | Time spent pruning irrelevant partitions using query predicates (time range, partition keys) | Microseconds to milliseconds. Grows with partition count |
| `elapsed_pull_partitions` | Total time spent pulling result streams from all partitions, reflecting distributed query network latency and transfer overhead | Milliseconds to hundreds of ms. Affected by data volume, partition count, and network latency |

---

## 2. Backend Metrics (PartitionScanExec)

Backend-level metrics reveal the internal query processing details within a single data partition.

| Metric | Description | Typical Values |
|---|---|---|
| `memtable_count` | Number of memtable sources in `pruned/total` format. `pruned` is the count skipped via precomputed aggregation, `total` is the count after time-range filtering | Typically `total` 0~2. `pruned` may equal `total` for count(*) queries |
| `sst_file_count` | Number of SST (Parquet) file sources in `pruned/total` format. `pruned` is the count skipped via precomputation | `total` depends on file count and query time range. `pruned` can be large for precomputable aggregation queries |
| `range_count` | Number of non-overlapping source groups. In overwrite mode, time-overlapping sources are merged into one range; in append mode, each source forms its own range | Usually ≤ total source count, 1~100+ |
| `elapsed_query_handling` | Total query handling time on this partition, including plan decode, partition scan, and source scanning | Milliseconds to seconds. Depends on data volume and query complexity |
| `elapsed_partition_scan` | Time spent calling `PartitionProvider::scan` to create the `PartitionScanExec` operator, including source listing and scan context construction | Milliseconds, typically < 50ms |
| `elapsed_plan_decode` | Time spent deserializing the Substrait logical plan into an executable plan | Microseconds to milliseconds, typically small |
| `elapsed_plan_transform` | Time spent on backend physical optimization | Microseconds to milliseconds, typically small |
| `elapsed_scan_memtables` | Actual time scanning memtable data (Mutable + Immutable) | Microseconds to milliseconds. Depends on row count in memtables |
| `elapsed_scan_sst_files` | Time scanning SST (Parquet) files, including file listing, metadata reading, and data reading | Milliseconds to seconds. Depends on file count and data volume. Usually the dominant component |

---

## 3. DataFusion Native Metrics (BaselineMetrics)

These are standard metrics provided by the DataFusion framework for all physical operators, visible on both `PartitionedScanExec` and `PartitionScanExec`.

| Metric | Description | Typical Values |
|---|---|---|
| `elapsed_compute` | Total wall-clock time spent in computation, including child stream polling time. The timer starts at `execute()` entry and stops when the stream is exhausted | Milliseconds to seconds. The primary reference for perceived operator latency |
| `output_rows` | Total number of rows output by this operator | Depends on predicate selectivity and data volume, 0 to millions+ |
| `mem_used` | Total memory consumed by output RecordBatches (in bytes) | Depends on output row count and column width, KB~GB |

---

## 4. File Scan Metrics (Parquet Level)

These metrics are natively provided by DataFusion's `ParquetExec` (`DataSourceExec`) and aggregated by Datalayers via `FileScanMetrics`. They appear in the `PartitionScanExec` output only when the query actually scans SST files.

Pruning metrics (`files_ranges_pruned`, `row_groups_pruned`, `row_groups_pruned_bloom_filter`, `limit_pruned_row_groups`, `page_index_pages_pruned`, `page_index_rows_pruned`) are shown in `pruned/total` format, where `pruned` is the number pruned and `total = pruned + matched` is the total number of containers examined at that pruning tier.

| Metric | Description | Typical Values |
|---|---|---|
| `files_ranges_pruned` | Number of file ranges pruned or matched by file-level statistics (partition values, file Min/Max, etc.). Pruning often happens at planning time, but may also occur at execution time when dynamic filters (e.g., runtime filters from a Join) provide additional pruning | `pruned/total`. For a single SST scan, `total` is always 1 with `pruned` 0 (scanned) or 1 (fully pruned). Multi-file aggregation may show `pruned > 0` |
| `row_groups_pruned` | Row groups pruned by row-group-level column Min/Max and Null Count statistics | `pruned/total`. `total` equals the total number of row groups in files. Higher `pruned` means better statistics-based filtering |
| `row_groups_pruned_bloom_filter` | Row groups pruned by Bloom Filter | `pruned/total`. Only effective when the Parquet file contains a Bloom Filter and the query predicate hits the Bloom Filter column |
| `limit_pruned_row_groups` | Row groups pruned by LIMIT pushdown (reading stopped early once required rows are satisfied) | `pruned/total`. Only appears in queries with LIMIT. Higher `pruned` means earlier termination |
| `page_index_pages_pruned` | Pages pruned by Page Index level statistics | `pruned/total`. Only effective when files contain Page Index. More `pruned` pages means more I/O saved |
| `page_index_rows_pruned` | Rows pruned by Page Index level statistics | `pruned/total`. Only effective when files contain Page Index. Higher `pruned` means better page-level filtering |
| `bytes_scanned` | Total bytes physically read from the object store | KB~GB, depends on query filters and file size |
| `pushdown_rows_pruned` | Rows filtered out by row-level predicate pushdown (Row Filter during Parquet decoding) | Depends on predicate selectivity and data distribution |
| `pushdown_rows_matched` | Rows that passed the row-level predicate pushdown | `pushdown_rows_matched + pushdown_rows_pruned` = total rows evaluated by predicate pushdown |
| `row_pushdown_eval_time` | Time spent evaluating row-level pushdown filters (nanoseconds, displayed as ms) | Milliseconds, affected by row count |
| `statistics_eval_time` | Time spent evaluating row-group-level statistics filters (nanoseconds, displayed as ms) | Milliseconds, typically much less than I/O time |
| `bloom_filter_eval_time` | Time spent evaluating Bloom Filter (nanoseconds, displayed as ms) | Milliseconds, only present when Bloom Filter is used |
| `page_index_eval_time` | Time spent evaluating Page Index filters (nanoseconds, displayed as ms) | Milliseconds, only present when Page Index is used |
| `metadata_load_time` | Time spent reading and parsing Parquet file footer metadata (nanoseconds, displayed as ms) | Milliseconds, typically < 10ms per file |
| `scan_efficiency` | Scan efficiency percentage = `bytes_scanned / total_bytes * 100%`. `total_bytes` is the uncompressed file size, `bytes_scanned` is the actual bytes read | 0%~100%. Higher means more "wasteful" scanning (more unnecessary data read). Lower means better column pruning and predicate pushdown |

---

## 5. Output Example

After running `EXPLAIN ANALYZE <query>`, you can find the operator's metrics in the output. Here is an example for `PartitionScanExec`:

```text
PartitionScanExec: filters=[ts >= 1000 AND ts < 2000], limit=None, output_ordering=[], output_partitions=2,
  file_scan=[files_ranges_pruned=0/3, row_groups_pruned=5/12, limit_pruned_row_groups=0/0,
  page_index_rows_pruned=0/0, page_index_pages_pruned=0/0,
  bytes_scanned=2048000, pushdown_rows_pruned=0, pushdown_rows_matched=100000,
  row_pushdown_eval_time=12ms, statistics_eval_time=3ms, page_index_eval_time=0ms, metadata_load_time=5ms,
  scan_efficiency=25.0%],
  hybrid_cache=off, precomputed=[count(*)=42]

  metrics=[output_rows=100000, elapsed_compute=523ms, mem_used=16384000, memtable_count=0/1,
  sst_file_count=1/3, range_count=3, elapsed_query_handling=510ms, elapsed_partition_scan=2ms,
  elapsed_plan_decode=1ms, elapsed_plan_transform=0ms, elapsed_scan_memtables=2ms,
  elapsed_scan_sst_files=480ms]
```

Explanation of `hybrid_cache` and `precomputed` fields:
- **`hybrid_cache`**: Hybrid cache state (`on` / `off`), indicating whether hot data caching is enabled for this partition.
- **`precomputed`**: Precomputed aggregate value. When the query type supports precomputation and source statistics are accurate, this value is returned directly without actual scanning. `none` means no precomputed hit; otherwise, it shows the precomputed aggregation result.
