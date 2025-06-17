 
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
       input pcBuffers      - Buffer names for the dataset
       input pcFields       - Fields to include in the query
       input pcSources      - Data source names
       input pcSourceKeys   - Key fields for the data sources
       input pcKeyValue     - Value for key field filtering
       input pFilter        - Filter parameters (sorting, paging, where clause)
       input-output phDataSet - Handle to the target dataset
     Notes:
       - Supports dynamic where clause construction
       - Implements skip/top for pagination
       - Handles sorting through order by clause
    ------------------------------------------------------------------------------*/
    method public void attachSource(
        input pcBuffers as character,
        input pcFields as character,
        input pcSources as character,
        input pcSourceKeys as character,
        input pcKeyValue as character,
        input pFilter as FilterParams,
        input-output dataset-handle phDataSet):
        
        /* Handle variables */
        var handle hDataSource, hBuffer, hQuery, qh.
        
        /* Integer variables */
        var integer iNumRecs, iEntry, iCount.
        var integer iMaxRows, iSkipRows = ?.
        
        /* Logical variables */
        var logical lUseReposition.
        
        /* Character variables */
        var character cWhere, cQuery, cOrderby, cId.
        cOrderBy = "".
        cId = ?.
        
        /* Extract filter parameters with error handling */
        assign
            iMaxRows = pFilter:TopRecs 
            iSkipRows = pFilter:SkipRecs 
            cWhere = pFilter:Where 
            cId = pFilter:rowid 
            pcKeyValue = pFilter:id1
            cOrderBy = pFilter:SortBy no-error.
            
        /* Construct WHERE clause safely */
        if cWhere > "" then
            cWhere = " WHERE " + cWhere.
        
        /* Process ORDER BY clause */
        if cOrderBy > "" then
        do:
            /* Convert comma-separated fields to ABL ORDER BY syntax */
            cOrderBy = replace(cOrderBy, ",", " by ").
            cOrderBy = "by " + cOrderBy + " ".
            
            /* Remove system fields from sorting */
            assign
                cOrderBy = replace(cOrderBy, "by id desc", "")
                cOrderBy = replace(cOrderBy, "by id ", "")
                cOrderBy = replace(cOrderBy, "by seq desc", "")
                cOrderBy = replace(cOrderBy, "by seq ", "").
        end.
        
        /* Set pagination flag */
        lUseReposition = iSkipRows > 0.
        
        /* Process each data source */
        do iEntry = 1 to num-entries(pcSources):
            /* Create and attach data source */
            create data-source hDataSource no-error.
            if error-status:error then 
            do:
                undo, throw new Progress.Lang.AppError(
                    "Error creating data source: " + error-status:get-message(1)).
            end.
            
            create buffer hBuffer for table entry(iEntry, pcSources) no-error.
            if error-status:error then 
            do:
                delete object hDataSource no-error.
                undo, throw new Progress.Lang.AppError(
                    "Error creating buffer for " + entry(iEntry, pcSources) + ": " + 
                    error-status:get-message(1)).
            end.
            
            /* Add buffer to data source */
            hDataSource:add-source-buffer(hBuffer, entry(iEntry,pcSourceKeys)) no-error.
            if error-status:error then 
            do:
                delete object hDataSource no-error.
                delete object hBuffer no-error.
                undo, throw new Progress.Lang.AppError(
                    "Error adding source buffer: " + error-status:get-message(1)).
            end.
            
            /* Attach data source to dataset buffer */
            phDataSet:get-buffer-handle(iEntry):attach-data-source(hDataSource) no-error.
            if error-status:error then 
            do:
                delete object hDataSource no-error.
                delete object hBuffer no-error.
                undo, throw new Progress.Lang.AppError(
                    "Error attaching data source: " + error-status:get-message(1)).
            end.
            
            /* Apply filtering if provided */
            if pFilter <> ? then
            do:
                if (iEntry = 1 and pcKeyValue = "") then
                do:
                    /* Handle maximum rows limit */
                    if iMaxRows <> ? and iMaxRows > 0 then
                    do:
                        create query qh no-error.
                        if error-status:error then
                            undo, throw new Progress.Lang.AppError(
                                "Error creating query: " + error-status:get-message(1)).
                                
                        qh:set-buffers(hBuffer).
                        qh:query-prepare("preselect each " + entry(1, pcSources) + cWhere) no-error.
                        if error-status:error then
                            undo, throw new Progress.Lang.AppError(
                                "Error preparing query: " + error-status:get-message(1)).
                                
                        qh:query-open() no-error.
                        if error-status:error then
                            undo, throw new Progress.Lang.AppError(
                                "Error opening query: " + error-status:get-message(1)).
                                
                        iNumRecs = qh:num-results.
                        phDataSet:get-buffer-handle(1):batch-size = iMaxRows.
                    end.
                    else do:
                        /* Set batch size based on ID presence */
                        phDataSet:get-buffer-handle(iEntry):batch-size = 
                            (if cId > "" then 1 else 0).
                    end.
                    
                    /* Ensure order by is initialized */
                    if cOrderBy = ? then 
                        cOrderBy = "".
                
                    cWhere =    if cWhere > "" then 
                                    (cWhere + " " + cOrderBy)
                                else 
                                    (cOrderBy).
                
                    hDataSource:fill-where-string = cWhere.
                    
                    if lUseReposition then
                    do:
                        /* Get query handle from data source */
                        hQuery = hDataSource:query no-error.
                        if error-status:error then
                            undo, throw new Progress.Lang.AppError(
                                "Error getting query handle: " + error-status:get-message(1)).
                        
                        /* Open the query */
                        hQuery:query-open no-error.
                        if error-status:error then
                            undo, throw new Progress.Lang.AppError(
                                "Error opening query: " + error-status:get-message(1)).
                        
                        /* Position to specific record or skip rows */
                        if cId > "" and cId <> "?" then
                        do:
                            hQuery:reposition-to-rowid(to-rowid(cId)) no-error.
                            if error-status:error then
                                undo, throw new Progress.Lang.AppError(
                                    "Error repositioning to rowid: " + error-status:get-message(1)).
                        end.
                        else if iSkipRows <> ? and iSkipRows > 0 then
                        do:
                            hQuery:reposition-to-row(iSkipRows) no-error.
                            if error-status:error then
                                undo, throw new Progress.Lang.AppError(
                                    "Error repositioning to row: " + error-status:get-message(1)).
                                    
                            if not hbuffer:available then
                                hQuery:get-next() no-error.
                            if error-status:error then
                                undo, throw new Progress.Lang.AppError(
                                    "Error getting next record: " + error-status:get-message(1)).
                        end.
                        
                        /* Process records within maxRows limit */
                        iCount = 0.
                        repeat while not hQuery:query-off-end and (iMaxRows = ? or iCount < iMaxRows):
                            hQuery:get-next() no-error.
                            if error-status:error then
                                undo, throw new Progress.Lang.AppError(
                                    "Error getting next record: " + error-status:get-message(1)).
                                    
                            if hBuffer:available then
                            do:
                                /* Create and copy buffer */
                                phDataSet:get-buffer-handle(1):buffer-create no-error.
                                if error-status:error then
                                    undo, throw new Progress.Lang.AppError(
                                        "Error creating buffer: " + error-status:get-message(1)).
                                        
                                phDataSet:get-buffer-handle(1):buffer-copy(hBuffer) no-error.
                                if error-status:error then
                                    undo, throw new Progress.Lang.AppError(
                                        "Error copying buffer: " + error-status:get-message(1)).
                                
                                /* Set id and sequence fields */
                                phDataSet:get-buffer-handle(1):buffer-field("id"):buffer-value() = 
                                    string(hBuffer:rowid) no-error.
                                if error-status:error then
                                    undo, throw new Progress.Lang.AppError(
                                        "Error setting id field: " + error-status:get-message(1)).
                                
                                iSeq = iSeq + 1.
                                phDataSet:get-buffer-handle(1):buffer-field("seq"):buffer-value() = 
                                    string(iSeq) no-error.
                                if error-status:error then
                                    undo, throw new Progress.Lang.AppError(
                                        "Error setting sequence field: " + error-status:get-message(1)).
                            end.
                            
                            iCount = iCount + 1.
                        end.
                    end.
                    else 
                    do:
                        if cId > "" then hDataSource:restart-rowid(1)
                            = to-rowid ((cId)).
                        phDataSet:get-buffer-handle(iEntry):set-callback ("after-row-fill", "addIdField").
                        phDataSet:fill().
                        
                    end.
                end. /* do if iEntry = 1 */
                else do:
                    create query hQuery.
                    hQuery:add-buffer(hBuffer).
                    hQuery:query-prepare("for each " + entry(1, pcSources) +
                        " where " + entry(1, pcSourceKeys) + " = " + pcKeyValue).
                    hDataSource:query = hQuery.
                    hQuery:query-open.
                    hQuery:get-next() no-error.
                    if hBuffer:available then do:
                        phDataSet:get-buffer-handle(1):buffer-create().
                        phDataSet:get-buffer-handle(1):buffer-copy(hBuffer).
                        phDataSet:get-buffer-handle(1):buffer-field("id"):buffer-value() = string(hBuffer:rowid).
                        iSeq = iSeq + 1.
                        phDataSet:get-buffer-handle(1):buffer-field("seq"):buffer-value() = string(iSeq).
                    end.
                    delete object hQuery.
                end. 
            end.
            
            
        end. /* DO iEntry = 1 TO NUM-ENTRIES */
        
        finally:
            /* Clean up all handles */
            delete object hBuffer no-error.
            delete object hQuery no-error.
            delete object qh no-error.
            delete object hDataSource no-error.
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
            phDataSet:write-json('file', '/tmp/phDataSet.json').

    end method.
    
    method public void fetchAll(input-output dataset-handle phDataSet):
        var character cErrorMsg.
        
        if not valid-handle(phDataSet) then
        do:
            assign cErrorMsg = "Invalid dataset handle".
            undo, throw new Progress.Lang.AppError(cErrorMsg).
        end.
        phDataSet:fill().
        
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
            hTopBuff:write-json('file', '/tmp/hTop.json').
                
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