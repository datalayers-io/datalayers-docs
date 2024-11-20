# Quick Start

This section will guide you through the basic steps to quickly get started with the Datalayers Key-value Service.

## Starting the Datalayers Service

To launch the Datalayers Service with Redis support enabled (assuming the default configuration):

1. Open the `config/config.toml` file and locate the `[server]` section.
2. Set the `standalone` key in this section to `false`.
3. Uncomment the `redis` key within the same section.
4. Save the configuration file and exit.
5. Start the Datalayers service with the following command:

    ```bash
    ./target/debug/datalayers -c ./config/config.toml
    ```

## Connecting to Datalayers using Redis-cli

1. If Redis is not already installed on your system, you can download and install it by following the instructions on the [Install Redis | Docs](https://redis.io/docs/latest/operate/oss_and_stack/install/install-redis/).
2. Once installed, connect to the Datalayers Redis Service using the following command:

    ```bash
    redis-cli -p 8362
    ```
