/*------------------------------------------------------------------------
    File        : ValidatorTest
    Purpose     : Unit tests for Validator class
    Syntax      : 
    Description : Tests the validation functionality
    Author(s)   : 
    Created     : Tue Jul 08 10:55:12 UTC 2025
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING OpenEdge.Core.Assert.
USING core.Validator.
USING Progress.Json.ObjectModel.JsonObject.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS tests.core.ValidatorTest:
    
    DEFINE PRIVATE VARIABLE validator AS core.Validator NO-UNDO.
    DEFINE PRIVATE VARIABLE testData AS JsonObject NO-UNDO.
    
    /*------------------------------------------------------------------------------
     Purpose: Set up test environment before each test
     Notes:   
    ------------------------------------------------------------------------------*/
    @Setup.
    METHOD PUBLIC VOID SetUp():
        validator = NEW core.Validator().
        
        /* Create test data */
        testData = NEW JsonObject().
        testData:Add("stringField", "Test String").
        testData:Add("numericField", 123).
        testData:Add("logicalField", TRUE).
        testData:Add("dateField", TODAY).
        testData:Add("emptyString", "").
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose: Test IsRequired validation
     Notes:   
    ------------------------------------------------------------------------------*/
    @Test.
    METHOD PUBLIC VOID TestIsRequired():
        /* Test with field that exists */
        DEFINE VARIABLE result AS JsonObject NO-UNDO.
        result = validator:IsRequired(testData, "stringField").
        
        Assert:NotNull(result, "Validation result should not be null").
        Assert:IsTrue(result:GetLogical("valid"), "Validation should pass for field that exists").
        
        /* Test with field that exists but is empty */
        result = validator:IsRequired(testData, "emptyString").
        
        Assert:NotNull(result, "Validation result should not be null").
        Assert:IsFalse(result:GetLogical("valid"), "Validation should fail for empty field").
        Assert:IsTrue(result:Has("message"), "Validation result should have error message").
        
        /* Test with field that doesn't exist */
        result = validator:IsRequired(testData, "nonExistentField").
        
        Assert:NotNull(result, "Validation result should not be null").
        Assert:IsFalse(result:GetLogical("valid"), "Validation should fail for non-existent field").
        Assert:IsTrue(result:Has("message"), "Validation result should have error message").
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose: Test IsNumeric validation
     Notes:   
    ------------------------------------------------------------------------------*/
    @Test.
    METHOD PUBLIC VOID TestIsNumeric():
        /* Test with numeric field */
        DEFINE VARIABLE result AS JsonObject NO-UNDO.
        result = validator:IsNumeric(testData, "numericField").
        
        Assert:NotNull(result, "Validation result should not be null").
        Assert:IsTrue(result:GetLogical("valid"), "Validation should pass for numeric field").
        
        /* Test with non-numeric field */
        result = validator:IsNumeric(testData, "stringField").
        
        Assert:NotNull(result, "Validation result should not be null").
        Assert:IsFalse(result:GetLogical("valid"), "Validation should fail for non-numeric field").
        Assert:IsTrue(result:Has("message"), "Validation result should have error message").
        
        /* Test with field that doesn't exist */
        result = validator:IsNumeric(testData, "nonExistentField").
        
        Assert:NotNull(result, "Validation result should not be null").
        Assert:IsFalse(result:GetLogical("valid"), "Validation should fail for non-existent field").
        Assert:IsTrue(result:Has("message"), "Validation result should have error message").
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose: Test IsLogical validation
     Notes:   
    ------------------------------------------------------------------------------*/
    @Test.
    METHOD PUBLIC VOID TestIsLogical():
        /* Test with logical field */
        DEFINE VARIABLE result AS JsonObject NO-UNDO.
        result = validator:IsLogical(testData, "logicalField").
        
        Assert:NotNull(result, "Validation result should not be null").
        Assert:IsTrue(result:GetLogical("valid"), "Validation should pass for logical field").
        
        /* Test with non-logical field */
        result = validator:IsLogical(testData, "stringField").
        
        Assert:NotNull(result, "Validation result should not be null").
        Assert:IsFalse(result:GetLogical("valid"), "Validation should fail for non-logical field").
        Assert:IsTrue(result:Has("message"), "Validation result should have error message").
        
        /* Test with field that doesn't exist */
        result = validator:IsLogical(testData, "nonExistentField").
        
        Assert:NotNull(result, "Validation result should not be null").
        Assert:IsFalse(result:GetLogical("valid"), "Validation should fail for non-existent field").
        Assert:IsTrue(result:Has("message"), "Validation result should have error message").
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose: Test IsDate validation
     Notes:   
    ------------------------------------------------------------------------------*/
    @Test.
    METHOD PUBLIC VOID TestIsDate():
        /* Test with date field */
        DEFINE VARIABLE result AS JsonObject NO-UNDO.
        result = validator:IsDate(testData, "dateField").
        
        Assert:NotNull(result, "Validation result should not be null").
        Assert:IsTrue(result:GetLogical("valid"), "Validation should pass for date field").
        
        /* Test with non-date field */
        result = validator:IsDate(testData, "stringField").
        
        Assert:NotNull(result, "Validation result should not be null").
        Assert:IsFalse(result:GetLogical("valid"), "Validation should fail for non-date field").
        Assert:IsTrue(result:Has("message"), "Validation result should have error message").
        
        /* Test with field that doesn't exist */
        result = validator:IsDate(testData, "nonExistentField").
        
        Assert:NotNull(result, "Validation result should not be null").
        Assert:IsFalse(result:GetLogical("valid"), "Validation should fail for non-existent field").
        Assert:IsTrue(result:Has("message"), "Validation result should have error message").    
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose: Test MinLength validation
     Notes:   
    ------------------------------------------------------------------------------*/
    @Test.
    METHOD PUBLIC VOID TestMinLength():
        /* Test with string that meets minimum length */
        DEFINE VARIABLE result AS JsonObject NO-UNDO.
        result = validator:MinLength(testData, "stringField", 5).
        
        Assert:NotNull(result, "Validation result should not be null").
        Assert:IsTrue(result:GetLogical("valid"), "Validation should pass for string that meets minimum length").
        
        /* Test with string that doesn't meet minimum length */
        result = validator:MinLength(testData, "stringField", 20).
        
        Assert:NotNull(result, "Validation result should not be null").
        Assert:IsFalse(result:GetLogical("valid"), "Validation should fail for string that doesn't meet minimum length").
        Assert:IsTrue(result:Has("message"), "Validation result should have error message").
        
        /* Test with field that doesn't exist */
        result = validator:MinLength(testData, "nonExistentField", 5).
        
        Assert:NotNull(result, "Validation result should not be null").
        Assert:IsFalse(result:GetLogical("valid"), "Validation should fail for non-existent field").
        Assert:IsTrue(result:Has("message"), "Validation result should have error message").
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose: Test MaxLength validation
     Notes:   
    ------------------------------------------------------------------------------*/
    @Test.
    METHOD PUBLIC VOID TestMaxLength():
        /* Test with string that meets maximum length */
        DEFINE VARIABLE result AS JsonObject NO-UNDO.
        result = validator:MaxLength(testData, "stringField", 20).
        
        Assert:NotNull(result, "Validation result should not be null").
        Assert:IsTrue(result:GetLogical("valid"), "Validation should pass for string that meets maximum length").
        
        /* Test with string that exceeds maximum length */
        result = validator:MaxLength(testData, "stringField", 5).
        
        Assert:NotNull(result, "Validation result should not be null").
        Assert:IsFalse(result:GetLogical("valid"), "Validation should fail for string that exceeds maximum length").
        Assert:IsTrue(result:Has("message"), "Validation result should have error message").
        
        /* Test with field that doesn't exist */
        result = validator:MaxLength(testData, "nonExistentField", 20).
        
        Assert:NotNull(result, "Validation result should not be null").
        Assert:IsFalse(result:GetLogical("valid"), "Validation should fail for non-existent field").
        Assert:IsTrue(result:Has("message"), "Validation result should have error message").
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose: Clean up after tests
     Notes:   
    ------------------------------------------------------------------------------*/
    @TearDown.
    METHOD PUBLIC VOID TearDown():
        /* Nothing to clean up */
    END METHOD.
    
END CLASS.
