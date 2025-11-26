/*------------------------------------------------------------------------
    File        : remote-test-transaction.p
    Purpose     : Test database transaction handling on AppServer
    Description : Remote procedure that tests transaction commit/rollback
    Author(s)   : 
    Created     : 
    Notes       : Called remotely via APSV transport
                  This creates and immediately deletes a test record
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.

BLOCK-LEVEL ON ERROR UNDO, THROW.

DEFINE BUFFER bCustomer FOR Customer.
DEFINE VARIABLE iTestCustNum AS INTEGER NO-UNDO.

/* Start transaction */
DO TRANSACTION:
    
    /* Find highest customer number */
    FOR EACH bCustomer NO-LOCK:
        IF bCustomer.CustNum > iTestCustNum THEN
            iTestCustNum = bCustomer.CustNum.
    END.
    
    iTestCustNum = iTestCustNum + 1.
    
    /* Create test customer */
    CREATE bCustomer.
    ASSIGN
        bCustomer.CustNum = iTestCustNum
        bCustomer.Name = "APSV Test Customer"
        bCustomer.Country = "USA"
        bCustomer.State = "MA"
        bCustomer.City = "Boston".
    
    /* Verify creation */
    FIND FIRST bCustomer NO-LOCK
        WHERE bCustomer.CustNum = iTestCustNum NO-ERROR.
    
    IF NOT AVAILABLE bCustomer THEN
        UNDO, THROW NEW Progress.Lang.AppError("Failed to create test customer", 1).
    
    /* Delete test customer */
    FIND FIRST bCustomer EXCLUSIVE-LOCK
        WHERE bCustomer.CustNum = iTestCustNum NO-ERROR.
    
    IF AVAILABLE bCustomer THEN
        DELETE bCustomer.
    
END. /* transaction */

RETURN.

CATCH e AS Progress.Lang.Error:
    MESSAGE "Error in remote-test-transaction.p:" SKIP
            e:GetMessage(1).
    UNDO, THROW e.
END CATCH.
