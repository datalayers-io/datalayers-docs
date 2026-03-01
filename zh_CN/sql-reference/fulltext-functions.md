# 全文检索函数

## 功能概述

Datalayers 提供以下 3 个全文检索相关 UDF：

- `MATCH`：按“列 + 检索词”执行全文检索。
- `QUERY`：按查询表达式执行全文检索。
- `SCORE`：返回当前检索命中的相关性评分。

## 使用约束

- `MATCH` 和 `QUERY` 只能出现在 `WHERE` 子句中。
- 一条查询中最多只能使用一个全文检索函数（`MATCH` 或 `QUERY`）。
- `SCORE()` 必须与 `MATCH` 或 `QUERY` 一起使用。

## MATCH

按“列 + 检索词”执行全文检索。

### 语法

```SQL
MATCH('<columns>', '<terms>'[, '<options>'])
```

### 参数说明

- `columns`：要检索的列名，字符串字面量。支持单列与多列：
  - 单列：`'message'`
  - 多列（逗号分隔）：`'summary,tags'`
  - 多列可设置列权重：`'summary^1.0,tags^2.0'`
- `terms`：检索词，字符串字面量。
- `options`：可选，`key=value` 形式，多个选项用 `;` 分隔。

支持的 `options`：

- `fuzziness`：模糊匹配编辑距离，取值 `0 | 1 | 2`。
- `operator`：词项组合方式，取值 `AND | OR`，默认 `OR`。
- `max_expansions`：模糊匹配最大扩展词数，非负整数。
- `prefix_length`：前缀保持不变长度，非负整数。
- `slop`：短语匹配允许词间距离，非负整数。

示例：

```SQL
SELECT *
FROM logs
WHERE MATCH('message', 'timeout');

SELECT *
FROM logs
WHERE MATCH('summary,tags', 'database', 'fuzziness=1');

-- 指定多个检索词，搜索结果需包含所有检索词
SELECT message, SCORE() AS score
FROM logs
WHERE MATCH('message', 'datalayers model', 'operator=AND')
ORDER BY SCORE() DESC
LIMIT 10;

-- 多列检索并设置列权重（summary 权重更高）
-- 针对每一列都会搜索所有检索词
SELECT *
FROM logs
WHERE MATCH('summary^2.0,tags^1.0', 'database timeout');

-- 使用完整 options 配置
SELECT *
FROM logs
WHERE MATCH(
  'message',
  'connection refused',
  'fuzziness=1;operator=AND;max_expansions=50;prefix_length=1;slop=1'
);
```

## QUERY

按查询表达式执行全文检索。

### 语法

```SQL
QUERY('<query_expr>'[, '<options>'])
```

### 参数说明

- `query_expr`：查询表达式，字符串字面量。
- `options`：可选，语法与 `MATCH` 的 `options` 一致。

支持的表达式能力：

- 基础匹配：`column:term`
- 短语匹配：`column:"a b"`
- 集合匹配：`column:in [term1 term2 term3]`
- 布尔表达式：`AND`、`OR`、`(...)`
- 必须/排除词：`+term`、`-term`
- 权重：`term^1.2`（权重范围 `0.1 ~ 100`）

示例：

```SQL
SELECT *
FROM logs
WHERE QUERY('message:error AND service:api');

SELECT *
FROM logs
WHERE QUERY('message:"disk full" OR message:in [timeout retry]');

SELECT message, SCORE() AS score
FROM logs
WHERE QUERY('message:+database -cache')
ORDER BY SCORE() DESC;

-- IN 语法：无 boost 时会按一个查询表达式处理
SELECT *
FROM logs
WHERE QUERY('message:in [timeout retry refused]');

-- IN 语法：带 boost（每个词可单独加权）
SELECT *
FROM logs
WHERE QUERY('message:in [timeout^0.5 retry refused^0.8]');

-- 同一列多词：包含 MUST / SHOULD / MUST_NOT，至少包含一个 MUST 或者 SHOULD 词项
SELECT *
FROM logs
WHERE QUERY('message:+database timeout -cache +storage');

-- 括号分组与布尔优先级
SELECT *
FROM logs
WHERE QUERY('service:api AND (message:timeout OR message:"connection refused")');

-- 反引号写法（当列名存在特殊字符时）
SELECT *
FROM logs
WHERE QUERY('`message`:database');
```

## SCORE

返回当前检索命中的相关性评分。

### 语法

```SQL
SCORE()
```

### 说明

- 返回当前命中记录的相关性分值（`FLOAT32`）。
- 常与 `SELECT` 投影和 `ORDER BY` 结合使用。

示例：

```SQL
SELECT message, SCORE() AS score
FROM logs
WHERE MATCH('message', 'multi-model database')
ORDER BY SCORE() DESC;
```
