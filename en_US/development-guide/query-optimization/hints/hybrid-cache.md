---
title: "Datalayers Hybrid Cache Hint Guide"
description: "Control object store cache behavior per query using the hybrid_cache hint."
---
# Hybrid Cache Hint Guide

## Overview

Datalayers uses Hybrid Cache (a foyer-based memory + disk cache) to cache Parquet file metadata and content from object stores, accelerating queries. In some scenarios, bypassing the cache for direct storage reads is preferable. The `hybrid_cache` hint enables per-query control over cache behavior.

## Syntax

```sql
-- Disable cache for the current query
SELECT /*+ SET_VAR(hybrid_cache=off) */ * FROM t;

-- Explicitly enable cache (default behavior)
SELECT /*+ SET_VAR(hybrid_cache=on) */ * FROM t;
```

Supported values:

| Value | Meaning |
|-------|---------|
| `on`, `1`, `true` | Enable cache (default) |
| `off`, `0`, `false` | Disable cache |

Case insensitive. Can be combined with other hints:

```sql
SELECT /*+ SET_VAR(parallel_degree=4), SET_VAR(hybrid_cache=off) */ * FROM t;
```

## Use Cases

- **Benchmarking after cache warm-up**: compare cached vs. non-cached query performance
- **Debugging cache issues**: disable cache to verify data consistency when suspecting stale cache entries
- **Large scan queries**: when a single query would evict hot data from the cache, temporarily disable it

## Verification

Use `EXPLAIN ANALYZE VERBOSE` to inspect the physical plan output:

```sql
-- Default: shows hybrid_cache=on
EXPLAIN ANALYZE VERBOSE SELECT * FROM t;

-- Cache disabled: shows hybrid_cache=off
EXPLAIN ANALYZE VERBOSE SELECT /*+ SET_VAR(hybrid_cache=off) */ * FROM t;
```

Look for `hybrid_cache=on` or `hybrid_cache=off` in the `PartitionScanExec` node of the physical plan.

> **Note**: If the instance has no Hybrid Cache configured (`object_store.file_cache` and `metadata_cache` are both empty), the output always shows `hybrid_cache=off` regardless of the hint value.

## See Also

- For SQL Hints overview, see [SQL Hints Guide](./overview.md)
- For query parallelism control, see [Parallel Degree Guide](./parallel-degree.md)
