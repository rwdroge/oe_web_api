/*------------------------------------------------------------------------
    File        : MetadataService
    Purpose     : Provide metadata services for entity repositories
    Syntax      : 
    Description : Service class for handling entity metadata operations
    Author(s)   : Cascade AI
    Created     : 2025-06-24
    Notes       : Replaces the metadata.i include file with a reusable service
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using Progress.Json.ObjectModel.*.

block-level on error undo, throw.

class services.MetadataService:
    
    /*------------------------------------------------------------------------------
     Purpose: Check if a field list is valid for a given temp-table
     Parameters:
       input phTempTable - Handle to the temp-table
       input pcFieldList - Comma-separated list of fields to check
       output pcInvalidFields - Comma-separated list of invalid fields
       output plValid - Logical indicating if all fields are valid
     Notes: Validates that all fields in pcFieldList exist in the temp-table
    ------------------------------------------------------------------------------*/
    method public void checkFieldList(
        input phTempTable as handle,
        input pcFieldList as character,
        output pcInvalidFields as character,
        output plValid as logical):
        
        var character cFieldList = "".
        var integer i = 0.
        var character cNotListed = "".
        
        plValid = true.
        
        /* Build list of all fields in the temp-table */
        do i = 1 to phTempTable:num-fields:
            cFieldList = right-trim(phTempTable:buffer-field(i):name + "," + cFieldList, ",").
        end.
        
        /* Check each requested field against the field list */
        do i = 1 to num-entries(pcFieldList, ","):
            if lookup(entry(i, pcFieldList), cFieldList) = 0 then do:
                cNotListed = left-trim(cNotListed + "," + entry(i, pcFieldList), ",").
            end.
        end.
        
        if cNotListed > "" then
            plValid = false.
            
        pcInvalidFields = cNotListed.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Check if values in query parameters match field data types
     Parameters:
       input phTempTable - Handle to the temp-table
       input phQueryParams - Handle to the query parameters table
       output pcInvalidPairs - Comma-separated list of invalid field/value pairs
       output plValid - Logical indicating if all values are valid
     Notes: Validates that values in query parameters match field data types
    ------------------------------------------------------------------------------*/
    method public void checkValueList(
        input phTempTable as handle,
        input table-handle phQueryParams,
        output pcKeyValuePair as character,
        output plValid as logical):
        
        var character cDataType = "".
        var character cFieldName = "".
        var character cValue = "".
        var handle hQuery = ?.
        var handle bQueryParams = ?.
        
        plValid = true.
        
        bQueryParams = phQueryParams:default-buffer-handle.
        
        create query hQuery.
        hQuery:set-buffers(bQueryParams).
        hQuery:query-prepare("for each " + phQueryParams:name).
        hQuery:query-open.
        
        /* Go through all query string parameters and check their values for incorrect datatypes */
        repeat:
            hQuery:get-next().
            if hQuery:query-off-end then leave.
            
            if bQueryParams:available then do:
                cFieldName = bQueryParams:buffer-field("fieldname"):buffer-value().
                cValue = bQueryParams:buffer-field("fieldvalue"):buffer-value().
                
                /* Get the data type of the field */
                assign cDataType = phTempTable:buffer-field(cFieldName):data-type no-error.
                
                if error-status:error then do:
                    pcKeyValuePair = pcKeyValuePair + cFieldName + "/unknown/unknown/,".
                    plValid = false.
                    next.
                end.
                
                /* Check if the value matches the data type */
                case cDataType:
                    when "integer" then integer(cValue) no-error.
                    when "decimal" then decimal(cValue) no-error.    
                    when "logical" then logical(cValue) no-error.
                    when "date" then date(cValue) no-error.
                end case.
                
                if error-status:error then do:
                    pcKeyValuePair = pcKeyValuePair + cFieldName + "/" + cValue + "/" + cDataType + "/,".
                    plValid = false.
                end.
            end.
        end.
        
        finally:
            delete object hQuery no-error.
        end finally.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Create a JSON model of an entity's structure
     Parameters:
       input phTempTable - Handle to the temp-table
       output plcModel - Longchar containing the JSON model
     Notes: Builds a JSON object describing the entity's fields and data types
    ------------------------------------------------------------------------------*/
    method public void createEntityModel(
        input phTempTable as handle,
        output plcModel as longchar):
        
        var integer i = 0.
        var JsonObject joModel = new JsonObject().
        var character cDataType = "".
        
        /* Build JSON model from temp-table fields */
        do i = 1 to phTempTable:num-fields:
            /* Convert ABL data types to JSON-friendly types */
            case phTempTable:buffer-field(i):data-type:
                when "character" then cDataType = "string".
                when "decimal" then cDataType = "number".
                when "logical" then cDataType = "boolean".
                otherwise
                    cDataType = phTempTable:buffer-field(i):data-type.
            end case.
            
            /* Skip internal fields */
            if (phTempTable:buffer-field(i):name <> "seq" and 
                phTempTable:buffer-field(i):name <> "id") then
                joModel:add(phTempTable:buffer-field(i):name, cDataType).
        end.
        
        plcModel = joModel:getJsonText().
        
        finally:
            delete object joModel no-error.
        end finally.
    end method.
    
end class.
