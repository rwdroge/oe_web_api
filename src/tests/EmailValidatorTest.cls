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

class tests.EmailValidatorTest:

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
        Assert:Equals(0, iResult).
        
        /* Test valid email with subdomain */
        iResult = emailValidator:ValidateEmail("user@subdomain.example.com").
        Assert:Equals(0, iResult).
        
        /* Test valid email with plus addressing */
        iResult = emailValidator:ValidateEmail("user+tag@example.com").
        Assert:Equals(0, iResult).
        
        /* Test valid email with numbers */
        iResult = emailValidator:ValidateEmail("user123@example123.com").
        Assert:Equals(0, iResult).
        
        /* Test valid email with hyphens and underscores */
        iResult = emailValidator:ValidateEmail("user-name_123@example-domain.com").
        Assert:Equals(0, iResult).
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
        Assert:Equals(1, iResult).
        
        /* Test unknown value */
        iResult = emailValidator:ValidateEmail(?).
        Assert:Equals(1, iResult).
        
        /* Test whitespace only */
        iResult = emailValidator:ValidateEmail("   ").
        Assert:Equals(1, iResult).
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
        Assert:Equals(2, iResult).
        
        /* Test email with period instead of @ */
        iResult = emailValidator:ValidateEmail("user.example.com").
        Assert:Equals(2, iResult).
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
        Assert:Equals(3, iResult).
        
        /* Test email with three @ symbols */
        iResult = emailValidator:ValidateEmail("user@sub@domain@example.com").
        Assert:Equals(3, iResult).
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
        Assert:Equals(4, iResult).
        
        /* Test email with empty local part */
        iResult = emailValidator:ValidateEmail(" @example.com").
        Assert:Equals(4, iResult).
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
        Assert:Equals(5, iResult).
        
        /* Test email with empty domain part */
        iResult = emailValidator:ValidateEmail("user@ ").
        Assert:Equals(5, iResult).
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
        Assert:Equals(0, iResult).
        
        /* Test email with special characters in local part */
        iResult = emailValidator:ValidateEmail("user.name+tag-123@example.com").
        Assert:Equals(0, iResult).
    end method.

end class.
