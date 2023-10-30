# 数据查询



## 查询数据

### 示例 
```shell
curl -X POST \
http://127.0.0.1:3308/api/v1/query?db=test \
-H 'Content-Type: application/json' \
-H 'Authorization: 62142d26f55fd8e42c24da7d772accb9' \
-d 'SELECT speed from vehicle_info where ts > NOW() - 1h and sn = 88888888'
```
返回值
```
todo
```

