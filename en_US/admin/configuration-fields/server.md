# Server

The `server` section contains configuration settings for starting and managing the Datalayers server. These options define how the server operates, including its mode (standalone or cluster), communication endpoints, and authentication settings.

## Configure Server Mode

- **`standalone`**:  
  Determines whether the server operates in standalone or cluster mode.  
  - `true`: Server runs in standalone mode, not part of a distributed system.  
  - `false`: Server runs in cluster mode, participating in a distributed environment.
  - **Default**: `false`.

## Configure Communication Endpoints

These settings define the communication ports for different protocols used by the Datalayers server.

- **`addr`**:  
  Specifies the Arrow FlightSql endpoint of the server. Clients connect to this endpoint for communicating through the Arrow FlightSql protocol.  
  - **Default**: `"0.0.0.0:8360"`.
  
- **`http`**:  
  Specifies the HTTP endpoint of the server.  
  - **Default**: `"0.0.0.0:8361"`.

- **`redis`**:  
  Specifies the Redis Service endpoint, which is only available in cluster mode.  
  - **Default**: `"0.0.0.0:8362"`.  
  - Note: This option is commented out, so it is disabled by default. Uncomment it to enable.

## Session Management

- **`session_timeout`**:  
  Determines how long a session can be inactive before timing out.  
  - **Default**: `"10s"` (10 seconds of inactivity).

## Configure Timezone

- **`timezone`**:  
  Defines the timezone the server operates in. If this is not provided, the server will use the local machine's timezone.  
  - **Default**: `"Asia/Shanghai"`.

## TLS (Transport Layer Security)

The `server.tls` section provides options for configuring TLS to secure communication with the server.

- **`key`**:  
  Path to the private key file for TLS-encrypted services (used for both HTTPS and FlightSql).  
  - Example: `"/etc/datalayers/certs/server.key"`.  
  - **Default**: Not provided by default (must be configured by the user).

- **`cert`**:  
  Path to the certificate file for TLS-encrypted services.  
  - Example: `"/etc/datalayers/certs/server.crt"`.  
  - **Default**: Not provided by default (must be configured by the user).

## Authentication

The `server.auth` section is used to configure user authentication for accessing the Datalayers server.

- **`username`**:  
  Username for logging into the Datalayers server.  
  - **Default**: `"admin"`.

- **`password`**:  
  Password for logging into the Datalayers server.  
  - **Default**: `"public"`.

- **`token`**:  
  A predefined token for authentication, used as an alternative method.  
  - **Default**: `"c720790361da729344983bfc44238f24"`.

- **`jwt_secret`**:  
  A secret key used for generating and validating JSON Web Tokens (JWT) for authentication.  
  - **Default**: `"871b3c2d706d875e9c6389fb2457d957"`.
