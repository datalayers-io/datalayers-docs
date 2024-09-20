# 多语言接入示例

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
    #
    # The authorization token `YWRtaW46cHVibGlj` is the encoded username and password 
    # which are 'admin' and 'public', respectively.
    host = "127.0.0.1"
    port = 8361
    url = "http://{}:{}/api/v1/sql".format(host, port)
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

```Go [Go]
package main

import (
    "bytes"
    "encoding/base64"
    "encoding/json"
    "fmt"
    "io"
    "net/http"
)

type Executor struct {
    client         *http.Client
    url            string
    requestHeaders map[string]string
}

func makeExecutor(host string, port uint32, username, password string) *Executor {
    auth := username + ":" + password
    encodedAuth := "Basic " + base64.StdEncoding.EncodeToString([]byte(auth))
    headers := make(map[string]string)
    headers["Content-Type"] = "application/binary"
    headers["Authorization"] = encodedAuth

    return &Executor{
        client:         &http.Client{},
        url:            fmt.Sprintf("http://%s:%d/api/v1/sql", host, port),
        requestHeaders: headers,
    }
}

func (exec *Executor) execute(sql string) (*http.Response, error) {
    encodedSql := bytes.NewBuffer([]byte(sql))
    request, err := http.NewRequest("POST", exec.url, encodedSql)
    if err != nil {
        fmt.Println("Error creating request:", err)
        return nil, err
    }

    for k, v := range exec.requestHeaders {
        request.Header.Set(k, v)
    }

    response, err := exec.client.Do(request)
    if err != nil {
        fmt.Println("Error sending request:", err)
        return nil, err
    }
    return response, nil
}

func print_response_status(response *http.Response) {
    fmt.Println("Status:", response.Status)
}

func print_query_result(response *http.Response) error {
    defer response.Body.Close()

    body, err := io.ReadAll(response.Body)
    if err != nil {
        fmt.Println("Error reading response body:", err)
        return err
    }

    // Parses the response into json objects.
    var obj map[string]interface{}
    if err = json.Unmarshal(body, &obj); err != nil {
        fmt.Println("Error decoding response into json:", err)
        return err
    }

    result := obj["result"].(map[string]interface{})
    columns := result["columns"].([]interface{})
    values := result["values"].([]interface{})

    // Print column names
    for _, col := range columns {
        fmt.Print(col, " ")
    }
    fmt.Println()

    // Print each row
    for _, row := range values {
        for _, val := range row.([]interface{}) {
            fmt.Print(val, " ")
        }
        fmt.Println()
    }

    return nil
}

func main() {
    // Setups an executor for executing sql against the Datalayers server.
    executor := makeExecutor("127.0.0.1", 8361, "admin", "public")

    // Creates a database `test`.
    sql := "create database test;"
    response, err := executor.execute(sql)
    if err != nil {
        fmt.Println("Error executing sql: ", err)
        return
    }
    // The returned status should be 200.
    print_response_status(response)

    // Creates a table `demo` within the database `test`.
    sql = `
        CREATE TABLE test.demo (
            ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            sid INT32,
            value REAL,
            flag INT8,
            timestamp key(ts)
        )
        PARTITION BY HASH(sid) PARTITIONS 8
        ENGINE=TimeSeries;`
    response, err = executor.execute(sql)
    if err != nil {
        fmt.Println("Error executing sql: ", err)
        return
    }
    // The returned status code should be 200.
    print_response_status(response)

    // Inserts some data into the `demo` table.
    sql = `
        INSERT INTO test.demo (ts, sid, value, flag) VALUES
            ('2024-09-01 10:00:00', 1, 12.5, 0),
            ('2024-09-01 10:05:00', 2, 15.3, 1),
            ('2024-09-01 10:10:00', 3, 9.8, 0),
            ('2024-09-01 10:15:00', 4, 22.1, 1),
            ('2024-09-01 10:20:00', 5, 30.0, 0);`
    response, err = executor.execute(sql)
    if err != nil {
        fmt.Println("Error executing sql: ", err)
        return
    }
    // The returned status code should be 200.
    print_response_status(response)

    // Queries the inserted data.
    sql = "SELECT * FROM test.demo"
    response, err = executor.execute(sql)
    if err != nil {
        fmt.Println("Error executing sql: ", err)
        return
    }
    // Prints the query result.
    //
    // The expected result is:
    // ts sid value flag
    // 2024-09-01T18:05:00+08:00 2 15.3 1
    // 2024-09-01T18:10:00+08:00 3 9.8 0
    // 2024-09-01T18:15:00+08:00 4 22.1 1
    // 2024-09-01T18:00:00+08:00 1 12.5 0
    // 2024-09-01T18:20:00+08:00 5 30 0
    if err = print_query_result(response); err != nil {
        fmt.Println("Error executing sql: ", err)
    }
}
```

:::
