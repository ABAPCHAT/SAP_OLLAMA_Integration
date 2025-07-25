# SAP_OLLAMA_Integration Connector

This directory contains the middleware connector application that facilitates communication between the Ollama LLM and the SAP system.

## Technologies

*   **Language:** Python
*   **SAP Connectivity:** `pyrfc` (or similar library for RFC calls) / OData client libraries
*   **LLM Integration:** Ollama Python client library (or direct HTTP requests)

## Key Responsibilities

*   Receiving tool call requests from the Ollama LLM.
*   Authenticating and establishing a secure session with the SAP system.
*   Translating LLM requests into appropriate SAP calls (RFC, OData, BAPI).
*   Executing calls against the SAP system.
*   Transforming raw SAP responses into LLM-friendly formats (e.g., JSON, structured text).
*   Handling errors and exceptions, including SAP authorization failures.
*   Logging interactions for auditing and debugging.

## Setup and Configuration

1.  **Python Environment:** Set up a Python virtual environment.
2.  **Dependencies:** Install required Python packages (e.g., `pyrfc`, `requests`, `ollama`).
3.  **SAP Connection Details:** Configure SAP system connection parameters (e.g., hostname, client, user, password, RFC destination details).
4.  **Ollama Endpoint:** Configure the URL of your local Ollama instance.

## Usage

To be detailed: How to start the connector, how it listens for LLM requests, and how it processes them.
