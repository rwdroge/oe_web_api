 
 /*------------------------------------------------------------------------
    File        : customers 
    Syntax      : 
    Author(s)   : rdroge
    Created     : Thu Dec 13 12:49:18 CET 2018
    Notes       : Updated to use repository pattern
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using OpenEdge.BusinessLogic.BusinessEntity.
using Progress.Json.ObjectModel.*.
using data.*.

block-level on error undo, throw.

class entities.customers inherits BusinessEntity implements interfaces.CRUD:
    /*------------------------------------------------------------------------------
            Purpose: Entity class for customers using repository pattern                                                                     
            Notes: Refactored to use CustomerRepository for data access                                                                       
    ------------------------------------------------------------------------------*/
    
    {"entities/inc/customers.i"}
     
    define public property ttName as character no-undo initial "ttcustomer" get. set. 
    define public property piName as character no-undo initial "custnum" get. set.
    define public property dbName as character no-undo initial "customer" get. set.
    
    /* Repository for data access operations */
    var data.CustomerRepository customerRepository.
    
    /*------------------------------------------------------------------------------
            Purpose: Initialize the customers entity                                                                      
            Notes: Creates repository instance                                                                        
    ------------------------------------------------------------------------------*/
    constructor public customers():
        super (dataset dsCustomer:HANDLE).
        
        /* Initialize repository */
        customerRepository = new data.CustomerRepository().
    end constructor.
   
    method public void Read(input filter as generics.FilterParams, output dataset-handle hDataSet):
        /* Use repository to get customers */
        hDataSet = customerRepository:FindByFilter(filter).
    end method.
    
    method public void Create(input jsonObject as JsonObject, output dataset-handle hDataSet):
        /* Use repository to create customer */
        hDataSet = customerRepository:Save(jsonObject).
    end method. 
    
    method public void Update(input filter as generics.FilterParams, input jsonObject as JsonObject, output dataset-handle hDataSet):
        /* Use repository to update customer */
        hDataSet = customerRepository:Update(filter:id1, jsonObject).
    end method.
    
    method public void Delete(input filter as generics.FilterParams, output dataset-handle hDataSet):
        /* Use repository to delete customer */
        var logical lSuccess = customerRepository:Delete(filter:id1).
        
        /* Return dataset for consistency with interface */
        hDataSet = customerRepository:FindById(filter:id1).
    end method.
        
    /*------------------------------------------------------------------------------
            Purpose:  Get one or more records, based on a filter string                                                                     
            Notes:  Now uses repository pattern                                                                      
    ------------------------------------------------------------------------------*/
    method private void GetCustomers(input filter as generics.FilterParams, output DATASET dsCustomer):
        /* This method is kept for backward compatibility */
        dataset dsCustomer:handle = customerRepository:FindByFilter(filter).
    end method.
    
    /* CheckFieldList, CheckValueList, and CreateEntityModel methods are included from metadata.i */
    
    /*------------------------------------------------------------------------------
            Purpose:  Update one or more records                                                                  
            Notes:  Now uses repository pattern                                                                      
    ------------------------------------------------------------------------------*/
    method public void UpdateCustomer(input filter as generics.FilterParams, input-output DATASET dsCustomer):
        /* Convert dataset to JSON for repository update */
        var JsonObject updateJson = new JsonObject().
        updateJson:Read(dataset dsCustomer:get-buffer-handle(1):table-handle).
        
        /* Use repository to update */
        dataset dsCustomer:handle = customerRepository:Update(filter:id1, updateJson).
        
        finally:
            delete object updateJson no-error.
        end finally.
    end method.
    
    /*------------------------------------------------------------------------------
            Purpose:    Delete a record                                                               
            Notes:  Now uses repository pattern                                                                      
    ------------------------------------------------------------------------------*/
    method public void DeleteCustomer(input-output DATASET dsCustomer):
        /* Get ID from dataset */
        var character customerId = dataset dsCustomer:get-buffer-handle(1):buffer-field("custnum"):buffer-value().
        
        /* Use repository to delete */
        customerRepository:Delete(customerId).
    end method.
    
    /*------------------------------------------------------------------------------
            Purpose: Clean up resources when object is destroyed
    ------------------------------------------------------------------------------*/
    destructor public customers():
        delete object customerRepository no-error.
        delete ttcustomer no-error.
    end destructor.
    
end class.
