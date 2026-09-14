/*------------------------------------------------------------------------
    File        : ValidationPatternParams
    Purpose     : Parameter object for Validator.ValidatePattern method
    Syntax      : 
    Description : Encapsulates parameters for pattern validation to reduce parameter count
    Author(s)   : 
    Created     : Wed Aug 28 07:22:00 UTC 2025
    Notes       : Part of parameter object refactoring to reduce method complexity
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING Progress.Json.ObjectModel.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS generics.ValidationPatternParams:
    
    /* JSON object to validate */
    DEFINE PUBLIC PROPERTY JsonObject AS JsonObject NO-UNDO
        GET.
        SET.
    
    /* Field name to validate */
    DEFINE PUBLIC PROPERTY FieldName AS CHARACTER NO-UNDO
        GET.
        SET.
    
    /* Regular expression pattern */
    DEFINE PUBLIC PROPERTY Pattern AS CHARACTER NO-UNDO
        GET.
        SET.
    
    /* Error message to display if validation fails */
    DEFINE PUBLIC PROPERTY ErrorMessage AS CHARACTER NO-UNDO
        GET.
        SET.
    
    /*------------------------------------------------------------------------------
     Purpose: Creates a new instance with default values
     Notes: All properties are initialized to appropriate defaults
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC ValidationPatternParams():
        SUPER().
        
        /* Initialize with safe defaults */
        JsonObject = ?.
        FieldName = "".
        Pattern = "".
        ErrorMessage = "".
    END CONSTRUCTOR.
    
    /*------------------------------------------------------------------------------
     Purpose: Creates a new instance with all parameters
     Parameters: All the parameters needed for pattern validation
     Notes: Convenience constructor for full initialization
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC ValidationPatternParams(
        INPUT jsonObject AS JsonObject,
        INPUT fieldName AS CHARACTER,
        INPUT pattern AS CHARACTER,
        INPUT errorMessage AS CHARACTER):
        
        THIS-OBJECT().
        
        ASSIGN
            THIS-OBJECT:JsonObject = jsonObject
            THIS-OBJECT:FieldName = fieldName
            THIS-OBJECT:Pattern = pattern
            THIS-OBJECT:ErrorMessage = errorMessage.
    END CONSTRUCTOR.
    
    /*------------------------------------------------------------------------------
     Purpose: Validates that all required parameters are set
     Returns: TRUE if all required parameters are valid, FALSE otherwise
     Notes: Checks for valid JSON object and non-empty required fields
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC LOGICAL IsValid():
        RETURN (VALID-OBJECT(JsonObject) AND
                FieldName > "" AND
                Pattern > "" AND
                ErrorMessage > "").
    END METHOD.
    
END CLASS.
