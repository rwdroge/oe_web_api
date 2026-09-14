# OpenTelemetry to MongoDB Persistence Service Specification

## Overview
This document specifies the requirements for a separate service that reads OpenTelemetry data from JSON files and persists it to MongoDB.

## Data Format

### File Format: OTLP/JSON (JSON Lines)
The OpenTelemetry Collector exports data in **OTLP/JSON format** using the file exporter with `format: json`.

**Format Details:**
- **File Extension**: `.jsonl` (JSON Lines)
- **Structure**: One complete OTLP object per line
- **Encoding**: UTF-8
- **Protocol**: OTLP (OpenTelemetry Protocol) serialized as JSON

### File Locations

| Signal Type | File Path | Description |
|-------------|-----------|-------------|
| Traces | `/var/log/otel/traces.jsonl` | OTLP ResourceSpans objects |
| Metrics | `/var/log/otel/metrics.jsonl` | OTLP ResourceMetrics objects |
| Logs | `/var/log/otel/logs.jsonl` | OTLP ResourceLogs objects |

## OTLP/JSON Structure

### Traces Format (OTLP ResourceSpans)
```json
{
  "resourceSpans": [
    {
      "resource": {
        "attributes": [
          {
            "key": "service.name",
            "value": {
              "stringValue": "oe-web-api-pasoe"
            }
          },
          {
            "key": "service.instance.id",
            "value": {
              "stringValue": "pasoe-instance-1"
            }
          }
        ]
      },
      "scopeSpans": [
        {
          "scope": {
            "name": "openedge-instrumentation",
            "version": "1.0.0"
          },
          "spans": [
            {
              "traceId": "5b8aa5a2d2c872e8321cf37308d69df2",
              "spanId": "051581bf3cb55c13",
              "parentSpanId": "5fb397be34d26b51",
              "name": "GET /web/api/data/customers",
              "kind": "SPAN_KIND_SERVER",
              "startTimeUnixNano": "1606240000000000000",
              "endTimeUnixNano": "1606240000100000000",
              "attributes": [
                {
                  "key": "http.method",
                  "value": {
                    "stringValue": "GET"
                  }
                },
                {
                  "key": "http.url",
                  "value": {
                    "stringValue": "/web/api/data/customers"
                  }
                },
                {
                  "key": "http.status_code",
                  "value": {
                    "intValue": "200"
                  }
                }
              ],
              "status": {
                "code": "STATUS_CODE_OK"
              }
            }
          ]
        }
      ]
    }
  ]
}
```

### Metrics Format (OTLP ResourceMetrics)
```json
{
  "resourceMetrics": [
    {
      "resource": {
        "attributes": [
          {
            "key": "service.name",
            "value": {
              "stringValue": "oe-web-api-pasoe"
            }
          }
        ]
      },
      "scopeMetrics": [
        {
          "scope": {
            "name": "openedge-instrumentation"
          },
          "metrics": [
            {
              "name": "openedge.pasoe.requests.total",
              "description": "Total number of requests",
              "unit": "1",
              "sum": {
                "dataPoints": [
                  {
                    "attributes": [
                      {
                        "key": "http.method",
                        "value": {
                          "stringValue": "GET"
                        }
                      }
                    ],
                    "startTimeUnixNano": "1606240000000000000",
                    "timeUnixNano": "1606240060000000000",
                    "asInt": "42"
                  }
                ],
                "aggregationTemporality": "AGGREGATION_TEMPORALITY_CUMULATIVE",
                "isMonotonic": true
              }
            }
          ]
        }
      ]
    }
  ]
}
```

### Logs Format (OTLP ResourceLogs)
```json
{
  "resourceLogs": [
    {
      "resource": {
        "attributes": [
          {
            "key": "service.name",
            "value": {
              "stringValue": "oe-web-api-pasoe"
            }
          }
        ]
      },
      "scopeLogs": [
        {
          "scope": {
            "name": "openedge-instrumentation"
          },
          "logRecords": [
            {
              "timeUnixNano": "1606240000000000000",
              "severityNumber": "SEVERITY_NUMBER_INFO",
              "severityText": "INFO",
              "body": {
                "stringValue": "Request processed successfully"
              },
              "attributes": [
                {
                  "key": "http.method",
                  "value": {
                    "stringValue": "GET"
                  }
                }
              ],
              "traceId": "5b8aa5a2d2c872e8321cf37308d69df2",
              "spanId": "051581bf3cb55c13"
            }
          ]
        }
      ]
    }
  ]
}
```

## Service Requirements

### 1. File Monitoring
The service MUST:
- Monitor the three OTLP JSON files for new data
- Use incremental reading (track file position/offset)
- Handle file rotation gracefully
- Process new data in near real-time (< 10 seconds latency)

### 2. Data Parsing
The service MUST:
- Parse JSON Lines format (one OTLP object per line)
- Validate OTLP/JSON structure
- Handle malformed JSON gracefully (skip and log errors)
- Extract key identifiers (traceId, spanId, metric names, etc.)

### 3. MongoDB Persistence

