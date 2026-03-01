# Log Table Design Guide

## Overview

The log table model is optimized for log search workloads. By combining columnar storage, partitioning, and inverted indexing, Datalayers supports high-throughput ingestion and low-latency retrieval.

For log scenarios, focus on the following design goals first:

- Write throughput: sustained high-concurrency log ingestion
- Query efficiency: fast retrieval using keywords, phrases, and boolean expressions
- Storage efficiency: controlled resource usage while keeping logs searchable

## Table DDL

```sql
CREATE TABLE [IF NOT EXISTS] [database.]table_name
(
    ts TIMESTAMP [ DEFAULT default_expr ],
    service STRING,
    level STRING,
    message STRING,
    ...,
    TIMESTAMP KEY (ts),
    [ INVERTED INDEX [index_name] (message_column) [WITH (key=value, ...)] ]
)
PARTITION BY HASH(partition_key) PARTITIONS n
[ENGINE=TimeSeries]
[ WITH ( [ key = value ] [, ... ] ) ]
```

## Practical Patterns

### Scenario 1: General log search (partition by service)

For general log search, use `service` as the partition key, keep log content in `message`, and declare an inverted index directly in the table DDL.

| Column   | Description |
|----------|-------------|
| ts       | Log timestamp (required) |
| service  | Service/application name for filtering and isolation |
| level    | Log level (INFO/WARN/ERROR) |
| message  | Log content used for full-text search |

Example table DDL:

```sql
CREATE TABLE logs (
    ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    service STRING NOT NULL,
    level STRING,
    message STRING,
    timestamp key(ts),
    inverted index idx_message (message) with (tokenizer=english, case_sensitive=false, with_position=true)
)
PARTITION BY HASH(service) PARTITIONS 2;
```

**Notes**:

- `ts` must be `TIMESTAMP` and declared with `TIMESTAMP KEY`
- `message` should use `STRING` as the primary full-text field
- Choosing `service` as the partition key helps service-level filtering and parallel query execution

### Scenario 2: Multi-tenant log search (partition by tenant)

For multi-tenant workloads, use `tenant_id` as the partition key. This enables tenant-level filtering before full-text matching on log content.

| Column    | Description |
|-----------|-------------|
| ts        | Log timestamp |
| tenant_id | Tenant identifier |
| host      | Host or node |
| message   | Log content |

Example table DDL:

```sql
CREATE TABLE tenant_logs (
    ts TIMESTAMP NOT NULL,
    tenant_id STRING NOT NULL,
    host STRING,
    message STRING,
    timestamp key(ts),
    inverted index idx_tenant_message (message) with (tokenizer=chinese, case_sensitive=false, with_position=true)
)
PARTITION BY HASH(tenant_id) PARTITIONS 4;
```

**Notes**:

- Using `tenant_id` as partition key improves in-tenant query efficiency
- Choose `tokenizer` based on log language (`english` / `chinese`)
- `with_position=true` helps phrase-level matching and relevance scoring

## PARTITIONS Sizing Recommendations

- `PARTITIONS` currently cannot be changed dynamically after table creation, so it must be planned up front
- As a rule of thumb, one partition can typically handle hundreds of thousands of point writes per second, depending on workload
- More partitions consume more CPU and memory; keep partition count within the total CPU cores across cluster nodes
- Prefer high-cardinality fields frequently used as filters as partition keys (for example, `service`, `tenant_id`)
- If partition planning later proves unsuitable, adjustment usually requires creating a new table and migrating data

## Related Docs

- [CREATE Statement](../../sql-reference/statements/create.md)
- [REFRESH Statement](../../sql-reference/statements/refresh.md)
- [DROP Statement](../../sql-reference/statements/drop.md)
- [Fulltext Functions](../../sql-reference/fulltext-functions.md)
- [Log Search Overview](../../log-search/overview.md)
