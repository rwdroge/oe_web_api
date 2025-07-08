/*------------------------------------------------------------------------
    File        : OrderRepository
    Purpose     : Repository implementation for orders entity
    Syntax      : 
    Description : Provides data access operations for orders
    Author(s)   : Cascade AI
    Created     : 2025-07-07
    Notes       : Repository pattern implementation for orders entity
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using data.BaseRepository.
using generics.FilterParams.
using Progress.Json.ObjectModel.*.

block-level on error undo, throw.

class data.OrderRepository inherits BaseRepository:
    
    /* Dataset definition for orders */
    {entities/inc/orders.i}
    
    /* Temp-table for query parameters */
    define temp-table ttQueryParams
        field fieldname   as character 
        field fieldvalue  as character 
        index fieldname is primary unique fieldname ascending
    .
    
    /*------------------------------------------------------------------------------
     Purpose: Constructor for OrderRepository
     Notes: Initializes repository with orders entity information
    ------------------------------------------------------------------------------*/
    constructor public OrderRepository():
        /* Call super constructor with entity information */
        super("ttorder", "ordernum", "order", dataset dsOrder).
    end constructor.
    
    /*------------------------------------------------------------------------------
     Purpose: Get metadata for the orders entity
     Returns: longchar containing entity metadata
    ------------------------------------------------------------------------------*/
    method override public longchar GetMetadata():
        var longchar lcModel = "".
        var handle hBuffer = ?.
        
        /* Get the buffer handle for the order temp-table */
        hBuffer = dataset dsOrder:get-buffer-handle(1).
        
        /* Use metadata service to create entity model */
        this-object:MetadataService:createEntityModel(hBuffer, output lcModel).
        
        return lcModel.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Find orders by customer
     Parameters:
       input piCustNum - Customer number
     Returns: handle to dataset containing matching orders
     Notes: Example of repository-specific method
    ------------------------------------------------------------------------------*/
    method public handle FindOrdersByCustomer(input piCustNum as integer):
        var generics.FilterParams filter = new generics.FilterParams(
            "order", 
            ?, 
            "custnum = " + string(piCustNum), 
            ?, 
            ?, 
            output table ttQueryParams).
            
        /* Use base method to find orders */
        return this-object:FindByFilter(filter).
        
        finally:
            delete object filter no-error.
        end finally.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Find orders by date range
     Parameters:
       input pdStartDate - Start date
       input pdEndDate - End date
     Returns: handle to dataset containing matching orders
     Notes: Example of repository-specific method
    ------------------------------------------------------------------------------*/
    method public handle FindOrdersByDateRange(input pdStartDate as date, input pdEndDate as date):
        var generics.FilterParams filter = new generics.FilterParams(
            "order", 
            ?, 
            "orderdate >= " + quoter(string(pdStartDate)) + " and orderdate <= " + quoter(string(pdEndDate)), 
            ?, 
            ?, 
            output table ttQueryParams).
            
        /* Use base method to find orders */
        return this-object:FindByFilter(filter).
        
        finally:
            delete object filter no-error.
        end finally.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Find orders by status
     Parameters:
       input pcStatus - Order status
     Returns: handle to dataset containing matching orders
     Notes: Example of repository-specific method
    ------------------------------------------------------------------------------*/
    method public handle FindOrdersByStatus(input pcStatus as character):
        var generics.FilterParams filter = new generics.FilterParams(
            "order", 
            ?, 
            "orderstatus = '" + pcStatus + "'", 
            ?, 
            ?, 
            output table ttQueryParams).
            
        /* Use base method to find orders */
        return this-object:FindByFilter(filter).
        
        finally:
            delete object filter no-error.
        end finally.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Clean up resources
    ------------------------------------------------------------------------------*/
    destructor public OrderRepository():
        /* Base class destructor will handle DAO cleanup */
        delete ttorder no-error.
    end destructor.
    
end class.
