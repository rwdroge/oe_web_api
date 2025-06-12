 
 /*------------------------------------------------------------------------
 Syntax      : 
    Author(s)   : rdroge
    Created     : Thu Dec 13 12:49:18 CET 2018
    File        : customers
    Notes       : 
  ----------------------------------------------------------------------*/
 
using Progress.Lang.*.
using Progress.Json.ObjectModel.*.
using data.*.
using OpenEdge.BusinessLogic.*.
 
block-level on error undo, throw.

class entities.customers inherits OpenEdge.BusinessLogic.BusinessEntity implements interfaces.CRUD:
    /*------------------------------------------------------------------------------
     Purpose: Customer entity class for managing customer data
     Notes: Implements CRUD operations for customer records using DataAccess layer
    ------------------------------------------------------------------------------*/
    
    /* Include customer temp-table definition */
    {"entities/inc/customers.i"}
  
    /* Public properties */
    define public property ttName  as character no-undo initial "ttcustomer" get. set.
    define public property idField as character no-undo initial "custnum"    get. set.
    define public property dbTable as character no-undo initial "customer"   get. set.
    
    /* Private members */
    var private integer iSeq.
    var private DataAccess oDao.
    
    /*------------------------------------------------------------------------------
     Purpose: Initialize a new instance of the customers class
     Notes: Sets up the customer dataset and initializes base class
    ------------------------------------------------------------------------------*/
    constructor public customers():
        super(dataset dsCustomer:handle).
    end constructor.
    
    /*------------------------------------------------------------------------------
     Purpose: Read customer records based on filter criteria
     Parameters:
       input  filter  - Filter parameters for customer query
       output hDataSet - Handle to the resulting dataset
    ------------------------------------------------------------------------------*/
    method public void read(input filter as generics.FilterParams, output dataset-handle hDataSet):
        this-object:getCustomers(filter, output dataset dsCustomer by-reference).
        hDataSet = dataset dsCustomer:handle.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Create new customer record from JSON data
     Parameters:
       input  jsonObject - JSON data containing customer information
       output hDataSet   - Handle to the resulting dataset
    ------------------------------------------------------------------------------*/
    method public void create(input jsonObject as JsonObject, output dataset-handle hDataSet):
        var handle hBuffer.
        
        
            assign oDao = new DataAccess().
            oDao:attachSource(ttName, idField, dbTable, idField, "", ?, 
                            input-output dataset dsCustomer by-reference).
            
            hBuffer = dataset dsCustomer:get-buffer-handle(1).
            hBuffer:table-handle:tracking-changes = true.
            dataset dsCustomer:read-json('JsonObject', jsonObject).
            hBuffer:table-handle:tracking-changes = false.
            
            oDao:commitChanges(idField, dataset dsCustomer by-reference).
            hDataSet = dataset dsCustomer:handle.
        
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Update existing customer record
     Parameters:
       input  filter     - Filter to identify customer record
       input  jsonObject - JSON data containing updated information
       output hDataSet   - Handle to the resulting dataset
    ------------------------------------------------------------------------------*/
    method public void update(input filter as generics.FilterParams, 
                            input jsonObject as JsonObject, 
                            output dataset-handle hDataSet):
        this-object:updateCustomer(filter, input-output dataset dsCustomer by-reference).
        hDataSet = dataset dsCustomer:handle.,.
        
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Delete customer record
     Parameters:
       input  filter   - Filter to identify customer record
       output hDataSet - Handle to the resulting dataset
    ------------------------------------------------------------------------------*/
    method public void delete(input filter as generics.FilterParams, 
                            output dataset-handle hDataSet):
        
            assign oDao = new DataAccess().
            oDao:attachSource(ttName, idField, dbTable, idField, 
                            filter:id1, filter, input-output dataset dsCustomer by-reference).
            this-object:deleteCustomer(input-output dataset dsCustomer by-reference).
        
            hDataSet = dataset dsCustomer:handle.
        
        finally:
            if valid-object(oDao) then
                oDao:detachSource(dataset dsCustomer by-reference).
        end finally.
    end method.
        
    /*------------------------------------------------------------------------------
            Purpose:  Get one or more records, based on a filter string                                                                     
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
    /*------------------------------------------------------------------------------
     Purpose: Get one or more customer records based on filter criteria
     Parameters:
       input  filter     - Filter parameters for customer query
       output dsCustomer - Customer dataset to populate
    ------------------------------------------------------------------------------*/
    method private void getCustomers(input filter as generics.FilterParams,
                                   output dataset dsCustomer):
        
            assign oDao = new DataAccess().
            oDao:attachSource(ttName, idField, dbTable, idField,
                            filter:id1, filter, input-output dataset dsCustomer by-reference).
        finally:
            if valid-object(oDao) then
                oDao:detachSource(dataset dsCustomer by-reference).
        end finally.
    end method. 
    
    {entities/inc/metadata.i &entity=customer}
    
    /*------------------------------------------------------------------------------
            Purpose:  Update one or more records                                                                  
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
    /*------------------------------------------------------------------------------
     Purpose: Update one or more customer records
     Parameters:
       input        filter     - Filter to identify customer records
       input-output dsCustomer - Customer dataset with updates
    ------------------------------------------------------------------------------*/
    method public void updateCustomer(input filter as generics.FilterParams,
                                    input-output dataset dsCustomer):
        
            assign oDao = new DataAccess().
            oDao:attachSource(ttName, idField, dbTable, idField,
                            filter:id1, filter, input-output dataset dsCustomer by-reference).
            oDao:commitChanges(idField, input-output dataset dsCustomer by-reference).
        
        finally:
            if valid-object(oDao) then
                oDao:detachSource(dataset dsCustomer by-reference).
        end finally.
    end method.
    
    /*------------------------------------------------------------------------------
            Purpose:    Delete a record                                                               
            Notes:                                                                        
    ------------------------------------------------------------------------------*/
    /*------------------------------------------------------------------------------
     Purpose: Delete customer record
     Parameters:
       input-output dsCustomer - Customer dataset with record to delete
    ------------------------------------------------------------------------------*/
    method public void deleteCustomer(input-output dataset dsCustomer):
        var handle hBuffer.
        
        
            hBuffer = dataset dsCustomer:get-buffer-handle(1).
            if hBuffer:available then
                hBuffer:buffer-delete().
        
    end method.
  
    /*------------------------------------------------------------------------------
     Purpose: Clean up resources when object is destroyed
    ------------------------------------------------------------------------------*/
    destructor public customers():
        
        if valid-object(oDao) then do:
            delete object oDao no-error.
            
        end.
        
    end destructor. 
      
end class.
