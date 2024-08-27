# Overview

The Key-Value Data Model is an essential component of DataLayers, providing a distributed, transactional key-value data store with strong consistency guarantees. Leveraging the robust infrastructure of FoundationDB, this model ensures that updates to a key are instantly visible to all subsequent accesses, maintaining data consistency across users. Multiple optimizations have been implemented to enhance performance, making this model both powerful and reliable.

The Redis Service acts as a seamless interface between users and our key-value data model, facilitating interaction via a Redis client. While traditional Redis implementations are designed for in-memory key-value stores, our solution is engineered for a persistent, distributed key-value data model, ensuring data durability and scalability in distributed environments.

Looking ahead, future updates will introduce support for mapping SQL operations to key-value actions, further broadening the capabilities of our platform.

This document provides a comprehensive guide to using the Redis Service, along with best practices and compatibility information.