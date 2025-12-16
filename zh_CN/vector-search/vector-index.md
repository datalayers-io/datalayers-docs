# 向量索引技术指南

## 概述

向量索引是加速大规模向量数据集检索的关键技术。Datalayers 支持多种向量索引类型，通过三层式架构实现高效的近似最近邻搜索。
使用向量索引会带来额外的构建索引开销、检索开销，同时可能会降低召回率（recall），因此需要根据具体场景选择合适的索引、以及配置合适的参数。

## 向量索引模型

Datalayers 使用三层式结构对主流的向量索引进行统一建模。

![向量索引模型](../assets/vector-index-model.png)

### IVF Model

IVF（Inverted File）模型指质心 -> 向量组的倒排索引。在构建向量索引时，我们首先利用 K-Means 聚簇算法将向量数据集分成若干个向量组，每个向量组存在一个质心（Centroid）。IVF 模型维护了每个质心与其所在向量组的映射关系。

### Cell Index

我们将每一个向量组称为一个 Cell，该名称延用知名向量检索库 Faiss 中的命名。Datalayers 支持给向量组内的向量构建索引，称为 Cell Index，以加速向量组内的近似最近邻搜索。例如，当我们使用 HNSW 向量索引时，我们会为每个向量组构建一个图索引，利用图数据结构来加速检索。

### Vector Store

Vector Store 是向量的存储抽象。为了节省存储空间，我们支持对向量进行量化。量化指将原始向量投影到另一个更紧凑的向量空间，以达到数据压缩的目的。主流的量化算法包括乘积量化（PQ）、标量量化（SQ）等，它们均是有损、不可逆的量化算法，因此在搜索时会降低召回率。

## 基于索引的向量检索

给定查询向量 Q 以及 top-K 中的 K，基于索引的三层式结构，Datalayers 的向量检索分成如下步骤：

1. 模糊搜索：我们首先访问 IVF Model，计算 Q 与所有质心的距离，并取最近的 P 个质心所对应的向量组。
2. 精确搜索：对于每个向量组，我们使用 Cell Index 加速向量组内的近似最近邻搜索，每个质心得到 top-N 个与 Q 距离最近的向量。
3. 精炼：考虑到向量索引会降低召回率，对于搜索得到的 `P * N` 个向量，计算它们与 Q 的距离，得到最终的 top-K 个距离最近的向量。其中 `N / K` 称为 `refine_factor`，表示为了补偿召回率，我们在精确搜索时每个向量组额外检索了多少个向量。这个步骤称为精炼（Refine）。

## 索引类型

|               |  IVF Model       | Cell Index  | Vector Store | 是否已支持 |
| :-----        | :----------:     | :---------: | :----------: | :-----: |
| FLAT          | Cell 个数固定为 1  | FLAT        | FLAT         |    是     |
| IVF_FLAT      | 支持配置 Cell 个数 | FLAT        | FLAT         |    是     |
| IVF_PQ        | 支持配置 Cell 个数 | FLAT        | PQ           |    是     |
| IVF_SQ        | 支持配置 Cell 个数 | FLAT        | SQ           |      否     |
| IVF_RQ        | 支持配置 Cell 个数 | FLAT        | RQ           |      是     |
| HNSW          | Cell 个数固定为 1 | HNSW        | FLAT          |      是     |
| HNSW_SQ       | Cell 个数固定为 1 | HNSW        | SQ          |      否     |
| HNSW_PQ       | Cell 个数固定为 1 | HNSW        | PQ          |      是     |
| HNSW_RQ       | Cell 个数固定为 1 | HNSW        | RQ          |      否     |
| IVF_HNSW      | 支持配置 Cell 个数 | HNSW        | FLAT          |      是     |
| IVF_HNSW_PQ   | 支持配置 Cell 个数 | HNSW        | PQ            |      是     |
| IVF_HNSW_SQ   | 支持配置 Cell 个数 | HNSW        | SQ            |      否     |
| IVF_HNSW_RQ   | 支持配置 Cell 个数 | HNSW        | RQ            |      否     |

