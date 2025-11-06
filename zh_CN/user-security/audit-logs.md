# 审计日志

Datalayers 提供数据库操作审计能力，可记录用户对数据库的查询、修改等操作。审计日志以文件形式存储，每条记录采用 `JSON` 格式，便于后续查询与分析。

::: tip
Datalayers 采用事件开始前记录审计日志的方式，审计日志的记录数有可能多于实际操作完成数。
:::

## 开启审计日志

审计日志功能默认关闭，需要在配置文件中进行启用和配置，配置方法可参考 [配置审计日志](../admin/configuration-fields/audit-logs.md)

## 各操作的审计约束

| 操作              | kind    |  action |
|-------------------|---------|---------|
| UPDATE            | write   | update |
| DELETE            | write   | delete |
| CREATE ROLE       | admin   | create_user |
| CREATE USER       | admin   | create_user |
| DROP ROLE         | admin   | drop_user |
| DROP USER         | admin   | drop_user |
| GRANT             | admin   | grant |
| REVOKE            | admin   | revoke |
| SET PASSWORD      | admin   | set_password |
| CREATE DATABASE   | ddl     | create |
| DROP DATABASE     | ddl     | drop |
| TRIM DATABASE     | ddl     | trim |
| CREATE TABLE      | ddl     | create |
| DROP TABLE        | ddl     | drop |
| ALTER TABLE       | ddl     | alter |
| TRUNCATE TABLE    | ddl     | truncate |
| CREATE INDEX      | ddl     | alter |
| DROP INDEX        | ddl     | alter |
| FLUSH             | admin   | flush |
| COMPACT           | admin   | compact |
| EXPORT            | admin   | export |
| EXCLUDE NODE      | admin   | cluster |
| INCLUDE NODE      | admin   | cluster |
| DROP NODE         | admin   | cluster |
| REBALANCE         | admin   | migrate |
| STOP MIGRATION    | admin   | migrate |
| DESC TABLE        | admin   | desc |
| SHOW              | admin   | show |


::: tip
目前不支持对 SELECT 和 INSERT 语句的审计。
:::

## 查看审计日志

审计日志文件默认存储在以下目录：

``` text
/var/lib/datalayers/audit
```

您可以通过查看该目录下的日志文件来获取详细的审计信息。系统会按日期自动分割日志文件，便于管理和查询。

在生产环境中，建议根据实际安全合规要求，合理配置 kinds 和 actions 参数，平衡审计需求与系统性能。
