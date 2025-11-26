/*------------------------------------------------------------------------
    File        : QueryContext
    Purpose     : Encapsulates query execution context to reduce parameter passing
    Syntax      : 
    Description : Parameter object pattern to simplify method signatures
    Author(s)   : Cascade AI
    Created     : 2025-11-26
    Notes       : Reduces method parameter counts by grouping related data
  ----------------------------------------------------------------------*/

block-level on error undo, throw.

class generics.QueryContext:
    
    /* Query clauses */
    define public property Where as character no-undo get. set.
    define public property OrderBy as character no-undo get. set.
    
    /* Pagination */
    define public property MaxRows as integer no-undo get. set.
    define public property SkipRows as integer no-undo get. set.
    
    /* Identifiers */
    define public property KeyValue as character no-undo get. set.
    define public property RowId as character no-undo get. set.
    
    /* Flags */
    define public property UseReposition as logical no-undo get. set.
    
    /*------------------------------------------------------------------------------
     Purpose: Constructor
     Notes: Initializes with default values
    ------------------------------------------------------------------------------*/
    constructor public QueryContext():
        super().
        
        assign
            this-object:Where = ""
            this-object:OrderBy = ""
            this-object:MaxRows = ?
            this-object:SkipRows = ?
            this-object:KeyValue = ""
            this-object:RowId = ?
            this-object:UseReposition = false.
    end constructor.
    
end class.
