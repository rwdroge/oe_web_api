/*------------------------------------------------------------------------
    File        : ApplicationBootstrap
    Purpose     : Bootstrap the application
    Syntax      : 
    Description : Initializes application components and dependencies
    Author(s)   : Cascade AI
    Created     : 2025-06-24
    Notes       : Application initialization and dependency configuration
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using core.DependencyContainer.
using interfaces.*.
using data.*.
using services.*.

block-level on error undo, throw.

class core.ApplicationBootstrap:
    
    /* Singleton instance */
    define private static variable Instance as core.ApplicationBootstrap no-undo.
    
    /* Dependency container */
    define private variable Container as core.DependencyContainer no-undo.
    
    /*------------------------------------------------------------------------------
     Purpose: Private constructor for singleton pattern
     Notes: Prevents direct instantiation
    ------------------------------------------------------------------------------*/
    constructor private ApplicationBootstrap():
        super().
        
        /* Get dependency container */
        Container = DependencyContainer:GetInstance().
        
        /* Register dependencies */
        this-object:RegisterDependencies().
    end constructor.
    
    /*------------------------------------------------------------------------------
     Purpose: Get singleton instance
     Returns: ApplicationBootstrap instance
     Notes: Creates instance if it doesn't exist
    ------------------------------------------------------------------------------*/
    method public static core.ApplicationBootstrap GetInstance():
        if not valid-object(Instance) then
            Instance = new core.ApplicationBootstrap().
            
        return Instance.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Register application dependencies
     Notes: Configures dependency injection container
    ------------------------------------------------------------------------------*/
    method private void RegisterDependencies():
        /* Register repositories */
        Container:Register("interfaces.IRepository:item", "data.ItemRepository", false).
        Container:Register("interfaces.IRepository:customer", "data.CustomerRepository", false).
        Container:Register("interfaces.IRepository:order", "data.OrderRepository", false).
        Container:Register("interfaces.IRepository:supplier", "data.SupplierRepository", false).
        
        /* Register services */
        Container:Register("interfaces.IService:item", "services.ItemService", true).
        Container:Register("interfaces.IService:customer", "services.CustomerService", true).
        Container:Register("interfaces.IService:order", "services.OrderService", true).
        Container:Register("interfaces.IService:supplier", "services.SupplierService", true).
        
        /* Register other dependencies as needed */
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Get repository for entity
     Parameters:
       input pcEntityName - Name of the entity
     Returns: IRepository instance
     Notes: Resolves repository from dependency container
    ------------------------------------------------------------------------------*/
    method public IRepository GetRepository(input pcEntityName as character):
        return cast(Container:Resolve("interfaces.IRepository:" + pcEntityName), IRepository).
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Get service for entity
     Parameters:
       input pcEntityName - Name of the entity
     Returns: IService instance
     Notes: Resolves service from dependency container
    ------------------------------------------------------------------------------*/
    method public IService GetService(input pcEntityName as character):
        return cast(Container:Resolve("interfaces.IService:" + pcEntityName), IService).
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Initialize the application
     Notes: Performs any necessary startup tasks
    ------------------------------------------------------------------------------*/
    method public void Initialize():
        /* Initialize database connections */
        
        /* Initialize logging */
        
        /* Initialize other components */
        
        /* Log application start */
        message "Application initialized successfully".
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Clean up resources
    ------------------------------------------------------------------------------*/
    destructor public ApplicationBootstrap():
        /* No resources to clean up */
    end destructor.
    
end class.
