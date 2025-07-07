# GenericServiceRefactored API Integration Guide

This guide provides detailed information on how to integrate the GenericServiceRefactored API with various systems and frameworks.

## Table of Contents

- [Overview](#overview)
- [API Client Generation](#api-client-generation)
- [Authentication](#authentication)
- [Common Integration Patterns](#common-integration-patterns)
- [Error Handling](#error-handling)
- [Performance Considerations](#performance-considerations)
- [Examples](#examples)

## Overview

The GenericServiceRefactored API provides a RESTful interface for performing CRUD operations on various entities. It follows a consistent pattern for all endpoints, making it straightforward to integrate with any system that can make HTTP requests.

Base URL: `/api/v1`

## API Client Generation

You can generate client libraries for various programming languages using the OpenAPI specification file (`openapi-specification.yaml`).

### Using OpenAPI Generator

The [OpenAPI Generator](https://github.com/OpenAPITools/openapi-generator) is a powerful tool that can generate client libraries, server stubs, and documentation from an OpenAPI specification.

```bash
# Install OpenAPI Generator
npm install @openapitools/openapi-generator-cli -g

# Generate a client library (example for JavaScript)
openapi-generator-cli generate -i openapi-specification.yaml -g javascript -o ./generated-client

# Generate a client library (example for Python)
openapi-generator-cli generate -i openapi-specification.yaml -g python -o ./generated-client

# Generate a client library (example for Java)
openapi-generator-cli generate -i openapi-specification.yaml -g java -o ./generated-client
```

### Using Swagger Codegen

[Swagger Codegen](https://github.com/swagger-api/swagger-codegen) is another option for generating client libraries.

```bash
# Download Swagger Codegen JAR
wget https://repo1.maven.org/maven2/io/swagger/codegen/v3/swagger-codegen-cli/3.0.34/swagger-codegen-cli-3.0.34.jar -O swagger-codegen-cli.jar

# Generate a client library (example for JavaScript)
java -jar swagger-codegen-cli.jar generate -i openapi-specification.yaml -l javascript -o ./generated-client
```

## Authentication

The current version of the API does not implement authentication. Future versions will support standard authentication mechanisms such as:

- API Keys
- OAuth 2.0
- JWT Tokens

When authentication is implemented, it will be documented in the OpenAPI specification.

## Common Integration Patterns

### Direct HTTP Requests

The simplest integration pattern is to make direct HTTP requests to the API endpoints. This approach works well for simple integrations or when you want to avoid dependencies on generated clients.

Example using JavaScript's fetch API:

```javascript
// Get all items
async function getAllItems() {
  const response = await fetch('http://localhost:8080/api/v1/data/items');
  if (!response.ok) {
    throw new Error(`HTTP error! status: ${response.status}`);
  }
  return await response.json();
}

// Create a new item
async function createItem(item) {
  const response = await fetch('http://localhost:8080/api/v1/data/items', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(item),
  });
  if (!response.ok) {
    throw new Error(`HTTP error! status: ${response.status}`);
  }
  return await response.json();
}
```

### Using a Generated Client

When using a generated client, the integration is typically more straightforward and type-safe.

Example using a JavaScript generated client:

```javascript
import { ApiClient, ItemsApi } from './generated-client';

const apiClient = new ApiClient('http://localhost:8080/api/v1');
const itemsApi = new ItemsApi(apiClient);

// Get all items
itemsApi.getAllItems((error, data) => {
  if (error) {
    console.error(error);
  } else {
    console.log('Items:', data);
  }
});

// Create a new item
const newItem = {
  itemname: 'Smartphone',
  price: {
    value: 699.99
  },
  category: 'Electronics',
  instock: true,
  quantity: 100
};

itemsApi.createItem(newItem, (error, data) => {
  if (error) {
    console.error(error);
  } else {
    console.log('Created item:', data);
  }
});
```

### Webhook Integration

For event-driven architectures, you might want to implement webhooks to notify external systems when certain events occur (e.g., item created, updated, deleted).

While the current API does not implement webhooks, you could extend it to support this pattern by:

1. Adding webhook registration endpoints
2. Implementing event listeners in the service layer
3. Sending HTTP requests to registered webhook URLs when events occur

## Error Handling

The API returns standard HTTP status codes to indicate the success or failure of a request. Additionally, error responses include a JSON body with more details about the error.

Example error response:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "details": [
      {
        "field": "price",
        "message": "Price must be a positive number"
      }
    ]
  }
}
```

When integrating with the API, make sure to handle these error responses appropriately.

## Performance Considerations

### Pagination

For endpoints that return collections of items, use the pagination parameters (`limit` and `offset`) to control the amount of data returned in a single request.

```
GET /api/v1/data/items?limit=10&offset=0
```

### Filtering

Use query parameters to filter results and reduce the amount of data transferred.

```
GET /api/v1/data/items?category=Electronics&instock=true
```

### Caching

Consider implementing client-side caching for frequently accessed data that doesn't change often, such as metadata.

## Examples

### Integration with a Front-End Framework

#### React Example

```jsx
import React, { useState, useEffect } from 'react';

function ItemsList() {
  const [items, setItems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetch('http://localhost:8080/api/v1/data/items')
      .then(response => {
        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`);
        }
        return response.json();
      })
      .then(data => {
        setItems(data.items || []);
        setLoading(false);
      })
      .catch(error => {
        setError(error.message);
        setLoading(false);
      });
  }, []);

  if (loading) return <p>Loading...</p>;
  if (error) return <p>Error: {error}</p>;

  return (
    <div>
      <h1>Items</h1>
      <ul>
        {items.map(item => (
          <li key={item.id}>
            {item.itemname} - ${item.price.value} ({item.category})
          </li>
        ))}
      </ul>
    </div>
  );
}

export default ItemsList;
```

#### Angular Example

```typescript
import { Component, OnInit } from '@angular/core';
import { HttpClient } from '@angular/common/http';

interface Item {
  id: number;
  itemname: string;
  price: {
    value: number;
  };
  category: string;
  instock: boolean;
  quantity: number;
}

interface ItemsResponse {
  items: Item[];
  total: number;
}

@Component({
  selector: 'app-items-list',
  template: `
    <div *ngIf="loading">Loading...</div>
    <div *ngIf="error">Error: {{error}}</div>
    <div *ngIf="!loading && !error">
      <h1>Items</h1>
      <ul>
        <li *ngFor="let item of items">
          {{item.itemname}} - ${{item.price.value}} ({{item.category}})
        </li>
      </ul>
    </div>
  `
})
export class ItemsListComponent implements OnInit {
  items: Item[] = [];
  loading = true;
  error: string | null = null;

  constructor(private http: HttpClient) {}

  ngOnInit() {
    this.http.get<ItemsResponse>('http://localhost:8080/api/v1/data/items')
      .subscribe({
        next: (data) => {
          this.items = data.items || [];
          this.loading = false;
        },
        error: (error) => {
          this.error = error.message;
          this.loading = false;
        }
      });
  }
}
```

### Integration with a Back-End System

#### Node.js Example

```javascript
const express = require('express');
const axios = require('axios');
const app = express();
const port = 3000;

app.use(express.json());

// Proxy endpoint for items
app.get('/items', async (req, res) => {
  try {
    const response = await axios.get('http://localhost:8080/api/v1/data/items', {
      params: req.query
    });
    res.json(response.data);
  } catch (error) {
    res.status(error.response?.status || 500).json({
      error: error.response?.data?.error || { message: 'Internal server error' }
    });
  }
});

// Create a new item
app.post('/items', async (req, res) => {
  try {
    const response = await axios.post('http://localhost:8080/api/v1/data/items', req.body);
    res.status(201).json(response.data);
  } catch (error) {
    res.status(error.response?.status || 500).json({
      error: error.response?.data?.error || { message: 'Internal server error' }
    });
  }
});

app.listen(port, () => {
  console.log(`Proxy server listening at http://localhost:${port}`);
});
```

#### Python Example

```python
from flask import Flask, request, jsonify
import requests

app = Flask(__name__)
API_BASE_URL = 'http://localhost:8080/api/v1'

@app.route('/items', methods=['GET'])
def get_items():
    params = request.args.to_dict()
    response = requests.get(f'{API_BASE_URL}/data/items', params=params)
    return jsonify(response.json()), response.status_code

@app.route('/items', methods=['POST'])
def create_item():
    data = request.get_json()
    response = requests.post(f'{API_BASE_URL}/data/items', json=data)
    return jsonify(response.json()), response.status_code

if __name__ == '__main__':
    app.run(port=3000)
```

### Integration with a Mobile App

#### React Native Example

```jsx
import React, { useState, useEffect } from 'react';
import { View, Text, FlatList, StyleSheet } from 'react-native';

const ItemsScreen = () => {
  const [items, setItems] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetch('http://localhost:8080/api/v1/data/items')
      .then(response => {
        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`);
        }
        return response.json();
      })
      .then(data => {
        setItems(data.items || []);
        setLoading(false);
      })
      .catch(error => {
        setError(error.message);
        setLoading(false);
      });
  }, []);

  if (loading) return <Text>Loading...</Text>;
  if (error) return <Text>Error: {error}</Text>;

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Items</Text>
      <FlatList
        data={items}
        keyExtractor={item => item.id.toString()}
        renderItem={({ item }) => (
          <View style={styles.item}>
            <Text style={styles.itemName}>{item.itemname}</Text>
            <Text>${item.price.value}</Text>
            <Text>Category: {item.category}</Text>
          </View>
        )}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 16,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    marginBottom: 16,
  },
  item: {
    padding: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#ccc',
  },
  itemName: {
    fontSize: 18,
    fontWeight: 'bold',
  },
});

export default ItemsScreen;
```

This integration guide provides a comprehensive overview of how to integrate with the GenericServiceRefactored API using various technologies and patterns. For specific integration questions or issues, please contact the development team.
