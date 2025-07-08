/*------------------------------------------------------------------------
    File        : SupplierRepository
    Purpose     : Repository implementation for suppliers entity
    Syntax      : 
    Description : Provides data access operations for suppliers
    Author(s)   : Cascade AI
    Created     : 2025-07-07
    Notes       : Repository pattern implementation for suppliers entity
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using data.BaseRepository.
using generics.FilterParams.
using Progress.Json.ObjectModel.*.

block-level on error undo, throw.

class data.SupplierRepository inherits BaseRepository:
    
    /* Dataset definition for suppliers */
    {entities/inc/suppliers.i}
    
    /* Temp-table for query parameters */
    define temp-table ttQueryParams
        field fieldname   as character 
        field fieldvalue  as character 
        index fieldname is primary unique fieldname ascending
    .
    
    /*------------------------------------------------------------------------------
     Purpose: Constructor for SupplierRepository
     Notes: Initializes repository with suppliers entity information
    ------------------------------------------------------------------------------*/
    constructor public SupplierRepository():
        /* Call super constructor with entity information */
        super("ttsupplier", "supplieridnum", "supplier", dataset dsSupplier).
    end constructor.
    
    /*------------------------------------------------------------------------------
     Purpose: Get metadata for the suppliers entity
     Returns: longchar containing entity metadata
    ------------------------------------------------------------------------------*/
    method override public longchar GetMetadata():
        var longchar lcModel = "".
        var handle hBuffer = ?.
        
        /* Get the buffer handle for the supplier temp-table */
        hBuffer = dataset dsSupplier:get-buffer-handle(1).
        
        /* Use metadata service to create entity model */
        this-object:MetadataService:createEntityModel(hBuffer, output lcModel).
        
        return lcModel.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Find suppliers by country
     Parameters:
       input pcCountry - Country code
     Returns: handle to dataset containing matching suppliers
     Notes: Example of repository-specific method
    ------------------------------------------------------------------------------*/
    method public handle FindSuppliersByCountry(input pcCountry as character):
        var generics.FilterParams filter = new generics.FilterParams(
            "supplier", 
            ?, 
            "country = '" + pcCountry + "'", 
            ?, 
            ?, 
            output table ttQueryParams).
            
        /* Use base method to find suppliers */
        return this-object:FindByFilter(filter).
        
        finally:
            delete object filter no-error.
        end finally.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Find suppliers with discount
     Parameters:
       input piMinDiscount - Minimum discount percentage
     Returns: handle to dataset containing matching suppliers
     Notes: Example of repository-specific method
    ------------------------------------------------------------------------------*/
    method public handle FindSuppliersWithDiscount(input piMinDiscount as integer):
        var generics.FilterParams filter = new generics.FilterParams(
            "supplier", 
            ?, 
            "discount >= " + string(piMinDiscount), 
            ?, 
            ?, 
            output table ttQueryParams).
            
        /* Use base method to find suppliers */
        return this-object:FindByFilter(filter).
        
        finally:
            delete object filter no-error.
        end finally.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Clean up resources
    ------------------------------------------------------------------------------*/
    destructor public SupplierRepository():
        /* Base class destructor will handle DAO cleanup */
        delete ttsupplier no-error.
    end destructor.
    
end class.
