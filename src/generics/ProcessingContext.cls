/*------------------------------------------------------------------------
    File        : ProcessingContext
    Purpose     : Encapsulates data processing context to reduce parameter passing
    Syntax      : 
    Description : Parameter object with builder pattern for simplified construction
    Author(s)   : Cascade AI
    Created     : 2025-11-26
    Notes       : Uses fluent interface for flexible construction
  ----------------------------------------------------------------------*/

using generics.DataSourceAttachParams.
using generics.QueryContext.

block-level on error undo, throw.

class generics.ProcessingContext:
    
    /* Core handles */
    define public property DataSource as handle no-undo get. set.
    define public property Buffer as handle no-undo get. set.
    
    /* Parameters */
    define public property Params as DataSourceAttachParams no-undo get. set.
    define public property Context as QueryContext no-undo get. set.
    
    /* Entry index */
    define public property EntryIndex as integer no-undo get. set.
    
    /*------------------------------------------------------------------------------
     Purpose: Default constructor for builder pattern
     Notes: Use setter methods to configure the context
    ------------------------------------------------------------------------------*/
    constructor public ProcessingContext():
        super().
    end constructor.
    
    /*------------------------------------------------------------------------------
     Purpose: Simplified constructor with core parameters
     Parameters:
       input params - DataSourceAttachParams
       input context - Query context
       input iEntry - Entry index
     Notes: Handles and other properties set via setters
    ------------------------------------------------------------------------------*/
    constructor public ProcessingContext(
        input params as DataSourceAttachParams,
        input context as QueryContext,
        input iEntry as integer):
        
        super().
        
        assign
            this-object:Params = params
            this-object:Context = context
            this-object:EntryIndex = iEntry.
    end constructor.
    
end class.
