/*------------------------------------------------------------------------
    File        : orders
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

class entities.orders inherits BusinessEntity implements interfaces.CRUD:
    /*------------------------------------------------------------------------------
            Purpose: Entity class for orders using repository pattern                                                                     
            Notes: Refactored to use OrderRepository for data access                                                                       
    ------------------------------------------------------------------------------*/
    
    {"entities/inc/orders.i"}
  
    define public property ttName as character no-undo initial "ttorder" get. set. 
    define public property piName as character no-undo initial "ordernum" get. set.
    define public property dbName as character no-undo initial "order" get. set.
    
    /* Repository for data access operations */
    var data.OrderRepository orderRepository.
    
    /*------------------------------------------------------------------------------
            Purpose: Initialize the orders entity                                                                      
            Notes: Creates repository instance                                                                        
    ------------------------------------------------------------------------------*/
    constructor public orders():
        super (dataset dsOrder:HANDLE).
        
        /* Initialize repository */
        orderRepository = new data.OrderRepository().
    end constructor.
    
    method public void Read(input filter as generics.FilterParams, output dataset-handle hDataSet):
        /* Use repository to get orders */
        message " i am here".
        hDataSet = orderRepository:FindByFilter(filter).
    end method.
    
    method public void Create(input jsonObject as JsonObject, output dataset-handle hDataSet):
        /* Use repository to create order */
        hDataSet = orderRepository:Save(jsonObject).
    end method.
    
    method public void Update(input filter as generics.FilterParams, input jsonObject as JsonObject, output dataset-handle hDataSet):
        /* Use repository to update order */
        hDataSet = orderRepository:Update(filter:id1, jsonObject).
    end method.
    
    method public void Delete(input filter as generics.FilterParams, output dataset-handle hDataSet):
        /* Use repository to delete order */
        var logical lSuccess = orderRepository:Delete(filter:id1).
        
        /* Return dataset for consistency with interface */
        hDataSet = orderRepository:FindById(filter:id1).
    end method.
        
    /*------------------------------------------------------------------------------
            Purpose:  Get one or more records, based on a filter string                                                                     
            Notes:  Now uses repository pattern                                                                      
    ------------------------------------------------------------------------------*/
    method private void GetOrders(input filter as generics.FilterParams, output DATASET dsOrder):
        /* This method is kept for backward compatibility */
        dataset dsOrder:handle = orderRepository:FindByFilter(filter).
    end method.
    
    /* CheckFieldList, CheckValueList, and CreateEntityModel methods are included from metadata.i */
    
    /*------------------------------------------------------------------------------
            Purpose:  Update one or more records                                                                  
            Notes:  Now uses repository pattern                                                                      
    ------------------------------------------------------------------------------*/
    method public void UpdateOrders(input filter as generics.FilterParams, input-output DATASET dsOrder):
        /* Convert dataset to JSON for repository update */
        var JsonObject updateJson = new JsonObject().
        updateJson:Read(dataset dsOrder:get-buffer-handle(1):table-handle).
        
        /* Use repository to update */
        dataset dsOrder:handle = orderRepository:Update(filter:id1, updateJson).
        
        finally:
            delete object updateJson no-error.
        end finally.
    end method.
    
    /*------------------------------------------------------------------------------
            Purpose:    Delete a record                                                               
            Notes:  Now uses repository pattern                                                                      
    ------------------------------------------------------------------------------*/
    method public void DeleteOrder(input-output DATASET dsOrder):
        /* Get ID from dataset */
        var character orderId = dataset dsOrder:get-buffer-handle(1):buffer-field("ordernum"):buffer-value().
        
        /* Use repository to delete */
        orderRepository:Delete(orderId).
    end method.
    
    /*------------------------------------------------------------------------------
            Purpose: Clean up resources when object is destroyed
    ------------------------------------------------------------------------------*/
    destructor public orders():
        delete object orderRepository no-error.
        delete ttorder no-error.
    end destructor.
    
end class.
