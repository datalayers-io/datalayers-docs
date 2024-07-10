# TLS

## 配置和使用 TLS

### 生成证书
生成所需的根证书、服务端私钥、服务端证书，生成方法在下面。注意生成证书时授权的域名或 IP 要和访问目标的一致。

### 修改配置
``` toml
[server.tls]
key = "path_to_server_private_key"
cert = "path_to_server_cert"
```
配置文件中的 key 替换为服务端私钥的完整路径，cert 替换为服务端证书的完整路径。

### 访问方式
#### 访问 Https
通过浏览器访问，如果使用了自签证书，浏览器会提示不安全，忽略提示继续访问即可。

通过 wget 访问，如果使用了自签证书，需要增加命令行选项如下：
``` shell
$ wget --no-check-certificate https://127.0.0.1:8361/metrics
```
如果使用了机构签发证书，直接 wget 即可，注意替换域名为签发许可的域名：
``` shell
$ wget https://demo.datalayers.cn:8361/metrics
```

#### 访问 flightsql over TLS
通过 dlsql 命令行工具访问，如果使用自签证书，需要把根证书发布到客户端，dlsql 能访问的路径下，通过增加命令行选项 --tls 连接服务端，如下：
``` shell
$ dlsql -h 127.0.0.1 -P 8360 -u admin -p public --tls /path/to/ca.crt
```
如果使用了机构签发证书，使用 --tls 选项不带具体证书路径如下，注意替换域名为签发许可的域名：
``` shell
$ dlsql -h demo.datalayers.cn -P 8360 -u admin -p public --tls
```

## 生成证书
使用 TLS 需要配置证书路径，获取证书的方式包括从证书颁发机构获取和自签名两种。

### 自签证书

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

### 获取机构颁发证书
请参考证书颁发机构的证书申请流程，获得有效的服务端证书！注意，配置 datalayers 时仍需同时提供生成服务端证书所对应的私钥！
