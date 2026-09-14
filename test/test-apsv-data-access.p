/*------------------------------------------------------------------------
    File        : test-apsv-data-access.p
    Purpose     : Test APSV transport with database access
    Description : Tests remote procedure calls that access the Sports2020 database
    Author(s)   : 
    Created     : 
    Notes       : Run this from a client session to test AppServer data access
                  
    Usage:
    _progres -p test/test-apsv-data-access.p -param "http://localhost:8810/pas/apsv"
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

DEFINE VARIABLE hAppServer AS HANDLE NO-UNDO.
DEFINE VARIABLE cURL AS CHARACTER NO-UNDO.
DEFINE VARIABLE lConnected AS LOGICAL NO-UNDO.
DEFINE VARIABLE iTestsPassed AS INTEGER NO-UNDO.
DEFINE VARIABLE iTestsFailed AS INTEGER NO-UNDO.
DEFINE VARIABLE iCustomerCount AS INTEGER NO-UNDO.
DEFINE VARIABLE cCustomerName AS CHARACTER NO-UNDO.

/* Get URL from parameter or use default */
cURL = SESSION:PARAMETER.
IF cURL = "" OR cURL = ? THEN
    cURL = "http://localhost:8810/pas/apsv".

MESSAGE "========================================" SKIP
        "APSV Data Access Test" SKIP
        "========================================" SKIP
        "Target URL:" cURL SKIP
        "========================================" SKIP.

CREATE SERVER hAppServer.

lConnected = hAppServer:CONNECT(
    "-URL " + cURL + " -sessionModel session-free"
).

IF NOT lConnected THEN DO:
    MESSAGE "✗ Failed to connect to AppServer" SKIP.
    RETURN.
END.

MESSAGE "✓ Connected to AppServer" SKIP SKIP.

/* Test 1: Get Customer Count */
MESSAGE "Test 1: Get Customer Count..." SKIP.

RUN test/remote-get-customer-count.p ON hAppServer 
    (OUTPUT iCustomerCount) NO-ERROR.

IF ERROR-STATUS:ERROR THEN DO:
    MESSAGE "✗ Failed to get customer count" SKIP
            "  Error: " ERROR-STATUS:GET-MESSAGE(1) SKIP.
    iTestsFailed = iTestsFailed + 1.
END.
ELSE DO:
    MESSAGE "✓ Customer count retrieved: " iCustomerCount SKIP.
    iTestsPassed = iTestsPassed + 1.
END.

/* Test 2: Get Customer by ID */
MESSAGE SKIP "Test 2: Get Customer by ID..." SKIP.

RUN test/remote-get-customer.p ON hAppServer 
    (INPUT 1, OUTPUT cCustomerName) NO-ERROR.

IF ERROR-STATUS:ERROR THEN DO:
    MESSAGE "✗ Failed to get customer" SKIP
            "  Error: " ERROR-STATUS:GET-MESSAGE(1) SKIP.
    iTestsFailed = iTestsFailed + 1.
END.
ELSE DO:
    MESSAGE "✓ Customer retrieved: " cCustomerName SKIP.
    iTestsPassed = iTestsPassed + 1.
END.

/* Test 3: Test Database Transaction */
MESSAGE SKIP "Test 3: Test Database Transaction..." SKIP.

RUN test/remote-test-transaction.p ON hAppServer NO-ERROR.

IF ERROR-STATUS:ERROR THEN DO:
    MESSAGE "✗ Transaction test failed" SKIP
            "  Error: " ERROR-STATUS:GET-MESSAGE(1) SKIP.
    iTestsFailed = iTestsFailed + 1.
END.
ELSE DO:
    MESSAGE "✓ Transaction test completed successfully" SKIP.
    iTestsPassed = iTestsPassed + 1.
END.

/* Cleanup */
hAppServer:DISCONNECT().
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
    MESSAGE "⚠ Some tests failed. Check AppServer database connectivity." SKIP.
ELSE
    MESSAGE "✓ All data access tests passed!" SKIP.

CATCH e AS Progress.Lang.Error:
    MESSAGE "Error during testing:" SKIP
            e:GetMessage(1) SKIP.
END CATCH.
