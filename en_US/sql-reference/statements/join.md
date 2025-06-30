# Join Statement

JOIN 语句用来连接两个表以生成一个新的表。根据 JOIN 语句的类型，新的表包含被 JOIN 的两个表的列，或仅包含某个表的列。

## Inner Join

```sql
select * from sx1 join sx2 on sx1.sid = sx2.
```

## Full Join

```sql
select * from sx1 full join sx2 on sx1.sid = sx2.sid
```

## Left Join

```sql
select * from sx1 left join sx2 on sx1.sid = sx2.sid
```

## Left Semi Join

```sql
select * from sx1 left semi join sx2 on sx1.sid = sx2.sid
```

## Left Anti-Semi Join

```sql
select * from sx1 left anti join sx2 on sx1.sid = sx2.sid
```

## Right Join

```sql
select * from sx1 right join sx2 on sx1.sid = sx2.sid
```

## Right Semi Join

```sql
select * from sx1 right semi join sx2 on sx1.sid = sx2.sid
```

## Right Anti-Semi Join

```sql
select * from sx1 right anti join sx2 on sx1.sid = sx2.sid
```

## Natural Join

```sql
select * from sx1 natural join sx2
```

## Cross Join

```sql
select * from sx1 cross join sx2
```
