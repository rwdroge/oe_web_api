/*------------------------------------------------------------------------
    File        : ServiceFactory
    Purpose     : Factory for creating service instances
    Syntax      : 
    Description : Creates and manages service instances
    Author(s)   : Cascade AI
    Created     : 2025-06-24
    Notes       : Factory pattern implementation for services using DI
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using interfaces.IService.
using services.*.
using core.DependencyContainer.
using core.ApplicationBootstrap.

block-level on error undo, throw.

class webhandlers.ServiceFactory:
    
    /* Static instance for singleton pattern */
    var static webhandlers.ServiceFactory Instance.
    
    /* Dependency container */
    var DependencyContainer Container.
    
    /* Application bootstrap */
    var ApplicationBootstrap Bootstrap.
    
    /*------------------------------------------------------------------------------
     Purpose: Private constructor for singleton pattern
     Notes: Prevents direct instantiation
    ------------------------------------------------------------------------------*/
    constructor private ServiceFactory():
        super().
        
        /* Get dependency container and bootstrap */
        Container = DependencyContainer:GetInstance().
        Bootstrap = ApplicationBootstrap:GetInstance().
    end constructor.
    
    /*------------------------------------------------------------------------------
     Purpose: Get singleton instance
     Returns: ServiceFactory instance
     Notes: Creates instance if it doesn't exist
    ------------------------------------------------------------------------------*/
    method public static webhandlers.ServiceFactory GetInstance():
        if not valid-object(webhandlers.ServiceFactory:Instance) then
            webhandlers.ServiceFactory:Instance = new webhandlers.ServiceFactory().
            
        return webhandlers.ServiceFactory:Instance.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Get service for entity
     Parameters:
       input pcEntityName - Name of the entity
     Returns: IService instance
     Notes: Resolves service from dependency container
    ------------------------------------------------------------------------------*/
    method public IService GetService(input pcEntityName as character):
        var IService oService.
        
        
            /* Get service from bootstrap */
            oService = Bootstrap:GetService(pcEntityName).
            return oService.
        catch e as Progress.Lang.Error:
            /* If service not registered, try dynamic instantiation */
            oService = dynamic-new string("services." + pcEntityName + "Service") () no-error.
            
            /* If dynamic instantiation fails, throw error */
            if not valid-object(oService) then
                undo, throw new Progress.Lang.AppError(
                    "Service not found for entity: " + pcEntityName).
        end.
        
        
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Clean up resources
    ------------------------------------------------------------------------------*/
    destructor public ServiceFactory():
        /* No resources to clean up - DI container handles lifecycle */
    end destructor.
    
end class.
