---
name: newproperty
description: Add a new property to an existing class
---

# New Property Addition Workflow

This skill adds a new property to the ABL `.cls` file you specify.

## Required Information

Ask the user for the following if not already provided:

1. **Class File Path**: path to the `.cls` file to edit
2. **Property Name**: e.g. `CustomerName`
3. **Property Type**: ABL data type or class name
4. **GET Access**: `PUBLIC`, `PROTECTED`, `PACKAGE-PROTECTED`, `PACKAGE-PRIVATE`, or `PRIVATE`
5. **SET Access**: `PUBLIC`, `PROTECTED`, `PACKAGE-PROTECTED`, `PACKAGE-PRIVATE`, `PRIVATE`, or `NONE` (read-only)
6. **Static**: `YES` or `NO`
7. **Custom Accessor Logic**: `YES` or `NO`
8. **Validation Code** (only if custom accessor): ABL code to run before setting the value
9. **Backing Field Name**: `m_<PropertyName>` if not specified

## Steps

1. Read the class file
2. Ask for any missing required information
3. Generate the appropriate property block:
   - **Simple property**: `define <get-access> [static] property <name> as <type> get. <set-access> set.`
   - **Read-only simple property**: `define <get-access> [static] property <name> as <type> get.`
   - **Custom accessor**: add `var private [static] <type> m_<name>.`, then `define <get-access> [static] property <name> as <type> get(): return m_<name>. end get. <set-access> set(input value as <type>): <validation> m_<name> = value. end set.`
4. Insert the property at the top of the class, just after the `class ...:` line
5. Run the project's ABL compile/lint command (e.g. `prolint -g <file>`) if available, and report errors

## Property Templates

### Simple Property

```abl
/* [PropertyName] property */
define <get-access> [static] property <propertyName> as <TYPE>
    get.
    <set-access> set.
```

### Read-Only Simple Property

```abl
/* [PropertyName] property (read-only) */
define <get-access> [static] property <propertyName> as <TYPE>
    get.
```

### Custom Accessor

```abl
/* [PropertyName] property - private backing field */
var private [static] <TYPE> m_<propertyName>.

/* [PropertyName] property */
define <get-access> [static] property <propertyName> as <TYPE>
    get():
        return m_<propertyName>.
    end get.
    <set-access> set(input value as <TYPE>):
        [VALIDATION_CODE]
        m_<propertyName> = value.
    end set.
```

## Best Practices

- Group property declarations at the top of the class
- Use simple property accessors unless validation or special logic is required
- Consider read-only properties when appropriate
- Use private setters for properties that should only be modified internally
- Use consistent naming conventions
- Use lowercase ABL keywords and the `var` statement for backing fields
