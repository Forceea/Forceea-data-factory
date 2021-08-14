/*
  Forceea data factory (v2.5.2)
  Copyright (C) 2021 Nikos Mitrakis

  This program is free software: you can redistribute it and/or modify it under the terms
  of the GNU General Public License as published by the Free Software Foundation,
  either version 3 of the License, or any later version.

  This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
  without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  See the GNU General Public License for more details.

  You can find a copy of the GNU General Public License at
  https://github.com/Forceea/Forceea-data-factory/blob/master/LICENSE
*/
public with sharing class FObject {

    /* CLASSES */

    /**
     * @description An error message.
     */
    private class Error {
        private String id { get; set; }
        private String errorMessage { get; set; }

        private Error(String errorId, String errorMessage) {
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

    /* CONSTANTS */

    private static final Integer BAR_LENGTH = 60;
    private static final String BAR_SYMBOL = '=';
    private static final String BLANK_VALUE = '...';

    @TestVisible private static final Integer DEFAULT_NUM_MAX_ERROR_RECORDS_TO_DISPLAY = 20;
    @TestVisible private static final Integer DEFAULT_NUM_RECORDS_TO_CREATE = 201;
    @TestVisible private static final Integer DEFAULT_NUM_RECORDS_TO_DISPLAY = 20;

    private static final String DEBUG_LOG_PROMPT = 'FORCEEA ';
    @TestVisible private static final Integer DEFAULT_QUERY_LIMIT = 1000;
    @TestVisible private static final Integer DEFAULT_QUERY_LIMIT_FOR_BIG_OBJECT = 50000;
    private static final String PERMUTATIONS_AUTO = 'auto';

    private static final String SETTINGS_DEFAULT = 'Default';

    private static final String SYMBOL_FAILURE = '*';
    private static final String SYMBOL_MILESTONE = '>>';
    private static final String SYMBOL_SUCCESS = '-';

    private static final VerboseLevel VERBOSE_MODE = VerboseLevel.VERBOSE_NONE;
    private static final String VERSION = '2.5';

    private static final String MESSAGE_INVALID_PROCESS = 'Process is invalid and will terminate.';
    private static final String MESSAGE_INVALID_VALUE = 'Invalid value';
    private static final String MESSAGE_FOR_RECORD = 'for record #';
    private static final String MESSAGE_INVALID_VIRTUAL_FIELD = 'Invalid virtual field';
    private static final String MESSAGE_METHOD_SET_STANDARD_PRICEBOOK_ENTRIES = 'in method [setStandardPricebookEntries]';
    private static final String MESSAGE_VALIDATED_DEFINITIONS = 'Validated definitions of';
    private static final String MESSAGE_VALUES = 'Values of';
    private static final String MESSAGE_WILL_DELETE_ALL_FIELDS_DEFINITIONS = 'Will delete all field definitions of';
    private static final String MESSAGE_WILL_DELETE_DEFINITION_WITH_ID = 'Will delete the definition with ID';
    private static final String MESSAGE_WILL_DELETE_FIELD_DEFINITIONS = 'Will delete all definitions of field';
    private static final String MESSAGE_WILL_DELETE_RECORDS = 'Will delete records';
    private static final String MESSAGE_WILL_DISPLAY_CREATED_FIELD_VALUES = 'Will display the created field values';
    private static final String MESSAGE_WILL_INSERT_CREATED_RECORDS = 'Will insert the created records';
    private static final String MESSAGE_WILL_NOT_DELETE_RECORDS = 'Will not delete records';
    private static final String MESSAGE_WILL_NOT_INSERT_RECORDS = 'Will not insert records';
    private static final String MESSAGE_WILL_REPLACE_ALL_DEFINITIONS = 'Will replace all definition of';
    private static final String MESSAGE_WILL_REPLACE_DEFINITION_WITH_ID = 'Will replace the definition with ID';
    private static final String MESSAGE_WILL_SET_DEFINITIONS_OF_REQUIRED_FIELDS =
        'Will set the definition of required fields';
    private static final String MESSAGE_WILL_STORE_CREATED_RECORDS = 'Will store the created records with mocked IDs';
    private static final String MESSAGE_WILL_UPDATE_FIELD_VALUES = 'Will update the field values';
    private static final String MESSAGE_WILL_UPDATE_RECORDS = 'Will update the records';
    private static final String MESSAGE_WILL_VALIDATE_FIELD_DEFINITIONS = 'Will validate the field definitions';

    private static final String PRODUCT2 = 'Product2';

    /* ENUMS */

    private enum VerboseLevel {
        VERBOSE_NONE, VERBOSE_DEBUG, VERBOSE_INFO
    }

    /* STATIC COLLECTIONS */

    // the library of addresses
    public static List<ForceeaAddress> addressesLibrary = new List<ForceeaAddress>();
    // the valid script commands
    private static List<String> commands = new List<String>{
        ForceeaService.COMMAND_COPY, ForceeaService.COMMAND_MOCK, ForceeaService.COMMAND_RANDOM,
        ForceeaService.COMMAND_SERIAL, ForceeaService.COMMAND_STATIC,
        ForceeaService.COMMAND_FUNCTION_ADD, ForceeaService.COMMAND_FUNCTION_CONVERT
    };
    // the debug logs
    private static List<String> debugLogs = new List <String>();
    // the defined cluster types
    public static List<ForceeaDefinitionType> definitionTypes = new List<ForceeaDefinitionType>();
    // the libraries for first names - key: gender, value: first names
    public static Map<String, List<String>> firstNamesLibraryByGender = new Map<String, List<String>>();
    // the map with key: Template key, value: the FObject to insert
    private static Map<String, FObject> fObjectsToInsertByTemplateKey = new Map<String, FObject>();
    // the field details of each declared FObject
    // key: SObject API name (lowercase), value: (key:field API name (lowercase), value: Field)
    public static Map<String, Map<String, ForceeaFieldInfo>> globalFieldsMapBySObject =
        new Map<String, Map<String, ForceeaFieldInfo>>();
    // the inserted records of all objects
    // key: objectApiName or objectApiName.groupName (lowercase), value: list of records
    public static Map<String, List<SObject>> globalInsertedRecordsByGroup = new Map<String, List<SObject>>();
    // the variables
    public static List<ForceeaVariable> globalVariables = new List<ForceeaVariable>();
    // the inserted SObject records by Group name
    private static Map<String, List<SObject>> insertedRecordsByGroupWithOptimizer = new Map<String, List<SObject>>();
    // the inserted SObject records by Template key
    private static Map<String, List<SObject>> insertedRecordsByTemplateKeyWithOptimizer = new Map<String, List<SObject>>();
    // the libraries for last names - key: gender, value: last names
    public static Map<String, List<String>> lastNamesLibraryByGender = new Map<String, List<String>>();
    /**
     * @description Τhe serializations map with key: SObject API name, value: next serialized record number.
     */
    public static Map<String, Integer> numFirstRecordsBySObject = new Map<String, Integer>();
    // the valid script parameters
    private static Set<String> parametersSet = new Set<String>{
        'scale', 'except', 'field', 'format', 'from', 'group', 'include', 'lookup', 'maxlength', 'minlength', 'mode',
        'number', 'source', 'startwith', 'step', 'to', 'type', 'value', 'where'
    };
    // the SObject records to insert by Group name
    private static Map<String, List<SObject>> recordsToInsertByGroupWithOptimizer = new Map<String, List<SObject>>();
    // the SObject records to insert by Template key
    private static Map<String, List<SObject>> recordsToInsertByTemplateKeyWithOptimizer = new Map<String, List<SObject>>();
    // the records to be inserted
    private static List<SObject> recordsToInsertWithOptimizer = new List<SObject>();
    // the map with key: SObject Type and value: list of Record Type Infos
    private static Map<Schema.SObjectType, List<Schema.RecordTypeInfo>> recordTypeInfosBySObject =
        new Map<Schema.SObjectType, List<Schema.RecordTypeInfo>>();
    //
    private static Map<String, List<Database.SaveResult>> saveResultsByTemplateKeyWithOptimizer =
        new Map<String, List<Database.SaveResult>>();
    // the list of SaveResult objects when inserting records with DML Optimizer
    private static List<Database.SaveResult> saveResultsWithOptimizer = new List<Database.SaveResult>();

    /* INSTANCE COLLECTIONS */

    /**
     * @description A map with the addresses - key: address group, value: address
     */
    public Map<String, List<ForceeaAddress>> addressesByGroup = new Map<String, List<ForceeaAddress>>();
    /**
     * @description The last created SObject records.
     */
    private List<SObject> createdRecords = new List<SObject>();
    /**
     * @description The declared field definitions.
     */
    public List<ForceeaDefinition> definitions = new List<ForceeaDefinition>();
    /**
     * @description The deleted records.
     */
    private List<SObject> deletedRecords = new List<SObject>();
    /**
     * @description The delete results list.
     */
    private List<Database.DeleteResult> deleteResults = new List<Database.DeleteResult>();
    /**
     * @description The definition errors.
     */
    private List<Error> errors = new List<Error>();
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
    private List<SObject> insertedRecords = new List<SObject>();
    /**
     * @description A map with key: <blank> or groupName (lowercase), value: list of records.
     */
    private Map<String, List<SObject>> instanceInsertedRecordsByGroup = new Map<String, List<SObject>>();
    /**
     * @description The first & last names - key: name group, value: name.
     */
    public Map<String, List<ForceeaName>> namesByGroup = new Map<String, List<ForceeaName>>();
    /**
     * @description A map with key: field API name, value: the next new field position.
     */
    private Map<String, Integer> nextNewFieldPositionByFieldName = new Map<String, Integer>();
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
    private List<Product2> productsToInsertPricebookEntries = new List<Product2>();
    /**
     * @description The records to be deleted.
     */
    private List<SObject> recordsToDelete = new List<SObject>();
    /**
     * @description The records to be inserted.
     */
    private List<SObject> recordsToInsert = new List<SObject>();
    // the records to be updated
    public List<SObject> recordsToUpdate = new List<SObject>();
    // the record types of this SObject - key: DeveloperName, value: Id)
    public Map<String, Id> recordTypeIdsByDeveloperName = new Map<String, Id>();
    // the field API names of required fields
    private List<String> requiredFieldNames = new List<String>();
    // the save results list
    private List<Database.SaveResult> saveResults = new List<Database.SaveResult>();
    // the updated records
    private List<SObject> updatedRecords = new List<SObject>();
    // the variables
    public List<ForceeaVariable> variables = new List<ForceeaVariable>();

    /* STATIC VARIABLES & PROPERTIES */

    // if true, the DML operation will not allow partial success
    private static Boolean allOrNone { get; set; }
    // the CPU time for the global setup
    private static Integer cpuTimeOfGlobalSetup { get; set; }
    // if true, the Exception error message has been displayed
    private static Boolean exceptionErrorMessageIsDisplayed { get; set; }
    // the Exception Handling mode: break (default): breaks execution, continue: continues execution
    private static String exceptionHandlingMode { get; set; }
    // the default SOQL query LIMIT
    private static Integer globalQueryLimit { get; set; }
    // if true, the DML Optimizer is activated
    private static Boolean hasActivatedDmlOptimizer { get; set; }
    // if true, if the initialization message has been displayed
    private static Boolean initializationMessageIsDisplayed { get; set; }
    // if true, the process is asynchronous
    private static Boolean isAsync { get; set; }
    // if true, Forceea creates records with mocked IDs
    private static Boolean isGlobalMocking { get; set; }
    // if true, the process is asynchronous
    private static Boolean isOnValidation { get; set; }
    // the language in name fields and addresses
    private static String language {
        get;
        set {
            resetLanguageLocality();
            language = value;
        }
    }
    // the locality in name fields and addresses
    private static String locality {
        get;
        set {
            resetLanguageLocality();
            locality = value;
        }
    }
    // the level of verbose mode
    private static VerboseLevel globalVerboseMode { get; set; }
    // the serial number for the mocked IDs
    public static Integer mockingSerialNumber { get; set; }
    // the default number of records to create
    @TestVisible private static Integer numRecordsToCreate { get; set; }
    // the maximum number of error records to display
    @TestVisible private static Integer numMaxErrorRecordsToDisplay { get; set; }
    // the number of created records to display
    @TestVisible private static Integer numRecordsToDisplay { get; set; }
    // if true, the process has no errors (valid)
    private static Boolean processIsValid { get; set; }
    // a pseudorandom number that is greater than or equal to 0 and less than 1
    // modified from DeviousBard https://github.com/DeviousBard/Salesforce
    public static Double random {
        get {
            Integer bits = 32;
            seed = (seed * 25214903917L + 11L) & ((1L << 48) - 1L);
            Long uInt = (Long) (seed >>> (48 - bits));
            return (Double) (((Double) uInt + 1.0) * 0.0000000002328306435454494);
        }
    }
    // the seed of pseudo-random number generator
    public static Long seed {
        get;
        set {
            seed = (value ^ 25214903917L) & ((1L << 48) - 1L);
        }
    }
    // if true, the DML statements should be optimized when using the method insertRecordsFromTemplate
    private static Boolean shouldOptimizeDml { get; set; }
    // the Standard Pricebook ID
    private static Id standardPriceBookId {
        get {
            if (standardPriceBookId == null) {
                if (Test.isRunningTest()) {
                    return Test.getStandardPricebookId();
                }

                Pricebook2 standardPriceBook = new ForceeaSelector().selectStandardPriceBook();
                if (standardPriceBook == null) {
                    return null;
                }
                standardPriceBookId = standardPriceBook.Id;
            }
            return standardPriceBookId;
        }
        set;
    }
    // if true, the street number is after street, e.g. Abcd 12
    public static Boolean streetNumberGoesAfterStreet { get; set; }
    // the message to display when initializing FObject
    @TestVisible private static String userMessage { get; set; }
    // the number of inserted records with the DML Optimizer
    private static Integer numInsertedRecordsWithOptimizer { get; set; }

    /* INSTANCE VARIABLES & PROPERTIES */

    // the index fields for the SELECT statement of Big Objects
    public String bigObjectIndexFieldsString { get; set; }
    // if true, User records can be inserted when not in Testing
    @TestVisible private Boolean canInsertUsers { get; set; }
    // the duration of CPU time for the SObject setup
    private Integer cpuTimeOfObjectSetup { get; set; }
    // the start of CPU time for the SObject setup
    private Integer cpuTimeStartOfObjectSetup { get; set; }
    // the duration of CPU time for the SObject data generation
    private Integer cpuTimeOfDataGeneration { get; set; }
    // the start of CPU time for the SObject data generation
    private Integer cpuTimeStartOfDataGeneration { get; set; }
    // if true, all definitions are validated
    private Boolean definitionsAreValidated { get; set; }
    /**
     * @description The ID of the replaced definition.
     */
    private String definitionIdForReplacement { get; set; }
    /**
     * @description The definition position for replacing the definition.
     */
    private Integer definitionPositionForReplacement { get; set; }
    // if true, the process deletes records
    private Boolean dmlIsDelete { get; set; }
    // if true, the process inserts records
    private Boolean dmlIsInsert { get; set; }
    // if true, the process updates records
    public Boolean dmlIsUpdate { get; set; }
    // exclude the lookup records with IsActive = false
    public Boolean excludeInactiveLookupRecords { get; set; }
    // the group that will be used when inserting records for this FObject
    private String groupName { get; set; }
    // if true, it has the Schema of all fields
    private Boolean hasSchemaOfAllFields { get; set; }
    /**
     * @description If true, the SObject is excluded from the asynchronous deletion.
     */
    private Boolean isExcludedOnAsyncDelete { get; set; }
    // if true, the IDs are mocked
    public Boolean isMocking { get; set; }
    // if true, it's a Big Object
    public Boolean isBigObject {
        get {
            if (isBigObject == null) {
                isBigObject = ForceeaService.isBigObject(this.sObjectApiName);
            }
            return isBigObject;
        }
        set;
    }
    // if true, the process updates fields
    public Boolean isUpdate { get; set; }
    // the CPU limit time for the timer start and finish
    private Integer milestoneStartTime { get; set; }
    // the elapsed CPU time for a milestone
    private Integer milestoneDuration {
        get {
            if (Limits.getCpuTime() < milestoneStartTime) {
                return Limits.getCpuTime();
            } else {
                return Limits.getCpuTime() - milestoneStartTime;
            }
        }
    }
    // if true, new records must be created
    private Boolean mustCreateNewRecords { get; set; }
    // the number of field definitions which have any data
    private Integer numDefinitionsWithData { get; set; }
    // the number of deleted records
    private Integer numDeletedRecords { get; set; }
    // the number of inserted records
    private Integer numInsertedRecords { get; set; }
    /**
     * @description The number of the next record, used by the method setNumberOfNextRecord
     */
    private Integer numNextRecord { get; set; }
    // the number of updated records
    private Integer numUpdatedRecords { get; set; }
    // the number of validated definitions
    private Integer numValidatedDefinitions { get; set; }
    // the partition field for async processing
    private String partitionFieldName { get; set; }
    // if TRUE, the created records will have permutations
    private Boolean processHasPermutations { get; set; }
    // the SOQL query LIMIT
    private Integer queryLimit { get; set; }
    // the number of records to create
    private Integer records { get; set; }
    /**
     * @description The field API name for replacing definitions.
     */
    private String fieldApiNameForReplacement { get; set; }
    // if true, Forceea sets all required fields
    private Boolean requiredFieldsShouldBeAutomaticallyConfigured { get; set; }
    // the SObject API name
    private String sObjectApiName { get; set; }
    // the SObject type
    public Schema.SObjectType sObjType { get; set; }
    // the key of the Template that contains this FObject
    private String templateKey { get; set; }
    // the level of verbose mode
    private VerboseLevel verboseMode { get; set; }
    // the name of the virtual field for getting the values of Standard Price Book entries
    private String virtualFieldForStandardPriceBookEntries { get; set; }

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

    public FObject(SObject insertedRecord) {
        this(null, new List<SObject>{ insertedRecord }, '');
    }

    public FObject(SObject insertedRecord, String groupName) {
        this(null, new List<SObject>{ insertedRecord }, groupName);
    }

    public FObject(List<SObject> insertedRecords) {
        this(null, insertedRecords, '');
    }

    public FObject(List<SObject> insertedRecords, String groupName) {
        this(null, insertedRecords, groupName);
    }

    public FObject(Schema.SObjectType sObjType, List<SObject> insertedRecords, String groupName) {
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

    public FObject(Schema.SObjectType sObjectType) {
        fObjectConstructorHandler(sObjectType, '', 0);
    }

    public FObject(String sObjectName) {
        fObjectConstructorHandler(null, sObjectName, 0);
    }

    public FObject(Schema.SObjectType sObjectType, Integer records) {
        fObjectConstructorHandler(sObjectType, '', records);
    }

    public FObject(String sObjectName, Integer records) {
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
        displayInitializationMessage();

        // validate the number of records
        if (numRecords < 0) {
            addError(sObjectApiName, 'Invalid number of records of [' + sObjectApiName + ']');
            if (FObject.processMustTerminate()) {
                return;
            }
        } else if (numRecords == 0) { // get the default records
            this.records = FObject.numRecordsToCreate;
        } else {
            this.records = numRecords;
        }

        initializeNumFirstRecordsBySObject();
        setInstanceProperties();
        setRecordTypes();
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

    private void addFieldInPosition(List<String> fields, String controllingFieldApiName, Integer position) {
        fields.add(position, controllingFieldApiName);
    }

    /**
     * @description Adds a list of PricebookEntry records to the global inserted map.
     * @param recordsToAdd The list of PricebookEntry records to add.
     */
    private void addPricebookEntriesToGlobalMap(List<SObject> recordsToAdd) {
        List<SObject> records = new List<SObject>();

        String key = 'pricebookentry.';
        if (FObject.globalInsertedRecordsByGroup.containsKey(key)) {
            records = FObject.globalInsertedRecordsByGroup.get(key);
        }

        records.addAll(recordsToAdd);
        FObject.globalInsertedRecordsByGroup.put(key, records);
    }

    /**
     * @description Adds the inserted records to the related maps of inserted records.
     */
    private void addRecordsToMapsOnInsert() {
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

    private static void addRecordsToMapsOnInsertWithOptimizer(String sObjectApiName) {
        FObject.addRecordsToInsertedRecordsByGroupWithOptimizer(sObjectApiName);
        FObject.addRecordsToInsertedRecordsByTemplateKeyWithOptimizer();
    }

    private static void addRecordsToInsertedRecordsByGroupWithOptimizer(String sObjectApiName) {
        for (String groupName : FObject.insertedRecordsByGroupWithOptimizer.keySet()) {
            List<SObject> recordsToAdd = FObject.insertedRecordsByGroupWithOptimizer.get(groupName);

            ForceeaService.putSObjectsIntoMap(
                FObject.globalInsertedRecordsByGroup, ForceeaService.getKey(sObjectApiName, ''), recordsToAdd);

            if (String.isBlank(groupName)) {
                continue;
            }
            ForceeaService.putSObjectsIntoMap(
                FObject.globalInsertedRecordsByGroup, ForceeaService.getKey(sObjectApiName, groupName), recordsToAdd);
        }
    }

    private static void addRecordsToInsertedRecordsByTemplateKeyWithOptimizer() {
        for (String key : FObject.insertedRecordsByTemplateKeyWithOptimizer.keySet()) {
            List<SObject> recordsToAdd = FObject.insertedRecordsByTemplateKeyWithOptimizer.get(key);
            FObject fObj = FObject.fObjectsToInsertByTemplateKey.get(key);

            ForceeaService.putSObjectsIntoMap(fObj.instanceInsertedRecordsByGroup, '', recordsToAdd);

            if (String.isNotBlank(fObj.groupName)) {
                ForceeaService.putSObjectsIntoMap(
                    fObj.instanceInsertedRecordsByGroup, fObj.groupName.toLowerCase(), recordsToAdd);
            }
        }
    }

    /**
     * @description Adds field values to Field Values Matrix.
     * @param fieldApiName The API name of the field.
     * @param fieldValues The list of field values.
     * @param definitionIsFunction If true, the definition is a function-x.
     */
    private void addToFieldValuesMatrix(String fieldApiName, List<String> fieldValues, Boolean definitionIsFunction) {
        Integer fieldCounter = 0;
        for (String field : getFieldsToProcess()) {
            if (field == fieldApiName) {
                for (Integer recordCounter = 0; recordCounter < this.records; recordCounter++) {
                    try { // append new value to existing value
                        if (definitionIsFunction) {
                            this.fieldValuesMatrix[fieldCounter][recordCounter] = fieldValues[recordCounter];
                        } else {
                            this.fieldValuesMatrix[fieldCounter][recordCounter] += fieldValues[recordCounter];
                        }
                    } catch (Exception exp) {
                        // avoid raising an error for a blank value
                    }
                }
                break;
            }
            fieldCounter++;
        }
    }

    /**
     * @description Appends new definitions after the definition with the given ID.
     * @param definitionId The Definition ID.
     * @return An FObject instance.
     */
    public FObject appendDefinitionsAfterId(String definitionId) {
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
    public FObject appendDefinitions(String fieldName) {
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
    public FObject appendDefinitions(Schema.SObjectField sObjectField) {
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
        Integer lastDefinitionPosition = definitionIndexes.get(size -1);
        this.nextNewFieldPositionByFieldName.put(fieldApiName, lastDefinitionPosition + 1);
    }

    /**
     * @description Defines if user records can be inserted when not testing.
     * @param insertUsers True, if we allow users to be inserted in non-testing mode.
     * @return An FObject instance.
     */
    public FObject canInsertUsers(Boolean insertUsers) {
        this.canInsertUsers = insertUsers;
        return this;
    }

    /**
     * @description Clears the next position map, if this is a new field.
     * @param fieldApiName The field API name.
     */
    private void clearNextNewFieldPositionsByFieldNameMap(String fieldApiName) {
        if (!this.nextNewFieldPositionByFieldName.containsKey(fieldApiName)) {
            this.nextNewFieldPositionByFieldName.clear();
        }
    }

    /**
     * @description Validates a definition command.
     * @param command The definition command.
     * @return A boolean value.
     */
    private Boolean commandIsValid(String command) {
        command = command.toLowerCase();

        for (String cmd : FObject.commands) {
            if (cmd == command) {
                return true;
            }
        }

        return false;
    }

    /**
     * @description Informs if the FObject contains a self-lookup definition.
     * @return True, if the FObject has any definition with "lookup(<SObjectApiName>)".
     */
    private Boolean containsSelfLookupDefinition() {
        String keyToSearch = 'lookup(' + this.sObjectApiName + ')';

        for (ForceeaDefinition def : this.definitions) {
            if (def.definitionString.containsIgnoreCase(keyToSearch)) {
                return true;
            }
        }

        return false;
    }

    /**
     * @description Creates and displays the field values.
     */
    private void createAndDisplayFieldValues() {
        for (String fieldName : getFieldsToProcess()) {
            for (ForceeaDefinition def : this.definitions) {
                Boolean skipIfValid = (this.isUpdate) ? !def.isForUpdate : def.isForUpdate;
                if (fieldName != def.fieldApiName || skipIfValid) {
                    continue;
                }

                List<String> fieldValues = new ForceeaGenerator(def).getValues();
                if (FObject.processMustTerminate()) {
                    return;
                }

                addToFieldValuesMatrix(def.fieldApiName, fieldValues, def.isFunction);
                this.numDefinitionsWithData++;
            }
        }

        displayFieldValues();
    }

    /**
     * @description Creates SObject records using the field definitions.
     */
    private void createNewRecords() {
        if (FObject.processMustTerminate() || !this.mustCreateNewRecords) {
            return;
        }
        onBeforeCreateRecords();

        validateDefinitions();
        if (FObject.processMustTerminate()) {
            return;
        }

        setPermutationValues();
        resetMilestoneTimer(MESSAGE_VALIDATED_DEFINITIONS + ' [' + this.sObjectApiName + ']');

        initializeFieldValuesMatrix();
        this.cpuTimeOfObjectSetup = Limits.getCpuTime() - this.cpuTimeStartOfObjectSetup;
        this.cpuTimeStartOfDataGeneration = Limits.getCpuTime();
        this.createdRecords = getCreatedRecords();

        onAfterCreateRecords();
    }

    /**
     * @description Creates records using the declared field definitions.
     * @return An FObject instance.
     */
    public FObject createRecords() {
        this.mustCreateNewRecords = true;
        createNewRecords();

        return this;
    }

    /**
     * @description Creates records starting with the record with a specific ID.
     * @param recordNumber The number of the next record to be created.
     * @return An FObject instance.
     */
    public FObject createRecords(Integer recordNumber) {
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
     * @description Deletes all definitions of every field.
     * @return An FObject instance.
     */
    public FObject deleteAllDefinitions() {
        forceeaDebug(ForceeaService.INFO, MESSAGE_WILL_DELETE_ALL_FIELDS_DEFINITIONS + ' [' + this.sObjectApiName + ']');
        this.definitions.clear();
        this.fields.clear();

        return this;
    }

    private void deleteAllDefinitionsForUpdateOfAllFields() {
        List<String> fieldsToRemove = new List<String>(this.fieldsForUpdate);

        for (String fieldName : fieldsToRemove) {
            deleteAllDefinitionsOfField(fieldName);
        }
    }

    /**
     * @description Deletes all definitions of a field.
     * @param fieldName The API name of a field.
     * @return An FObject instance.
     */
    private FObject deleteAllDefinitionsOfField(String fieldName) {
        String fieldApiName = ForceeaService.getFieldApiName(
            this, '', this.sObjectApiName, fieldName, null, '', 'deleteDefinitions');
        if (String.isBlank(fieldApiName)) {
            return this;
        }

        Integer fieldPosition = getFieldsToProcess().indexOf(fieldApiName);
        if (fieldPosition == -1) {
            return this;
        }
        displayMessageWillDeleteFieldDefinitions(this.sObjectApiName + '.' + fieldApiName);
        removeDefinitionIndexes(fieldApiName);

        if (!this.isUpdate) {
            this.fields.remove(fieldPosition);
        }

        return this;
    }

    /**
     * @description Deletes all definitions of a field.
     * @param sObjectField The SObjectField.
     * @return An FObject instance.
     */
    public FObject deleteDefinitions(Schema.SObjectField sObjectField) {
        return deleteAllDefinitionsOfField(sObjectField.getDescribe().getName());
    }

    /**
     * @description Deletes all definitions of a field.
     * @param fieldName The field API name.
     * @return An FObject instance.
     */
    public FObject deleteDefinitions(String fieldName) {
        return deleteAllDefinitionsOfField(fieldName);
    }

    /**
    * @description Deletes a field definition with the given ID.
    * @param definitionId The Definition ID.
    * @return An FObject instance.
    */
    public FObject deleteDefinitionWithId(String definitionId) {
        Integer index = 0;

        for (ForceeaDefinition def: this.definitions) {
            if (def.definitionId == definitionId) {
                this.definitions.remove(index);
                forceeaDebug(ForceeaService.DEBUG, MESSAGE_WILL_DELETE_DEFINITION_WITH_ID + ' [' + definitionId + ']');
                break;
            }
            index++;
        }

        return this;
    }

    /**
     * @description Deletes records of the SObject, using specific criteria (WHERE clause).
     * @param whereClause The WHERE clause of the SOQL query (e.g. MyField__c > 10).
     * @param allOrNone If true, the operation allows partial success.
     * @return A list of Database.DeleteResult objects.
     */
    public List<Database.DeleteResult> deleteRecords(String whereClause, Boolean allOrNone) {
        List<Database.DeleteResult> results = new List<Database.DeleteResult>();
        if (FObject.processMustTerminate() || allOrNone == null) {
            return results;
        }

        onBeforeDeleteRecords();
        deleteRecordsWithoutMockedIds(whereClause, allOrNone);
        results = new List<Database.DeleteResult>(this.deleteResults);

        onAfterDeleteRecords();
        return results;
    }

    /**
     * @description Deleted records when we don't have ID mocking.
     * @param whereClause The WHERE string.
     * @param allOrNone If true, the operation allows partial success.
     */
    private void deleteRecordsWithoutMockedIds(String whereClause, Boolean allOrNone) {
        if (this.sObjectApiName.equalsIgnoreCase('user')) {
            forceeaDebug(ForceeaService.WARN, MESSAGE_WILL_NOT_DELETE_RECORDS + ' of [User]');
            return;
        }

        forceeaDebug(ForceeaService.DEBUG,
            MESSAGE_WILL_DELETE_RECORDS + ' of [' + this.sObjectApiName + ']');
        this.deleteResults = getDeleteResults(whereClause, allOrNone);
        handleErrorsOnDelete();
    }

    /**
     * @description Displays the Field Value Matrix (FVM) values.
     */
    private void displayFieldValues() {
        forceeaDebug(ForceeaService.DEBUG, MESSAGE_WILL_DISPLAY_CREATED_FIELD_VALUES + ' of [' + this.sObjectApiName + ']');
        Integer counterField = 0;

        for (String fieldName : getFieldsToProcess()) {
            List<String> values = new List<String>();
            for (Integer counterRecord = 0; counterRecord < getNumRecordsToDisplay(); counterRecord++) {
                String value = this.fieldValuesMatrix.get(counterField).get(counterRecord);
                value = (String.isBlank(value)) ? BLANK_VALUE : value;
                values.add(value);
            }
            counterField++;
            forceeaDebug(ForceeaService.DEBUG, SYMBOL_SUCCESS + ' ' + MESSAGE_VALUES +
                ' [' + fieldName + ']: ' + String.join(values, ', '));
        }
    }

    /**
     * @description Displays the Forceea version and the User message.
     */
    private void displayInitializationMessage() {
        if (FObject.initializationMessageIsDisplayed) {
            return;
        }

        Boolean messageWasDisplayed = forceeaDebug(ForceeaService.INFO, '=== v' + VERSION + ' ===');
        if (String.isNotBlank(FObject.userMessage) && messageWasDisplayed) {
            forceeaDebug(ForceeaService.INFO, FObject.userMessage);
        }

        FObject.initializationMessageIsDisplayed = messageWasDisplayed;
    }

    private void displayMessageWillDeleteFieldDefinitions(String sObjectNameFieldName) {
        if (this.isUpdate) {
            return;
        }

        forceeaDebug(ForceeaService.INFO, MESSAGE_WILL_DELETE_FIELD_DEFINITIONS + ' [' + sObjectNameFieldName + ']');
    }

    /**
     * @description Displays a separator with a text.
     * @param sObjectApiName The SObject API name.
     * @param text The text.
     * @param templateKey The Template key.
     */
    private static void displaySeparatorOnMethodStart(String sObjectApiName, String text, String templateKey) {
        String key = (String.isNotBlank(templateKey)) ? templateKey + ':' : '';
        String optimizer = (FObject.shouldOptimizeDml) ? 'DMLOpt ' : '';
        String message = ' ' + text + ' [' + key + sObjectApiName + '] ' + optimizer;

        Integer totalBarLength = BAR_LENGTH - message.length();
        totalBarLength = totalBarLength < 2 ? 2 : totalBarLength;

        Integer leftBarLength = Math.max((Integer) totalBarLength / 2, 5);
        Integer rightBarLength = Math.max(totalBarLength - leftBarLength, 5);
        String leftBar = BAR_SYMBOL.repeat(leftBarLength);
        String rightBar = BAR_SYMBOL.repeat(rightBarLength);

        FObject.forceeaDebugStatic(ForceeaService.DEBUG, leftBar + message + rightBar);
    }

    /**
     * @description Displays a separator for a method (insert, update)
     */
    private void displaySeparatorOnMethodFinish() {
        forceeaDebug(ForceeaService.DEBUG, '.'.repeat(BAR_LENGTH));
    }

    /**
     * @description Excludes the inactive (IsActive=false) lookup records.
     * @param isExcluded If true, the lookup records with IsActive=false will be excluded.
     * @return An FObject instance.
     */
    public FObject excludeInactiveLookupRecords(Boolean isExcluded) {
        this.excludeInactiveLookupRecords = isExcluded;
        return this;
    }

    /**
     * @description Excludes the inactive (IsActive=false) lookup records.
     * @param isExcluded If true, the SObject will be excluded from the async delete process.
     * @return An FObject instance.
     */
    public FObject excludeOnAsyncDelete(Boolean isExcluded) {
        this.isExcludedOnAsyncDelete = isExcluded;
        return this;
    }

    /**
     * @description Informs if the field has a controlling field.
     * @param field The System.LoggingLevel enum.
     * @return True, if the field has a controlling field.
     */
    private Boolean fieldHasControllingField(ForceeaFieldInfo field) {
        return String.isBlank(field.controllingFieldApiName);
    }

    /**
 	 * @description Informs whether the field is defined.
 	 * @param fieldApiName The API name of a field.
 	 * @param isForUpdate True, if the field is for update.
 	 * @return True, if the field is already defined.
	 */
    private Boolean fieldIsDefined(String fieldApiName, Boolean isForUpdate) {
        List<String> fieldsToSearch = (isForUpdate) ? this.fieldsForUpdate : this.fields;

        for (String field : fieldsToSearch) {
            if (fieldApiName.equalsIgnoreCase(field)) {
                return true;
            }
        }

        return false;
    }

    /**
     * @description Informs whether the field exists in the list of fields.
     * @return True, if the field is not already defined with a definition.
     */
    private Boolean fieldDoesNotExist(String fieldApiName) {
        Integer fieldPosition = getFieldsToProcess().indexOf(fieldApiName);
        return fieldPosition == -1;
    }

    /**
     * @description Informs whether the field is for replacement.
     * @return True, if the field is set for replacing its definitions, set with replaceDefinitions.
     */
    private Boolean fieldIsNotForReplacement(String fieldApiName) {
        return !this.fieldApiNameForReplacement.equalsIgnoreCase(fieldApiName);
    }

    /**
     * @description Informs if the field is required.
     * @param dfr The schema describe field result.
     * @return True, if the field is required.
     */
    private static Boolean fieldIsRequired(Schema.DescribeFieldResult dfr) {
        return dfr.isCreateable() && !dfr.isNillable() && !dfr.isDefaultedOnCreate();
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
    public Map<String, List<String>> getAllDefinitions() {
        Map<String, List<String>> results = new Map<String, List<String>>();
        validateDefinitions();

        for (ForceeaDefinition def : this.definitions) {
            String field = def.fieldApiName;
            if (results.containsKey(field)) {
                results.get(field).add(def.definitionString);
            } else {
                results.put(field, new List<String>{def.definitionString});
            }
        }

        return results;
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

        createAndDisplayFieldValues();
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
    private List<Integer> getDefinitionIndexes(String fieldApiName) {
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
    * @description Retrieves a list of all definitions of a field.
    * @param sObjectField The SObjectField.
    * @return A list of string values.
    */
    public List<String> getDefinitions(Schema.SObjectField sObjectField) {
        return getDefinitions(sObjectField.getDescribe().getName());
    }

    /**
     * @description Retrieves a list of all definitions of a field.
     * @param fieldApiName The API name of the field.
     * @return A list of string values.
     */
    public List<String> getDefinitions(String fieldApiName) {
        validateDefinitions();
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
     * @description Retrieves the results of a delete operation.
     * @param whereClause The WHERE string.
     * @param allOrNone If true, the operation allows partial success.
     * @return A list of delete results.
     */
    private List<Database.DeleteResult> getDeleteResults(String whereClause, Boolean allOrNone) {
        Integer defaultQueryLimit = (this.isBigObject) ? DEFAULT_QUERY_LIMIT_FOR_BIG_OBJECT : DEFAULT_QUERY_LIMIT;
        Integer queryLimit = (this.queryLimit == null) ? defaultQueryLimit : this.queryLimit;

        this.recordsToDelete = new ForceeaSelector(this)
            .setWhere(whereClause)
            .setLimit(queryLimit)
            .selectAll();

        List<Database.DeleteResult> results = new List<Database.DeleteResult>();
        if (this.recordsToDelete.isEmpty()) {
            return results;
        }

        if (this.isBigObject) {
            return Database.deleteImmediate(this.recordsToDelete);
        } else {
            return Database.delete(this.recordsToDelete, allOrNone);
        }
    }

    /**
     * @description Retrieves the DML description.
     * @return A string of the DML description in the preferred tense.
     */
    private String getDmlDescription(String suffix, String startsWith) {
        String result = '';

        if (this.dmlIsInsert) {
            result = 'insert' + suffix;
        } else if (this.dmlIsUpdate) {
            result = 'updat' + suffix;
        } else if (this.dmlIsDelete) {
            result = 'delet' + suffix;
        }

        return (startsWith.toLowerCase() == 'uppercase') ? result.capitalize() : result;
    }

    /**
     * @description Retrieves the description of a DML milestone.
     * @return The description string.
     */
    private String getDmlMilestoneDescription(Integer numRecords) {
        String description = getDmlDescription('ed', 'uppercase') + ' ' +
            ForceeaService.getCountable('record', numRecords) + ' of [' + this.sObjectApiName + ']';

        return String.isNotBlank(this.groupName)
            ? description + ' group [' + this.groupName + ']'
            : description;
    }

    /**
     * @description Retrieves a list of the errors found during the process of creating the records of an FObject.
     * @return A map of key: String, value: List<String> values.
     */
    public Map<String, List<String>> getErrors() {
        Map<String, List<String>> results = new Map<String, List<String>>();

        for (Error err : this.errors) {
            if (results.containsKey(err.id)) {
                results.get(err.id).add(err.errorMessage);
            } else {
                results.put(err.id, new List<String>{
                    err.errorMessage
                });
            }
        }

        return results;
    }

    /**
     * @description Retrieves the field details.
     * @param sObjectField The sObject field.
     * @return A Field object.
     */
    public static ForceeaFieldInfo getFieldInfoFromSObjectField(Schema.SObjectField sObjectField) {
        ForceeaFieldInfo result = new ForceeaFieldInfo();
        Schema.DescribeFieldResult dfr = sObjectField.getDescribe();

        result.fieldName = dfr.getName().toLowerCase();
        result.fieldApiName = dfr.getName();
        result.label = dfr.getLabel();
        result.dataType = dfr.getType();
        result.isRestrictedPicklist = dfr.isRestrictedPicklist();
        result.canHaveMultipleTypesAsParents = dfr.isNamePointing();
        result.length = dfr.getLength();
        result.parents = dfr.getReferenceTo();
        result.isAccessible = dfr.isAccessible();
        result.isCreateable = dfr.isCreateable();

        if (FObject.fieldIsRequired(dfr)) {
            result.isRequired = true;
        } else {
            result.isRequired = false;
        }

        Schema.DisplayType dt = result.dataType;

        if (dt == Schema.DisplayType.STRING ||
            dt == Schema.DisplayType.EMAIL ||
            dt == Schema.DisplayType.URL ||
            dt == Schema.DisplayType.BASE64 ||
            dt == Schema.DisplayType.PHONE ||
            dt == Schema.DisplayType.TEXTAREA ||
            dt == Schema.DisplayType.COMBOBOX) {
            result.allowsMultipleDefinitions = true;
        } else {
            result.allowsMultipleDefinitions = false;
        }

        if (dt == Schema.DisplayType.PICKLIST ||
            dt == Schema.DisplayType.MULTIPICKLIST ||
            dt == Schema.DisplayType.COMBOBOX) {
            if (dfr.getController() != null) {
                result.controllingFieldApiName = dfr.getController().getDescribe().getName();
            }
            result.picklistValues = dfr.getPicklistValues();
        }

        return result;
    }

    /**
     * @description Retrieves the position of a field.
     * @param fieldApiName The API name of the field.
     * @return An integer value.
     */
    private Integer getFieldPosition(String fieldApiName) {
        Integer result = -1;
        Integer counter = 0;

        for (String field : this.fields) {
            if (field == fieldApiName) {
                result = counter;
                break;
            }
            counter++;
        }

        return result;
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
        List<ForceeaSetting__mdt> forceeaSettings = new ForceeaSelector().selectCustomMetadataSettings();
        ForceeaSetting__mdt result;
        for (ForceeaSetting__mdt setting : forceeaSettings) {
            if (setting.DeveloperName.equalsIgnoreCase(SETTINGS_DEFAULT)) {
                result = setting;
                break;
            }
        }

        return result;
    }

    /**
     * @description Retrieves the Forceea custom setting.
     * @return The Forceea custom setting.
     */
    private static ForceeaSettings__c getForceeaDefaultCustomSettings() {
        ForceeaSettings__c result;

        for (ForceeaSettings__c item : ForceeaSettings__c.getAll().values()) {
            if (item.Name.equalsIgnoreCase(SETTINGS_DEFAULT)) {
                result = item;
                break;
            }
        }

        return result;
    }

    /**
     * @description Retrieves the debug logs.
     * @return The list of debug logs.
     */
    public static List<String> getGlobalDebugLogs() {
        return FObject.debugLogs;
    }

    /**
     * @description Retrieves the language.
     * @return An string value.
     */
    public static String getGlobalLanguage() {
        return FObject.language;
    }

    /**
     * @description Retrieves the locality.
     * @return An string value.
     */
    public static String getGlobalLocality() {
        return FObject.locality;
    }

    /**
     * @description Retrieves the group name.
     * @return The string of group name.
     */
    public String getGroupName() {
        return this.groupName;
    }

    /**
     * @description Retrieves the default query limit.
     * @return The default query limit.
     */
    public Integer getGlobalQueryLimit() {
        if (this.dmlIsDelete && this.isBigObject) {
            return DEFAULT_QUERY_LIMIT_FOR_BIG_OBJECT;
        } else {
            return DEFAULT_QUERY_LIMIT;
        }
    }

    /**
     * @description Retrieves the global verbose.
     * @return The global verbose (none, info, debug).
     */
    public static String getGlobalVerbose() {
        switch on FObject.globalVerboseMode {
            when VERBOSE_INFO {
                return 'info';
            }
            when VERBOSE_DEBUG {
                return 'debug';
            }
            when else {
                return 'none';
            }
        }
    }

    /**
     * @description Retrieves the index of the next definition for replacement.
     * @param fieldApiName The field API name.
     * @return An integer number >= 0.
     */
    private Integer getIndexForReplacement(String fieldApiName) {
        Integer result = this.definitions.size();

        if (this.nextNewFieldPositionByFieldName.containsKey(fieldApiName)) {
            result = this.nextNewFieldPositionByFieldName.get(fieldApiName);
            this.nextNewFieldPositionByFieldName.put(fieldApiName, result + 1);
        }

        return result;
    }

    /**
     * @description Retrieves the first inserted record of an SObject that belongs to a specific group
     *   and is located in a specific zero-based position.
     * @param groupName The group name of the inserted records.
     * @return An SObject.
     */
    public SObject getInsertedGroupRecord(String groupName) {
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
    public List<SObject> getInsertedGroupRecords(String groupName) {
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
    public static List<SObject> getInsertedGroupRecords(Schema.SObjectType sObjectType, String groupName) {
        return getInsertedGroupRecords(sObjectType.getDescribe().getName(), groupName);
    }

    /**
     * @description Retrieves all inserted records of an SObject.
     * @param sObjectName The SObject name.
     * @param groupName The group name of the inserted records.
     * @return A list of SObjects.
     */
    public static List<SObject> getInsertedGroupRecords(String sObjectName, String groupName) {
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
    public SObject getInsertedRecord() {
        return getInsertedGroupRecord('');
    }

    /**
     * @description Retrieves all inserted records of an SObject.
     * @return A list of SObjects.
     */
    public List<SObject> getInsertedRecords() {
        return getInsertedGroupRecords('');
    }

    /**
     * @description Retrieves all inserted records of an SObject.
     * @param sObjectType The SObject type.
     * @return A list of SObjects.
     */
    public static List<SObject> getInsertedRecords(Schema.SObjectType sObjectType) {
        return FObject.getInsertedGroupRecords(sObjectType.getDescribe().getName(), '');
    }

    /**
     * @description Retrieves all inserted records of an SObject.
     * @param sObjectApiName The SObject API name.
     * @return A list of SObjects.
     */
    public static List<SObject> getInsertedRecords(String sObjectApiName) {
        return FObject.getInsertedGroupRecords(sObjectApiName, '');
    }

    /**
     * @description Retrieves the results of an insert operation.
     * @param allOrNone If true, the operation allows partial success.
     * @return A list of save results.
     */
    private List<Database.SaveResult> getInsertResults(Boolean allOrNone) {
        if (this.isBigObject) {
            return Database.insertImmediate(this.recordsToInsert);
        } else {
            return Database.insert(this.recordsToInsert, allOrNone);
        }
    }

    /**
     * @description Retrieves a map with key: SObject API name, value: list of FObjects of this SObject.
     * @param template The Template map.
     * @return A map of FObjects by SObject.
     */
    private static Map<String, List<FObject>> getMapWithFObjectsToInsertBySObjectKey(Map<String, FObject> template) {
        Map<String, List<FObject>> results = new Map<String, List<FObject>>();
        Set<String> keys = template.keySet();
        Map<String, Integer> countersBySObjectName = new Map<String, Integer>();

        for (String key : keys) {
            FObject fObj = template.get(key);
            fObj.templateKey = key;

            String sObjectApiName = fObj.sObjectApiName;
            if (!results.containsKey(sObjectApiName)) {
                countersBySObjectName.put(sObjectApiName, 0);
            }

            if (fObj.containsSelfLookupDefinition() || fObj.hasMockCommand() || fObj.hasStandardPriceBookEntries()) {
                Integer counter = countersBySObjectName.get(sObjectApiName) + 1;
                countersBySObjectName.put(sObjectApiName, counter);
                results.put(sObjectApiName + '.' + String.valueOf(counter), new List<FObject>{ fObj });
            } else {
                List<FObject> fObjects =
                    results.containsKey(sObjectApiName) ? results.get(sObjectApiName) : new List<FObject>();
                fObjects.add(fObj);
                results.put(sObjectApiName, fObjects);
            }
        }

        return results;
    }

    /**
     * @description Retrieves a map with key: SObject record ID, value: group name of the FObject related to this group.
     * @return The map recordsToInsertByGroupWithOptimizer.
     */
    private static Map<Id, String> getMapGroupsByRecordId() {
        Map<Id, String> results = new Map<Id, String>();

        for (String groupName : FObject.recordsToInsertByGroupWithOptimizer.keySet()) {
            for (SObject record : FObject.recordsToInsertByGroupWithOptimizer.get(groupName)) {
                results.put(record.Id, groupName);
            }
        }

        return results;
    }

    /**
     * @description Generates a map for the template keys by record ID.
     * @return A map with key: record ID, value: template key.
     */
    private static Map<Id, String> getMapTemplateKeysByRecordId() {
        Map<Id, String> results = new Map<Id, String>();

        for (String key : FObject.recordsToInsertByTemplateKeyWithOptimizer.keySet()) {
            for (SObject record : FObject.recordsToInsertByTemplateKeyWithOptimizer.get(key)) {
                results.put(record.Id, key);
            }
        }

        return results;
    }

    /**
     * @description Retrieves the number of records.
     * @return An integer value.
     */
    public Integer getNumberOfRecords() {
        return this.records;
    }

    /**
     * @description Retrieves the number of records to display.
     * @return An integer value.
     */
    private Integer getNumRecordsToDisplay() {
        return (this.records <= FObject.numRecordsToDisplay) ? this.records : FObject.numRecordsToDisplay;
    }

    /**
     * @description Retrieves the API name of the Partition field.
     * @return A string value of the Partition field name.
     */
    public String getPartitionFieldName() {
        return this.partitionFieldName;
    }

    /**
     * @description Finds the position of the closing double quotes.
     * @param script The field definition script.
     * @return The integer position of the closing double quotes.
     */
    private Integer getPositionOfClosingQuotes(String script) {
        Integer result = -1;
        Integer index = 0;
        Boolean resultIsFound = false;

        do {
            result = script.indexOf('"', index); // get position of next "
            String nextChar = script.mid(result + 1, 1);

            if (nextChar != '"') { // if next char is not "
                resultIsFound = true;
            }
            index = result + 2;
        } while (!resultIsFound);

        return result;
    }

    /**
	 * @description Creates a PricebookEntry record.
	 * @param standardPriceBookId The standard pricebook ID
	 * @param product2Id The product ID.
	 * @param unitPrice The unit price.
	 * @return An PricebookEntry SObject record.
	 */
    private SObject getPricebookEntry(Id standardPriceBookId, Id product2Id, Decimal unitPrice) {
        SObject result = PricebookEntry.SObjectType.newSObject();

        result.put('IsActive', true);
        result.put('Pricebook2Id', standardPriceBookId);
        result.put('Product2Id', product2Id);
        result.put('UnitPrice', unitPrice);

        return result;
    }

    /**
     * @description Retrieves the FObject query LIMIT.
     * @return The query LIMIT.
     */
    public Integer getQueryLimit() {
        return this.queryLimit;
    }

    /**
     * @description Creates an SObject record.
     * @param recordCounter The number of the record.
     * @return An SObject.
     */
    public SObject getRecord(Integer recordCounter) {
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
    public List<SObject> getRecords() {
        createNewRecords();
        List<SObject> results = new List<SObject>(this.createdRecords);

        return results;
    }

    /**
     * @description Retrieves the records to update.
     * @param groupName The group name.
     * @return A list of SObjects.
     */
    private List<SObject> getRecordsToUpdate(String groupName) {
        List<SObject> results = new List<SObject>();

        if (groupName == null) {
            results = this.createdRecords;
        } else if (String.isBlank(groupName)) {
            results = getInsertedRecords();
        } else {
            results = getInsertedGroupRecords(groupName);
        }

        return results;
    }

    /**
     * @description Retrieves the SObject API name.
     * @return A string value of the SObject name.
     */
    public String getSObjectName() {
        return this.sObjectApiName;
    }

    /**
     * @description Retrieves the list of Standard Pricebook entries to insert.
     * @param virtualFieldValues The list of virtual field values.
     * @param standardPriceBookId The ID of the standard pricebook.
     * @return An PricebookEntry SObject record.
     */
    private List<SObject> getStandardPricebookEntriesToInsert(List<String> virtualFieldValues) {
        List<SObject> results = new List<SObject>();
        Integer counter = 0;
        Id standardPriceBookId = FObject.standardPriceBookId;

        for (SObject record : this.productsToInsertPricebookEntries) {
            SObject newPricebookEntry = getPricebookEntry(
                standardPriceBookId, record.Id, Decimal.valueOf(virtualFieldValues.get(counter)));
            results.add(newPricebookEntry);
            counter++;
        }

        return results;
    }

    /**
     * @description Retrieves the active Standard Pricebook ID.
     * @return The Standard Price-book ID.
     */
    private Id getStandardPriceBookId() {
        if (Test.isRunningTest()) {
            return Test.getStandardPricebookId();
        }

        Pricebook2 standardPriceBook = new ForceeaSelector().selectStandardPriceBook();
        if (standardPriceBook == null) {
            return null;
        }
        return standardPriceBook.Id;
    }

    /**
     * @description Replaces the variables of the argument string with their values.
     * @param argument The argument String with defined variables as {@variableName}.
     * @return The argument String with the actual variable values.
     */
    private String getStringWithVariablesReplaced(String argument) {
        String result = argument;

        if (!result.contains('{@')) {
            return result;
        }

        List<ForceeaVariable> variables = new List<ForceeaVariable>(FObject.globalVariables);
        variables.addAll(this.variables);

        for (ForceeaVariable var : variables) {
            result = result.replace('{@' + var.name + '}', getVariableStringValue(var));
        }

        return result;
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
     * @description Retrieves all updated records.
     * @return A list of SObjects.
     */
    public List<SObject> getUpdatedRecords() {
        List<SObject> results = new List<SObject>(this.updatedRecords);
        return results;
    }

    /**
     * @description Validates and returns the SOQL query LIMIT.
     * @param queryLimit The SOQL query LIMIT.
     * @return The validated query LIMIT.
     */
    private static Integer getValidatedQueryLimit(Integer queryLimit) {
        Integer result = queryLimit;

        if (queryLimit < 1) {
            result = 1;
        } else if (queryLimit > 50000) {
            result = 50000;
        }

        return result;
    }

    /**
     * @description Retrieves the variable string value.
     * @param var The variable object.
     * @return The variable value as a string.
     */
    private String getVariableStringValue(ForceeaVariable var) {
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
     * @description Retrieves the variable value.
     * @param name The variable name.
     * @return The variable value as a string.
     */
    @TestVisible
    private String getVariableStringValue(String name) {
        String result = '';
        String nameToSearch = name.toLowerCase();

        List<ForceeaVariable> variables = new List<ForceeaVariable>(FObject.globalVariables);
        variables.addAll(this.variables);

        for (ForceeaVariable var : variables) {
            if (var.name == nameToSearch) {
                result = getVariableStringValue(var);
                break;
            }
        }

        return result;
    }

    /**
     * @description Creates new records if applicable.
     */
    private void handleCreationOfRecords() {
        if (this.recordsToInsert.isEmpty()) {
            this.mustCreateNewRecords = true;
        } else {
            this.mustCreateNewRecords = false;
        }
        createNewRecords();
    }

    /**
     * @description Handles the milestone for a DML operation.
     */
    private void handleDmlMilestone() {
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
     * @description Handles the errors displayed after a delete DML operation.
     */
    private void handleErrorsOnDelete() {
        Integer errors = 0;
        Integer counter = 0;
        Integer numSuccessfulRecords = 0;
        String dmlDescription = getDmlDescription('ing', 'lowercase');

        for (Database.DeleteResult result : this.deleteResults) {
            counter++;
            if (result.isSuccess()) {
                numSuccessfulRecords++;
                this.deletedRecords.add(this.recordsToDelete.get(counter - 1));
            } else {
                errors++;
                if (errors <= FObject.numMaxErrorRecordsToDisplay) {
                    for (Database.Error err : result.getErrors()) {
                        forceeaDebug(ForceeaService.WARN,
                            'Found errors ' + dmlDescription + ' record #' + counter + ': ' + err.getMessage());
                    }
                }
            }
        }

        this.numDeletedRecords = numSuccessfulRecords;

        if (errors > 0) {
            forceeaDebug(ForceeaService.WARN,
                'Found ' + ForceeaService.getCountable('error', errors) + ' ' + dmlDescription + ' ' +
                    ForceeaService.getCountable('record', this.deleteResults.size()) + ' of [' + this.sObjectApiName + ']');
        }
    }

    /**
     * @description Handles the errors displayed after an insert/update DML operation.
     */
    private void handleErrorsOnInsertOrUpdate() {
        Integer errors = 0;
        Integer counter = 0;
        Integer numSuccessfulRecords = 0;
        String dmlDescription = getDmlDescription('ing', 'lowercase');

        for (Database.SaveResult result : this.saveResults) {
            counter++;
            if (result.isSuccess()) {
                numSuccessfulRecords++;
                if (this.dmlIsInsert) {
                    this.insertedRecords.add(this.recordsToInsert.get(counter - 1));
                } else if (this.dmlIsUpdate) {
                    this.updatedRecords.add(this.recordsToUpdate.get(counter - 1));
                }
            } else {
                errors++;
                if (errors <= FObject.numMaxErrorRecordsToDisplay) {
                    for (Database.Error err : result.getErrors()) {
                        forceeaDebug(ForceeaService.WARN,
                            'Found errors ' + dmlDescription + ' record #' + counter + ': ' + err.getMessage());
                    }
                }
            }
        }

        if (this.dmlIsInsert) {
            this.numInsertedRecords = numSuccessfulRecords;
        } else if (this.dmlIsUpdate) {
            this.numUpdatedRecords = numSuccessfulRecords;
        }

        if (errors > 0) {
            forceeaDebug(ForceeaService.WARN,
                'Found ' + ForceeaService.getCountable('error', errors) + ' ' + dmlDescription + ' ' +
                    ForceeaService.getCountable('record', this.saveResults.size()) + ' of [' + this.sObjectApiName + ']');
        }
    }

    /**
     * @description Handles the errors displayed after inserting records with DML Optimizer.
     * @param sObjectApiName The SObject API name.
     */
    private static void handleErrorsOnDmlWithOptimizer(String sObjectApiName) {
        Integer errors = 0;
        Integer counter = 0;
        Integer numSuccessfulRecords = 0;
        Map<Id, String> groupsByRecordId = FObject.getMapGroupsByRecordId();
        Map<Id, String> templateKeysByRecordId = FObject.getMapTemplateKeysByRecordId();

        for (Database.SaveResult sr : FObject.saveResultsWithOptimizer) {
            counter++;
            String templateKey = templateKeysByRecordId.get(sr.getId());
            ForceeaService.putSaveResultIntoMap(FObject.saveResultsByTemplateKeyWithOptimizer, templateKey, sr);

            if (sr.isSuccess()) {
                numSuccessfulRecords++;
                SObject insertedSObj = FObject.recordsToInsertWithOptimizer.get(counter - 1);

                String groupName = groupsByRecordId.get(sr.getId());
                ForceeaService.putSObjectIntoMap(FObject.insertedRecordsByGroupWithOptimizer, groupName, insertedSObj);
                ForceeaService.putSObjectIntoMap(FObject.insertedRecordsByTemplateKeyWithOptimizer, templateKey, insertedSObj);
            } else {
                errors++;
                if (errors <= FObject.numMaxErrorRecordsToDisplay) {
                    for (Database.Error err : sr.getErrors()) {
                        FObject.forceeaDebugStatic(ForceeaService.ERROR,
                            'Found errors inserting record #' + counter + ': ' + err.getMessage());
                    }
                }
            }
        }

        FObject.numInsertedRecordsWithOptimizer = numSuccessfulRecords;

        if (errors > 0) {
            FObject.forceeaDebugStatic(ForceeaService.WARN,
                'Found ' + ForceeaService.getCountable('error', errors) + ' inserting ' +
                    ForceeaService.getCountable('record', FObject.saveResultsWithOptimizer.size()) +
                    ' of [' + sObjectApiName + ']');
        }
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
     * @description Handles the update of records.
     * @param allOrNone If true, the operation allows partial success.
     */
    private void handleRecordsOnUpdate(Boolean allOrNone) {
        List<SObject> validRecordsToUpdate = new List<SObject>();

        for (SObject record : this.recordsToUpdate) {
            if (idIsValid(record.Id)) {
                validRecordsToUpdate.add(record);
            }
        }

        forceeaDebug(ForceeaService.DEBUG, MESSAGE_WILL_UPDATE_RECORDS + ' of [' + this.sObjectApiName + ']');
        this.saveResults = Database.update(validRecordsToUpdate, allOrNone);
        handleErrorsOnInsertOrUpdate();
    }

    /**
     * @description Updates records using field definitions for update.
     * @param groupName The group name.
     */
    private void handleRecordsWithUpdatedValues(String groupName) {
        this.recordsToUpdate = getRecordsToUpdate(groupName);
        this.records = this.recordsToUpdate.size();
        if (this.recordsToUpdate.isEmpty()) {
            return;
        }

        validateDefinitionsOnUpdate();
        if (FObject.processMustTerminate()) {
            return;
        }

        initializeFieldValuesMatrix();
        createAndDisplayFieldValues();

        if (this.numDefinitionsWithData == 0) {
            this.recordsToUpdate = new List<SObject>();
            return;
        }

        setRecordsToUpdateWithNewFieldValues();
    }

    /**
     * @description Removes all existing field definitions and sets the position of the next definition.
     * @param fieldApiName The field API name.
     */
    private void handleReplacementOfFieldDefinitions(String fieldApiName) {
        if (fieldIsNotForReplacement(fieldApiName)) {
            return;
        }
        this.fieldApiNameForReplacement = '';

        clearNextNewFieldPositionsByFieldNameMap(fieldApiName);

        List<Integer> definitionIndexesToRemove = getDefinitionIndexes(fieldApiName);
        definitionIndexesToRemove.sort();
        removeDefinitionIndexes(fieldApiName);

        Integer firstDefinitionPosition = definitionIndexesToRemove.get(0);
        this.nextNewFieldPositionByFieldName.put(fieldApiName, firstDefinitionPosition);
        forceeaDebug(ForceeaService.DEBUG, MESSAGE_WILL_REPLACE_ALL_DEFINITIONS + ' [' + fieldApiName + ']');
    }

    /**
     * @description Removes existing field definitions and sets the position of the next definition.
     */
    private void handleReplacementOfDefinitionId(String fieldApiName) {
        if (this.definitionPositionForReplacement == -1) {
            return;
        }

        clearNextNewFieldPositionsByFieldNameMap(fieldApiName);

        Integer definitionIndexToRemove = this.definitionPositionForReplacement;
        this.definitions.remove(definitionIndexToRemove);
        forceeaDebug(ForceeaService.DEBUG, MESSAGE_WILL_REPLACE_DEFINITION_WITH_ID + ' [' + this.definitionIdForReplacement + ']');

        this.nextNewFieldPositionByFieldName.put(fieldApiName, definitionIndexToRemove);
        this.definitionPositionForReplacement = -1;
    }

    /**
     * @description Informs whether the FObject contains a mock command.
     * @return True, if the ock command exists.
     */
    private Boolean hasMockCommand() {
        for (ForceeaDefinition def : this.definitions) {
            if (def.definitionString.trim().startsWithIgnoreCase('mock')) {
                return true;
            }
        }

        return false;
    }

    /**
     * @description Informs whether the FObject has calculations for standard Pricebook entries.
     * @return True, if the FObject is related to Product2 SObject with a virtual field for standard pricebook entries.
     */
    private Boolean hasStandardPriceBookEntries() {
        return this.sObjectApiName == PRODUCT2 && String.isNotBlank(this.virtualFieldForStandardPriceBookEntries);
    }

    /**
     * @description Informs whether the ID value is valid (not blank or mocked).
     * @param idValue A string of the ID value.
     * @return True, if the ID is valid.
     */
    private Boolean idIsValid(String idValue) {
        return String.isNotBlank(idValue) && idValue.mid(3, 6) != '0'.repeat(6);
    }

    /**
     * @description Initializes the Field Values Matrix.
     */
    private void initializeFieldValuesMatrix() {
        this.fieldValuesMatrix.clear();

        for (Integer fieldCounter = 0; fieldCounter < getFieldsToProcess().size(); fieldCounter++) {
            List<String> values = new List<String>();
            for (Integer recordCounter = 0; recordCounter < this.records; recordCounter++) {
                values.add('');
            }
            this.fieldValuesMatrix.add(values);
        }
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
    public List<Database.SaveResult> insertRecords(Boolean allOrNone) {
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
    public List<Database.SaveResult> insertRecords(Boolean allOrNone, String groupName) {
        List<Database.SaveResult> results = new List<Database.SaveResult>();
        if (FObject.processMustTerminate() || allOrNone == null) {
            return results;
        }

        setGroupName(groupName);
        onBeforeInsertRecords();
        handleCreationOfRecords();
        if (FObject.processMustTerminate()) {
            onAfterInsertRecords();
            return results;
        }

        if (this.isMocking) {
            insertRecordsWithMockedIds();
        } else {
            insertRecordsWithoutMockedIds(allOrNone);
            results = new List<Database.SaveResult>(this.saveResults);
        }

        onAfterInsertRecords();
        return results ;
    }

    /**
     * @description Inserts the records of the FObjects, which are related to the same SObject.
     * @param fObjectsToInsert Specifies whether the operation allows partial success. If you specify false
     * @return A map with key: template key, value: a list of SaveResult.
     */
    private static Map<String, List<Database.SaveResult>> insertRecordsFromListWithOptimizer(
        List<FObject> fObjectsToInsert) {
        FObject.onBeforeInsertRecordsFromListWithOptimizer();

        for (FObject fObj : fObjectsToInsert) {
            if (fObj.numNextRecord != null) {
                fObj.setNumberOfNextRecord(fObj.numNextRecord);
            }
            fObj.mustCreateNewRecords = true;
            fObj.createNewRecords();
            FObject.fObjectsToInsertByTemplateKey.put(fObj.templateKey, fObj);
        }

        String sObjectApiName = fObjectsToInsert.get(0).sObjectApiName;
        FObject.insertRecordsWithoutMockedIdsWithOptimizer(sObjectApiName);

        FObject.onAfterInsertRecordsFromListWithOptimizer(sObjectApiName);

        return FObject.saveResultsByTemplateKeyWithOptimizer;
    }

    /**
     * @description Inserts the FObject records of a Template in their respective groups.
     * @param template The Template map.
     * @param allOrNone Specifies whether the operation allows partial success.
     * @return A map with key: template key, value: a list of SaveResult.
     */
    public static Map<String, List<Database.SaveResult>> insertRecordsFromTemplate(
        Map<String, FObject> template, Boolean allOrNone) {
        Map<String, List<Database.SaveResult>> results = new Map<String, List<Database.SaveResult>>();
        if (template == null || template.isEmpty() || allOrNone == null) {
            return results;
        }

        FObject.allOrNone = allOrNone;

        return (FObject.hasActivatedDmlOptimizer)
            ? insertRecordsFromTemplateWithOptimizer(template)
            : insertRecordsFromTemplateWithoutOptimizer(template);
    }

    /**
     * @description Inserts the FObject records related to specific keys of a Template in their respective groups.
     * @param template The Template map.
     * @param allOrNone Specifies whether the operation allows partial success.
     * @param keys A list of existing Template keys.
     * @return A list of Database.SaveResult objects, with key: template key, value: a list of SaveResult.
     */
    public static Map<String, List<Database.SaveResult>> insertRecordsFromTemplateWithKeys(
        Map<String, FObject> template, Boolean allOrNone, List<String> keys) {
        Map<String, List<Database.SaveResult>> results = new Map<String, List<Database.SaveResult>>();

        if (template == null || template.isEmpty() || allOrNone == null ||
            keys == null || keys.isEmpty()) {
            return results;
        }

        return insertRecordsFromTemplate(getTemplateWithKeys(template, keys), allOrNone);
    }

    /**
     * @description Inserts the FObject records not related to specific keys of a Template in their respective groups.
     * @param template The Template map.
     * @param allOrNone Specifies whether the operation allows partial success.
     * @param keys A list of existing Template keys.
     * @return A list of Database.SaveResult objects, with key: template key, value: a list of SaveResult.
     */
    public static Map<String, List<Database.SaveResult>> insertRecordsFromTemplateWithoutKeys(
        Map<String, FObject> template, Boolean allOrNone, List<String> keys) {
        Map<String, List<Database.SaveResult>> results = new Map<String, List<Database.SaveResult>>();

        if (template == null || template.isEmpty() || allOrNone == null ||keys == null || keys.isEmpty()) {
            return results;
        }

        return insertRecordsFromTemplate(getTemplateWithoutKeys(template, keys), allOrNone);
    }

    /**
     * @description Inserts in their group (if any) the FObject records of a Template
     *   for all Template entries before and including a specific key and removes the keys from Template.
     * @param template The Template map.
     * @param allOrNone Specifies whether the operation allows partial success.
     * @param lastKey The last key to include.
     * @return A list of Database.SaveResult objects.
     */
    public static Map<String, List<Database.SaveResult>> insertRecordsFromTemplateBeforeKey(
        Map<String, FObject> template, Boolean allOrNone, String lastKey) {
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
     * @description Inserts the FObject records of a Template for all FObjects with DML Optimizer.
     * @param template The Template map.
     * @return A map with key: template key, value: a list of SaveResult.
     */
    private static Map<String, List<Database.SaveResult>> insertRecordsFromTemplateWithOptimizer(
        Map<String, FObject> template) {
        Map<String, List<FObject>> fObjectsBySObjectKey = getMapWithFObjectsToInsertBySObjectKey(template);
        Map<String, List<Database.SaveResult>> results = new Map<String, List<Database.SaveResult>>();

        for (String key : fObjectsBySObjectKey.keySet()) {
            List<FObject> fObjectsToInsert = fObjectsBySObjectKey.get(key);

            FObject fObj = fObjectsToInsert.get(0);
            if (fObjectsToInsert.size() == 1) {
                FObject.shouldOptimizeDml = false;
                results.put(fObj.templateKey, fObj.insertRecords(FObject.allOrNone, fObj.groupName));
                FObject.shouldOptimizeDml = true;
                continue;
            }

            Map<String, List<Database.SaveResult>> saveResultsByTemplateKey =
                FObject.insertRecordsFromListWithOptimizer(fObjectsToInsert);
            for (String templateKey : saveResultsByTemplateKey.keySet()) {
                results.put(templateKey, saveResultsByTemplateKey.get(templateKey));
            }
        }

        return results;
    }

    /**
     * @description Inserts the FObject records of a Template for all FObjects without DML Optimizer.
     * @param template The Template map.
     * @return A map with key: template key, value: a list of SaveResult.
     */
    private static Map<String, List<Database.SaveResult>> insertRecordsFromTemplateWithoutOptimizer(
        Map<String, FObject> template) {
        Map<String, List<Database.SaveResult>> results = new Map<String, List<Database.SaveResult>>();

        for (String key : template.keySet()) {
            FObject fObj = template.get(key);
            if (fObj.numNextRecord != null) {
                fObj.setNumberOfNextRecord(fObj.numNextRecord);
            }
            results.put(key, fObj.insertRecords(FObject.allOrNone, fObj.groupName));
        }

        return results;
    }

    /**
     * @description Stores the created records when we have ID mocking.
     */
    private void insertRecordsWithMockedIds() {
        forceeaDebug(ForceeaService.DEBUG,
            MESSAGE_WILL_STORE_CREATED_RECORDS + ' of [' + this.sObjectApiName + ']');

        for (Integer counter = 0; counter < this.recordsToInsert.size(); counter++) {
            this.insertedRecords.add(this.recordsToInsert[counter]);
        }
    }

    /**
     * @description Inserts the created records when we don't have ID mocking.
     * @param allOrNone If true, the operation allows partial success.
     */
    private void insertRecordsWithoutMockedIds(Boolean allOrNone) {
        if (this.sObjectApiName.equalsIgnoreCase('user') && !Test.isRunningTest() && !this.canInsertUsers) {
            forceeaDebug(ForceeaService.WARN, MESSAGE_WILL_NOT_INSERT_RECORDS + ' of [User]');
            return;
        }

        forceeaDebug(ForceeaService.DEBUG,
            MESSAGE_WILL_INSERT_CREATED_RECORDS + ' of [' + this.sObjectApiName + ']');
        this.saveResults = getInsertResults(allOrNone);
        handleErrorsOnInsertOrUpdate();
    }

    private static void insertRecordsWithoutMockedIdsWithOptimizer(String sObjectApiName) {
        FObject.forceeaDebugStatic(ForceeaService.DEBUG,
            MESSAGE_WILL_INSERT_CREATED_RECORDS + ' of [' + sObjectApiName + ']');

        FObject.saveResultsWithOptimizer = Database.insert(FObject.recordsToInsertWithOptimizer, FObject.allOrNone);
        FObject.handleErrorsOnDmlWithOptimizer(sObjectApiName);

        String text = 'Inserted ' + ForceeaService.getCountable('record', FObject.numInsertedRecordsWithOptimizer) +
            ' of [' + sObjectApiName + ']';
        FObject.forceeaDebugStatic(ForceeaService.INFO, SYMBOL_MILESTONE + ' ' + text +
            '. Transaction duration: ' + Limits.getCpuTime() + 'ms.');
    }

    /**
     * @description Inserts entries for the Standard Price Book using the values of a virtual field.
     */
    private void insertStandardPricebookEntries() {
        if (String.isBlank(this.virtualFieldForStandardPriceBookEntries) || this.sObjectApiName != PRODUCT2) {
            return;
        }

        this.productsToInsertPricebookEntries = (List<Product2>) this.createdRecords;
        if (this.productsToInsertPricebookEntries.isEmpty()) {
            return;
        }

        Integer virtualFieldPosition = this.getFieldPosition(this.virtualFieldForStandardPriceBookEntries);
        if (virtualFieldPosition == -1) {
            addError(this.sObjectApiName, MESSAGE_INVALID_VIRTUAL_FIELD + ' [' +
                this.virtualFieldForStandardPriceBookEntries + '] ' + MESSAGE_METHOD_SET_STANDARD_PRICEBOOK_ENTRIES);
            return;
        }

        List<String> virtualFieldValues = new List<String>();
        String fieldValue = '';
        for (Integer counter = 0; counter < this.productsToInsertPricebookEntries.size(); counter++) {
            fieldValue = this.fieldValuesMatrix.get(virtualFieldPosition).get(counter);
            virtualFieldValues.add(fieldValue);
        }

        insertStandardPricebookEntriesFromVirtualFieldValues(virtualFieldValues);
    }

    /**
     * @description Inserts Standard Pricebook entries from virtual field values.
     * @param virtualFieldValues A list of string UnitPrice values.
     */
    private void insertStandardPricebookEntriesFromVirtualFieldValues(List<String> virtualFieldValues) {
        if (!FObject.processIsValid || FObject.standardPriceBookId == null || virtualFieldValues.isEmpty() || this.isMocking) {
            return;
        }

        List<SObject> standardPricebookEntriesToInsert =
            getStandardPricebookEntriesToInsert(virtualFieldValues);
        addPricebookEntriesToGlobalMap(standardPricebookEntriesToInsert);
        Database.insert(standardPricebookEntriesToInsert, true);
        forceeaDebug(ForceeaService.INFO,
            'Inserted ' + ForceeaService.getCountable('standard pricebook entry', standardPricebookEntriesToInsert.size()) + '.');
    }

    public Boolean isExcludedOnAsyncDelete() {
        return this.isExcludedOnAsyncDelete;
    }

    private Boolean keyDoesNotBelongToThisSObject(String sObjectApiName) {
        return !sObjectApiName.equalsIgnoreCase(this.sObjectApiName);
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
        displaySeparatorOnMethodFinish();
    }

    /**
     * @description Executes after the deletion of records.
     */
    private void onAfterDeleteRecords() {
        if (FObject.processMustTerminate()) {
            return;
        }

        removeRecordsFromMapsOnDelete();
        handleDmlMilestone();

        this.dmlIsDelete = false;
        this.recordsToDelete.clear();

        displaySeparatorOnMethodFinish();
    }

    /**
     * @description Executes after the insertion of records.
     */
    private void onAfterInsertRecords() {
        if (FObject.processMustTerminate()) {
            return;
        }

        addRecordsToMapsOnInsert();
        insertStandardPricebookEntries();
        handleDmlMilestone();

        this.dmlIsInsert = false;
        this.productsToInsertPricebookEntries.clear();
        this.recordsToInsert.clear();
        this.virtualFieldForStandardPriceBookEntries = '';
        this.cpuTimeOfDataGeneration = Limits.getCpuTime() - this.cpuTimeStartOfDataGeneration;

        displaySeparatorOnMethodFinish();
    }

    private static void onAfterInsertRecordsFromListWithOptimizer(String sObjectApiName) {

        FObject.addRecordsToMapsOnInsertWithOptimizer(sObjectApiName);
    }

    /**
     * @description Executes after the update of fields.
     */
    private void onAfterUpdateFields(String groupName) {
        if (String.isBlank(groupName)) {
            resetMilestoneTimer('Updated the field values of ' + this.numUpdatedRecords + ' records');
        } else {
            resetMilestoneTimer('Updated the field values of ' + this.numUpdatedRecords +
                ' records of group [' + groupName + ']');
        }

        deleteAllDefinitionsForUpdateOfAllFields();
        this.fieldsForUpdate.clear();
        this.isUpdate = false;

        displaySeparatorOnMethodFinish();
    }

    /**
     * @description Executes after the update of records.
     */
    private void onAfterRecordsUpdate() {
        handleDmlMilestone();

        this.dmlIsUpdate = false;
        this.recordsToUpdate.clear();

        displaySeparatorOnMethodFinish();
    }

    /**
     * @description Executes before the creation of records.
     */
    private void onBeforeCreateRecords() {
        displayInitializationMessage();
        FObject.displaySeparatorOnMethodStart(
            this.sObjectApiName, 'Create records', this.templateKey);

        this.createdRecords.clear();
        this.permutationsList.clear();
        this.namesByGroup.clear();
        this.addressesByGroup.clear();
        this.numDefinitionsWithData = 0;

        setDefinitionOfRequiredFields();
    }

    /**
    * @description Executes before the deletion of records.
    */
    private void onBeforeDeleteRecords() {
        this.deleteResults.clear();
        this.deletedRecords.clear();
        this.numDeletedRecords = 0;
        this.dmlIsDelete = true;
    }

    /**
     * @description Executes before the insertion of records.
     */
    private void onBeforeInsertRecords() {
        this.saveResults.clear();
        this.insertedRecords.clear();
        this.numInsertedRecords = 0;
        this.dmlIsInsert = true;
    }

    private static void onBeforeInsertRecordsFromListWithOptimizer() {
        FObject.shouldOptimizeDml = true;

        FObject.recordsToInsertWithOptimizer.clear();
        FObject.recordsToInsertByGroupWithOptimizer.clear();
        FObject.recordsToInsertByTemplateKeyWithOptimizer.clear();

        FObject.insertedRecordsByGroupWithOptimizer.clear();
        FObject.insertedRecordsByTemplateKeyWithOptimizer.clear();

        FObject.saveResultsByTemplateKeyWithOptimizer.clear();
        FObject.saveResultsWithOptimizer.clear();
        FObject.fObjectsToInsertByTemplateKey.clear();
    }

    /**
      * @description Executes before the update of fields.
      */
    private void onBeforeUpdateFields() {
        FObject.displaySeparatorOnMethodStart(
            this.sObjectApiName, 'Update fields', this.templateKey);

        this.isUpdate = true;
        this.numDefinitionsWithData = 0;
        this.numUpdatedRecords = 0;
        this.numValidatedDefinitions = 0;

        this.addressesByGroup.clear();
        this.namesByGroup.clear();
    }

    /**
     * @description Executes before the update of records.
     */
    private void onBeforeUpdateRecords() {
        FObject.displaySeparatorOnMethodStart(
            this.sObjectApiName, 'Update records', this.templateKey);

        this.saveResults.clear();
        this.updatedRecords.clear();
        this.numUpdatedRecords = 0;
        this.dmlIsUpdate = true;
    }

    /**
     * @description Validates the parameter of a cluster.
     * @param parameter The parameter of a cluster.
     * @return A boolean value.
     */
    private Boolean parameterIsValid(String parameter) {
        if (!FObject.parametersSet.contains(parameter.trim().toLowerCase()) || String.isBlank(parameter)) {
            return false;
        } else {
            return true;
        }
    }

    /**
     * @description Parses a definition to its command and clusters.
     * @param def The field definition.
     */
    private void parseDefinition(ForceeaDefinition def) {
        String definitionString = def.definitionString.trim();
        String fieldApiName = def.fieldApiName;
        String script = '';

        // parse command
        String command = definitionString.substringBefore(' ').trim();
        if (!def.isSystemDeclared && !commandIsValid(command)) {
            addError(fieldApiName, 'Invalid command [' + command + '] in definition [' + definitionString + ']');
            def.setValid(false);
            return;
        }

        script = definitionString.removeStart(command + ' ');
        command = command.toLowerCase();
        def.command = command.toLowerCase();

        // parse script
        do {
            script = parseCluster(def, script);
        } while (String.isNotEmpty(script));
    }

    /**
     * @description Parses a script cluster.
     * @param def The field definition.
     * @param script The script.
     * @return Returns the script without the cluster.
     */
    private String parseCluster(ForceeaDefinition def, String script) {
        List<String> arguments = new List<String>();
        String result = script.trim();
        String argument = '';
        String chr = '';
        String parameter = '';

        Integer doubleQuotesPosition = 0;
        Boolean mustContinue = true;
        Boolean commaExists = false;
        Boolean hasError = false;

        final String fieldApiName = def.fieldApiName;
        final String errorMessage = ForceeaService.MESSAGE_INVALID_DEFINITION + ' [' + def.definitionString + '] ' +
            'of field [' + fieldApiName + ']';

        // get parameter
        if (result.indexOf('(') == -1) { // found no (
            addError(fieldApiName, errorMessage);
            def.setValid(false);
            return '';
        } else { // found (
            parameter = result.substringBefore('('); // get parameter
            if (!parameterIsValid(parameter)) { // is invalid
                addError(fieldApiName, 'Invalid parameter [' + parameter.trim() + '] in definition [' +
                    def.definitionString + ']');
                def.setValid(false);
                return '';
            }
            result = result.removeStart(parameter + '('); // remove parameter and ( from script
            parameter = parameter.trim();
        }

        do {
            result = result.trim();

            chr = result.left(1); // get first char
            if (chr == '"') { // an argument in double quotation marks, e.g. "My argument"
                result = result.removeStart(chr); // remove opening "
                doubleQuotesPosition = getPositionOfClosingQuotes(result); // get position of closing "
                if (doubleQuotesPosition == -1) { // found no closing "
                    addError(fieldApiName, errorMessage);
                    def.setValid(false);
                    return '';
                } else { // found closing "
                    argument = result.substringBefore('"'); // get argument
                    result = result.removeStart(argument + '"'); // remove argument and " from script
                    result = result.trim();
                    // check if argument has leading or trailing white space characters
                    if (parameter.toLowerCase() == 'value' && (argument.startsWith(' ') || argument.endsWith(' '))) {
                        argument = '"' + argument + '"';
                    } else {
                        argument = argument.trim();
                    }
                    arguments.add(argument);
                }

                chr = result.left(1); // get next char - it should be , or )
                if (chr == ')') { // found (
                    result = result.removeStart(chr).trim(); // remove the )
                    mustContinue = false;
                } else if (chr == ',') { // found ,
                    result = result.removeStart(chr).trim(); // remove the comna
                } else { // found something else
                    addError(fieldApiName, errorMessage);
                    def.setValid(false);
                    return '';
                }
            } else if (chr.containsAny('(),')) { // invalid chars
                addError(fieldApiName, errorMessage);
                def.setValid(false);
                return '';
            } else { // an argument without double quotation marks
                // get the position of chars ( ) , "
                Integer commaPosition = result.indexOf(','); // get the position of next ,
                commaExists = (commaPosition != -1) ? true : false;
                doubleQuotesPosition = result.indexOf('"'); // get the position of next "

                Integer rightParenthesisPosition = result.indexOf(')'); // get the position of next )
                Boolean rightParenthesisExists = (rightParenthesisPosition != -1) ? true : false;

                // decide action based on next chars
                hasError = false;

                if (rightParenthesisExists && commaExists) {
                    if (rightParenthesisPosition < commaPosition) { // found )
                        chr = ')';
                        mustContinue = false;
                    } else { // found ,
                        chr = ',';
                        String textBeforeComma = result.left(commaPosition).trim();
                        if (textBeforeComma.right(1) == '"') {
                            hasError = true;
                        }
                    }
                } else if (rightParenthesisExists && !commaExists) { // found )
                    chr = ')'; // found )
                    mustContinue = false;
                    String textBeforeParenthesis = result.left(rightParenthesisPosition).trim();
                    if (textBeforeParenthesis.right(1) == '"') {
                        hasError = true;
                    }
                } else {
                    hasError = true;
                }

                argument = result.substringBefore(chr);

                // if the argument has the invalid chars ( or is empty
                if (argument.contains('(') || String.isBlank(argument)) {
                    hasError = true;
                }

                if (hasError) {
                    addError(fieldApiName, errorMessage);
                    def.setValid(false);
                    return '';
                }

                result = result.removeStart(argument + chr); // remove argument and ) or , from script
                arguments.add(argument.trim());
            } // argument without double quotes
        } while (mustContinue);

        // add cluster to definition
        ForceeaCluster newCluster = new ForceeaCluster(parameter.toLowerCase(), arguments);
        def.clusters.add(newCluster);

        return result;
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
            System.debug(LoggingLevel.ERROR, DEBUG_LOG_PROMPT + message);
            FObject.processIsValid = false;
        } else if (errorLevel == ForceeaService.WARN) {
            System.debug(LoggingLevel.WARN, DEBUG_LOG_PROMPT + message);
        } else if (errorLevel == ForceeaService.INFO && verboseLevel.ordinal() >= 1) {
            System.debug(LoggingLevel.INFO, DEBUG_LOG_PROMPT + message);
        } else if (errorLevel == ForceeaService.DEBUG && verboseLevel.ordinal() == 1) {
            System.debug(LoggingLevel.DEBUG, DEBUG_LOG_PROMPT + message);
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
    public static Boolean processIsValid() {
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

    private void removeDefinitionIndexes(String fieldApiName) {
        List<Integer> definitionIndexesToRemove = getDefinitionIndexes(fieldApiName);

        for (Integer counter = definitionIndexesToRemove.size() - 1; counter >= 0; counter--) {
            this.definitions.remove(definitionIndexesToRemove.get(counter));
        }
    }

    /**
     * @description Removes the deleted records from the related maps of inserted records.
     */
    private void removeRecordsFromMapsOnDelete() {
        if (this.isBigObject) {
            return;
        }

        Set<Id> deletedRecordIds = (new Map<Id, SObject>(this.deletedRecords)).keySet();

        for (String key : FObject.globalInsertedRecordsByGroup.keySet()) {
            String localGroupName = '';
            String sObjectApiName = '';

            if (key.contains('.')) { // this is a local group
                sObjectApiName = key.substringBefore('.');
                localGroupName = key.substringAfter('.');
            } else { // this is a global group
                sObjectApiName = key;
            }

            if (keyDoesNotBelongToThisSObject(sObjectApiName)) {
                continue;
            }

            Map<Id, SObject> insertedGlobalRecordsById =
                new Map<Id, SObject>(FObject.globalInsertedRecordsByGroup.get(key));
            Map<Id, SObject> insertedInstanceRecordsById =
                new Map<Id, SObject>(this.instanceInsertedRecordsByGroup.get(localGroupName));

            for (Id deletedRecordId : deletedRecordIds) {
                insertedGlobalRecordsById.remove(deletedRecordId);
                insertedInstanceRecordsById.remove(deletedRecordId);
            }

            // update the inserted records map
            FObject.globalInsertedRecordsByGroup.put(key, insertedGlobalRecordsById.values());
            this.instanceInsertedRecordsByGroup.put(localGroupName, insertedInstanceRecordsById.values());
        }
    }

    /**
     * @description Removes all existing field definitions
     *   and inserts any new definition(s) in the same position of the 1st existing definition.
     * @param fieldName The field API name.
     * @return An FObject instance.
     */
    public FObject replaceDefinitions(String fieldName) {
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
    public FObject replaceDefinitions(Schema.SObjectField sObjectField) {
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
    public FObject replaceDefinitionWithId(String definitionId) {
        //this.fieldApiNameForReplacement = getDefinitionDetailsFromId(definitionId).fieldApiName;
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
        FObject.firstNamesLibraryByGender.clear();
        FObject.lastNamesLibraryByGender.clear();
        FObject.addressesLibrary.clear();
    }

    /**
     * @description Resets the CPU timer and displays information
     *   about the elapsed time (in ms) since the previous reset.
     * @param infoText The information message to display.
     */
    private void resetMilestoneTimer(String infoText) {
        forceeaDebug(ForceeaService.INFO, SYMBOL_MILESTONE + ' ' + infoText + ' in ' +
            this.milestoneDuration + 'ms. Transaction duration: ' + Limits.getCpuTime() + 'ms.');
        this.milestoneStartTime = Limits.getCpuTime();
    }

    /**
     * @description Defines the process as synchronous or asynchronous.
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
    public FObject setDefinition(Schema.SObjectField sObjectField, String definitionString) {
        setDefinition('', sObjectField, false, false, definitionString.trim());
        return this;
    }

    /**
     * @description Declares a field definition with field as String.
     * @param fieldApiName The API name of a field.
     * @param definitionString The field definition string.
     * @return An FObject instance.
     */
    public FObject setDefinition(String fieldApiName, String definitionString) {
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
    private void setDefinition(
        String fieldName,
        Schema.SObjectField sObjField,
        Boolean isSystemDeclared,
        Boolean isForUpdate,
        String definitionString) {
        this.definitionsAreValidated = false;
        definitionString = getStringWithVariablesReplaced(definitionString);

        String fieldApiName = ForceeaService.getFieldApiName(
            this, definitionString, this.sObjectApiName, fieldName, sObjField, '', 'standard');
        if (String.isBlank(fieldApiName)) {
            return;
        }

        handleReplacementOfFieldDefinitions(fieldApiName);
        handleReplacementOfDefinitionId(fieldApiName);
        clearNextNewFieldPositionsByFieldNameMap(fieldApiName);
        setDefinitionInCorrectPosition(fieldApiName, fieldName, isSystemDeclared, isForUpdate, definitionString);

        if (!fieldIsDefined(fieldApiName, isForUpdate)) {
            if (isForUpdate) {
                this.fieldsForUpdate.add(fieldApiName);
            } else {
                this.fields.add(fieldApiName);
            }
        }

        this.mustCreateNewRecords = (isForUpdate) ? false : true;
    }

    private void setDefinitionInCorrectPosition(
        String fieldApiName,
        String fieldName,
        Boolean isSystemDeclared,
        Boolean isForUpdate,
        String definitionString) {
        ForceeaDefinition newDefinition = new ForceeaDefinition(
            this, this.sObjectApiName, fieldName, fieldApiName, isSystemDeclared, isForUpdate, definitionString);

        Integer index = getIndexForReplacement(fieldApiName);
        if (index == this.definitions.size()) { // end of list
            this.definitions.add(newDefinition);
        } else {
            this.definitions.add(index, newDefinition);
        }
    }

    /**
     * @description Declares a field definition for updating records.
     * @param sObjectField The SObjectField.
     * @param definition The field definition (command + script).
     * @return An FObject instance.
     */
    public FObject setDefinitionForUpdate(Schema.SObjectField sObjectField, String definition) {
        setDefinition(sObjectField.getDescribe().getName(), null, false, true, definition);
        return this;
    }

    /**
     * @description Declares a field definition for updating records.
     * @param fieldApiName The API name of a field.
     * @param definition The field definition (command + script).
     * @return An FObject instance.
     */
    public FObject setDefinitionForUpdate(String fieldApiName, String definition) {
        setDefinition(fieldApiName, null, false, true, definition);
        return this;
    }

    /**
     * @description Sets a field definition based on the field data type and the SObject.
     * @param field A field object.
     */
    @TestVisible
    private void setDefinitionFromField(ForceeaFieldInfo field) {
        if (this.sObjectApiName == 'Account' && field.fieldApiName == 'Name') {
            setDefinition(field.fieldName, null, true, false,
                'static value(Company-)');
            setDefinition(field.fieldName, null, true, false,
                'serial type(number) from(1) step(1) scale(0)');
        } else if (this.sObjectApiName == 'Contact' && field.fieldApiName == 'FirstName') {
            setDefinition(field.fieldName, null, true, false,
                'random type(firstName) group(name)');
        } else if (this.sObjectApiName == 'Contact' && field.fieldApiName == 'LastName') {
            setDefinition(field.fieldName, null, true, false,
                'random type(lastName) group(name)');
        } else if (this.sObjectApiName == 'Lead' && field.fieldApiName == 'Company') {
            setDefinition(field.fieldName, null, true, false,
                'static value(Company-)');
            setDefinition(field.fieldName, null, true, false,
                'serial type(number) from(1) step(1) scale(0)');
        } else if (this.sObjectApiName == 'Lead' && field.fieldApiName == 'FirstName') {
            setDefinition(field.fieldName, null, true, false,
                'random type(firstName) group(name)');
        } else if (this.sObjectApiName == 'Lead' && field.fieldApiName == 'LastName') {
            setDefinition(field.fieldName, null, true, false,
                'random type(lastName) group(name)');
        } else if (this.sObjectApiName == 'Opportunity' && field.fieldApiName == 'Name') {
            setDefinition(field.fieldName, null, true, false,
                'static value(Opportunity-)');
            setDefinition(field.fieldName, null, true, false,
                'serial type(number) from(1) step(1) scale(0)');
        } else if (field.dataType == Schema.DisplayType.INTEGER) {
            setDefinition(field.fieldName, null, true, false,
                'random type(number) from(1) to(100) scale(0)');
        } else if (field.dataType == Schema.DisplayType.CURRENCY) {
            setDefinition(field.fieldName, null, true, false,
                'random type(number) from(1000) to(10000) scale(2)');
        } else if (field.dataType == Schema.DisplayType.DOUBLE) {
            setDefinition(field.fieldName, null, true, false,
                'random type(number) from(1000) to(10000) scale(3)');
        } else if (field.dataType == Schema.DisplayType.DATE) {
            Integer thisYear = Date.today().year();
            String fromDate = String.valueOf(thisYear - 1) + '-01-01';
            String toDate = String.valueOf(thisYear + 1) + '-12-31';
            setDefinition(field.fieldName, null, true, false,
                'random type(date) from(' + fromDate + ') to(' + toDate + ')');
        } else if (field.dataType == Schema.DisplayType.DATETIME) {
            Integer thisYear = Date.today().year();
            String fromDate = String.valueOf(thisYear - 1) + '-01-01';
            String toDate = String.valueOf(thisYear + 1) + '-12-31';
            setDefinition(field.fieldName, null, true, false,
                'random type(datetime) from(' + fromDate + ') to(' + toDate + ')');
        } else if (field.dataType == Schema.DisplayType.TIME) {
            setDefinition(field.fieldName, null, true, false,
                'random type(time) from(00:00:00) to(23:59:59)');
        } else if (
            field.dataType == Schema.DisplayType.PICKLIST ||
                field.dataType == Schema.DisplayType.MULTIPICKLIST ||
                field.dataType == Schema.DisplayType.COMBOBOX) {
            setDefinition(field.fieldName, null, true, false,
                'random type(picklist)');
        } else if (field.dataType == Schema.DisplayType.STRING) {
            Integer minlength = (field.length < 5) ? field.length : 5;
            setDefinition(field.fieldName, null, true, false,
                'random type(string) minLength(' + minlength + ') maxLength(' +
                    field.length + ') startWith(upper) include(lower,upper)');
        } else if (field.dataType == Schema.DisplayType.TEXTAREA) {
            setDefinition(field.fieldName, null, true, false,
                'random type(text) minLength(30) maxLength(100)');
        } else if (field.dataType == Schema.DisplayType.PERCENT) {
            setDefinition(field.fieldName, null, true, false,
                'random type(number) from(0) to(100) scale(2)');
        } else if (field.dataType == Schema.DisplayType.REFERENCE) {
            setDefinition(field.fieldName, null, true, false,
                'random lookup(' + field.parents[0] + ') source(' + ForceeaService.SOURCE_FORCEEA + ')');
        } else if (field.dataType == Schema.DisplayType.BOOLEAN) {
            setDefinition(field.fieldName, null, true, false,
                'random type(boolean)');
        } else if (field.dataType == Schema.DisplayType.EMAIL) {
            setDefinition(field.fieldName, null, true, false,
                'random type(email)');
        } else if (field.dataType == Schema.DisplayType.PHONE) {
            setDefinition(field.fieldName, null, true, false,
                'random type(phone) format(DD dDD dd-DD-DDD)');
        } else if (field.dataType == Schema.DisplayType.URL) {
            setDefinition(field.fieldName, null, true, false,
                'random type(url)');
        }
    }

    /**
     * @description Sets the required fields.
     */
    private void setDefinitionOfRequiredFields() {
        if (FObject.isGlobalMocking) {
            String fieldName = ForceeaService.getFieldApiNameFromKey(this.sObjectApiName, 'Id', null);
            this.fields.add(fieldName);
            ForceeaDefinition def = new ForceeaDefinition(
                this, this.sObjectApiName, fieldName, fieldName, false, false, 'mock type(id)');
            this.definitions.add(def);
        }

        if (!this.requiredFieldsShouldBeAutomaticallyConfigured) {
            return;
        }
        setFields();
        handleInitializationOfRequiredFields();

        if (this.sObjectApiName.equalsIgnoreCase('user')) {
            setDefinitionsOfRequiredFieldsForUser();
        } else {
            setDefinitionsOfRequiredFieldsForSObjectsExceptUser();
        }

        if (this.requiredFieldNames.isEmpty()) {
            forceeaDebug(ForceeaService.INFO, 'Found no required fields');
        }
    }

    /**
     * @description Sets if each definition is a function-x.
     */
    private void setDefinitionsAsFunctions() {
        for (ForceeaDefinition def : this.definitions) {
            if (def.definitionString.left(8).equalsIgnoreCase('function')) {
                def.isFunction = true;
            }
        }
    }

    /**
     * @description Declares the definitions of required fields for all SObjects except User.
     */
    private void setDefinitionsOfRequiredFieldsForSObjectsExceptUser() {
        for (ForceeaFieldInfo field : FObject.globalFieldsMapBySObject.get(this.sObjectApiName.toLowerCase()).values()) {
            String fieldApiName = field.fieldApiName;
            if (field.isRequired && (!this.fields.contains(fieldApiName))) {
                setDefinitionFromField(field);
                this.requiredFieldNames.add(fieldApiName);
                forceeaDebug(ForceeaService.DEBUG, SYMBOL_SUCCESS + ' ' + ForceeaService.MESSAGE_GENERATED_DEFINITION +
                    ' of [' + fieldApiName + ']');
            }
        }
    }

    /**
     * @description Declares the definitions of required fields for User.
     */
    private void setDefinitionsOfRequiredFieldsForUser() {
        List<String> requiredDefinitions = new List<String>();

        this.requiredFieldNames.add('Alias');
        requiredDefinitions.add('random type(string) minLength(8) maxLength(8) startWith(upper) include(lower)');

        this.requiredFieldNames.add('FirstName');
        requiredDefinitions.add('random type(firstName) group(name)');

        this.requiredFieldNames.add('LastName');
        requiredDefinitions.add('random type(lastName) group(name)');

        this.requiredFieldNames.add('Username');
        requiredDefinitions.add('random type(email)');

        this.requiredFieldNames.add('Email');
        requiredDefinitions.add('copy field(Username)');

        this.requiredFieldNames.add('EmailEncodingKey');
        requiredDefinitions.add('static value(UTF-8)');

        this.requiredFieldNames.add('TimeZoneSidKey');
        requiredDefinitions.add('static value(GMT)');

        this.requiredFieldNames.add('LocaleSidKey');
        requiredDefinitions.add('static value(en_US)');

        this.requiredFieldNames.add('LanguageLocaleKey');
        requiredDefinitions.add('static value(en_US)');

        this.requiredFieldNames.add('ProfileId');
        requiredDefinitions.add('static lookup(profile) field(name) value(Standard User) source(salesforce)');

        for (Integer counter = 0; counter < this.requiredFieldNames.size(); counter++) {
            String fieldName = this.requiredFieldNames.get(counter);
            if (!this.fields.contains(fieldName)) {
                setDefinition(fieldName, null, true, false, requiredDefinitions.get(counter));
                forceeaDebug(ForceeaService.DEBUG,
                    SYMBOL_SUCCESS + ' ' + ForceeaService.MESSAGE_GENERATED_DEFINITION + ' of [' + fieldName + ']');
            }
        }
    }

    /**
     * @description Defines if Forceea will optimized the DML operation when inserting records from a Template.
     * @param isOptimized If true, the DML operation will be optimized for Templates.
     */
    public static void setDmlOptimizer(Boolean isOptimized) {
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
    public static void setExceptionHandling(String mode) {
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
     * @description Sets the controlling fields' definition
     */
    private void setFieldDependency() {
        if (!FObject.processIsValid) {
            return;
        }

        Integer controllingFieldPosition = -1;
        String controllingFieldApiName = '';
        String dependentFieldApiName = '';
        Integer dependentFieldPosition = -1;
        ForceeaFieldInfo field = new ForceeaFieldInfo(); // the field details of the dependent field

        List<ForceeaDefinition> existingDefinitions = new List<ForceeaDefinition>(this.definitions);
        for (ForceeaDefinition def : existingDefinitions) {
            if (def.isVirtualField || this.isUpdate) {
                continue;
            }

            dependentFieldApiName = def.fieldApiName;
            field = ForceeaService.getField(this.sObjectApiName, dependentFieldApiName);

            if (fieldHasControllingField(field)) {
                continue;
            } else {
                controllingFieldApiName = field.controllingFieldApiName;
            }

            // the (dependent) field has a controlling field and it respects field dependencies
            controllingFieldApiName = ForceeaService.getFieldApiNameFromKey(
                this.sObjectApiName, controllingFieldApiName, null);
            Schema.DisplayType controllingFieldType =
                ForceeaService.getField(this.sObjectApiName, controllingFieldApiName).dataType;

            // check the controlling field data type
            if (controllingFieldType == Schema.DisplayType.PICKLIST || controllingFieldType == Schema.DisplayType.MULTIPICKLIST) {
                // get the position of dependent/controlling field definitions
                dependentFieldPosition = this.fields.indexOf(dependentFieldApiName);
                controllingFieldPosition = this.fields.indexOf(controllingFieldApiName);
            } else if (controllingFieldType == Schema.DisplayType.BOOLEAN) {
                forceeaDebug(ForceeaService.WARN, 'The Checkbox field type is not supported ' +
                    'for the controlling field of dependent field [' + dependentFieldApiName + ']');
                continue;
            }

            if (controllingFieldPosition == -1) { // controlling field is not defined
                // create a new definition for the controlling field, before the definition of the dependent field
                forceeaDebug(ForceeaService.INFO, 'Did not find a definition for the controlling field [' +
                    controllingFieldApiName + '] of dependent field [' + dependentFieldApiName + '] and will generate a definition');
                setDefinition(controllingFieldApiName, null, true, this.isUpdate, 'random type(picklist)');
            }
            upsertFieldBeforePosition(controllingFieldApiName, dependentFieldApiName, dependentFieldPosition);
        }

        validateDefinitions();
    }

    /**
     * @description Populates the globalFieldsMapBySObject map.
     */
    private void setFields() {
        if (this.hasSchemaOfAllFields) {
            return;
        }

        Map<String, ForceeaFieldInfo> fieldInfosByName = new Map<String, ForceeaFieldInfo>();
        for (Schema.SObjectField sof : ForceeaService.getSObjectFieldsByName(this.sObjectApiName).values()) {
            ForceeaFieldInfo ForceeaFieldInfo = FObject.getFieldInfoFromSObjectField(sof);
            String key = ForceeaFieldInfo.fieldApiName.toLowerCase();
            if (!fieldInfosByName.containsKey(key)) {
                fieldInfosByName.put(key, ForceeaFieldInfo);
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
        FObject.numRecordsToCreate = defaultCustomSettings.RecordsToCreate__c.intValue();
        FObject.numRecordsToDisplay = defaultCustomSettings.RecordsToDisplay__c.intValue();
        FObject.numMaxErrorRecordsToDisplay = defaultCustomSettings.MaxErrorRecordsToDisplay__c.intValue();
        FObject.userMessage = defaultCustomSettings.UserMessage__c;
        FObject.setForceeaValidSettings();
    }

    private static void setForceeaValidSettings() {
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
    public static void setGlobalLanguage(String language) {
        FObject.language = language.trim();
    }

    /**
     * @description Sets the locality at the class level.
     * @param locality The language for all FObject instances.
     */
    public static void setGlobalLocality(String locality) {
        FObject.locality = locality.trim();
    }

    /**
     * @description Defines the ID mocking for all records.
     * @param isMocked If true, Forceea sets ID mocking for all FObjects.
     */
    public static void setGlobalMocking(Boolean isMocked) {
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

        FObject.cpuTimeOfGlobalSetup = Limits.getCpuTime();
    }

    /**
     * @description Sets the global SOQL query LIMIT.
     * @param queryLimit The SOQL query LIMIT for all FObject instances.
     */
    public static void setGlobalQueryLimit(Integer queryLimit) {
        FObject.globalQueryLimit = FObject.getValidatedQueryLimit(queryLimit);
    }

    /**
     * @description Sets a variable.
     * @param name The variable name.
     * @param value The variable value.
     */
    public static void setGlobalVariable(String name, Boolean value) {
        FObject.globalVariables.add(new ForceeaVariable(name, value, true));
    }
    public static void setGlobalVariable(String name, Date value) {
        FObject.globalVariables.add(new ForceeaVariable(name, value, true));
    }
    public static void setGlobalVariable(String name, Datetime value) {
        FObject.globalVariables.add(new ForceeaVariable(name, value, true));
    }
    public static void setGlobalVariable(String name, Decimal value) {
        FObject.globalVariables.add(new ForceeaVariable(name, value, true));
    }
    public static void setGlobalVariable(String name, Integer value) {
        FObject.globalVariables.add(new ForceeaVariable(name, value, true));
    }
    public static void setGlobalVariable(String name, String value) {
        FObject.globalVariables.add(new ForceeaVariable(name, value, true));
    }

    /**
     * @description Sets the verbose mode at the class level.
     * @param verboseMode The verbose mode (none, info, debug).
     */
    public static void setGlobalVerbose(String verboseMode) {
        verboseMode = verboseMode.toLowerCase().trim();

        if (verboseMode == 'none') {
            FObject.globalVerboseMode = VerboseLevel.VERBOSE_NONE;
        } else if (verboseMode == 'debug') {
            FObject.globalVerboseMode = VerboseLevel.VERBOSE_DEBUG;
        } if (verboseMode == 'info') {
            FObject.globalVerboseMode = VerboseLevel.VERBOSE_INFO;
        }
    }

    /**
     * @description Stores the SObject's group, which will be used when inserting records.
     * @param groupName The group name.
     * @return An FObject instance.
     */
    public FObject setGroupName(String groupName) {
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
    public FObject setIndexFields(Set<String> indexFields) {
        List<String> indexFieldsList = new List<String>(indexFields);
        String fieldsString = String.join(indexFieldsList, ',');
        return setIndexFields(fieldsString);
    }

    /**
     * @description Sets the index fields from a string of comma-separated fields.
     * @param indexFieldsString The comma-separated string of index fields.
     * @return An FObject instance.
     */
    public FObject setIndexFields(String indexFieldsString) {
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
        this.isMocking = false;
        this.isUpdate = false;
        this.mustCreateNewRecords = true;
        this.numValidatedDefinitions = 0;
        this.processHasPermutations = false;
        this.queryLimit = FObject.globalQueryLimit;
        this.requiredFieldsShouldBeAutomaticallyConfigured = false;
        this.sObjType = ForceeaService.getSObjectType(this.sObjectApiName);
        this.virtualFieldForStandardPriceBookEntries = '';
    }

    /**
     * @description Sets the number of the first record to be created for serial values.
     * @param numberOfNextRecord The number of the next record.
     * @return An FObject instance.
     */
    public FObject setNumberOfNextRecord(Integer numberOfNextRecord) {
        this.numNextRecord = (numberOfNextRecord <= 0) ? 1 : numberOfNextRecord;
        FObject.numFirstRecordsBySObject.put(this.sObjectApiName, this.numNextRecord);

        return this;
    }

    /**
     * @description Sets the number of records.
     * @param numberOfRecords The number of records.
     * @return An FObject instance.
     */
    public FObject setNumberOfRecords(Integer numberOfRecords) {
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
    public FObject setNumberOfRecords(String generationMode) {
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
    public FObject setPartitionFieldName(Schema.SObjectField sObjectFieldName) {
        this.partitionFieldName = sObjectFieldName.getDescribe().getName();
        return this;
    }

    /**
     * @description Sets the lists for calculating permutations.
     */
    private void setPermutationValues() { // TODO set for update
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
    public FObject setProcessValid(Boolean isValid) {
        FObject.processIsValid = isValid;
        return this;
    }

    /**
     * @description Sets the SOQL query LIMIT.
     * @param queryLimit The LIMIT.
     * @return An FObject instance.
     */
    public FObject setQueryLimit(Integer queryLimit) {
        this.queryLimit = FObject.getValidatedQueryLimit(queryLimit);
        return this;
    }

    /**
     * @description Amend the records to update with the new field values.
     */
    private void setRecordsToUpdateWithNewFieldValues() {
        forceeaDebug(ForceeaService.DEBUG, MESSAGE_WILL_UPDATE_FIELD_VALUES + ' of [' + this.sObjectApiName + ']');

        for (Integer counter = 0; counter < this.recordsToUpdate.size(); counter++) {
            SObject recordWithUpdatedValues = getRecord(counter);
            if (!FObject.processIsValid) {
                break;
            }

            SObject recordToUpdate = this.recordsToUpdate.get(counter);
            Map<String, Object> populatedFieldsByName = recordWithUpdatedValues.getPopulatedFieldsAsMap();

            Integer numUpdatedFields = 0;
            for (String fieldName : populatedFieldsByName.keySet()) {
                Object fieldValue = populatedFieldsByName.get(fieldName);
                recordToUpdate.put(fieldName, fieldValue);
                numUpdatedFields++;
            }

            if (numUpdatedFields > 0) {
                this.numUpdatedRecords++;
            }
        }
    }

    /**
     * @description Set Record Types.
     */
    private void setRecordTypes() {
        if (this.isBigObject)
        {
            return;
        }

        if (!FObject.recordTypeInfosBySObject.containsKey(this.sObjType)) {
            List<Schema.RecordTypeInfo> rtInfos = new List<Schema.RecordTypeInfo>();
            for (Schema.RecordTypeInfo rti : this.sObjType.getDescribe().getRecordTypeInfos()) {
                if (!rti.isMaster() && rti.isActive()) {
                    rtInfos.add(rti);
                }
            }
            FObject.recordTypeInfosBySObject.put(this.sObjType, rtInfos);
        }

        for (Schema.RecordTypeInfo rti : FObject.recordTypeInfosBySObject.get(this.sObjType)) {
            this.recordTypeIdsByDeveloperName.put(rti.getDeveloperName().toLowerCase(), rti.getRecordTypeId());
        }
    }

    /**
     * @description Sets if Forceea should define the required fields.
     * @param fieldsAreRequired If true, Forceea automatically defines the required fields.
     * @return An FObject instance.
     */
    public FObject setRequiredFields(Boolean fieldsAreRequired) {
        this.requiredFieldsShouldBeAutomaticallyConfigured = fieldsAreRequired;
        return this;
    }

    /**
     * @description Sets the PRNG seed.
     */
    public static void setSeed(Long seedNumber) {
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
            }
            when DOUBLE {
                result.put(fieldName, Double.valueOf(fieldValue));
            }
            when CURRENCY {
                result.put(fieldName, Decimal.valueOf(fieldValue));
            }
            when BOOLEAN {
                result.put(fieldName, Boolean.valueOf(fieldValue));
            }
            when DATE {
                result.put(fieldName, Date.valueOf(fieldValue));
            }
            when PERCENT {
                result.put(fieldName, Decimal.valueOf(fieldValue));
            }
            when DATETIME {
                result.put(fieldName, Datetime.valueOf(fieldValue));
            }
            when INTEGER {
                result.put(fieldName, Integer.valueOf(fieldValue));
            }
            when TIME {
                Time valueTime;
                String thisYear = String.valueOf(Date.today().year());
                valueTime = Datetime.valueOf(thisYear + '-01-01 ' + fieldValue).time();
                result.put(fieldName, valueTime);
            }
            when BASE64 {
                result.put(fieldName, Blob.valueOf(fieldValue));
            }
            when else { // any other type
                result.put(fieldName, fieldValue);
            }
        }
    }

    /**
     * @description Sets the source parameter for all related definitions.
     * @param source The new source (forceea or salesforce).
     * @return An FObject instance.
     */
    public FObject setSource(String source) {
        String sourceToValidate = source.toLowerCase().trim();

        if (ForceeaService.sourceIsValid(sourceToValidate)) {
            for (ForceeaDefinition def : this.definitions) {
                def.setNewSource(sourceToValidate);
            }
        }

        return this;
    }

    /**
     * @description Sets the source parameter for all related definitions.
     * @param sObjField The SObjectField.
     * @param source The new source (forceea or salesforce).
     * @return An FObject instance.
     */
    public FObject setSource(Schema.SObjectField sObjField, String source) {
        String fieldApiName = ForceeaService.getFieldApiName(
            this, '', this.sObjectApiName, '', sObjField, '', 'standard');
        for (ForceeaDefinition def : this.definitions) {
            def.setNewSource(fieldApiName, source);
        }

        return this;
    }

    /**
     * @description Inserts entries for the Standard Price Book using the values of a virtual field.
     * @param virtualFieldName The virtual field name.
     * @return An FObject instance.
     */
    public FObject setStandardPricebookEntries(String virtualFieldName) {
        if (!virtualFieldIsValid(virtualFieldName)) {
            addError(this.sObjectApiName, MESSAGE_INVALID_VIRTUAL_FIELD + ' [' +
                virtualFieldName.trim() + '] ' + MESSAGE_METHOD_SET_STANDARD_PRICEBOOK_ENTRIES);
            return this;
        }

        this.virtualFieldForStandardPriceBookEntries = virtualFieldName.trim();

        return this;
    }

    /**
     * @description Sets a variable.
     * @param name The variable name.
     * @param value The variable value.
     * @return An FObject instance.
     */
    public FObject setVariable(String name, Boolean value) {
        this.variables.add(new ForceeaVariable(name, value, false));
        return this;
    }
    public FObject setVariable(String name, Date value) {
        this.variables.add(new ForceeaVariable(name, value, false));
        return this;
    }
    public FObject setVariable(String name, Datetime value) {
        this.variables.add(new ForceeaVariable(name, value, false));
        return this;
    }
    public FObject setVariable(String name, Decimal value) {
        this.variables.add(new ForceeaVariable(name, value, false));
        return this;
    }
    public FObject setVariable(String name, Integer value) {
        this.variables.add(new ForceeaVariable(name, value, false));
        return this;
    }
    public FObject setVariable(String name, String value) {
        this.variables.add(new ForceeaVariable(name, value, false));
        return this;
    }

    /**
     * @description Sets the verbose mode at the instance level.
     * @param mode The verbose mode (none, info, debug).
     * @return An FObject instance.
     */
    public FObject setVerbose(String mode) {
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
     * @description Updates the fields of the recent records.
     * @return An instance of FObject.
     */
    public FObject updateFields() {
        return updateFields(null);
    }

    /**
     * @description Updates the fields of group records.
     * @return An instance of FObject.
     */
    public FObject updateFields(String groupName) {
        if (FObject.processMustTerminate()) {
            return this;
        }
        onBeforeUpdateFields();
        handleRecordsWithUpdatedValues(groupName);
        onAfterUpdateFields(groupName);

        return this;
    }

    /**
     * @description Updates the created records.
     * @param allOrNone Specifies whether the operation allows partial success. If you specify false
     *   for this parameter and a record fails, the remainder of the DML operation can still succeed.
     * @return A list of Database.SaveResult objects.
     */
    public List<Database.SaveResult> updateRecords(Boolean allOrNone) {
        List<Database.SaveResult> results = new List<Database.SaveResult>();
        if (FObject.processMustTerminate() || allOrNone == null) {
            return results;
        }

        onBeforeUpdateRecords();
        handleRecordsOnUpdate(allOrNone);
        results = new List<Database.SaveResult>(this.saveResults);
        onAfterRecordsUpdate();

        return results;
    }

    /**
     * @description Inserts or moves a controlling field before a dependent field.
     *   If the field exists, it is moved before the position.
	 *   If it doesn't exist, it is inserted before the position.
	 * @param controllingFieldApiName The controlling field API name.
	 * @param dependentFieldApiName The dependent field API name.
	 * @param dependentFieldPosition The dependent field position.
	 */
    private void upsertFieldBeforePosition(
        String controllingFieldApiName, String dependentFieldApiName, Integer dependentFieldPosition) {
        Boolean mustAddControllingField = false;
        List<String> fields = getFieldsToProcess();

        if (fields.contains(controllingFieldApiName)) {
            Integer fieldPosition = fields.indexOf(controllingFieldApiName);
            if (dependentFieldPosition < fieldPosition) { // field must be moved
                fields.remove(fieldPosition);
                mustAddControllingField = true;
                forceeaDebug(ForceeaService.INFO, 'Moved definition of controlling field [' +
                    controllingFieldApiName + '] before definition of its dependent field [' + dependentFieldApiName + ']');
            }
        } else {
            mustAddControllingField = true;
        }

        if (mustAddControllingField) {
            if (dependentFieldPosition == 0) {
                addFieldInPosition(fields, controllingFieldApiName, 0);
            } else {
                addFieldInPosition(fields, controllingFieldApiName, dependentFieldPosition - 1);
            }
        }
    }

    /**
     * @description Validates the user-defined and system-defined definitions.
     */
    public void validateDefinitions() {
        if (this.definitionsAreValidated) {
            return;
        }

        if (this.definitions.isEmpty()) {
            forceeaDebug(ForceeaService.DEBUG, 'Found no definitions to validate.');
            return;
        }
        forceeaDebug(ForceeaService.DEBUG, MESSAGE_WILL_VALIDATE_FIELD_DEFINITIONS + ' of [' + this.sObjectApiName + ']');
        setDefinitionsAsFunctions();

        this.numValidatedDefinitions = 0;
        for (ForceeaDefinition def : this.definitions) {
            if (def.isValidated) {
                continue;
            }

            parseDefinition(def);

            this.numValidatedDefinitions++;
            if (!def.isValid()) {
                continue;
            }

            def.validate();

            if (def.isValid()) {
                forceeaDebug(ForceeaService.DEBUG, SYMBOL_SUCCESS + ' Definition [' + def.definitionString +
                    '] of [' + def.fieldApiName + '] is valid with ID [' + def.definitionId + ']');
            }
        }

        this.definitionsAreValidated = true;
        setFieldDependency();
    }

    /**
	* @description Validates the field definitions when updating field values.
	*/
    private void validateDefinitionsOnUpdate() {
        validateDefinitions();

        if (this.numValidatedDefinitions > 0) {
            resetMilestoneTimer('Validated definitions');
        }
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
