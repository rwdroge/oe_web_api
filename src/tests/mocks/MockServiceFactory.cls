/*------------------------------------------------------------------------
    File        : MockServiceFactory
    Purpose     : Mock service factory for testing
    Syntax      : 
    Description : Creates mock services for unit tests
    Author(s)   : 
    Created     : Tue Jul 08 11:01:23 UTC 2025
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING interfaces.IService.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS tests.mocks.MockServiceFactory:
    
    METHOD PUBLIC IService GetService(INPUT entityName AS CHARACTER):
        IF entityName = "mock" THEN
            RETURN NEW tests.mocks.MockService().
        ELSE
            RETURN ?.
    END METHOD.
    
END CLASS.
