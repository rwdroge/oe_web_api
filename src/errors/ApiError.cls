/*------------------------------------------------------------------------
    File        : ApiError
    Purpose     : Custom error class for API errors
    Syntax      : 
    Description : Represents API-specific errors with HTTP status codes
    Author(s)   : Cascade AI
    Created     : 2025-06-24
    Notes       : Custom error class for standardized error handling
  ----------------------------------------------------------------------*/

using Progress.Lang.*.

block-level on error undo, throw.

class errors.ApiError inherits Progress.Lang.AppError:
    
    /* HTTP status code */
    define public property StatusCode as integer no-undo get. set.
    
    /* Error category */
    define public property Category as character no-undo get. set.
    
    /* Entity name */
    define public property EntityName as character no-undo get. set.
    
    /* Entity ID */
    define public property EntityId as character no-undo get. set.
    
    /* Additional details */
    define public property Details as character no-undo get. set.
    
    /*------------------------------------------------------------------------------
     Purpose: Constructor for ApiError
     Parameters:
       input pcMessage - Error message
     Notes: Creates error with default status code 500
    ------------------------------------------------------------------------------*/
    constructor public ApiError(input pcMessage as character):
        super(pcMessage).
        this-object:StatusCode = 500.
    end constructor.
    
    /*------------------------------------------------------------------------------
     Purpose: Constructor for ApiError with status code
     Parameters:
       input pcMessage - Error message
       input piStatusCode - HTTP status code
     Notes: Creates error with specified status code
    ------------------------------------------------------------------------------*/
    constructor public ApiError(
        input pcMessage as character,
        input piStatusCode as integer):
        
        super(pcMessage).
        this-object:StatusCode = piStatusCode.
    end constructor.
    
    /*------------------------------------------------------------------------------
     Purpose: Constructor for ApiError with all properties
     Parameters:
       input pcMessage - Error message
       input piStatusCode - HTTP status code
       input pcCategory - Error category
       input pcEntityName - Entity name
       input pcEntityId - Entity ID
       input pcDetails - Additional details
     Notes: Creates error with all properties
    ------------------------------------------------------------------------------*/
    constructor public ApiError(
        input pcMessage as character,
        input piStatusCode as integer,
        input pcCategory as character,
        input pcEntityName as character,
        input pcEntityId as character,
        input pcDetails as character):
        
        super(pcMessage).
        assign
            this-object:StatusCode = piStatusCode
            this-object:Category = pcCategory
            this-object:EntityName = pcEntityName
            this-object:EntityId = pcEntityId
            this-object:Details = pcDetails.
    end constructor.
    
    /*------------------------------------------------------------------------------
     Purpose: Convert error to JSON object
     Returns: JsonObject containing error details
     Notes: Useful for API responses
    ------------------------------------------------------------------------------*/
    method public Progress.Json.ObjectModel.JsonObject ToJson():
        var Progress.Json.ObjectModel.JsonObject joError = new Progress.Json.ObjectModel.JsonObject().
        
        /* Add basic error information */
        joError:Add("error", this-object:GetMessage(1)).
        joError:Add("statusCode", this-object:StatusCode).
        
        /* Add optional properties if present */
        if this-object:Category > "" then
            joError:Add("category", this-object:Category).
            
        if this-object:EntityName > "" then
            joError:Add("entity", this-object:EntityName).
            
        if this-object:EntityId > "" then
            joError:Add("id", this-object:EntityId).
            
        if this-object:Details > "" then
            joError:Add("details", this-object:Details).
            
        return joError.
    end method.
    
end class.
