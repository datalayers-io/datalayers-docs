# 快速开始

本节将引导您快速启动并使用Datalayers Key-value服务 的基本步骤。

## 启动Datalayers服务

通过以下配置可开启 Datalayers 的 Key-value 存储服务。

1. 打开 `config/config.toml` 文件，并找到 `[server]` 部分。
2. 将此部分中的 `standalone` 键设置为 `false`。
3. 取消注释同一部分中的 `redis` 键。
4. 保存配置文件并退出。
5. 使用以下命令启动Datalayers服务：

    ```bash
    ./target/debug/datalayers -c ./config/config.toml
    ```

## 使用Redis-cli连接到Datalayers

1. 如果您的系统尚未安装Redis，可以按照[Install Redis | Docs](https://redis.io/docs/latest/operate/oss_and_stack/install/install-redis/)中的说明下载并安装Redis。
2. 安装完成后，使用以下命令连接到Datalayers Key-value服务：

    ```bash
    redis-cli -p 8362
    ```
