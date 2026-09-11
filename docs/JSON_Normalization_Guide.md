# JSON Response Normalization Guide

## Overview

This document describes the JSON normalization implementation that removes the proprietary ProDataSet format from API responses and handles bidirectional conversion between normalized JSON and ProDataSet format.

## Problem Statement

The API was originally returning JSON responses in ProDataSet format, which wraps actual data in a proprietary structure like:

```json
{
  "dsCustomer": {
    "ttCustomer": [
      {"id": 1, "name": "John Doe", "email": "john@example.com"}
    ]
  }
}
```

This format is not user-friendly and requires clients to understand the proprietary ProDataSet structure.

## Solution

Implemented bidirectional normalization in `BaseService.cls` to:

1. **Outbound**: Convert ProDataSet responses to clean JSON objects/arrays
2. **Inbound**: Convert normalized JSON input to ProDataSet format for backend compatibility

## Implementation Details

### Outbound Normalization (API Responses)

#### Methods Added to BaseService.cls

**1. NormalizeSingleEntityResponse()**
- **Purpose**: Extracts single entity data from ProDataSet wrapper
- **Input**: JsonObject with ProDataSet format
- **Output**: Clean JsonObject with entity properties
- **Usage**: Applied to GetById(), Create(), Update() methods

**2. NormalizeMultipleEntityResponse()**
- **Purpose**: Handles multiple entity responses
- **Input**: JsonObject with ProDataSet format containing array
- **Output**: 
  - Single object if only one result
  - `{data: [...], count: n}` structure for multiple results
- **Usage**: Applied to GetByFilter() method

#### Response Format Examples

**Before (ProDataSet format):**
```json
{
  "dsCustomer": {
    "ttCustomer": [
      {"id": 1, "name": "John Doe", "email": "john@example.com"}
    ]
  }
}
```

**After (Normalized format):**
```json
// Single entity
{"id": 1, "name": "John Doe", "email": "john@example.com"}

// Multiple entities
{
  "data": [
    {"id": 1, "name": "John Doe", "email": "john@example.com"},
    {"id": 2, "name": "Jane Smith", "email": "jane@example.com"}
  ],
  "count": 2
}
```

### Inbound Normalization (User Input)

#### Method Added to BaseService.cls

**ConvertToProDataSetFormat()**
- **Purpose**: Converts normalized JSON to ProDataSet format for repository layer
- **Input**: JsonObject with normalized entity data
- **Output**: JsonObject in ProDataSet format expected by repository
- **Usage**: Applied in Create() and Update() methods before calling repository

#### Conversion Example

**User Input (Normalized):**
```json
{"name": "John Doe", "email": "john@example.com"}
```

**Converted to ProDataSet format:**
```json
{
  "dsCustomer": {
    "ttCustomer": [
      {"name": "John Doe", "email": "john@example.com"}
    ]
  }
}
```

## Data Flow

### Create/Update Operations
1. User sends normalized JSON → API receives clean object
2. `ConvertToProDataSetFormat()` → Wraps in ProDataSet structure
3. Repository processes ProDataSet format → Database operations
4. Repository returns ProDataSet format → Service layer
5. `NormalizeSingleEntityResponse()` → Extracts clean object
6. User receives normalized JSON response

### Read Operations
1. Repository returns ProDataSet format → Service layer
2. `NormalizeSingleEntityResponse()` or `NormalizeMultipleEntityResponse()` → Extracts clean data
3. User receives normalized JSON response

## Methods Modified

### BaseService.cls

**GetById():**
- Added call to `NormalizeSingleEntityResponse()` after reading from repository
- Returns clean single entity object

**GetByFilter():**
- Added call to `NormalizeMultipleEntityResponse()` after reading from repository
- Returns single object or array with count metadata

**Create():**
- Added call to `ConvertToProDataSetFormat()` before calling repository
- Added call to `NormalizeSingleEntityResponse()` after repository returns data
- Added cleanup for temporary ProDataSet format object

**Update():**
- Added call to `ConvertToProDataSetFormat()` before calling repository
- Added call to `NormalizeSingleEntityResponse()` after repository returns data
- Added cleanup for temporary ProDataSet format object

## Memory Management

All normalization methods include proper cleanup in finally blocks to prevent memory leaks:

- ProDataSet format objects are deleted after use
- Temporary JSON objects and arrays are properly disposed
- Dataset handles are cleaned up appropriately

## Error Handling

- Error responses remain unchanged and are not normalized
- Validation errors continue to use the existing error format
- Repository-level errors are passed through without modification

## Backward Compatibility

- The normalization is transparent to existing repository and data access layers
- Database operations remain unchanged
- Only the service layer JSON handling is modified

## Testing Considerations

When testing the API:

1. **Create/Update Operations**: Send normalized JSON objects
2. **Read Operations**: Expect clean JSON responses
3. **Error Cases**: Verify error responses are still properly formatted
4. **Multiple Results**: Verify array responses include count metadata

## Maintenance Notes

- The entity name is derived from `this-object:EntityName` property
- ProDataSet structure follows pattern: `ds{EntityName}` containing `tt{EntityName}` table
- All normalization methods are protected and can be overridden in derived services if needed
- Memory cleanup is critical - always ensure temporary objects are deleted in finally blocks

## Future Enhancements

Potential improvements:
- Caching of ProDataSet structure for performance
- Configuration options for response format preferences
- Support for nested entity relationships
- Bulk operation normalization for better performance
