/*------------------------------------------------------------------------
    File        : test-generic-service.p
    Purpose     : Simple test to verify GenericServiceTest fixes
    Description : Tests the MockRequest and MockService implementations
    Author(s)   : Cascade AI
    Created     : 2025-08-27
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING tests.mocks.MockRequest.
USING tests.mocks.MockService.
USING tests.mocks.MockServiceFactory.
USING Progress.Json.ObjectModel.JsonObject.

BLOCK-LEVEL ON ERROR UNDO, THROW.

DEFINE VARIABLE mockRequest AS MockRequest NO-UNDO.
DEFINE VARIABLE mockService AS MockService NO-UNDO.
DEFINE VARIABLE jsonResult AS JsonObject NO-UNDO.

/* Test 1: MockRequest path parameter functionality */
MESSAGE "Testing MockRequest path parameters..." VIEW-AS ALERT-BOX.

mockRequest = NEW MockRequest("/data/mock").
mockRequest:SetPathParameter("entityname", "mock").
mockRequest:SetPathParameter("apitype", "data").

IF mockRequest:GetPathParameter("entityname") = "mock" THEN
    MESSAGE "✓ MockRequest path parameters working correctly" VIEW-AS ALERT-BOX.
ELSE
    MESSAGE "✗ MockRequest path parameters failed" VIEW-AS ALERT-BOX.

/* Test 2: MockService functionality */
MESSAGE "Testing MockService methods..." VIEW-AS ALERT-BOX.

mockService = NEW MockService().

/* Test GetById */
jsonResult = mockService:GetById("123").
IF jsonResult:GetCharacter("name") = "Mock Item 123" THEN
    MESSAGE "✓ MockService GetById working correctly" VIEW-AS ALERT-BOX.
ELSE
    MESSAGE "✗ MockService GetById failed" VIEW-AS ALERT-BOX.

/* Test Create */
DEFINE VARIABLE createData AS JsonObject NO-UNDO.
createData = NEW JsonObject().
createData:Add("name", "New Mock Item").

jsonResult = mockService:Create(createData).
IF jsonResult:GetCharacter("name") = "New Mock Item" THEN
    MESSAGE "✓ MockService Create working correctly" VIEW-AS ALERT-BOX.
ELSE
    MESSAGE "✗ MockService Create failed" VIEW-AS ALERT-BOX.

MESSAGE "Test completed successfully!" VIEW-AS ALERT-BOX.

CATCH e AS Progress.Lang.Error:
    MESSAGE "Error during testing: " e:GetMessage(1) VIEW-AS ALERT-BOX.
END CATCH.
