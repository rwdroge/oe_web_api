/*------------------------------------------------------------------------
    File        : OrdersResourceHandler
    Purpose     : MCP resource handler for Orders
    Syntax      : 
    Description : Handles MCP operations for the Orders resource
    Author(s)   : Cascade AI
    Created     : 2025-07-10
    Notes       : Implements standard methods for Orders resource
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using Progress.Json.ObjectModel.*.
using mcp.BaseResourceHandler.
using interfaces.IService.

block-level on error undo, throw.

class mcp.resources.OrdersResourceHandler inherits mcp.BaseResourceHandler:
    
    /*------------------------------------------------------------------------------
     Purpose: Constructor for OrdersResourceHandler
     Notes: Initializes resource with name and entity information
    ------------------------------------------------------------------------------*/
    constructor public OrdersResourceHandler():
        super("orders", "order").
    end constructor.
    
    /*------------------------------------------------------------------------------
     Purpose: Get schema for custom methods
     Returns: JsonArray containing custom method schemas
     Notes: Orders has no custom methods currently
    ------------------------------------------------------------------------------*/
    method override protected JsonArray GetCustomMethodsSchema():
        /* Orders has no custom methods currently */
        return new JsonArray().
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Clean up resources
    ------------------------------------------------------------------------------*/
    destructor public OrdersResourceHandler():
        /* No resources to clean up */
    end destructor.
    
end class.
