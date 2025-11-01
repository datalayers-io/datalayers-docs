# Join 语句详解

## 功能概述
JOIN 语句是 SQL 中用于连接多个表的核心操作，它基于表之间的关联关系将数据组合在一起，形成更完整的数据视图。

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
