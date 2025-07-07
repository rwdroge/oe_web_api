#!/usr/bin/env python3
"""
GenericServiceRefactored API Test Script

This script provides functions to test the GenericServiceRefactored API endpoints using Python's requests library.
"""

import requests
import json
import argparse
from typing import Dict, Any, Optional, List, Union

# Base URL for the API
BASE_URL = "http://localhost:8080/api/v1"

# Headers for JSON content
JSON_HEADERS = {"Content-Type": "application/json", "Accept": "application/json"}


def get_all_items(limit: int = 10, offset: int = 0, sort_by: str = "itemname") -> Dict[str, Any]:
    """Get all items with optional filtering."""
    url = f"{BASE_URL}/data/items"
    params = {"limit": limit, "offset": offset, "sort_by": sort_by}
    response = requests.get(url, params=params, headers=JSON_HEADERS)
    return {"status_code": response.status_code, "data": response.json() if response.ok else None}


def get_item_by_id(item_id: int) -> Dict[str, Any]:
    """Get a specific item by its ID."""
    url = f"{BASE_URL}/data/items/{item_id}"
    response = requests.get(url, headers=JSON_HEADERS)
    return {"status_code": response.status_code, "data": response.json() if response.ok else None}


def create_item(item_data: Dict[str, Any]) -> Dict[str, Any]:
    """Create a new item."""
    url = f"{BASE_URL}/data/items"
    response = requests.post(url, json=item_data, headers=JSON_HEADERS)
    return {"status_code": response.status_code, "data": response.json() if response.ok else None}


def update_item(item_id: int, item_data: Dict[str, Any]) -> Dict[str, Any]:
    """Update an existing item."""
    url = f"{BASE_URL}/data/items/{item_id}"
    response = requests.put(url, json=item_data, headers=JSON_HEADERS)
    return {"status_code": response.status_code, "data": response.json() if response.ok else None}


def delete_item(item_id: int) -> Dict[str, Any]:
    """Delete an item."""
    url = f"{BASE_URL}/data/items/{item_id}"
    response = requests.delete(url, headers=JSON_HEADERS)
    return {"status_code": response.status_code, "data": response.json() if response.ok else None}


def get_items_by_category(category: str) -> Dict[str, Any]:
    """Get all items in a specific category."""
    url = f"{BASE_URL}/data/items/category/{category}"
    response = requests.get(url, headers=JSON_HEADERS)
    return {"status_code": response.status_code, "data": response.json() if response.ok else None}


def apply_discount_to_item(item_id: int, discount_percent: float) -> Dict[str, Any]:
    """Apply a discount to an item's price."""
    url = f"{BASE_URL}/data/items/{item_id}/discount"
    discount_data = {"discountPercent": discount_percent}
    response = requests.post(url, json=discount_data, headers=JSON_HEADERS)
    return {"status_code": response.status_code, "data": response.json() if response.ok else None}


def get_item_metadata() -> Dict[str, Any]:
    """Get metadata for the items entity."""
    url = f"{BASE_URL}/meta/items"
    response = requests.get(url, headers=JSON_HEADERS)
    return {"status_code": response.status_code, "data": response.json() if response.ok else None}


def get_all_customers(limit: int = 10, offset: int = 0, sort_by: str = "name") -> Dict[str, Any]:
    """Get all customers with optional filtering."""
    url = f"{BASE_URL}/data/customers"
    params = {"limit": limit, "offset": offset, "sort_by": sort_by}
    response = requests.get(url, params=params, headers=JSON_HEADERS)
    return {"status_code": response.status_code, "data": response.json() if response.ok else None}


def get_customer_by_id(customer_id: int) -> Dict[str, Any]:
    """Get a specific customer by ID."""
    url = f"{BASE_URL}/data/customers/{customer_id}"
    response = requests.get(url, headers=JSON_HEADERS)
    return {"status_code": response.status_code, "data": response.json() if response.ok else None}


