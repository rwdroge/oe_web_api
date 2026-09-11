/*------------------------------------------------------------------------
    File        : CrudErrorParams
    Purpose     : Parameter object for CRUD error handling
    Syntax      : 
    Description : Encapsulates error parameters to reduce method complexity
    Author(s)   : Cascade AI
    Created     : Wed Nov 27 09:30:00 UTC 2025
    Notes       : Part of parameter object refactoring to reduce Unit Interfacing
  ----------------------------------------------------------------------*/

using Progress.Lang.*.

block-level on error undo, throw.

class generics.CrudErrorParams:
    
    /* Error message text */
    define public property ErrorMessage as character no-undo get. set.
    
    /* Entity name (optional) */
    define public property EntityName as character no-undo get. set.
    
    /* Entity ID (optional) */
    define public property Id as character no-undo get. set.
    
    /* Error details from exception */
    define public property ErrorDetails as character no-undo get. set.
    
    /*------------------------------------------------------------------------------
     Purpose: Creates a new instance with default values
     Notes: All properties are initialized to empty strings
    ------------------------------------------------------------------------------*/
    constructor public CrudErrorParams():
        super().
        
        /* Initialize with safe defaults */
        ErrorMessage = "".
        EntityName = "".
        Id = "".
        ErrorDetails = "".
    end constructor.
    
    /*------------------------------------------------------------------------------
     Purpose: Creates a new instance with error message
     Parameters:
       input errorMessage - The error message
     Notes: Convenience constructor for basic errors
    ------------------------------------------------------------------------------*/
    constructor public CrudErrorParams(input errorMessage as character):
        this-object().
        this-object:ErrorMessage = errorMessage.
    end constructor.
    
end class.
