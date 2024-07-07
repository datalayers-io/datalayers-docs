# TLS

## 配置和使用 TLS

### 开启 Https 服务
#### 生成证书
生成 https 服务所需的服务端私钥和服务端证书，生成方法在下面。注意生成证书时授权的域名或 IP 要和访问目标的一致。

#### 修改配置
``` toml
[server.tls]
http_key = "path_to_server_private_key"
http_cert = "path_to_server_cert"
```
配置文件中的 http_key 替换为服务端私钥的完整路径，http_cert 替换为服务端证书的完整路径。

#### 访问方式
通过浏览器访问，如果使用了自签证书，浏览器会提示不安全，忽略提示继续访问即可。

通过 wget 访问，如果使用了自签证书，需要增加命令行选项如下：
``` shell
$ wget --no-check-certificate https://127.0.0.1:8361/metrics
```

### 开启 flightsql over TLS
#### 生成证书
生成 flightsql over TLS 所需的根证书、服务端私钥、服务端证书，生成方法在下面。注意生成证书时授权的域名或 IP 要和访问目标的一致。

#### 修改配置
``` toml
[server.tls]
flight_key = "path_to_server_private_key"
flight_cert = "path_to_server_cert"
```
配置文件中的 flight_key 替换为服务端私钥的完整路径，flight_cert 替换为服务端证书的完整路径。

#### 访问方式
通过 dlsql 命令行工具访问，需要把根证书发布到客户端，dlsql 能访问的路径下，通过增加命令行选项 --tls 链接服务端，如下：
``` shell
$ dlsql -h 127.0.0.1 -P 8360 -u admin -p public --tls /path/to/ca.crt
```

## 生成证书
使用 TLS 需要配置证书路径，获取证书的方式包括从证书颁发机构获取和自签名两种。

### Https 自签证书
采用 Flightsql 自签证书的方法，生成的服务端私钥和证书，可以同时用于 https 和 flightsql 服务。

如果只用于 https 服务并希望简化 https 自签证书的生成，可以依照下面的方法，不通过根证书而直接根据服务端私钥生成证书。这种方法生成的证书不适用于 flightsql 服务。

1. 生成服务端的私钥
``` shell
$ openssl genrsa -out server.key 2048
```

2. 用服务端私钥生成证书
``` shell
$ openssl req -x509 -new -nodes -key server.key -sha256 -days 3650 -out server.crt
```

### Flightsql 自签证书

#### 生成根证书
1. 生成根证书的私钥
```shell
$ openssl genrsa -out ca.key 2048
```

2. 用该私钥生成根证书
```shell
$ openssl req -x509 -new -nodes -key ca.key -sha256 -days 3650 -out ca.crt
```
参数说明
* -nodes 免密码认证，避免服务器启动验证的时候需要输入密码。
* -days 指定有效期。

#### 生成服务端证书
1. 生成服务端的私钥
```shell
$ openssl genrsa -out server.key 2048
```

2. 用该私钥生成证书请求

首先创建一个配置文件 openssl.cnf 内容如下
```text
[req]
default_bits = 2048
distinguished_name = req_distinguished_name
req_extensions = req_ext
x509_extensions = v3_req
prompt = no

[req_distinguished_name]
countryName = CN
stateOrProvinceName = BeiJing
localityName = BeiJing
organizationName = Your Org Name
commonName = 127.0.0.1

[req_ext]
subjectAltName = @alt_names

[v3_req]
subjectAltName = @alt_names

[alt_names]
IP.1 = 127.0.0.1
DNS.1 = example.com
```
内容说明
* req_distinguished_name 的内容可以根据实际情况修改，其中 commonName 是授权认证的服务端域名或 IP；
* alt_names 的地址修改为服务端实际的 IP 或 DNS 或域名。

使用服务端私钥和 openssl.cnf 生成证书申请文件
``` shell
$ openssl req -new -key server.key -config openssl.cnf -out server.csr
```

3. 使用根证书对服务端颁发证书
``` shell
$ openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 3650 -sha256 -extensions v3_req -extfile openssl.cnf
```

4. 验证签发证书能够被根证书认可
``` shell
$ openssl verify -CAfile ca.crt server.crt
```
