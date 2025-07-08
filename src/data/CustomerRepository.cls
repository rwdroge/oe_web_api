/*------------------------------------------------------------------------
    File        : CustomerRepository
    Purpose     : Repository implementation for customers entity
    Syntax      : 
    Description : Provides data access operations for customers
    Author(s)   : Cascade AI
    Created     : 2025-07-07
    Notes       : Repository pattern implementation for customers entity
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using data.BaseRepository.
using generics.FilterParams.
using Progress.Json.ObjectModel.*.

block-level on error undo, throw.

class data.CustomerRepository inherits BaseRepository:
    
    /* Dataset definition for customers */
    {entities/inc/customers.i}
    
    /* Temp-table for query parameters */
    define temp-table ttQueryParams
        field fieldname   as character 
        field fieldvalue  as character 
        index fieldname is primary unique fieldname ascending
    .
    
    /*------------------------------------------------------------------------------
     Purpose: Constructor for CustomerRepository
     Notes: Initializes repository with customers entity information
    ------------------------------------------------------------------------------*/
    constructor public CustomerRepository():
        /* Call super constructor with entity information */
        super("ttcustomer", "custnum", "customer", dataset dsCustomer).
    end constructor.
    
    /*------------------------------------------------------------------------------
     Purpose: Get metadata for the customers entity
     Returns: longchar containing entity metadata
    ------------------------------------------------------------------------------*/
    method override public longchar GetMetadata():
        var longchar lcModel = "".
        var handle hBuffer = ?.
        
        /* Get the buffer handle for the customer temp-table */
        hBuffer = dataset dsCustomer:get-buffer-handle(1).
        
        /* Use metadata service to create entity model */
        this-object:MetadataService:createEntityModel(hBuffer, output lcModel).
        
        return lcModel.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Find customers by country
     Parameters:
       input pcCountry - Country code
     Returns: handle to dataset containing matching customers
     Notes: Example of repository-specific method
    ------------------------------------------------------------------------------*/
    method public handle FindCustomersByCountry(input pcCountry as character):
        var generics.FilterParams filter = new generics.FilterParams(
            "customer", 
            ?, 
            "country = '" + pcCountry + "'", 
            ?, 
            ?, 
            output table ttQueryParams).
            
        /* Use base method to find customers */
        return this-object:FindByFilter(filter).
        
        finally:
            delete object filter no-error.
        end finally.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Find customers by sales rep
     Parameters:
       input pcSalesRep - Sales representative
     Returns: handle to dataset containing matching customers
     Notes: Example of repository-specific method
    ------------------------------------------------------------------------------*/
    method public handle FindCustomersBySalesRep(input pcSalesRep as character):
        var generics.FilterParams filter = new generics.FilterParams(
            "customer", 
            ?, 
            "salesrep = '" + pcSalesRep + "'", 
            ?, 
            ?, 
            output table ttQueryParams).
            
        /* Use base method to find customers */
        return this-object:FindByFilter(filter).
        
        finally:
            delete object filter no-error.
        end finally.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Clean up resources
    ------------------------------------------------------------------------------*/
    destructor public CustomerRepository():
        /* Base class destructor will handle DAO cleanup */
        delete ttcustomer no-error.
    end destructor.
    
end class.
