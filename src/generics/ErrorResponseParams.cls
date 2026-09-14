/*------------------------------------------------------------------------
   File        : ErrorResponseParams
   Purpose     : Parameter object for error response creation
   Syntax      : class ErrorResponseParams
   Description : Encapsulates parameters commonly used for creating error responses
   Author(s)   : Cascade AI
   Created     : 2025-08-26
   Notes       : Reduces parameter count in error response methods
 ----------------------------------------------------------------------*/

using Progress.Lang.*.

block-level on error undo, throw.

class generics.ErrorResponseParams:
    
    /* Core error information */
    define public property StatusCode as integer no-undo get. set.
    define public property ErrorMessage as character no-undo get. set.
    define public property Details as character no-undo get. set.
    
    /* Context information */
    define public property EntityName as character no-undo get. set.
    define public property ResourceName as character no-undo get. set.
    define public property MethodName as character no-undo get. set.
    define public property Id as character no-undo get. set.
    
    constructor public ErrorResponseParams():
        super().
        /* Initialize with default values */
        assign
            StatusCode = 500
            ErrorMessage = ""
            Details = ""
            EntityName = ""
            ResourceName = ""
            MethodName = ""
            Id = "".
    end constructor.
    
    constructor public ErrorResponseParams(input pcErrorMessage as character):
        this-object().
        assign ErrorMessage = pcErrorMessage.
    end constructor.
    
    constructor public ErrorResponseParams(input piStatusCode as integer, input pcErrorMessage as character):
        this-object(pcErrorMessage).
        assign StatusCode = piStatusCode.
    end constructor.
    
    /* Convenience method to set entity context */
    method public void SetEntityContext(input pcEntityName as character, input pcId as character):
        assign
            EntityName = pcEntityName
            Id = pcId.
    end method.
    
    /* Convenience method to set resource context */
    method public void SetResourceContext(input pcResourceName as character, input pcMethodName as character):
        assign
            ResourceName = pcResourceName
            MethodName = pcMethodName.
    end method.
    
    /* Check if entity context is provided */
    method public logical HasEntityContext():
        return (EntityName > "").
    end method.
    
    /* Check if resource context is provided */
    method public logical HasResourceContext():
        return (ResourceName > "").
    end method.
    
    /* Check if details are provided */
    method public logical HasDetails():
        return (Details > "").
    end method.
    
    /* Check if ID is provided */
    method public logical HasId():
        return (Id > "").
    end method.

end class.
