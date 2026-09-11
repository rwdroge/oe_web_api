/*------------------------------------------------------------------------
    File        : DependencyContainerTest
    Purpose     : Unit tests for DependencyContainer class
    Syntax      : 
    Description : Tests the dependency injection container functionality
    Author(s)   : 
    Created     : Tue Jul 08 10:47:23 UTC 2025
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING OpenEdge.Core.Assert.
USING core.DependencyContainer.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS tests.core.DependencyContainerTest:
    
    DEFINE PRIVATE VARIABLE container AS core.DependencyContainer NO-UNDO.
    
    /*------------------------------------------------------------------------------
     Purpose: Set up test environment before each test
     Notes:   
    ------------------------------------------------------------------------------*/
    @Setup.
    METHOD PUBLIC VOID SetUp():
        /* Get singleton instance */
        container = DependencyContainer:GetInstance().
        
        /* Clear any existing registrations for clean testing */
        container:Reset(). 
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose: Test that GetInstance returns a valid singleton instance
     Notes:   
    ------------------------------------------------------------------------------*/
    @Test.
    METHOD PUBLIC VOID TestGetInstance():
        /* Test that GetInstance returns a valid instance */
        Assert:NotNull(container, "DependencyContainer:GetInstance() should return a valid instance").
        
        /* Test that calling GetInstance again returns the same instance */
        DEFINE VARIABLE container2 AS core.DependencyContainer NO-UNDO.
        container2 = DependencyContainer:GetInstance().
        Assert:IsTrue(container = container2, "DependencyContainer:GetInstance() should return the same instance when called multiple times").
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose: Test registering and resolving a singleton component
     Notes:   
    ------------------------------------------------------------------------------*/
    @Test.
    METHOD PUBLIC VOID TestRegisterAndResolveSingleton():
        /* Create a test object */
        DEFINE VARIABLE testObj AS Progress.Lang.Object NO-UNDO.
        testObj = NEW Progress.Lang.Object().
        
        /* Register the test object as a singleton */
        container:RegisterSingleton("testKey", testObj).
        
        /* Resolve the registered object */
        DEFINE VARIABLE resolvedObj AS Progress.Lang.Object NO-UNDO.
        resolvedObj = CAST(container:Resolve("testKey"), Progress.Lang.Object).
        
        /* Test that the resolved object is the same as the registered object */
        Assert:IsTrue(testObj = resolvedObj, "Resolving a singleton should return the same instance that was registered").
        
        /* Resolve again and verify it's still the same instance */
        DEFINE VARIABLE resolvedObj2 AS Progress.Lang.Object NO-UNDO.
        resolvedObj2 = CAST(container:Resolve("testKey"), Progress.Lang.Object).
        Assert:IsTrue(testObj = resolvedObj2, "Resolving a singleton multiple times should return the same instance").
    END METHOD.
    
    
    /*------------------------------------------------------------------------------
     Purpose: Test resolving an unregistered component
     Notes:   
    ------------------------------------------------------------------------------*/
    @Test.
    METHOD PUBLIC VOID TestResolveUnregistered():
        /* Try to resolve an unregistered key */
        DEFINE VARIABLE resolvedObj AS Progress.Lang.Object NO-UNDO.
        resolvedObj = container:Resolve("unregisteredKey").
        
        /* Test that the result is null */
        Assert:IsNull(resolvedObj, "Resolving an unregistered key should return null").
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose: Test clearing the container
     Notes:   
    ------------------------------------------------------------------------------*/
    @Test.
    METHOD PUBLIC VOID TestClear():
        /* Register a test object */
        DEFINE VARIABLE testObj AS Progress.Lang.Object NO-UNDO.
        testObj = NEW Progress.Lang.Object().
        container:RegisterSingleton("testKey", testObj).
        
        /* Verify it's registered */
        DEFINE VARIABLE resolvedObj AS Progress.Lang.Object NO-UNDO.
        resolvedObj = CAST(container:Resolve("testKey"), Progress.Lang.Object).
        Assert:NotNull(resolvedObj, "Object should be resolvable after registration").
        
        /* Clear the container */
        container:Reset().
        
        /* Verify the object is no longer registered */
        resolvedObj = CAST(container:Resolve("testKey"), Progress.Lang.Object).
        Assert:IsNull(resolvedObj, "Object should not be resolvable after clearing the container").
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose: Factory method for creating test objects
     Notes:   Used for testing transient registrations
    ------------------------------------------------------------------------------*/
    METHOD PRIVATE Progress.Lang.Object CreateTestObject():
        RETURN NEW Progress.Lang.Object().
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose: Clean up after tests
     Notes:   
    ------------------------------------------------------------------------------*/
    @TearDown.
    METHOD PUBLIC VOID TearDown():
        /* Clear the container after tests */
        container:Reset().
    END METHOD.
    
END CLASS.
