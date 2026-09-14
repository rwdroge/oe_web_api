/*------------------------------------------------------------------------
    File        : LoggerTest
    Purpose     : Unit tests for Logger class
    Syntax      : 
    Description : Tests the logging functionality
    Author(s)   : 
    Created     : Tue Jul 08 10:49:45 UTC 2025
    Notes       : 
  ----------------------------------------------------------------------*/

USING Progress.Lang.*.
USING OpenEdge.Core.Assert.
USING core.Logger.
USING core.LogLevel.

BLOCK-LEVEL ON ERROR UNDO, THROW.

CLASS tests.core.LoggerTest:
    
    DEFINE PRIVATE VARIABLE logger AS core.Logger NO-UNDO.
    DEFINE PRIVATE VARIABLE logFilePath AS CHARACTER NO-UNDO.
    
    /*------------------------------------------------------------------------------
     Purpose: Set up test environment before each test
     Notes:   
    ------------------------------------------------------------------------------*/
    @Setup.
    METHOD PUBLIC VOID SetUp():
        /* Create a temporary log file for testing */
        logFilePath = SESSION:TEMP-DIRECTORY + "loggertest.log".
        
        /* Initialize logger with test log file */
        logger = core.Logger:GetInstance().
        logger:SetLogFile(logFilePath).
        
        /* Delete existing log file if it exists */
        FILE-INFO:FILE-NAME = logFilePath.
        IF FILE-INFO:FULL-PATHNAME NE ? THEN DO:
            OS-DELETE VALUE(logFilePath).
        END.
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose: Test logger initialization
     Notes:   
    ------------------------------------------------------------------------------*/
    @Test.
    METHOD PUBLIC VOID TestInitialization():
        /* Test that logger is properly initialized */
        Assert:NotNull(logger, "Logger should be initialized").
        
        /* Test that log file is created */
        logger:Info("Test initialization").
        FILE-INFO:FILE-NAME = logFilePath.
        Assert:IsTrue(FILE-INFO:FULL-PATHNAME NE ?, "Log file should be created after logging").
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose: Test logging at different levels
     Notes:   
    ------------------------------------------------------------------------------*/
    @Test.
    METHOD PUBLIC VOID TestLogLevels():
        /* Log messages at different levels */
        logger:Debug("Debug message").
        logger:Info("Info message").
        logger:Warn("Warning message").
        logger:Error("Error message").
        
        /* Verify log file exists and has content */
        FILE-INFO:FILE-NAME = logFilePath.
        Assert:IsTrue(FILE-INFO:FULL-PATHNAME NE ?, "Log file should exist").
        Assert:IsTrue(FILE-INFO:FILE-SIZE > 0, "Log file should have content").
        
        /* Read log file content to verify messages were logged */
        DEFINE VARIABLE logContent AS longchar NO-UNDO.
        COPY-LOB FILE logFilePath TO logContent.
        
        /* Check that messages were logged */
        Assert:IsTrue(index(string(logContent), "Debug message") > 0, "Debug message should be logged").
        Assert:IsTrue(index(string(logContent), "Info message") > 0, "Info message should be logged").
        Assert:IsTrue(index(string(logContent), "Warning message") > 0, "Warning message should be logged").
        Assert:IsTrue(index(string(logContent), "Error message") > 0, "Error message should be logged").
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose: Test log level filtering
     Notes:   
    ------------------------------------------------------------------------------*/
    @Test.
    METHOD PUBLIC VOID TestLogLevelFiltering():
        /* Create a new logger with INFO level */
        DEFINE VARIABLE infoLogger AS core.Logger NO-UNDO.
        DEFINE VARIABLE infoLogPath AS CHARACTER NO-UNDO.
        infoLogPath = SESSION:TEMP-DIRECTORY + "infolevel.log".
        
        /* Delete existing log file if it exists */
        FILE-INFO:FILE-NAME = infoLogPath.
        IF FILE-INFO:FULL-PATHNAME NE ? THEN DO:
            OS-DELETE VALUE(infoLogPath).
        END.
        
        /* Create logger with INFO level */
        infoLogger = core.Logger:GetInstance().
        infoLogger:SetLevel(LogLevel:INFO).
        infoLogger:SetLogFile(infoLogPath).
        
        /* Log messages at different levels */
        infoLogger:Debug("Debug message").  /* Should not be logged */
        infoLogger:Info("Info message").    /* Should be logged */
        infoLogger:Warn("Warning message"). /* Should be logged */
        infoLogger:Error("Error message").  /* Should be logged */
        
        /* Read log file content */
        DEFINE VARIABLE logContent AS longchar NO-UNDO.
        COPY-LOB FILE infoLogPath TO logContent.
        
        /* Check that only messages at INFO level and above were logged */
        Assert:IsFalse(index(string(logContent), "Debug message") > 0, "Debug message should NOT be logged when level is INFO").
        Assert:IsTrue(index(string(logContent), "Info message") > 0, "Info message should be logged when level is INFO").
        Assert:IsTrue(index(string(logContent), "Warning message") > 0, "Warning message should be logged when level is INFO").
        Assert:IsTrue(index(string(logContent), "Error message") > 0, "Error message should be logged when level is INFO").
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose: Test logging exceptions
     Notes:   
    ------------------------------------------------------------------------------*/
    @Test.
    METHOD PUBLIC VOID TestLogException():
        /* Create a test exception */
        DEFINE VARIABLE testException AS Progress.Lang.Error NO-UNDO.
        testException = NEW Progress.Lang.AppError("Test exception message", 1000).
        
        /* Log the exception */
        logger:LogError(testException).
        
        /* Read log file content */
        DEFINE VARIABLE logContent AS longchar NO-UNDO.
        COPY-LOB FILE logFilePath TO logContent.
        
        /* Check that exception details were logged */
        Assert:IsTrue(index(string(logContent), "Test exception message") > 0, "Exception message should be logged").
        Assert:IsTrue(index(string(logContent), "1000") > 0, "Exception number should be logged").
    END METHOD.
    
    /*------------------------------------------------------------------------------
     Purpose: Clean up after tests
     Notes:   
    ------------------------------------------------------------------------------*/
    @TearDown.
    METHOD PUBLIC VOID TearDown():
        /* Delete test log files */
        FILE-INFO:FILE-NAME = logFilePath.
        IF FILE-INFO:FULL-PATHNAME NE ? THEN DO:
            OS-DELETE VALUE(logFilePath).
        END.
        
        FILE-INFO:FILE-NAME = SESSION:TEMP-DIRECTORY + "infolevel.log".
        IF FILE-INFO:FULL-PATHNAME NE ? THEN DO:
            OS-DELETE VALUE(FILE-INFO:FULL-PATHNAME).
        END.
    END METHOD.
    
END CLASS.
