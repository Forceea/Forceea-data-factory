/*
  Forceea data factory (v2.9.0)
  Copyright (C) 2023 Nikos Mitrakis

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
 * @description Handles the synchronous Forceea operations.
 */
@SuppressWarnings('PMD.FieldDeclarationsShouldBeAtStart, PMD.AvoidGlobalModifier')
global with sharing class FObject {

    /* CONSTANTS */

    private static final String DEBUG_LOG_PROMPT = 'FORCEEA ';
    @TestVisible private static final Integer DEFAULT_NUM_MAX_ERROR_RECORDS_TO_DISPLAY = 20;
    @TestVisible private static final Integer DEFAULT_NUM_RECORDS_TO_CREATE = 201;
    @TestVisible private static final Integer DEFAULT_NUM_RECORDS_TO_DISPLAY = 20;
    public static final Integer DEFAULT_QUERY_LIMIT = 1000;
    public static final Integer DEFAULT_QUERY_LIMIT_FOR_BIG_OBJECT = 50000;
    private static final Integer DEFAULT_TIME_FRAME_FOR_UPDATE = 0;
    private static final String MESSAGE_INVALID_PROCESS = 'Process is invalid and will terminate.';
    private static final String MESSAGE_INVALID_VALUE = 'Invalid value';
    private static final String MESSAGE_FOR_RECORD = 'for record #';
    public static final String MESSAGE_INVALID_VIRTUAL_FIELD = 'Invalid virtual field';
    public static final String MESSAGE_METHOD_SET_STANDARD_PRICEBOOK_ENTRIES = 'in method [setStandardPricebookEntries]';
    private static final String MESSAGE_VALIDATED_DEFINITIONS = 'Validated definitions of';
    private static final String MESSAGE_WILL_REMOVE_ALL_FIELDS_DEFINITIONS = 'Will remove all field definitions of';
    private static final String MESSAGE_WILL_REMOVE_DEFINITION_WITH_ID = 'Will remove the definition with ID';
    private static final String MESSAGE_WILL_SET_DEFINITIONS_OF_REQUIRED_FIELDS =
        'Will set the definition of required fields';
    public static final String MESSAGE_WILL_VALIDATE_FIELD_DEFINITIONS = 'Will validate the field definitions';
    private static final String PERMUTATIONS_AUTO = 'auto';
    private static final String SETTINGS_DEFAULT = 'Default';
    public static final String PRODUCT2 = 'Product2';
    private static final String SYMBOL_FAILURE = '*';
    public static final String SYMBOL_MILESTONE = '>>';
    public static final String SYMBOL_SUCCESS = '-';
    private static final VerboseLevel VERBOSE_MODE = VerboseLevel.VERBOSE_NONE;

    /* STATIC VARIABLES & PROPERTIES */

    /**
     * @description If true, the DML operation will not allow partial success.
     */
    public static Boolean allOrNone { get; set; }
    /**
     * @description The CPU time for the global setup.
     */
    private static Integer cpuTimeOfGlobalSetup { get; set; }
    /**
     * @description The name of the Apex class that stores the method which displays a Debug Log.
     */
    private static String debugLogClass { get; set; }
    /**
     * @description The name of the Apex method (in the defined Apex class) which displays a Debug Log.
     */
    private static String debugLogMethod { get; set; }
    /**
     * @description If true, the Exception error message has been displayed.
     */
    private static Boolean exceptionErrorMessageIsDisplayed { get; set; }
    /**
     * @description The Exception Handling mode: break (default): breaks execution, continue: continues execution.
     */
    private static String exceptionHandlingMode { get; set; }
    /**
     * @description The default SOQL query LIMIT.
     */
    private static Integer globalQueryLimit { get; set; }
    /**
     * @description If true, the DML Optimizer is activated.
     */
    private static Boolean hasActivatedDmlOptimizer { get; set; }
    /**
     * @description If true, if the initialization message has been displayed.
     */
    public static Boolean initializationMessageIsDisplayed { get; set; }
    /**
     * @description If true, the process is asynchronous.
     */
    private static Boolean isAsync { get; set; }
    /**
     * @description If true, Forceea creates records with mocked IDs.
     */
    private static Boolean isGlobalMocking { get; set; }
    /**
     * @description If true, the process is asynchronous.
     */
    private static Boolean isOnValidation { get; set; }
    /**
     * @description The language in name fields and addresses.
     */
    private static String language {
        get;
        set {
            resetLanguageLocality();
            language = value;
        }
    }
    /**
     * @description The locality in name fields and addresses.
     */
    private static String locality {
        get;
        set {
            resetLanguageLocality();
            locality = value;
        }
    }
    /**
     * @description The level of verbose mode.
     */
    private static VerboseLevel globalVerboseMode { get; set; }
    /**
     * @description The serial number for the mocked IDs.
     */
    public static Integer mockingSerialNumber { get; set; }
    /**
     * @description The default number of records to create.
     */
    @TestVisible private static Integer numRecordsToCreate { get; set; }
    /**
     * @description The maximum number of error records to display.
     */
    public static Integer numMaxErrorRecordsToDisplay { get; set; }
    /**
     * @description The number of created records to display.
     */
    public static Integer numRecordsToDisplay { get; set; }
    /**
     * @description If true, the process has no errors (valid).
     */
    public static Boolean processIsValid { get; set; }
    /**
     * @description A pseudorandom number that is greater than or equal to 0 and less than 1
     * modified from DeviousBard https://github.com/DeviousBard/Salesforce
     */
    public static Double random {
        get {
            Integer bits = 32;
            seed = (seed * 25214903917L + 11L) & ((1L << 48) - 1L);
            Long uInt = (Long) (seed >>> (48 - bits));
            return (Double) (((Double) uInt + 1.0) * 0.0000000002328306435454494);
        }
    }
    /**
     * @description The seed of pseudo-random number generator.
     */
    public static Long seed {
        get;
        set {
            seed = (value ^ 25214903917L) & ((1L << 48) - 1L);
        }
    }
    /**
     * @description If true, the DML statements should be optimized when using the method insertRecordsFromTemplate.
     */
    public static Boolean shouldOptimizeDml { get; set; }
    /**
     * @description If true, it should display the message using System.debug method
     */
    private static Boolean shouldUseExternalSystemDebug { get; set; }
    /**
     * @description The Standard Pricebook ID.
     */
    public Id standardPriceBookId { get; set; }
    /**
     * @description If true, the street number is after street, e.g. Abcd 12.
     */
    public static Boolean streetNumberGoesAfterStreet { get; set; }
    /**
     * @description The message to display when initializing FObject.
     */
    public static String userMessage { get; set; }

    /* STATIC COLLECTIONS */

    /**
     * @description The debug logs.
     */
    private static List<String> debugLogs = new List <String>();
    /**
     * @description The map with key: Template key, value: the FObject to insert.
     */
    public static Map<String, FObject> fObjectsToInsertByTemplateKey = new Map<String, FObject>();
    /**
     * @description The field details of each declared FObject
     *  key: SObject API name (lowercase), value: (key:field API name (lowercase), value: Field).
     */
    public static Map<String, Map<String, Forceea.FieldInfo>> globalFieldsMapBySObject =
        new Map<String, Map<String, Forceea.FieldInfo>>();
    /**
     * @description The inserted records of all objects
     *  key: objectApiName or objectApiName.groupName (lowercase), value: list of records.
     */
    public static Map<String, List<SObject>> globalInsertedRecordsByGroup = new Map<String, List<SObject>>();
    /**
     * @description The map with key: variable name, value: a Forceea.Variable object.
     */
    public static Map<String, Forceea.Variable> globalVariablesByName = new Map<String, Forceea.Variable>();
    /**
     * @description The map with key: Group name, value: a list of inserted SObject records.
     */
    public static Map<String, List<SObject>> insertedRecordsByGroupWithOptimizer = new Map<String, List<SObject>>();
    /**
     * @description The map with key: Template key, value: inserted SObject records.
     */
    public static Map<String, List<SObject>> insertedRecordsByTemplateKeyWithOptimizer = new Map<String, List<SObject>>();
    /**
     * @description Τhe serializations map with key: SObject API name, value: next serialized record number.
     */
    public static Map<String, Integer> numFirstRecordsBySObject = new Map<String, Integer>();
    /**
     * @description The map with key: Group name, value: SObject records to insert.
     */
    public static Map<String, List<SObject>> recordsToInsertByGroupWithOptimizer = new Map<String, List<SObject>>();
    /**
     * @description The map with key: Template key, value: SObject records to insert.
     */
    public static Map<String, List<SObject>> recordsToInsertByTemplateKeyWithOptimizer = new Map<String, List<SObject>>();
    /**
     * @description The records to be inserted.
     */
    public static List<SObject> recordsToInsertWithOptimizer = new List<SObject>();
    /**
     * @description The map with key: Template key, value: SaveResult objects.
     */
    public static Map<String, List<Database.SaveResult>> saveResultsByTemplateKeyWithOptimizer =
        new Map<String, List<Database.SaveResult>>();
    /**
     * @description The list of SaveResult objects when inserting records with DML Optimizer.
     */
    public static List<Database.SaveResult> saveResultsWithOptimizer = new List<Database.SaveResult>();

    /* INSTANCE VARIABLES & PROPERTIES */

    /**
     * @description The index fields for the SELECT statement of Big Objects.
     */
    public String bigObjectIndexFieldsString { get; set; }
    /**
     * @description If true, User records can be inserted when not in Testing.
     */
    public Boolean canInsertUsers { get; set; }
    /**
     * @description The duration of CPU time for the SObject setup.
     */
    private Integer cpuTimeOfObjectSetup { get; set; }
    /**
     * @description The start of CPU time for the SObject setup.
     */
    private Integer cpuTimeStartOfObjectSetup { get; set; }
    /**
     * @description The duration of CPU time for the SObject data generation.
     */
    public Integer cpuTimeOfDataGeneration { get; set; }
    /**
     * @description The start of CPU time for the SObject data generation.
     */
    public Integer cpuTimeStartOfDataGeneration { get; set; }
    /**
     * @description If true, all definitions are validated.
     */
    public Boolean definitionsAreValidated { get; set; }
    /**
     * @description The ID of the replaced definition.
     */
    public String definitionIdForReplacement { get; set; }
    /**
     * @description The definition position for replacing the definition.
     */
    public Integer definitionPositionForReplacement { get; set; }
    /**
     * @description If true, the process deletes records.
     */
    public Boolean dmlIsDelete { get; set; }
    /**
     * @description If true, the process inserts records.
     */
    public Boolean dmlIsInsert { get; set; }
    /**
     * @description If true, the process updates records.
     */
    public Boolean dmlIsUpdate { get; set; }
    /**
     * @description Excludes the lookup records with IsActive = false.
     */
    public Boolean excludeInactiveLookupRecords { get; set; }
    /**
     * @description The group that will be used when inserting records for this FObject.
     */
    public String groupName { get; set; }
    /**
     * @description If true, it has the Schema of all fields.
     */
    private Boolean hasSchemaOfAllFields { get; set; }
    /**
     * @description If true, the SObject is excluded from the asynchronous deletion.
     */
    private Boolean isExcludedOnAsyncDelete { get; set; }
    /**
     * @description If true, the SObject is excluded from the asynchronous deletion.
     */
    private Boolean isExcludedOnAsyncUpdate { get; set; }
    /**
     * @description If true, the IDs are mocked.
     */
    public Boolean isMocking { get; set; }
    /**
     * @description If true, it's a Big Object.
     */
    public Boolean isBigObject {
        get {
            if (isBigObject == null) {
                isBigObject = ForceeaService.isBigObject(this.sObjectApiName);
            }
            return isBigObject;
        }
        set;
    }
    /**
     * @description If true, the process updates fields.
     */
    public Boolean isUpdate { get; set; }
    /**
     * @description The CPU limit time for the timer start and finish.
     */
    private Integer milestoneStartTime { get; set; }
    /**
     * @description The elapsed CPU time for a milestone.
     */
    private Integer milestoneDuration {
        get {
            if (Limits.getCpuTime() < milestoneStartTime) {
                return Limits.getCpuTime();
            } else {
                return Limits.getCpuTime() - milestoneStartTime;
            }
        }
    }
    /**
     * @description The maximum number of records to be deleted asynchronously.
     */
    private Integer numMaxRecordOnAsyncDelete { get; set; }
    /**
     * @description The maximum number of records to be updated asynchronously.
     */
    private Integer numMaxRecordOnAsyncUpdate { get; set; }
    /**
     * @description If true, new records must be created.
     */
    public Boolean mustCreateNewRecords { get; set; }
    /**
     * @description The number of field definitions which have any data.
     */
    public Integer numDefinitionsWithData { get; set; }
    /**
     * @description The number of deleted records.
     */
    public Integer numDeletedRecords { get; set; }
    /**
     * @description The number of inserted recordst.
     */
    public Integer numInsertedRecords { get; set; }
    /**
     * @description The number of the next record, used by the method setNumberOfNextRecord
     */
    public Integer numNextRecord { get; set; }
    /**
     * @description The number of updated records.
     */
    public Integer numUpdatedRecords { get; set; }
    /**
     * @description The number of validated definitions.
     */
    public Integer numValidatedDefinitions { get; set; }
    /**
     * @description The partition field for async processing.
     */
    private String partitionFieldName { get; set; }
    /**
     * @description If TRUE, the created records will have permutations.
     */
    private Boolean processHasPermutations { get; set; }
    /**
     * @description The SOQL query LIMIT.
     */
    public Integer queryLimit { get; set; }
    /**
     * @description The number of records to create.
     */
    public Integer records { get; set; }
    /**
     * @description The field API name for replacing definitions.
     */
    public String fieldApiNameForReplacement { get; set; }
    /**
     * @description If true, Forceea sets all required fields.
     */
    private Boolean requiredFieldsShouldBeAutomaticallyConfigured { get; set; }
    /**
     * @description The SObject API name.
     */
    public String sObjectApiName { get; set; }
    /**
     * @description The SObject type.
     */
    public Schema.SObjectType sObjType { get; set; }
    /**
     * @description The key of the Template that contains this FObject.
     */
    public String templateKey { get; set; }
    /**
     * @description The level of verbose mode.
     */
    private VerboseLevel verboseMode { get; set; }
    /**
     * @description The name of the virtual field for getting the values of Standard Price Book entries.
     */
    public String virtualFieldForStandardPriceBookEntries { get; set; }
    /**
     * @description The SOQL WHERE clause for filtering the records to be deleted asynchronously.
     */
    private String whereClauseOnAsyncDelete { get; set; }
    /**
     * @description The SOQL WHERE clause for filtering the records to be updated asynchronously.
     */
    private String whereClauseOnAsyncUpdate { get; set; }

    /* INSTANCE COLLECTIONS */

    /**
     * @description A map with the addresses - key: address group, value: address
     */
    public Map<String, List<ForceeaAddress>> addressesByGroup = new Map<String, List<ForceeaAddress>>();
    /**
     * @description The last created SObject records.
     */
    public List<SObject> createdRecords = new List<SObject>();
    /**
     * @description The declared field definitions.
     */
    public List<ForceeaDefinition> definitions = new List<ForceeaDefinition>();
    /**
     * @description The deleted records.
     */
    public List<SObject> deletedRecords = new List<SObject>();
    /**
     * @description The delete results list.
     */
    public List<Database.DeleteResult> deleteResults = new List<Database.DeleteResult>();
    /**
     * @description The definition errors.
     */
    public List<Error> errors = new List<Error>();
    /**
     * @description The fields with declared definitions.
     */
    public List<String> fields = new List<String>();
    /**
     * @description The fields to be updated.
     */
    public List<String> fieldsForUpdate = new List<String>();
    /**
     * @description The FVM, each List<String> contains a field's values.
     */
    public List<List<String>> fieldValuesMatrix = new List<List<String>>();
    /**
     * @description The inserted records.
     */
    public List<SObject> insertedRecords = new List<SObject>();
    /**
     * @description A map with key: <blank> or groupName (lowercase), value: list of records.
     */
    public Map<String, List<SObject>> instanceInsertedRecordsByGroup = new Map<String, List<SObject>>();
    /**
     * @description The first & last names - key: name group, value: name.
     */
    public Map<String, List<ForceeaName>> namesByGroup = new Map<String, List<ForceeaName>>();
    /**
     * @description A map with key: field API name, value: the next new field position.
     */
    public Map<String, Integer> nextNewFieldPositionByFieldName = new Map<String, Integer>();
    /**
     * @description The lists of permutations.
     */
    public List<List<String>> permutationsList = new List<List<String>>();
    /**
     * @description The permutation values for all records.
     */
    public List<List<String>> permutationValues = new List<List<String>>();
    /**
     * @description The list of products to insert a Standard Price Book entry.
     */
    public List<Product2> productsToInsertPricebookEntries = new List<Product2>();
    /**
     * @description The records to be deleted.
     */
    public List<SObject> recordsToDelete = new List<SObject>();
    /**
     * @description The records to be inserted.
     */
    public List<SObject> recordsToInsert = new List<SObject>();
    /**
     * @description The records to be updated.
     */
    public List<SObject> recordsToUpdate = new List<SObject>();
    /**
     * @description The field API names of required fields.
     */
    public List<String> requiredFieldNames = new List<String>();
    /**
     * @description The save results list.
     */
    public List<Database.SaveResult> saveResults = new List<Database.SaveResult>();
    /**
     * @description The number of minutes of the time frame for updating records asynchronously.
     */
    private Integer timeFrameForUpdateInMinutes { get; set; }
    /**
     * @description The updated records.
     */
    public List<SObject> updatedRecords = new List<SObject>();
    /**
     * @description The definition variables.
     */
    public Map<String, Forceea.Variable> variables = new Map<String, Forceea.Variable>();

    /* ENUMS */

    private enum VerboseLevel {
        VERBOSE_NONE, VERBOSE_DEBUG, VERBOSE_INFO
    }

    /* CLASSES */

    /**
     * @description An error message.
     */
    public class Error {
        /**
         * @description The error ID.
         */
        public String id { get; set; }
        /**
         * @description The error message.
         */
        public String errorMessage { get; set; }

        /**
         * @description The constructor for the class.
         * @param errorId The error ID.
         * @param errorMessage The error message.
         */
        public Error(String errorId, String errorMessage) {
            this.id = errorId;
            this.errorMessage = errorMessage;
        }
    }

    /**
     * @description A wrapper for definition details.
     */
    private class DefinitionWrapper {
        private Integer position { get; set; }
        private String fieldApiName { get; set; }

        private DefinitionWrapper(Integer position, String fieldApiName) {
            this.position = position;
            this.fieldApiName = fieldApiName;
        }
    }

    /**
     * @description The exception handler class.
     */
    private class FObjectException extends Exception {
    }

    /* INITIALIZATION */

    // static initialization
    static {
        setForceeaSettings();
        ForceeaDefinitionType.setDefinitionTypes();
        setGlobalProperties();
    }

    // instance initialization
    {
        this.milestoneStartTime = Limits.getCpuTime();
        this.cpuTimeStartOfObjectSetup = Limits.getCpuTime();
        this.canInsertUsers = false;
    }

    /* CONSTRUCTORS */

    // FObject from existing record(s) with/without group

    /**
     * @description The constructor for the class.
     * @param insertedRecord The inserted SObject record.
     */
    global FObject(SObject insertedRecord) {
        this(null, new List<SObject>{
            insertedRecord
        }, '');
    }

    /**
     * @description The constructor for the class.
     * @param insertedRecord The inserted SObject record.
     * @param groupName The group name.
     */
    global FObject(SObject insertedRecord, String groupName) {
        this(null, new List<SObject>{
            insertedRecord
        }, groupName);
    }

    /**
     * @description The constructor for the class.
     * @param insertedRecords The list of inserted SObject records.
     */
    global FObject(List<SObject> insertedRecords) {
        this(null, insertedRecords, '');
    }

    /**
     * @description The constructor for the class.
     * @param insertedRecords The list of inserted SObject records.
     * @param groupName The group name.
     */
    global FObject(List<SObject> insertedRecords, String groupName) {
        this(null, insertedRecords, groupName);
    }

    /**
     * @description The constructor for the class.
     * @param sObjType The SObject record.
     * @param insertedRecords The list of inserted SObject records.
     * @param groupName The group name.
     */
    global FObject(Schema.SObjectType sObjType, List<SObject> insertedRecords, String groupName) {
        if (insertedRecords == null || insertedRecords.isEmpty()) {
            return;
        }

        for (SObject record : insertedRecords) {
            if (record == null) {
                return;
            }
        }

        this.groupName = ForceeaService.getStringValue(groupName);
        this.insertedRecords.addAll(insertedRecords);
        this.sObjType = (sObjType == null) ? insertedRecords.get(0).getSObjectType() : sObjType ;

        fObjectConstructorHandler(this.sObjType, '', 0);
        addRecordsToMapsOnInsert();
    }

    // FObject from API Name or SObject type with/without group

    /**
     * @description The constructor for the class.
     * @param sObjectType The SObject type.
     */
    global FObject(Schema.SObjectType sObjectType) {
        fObjectConstructorHandler(sObjectType, '', 0);
    }

    /**
     * @description The constructor for the class.
     * @param sObjectName The SObject name.
     */
    global FObject(String sObjectName) {
        fObjectConstructorHandler(null, sObjectName, 0);
    }

    /**
     * @description The constructor for the class.
     * @param sObjectType The SObject record.
     * @param records The number of records.
     */
    global FObject(Schema.SObjectType sObjectType, Integer records) {
        fObjectConstructorHandler(sObjectType, '', records);
    }

    /**
     * @description The constructor for the class.
     * @param sObjectName The SObject name.
     * @param records The number of records.
     */
    global FObject(String sObjectName, Integer records) {
        fObjectConstructorHandler(null, sObjectName, records);
    }

    /**
     * @description Constructs an FObject based on the SObject type or API name.
     * @param sObjectType The SObject type.
     * @param sObjectName The SObject API name.
     * @param numRecords The number of records.
     */
    private void fObjectConstructorHandler(Schema.SObjectType sObjectType, String sObjectName, Integer numRecords) {
        String sObjectApiName = '';

        if (sObjectType != null) {
            sObjectApiName = sObjectType.getDescribe().getName();
        } else {
            sObjectApiName = ForceeaService.getSObjectApiName(
                this, '', sObjectName, '', 'standard');
            if (String.isBlank(sObjectApiName)) {
                if (FObject.processMustTerminate()) {
                    return;
                }
            }
        }

        this.sObjectApiName = sObjectApiName;
        new ForceeaDebugHandler(this).displayInitializationMessage();

        // validate the number of records
        if (numRecords < 0) {
            addError(sObjectApiName, 'Invalid number of records of [' + sObjectApiName + ']');
            if (FObject.processMustTerminate()) {
                return;
            }
        } else if (numRecords == 0) {
            // get the default records
            this.records = FObject.numRecordsToCreate;
        } else {
            this.records = numRecords;
        }

        initializeNumFirstRecordsBySObject();
        setInstanceProperties();
        new ForceeaRecordTypeHandler(this).setRecordTypes();
    }

    /* METHODS */

    private void addCreatedRecordsToMapsWithOptimizer() {
        if (!FObject.shouldOptimizeDml) {
            return;
        }

        ForceeaService.putSObjectsIntoMap(
            FObject.recordsToInsertByTemplateKeyWithOptimizer, this.templateKey, this.createdRecords);
        ForceeaService.putSObjectsIntoMap(
            FObject.recordsToInsertByGroupWithOptimizer, this.groupName, this.createdRecords);
        FObject.recordsToInsertWithOptimizer.addAll(this.createdRecords);
    }

    /**
     * @description Adds an error message to Errors list - global Errors map, and posts message to Debug Log.
     * @param errorId The error reference (e.g. the field or parameter which created the error).
     * @param errorMessage The error message.
     */
    public void addError(String errorId, String errorMessage) {
        this.errors.add(new Error(errorId, errorMessage));
        forceeaDebug(ForceeaService.ERROR, DEBUG_LOG_PROMPT + SYMBOL_FAILURE + ' ' + errorMessage + '.');
    }

    /**
     * @description Adds an error message for invalid field.
     * @param sObjectApiName The SObject API name.
     * @param fieldName The field API name.
     * @param methodName The method name.
     */
    public void addErrorInvalidFieldInMethod(String sObjectApiName, String fieldName, String methodName) {
        addError(sObjectApiName, ForceeaService.MESSAGE_INVALID_FIELD + ' [' + fieldName.trim() +
            '] in method [' + methodName + ']');
    }

    /**
     * @description Adds the inserted records to the related maps of inserted records.
     */
    public void addRecordsToMapsOnInsert() {
        List<SObject> recordsToAdd = new List<SObject>(this.insertedRecords);

        ForceeaService.putSObjectsIntoMap(
            this.instanceInsertedRecordsByGroup,
            '',
            recordsToAdd);
        ForceeaService.putSObjectsIntoMap(
            FObject.globalInsertedRecordsByGroup,
            ForceeaService.getKey(this.sObjectApiName, ''),
            recordsToAdd);

        if (String.isBlank(this.groupName)) {
            return;
        }
        ForceeaService.putSObjectsIntoMap(
            this.instanceInsertedRecordsByGroup,
            this.groupName.toLowerCase(),
            recordsToAdd);
        ForceeaService.putSObjectsIntoMap(
            FObject.globalInsertedRecordsByGroup,
            ForceeaService.getKey(this.sObjectApiName, this.groupName),
            recordsToAdd);
    }

    /**
     * @description Appends new definitions after the definition with the given ID.
     * @param definitionId The Definition ID.
     * @return An FObject instance.
     */
    global FObject appendDefinitionsAfterId(String definitionId) {
        DefinitionWrapper definitionDetails = getDefinitionDetailsFromId(definitionId);
        Integer definitionPosition = definitionDetails.position;
        String fieldApiName = definitionDetails.fieldApiName;
        this.nextNewFieldPositionByFieldName.put(fieldApiName, definitionPosition + 1);

        return this;
    }

    /**
     * @description Appends new definitions after last field definition.
     * @param fieldName The field API name.
     * @return An FObject instance.
     */
    global FObject appendDefinitions(String fieldName) {
        String fieldApiName = ForceeaService.getFieldApiName(
            this, '', this.sObjectApiName, fieldName, null, '', 'replaceDefinitions');

        if (String.isNotBlank(fieldApiName)) {
            appendDefinitionsOfField(fieldApiName);
        }

        return this;
    }

    /**
     * @description Appends new definitions after last field definition.
     * @param sObjectField The SObjectField.
     * @return An FObject instance.
     */
    global FObject appendDefinitions(Schema.SObjectField sObjectField) {
        String fieldApiName = sObjectField.getDescribe().getName();
        appendDefinitionsOfField(fieldApiName);

        return this;
    }

    /**
     * @description Appends the insertion of new definitions after the last field definition.
     * @param fieldApiName The field API name.
     */
    private void appendDefinitionsOfField(String fieldApiName) {
        if (fieldDoesNotExist(fieldApiName)) {
            return;
        }

        List<Integer> definitionIndexes = getDefinitionIndexes(fieldApiName);
        Integer size = definitionIndexes.size();
        Integer lastDefinitionPosition = definitionIndexes.get(size - 1);
        this.nextNewFieldPositionByFieldName.put(fieldApiName, lastDefinitionPosition + 1);
    }

    /**
     * @description Calls an external method to display the debug log.
     * @param errorLevel The error level LoggingLevel enum.
     * @param message The message to display.
     */
    private static void callExternalMethodForDebugLog(LoggingLevel errorLevel, String message) {
        Map<String, Object> args = new Map<String, Object>{
            'message' => message,
            'errorLevel' => errorLevel
        };

        try {
            Callable ext = (Callable) Type.forName('', FObject.debugLogClass).newInstance();
            ext.call(FObject.debugLogMethod, args);
        } catch (Exception exp) {
            System.debug(errorLevel, message); // NOPMD
            FObject.shouldUseExternalSystemDebug = false;
        }
    }

    /**
     * @description Defines if user records can be inserted when not testing.
     * @param insertUsers True, if we allow users to be inserted in non-testing mode.
     * @return An FObject instance.
     */
    global FObject canInsertUsers(Boolean insertUsers) {
        this.canInsertUsers = insertUsers;
        return this;
    }

    /**
     * @description Creates SObject records using the field definitions.
     */
    public void createNewRecords() {
        if (FObject.processMustTerminate() || !this.mustCreateNewRecords) {
            return;
        }
        onBeforeCreateRecords();

        new ForceeaParser(this).validateDefinitions();
        if (FObject.processMustTerminate()) {
            return;
        }

        setPermutationValues();
        resetMilestoneTimer(MESSAGE_VALIDATED_DEFINITIONS + ' [' + this.sObjectApiName + ']');

        new ForceeaFieldValuesMatrixHandler(this).initializeFieldValuesMatrix();
        this.cpuTimeOfObjectSetup = Limits.getCpuTime() - this.cpuTimeStartOfObjectSetup;
        this.cpuTimeStartOfDataGeneration = Limits.getCpuTime();
        this.createdRecords = getCreatedRecords();

        onAfterCreateRecords();
    }

    /**
     * @description Creates records using the declared field definitions.
     * @return An FObject instance.
     */
    global FObject createRecords() {
        this.mustCreateNewRecords = true;
        createNewRecords();

        return this;
    }

    /**
     * @description Creates records starting with the record with a specific ID.
     * @param recordNumber The number of the next record to be created.
     * @return An FObject instance.
     */
    global FObject createRecords(Integer recordNumber) {
        this.mustCreateNewRecords = true;

        if (recordNumber <= 0) {
            addError(this.sObjectApiName, 'Invalid record number in method [createRecords]');
            if (FObject.processMustTerminate()) {
                return this;
            }
        } else {
            setNumberOfNextRecord(recordNumber);
        }
        createNewRecords();

        return this;
    }

    /**
     * @description Deletes records of the SObject, using specific criteria (WHERE clause).
     * @param whereClause The WHERE clause of the SOQL query (e.g. MyField__c > 10).
     * @param allOrNone If true, the operation allows partial success.
     * @return A list of Database.DeleteResult objects.
     */
    global List<Database.DeleteResult> deleteRecords(String whereClause, Boolean allOrNone) {
        return new ForceeaDeleteHandler(this).getResults(whereClause, allOrNone);
    }

    /**
     * @description Excludes the inactive (IsActive=false) lookup records.
     * @param isExcluded If true, the lookup records with IsActive=false will be excluded.
     * @return An FObject instance.
     */
    global FObject excludeInactiveLookupRecords(Boolean isExcluded) {
        this.excludeInactiveLookupRecords = isExcluded;
        return this;
    }

    /**
     * @description Excludes the FObject from async deletion.
     * @param isExcluded If true, the SObject will be excluded from the async delete process.
     * @return An FObject instance.
     */
    global FObject excludeOnAsyncDelete(Boolean isExcluded) {
        this.isExcludedOnAsyncDelete = isExcluded;
        return this;
    }

    /**
     * @description Excludes the FObject from async update.
     * @param isExcluded If true, the SObject will be excluded from the async update process.
     * @return An FObject instance.
     */
    global FObject excludeOnAsyncUpdate(Boolean isExcluded) {
        this.isExcludedOnAsyncUpdate = isExcluded;
        return this;
    }

    /**
     * @description Display the debug log message using a specific logging level.
     * @param errorLevel The error level LoggingLevel enum.
     * @param message The message to display.
     */
    public static void executeDebugLog(LoggingLevel errorLevel, String message) {
        if (FObject.shouldUseExternalSystemDebug) {
            callExternalMethodForDebugLog(errorLevel, message);
        } else {
            System.debug(errorLevel, message); // NOPMD
        }
    }

    /**
     * @description Informs whether the field exists in the list of fields.
     * @param fieldApiName The field API name.
     * @return True, if the field is not already defined with a definition.
     */
    private Boolean fieldDoesNotExist(String fieldApiName) {
        Integer fieldPosition = getFieldsToProcess().indexOf(fieldApiName);
        return fieldPosition == -1;
    }

    /**
     * @description Posts an instance System.debug message.
     * @param errorLevel The System.LoggingLevel enum.
     * @param message The message to post.
     * @return True, if the message was displayed.
     */
    public Boolean forceeaDebug(String errorLevel, String message) {
        String chars = '.=';
        message = message.right(1).containsAny(chars) ? message : message + '.';

        if (this.verboseMode != null) {
            return FObject.postDebug(errorLevel, message, this.verboseMode);
        } else {
            return FObject.postDebug(errorLevel, message, FObject.globalVerboseMode);
        }
    }

    /**
     * @description Posts a static System.debug message.
     * @param errorLevel The System.LoggingLevel enum.
     * @param message The message to post.
     */
    public static void forceeaDebugStatic(String errorLevel, String message) {
        FObject.postDebug(errorLevel, message, FObject.globalVerboseMode);
    }

    /**
     * @description Retrieves a map of all definitions of every field.
     * @return A map of key:string, value: list of string values.
     */
    global Map<String, List<String>> getAllDefinitions() {
        Map<String, List<String>> results = new Map<String, List<String>>();
        new ForceeaParser(this).validateDefinitions();

        for (ForceeaDefinition def : this.definitions) {
            String field = def.fieldApiName;
            if (results.containsKey(field)) {
                results.get(field).add(def.definitionString);
            } else {
                results.put(field, new List<String>{
                    def.definitionString
                });
            }
        }

        return results;
    }

    /**
     * @description Corrects the provided maximum number of records to update or delete asynchronously per batch.
     * @param numberOfRecords The maximum number of records.
     * @return An instance of FObject.
     */
    private Integer getCorrectMaxNumberOfRecordOnAsyncUpdateOrDelete(Integer numberOfRecords) {
        Integer result = Limits.getLimitDmlRows();
        if (numberOfRecords > 0 && numberOfRecords < Limits.getLimitDmlRows()) {
            result = numberOfRecords;
        }

        return result;
    }

    /**
     * @description Retrieves the CPU time of data generation.
     * @return The CPU time of data generation in ms.
     */
    public Integer getCpuTimeOfDataGeneration() {
        return this.cpuTimeOfDataGeneration;
    }

    /**
     * @description Retrieves the CPU time of global setup.
     * @return The CPU time of global setup in ms.
     */
    public static Integer getCpuTimeOfGlobalSetup() {
        return FObject.cpuTimeOfGlobalSetup;
    }

    /**
     * @description Retrieves the CPU time of SObject setup.
     * @return The CPU time of SObject setup in ms.
     */
    public Integer getCpuTimeOfSObjectSetup() {
        return this.cpuTimeOfObjectSetup;
    }

    /**
     * @description Retrieves the created SObject records from the Field Value Matrix.
     * @return A list of SObject records.
     */
    private List<SObject> getCreatedRecords() {
        List<SObject> results = new List<SObject>();

        new ForceeaFieldValuesMatrixHandler(this).createAndDisplayFieldValues();
        if (FObject.processMustTerminate()) {
            return results;
        }

        for (Integer counter = 0; counter < this.records; counter++) {
            results.add(getRecord(counter));
            if (FObject.processMustTerminate()) {
                results.clear();
                break;
            }
        }

        return results;
    }

    /**
     * @description Retrieves the zero-based definition position or -1 if it is not found.
     * @param definitionId The field ID.
     * @return A DefinitionWrapper object.
     */
    private DefinitionWrapper getDefinitionDetailsFromId(String definitionId) {
        DefinitionWrapper result = new DefinitionWrapper(-1, '');
        Integer index = 0;

        for (ForceeaDefinition def : this.definitions) {
            if (def.definitionId == definitionId) {
                result.position = index;
                result.fieldApiName = def.fieldApiName;
                break;
            }
            index++;
        }

        return result;
    }

    /**
     * @description Retrieves the indexes of the definitions.
     * @param fieldApiName The field API name.
     * @return The list of definition indexes.
     */
    public List<Integer> getDefinitionIndexes(String fieldApiName) {
        List<Integer> results = new List<Integer>();
        Integer index = 0;
        Boolean isSelectable = false;

        for (ForceeaDefinition def : this.definitions) {
            if (this.isUpdate) {
                isSelectable = def.isForUpdate && def.fieldApiName == fieldApiName;
            } else {
                isSelectable = def.fieldApiName == fieldApiName;
            }

            if (isSelectable) {
                results.add(index);
            }
            index++;
        }

        return results;
    }

    /**
     * @description Retrieves the definition string with the replaced source.
     * @param definitionString The definition string.
     * @param source The source (forceea or salesforce.
     * @return The updated definition string.
     * A list of string values.
     */
    private String getDefinitionStringWithReplacedSource(String definitionString, String source) {
        String sourceParameterForceea = 'source(forceea)';
        String sourceParameterSalesforce = 'source(salesforce)';

        if (source.equalsIgnoreCase('salesforce') && definitionString.containsIgnoreCase(sourceParameterForceea)) {
            return definitionString.replace(sourceParameterForceea, sourceParameterSalesforce);
        } else if (source.equalsIgnoreCase('forceea') && definitionString.containsIgnoreCase(sourceParameterSalesforce)) {
            return definitionString.replace(sourceParameterSalesforce, sourceParameterForceea);
        }

        return definitionString;
    }

    /**
     * @description Retrieves a list of all definitions of a field.
     * @param sObjectField The SObjectField.
     * @return A list of string values.
     */
    global List<String> getDefinitions(Schema.SObjectField sObjectField) {
        return getDefinitions(sObjectField.getDescribe().getName());
    }

    /**
     * @description Retrieves a list of all definitions of a field.
     * @param fieldApiName The API name of the field.
     * @return A list of string values.
     */
    global List<String> getDefinitions(String fieldApiName) {
        new ForceeaParser(this).validateDefinitions();
        String thisFieldApiName = fieldApiName.trim();

        thisFieldApiName = thisFieldApiName.toLowerCase();

        List<String> values = new List<String>();
        for (ForceeaDefinition def : this.definitions) {
            if (def.fieldApiName.toLowerCase() == thisFieldApiName) {
                values.add(def.definitionString);
            }
        }

        return values;
    }

    /**
     * @description Retrieves the description of a DML milestone.
     * @param numRecords The number of records for the DML operation.
     * @return The description string.
     */
    private String getDmlMilestoneDescription(Integer numRecords) {
        String description = ForceeaService.getDmlDescription(this, 'ed', 'uppercase') + ' ' +
            ForceeaService.getCountable('record', numRecords) + ' of [' + this.sObjectApiName + ']';

        return String.isNotBlank(this.groupName)
            ? description + ' group [' + this.groupName + ']'
            : description;
    }

    /**
     * @description Retrieves a list of the errors found during the process of creating the records of an FObject.
     * @return A map of key: String, value: List<String> values.
     */
    global Map<String, List<String>> getErrors() {
        return new ForceeaErrorHandler(this).getErrors();
    }

    /**
     * @description Retrieves the fields to process, based on update.
     * @return An list of strings.
     */
    public List<String> getFieldsToProcess() {
        return (this.isUpdate) ? this.fieldsForUpdate : this.fields;
    }

    /**
     * @description Retrieves the Forceea custom metadata type.
     * @return The Forceea custom metadata type.
     */
    private static ForceeaSetting__mdt getForceeaDefaultCustomMetadata() {
        for (ForceeaSetting__mdt setting : new ForceeaSelector().selectCustomMetadataSettings()) {
            if (setting.DeveloperName.equalsIgnoreCase(SETTINGS_DEFAULT)) {
                return setting;
            }
        }

        return null;
    }

    /**
     * @description Retrieves the Forceea custom setting.
     * @return The Forceea custom setting.
     */
    private static ForceeaSettings__c getForceeaDefaultCustomSettings() {
        for (ForceeaSettings__c setting : ForceeaSettings__c.getAll().values()) {
            if (setting.Name.equalsIgnoreCase(SETTINGS_DEFAULT)) {
                return setting;
            }
        }

        return null;
    }

    /**
     * @description Retrieves the debug logs.
     * @return The list of debug logs.
     */
    global static List<String> getGlobalDebugLogs() {
        return FObject.debugLogs;
    }

    /**
     * @description Retrieves the language.
     * @return An string value.
     */
    global static String getGlobalLanguage() {
        return FObject.language;
    }

    /**
     * @description Retrieves the locality.
     * @return An string value.
     */
    global static String getGlobalLocality() {
        return FObject.locality;
    }

    /**
     * @description Retrieves the group name.
     * @return The string of group name.
     */
    global String getGroupName() {
        return this.groupName;
    }

    /**
     * @description Retrieves the default query limit.
     * @return The default query limit.
     */
    global Integer getGlobalQueryLimit() {
        if (this.dmlIsDelete && this.isBigObject) {
            return DEFAULT_QUERY_LIMIT_FOR_BIG_OBJECT;
        } else {
            return DEFAULT_QUERY_LIMIT;
        }
    }

    /**
     * @description Retrieves the global variable value.
     * @param name The variable name.
     * @return The variable value as a string.
     */
    global static String getGlobalVariable(String name) {
        String result = '';

        for (Forceea.Variable var : FObject.globalVariablesByName.values()) {
            if (var.name.equalsIgnoreCase(name)) {
                result = FObject.getVariableStringValue(var);
                break;
            }
        }

        return result;
    }

    /**
     * @description Retrieves the global verbose.
     * @return The global verbose (none, info, debug).
     */
    global static String getGlobalVerbose() {
        switch on FObject.globalVerboseMode {
            when VERBOSE_INFO {
                return 'info';
            } when VERBOSE_DEBUG {
                return 'debug';
            } when else {
                return 'none';
            }
        }
    }

    /**
     * @description Retrieves the first inserted record of an SObject that belongs to a specific group
     *   and is located in a specific zero-based position.
     * @param groupName The group name of the inserted records.
     * @return An SObject.
     */
    global SObject getInsertedGroupRecord(String groupName) {
        String key = ForceeaService.getStringValueToLower(groupName);

        if (this.instanceInsertedRecordsByGroup.containsKey(key) &&
            !this.instanceInsertedRecordsByGroup.get(key).isEmpty()) {
            return this.instanceInsertedRecordsByGroup.get(key).get(0);
        }

        return null;
    }

    /**
     * @description Retrieves all inserted records of an SObject.
     * @param groupName The group name of the inserted records.
     * @return A list of SObjects.
     */
    global List<SObject> getInsertedGroupRecords(String groupName) {
        List<SObject> results = new List<SObject>();
        String key = ForceeaService.getStringValueToLower(groupName);

        if (this.instanceInsertedRecordsByGroup.containsKey(key)) {
            results.addAll(this.instanceInsertedRecordsByGroup.get(key));
        }

        return results;
    }

    /**
     * @description Retrieves all inserted records of an SObject.
     * @param sObjectType The SObject type.
     * @param groupName The group name of the inserted records.
     * @return A list of SObjects.
     */
    global static List<SObject> getInsertedGroupRecords(Schema.SObjectType sObjectType, String groupName) {
        return getInsertedGroupRecords(sObjectType.getDescribe().getName(), groupName);
    }

    /**
     * @description Retrieves all inserted records of an SObject.
     * @param sObjectName The SObject name.
     * @param groupName The group name of the inserted records.
     * @return A list of SObjects.
     */
    global static List<SObject> getInsertedGroupRecords(String sObjectName, String groupName) {
        List<SObject> results = new List<SObject>();
        String sObjectApiName = ForceeaService.getSObjectApiName(sObjectName);

        if (String.isBlank(sObjectApiName)) {
            String methodName = String.isBlank(groupName) ? 'getInsertedRecords' : 'getInsertedGroupRecords';
            FObject.postDebug(ForceeaService.ERROR, DEBUG_LOG_PROMPT + SYMBOL_FAILURE + ' ' +
                'Invalid SObject [' + sObjectName + '] in static method ' + methodName, FObject.globalVerboseMode);
            return results;
        }

        String key = ForceeaService.getKey(sObjectApiName, groupName);
        if (FObject.globalInsertedRecordsByGroup.containsKey(key)) {
            results.addAll(FObject.globalInsertedRecordsByGroup.get(key));
        }

        return results;
    }

    /**
     * @description Retrieves the first inserted record of an SObject.
     * @return An SObject.
     */
    global SObject getInsertedRecord() {
        return getInsertedGroupRecord('');
    }

    /**
     * @description Retrieves all inserted records of an SObject.
     * @return A list of SObjects.
     */
    global List<SObject> getInsertedRecords() {
        return getInsertedGroupRecords('');
    }

    /**
     * @description Retrieves all inserted records of an SObject.
     * @param sObjectType The SObject type.
     * @return A list of SObjects.
     */
    global static List<SObject> getInsertedRecords(Schema.SObjectType sObjectType) {
        return FObject.getInsertedGroupRecords(sObjectType.getDescribe().getName(), '');
    }

    /**
     * @description Retrieves all inserted records of an SObject.
     * @param sObjectApiName The SObject API name.
     * @return A list of SObjects.
     */
    global static List<SObject> getInsertedRecords(String sObjectApiName) {
        return FObject.getInsertedGroupRecords(sObjectApiName, '');
    }

    /**
     * @description Retrieves the max number of records that should be deleted asynchronously in any batch.
     * @return An integer value.
     */
    global Integer getMaxNumberOfRecordOnAsyncDelete() {
        return this.numMaxRecordOnAsyncDelete;
    }

    /**
     * @description Retrieves the number of records that should be updated asynchronously in any batch.
     * @return An integer value.
     */
    global Integer getMaxNumberOfRecordOnAsyncUpdate() {
        return this.numMaxRecordOnAsyncUpdate;
    }

    /**
     * @description Retrieves the number of records.
     * @return An integer value.
     */
    global Integer getNumberOfRecords() {
        return this.records;
    }

    /**
     * @description Retrieves the API name of the Partition field.
     * @return A string value of the Partition field name.
     */
    global String getPartitionFieldName() {
        return this.partitionFieldName;
    }

    /**
     * @description Retrieves the FObject query LIMIT.
     * @return The query LIMIT.
     */
    global Integer getQueryLimit() {
        return this.queryLimit;
    }

    /**
     * @description Creates an SObject record.
     * @param recordCounter The number of the record.
     * @return An SObject.
     */
    global SObject getRecord(Integer recordCounter) {
        SObject result = this.sObjType.newSObject();
        List<String> fieldsToProcess = getFieldsToProcess();

        for (Integer fieldCounter = 0; fieldCounter < fieldsToProcess.size(); fieldCounter++) {
            String fieldName = fieldsToProcess.get(fieldCounter);
            if (ForceeaService.fieldIsVirtual(fieldName)) {
                continue;
            }

            String fieldValue = this.fieldValuesMatrix.get(fieldCounter).get(recordCounter).trim();
            Schema.DisplayType valueType = ForceeaService.getField(this.sObjectApiName, fieldName).dataType;

            try {
                setSObjectFieldValue(result, valueType, fieldName, fieldValue);
            } catch (TypeException exp) {
                addError(fieldName,
                    MESSAGE_INVALID_VALUE + ' [' + fieldValue + '] ' +
                    MESSAGE_FOR_RECORD + recordCounter + ' of field [' + fieldName + ']');
            }
        }

        return result;
    }

    /**
     * @description Retrieves the new created records of an SObject.
     * @return A list of SObjects.
     */
    global List<SObject> getRecords() {
        createNewRecords();
        List<SObject> results = new List<SObject>(this.createdRecords);

        return results;
    }

    /**
     * @description Retrieves the SObject API name.
     * @return A string value of the SObject name.
     */
    global String getSObjectApiName() {
        return this.sObjectApiName;
    }

    /**
     * @description Retrieves a new Template excluding some Template keys and removes the consumed keys.
     * @param template The Template map.
     * @param keys A list of Template keys to exclude.
     * @return A Map<String, FObject>.
     */
    private static Map<String, FObject> getTemplateWithoutKeys(Map<String, FObject> template, List<String> keys) {
        Map<String, FObject> results = new Map<String, FObject>();

        for (String key : template.keySet()) {
            if (keys.contains(key)) {
                continue;
            }

            FObject fObj = template.get(key);
            fObj.templateKey = key;
            results.put(key, fObj);
            template.remove(key);
        }

        return results;
    }

    /**
     * @description Retrieves a new Template from existing Template keys and removes the keys.
     * @param template The Template map.
     * @param keys A list of Template keys to include.
     * @return A Map<String, FObject>.
     */
    private static Map<String, FObject> getTemplateWithKeys(Map<String, FObject> template, List<String> keys) {
        Map<String, FObject> results = new Map<String, FObject>();

        for (String key : template.keySet()) {
            if (!keys.contains(key)) {
                continue;
            }

            FObject fObj = template.get(key);
            fObj.templateKey = key;
            results.put(key, fObj);
            template.remove(key);
        }

        return results;
    }

    /**
     * @description Retrieves the time frame for asynchronous update.
     * @return The integer number of minutes of the time frame.
     */
    public Integer getTimeFrameOnAsyncUpdate() {
        return this.timeFrameForUpdateInMinutes;
    }

    /**
     * @description Retrieves all updated records.
     * @return A list of SObjects.
     */
    global List<SObject> getUpdatedRecords() {
        List<SObject> results = new List<SObject>(this.updatedRecords);
        return results;
    }

    /**
     * @description Retrieves the local variable value.
     * @param name The variable name.
     * @return The variable value as a string.
     */
    global String getVariable(String name) {
        String result = '';

        for (Forceea.Variable var : this.variables.values()) {
            if (var.name.equalsIgnoreCase(name)) {
                result = FObject.getVariableStringValue(var);
                break;
            }
        }

        return result;
    }

    /**
     * @description Retrieves the variable string value.
     * @param var The variable object.
     * @return The variable value as a string.
     */
    public static String getVariableStringValue(Forceea.Variable var) {
        String result = '';

        if (var.integerValue != null) {
            result = String.valueOf(var.integerValue);
        } else if (String.isNotBlank(var.stringValue)) {
            result = var.stringValue;
        } else if (var.decimalValue != null) {
            result = String.valueOf(var.decimalValue);
        } else if (var.dateValue != null) {
            result = String.valueOf(var.dateValue);
        } else if (var.datetimeValue != null) {
            result = String.valueOf(var.datetimeValue);
        } else if (var.booleanValue != null) {
            result = String.valueOf(var.booleanValue);
        }

        return result;
    }

    /**
     * @description Retrieves the SOQL WHERE clause for filtering the records to be deleted asynchronously.
     * @return The WHERE clause string.
     */
    global String getWhereClauseOnAsyncDelete() {
        return this.whereClauseOnAsyncDelete;
    }

    /**
     * @description Retrieves the SOQL WHERE clause for filtering the records to be updated asynchronously.
     * @return The WHERE clause string.
     */
    global String getWhereClauseOnAsyncUpdate() {
        return this.whereClauseOnAsyncUpdate;
    }

    /**
     * @description Handles the milestone for a DML operation.
     */
    public void handleDmlMilestone() {
        Integer numRecords = 0;
        if (this.dmlIsInsert) {
            numRecords = this.numInsertedRecords;
        } else if (this.dmlIsUpdate) {
            numRecords = this.numUpdatedRecords;
        } else if (this.dmlIsDelete) {
            numRecords = this.numDeletedRecords;
        }

        resetMilestoneTimer(getDmlMilestoneDescription(numRecords));
    }

    /**
     * @description Initializes properties and displays messages for setting required fields.
     */
    private void handleInitializationOfRequiredFields() {
        forceeaDebug(ForceeaService.DEBUG,
            MESSAGE_WILL_SET_DEFINITIONS_OF_REQUIRED_FIELDS + ' of [' + this.sObjectApiName + ']');
        this.requiredFieldNames.clear();
    }

    /**
     * @description Initializes the numOfFirstRecordsBySObject map.
     */
    private void initializeNumFirstRecordsBySObject() {
        if (!FObject.numFirstRecordsBySObject.containsKey(this.sObjectApiName)) {
            FObject.numFirstRecordsBySObject.put(this.sObjectApiName, 1);
        }
    }

    /**
     * @description Inserts the created records.
     * @param allOrNone Specifies whether the operation allows partial success. If you specify false
     *   for this parameter and a record fails, the remainder of the DML operation can still succeed.
     * @return A list of Database.SaveResult objects.
     */
    global List<Database.SaveResult> insertRecords(Boolean allOrNone) {
        String groupName = '';
        if (String.isNotBlank(this.groupName)) {
            groupName = this.groupName;
        }

        return insertRecords(allOrNone, groupName);
    }

    /**
     * @description Inserts the created records.
     * @param allOrNone Specifies whether the operation allows partial success. If you specify false
     *   for this parameter and a record fails, the remainder of the DML operation can still succeed.
     * @param groupName The group name of the inserted records.
     * @return A list of Database.SaveResult objects.
     */
    global List<Database.SaveResult> insertRecords(Boolean allOrNone, String groupName) {
        return new ForceeaInsertUpdateHandler(this).getInsertResults(allOrNone, groupName);
    }

    /**
     * @description Inserts the FObject records of a Template in their respective groups.
     * @param template The Template map.
     * @param allOrNone Specifies whether the operation allows partial success.
     * @return A map with key: template key, value: a list of SaveResult.
     */
    global static Map<String, List<Database.SaveResult>> insertRecordsFromTemplate(
        Map<String, FObject> template, Boolean allOrNone) {
        Map<String, List<Database.SaveResult>> results = new Map<String, List<Database.SaveResult>>();
        if (template == null || template.isEmpty() || allOrNone == null) {
            return results;
        }

        FObject.allOrNone = allOrNone;
        ForceeaService.setStandardPriceBookId(template);

        return (FObject.hasActivatedDmlOptimizer)
            ? ForceeaDomain.insertRecordsFromTemplateWithOptimizer(template)
            : ForceeaDomain.insertRecordsFromTemplateWithoutOptimizer(template);
    }

    /**
     * @description Inserts the FObject records related to specific keys of a Template.
     * @param template The Template map.
     * @param allOrNone Specifies whether the operation allows partial success.
     * @param keys A list of existing Template keys.
     * @return A list of Database.SaveResult objects, with key: template key, value: a list of SaveResult.
     */
    /* DEPRECATED */
    global static Map<String, List<Database.SaveResult>> insertRecordsFromTemplateWithKeys(
        Map<String, FObject> template, Boolean allOrNone, List<String> keys) {
        ForceeaDebugHandler.displayMethodIsDeprecatedMessage('insertRecordsFromTemplateWithKeys');
        Map<String, List<Database.SaveResult>> results = new Map<String, List<Database.SaveResult>>();

        if (template == null || template.isEmpty() || allOrNone == null || keys == null || keys.isEmpty()) {
            return results;
        }

        return insertRecordsFromTemplate(getTemplateWithKeys(template, keys), allOrNone);
    }

    /**
     * @description Inserts the FObject records not related to specific keys of a Template.
     * @param template The Template map.
     * @param allOrNone Specifies whether the operation allows partial success.
     * @param keys A list of existing Template keys.
     * @return A list of Database.SaveResult objects, with key: template key, value: a list of SaveResult.
     */
    /* DEPRECATED */
    global static Map<String, List<Database.SaveResult>> insertRecordsFromTemplateWithoutKeys(
        Map<String, FObject> template, Boolean allOrNone, List<String> keys) {
        ForceeaDebugHandler.displayMethodIsDeprecatedMessage('insertRecordsFromTemplateWithoutKeys');
        Map<String, List<Database.SaveResult>> results = new Map<String, List<Database.SaveResult>>();

        if (template == null || template.isEmpty() || allOrNone == null ||
            keys == null || keys.isEmpty()) {
            return results;
        }

        return insertRecordsFromTemplate(getTemplateWithoutKeys(template, keys), allOrNone);
    }

    /**
     * @description Inserts in their group (if any) the FObject records of a Template
     *   for all Template entries before and including a specific key, and removes the keys from Template.
     * @param template The Template map.
     * @param allOrNone Specifies whether the operation allows partial success.
     * @param lastKey The last key to include.
     * @return A list of Database.SaveResult objects.
     */
    /* DEPRECATED */
    global static Map<String, List<Database.SaveResult>> insertRecordsFromTemplateBeforeKey(
        Map<String, FObject> template, Boolean allOrNone, String lastKey) {
        ForceeaDebugHandler.displayMethodIsDeprecatedMessage('insertRecordsFromTemplateBeforeKey');
        Map<String, List<Database.SaveResult>> results = new Map<String, List<Database.SaveResult>>();

        if (template == null || template.isEmpty() || allOrNone == null ||
            String.isBlank(lastKey) || !template.keySet().contains(lastKey)) {
            return results;
        }
        FObject.allOrNone = allOrNone;

        Map<String, FObject> newTemplate = new Map<String, FObject>();
        for (String key : template.keySet()) {
            if (key == lastKey) {
                break;
            }
            newTemplate.put(key, template.get(key));
            template.remove(key);
        }

        return insertRecordsFromTemplate(newTemplate, allOrNone);
    }

    /**
     * @description Informs if the FObject will be excluded on async delete.
     * @return True, if the FObject is excluded on async delete.
     */
    public Boolean isExcludedOnAsyncDelete() {
        return this.isExcludedOnAsyncDelete;
    }

    /**
     * @description Informs if the FObject will be excluded on async update.
     * @return True, if the FObject is excluded on async update.
     */
    public Boolean isExcludedOnAsyncUpdate() {
        return this.isExcludedOnAsyncUpdate;
    }

    /**
     * @description Executes after the creation of records.
     * @return True, if the number of records is set to 'auto'.
     */
    public Boolean numOfRecordsIsAuto() {
        return this.processHasPermutations;
    }

    /**
     * @description Executes after the creation of records.
     */
    private void onAfterCreateRecords() {
        if (FObject.processMustTerminate() || this.createdRecords.isEmpty()) {
            return;
        }

        addCreatedRecordsToMapsWithOptimizer();
        this.recordsToInsert.addAll(this.createdRecords);
        this.mustCreateNewRecords = false;

        Integer numFirstRecord = FObject.numFirstRecordsBySObject.get(this.sObjectApiName);
        FObject.numFirstRecordsBySObject.put(this.sObjectApiName, numFirstRecord + this.records);

        resetMilestoneTimer('Created ' +
            ForceeaService.getCountable('record', this.createdRecords.size()) + ' of [' + this.sObjectApiName + ']');
        new ForceeaDebugHandler(this).displaySeparatorOnMethodFinish();
    }

    /**
     * @description Executes before the creation of records.
     */
    private void onBeforeCreateRecords() {
        new ForceeaDebugHandler(this).displayInitializationMessage();
        ForceeaDebugHandler.displaySeparatorOnMethodStart(
            this.sObjectApiName, 'Create records', this.templateKey);

        this.createdRecords.clear();
        this.permutationsList.clear();
        this.namesByGroup.clear();
        this.addressesByGroup.clear();
        this.numDefinitionsWithData = 0;

        setDefinitionOfRequiredFields();
    }

    /**
     * @description Posts a System.debug message.
     * @param errorLevel The System.LoggingLevel enum.
     * @param message The message to post.
     * @param verboseLevel The verbose level.
     * @return True, if the message was displayed.
     */
    private static Boolean postDebug(String errorLevel, String message, VerboseLevel verboseLevel) {
        errorLevel = errorLevel.trim();
        errorLevel = errorLevel.toLowerCase();

        if (errorLevel == ForceeaService.ERROR) {
            executeDebugLog(LoggingLevel.ERROR, DEBUG_LOG_PROMPT + message);
            FObject.processIsValid = false;
        } else if (errorLevel == ForceeaService.WARN) {
            executeDebugLog(LoggingLevel.WARN, DEBUG_LOG_PROMPT + message);
        } else if (errorLevel == ForceeaService.INFO && verboseLevel.ordinal() >= 1) {
            executeDebugLog(LoggingLevel.INFO, DEBUG_LOG_PROMPT + message);
        } else if (errorLevel == ForceeaService.DEBUG && verboseLevel.ordinal() == 1) {
            executeDebugLog(LoggingLevel.DEBUG, DEBUG_LOG_PROMPT + message);
        } else {
            return false;
        }

        FObject.debugLogs.add(message);
        return true;
    }

    /**
     * @description Determines if the process is valid.
     * @return True, if the process is valid.
     */
    global static Boolean processIsValid() {
        return FObject.processIsValid;
    }

    /**
     * @description Terminates the process if it is invalid.
     * @return True, if the process must terminate.
     */
    public static Boolean processMustTerminate() {
        if (FObject.processIsValid) {
            return false;
        }

        if (FObject.exceptionHandlingMode.equalsIgnoreCase('break')) {
            throw (Exception) new FObjectException(MESSAGE_INVALID_PROCESS);
        } else {
            if (!FObject.exceptionErrorMessageIsDisplayed) {
                FObject.forceeaDebugStatic(ForceeaService.ERROR, MESSAGE_INVALID_PROCESS);
                FObject.exceptionErrorMessageIsDisplayed = true;
            }
        }

        return true;
    }

    /**
     * @description Removes all definitions of every field.
     * @return An FObject instance.
     */
    global FObject removeAllDefinitions() {
        forceeaDebug(ForceeaService.INFO, MESSAGE_WILL_REMOVE_ALL_FIELDS_DEFINITIONS + ' [' + this.sObjectApiName + ']');
        this.definitions.clear();
        this.fields.clear();

        return this;
    }

    /**
     * @description Removes all definitions of a field.
     * @param fieldName The API name of a field.
     * @return An FObject instance.
     */
    public FObject removeAllDefinitionsOfField(String fieldName) {
        String fieldApiName = ForceeaService.getFieldApiName(
            this, '', this.sObjectApiName, fieldName, null, '', 'removeDefinitions');
        if (String.isBlank(fieldApiName)) {
            return this;
        }

        Integer fieldPosition = getFieldsToProcess().indexOf(fieldApiName);
        if (fieldPosition == -1) {
            return this;
        }
        new ForceeaDebugHandler(this)
            .displayMessageWillRemoveFieldDefinitions(this.sObjectApiName + '.' + fieldApiName);
        removeDefinitionIndexes(fieldApiName);

        if (!this.isUpdate) {
            this.fields.remove(fieldPosition);
        }

        return this;
    }

    /**
     * @description Removes all definitions of a field.
     * @param sObjectField The SObjectField.
     * @return An FObject instance.
     */
    global FObject removeDefinitions(Schema.SObjectField sObjectField) {
        return removeAllDefinitionsOfField(sObjectField.getDescribe().getName());
    }

    /**
     * @description Removes all definitions of a field.
     * @param fieldName The field API name.
     * @return An FObject instance.
     */
    global FObject removeDefinitions(String fieldName) {
        return removeAllDefinitionsOfField(fieldName);
    }

    /**
     * @description Removes a field definition with the given ID.
     * @param definitionId The Definition ID.
     * @return An FObject instance.
     */
    global FObject removeDefinitionWithId(String definitionId) {
        Integer index = 0;

        for (ForceeaDefinition def : this.definitions) {
            if (def.definitionId == definitionId) {
                this.definitions.remove(index);
                forceeaDebug(ForceeaService.DEBUG, MESSAGE_WILL_REMOVE_DEFINITION_WITH_ID + ' [' + definitionId + ']');
                break;
            }
            index++;
        }

        return this;
    }

    /**
     * @description Removes the definition indexes of the specified field.
     * @param fieldApiName The field API name.
     */
    public void removeDefinitionIndexes(String fieldApiName) {
        List<Integer> definitionIndexesToRemove = getDefinitionIndexes(fieldApiName);

        for (Integer counter = definitionIndexesToRemove.size() - 1; counter >= 0; counter--) {
            this.definitions.remove(definitionIndexesToRemove.get(counter));
        }
    }

    /**
     * @description Removes all existing field definitions
     *   and inserts any new definition(s) in the same position of the 1st existing definition.
     * @param fieldName The field API name.
     * @return An FObject instance.
     */
    global FObject replaceDefinitions(String fieldName) {
        String fieldApiName = ForceeaService.getFieldApiName(
            this, '', this.sObjectApiName, fieldName, null, '', 'replaceDefinitions');

        if (String.isNotBlank(fieldApiName)) {
            replaceDefinitionsOfField(fieldApiName);
        }

        return this;
    }

    /**
     * @description Removes all existing field definitions
     *   and inserts any new definition(s) in the same position of the 1st existing definition.
     * @param sObjectField The SObjectField.
     * @return An FObject instance.
     */
    global FObject replaceDefinitions(Schema.SObjectField sObjectField) {
        String fieldApiName = sObjectField.getDescribe().getName();
        replaceDefinitionsOfField(fieldApiName);

        return this;
    }

    /**
     * @description Removes all existing field definitions
     *   and activates the insertion of new definitions in the same position.
     * @param fieldApiName The field API name.
     */
    private void replaceDefinitionsOfField(String fieldApiName) {
        Integer fieldPosition = getFieldsToProcess().indexOf(fieldApiName);
        if (fieldPosition == -1) {
            return;
        }

        this.fieldApiNameForReplacement = fieldApiName;
    }

    /**
     * @description Replaces a field definition with the given ID.
     * @param definitionId The Definition ID.
     * @return An FObject instance.
     */
    global FObject replaceDefinitionWithId(String definitionId) {
        this.definitionPositionForReplacement = getDefinitionDetailsFromId(definitionId).position;
        this.definitionIdForReplacement = definitionId;

        return this;
    }

    /**
     * @description Informs if the required fields must be automatically configured.
     * @return True, if required fields should be configured automatically.
     */
    public Boolean requiredFieldsShouldBeAutomaticallyConfigured() {
        return this.requiredFieldsShouldBeAutomaticallyConfigured;
    }

    /**
     * @description Resets the static maps for names and addresses.
     */
    private static void resetLanguageLocality() {
        ForceeaAddress.firstNamesLibraryByGender.clear();
        ForceeaAddress.lastNamesLibraryByGender.clear();
        ForceeaAddress.addresses.clear();
    }

    /**
     * @description Resets the CPU timer and displays information
     *   about the elapsed time (in ms) since the previous reset.
     * @param infoText The information message to display.
     */
    public void resetMilestoneTimer(String infoText) {
        forceeaDebug(ForceeaService.INFO, SYMBOL_MILESTONE + ' ' + infoText + ' in ' +
            this.milestoneDuration + 'ms. Transaction duration: ' + Limits.getCpuTime() + 'ms.');
        this.milestoneStartTime = Limits.getCpuTime();
    }

    /**
     * @description Defines the process as synchronous or asynchronous.
     * @param isAsync If true, the process is asynchronous.
     */
    public static void setAsync(Boolean isAsync) {
        FObject.isAsync = isAsync;
    }

    /**
     * @description Declares a field definition with field as sObjectField.
     * @param sObjectField The SObjectField.
     * @param definitionString The field definition string.
     * @return An FObject instance.
     */
    global FObject setDefinition(Schema.SObjectField sObjectField, String definitionString) {
        setDefinition('', sObjectField, false, false, definitionString.trim());
        return this;
    }

    /**
     * @description Declares a field definition with field as String.
     * @param fieldApiName The API name of a field.
     * @param definitionString The field definition string.
     * @return An FObject instance.
     */
    global FObject setDefinition(String fieldApiName, String definitionString) {
        setDefinition(fieldApiName.trim(), null, false, false, definitionString.trim());
        return this;
    }

    /**
     * @description Declares a field definition.
     * @param fieldName The API name of a field.
     * @param sObjField The Schema SObject field.
     * @param isSystemDeclared If true, the definition is declared by Forceea.
     * @param isForUpdate If true, the definition is for update.
     * @param definitionString The field definition.
     */
    public void setDefinition(
        String fieldName,
        Schema.SObjectField sObjField,
        Boolean isSystemDeclared,
        Boolean isForUpdate,
        String definitionString
    ) {
        new ForceeaDefinitionHandler(this)
            .setDefinitionString(definitionString)
            .setFieldName(fieldName)
            .setIsForUpdate(isForUpdate)
            .setIsSystemDeclared(isSystemDeclared)
            .setSObjectField(sObjField)
            .setDefinition();
    }

    /**
     * @description Declares a field definition for updating records.
     * @param sObjectField The SObjectField.
     * @param definition The field definition (command + script).
     * @return An FObject instance.
     */
    global FObject setDefinitionForUpdate(Schema.SObjectField sObjectField, String definition) {
        setDefinition(sObjectField.getDescribe().getName(), null, false, true, definition);
        return this;
    }

    /**
     * @description Declares a field definition for updating records.
     * @param fieldApiName The API name of a field.
     * @param definition The field definition (command + script).
     * @return An FObject instance.
     */
    global FObject setDefinitionForUpdate(String fieldApiName, String definition) {
        setDefinition(fieldApiName, null, false, true, definition);
        return this;
    }

    /**
     * @description Sets the required fields.
     */
    private void setDefinitionOfRequiredFields() {
        if (FObject.isGlobalMocking) {
            String fieldName = ForceeaService.getFieldApiNameFromKey(this.sObjectApiName, 'Id', null);
            this.fields.add(fieldName);
            ForceeaDefinition def = new ForceeaDefinition(
                this, fieldName, fieldName, false, false, 'mock type(id)');
            this.definitions.add(def);
        }

        if (!this.requiredFieldsShouldBeAutomaticallyConfigured) {
            return;
        }
        setFields();
        handleInitializationOfRequiredFields();

        if (this.sObjectApiName.equalsIgnoreCase('user')) {
            new ForceeaRequiredFieldHandler(this)
                .setDefinitionsOfRequiredFieldsForUser();
        } else {
            new ForceeaRequiredFieldHandler(this)
                .setDefinitionsOfRequiredFieldsForSObjectsExceptUser();
        }

        if (this.requiredFieldNames.isEmpty()) {
            forceeaDebug(ForceeaService.INFO, 'Found no required fields');
        }
    }

    /**
     * @description Defines if Forceea will optimized the DML operation when inserting records from a Template.
     * @param isOptimized If true, the DML operation will be optimized for Templates.
     */
    global static void setDmlOptimizer(Boolean isOptimized) {
        if (FObject.isGlobalMocking) {
            FObject.hasActivatedDmlOptimizer = false;
        } else {
            FObject.hasActivatedDmlOptimizer = isOptimized;
        }
    }

    /**
     * @description Sets the exception handling's mode
     * @param mode The exception handling mode (break, continue)
     */
    global static void setExceptionHandling(String mode) {
        Set<String> modes = new Set<String>{
            'break', 'continue'
        };

        if (!modes.contains(mode.toLowerCase())) {
            FObject.exceptionHandlingMode = 'break';
        } else {
            FObject.exceptionHandlingMode = mode.toLowerCase();
        }
    }

    /**
     * @description Populates the globalFieldsMapBySObject map.
     */
    private void setFields() {
        if (this.hasSchemaOfAllFields) {
            return;
        }

        Map<String, Forceea.FieldInfo> fieldInfosByName = new Map<String, Forceea.FieldInfo>();
        for (Schema.SObjectField sof : ForceeaService.getSObjectFieldsByName(this.sObjectApiName).values()) {
            Forceea.FieldInfo fieldInfo = new ForceeaInfo().getFieldInfoFromSObjectField(sof);
            String key = fieldInfo.fieldApiName.toLowerCase();
            if (!fieldInfosByName.containsKey(key)) {
                fieldInfosByName.put(key, fieldInfo);
            }
        }

        FObject.globalFieldsMapBySObject.put(this.sObjectApiName.toLowerCase(), fieldInfosByName);
        this.hasSchemaOfAllFields = true;
    }

    /**
     * @description Sets Forceea settings based on default settings.
     */
    private static void setForceeaSettings() {
        ForceeaSettings__c defaultCustomSettings = FObject.getForceeaDefaultCustomSettings();
        if (defaultCustomSettings != null) {
            setForceeaSettingsFromCustomSettings(defaultCustomSettings);
            return;
        }

        ForceeaSetting__mdt defaultCustomMetadata = FObject.getForceeaDefaultCustomMetadata();
        if (defaultCustomMetadata != null) {
            setForceeaSettingsFromCustomMetadata(defaultCustomMetadata);
            return;
        }

        FObject.numRecordsToCreate = DEFAULT_NUM_RECORDS_TO_CREATE;
        FObject.numRecordsToDisplay = DEFAULT_NUM_RECORDS_TO_DISPLAY;
        FObject.numMaxErrorRecordsToDisplay = DEFAULT_NUM_MAX_ERROR_RECORDS_TO_DISPLAY;
        FObject.userMessage = '';
    }

    /**
     * @description Sets the Forceea settings from the default custom metadata settings.
     * @param defaultCustomMetadataSettings The default custom metadata settings.
     */
    private static void setForceeaSettingsFromCustomMetadata(ForceeaSetting__mdt defaultCustomMetadataSettings) {
        FObject.debugLogClass = defaultCustomMetadataSettings.DebugLogClass__c;
        FObject.debugLogMethod = defaultCustomMetadataSettings.DebugLogMethod__c;
        FObject.numRecordsToCreate = defaultCustomMetadataSettings.RecordsToCreate__c.intValue();
        FObject.numRecordsToDisplay = defaultCustomMetadataSettings.RecordsToDisplay__c.intValue();
        FObject.numMaxErrorRecordsToDisplay = defaultCustomMetadataSettings.MaxErrorRecordsToDisplay__c.intValue();
        FObject.userMessage = defaultCustomMetadataSettings.UserMessage__c;
        FObject.setForceeaValidSettings();
    }

    /**
     * @description Sets the Forceea settings from the default custom settings.
     * @param defaultCustomSettings The default custom settings.
     */
    private static void setForceeaSettingsFromCustomSettings(ForceeaSettings__c defaultCustomSettings) {
        FObject.debugLogClass = defaultCustomSettings.DebugLogClass__c;
        FObject.debugLogMethod = defaultCustomSettings.DebugLogMethod__c;
        FObject.numRecordsToCreate = defaultCustomSettings.RecordsToCreate__c.intValue();
        FObject.numRecordsToDisplay = defaultCustomSettings.RecordsToDisplay__c.intValue();
        FObject.numMaxErrorRecordsToDisplay = defaultCustomSettings.MaxErrorRecordsToDisplay__c.intValue();
        FObject.userMessage = defaultCustomSettings.UserMessage__c;
        FObject.setForceeaValidSettings();
    }

    private static void setForceeaValidSettings() {
        if (String.isBlank(FObject.debugLogClass)) {
            FObject.shouldUseExternalSystemDebug = false;
        }

        if (FObject.numRecordsToCreate <= 0) {
            FObject.numRecordsToCreate = DEFAULT_NUM_RECORDS_TO_CREATE;
        }

        if (FObject.numRecordsToDisplay <= 0) {
            FObject.numRecordsToDisplay = DEFAULT_NUM_RECORDS_TO_DISPLAY;
        }

        if (FObject.numMaxErrorRecordsToDisplay <= 0) {
            FObject.numMaxErrorRecordsToDisplay = DEFAULT_NUM_MAX_ERROR_RECORDS_TO_DISPLAY;
        }
    }

    /**
     * @description Sets the language at the class level.
     * @param language The language for all FObject instances.
     */
    global static void setGlobalLanguage(String language) {
        FObject.language = language.trim();
    }

    /**
     * @description Sets the locality at the class level.
     * @param locality The language for all FObject instances.
     */
    global static void setGlobalLocality(String locality) {
        FObject.locality = locality.trim();
    }

    /**
     * @description Defines the ID mocking for all records.
     * @param isMocked If true, Forceea sets ID mocking for all FObjects.
     */
    global static void setGlobalMocking(Boolean isMocked) {
        FObject.isGlobalMocking = isMocked;
        if (isMocked) {
            FObject.hasActivatedDmlOptimizer = false;
        }
    }

    /**
     * @description Sets the static properties.
     */
    private static void setGlobalProperties() {
        FObject.exceptionErrorMessageIsDisplayed = false;
        FObject.exceptionHandlingMode = 'break';
        FObject.globalQueryLimit = DEFAULT_QUERY_LIMIT;
        FObject.globalVerboseMode = VERBOSE_MODE;
        FObject.hasActivatedDmlOptimizer = false;
        FObject.initializationMessageIsDisplayed = false;
        FObject.isAsync = false;
        FObject.shouldOptimizeDml = false;
        FObject.isGlobalMocking = false;
        FObject.isOnValidation = false;
        FObject.language = 'English';
        FObject.locality = 'United States';
        FObject.mockingSerialNumber = 1;
        FObject.processIsValid = true;
        FObject.seed = Datetime.now().getTime();
        FObject.shouldUseExternalSystemDebug = true;

        FObject.cpuTimeOfGlobalSetup = Limits.getCpuTime();
    }

    /**
     * @description Sets the global SOQL query LIMIT.
     * @param queryLimit The SOQL query LIMIT for all FObject instances.
     */
    global static void setGlobalQueryLimit(Integer queryLimit) {
        FObject.globalQueryLimit = new ForceeaSelector().getValidatedQueryLimit(queryLimit);
    }

    /**
     * @description Sets a variable.
     * @param name The variable name.
     * @param value The variable value.
     */
    global static void setGlobalVariable(String name, Boolean value) {
        FObject.globalVariablesByName.put(name, new Forceea.Variable(name, value, true));
    }
    /**
     * @description Sets a String global variable.
     * @param name The variable name.
     * @param value The variable value.
     */
    global static void setGlobalVariable(String name, Date value) {
        FObject.globalVariablesByName.put(name, new Forceea.Variable(name, value, true));
    }
    /**
     * @description Sets a String global variable.
     * @param name The variable name.
     * @param value The variable value.
     */
    global static void setGlobalVariable(String name, Datetime value) {
        FObject.globalVariablesByName.put(name, new Forceea.Variable(name, value, true));
    }

    /**
     * @description Sets a Decimal global variable.
     * @param name The variable name.
     * @param value The variable value.
     */
    global static void setGlobalVariable(String name, Decimal value) {
        FObject.globalVariablesByName.put(name, new Forceea.Variable(name, value, true));
    }

    /**
     * @description Sets an Integer global variable.
     * @param name The variable name.
     * @param value The variable value.
     */
    global static void setGlobalVariable(String name, Integer value) {
        FObject.globalVariablesByName.put(name, new Forceea.Variable(name, value, true));
    }

    /**
     * @description Sets a String global variable.
     * @param name The variable name.
     * @param value The variable value.
     */
    global static void setGlobalVariable(String name, String value) {
        FObject.globalVariablesByName.put(name, new Forceea.Variable(name, value, true));
    }

    /**
     * @description Sets the verbose mode at the class level.
     * @param verboseMode The verbose mode (none, info, debug).
     */
    global static void setGlobalVerbose(String verboseMode) {
        String verbose = verboseMode.toLowerCase().trim();
        switch on verbose {
            when 'none' {
                FObject.globalVerboseMode = VerboseLevel.VERBOSE_NONE;
            } when 'debug' {
                FObject.globalVerboseMode = VerboseLevel.VERBOSE_DEBUG;
            } when 'info' {
                FObject.globalVerboseMode = VerboseLevel.VERBOSE_INFO;
            } when else {
                FObject.globalVerboseMode = VerboseLevel.VERBOSE_NONE;
            }
        }
    }

    /**
     * @description Stores the SObject's group, which will be used when inserting records.
     * @param groupName The group name.
     * @return An FObject instance.
     */
    global FObject setGroupName(String groupName) {
        if (String.isNotBlank(groupName)) {
            this.groupName = groupName.trim();
        }
        return this;
    }

    /**
     * @description Stores the SObject's group, which will be used when inserting records.
     * @param indexFields The list of index fields.
     * @return An FObject instance.
     */
    global FObject setIndexFields(Set<String> indexFields) {
        List<String> indexFieldsList = new List<String>(indexFields);
        String fieldsString = String.join(indexFieldsList, ',');
        return setIndexFields(fieldsString);
    }

    /**
     * @description Sets the index fields from a string of comma-separated fields.
     * @param indexFieldsString The comma-separated string of index fields.
     * @return An FObject instance.
     */
    global FObject setIndexFields(String indexFieldsString) {
        this.bigObjectIndexFieldsString = indexFieldsString;
        return this;
    }

    /**
     * @description Initializes instance properties.
     */
    private void setInstanceProperties() {
        this.cpuTimeOfObjectSetup = 0;
        this.cpuTimeStartOfObjectSetup = 0;
        this.cpuTimeOfDataGeneration = 0;
        this.cpuTimeStartOfDataGeneration = 0;
        this.definitionsAreValidated = false;
        this.definitionPositionForReplacement = -1;
        this.dmlIsDelete = false;
        this.dmlIsInsert = false;
        this.dmlIsUpdate = false;
        this.excludeInactiveLookupRecords = true;
        this.fieldApiNameForReplacement = '';
        this.groupName = ForceeaService.getStringValue(this.groupName);
        this.hasSchemaOfAllFields = false;
        this.isExcludedOnAsyncDelete = false;
        this.isExcludedOnAsyncUpdate = false;
        this.isMocking = false;
        this.isUpdate = false;
        this.numMaxRecordOnAsyncDelete = 0;
        this.numMaxRecordOnAsyncUpdate = 0;
        this.mustCreateNewRecords = true;
        this.numValidatedDefinitions = 0;
        this.processHasPermutations = false;
        this.queryLimit = FObject.globalQueryLimit;
        this.requiredFieldsShouldBeAutomaticallyConfigured = false;
        this.sObjType = ForceeaService.getSObjectType(this.sObjectApiName);
        this.timeFrameForUpdateInMinutes = DEFAULT_TIME_FRAME_FOR_UPDATE;
        this.virtualFieldForStandardPriceBookEntries = '';
    }

    /**
     * @description Sets the maximum number of records to delete asynchronously per batch.
     * @param numberOfRecords The maximum number of records to be deleted.
     * @return An instance of FObject.
     */
    global FObject setMaxNumberOfRecordOnAsyncDelete(Integer numberOfRecords) {
        this.numMaxRecordOnAsyncDelete = getCorrectMaxNumberOfRecordOnAsyncUpdateOrDelete(numberOfRecords);
        return this;
    }

    /**
     * @description Sets the maximum number of records to update asynchronously per batch.
     * @param numberOfRecords The maximum number of records to be updated.
     * @return An instance of FObject.
     */
    global FObject setMaxNumberOfRecordOnAsyncUpdate(Integer numberOfRecords) {
        this.numMaxRecordOnAsyncUpdate = getCorrectMaxNumberOfRecordOnAsyncUpdateOrDelete(numberOfRecords);
        return this;
    }

    /**
     * @description Sets the number of the first record to be created for serial values.
     * @param numberOfNextRecord The number of the next record.
     * @return An FObject instance.
     */
    global FObject setNumberOfNextRecord(Integer numberOfNextRecord) {
        this.numNextRecord = (numberOfNextRecord <= 0) ? 1 : numberOfNextRecord;
        FObject.numFirstRecordsBySObject.put(this.sObjectApiName, this.numNextRecord);

        return this;
    }

    /**
     * @description Sets the number of records.
     * @param numberOfRecords The number of records.
     * @return An FObject instance.
     */
    global FObject setNumberOfRecords(Integer numberOfRecords) {
        if (numberOfRecords <= 0) {
            this.records = 1;
        } else {
            this.records = numberOfRecords;
        }

        this.processHasPermutations = false;

        return this;
    }

    /**
     * @description Sets the number of records for permutations.
     * @param generationMode The mode.
     * @return An FObject instance.
     */
    global FObject setNumberOfRecords(String generationMode) {
        if (generationMode.toLowerCase() == PERMUTATIONS_AUTO) {
            this.processHasPermutations = true;
        }

        return this;
    }

    /**
     * @description Sets the partition field for async process.
     * @param sObjectFieldName The partition SObjectField.
     * @return An FObject instance.
     */
    global FObject setPartitionFieldName(Schema.SObjectField sObjectFieldName) {
        this.partitionFieldName = sObjectFieldName.getDescribe().getName();
        return this;
    }

    /**
     * @description Sets the lists for calculating permutations.
     */
    private void setPermutationValues() {
        for (ForceeaDefinition def : this.definitions) {
            def.setPermutations();
        }

        if (this.permutationsList.isEmpty()) {
            return;
        }

        List<String> permutationValues = new List<String>();
        ForceeaService.getPermutations(this.permutationsList, permutationValues, 0, '');

        List<List<String>> values = new List<List<String>>();
        for (Integer counter = 0; counter < permutationValues.size(); counter++) {
            values.add(permutationValues.get(counter).split('@@@'));
            values.get(counter).remove(0);
        }

        this.permutationValues = new List<List<String>>(values);
        if (this.processHasPermutations) {
            this.records = this.permutationValues.size();
        }
    }

    /**
     * @description Sets the process as valid or invalid.
     * @param isValid If true, the process is valid.
     * @return An FObject instance.
     */
    public FObject setProcessAsValid(Boolean isValid) {
        FObject.processIsValid = isValid;
        return this;
    }

    /**
     * @description Sets the SOQL query LIMIT.
     * @param queryLimit The LIMIT.
     * @return An FObject instance.
     */
    global FObject setQueryLimit(Integer queryLimit) {
        this.queryLimit = new ForceeaSelector().getValidatedQueryLimit(queryLimit);
        return this;
    }

    /**
     * @description Sets if Forceea should define the required fields.
     * @param fieldsAreRequired If true, Forceea automatically defines the required fields.
     * @return An FObject instance.
     */
    global FObject setRequiredFields(Boolean fieldsAreRequired) {
        this.requiredFieldsShouldBeAutomaticallyConfigured = fieldsAreRequired;
        return this;
    }

    /**
     * @description Sets the PRNG seed.
     * @param seedNumber The initial seed number for the generator.
     */
    global static void setSeed(Long seedNumber) {
        FObject.seed = seedNumber;
    }

    /**
     * @description Modifies an SObject record.
     * @param result The modified SObject.
     * @param valueType The Schema Display Type.
     * @param fieldName The field name string.
     * @param fieldValue The field value string.
     */
    private void setSObjectFieldValue(SObject result, Schema.DisplayType valueType, String fieldName, String fieldValue) {
        if (String.isBlank(fieldValue)) {
            result.put(fieldName, null);
            return;
        }

        switch on valueType {
            when STRING, PICKLIST {
                result.put(fieldName, fieldValue);
            } when DOUBLE {
                result.put(fieldName, Double.valueOf(fieldValue));
            } when CURRENCY {
                result.put(fieldName, Decimal.valueOf(fieldValue));
            } when BOOLEAN {
                result.put(fieldName, Boolean.valueOf(fieldValue));
            } when DATE {
                result.put(fieldName, Date.valueOf(fieldValue));
            } when PERCENT {
                result.put(fieldName, Decimal.valueOf(fieldValue));
            } when DATETIME {
                result.put(fieldName, Datetime.valueOf(fieldValue));
            } when INTEGER {
                result.put(fieldName, Integer.valueOf(fieldValue));
            } when TIME {
                Time valueTime;
                String thisYear = String.valueOf(Date.today().year());
                valueTime = Datetime.valueOf(thisYear + '-01-01 ' + fieldValue).time();
                result.put(fieldName, valueTime);
            } when BASE64 {
                result.put(fieldName, Blob.valueOf(fieldValue));
            } when else {
                // any other type
                result.put(fieldName, fieldValue);
            }
        }
    }

    /**
     * @description Sets the source parameter for all related definitions.
     * @param source The new source (forceea or salesforce).
     * @return An FObject instance.
     */
    global FObject setSource(String source) {
        String sourceToValidate = source.toLowerCase().trim();

        if (ForceeaService.sourceIsValid(sourceToValidate)) {
            for (ForceeaDefinition def : this.definitions) {
                def.setNewSource(sourceToValidate);
                def.definitionString = getDefinitionStringWithReplacedSource(def.definitionString, source);
            }
        }

        return this;
    }

    /**
     * @description Sets the source parameter for a specified definition.
     * @param sObjField The SObjectField.
     * @param source The new source (forceea or salesforce).
     * @return An FObject instance.
     */
    global FObject setSource(Schema.SObjectField sObjField, String source) {
        String fieldApiName = ForceeaService.getFieldApiName(
            this, '', this.sObjectApiName, '', sObjField, '', 'standard');
        for (ForceeaDefinition def : this.definitions) {
            def.setNewSource(fieldApiName, source);
            def.definitionString = getDefinitionStringWithReplacedSource(def.definitionString, source);
        }

        return this;
    }

    /**
     * @description Inserts entries for the Standard Price Book using the values of a virtual field.
     * @param virtualFieldName The virtual field name.
     * @return An FObject instance.
     */
    global FObject setStandardPricebookEntries(String virtualFieldName) {
        if (!virtualFieldIsValid(virtualFieldName)) {
            addError(this.sObjectApiName, MESSAGE_INVALID_VIRTUAL_FIELD + ' [' +
                virtualFieldName.trim() + '] ' + MESSAGE_METHOD_SET_STANDARD_PRICEBOOK_ENTRIES);
            return this;
        }

        this.virtualFieldForStandardPriceBookEntries = virtualFieldName.trim();
        return this;
    }

    /**
     * @description Sets the number of minutes of the time frame for update.
     * @param minutes The SObjectField.
     * @return An FObject instance.
     */
    global FObject setTimeFrameOnAsyncUpdate(Integer minutes) {
        this.timeFrameForUpdateInMinutes = minutes > 0
            ? minutes
            : DEFAULT_TIME_FRAME_FOR_UPDATE;
        return this;
    }

    /**
     * @description Sets a variable.
     * @param name The variable name.
     * @param value The Boolean variable value.
     * @return An FObject instance.
     */
    global FObject setVariable(String name, Boolean value) {
        this.variables.put(name, new Forceea.Variable(name, value, false));
        return this;
    }

    /**
     * @description Sets a variable.
     * @param name The variable name.
     * @param value The Date variable value.
     * @return An FObject instance.
     */
    global FObject setVariable(String name, Date value) {
        this.variables.put(name, new Forceea.Variable(name, value, false));
        return this;
    }

    /**
     * @description Sets a variable.
     * @param name The variable name.
     * @param value The Datetime variable value.
     * @return An FObject instance.
     */
    global FObject setVariable(String name, Datetime value) {
        this.variables.put(name, new Forceea.Variable(name, value, false));
        return this;
    }

    /**
     * @description Sets a variable.
     * @param name The variable name.
     * @param value The Decimal variable value.
     * @return An FObject instance.
     */
    global FObject setVariable(String name, Decimal value) {
        this.variables.put(name, new Forceea.Variable(name, value, false));
        return this;
    }

    /**
     * @description Sets a variable.
     * @param name The variable name.
     * @param value The Integer variable value.
     * @return An FObject instance.
     */
    global FObject setVariable(String name, Integer value) {
        this.variables.put(name, new Forceea.Variable(name, value, false));
        return this;
    }

    /**
     * @description Sets a variable.
     * @param name The variable name.
     * @param value The String variable value.
     * @return An FObject instance.
     */
    global FObject setVariable(String name, String value) {
        this.variables.put(name, new Forceea.Variable(name, value, false));
        return this;
    }

    /**
     * @description Sets the verbose mode at the instance level.
     * @param mode The verbose mode (none, info, debug).
     * @return An FObject instance.
     */
    global FObject setVerbose(String mode) {
        mode = mode.toLowerCase();

        if (mode == 'none') {
            this.verboseMode = VerboseLevel.VERBOSE_NONE;
        } else if (mode == 'debug') {
            this.verboseMode = VerboseLevel.VERBOSE_DEBUG;
        } if (mode == 'info') {
            this.verboseMode = VerboseLevel.VERBOSE_INFO;
        }

        return this;
    }

    /**
     * @description Sets the SOQL WHERE clause for filtering the records to be deleted asynchronously.
     * @param whereClause The SOQL WHERE clause.
     * @return An FObject instance.
     */
    global FObject setWhereClauseOnAsyncDelete(String whereClause) {
        this.whereClauseOnAsyncDelete = whereClause;
        return this;
    }

    /**
     * @description Sets the SOQL WHERE clause for filtering the records to be updated asynchronously.
     * @param whereClause The SOQL WHERE clause.
     * @return An FObject instance.
     */
    global FObject setWhereClauseOnAsyncUpdate(String whereClause) {
        this.whereClauseOnAsyncUpdate = whereClause;
        return this;
    }

    /**
     * @description Updates the fields of the recent records.
     * @return An instance of FObject.
     */
    global FObject updateFields() {
        return updateFields(null);
    }

    /**
     * @description Updates the fields of group records.
     * @param groupName The group name.
     * @return An instance of FObject.
     */
    global FObject updateFields(String groupName) {
        if (FObject.processMustTerminate()) {
            return this;
        }

        new ForceeaInsertUpdateHandler(this).updateFields(groupName);
        return this;
    }

    /**
     * @description Updates the created records.
     * @param allOrNone Specifies whether the operation allows partial success. If you specify false
     *   for this parameter and a record fails, the remainder of the DML operation can still succeed.
     * @return A list of Database.SaveResult objects.
     */
    global List<Database.SaveResult> updateRecords(Boolean allOrNone) {
        return new ForceeaInsertUpdateHandler(this).getUpdateResults(allOrNone);
    }

    /**
     * @description Validates a virtual field name.
     * @param virtualFieldName The virtual field name.
     * @return True, if the virtual field is valid.
     */
    @TestVisible
    private Boolean virtualFieldIsValid(String virtualFieldName) {
        String fieldName = virtualFieldName.trim();
        Boolean firstCharIsNotDollar = fieldName.left(1) != '$';
        Boolean isBlank = String.isBlank(fieldName);
        Boolean containsWhiteSpace = fieldName.containsWhitespace();
        String fieldWithoutDollar = fieldName.replace('$', '');
        Boolean hasIllegalCharacters = !fieldWithoutDollar.isAlpha();

        if (firstCharIsNotDollar || isBlank || containsWhiteSpace || hasIllegalCharacters) {
            return false;
        }

        return true;
    }

}