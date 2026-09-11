/*------------------------------------------------------------------------
    File        : ValueListValidationParams
    Purpose     : Parameter object for MetadataService.checkValueList method
    Syntax      : 
    Description : Encapsulates parameters for value list validation to reduce parameter count
    Author(s)   : 
    Created     : Wed Aug 28 08:41:00 UTC 2025
    Notes       : Part of parameter object refactoring to reduce method complexity
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS generics.ValueListValidationParams:
    
    /* Handle to the temp-table to validate against */
    DEFINE PUBLIC PROPERTY TempTableHandle AS HANDLE NO-UNDO
        GET.
        SET.
    
    /* Handle to the query parameters table */
    DEFINE PUBLIC PROPERTY QueryParamsHandle AS HANDLE NO-UNDO
        GET.
        SET.
    
    /* Output: Comma-separated list of invalid field/value pairs */
    DEFINE PUBLIC PROPERTY InvalidPairs AS CHARACTER NO-UNDO
        GET.
        SET.
    
    /* Output: Logical indicating if all values are valid */
    DEFINE PUBLIC PROPERTY IsValid AS LOGICAL NO-UNDO
        GET.
        SET.
    
    /*------------------------------------------------------------------------------
     Purpose: Creates a new instance with default values
     Notes: All properties are initialized to appropriate defaults
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC ValueListValidationParams():
        SUPER().
        
        /* Initialize with safe defaults */
        TempTableHandle = ?.
        QueryParamsHandle = ?.
        InvalidPairs = "".
        IsValid = FALSE.
    END CONSTRUCTOR.
    
    /*------------------------------------------------------------------------------
     Purpose: Creates a new instance with input parameters
     Parameters: Input parameters needed for value list validation
     Notes: Convenience constructor for initialization with input parameters
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC ValueListValidationParams(
        INPUT tempTableHandle AS HANDLE,
        INPUT queryParamsHandle AS HANDLE):
        
        THIS-OBJECT().
        
        ASSIGN
            THIS-OBJECT:TempTableHandle = tempTableHandle
            THIS-OBJECT:QueryParamsHandle = queryParamsHandle.
    END CONSTRUCTOR.
    
    /*------------------------------------------------------------------------------
     Purpose: Validates that all required input parameters are set
     Returns: TRUE if all required input parameters are valid, FALSE otherwise
     Notes: Checks for valid temp-table and query params handles
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC LOGICAL HasValidInputs():
        RETURN (VALID-HANDLE(TempTableHandle) AND
                VALID-HANDLE(QueryParamsHandle)).
    END METHOD.
    
END CLASS.