注：

- Cell Index 为 FLAT，表示向量组内的搜索退回到平搜（Flat Search），即搜索所有向量。
- Cell Index 为 HNSW，表示使用 HNSW（Hierarchical Navigable Small Worlds）索引加速向量组内的搜索。
- Vector Store 为 FLAT，表示不使用任何量化算法，而存储原始、未经压缩的向量。
- PQ 指 Product Quantization，即乘积量化。
- SQ 指 Scalar Quantization，即标量量化。
- RQ 指 RaBit Quantization。

## 语法

Datalayers 支持在建表时为向量列指定向量索引，语法为：

``` sql
VECTOR INDEX <index_name>(<vector_col_name>) [ WITH (<vector_index_options>) ]
```

例如，在创建表 `t` 时，给 `embed` 向量列指定一个向量索引，命名为 `my_vector_index`，同时将其类型设置为 `IVF_PQ`，距离函数设置为 `L2`。

``` sql
CREATE TABLE `t` (
    `ts` TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `sid` INT32 NOT NULL,
    `embed` VECTOR(64),
    TIMESTAMP KEY(`ts`),
    VECTOR INDEX `my_vector_index`(`embed`) WITH (TYPE=IVF_PQ, DISTANCE=L2)
) 
PARTITION BY HASH (`sid`) PARTITIONS 1
```

## 示例

我们提供了一个 Python 脚本，展示如何使用向量索引来加速向量检索。这个脚本执行的步骤如下：

1. 创建数据库 `demo`。
2. 创建表 `t`。表中包含一个向量列 `embed`，维度为 64。同时为该列指定 IVF_PQ 索引，同时设置构建索引的距离函数为 L2。
3. 写入 5000 条随机数据。
4. Flush 数据。
5. 等待索引构建完成，默认等待 15 秒。
6. 使用随机向量，执行向量检索。

