 /*------------------------------------------------------------------------
    File        : suppliers
    Syntax      : 
    Author(s)   : rdroge
    Created     : Mon Jun 16 11:40:26 CEST 2025
    Notes       : 
  ----------------------------------------------------------------------*/


using Progress.Lang.*.
using OpenEdge.BusinessLogic.BusinessEntity.
using Progress.Json.ObjectModel.*.
using data.*.

block-level on error undo, throw.

class entities.suppliers inherits BusinessEntity implements interfaces.CRUD:
    /*------------------------------------------------------------------------------
            Purpose: Supplier entity class for managing supplier data
            Notes: Implements CRUD operations for supplier records using DataAccess layer                                                                   
    ------------------------------------------------------------------------------*/
    
    {"entities/inc/suppliers.i"}
     
    define public property ttName as character no-undo initial "ttsupplier" get. set. 
    define public property piName as character no-undo initial "supplieridnum" get. set.
    define public property dbName as character no-undo initial "supplier" get. set.
    
    var private integer iSeq.
    var private DataAccess dao.
    
    /*------------------------------------------------------------------------------
            Purpose: Initialize a new instance of the suppliers class
            Notes: Sets up the supplier dataset and initializes base class                                                                      
    ------------------------------------------------------------------------------*/
    constructor public suppliers():
        super (dataset dsSupplier:HANDLE).
        
    end constructor.
   
    /*------------------------------------------------------------------------------
            Purpose: Read supplier records based on filter criteria
            Parameters:
              input  filter  - Filter parameters for supplier query
              output hDataSet - Handle to the resulting dataset                                                                    
    ------------------------------------------------------------------------------*/
    method public void Read(input filter as generics.FilterParams, output dataset-handle hDataSet):
        this-object:GetSuppliers(filter, output dataset dsSupplier by-reference).
        hDataSet = dataset dsSupplier:handle.    
    end method.
    
    /*------------------------------------------------------------------------------
            Purpose: Create new supplier record from JSON data
            Parameters:
              input  jsonObject - JSON data containing supplier information
              output hDataSet   - Handle to the resulting dataset                                                                 
    ------------------------------------------------------------------------------*/
    method public void Create(input jsonObject as JsonObject, output dataset-handle hDataSet):
        
        assign dao = new DataAccess().
        dao:attachSource("ttsupplier", "supplieridnum", "supplier", "supplieridnum", "", ?, input-output dataset dsSupplier by-reference).
        dataset dsSupplier:get-buffer-handle(1):table-handle:tracking-changes = true.
        dataset dsSupplier:read-json('JsonObject', jsonObject).
        dataset dsSupplier:get-buffer-handle(1):table-handle:tracking-changes = false.
        
        dao:CommitChanges(piName, dataset dsSupplier by-reference).
        hDataSet = dataset dsSupplier:handle.
    
    end method.
    
    /*------------------------------------------------------------------------------
            Purpose: Update existing supplier record
            Parameters:
              input  filter     - Filter to identify supplier record
              input  jsonObject - JSON data containing updated information
              output hDataSet   - Handle to the resulting dataset                                                                  
    ------------------------------------------------------------------------------*/
    method public void Update(input filter as generics.FilterParams, input jsonObject as JsonObject, output dataset-handle hDataSet):
        define variable hChanges as handle.
        
        assign dao = new DataAccess().
        dao:attachSource("ttsupplier", "supplieridnum", "supplier", "supplieridnum", filter:id1, filter, input-output dataset dsSupplier by-reference).
        
        create dataset hChanges.
        hChanges:create-like(dataset dsSupplier:handle).
        hChanges:read-json('JsonObject', jsonObject).
        
        hChanges:get-changes(dataset dsSupplier:handle).
        hChanges:merge-changes(dataset dsSupplier:handle).
        
        dao:CommitChanges(piName, input-output dataset dsSupplier by-reference).
        hDataSet = dataset dsSupplier:handle.
    
    end method.
    
    /*------------------------------------------------------------------------------
            Purpose: Delete supplier record
            Parameters:
              input  filter   - Filter to identify supplier record
              output hDataSet - Handle to the resulting dataset                                                                
    ------------------------------------------------------------------------------*/
    method public void Delete(input filter as generics.FilterParams, output dataset-handle hDataSet):
        
        assign dao = new DataAccess().
        dao:attachSource("ttsupplier", "supplieridnum", "supplier", "supplieridnum", filter:id1, filter, input-output dataset dsSupplier by-reference).
        this-object:DeleteSupplier(input-output dataset dsSupplier by-reference);
        hDataSet = dataset dsSupplier:handle.
        
        finally:
            if valid-object(dao) then
                dao:detachSource(dataset dsSupplier by-reference).
        end finally.
    
    end method.
        
    /*------------------------------------------------------------------------------
            Purpose: Get one or more supplier records based on filter criteria
            Parameters:
              input  filter      - Filter parameters for supplier query
              output dsSupplier - Supplier dataset to populate                                                                     
    ------------------------------------------------------------------------------*/
    method private void GetSuppliers(input filter as generics.FilterParams, output DATASET dsSupplier):
        
        assign dao = new DataAccess().
        dao:attachSource(this-object:ttName, this-object:piName, this-object:dbName, this-object:piName, filter:id1, filter, input-output dataset dsSupplier by-reference).
        
        finally:
            if valid-object(dao) then
                dao:detachSource(dataset dsSupplier by-reference).
        end finally.
            
    end method.
    
    {entities/inc/metadata.i &entity=supplier}
    
    /*------------------------------------------------------------------------------
            Purpose: Update one or more supplier records
            Parameters:
              input        filter      - Filter to identify supplier records
              input-output dsSupplier - Supplier dataset with updates                                                                  
    ------------------------------------------------------------------------------*/
    method public void UpdateSuppliers(input filter as generics.FilterParams, input-output DATASET dsSupplier):            
    
        assign dao = new DataAccess().
        dao:attachSource("ttsupplier", "supplieridnum", "supplier", "supplieridnum", filter:id1, filter, input-output dataset dsSupplier by-reference).
        dao:CommitChanges(piName, input-output dataset dsSupplier by-reference);
        
        finally:
            if valid-object(dao) then
                dao:detachSource(dataset dsSupplier by-reference).
        end finally.
              
    end method.
    
    /*------------------------------------------------------------------------------
            Purpose: Delete supplier record
            Parameters:
              input-output dsSupplier - Supplier dataset with record to delete                                                               
    ------------------------------------------------------------------------------*/
    method public void DeleteSupplier(input-output DATASET dsSupplier):
        var handle hBuffer.
        
        hBuffer = dataset dsSupplier:get-buffer-handle(1).
        if hBuffer:available then
            hBuffer:buffer-delete().
    
    end method.
    
    /*------------------------------------------------------------------------------
            Purpose: Clean up resources when object is destroyed
    ------------------------------------------------------------------------------*/
    destructor public suppliers():
        if valid-object(dao) then do:
            delete object dao no-error.
        end.
    end destructor.
      
end class.
