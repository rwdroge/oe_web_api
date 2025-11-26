/*------------------------------------------------------------------------
    File        : ProcessingContext
    Purpose     : Encapsulates data processing context to reduce parameter passing
    Syntax      : 
    Description : Parameter object pattern to simplify ProcessPrimaryRecords signature
    Author(s)   : Cascade AI
    Created     : 2025-11-26
    Notes       : Groups related processing parameters together
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
     Purpose: Constructor with all parameters
     Parameters:
       input hDataSource - Data source handle
       input hBuffer - Buffer handle
       input params - DataSourceAttachParams
       input context - Query context
       input iEntry - Entry index
    ------------------------------------------------------------------------------*/
    constructor public ProcessingContext(
        input hDataSource as handle,
        input hBuffer as handle,
        input params as DataSourceAttachParams,
        input context as QueryContext,
        input iEntry as integer):
        
        super().
        
        assign
            this-object:DataSource = hDataSource
            this-object:Buffer = hBuffer
            this-object:Params = params
            this-object:Context = context
            this-object:EntryIndex = iEntry.
    end constructor.
    
end class.
