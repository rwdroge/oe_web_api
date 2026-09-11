/*------------------------------------------------------------------------
    File        : EmailValidatorTest
    Purpose     : Unit tests for EmailValidator class
    Syntax      : 
    Description : ABLUnit test cases for email validation functionality
    Author(s)   : 
    Created     : 2025-05-21
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using OpenEdge.Core.Assert.
using data.EmailValidator.

block-level on error undo, throw.

class tests.validations.EmailValidatorTest:

    /* Test fixtures */
    var private EmailValidator emailValidator.
    
    /*------------------------------------------------------------------------------
     Purpose: Set up test environment before each test
     Notes: Creates fresh instance of EmailValidator
    ------------------------------------------------------------------------------*/
    @Setup.
    method public void setUp():
        /* Create fresh instance for each test */
        emailValidator = new EmailValidator().
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Clean up test environment after each test
     Notes: Releases resources used in tests
    ------------------------------------------------------------------------------*/
    @TearDown.
    method public void tearDown():
        /* Clean up resources */
        if valid-object(emailValidator) then
            delete object emailValidator.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Test valid email addresses
     Notes: Verifies that valid email addresses return 0
    ------------------------------------------------------------------------------*/
    @Test.
    method public void testValidEmails():
        /* Test variables */
        var integer iResult.
        
        /* Test simple valid email */
        iResult = emailValidator:ValidateEmail("user@example.com").
        Assert:IsTrue(iResult = 0, "Result should be 0").
        
        /* Test valid email with subdomain */
        iResult = emailValidator:ValidateEmail("user@subdomain.example.com").
        Assert:IsTrue(iResult = 0, "Result should be 0").
        
        /* Test valid email with plus addressing */
        iResult = emailValidator:ValidateEmail("user+tag@example.com").
        Assert:IsTrue(iResult = 0, "Result should be 0").
        
        /* Test valid email with numbers */
        iResult = emailValidator:ValidateEmail("user123@example123.com").
        Assert:IsTrue(iResult = 0, "Result should be 0").
        
        /* Test valid email with hyphens and underscores */
        iResult = emailValidator:ValidateEmail("user-name_123@example-domain.com").
        Assert:IsTrue(iResult = 0, "Result should be 0").
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Test empty or unknown email
     Notes: Verifies error code 1 is returned for empty or unknown emails
    ------------------------------------------------------------------------------*/
    @Test.
    method public void testEmptyEmail():
        /* Test variables */
        var integer iResult.
        
        /* Test empty string */
        iResult = emailValidator:ValidateEmail("").
        Assert:IsTrue(iResult = 1, "Result should be 1").
        
        /* Test unknown value */
        iResult = emailValidator:ValidateEmail(?).
        Assert:IsTrue(iResult = 1, "Result should be 1").
        
        /* Test whitespace only */
        iResult = emailValidator:ValidateEmail("   ").
        Assert:IsTrue(iResult = 1, "Result should be 1").
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Test email without @ character
     Notes: Verifies error code 2 is returned for emails without @ character
    ------------------------------------------------------------------------------*/
    @Test.
    method public void testNoAtSymbol():
        /* Test variables */
        var integer iResult.
        
        /* Test email without @ */
        iResult = emailValidator:ValidateEmail("userexample.com").
        Assert:IsTrue(iResult = 2, "Result should be 2").
        
        /* Test email with period instead of @ */
        iResult = emailValidator:ValidateEmail("user.example.com").
        Assert:IsTrue(iResult = 2, "Result should be 2").
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Test email with multiple @ characters
     Notes: Verifies error code 3 is returned for emails with multiple @ characters
    ------------------------------------------------------------------------------*/
    @Test.
    method public void testMultipleAtSymbols():
        /* Test variables */
        var integer iResult.
        
        /* Test email with two @ symbols */
        iResult = emailValidator:ValidateEmail("user@domain@example.com").
        Assert:IsTrue(iResult = 3, "Result should be 3").
        
        /* Test email with three @ symbols */
        iResult = emailValidator:ValidateEmail("user@sub@domain@example.com").
        Assert:IsTrue(iResult = 3, "Result should be 3").
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Test email without local part
     Notes: Verifies error code 4 is returned for emails without local part
    ------------------------------------------------------------------------------*/
    @Test.
    method public void testNoLocalPart():
        /* Test variables */
        var integer iResult.
        
        /* Test email with @ at beginning */
        iResult = emailValidator:ValidateEmail("@example.com").
        Assert:IsTrue(iResult = 4, "Result should be 4").
        
        /* Test email with empty local part */
        iResult = emailValidator:ValidateEmail(" @example.com").
        Assert:IsTrue(iResult = 4, "Result should be 4").
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Test email without domain part
     Notes: Verifies error code 5 is returned for emails without domain part
    ------------------------------------------------------------------------------*/
    @Test.
    method public void testNoDomainPart():
        /* Test variables */
        var integer iResult.
        
        /* Test email with @ at end */
        iResult = emailValidator:ValidateEmail("user@").
        Assert:IsTrue(iResult = 5, "Result should be 5").
        
        /* Test email with empty domain part */
        iResult = emailValidator:ValidateEmail("user@ ").
        Assert:IsTrue(iResult = 5, "Result should be 5").
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Test boundary cases
     Notes: Verifies handling of edge cases
    ------------------------------------------------------------------------------*/
    @Test.
    method public void testBoundaryCases():
        /* Test variables */
        var integer iResult.
        
        /* Test very long email */
        iResult = emailValidator:ValidateEmail("verylongusername1234567890" + 
                                             "1234567890@verylongdomain" + 
                                             "1234567890.com").
        Assert:IsTrue(iResult = 0, "Result should be 0").
        
        /* Test email with special characters in local part */
        iResult = emailValidator:ValidateEmail("user.name+tag-123@example.com").
        Assert:IsTrue(iResult = 0, "Result should be 0").
    end method.

end class.
