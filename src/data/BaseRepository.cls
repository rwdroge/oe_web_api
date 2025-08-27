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
        /* Create filter for primary key lookup */
        var generics.FilterParams filter.
        var handle dshandle.
        VAR DataSourceAttachParams attachParams.
        create dataset dshandle.
        dshandle = this-object:DatasetHandle.
        empty temp-table ttQueryParams.
        filter = new generics.FilterParams(
            this-object:DatabaseTable, ?, ?, pcId, ?, output table ttQueryParams).
        
            
        /* Use data access object to fetch data */
        attachParams = NEW DataSourceAttachParams(
            this-object:TempTableName,
            this-object:PrimaryKeyField,
            this-object:DatabaseTable,
            this-object:PrimaryKeyField,
            pcId,
            filter,
            dshandle).
        this-object:Dao:attachSource(attachParams).
            
        this-object:DatasetHandle = dshandle.
        
        /* Return dataset handle */
        return this-object:DatasetHandle:handle.
        catch e as Progress.Lang.Error:
            undo, throw e.
        end.
        finally:
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
        var handle dshandle = ?.
        VAR DataSourceAttachParams attachParams.
        
        /* Create a new dataset handle for each request */
        create dataset dshandle.
        
        /* Clone the structure from the template dataset */
        dshandle:create-like(this-object:DatasetHandle).
       
        /* Use data access object to fetch filtered data */
        attachParams = NEW DataSourceAttachParams(
            this-object:TempTableName,
            this-object:PrimaryKeyField,
            this-object:DatabaseTable,
            this-object:PrimaryKeyField,
            pFilter:id1,
            pFilter,
            dshandle).
        this-object:Dao:attachSource(attachParams).
        
        /* Return the new dataset handle - caller is responsible for cleanup */
        
        return dshandle.
        
        catch e as Progress.Lang.Error:
            /* Clean up on error */
            if valid-handle(dshandle) then do:
                this-object:Dao:detachSource(input dataset-handle dshandle).
                delete object dshandle no-error.
            end.
            undo, throw e.
        end catch.
       
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Save a new entity
     Parameters:
       input poEntity - JSON object containing entity data
     Returns: handle to dataset containing the created entity
    ------------------------------------------------------------------------------*/
    method public handle Save(input poEntity as JsonObject):
        var handle dshandle.
        VAR DataSourceAttachParams attachParams.
        create dataset dshandle.
        dshandle = this-object:DatasetHandle.
        /* Attach data source for the new entity */
        attachParams = NEW DataSourceAttachParams(
            this-object:TempTableName,
            this-object:PrimaryKeyField,
            this-object:DatabaseTable,
            this-object:PrimaryKeyField,
            "",
            ?,
            dshandle).
        this-object:Dao:attachSource(attachParams).
            
        /* Convert JSON to dataset */
        dshandle:read-json('JsonObject', poEntity).
        
        /* Commit changes to database */
        this-object:Dao:commitChanges(this-object:PrimaryKeyField, 
                                     input-output dataset-handle dshandle by-reference).
                                     
        /* Return dataset handle */
        return dshandle.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Update an existing entity
     Parameters:
       input pcId - Primary key value
       input poEntity - JSON object containing updated entity data
     Returns: handle to dataset containing the updated entity
    ------------------------------------------------------------------------------*/
    method public handle Update(input pcId as character, input poEntity as JsonObject):
        var handle dshandle.
        VAR DataSourceAttachParams attachParams.
        
        /* Create filter for primary key lookup */
        var generics.FilterParams filter = new generics.FilterParams(
            this-object:DatabaseTable, ?, ?, pcId, ?, output table ttQueryParams).
        
            create dataset dshandle.
            dshandle = this-object:DatasetHandle.    
        /* Attach data source for the entity */
        attachParams = NEW DataSourceAttachParams(
            this-object:TempTableName,
            this-object:PrimaryKeyField,
            this-object:DatabaseTable,
            this-object:PrimaryKeyField,
            pcId,
            filter,
            dshandle).
        this-object:Dao:attachSource(attachParams).
            
        /* Apply updates from JSON */
        dshandle:read-json('JsonObject', poEntity).
        
        /* Commit changes to database */
        this-object:Dao:commitChanges(this-object:PrimaryKeyField, 
                                     input-output dataset-handle dshandle by-reference).
                                     
        /* Return dataset handle */
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
        /* Create filter for primary key lookup */
        var generics.FilterParams filter = new generics.FilterParams(
            this-object:DatabaseTable, ?, ?, pcId, ?, output table ttQueryParams).
            var handle dshandle.
            VAR DataSourceAttachParams attachParams.
            create dataset dshandle.
            dshandle = this-object:DatasetHandle.    
        /* Attach data source for the entity */
        attachParams = NEW DataSourceAttachParams(
            this-object:TempTableName,
            this-object:PrimaryKeyField,
            this-object:DatabaseTable,
            this-object:PrimaryKeyField,
            pcId,
            filter,
            dshandle).
        this-object:Dao:attachSource(attachParams).
            
        /* Delete the entity */
        if dshandle:get-buffer-handle(1):available then do:
            dshandle:get-buffer-handle(1):buffer-delete().
            this-object:Dao:commitChanges(  this-object:PrimaryKeyField, 
                                            input-output dataset-handle dshandle by-reference).
            return true.
        end.
        else
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
        message " what the fuck".
        
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
