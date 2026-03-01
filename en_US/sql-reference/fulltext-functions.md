# Fulltext Functions

This is a placeholder page for fulltext SQL functions in Datalayers.

## Covered Functions

- `MATCH('<columns>', '<terms>'[, '<options>'])`
- `QUERY('<query_expr>'[, '<options>'])`
- `SCORE()`

## Current Constraints (Code-aligned)

- `MATCH` and `QUERY` are only valid in the `WHERE` clause.
- Only one fulltext search function (`MATCH` or `QUERY`) can be used in a single query.
- `SCORE()` must be used together with `MATCH` or `QUERY`.

## Example

```sql
SELECT message, SCORE() AS score
FROM logs
WHERE MATCH('message', 'database timeout')
ORDER BY SCORE() DESC
LIMIT 10;
```

## Notes

A full English version will be added in a later documentation update.
