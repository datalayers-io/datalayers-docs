# Quick Start

This section will guide you through the basic steps to quickly get started with the DataLayers Redis Service.

## Starting the DataLayers Service

To launch the DataLayers Service with Redis support enabled (assuming the default configuration):

1. Open the `config/config.toml` file and locate the `[server]` section.
2. Set the `standalone` key in this section to `false`.
3. Uncomment the `redis` key within the same section.
4. Save the configuration file and exit.
5. Start the DataLayers service with the following command:

    ```bash
    ./target/debug/datalayers -c ./config/config.toml
    ```

## Connecting to DataLayers using Redis-cli

1. If Redis is not already installed on your system, you can download and install it by following the instructions on the [Install Redis | Docs](https://redis.io/docs/latest/operate/oss_and_stack/install/install-redis/).
2. Once installed, connect to the DataLayers Redis Service using the following command (assuming the default Redis service port):

    ```bash
    redis-cli -p 8362
    ```