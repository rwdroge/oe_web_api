 
 /*------------------------------------------------------------------------
    File        : DataAccess
    Purpose     : Provides data access functionality for entity operations
    Syntax      : class data.DataAccess
    Description : Handles data source attachment and query operations for
                  entities, supporting filtering, sorting, and pagination.
    Author(s)   : rdroge
    Created     : Fri Jan 04 10:52:21 CET 2019
    Notes       : - Supports dynamic data source attachment
                 - Handles filtering and sorting
                 - Implements pagination with skip/top
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using generics.FilterParams.
using generics.DataSourceAttachParams.
using generics.QueryContext.
using Progress.Profiler.MemoryProfiler.
using data.DataAccessHelper.

block-level on error undo, throw.

class data.DataAccess: 

    /* Sequence counter for unique identifiers */
    var private integer iSeq.
   
    /*------------------------------------------------------------------------------
     Purpose: Creates a new instance of the DataAccess class
     Notes: Initializes base class and prepares for data operations
    ------------------------------------------------------------------------------*/
    constructor public DataAccess():
        super().
    end constructor.
    
    /*------------------------------------------------------------------------------
     Purpose: Attaches a data source to a dataset with filtering and sorting
     Parameters:
       input params - DataSourceAttachParams object containing all attachment parameters
     Notes:
       - Supports dynamic where clause construction
       - Implements skip/top for pagination
       - Handles sorting through order by clause
    ------------------------------------------------------------------------------*/
    /*------------------------------------------------------------------------------
     Purpose: Reposition query to starting point
     Parameters:
       input hQuery - Query handle
       input hBuffer - Buffer handle
       input context - Query context
    ------------------------------------------------------------------------------*/
    method private void RepositionQuery(
        input hQuery as handle,
        input hBuffer as handle,
        input context as QueryContext):
        
        if context:RowId > "" and context:RowId <> "?" then
        do:
            hQuery:reposition-to-rowid(to-rowid(context:RowId)) no-error.
            if error-status:error then
                undo, throw new Progress.Lang.AppError(
                    "Error repositioning to rowid: " + error-status:get-message(1)).
        end.
        else if context:SkipRows <> ? and context:SkipRows > 0 then
        do:
            hQuery:reposition-to-row(context:SkipRows) no-error.
            if error-status:error then
                undo, throw new Progress.Lang.AppError(
                    "Error repositioning to row: " + error-status:get-message(1)).
                    
            if not hbuffer:available then
                hQuery:get-next() no-error.
            if error-status:error then
                undo, throw new Progress.Lang.AppError(
                    "Error getting next record: " + error-status:get-message(1)).
        end.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Process records with pagination using query repositioning
     Parameters:
       input hQuery - Query handle
       input hBuffer - Buffer handle
       input hTargetBuffer - Target buffer handle
       input context - Query context with pagination settings
    ------------------------------------------------------------------------------*/
    method private void ProcessRecordsWithPagination(
        input hQuery as handle,
        input hBuffer as handle,
        input hTargetBuffer as handle,
        input context as QueryContext):
        
        var integer iCount.
        
        /* Position to starting point */
        this-object:RepositionQuery(hQuery, hBuffer, context).
        
        /* Process records within maxRows limit */
        iCount = 0.
        repeat while not hQuery:query-off-end and (context:MaxRows = ? or iCount < context:MaxRows):
            hQuery:get-next() no-error.
            if error-status:error then
                undo, throw new Progress.Lang.AppError(
                    "Error getting next record: " + error-status:get-message(1)).
                    
            if hBuffer:available then
                this-object:CopyBufferWithIdAndSeq(hBuffer, hTargetBuffer).
            
            iCount = iCount + 1.
        end.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Copy buffer and set id and sequence fields
     Parameters:
       input hSourceBuffer - Source buffer to copy from
       input hTargetBuffer - Target buffer to copy to
    ------------------------------------------------------------------------------*/
    method private void CopyBufferWithIdAndSeq(
        input hSourceBuffer as handle,
        input hTargetBuffer as handle):
        
        /* Create and copy buffer */
        hTargetBuffer:buffer-create no-error.
        if error-status:error then
            undo, throw new Progress.Lang.AppError(
                "Error creating buffer: " + error-status:get-message(1)).
                
        hTargetBuffer:buffer-copy(hSourceBuffer) no-error.
        if error-status:error then
            undo, throw new Progress.Lang.AppError(
                "Error copying buffer: " + error-status:get-message(1)).
        
        /* Set id and sequence fields */
        hTargetBuffer:buffer-field("id"):buffer-value() = 
            string(hSourceBuffer:rowid) no-error.
        if error-status:error then
            undo, throw new Progress.Lang.AppError(
                "Error setting id field: " + error-status:get-message(1)).
        
        iSeq = iSeq + 1.
        hTargetBuffer:buffer-field("seq"):buffer-value() = 
            string(iSeq) no-error.
        if error-status:error then
            undo, throw new Progress.Lang.AppError(
                "Error setting sequence field: " + error-status:get-message(1)).
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Process primary records with filtering and pagination
     Parameters:
       input hDataSource - Data source handle
       input hBuffer - Buffer handle
       input params - DataSourceAttachParams
       input context - Query context
       input iEntry - Entry index
    ------------------------------------------------------------------------------*/
    method private void ProcessPrimaryRecords(
        input hDataSource as handle,
        input hBuffer as handle,
        input params as DataSourceAttachParams,
        input context as QueryContext,
        input iEntry as integer):
        
        var handle hQuery, qh.
        var integer iNumRecs.
        var character cWhere.
        
        /* Configure batch size */
        if context:MaxRows <> ? and context:MaxRows > 0 then
        do:
            this-object:ConfigureBatchSize(hBuffer, params, context, entry(1, params:Sources)).
            params:dsDataSet:get-buffer-handle(1):batch-size = context:MaxRows.
        end.
        else
            params:dsDataSet:get-buffer-handle(iEntry):batch-size = 
                (if context:RowId > "" then 1 else 0).
        
        /* Build complete WHERE clause */
        cWhere = if context:Where > "" then 
                    (context:Where + " " + context:OrderBy)
                 else 
                    context:OrderBy.
        
        hDataSource:fill-where-string = cWhere.
        
        /* Execute query with or without pagination */
        if context:UseReposition then
            this-object:ExecuteWithPagination(hDataSource, hBuffer, params, context).
        else
            this-object:ExecuteWithoutPagination(hDataSource, params, context, iEntry).
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Configure batch size with preselect query
     Parameters:
       input hBuffer - Buffer handle
       input params - DataSourceAttachParams
       input context - Query context
       input pcTableName - Table name
    ------------------------------------------------------------------------------*/
    method private void ConfigureBatchSize(
        input hBuffer as handle,
        input params as DataSourceAttachParams,
        input context as QueryContext,
        input pcTableName as character):
        
        var handle qh.
        var integer iNumRecs.
        
        create query qh no-error.
        if error-status:error then
            undo, throw new Progress.Lang.AppError(
                "Error creating query: " + error-status:get-message(1)).
                
        qh:set-buffers(hBuffer).
        qh:query-prepare("preselect each " + pcTableName + context:Where) no-error.
        if error-status:error then
        do:
            delete object qh no-error.
            undo, throw new Progress.Lang.AppError(
                "Error preparing query: " + error-status:get-message(1)).
        end.
                
        qh:query-open() no-error.
        if error-status:error then
        do:
            delete object qh no-error.
            undo, throw new Progress.Lang.AppError(
                "Error opening query: " + error-status:get-message(1)).
        end.
                
        iNumRecs = qh:num-results.
        delete object qh no-error.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Execute query with pagination (reposition)
     Parameters:
       input hDataSource - Data source handle
       input hBuffer - Buffer handle
       input params - DataSourceAttachParams
       input context - Query context
    ------------------------------------------------------------------------------*/
    method private void ExecuteWithPagination(
        input hDataSource as handle,
        input hBuffer as handle,
        input params as DataSourceAttachParams,
        input context as QueryContext):
        
        var handle hQuery.
        
        hQuery = hDataSource:query no-error.
        if error-status:error then
            undo, throw new Progress.Lang.AppError(
                "Error getting query handle: " + error-status:get-message(1)).
        
        MemoryProfiler:TakeSnapshot("attach_qopen_before").
        hQuery:query-open no-error.
        if error-status:error then
            undo, throw new Progress.Lang.AppError(
                "Error opening query: " + error-status:get-message(1)).
        
        this-object:ProcessRecordsWithPagination(
            hQuery, hBuffer, params:dsDataSet:get-buffer-handle(1), context).
        
        MemoryProfiler:TakeSnapshot("attach_qopen_after").
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Execute query without pagination (standard fill)
     Parameters:
       input hDataSource - Data source handle
       input params - DataSourceAttachParams
       input context - Query context
       input iEntry - Entry index
    ------------------------------------------------------------------------------*/
    method private void ExecuteWithoutPagination(
        input hDataSource as handle,
        input params as DataSourceAttachParams,
        input context as QueryContext,
        input iEntry as integer):
        
        if context:RowId > "" then
            hDataSource:restart-rowid(1) = to-rowid(context:RowId).
            
        params:dsDataSet:get-buffer-handle(iEntry):set-callback("after-row-fill", "addIdField").
        MemoryProfiler:TakeSnapshot("attach_fill_before").
        params:dsDataSet:fill().
        MemoryProfiler:TakeSnapshot("attach_fill_after").
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Process child records
     Parameters:
       input hBuffer - Buffer handle
       input params - DataSourceAttachParams
       input context - Query context
    ------------------------------------------------------------------------------*/
    method private void ProcessChildRecords(
        input hBuffer as handle,
        input params as DataSourceAttachParams,
        input context as QueryContext):
        
        var handle hQuery.
        
        create query hQuery.
        hQuery:add-buffer(hBuffer).
        hQuery:query-prepare("for each " + entry(1, params:Sources) +
            " where " + entry(1, params:SourceKeys) + " = " + context:KeyValue).
        
        MemoryProfiler:TakeSnapshot("attach_child_qopen_before").
        hQuery:query-open.
        hQuery:get-next() no-error.
        
        if hBuffer:available then
            this-object:CopyBufferWithIdAndSeq(hBuffer, params:dsDataSet:get-buffer-handle(1)).
        
        MemoryProfiler:TakeSnapshot("attach_child_qopen_after").
        delete object hQuery no-error.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Prepare query context from parameters
     Parameters:
       input params - DataSourceAttachParams object
     Returns: QueryContext object with prepared clauses
    ------------------------------------------------------------------------------*/
    method private QueryContext PrepareQueryContext(
        input params as DataSourceAttachParams):
        
        var QueryContext context = new QueryContext().
        
        /* Extract filter parameters with error handling */
        if params:Filter <> ? then
        do:
            assign
                context:MaxRows = params:Filter:TopRecs
                context:SkipRows = params:Filter:SkipRecs
                context:Where = params:Filter:Where
                context:RowId = params:Filter:rowid
                context:KeyValue = params:Filter:id1
                context:OrderBy = params:Filter:SortBy no-error.
        end.
        
        /* Use default key value if filter doesn't provide one */
        if context:KeyValue = "" and params:KeyValue > "" then
            context:KeyValue = params:KeyValue.
        
        /* Construct WHERE and ORDER BY clauses using helper */
        context:Where = DataAccessHelper:BuildWhereClause(context:Where).
        context:OrderBy = DataAccessHelper:BuildOrderByClause(context:OrderBy).
        
        /* Set pagination flag */
        context:UseReposition = context:SkipRows > 0.
        
        return context.
    end method.
    
    method public void attachSource(input params as DataSourceAttachParams):
        var handle hDataSource, hBuffer.
        var integer iEntry.
        var QueryContext context.
        
        MemoryProfiler:TakeSnapshot("attach_begin").
        
        /* Validate input parameters */
        if params = ? then
            undo, throw new Progress.Lang.AppError("DataSourceAttachParams cannot be unknown value").
        
        if not params:IsValid() then
            undo, throw new Progress.Lang.AppError("Invalid DataSourceAttachParams: required fields are missing").
        
        /* Prepare query context */
        context = this-object:PrepareQueryContext(params).
        
        /* Process each data source */
        do iEntry = 1 to num-entries(params:Sources):
            /* Create and attach data source */
            DataAccessHelper:CreateDataSourceBuffer(
                entry(iEntry, params:Sources),
                entry(iEntry, params:SourceKeys),
                output hDataSource,
                output hBuffer).
            
            params:dsDataSet:get-buffer-handle(iEntry):attach-data-source(hDataSource) no-error.
            if error-status:error then 
            do:
                delete object hDataSource no-error.
                delete object hBuffer no-error.
                undo, throw new Progress.Lang.AppError(
                    "Error attaching data source: " + error-status:get-message(1)).
            end.
            
            /* Apply filtering if provided */
            if params:Filter <> ? then
            do:
                if (iEntry = 1 and context:KeyValue = "") then
                    this-object:ProcessPrimaryRecords(hDataSource, hBuffer, params, context, iEntry).
                else
                    this-object:ProcessChildRecords(hBuffer, params, context).
            end.
        end.
        
        catch e as Progress.Lang.Error:
            undo, throw e.
        end.
        finally:
            delete object hBuffer no-error.
            delete object hDataSource no-error.
            delete object context no-error.
        end.
    end method.

    /*------------------------------------------------------------------------------
     Purpose: Adds a unique identifier field to the dataset
     Parameters:
       input phDataSet - Handle to the dataset requiring id field
     Notes:
       - Uses rowid as the base for id generation
       - Increments sequence counter for uniqueness
       - Adds 'id' field to first buffer in dataset
    ------------------------------------------------------------------------------*/
    method public void addIdField(input dataset-handle phDataSet):
        if not valid-handle(phDataSet) then
            undo, throw new Progress.Lang.AppError("Invalid dataset handle").
            
        phDataSet:get-buffer-handle(1):buffer-field("id"):buffer-value() = 
            string(phDataSet:get-buffer-handle(1):rowid) no-error.
        if error-status:error then
            undo, throw new Progress.Lang.AppError(
                "Error setting id field: " + error-status:get-message(1)).
                
        iSeq = iSeq + 1.
            phDataSet:get-buffer-handle(1):buffer-field("seq"):buffer-value() = string(iSeq).
            

    end method.
    
    method public void fetchAll(input-output dataset-handle phDataSet):
        var character cErrorMsg.
        
        if not valid-handle(phDataSet) then
        do:
            assign cErrorMsg = "Invalid dataset handle".
            undo, throw new Progress.Lang.AppError(cErrorMsg).
        end.
        MemoryProfiler:TakeSnapshot("fetchAll_fill_before").
        phDataSet:fill().
        MemoryProfiler:TakeSnapshot("fetchAll_fill_after").
        
    end method.

    method public void detachSource(input dataset-handle phDataSet):
        var integer iBuff.
        var character cErrorMsg.
        
        if not valid-handle(phDataSet) then
        do:
            assign cErrorMsg = "Invalid dataset handle".
            undo, throw new Progress.Lang.AppError(cErrorMsg).
        end.

        do iBuff = 1 to phDataSet:num-buffers:
            phDataSet:get-buffer-handle(iBuff):detach-data-source().
        end.
    end method.
    
    
    method public void commitChanges(input pcSkipList as character, input-output dataset-handle hDataSet):
        /* Handle variables */
        var handle hTopBuff.
        
        /* Integer variables */
        var integer iBuff.
        
        /* Character variables */
        var character cErrorMsg.
        
        if not valid-handle(hDataSet) then
        do:
            assign cErrorMsg = "Invalid dataset handle".
            undo, throw new Progress.Lang.AppError(cErrorMsg).
        end.
        
        do iBuff = 1 to hDataSet:num-top-buffers:
            hTopBuff = hDataSet:get-top-buffer(iBuff).
            
                
            /* Skip the reposition children. */
            if hTopBuff:parent-relation ne ? then next.
            this-object:traverseBuffers(pcSkipList, hTopBuff, dataset-handle hDataSet by-reference).
        end.
        
    
    end method.
    
    method private void traverseBuffers(input pcSkipList as character, input phBuffer as handle, input-output dataset-handle hDataSet):
        /* Integer variables */
        var integer iChildRel.
        
        /* Handle variables */
        var handle hChildBuffer.
        
        /* Character variables */
        var character cErrorMsg.
        
        if not valid-handle(phBuffer) then
        do:
            assign cErrorMsg = "Invalid buffer handle".
            undo, throw new Progress.Lang.AppError(cErrorMsg).
        end.
            
        if not valid-handle(hDataSet) then
        do:
            assign cErrorMsg = "Invalid dataset handle".
            undo, throw new Progress.Lang.AppError(cErrorMsg).
        end.
            
        this-object:saveBuffer(pcSkipList, phBuffer, dataset-handle hDataSet by-reference).
            
        do iChildRel = 1 to phBuffer:num-child-relations:
            hChildBuffer = phBuffer:get-child-relation(iChildRel):child-buffer.
            if valid-handle(hChildBuffer) then
                this-object:traverseBuffers(pcSkipList, hChildBuffer, dataset-handle hDataSet by-reference).
        end.
    
    end method.
    
    method private void saveBuffer(input pcSkipList as character, input phBuffer as handle, input-output dataset-handle hDataSet):
        /* Handle variables */
        var handle hBeforeBuff, hBeforeQry, hDataSource, hBuffer.
        
        /* Character variables */
        var character cLogicProc, cErrorMsg.

        hBeforeBuff = phBuffer:before-buffer.
            
        //hDataSet:set-buffers(hBeforeBuff).
        create data-source hDataSource.
        hDataSet:get-top-buffer():attach-data-source(hDataSource).
                
        if valid-handle(hBeforeBuff) then 
        do:
            /* Create a query on the before buffer BIttCust, then read through the change records */
            /* and commit the changes to the database                                            */
            
            create query hBeforeQry.
            hBeforeQry:add-buffer(hBeforeBuff).
            hBeforeQry:query-prepare("for each " + hBeforeBuff:name).
            hBeforeQry:query-open().
            hBeforeQry:get-first().
            
            do while not (hBeforeQry:query-off-end):
            end.
        
            /* The actual SAVE to the database */
            if not hBeforeBuff:error then
                hBeforeBuff:save-row-changes(1, pcSkipList).
                  
            /* If there was an error signal that this row did not make it into the database. */
            if hBeforeBuff:error then
                assign 
                    hDataSet:error       = true
                    hBeforeBuff:rejected = true.
                hBeforeQry:get-next().
            /* DO WHILE NOT QUERY-OFF-END */
            delete object hBeforeQry.
        end. /* DO IF VALID-HANDLE */
        finally:
            if valid-handle(hBeforeQry) then
                delete object hBeforeQry no-error.
            if valid-handle(hDataSource) then
                delete object hDataSource no-error.
        end finally.
        
    end method.
end class.