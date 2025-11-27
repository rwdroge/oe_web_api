/*------------------------------------------------------------------------
    File        : BaseRepository
    Purpose     : Base implementation of repository pattern
    Syntax      : 
    Description : Abstract base class for entity repositories
    Author(s)   : Cascade AI
    Created     : 2025-06-24
    Notes       : Provides common repository functionality
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using interfaces.IRepository.
using generics.FilterParams.
using generics.DataSourceAttachParams.
using Progress.Json.ObjectModel.*.
using data.DataAccess.
using services.MetadataService.
using Progress.Profiler.MemoryProfiler.

block-level on error undo, throw.

class data.BaseRepository abstract implements interfaces.IRepository:
    
    /* Protected properties for entity information */
    define protected property TempTableName as character no-undo get. set.
    define protected property PrimaryKeyField as character no-undo get. set.
    define protected property DatabaseTable as character no-undo get. set.
    define protected property DatasetHandle as handle no-undo get. set.
    
    /* Data access object */
    define protected property Dao as DataAccess no-undo get. set.
    
    /* Metadata service */
    define protected property MetadataService as MetadataService no-undo get. set.
    
    /* Temp-table for query parameters */
    define temp-table ttQueryParams
        field fieldname as character
        field fieldvalue as character
        index fieldname is primary unique fieldname ascending.
    
    /*------------------------------------------------------------------------------
     Purpose: Helper method to find by query string filter
     Parameters:
       input pcQueryString - Query string filter (e.g., "country='USA'")
     Returns: handle to dataset containing matching entities
     Notes: Common pattern for repository-specific filter methods
    ------------------------------------------------------------------------------*/
    method protected handle FindByQueryString(input pcQueryString as character):
        var generics.FilterParams filter.
        
        filter = new generics.FilterParams(
            this-object:DatabaseTable,
            pcQueryString,
            "",
            output table ttQueryParams).
        
        return this-object:FindByFilter(filter).
        
        finally:
            delete object filter no-error.
        end finally.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Helper method to create and prepare a dataset handle
     Parameters:
       input lCloneStructure - Whether to clone from template or use existing
     Returns: Dataset handle
    ------------------------------------------------------------------------------*/
    method private handle PrepareDatasetHandle(input lCloneStructure as logical):
        var handle dshandle.
        
        create dataset dshandle.
        
        if lCloneStructure then
            dshandle:create-like(this-object:DatasetHandle).
        else
            dshandle = this-object:DatasetHandle.
        
        return dshandle.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Helper method to create DataSourceAttachParams
     Parameters:
       input pcKeyValue - Primary key value
       input pFilter - Filter parameters (can be ?)
       input phDataset - Dataset handle
     Returns: DataSourceAttachParams object
    ------------------------------------------------------------------------------*/
    method private DataSourceAttachParams CreateAttachParams(
        input pcKeyValue as character,
        input pFilter as generics.FilterParams,
        input phDataset as handle):
        
        return new DataSourceAttachParams(
            this-object:TempTableName,
            this-object:PrimaryKeyField,
            this-object:DatabaseTable,
            this-object:PrimaryKeyField,
            pcKeyValue,
            pFilter,
            phDataset).
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Helper method to attach data source and fetch data
     Parameters:
       input pcKeyValue - Primary key value
       input pFilter - Filter parameters
       input phDataset - Dataset handle
    ------------------------------------------------------------------------------*/
    method private void AttachAndFetch(
        input pcKeyValue as character,
        input pFilter as generics.FilterParams,
        input phDataset as handle):
        
        var DataSourceAttachParams attachParams.
        
        attachParams = this-object:CreateAttachParams(pcKeyValue, pFilter, phDataset).
        this-object:Dao:attachSource(attachParams).
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Constructor for BaseRepository
     Parameters:
       input pcTempTableName - Name of the temp-table
       input pcPrimaryKeyField - Name of the primary key field
       input pcDatabaseTable - Name of the database table
       input phDatasetHandle - Handle to the dataset
     Notes: Initializes repository with entity information
    ------------------------------------------------------------------------------*/
    constructor public BaseRepository(
        input pcTempTableName as character,
        input pcPrimaryKeyField as character,
        input pcDatabaseTable as character,
        input dataset-handle phDatasetHandle):
        
        assign
            this-object:TempTableName = pcTempTableName
            this-object:PrimaryKeyField = pcPrimaryKeyField
            this-object:DatabaseTable = pcDatabaseTable
            this-object:DatasetHandle = phDatasetHandle            
            this-object:Dao = new DataAccess()
            this-object:MetadataService = new MetadataService().
            
    end constructor.
    
    /*------------------------------------------------------------------------------
     Purpose: Find entity by primary key
     Parameters:
       input pcId - Primary key value
     Returns: handle to dataset containing the entity
    ------------------------------------------------------------------------------*/
    method public handle FindById(input pcId as character):
        var generics.FilterParams filter.
        var handle dshandle.
        
        MemoryProfiler:TakeSnapshot("StartOfFindById").
        
        /* Prepare dataset and filter */
        dshandle = this-object:PrepareDatasetHandle(false).
        empty temp-table ttQueryParams.
        filter = new generics.FilterParams(
            this-object:DatabaseTable, "", pcId, output table ttQueryParams).
        
        /* Fetch data */
        this-object:AttachAndFetch(pcId, filter, dshandle).
        this-object:DatasetHandle = dshandle.
        
        return this-object:DatasetHandle:handle.
        
        catch e as Progress.Lang.Error:
            undo, throw e.
        end.
        finally:
            MemoryProfiler:TakeSnapshot("EndOfFindById").
            delete object filter no-error.
        end finally.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Find entities by filter criteria
     Parameters:
       input pFilter - Filter parameters
     Returns: handle to dataset containing matching entities
    ------------------------------------------------------------------------------*/
    method public handle FindByFilter(input pFilter as generics.FilterParams):
        var handle dshandle.
        
        MemoryProfiler:TakeSnapshot("StartOfFindByFilter").
        
        /* Prepare new dataset with cloned structure */
        dshandle = this-object:PrepareDatasetHandle(true).
        
        /* Fetch filtered data */
        this-object:AttachAndFetch(pFilter:id1, pFilter, dshandle).
        
        return dshandle.
        
        catch e as Progress.Lang.Error:
            /* Clean up on error */
            if valid-handle(dshandle) then do:
                this-object:Dao:detachSource(input dataset-handle dshandle).
                delete object dshandle no-error.
            end.
            undo, throw e.
        end catch.
        finally:
            MemoryProfiler:TakeSnapshot("EndOfFindByFilter").
        end finally.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Save a new entity
     Parameters:
       input poEntity - JSON object containing entity data
     Returns: handle to dataset containing the created entity
    ------------------------------------------------------------------------------*/
    method public handle Save(input poEntity as JsonObject):
        var handle dshandle.
        
        /* Prepare dataset */
        dshandle = this-object:PrepareDatasetHandle(false).
        
        /* Attach data source for the new entity */
        this-object:AttachAndFetch("", ?, dshandle).
        
        /* Convert JSON to dataset */
        dshandle:read-json('JsonObject', poEntity).
        
        /* Commit changes */
        this-object:Dao:commitChanges(this-object:PrimaryKeyField, 
            input-output dataset-handle dshandle by-reference).
        
        return dshandle.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Update an existing entity
     Parameters:
       input pcId - Primary key value
       input poEntity - JSON object containing updated entity data
     Returns: handle to dataset containing the updated entity
    ------------------------------------------------------------------------------*/
    method public handle UpdateEntity(input pcId as character, input poEntity as JsonObject):
        var handle dshandle.
        var generics.FilterParams filter.
        
        /* Prepare dataset and filter */
        dshandle = this-object:PrepareDatasetHandle(false).
        filter = new generics.FilterParams(
            this-object:DatabaseTable, "", pcId, output table ttQueryParams).
        
        /* Fetch existing entity */
        this-object:AttachAndFetch(pcId, filter, dshandle).
        
        /* Apply updates from JSON */
        dshandle:read-json('JsonObject', poEntity).
        
        /* Commit changes */
        this-object:Dao:commitChanges(this-object:PrimaryKeyField, 
            input-output dataset-handle dshandle by-reference).
        
        return this-object:DatasetHandle:handle.
        
        finally:
            delete object filter no-error.
        end finally.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Delete an entity by primary key
     Parameters:
       input pcId - Primary key value
     Returns: logical indicating success
    ------------------------------------------------------------------------------*/
    method public logical Delete(input pcId as character):
        var generics.FilterParams filter.
        var handle dshandle.
        
        /* Prepare dataset and filter */
        dshandle = this-object:PrepareDatasetHandle(false).
        filter = new generics.FilterParams(
            this-object:DatabaseTable, "", pcId, output table ttQueryParams).
        
        /* Fetch entity to delete */
        this-object:AttachAndFetch(pcId, filter, dshandle).
        
        /* Delete if found */
        if dshandle:get-buffer-handle(1):available then do:
            dshandle:get-buffer-handle(1):buffer-delete().
            this-object:Dao:commitChanges(this-object:PrimaryKeyField, 
                input-output dataset-handle dshandle by-reference).
            return true.
        end.
        
        return false.
        
        finally:
            delete object filter no-error.
        end finally.
    end method.
    
    /* Abstract method declaration removed to fix duplicate signature error */
    
    /*------------------------------------------------------------------------------
     Purpose: Clean up resources
    ------------------------------------------------------------------------------*/
    /*------------------------------------------------------------------------------
     Purpose: Get metadata for the entity
     Returns: longchar containing entity metadata
     Notes: Default implementation that can be overridden by subclasses
    ------------------------------------------------------------------------------*/
    method public longchar GetMetadata():
        var longchar lcModel = "".
        var handle hBuffer = ?.
        
        /* Get the first buffer from the dataset */
        hBuffer = this-object:DatasetHandle:get-buffer-handle(1).
        
        /* Use metadata service to create entity model */
        this-object:MetadataService:createEntityModel(hBuffer, output lcModel).
        
        return lcModel.
    end method.
    
    destructor public BaseRepository():
        delete object this-object:Dao no-error.
        delete object this-object:MetadataService no-error.
    end destructor.
    
end class.
