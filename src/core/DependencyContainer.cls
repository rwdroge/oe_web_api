/*------------------------------------------------------------------------
    File        : DependencyContainer
    Purpose     : Simple dependency injection container
    Syntax      : 
    Description : Manages dependencies and their lifecycle
    Author(s)   : Cascade AI
    Created     : 2025-06-24
    Notes       : Dependency injection container implementation
  ----------------------------------------------------------------------*/

using Progress.Lang.*.

block-level on error undo, throw.

class core.DependencyContainer:
    
    /* Singleton instance */
    define private static variable Instance as core.DependencyContainer no-undo.
    
    /* Dependency registry */
    define private temp-table Dependencies no-undo
        field InterfaceName as character
        field ImplementationName as character
        field Singleton as logical
        field Instance as Progress.Lang.Object
        index idx1 as primary unique InterfaceName.
    
    /*------------------------------------------------------------------------------
     Purpose: Private constructor for singleton pattern
     Notes: Prevents direct instantiation
    ------------------------------------------------------------------------------*/
    constructor private DependencyContainer():
        super().
    end constructor.
    
    /*------------------------------------------------------------------------------
     Purpose: Get singleton instance
     Returns: DependencyContainer instance
     Notes: Creates instance if it doesn't exist
    ------------------------------------------------------------------------------*/
    method public static core.DependencyContainer GetInstance():
        if not valid-object(Instance) then
            Instance = new core.DependencyContainer().
            
        return Instance.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Register a dependency
     Parameters:
       input pcInterfaceName - Name of the interface
       input pcImplementationName - Name of the implementation class
       input plSingleton - Whether to use singleton pattern for this dependency
     Notes: Registers a dependency for later resolution
    ------------------------------------------------------------------------------*/
    method public void Register(
        input pcInterfaceName as character,
        input pcImplementationName as character,
        input plSingleton as logical):
        
        /* Check if dependency already exists */
        find Dependencies where Dependencies.InterfaceName = pcInterfaceName no-error.
        if available Dependencies then
            delete Dependencies.
            
        /* Register new dependency */
        create Dependencies.
        assign
            Dependencies.InterfaceName = pcInterfaceName
            Dependencies.ImplementationName = pcImplementationName
            Dependencies.Singleton = plSingleton
            Dependencies.Instance = ?.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Resolve a dependency
     Parameters:
       input pcInterfaceName - Name of the interface to resolve
     Returns: Object instance implementing the interface
     Notes: Creates or returns instance based on registration
    ------------------------------------------------------------------------------*/
    method public Progress.Lang.Object Resolve(input pcInterfaceName as character):
        define variable oInstance as Progress.Lang.Object no-undo.
        
        
        /* Find dependency registration */
        find Dependencies where Dependencies.InterfaceName = pcInterfaceName no-error.
        if not available Dependencies then
            undo, throw new Progress.Lang.AppError(
                "Dependency not registered: " + pcInterfaceName).
                
        /* Return existing instance if singleton */
        if Dependencies.Singleton and valid-object(Dependencies.Instance) then
            return Dependencies.Instance.
            
            
        /* Create new instance */
        oInstance = dynamic-new string(Dependencies.ImplementationName) () no-error.
        if not valid-object(oInstance) then
            undo, throw new Progress.Lang.AppError(
                "Failed to create instance of " + Dependencies.ImplementationName).
                
        /* Store instance if singleton */
        if Dependencies.Singleton then
            Dependencies.Instance = oInstance.
            
        return oInstance.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Register an existing object instance as a singleton
     Parameters:
       input pcInterfaceName - Name of the interface
       input poInstance - Object instance to register
     Notes: Registers an existing object instance as a singleton
    ------------------------------------------------------------------------------*/
    method public void RegisterSingleton(
        input pcInterfaceName as character,
        input poInstance as Progress.Lang.Object):
        
        /* Check if dependency already exists */
        find Dependencies where Dependencies.InterfaceName = pcInterfaceName no-error.
        if available Dependencies then
            delete Dependencies.
            
        /* Register new dependency with existing instance */
        create Dependencies.
        assign
            Dependencies.InterfaceName = pcInterfaceName
            Dependencies.ImplementationName = poInstance:GetClass():TypeName
            Dependencies.Singleton = true
            Dependencies.Instance = poInstance.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Resolve a dependency with constructor parameters
     Parameters:
       input pcInterfaceName - Name of the interface to resolve
       input poParam1 - First constructor parameter
     Returns: Object instance implementing the interface
     Notes: Creates or returns instance based on registration
    ------------------------------------------------------------------------------*/
    method public Progress.Lang.Object ResolveWithParams(
        input pcInterfaceName as character,
        input poParam1 as Progress.Lang.Object):
        
        define variable oInstance as Progress.Lang.Object no-undo.
        
        /* Find dependency registration */
        find Dependencies where Dependencies.InterfaceName = pcInterfaceName no-error.
        if not available Dependencies then
            undo, throw new Progress.Lang.AppError(
                "Dependency not registered: " + pcInterfaceName).
                
        /* Return existing instance if singleton */
        if Dependencies.Singleton and valid-object(Dependencies.Instance) then
            return Dependencies.Instance.
            
        /* Create new instance with parameter */
        oInstance = dynamic-new string(Dependencies.ImplementationName) (poParam1) no-error.
        if not valid-object(oInstance) then
            undo, throw new Progress.Lang.AppError(
                "Failed to create instance of " + Dependencies.ImplementationName).
                
        /* Store instance if singleton */
        if Dependencies.Singleton then
            Dependencies.Instance = oInstance.
            
        return oInstance.
    end method.
    
    
    /*------------------------------------------------------------------------------
     Purpose: Reset container and clear all registrations
     Notes: Useful for testing
    ------------------------------------------------------------------------------*/
    method public void Reset():
        for each Dependencies:
            delete object Dependencies.Instance no-error.
            delete Dependencies.
        end.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Clean up resources
    ------------------------------------------------------------------------------*/
    destructor public DependencyContainer():
        /* Clean up dependencies */
        for each Dependencies:
            delete object Dependencies.Instance no-error.
            delete Dependencies.
        end.
    end destructor.
    
end class.
