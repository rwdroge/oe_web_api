# GenericServiceRefactored API Documentation

This directory contains comprehensive documentation for the GenericServiceRefactored API.

## Documentation Files

- **OpenAPI Specification**: [`../openapi-specification.yaml`](../openapi-specification.yaml)
  - The formal OpenAPI 3.0.3 specification that describes all API endpoints, parameters, request/response structures, and schemas.

- **Interactive Documentation**: [`index.html`](index.html)
  - A Swagger UI-based interactive documentation page that allows you to explore the API visually.
  - Open this file in a web browser to view the interactive documentation.

- **API Guide**: [`API_GUIDE.md`](API_GUIDE.md)
  - A comprehensive guide that explains how to use the API with examples and detailed explanations.

- **Integration Guide**: [`INTEGRATION_GUIDE.md`](INTEGRATION_GUIDE.md)
  - Detailed information on how to integrate the API with various systems and frameworks, including code examples.

- **Extending the API**: [`EXTENDING_THE_API.md`](EXTENDING_THE_API.md)
  - Step-by-step instructions on how to extend the API with new entities and custom endpoints.

## Getting Started

1. To view the interactive documentation:
   - Open `index.html` in a web browser
   - The documentation will load the OpenAPI specification and render it in a user-friendly interface

2. For a quick reference on how to use the API:
   - Refer to the `API_GUIDE.md` file which contains examples and explanations

3. For testing the API:
   - Import the `GenericServiceRefactored_API.postman_collection.json` file into Postman
   - Use the cURL commands provided in `curl_examples.md`
   - Run the Python test script with `python api_test.py --run-examples`

4. For integration with tools or code generation:
   - Use the `openapi-specification.yaml` file directly

## API Overview

The GenericServiceRefactored API provides a RESTful interface for performing CRUD operations on various entities:

- **Items**: Products or inventory items
- **Customers**: Customer information
- **Orders**: Customer orders
- **Suppliers**: Supplier information

The API follows a service layer pattern and supports both data operations and metadata retrieval.

## Base URL

All API endpoints are relative to:

```
/api/v1
```

## API Types

The API supports two types of operations:

- `data`: For retrieving and manipulating entity data
- `meta`: For retrieving entity metadata

## Authentication

Authentication details will be added in a future version of the API.

## Support

For questions or issues related to the API, please contact the development team.