``` python
import http
import json
import random
import time
from http.client import HTTPConnection


def main():
    host = "0.0.0.0"
    port = 8361
    url = "http://{}:{}/api/v1/sql".format(host, port)
    headers = {
        "Content-Type": "application/binary",
        "Authorization": "Basic YWRtaW46cHVibGlj"
    }
    conn = http.client.HTTPConnection(host=host, port=port)

    # Create database `demo`.
    sql = "CREATE DATABASE IF NOT EXISTS demo;"
    conn.request(method="POST", url=url, headers=headers, body=sql)
    print_response("创建数据库", conn)

    # Create table `t`.
    sql = '''
        CREATE TABLE IF NOT EXISTS `demo`.`t` (
            `ts` TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
            `sid` INT32 NOT NULL,
            `value` REAL,
            `flag` INT8,
            `embed` VECTOR(64),
            TIMESTAMP KEY(`ts`),
            VECTOR INDEX `my_vector_index`(`embed`) WITH (TYPE=IVF_PQ, DISTANCE=L2)
        ) 
        PARTITION BY HASH (`sid`) PARTITIONS 1
        ENGINE=TimeSeries
        WITH (
            MEMTABLE_SIZE=1024MB,
            STORAGE_TYPE=LOCAL,
            UPDATE_MODE=APPEND
        );
        '''
    conn.request(method="POST", url=url, headers=headers, body=sql)
    print_response("创建表", conn)

    # 分批插入数据
    insert_data(
        conn, url, headers, total_rows=5000, batch_size=1000)

    # Flush 数据
    flush_data(conn, url, headers)

    # 等待索引构建完成
    print("等待索引构建完成...")
    time.sleep(15)

    # Vector search with random query vector
    query_vector = generate_random_vector(64)
    sql = f"SELECT value FROM demo.t WHERE sid = 1 ORDER BY l2_distance(embed, {query_vector}) LIMIT 1"
    print(f"执行向量检索: {sql}")
    conn.request(method="POST", url=url, headers=headers, body=sql)
    print_query_result(conn)


def generate_random_vector(dim: int) -> str:
    """生成随机向量字符串表示"""
    vector = [round(random.uniform(-1.0, 1.0), 6) for _ in range(dim)]
    return "[" + ", ".join(map(str, vector)) + "]"


def insert_data(conn: HTTPConnection, url: str, headers: dict, total_rows: int, batch_size: int):
    """分批插入数据"""
    num_batches = total_rows // batch_size

    print(f"开始插入 {total_rows} 条数据，分 {num_batches} 批次，每批 {batch_size} 条")

    for batch in range(num_batches):
        print(f"插入第 {batch + 1}/{num_batches} 批次...")

        values = []
        for _ in range(batch_size):
            sid = random.randint(0, 5000)
            value = round(random.uniform(0.0, 100.0), 2)
            flag = random.randint(0, 1)
            embed = generate_random_vector(64)

            values.append(f"({sid}, {value}, {flag}, {embed})")

        sql = f"INSERT INTO demo.t (sid, value, flag, embed) VALUES {', '.join(values)}"
        conn.request(method="POST", url=url, headers=headers, body=sql)

        response = conn.getresponse()

        if response.status == 200:
            print(f"✓ 第 {batch + 1} 批次插入成功")
        else:
            print(f"✗ 第 {batch + 1} 批次插入失败: {response.status} {response.reason}")

        response.read()

        time.sleep(0.5)


def flush_data(conn: HTTPConnection, url: str, headers: dict):
    print("正在 Flush 数据")
    sql = "FLUSH TABLE demo.t SYNC"
    conn.request(method="POST", url=url, headers=headers, body=sql)

    response = conn.getresponse()

    if response.status == 200:
        print(f"Flush 数据成功")
    else:
        print(f"Flush 数据失败: {response.status} {response.reason}")

    response.read()


def print_response(msg: str, conn: HTTPConnection):
    with conn.getresponse() as response:
        if response.status == 200:
            print(f"{msg} 成功")
        else:
            print(f"{msg} 失败: {response.status} {response.reason}")

        response.read()

def print_query_result(conn: HTTPConnection):
    print("检索结果:")

    with conn.getresponse() as response:
        data = response.read().decode('utf-8')
        obj = json.loads(data)

        columns = obj['result']['columns']
        rows = obj['result']['values']

        print(columns)
        for row in rows:
            print(row)

if __name__ == "__main__":
    main()
```

在测试机器上，为 5000 条数据构建向量索引大致需要 2 秒。为了确认在您的机器上索引已经构建完成，您可以通过执行 `SHOW TASKS` 命令检视当前正在执行、被挂起的索引构建任务。如果 `build_index` 任务的 `running` 和 `pending` 数量为 0，说明所有索引已经构建完毕。

``` sql
> show tasks

+-------------+---------+---------+-------------------+-------------+----------------------------------------------------+
| type        | running | pending | concurrence_limit | queue_limit | description                                        |
+-------------+---------+---------+-------------------+-------------+----------------------------------------------------+
| build_index | 1       | 1       | 1                 | 10000       | Build index.                                       |
| compact     | 0       | 0       | 3                 | 10000       | Compaction, TTL clean.                             |
| flush       | 0       | 0       | 10                | 10000       | Flush memtable into file.                          |
| gc          | 0       | 0       | 100               | 10000       | Delete files when drop table, truncate table, etc. |
| timer       | 0       | 18      | 0                 | 0           | Delayed tasks executed at specified time           |
| workflow    | 0       | 0       | 10                | 10000       | Table DDL operation.                               |
+-------------+---------+---------+-------------------+-------------+----------------------------------------------------+
```

## 注意事项

- 构建索引时的距离函数与搜索时的距离函数必须一致，否则无法触发向量索引。
- 目前仅支持为 32 维以上的向量列构建向量索引。
- 目前不支持为索引配置构建参数、搜索参数，仅支持使用内部默认参数。
