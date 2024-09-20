# 示例

我们提供以下语言的示例，展示如何使用基于 HTTP/HTTPS 的 REST API 与 Datalayers 进行交互：

* Python

::: code-group

```Python [Python]
import http
import json
from http.client import HTTPConnection


def print_response_status(conn: HTTPConnection):
    with conn.getresponse() as response:
        print(response.status)


def print_query_result(conn: HTTPConnection):
    with conn.getresponse() as response:
        # Parses the response into a json object since the Datalayers server always encodes response into json.
        data = response.read().decode('utf-8')
        obj = json.loads(data)
        # Retrieves the `columns` and `values` objects.
        # The `columns` object are the column names of the query result.
        # The `values` object are the rows of the query result.
        columns = obj['result']['columns']
        rows = obj['result']['values']
        # First prints the column names and then prints each row separately.
        print(columns)
        for row in rows:
            print(row)


def main():
    # Establishes an HTTP connection with the Datalayers server.
    # The authorization token is the encoded username and password which are 'admin' and 'public', respectively.
    host = "127.0.0.1"
    port = 18361
    url = "http://0.0.0.0:18361/api/v1/sql"
    headers = {
        "Content-Type": "application/binary",
        "Authorization": "Basic YWRtaW46cHVibGlj"
    }
    conn = http.client.HTTPConnection(host=host, port=port)

    # Creates a database `test`.
    sql = "create database test;"
    conn.request(method="POST", url=url, headers=headers, body=sql)
    # The returned status code should be 200.
    print_response_status(conn)

    # Creates a table `demo` within the database `test`.
    sql = '''
        CREATE TABLE test.demo (
                ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                sid INT32,
                value REAL,
                flag INT8,
                timestamp key(ts)
        )
        PARTITION BY HASH(sid) PARTITIONS 8
        ENGINE=TimeSeries;
        '''
    conn.request(method="POST", url=url, headers=headers, body=sql)
    # The returned status code should be 200.
    print_response_status(conn)

    # Inserts some data into the `demo` table.
    sql = '''
        INSERT INTO test.demo (ts, sid, value, flag) VALUES
            ('2024-09-01 10:00:00', 1, 12.5, 0),
            ('2024-09-01 10:05:00', 2, 15.3, 1),
            ('2024-09-01 10:10:00', 3, 9.8, 0),
            ('2024-09-01 10:15:00', 4, 22.1, 1),
            ('2024-09-01 10:20:00', 5, 30.0, 0);
        '''
    conn.request(method="POST", url=url, headers=headers, body=sql)
    # The returned status code should be 200.
    print_response_status(conn)

    # Queries the inserted data.
    sql = "SELECT * FROM test.demo"
    conn.request(method="POST", url=url, headers=headers, body=sql)
    # Prints the query result.
    print_query_result(conn)


if __name__ == "__main__":
    main()
```

:::
