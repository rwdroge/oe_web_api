/*------------------------------------------------------------------------
    File        : test-apsv-connection.p
    Purpose     : Test APSV transport connection to PASOE instances
    Description : Validates APSV transport connectivity and basic operations
    Author(s)   : 
    Created     : 
    Notes       : Run this from a client session to test AppServer connectivity
                  
    Usage:
    _progres -p test/test-apsv-connection.p -param "http://localhost:8810/pas/apsv"
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

DEFINE VARIABLE hAppServer AS HANDLE NO-UNDO.
DEFINE VARIABLE cURL AS CHARACTER NO-UNDO.
DEFINE VARIABLE lConnected AS LOGICAL NO-UNDO.
DEFINE VARIABLE cSessionModel AS CHARACTER NO-UNDO.
DEFINE VARIABLE iTestsPassed AS INTEGER NO-UNDO.
DEFINE VARIABLE iTestsFailed AS INTEGER NO-UNDO.

/* Get URL from parameter or use default */
cURL = SESSION:PARAMETER.
IF cURL = "" OR cURL = ? THEN
    cURL = "http://localhost:8810/pas/apsv".

MESSAGE "========================================" SKIP
        "APSV Transport Connection Test" SKIP
        "========================================" SKIP
        "Target URL:" cURL SKIP
        "========================================" SKIP.

/* Test 1: Session-Free Connection */
MESSAGE SKIP "Test 1: Session-Free Connection..." SKIP.

CREATE SERVER hAppServer.

lConnected = hAppServer:CONNECT(
    "-URL " + cURL + " -sessionModel session-free"
).

IF lConnected THEN DO:
    MESSAGE "✓ Session-free connection successful" SKIP.
    iTestsPassed = iTestsPassed + 1.
    
    /* Display connection info */
    MESSAGE "  - Connected: " hAppServer:CONNECTED() SKIP
            "  - Server Type: " hAppServer:TYPE SKIP.
    
    /* Disconnect */
    hAppServer:DISCONNECT().
    MESSAGE "  - Disconnected successfully" SKIP.
END.
ELSE DO:
    MESSAGE "✗ Session-free connection failed" SKIP.
    iTestsFailed = iTestsFailed + 1.
END.

/* Test 2: Session-Managed Connection */
MESSAGE SKIP "Test 2: Session-Managed Connection..." SKIP.

lConnected = hAppServer:CONNECT(
    "-URL " + cURL + " -sessionModel session-managed"
).

IF lConnected THEN DO:
    MESSAGE "✓ Session-managed connection successful" SKIP.
    iTestsPassed = iTestsPassed + 1.
    
    /* Display connection info */
    MESSAGE "  - Connected: " hAppServer:CONNECTED() SKIP
            "  - Server Type: " hAppServer:TYPE SKIP.
    
    /* Disconnect */
    hAppServer:DISCONNECT().
    MESSAGE "  - Disconnected successfully" SKIP.
END.
ELSE DO:
    MESSAGE "✗ Session-managed connection failed" SKIP.
    iTestsFailed = iTestsFailed + 1.
END.

/* Test 3: Run Remote Procedure (if available) */
MESSAGE SKIP "Test 3: Run Remote Procedure..." SKIP.

lConnected = hAppServer:CONNECT(
    "-URL " + cURL + " -sessionModel session-free"
).

IF lConnected THEN DO:
    /* Try to run a simple remote procedure */
    RUN test/remote-test-proc.p ON hAppServer NO-ERROR.
    
    IF ERROR-STATUS:ERROR THEN DO:
        MESSAGE "✗ Remote procedure execution failed" SKIP
                "  Error: " ERROR-STATUS:GET-MESSAGE(1) SKIP.
        iTestsFailed = iTestsFailed + 1.
    END.
    ELSE DO:
        MESSAGE "✓ Remote procedure executed successfully" SKIP.
        iTestsPassed = iTestsPassed + 1.
    END.
    
    hAppServer:DISCONNECT().
END.
ELSE DO:
    MESSAGE "✗ Could not connect for remote procedure test" SKIP.
    iTestsFailed = iTestsFailed + 1.
END.

/* Test 4: Connection with Timeout Settings */
MESSAGE SKIP "Test 4: Connection with Timeout Settings..." SKIP.

lConnected = hAppServer:CONNECT(
    "-URL " + cURL + 
    " -sessionModel session-free" +
    " -clientConnectTimeout 5000" +
    " -initialConnections 2" +
    " -maxConnections 10"
).

IF lConnected THEN DO:
    MESSAGE "✓ Connection with custom parameters successful" SKIP.
    iTestsPassed = iTestsPassed + 1.
    hAppServer:DISCONNECT().
END.
ELSE DO:
    MESSAGE "✗ Connection with custom parameters failed" SKIP.
    iTestsFailed = iTestsFailed + 1.
END.

/* Cleanup */
DELETE OBJECT hAppServer NO-ERROR.

/* Summary */
MESSAGE SKIP
        "========================================" SKIP
        "Test Summary" SKIP
        "========================================" SKIP
        "Tests Passed: " iTestsPassed SKIP
        "Tests Failed: " iTestsFailed SKIP
        "========================================" SKIP.

IF iTestsFailed > 0 THEN
    MESSAGE "⚠ Some tests failed. Check PASOE configuration." SKIP.
ELSE
    MESSAGE "✓ All tests passed successfully!" SKIP.

CATCH e AS Progress.Lang.Error:
    MESSAGE "Error during testing:" SKIP
            e:GetMessage(1) SKIP.
END CATCH.