#### Collections
```
Database: openedge_telemetry

Collections:
  - traces      (for OTLP ResourceSpans)
  - metrics     (for OTLP ResourceMetrics)
  - logs        (for OTLP ResourceLogs)
```

#### Document Structure

**Traces Collection:**
```json
{
  "_id": "5b8aa5a2d2c872e8321cf37308d69df2-051581bf3cb55c13",
  "traceId": "5b8aa5a2d2c872e8321cf37308d69df2",
  "spanId": "051581bf3cb55c13",
  "parentSpanId": "5fb397be34d26b51",
  "serviceName": "oe-web-api-pasoe",
  "serviceInstanceId": "pasoe-instance-1",
  "name": "GET /web/api/data/customers",
  "kind": "SPAN_KIND_SERVER",
  "startTime": ISODate("2024-11-26T07:00:00.000Z"),
  "endTime": ISODate("2024-11-26T07:00:00.100Z"),
  "duration": 100000000,
  "attributes": {
    "http.method": "GET",
    "http.url": "/web/api/data/customers",
    "http.status_code": 200
  },
  "status": {
    "code": "STATUS_CODE_OK"
  },
  "events": [],
  "links": [],
  "resource": { /* full resource attributes */ },
  "rawOtlp": { /* original OTLP span object */ },
  "ingestedAt": ISODate("2024-11-26T07:00:01.000Z")
}
```

**Metrics Collection:**
```json
{
  "_id": "openedge.pasoe.requests.total-1732604400000",
  "metricName": "openedge.pasoe.requests.total",
  "serviceName": "oe-web-api-pasoe",
  "serviceInstanceId": "pasoe-instance-1",
  "description": "Total number of requests",
  "unit": "1",
  "type": "sum",
  "value": 42,
  "attributes": {
    "http.method": "GET"
  },
  "timestamp": ISODate("2024-11-26T07:01:00.000Z"),
  "resource": { /* full resource attributes */ },
  "rawOtlp": { /* original OTLP metric object */ },
  "ingestedAt": ISODate("2024-11-26T07:01:01.000Z")
}
```

**Logs Collection:**
```json
{
  "_id": ObjectId(),
  "traceId": "5b8aa5a2d2c872e8321cf37308d69df2",
  "spanId": "051581bf3cb55c13",
  "serviceName": "oe-web-api-pasoe",
  "serviceInstanceId": "pasoe-instance-1",
  "timestamp": ISODate("2024-11-26T07:00:00.000Z"),
  "severity": "INFO",
  "severityNumber": 9,
  "body": "Request processed successfully",
  "attributes": {
    "http.method": "GET"
  },
  "resource": { /* full resource attributes */ },
  "rawOtlp": { /* original OTLP log record */ },
  "ingestedAt": ISODate("2024-11-26T07:00:01.000Z")
}
```

### 4. Persistence Operations

**Create/Update/Append Logic:**

**For Traces:**
- **Primary Key**: `traceId + spanId`
- **Operation**: UPSERT (insert if not exists, update if exists)
- **Update Strategy**: Replace entire document (spans are immutable)

**For Metrics:**
- **Primary Key**: `metricName + timestamp + attribute hash`
- **Operation**: UPSERT
- **Update Strategy**: 
  - For cumulative metrics: UPDATE value
  - For delta metrics: APPEND to time series array

**For Logs:**
- **Primary Key**: Auto-generated ObjectId
- **Operation**: INSERT (logs are append-only)
- **Update Strategy**: N/A (no updates)

### 5. Indexes

**Traces Collection:**
```javascript
db.traces.createIndex({ "traceId": 1 })
db.traces.createIndex({ "serviceName": 1, "startTime": -1 })
db.traces.createIndex({ "name": 1, "startTime": -1 })
db.traces.createIndex({ "attributes.http.status_code": 1 })
db.traces.createIndex({ "duration": -1 })
db.traces.createIndex({ "ingestedAt": -1 })
```

**Metrics Collection:**
```javascript
db.metrics.createIndex({ "metricName": 1, "timestamp": -1 })
db.metrics.createIndex({ "serviceName": 1, "timestamp": -1 })
db.metrics.createIndex({ "ingestedAt": -1 })
```

**Logs Collection:**
```javascript
db.logs.createIndex({ "traceId": 1 })
db.logs.createIndex({ "serviceName": 1, "timestamp": -1 })
db.logs.createIndex({ "severity": 1, "timestamp": -1 })
db.logs.createIndex({ "ingestedAt": -1 })
```

### 6. Error Handling
The service MUST:
- Log all errors with context
- Continue processing on individual record errors
- Implement retry logic for MongoDB connection failures
- Expose health check endpoint
- Track and report statistics (records processed, errors, etc.)

