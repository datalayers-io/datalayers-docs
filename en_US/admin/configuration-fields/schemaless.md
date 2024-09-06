# Schemaless

The `schemaless` section controls the behavior of Datalayers when writing data without a predefined schema. This configuration is particularly useful in environments where flexibility in schema management is required, such as in IoT applications or unstructured data storage.

## Configure Auto Table Alteration

- **`auto_alter_table`**:  
  This setting determines whether Datalayers is allowed to automatically modify a table's schema when writing schemaless data.  
  - `true`: Automatic table alterations are allowed, meaning that the system will adjust the schema dynamically as new data with different structures is ingested.  
  - `false`: Automatic table alterations are disabled, and manual schema modifications will be required if new data doesn't match the existing schema.  
  - **Default**: `true`.
