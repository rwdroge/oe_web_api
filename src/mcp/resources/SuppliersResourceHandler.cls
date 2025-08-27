/*------------------------------------------------------------------------
    File        : SuppliersResourceHandler
    Purpose     : MCP resource handler for Suppliers
    Syntax      : 
    Description : Handles MCP operations for the Suppliers resource
    Author(s)   : Cascade AI
    Created     : 2025-07-10
    Notes       : Implements standard methods for Suppliers resource
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using Progress.Json.ObjectModel.*.
using mcp.BaseResourceHandler.
using interfaces.IService.

block-level on error undo, throw.

class mcp.resources.SuppliersResourceHandler inherits mcp.BaseResourceHandler:
    
    /*------------------------------------------------------------------------------
     Purpose: Constructor for SuppliersResourceHandler
     Notes: Initializes resource with name and entity information
    ------------------------------------------------------------------------------*/
    constructor public SuppliersResourceHandler():
        super("suppliers", "supplier").
    end constructor.
    
    /*------------------------------------------------------------------------------
     Purpose: Get schema for custom methods
     Returns: JsonArray containing custom method schemas
     Notes: Suppliers has no custom methods currently
    ------------------------------------------------------------------------------*/
    method override protected JsonArray GetCustomMethodsSchema():
        /* Suppliers has no custom methods currently */
        return new JsonArray().
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Clean up resources
    ------------------------------------------------------------------------------*/
    destructor public SuppliersResourceHandler():
        /* No resources to clean up */
    end destructor.
    
end class.