def create_customer(customer_data: Dict[str, Any]) -> Dict[str, Any]:
    """Create a new customer."""
    url = f"{BASE_URL}/data/customers"
    response = requests.post(url, json=customer_data, headers=JSON_HEADERS)
    return {"status_code": response.status_code, "data": response.json() if response.ok else None}


def update_customer(customer_id: int, customer_data: Dict[str, Any]) -> Dict[str, Any]:
    """Update an existing customer."""
    url = f"{BASE_URL}/data/customers/{customer_id}"
    response = requests.put(url, json=customer_data, headers=JSON_HEADERS)
    return {"status_code": response.status_code, "data": response.json() if response.ok else None}


def delete_customer(customer_id: int) -> Dict[str, Any]:
    """Delete a customer."""
    url = f"{BASE_URL}/data/customers/{customer_id}"
    response = requests.delete(url, headers=JSON_HEADERS)
    return {"status_code": response.status_code, "data": response.json() if response.ok else None}


def get_customer_metadata() -> Dict[str, Any]:
    """Get metadata for the customers entity."""
    url = f"{BASE_URL}/meta/customers"
    response = requests.get(url, headers=JSON_HEADERS)
    return {"status_code": response.status_code, "data": response.json() if response.ok else None}


def get_all_orders(limit: int = 10, offset: int = 0, sort_by: str = "orderdate") -> Dict[str, Any]:
    """Get all orders with optional filtering."""
    url = f"{BASE_URL}/data/orders"
    params = {"limit": limit, "offset": offset, "sort_by": sort_by}
    response = requests.get(url, params=params, headers=JSON_HEADERS)
    return {"status_code": response.status_code, "data": response.json() if response.ok else None}


def get_order_by_id(order_id: int) -> Dict[str, Any]:
    """Get a specific order by ID."""
    url = f"{BASE_URL}/data/orders/{order_id}"
    response = requests.get(url, headers=JSON_HEADERS)
    return {"status_code": response.status_code, "data": response.json() if response.ok else None}


def create_order(order_data: Dict[str, Any]) -> Dict[str, Any]:
    """Create a new order."""
    url = f"{BASE_URL}/data/orders"
    response = requests.post(url, json=order_data, headers=JSON_HEADERS)
    return {"status_code": response.status_code, "data": response.json() if response.ok else None}


def update_order(order_id: int, order_data: Dict[str, Any]) -> Dict[str, Any]:
    """Update an existing order."""
    url = f"{BASE_URL}/data/orders/{order_id}"
    response = requests.put(url, json=order_data, headers=JSON_HEADERS)
    return {"status_code": response.status_code, "data": response.json() if response.ok else None}


def delete_order(order_id: int) -> Dict[str, Any]:
    """Delete an order."""
    url = f"{BASE_URL}/data/orders/{order_id}"
    response = requests.delete(url, headers=JSON_HEADERS)
    return {"status_code": response.status_code, "data": response.json() if response.ok else None}


def get_order_metadata() -> Dict[str, Any]:
    """Get metadata for the orders entity."""
    url = f"{BASE_URL}/meta/orders"
    response = requests.get(url, headers=JSON_HEADERS)
    return {"status_code": response.status_code, "data": response.json() if response.ok else None}


def get_all_suppliers(limit: int = 10, offset: int = 0, sort_by: str = "name") -> Dict[str, Any]:
    """Get all suppliers with optional filtering."""
    url = f"{BASE_URL}/data/suppliers"
    params = {"limit": limit, "offset": offset, "sort_by": sort_by}
    response = requests.get(url, params=params, headers=JSON_HEADERS)
    return {"status_code": response.status_code, "data": response.json() if response.ok else None}


