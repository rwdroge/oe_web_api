/*------------------------------------------------------------------------
    File        : ValidationRangeParams
    Purpose     : Parameter object for Validator.ValidateRange method
    Syntax      : 
    Description : Encapsulates parameters for range validation to reduce parameter count
    Author(s)   : 
    Created     : Wed Aug 28 07:22:00 UTC 2025
    Notes       : Part of parameter object refactoring to reduce method complexity
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING Progress.Json.ObjectModel.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS generics.ValidationRangeParams:
    
    /* JSON object to validate */
    DEFINE PUBLIC PROPERTY JsonObject AS JsonObject NO-UNDO
        GET.
        SET.
    
    /* Field name to validate */
    DEFINE PUBLIC PROPERTY FieldName AS CHARACTER NO-UNDO
        GET.
        SET.
    
    /* Minimum allowed value */
    DEFINE PUBLIC PROPERTY MinValue AS DECIMAL NO-UNDO
        GET.
        SET.
    
    /* Maximum allowed value */
    DEFINE PUBLIC PROPERTY MaxValue AS DECIMAL NO-UNDO
        GET.
        SET.
    
    /*------------------------------------------------------------------------------
     Purpose: Creates a new instance with default values
     Notes: All properties are initialized to appropriate defaults
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC ValidationRangeParams():
        SUPER().
        
        /* Initialize with safe defaults */
        JsonObject = ?.
        FieldName = "".
        MinValue = 0.
        MaxValue = 0.
    END CONSTRUCTOR.
    
    /*------------------------------------------------------------------------------
     Purpose: Creates a new instance with all parameters
     Parameters: All the parameters needed for range validation
     Notes: Convenience constructor for full initialization
    ------------------------------------------------------------------------------*/
    CONSTRUCTOR PUBLIC ValidationRangeParams(
        INPUT jsonObject AS JsonObject,
        INPUT fieldName AS CHARACTER,
        INPUT minValue AS DECIMAL,
        INPUT maxValue AS DECIMAL):
        
        THIS-OBJECT().
        
        ASSIGN
            THIS-OBJECT:JsonObject = jsonObject
            THIS-OBJECT:FieldName = fieldName
            THIS-OBJECT:MinValue = minValue
            THIS-OBJECT:MaxValue = maxValue.
    END CONSTRUCTOR.
    
    /*------------------------------------------------------------------------------
     Purpose: Validates that all required parameters are set
     Returns: TRUE if all required parameters are valid, FALSE otherwise
     Notes: Checks for valid JSON object and non-empty field name
    ------------------------------------------------------------------------------*/
    METHOD PUBLIC LOGICAL IsValid():
        RETURN (VALID-OBJECT(JsonObject) AND
                FieldName > "" AND
                MaxValue >= MinValue).
    END METHOD.
    
END CLASS.
