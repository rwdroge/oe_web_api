/*------------------------------------------------------------------------
    File        : CacheManagerTest
    Purpose     : Unit tests for CacheManager class
    Syntax      : 
    Description : Tests the cache management functionality
    Author(s)   : 
    Created     : Tue Jul 08 10:56:45 UTC 2025
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using OpenEdge.Core.Assert.
using OpenEdge.Core.*.
using core.CacheManager.

block-level on error undo, throw.

class tests.core.CacheManagerTest:
    
    define private variable cacheManager as core.CacheManager no-undo.
    
    /*------------------------------------------------------------------------------
     Purpose: Set up test environment before each test
     Notes:   
    ------------------------------------------------------------------------------*/
    @Setup.
    method public void SetUp():
        /* Get singleton instance */
        cacheManager = core.CacheManager:GetInstance().
        
        /* Clear cache for clean testing */
        cacheManager:Clear().
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Test that GetInstance returns a valid singleton instance
     Notes:   
    ------------------------------------------------------------------------------*/
    @Test.
    method public void TestGetInstance():
        /* Test that GetInstance returns a valid instance */
        Assert:NotNull(cacheManager, "CacheManager:GetInstance() should return a valid instance").
        
        /* Test that calling GetInstance again returns the same instance */
        define variable cacheManager2 as core.CacheManager no-undo.
        cacheManager2 = core.CacheManager:GetInstance().
        Assert:IsTrue(cacheManager = cacheManager2, "CacheManager:GetInstance() should return the same instance when called multiple times").
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Test Set and Get methods
     Notes:   
    ------------------------------------------------------------------------------*/
    @Test.
    method public void TestSetAndGet():
        /* Set a string value */
        define variable objValue as Progress.Lang.Object no-undo.
        objValue = new Progress.Lang.Object().
        cacheManager:Set("testKey", objValue, 3600).
        
        /* Get the value */
        define variable cacheValue as Progress.Lang.Object no-undo.
        cacheValue = cacheManager:Get("testKey").
        
        /* Verify the value */
        Assert:IsTrue(cacheValue = objValue, "Get should return the value that was set").
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Test Get with non-existent key
     Notes:   
    ------------------------------------------------------------------------------*/
    @Test.
    method public void TestGetNonExistentKey():
        /* Get a value for a key that doesn't exist */
        define variable cacheValue as Progress.Lang.Object no-undo.
        cacheValue = cacheManager:Get("nonExistentKey").
        
        /* Verify the value is null */
        Assert:IsNull(cacheValue, "Get should return null for a non-existent key").
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Test Contains method
     Notes:   
    ------------------------------------------------------------------------------*/
    @Test.
    method public void TestContains():
        /* Set a value */
        define variable objValue as Progress.Lang.Object no-undo.
        objValue = new Progress.Lang.Object().
        cacheManager:Set("testKey", objValue, 3600).
        
        /* Test Contains with existing key */
        define variable containsExisting as logical no-undo.
        containsExisting = cacheManager:Contains("testKey").
        
        /* Test Contains with non-existent key */
        define variable containsNonExistent as logical no-undo.
        containsNonExistent = cacheManager:Contains("nonExistentKey").
        
        /* Verify results */
        Assert:IsTrue(containsExisting, "Contains should return TRUE for an existing key").
        Assert:IsFalse(containsNonExistent, "Contains should return FALSE for a non-existent key").
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Test Remove method
     Notes:   
    ------------------------------------------------------------------------------*/
    @Test.
    method public void TestRemove():
        /* Set a value */
        define variable objValue as Progress.Lang.Object no-undo.
        objValue = new Progress.Lang.Object().
        cacheManager:Set("testKey", objValue, 3600).
        
        /* Verify it's in the cache */
        Assert:IsTrue(cacheManager:Contains("testKey"), "Key should be in cache after Set").
        
        /* Remove the key */
        cacheManager:Remove("testKey").
        
        /* Verify it's no longer in the cache */
        Assert:IsFalse(cacheManager:Contains("testKey"), "Key should not be in cache after Remove").
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Test Clear method
     Notes:   
    ------------------------------------------------------------------------------*/
    @Test.
    method public void TestClear():
        /* Set multiple values */
        define variable objValue1 as Progress.Lang.Object no-undo.
        define variable objValue2 as Progress.Lang.Object no-undo.
        define variable objValue3 as Progress.Lang.Object no-undo.
        
        objValue1 = new Progress.Lang.Object().
        objValue2 = new Progress.Lang.Object().
        objValue3 = new Progress.Lang.Object().
        
        cacheManager:Set("testKey1", objValue1, 3600).
        cacheManager:Set("testKey2", objValue2, 3600).
        cacheManager:Set("testKey3", objValue3, 3600).
        
        /* Verify they're in the cache */
        Assert:IsTrue(cacheManager:Contains("testKey1"), "Key1 should be in cache after Set").
        Assert:IsTrue(cacheManager:Contains("testKey2"), "Key2 should be in cache after Set").
        Assert:IsTrue(cacheManager:Contains("testKey3"), "Key3 should be in cache after Set").
        
        /* Clear all cache */
        cacheManager:Clear().
        
        /* Verify all keys are removed */
        Assert:IsFalse(cacheManager:Contains("testKey1"), "Key1 should not be in cache after Clear").
        Assert:IsFalse(cacheManager:Contains("testKey2"), "Key2 should not be in cache after Clear").
        Assert:IsFalse(cacheManager:Contains("testKey3"), "Key3 should not be in cache after Clear").
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Test cache with different types of objects
     Notes:   
    ------------------------------------------------------------------------------*/
    @Test.
    method public void TestDifferentObjectTypes():
        /* Set different types of objects */
        define variable stringValue as character no-undo initial "stringValue".
        define variable intValue as integer no-undo initial 123.
        define variable logicalValue as logical no-undo initial true.
        define variable dateValue as date no-undo initial today.
        define variable objValue as Progress.Lang.Object no-undo.
        
        /* Create the object value */
        objValue = new Progress.Lang.Object().
        
        /* Store values in cache */
        cacheManager:Set("stringKey", new OpenEdge.Core.String(stringValue), 3600).
        cacheManager:Set("integerKey", new OpenEdge.Core.Integer(intValue), 3600).
        cacheManager:Set("logicalKey", new OpenEdge.Core.LogicalValue(logicalValue), 3600).
        cacheManager:Set("dateKey", new OpenEdge.Core.DateHolder(dateValue), 3600).
        cacheManager:Set("objectKey", objValue, 3600).
        
        /* Verify they're in the cache */
        Assert:IsTrue(cacheManager:Contains("stringKey"), "String key should be in cache after Set").
        Assert:IsTrue(cacheManager:Contains("integerKey"), "Integer key should be in cache after Set").
        Assert:IsTrue(cacheManager:Contains("logicalKey"), "Logical key should be in cache after Set").
        Assert:IsTrue(cacheManager:Contains("dateKey"), "Date key should be in cache after Set").
        Assert:IsTrue(cacheManager:Contains("objectKey"), "Object key should be in cache after Set").
        
        /* Get and verify values */
        define variable retrievedString as OpenEdge.Core.String no-undo.
        define variable retrievedInteger as OpenEdge.Core.Integer no-undo.
        define variable retrievedLogical as OpenEdge.Core.LogicalValue no-undo.
        define variable retrievedDate as OpenEdge.Core.DateHolder no-undo.
        
        retrievedString = cast(cacheManager:Get("stringKey"), OpenEdge.Core.String).
        retrievedInteger = cast(cacheManager:Get("integerKey"), OpenEdge.Core.Integer).
        retrievedLogical = cast(cacheManager:Get("logicalKey"), OpenEdge.Core.LogicalValue).
        retrievedDate = cast(cacheManager:Get("dateKey"), OpenEdge.Core.DateHolder).
        
        Assert:Equals(retrievedString:Value, stringValue).
        Assert:Equals(retrievedInteger:Value, intValue).
        Assert:Equals(retrievedLogical:Value, logicalValue).
        Assert:Equals(retrievedDate:Value, dateValue).
        Assert:Equals(cacheManager:Get("objectKey"), objValue).
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Clean up after tests
     Notes:   
    ------------------------------------------------------------------------------*/
    @TearDown.
    method public void TearDown():
        /* Clear cache after tests */
        cacheManager:Clear().
    end method.
    
end class.
