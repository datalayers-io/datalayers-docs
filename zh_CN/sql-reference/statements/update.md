# UPDATE
UPDATE将更改满足条件的所有行中指定列的值。只有要修改的列需要在SET子句中提到;未显式修改的列保留其先前的值。

## UPDATE STATEMENT
```SQL
-- 对于符合 `id > 10`的每一行，将i 设置为 0
UPDATE table_name SET i = 0 WHERE id > 10 ;
-- 将表中所有数据的 i 设置为 1 ， j 设置为2 
UPDATE table_name SET i = 1, j = 2;
```