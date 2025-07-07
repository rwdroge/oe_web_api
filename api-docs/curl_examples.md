# GenericServiceRefactored API - cURL Examples

This document provides cURL command examples for testing the GenericServiceRefactored API endpoints from the command line.

## Base URL

Replace `http://localhost:8080/api/v1` with your actual API base URL if different.

## Items

### Get All Items

```bash
curl -X GET "http://localhost:8080/api/v1/data/items?limit=10&offset=0&sort_by=itemname" -H "Accept: application/json"
```

### Get Item by ID

```bash
curl -X GET "http://localhost:8080/api/v1/data/items/101" -H "Accept: application/json"
```

### Create Item

```bash
curl -X POST "http://localhost:8080/api/v1/data/items" \
  -H "Content-Type: application/json" \
  -d '{
    "itemname": "Smartphone",
    "price": {
      "value": 699.99
    },
    "category": "Electronics",
    "instock": true,
    "quantity": 100
  }'
```

### Update Item

```bash
curl -X PUT "http://localhost:8080/api/v1/data/items/102" \
  -H "Content-Type: application/json" \
  -d '{
    "price": {
      "value": 649.99
    },
    "quantity": 75
  }'
```

### Delete Item

```bash
curl -X DELETE "http://localhost:8080/api/v1/data/items/102"
```

### Get Items by Category

```bash
curl -X GET "http://localhost:8080/api/v1/data/items/category/Electronics" -H "Accept: application/json"
```

### Apply Discount to Item

```bash
curl -X POST "http://localhost:8080/api/v1/data/items/101/discount" \
  -H "Content-Type: application/json" \
  -d '{
    "discountPercent": 15.5
  }'
```

### Get Item Metadata

```bash
curl -X GET "http://localhost:8080/api/v1/meta/items" -H "Accept: application/json"
```

## Customers

### Get All Customers

```bash
curl -X GET "http://localhost:8080/api/v1/data/customers?limit=10&offset=0&sort_by=name" -H "Accept: application/json"
```

### Get Customer by ID

```bash
curl -X GET "http://localhost:8080/api/v1/data/customers/1001" -H "Accept: application/json"
```

### Create Customer

```bash
curl -X POST "http://localhost:8080/api/v1/data/customers" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "address": "123 Main St",
    "city": "Springfield",
    "state": "IL",
    "country": "USA",
    "phone": "555-123-4567",
    "email": "john.doe@example.com"
  }'
```

### Update Customer

```bash
curl -X PUT "http://localhost:8080/api/v1/data/customers/1001" \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "555-987-6543",
    "email": "john.updated@example.com"
  }'
```

### Delete Customer

```bash
curl -X DELETE "http://localhost:8080/api/v1/data/customers/1001"
```

### Get Customer Metadata

```bash
curl -X GET "http://localhost:8080/api/v1/meta/customers" -H "Accept: application/json"
```

## Orders

### Get All Orders

```bash
curl -X GET "http://localhost:8080/api/v1/data/orders?limit=10&offset=0&sort_by=orderdate" -H "Accept: application/json"
```

### Get Order by ID

```bash
curl -X GET "http://localhost:8080/api/v1/data/orders/5001" -H "Accept: application/json"
```

### Create Order

```bash
curl -X POST "http://localhost:8080/api/v1/data/orders" \
  -H "Content-Type: application/json" \
  -d '{
    "custnum": 1001,
    "orderdate": "2025-06-24",
    "status": "new",
    "items": [
      {
        "itemnum": 101,
        "quantity": 2,
        "price": 999.99
      }
    ]
  }'
```

### Update Order

```bash
curl -X PUT "http://localhost:8080/api/v1/data/orders/5001" \
  -H "Content-Type: application/json" \
  -d '{
    "status": "processing",
    "shipdate": "2025-06-28"
  }'
```

### Delete Order

```bash
curl -X DELETE "http://localhost:8080/api/v1/data/orders/5001"
```

### Get Order Metadata

```bash
curl -X GET "http://localhost:8080/api/v1/meta/orders" -H "Accept: application/json"
```

## Suppliers

### Get All Suppliers

```bash
curl -X GET "http://localhost:8080/api/v1/data/suppliers?limit=10&offset=0&sort_by=name" -H "Accept: application/json"
```

### Get Supplier by ID

```bash
curl -X GET "http://localhost:8080/api/v1/data/suppliers/201" -H "Accept: application/json"
```

### Create Supplier

```bash
curl -X POST "http://localhost:8080/api/v1/data/suppliers" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "ABC Supplies",
    "address": "456 Business Ave",
    "city": "Chicago",
    "state": "IL",
    "country": "USA",
    "phone": "555-987-6543",
    "email": "contact@abcsupplies.com",
    "active": true
  }'
```

### Update Supplier

```bash
curl -X PUT "http://localhost:8080/api/v1/data/suppliers/201" \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "555-111-2222",
    "email": "updated@abcsupplies.com"
  }'
```

### Delete Supplier

```bash
curl -X DELETE "http://localhost:8080/api/v1/data/suppliers/201"
```

### Get Supplier Metadata

```bash
curl -X GET "http://localhost:8080/api/v1/meta/suppliers" -H "Accept: application/json"
```
