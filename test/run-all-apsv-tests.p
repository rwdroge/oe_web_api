/*------------------------------------------------------------------------
    File        : run-all-apsv-tests.p
    Purpose     : Run all APSV transport tests
    Description : Master test runner for APSV connectivity and data access
    Author(s)   : 
    Created     : 
    Notes       : Run this to execute complete APSV test suite
                  
    Usage:
    _progres -p test/run-all-apsv-tests.p -param "http://localhost:8810/pas/apsv"
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

DEFINE VARIABLE cURL AS CHARACTER NO-UNDO.
DEFINE VARIABLE cInstance2URL AS CHARACTER NO-UNDO.
DEFINE VARIABLE iTotalPassed AS INTEGER NO-UNDO.
DEFINE VARIABLE iTotalFailed AS INTEGER NO-UNDO.

/* Get URL from parameter or use default */
cURL = SESSION:PARAMETER.
IF cURL = "" OR cURL = ? THEN
    cURL = "http://localhost:8810/pas/apsv".

/* Derive second instance URL */
cInstance2URL = REPLACE(cURL, "8810", "8820").

MESSAGE "========================================" SKIP
        "APSV Transport Test Suite" SKIP
        "========================================" SKIP
        "Instance 1 URL:" cURL SKIP
        "Instance 2 URL:" cInstance2URL SKIP
        "========================================" SKIP SKIP.

/* Test Instance 1 */
MESSAGE "Testing PASOE Instance 1..." SKIP
        "========================================" SKIP.

RUN test/test-apsv-connection.p PERSISTENT SET THIS-PROCEDURE
    (INPUT cURL) NO-ERROR.

IF ERROR-STATUS:ERROR THEN DO:
    MESSAGE "✗ Instance 1 connection tests failed" SKIP.
    iTotalFailed = iTotalFailed + 1.
END.
ELSE DO:
    MESSAGE "✓ Instance 1 connection tests passed" SKIP.
    iTotalPassed = iTotalPassed + 1.
END.

MESSAGE SKIP.

RUN test/test-apsv-data-access.p PERSISTENT SET THIS-PROCEDURE
    (INPUT cURL) NO-ERROR.

IF ERROR-STATUS:ERROR THEN DO:
    MESSAGE "✗ Instance 1 data access tests failed" SKIP.
    iTotalFailed = iTotalFailed + 1.
END.
ELSE DO:
    MESSAGE "✓ Instance 1 data access tests passed" SKIP.
    iTotalPassed = iTotalPassed + 1.
END.

MESSAGE SKIP SKIP.

/* Test Instance 2 */
MESSAGE "Testing PASOE Instance 2..." SKIP
        "========================================" SKIP.

RUN test/test-apsv-connection.p PERSISTENT SET THIS-PROCEDURE
    (INPUT cInstance2URL) NO-ERROR.

IF ERROR-STATUS:ERROR THEN DO:
    MESSAGE "✗ Instance 2 connection tests failed" SKIP.
    iTotalFailed = iTotalFailed + 1.
END.
ELSE DO:
    MESSAGE "✓ Instance 2 connection tests passed" SKIP.
    iTotalPassed = iTotalPassed + 1.
END.

MESSAGE SKIP.

RUN test/test-apsv-data-access.p PERSISTENT SET THIS-PROCEDURE
    (INPUT cInstance2URL) NO-ERROR.

IF ERROR-STATUS:ERROR THEN DO:
    MESSAGE "✗ Instance 2 data access tests failed" SKIP.
    iTotalFailed = iTotalFailed + 1.
END.
ELSE DO:
    MESSAGE "✓ Instance 2 data access tests passed" SKIP.
    iTotalPassed = iTotalPassed + 1.
END.

/* Final Summary */
MESSAGE SKIP SKIP
        "========================================" SKIP
        "COMPLETE TEST SUITE SUMMARY" SKIP
        "========================================" SKIP
        "Total Test Suites Passed: " iTotalPassed SKIP
        "Total Test Suites Failed: " iTotalFailed SKIP
        "========================================" SKIP.

IF iTotalFailed = 0 THEN
    MESSAGE "✓✓✓ ALL TESTS PASSED! ✓✓✓" SKIP
            "Both PASOE instances are ready for production." SKIP.
ELSE
    MESSAGE "⚠⚠⚠ SOME TESTS FAILED ⚠⚠⚠" SKIP
            "Review logs and fix issues before production deployment." SKIP.

CATCH e AS Progress.Lang.Error:
    MESSAGE "Error during test suite execution:" SKIP
            e:GetMessage(1) SKIP.
END CATCH.
