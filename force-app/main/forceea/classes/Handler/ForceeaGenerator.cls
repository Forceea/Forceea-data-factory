/*
  Forceea data factory (v2.9.1)
  Copyright (C) 2024 Nikos Mitrakis

  This program is free software: you can redistribute it and/or modify it under the terms
  of the GNU General Public License as published by the Free Software Foundation,
  either version 3 of the License, or any later version.

  This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
  without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  See the GNU General Public License for more details.

  You can find a copy of the GNU General Public License at
  https://github.com/Forceea/Forceea-data-factory/blob/master/LICENSE
*/
/**
 * @description Controls the data generation proccess based on the field definitions.
 */
public with sharing class ForceeaGenerator {

    /* CONSTANTS */

    private static final String MESSAGE_INVALID_PARAMETER = 'Invalid parameter';
    private static final String PARAMETER_EXCEPT = 'except';
    private static final String PARAMETER_FIELD = 'field';
    private static final String PARAMETER_FROM = 'from';
    private static final String PARAMETER_GROUP = 'group';
    private static final String PARAMETER_LOOKUP = 'lookup';
    private static final String PARAMETER_SCALE = 'scale';
    private static final String PARAMETER_MODE = 'mode';
    public static final String PARAMETER_SOURCE = 'source';
    private static final String PARAMETER_STEP = 'step';
    private static final String PARAMETER_TO = 'to';
    private static final String PARAMETER_VALUE = 'value';
    private static final String PARAMETER_WHERE = 'where';

    /**
     * @description The valid sources (forceea, salesforce).
     */
    private static final Set<String> SOURCES = new Set<String>{
        ForceeaService.SOURCE_FORCEEA, ForceeaService.SOURCE_SALESFORCE
    };
    private static final List<String> WORDS = new List<String>{
        'lorem', 'ipsum', 'dolor', 'sit', 'amet', 'tempor', 'aboreant',
        'eu', 'nos', 'a', 'quo', 'magna', 'primis', 'labore', 'usi', 'virtute', 'fabellas', 'vis', 'duis',
        'scripta', 'laudem', 'commune', 'nam', 'laoreet', 'propriae', 'ea', 'partem',
        'inermis', 'ius', 'sint', 'impedit', 'eam', 'elit', 'nusquam'
    };
    private static final Map<Integer, List<String>> WORDS_BY_LENGTH = new Map<Integer, List<String>>{
        1 => new List<String>{
            'a', 'e'
        },
        2 => new List<String>{
            'eu', 'ea'
        },
        3 => new List<String>{
            'sit', 'nos', 'usi', 'nam', 'eam', 'vis', 'quo', 'ius'
        },
        4 => new List<String>{
            'amet', 'duis', 'elit', 'sint'
        },
        5 => new List<String>{
            'lorem', 'ipsum', 'dolor', 'magna'
        },
        6 => new List<String>{
            'tempor', 'partem', 'labore', 'primis', 'nusquam', 'laudem'
        },
        7 => new List<String>{
            'inermis', 'laoreet', 'commune', 'scripta', 'virtute', 'impedit'
        },
        8 => new List<String>{
            'aboreant', 'fabellas', 'propriae'
        }
    };

    /* COLLECTIONS */

    private List<String> lookupExceptions { get; set; }
    private List<String> lookupIds { get; set; }
    private Set<String> lookupIdsSet { get; set; }
    private List<SObject> lookupRecords { get; set; }
    private Map<Id, SObject> lookupRecordsById { get; set; }
    private List<String> lookupValues { get; set; }

    /* INSTANCE VARIABLES & PROPERTIES */

    private String command { get; set; }
    private final ForceeaDefinition def { get; set; }
    private String fieldApiName { get; set; }
    private final FObject fObj { get; set; }
    private String groupName { get; set; }
    private String lookupFromFieldApiName { get; set; }
    private String lookupMode { get; set; }
    private String lookupSObjectApiName { get; set; }
    private Integer maxLength { get; set; }
    private Integer minLength { get; set; }
    private final Integer numRecords { get; set; }
    private String previousWord { get; set; }
    /**
     * @description If true, will retrieve permutations.
     */
    private Boolean shouldGetUniqueValues { get; set; }
    private String source { get; set; }
    private String whereClause { get; set; }

    /* ENUMS */

    private enum FunctionAddType {
        TYPE_DATE, TYPE_DATETIME, TYPE_NONE, TYPE_NUMBER
    }

    /* CONSTRUCTORS */

    /**
     * @description The constructor for the class.
     * @param def A ForceeaDefinition object.
     */
    public ForceeaGenerator(ForceeaDefinition def) {
        this.def = def;
        this.fObj = def.fObj;
        this.numRecords = def.fObj.getNumberOfRecords();
    }

    /* METHODS */

    /**
     * @description Adds a string to the end of a list of partial phone numbers.
     * @param existingPhoneValues The existing phone numbers.
     * @param str The string to add, which represents phone number digits .
     * @return A list of strings (partial phone numbers).
     */
    private List<String> addPhoneDigitsOfSameType(List<String> existingPhoneValues, String str) {
        List<String> results = new List<String>();

        for (String val : existingPhoneValues) {
            results.add(val + str);
        }

        return results;
    }

    /**
     * @description Adds a random digit between 1 and 9 to the end of a list of partial phone numbers.
     * @param existingPhoneValues The existing phone numbers.
     * @return A list of strings (partial phone numbers).
     */
    private List<String> addPhoneDigitsOfTypeLowerD(List<String> existingPhoneValues) {
        List<String> results = new List<String>();

        Integer rnd = 0;
        for (String val : existingPhoneValues) {
            rnd = 1 + (FObject.random * 9).intValue(); // get a random number between 1 and 9
            results.add(val + String.valueOf(rnd));
        }

        return results;
    }

    /**
     * @description Adds a random digit between 0 and 9 to the end of a list of partial phone numbers.
     * @param existingPhoneValues The existing phone numbers.
     * @return A list of strings (partial phone numbers).
     */
    private List<String> addPhoneDigitsOfTypeUpperD(List<String> existingPhoneValues) {
        List<String> results = new List<String>();

        Integer rnd = 0;
        for (String val : existingPhoneValues) {
            rnd = (FObject.random * 10).intValue(); // get a random number between 0 and 9
            results.add(val + String.valueOf(rnd));
        }

        return results;
    }

    /**
     * @description Informs if the IsActive standard field exists for the SObject.
     * @param sObjectApiName The SObject API name.
     * @return True, if the SObject contains an IsActive field.
     */
    private Boolean existsIsActiveStandardField(String sObjectApiName) {
        String fieldApiName = ForceeaService.getFieldApiNameFromKey(sObjectApiName, 'IsActive', null);
        return (String.isNotBlank(fieldApiName));
    }

    /**
     * @description Informs whether the field is a Checkbox.
     * @param fieldApiName The field API name.
     * @return A Boolean value.
     */
    private Boolean fieldIsCheckbox(String fieldApiName) {
        Forceea.FieldInfo field = ForceeaService.getField(this.fObj.getSObjectApiName(), fieldApiName);
        return (field != null && field.dataType == Schema.DisplayType.BOOLEAN);
    }

    private Boolean fieldIsDatetime(String fieldApiName) {
        Forceea.FieldInfo field = ForceeaService.getField(this.fObj.getSObjectApiName(), fieldApiName);
        return (field != null && field.dataType == Schema.DisplayType.DATETIME);
    }

    private Boolean fieldIsLookup(String fieldApiName) {
        Forceea.FieldInfo field = ForceeaService.getField(this.fObj.getSObjectApiName(), fieldApiName);
        return (field != null && field.dataType == Schema.DisplayType.REFERENCE);
    }

    private Boolean fromFieldIsNotLookupOrVirtualField() {
        Boolean fieldIsLookupOrBoolean =
            ForceeaService.fieldIsVirtual(this.fieldApiName) || fieldIsLookup(this.fieldApiName);

        if (!fieldIsLookupOrBoolean) {
            this.fObj.addError(this.def.fieldApiName,
                'The [from] field [' + this.fieldApiName + '] is not a lookup or virtual field');
            return true;
        }

        return false;
    }

    private Boolean fromFieldIsTheSameAsDefinitionField() {
        if (this.fieldApiName.equalsIgnoreCase(this.def.fieldApiName)) {
            this.fObj.addError(this.def.fieldApiName, 'The field [' + this.fieldApiName +
                '] cannot be the same as the definition field in definition [' + this.def.definitionString + ']');
            return true;
        }

        return false;
    }

    private Integer getAdditionalLength(Integer randomLength, String previousResult) {
        Integer result = randomLength - previousResult.length() - 1;

        return (result < 1) ? 1 : result;
    }

    /**
     * @description Returns the first argument of a cluster.
     * @param parameter The parameter of the cluster.
     * @return A string value.
     */
    public String getClusterArgument(String parameter) {
        String result = '';
        String par = parameter.toLowerCase();

        for (Forceea.Cluster cluster : this.def.clusters) {
            if (par == cluster.parameter) {
                // parameter is found
                result = cluster.arguments[0];
                if (result.startsWith('"')) {
                    result = result.removeStart('"').removeEnd('"');
                }
                break;
            }
        }

        return result;
    }

    /**
     * @description Returns the arguments of a cluster.
     * @param parameter The parameter of the cluster.
     * @return A list of string values.
     */
    private List<String> getClusterArguments(String parameter) {
        List<String> results = new List<String>();
        String par = parameter.toLowerCase();

        for (Forceea.Cluster cluster : this.def.clusters) {
            if (par == cluster.parameter) {
                // parameter is found
                for (String arg : cluster.arguments) {
                    String result = arg;
                    if (result.startsWith('"')) {
                        result = arg.removeStart('"').removeEnd('"');
                    }
                    results.add(result);
                }
                break;
            }
        }

        return results;
    }

    /**
     * @description Copies the values of another lookup SObject's field.
     * @param referenceFieldName The API name of the reference field.
     * @param fromSObjectDotField The lookup SObject and the lookup field API names, separated by . (e.g. Account.Rating).
     * @return A list of string values.
     */
    private List<String> getCopiedLookupValues(String referenceFieldName, String fromSObjectDotField) {
        List<String> results = new List<String>();
        this.fieldApiName = ForceeaService.getFieldApiName(this.fObj, this.def.definitionString,
            this.fObj.getSObjectApiName(), referenceFieldName, null, this.def.fieldApiName, 'copy-field');

        if (shouldReturnEmptyResultsFromCopiedLookupValues1(fromSObjectDotField)) {
            return results;
        }

        setLookupIds();
        setLookupRecordsMap();
        if (shouldReturnEmptyResultsFromCopiedLookupValues2()) {
            return results;
        }

        return getCopiedLookupValuesBasedOnDataType();
    }

    private List<String> getCopiedLookupValuesBasedOnDataType() {
        List<String> results = new List<String>();
        String val = '';
        Datetime dt;

        if (fieldIsDatetime(this.def.fieldApiName)) {
            for (String lookupId : this.lookupIds) {
                dt = (Datetime) this.lookupRecordsById.get(lookupId).get(this.lookupFromFieldApiName);
                val = String.valueOf(dt);

                if (String.isBlank(val)) {
                    results.add('');
                } else {
                    results.add(val);
                }
            }
            return results;
        }

        // the field is not Datatime
        for (String lookupId : this.lookupIds) {
            val = String.valueOf(this.lookupRecordsById.get(lookupId).get(this.lookupFromFieldApiName));
            if (String.isBlank(val)) {
                results.add('');
            } else {
                results.add(val);
            }
        }
        return results;
    }

    /**
     * @description Copies the values of a field.
     * @param fieldName The API name of the field.
     * @return A list of string values.
     */
    private List<String> getCopiedFieldValues(String fieldName) {
        List<String> results = new List<String>();
        fieldName = fieldName.trim();

        String fieldApiName = ForceeaService.getFieldApiName(
            this.fObj, this.def.definitionString, this.fObj.getSObjectApiName(), fieldName, null,
            this.def.fieldApiName, 'copy-field');
        if (String.isBlank(fieldApiName)) {
            return results;
        }

        if (fieldApiName.equalsIgnoreCase(this.def.fieldApiName)) {
            this.fObj.addError(this.def.fieldApiName,
                'The field [' + fieldApiName + '] cannot be the same as ' +
                'the definition field in definition [' + this.def.definitionString + ']');
            return results;
        }

        Integer thisFieldPosition = getFieldPosition(this.def.fieldApiName);
        Integer fieldPosition = getFieldPosition(fieldApiName);

        if (thisFieldPosition < fieldPosition || fieldPosition == -1) {
            results = getCopiedFieldValuesFromExisting(fieldApiName);
        } else {
            results = this.fObj.fieldValuesMatrix.get(fieldPosition);
        }

        return results;
    }

    /**
     * @description Copies the existing values of a field.
     * @param fieldName The API name of the field.
     * @return A list of string values.
     */
    private List<String> getCopiedFieldValuesFromExisting(String fieldName) {
        List<String> results = new List<String>();

        for (Integer counter = 0; counter < this.fObj.recordsToUpdate.size(); counter++) {
            if (!FObject.processIsValid()) {
                break;
            }

            SObject obj = this.fObj.recordsToUpdate.get(counter);

            if (obj.get(fieldName) == null) {
                results.add('');
            } else {
                results.add(String.valueOf(obj.get(fieldName)));
            }
        }

        return results;
    }

    /**
     * @description Creates copy values.
     * @return A list of string values.
     */
    private List<String> getCopyValues() {
        List<String> results = new List<String>();

        switch on this.def.type.id {
            when COPY_FIELD {
                String field = getClusterArgument(PARAMETER_FIELD);
                results = getCopiedFieldValues(field);
            } when COPY_LOOKUP {
                String referenceFieldName = getClusterArgument(PARAMETER_FIELD);
                String fromSObjectDotField = getClusterArgument(PARAMETER_FROM);
                results = getCopiedLookupValues(referenceFieldName, fromSObjectDotField);
            }
        }

        return results;
    }

    private Datetime getFromDatetime() {
        Datetime fromArgm;
        try {
            fromArgm = Datetime.valueOf(getClusterArgument(PARAMETER_FROM));
        } catch (TypeException ex) {
            fromArgm = Datetime.newInstance(
                Date.valueOf(getClusterArgument(PARAMETER_FROM)), Time.newInstance(0, 0, 0, 0));
        }
        return fromArgm;
    }

    /**
     * @description Create values for function-add.
     * @return A list of string values.
     */
    private List<String> getFunctionAddValues() {
        String fieldName = getClusterArgument(PARAMETER_FIELD);
        Integer currentFieldPosition = getFieldPosition(this.def.fieldApiName);
        List<String> currentValues = this.fObj.fieldValuesMatrix.get(currentFieldPosition);
        List<String> valuesToAdd = getCopiedFieldValues(fieldName);

        List<String> results = new List<String>();
        if (FObject.processMustTerminate()) {
            return results;
        }

        for (Integer counter = 0; counter < this.numRecords; counter++) {
            setFunctionAddValues(currentValues.get(counter), valuesToAdd.get(counter), results);
        }

        return results;
    }

    /**
     * @description Retrieves the FunctionAddType enum based on the current and added value strings.
     * @param currentStringValue The string of the current value.
     * @param stringValueToAdd The string of the value to add.
     * @return The enum of FunctionAddType.
     */
    private FunctionAddType getFunctionAddType(String currentStringValue, String stringValueToAdd) {
        ForceeaService.ValueType existingValueType = new ForceeaService().getValueType(currentStringValue);
        ForceeaService.ValueType addedValueType = new ForceeaService().getValueType(stringValueToAdd);
        ForceeaService service = new ForceeaService();

        if (service.valueTypesToAddAreNumbers(existingValueType, addedValueType)) {
            return FunctionAddType.TYPE_NUMBER;
        } else if (service.valueTypesToAddAreDate(existingValueType, addedValueType)) {
            return FunctionAddType.TYPE_DATE;
        } else if (service.valueTypesToAddAreDatetime(existingValueType, addedValueType)) {
            return FunctionAddType.TYPE_DATETIME;
        } else {
            return FunctionAddType.TYPE_NONE;
        }
    }

    /**
     * @description Create values for function-convert.
     * @return A list of string values.
     */
    private List<String> getFunctionConvertValues() {
        List<String> results = new List<String>();
        if (FObject.processMustTerminate()) {
            return results;
        }

        String parameter = getClusterArgument(PARAMETER_TO);
        Integer currentFieldPosition = getFieldPosition(this.def.fieldApiName);
        List<String> currentValues = this.fObj.fieldValuesMatrix.get(currentFieldPosition);

        switch on parameter {
            when 'lower' {
                results = ForceeaService.convertListToLowercase(currentValues);
            } when 'upper' {
                results = ForceeaService.convertListToUppercase(currentValues);
            } when else {
                String errorMessage = MESSAGE_INVALID_PARAMETER + ' [' + parameter + '] ' +
                    ForceeaService.MESSAGE_IN_DEFINITION + ' [' + this.def.definitionString + ']';
                this.fObj.addError(this.def.fieldApiName, errorMessage);
            }
        }

        return results;
    }

    /**
     * @description Creates function values.
     * @return A list of string values.
     */
    private List<String> getFunctionValues() {
        List<String> results = new List<String>();

        if (FObject.processMustTerminate()) {
            return results;
        }

        switch on this.def.type.id {
            when FUNCTION_ADD {
                results = getFunctionAddValues();
            } when FUNCTION_CONVERT {
                results = getFunctionConvertValues();
            }
        }

        return results;
    }

    /**
     * @description Retrieves the data type of the current field.
     * @return The DisplayType of the definition field or ANYTYPE if it's a Virtual Field.
     */
    private Schema.DisplayType getFieldDataType() {
        if (this.def.isVirtualField) {
            return Schema.DisplayType.ANYTYPE;
        }

        Forceea.FieldInfo field = ForceeaService.getField(this.fObj.getSObjectApiName(), this.def.fieldApiName);
        return field.dataType;
    }

    /**
     * @description Retrieves the data type of a field.
     * @param fieldApiName The field API name.
     * @return The DisplayType of the definition field or ANYTYPE if it's a Virtual Field.
     */
    private Schema.DisplayType getFieldDataType(String fieldApiName) {
        if (String.isBlank(fieldApiName)) {
            return null;
        }

        if (ForceeaService.fieldIsVirtual(fieldApiName)) {
            return Schema.DisplayType.ANYTYPE;
        }

        return ForceeaService.getField(this.fObj.getSObjectApiName(), fieldApiName).dataType;
    }

    /**
     * @description Retrieves the list of standard picklist values, excluding exceptions.
     * @return A list of picklist values.
     */
    private List<String> getFieldPicklistValuesExcludingExceptions() {
        List<String> picklistValues = new List<String>();
        String fieldApiName = this.def.fieldApiName.toLowerCase();

        Forceea.FieldInfo field = ForceeaService.getField(this.fObj.getSObjectApiName(), fieldApiName);
        for (Schema.PicklistEntry picklistEntry : field.picklistValues) {
            picklistValues.add(picklistEntry.getValue());
        }

        List<String> exceptions = getClusterArguments(PARAMETER_EXCEPT);
        return ForceeaService.removeValuesFromList(picklistValues, exceptions);
    }

    /**
     * @description Retrieves the position of a field.
     * @param fieldApiName The API name of the field.
     * @return An integer value.
     */
    private Integer getFieldPosition(String fieldApiName) {
        Integer result = -1;
        Integer counter = 0;

        for (String field : this.fObj.getFieldsToProcess()) {
            if (field == fieldApiName) {
                result = counter;
                break;
            }
            counter++;
        }

        return result;
    }

    /**
     * @description Creates list values for permutations.
     * @return A list of string values.
     */
    public List<String> getListValuesForPermutations() {
        List<String> results = new List<String>();
        this.def.hasPermutation = true;

        if (this.def.fieldApiName == ForceeaService.RECORD_TYPE_ID) {
            return new ForceeaRecordTypeHandler(this.fObj)
                .getRecordTypeIdsExcludingExceptions(getClusterArguments(PARAMETER_EXCEPT));
        }

        switch on getClusterArgument('type').toLowerCase() {
            when 'list' {
                results = getClusterArguments(PARAMETER_VALUE);
            } when 'number' {
                results = getUniqueSerialValues();
            } when 'picklist' {
                results = getFieldPicklistValuesExcludingExceptions();
            }
        }

        return results;
    }

    /**
     * @description Retrieves IDs from a lookup records.
     * @param lookupFieldApiName The API name of the lookup field.
     * @param fieldApiName The API name of the field.
     * @return A list of IDs.
     */
    private List<String> getLookupIds(String lookupFieldApiName, String fieldApiName) {
        Boolean thereAreLookupValues = thereAreLookupValues();
        Boolean thereAreLookupExceptions = thereAreLookupExceptions();

        if (!thereAreLookupValues && !thereAreLookupExceptions) {
            return getLookupIdsWhenThereAreNoLookupValuesAndExceptions();
        } else if (thereAreLookupValues && !thereAreLookupExceptions) {
            return getLookupIdsWhenThereAreLookupValuesAndNoExceptions(lookupFieldApiName);
        } else if (!thereAreLookupValues && thereAreLookupExceptions) {
            return getLookupIdsWhenThereAreNoLookupValuesAndAreExceptions(lookupFieldApiName);
        } else {
            this.fObj.addError(fieldApiName, 'System Error: Invalid lookup type');
        }

        return new List<String>();
    }

    private List<String> getLookupIdsWhenThereAreLookupValuesAndNoExceptions(String lookupFieldApiName) {
        List<String> results = new List<String>();

        Set<String> lookupValuesSet = new Set<String>(this.lookupValues);
        lookupValuesSet = ForceeaService.convertSetToLowercase(lookupValuesSet);

        for (SObject objRecord : this.lookupRecords) {
            String fieldValue = (String) objRecord.get(lookupFieldApiName);
            if (String.isNotBlank(fieldValue) && lookupValuesSet.contains(fieldValue.toLowerCase())) {
                results.add(objRecord.Id);
            }
        }

        return results;
    }

    private List<String> getLookupIdsWhenThereAreNoLookupValuesAndAreExceptions(String lookupFieldApiName) {
        List<String> results = new List<String>();

        Set<String> lookupExceptionsSet = new Set<String>(this.lookupExceptions);
        lookupExceptionsSet = ForceeaService.convertSetToLowercase(lookupExceptionsSet);

        for (SObject objRecord : this.lookupRecords) {
            String fieldValue = (String) objRecord.get(lookupFieldApiName);
            if (String.isNotBlank(fieldValue) && !lookupExceptionsSet.contains(fieldValue)) {
                // if exception value is not found
                results.add(objRecord.Id);
            }
        }

        return results;
    }

    private List<String> getLookupIdsWhenThereAreNoLookupValuesAndExceptions() {
        List<String> results = new List<String>();

        for (SObject objRecord : this.lookupRecords) {
            results.add(objRecord.Id);
        }

        return results;
    }

    private List<SObject> getLookupRecords(
        String lookupSObjectApiName, String lookupFieldApiName, String lookupFieldName) {
        List<SObject> results = new List<SObject>();

        switch on this.source.toLowerCase() {
            when 'forceea' {
                return getLookupRecordsFromForceea(lookupSObjectApiName, lookupFieldApiName);
            } when 'salesforce' {
                return getLookupRecordsFromSalesforce(lookupSObjectApiName, lookupFieldName);
            } when else {
                return results;
            }
        }
    }

    /**
     * @description Retrieves lookup records from forceea source.
     * @param lookupSObjectApiName The API name of the lookup SObject.
     * @param lookupFieldApiName The API name of the lookup field.
     * @return A list of SObjects.
     */
    private List<SObject> getLookupRecordsFromForceea(String lookupSObjectApiName, String lookupFieldApiName) {
        List<SObject> results = new List<SObject>();
        String key = lookupSObjectApiName.toLowerCase() + '.' + this.groupName.trim().toLowerCase() ;

        if (FObject.globalInsertedRecordsByGroup.containsKey(key)) {
            results = FObject.globalInsertedRecordsByGroup.get(key);
        }

        if (results.isEmpty() && this.def.isSystemDeclared) {
            results = getLookupRecordsFromSalesforce(lookupSObjectApiName, lookupFieldApiName);
        }

        return results;
    }

    /**
     * @description Retrieves lookup records from salesforce source.
     * @param lookupSObjectApiName The API name of the lookup SObject.
     * @param lookupFieldApiName The API name of the lookup field.
     * @return A list of SObjects.
     */
    private List<SObject> getLookupRecordsFromSalesforce(String lookupSObjectApiName, String lookupFieldApiName) {
        List<SObject> results = new List<SObject>();

        try {
            Boolean isActiveFieldExists = existsIsActiveStandardField(lookupSObjectApiName);
            ForceeaSelector selector = new ForceeaSelector()
                .setField(lookupFieldApiName)
                .setFrom(lookupSObjectApiName)
                .setWhere(this.whereClause)
                .excludeInactive(this.fObj.excludeInactiveLookupRecords)
                .isActiveFieldExists(isActiveFieldExists)
                .setLimit(this.fObj.getQueryLimit());
            results = Database.query(selector.getQueryString());
        } catch (QueryException ex) {
            String key = (String.isBlank(lookupFieldApiName)) ? this.def.fieldApiName : lookupFieldApiName;
            this.fObj.addError(key, ForceeaService.MESSAGE_FOUND_ERRORS_SELECTING_FROM_LOOKUP + ' [' +
                lookupSObjectApiName + '] of [' + this.fObj.getSObjectApiName() + ']: ' + ex.getMessage());
        }

        return results;
    }

    private String getLookupSObjectApiName(String fromSObjectDotField) {
        String lookupSObjectName = fromSObjectDotField.trim().substringBefore('.');
        return ForceeaService.getSObjectApiName(
            this.fObj, this.def.definitionString, lookupSObjectName, this.def.fieldApiName, 'lookup');
    }

    /**
     * @description Creates IDs from a lookup SObject's records.
     * @param lookupSObjectName The API name of the lookup SObject.
     * @param lookupFieldName The API name of the lookup field.
     * @return A list of IDs.
     */
    private List<String> getLookupValues(String lookupSObjectName, String lookupFieldName) {
        List<String> results = new List<String>();
        String fieldApiName = this.def.fieldApiName;

        String lookupSObjectApiName = ForceeaService.getSObjectApiName(
            this.fObj, this.def.definitionString, lookupSObjectName, this.def.fieldApiName, 'lookup');
        if (String.isBlank(lookupSObjectApiName)) {
            new ForceeaErrorHandler(this.def).addErrorInvalidLookupSObject(lookupSObjectName);
            return results;
        }

        String lookupFieldApiName = ''; // may be blank because of the definition random lookup(SObject)
        if (String.isNotBlank(lookupFieldName)) {
            lookupFieldApiName = ForceeaService.getFieldApiNameFromKey(lookupSObjectApiName, lookupFieldName, null);
            if (String.isBlank(lookupFieldApiName)) {
                new ForceeaErrorHandler(this.def).addErrorInvalidLookupField(lookupFieldName);
                return results;
            }
        }

        if (!sourceIsValid(this.source)) {
            new ForceeaErrorHandler(this.def).addErrorInvalidLookupSource(this.source);
            return results;
        }

        this.lookupRecords = getLookupRecords(lookupSObjectApiName, lookupFieldApiName, lookupFieldName);
        if (FObject.processMustTerminate()) {
            return results;
        }

        return getResultsOnCommand(lookupFieldApiName, fieldApiName);
    }

    /**
     * @description Creates lookup values for permutations.
     * @return A list of string values.
     */
    public List<String> getLookupValuesForPermutations() {
        this.def.hasPermutation = true;

        String lookupObject = getClusterArgument(PARAMETER_LOOKUP);
        String lookupFieldName = getClusterArgument(PARAMETER_FIELD);
        setParametersForPermutationValues();
        return getLookupValues(lookupObject, lookupFieldName);
    }

    /**
     * @description Creates mocked IDs.
     * @param sObjectType The SObject type.
     * @return A list of string values.
     */
    private List<String> getMockedIds(Schema.SObjectType sObjectType) {
        List<String> results = new List<String>();
        String prefix = sObjectType.getDescribe().getKeyPrefix();

        for (Integer counter = 0; counter < this.numRecords; counter++) {
            String serialNumber = String.valueOf(FObject.mockingSerialNumber++);
            results.add(prefix + '0'.repeat(12 - serialNumber.length()) + serialNumber);
        }

        return results;
    }

    /**
     * @description Creates mock values.
     * @return A list of string values.
     */
    private List<String> getMockValues() {
        List<String> results = new List<String>();

        switch on this.def.type.id {
            when MOCK_ID {
                Schema.SObjectType objType = this.fObj.sObjType;
                results = getMockedIds(objType);
            }
        }

        return results;
    }

    private String getNewWord(Integer additionalLength) {
        String result = '';
        Integer counter = 0;
        List<String> additionalWords = WORDS_BY_LENGTH.get(additionalLength);

        do {
            result = additionalWords.get(counter);
            counter++;
        } while (this.previousWord == result);

        return result;
    }

    /**
     * @description Returns the next record number of the SObject.
     * @return The serialized record number of next record.
     */
    public Integer getNumberOfNextRecord() {
        return FObject.numFirstRecordsBySObject.get(this.fObj.getSObjectApiName());
    }

    /**
     * @description Returns the permutation values of a specific permutation list.
     * @param permutationPosition The position number of the permutation.
     * @return The list of permutation values.
     */
    private List<String> getPermutationValues(Integer permutationPosition) {
        List<String> results = new List<String>();
        if (permutationPosition == null || permutationPosition < 0) {
            return results;
        }

        for (Integer counter = 0; counter < this.fObj.permutationValues.size(); counter++) {
            results.add(this.fObj.permutationValues.get(counter).get(permutationPosition));
        }

        return results;
    }

    /**
     * @description Creates random picklist values, respecting the fields dependencies.
     * @param dependentFieldApiName The API name of the dependent field.
     * @param controllingFieldApiName The API name of the controlling field.
     * @param inclusions The picklist values to keep.
     * @param exceptions The picklist values to remove.
     * @return A list of string values.
     */
    private List<String> getPicklistValuesWithRespectToDependencies(
        String dependentFieldApiName, String controllingFieldApiName, List<String> inclusions, List<String> exceptions) {
        exceptions = ForceeaService.convertListToLowercase(exceptions);
        Integer controllingFieldPosition = getFieldPosition(controllingFieldApiName);

        // get the Field Dependencies map (key: controlling field value, value: dependent field values)
        Map<String, Set<String>> fieldDependenciesMap = new ForceeaInfo(this.fObj)
            .getFieldDependenciesMap(controllingFieldApiName, dependentFieldApiName);

        // amend the Field Dependencies map based on the inclusions and exceptions
        if (inclusions != null) {
            // && !inclusions.isEmpty()
            // keep in the Field Dependencies map only the values of inclusions list
            for (String value : fieldDependenciesMap.keySet()) {
                fieldDependenciesMap.get(value).retainAll(inclusions); // remove any value, except from inclusions
            }
        } else if (!exceptions.isEmpty()) {
            // remove the values of the exceptions list from the Field Dependencies map
            for (String value : fieldDependenciesMap.keySet()) {
                fieldDependenciesMap.get(value).removeAll(exceptions); // remove the except values from the set
            }
        }

        List<String> controllingFieldValues = this.fObj.fieldValuesMatrix.get(controllingFieldPosition);
        List<String> dependentFieldValues = new List<String>();

        // the dependent field's values mapped to the controlling field's value
        List<String> results = new List<String>();
        Set<String> fieldDependenciesSet = new Set<String>();
        String controllingFieldValue = '';
        Integer rnd = 0;

        for (Integer counter = 0; counter < this.numRecords; counter++) {
            controllingFieldValue = controllingFieldValues[counter];

            // get the dependent field's value set from the Field Dependencies map
            fieldDependenciesSet = fieldDependenciesMap.get(controllingFieldValue);
            // if there are no mapped values between controlling and dependent field
            if (fieldDependenciesSet == null || fieldDependenciesSet.isEmpty()) {
                results.add(''); // add an empty string to results
            } else {
                // there at least one value
                dependentFieldValues = new List<String>(fieldDependenciesSet);
                rnd = (FObject.random * dependentFieldValues.size()).intValue();
                results.add(dependentFieldValues[rnd]);
            }
        }

        return results;
    }

    /**
     * @description Creates random addresses having street (with number), postal code, city, state and country.
     * @return A list of ForceeaAddress objects.
     */
    private List<ForceeaAddress> getRandomAddresses() {
        List<ForceeaAddress> results = new List<ForceeaAddress>();

        ForceeaAddress.loadAddresses();
        Integer librarySize = ForceeaAddress.addresses.size();

        for (Integer counter = 0; counter < this.numRecords; counter++) {
            Integer rnd = (FObject.random * librarySize).intValue();
            results.add(ForceeaAddress.addresses.get(rnd));
        }

        return results;
    }

    /**
     * @description Creates random cities.
     * @param addressGroup The group of this address.
     * @return A list of string values.
     */
    private List<String> getRandomCities(String addressGroup) {
        List<String> values = new List<String>();

        // create addresses if needed
        List<ForceeaAddress> groupAddresses = this.fObj.addressesByGroup.get(addressGroup);
        if (groupAddresses == null || groupAddresses.isEmpty()) {
            // set random addresses
            this.fObj.addressesByGroup.put(addressGroup, getRandomAddresses());
            // get created addresses
            groupAddresses = this.fObj.addressesByGroup.get(addressGroup);
        }

        for (Integer counter = 0; counter < this.numRecords; counter++) {
            values.add(groupAddresses[counter].city);
        }

        return values;
    }

    /**
     * @description Creates random countries.
     * @param addressGroup The group of this address.
     * @return A list of string values.
     */
    private List<String> getRandomCountries(String addressGroup) {
        List<String> values = new List<String>();

        // create addresses if needed
        List<ForceeaAddress> groupAddresses = this.fObj.addressesByGroup.get(addressGroup);
        if (groupAddresses == null || groupAddresses.isEmpty()) {
            // set random addresses
            this.fObj.addressesByGroup.put(addressGroup, getRandomAddresses());
            // get created addresses
            groupAddresses = this.fObj.addressesByGroup.get(addressGroup);
        }

        for (Integer counter = 0; counter < this.numRecords; counter++) {
            values.add(groupAddresses[counter].country);
        }

        return values;
    }

    /**
     * @description Returns a list of random domains.
     * @param syllables The number of syllables(musical notes) the domain consists of.
     * @return A list of string values.
     */
    private List<String> getRandomDomains(Integer syllables) {
        List<String> values = new List<String>();
        List<String> notes = new List<String>{
            'do', 're', 'mi', 'fa', 'sol', 'la', 'si'
        };

        for (Integer counter1 = 0; counter1 < this.numRecords; counter1++) {
            String domain = '';
            for (Integer counter2 = 0; counter2 < syllables; counter2++) {
                Integer rnd = (FObject.random * 7).intValue();
                domain += notes[rnd];
            }
            values.add(domain + '.com');
        }

        return values;
    }

    /**
     * @description Returns a list of random first names.
     * @param nameGroup The group of this name.
     * @return A list of string values.
     */
    private List<String> getRandomFirstNames(String nameGroup) {
        List<String> values = new List<String>();

        if (this.fObj.namesByGroup.get(nameGroup) == null) {
            // there are no created names for this group
            this.fObj.namesByGroup.put(nameGroup, getRandomNames()); // create names
        }

        List<ForceeaName> groupNames = this.fObj.namesByGroup.get(nameGroup); // get the first names for the group

        // get the first names
        for (Integer counter = 0; counter < this.numRecords; counter++) {
            values.add(groupNames[counter].firstName);
        }

        return values;
    }

    /**
     * @description Creates random last names.
     * @param nameGroup The group of this name.
     * @return A list of string values.
     */
    private List<String> getRandomLastNames(String nameGroup) {
        List<String> values = new List<String>();

        if (this.fObj.namesByGroup.get(nameGroup) == null) {
            // there are no created names for this group
            this.fObj.namesByGroup.put(nameGroup, getRandomNames()); // create names
        }

        List<ForceeaName> groupNames = this.fObj.namesByGroup.get(nameGroup); // get the first names for the group
        for (Integer counter = 0; counter < this.numRecords; counter++) {
            values.add(groupNames[counter].lastName);
        }

        return values;
    }

    /**
     * @description Creates random list values.
     * @return A list of string values.
     */
    private List<String> getRandomListValues() {
        List<String> results = new List<String>();
        List<String> arguments = getClusterArguments(PARAMETER_VALUE);

        if (this.def.fieldApiName == ForceeaService.RECORD_TYPE_ID) {
            List<String> recordTypeIds = new ForceeaRecordTypeHandler(this.fObj, this.def)
                .getRecordTypeIdsFromDeveloperNames(arguments);
            if (FObject.processMustTerminate()) {
                return results;
            }
            return getRandomValuesFromList(recordTypeIds);
        }

        switch on getFieldDataType() {
            when PICKLIST, MULTIPICKLIST {
                return getRandomListValuesForPicklists();
            } when else {
                return getRandomValuesFromList(arguments);
            }
        }
    }

    /**
     * @description Creates random picklist values from a list.
     * @return A list of string values.
     */
    private List<String> getRandomListValuesForPicklists() {
        List<String> arguments = getClusterArguments(PARAMETER_VALUE);
        List<String> values = new List<String>();
        String fieldApiName = this.def.fieldApiName;

        // get all picklist values
        List<String> picklistValues = new List<String>();

        Forceea.FieldInfo depField = ForceeaService.getField(this.fObj.getSObjectApiName(), fieldApiName);
        for (Schema.PicklistEntry picklistEntry : depField.picklistValues) {
            picklistValues.add(picklistEntry.getValue());
        }

        // get controlling field's API name
        String ctrlFieldApiName = depField.controllingFieldApiName;

        if (depField.isRestrictedPicklist) {
            arguments = ForceeaService.convertToMasterValues(arguments, picklistValues);
        }

        if (String.isBlank(ctrlFieldApiName) ||
            getFieldDataType(ctrlFieldApiName) == Schema.DisplayType.BOOLEAN ||
            this.fObj.isUpdate) {
            values = getRandomValuesFromList(arguments);
        } else {
            values = getPicklistValuesWithRespectToDependencies(fieldApiName, ctrlFieldApiName, arguments, null);
        }

        return values;
    }

    /**
     * @description Creates random IDs from a lookup SObject's records.
     * @param lookupFieldApiName The API name of the lookup field.
     * @param fieldApiName The API name of the field.
     * @return A list of IDs.
     */
    private List<String> getRandomLookupValues(String lookupFieldApiName, String fieldApiName) {
        List<String> results = new List<String>();

        List<String> lookupIds = getLookupIds(lookupFieldApiName, fieldApiName);

        Integer size = lookupIds.size();
        Integer rnd = 0;
        if (size == 0) {
            return results;
        }
        if (size == 1) {
            for (Integer counter = 0; counter < this.numRecords; counter++) {
                results.add(lookupIds[0]);
            }
        } else if (size > 1) {
            for (Integer counter = 0; counter < this.numRecords; counter++) {
                rnd = (FObject.random * size).intValue();
                results.add(lookupIds[rnd]);
            }
        }

        return results;
    }

    /**
     * @description Creates random names.
     * @return A list of Name objects.
     */
    private List<ForceeaName> getRandomNames() {
        List<ForceeaName> results = new List<ForceeaName>();

        String firstName = '';
        String lastName = '';
        String gender = '';
        Integer firstNamesSize = 0; // size of the first names list
        Integer lastNamesSize = 0; // size of the last names list
        Integer vFirst = 0; // random index for the first name
        Integer vLast = 0; // random index for the last name
        Integer counterNames = 0; // counter of created names
        Integer counterGroups = 0; // counter of groups

        ForceeaName.loadNames();
        Integer numGroups = ForceeaAddress.lastNamesLibraryByGender.size();

        // get the size of each locality/gender group
        Integer groupSize = this.numRecords / numGroups;

        for (String key : ForceeaAddress.lastNamesLibraryByGender.keySet()) {
            // get the data (first & last name lists)
            List<String> firstNames = ForceeaAddress.firstNamesLibraryByGender.get(key);
            List<String> lastNames = ForceeaAddress.lastNamesLibraryByGender.get(key);

            firstNamesSize = firstNames.size();
            lastNamesSize = lastNames.size();
            gender = key;

            // check if this is the last group
            counterGroups++;
            if (counterGroups == numGroups) {
                groupSize = this.numRecords - counterNames;
            } else {
                counterNames += groupSize;
            }

            // set values
            for (Integer counter = 0; counter < groupSize; counter++) {
                vFirst = (FObject.random * firstNamesSize).intValue();
                firstName = firstNames[vFirst];
                vLast = (FObject.random * lastNamesSize).intValue();
                lastName = lastNames[vLast];
                results.add(new ForceeaName(firstName, lastName, gender));
            }
        }

        ForceeaName temp = new ForceeaName();
        Integer size = results.size();
        for (Integer counter = 0; counter < size; counter++) {
            Integer rnd = (FObject.random * size).intValue();
            temp = results[counter] ;
            results[counter] = results[rnd];
            results[rnd] = temp;
        }

        return results;
    }

    /**
     * @description Returns a list of random decimals.
     * @param fromNumber The minimum decimal.
     * @param toNumber The maximum decimal.
     * @param scale The scale.
     * @return A list of string values.
     */
    private List<String> getRandomNumbers(Decimal fromNumber, Decimal toNumber, Integer scale) {
        List<String> values = new List<String>();

        fromNumber = fromNumber.setScale(scale);
        toNumber = toNumber.setScale(scale);

        // check arguments
        if (fromNumber >= toNumber) {
            this.fObj.addError(this.def.fieldApiName, 'The [from] number is greater than or equal to ' +
                'the [to] number in definition [' + this.def.definitionString + ']');
        }

        Decimal range = toNumber - fromNumber;
        Decimal val = 0;
        for (Integer counter = 0; counter < this.numRecords; counter++) {
            val = fromNumber + FObject.random * range;
            values.add(val.setScale(scale).toPlainString());
        }

        return values;
    }

    /**
     * @description Creates random phone numbers.
     * @param formatString The format string which defines the phone numbers.
     * @return A list of strings (phone numbers).
     */
    private List<String> getRandomPhoneNumbers(String formatString) {
        List<String> results = new List<String>();
        String thisFormatString = formatString.trim();

        for (Integer counter = 0; counter < this.numRecords; counter++) {
            results.add('');
        }

        for (Integer counter = 0; counter < thisFormatString.length(); counter++) {
            Integer charNumber = thisFormatString.charAt(counter);

            if (charNumber == 100) {
                // d
                results = addPhoneDigitsOfTypeLowerD(results);
            } else if (charNumber == 68) {
                // D
                results = addPhoneDigitsOfTypeUpperD(results);
            } else {
                results = addPhoneDigitsOfSameType(results, thisFormatString.mid(counter, 1));
            }
        }

        return results;
    }

    /**
     * @description Creates random postal codes.
     * @param addressGroup The group of this address.
     * @return A list of string values.
     */
    private List<String> getRandomPostalCodes(String addressGroup) {
        List<String> results = new List<String>();

        // create addresses if needed
        List<ForceeaAddress> groupAddresses = this.fObj.addressesByGroup.get(addressGroup);
        if (groupAddresses == null || groupAddresses.isEmpty()) {
            this.fObj.addressesByGroup.put(addressGroup, getRandomAddresses()); // set random addresses
            groupAddresses = this.fObj.addressesByGroup.get(addressGroup);
        }

        for (Integer counter = 0; counter < this.numRecords; counter++) {
            results.add(groupAddresses[counter].postalCode);
        }

        return results;
    }

    /**
     * @description Creates random Record Type IDs, excluding specific values.
     * @return A list of IDs as string values.
     */
    private List<String> getRandomRecordTypes() {
        List<String> recordTypeIds = new ForceeaRecordTypeHandler(this.fObj)
            .getRecordTypeIdsExcludingExceptions(getClusterArguments(PARAMETER_EXCEPT));

        return getRandomValuesFromList(recordTypeIds);
    }

    /**
     * @description Creates random states.
     * @param addressGroup The group of this address.
     * @return A list of string values.
     */
    private List<String> getRandomStates(String addressGroup) {
        List<String> results = new List<String>();

        // create addresses if needed
        List<ForceeaAddress> groupAddresses = this.fObj.addressesByGroup.get(addressGroup);
        if (groupAddresses == null || groupAddresses.isEmpty()) {
            // set random addresses
            this.fObj.addressesByGroup.put(addressGroup, getRandomAddresses());
            // get created addresses
            groupAddresses = this.fObj.addressesByGroup.get(addressGroup);
        }

        for (Integer counter = 0; counter < this.numRecords; counter++) {
            results.add(groupAddresses[counter].state);
        }

        return results;
    }

    /**
     * @description Creates random streets.
     * @param addressGroup The group of this address.
     * @return A list of string values.
     */
    private List<String> getRandomStreets(String addressGroup) {
        List<String> results = new List<String>();

        // create addresses if needed
        List<ForceeaAddress> groupAddresses = this.fObj.addressesByGroup.get(addressGroup);
        if (groupAddresses == null || groupAddresses.isEmpty()) {
            // set random addresses
            this.fObj.addressesByGroup.put(addressGroup, getRandomAddresses());
            // get created addresses
            groupAddresses = this.fObj.addressesByGroup.get(addressGroup);
        }

        Integer rnd = 0;
        String street = '';

        for (Integer counter = 0; counter < this.numRecords; counter++) {
            street = groupAddresses[counter].street;
            rnd = (FObject.random * 20).intValue() + 1; // get a random number from 1 to 20
            if (FObject.streetNumberGoesAfterStreet) {
                // number is after street
                street = street + ' ' + String.valueOf(rnd);
            } else {
                // number is before street
                street = String.valueOf(rnd) + ' ' + street;
            }
            results.add(street);
        }

        return results;
    }

    /**
     * @description Creates random texts.
     * @return A list of string values.
     */
    private List<String> getRandomTexts() {
        List<String> results = new List<String>();

        new ForceeaErrorHandler(this.fObj, this.def)
            .validateMinLength(this.minLength)
            .validateMaxLength(this.minLength, this.maxLength);

        if (FObject.processMustTerminate()) {
            return results;
        }

        for (Integer counter = 0; counter < this.numRecords; counter++) {
            this.previousWord = '';
            results.add(getText());
        }

        return results;
    }

    /**
     * @description Returns a list of random time values.
     * @param fromDatetime The minimum datetime.
     * @param toDatetime The maximum datetime.
     * @return A list of string values.
     */
    private List<String> getRandomTimes(Datetime fromDatetime, Datetime toDatetime) {
        List<String> values = new List<String>();

        Long fromDatetimePoint = fromDatetime.getTime(); // ms from 1/1/1970
        Long toDatetimePoint = toDatetime.getTime(); // ms from 1/1/1970
        if (fromDatetimePoint >= toDatetimePoint) {
            this.fObj.addError(this.def.fieldApiName, 'The [from] time is greater than or equal to ' +
                'the [to] time in definition [' + this.def.definitionString + ']');
            return values;
        }

        Long range = toDatetimePoint - fromDatetimePoint;
        Long randomPoint = 0;
        for (Integer counter = 0; counter < this.numRecords; counter++) {
            randomPoint = fromDatetimePoint + (FObject.random * range).longValue();
            Datetime dt = Datetime.newInstance(randomPoint);
            Integer hour = dt.hour();
            Integer min = dt.minute();
            Integer sec = dt.second();
            values.add(String.valueOf(Time.newInstance(hour, min, sec, 0)));
        }

        return values;
    }

    /**
     * @description Creates random values.
     * @return A list of string values.
     */
    private List<String> getRandomValues() {
        List<String> results = new List<String>();

        switch on this.def.type.id {
            when RANDOM_NUMBER {
                results = getRandomValuesWhenNumber();
            } when RANDOM_DATE {
                results = getRandomValuesWhenDate();
            } when RANDOM_DATETIME {
                results = getRandomValuesWhenDatetime();
            } when RANDOM_TIME {
                results = getRandomValuesWhenTime();
            } when RANDOM_PICKLIST, RANDOM_PICKLIST_EXCEPT {
                results = getRandomValuesWhenSelection();
            } when RANDOM_LIST_STRING, RANDOM_LIST_INTEGER, RANDOM_LIST_DECIMAL,
                RANDOM_LIST_DATE, RANDOM_LIST_TIME, RANDOM_LIST_DATETIME {
                results = getRandomListValues();
            } when RANDOM_EMAIL {
                results = getRandomValuesWhenEmail();
            } when RANDOM_URL {
                results = getRandomValuesWhenUrl();
            } when RANDOM_BOOLEAN {
                results = getRandomValuesWhenBoolean();
            } when RANDOM_FIRSTNAME {
                String nameGroup = getClusterArgument(PARAMETER_GROUP);
                results = getRandomFirstNames(nameGroup);
            } when RANDOM_LASTNAME {
                String nameGroup = getClusterArgument(PARAMETER_GROUP);
                results = getRandomLastNames(nameGroup);
            } when RANDOM_STREET {
                String addressGroup = getClusterArgument(PARAMETER_GROUP);
                results = getRandomStreets(addressGroup);
            } when RANDOM_POSTALCODE {
                String addressGroup = getClusterArgument(PARAMETER_GROUP);
                results = getRandomPostalCodes(addressGroup);
            } when RANDOM_CITY {
                String addressGroup = getClusterArgument(PARAMETER_GROUP);
                results = getRandomCities(addressGroup);
            } when RANDOM_STATE {
                String addressGroup = getClusterArgument(PARAMETER_GROUP);
                results = getRandomStates(addressGroup);
            } when RANDOM_COUNTRY {
                String addressGroup = getClusterArgument(PARAMETER_GROUP);
                results = getRandomCountries(addressGroup);
            } when RANDOM_STRING {
                results = getRandomValuesWhenString();
            } when RANDOM_TEXT {
                this.minLength = Integer.valueOf(getClusterArgument('minlength'));
                this.maxLength = Integer.valueOf(getClusterArgument('maxlength'));
                results = getRandomTexts();
            } when RANDOM_PHONE {
                String formatString = getClusterArgument('format');
                results = getRandomPhoneNumbers(formatString);
            } when RANDOM_LOOKUP {
                results = getRandomValuesWhenLookup();
            } when RANDOM_LOOKUP_WHERE {
                results = getRandomValuesWhenLookupWhere();
            }
        }

        return results;
    }

    /**
     * @description Creates random booleans.
     * @return A list of string values.
     */
    private List<String> getRandomValuesWhenBoolean() {
        List<String> values = new List<String>();

        for (Integer counter = 0; counter < this.numRecords; counter++) {
            if (FObject.random > 0.5) {
                values.add('true');
            } else {
                values.add('false');
            }
        }

        return values;
    }

    private List<String> getRandomValuesWhenDate() {
        Date fromArgm = Date.valueOf(getClusterArgument(PARAMETER_FROM));
        Date toArgument = Date.valueOf(getClusterArgument(PARAMETER_TO));

        return new ForceeaGeneratorDate(this.def).getRandomValues(fromArgm, toArgument);
    }

    private List<String> getRandomValuesWhenDatetime() {
        Datetime fromArgument = getFromDatetime();
        Datetime toArgument = getToDatetime();

        return new ForceeaGeneratorDate(this.def).getRandomValues(fromArgument, toArgument);
    }

    /**
     * @description Returns a list of random emails.
     * @return A list of string values.
     */
    private List<String> getRandomValuesWhenEmail() {
        List<String> values = new List<String>();
        List<String> includes = new List<String>{
            'lower'
        };
        List<String> names = getStringGeneratorWhenEmail(includes).getRandomStrings();
        List<String> domains = getRandomDomains(5);

        for (Integer counter = 0; counter < this.numRecords; counter++) {
            values.add(names[counter] + '@' + domains[counter]);
        }

        return values;
    }

    private List<String> getRandomValuesWhenLookup() {
        String lookupObject = getClusterArgument(PARAMETER_LOOKUP);
        String lookupField = getClusterArgument(PARAMETER_FIELD);
        setParametersForRandomLookupValues();
        return getLookupValues(lookupObject, lookupField);
    }

    private List<String> getRandomValuesWhenLookupWhere() {
        String lookupObject = getClusterArgument(PARAMETER_LOOKUP);
        setParametersForRandomLookupWhereValues();
        return getLookupValues(lookupObject, null);
    }

    private List<String> getRandomValuesWhenNumber() {
        Decimal fromArgument = Decimal.valueOf(getClusterArgument(PARAMETER_FROM));
        Decimal toArgument = Decimal.valueOf(getClusterArgument(PARAMETER_TO));
        Integer scaleArgm = Integer.valueOf(getClusterArgument(PARAMETER_SCALE));

        return getRandomNumbers(fromArgument, toArgument, scaleArgm);
    }

    /**
     * @description Creates random picklist values.
     * @return A list of string values.
     */
    private List<String> getRandomValuesWhenSelection() {
        String fieldApiName = this.def.fieldApiName;
        if (fieldApiName == ForceeaService.RECORD_TYPE_ID) {
            return getRandomRecordTypes();
        }

        // get dependent and controlling fields
        Forceea.FieldInfo dependentField = ForceeaService.getField(this.fObj.getSObjectApiName(), fieldApiName);
        String controllingFieldApiName = dependentField.controllingFieldApiName;

        List<String> results = new List<String>();
        List<String> exceptions = getClusterArguments(PARAMETER_EXCEPT);
        if (String.isBlank(controllingFieldApiName) || this.fObj.isUpdate || fieldIsCheckbox(controllingFieldApiName)) {
            List<String> picklistValues = getFieldPicklistValuesExcludingExceptions();
            results = getRandomValuesFromList(picklistValues);
        } else {
            // there is a controlling field
            results = getPicklistValuesWithRespectToDependencies(fieldApiName, controllingFieldApiName, null, exceptions);
        }

        return results;
    }

    private List<String> getRandomValuesWhenString() {
        ForceeaStringGenerator result = new ForceeaStringGenerator(this.def);

        result.minlength = Integer.valueOf(getClusterArgument('minlength'));
        result.maxlength = Integer.valueOf(getClusterArgument('maxlength'));
        result.startsWith = getClusterArgument('startwith');
        result.includes = getClusterArguments('include');

        return result.getRandomStrings();
    }

    private List<String> getRandomValuesWhenTime() {
        Datetime fromArgument;
        Datetime toArgument;

        try {
            fromArgument = Datetime.valueOf('2020-1-1 ' + getClusterArgument(PARAMETER_FROM));
        } catch (TypeException ex) {
            fromArgument = Datetime.valueOf('2020-1-1 00:00:00');
        }

        try {
            toArgument = Datetime.valueOf('2020-1-1 ' + getClusterArgument(PARAMETER_TO));
        } catch (TypeException ex) {
            fromArgument = Datetime.valueOf('2020-1-1 23:59:59');
        }

        return getRandomTimes(fromArgument, toArgument);
    }

    /**
     * @description Creates random URLs.
     * @return A list of string values.
     */
    private List<String> getRandomValuesWhenUrl() {
        List<String> results = new List<String>();
        List<String> domains = getRandomDomains(5);

        for (Integer counter = 0; counter < this.numRecords; counter++) {
            results.add('http://www.' + domains[counter]);
        }

        return results;
    }

    /**
     * @description Creates random values from a list.
     * @param values A list of input values.
     * @return A list of values.
     */
    private List<String> getRandomValuesFromList(List<String> values) {
        List<String> results = new List<String>();
        Integer size = values.size();

        switch on size {
            when 0 {
                return results;
            }
            when 1 {
                String value = values.get(0);
                for (Integer counter = 0; counter < this.numRecords; counter++) {
                    results.add(value);
                }
                return results;
            }
        }

        Integer rnd = 0;
        for (Integer counter = 0; counter < this.numRecords; counter++) {
            rnd = (FObject.random * size).intValue();
            results.add(values.get(rnd));
        }

        return results;
    }

    private List<String> getResultsOnCommand(String lookupFieldApiName, String fieldApiName) {
        if (this.shouldGetUniqueValues) {
            return getLookupIds(lookupFieldApiName, fieldApiName);
        }

        List<String> results = new List<String>();
        switch on this.command {
            when 'static' {
                results = getStaticLookupValues(lookupFieldApiName, fieldApiName);
            } when 'random' {
                results = getRandomLookupValues(lookupFieldApiName, fieldApiName);
            } when 'serial' {
                if (this.def.hasPermutation) {
                    results = getPermutationValues(this.def.positionForPermutations);
                } else {
                    results = getSerialLookupValues(lookupFieldApiName, fieldApiName);
                }
            }
        }

        return results;
    }

    /**
     * @description Creates serial date values.
     * @param fromDate The starting date value.
     * @param stepDays The number of days added to previous date value.
     * @return A list of string values.
     */
    private List<String> getSerialDates(Date fromDate, Integer stepDays) {
        List<String> results = new List<String>();
        Date val = fromDate.addDays((getNumberOfNextRecord() - 1) * stepDays);

        for (Integer counter = 0; counter < this.numRecords; counter++) {
            results.add(String.valueOf(val));
            val = val.addDays(stepDays);
        }

        return results;
    }

    /**
     * @description Creates serial datetime values.
     * @param fromDatetime The starting datetime value.
     * @param step The number of days added to previous datetime value.
     * @return A list of string values.
     */
    private List<String> getSerialDatetimes(Datetime fromDatetime, Decimal step) {
        List<String> results = new List<String>();

        // get the days/hours/minutes/seconds of the step
        Integer stepDays = step.intValue();

        Decimal stepHoursDecimal = (step - stepDays) * 24;
        Integer stepHours = stepHoursDecimal.intValue();

        Decimal stepMinutesDecimal = (stepHoursDecimal - stepHours) * 60;
        Integer stepMinutes = stepMinutesDecimal.intValue();

        Decimal stepSecondsDecimal = (stepMinutesDecimal - stepMinutes) * 60;
        Integer stepSeconds = stepSecondsDecimal.intValue();

        Datetime val = fromDatetime;
        Integer nextRecord = getNumberOfNextRecord();
        val = val.addDays((nextRecord - 1) * stepDays);
        val = val.addHours((nextRecord - 1) * stepHours);
        val = val.addMinutes((nextRecord - 1) * stepMinutes);
        val = val.addSeconds((nextRecord - 1) * stepSeconds);

        for (Integer counter = 0; counter < this.numRecords; counter++) {
            results.add(String.valueOf(val));
            val = val.addDays(stepDays);
            val = val.addHours(stepHours);
            val = val.addMinutes(stepMinutes);
            val = val.addSeconds(stepSeconds);
        }

        return results;
    }

    /**
     * @description Creates serial string values.
     * @param values The string values.
     * @param permutationPosition The definition position in permutations.
     * @return A list of string values.
     */
    private List<String> getSerialListValues(List<String> values, Integer permutationPosition) {
        List<String> results = new List<String>();
        if (values.isEmpty()) {
            return results;
        }

        String mode = getClusterArgument(PARAMETER_MODE);
        switch on mode.toLowerCase() {
            when 'cyclical' {
                results = getSerialListValuesOnModeCyclical(values);
            }
            when 'first' {
                results = getSerialListValuesOnModeFirst(values);
            }
            when 'last' {
                results = getSerialListValuesOnModeLast(values);
            }
            when 'null' {
                results = getSerialListValuesOnModeNull(values);
            }
            when 'permutation' {
                results = getPermutationValues(permutationPosition);
            }
        }

        return results;
    }

    /**
     * @description Creates serial string values on mode(cyclical).
     * @param values The string values.
     * @return A list of serial string values.
     */
    private List<String> getSerialListValuesOnModeCyclical(List<String> values) {
        List<String> results = new List<String>();
        Integer size = values.size();
        Integer counter = 0;

        for (Integer recordCounter = 0; recordCounter < this.numRecords; recordCounter++) {
            if (counter == size) {
                counter = 0;
            }
            results.add(values.get(counter));
            counter++;
        }

        return results;
    }

    /**
     * @description Creates serial string values on mode(first).
     * @param values The string values.
     * @return A list of serial string values.
     */
    private List<String> getSerialListValuesOnModeFirst(List<String> values) {
        List<String> results = new List<String>();
        Integer size = values.size();
        Integer counter = 0;

        for (Integer recordCounter = 0; recordCounter < this.numRecords; recordCounter++) {
            if (recordCounter >= size) {
                counter = 0;
            }
            results.add(values.get(counter));
            counter++;
        }

        return results;
    }

    /**
     * @description Creates serial string values on mode(last).
     * @param values The string values.
     * @return A list of serial string values.
     */
    private List<String> getSerialListValuesOnModeLast(List<String> values) {
        List<String> results = new List<String>();
        Integer size = values.size();
        Integer counter = 0;

        for (Integer recordCounter = 0; recordCounter < this.numRecords; recordCounter++) {
            if (recordCounter >= size) {
                counter = (size - 1);
            }
            results.add(values.get(counter));
            counter++;
        }

        return results;
    }

    /**
     * @description Creates serial string values on mode(null).
     * @param values The string values.
     * @return A list of serial string values.
     */
    private List<String> getSerialListValuesOnModeNull(List<String> values) {
        List<String> results = new List<String>();
        Integer size = values.size();

        Integer actualSize = (size >= this.numRecords ? this.numRecords : size);
        for (Integer recordCounter = 0; recordCounter < actualSize; recordCounter++) {
            results.add(values.get(recordCounter));
        }

        if (size < this.numRecords) {
            for (Integer recordCounter = size; recordCounter < this.numRecords; recordCounter++) {
                results.add('');
            }
        }

        return results;
    }

    /**
     * @description Creates serial lookup IDs.
     * @param lookupFieldApiName The API name of the lookup field.
     * @param fieldApiName The API name of the field.
     * @return A list of IDs.
     */
    private List<String> getSerialLookupValues(String lookupFieldApiName, String fieldApiName) {
        List<String> results = new List<String>();

        List<String> lookupIds = getLookupIds(lookupFieldApiName, fieldApiName);
        if (lookupIds.size() == 0) {
            return results;
        }

        switch on this.lookupMode.toLowerCase() {
            when 'cyclical' {
                results = getSerialListValuesOnModeCyclical(lookupIds);
            } when 'first' {
                results = getSerialListValuesOnModeFirst(lookupIds);
            } when 'last' {
                results = getSerialListValuesOnModeLast(lookupIds);
            } when 'null' {
                results = getSerialListValuesOnModeNull(lookupIds);
            }
        }

        return results;
    }

    /**
     * @description Creates serial decimal values.
     * @param fromNumber The starting value.
     * @param stepNumber The value added to previous value.
     * @param scale The number of decimal places.
     * @return A list of string values.
     */
    private List<String> getSerialNumbers(Decimal fromNumber, Decimal stepNumber, Integer scale) {
        List<String> results = new List<String>();

        Decimal val = fromNumber + (getNumberOfNextRecord() - 1) * stepNumber;
        for (Integer counter = 0; counter < this.numRecords; counter++) {
            results.add(val.setScale(scale).toPlainString());
            val += stepNumber;
        }

        return results;
    }

    /**
     * @description
     * @param fromNumber The starting value.
     * @param toNumber The max value.
     * @param stepNumber The value added to previous value.
     * @param scale The number of decimal places.
     * @return A list of string values.
     */
    public List<String> getSerialNumbers(Decimal fromNumber, Decimal toNumber, Decimal stepNumber, Integer scale) {
        List<String> results = new List<String>();

        if ((toNumber > fromNumber && stepNumber < 0) ||
            (fromNumber > toNumber && stepNumber > 0)) {
            return results;
        }

        Decimal counter = fromNumber;

        if (stepNumber < 0) {
            do {
                results.add(counter.setScale(scale).toPlainString());
                counter += stepNumber;
            } while (counter >= toNumber);
        } else {
            do {
                results.add(counter.setScale(scale).toPlainString());
                counter += stepNumber;
            } while (counter <= toNumber);
        }

        return results;
    }

    /**
     * @description Creates serial picklist values.
     * @param permutationPosition The definition position in permutations.
     * @return A list of string values.
     */
    private List<String> getSerialPicklistValues(Integer permutationPosition) {
        List<String> results = new List<String>();
        List<String> picklistValues = new List<String>();

        switch on this.def.fieldApiName {
            when 'RecordTypeId' {
                picklistValues = new ForceeaRecordTypeHandler(this.fObj)
                    .getRecordTypeIdsExcludingExceptions(getClusterArguments(PARAMETER_EXCEPT));
            }
            when else {
                picklistValues = getFieldPicklistValuesExcludingExceptions();
            }
        }

        if (picklistValues.isEmpty()) {
            return results;
        }

        return getSerialListValues(picklistValues, permutationPosition);
    }

    /**
     * @description Creates serial values.
     * @return A list of string values.
     */
    private List<String> getSerialValues() {
        List<String> results = new List<String>();

        switch on this.def.type.id {
            when SERIAL_PICKLIST {
                results = getSerialPicklistValues(this.def.positionForPermutations);
            } when SERIAL_LIST_STRING, SERIAL_LIST_INTEGER, SERIAL_LIST_DECIMAL,
                SERIAL_LIST_DATE, SERIAL_LIST_DATETIME, SERIAL_LIST_TIME {
                List<String> values = getClusterArguments(PARAMETER_VALUE);
                results = getSerialListValues(values, this.def.positionForPermutations);
            } when SERIAL_NUMBER {
                Decimal fromArgument = Decimal.valueOf(getClusterArgument(PARAMETER_FROM));
                Decimal stepArgm = Decimal.valueOf(getClusterArgument(PARAMETER_STEP));
                Integer scaleArgm = Integer.valueOf(getClusterArgument(PARAMETER_SCALE));
                results = getSerialNumbers(fromArgument, stepArgm, scaleArgm);
            } when SERIAL_NUMBER_MODE {
                List<String> values = getUniqueSerialValues();
                results = getSerialListValues(values, this.def.positionForPermutations);
            } when SERIAL_DATE {
                Date fromArgument = Date.valueOf(getClusterArgument(PARAMETER_FROM));
                Integer stepArgm = Integer.valueOf(getClusterArgument(PARAMETER_STEP));
                results = getSerialDates(fromArgument, stepArgm);
            } when SERIAL_DATETIME {
                Datetime fromArgument;
                try {
                    fromArgument = Datetime.valueOf(getClusterArgument(PARAMETER_FROM));
                } catch (TypeException ex) {
                    fromArgument = Datetime.newInstance(
                        Date.valueOf(getClusterArgument(PARAMETER_FROM)), Time.newInstance(0, 0, 0, 0));
                }
                Decimal stepArgm = Decimal.valueOf(getClusterArgument(PARAMETER_STEP));
                results = getSerialDatetimes(fromArgument, stepArgm);
            } when SERIAL_LOOKUP {
                String lookupObject = getClusterArgument(PARAMETER_LOOKUP);
                String lookupField = getClusterArgument(PARAMETER_FIELD);
                setParametersForSerialLookupValues();
                results = getLookupValues(lookupObject, lookupField);
            }
        }

        return results;
    }

    /**
     * @description Creates static lookup IDs.
     * @param lookupFieldApiName The API name of the lookup field.
     * @param fieldApiName The API name of the field.
     * @return A list of IDs.
     */
    private List<String> getStaticLookupValues(String lookupFieldApiName, String fieldApiName) {
        List<String> results = new List<String>();

        List<String> lookupIds = getLookupIds(lookupFieldApiName, fieldApiName);
        if (lookupIds.isEmpty()) {
            return results;
        }

        return getStaticValuesFromValue(lookupIds.get(0));
    }

    /**
     * @description Creates static values.
     * @return A list of string values.
     */
    private List<String> getStaticValues() {
        List<String> results = new List<String>();

        switch on this.def.type.id {
            when STATIC_STRING, STATIC_INTEGER, STATIC_DECIMAL, STATIC_DATE, STATIC_TIME, STATIC_DATETIME {
                String value = getClusterArgument(PARAMETER_VALUE);
                results = getStaticValues(value);
            } when STATIC_LOOKUP {
                String lookupObject = getClusterArgument(PARAMETER_LOOKUP);
                String lookupField = getClusterArgument(PARAMETER_FIELD);
                setParametersForStaticValues();
                results = getLookupValues(lookupObject, lookupField);
            }
        }

        return results;
    }

    /**
     * @description Creates static values.
     * @param argument The static value.
     * @return A list of string values.
     */
    private List<String> getStaticValues(String argument) {
        List<String> results = new List<String>();
        String fieldApiName = this.def.fieldApiName;

        if (fieldApiName.equalsIgnoreCase(ForceeaService.RECORD_TYPE_ID)) {
            List<String> recordTypeIds = new ForceeaRecordTypeHandler(this.fObj, this.def)
                .getRecordTypeIdsFromDeveloperNames(new List<String>{
                    argument
                });
            if (FObject.processMustTerminate()) {
                return results;
            }
            return getStaticValuesFromValue(recordTypeIds.get(0));
        }

        Forceea.FieldInfo depField = ForceeaService.getField(this.fObj.getSObjectApiName(), fieldApiName);
        Set<Schema.DisplayType> types = new Set<DisplayType>{
            Schema.DisplayType.PICKLIST, Schema.DisplayType.MULTIPICKLIST
        };
        if (this.def.isVirtualField || !types.contains(depField.dataType)) {
            for (Integer counter = 0; counter < this.numRecords; counter++) {
                results.add(argument);
            }
            return results;
        }

        List<String> picklistValues = new List<String>();
        for (Schema.PicklistEntry picklistEntry : depField.picklistValues) {
            picklistValues.add(picklistEntry.getValue());
        }

        String ctrlFieldApiName = depField.controllingFieldApiName; // get controlling field's API name
        List<String> arguments = new List<String>{
            argument
        };

        if (depField.isRestrictedPicklist) {
            // if the field is restricted remove argument if not a valid picklist value
            arguments = ForceeaService.keepValuesInList(arguments, picklistValues);
        }

        if (String.isBlank(ctrlFieldApiName) || // the controlling field is a Checkbox or there is no controlling field
            ForceeaService.getField(this.fObj.getSObjectApiName(), ctrlFieldApiName).dataType == Schema.DisplayType.BOOLEAN) {
            results = getRandomValuesFromList(arguments);
        } else {
            // there is a controlling field
            results = getPicklistValuesWithRespectToDependencies(fieldApiName, ctrlFieldApiName, arguments, null);
        }

        return results;
    }

    /**
     * @description Creates a list of values equal to a specific value.
     * @param value The value.
     * @return A list of string values.
     */
    private List<String> getStaticValuesFromValue(String value) {
        List<String> results = new List<String>();

        for (Integer counter = 0; counter < this.numRecords; counter++) {
            results.add(value);
        }

        return results;
    }

    private ForceeaStringGenerator getStringGeneratorWhenEmail(List<String> includedChars) {
        ForceeaStringGenerator result = new ForceeaStringGenerator(this.def);

        result.minlength = 10;
        result.maxlength = 10;
        result.startsWith = 'lower';
        result.includes = includedChars;

        return result;
    }

    private String getText() {
        String result = '';

        Integer newLength = 0;
        Integer numWords = WORDS.size();
        Integer randomLength = (FObject.random * (this.maxLength - this.minLength)).intValue() + this.minLength;

        do {
            Integer rnd = (FObject.random * numWords).intValue();
            String newWord = WORDS.get(rnd);
            newLength = (result + newWord).length();
            if (this.previousWord != newWord && newLength <= randomLength) {
                result += newWord + ' ';
                this.previousWord = newWord;
            }
        } while (newLength <= (randomLength + 1));

        return getTextWhenLessThanMinLength(result, randomLength).capitalize();
    }

    private String getTextWhenLessThanMinLength(String previousResult, Integer randomLength) {
        String result = previousResult.trim();
        if (result.length() >= this.minLength) {
            return result;
        }

        Integer additionalLength = getAdditionalLength(randomLength, result);
        result += ' ' + getNewWord(additionalLength);
        return result.trim();
    }

    private Datetime getToDatetime() {
        Datetime toArgument;

        try {
            toArgument = Datetime.valueOf(getClusterArgument(PARAMETER_TO));
        } catch (TypeException ex) {
            toArgument = Datetime.newInstance(
                Date.valueOf(getClusterArgument(PARAMETER_TO)), Time.newInstance(0, 0, 0, 0));
        }

        return toArgument;
    }

    private List<String> getUniqueSerialValues() {
        Decimal fromArgument = Decimal.valueOf(getClusterArgument(PARAMETER_FROM));
        Decimal toArgument = Decimal.valueOf(getClusterArgument(PARAMETER_TO));
        Decimal stepArgm = Decimal.valueOf(getClusterArgument(PARAMETER_STEP));
        Integer scaleArgm = Integer.valueOf(getClusterArgument(PARAMETER_SCALE));
        return getSerialNumbers(fromArgument, toArgument, stepArgm, scaleArgm);
    }

    /**
     * @description Creates field values.
     * @return A list of string values.
     */
    public List<String> getValues() {
        List<String> results = new List<String>();

        if (this.def.isFunction) {
            return getFunctionValues();
        }

        switch on this.def.command.toLowerCase() {
            when 'copy' {
                results = getCopyValues();
            } when 'mock' {
                results = getMockValues();
            } when 'random' {
                results = getRandomValues();
            } when 'serial' {
                results = getSerialValues();
            } when 'static' {
                results = getStaticValues();
            }
        }

        return results;
    }

    /**
     * @description Updates the Function-add results.
     * @param currentStringValue The string of the current value.
     * @param stringValueToAdd The string of the value to add.
     * @param results The updated list of the current process results.
     */
    private void setFunctionAddValues(String currentStringValue, String stringValueToAdd, List<String> results) {
        switch on getFunctionAddType(currentStringValue, stringValueToAdd) {
            when TYPE_DATE {
                Date currentDateValue = Date.valueOf(currentStringValue);
                Decimal valueToAdd = Decimal.valueOf(stringValueToAdd);
                Integer daysToAdd = (Integer) valueToAdd.round(System.RoundingMode.HALF_DOWN);
                Date newDateValue = currentDateValue.addDays(daysToAdd);
                results.add(String.valueOf(newDateValue));
            }
            when TYPE_DATETIME {
                Decimal valueToAdd = Decimal.valueOf(stringValueToAdd);
                Decimal newDecimalValue = Datetime.valueOfGmt(currentStringValue).getTime() +
                    ForceeaService.getMillisecondsFromDays(valueToAdd);
                Datetime newDatetimeValue = Datetime.newInstance((Long) newDecimalValue);
                results.add(String.valueOfGmt(newDatetimeValue));
            }
            when TYPE_NUMBER {
                Decimal valueToAdd = Decimal.valueOf(stringValueToAdd);
                Decimal newDecimalValue = Decimal.valueOf(currentStringValue) + valueToAdd;
                results.add(newDecimalValue.toPlainString());
            }
            when else {
                results.add(currentStringValue);
            }
        }
    }

    private void setLookupIds() {
        Integer fieldPosition = getFieldPosition(this.fieldApiName);
        this.lookupIds = new List<String>(this.fObj.fieldValuesMatrix.get(fieldPosition));
        this.lookupIdsSet = new Set<String>(this.lookupIds);
    }

    private void setLookupRecordsMap() {
        try {
            List<SObject> records = new ForceeaSelector().selectLookupRecords(
                new List<String>{
                    this.lookupFromFieldApiName
                },
                this.lookupSObjectApiName,
                this.lookupIdsSet,
                this.fObj.getQueryLimit()
            );
            this.lookupRecordsById = new Map<Id, SObject>(records);
        } catch (QueryException exp) {
            this.fObj.addError(this.fieldApiName,
                ForceeaService.MESSAGE_FOUND_ERRORS_SELECTING_FROM_LOOKUP + ' [' + this.lookupSObjectApiName +
                '] of [' + this.fObj.getSObjectApiName() + ']: ' + exp.getMessage());
        }
    }

    private void setParametersForPermutationValues() {
        this.command = ForceeaService.COMMAND_SERIAL;
        this.groupName = getClusterArgument(PARAMETER_GROUP);
        this.lookupExceptions = getClusterArguments(PARAMETER_EXCEPT);
        this.lookupMode = ForceeaService.MODE_PERMUTATION;
        this.lookupValues = getClusterArguments(PARAMETER_VALUE);
        this.shouldGetUniqueValues = true;
        this.source = getClusterArgument(PARAMETER_SOURCE);
        this.whereClause = getClusterArgument(PARAMETER_WHERE);
    }

    private void setParametersForRandomLookupValues() {
        this.command = ForceeaService.COMMAND_RANDOM;
        this.groupName = getClusterArgument(PARAMETER_GROUP);
        this.lookupExceptions = getClusterArguments(PARAMETER_EXCEPT);
        this.lookupMode = null;
        this.lookupValues = getClusterArguments(PARAMETER_VALUE);
        this.shouldGetUniqueValues = false;
        this.source = getClusterArgument(PARAMETER_SOURCE);
    }

    private void setParametersForRandomLookupWhereValues() {
        this.command = ForceeaService.COMMAND_RANDOM;
        this.groupName = '';
        this.lookupMode = null;
        this.lookupValues = null;
        this.shouldGetUniqueValues = false;
        this.source = getClusterArgument(PARAMETER_SOURCE);
        this.whereClause = getClusterArgument(PARAMETER_WHERE);
    }

    private void setParametersForSerialLookupValues() {
        this.command = ForceeaService.COMMAND_SERIAL;
        this.groupName = getClusterArgument(PARAMETER_GROUP);
        this.lookupExceptions = getClusterArguments(PARAMETER_EXCEPT);
        this.lookupMode = getClusterArgument(PARAMETER_MODE);
        this.lookupValues = getClusterArguments(PARAMETER_VALUE);
        this.shouldGetUniqueValues = false;
        this.source = getClusterArgument(PARAMETER_SOURCE);
        this.whereClause = getClusterArgument(PARAMETER_WHERE);
    }

    private void setParametersForStaticValues() {
        this.command = ForceeaService.COMMAND_STATIC;
        this.groupName = getClusterArgument(PARAMETER_GROUP);
        this.lookupExceptions = getClusterArguments(PARAMETER_EXCEPT);
        this.lookupMode = null;
        this.lookupValues = getClusterArguments(PARAMETER_VALUE);
        this.shouldGetUniqueValues = false;
        this.source = getClusterArgument(PARAMETER_SOURCE);
        this.whereClause = getClusterArgument(PARAMETER_WHERE);
    }

    private Boolean shouldReturnEmptyResultsFromCopiedLookupValues1(String fromSObjectDotField) {
        if (String.isBlank(this.fieldApiName) ||
            fromFieldIsTheSameAsDefinitionField() ||
            fromFieldIsNotLookupOrVirtualField()) {
            return true;
        }

        this.lookupSObjectApiName = getLookupSObjectApiName(fromSObjectDotField);
        if (FObject.processMustTerminate()) {
            return true;
        }

        this.lookupFromFieldApiName = ForceeaService.getFieldApiName(this.fObj, this.def.definitionString,
            this.lookupSObjectApiName, fromSObjectDotField.trim().substringAfter('.'),
            null, this.def.fieldApiName, 'copy-from');
        if (String.isBlank(this.lookupFromFieldApiName)) {
            return true;
        }

        return false;
    }

    private Boolean shouldReturnEmptyResultsFromCopiedLookupValues2() {
        return this.lookupRecordsById.isEmpty() || FObject.processMustTerminate();
    }

    /**
     * @description Validates a source.
     * @param source The definition source.
     * @return A boolean value.
     */
    private Boolean sourceIsValid(String source) {
        return (ForceeaGenerator.SOURCES.contains(source.toLowerCase()));
    }

    private Boolean thereAreLookupExceptions() {
        return !(this.lookupExceptions == null || this.lookupExceptions.isEmpty());
    }

    private Boolean thereAreLookupValues() {
        return !(this.lookupValues == null || this.lookupValues.isEmpty());
    }

}