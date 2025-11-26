/*------------------------------------------------------------------------
    File        : DataAccessHelper
    Purpose     : Helper methods for DataAccess to reduce complexity
    Description : Extracted helper methods to improve code quality
    Author(s)   : 
    Created     : 
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.

block-level on error undo, throw.

class data.DataAccessHelper:
    
    /*------------------------------------------------------------------------------
     Purpose: Build WHERE clause from filter string
     Parameters:
       input pcWhere - Filter string
     Returns: Formatted WHERE clause
    ------------------------------------------------------------------------------*/
    method public static character BuildWhereClause(input pcWhere as character):
        if pcWhere > "" then
            return " WHERE " + pcWhere.
        return "".
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Build ORDER BY clause from sort string
     Parameters:
       input pcOrderBy - Sort string (comma-separated fields)
     Returns: Formatted ORDER BY clause
    ------------------------------------------------------------------------------*/
    method public static character BuildOrderByClause(input pcOrderBy as character):
        var character cResult = "".
        
        if pcOrderBy > "" then
        do:
            /* Convert comma-separated fields to ABL ORDER BY syntax */
            cResult = replace(pcOrderBy, ",", " by ").
            cResult = "by " + cResult + " ".
            
            /* Remove system fields from sorting */
            assign
                cResult = replace(cResult, "by id desc", "")
                cResult = replace(cResult, "by id ", "")
                cResult = replace(cResult, "by seq desc", "")
                cResult = replace(cResult, "by seq ", "").
        end.
        
        return cResult.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Create and attach data source buffer
     Parameters:
       input pcTableName - Table name
       input pcSourceKey - Source key field
       output phDataSource - Data source handle
       output phBuffer - Buffer handle
    ------------------------------------------------------------------------------*/
    method public static void CreateDataSourceBuffer(
        input pcTableName as character,
        input pcSourceKey as character,
        output phDataSource as handle,
        output phBuffer as handle):
        
        /* Create data source */
        create data-source phDataSource no-error.
        if error-status:error then 
            undo, throw new Progress.Lang.AppError(
                "Error creating data source: " + error-status:get-message(1)).
        
        /* Create buffer */
        create buffer phBuffer for table pcTableName no-error.
        if error-status:error then 
        do:
            delete object phDataSource no-error.
            undo, throw new Progress.Lang.AppError(
                "Error creating buffer for " + pcTableName + ": " + 
                error-status:get-message(1)).
        end.
        
        /* Add buffer to data source */
        phDataSource:add-source-buffer(phBuffer, pcSourceKey) no-error.
        if error-status:error then 
        do:
            delete object phDataSource no-error.
            delete object phBuffer no-error.
            undo, throw new Progress.Lang.AppError(
                "Error adding source buffer: " + error-status:get-message(1)).
        end.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Set batch size for dataset buffer
     Parameters:
       input phBuffer - Buffer handle
       input piMaxRows - Maximum rows (can be ?)
       input pcId - ID value
    ------------------------------------------------------------------------------*/
    method public static void SetBatchSize(
        input phBuffer as handle,
        input piMaxRows as integer,
        input pcId as character):
        
        if piMaxRows <> ? and piMaxRows > 0 then
            phBuffer:batch-size = piMaxRows.
        else
            phBuffer:batch-size = (if pcId > "" then 1 else 0).
    end method.
    
end class.
