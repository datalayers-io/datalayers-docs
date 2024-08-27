# Redis Compatibility

The current implementation of the DataLayers Redis Service supports a subset of Redis commands, as outlined below:

| Command Category | Command | Support Level | Comments |
| --- | --- | --- | --- |
| **Connection Management** | PING | Fully Supported |     |
| **Generic** | KEYS | Fully Supported |     |
|     | DEL | Fully Supported |     |
| **Transaction** | MULTI | Fully Supported |     |
|     | EXEC | Fully Supported | If the transaction involves conflicting keys with another transaction on a different node, an error will be returned. This behavior differs from Redis, but we offer the option to retry the transaction. |
|     | DISCARD | Fully Supported |     |
| **String** | GET | Fully Supported |     |
|     | SET | Partially Supported | Supported syntax: `SET key value` |
|     | INCR | Fully Supported |     |
|     | INCRBY | Fully Supported |     |
|     | DECR | Fully Supported |     |
|     | DECRBY | Fully Supported |     |
| **Hash** | HSET | Fully Supported |     |
|     | HGET | Fully Supported |     |
|     | HDEL | Fully Supported |     |
|     | HLEN | Fully Supported |     |
| **Set** | SADD | Fully Supported |     |
|     | SMEMBERS | Fully Supported |     |
|     | SCARD | Fully Supported |     |
|     | SREM | Fully Supported |     |
| **SortedSet** | ZADD | Partially Supported | Supported syntax: `ZADD key score member` |
|     | ZRANGE | Partially Supported | Supported syntax: `ZRANGE key start stop`. Note: Time complexity is O(stop) instead of O(stop-start). |
|     | ZREM | Fully Supported |     |
|     | ZCARD | Fully Supported |     |

## Notes

- **Support Levels:**
  - **Fully Supported**: The command is fully supported. While the syntax and behavior closely align with Redis, there may be slight differences. Refer to the comments for specific details.
  - **Partially Supported**: The command is partially supported. Only certain syntaxes or functionalities are available. Refer to the comments for details.
