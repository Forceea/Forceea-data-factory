/*
  Forceea data factory (v2.1.2)
  Copyright (C) 2020 Nikos Mitrakis

  This program is free software: you can redistribute it and/or modify it under the terms
  of the GNU General Public License as published by the Free Software Foundation,
  either version 3 of the License, or any later version.

  This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
  without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  See the GNU General Public License for more details.

  You can find a copy of the GNU General Public License at
  https://github.com/nmitrakis/Forceea/blob/master/LICENSE
*/
public with sharing class ForceeaService {

    /* CONSTANTS */

    public static final String COMMAND_COPY = 'copy';
    public static final String COMMAND_FUNCTION_ADD = 'function-add';
    public static final String COMMAND_MOCK = 'mock';
    public static final String COMMAND_RANDOM = 'random';
    public static final String COMMAND_SERIAL = 'serial';
    public static final String COMMAND_STATIC = 'static';

    public static final String MODE_PERMUTATION = 'permutation';

    public static final String DEBUG = 'debug';
    public static final String ERROR = 'error';
    public static final String INFO = 'info';
    public static final String WARN = 'warn';
    private static final String FORCEEA_PROCESS_SETTING_NAME = 'Standard';
    public static final String SOURCE_FORCEEA = 'forceea';
    public static final String SOURCE_SALESFORCE = 'salesforce';

    public static final String PARAMETER_EXCEPT = 'except';
    public static final String PARAMETER_FIELD = 'field';
    public static final String PARAMETER_FROM = 'from';
    public static final String PARAMETER_GROUP = 'group';
    public static final String PARAMETER_LOOKUP = 'lookup';
    public static final String PARAMETER_SCALE = 'scale';
    public static final String PARAMETER_MODE = 'mode';
    public static final String PARAMETER_SOURCE = 'source';
    public static final String PARAMETER_TO = 'to';
    public static final String PARAMETER_VALUE = 'value';
    public static final String PARAMETER_WHERE = 'where';

    public static final String RECORD_TYPE_ID = 'RecordTypeId';

    public static final String MESSAGE_ADDRESSES = 'Loaded addresses from ';
    public static final String MESSAGE_FOUND_ERRORS_SELECTING_FROM_LOOKUP =
        'Found errors selecting records from the lookup SObject';
    public static final String MESSAGE_GENERATED_DEFINITION = 'Generated definition';
    public static final String MESSAGE_INVALID_DEFINITION = 'Invalid definition';
    public static final String MESSAGE_INVALID_FIELD = 'Invalid field';
    public static final String MESSAGE_INVALID_LOOKUP_SOBJECT = 'Invalid lookup SObject';
    public static final String MESSAGE_INVALID_PROCESS = 'Process is invalid and will terminate.';
    public static final String MESSAGE_INVALID_SOBJECT = 'Invalid SObject';
    public static final String MESSAGE_NAMES = 'Loaded first & last names from';
    public static final String MESSAGE_VALUES = 'Values of';
    public static final String MESSAGE_VALIDATED_DEFINITIONS = 'Validated definitions of';
    public static final String MESSAGE_WILL_DELETE_ALL_FIELDS_DEFINITIONS = 'Will delete all field definitions of';
    public static final String MESSAGE_WILL_DELETE_FIELD_DEFINITIONS = 'Will delete all definitions of field';
    public static final String MESSAGE_WILL_DELETE_RECORDS = 'Will delete records';
    public static final String MESSAGE_WILL_DISPLAY_CREATED_FIELD_VALUES = 'Will display the created field values';
    public static final String MESSAGE_WILL_INSERT_CREATED_RECORDS = 'Will insert the created records';
    public static final String MESSAGE_WILL_NOT_INSERT_RECORDS = 'Will not insert records';
    public static final String MESSAGE_WILL_NOT_SET_DEFINITIONS_OF_REQUIRED_FIELDS =
        'Will not set the definition of required fields';
    public static final String MESSAGE_WILL_SET_DEFINITIONS_OF_REQUIRED_FIELDS =
        'Will set the definition of required fields';
    public static final String MESSAGE_WILL_STORE_CREATED_RECORDS = 'Will store the created records with mocked IDs';
    public static final String MESSAGE_WILL_UPDATE_FIELD_VALUES = 'Will update the field values';
    public static final String MESSAGE_WILL_UPDATE_RECORDS = 'Will update the records';
    public static final String MESSAGE_WILL_VALIDATE_FIELD_DEFINITIONS = 'Will validate the field definitions';
    public static final String MESSAGE_WITH_DEFINITION = 'with definition';

    /* ENUMS */

    public enum asyncMessageType {
        MESSAGE_TYPE_ERROR, MESSAGE_TYPE_INFO, MESSAGE_TYPE_WARN, MESSAGE_TYPE_SUCCESS
    }
    public enum OperationType {
        ASYNC_INSERT, ASYNC_DELETE
    }

    /* STATIC VARIABLES & PROPERTIES */

    // the ID of the ForceeaQueueable class
    private static Id classId {
        get {
            if (classId == null) {
                classId = [SELECT Id FROM ApexClass WHERE Name = 'ForceeaQueueable'].Id;
            }
            return classId;
        }
        set;
    }
    // the async Process ID
    public static String processId = '';

    /* CLASSES */

    public class FieldDefinition {
        public String definitionString = '';
        public String fieldApiName = '';
    }

    public class FObjectAsync {
        public List<FieldDefinition> definitions = new List<FieldDefinition>();
        public Boolean setRequiredFields = true;
        public Integer numOfRecords = 0;
        public String sObjectApiName = '';
        public String partitionFieldName = '';
    }

    public class AsyncTransaction {
        public Map<String, Integer> numFirstRecordsBySObject = new Map<String, Integer>();
        public List<ForceeaService.FObjectAsync> sObjectsToDelete = new List<ForceeaService.FObjectAsync>();
        public Map<String, ForceeaService.FObjectAsync> template = new Map<String, ForceeaService.FObjectAsync>();

        public Integer batchId = 1;
        public Boolean hasPartitioning = true;
        public Boolean isBenchmark = false;
        public Integer jobId = 0;
        public String locality = '';
        public String language = '';
        public Integer numErrors = 0;
        public Integer numJobs = 0;
        public Integer numJobUnitsExecuted = 0; // the iterations that have been inserted in the job
        public Integer numJobUnitsToExecute = 0; // the units that should be executed in the job
        public Integer numTotalJobUnits = 0; // the units that should be executed in the job
        public Integer numMaxUnitsPerBatch = 1; // the max units allowed to be executed per batch
        public Integer numProcessUnitsToExecute = 0; // the total units (iterations/records) that should be executed
        public ForceeaService.OperationType operationType;
        public String partitionFieldValue = '';
        public String processId = '';
        public Long seed = 0;
        public Integer sector = 0;
        public Integer sObjectToDeleteIndex = 0;
        public String sObjectApiName = '';
    }

    public class Variable {
        public Boolean booleanValue { get; set; }
        public Date dateValue { get; set; }
        public Datetime datetimeValue { get; set; }
        public Decimal decimalValue { get; set; }
        public Integer integerValue { get; set; }
        public Boolean isGlobalVariable { get; set; }
        public String name { get; set; }
        public String stringValue { get; set; }

        public Variable(String name, Boolean value, Boolean isGlobalVariable) {
            this.name = name;
            this.booleanValue = value;
            this.isGlobalVariable = isGlobalVariable;
        }

        public Variable(String name, Date value, Boolean isGlobalVariable) {
            this.name = name;
            this.dateValue = value;
            this.isGlobalVariable = isGlobalVariable;
        }

        public Variable(String name, Datetime value, Boolean isGlobalVariable) {
            this.name = name;
            this.datetimeValue = value;
            this.isGlobalVariable = isGlobalVariable;
        }

        public Variable(String name, Decimal value, Boolean isGlobalVariable) {
            this.name = name;
            this.decimalValue = value;
            this.isGlobalVariable = isGlobalVariable;
        }

        public Variable(String name, Integer value, Boolean isGlobalVariable) {
            this.name = name;
            this.integerValue = value;
            this.isGlobalVariable = isGlobalVariable;
        }

        public Variable(String name, String value, Boolean isGlobalVariable) {
            this.name = name;
            this.stringValue = value;
            this.isGlobalVariable = isGlobalVariable;
        }
    }

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
    public static void enqueueJob(ForceeaService.AsyncTransaction fObjectTransaction) {
        System.enqueueJob(new ForceeaQueueable(fObjectTransaction));
    }

    /**
     * @description Determines is the field has multiple definitions.
     * @param fieldName The API name of the field.
     * @return A boolean value.
     */
    public static Boolean fieldIsVirtual(String fieldName) {
        return (fieldName.toLowerCase().left(1) == '$');
    }

    /**
     * @description Retrieves the API name of a specific SObject's field or a blank string if the field name is invalid.
     * @param fObj The FObject.
     * @param definitionString The definition string.
     * @param sObjectApiName The SObject API Name.
     * @param fieldName The field name.
     * @param relatedFieldApiName The API name of the field that lookup field is related to.
     * @param category The field category for fields (standard/lookup) or methods (e.g.deleteDefinitions).
     * @return A string value.
     */
    public static String getFieldApiName(FObject fObj, String definitionString, String sObjectApiName, String fieldName,
        String relatedFieldApiName, String category) {
        String result = '';

        if (ForceeaService.fieldIsVirtual(fieldName)) {
            return fieldName;
        }

        if (String.isBlank(sObjectApiName)) {
            return result;
        }

        fieldName = fieldName.trim();
        Map<String, FObject.Field> fieldsByFieldApiName = FObject.globalFieldsMapBySObject.get(sObjectApiName.toLowerCase());
        if (fieldsByFieldApiName.containsKey(fieldName.toLowerCase())) {
            result = fieldsByFieldApiName.get(fieldName.toLowerCase()).fieldApiName;
        }

        if (String.isNotBlank(result)) {
            return result;
        }

        switch on category.toLowerCase() {
            when 'standard' {
                fObj.addError(fObj.sObjectApiName,
                    'Invalid field [' + fieldName + '] in definition [' + definitionString + ']');
            }
            when 'copy-field' {
                fObj.addError(relatedFieldApiName,
                    'Invalid copy field [' + fieldName + '] in definition [' + definitionString + ']');
            }
            when 'copy-from' {
                fObj.addError(relatedFieldApiName,
                    'Invalid lookup field [' + sObjectApiName + '.' + fieldName + '] in definition [' + definitionString + ']');
            }
            when 'deletedefinitions' {
                if (!fObj.isUpdate) {
                    fObj.addErrorInvalidFieldInMethod(fObj.sObjectApiName, fieldName, category);
                    return result;
                }
            }
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
     * @description Enqueues a transaction for asynchronous processing.
     * @param messageType An asyncMessageType (MESSAGE_TYPE_ ERROR/INFO/WARN/SUCCESS.
     * @return An HTML string <b><span style="color:{color}>;">{CurrentDatetime}</span></b>.
     */
    public static String getHtmlMessageHeader(ForceeaService.asyncMessageType messageType) {
        String color = '';
        switch on messageType {
            when MESSAGE_TYPE_ERROR {
                color += 'red';
            }
            when MESSAGE_TYPE_INFO {
                color += 'black';
            }
            when MESSAGE_TYPE_SUCCESS {
                color += 'green';
            }
            when MESSAGE_TYPE_WARN {
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
        return [
            SELECT Id
            FROM AsyncApexJob
            WHERE ApexClassId = :ForceeaService.classId AND Status IN :statuses
        ];
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
     * @description Constructs the plural of a countable noun.
     * @param text The countable noun.
     * @param count The number of occurrences.
     * @return The ForceeaProcess__c custom setting "Standard" record.
     */
    public static String getPlural(String text, Integer count) {
        Boolean isOne = (count == 1 || count == -1);
        String result = (isOne) ? text : text + 's';
        return result;
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
        String result = '';
        sObjectName = sObjectName.trim();

        if (String.isBlank(sObjectName)) {
            fObj.addError(sObjectName, ForceeaService.MESSAGE_INVALID_SOBJECT + ' [' + sObjectName + ']');
            return result;
        }

        for (String name : FObject.sObjectApiNames) {
            if (name.equalsIgnoreCase(sObjectName)) {
                result = name;
                break;
            }
        }

        if (String.isNotBlank(result)) {
            return result;
        }

        switch on category.toLowerCase() {
            when 'standard' {
                fObj.addError(sObjectName, ForceeaService.MESSAGE_INVALID_SOBJECT + ' [' + sObjectName + ']');
            }
            when 'lookup' {
                fObj.addError(relatedFieldApiName,
                    ForceeaService.MESSAGE_INVALID_LOOKUP_SOBJECT + ' [' + sObjectName +
                        '] in definition [' + definitionString + ']');
            }
        }

        return result;
    }

    public static String getStringValue(String value) {
        return String.isBlank(value) ? '' : value;
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
     * @description Keeps some case-insensitive values in a list and removes anything else.
     * @param listToProcess The list to be processed.
     * @param valuesToKeep The values to keep in the list.
     * @return A list of string values.
     */
    public static List<String> keepValuesInList(List<String> listToProcess, List<String> valuesToKeep) {
        List<String> results = new List<String>();
        List<String> valuesToKeepToLowercase = ForceeaService.convertListToLowercase(valuesToKeep);
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
    public static void publishUserMessage(ForceeaService.asyncMessageType messageType, String message) {
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
     * @description Checks if data are allowed to be deleted.
     * @return True, if the data can be deleted.
     */
    public static Boolean recordsCanBeDeletedInThisOrg() {
        Organization org = [
            SELECT IsSandbox, OrganizationType, TrialExpirationDate
            FROM Organization
            WHERE Id = :UserInfo.getOrganizationId()
        ];

        Boolean isOtherThanProductionOrg = org.IsSandbox ||
            org.OrganizationType.equalsIgnoreCase('Developer Edition') || org.TrialExpirationDate != null;

        return Test.isRunningTest() || isOtherThanProductionOrg;
    }

    /**
     * @description Removes some case-insensitive values in a list.
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

        try { // new value is different from old
            existingRecord.IsTerminated__c = newValue;
            update existingRecord;
        } catch (Exception ex) {
            ForceeaService.publishUserMessage(ForceeaService.asyncMessageType.MESSAGE_TYPE_WARN,
                'Forceea cannot update the Process custom setting');
        }
    }

}