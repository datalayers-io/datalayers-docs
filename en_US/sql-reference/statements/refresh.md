# REFRESH Statement

## Overview

The `REFRESH` statement triggers index refresh/build tasks. For historical data written before index creation, use this statement to backfill the index.

## Syntax

### REFRESH INDEX

```SQL
REFRESH INDEX index_name ON [database.]table_name [LIMIT n] [SYNC]
```

## Parameters

- `index_name`: index name.
- `[database.]table_name`: table that owns the index, optionally prefixed with database.
- `LIMIT n`: limits the number of partitions/tasks refreshed in this run.
- `SYNC`: runs synchronously and returns after refresh completes.

## Examples

```SQL
REFRESH INDEX idx_message ON logs;

REFRESH INDEX idx_message ON logs LIMIT 1;

REFRESH INDEX idx_message ON logs SYNC;
```
