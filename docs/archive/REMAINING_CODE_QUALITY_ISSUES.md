# Remaining Code Quality Issues

## Overview
After two refactoring sessions, we've eliminated ~160 lines of duplicated code and extracted 5 helper methods. The following issues remain to be addressed.

## High Priority Issues

### 1. Large Method: BaseService.UpdateEntity() 
**Location**: `src/services/BaseService.cls` lines ~236-273  
**Issue**: Method is too large (38 lines) with multiple responsibilities  
**Recommendation**: Extract validation logic and error response building into separate methods

**Suggested Refactoring**:
- Extract `ValidateFieldsForUpdate()` method
- Extract `BuildUpdateErrorResponse()` method
- Extract `ExecuteUpdate()` method

### 2. Large Method: BaseService.Create()
**Location**: `src/services/BaseService.cls` lines ~175-226  
**Issue**: Method is too large (52 lines) with transaction and validation logic mixed  
**Recommendation**: Extract validation and transaction logic

**Suggested Refactoring**:
- Extract `ValidateFieldsForCreate()` method
- Extract `ExecuteCreate()` method
- Extract `BuildCreateErrorResponse()` method

### 3. Complex Method: BaseService.NormalizeMultipleEntityResponse()
**Location**: `src/services/BaseService.cls` lines ~720-800  
**Issue**: High cyclomatic complexity with nested loops and conditionals  
**Recommendation**: Extract record normalization logic

**Suggested Refactoring**:
- Extract `NormalizeSingleRecord()` method
- Extract `CopyRecordProperties()` method
- Simplify nested loops

### 4. Complex Method: BaseService.NormalizeSingleEntityResponse()
**Location**: `src/services/BaseService.cls` lines ~652-700  
**Issue**: High cyclomatic complexity with type-based property copying  
**Recommendation**: Extract property copying logic

**Suggested Refactoring**:
- Extract `CopyPropertyByType()` method
- Reduce nested conditionals

## Medium Priority Issues

### 5. Large Method: GenericService.HandleGet()
**Location**: `src/GenericService.cls` lines ~76-140  
**Issue**: Method handles multiple API types (data/meta) making it too large  
**Recommendation**: Split into separate methods

**Suggested Refactoring**:
- Extract `HandleDataRequest()` method
- Extract `HandleMetadataRequest()` method
- Extract `BuildFilterFromQueryParams()` method

### 6. Large Method: GenericService.HandlePost()
**Location**: `src/GenericService.cls` lines ~168-210  
**Issue**: Method size could be reduced further  
**Recommendation**: Extract response handling logic

**Suggested Refactoring**:
- Extract `ProcessCreateResponse()` method
- Extract `DetermineCreateStatusCode()` method

### 7. Large Method: GenericService.HandlePut()
**Location**: `src/GenericService.cls` lines ~224-270  
**Issue**: Similar to HandlePost, could be more focused  
**Recommendation**: Extract response handling logic

**Suggested Refactoring**:
- Extract `ProcessUpdateResponse()` method
- Extract `DetermineUpdateStatusCode()` method

### 8. Large Method: GenericService.HandleDelete()
**Location**: `src/GenericService.cls` lines ~272-320  
**Issue**: Could be more focused  
**Recommendation**: Extract response handling logic

**Suggested Refactoring**:
- Extract `ProcessDeleteResponse()` method
- Extract `DetermineDeleteStatusCode()` method

### 9. Complex Method: OrderService.ValidateOrder()
**Location**: `src/services/OrderService.cls` lines ~140-213  
**Issue**: Large validation method with many field checks  
**Recommendation**: Extract individual field validators

**Suggested Refactoring**:
- Extract `ValidateOrderNumber()` method
- Extract `ValidateCustomerNumber()` method
- Extract `ValidateOrderDate()` method
- Extract `ValidateOrderStatus()` method

### 10. Complex Method: MetadataService.checkValueList()
**Location**: `src/services/MetadataService.cls` lines ~65-125  
**Issue**: Complex query and validation logic  
**Recommendation**: Extract query building and validation logic

**Suggested Refactoring**:
- Extract `BuildQueryParamsQuery()` method
- Extract `ValidateFieldDataType()` method
- Extract `CheckDataTypeMatch()` method

## Low Priority Issues

### 11. High Parameter Count: ExecuteRepositoryQueryWithMetadata()
**Location**: `src/services/BaseService.cls` lines ~941-1019  
**Issue**: Methods have 4-5 parameters  
**Recommendation**: Consider parameter object pattern

**Suggested Refactoring**:
- Create `RepositoryQueryParams` class with properties:
  - MethodName
  - Parameter (variant type or multiple overloads)
  - Metadata
  - ArrayName
- Reduce to single method accepting parameter object

### 12. Module Coupling: BaseService.cls
**Issue**: BaseService has dependencies on multiple modules  
**Recommendation**: Review dependency injection and consider facade pattern

**Suggested Refactoring**:
- Review Repository interface usage
- Consider introducing service locator pattern
- Evaluate if some dependencies can be injected

## Estimated Impact

If all remaining issues are addressed:
- **Additional Lines Reduced**: ~200-250 lines
- **New Methods Created**: ~25-30 helper methods
- **Complexity Reduction**: 40-50% in large methods
- **Maintainability**: Significantly improved

## Prioritization Strategy

1. **Phase 1** (Highest ROI): Issues #1-4 (Large/Complex BaseService methods)
   - Most code reuse potential
   - Biggest complexity reduction
   
2. **Phase 2** (Good ROI): Issues #5-8 (GenericService Handle methods)
   - Consistent pattern across methods
   - Easier to test after refactoring

3. **Phase 3** (Medium ROI): Issues #9-10 (Validation methods)
   - Service-specific improvements
   - Better validation reusability

4. **Phase 4** (Nice to Have): Issues #11-12 (Architecture improvements)
   - Longer-term maintainability
   - May require more extensive changes

## Notes

- All refactorings should maintain backward compatibility
- Add unit tests for extracted methods
- Consider performance impact of additional method calls (minimal in ABL)
- Follow existing code style and naming conventions
- Use VAR syntax for variable declarations (ABL standard)
