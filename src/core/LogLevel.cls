/*------------------------------------------------------------------------
    File        : LogLevel
    Purpose     : Define log levels for the logging system
    Syntax      : 
    Description : Enumeration of log levels
    Author(s)   : Cascade AI
    Created     : 2025-06-24
    Notes       : Used by the Logger class
  ----------------------------------------------------------------------*/

using Progress.Lang.*.

block-level on error undo, throw.

/* Log levels */
ENUM core.LogLevel:
    DEFINE ENUM DEBUG
                INFO
                WARN
                ERROR
                FATAL.
END ENUM.
