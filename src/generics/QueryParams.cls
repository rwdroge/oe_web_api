/*------------------------------------------------------------------------
   File        : QueryParams
   Purpose     : Parameter object for query operations
   Syntax      : class QueryParams
   Description : Encapsulates parameters commonly used for querying data
   Author(s)   : Cascade AI
   Created     : 2025-08-26
   Notes       : Reduces parameter count in query methods
 ----------------------------------------------------------------------*/

using Progress.Lang.*.

block-level on error undo, throw.

class generics.QueryParams:
    
    /* Query parameters */
    define public property Filter as character no-undo get. set.
    define public property Sort as character no-undo get. set.
    define public property Limit as integer no-undo get. set.
    define public property Offset as integer no-undo get. set.
    
    /* Search parameters */
    define public property SearchTerm as character no-undo get. set.
    define public property SearchFields as character no-undo get. set.
    
    constructor public QueryParams():
        super().
        /* Initialize with default values */
        assign
            Filter = ""
            Sort = ""
            Limit = 0
            Offset = 0
            SearchTerm = ""
            SearchFields = "".
    end constructor.
    
    constructor public QueryParams(input pcFilter as character, input pcSort as character, input piLimit as integer, input piOffset as integer):
        this-object().
        assign
            Filter = pcFilter
            Sort = pcSort
            Limit = piLimit
            Offset = piOffset.
    end constructor.
    
    /* Check if filter is provided */
    method public logical HasFilter():
        return (Filter > "").
    end method.
    
    /* Check if sort is provided */
    method public logical HasSort():
        return (Sort > "").
    end method.
    
    /* Check if limit is provided */
    method public logical HasLimit():
        return (Limit > 0).
    end method.
    
    /* Check if offset is provided */
    method public logical HasOffset():
        return (Offset > 0).
    end method.
    
    /* Check if search term is provided */
    method public logical HasSearchTerm():
        return (SearchTerm > "").
    end method.
    
    /* Check if search fields are provided */
    method public logical HasSearchFields():
        return (SearchFields > "").
    end method.
    
    /* Set pagination parameters */
    method public void SetPagination(input piLimit as integer, input piOffset as integer):
        assign
            Limit = piLimit
            Offset = piOffset.
    end method.
    
    /* Set search parameters */
    method public void SetSearch(input pcSearchTerm as character, input pcSearchFields as character):
        assign
            SearchTerm = pcSearchTerm
            SearchFields = pcSearchFields.
    end method.

end class.
