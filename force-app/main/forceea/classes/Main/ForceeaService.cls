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
 * @description Provides functionality to other classes.
 */
@SuppressWarnings('PMD.FieldDeclarationsShouldBeAtStart')
public with sharing class ForceeaService {

    /* CONSTANTS */

    public static final String COMMAND_COPY = 'copy';
    public static final String COMMAND_FUNCTION_ADD = 'function-add';
    public static final String COMMAND_FUNCTION_CONVERT = 'function-convert';
    public static final String COMMAND_MOCK = 'mock';
    public static final String COMMAND_RANDOM = 'random';
    public static final String COMMAND_SERIAL = 'serial';
    public static final String COMMAND_STATIC = 'static';
    public static final String DEBUG = 'debug';
    public static final String ERROR = 'error';
    private static final String FORCEEA_PROCESS_SETTING_NAME = 'Standard';
    public static final String INFO = 'info';
    private static final String MAXIMUM_STACK_DEPTH_HAS_BEEN_REACHED = 'Maximum stack depth has been reached';
    public static final String MODE_PERMUTATION = 'permutation';
    public static final String MESSAGE_FOUND_ERRORS_SELECTING_FROM_LOOKUP =
        'Found errors selecting records from the lookup SObject';
    public static final String MESSAGE_GENERATED_DEFINITION = 'Generated definition';
    public static final String MESSAGE_IN_DEFINITION = 'in definition';
    public static final String MESSAGE_INVALID_DEFINITION = 'Invalid definition';
    public static final String MESSAGE_INVALID_FIELD = 'Invalid field';
    public static final String MESSAGE_INVALID_LOOKUP_SOBJECT = 'Invalid lookup SObject';
    public static final String MESSAGE_INVALID_SOBJECT = 'Invalid SObject';
    /**
     * @description The ID of the ForceeaQueueable class.
     */
    private static final Id QUEUEABLE_CLASS_ID {
        get {
            if (QUEUEABLE_CLASS_ID == null) {
                QUEUEABLE_CLASS_ID = new ForceeaSelector().selectQueueableClassByName('ForceeaQueueable').Id;
            }
            return QUEUEABLE_CLASS_ID;
        }
        set;
    }
    public static final String RECORD_TYPE_ID = 'RecordTypeId';
    public static final String SOURCE_FORCEEA = 'forceea';
    public static final String SOURCE_SALESFORCE = 'salesforce';
    /**
     * @description The standard price book ID.
     */
    public static final Id STANDARD_PRICEBOOK_ID {
        get {
            if (STANDARD_PRICEBOOK_ID == null) {
                STANDARD_PRICEBOOK_ID = new ForceeaService().getStandardPriceBookId();
            }
            return STANDARD_PRICEBOOK_ID;
        }
        set;
    }
    public static final String WARN = 'warn';

    /* ENUMS */

    public enum AsyncMessageType {
        MESSAGE_TYPE_ERROR, MESSAGE_TYPE_INFO, MESSAGE_TYPE_WARN, MESSAGE_TYPE_SUCCESS
    }
    public enum DefinitionTypeId {
        COPY_FIELD, COPY_LOOKUP,
        FUNCTION_ADD, FUNCTION_CONVERT,
        MOCK_ID,
        RANDOM_STRING, RANDOM_TEXT, RANDOM_NUMBER, RANDOM_PHONE,
        RANDOM_DATE, RANDOM_DATETIME, RANDOM_TIME,
        RANDOM_PICKLIST, RANDOM_PICKLIST_EXCEPT,
        RANDOM_LIST_INTEGER, RANDOM_LIST_DECIMAL, RANDOM_LIST_STRING,
        RANDOM_LIST_DATE, RANDOM_LIST_DATETIME, RANDOM_LIST_TIME,
        RANDOM_STREET, RANDOM_CITY, RANDOM_STATE, RANDOM_POSTALCODE, RANDOM_COUNTRY,
        RANDOM_FIRSTNAME, RANDOM_LASTNAME,
        RANDOM_EMAIL, RANDOM_BOOLEAN, RANDOM_URL,
        RANDOM_LOOKUP, RANDOM_LOOKUP_WHERE,
        SERIAL_NUMBER, SERIAL_NUMBER_MODE, SERIAL_DATE, SERIAL_DATETIME, SERIAL_PICKLIST, SERIAL_LOOKUP,
        SERIAL_LIST_STRING, SERIAL_LIST_INTEGER, SERIAL_LIST_DECIMAL,
        SERIAL_LIST_DATE, SERIAL_LIST_DATETIME, SERIAL_LIST_TIME,
        STATIC_INTEGER, STATIC_DECIMAL,
        STATIC_DATE, STATIC_DATETIME, STATIC_TIME, STATIC_STRING,
        STATIC_BLANK, STATIC_LOOKUP
    }
    public enum OperationType {
        ASYNC_INSERT, ASYNC_DELETE, ASYNC_UPDATE
    }
    public enum ValueType {
        TYPE_INTEGER, TYPE_DECIMAL, TYPE_STRING, TYPE_DATE, TYPE_DATETIME, TYPE_TIME, TYPE_BLANK
    }

    /* STATIC COLLECTIONS */

    /**
     * @description The map of defined SObject names (keys) to SObject Infos (values).
     */
    private static final Map<String, Forceea.SObjectInfo> sObjectInfosBySObjectName =
        new Map<String, Forceea.SObjectInfo>();
    /**
     * @description The map of defined SObject types (keys) to SObject Infos (values).
     */
    private static final Map<Schema.SObjectType, Forceea.SObjectInfo> sObjectInfosBySObjectType =
        new Map<Schema.SObjectType, Forceea.SObjectInfo>();
    /**
     * @description The map of defined SObject names (keys) to map [SObject fields by Field name] (values).
     */
    private static final Map<String, Map<String, Schema.SObjectField>> sObjectFieldsMapBySObjectName =
        new Map<String, Map<String, Schema.SObjectField>>();

    /* STATIC VARIABLES & PROPERTIES */

    /**
     * @description The async Process ID.
     */
    public static String processId = '';

    /* METHODS */

    /**
     * @description Informs if the async process is terminated or not.
     * @return True, if the async process has been terminated.
     */
    public static Boolean asyncProcessIsTerminated() {
        ForceeaProcess__c setting = ForceeaService.getForceeaProcessSetting();
        if (setting != null) {
            return ForceeaProcess__c.getInstance(FORCEEA_PROCESS_SETTING_NAME).IsTerminated__c;
        }

        return false;
    }

    /**
     * @description Converts all items of a list to lowercase.
     * @param listToConvert The list for conversion.
     * @return A list of string values.
     */
    public static List<String> convertListToLowercase(List<String> listToConvert) {
        List<String> results = new List<String>();
        if (listToConvert == null || listToConvert.isEmpty()) {
            return results;
        }

        for (String value : listToConvert) {
            results.add(value.toLowerCase());
        }

        return results;
    }

    /**
     * @description Converts all items of a list to uppercase.
     * @param listToConvert The list for conversion.
     * @return A list of string values.
     */
    public static List<String> convertListToUppercase(List<String> listToConvert) {
        List<String> results = new List<String>();
        if (listToConvert == null || listToConvert.isEmpty()) {
            return results;
        }

        for (String value : listToConvert) {
            results.add(value.toUpperCase());
        }

        return results;
    }

    /**
     * @description Converts all items of a set to lowercase.
     * @param setToConvert The set for conversion.
     * @return A set of string values.
     */
    public static Set<String> convertSetToLowercase(Set<String> setToConvert) {
        Set<String> results = new Set<String>();

        for (String value : setToConvert) {
            results.add(value.toLowerCase());
        }

        return results;
    }

    /**
     * @description Converts a list of case-insensitive string values to master (e.g. picklist) values.
     *   If the value is not in the list of picklist values, it is removed.
     * @param valuesToConvert The values to convert.
     * @param masterValues The master values.
     * @return A set of string values.
     */
    public static List<String> convertToMasterValues(List<String> valuesToConvert, List<String> masterValues) {
        List<String> results = new List<String>();
        List<String> valuesToConvertLowercase = convertListToLowercase(valuesToConvert);
        List<String> masterValuesLowercase = convertListToLowercase(masterValues);

        Integer counter = 0;
        Integer index = 0;
        for (String value : valuesToConvertLowercase) {
            if (masterValuesLowercase.contains(value)) {
                index = masterValuesLowercase.indexOf(value);
                results.add(masterValues[index]);
            }
            counter++;
        }

        return results;
    }

    /**
     * @description Enqueues a transaction for asynchronous processing.
     * @param fObjectTransaction An instance of AsyncTransaction.
     */
    public static void enqueueJob(Forceea.AsyncTransaction fObjectTransaction) {
        try {
            System.enqueueJob(new ForceeaQueueable(fObjectTransaction));
        } catch (Exception exp) {
            handleMaxStackDepthError(exp, fObjectTransaction);
        }
    }

    private static Boolean errorIsRelatedToMaxStackDepth(Exception exp) {
        return exp.getMessage().contains(MAXIMUM_STACK_DEPTH_HAS_BEEN_REACHED);
    }

    @Future
    private static void executeWithFuture(String jsonString) {
        System.enqueueJob(new ForceeaQueueable(jsonString));
    }

    /**
     * @description Determines is the field is virtual.
     * @param fieldName The API name of the field.
     * @return A boolean value.
     */
    public static Boolean fieldIsVirtual(String fieldName) {
        return (fieldName.left(1) == '$');
    }

    /**
     * @description Constructs the countable form (singular or plural) of a noun.
     * @param noun The countable noun.
     * @param count The number of occurrences.
     * @return The countable form.
     */
    public static String getCountable(String noun, Integer count) {
        Boolean isSingular = (count == 1 || count == -1) ? true : false;
        if (isSingular) {
            return String.valueOf(count) + ' ' + noun;
        }

        Boolean endsWithY = (noun.right(1).equalsIgnoreCase('y')) ? true : false;
        Boolean endsWithS = (noun.right(1).equalsIgnoreCase('s')) ? true : false;

        String nounInPlural = '';
        if (endsWithS) {
            nounInPlural = noun + 'es';
        } else if (endsWithY) {
            nounInPlural = noun.removeEndIgnoreCase('y') + 'ies';
        } else {
            nounInPlural = noun + 's';
        }

        return String.valueOf(count) + ' ' + nounInPlural;
    }

    /**
     * @description Retrieves the DML description.
     * @param fObj The FObject object.
     * @param suffix The description suffix, e.g. "ing"
     * @param startsWith A token ("lowercase" or "uppercase") for the proper capitalization.
     * @return A string of the DML description in the preferred tense.
     */
    public static String getDmlDescription(FObject fObj, String suffix, String startsWith) {
        String result = '';

        if (fObj.dmlIsInsert) {
            result = 'insert' + suffix;
        } else if (fObj.dmlIsUpdate) {
            result = 'updat' + suffix;
        } else if (fObj.dmlIsDelete) {
            result = 'delet' + suffix;
        }

        return (startsWith.toLowerCase() == 'uppercase') ? result.capitalize() : result;
    }

    /**
     * @description Retrieves the FObject.Field object from global fields map.
     * @param sObjectApiName The SObject API Name.
     * @param fieldApiName The field API name.
     * @return An FObject.Field object.
     */
    public static Forceea.FieldInfo getField(String sObjectApiName, String fieldApiName) {
        return FObject.globalFieldsMapBySObject.get(sObjectApiName.toLowerCase()).get(fieldApiName.toLowerCase());
    }

    /**
     * @description Retrieves the field API name or a blank string if the field name is invalid.
     * @param fObj The FObject.
     * @param definitionString The definition string.
     * @param sObjectApiName The SObject API Name.
     * @param fieldName The field name.
     * @param sObjectField The Schema SObject field.
     * @param relatedFieldApiName The API name of the field that lookup field is related to.
     * @param category The field category for fields (standard/lookup) or methods (e.g.removeDefinitions).
     * @return A string of the field API name.
     */
    public static String getFieldApiName(
        FObject fObj,
        String definitionString,
        String sObjectApiName,
        String fieldName,
        Schema.SObjectField sObjectField,
        String relatedFieldApiName,
        String category
    ) {
        String result = getFieldApiNameFromKey(sObjectApiName, fieldName, sObjectField);

        if (sObjectField != null) {
            String fieldApiName = sObjectField.getDescribe().getName();
            SObjectField fieldInfo = ForceeaService.getSObjectFieldsByName(sObjectApiName.toLowerCase()).get(fieldApiName);
            if (fieldInfo != sObjectField) {
                fObj.addError(fObj.getSObjectApiName(), ForceeaService.MESSAGE_INVALID_FIELD + ' [' + fieldApiName +
                    '] for SObject [' + fObj.getSObjectApiName() + ']');
            }
        }

        if (String.isNotBlank(result)) {
            return result;
        }

        switch on category.toLowerCase() {
            when 'standard' {
                fObj.addError(fObj.getSObjectApiName(),
                    'Invalid field [' + fieldName + '] ' + MESSAGE_IN_DEFINITION + ' [' + definitionString + ']');
            } when 'copy-field' {
                fObj.addError(relatedFieldApiName,
                    'Invalid copy field [' + fieldName + '] ' + MESSAGE_IN_DEFINITION + ' [' + definitionString + ']');
            } when 'copy-from' {
                fObj.addError(relatedFieldApiName,
                    'Invalid lookup field [' + sObjectApiName + '.' + fieldName + '] ' +
                    MESSAGE_IN_DEFINITION + ' [' + definitionString + ']');
            } when 'removedefinitions' {
                if (!fObj.isUpdate) {
                    fObj.addErrorInvalidFieldInMethod(fObj.getSObjectApiName(), fieldName, category);
                    return result;
                }
            }
        }

        return result;
    }

    /**
     * @description Retrieves the field API name or a blank string if the field name is invalid.
     * @param sObjectApiName The SObject API Name.
     * @param fieldApiName The field API name.
     * @param sObjectField The Schema SObject field.
     * @return A string of the field API name.
     */
    public static String getFieldApiNameFromKey(
        String sObjectApiName, String fieldApiName, Schema.SObjectField sObjectField) {
        String result = '';
        if (ForceeaService.fieldIsVirtual(fieldApiName)) {
            return fieldApiName;
        }

        if (sObjectField == null) {
            sObjectField = getSObjectFieldFromString(sObjectApiName, fieldApiName);
        }

        if (sObjectField != null) {
            Forceea.FieldInfo field = new ForceeaInfo().getFieldInfoFromSObjectField(sObjectField);
            setFieldInGlobalFieldsMap(field, sObjectApiName);
            result = field.fieldApiName;
        }

        return result;
    }

    /**
     * @description Retrieves the AsyncApexJob records.
     * @return The ForceeaProcess__c custom setting "Standard" record.
     */
    private static ForceeaProcess__c getForceeaProcessSetting() {
        for (ForceeaProcess__c setting : ForceeaProcess__c.getAll().values()) {
            if (setting.Name == FORCEEA_PROCESS_SETTING_NAME) {
                return setting;
            }
        }

        return null;
    }

    /**
     * @description Returns a Forceea.SObjectInfo object from an SObject API name and type.
     * @param sObjectApiName The SObject API name.
     * @param sObjType The SObject type.
     * @return A Forceea.SObjectInfo object.
     */
    private static Forceea.SObjectInfo getForceeaSObjectInfo(String sObjectApiName, SObjectType sObjType) {
        Forceea.SObjectInfo result = new Forceea.SObjectInfo();

        result.sObjectApiName = sObjectApiName;
        result.sObjType = sObjType;

        return result;
    }

    /**
     * @description Enqueues a transaction for asynchronous processing.
     * @param messageType An asyncMessageType (MESSAGE_TYPE_ ERROR/INFO/WARN/SUCCESS.
     * @return An HTML string <b><span style="color:{color}>;">{CurrentDatetime}</span></b>.
     */
    public static String getHtmlMessageHeader(ForceeaService.AsyncMessageType messageType) {
        String color = '';
        switch on messageType {
            when MESSAGE_TYPE_ERROR {
                color += 'red';
            } when MESSAGE_TYPE_INFO {
                color += 'black';
            } when MESSAGE_TYPE_SUCCESS {
                color += 'green';
            } when MESSAGE_TYPE_WARN {
                color += 'darkorange';
            }
        }

        return '<b><span style="color:' + color + ';">' + Datetime.now() + '</span></b> ';
    }

    /**
     * @description Retrieves the AsyncApexJob records.
     * @return A list of AsyncApexJob records.
     */
    public static List<AsyncApexJob> getJobs() {
        Set<String> statuses = new Set<String>{
            'Preparing', 'Processing', 'Queued'
        };
        return new ForceeaSelector().selectAsyncJobsByStatus(statuses);
    }

    /**
     * @description Generates a lowercase 2-part key "majorValue.minorValue".
     * @param majorValue The first part of the key, e.g. the SObject API name.
     * @param minorValue The second part of the key, e.g. the group name.
     * @return A string of the generated key.
     */
    public static String getKey(String majorValue, String minorValue) {
        return getStringValueToLower(majorValue) + '.' + getStringValueToLower(minorValue);
    }

    /**
     * @description Retrieves the long number of milliseconds equal to a given number of days.
     * @param days The decimal number of days.
     * @return The long number of milliseconds.
     */
    public static Long getMillisecondsFromDays(Decimal days) {
        Decimal result = days * 86400 * 1000;
        return (Long) result;
    }

    /**
     * @description Retrieves the number reduced by a percent.
     * @param value The FObject.
     * @param percent The definition string.
     * @return The reduced integer number.
     */
    public static Integer getNumberReducedByPercent(Decimal value, Decimal percent) {
        return Integer.valueOf((1 - percent / 100) * value);
    }

    /**
     * @description The recursive calculation of permutation values.
     * @param lists The permutation lists.
     * @param results The list of permutation strings.
     * @param depth The initial level in the hierarchy of permutation lists.
     * @param current The current item.
     */
    public static void getPermutations(
        List<List<String>> lists, List<String> results, Integer depth, String current) {
        if (depth == lists.size()) {
            results.add(current);
            return;
        }

        for (Integer i = 0; i < lists.get(depth).size(); i++) {
            String newCurrent = current + '@@@' + lists.get(depth).get(i);
            getPermutations(lists, results, depth + 1, newCurrent);
        }
    }

    /**
     * @description Retrieves the ID of the queueable class.
     * @return The queueable class ID.
     */
    public static Id getQueueableClassId() {
        return ForceeaService.QUEUEABLE_CLASS_ID;
    }

    /**
     * @description Retrieves the API name of an SObject or an empty string if the name is invalid.
     * @param fObj The FObject.
     * @param definitionString The definition string.
     * @param sObjectName The SObject name.
     * @param relatedFieldApiName The API name of the field that lookup field is related to.
     * @param category The field category: standard, lookup.
     * @return A string value.
     */
    public static String getSObjectApiName(
        FObject fObj, String definitionString, String sObjectName, String relatedFieldApiName, String category) {
        sObjectName = sObjectName.trim();

        String sObjectApiName = ForceeaService.getSObjectApiName(sObjectName);
        if (String.isNotBlank(sObjectApiName)) {
            return sObjectApiName;
        }

        switch on category.toLowerCase() {
            when 'standard' {
                fObj.addError(sObjectName, MESSAGE_INVALID_SOBJECT + ' [' + sObjectName + ']');
            } when 'lookup' {
                fObj.addError(relatedFieldApiName,
                    MESSAGE_INVALID_LOOKUP_SOBJECT + ' [' + sObjectName +
                    '] in definition [' + definitionString + ']');
            }
        }

        return '';
    }

    /**
     * @description Retrieves the SObject API name or an empty string if invalid.
     * @param sObjectName The SObject name.
     * @return The string of SObject API name.
     */
    public static String getSObjectApiName(String sObjectName) {
        Forceea.SObjectInfo info = ForceeaService.getSObjectInfo(sObjectName);
        if (info == null) {
            return '';
        }

        return info.sObjectApiName;
    }

    /**
     * @description Retrieves the Schema.SObjectField map for an SObject.
     * @param sObjectApiName The SObject API name.
     * @param fieldApiName The field API name.
     * @return The Schema.SObjectField object or null if the field doesn't exist in cache.
     */
    private static Schema.SObjectField getSObjectFieldFromString(String sObjectApiName, String fieldApiName) {
        Schema.SObjectField result;

        Map<String, Schema.SObjectField> sObjectFieldsByName = ForceeaService.getSObjectFieldsByName(sObjectApiName);
        if (sObjectFieldsByName.containsKey(fieldApiName)) {
            result = sObjectFieldsByName.get(fieldApiName);
        }

        return result;
    }

    /**
     * @description Retrieves the Schema.SObjectField map for an SObject.
     * @param sObjectApiName The SObject API name.
     * @return A Schema.SObjectField map.
     */
    public static Map<String, Schema.SObjectField> getSObjectFieldsByName(String sObjectApiName) {
        String key = sObjectApiName.toLowerCase();

        if (!ForceeaService.sObjectFieldsMapBySObjectName.containsKey(key)) {
            Map<String, Schema.SObjectField> fieldInfosByName =
                ForceeaService.getSObjectType(sObjectApiName).getDescribe().fields.getMap();
            ForceeaService.sObjectFieldsMapBySObjectName.put(key, fieldInfosByName);
        }

        return ForceeaService.sObjectFieldsMapBySObjectName.get(key);
    }

    /**
     * @description Retrieves the SObjectInfo object related to an SObject name.
     * @param sObjectName The SObject name.
     * @return An SObjectInfo object.
     */
    public static Forceea.SObjectInfo getSObjectInfo(String sObjectName) {
        Forceea.SObjectInfo result;
        String sObjectApiNameToLower = sObjectName.toLowerCase();
        if (sObjectInfosBySObjectName.containsKey(sObjectApiNameToLower)) {
            return sObjectInfosBySObjectName.get(sObjectApiNameToLower);
        }

        List<Schema.DescribeSObjectResult> describeResults = new List<DescribeSObjectResult>();
        try {
            describeResults = Schema.describeSObjects(new List<String>{
                sObjectName
            });
        } catch (Exception exp) {
        } finally {
            if (!describeResults.isEmpty()) {
                result = new Forceea.SObjectInfo();
                result.sObjectApiName = describeResults.get(0).getName();
                result.sObjType = describeResults.get(0).getSObjectType();

                sObjectInfosBySObjectName.put(result.sObjectApiName.toLowerCase(), result);
                sObjectInfosBySObjectType.put(result.sObjType, result);
            }
        }
        return result;
    }

    /**
     * @description Retrieves the SObjectType from the SObject name.
     * @param sObjectApiName The SObject API name.
     * @return An SObjectInfo object.
     */
    public static Schema.SObjectType getSObjectType(String sObjectApiName) {
        String sObjectApiNameToLower = sObjectApiName.toLowerCase();
        if (sObjectInfosBySObjectName.containsKey(sObjectApiNameToLower)) {
            return sObjectInfosBySObjectName.get(sObjectApiNameToLower).sObjType;
        }

        Schema.SObjectType result;
        List<Schema.DescribeSObjectResult> describeResults = new List<DescribeSObjectResult>();
        Boolean hasError = false;
        try {
            describeResults = Schema.describeSObjects(new List<String>{
                sObjectApiName
            });
        } catch (Exception exp) {
            hasError = true;
        }

        if (!hasError) {
            result = describeResults.get(0).getSObjectType();
            String sObjApiName = describeResults.get(0).getName();
            sObjectInfosBySObjectName.put(sObjectApiName.toLowerCase(), getForceeaSObjectInfo(sObjApiName, result));
        }

        return result;
    }

    /**
     * @description Retrieves the active Standard Pricebook ID.
     * @return The Standard Price-book ID.
     */
    public Id getStandardPriceBookId() {
        if (Test.isRunningTest()) {
            return Test.getStandardPricebookId();
        }

        return new ForceeaSelector().selectStandardPriceBook()?.Id;
    }

    /**
     * @description Retrieves a string with joined List items (strings) using a separator.
     * @param values The List string values.
     * @param separator The separator, e.g. ",".
     * @return The joined string values.
     */
    public static String getStringFromList(List<String> values, String separator) {
        for (Integer counter = 0; counter < values.size(); counter++) {
            values[counter] = values[counter].trim();
        }
        return String.join(values, separator);
    }

    /**
     * @description Retrieves a trimmed string value as '' if string is blank.
     * @param value The string value.
     * @return The converted string.
     */
    public static String getStringValue(String value) {
        return String.isBlank(value) ? '' : value.trim();
    }

    /**
     * @description Retrieves a trimmed lowercase string value as '' if string is blank.
     * @param value The string value.
     * @return The converted string.
     */
    public static String getStringValueToLower(String value) {
        return String.isBlank(value) ? '' : value.trim().toLowerCase();
    }

    /**
     * @description Retrieves the ValueType enum of a string.
     * @param argument The string to be evaluated.
     * @return A ValueType enum represented by a string value.
     */
    public ForceeaService.ValueType getValueType(String argument) {
        // IMPORTANT: DO NOT CHANGE THE ORDER OF TYPES
        if (valueIsInteger(argument)) {
            return ValueType.TYPE_INTEGER;
        } else if (valueIsDecimal(argument)) {
            return ValueType.TYPE_DECIMAL;
        } else if (valueIsDatetime(argument)) {
            return ValueType.TYPE_DATETIME;
        } else if (valueIsDate(argument)) {
            return ValueType.TYPE_DATE;
        } else if (valueIsTime(argument)) {
            return ValueType.TYPE_TIME;
        } else {
            return ValueType.TYPE_STRING;
        }
    }

    /**
     * @description Informs if the global fields map contains a field.
     * @param sObjectApiNameToLower The SObject API name in lowercase.
     * @param fieldApiNameToLower The field API name in lowercase.
     * @return True, if the map contains the field.
     */
    private static Boolean globalFieldsMapContains(String sObjectApiNameToLower, String fieldApiNameToLower) {
        Boolean result = false;

        if (FObject.globalFieldsMapBySObject.containsKey(sObjectApiNameToLower) &&
            FObject.globalFieldsMapBySObject.get(sObjectApiNameToLower).containsKey(fieldApiNameToLower)) {
            result = true;
        }

        return result;
    }

    private static void handleMaxStackDepthError(Exception exp, Forceea.AsyncTransaction fObjectTransaction) {
        if (!errorIsRelatedToMaxStackDepth(exp)) {
            return;
        }

        executeWithFuture(JSON.serialize(fObjectTransaction));
    }

    /**
     * @description Inserts a new record of Process custom setting.
     * @param newValue The new value.
     */
    private static void insertNewProcessCustomSettingRecord(Boolean newValue) {
        insert new ForceeaProcess__c(
            Name = FORCEEA_PROCESS_SETTING_NAME,
            IsTerminated__c = newValue
        );
    }

    /**
     * @description Checks if the SObject is a Big Object.
     * @param sObjectApiName The SObject API name.
     * @return If true, the SObject is a Big Object.
     */
    public static Boolean isBigObject(String sObjectApiName) {
        return sObjectApiName.endsWith('__b');
    }

    /**
     * @description Keeps some case-insensitive values in a list and removes anything else.
     * @param listToProcess The list to be processed.
     * @param valuesToKeep The values to keep in the list.
     * @return A list of string values.
     */
    public static List<String> keepValuesInList(List<String> listToProcess, List<String> valuesToKeep) {
        List<String> results = new List<String>();
        List<String> valuesToKeepToLowercase = convertListToLowercase(valuesToKeep);
        String valueLowercase = '';
        Boolean mustInclude = false;

        for (String value : listToProcess) {
            mustInclude = false;
            valueLowercase = value.toLowerCase();
            for (String valueToKeep : valuesToKeepToLowercase) {
                if (valueLowercase == valueToKeep) {
                    mustInclude = true;
                    break;
                }
            }
            if (mustInclude) {
                results.add(value);
            }
        }

        return results;
    }

    /**
     * @description Publishes a platform event with a message to the user.
     * @param messageType The message type.
     * @param message The message.
     */
    public static void publishUserMessage(ForceeaService.AsyncMessageType messageType, String message) {
        if (String.isBlank(message)) {
            return;
        }

        ForceeaAsyncNotification__e platformEvent = new ForceeaAsyncNotification__e(
            Message__c = ForceeaService.getHtmlMessageHeader(messageType) + message + '<br/>',
            OperationType__c = 'user-message'
        );
        EventBus.publish(platformEvent);
    }

    /**
     * @description Puts a SaveResult value into a map.
     * @param mapToProcess The map.
     * @param key The map key.
     * @param value The SaveResult value.
     */
    public static void putSaveResultIntoMap(
        Map<String, List<Database.SaveResult>> mapToProcess, String key, Database.SaveResult value) {
        List<Database.SaveResult> records = new List<Database.SaveResult>();

        if (mapToProcess.containsKey(key)) {
            records = mapToProcess.get(key);
        }

        records.add(value);
        mapToProcess.put(key, records);
    }

    /**
     * @description Puts an SObject value into a map.
     * @param mapToProcess The map.
     * @param key The map key.
     * @param value The SObject value.
     */
    public static void putSObjectIntoMap(Map<String, List<SObject>> mapToProcess, String key, SObject value) {
        List<SObject> records = new List<SObject>();

        if (mapToProcess.containsKey(key)) {
            records = mapToProcess.get(key);
        }

        records.add(value);
        mapToProcess.put(key, records);
    }

    /**
     * @description Puts SObject values into a map.
     * @param mapToProcess The map.
     * @param key The map key.
     * @param values The SObject values.
     */
    public static void putSObjectsIntoMap(Map<String, List<SObject>> mapToProcess, String key, List<SObject> values) {
        if (mapToProcess == null || values == null || values.isEmpty()) {
            return;
        }

        key = (String.isBlank(key)) ? '' : key;
        if (!mapToProcess.containsKey(key)) {
            mapToProcess.put(key, new List<SObject>());
        }

        List<SObject> sObjects = mapToProcess.get(key);
        sObjects.addAll(values);
        mapToProcess.put(key, sObjects);
    }

    /**
     * @description Checks if the environment is Production org.
     * @return True, if the org is Production.
     */
    public static Boolean recordsCanBeDeletedInThisOrg() {
        Organization org = new ForceeaSelector().selectOrganization();
        // Boolean isSandboxOrg = org.IsSandbox && org.TrialExpirationDate == null;
        // Boolean isScratchOrg = org.IsSandbox && org.TrialExpirationDate != null;
        // Boolean isDeveloperOrg = !org.IsSandbox && org.OrganizationType.equalsIgnoreCase('Developer Edition');
        // Boolean isTrialOrg = !org.IsSandbox && org.TrialExpirationDate != null;
        Boolean isOtherThanProductionOrg = org.IsSandbox ||
            org.OrganizationType.equalsIgnoreCase('Developer Edition') || org.TrialExpirationDate != null;

        return Test.isRunningTest() || isOtherThanProductionOrg;
    }

    /**
     * @description Removes some case-insensitive values from a list.
     * @param listToProcess The list from which the values will be processed.
     * @param valuesToRemove The values to remove from the list.
     * @return A list of string values.
     */
    public static List<String> removeValuesFromList(List<String> listToProcess, List<String> valuesToRemove) {
        List<String> results = new List<String>();

        if (valuesToRemove.isEmpty()) {
            return listToProcess;
        }

        for (String value : listToProcess) {
            Boolean mustInclude = true;
            for (String valueToRemove : valuesToRemove) {
                if (value.equalsIgnoreCase(valueToRemove)) {
                    mustInclude = false;
                    break;
                }
            }
            if (mustInclude) {
                results.add(value);
            }
        }

        return results;
    }

    /**
     * @description Retrieves the field API name or a blank string if the field name is invalid.
     * @param field The field info object.
     * @param sObjectApiName The SObject API name.
     */
    private static void setFieldInGlobalFieldsMap(Forceea.FieldInfo field, String sObjectApiName) {
        String fieldApiNameToLower = field.fieldApiName.toLowerCase();
        String sObjectApiNameToLower = sObjectApiName.toLowerCase();

        if (!globalFieldsMapContains(sObjectApiNameToLower, fieldApiNameToLower)) {
            if (!FObject.globalFieldsMapBySObject.containsKey(sObjectApiNameToLower)) {
                FObject.globalFieldsMapBySObject.put(sObjectApiNameToLower, new Map<String, Forceea.FieldInfo>());
            }

            Map<String, Forceea.FieldInfo> fieldsByName = FObject.globalFieldsMapBySObject.get(sObjectApiNameToLower);
            fieldsByName.put(fieldApiNameToLower, field);
            FObject.globalFieldsMapBySObject.put(sObjectApiNameToLower, fieldsByName);
        }
    }

    /**
     * @description Updates the Forceea Process custom setting field value IsTerminated.
     * @param isTerminated The new value of field IsTerminated.
     */
    public static void setProcessCustomSetting(Boolean isTerminated) {
        Boolean newValue = isTerminated;
        ForceeaProcess__c existingSettingRecord = getForceeaProcessSetting();

        if (existingSettingRecord != null) {
            updateExistingProcessCustomSettingRecord(existingSettingRecord, newValue);
        } else {
            insertNewProcessCustomSettingRecord(newValue);
        }
    }

    /**
     * @description Sets the standard price book ID for every applicable FObject of the Template.
     * @param fObj An FObject object.
     */
    public static void setStandardPriceBookId(FObject fObj) {
        if (String.isNotBlank(fObj.virtualFieldForStandardPriceBookEntries)) {
            fObj.standardPriceBookId = STANDARD_PRICEBOOK_ID;
        }
    }

    /**
     * @description Sets the standard price book ID for every applicable FObject of the Template.
     * @param template A map with key: FObject key, value: FObject.
     */
    public static void setStandardPriceBookId(Map<String, FObject> template) {
        for (FObject fObj : template.values()) {
            setStandardPriceBookId(fObj);
        }
    }

    /**
     * @description Informs for the validity of the source.
     * @param source The source (forceea or salesforce).
     * @return True, if the source is valid.
     */
    public static Boolean sourceIsValid(String source) {
        return source.equalsIgnoreCase(ForceeaService.SOURCE_FORCEEA) ||
            source.equalsIgnoreCase(ForceeaService.SOURCE_SALESFORCE);
    }

    /**
     * @description Updates the IsTerminated__c field of an existing Process custom setting record.
     * @param existingRecord The existing record of Process custom setting.
     * @param newValue The value for updating the IsTerminated__c field.
     */
    private static void updateExistingProcessCustomSettingRecord(
        ForceeaProcess__c existingRecord, Boolean newValue) {

        Boolean oldValue = existingRecord.IsTerminated__c;
        if (oldValue == newValue) {
            return;
        }

        try {
            // new value is different from old
            existingRecord.IsTerminated__c = newValue;
            update existingRecord;
        } catch (Exception ex) {
            ForceeaService.publishUserMessage(ForceeaService.AsyncMessageType.MESSAGE_TYPE_WARN,
                'Forceea cannot update the Process custom setting');
        }
    }

    /**
     * @description Decides if the string data type is Date.
     * @param str The String parameter to validate.
     * @return True, if the String value has a Date data type.
     */
    private Boolean valueIsDate(String str) {
        try {
            Date value = Date.valueOf(str); // NOPMD
            return true;
        } catch (System.TypeException ex) {
            return false;
        }
    }

    /**
     * @description Decides if the string data type is Datetime.
     * @param str The String parameter to validate.
     * @return True, if the String value has a Datetime data type.
     */
    private Boolean valueIsDatetime(String str) {
        try {
            Datetime value = Datetime.valueOf(str); // NOPMD
            return true;
        } catch (System.TypeException ex) {
            return false;
        }
    }

    /**
     * @description Decides if the string data type is Decimal.
     * @param str The String parameter to validate.
     * @return True, if the String value has a Decimal data type.
     */
    private Boolean valueIsDecimal(String str) {
        try {
            Decimal value = Decimal.valueOf(str); // NOPMD
            return true;
        } catch (System.TypeException ex) {
            return false;
        }
    }

    /**
     * @description Decides if the string data type is Integer.
     * @param str The String parameter to validate.
     * @return True, if the String value has an Integer data type.
     */
    private Boolean valueIsInteger(String str) {
        try {
            Integer value = Integer.valueOf(str); // NOPMD
            return true;
        } catch (System.TypeException ex) {
            return false;
        }
    }

    /**
     * @description Decides if the string data type is Time.
     * @param str The String parameter to validate.
     * @return True, if the String value has a Time data type.
     */
    private Boolean valueIsTime(String str) {
        try {
            Datetime value = Datetime.valueOf('2000-01-01 ' + str); // NOPMD
            return true;
        } catch (System.TypeException ex) {
            return false;
        }
    }

    /**
     * @description If true, the value types is date.
     * @param valueType The value type to assess.
     * @return True, if the value type is date.
     */
    private Boolean valueTypeIsDate(ForceeaService.ValueType valueType) {
        return (valueType == ForceeaService.ValueType.TYPE_DATE);
    }

    /**
     * @description If true, the value types is datetime.
     * @param valueType The value type to assess.
     * @return True, if the value type is datetime.
     */
    private Boolean valueTypeIsDatetime(ForceeaService.ValueType valueType) {
        return (valueType == ForceeaService.ValueType.TYPE_DATETIME);
    }

    /**
     * @description If true, the value types is number.
     * @param valueType The value type to assess.
     * @return True, if the value type is number.
     */
    private Boolean valueTypeIsNumber(ForceeaService.ValueType valueType) {
        return (valueType == ForceeaService.ValueType.TYPE_INTEGER ||
            valueType == ForceeaService.ValueType.TYPE_DECIMAL);
    }

    /**
     * @description If true, the current and added value types are numbers.
     * @param existingValueType The type of the current value string.
     * @param addedValueType The type of the string value to add.
     * @return True, if the existing and added values are numbers.
     */
    public Boolean valueTypesToAddAreNumbers(ValueType existingValueType, ValueType addedValueType) {
        return valueTypeIsNumber(existingValueType) && valueTypeIsNumber(addedValueType);
    }

    /**
     * @description If true, the current and added value types are dates.
     * @param existingValueType The type of the current value string.
     * @param addedValueType The type of the string value to add.
     * @return True, if the existing and added values are dates.
     */
    public Boolean valueTypesToAddAreDate(ValueType existingValueType, ValueType addedValueType) {
        return valueTypeIsDate(existingValueType) && valueTypeIsNumber(addedValueType);
    }

    /**
     * @description If true, the current and added value types are datetimes.
     * @param existingValueType The type of the current value string.
     * @param addedValueType The type of the string value to add.
     * @return True, if the existing and added values are datetimes.
     */
    public Boolean valueTypesToAddAreDatetime(ValueType existingValueType, ValueType addedValueType) {
        return valueTypeIsDatetime(existingValueType) && valueTypeIsNumber(addedValueType);
    }

}