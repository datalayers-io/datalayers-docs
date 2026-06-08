---
title: "Datalayers Hybrid Cache Hint Guide"
description: "Control object store cache behavior per query using the hybrid_cache hint."
---
# Hybrid Cache Hint Guide

## Overview

Datalayers uses a Hybrid Cache (memory + disk cache) to cache Parquet file data and object metadata from object stores, accelerating queries. However, in some scenarios, bypassing the cache is desirable. The `hybrid_cache` hint temporarily disables the hybrid cache for an individual query.

## Syntax

```sql
-- Disable cache for the current query
SELECT /*+ SET_VAR(hybrid_cache=off) */ * FROM t;

-- Explicitly enable cache (default behavior, no need to set). Note: Hybrid Cache must be configured in the config file for it to actually take effect
SELECT /*+ SET_VAR(hybrid_cache=on) */ * FROM t;
```

Supported values (case insensitive):

| Value | Meaning |
|-------|---------|
| `on` or `1` | Enable cache (default) |
| `off` or `0` | Disable cache |

Can be combined with other hints:

```sql
SELECT /*+ SET_VAR(parallel_degree=4), SET_VAR(hybrid_cache=off) */ * FROM t;
```

## Use Cases

- **Benchmarking after cache warm-up**: compare cached vs. non-cached query performance
- **Debugging cache issues**: disable cache to verify data consistency when suspecting stale cache entries
- **Large scan queries**: when a single query would evict hot data from the cache, temporarily disable it

## Verification

Use `EXPLAIN` or `EXPLAIN ANALYZE` to inspect the physical plan output for the hybrid cache state:

```sql
-- If Hybrid Cache is configured, the PartitionScanExec operator shows hybrid_cache=on
EXPLAIN SELECT * FROM t;

-- If Hybrid Cache is not configured, or disabled by hint, the PartitionScanExec operator shows hybrid_cache=off
EXPLAIN SELECT /*+ SET_VAR(hybrid_cache=off) */ * FROM t;
```

> **Note**: If Hybrid Cache is not configured at startup (`object_store.file_cache` and `object_store.metadata_cache` are both empty), the output always shows `hybrid_cache=off` regardless of the hint value.
