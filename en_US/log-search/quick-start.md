# Log Search Quick Start

This is a placeholder quick start for log search.

## Basic Flow

1. Create a table with a `STRING` log message column.
2. Create an inverted index on the log message column.
3. Run `REFRESH INDEX` if historical data existed before index creation.
4. Query logs with `MATCH` / `QUERY` and sort by `SCORE()`.

See also:

- `sql-reference/fulltext-functions`
- `sql-reference/statements/index`
