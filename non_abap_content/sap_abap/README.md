# SAP_OLLAMA_Integration SAP ABAP Integration

This directory contains the ABAP code for the SAP Integration Layer of the SAP_OLLAMA_Integration framework. These components expose SAP functionalities and data to the external connector in a secure and controlled manner.

## Key Components

*   **RFC-enabled Function Modules:** For direct, synchronous calls to specific SAP logic (e.g., reading ABAP source code, fetching table data, executing BAPIs).
*   **OData Services:** (Optional, for more complex scenarios) For flexible, RESTful access to SAP data and business objects.
*   **Authorization Objects and Roles:** Custom and standard authorization objects to ensure that only authorized users can perform operations via the connector.
*   **Data Dictionary Objects:** Structures, table types, and tables required for data exchange.

## Development Guidelines

*   **Security First:** All exposed functionalities must include robust authorization checks (`AUTHORITY-CHECK`).
*   **Error Handling:** Implement comprehensive error handling and return meaningful error messages to the connector.
*   **Performance:** Optimize ABAP code for performance, especially when dealing with large datasets.
*   **Modularity:** Design components to be modular and reusable.
*   **Documentation:** Document all RFC-enabled function modules and other interfaces clearly.

## Example ABAP Functionality (Planned)

*   `Z_LLM_GET_ABAP_SOURCE`: Retrieves the source code of an ABAP program or class.
*   `Z_LLM_READ_TABLE_DATA`: Reads data from specified SAP tables, with filtering capabilities.
*   `Z_LLM_EXECUTE_BAPI`: A generic function module to execute standard SAP BAPIs.
*   `Z_LLM_GET_DDIC_INFO`: Retrieves Data Dictionary information for tables or structures.

## Transport Management

All ABAP development should be managed through standard SAP transport requests.
