/*------------------------------------------------------------------------
    File        : TestableRepository
    Purpose     : Concrete implementation of BaseRepository for testing
    Syntax      : 
    Description : Test helper class for BaseRepository unit tests
    Author(s)   : Cascade AI
    Created     : 2025-12-19
    Notes       : Allows testing of abstract BaseRepository class
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using data.BaseRepository.

block-level on error undo, throw.

class tests.data.TestableRepository inherits BaseRepository:
    
    define private temp-table ttTestEntity no-undo
        field TestId as integer
        field TestName as character
        field TestValue as character
        index TestId is primary unique TestId ascending.
    
    define private dataset dsTestEntity for ttTestEntity.
    
    constructor public TestableRepository():
        super("ttTestEntity", "TestId", "TestTable", dataset dsTestEntity:handle).
    end constructor.
    
end class.
