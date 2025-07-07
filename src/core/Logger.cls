/*------------------------------------------------------------------------
    File        : Logger
    Purpose     : Application logging system
    Syntax      : 
    Description : Provides logging functionality for the application
    Author(s)   : Cascade AI
    Created     : 2025-06-24
    Notes       : Logging framework for application events and errors
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
using Progress.Json.ObjectModel.*.
using core.LogLevel.

block-level on error undo, throw.

class core.Logger:
    
    /* Singleton instance */
    VAR private static core.Logger Instance.
    
    /* Log file handle */
    VAR private character LogFile.
    
    /* Current log level */
    VAR private LogLevel CurrentLevel.
    
    /*------------------------------------------------------------------------------
     Purpose: Private constructor for singleton pattern
     Notes: Prevents direct instantiation
    ------------------------------------------------------------------------------*/
    constructor private Logger():
        super().
        
        /* Set default log level */
        CurrentLevel = LogLevel:INFO.
        
        /* Set default log file */
        LogFile = "logs/application.log".
        
        /* Create log directory if it doesn't exist */
        file-info:file-name = "logs".
        if file-info:full-pathname = ? then
            os-command silent value("mkdir logs").
    end constructor.
    
    /*------------------------------------------------------------------------------
     Purpose: Get singleton instance
     Returns: Logger instance
     Notes: Creates instance if it doesn't exist
    ------------------------------------------------------------------------------*/
    method public static core.Logger GetInstance():
        if not valid-object(Instance) then
            Instance = new core.Logger().
            
        return Instance.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Set log level
     Parameters:
       input poLevel - Log level
     Notes: Sets minimum level for logging
    ------------------------------------------------------------------------------*/
    method public void SetLevel(input poLevel as LogLevel):
        CurrentLevel = poLevel.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Set log file
     Parameters:
       input pcLogFile - Log file path
     Notes: Sets log file path
    ------------------------------------------------------------------------------*/
    method public void SetLogFile(input pcLogFile as character):
        LogFile = pcLogFile.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Log message at DEBUG level
     Parameters:
       input pcMessage - Message to log
     Notes: Logs message if level is DEBUG or higher
    ------------------------------------------------------------------------------*/
    method public void Debug(input pcMessage as character):
        this-object:Log(LogLevel:DEBUG, pcMessage).
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Log message at INFO level
     Parameters:
       input pcMessage - Message to log
     Notes: Logs message if level is INFO or higher
    ------------------------------------------------------------------------------*/
    method public void Info(input pcMessage as character):
        this-object:Log(LogLevel:INFO, pcMessage).
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Log message at WARN level
     Parameters:
       input pcMessage - Message to log
     Notes: Logs message if level is WARN or higher
    ------------------------------------------------------------------------------*/
    method public void Warn(input pcMessage as character):
        this-object:Log(LogLevel:WARN, pcMessage).
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Log message at ERROR level
     Parameters:
       input pcMessage - Message to log
     Notes: Logs message if level is ERROR or higher
    ------------------------------------------------------------------------------*/
    method public void Error(input pcMessage as character):
        this-object:Log(LogLevel:ERROR, pcMessage).
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Log message at FATAL level
     Parameters:
       input pcMessage - Message to log
     Notes: Logs message if level is FATAL or higher
    ------------------------------------------------------------------------------*/
    method public void Fatal(input pcMessage as character):
        this-object:Log(LogLevel:FATAL, pcMessage).
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Log error object
     Parameters:
       input poError - Error object
     Notes: Logs error message and details at ERROR level
    ------------------------------------------------------------------------------*/
    method public void LogError(input poError as Progress.Lang.Error):
        define variable cMessage as character no-undo.
        define variable i as integer no-undo.
        
        /* Build error message with call stack */
        cMessage = "Error: " + poError:GetMessage(1) + "~n".
        cMessage = cMessage + "Call stack:~n".
        
        do i = 1 to poError:NumMessages:
            cMessage = cMessage + "  " + poError:GetMessage(i) + " (" + 
                       STRING(poError:GetMessageNum(i)) + ")~n".
        end.
        
        this-object:Log(LogLevel:ERROR, cMessage).
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Log message with JSON data
     Parameters:
       input poLevel - Log level
       input pcMessage - Message to log
       input poJson - JSON data to log
     Notes: Logs message with JSON data if level is appropriate
    ------------------------------------------------------------------------------*/
    method public void LogJson(
        input poLevel as LogLevel,
        input pcMessage as character,
        input poJson as JsonObject):
        
        define variable cLogMessage as character no-undo.
        
        /* Build log message with JSON data */
        cLogMessage = pcMessage + "~n" + poJson:GetJsonText().
        
        this-object:Log(poLevel, cLogMessage).
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Log message
     Parameters:
       input poLevel - Log level
       input pcMessage - Message to log
     Notes: Logs message if level is appropriate
    ------------------------------------------------------------------------------*/
    method private void Log(
        input poLevel as LogLevel,
        input pcMessage as character):
        
        define variable cTimestamp as character no-undo.
        define variable cLogMessage as character no-undo.
        define variable hLogFile as handle no-undo.
        
        /* Check if level is appropriate */
        if poLevel < CurrentLevel then
            return.
            
        /* Get timestamp */
        cTimestamp = string(now, "99/99/9999 HH:MM:SS.SSS").
        
        /* Build log message */
        cLogMessage = cTimestamp + " [" + string(poLevel) + "] " + pcMessage.
        
        /* Log to file */
        output to value(LogFile) append.
        put unformatted cLogMessage skip.
        output close.
        
        /* Also log to console for development */
        message cLogMessage.
    end method.
    
    /*------------------------------------------------------------------------------
     Purpose: Clean up resources
    ------------------------------------------------------------------------------*/
    destructor public Logger():
        /* No resources to clean up */
    end destructor.
    
end class.
