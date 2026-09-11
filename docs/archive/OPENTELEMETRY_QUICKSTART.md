# OpenTelemetry Quick Start Guide

## 🚀 Quick Setup (5 Minutes)

### 1. Start OpenTelemetry Stack
```bash
cd /opt/oe_web_api
chmod +x scripts/start-observability.sh
./scripts/start-observability.sh
```

This starts:
- ✅ OpenTelemetry Collector (ports 4317, 4318)
- ✅ Jaeger (port 16686)
- ✅ Prometheus (port 9090)
- ✅ Grafana (port 3000)

### 2. Configure PASOE Instances

The configuration files are already created:
- `conf/otelconfig.json` - PASOE Instance 1
- `conf/otelconfig-pas2.json` - PASOE Instance 2
- `conf/otelconfig-db.json` - Database

**Verify openedge.properties references the config:**

```bash
# Check Instance 1
grep otelConfigFile conf/openedge-pas1.properties

# Check Instance 2
grep otelConfigFile conf/openedge-pas2.properties
```

Should show:
```
otelConfigFile=${catalina.base}/conf/otelconfig.json
```

### 3. Deploy Configs to PASOE

```bash
# Copy to Instance 1
cp conf/otelconfig.json /opt/oe_web_api/pas1/conf/

# Copy to Instance 2
cp conf/otelconfig-pas2.json /opt/oe_web_api/pas2/conf/otelconfig.json
```

### 4. Restart PASOE Instances

```bash
# Restart Instance 1
cd /opt/oe_web_api/pas1/bin && ./tcman restart

# Restart Instance 2
cd /opt/oe_web_api/pas2/bin && ./tcman restart
```

### 5. Generate Some Traffic

```bash
# Make some API calls
curl http://localhost:8810/web/api/data/customers
curl http://localhost:8810/web/api/meta/customers
curl http://localhost:8820/web/api/data/customers
```

### 6. View Traces and Metrics

**Jaeger (Traces):**
1. Open http://localhost:16686
2. Select Service: `oe-web-api-pasoe`
3. Click "Find Traces"
4. Click on a trace to see details

**Prometheus (Metrics):**
1. Open http://localhost:9090
2. Try queries:
   - `openedge_pasoe_requests_total`
   - `openedge_pasoe_agents_active`
   - `rate(openedge_pasoe_requests_total[5m])`

**Grafana (Dashboards):**
1. Open http://localhost:3000
2. Login: admin/admin
3. Add Prometheus data source (http://prometheus:9090)
4. Add Jaeger data source (http://jaeger:16686)
5. Create dashboards

## 📊 What You'll See

### Traces in Jaeger
```
Trace: GET /web/api/data/customers
├─ HTTP Request (200ms)
│  ├─ GenericService.HandleGet (150ms)
│  │  ├─ Database Query (100ms)
│  │  └─ JSON Serialization (20ms)
│  └─ Response (30ms)
```

### Metrics in Prometheus
- Request count by endpoint
- Response times (p50, p95, p99)
- Error rates
- Active agents/sessions
- Database connection pool stats

## 🔧 Configuration Files

| File | Purpose | Location |
|------|---------|----------|
| `otelconfig.json` | PASOE Instance 1 config | `conf/` |
| `otelconfig-pas2.json` | PASOE Instance 2 config | `conf/` |
| `otelconfig-db.json` | Database config | `conf/` |
| `otel-collector-config.yaml` | Collector config | `conf/` |
| `prometheus.yml` | Prometheus config | `conf/` |

## 🎯 Key Endpoints

| Service | URL | Purpose |
|---------|-----|---------|
| Jaeger UI | http://localhost:16686 | View traces |
| Prometheus | http://localhost:9090 | Query metrics |
| Grafana | http://localhost:3000 | Dashboards |
| OTel Collector (gRPC) | localhost:4317 | Send telemetry |
| OTel Collector (HTTP) | localhost:4318 | Send telemetry |
| Health Check | http://localhost:13133 | Collector health |

## 🔍 Useful Queries

### Prometheus Queries

**Request Rate:**
```promql
rate(openedge_pasoe_requests_total[5m])
```

**Average Response Time:**
```promql
rate(openedge_pasoe_request_duration_sum[5m]) / 
rate(openedge_pasoe_request_duration_count[5m])
```

**Error Rate:**
```promql
rate(openedge_pasoe_errors_total[5m])
```

**95th Percentile Response Time:**
```promql
histogram_quantile(0.95, 
  rate(openedge_pasoe_request_duration_bucket[5m]))
```

### Jaeger Queries

**Find slow requests:**
- Operation: `GET /web/api/data/customers`
- Min Duration: `100ms`

**Find errors:**
- Tags: `error=true`
- Tags: `http.status_code=500`

**Find specific customer:**
- Tags: `customer.id=123`

## 🐛 Troubleshooting

### No traces appearing?

**1. Check collector is running:**
```bash
curl http://localhost:13133
```

**2. Check PASOE logs:**
```bash
tail -f /opt/oe_web_api/pas1/logs/pas1.agent.log | grep -i otel
```

**3. Test collector endpoint:**
```bash
# Test gRPC
telnet localhost 4317

# Test HTTP
curl -v http://localhost:4318/v1/traces
```

### Collector not starting?

**Check Docker logs:**
```bash
docker logs otel-collector
```

**Common issues:**
- Port 4317/4318 already in use
- Invalid YAML syntax in config
- Insufficient memory

### High memory usage?

**Reduce batch sizes in otelconfig.json:**
```json
"batch_processor_options": {
    "max_queue_size": 512,
    "max_export_batch_size": 128
}
```

## 📈 Production Tips

### 1. Adjust Sampling
For high-traffic production, reduce sampling:

```json
"sampler": {
    "type": "traceidratio",
    "probability": 0.1
}
```

### 2. Enable TLS
Update collector endpoint:
```json
"endpoint": "https://collector.yourdomain.com:4317"
```

### 3. Add Authentication
Add headers to exporter:
```json
"headers": {
    "Authorization": "Bearer YOUR_TOKEN"
}
```

### 4. Monitor Collector
- Watch memory usage
- Check queue sizes
- Monitor export failures

## 📚 Next Steps

1. **Create Grafana Dashboards**
   - Import pre-built dashboards
   - Create custom visualizations
   - Set up alerts

2. **Configure Alerts**
   - High error rates
   - Slow response times
   - Agent pool exhaustion

3. **Optimize Sampling**
   - Adjust based on traffic
   - Use different rates per endpoint
   - Implement head-based sampling

4. **Add Custom Spans**
   - Instrument critical code paths
   - Add business metrics
   - Track custom events

## 🔗 Resources

- **Full Documentation**: `docs/OPENTELEMETRY_SETUP.md`
- **OpenTelemetry Docs**: https://opentelemetry.io/docs/
- **Jaeger Docs**: https://www.jaegertracing.io/docs/
- **Prometheus Docs**: https://prometheus.io/docs/

## 🆘 Getting Help

**Check logs:**
```bash
# Collector logs
docker logs otel-collector

# PASOE logs
tail -f /opt/oe_web_api/pas1/logs/pas1.agent.log

# All observability logs
docker-compose -f docker-compose-observability.yaml logs -f
```

**Stop everything:**
```bash
docker-compose -f docker-compose-observability.yaml down
```

**Restart everything:**
```bash
docker-compose -f docker-compose-observability.yaml restart
```