### 7. Performance Requirements
- **Throughput**: Handle at least 1000 records/second
- **Latency**: Process new data within 10 seconds
- **Memory**: Efficient streaming (don't load entire files)
- **CPU**: Minimal overhead (< 5% CPU usage)

## Service API

### Health Check
```
GET /health
Response: 200 OK
{
  "status": "healthy",
  "tracesProcessed": 12345,
  "metricsProcessed": 6789,
  "logsProcessed": 4567,
  "errorCount": 3,
  "lastProcessedTime": "2024-11-26T07:00:00Z",
  "mongoConnected": true
}
```

### Statistics
```
GET /stats
Response: 200 OK
{
  "uptime": 3600,
  "tracesProcessed": 12345,
  "metricsProcessed": 6789,
  "logsProcessed": 4567,
  "errorCount": 3,
  "processingRate": {
    "traces": 3.4,
    "metrics": 1.9,
    "logs": 1.3
  },
  "lastProcessedTime": "2024-11-26T07:00:00Z"
}
```

## Configuration

### Environment Variables
```bash
# MongoDB Configuration
MONGO_HOST=localhost
MONGO_PORT=27017
MONGO_DATABASE=openedge_telemetry
MONGO_USERNAME=otel_user
MONGO_PASSWORD=secret

# File Paths
OTEL_TRACES_FILE=/var/log/otel/traces.jsonl
OTEL_METRICS_FILE=/var/log/otel/metrics.jsonl
OTEL_LOGS_FILE=/var/log/otel/logs.jsonl

# Service Configuration
POLL_INTERVAL=5000          # milliseconds
BATCH_SIZE=100              # records per batch
MAX_RETRIES=3
RETRY_DELAY=1000            # milliseconds

# Logging
LOG_LEVEL=INFO
LOG_FILE=/var/log/otel-mongo-service.log
```

## Deployment

### As Part of AI Agent
The service should:
1. Start automatically when AI agent starts
2. Run in background/daemon mode
3. Restart on failure
4. Gracefully shutdown on agent stop

### Docker Deployment (Alternative)
```yaml
version: '3.8'
services:
  otel-mongo-service:
    image: otel-mongo-persistence:latest
    environment:
      - MONGO_HOST=mongodb
      - MONGO_PORT=27017
      - MONGO_DATABASE=openedge_telemetry
    volumes:
      - /var/log/otel:/var/log/otel:ro
    depends_on:
      - mongodb
    restart: unless-stopped
```

## Testing

### Test Data
Sample OTLP/JSON files are provided in:
- `test/fixtures/sample-traces.jsonl`
- `test/fixtures/sample-metrics.jsonl`
- `test/fixtures/sample-logs.jsonl`

### Verification
```bash
# Check MongoDB collections
mongo openedge_telemetry --eval "db.traces.count()"
mongo openedge_telemetry --eval "db.metrics.count()"
mongo openedge_telemetry --eval "db.logs.count()"

# Query recent traces
mongo openedge_telemetry --eval "db.traces.find().sort({ingestedAt:-1}).limit(5).pretty()"

# Check service health
curl http://localhost:8080/health
```

## References

- **OTLP Specification**: https://opentelemetry.io/docs/specs/otlp/
- **OTLP/JSON Encoding**: https://opentelemetry.io/docs/specs/otlp/#json-protobuf-encoding
- **OpenTelemetry Collector File Exporter**: https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/exporter/fileexporter
- **MongoDB Node.js Driver**: https://mongodb.github.io/node-mongodb-native/

## Implementation Notes

### Recommended Tech Stack
- **Language**: Node.js, Python, or Go
- **MongoDB Driver**: Official driver for chosen language
- **JSON Parsing**: Native JSON parser
- **File Watching**: `chokidar` (Node.js), `watchdog` (Python), `fsnotify` (Go)

### Sample Implementation (Node.js)
```javascript
const fs = require('fs');
const readline = require('readline');
const { MongoClient } = require('mongodb');

class OtelMongoService {
  constructor() {
    this.mongoClient = new MongoClient(process.env.MONGO_HOST);
    this.db = null;
    this.filePositions = {
      traces: 0,
      metrics: 0,
      logs: 0
    };
  }

  async start() {
    await this.mongoClient.connect();
    this.db = this.mongoClient.db(process.env.MONGO_DATABASE);
    
    setInterval(() => this.processFiles(), 5000);
  }

  async processFiles() {
    await this.processFile('traces', '/var/log/otel/traces.jsonl');
    await this.processFile('metrics', '/var/log/otel/metrics.jsonl');
    await this.processFile('logs', '/var/log/otel/logs.jsonl');
  }

  async processFile(type, filePath) {
    const stream = fs.createReadStream(filePath, {
      start: this.filePositions[type],
      encoding: 'utf8'
    });

    const rl = readline.createInterface({ input: stream });

    for await (const line of rl) {
      if (line.trim()) {
        await this.persistRecord(type, JSON.parse(line));
      }
    }

    this.filePositions[type] = fs.statSync(filePath).size;
  }

  async persistRecord(type, otlpData) {
    // Transform OTLP to MongoDB document
    const doc = this.transformOtlp(type, otlpData);
    
    // Upsert to MongoDB
    await this.db.collection(type).updateOne(
      { _id: doc._id },
      { $set: doc },
      { upsert: true }
    );
  }
}
```
