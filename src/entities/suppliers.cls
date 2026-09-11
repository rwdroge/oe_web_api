 /*------------------------------------------------------------------------
    File        : suppliers
    Syntax      : 
    Author(s)   : rdroge
    Created     : Mon Jun 16 11:40:26 CEST 2025
    Notes       : Updated to use repository pattern
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using OpenEdge.BusinessLogic.BusinessEntity.
using Progress.Json.ObjectModel.*.
using data.*.

block-level on error undo, throw.

class entities.suppliers inherits BusinessEntity implements interfaces.CRUD:
    /*------------------------------------------------------------------------------
            Purpose: Supplier entity class for managing supplier data
            Notes: Implements CRUD operations for supplier records using repository pattern                                                                   
    ------------------------------------------------------------------------------*/
    
    {"entities/inc/suppliers.i"}
     
    /* Repository for data access operations */
    var data.SupplierRepository supplierRepository.
    
    /*------------------------------------------------------------------------------
            Purpose: Initialize a new instance of the suppliers class
            Notes: Sets up the supplier dataset and initializes base class                                                                      
    ------------------------------------------------------------------------------*/
    constructor public suppliers():
        super (dataset dsSupplier:HANDLE).
        /* Initialize repository */
        supplierRepository = new data.SupplierRepository().
    end constructor.
   
    /*------------------------------------------------------------------------------
            Purpose: Read supplier records based on filter criteria
            Parameters:
              input  filter  - Filter parameters for supplier query
              output hDataSet - Handle to the resulting dataset                                                                    
    ------------------------------------------------------------------------------*/
    method public void Read(input filter as generics.FilterParams, output dataset-handle hDataSet):
        /* Use repository to get suppliers */
        hDataSet = supplierRepository:FindByFilter(filter).
    end method.
    
    /*------------------------------------------------------------------------------
            Purpose: Create new supplier record from JSON data
            Parameters:
              input  jsonObject - JSON data containing supplier information
              output hDataSet   - Handle to the resulting dataset                                                                 
    ------------------------------------------------------------------------------*/
    method public void Create(input jsonObject as JsonObject, output dataset-handle hDataSet):
        /* Use repository to create supplier */
        hDataSet = supplierRepository:Save(jsonObject).
    end method.
    
    /*------------------------------------------------------------------------------
            Purpose: Update existing supplier record
            Parameters:
              input  filter     - Filter to identify supplier record
              input  jsonObject - JSON data containing updated information
              output hDataSet   - Handle to the resulting dataset                                                                  
    ------------------------------------------------------------------------------*/
    method public void UpdateRecord(input filter as generics.FilterParams, input jsonObject as JsonObject, output dataset-handle hDataSet):
        /* Use repository to update supplier */
        hDataSet = supplierRepository:UpdateEntity(filter:id1, jsonObject).
    end method.
    
    /*------------------------------------------------------------------------------
            Purpose: Delete supplier record
            Parameters:
              input  filter   - Filter to identify supplier record
              output hDataSet - Handle to the resulting dataset                                                                
    ------------------------------------------------------------------------------*/
    method public void Delete(input filter as generics.FilterParams, output dataset-handle hDataSet):
        /* Use repository to delete supplier */
        var logical lSuccess = supplierRepository:Delete(filter:id1).
        
        /* Return dataset for consistency with interface */
        hDataSet = supplierRepository:FindById(filter:id1).
    end method.
        
    /*------------------------------------------------------------------------------
            Purpose:  Get one or more records, based on a filter string                                                                     
            Notes:  Now uses repository pattern                                                                      
    ------------------------------------------------------------------------------*/
    method private void GetSuppliers(input filter as generics.FilterParams, output DATASET dsSupplier):
        /* This method is kept for backward compatibility */
        dataset dsSupplier:handle = supplierRepository:FindByFilter(filter).
    end method.
    
    /* CheckFieldList, CheckValueList, and CreateEntityModel methods are included from metadata.i */
    
    /*------------------------------------------------------------------------------
            Purpose:  Update one or more records                                                                  
            Notes:  Now uses repository pattern                                                                      
    ------------------------------------------------------------------------------*/
    method public void UpdateSupplier(input filter as generics.FilterParams, input-output DATASET dsSupplier):
        /* Convert dataset to JSON for repository update */
        var JsonObject updateJson = new JsonObject().
        updateJson:Read(dataset dsSupplier:get-buffer-handle(1):table-handle).
        
        /* Use repository to update */
        dataset dsSupplier:handle = supplierRepository:UpdateEntity(filter:id1, updateJson).
        
        finally:
            delete object updateJson no-error.
        end finally.
    end method.
    
    /*------------------------------------------------------------------------------
            Purpose:    Delete a record                                                               
            Notes:  Now uses repository pattern                                                                      
    ------------------------------------------------------------------------------*/
    method public void DeleteSupplier(input-output DATASET dsSupplier):
        /* Get ID from dataset */
        var character supplierId = dataset dsSupplier:get-buffer-handle(1):buffer-field("supplieridnum"):buffer-value().
        
        /* Use repository to delete */
        supplierRepository:Delete(supplierId).
    end method.
    
    /*------------------------------------------------------------------------------
            Purpose: Clean up resources when object is destroyed
    ------------------------------------------------------------------------------*/
    destructor public suppliers():
        delete object supplierRepository no-error.
        delete ttsupplier no-error.
    end destructor.
    
end class.
