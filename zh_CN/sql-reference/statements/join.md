---
title: "JOIN 语句详解"
description: "Datalayers JOIN 语句详解 - JOIN 语句是 SQL 中用于连接多个表的核心操作，它基于表之间的关联关系将数据组合在一起，形成更完整的数据视图。"
---
# JOIN 语句详解

## 功能概述

JOIN 语句是 SQL 中用于连接多个表的核心操作，它基于表之间的关联关系将数据组合在一起，形成更完整的数据视图。

## INNER JOIN

```sql
select * from sx1 join sx2 on sx1.sid = sx2.sid
```

## FULL JOIN

```sql
select * from sx1 full join sx2 on sx1.sid = sx2.sid
```

## LEFT JOIN

```sql
select * from sx1 left join sx2 on sx1.sid = sx2.sid
```

## LEFT SEMI JOIN

```sql
select * from sx1 left semi join sx2 on sx1.sid = sx2.sid
```

## LEFT ANTI JOIN

```sql
select * from sx1 left anti join sx2 on sx1.sid = sx2.sid
```

## RIGHT JOIN

```sql
select * from sx1 right join sx2 on sx1.sid = sx2.sid
```

## RIGHT SEMI JOIN

```sql
select * from sx1 right semi join sx2 on sx1.sid = sx2.sid
```

## RIGHT ANTI JOIN

```sql
select * from sx1 right anti join sx2 on sx1.sid = sx2.sid
```

## NATURAL JOIN

```sql
select * from sx1 natural join sx2
```

## CROSS JOIN

```sql
select * from sx1 cross join sx2
```
