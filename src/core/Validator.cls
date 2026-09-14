/*------------------------------------------------------------------------
    File        : Validator
    Purpose     : Data validation framework
    Syntax      : 
    Description : Provides validation functionality for data
    Author(s)   : Cascade AI
    Created     : 2025-06-24
    Notes       : Validation framework for data integrity
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using Progress.Json.ObjectModel.*.
using errors.ApiError.
using generics.ValidationRangeParams.
using generics.ValidationPatternParams.

block-level on error undo, throw.

class core.Validator:
    
    /* Validation errors */
    define private temp-table ValidationErrors no-undo
        field FieldName as character
        field ErrorMessage as character
        index idx1 as primary unique FieldName.
    
    /* Has errors flag */
    define public property HasErrors as logical no-undo 
        get():
            return temp-table ValidationErrors:has-records.
        end.
    
    /*------------------------------------------------------------------------------
     Purpose: Constructor
     Notes: Initializes validator
    ------------------------------------------------------------------------------*/
    constructor public Validator():
        super().
    end constructor.
    
    /*------------------------------------------------------------------------------
     Purpose: Validate if a field is required and exists
     Parameters:
       input poJson - JSON object to validate
       input pcField - Field name to check
     Returns: JsonObject with validation result
     Notes: Returns a JsonObject with valid flag and message if invalid
    ------------------------------------------------------------------------------*/
    method public JsonObject IsRequired(
        input poJson as JsonObject,
        input pcField as character):
        
        define variable joResult as JsonObject no-undo.
        
        /* Create result object */
        joResult = new JsonObject().
        
        /* Check if field exists and is not empty */
        if not poJson:Has(pcField) or poJson:IsNull(pcField) then do:
            joResult:Add("valid", false).
            joResult:Add("message", "Field is required").
            return joResult.
        end.
        
        /* For string fields, check if empty */
        if poJson:GetType(pcField) = JsonDataType:STRING then do:
            if poJson:GetCharacter(pcField) = "" then do:
                joResult:Add("valid", false).
                joResult:Add("message", "Field cannot be empty").
                return joResult.
            end.
        end.
        
        /* Field is valid */
        joResult:Add("valid", true).
        return joResult.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Validate required fields
     Parameters:
       input poJson - JSON object to validate
       input pcFields - Comma-separated list of required fields
     Notes: Adds validation errors for missing required fields
    ------------------------------------------------------------------------------*/
    method public void ValidateRequired(
        input poJson as JsonObject,
        input pcFields as character):
        
        var integer iField.
        var character cField.
        var integer iNumEntries.
        
        /* Get number of entries in the fields list */
        iNumEntries = NUM-ENTRIES(pcFields, ",").
        
        /* Check each field */
        do iField = 1 to iNumEntries:
            cField = TRIM(ENTRY(iField, pcFields, ",")).
            
            /* Check if field exists and is not null */
            if not poJson:Has(cField) or poJson:IsNull(cField) then
                this-object:AddError(cField, "Field is required").
        end.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Validate field type
     Parameters:
       input poJson - JSON object to validate
       input pcField - Field name
       input pcType - Expected type (character, integer, decimal, logical, date)
     Notes: Adds validation error if field type doesn't match expected type
    ------------------------------------------------------------------------------*/
    method public void ValidateType(
        input poJson as JsonObject,
        input pcField as character,
        input pcType as character):
        
        define variable cValue as character no-undo.
        define variable iValue as integer no-undo.
        define variable dValue as decimal no-undo.
        define variable lValue as logical no-undo.
        define variable dtValue as date no-undo.
        
        /* Skip if field doesn't exist or is null */
        if not poJson:Has(pcField) or poJson:IsNull(pcField) then
            return.
            
        /* Validate type based on expected type */
        case pcType:
            when "character" then do:
                if poJson:GetType(pcField) <> JsonDataType:STRING then
                    this-object:AddError(pcField, "Field must be a string").
            end.
            
            when "integer" then do:
                if poJson:GetType(pcField) <> JsonDataType:NUMBER then
                    this-object:AddError(pcField, "Field must be a number").
                else do:
                    /* Check if number is an integer */
                    cValue = string(poJson:GetCharacter(pcField)).
                    if index(cValue, ".") > 0 then
                        this-object:AddError(pcField, "Field must be an integer").
                end.
            end.
            
            when "decimal" then do:
                if poJson:GetType(pcField) <> JsonDataType:NUMBER then
                    this-object:AddError(pcField, "Field must be a number").
            end.
            
            when "logical" then do:
                if poJson:GetType(pcField) <> JsonDataType:BOOLEAN then
                    this-object:AddError(pcField, "Field must be a boolean").
            end.
            
            when "date" then do:
                if poJson:GetType(pcField) <> JsonDataType:STRING then
                    this-object:AddError(pcField, "Field must be a date string").
                else do:
                    /* Try to parse date */
                    cValue = poJson:GetCharacter(pcField).
                    dtValue = date(cValue) no-error.
                    if dtValue = ? then
                        this-object:AddError(pcField, "Field must be a valid date").
                end.
            end.
        end case.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Validate field length
     Parameters:
       input poJson - JSON object to validate
       input pcField - Field name
       input piMaxLength - Maximum length
     Notes: Adds validation error if field length exceeds maximum
    ------------------------------------------------------------------------------*/
    method public void ValidateLength(
        input poJson as JsonObject,
        input pcField as character,
        input piMaxLength as integer):
        
        define variable cValue as character no-undo.
        
        /* Skip if field doesn't exist or is null */
        if not poJson:Has(pcField) or poJson:IsNull(pcField) then
            return.
            
        /* Check if field is a string */
        if poJson:GetType(pcField) <> JsonDataType:STRING then
            return.
            
        /* Get field value */
        cValue = poJson:GetCharacter(pcField).
        
        /* Check length */
        if length(cValue) > piMaxLength then
            this-object:AddError(pcField, 
                "Field length exceeds maximum of " + string(piMaxLength)).
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Validate field range
     Parameters:
       input params - ValidationRangeParams containing validation parameters
     Notes: Adds validation error if field value is outside range
    ------------------------------------------------------------------------------*/
    method public void ValidateRange(input params as ValidationRangeParams):
        
        define variable dValue as decimal no-undo.
        
        /* Validate parameters */
        if not params:IsValid() then
            return.
        
        /* Skip if field doesn't exist or is null */
        if not params:JsonObject:Has(params:FieldName) or params:JsonObject:IsNull(params:FieldName) then
            return.
            
        /* Check if field is a number */
        if params:JsonObject:GetType(params:FieldName) <> JsonDataType:NUMBER then
            return.
            
        /* Get field value */
        dValue = params:JsonObject:GetDecimal(params:FieldName).
        
        /* Check range */
        if dValue < params:MinValue or dValue > params:MaxValue then
            this-object:AddError(params:FieldName, 
                "Field value must be between " + string(params:MinValue) + 
                " and " + string(params:MaxValue)).
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Validate field pattern
     Parameters:
       input params - ValidationPatternParams containing validation parameters
     Notes: Adds validation error if field value doesn't match pattern
    ------------------------------------------------------------------------------*/
    method public void ValidatePattern(input params as ValidationPatternParams):
        
        define variable cValue as character no-undo.
        
        /* Validate parameters */
        if not params:IsValid() then
            return.
        
        /* Skip if field doesn't exist or is null */
        if not params:JsonObject:Has(params:FieldName) or params:JsonObject:IsNull(params:FieldName) then
            return.
            
        /* Check if field is a string */
        if params:JsonObject:GetType(params:FieldName) <> JsonDataType:STRING then
            return.
            
        /* Get field value */
        cValue = params:JsonObject:GetCharacter(params:FieldName).
        
        /* Check pattern */
        if not cValue matches params:Pattern then
            this-object:AddError(params:FieldName, params:ErrorMessage).
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Add validation error
     Parameters:
       input pcField - Field name
       input pcMessage - Error message
     Notes: Adds validation error for field
    ------------------------------------------------------------------------------*/
    method public void AddError(
        input pcField as character,
        input pcMessage as character):
        
        /* Check if error already exists for field */
        find ValidationErrors where ValidationErrors.FieldName = pcField no-error.
        if available ValidationErrors then
            delete ValidationErrors.
            
        /* Add error */
        create ValidationErrors.
        assign
            ValidationErrors.FieldName = pcField
            ValidationErrors.ErrorMessage = pcMessage.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Get validation errors as JSON object
     Returns: JsonObject containing validation errors
     Notes: Returns JSON object with errors by field
    ------------------------------------------------------------------------------*/
    method public JsonObject GetErrors():
        define variable joErrors as JsonObject no-undo.
        define variable joFieldErrors as JsonObject no-undo.
        
        /* Create errors object */
        joErrors = new JsonObject().
        joErrors:Add("valid", not this-object:HasErrors).
        
        /* Add field errors */
        joFieldErrors = new JsonObject().
        
        for each ValidationErrors:
            joFieldErrors:Add(ValidationErrors.FieldName, 
                ValidationErrors.ErrorMessage).
        end.
        
        joErrors:Add("errors", joFieldErrors).
        
        return joErrors.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Throw validation error if has errors
     Notes: Throws ApiError with validation errors
    ------------------------------------------------------------------------------*/
    method public void ThrowIfErrors():
        var character cDetails.
        
        if this-object:HasErrors then do:
            cDetails = this-object:GetErrors():GetJsonText().
            undo, throw new ApiError(
                "Validation failed",
                422,
                "Validation",
                ?,
                ?,
                cDetails).
        end.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Clear validation errors
     Notes: Removes all validation errors
    ------------------------------------------------------------------------------*/
    method public void Clear():
        for each ValidationErrors:
            delete ValidationErrors.
        end.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Validate if a field is a logical value
     Parameters:
       input poJson - JSON object to validate
       input pcField - Field name to check
     Returns: JsonObject with validation result
     Notes: Returns a JsonObject with valid flag and message if invalid
    ------------------------------------------------------------------------------*/
    method public JsonObject IsLogical(
        input poJson as JsonObject,
        input pcField as character):
        
        define variable joResult as JsonObject no-undo.
        
        /* Create result object */
        joResult = new JsonObject().
        
        /* Check if field exists */
        if not poJson:Has(pcField) or poJson:IsNull(pcField) then do:
            joResult:Add("valid", true).
            return joResult.
        end.
        
        /* Check if field is a boolean */
        if poJson:GetType(pcField) <> JsonDataType:BOOLEAN then do:
            joResult:Add("valid", false).
            joResult:Add("message", "Field must be a boolean value").
            return joResult.
        end.
        
        /* Field is valid */
        joResult:Add("valid", true).
        return joResult.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Validate if a field does not exceed maximum length
     Parameters:
       input poJson - JSON object to validate
       input pcField - Field name to check
       input piMaxLength - Maximum allowed length
     Returns: JsonObject with validation result
     Notes: Returns a JsonObject with valid flag and message if invalid
    ------------------------------------------------------------------------------*/
    /*------------------------------------------------------------------------------
     Purpose: Validate if a field meets minimum length requirement
     Parameters:
       input poJson - JSON object to validate
       input pcField - Field name to check
       input piMinLength - Minimum allowed length
     Returns: JsonObject with validation result
     Notes: Returns a JsonObject with valid flag and message if invalid
    ------------------------------------------------------------------------------*/
    method public JsonObject MinLength(
        input poJson as JsonObject,
        input pcField as character,
        input piMinLength as integer):
        
        define variable joResult as JsonObject no-undo.
        define variable cValue as character no-undo.
        
        /* Create result object */
        joResult = new JsonObject().
        
        /* Check if field exists */
        if not poJson:Has(pcField) or poJson:IsNull(pcField) then do:
            joResult:Add("valid", true).
            return joResult.
        end.
        
        /* Check if field is a string */
        if poJson:GetType(pcField) <> JsonDataType:STRING then do:
            joResult:Add("valid", false).
            joResult:Add("message", "Field must be a string value").
            return joResult.
        end.
        
        /* Get field value */
        cValue = poJson:GetCharacter(pcField).
        
        /* Check minimum length */
        if length(cValue) < piMinLength then do:
            joResult:Add("valid", false).
            joResult:Add("message", "Field length must be at least " + string(piMinLength) + " characters").
            return joResult.
        end.
        
        /* Field is valid */
        joResult:Add("valid", true).
        return joResult.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Validate if a field is a date value
     Parameters:
       input poJson - JSON object to validate
       input pcField - Field name to check
     Returns: JsonObject with validation result
     Notes: Returns a JsonObject with valid flag and message if invalid
    ------------------------------------------------------------------------------*/
    method public JsonObject IsDate(
        input poJson as JsonObject,
        input pcField as character):
        
        define variable joResult as JsonObject no-undo.
        define variable cValue as character no-undo.
        define variable dValue as date no-undo.
        
        /* Create result object */
        joResult = new JsonObject().
        
        /* Check if field exists */
        if not poJson:Has(pcField) or poJson:IsNull(pcField) then do:
            joResult:Add("valid", true).
            return joResult.
        end.
        
        /* Check if field can be converted to a date */
        if poJson:GetType(pcField) = JsonDataType:STRING then do:
            cValue = poJson:GetCharacter(pcField).
            dValue = date(cValue) no-error.
            if dValue = ? then do:
                joResult:Add("valid", false).
                joResult:Add("message", "Field must be a valid date").
                return joResult.
            end.
        end.
        else do:
            joResult:Add("valid", false).
            joResult:Add("message", "Field must be a date string").
            return joResult.
        end.
        
        /* Field is valid */
        joResult:Add("valid", true).
        return joResult.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Validate if a field does not exceed maximum length
     Parameters:
       input poJson - JSON object to validate
       input pcField - Field name to check
       input piMaxLength - Maximum allowed length
     Returns: JsonObject with validation result
     Notes: Returns a JsonObject with valid flag and message if invalid
    ------------------------------------------------------------------------------*/
    method public JsonObject MaxLength(
        input poJson as JsonObject,
        input pcField as character,
        input piMaxLength as integer):
        
        define variable joResult as JsonObject no-undo.
        define variable cValue as character no-undo.
        
        /* Create result object */
        joResult = new JsonObject().
        
        /* Check if field exists */
        if not poJson:Has(pcField) or poJson:IsNull(pcField) then do:
            joResult:Add("valid", true).
            return joResult.
        end.
        
        /* Check if field is a string */
        if poJson:GetType(pcField) <> JsonDataType:STRING then do:
            joResult:Add("valid", true).
            return joResult.
        end.
        
        /* Get field value */
        cValue = poJson:GetCharacter(pcField).
        
        /* Check length */
        if length(cValue) > piMaxLength then do:
            joResult:Add("valid", false).
            joResult:Add("message", "Field length exceeds maximum of " + string(piMaxLength)).
            return joResult.
        end.
        
        /* Field is valid */
        joResult:Add("valid", true).
        return joResult.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Clean up resources
    ------------------------------------------------------------------------------*/
    destructor public Validator():
        /* Clean up validation errors */
        for each ValidationErrors:
            delete ValidationErrors.
        end.
    end destructor.
    
    /*------------------------------------------------------------------------------
     Purpose: Validate if a field is a numeric value
     Parameters:
       input poJson - JSON object to validate
       input pcField - Field name to check
     Returns: JsonObject with validation result
     Notes: Returns a JsonObject with valid flag and message if invalid
    ------------------------------------------------------------------------------*/
    method public JsonObject IsNumeric(
        input poJson as JsonObject,
        input pcField as character):
        
        define variable joResult as JsonObject no-undo.
        
        /* Create result object */
        joResult = new JsonObject().
        
        /* Check if field exists */
        if not poJson:Has(pcField) or poJson:IsNull(pcField) then do:
            joResult:Add("valid", true).
            return joResult.
        end.
        
        /* Check if field is a number */
        if poJson:GetType(pcField) <> JsonDataType:NUMBER then do:
            joResult:Add("valid", false).
            joResult:Add("message", "Field must be a numeric value").
            return joResult.
        end.
        
        /* Field is valid */
        joResult:Add("valid", true).
        return joResult.
    end method.
    
end class.
