# APSV Transport Testing

## Overview
This directory contains test procedures for validating APSV (AppServer Direct) transport connectivity and functionality for the GenericService application.

## Test Files

### Connection Tests
- **test-apsv-connection.p** - Tests basic APSV connectivity
  - Session-free connections
  - Session-managed connections
  - Remote procedure execution
  - Connection timeout settings

### Data Access Tests
- **test-apsv-data-access.p** - Tests database access via APSV
  - Customer count retrieval
  - Customer record retrieval
  - Transaction handling

### Remote Procedures
- **remote-test-proc.p** - Simple remote procedure for connectivity testing
- **remote-get-customer-count.p** - Returns total customer count
- **remote-get-customer.p** - Returns customer by ID
- **remote-test-transaction.p** - Tests transaction commit/rollback

### Test Suite
- **run-all-apsv-tests.p** - Master test runner for complete test suite

## Running Tests

### Prerequisites
1. Sports2020 database must be running
2. At least one PASOE instance must be running
3. APSV adapter must be enabled in openedge.properties

### Individual Test Execution

#### Test Connection to Instance 1
```bash
_progres -p test/test-apsv-connection.p -param "http://localhost:8810/pas/apsv"
```

#### Test Connection to Instance 2
```bash
_progres -p test/test-apsv-connection.p -param "http://localhost:8820/pas/apsv"
```

#### Test Data Access
```bash
_progres -p test/test-apsv-data-access.p -param "http://localhost:8810/pas/apsv"
```

### Complete Test Suite
```bash
_progres -p test/run-all-apsv-tests.p -param "http://localhost:8810/pas/apsv"
```

## Test Results

### Expected Output
```
========================================
APSV Transport Test Suite
========================================
Instance 1 URL: http://localhost:8810/pas/apsv
Instance 2 URL: http://localhost:8820/pas/apsv
========================================

Testing PASOE Instance 1...
========================================
✓ Session-free connection successful
✓ Session-managed connection successful
✓ Remote procedure executed successfully
✓ Connection with custom parameters successful

Test Summary
========================================
Tests Passed: 4
Tests Failed: 0
========================================
✓ All tests passed successfully!

✓✓✓ ALL TESTS PASSED! ✓✓✓
Both PASOE instances are ready for production.
```

## Troubleshooting

### Connection Failures
**Error**: "Session-free connection failed"

**Possible Causes**:
1. PASOE instance not running
2. APSV adapter not enabled
3. Incorrect URL
4. Firewall blocking connection

**Solutions**:
```bash
# Check PASOE status
cd /opt/oe_web_api/pas1/bin
./tcman status

# Verify APSV adapter is enabled in openedge.properties
[pas.ROOT.APSV]
    adapterEnabled=1

# Check logs
tail -f /opt/oe_web_api/pas1/logs/pas1.agent.log
```

### Database Access Failures
**Error**: "Failed to get customer count"

**Possible Causes**:
1. Database not connected
2. Database not running
3. Incorrect database connection parameters in as.pf

**Solutions**:
```bash
# Check database status
proshut sports2020 -C list

# Verify as.pf contains correct connection
cat /opt/oe_web_api/conf/as.pf
# Should contain: -db sports2020 -S 10000 -H <db-host>

# Test database connection manually
_progres -db sports2020 -H <db-host> -S 10000 -1
```

### Remote Procedure Errors
**Error**: "Remote procedure execution failed"

**Possible Causes**:
1. Procedure not in PROPATH
2. Syntax errors in procedure
3. Missing database connection

**Solutions**:
```bash
# Verify PROPATH in openedge.properties includes test directory
[AppServer.Agent.pas]
    PROPATH=.,/opt/oe_web_api/conf,/opt/oe_web_api/src,/opt/oe_web_api/test,...

# Check agent logs for specific errors
tail -f /opt/oe_web_api/pas1/logs/pas1.agent.log
```

## Integration with CI/CD

### Automated Testing
Add to your deployment pipeline:

```bash
#!/bin/bash
# test-deployment.sh

echo "Running APSV transport tests..."

$DLC/bin/_progres -p test/run-all-apsv-tests.p \
    -param "http://localhost:8810/pas/apsv" \
    > test-results.log 2>&1

if grep -q "ALL TESTS PASSED" test-results.log; then
    echo "✓ All APSV tests passed"
    exit 0
else
    echo "✗ Some APSV tests failed"
    cat test-results.log
    exit 1
fi
```

### Jenkins Integration
```groovy
stage('APSV Transport Tests') {
    steps {
        sh '''
            $DLC/bin/_progres -p test/run-all-apsv-tests.p \
                -param "http://localhost:8810/pas/apsv"
        '''
    }
}
```

## Performance Testing

### Load Testing APSV Connections
Create multiple concurrent connections:

```abl
/* test-apsv-load.p */
DEFINE VARIABLE i AS INTEGER NO-UNDO.
DEFINE VARIABLE hAppServer AS HANDLE EXTENT 10 NO-UNDO.

DO i = 1 TO 10:
    CREATE SERVER hAppServer[i].
    hAppServer[i]:CONNECT("-URL http://localhost:8810/pas/apsv -sessionModel session-free").
END.

/* Run concurrent operations */
DO i = 1 TO 10:
    RUN test/remote-get-customer-count.p ON hAppServer[i] ASYNCHRONOUS.
END.

/* Cleanup */
DO i = 1 TO 10:
    hAppServer[i]:DISCONNECT().
    DELETE OBJECT hAppServer[i].
END.
```

## Best Practices

1. **Always test both transports**: Test both APSV and WEB transports
2. **Test both instances**: Verify both PASOE instances work correctly
3. **Test under load**: Simulate production load conditions
4. **Monitor logs**: Watch agent logs during testing
5. **Automate tests**: Include in CI/CD pipeline
6. **Document failures**: Keep log of any issues encountered

## Additional Resources

- [OpenEdge Documentation - APSV Transport](https://docs.progress.com/)
- [PASOE Configuration Guide](../docs/PRODUCTION_DEPLOYMENT.md)
- [Troubleshooting Guide](../docs/TROUBLESHOOTING.md)