def get_supplier_by_id(supplier_id: int) -> Dict[str, Any]:
    """Get a specific supplier by ID."""
    url = f"{BASE_URL}/data/suppliers/{supplier_id}"
    response = requests.get(url, headers=JSON_HEADERS)
    return {"status_code": response.status_code, "data": response.json() if response.ok else None}


def create_supplier(supplier_data: Dict[str, Any]) -> Dict[str, Any]:
    """Create a new supplier."""
    url = f"{BASE_URL}/data/suppliers"
    response = requests.post(url, json=supplier_data, headers=JSON_HEADERS)
    return {"status_code": response.status_code, "data": response.json() if response.ok else None}


def update_supplier(supplier_id: int, supplier_data: Dict[str, Any]) -> Dict[str, Any]:
    """Update an existing supplier."""
    url = f"{BASE_URL}/data/suppliers/{supplier_id}"
    response = requests.put(url, json=supplier_data, headers=JSON_HEADERS)
    return {"status_code": response.status_code, "data": response.json() if response.ok else None}


def delete_supplier(supplier_id: int) -> Dict[str, Any]:
    """Delete a supplier."""
    url = f"{BASE_URL}/data/suppliers/{supplier_id}"
    response = requests.delete(url, headers=JSON_HEADERS)
    return {"status_code": response.status_code, "data": response.json() if response.ok else None}


def get_supplier_metadata() -> Dict[str, Any]:
    """Get metadata for the suppliers entity."""
    url = f"{BASE_URL}/meta/suppliers"
    response = requests.get(url, headers=JSON_HEADERS)
    return {"status_code": response.status_code, "data": response.json() if response.ok else None}


def print_response(response: Dict[str, Any]) -> None:
    """Print a formatted response."""
    print(f"Status Code: {response['status_code']}")
    if response['data']:
        print("Response Data:")
        print(json.dumps(response['data'], indent=2))
    else:
        print("No data returned or request failed.")


def run_example_tests() -> None:
    """Run some example tests to demonstrate API usage."""
    print("\n=== Testing Item Endpoints ===")
    
    # Get all items
    print("\n--- Getting all items ---")
    print_response(get_all_items())
    
    # Create a new item
    print("\n--- Creating a new item ---")
    new_item = {
        "itemname": "Test Smartphone",
        "price": {
            "value": 599.99
        },
        "category": "Electronics",
        "instock": True,
        "quantity": 50
    }
    create_response = create_item(new_item)
    print_response(create_response)
    
    # If item was created successfully, get its ID for further operations
    if create_response['status_code'] == 201 and create_response['data']:
        item_id = create_response['data'].get('id') or 101  # Fallback to 101 if no ID returned
        
        # Get item by ID
        print(f"\n--- Getting item by ID {item_id} ---")
        print_response(get_item_by_id(item_id))
        
        # Update the item
        print(f"\n--- Updating item {item_id} ---")
        update_data = {
            "price": {
                "value": 549.99
            },
            "quantity": 45
        }
        print_response(update_item(item_id, update_data))
        
        # Apply discount
        print(f"\n--- Applying 10% discount to item {item_id} ---")
        print_response(apply_discount_to_item(item_id, 10.0))
        
        # Delete the item
        print(f"\n--- Deleting item {item_id} ---")
        print_response(delete_item(item_id))
    
    # Get items by category
    print("\n--- Getting items by category 'Electronics' ---")
    print_response(get_items_by_category("Electronics"))
    
    # Get item metadata
    print("\n--- Getting item metadata ---")
    print_response(get_item_metadata())


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Test the GenericServiceRefactored API")
    parser.add_argument("--base-url", help="Base URL for the API", default=BASE_URL)
    parser.add_argument("--run-examples", action="store_true", help="Run example tests")
    
    args = parser.parse_args()
    
    if args.base_url:
        BASE_URL = args.base_url
    
    if args.run_examples:
        run_example_tests()
    else:
        print("Use --run-examples to run example tests or import this module to use its functions.")
        print(f"Current base URL: {BASE_URL}")
