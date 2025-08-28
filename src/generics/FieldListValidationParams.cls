/*------------------------------------------------------------------------
    File        : FieldListValidationParams
    Purpose     : Parameter object for MetadataService.checkFieldList method
    Syntax      : 
    Description : Encapsulates parameters for field list validation to reduce parameter count
    Author(s)   : 
    Created     : Wed Aug 28 07:26:00 UTC 2025
    Notes       : Part of parameter object refactoring to reduce method complexity
  ----------------------------------------------------------------------*/

using Progress.Lang.*.

block-level on error undo, throw.

class generics.FieldListValidationParams:
    
    /* Handle to the temp-table to validate against */
    define public property hTempTableHandle as handle no-undo
        get.
        set.
    
    /* Comma-separated list of fields to check */
    define public property cFieldList as character no-undo
        get.
        set.
    
    /* Output: Comma-separated list of invalid fields */
    define public property InvalidFields as character no-undo
        get.
        set.
    
    /* Output: Logical indicating if all fields are valid */
    define public property IsValid as logical no-undo
        get.
        set.
    
    /*------------------------------------------------------------------------------
     Purpose: Creates a new instance with default values
     Notes: All properties are initialized to appropriate defaults
    ------------------------------------------------------------------------------*/
    constructor public FieldListValidationParams():
        super().
        
        /* Initialize with safe defaults */
        hTempTableHandle = ?.
        cFieldList = "".
        InvalidFields = "".
        IsValid = false.
    end constructor.
    
    /*------------------------------------------------------------------------------
     Purpose: Creates a new instance with input parameters
     Parameters: Input parameters needed for field list validation
     Notes: Convenience constructor for initialization with input parameters
    ------------------------------------------------------------------------------*/
    constructor public FieldListValidationParams(
        input tempTableHandle as handle,
        input fieldList as character):
        
        this-object().
        
        assign
            this-object:hTempTableHandle = tempTableHandle
            this-object:cFieldList = fieldList.
    end constructor.
    
    /*------------------------------------------------------------------------------
     Purpose: Validates that all required input parameters are set
     Returns: TRUE if all required input parameters are valid, FALSE otherwise
     Notes: Checks for valid temp-table handle and non-empty field list
    ------------------------------------------------------------------------------*/
    method public logical HasValidInputs():
        return (valid-handle(hTempTableHandle) and
                cFieldList > "").
    end method.
    
end class.
