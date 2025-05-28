/*------------------------------------------------------------------------
  File        : EmailValidator
  Purpose     : Validate email addresses.
  Syntax      : 
  Description : 
  Author(s)   : Chris Skeldon 
  Created     : 
  Notes       : 
  ----------------------------------------------------------------------*/

  BLOCK-LEVEL ON ERROR UNDO, THROW.


  CLASS data.EmailValidator: 
  
  
    /*------------------------------------------------------------------------------
      Purpose: Validates email addresses.
      Notes:
      @param pcEmail The email address to validate.
      @return 0 if the address is valid and a positive integer if it is not. The
              integer will identify the reason why it is invalid. <br/>
              <br/>
              Return error codes: <br/>
              <br/>  
              1 - unknown or empty string passed in <br/>
              2 - no @ character in email <br/>
              3 - more than 1 @ in email <br/>
              4 - no local part of email (string to the left of @) <br/>
              5 - no domain part of email (string to the right of @) <br/>
              
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC INTEGER ValidateEmail( INPUT pcEmail AS CHARACTER ):
      
      DEFINE VARIABLE iResult AS INTEGER NO-UNDO.
  
  
  
      RETURN iResult.
  
    END METHOD.
  
  END CLASS.