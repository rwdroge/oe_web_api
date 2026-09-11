---
name: newclass
description: Create a new ABL class
---

# New ABL Class Creation Workflow

This skill creates a new ABL `.cls` file with the proper structure, inheritance, and placeholders.

## Required Information

Ask the user for the following if not already provided:

1. **Class Name**: PascalCase, e.g. `Customer`
2. **Package/Directory**: e.g. `business/logic` or leave blank for root
3. **File Path**: where to create the `.cls` file (derive from package + class name if not given)
4. **Inherits**: base class, e.g. `BusinessEntity`, `Progress.Lang.Object`, or `none`
5. **Implements**: comma-separated interfaces, or `none`
6. **Include Dataset**: path to a dataset include (`.i`), or leave blank
7. **USE-WIDGET-POOL**: `yes` (default) or `no`

## Steps

1. Ask for any missing required information
2. Ensure the target directory exists using `exec` (`New-Item -ItemType Directory -Force`)
3. Write the new `.cls` file using the template below, substituting the user's choices
4. Use the OpenEdge MCP server to verify ABL syntax if it is available
5. Run the project's ABL compile/lint command (e.g. `prolint -g <file>`) if available, and report errors

## Class Template

```abl
/*------------------------------------------------------------------------
  file        : [ClassName].cls
  purpose     : [short purpose]
  syntax      : 
  description : 
  author(s)   : 
  created     : [current date]
  notes       : 
----------------------------------------------------------------------*/

using Progress.Lang.*.
[add additional using statements for base class and interfaces]

block-level on error undo, throw.

class [package].[ClassName] [inherits BaseClass] [implements Interfaces] use-widget-pool:
    
    [dataset include if provided]
    /* {path/to/dataset.i} */
    
    [class-level var declarations if needed]
    
    /*------------------------------------------------------------------------------
     purpose: constructor for [ClassName]
     notes:
    ------------------------------------------------------------------------------*/
    constructor public [ClassName]():
        super().
    end constructor.
    
    /*------------------------------------------------------------------------------
     purpose: example method
     notes:
    ------------------------------------------------------------------------------*/
    method public void ExampleMethod():
        /* method implementation */
    end method.
    
end class.
```

## Notes

- Use lowercase ABL keywords and the `var` statement for variables.
- Add placeholder methods (Read, Create, Update, Delete, Validation, Business logic) if the class inherits `BusinessEntity` or the user requests them.
- Keep the file focused on structure; leave implementation for the user or another skill.
