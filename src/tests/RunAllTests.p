/*------------------------------------------------------------------------
    File        : RunAllTests.p
    Purpose     : Run all ABL unit tests
    Syntax      : 
    Description : Executes all ABL unit tests and generates test results
    Author(s)   : Generated
    Created     : 2025-06-18
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING OpenEdge.Core.Assert.
USING Progress.ABLUnit.TestRunner.
USING Progress.ABLUnit.TestSuite.
USING Progress.ABLUnit.TestResult.
USING Progress.ABLUnit.ResultFormats.XML.XMLResultWriter.

DEFINE INPUT PARAMETER pTestResultsDir AS CHARACTER NO-UNDO.

DEFINE VARIABLE testRunner AS TestRunner NO-UNDO.
DEFINE VARIABLE testSuite AS TestSuite NO-UNDO.
DEFINE VARIABLE testResult AS TestResult NO-UNDO.
DEFINE VARIABLE resultWriter AS XMLResultWriter NO-UNDO. 
DEFINE VARIABLE outputFile AS CHARACTER NO-UNDO.

/* Create test suite and add all test classes */
testSuite = NEW TestSuite("OE Web API Tests").
testSuite:AddTest(NEW tests.CustomersTest()).
testSuite:AddTest(NEW tests.DataAccessTest()).
testSuite:AddTest(NEW tests.EmailValidatorTest()).
testSuite:AddTest(NEW tests.ItemsTest()).
testSuite:AddTest(NEW tests.OrderValidationTest()).
testSuite:AddTest(NEW tests.OrdersTest()).
testSuite:AddTest(NEW tests.SuppliersTest()).

/* Create test runner */
testRunner = NEW TestRunner().

/* Run the tests */
testResult = testRunner:Run(testSuite).

/* Create output directory if it doesn't exist */
IF pTestResultsDir = "" OR pTestResultsDir = ? THEN
    pTestResultsDir = "./test-results".

FILE-INFO:FILE-NAME = pTestResultsDir.
IF NOT FILE-INFO:FILE-TYPE BEGINS "D" THEN DO:
    OS-CREATE-DIR VALUE(pTestResultsDir).
END.

/* Write test results to XML file */
outputFile = pTestResultsDir + "/test-results.xml".
resultWriter = NEW XMLResultWriter(outputFile).
resultWriter:Write(testResult).

/* Display test summary */
MESSAGE 
    "Tests run: " testResult:RunCount SKIP
    "Failures: " testResult:FailureCount SKIP
    "Errors: " testResult:ErrorCount SKIP
    "Test results written to: " outputFile
    VIEW-AS ALERT-BOX.

/* Exit with failure code if any tests failed */
IF testResult:ErrorCount > 0 OR testResult:FailureCount > 0 THEN DO:
    QUIT 1.
END.
ELSE DO:
    QUIT 0.
END.
