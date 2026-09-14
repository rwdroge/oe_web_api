---
name: newmethod
description: Add a new method to an existing ABL class
---

# New Method Addition Workflow

## Package: `business.logic`

This skill adds a new method to the ABL `.cls` file you specify, following the `business.logic` package conventions and the project's ABL style rules.

## Package-Level Guidelines

- Method names: action-oriented, PascalCase, `Verb` + `Noun` + `[Qualifier]`
- Default to `PROTECTED`; use `PUBLIC` only for public API; `PRIVATE` for internals
- Document package context and related methods

## Required Information

Ask the user for the following if not already provided:

1. **Class File Path**: path to the `.cls` file to edit
2. **Method Name**: e.g. `GetCustomerName`
3. **Return Type**: `VOID` or an ABL/CLASS type
4. **Access Modifier**: `PUBLIC`, `PROTECTED`, or `PRIVATE`
5. **Parameters**: e.g. `piCustNum AS INTEGER`
6. **Method Body**: the ABL implementation

## Steps

1. Read the class file and verify it contains `class ...` and `end class.`
2. Ask for any missing required information
3. Construct the method block in lowercase ABL using the new `var` statement for variables
4. Insert the method just before `end class.` using the edit tool
5. Run the project's ABL compile/lint command (e.g. `prolint -g <file>`) if available, and report errors

## Method Template

```abl
/*------------------------------------------------------------------------------
    purpose:  [short purpose]
    notes:
------------------------------------------------------------------------------*/
method {accessmodifier} {returntype} {methodname} ({parameters}):

    {methodbody}

end method. /* {methodname} */
```

## Example

To add `GetCustomerName` to `business/logic/Customer.cls`:

- **Name:** `GetCustomerName`
- **Return:** `CHARACTER`
- **Access:** `PUBLIC`
- **Parameters:** `piCustomerId AS INTEGER`
- **Body:**
  ```abl
  var character cName.
  define buffer bCustomer for Customer.

  find first bCustomer no-lock
       where bCustomer.CustNum = piCustomerId
       no-error.

  if available bCustomer then
      cName = bCustomer.Name.

  return cName.
  ```
