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
USING OpenEdge.ABLUnit.Runner.ABLRunner.
USING OpenEdge.ABLUnit.Runner.TestConfig.
USING OpenEdge.ABLUnit.Results.TestTypeResult.
USING OpenEdge.ABLUnit.Writer.ResultsXmlWriter.
USING Progress.Json.ObjectModel.JsonObject.
USING Progress.Json.ObjectModel.JsonArray.
USING Progress.Json.ObjectModel.ObjectModelParser.

/* Use existing ABL Unit configuration file */
VAR ABLRunner testRunner.
VAR CHARACTER configFile = "./src/tests/ablunit.json".
VAR CHARACTER outputFile.
VAR JsonObject configJson.
VAR TestConfig testConfig.
VAR ObjectModelParser parser.
var character resultsDir = "./results".

/* Load the existing configuration file */
parser = NEW ObjectModelParser().
configJson = CAST(parser:ParseFile(configFile), JsonObject).

/* Create test configuration and runner using existing config */
testConfig = NEW TestConfig(configJson).
testRunner = NEW ABLRunner(testConfig, "").

/* Run the tests */
testRunner:RunTests().

/* Create output directory if it doesn't exist */

FILE-INFO:FILE-NAME = resultsDir.
IF NOT FILE-INFO:FILE-TYPE BEGINS "D" THEN DO:
    OS-CREATE-DIR VALUE(resultsDir).
END.

/* The results file should be created automatically by the TestConfig */
outputFile = testConfig:GetResultsFile().

/* Display completion message */
MESSAGE 
    "ABL Unit tests completed using existing configuration." SKIP
    "Test results written to: " outputFile
    VIEW-AS ALERT-BOX.
