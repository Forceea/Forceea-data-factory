/*
  Forceea data factory (v2.0.0)
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

/**
 * @description Forceea data factory
 */
public with sharing class FObject {

    /* CONSTANTS */

    // various
    private static final Integer BAR_LENGTH = 60;
    private static final String BAR_SYMBOL = '.';
    private static final String DEBUG_LOG_PROMPT = 'FORCEEA ';
    @TestVisible private static final Integer DEFAULT_QUERY_LIMIT = 1000;
    private static final String SOURCE_FORCEEA = 'forceea';
    private static final String SOURCE_SALESFORCE = 'salesforce';
    private static final String SYMBOL_FAILURE = '*';
    private static final String SYMBOL_MILESTONE = '>>';
    private static final String SYMBOL_SUCCESS = '-';
    private static final VerboseLevel VERBOSE_MODE = VerboseLevel.VERBOSE_NONE;
    private static final String VERSION = '2.0.0';
    // messages
    private static final String MESSAGE_ADDRESSES = 'Loaded addresses from ';
    private static final String MESSAGE_FOUND_ERRORS_SELECTING_FROM_LOOKUP =
        'Found errors selecting records from the lookup SObject';
    private static final String MESSAGE_GENERATED_DEFINITION = 'Generated definition of';
    private static final String MESSAGE_INVALID_PROCESS = 'Process is invalid and will terminate';
    private static final String MESSAGE_NAMES = 'Loaded first & last names from ';
    private static final String MESSAGE_WILL_CREATE_FIELD_VALUES = 'Will create the field values';
    private static final String MESSAGE_WILL_CREATE_UPDATED_FIELD_VALUES = 'Will create the updated field values';
    private static final String MESSAGE_WILL_DELETE_ALL_FIELDS_DEFINITIONS = 'Will delete the definitions of all fields';
    private static final String MESSAGE_WILL_DELETE_FIELD_DEFINITIONS = 'Will delete the definitions of field';
    private static final String MESSAGE_WILL_DELETE_RECORDS = 'Will delete records';
    private static final String MESSAGE_WILL_DISPLAY_CREATED_FIELD_VALUES = 'Will display the created field values';
    private static final String MESSAGE_WILL_INSERT_CREATED_RECORDS = 'Will insert the created records';
    private static final String MESSAGE_WILL_NOT_INSERT_RECORDS = 'Will not insert records';
    private static final String MESSAGE_WILL_NOT_SET_DEFINITIONS_OF_REQUIRED_FIELDS =
        'Will not set the definition of required fields';
    private static final String MESSAGE_WILL_SET_DEFINITIONS_OF_REQUIRED_FIELDS =
        'Will set the definition of required fields';
    private static final String MESSAGE_WILL_STORE_CREATED_RECORDS = 'Will store the created records with mocked IDs';
    private static final String MESSAGE_WILL_UPDATE_RECORDS = 'Will update the records';
    private static final String MESSAGE_WILL_VALIDATE_FIELD_DEFINITIONS = 'Will validate the field definitions';
    // debugging
    private static final String DEBUG = 'debug';
    private static final String ERROR = 'error';
    private static final String INFO = 'info';
    private static final String WARN = 'warn';

    /* ENUMS */

    private enum DefinitionTypeId {
        RANDOM_STRING, RANDOM_TEXT, RANDOM_NUMBER, RANDOM_PHONE,
        RANDOM_DATE, RANDOM_DATETIME,
        RANDOM_PICKLIST, RANDOM_PICKLIST_EXCEPT,
        RANDOM_LIST_INTEGER, RANDOM_LIST_DECIMAL, RANDOM_LIST_STRING,
        RANDOM_LIST_DATE, RANDOM_LIST_DATETIME, RANDOM_LIST_TIME,
        RANDOM_STREET, RANDOM_CITY, RANDOM_STATE, RANDOM_POSTALCODE, RANDOM_COUNTRY,
        RANDOM_EMAIL, RANDOM_BOOLEAN, RANDOM_URL, RANDOM_FIRSTNAME, RANDOM_LASTNAME,
        RANDOM_LOOKUP, RANDOM_LOOKUP_WHERE,
        STATIC_INTEGER, STATIC_DECIMAL, STATIC_DATE, STATIC_DATETIME, STATIC_TIME, STATIC_STRING, STATIC_LOOKUP,
        SERIAL_NUMBER, SERIAL_DATE, SERIAL_DATETIME, SERIAL_LOOKUP,
        COPY_FIELD, COPY_LOOKUP,
        MOCK_ID
    }
    private enum ValueType {
        TYPE_INTEGER, TYPE_DECIMAL, TYPE_STRING, TYPE_DATE, TYPE_DATETIME, TYPE_TIME, TYPE_URL
    }
    private enum VerboseLevel {
        VERBOSE_NONE, VERBOSE_DEBUG, VERBOSE_INFO
    }

    /* STATIC COLLECTIONS */

    // the library of addresses
    @TestVisible
    private static List<FAddress> addressesLibrary = new List<FAddress>();
    // the valid script commands
    private static List<String> commands = new List<String>{
        'copy', 'random', 'static', 'serial', 'mock'
    };
    // the defined cluster types
    private static List<DefinitionType> definitionTypes = new List<DefinitionType>();
    // the libraries for first names - key: gender, value: first names
    private static Map<String, List<String>> firstNamesLibraryMap = new Map<String, List<String>>();
    // the inserted records of all objects
    // key: objectApiName or objectApiName.groupName (lowercase), value: list of records
    private static Map<String, List<SObject>> globalInsertedRecordsMap = new Map<String, List<SObject>>();
    // the field details of each declared FObject
    // key: SObject API name (lowercase), value: (key:field API name (lowercase), value: Field)
    private static Map<String, Map<String, Field>> globalSObjectFieldsMap = new Map<String, Map<String, Field>>();
    // the libraries for last names - key: gender, value: last names
    private static Map<String, List<String>> lastNamesLibraryMap = new Map<String, List<String>>();
    // lookup types used in serial lookup
    private static Set<String> lookupModesSet = new Set<String>{
        'cyclical', 'first', 'last', 'null'
    };
    // the valid script parameters
    private static Set<String> parametersSet = new Set<String>{
        'scale', 'except', 'field', 'format', 'from', 'group', 'include', 'lookup', 'maxlength', 'minlength', 'mode',
        'number', 'source', 'startwith', 'step', 'to', 'type', 'value', 'where'
    };
    // the map with key: SObject Type and value: list of Record Type Infos
    private static Map<Schema.SObjectType, List<Schema.RecordTypeInfo>> rtInfosBySObject =
        new Map<Schema.SObjectType, List<Schema.RecordTypeInfo>>();
    // the API names of all sObjects
    private static List<String> sObjectApiNames = new List<String>();
    // the serializations map with key: SObject API name, value: next serialized record number
    public static Map<String, Integer> numFirstRecordsBySObject = new Map<String, Integer>();
    // the valid sources
    private static Set<String> sourcesSet = new Set<String>{
        SOURCE_FORCEEA, SOURCE_SALESFORCE
    };
    // the map of all sObject names (keys) to sObject tokens (values) for the standard and custom objects defined
    private static Map<String, Schema.SObjectType> globalDescribe {
        get {
            if (globalDescribe == null) {
                globalDescribe = Schema.getGlobalDescribe();
            }
            return globalDescribe;
        }
        set;
    }

    /* INSTANCE COLLECTIONS */

    // the addresses - key: address group, value: address
    private Map<String, List<FAddress>> addressesMap = new Map<String, List<FAddress>>();
    // the last created SObject records
    private List<SObject> createdRecords = new List<SObject>();
    // the declared field definitions
    public List<Definition> definitions = new List<Definition>();
    // the definition errors
    private List<Error> errors = new List<Error>();
    // the fields with declared definitions
    private List<String> fields = new List<String>();
    // the FVM, each List<string> contains a field's values
    private List<List<String>> fieldValuesMatrix = new List<List<String>>();
    // the inserted records
    private List<SObject> insertedRecords = new List<SObject>();
    // key: <blank> or groupName (lowercase), value: list of records
    private Map<String, List<SObject>> instanceInsertedRecordsMap = new Map<String, List<SObject>>();
    // the first & last names - key: name group, value: name
    private Map<String, List<Name>> namesMap = new Map<String, List<Name>>();
    // the list of products to insert a Standard Price Book entry
    List<Product2> productsToInsertPricebookEntries = new List<Product2>();
    // all SObject fields - key: field API name (lowercase), value: field object
    private Map<String, Field> sObjectFieldsMap = new Map<String, Field>();
    // the records to be inserted
    private List<SObject> recordsToInsert = new List<SObject>();
	// the records to be updated
	private List<SObject> recordsToUpdate =  new List<SObject>();
    // the record types of this SObject - key: DeveloperName, value: Id)
    private Map<String, Id> recordTypesMap = new Map<String, Id>();
    // the field API names of required fields
    private List<String> requiredFieldNames = new List<String>();
    // the save results list
    private List<Database.SaveResult> saveResults = new List<Database.SaveResult>();
	// the updated records
	private List<SObject> updatedRecords = new List<SObject>();

    /* STATIC VARIABLES & PROPERTIES */

    // the CPU time for the global setup
    private static Integer cpuTimeOfGlobalSetup { get; set; }
    // if true, the Exception error message has been displayed
    private static Boolean exceptionErrorMessageIsDisplayed { get; set; }
    // the default SOQL query LIMIT
    private static Integer globalQueryLimit { get; set; }
    // if true, if the initialization message has been displayed
    private static Boolean initializationMessageIsDisplayed { get; set; }
    // if true, Forceea creates records with mocked IDs
    private static Boolean isGlobalMocking { get; set; }
    // if true, the process is asynchronous
    private static Boolean isAsync { get; set; }
    // if true, the process is asynchronous
    private static Boolean isOnValidation { get; set; }
    // the language in name fields and addresses
    public static String language {
        get;
        set {
            resetLanguageLocality();
            language = value;
        }
    }
    // the locality in name fields and addresses
    public static String locality {
        get;
        set {
            resetLanguageLocality();
            locality = value;
        }
    }
    // the level of verbose mode
    private static VerboseLevel globalVerboseMode { get; set; }
    // the serial number for the mocked IDs
    private static Integer mockingSerialNumber { get; set; }
    // the default number of records to create
    private static Integer numDefaultRecords { get; set; }
    // the maximum number of error records to display
    private static Integer numMaxErrorRecordsToDisplay { get; set; }
    // the number of created records to display
    private static Integer numRecordsToDisplay { get; set; }
    // if true, the process has no errors (valid)
    public static Boolean processIsValid { get; private set; }
    // a pseudorandom number that is greater than or equal to 0 and less than 1
    // DeviousBard https://github.com/DeviousBard/Salesforce
    private static Double random {
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
    // if true, it displays messages in Debug Log
    @TestVisible private static Boolean showDebugLog { get; set; }
    // if true, the street number is after street, e.g. Abcd 12
    private static Boolean streetNumberGoesAfterStreet { get; set; }
    // the message to display when initializing the FObject
    private static String userMessage { get; set; }

    /* INSTANCE VARIABLES & PROPERTIES */

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
    // exclude the lookup records with IsActive = false
    public Boolean excludeInactiveLookupRecords { get; set; }
    // the group that will be used when inserting records for this FObject
    private String groupName { get; set; }
    // if true, the process updates fields
    private Boolean isFieldsUpdate { get; set; }
    // if true, the process inserts records
    private Boolean isInsert { get; set; }
    // if true, the IDs are mocked
    private Boolean isMocking { get; set; }
    // if true, the process updates records
    private Boolean isRecordsUpdate { get; set; }
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
    // the number of inserted records
    private Integer numInsertedRecords { get; set; }
    // the number of updated records
    @TestVisible private Integer numUpdatedRecords { get; set; }
    // the number of validated definitions
    Integer numValidatedDefinitions { get; set; }
    // the partition field for async processing
    private String partitionFieldName { get; set; }
    // the SOQL query LIMIT
    @TestVisible private Integer queryLimit { get; set; }
    // the number of records to create
    public Integer records { get; set; }
    // if true, Forceea sets all required fields
    private Boolean requiredFieldsMustBeSet { get; set; }
    // if true, Forceea will set required fields
    public Boolean setRequiredFields {
        get;
        set {
            this.requiredFieldsMustBeSet = value;
        }
    }
    // the SObject API name
    private String sObjectApiName { get; set; }
    // the user-defined SObject name
    private String sObjectName { get; set; }
    // the SObject type
    private Schema.SObjectType sObjType { get; set; }
    // the level of verbose mode
    private VerboseLevel verboseMode { get; set; }
    // the name of the virtual field for getting the values of Standard Price Book entries
    private String virtualFieldForStandardPriceBookEntries { get; set; }
    // if true, Forceea displayed the message that validated the field definitions of an SObject
    private Boolean willValidateFieldDefinitionsMessageIsDisplayed { get; set; }

    /* CLASSES */

    /**
       * @description A definition cluster <cluster> ::= <parameter>(<argument[,...n]>).
       */
    private class Cluster {
        String parameter { get; set; }
        List<String> arguments = new List<String>();

        private Cluster(String parameter, List<String> arguments) {
            this.parameter = parameter;
            this.arguments = new List<String>(arguments);
        }
    }

    /**
       * @description A template for a valid cluster.
       *   Cluster Types are defined in static method setDefinitionTypes.
       */
    private class ClusterType {
        String parameter { get; set; } // the parameter, e.g. type
        ValueType valueType { get; set; } // the type of the parameter value, e.g. TYPE_DECIMAL or TYPE_STRING
        String value { get; set; } // the value of the parameter, e.g. street or 10
        Boolean allowsMultipleArguments { get; set; } // true if the value allows multiple arguments

        private ClusterType(String parameter, ValueType valueType, String value, Boolean allowsMultipleArguments) {
            this.parameter = parameter;
            this.valueType = valueType;
            this.value = value;
            this.allowsMultipleArguments = allowsMultipleArguments;
        }
    }

    /**
     * @description A field definition, <definition> ::= <command> <script>, <script> ::= <cluster>[,...n].
     */
    public class Definition {
        String fieldName { get; set; } // the user-defined field name
        public String fieldApiName { get; set; }
        public String definitionString { get; set; } // the user-defined field definition
        public String command { get; set; } // the definition command
        String script { get; set; } // the definition script
        Boolean isForUpdate { get; set; } // if true, the definition is valid for record updates
        Boolean isSystemDeclared { get; set; } // false: declared by user, true: declared by Forceea
        Boolean isValid { get; set; } // the definition is valid
        Boolean isValidated { get; set; } // the definition has been validated
        Boolean hasValidFieldDataType { get; set; } // the definition field data type is valid
        Boolean hasRestrictedPicklistValues { get; set; } // the definition restricts the created picklist values to existing values
        DefinitionType type { get; set; } // the type of the definition
        List<Cluster> clusters = new List<Cluster>(); // the list of clusters of the definition

        private Definition(
            String fieldName, String fieldApiName, Boolean isSystemDeclared, Boolean isForUpdate, String definitionString) {
            this.fieldName = fieldName;
            this.fieldApiName = fieldApiName;
            this.definitionString = definitionString;
            this.command = '';
            this.script = '';
            this.isForUpdate = isForUpdate;
            this.isSystemDeclared = isSystemDeclared;
            if (isSystemDeclared) {
                this.isValid = true;
            } else {
                this.isValid = false;
            }
            this.isValidated = false;
            this.hasValidFieldDataType = true;
            this.hasRestrictedPicklistValues = false;
            this.type = new DefinitionType();
        }
    }

    /**
     * @description A template for a valid definition.
     */
    private class DefinitionType {
        DefinitionTypeId id { get; set; } // e.g. RANDOM_STREET
        String description { get; set; } // e.g. RandomStreet
        String command { get; set; } // e.g. random
        List<ClusterType> clusterTypes = new List<ClusterType>();

        private DefinitionType(DefinitionTypeId id, String description, String command) {
            this.id = id;
            this.description = description;
            this.command = command;
        }

        private DefinitionType() {
            this.id = null;
            this.description = null;
            this.command = null;
        }
    }

    /**
     * @description An error message.
     */
    private class Error {
        String id { get; set; }
        String errorMessage { get; set; }

        private Error(String errorId, String errorMessage) {
            this.id = errorId;
            this.errorMessage = errorMessage;
        }
    }

    /**
     * @description An address object.
     */
    @TestVisible
    private class FAddress {
        @TestVisible String street { get; set; }
        @TestVisible String postalCode { get; set; }
        @TestVisible String city { get; set; }
        @TestVisible String state { get; set; }
        @TestVisible String country { get; set; }

        private FAddress(String street, String postalCode, String city, String state, String country) {
            this.street = street;
            this.city = city;
            this.postalCode = postalCode;
            this.state = state;
            this.country = country;
        }

        private FAddress(FAddress address) {
            this.street = address.street;
            this.city = address.city;
            this.postalCode = address.postalCode;
            this.state = address.state;
            this.country = address.country;
        }
    }

    /**
     * @description A Field object.
     */
    @TestVisible
    private class Field {
        private Boolean allowsMultipleDefinitions { get; set; }
        private Boolean canHaveMultipleTypesAsParents { get; set; }
        private String controllingFieldApiName { get; set; } // the API name of the controlling picklist field
        public Schema.DisplayType dataType { get; set; }
        public String fieldApiName { get; set; } // the field API name
        public String fieldName { get; set; } // the field API name in lowercase
        public Boolean isAccessible { get; set; } // the current user can see this field
        public Boolean isCreateable { get; set; } // can be created by the current user
        private Boolean isRequired { get; set; } // is required when inserting/updating a record
        private Boolean isRestrictedPicklist { get; set; }
        private String label { get; set; } // the text label that is displayed next to the field in the user interface
        public Integer length { get; set; } // for string fields, the maximum size
        public List<Schema.SObjectType> parents = new List<Schema.SObjectType>();
        private List<Schema.PicklistEntry> picklistValues = new List<Schema.PicklistEntry>();
    }

    /**
     * @description The exception handler class.
     */
    private class FObjectException extends Exception {
    }

    /**
     * @description A Name object.
     */
    private class Name {
        String FirstName { get; set; }
        String LastName { get; set; }
        String Gender { get; set; }

        private Name() {
            this.FirstName = '';
            this.LastName = '';
            this.Gender = '';
        }

        private Name(String firstName, String lastName, String gender) {
            this.FirstName = firstName;
            this.LastName = lastName;
            this.Gender = gender;
        }
    }

    /**
     * @description A picklist info object.
     */
    private class PicklistInfo {
        String validFor;
    }

    /* INITIALIZATION */

    // static initialization
    static {
        setFrameworkSettings();
        setDefinitionTypes();
        setSObjectApiNames();
        setGlobalProperties();
    }

    // instance initialization
    {
        this.milestoneStartTime = Limits.getCpuTime();
        this.cpuTimeStartOfObjectSetup = Limits.getCpuTime();
        this.canInsertUsers = false;
    }

    /* CONSTRUCTORS */

    public FObject(Schema.SObjectType sObjectType) {
        fObjectConstructor(sObjectType, null, 0);
    }

    public FObject(String sObjectName) {
        fObjectConstructor(null, sObjectName, 0);
    }

    public FObject(Schema.SObjectType sObjectType, Integer records) {
        fObjectConstructor(sObjectType, null, records);
    }

    public FObject(String sObjectName, Integer records) {
        fObjectConstructor(null, sObjectName, records);
    }

    private void fObjectConstructor(Schema.SObjectType sObjectType, String sObjectName, Integer numRecords) {
        String thisSObjectName = '';
        String sObjectApiName = '';

        if (sObjectType != null) {
            sObjectApiName = sObjectType.getDescribe().getName();
            thisSObjectName = sObjectApiName;
        } else if (sObjectName != null) {
            thisSObjectName = sObjectName.trim();
            String userSObjectName = thisSObjectName;
            sObjectApiName = FObject.getSObjectApiName(thisSObjectName);

            if (String.isBlank(sObjectApiName)) {
                FObject.processIsValid = false;
                addError(userSObjectName, 'Invalid SObject [' + userSObjectName + ']');
                if (processMustTerminate()) {
                    return;
                }
            }
        }

        this.sObjectApiName = sObjectApiName;
        this.sObjectName = thisSObjectName.toLowerCase();
        displayInitializationMessage();

        // validate the number of records
        if (numRecords < 0) {
            addError(sObjectApiName, 'Invalid number of records of [' + sObjectApiName + ']');
            if (processMustTerminate()) {
                return;
            }
        } else if (numRecords == 0) { // get the default records
            this.records = FObject.numDefaultRecords;
        } else {
            this.records = numRecords;
        }

        initializeNumFirstRecordsBySObject();
        setInstanceProperties();
        setRecordTypes();
        setSObjectFieldsMap();

        resetMilestoneTimer('Initialized settings of [' + this.sObjectApiName + ']');
    }

    /* METHODS */

    /**
     * @description Adds an error message to Errors list and posts message to Debug Log
     * @param errorId The error reference (e.g. the field or parameter which created the error)
     * @param errorMessage The error message.
     */
    private void addError(String errorId, String errorMessage) {
        this.errors.add(new Error(errorId, errorMessage));
        FObject.processIsValid = false;
        System.debug(LoggingLevel.ERROR, DEBUG_LOG_PROMPT + SYMBOL_FAILURE + ' ' + errorMessage + '.');
    }

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
     * @description Adds a list of PricebookEntry records to the global inserted map.
     * @param recordsToAdd The list of PricebookEntry records to add.
     */
    private void addPricebookEntriesToGlobalMap(List<SObject> recordsToAdd) {
        List<SObject> records = new List<SObject>();

        String key = 'pricebookentry.';
        if (FObject.globalInsertedRecordsMap.containsKey(key)) {
            records = FObject.globalInsertedRecordsMap.get(key);
        }

        records.addAll(recordsToAdd);
        FObject.globalInsertedRecordsMap.put(key, records);
    }

    /**
     * @description Adds the inserted records to the related maps of inserted records.
     */
    private void addRecordsToMapsOnInsert() {
        List<SObject> recordsToAdd = new List<SObject>(this.insertedRecords);
        String sObjectKey = this.sObjectApiName.toLowerCase();

        // instance global group
        String key = '';
        List<SObject> records = new List<SObject>();
        if (this.instanceInsertedRecordsMap.containsKey(key)) {
            records = this.instanceInsertedRecordsMap.get(key);
        }
        records.addAll(recordsToAdd);
        this.instanceInsertedRecordsMap.put(key, records);

	    // static global group
	    records = new List<SObject>();
	    key = sObjectKey + '.';
	    if (FObject.globalInsertedRecordsMap.containsKey(key)) {
		    records = FObject.globalInsertedRecordsMap.get(key);
	    }
	    records.addAll(recordsToAdd);
	    FObject.globalInsertedRecordsMap.put(key, records);

	    if (String.isNotBlank(this.groupName)) {
		    String groupKey = this.groupName.toLowerCase();

	        // instance group
		    records = new List<SObject>();
            key = groupKey;
		    if (this.instanceInsertedRecordsMap.containsKey(key)) {
			    records = this.instanceInsertedRecordsMap.get(key);
		    }
		    records.addAll(recordsToAdd);
		    this.instanceInsertedRecordsMap.put(key, records);

            // static group
            records = new List<SObject>();
            key = sObjectKey + '.' + key;
		    if (FObject.globalInsertedRecordsMap.containsKey(key)) {
			    records = FObject.globalInsertedRecordsMap.get(key);
		    }
		    records.addAll(recordsToAdd);
		    FObject.globalInsertedRecordsMap.put(key, records);
	    }
    }

    /**
     * @description Adds field values to Field Values Matrix.
     * @param fieldApiName The API name of the field.
     * @param fieldValues The list of field values.
     */
    private void addToFieldValuesMatrix(String fieldApiName, List<String> fieldValues) {
        Integer counter1 = 0;

        for (String field : this.fields) {
            if (field == fieldApiName) { // when field API name matches
                // for each value in field's value list
                for (Integer counter2 = 0; counter2 < this.records; counter2++) {
                    // append new value to existing value
                    try {
                        this.fieldValuesMatrix[counter1][counter2] += fieldValues[counter2];
                    } catch (Exception exp) {
                        // do not raise an error for a blank value
                    }
                }
                break;
            }
            counter1++;
        }
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
     * @description Checks that a cluster type exists in a definition.
     * @param clusterType The cluster type.
     * @param definition The field definition.
     * @return A boolean value.
     */
    private Boolean clusterTypeIsValid(ClusterType clusterType, Definition definition) {
        Integer countOfParameter = 0; // counts how many times a cluster parameter is found
        Integer index; // the position of a definition cluster with a specified (cluster type's) parameter

        // find how many times Parameter exists (countOfParameter) and its position (index)
        Integer counter = 0;
        for (Cluster cluster : definition.clusters) { // for every cluster in definition
            if (clusterType.parameter == cluster.parameter) { // if parameter is valid
                countOfParameter++;
                index = counter;
            }
            counter++;
        }

        // if parameter is not found or found more than once
        if (countOfParameter != 1) {
            return false;
        }

        // check if cluster value is valid
        if (valueIsValid(clusterType, definition.clusters[index])) {
            return true;
        } else {
            return false;
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
     * @description Converts all items of a list to lowercase.
     * @param listToConvert The list for conversion.
     * @return A list of string values.
     */
    private static List<String> convertListToLowercase(List<String> listToConvert) {
        List<String> results = new List<String>();

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
    private static Set<String> convertSetToLowercase(Set<String> setToConvert) {
        Set<String> results = new Set<String>();

        for (String value : setToConvert) {
            results.add(value.toLowerCase());
        }

        return results;
    }

    /**
      * @description Creates values based on a field definition.
      * @param definition A field definition.
      * @return A list of string values.
      */
    private List<String> createFieldValues(Definition definition) {
        List<String> results = new List<String>();
        List<Cluster> clusters = definition.clusters;
        DefinitionTypeId defId = definition.type.id;

        if (defId == DefinitionTypeId.RANDOM_NUMBER) {
            Decimal fromArgm = Decimal.valueOf(getClusterArgument('from', clusters));
            Decimal toArgm = Decimal.valueOf(getClusterArgument('to', clusters));
            Integer scaleArgm = Integer.valueOf(getClusterArgument('scale', clusters));
            results = getRandomNumbers(fromArgm, toArgm, scaleArgm, definition);
        } else if (defId == DefinitionTypeId.RANDOM_DATE) {
            Date fromArgm = Date.valueOf(getClusterArgument('from', clusters));
            Date toArgm = Date.valueOf(getClusterArgument('to', clusters));
            results = getRandomDates(fromArgm, toArgm, definition);
        } else if (defId == DefinitionTypeId.RANDOM_DATETIME) {
            Datetime fromArgm;
            Datetime toArgm;
            try {
                fromArgm = Datetime.valueOf(getClusterArgument('from', clusters));
            } catch (TypeException ex) {
                fromArgm = Datetime.newInstance(
                    Date.valueOf(getClusterArgument('from', clusters)),Time.newInstance(0, 0, 0, 0));
            }
            try {
                toArgm = Datetime.valueOf(getClusterArgument('to', clusters));
            } catch (TypeException ex) {
                toArgm = Datetime.newInstance(
                    Date.valueOf(getClusterArgument('to', clusters)), Time.newInstance(0, 0, 0, 0));
            }
            results = getRandomDatetimes(fromArgm, toArgm, definition);
        } else if (defId == DefinitionTypeId.RANDOM_PICKLIST) {
            results = getRandomPicklistValues(definition.fieldApiName);
        } else if (defId == DefinitionTypeId.RANDOM_PICKLIST_EXCEPT) {
            List<String> exceptions = getClusterArguments('except', clusters);
            results = getRandomPicklistValuesExcept(definition.fieldApiName, exceptions);
        } else if (
            defId == DefinitionTypeId.RANDOM_LIST_STRING ||
                defId == DefinitionTypeId.RANDOM_LIST_INTEGER ||
                defId == DefinitionTypeId.RANDOM_LIST_DECIMAL ||
                defId == DefinitionTypeId.RANDOM_LIST_DATE ||
                defId == DefinitionTypeId.RANDOM_LIST_TIME ||
                defId == DefinitionTypeId.RANDOM_LIST_DATETIME) {
            results = getRandomListValues(definition);
        } else if (defId == DefinitionTypeId.RANDOM_EMAIL) {
            results = getRandomEmails(definition);
        } else if (defId == DefinitionTypeId.RANDOM_URL) {
            results = getRandomUrls();
        } else if (defId == DefinitionTypeId.RANDOM_BOOLEAN) {
            results = getRandomBooleans();
        } else if (defId == DefinitionTypeId.RANDOM_FIRSTNAME) {
            String nameGroup = getClusterArgument('group', clusters);
            results = getRandomFirstNames(nameGroup);
        } else if (defId == DefinitionTypeId.RANDOM_LASTNAME) {
            String nameGroup = getClusterArgument('group', clusters);
            results = getRandomLastNames(nameGroup);
        } else if (defId == DefinitionTypeId.RANDOM_STREET) {
            String addressGroup = getClusterArgument('group', clusters);
            results = getRandomStreets(addressGroup);
        } else if (defId == DefinitionTypeId.RANDOM_POSTALCODE) {
            String addressGroup = getClusterArgument('group', clusters);
            results = getRandomPostalCodes(addressGroup);
        } else if (defId == DefinitionTypeId.RANDOM_CITY) {
            String addressGroup = getClusterArgument('group', clusters);
            results = getRandomCities(addressGroup);
        } else if (defId == DefinitionTypeId.RANDOM_STATE) {
            String addressGroup = getClusterArgument('group', clusters);
            results = getRandomStates(addressGroup);
        } else if (defId == DefinitionTypeId.RANDOM_COUNTRY) {
            String addressGroup = getClusterArgument('group', clusters);
            results = getRandomCountries(addressGroup);
        } else if (defId == DefinitionTypeId.RANDOM_STRING) {
            Integer minlength = Integer.valueOf(getClusterArgument('minlength', clusters));
            Integer maxlength = Integer.valueOf(getClusterArgument('maxlength', clusters));
            String startsWith = getClusterArgument('startwith', clusters);
            List<String> includes = getClusterArguments('include', clusters);
            results = getRandomStrings(minlength, maxlength, startsWith, includes, definition);
        } else if (defId == DefinitionTypeId.RANDOM_TEXT) {
            Integer minLength = Integer.valueOf(getClusterArgument('minlength', clusters));
            Integer maxLength = Integer.valueOf(getClusterArgument('maxlength', clusters));
            results = getRandomTexts(minLength, maxLength, definition);
        } else if (defId == DefinitionTypeId.RANDOM_PHONE) {
            String formatString = getClusterArgument('format', clusters);
            results = getRandomPhoneNumbers(formatString);
        } else if (defId == DefinitionTypeId.RANDOM_LOOKUP) {
            String source = getClusterArgument('source', clusters);
            String lookupObject = getClusterArgument('lookup', clusters);
            String lookupField = getClusterArgument('field', clusters);
            List<String> lookupValues = getClusterArguments('value', clusters);
            List<String> lookupExceptValues = getClusterArguments('except', clusters);
            String groupName = getClusterArgument('group', clusters);
            results = getLookupValues(definition, 'random', source,
                lookupObject, lookupField, lookupValues, lookupExceptValues, groupName, null, null);
        } else if (defId == DefinitionTypeId.RANDOM_LOOKUP_WHERE) {
            String source = getClusterArgument('source', clusters);
            String lookupObject = getClusterArgument('lookup', clusters);
            String whereClause = getClusterArgument('where', clusters);
            results = getLookupValues(definition, 'random', source, lookupObject,
                null, null, null, '', whereClause, null);
        } else if (defId == DefinitionTypeId.STATIC_LOOKUP) {
            String source = getClusterArgument('source', clusters);
            String lookupObject = getClusterArgument('lookup', clusters);
            String lookupField = getClusterArgument('field', clusters);
            List<String> lookupValues = getClusterArguments('value', clusters);
            results = getLookupValues(definition, 'static', source, lookupObject, lookupField, lookupValues,
                null, '', null, null);
        } else if (defId == DefinitionTypeId.SERIAL_LOOKUP) {
            String source = getClusterArgument('source', clusters);
            String lookupObject = getClusterArgument('lookup', clusters);
            String lookupMode = getClusterArgument('mode', clusters);
            List<String> lookupValues = getClusterArguments('value', clusters);
            String groupName = getClusterArgument('group', clusters);
            results = getLookupValues(definition, 'serial', source, lookupObject, null, lookupValues,
                null, groupName, null, lookupMode);
        } else if (defId == DefinitionTypeId.SERIAL_NUMBER) {
            Decimal fromArgm = Decimal.valueOf(getClusterArgument('from', clusters));
            Decimal stepArgm = Decimal.valueOf(getClusterArgument('step', clusters));
            Integer scaleArgm = Integer.valueOf(getClusterArgument('scale', clusters));
            results = getSerialNumbers(fromArgm, stepArgm, scaleArgm);
        } else if (defId == DefinitionTypeId.SERIAL_DATE) {
            Date fromArgm = Date.valueOf(getClusterArgument('from', clusters));
            Integer stepArgm = Integer.valueOf(getClusterArgument('step', clusters));
            results = getSerialDates(fromArgm, stepArgm);
        } else if (defId == DefinitionTypeId.SERIAL_DATETIME) {
            Datetime fromArgm;
            try {
                fromArgm = Datetime.valueOf(getClusterArgument('from', clusters));
            } catch (TypeException ex) {
                fromArgm = Datetime.newInstance(
                    Date.valueOf(getClusterArgument('from', clusters)), Time.newInstance(0, 0, 0, 0));
            }
            Decimal stepArgm = Decimal.valueOf(getClusterArgument('step', clusters));
            results = getSerialDatetimes(fromArgm, stepArgm);
        } else if (
            defId == DefinitionTypeId.STATIC_STRING ||
                defId == DefinitionTypeId.STATIC_INTEGER ||
                defId == DefinitionTypeId.STATIC_DECIMAL ||
                defId == DefinitionTypeId.STATIC_DATE ||
                defId == DefinitionTypeId.STATIC_TIME ||
                defId == DefinitionTypeId.STATIC_DATETIME) {
            String label = getClusterArgument('value', clusters);
            results = getStaticValues(definition, label);
        } else if (defId == DefinitionTypeId.COPY_FIELD) {
            String field = getClusterArgument('field', clusters);
            results = getCopiedValues(definition, field);
        } else if (defId == DefinitionTypeId.COPY_LOOKUP) {
            String fieldName = getClusterArgument('field', clusters);
            String fromObjectFieldName = getClusterArgument('from', clusters);
            results = getCopiedLookupValues(definition, fieldName, fromObjectFieldName);
        } else if (defId == DefinitionTypeId.MOCK_ID) {
            Schema.SObjectType objType = FObject.globalDescribe.get(this.sObjectName);
            results = getMockedIds(objType);
        }

        return results;
    }

    /**
     * @description Creates field values when updating fields.
     */
    private void createValuesOnFieldValuesUpdate() {
        initializeFieldValuesMatrix();
        forceeaDebug(DEBUG, MESSAGE_WILL_CREATE_UPDATED_FIELD_VALUES + ' of [' + this.sObjectApiName + ']');

        for (String fieldName : this.fields) {
            for (Definition def : this.definitions) {
                if (fieldName != def.fieldApiName || !def.isForUpdate) {
                    continue;
                }

                List<String> fieldValues = createFieldValues(def);
                if (processMustTerminate()) {
                    return;
                }

                if (!fieldValues.isEmpty()) {
                    addToFieldValuesMatrix(def.fieldApiName, fieldValues);
                    forceeaDebug(DEBUG, SYMBOL_SUCCESS + ' Created data of [' + def.fieldApiName +
                        '] with definition [' + def.definitionString + ']');
                    this.numDefinitionsWithData++;
                }
            }
        }
    }

    /**
     * @description Creates SObject records using the field definitions.
     */
    private void createNewRecords() {
        if (processMustTerminate() || !this.mustCreateNewRecords) {
            return;
        }

        onBeforeCreateRecords();

        // validate user-defined and system-defined definitions
        validateDefinitions();
        if (processMustTerminate()) {
            return;
        }

        resetMilestoneTimer('Validated definitions of [' + this.sObjectApiName + ']');
        initializeFieldValuesMatrix();
        forceeaDebug(DEBUG, MESSAGE_WILL_CREATE_FIELD_VALUES + ' of [' + this.sObjectApiName + ']');

        this.cpuTimeOfObjectSetup = Limits.getCpuTime() - this.cpuTimeStartOfObjectSetup;
        this.cpuTimeStartOfDataGeneration = Limits.getCpuTime();

        // create field values
        Integer numberOfFieldsWithData = 0;
        for (String field : this.fields) {
            for (Definition def : this.definitions) {
                if (field != def.fieldApiName || def.isForUpdate) {
                    continue; // go to next definition if this definition is not assigned to this field
                }

                List<String> fieldValues = createFieldValues(def);

                if (processMustTerminate()) {
                    return;
                }

                if (!fieldValues.isEmpty()) { // if field values are populated
                    // add the field values to FVM
                    addToFieldValuesMatrix(def.fieldApiName, fieldValues);
                    forceeaDebug(DEBUG, SYMBOL_SUCCESS + ' Created values of [' + def.fieldApiName +
                        '] with definition [' + def.definitionString + ']');
                    numberOfFieldsWithData++;
                } else { // do not add field values to FVM
                    forceeaDebug(WARN, 'Did not create values of [' + def.fieldApiName +
                        '] with definition [' + def.definitionString + ']');
                }
            }
        }

        if (numberOfFieldsWithData > 0) { // display data if there are created fields
            displayCreatedFieldValues();
        }

        // create records
        for (Integer counter = 0; counter < this.records; counter++) {
            this.createdRecords.add(this.getRecord(counter)); // add created SObject to output list
            if (!FObject.processIsValid) {
                break;
            }
        }

        if (processMustTerminate()) {
            return;
        }
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
            addError(this.sObjectApiName, 'Invalid record number in method createRecords');
            if (processMustTerminate()) {
                return this;
            }
        } else {
            setNumberOfNextRecord(recordNumber);
        }
        createNewRecords();

        return this;
    }

    /**
     * @description Validates a field definition.
     * @param definition The field definition.
     * @return A boolean value.
     */
    private Boolean definitionIsValid(Definition definition) {
        Boolean result = true;
        String fieldApiName = definition.fieldApiName;
        String errorMessage = '';
        definition.isValid = true;
        definition.isValidated = true;
        definition.command = definition.command.toLowerCase();

        // find the definition type of this definition
        for (DefinitionType defType : FObject.definitionTypes) { // for each definition type
            if (definitionTypeExists(defType, definition)) { // if definition type is found
                definition.type = defType;
                break;
            }
        }

        if (definition.isValid) { // found a definition type match
            if (fieldIsVirtual(definition.fieldApiName)) {
                result = true;
            } else if (!definitionIsValidForFieldDataType(definition)) { // has invalid field data type
                definition.hasValidFieldDataType = false;
                errorMessage = 'Invalid definition [' + definition.definitionString + '] ' +
                    'for the data type of field [' + fieldApiName + ']';
                addError(fieldApiName, errorMessage);
                definition.isValid = false;
                result = false;
            } else { // has valid field data type
                // check if field allows multiple definitions
                Field thisField = this.sObjectFieldsMap.get(fieldApiName.toLowerCase());
                if (thisField.allowsMultipleDefinitions == false && fieldHasMultipleDefinitions(fieldApiName)) {
                    if (!getErrors().containsKey(fieldApiName)) { // if there is no error for this field
                        errorMessage = 'Field [' + fieldApiName + '] does not accept multiple definitions';
                        addError(fieldApiName, errorMessage);
                        definition.isValid = false;
                        result = false;
                    }
                }
            }
        } else { // didn't find a definition type match
            errorMessage = 'Invalid definition [' + definition.definitionString + '] of field [' + fieldApiName + ']';
            addError(fieldApiName, errorMessage);
            definition.isValid = false;
            result = false;
        }

        return result;
    }

    /**
     * @description Validates the definition in regards to the data type of the definition field.
     * @param definition The definition for validation.
     * @return A boolean value.
     */
    private Boolean definitionIsValidForFieldDataType(Definition definition) {
        Boolean result = false;

        // get the field type
        Schema.DisplayType fieldType = this.sObjectFieldsMap.get(definition.fieldApiName.toLowerCase()).dataType;
        DefinitionTypeId typeId = definition.type.id;
        if (definition.fieldApiName == 'RecordTypeId') {
            if (typeId == DefinitionTypeId.STATIC_STRING ||
                typeId == DefinitionTypeId.RANDOM_LIST_STRING ||
                typeId == DefinitionTypeId.RANDOM_PICKLIST ||
                typeId == DefinitionTypeId.RANDOM_PICKLIST_EXCEPT) {
                result = true;
            }
        } else if (fieldType == Schema.DisplayType.String || fieldType == Schema.DisplayType.TextArea) {
            result = true;
            if (typeId == DefinitionTypeId.MOCK_ID ||
                typeId == DefinitionTypeId.RANDOM_LOOKUP ||
                typeId == DefinitionTypeId.RANDOM_LOOKUP_WHERE ||
                typeId == DefinitionTypeId.RANDOM_PICKLIST ||
                typeId == DefinitionTypeId.RANDOM_PICKLIST_EXCEPT ||
                typeId == DefinitionTypeId.SERIAL_LOOKUP ||
                typeId == DefinitionTypeId.STATIC_LOOKUP) {
                result = false;
            }
        } else if (fieldType == Schema.DisplayType.Date && (
            typeId == DefinitionTypeId.COPY_FIELD ||
                typeId == DefinitionTypeId.COPY_LOOKUP ||
                typeId == DefinitionTypeId.RANDOM_DATE ||
                typeId == DefinitionTypeId.RANDOM_LIST_DATE ||
                typeId == DefinitionTypeId.SERIAL_DATE ||
                typeId == DefinitionTypeId.STATIC_DATE)) {
            result = true;
        } else if (fieldType == Schema.DisplayType.Integer && (
            typeId == DefinitionTypeId.COPY_FIELD ||
                typeId == DefinitionTypeId.COPY_LOOKUP ||
                typeId == DefinitionTypeId.RANDOM_LIST_INTEGER ||
                typeId == DefinitionTypeId.RANDOM_LIST_DECIMAL ||
                typeId == DefinitionTypeId.RANDOM_NUMBER ||
                typeId == DefinitionTypeId.SERIAL_NUMBER ||
                typeId == DefinitionTypeId.STATIC_INTEGER)) {
            result = true;
        } else if ((
            fieldType == Schema.DisplayType.Percent || fieldType == Schema.DisplayType.Currency ||
                fieldType == Schema.DisplayType.Double) && (
            typeId == DefinitionTypeId.STATIC_INTEGER ||
                typeId == DefinitionTypeId.STATIC_DECIMAL ||
                typeId == DefinitionTypeId.RANDOM_LIST_INTEGER ||
                typeId == DefinitionTypeId.RANDOM_LIST_DECIMAL ||
                typeId == DefinitionTypeId.RANDOM_NUMBER ||
                typeId == DefinitionTypeId.SERIAL_NUMBER ||
                typeId == DefinitionTypeId.COPY_LOOKUP ||
                typeId == DefinitionTypeId.COPY_FIELD)) {
            result = true;
        } else if (fieldType == Schema.DisplayType.Boolean && (
            typeId == DefinitionTypeId.STATIC_STRING ||
                typeId == DefinitionTypeId.RANDOM_BOOLEAN ||
                typeId == DefinitionTypeId.RANDOM_LIST_STRING ||
                typeId == DefinitionTypeId.COPY_LOOKUP ||
                typeId == DefinitionTypeId.COPY_FIELD)) {
            result = true;
        } else if (fieldType == Schema.DisplayType.Email && (
            typeId == DefinitionTypeId.STATIC_STRING ||
                typeId == DefinitionTypeId.STATIC_INTEGER ||
                typeId == DefinitionTypeId.RANDOM_LIST_INTEGER ||
                typeId == DefinitionTypeId.RANDOM_LIST_STRING ||
                typeId == DefinitionTypeId.RANDOM_EMAIL ||
                typeId == DefinitionTypeId.RANDOM_STRING ||
                typeId == DefinitionTypeId.RANDOM_BOOLEAN ||
                typeId == DefinitionTypeId.RANDOM_NUMBER ||
                typeId == DefinitionTypeId.SERIAL_NUMBER ||
                typeId == DefinitionTypeId.COPY_LOOKUP ||
                typeId == DefinitionTypeId.COPY_FIELD)) {
            result = true;
        } else if (fieldType == Schema.DisplayType.Picklist || fieldType == Schema.DisplayType.MultiPicklist) {
            result = true;
            if (typeId == DefinitionTypeId.MOCK_ID ||
                typeId == DefinitionTypeId.RANDOM_LOOKUP ||
                typeId == DefinitionTypeId.RANDOM_LOOKUP_WHERE ||
                typeId == DefinitionTypeId.SERIAL_LOOKUP ||
                typeId == DefinitionTypeId.STATIC_LOOKUP) {
                result = false;
            }
        } else if (fieldType == Schema.DisplayType.Datetime && (
            typeId == DefinitionTypeId.STATIC_DATE ||
                typeId == DefinitionTypeId.STATIC_DATETIME ||
                typeId == DefinitionTypeId.RANDOM_LIST_DATE ||
                typeId == DefinitionTypeId.RANDOM_LIST_DATETIME ||
                typeId == DefinitionTypeId.RANDOM_DATE ||
                typeId == DefinitionTypeId.RANDOM_DATETIME ||
                typeId == DefinitionTypeId.SERIAL_DATE ||
                typeId == DefinitionTypeId.SERIAL_DATETIME ||
                typeId == DefinitionTypeId.COPY_LOOKUP ||
                typeId == DefinitionTypeId.COPY_FIELD)) {
            result = true;
        } else if (fieldType == Schema.DisplayType.Phone && (
            typeId == DefinitionTypeId.RANDOM_PHONE ||
                typeId == DefinitionTypeId.STATIC_INTEGER ||
                typeId == DefinitionTypeId.STATIC_STRING ||
                typeId == DefinitionTypeId.RANDOM_LIST_STRING ||
                typeId == DefinitionTypeId.RANDOM_NUMBER ||
                typeId == DefinitionTypeId.SERIAL_NUMBER ||
                typeId == DefinitionTypeId.COPY_LOOKUP ||
                typeId == DefinitionTypeId.COPY_FIELD)) {
            result = true;
        } else if (fieldType == Schema.DisplayType.Reference && (
            typeId == DefinitionTypeId.COPY_LOOKUP ||
                typeId == DefinitionTypeId.COPY_FIELD ||
                typeId == DefinitionTypeId.RANDOM_LOOKUP ||
                typeId == DefinitionTypeId.RANDOM_LOOKUP_WHERE ||
                typeId == DefinitionTypeId.SERIAL_LOOKUP ||
                typeId == DefinitionTypeId.STATIC_LOOKUP)) {
            result = true;
        } else if (fieldType == Schema.DisplayType.Url && (
            typeId == DefinitionTypeId.STATIC_INTEGER ||
                typeId == DefinitionTypeId.STATIC_STRING ||
                typeId == DefinitionTypeId.RANDOM_LIST_INTEGER ||
                typeId == DefinitionTypeId.RANDOM_LIST_STRING ||
                typeId == DefinitionTypeId.RANDOM_NUMBER ||
                typeId == DefinitionTypeId.RANDOM_STRING ||
                typeId == DefinitionTypeId.RANDOM_URL ||
                typeId == DefinitionTypeId.SERIAL_NUMBER ||
                typeId == DefinitionTypeId.COPY_LOOKUP ||
                typeId == DefinitionTypeId.COPY_FIELD)) {
            result = true;
        } else if (fieldType == Schema.DisplayType.Combobox) {
            result = true;
            if (typeId == DefinitionTypeId.MOCK_ID ||
                typeId == DefinitionTypeId.STATIC_LOOKUP ||
                typeId == DefinitionTypeId.RANDOM_LOOKUP ||
                typeId == DefinitionTypeId.RANDOM_LOOKUP_WHERE) {
                result = false;
            }
        } else if (fieldType == Schema.DisplayType.Base64) {
            result = true;
            if (typeId == DefinitionTypeId.MOCK_ID ||
                typeId == DefinitionTypeId.RANDOM_LOOKUP ||
                typeId == DefinitionTypeId.RANDOM_LOOKUP_WHERE ||
                typeId == DefinitionTypeId.RANDOM_PICKLIST ||
                typeId == DefinitionTypeId.RANDOM_PICKLIST_EXCEPT ||
                typeId == DefinitionTypeId.SERIAL_LOOKUP ||
                typeId == DefinitionTypeId.STATIC_LOOKUP) {
                result = false;
            }
        } else if (fieldType == Schema.DisplayType.Time && (
            typeId == DefinitionTypeId.COPY_FIELD ||
                typeId == DefinitionTypeId.COPY_LOOKUP ||
                typeId == DefinitionTypeId.STATIC_TIME ||
                typeId == DefinitionTypeId.RANDOM_LIST_TIME)) {
            result = true;
        } else if (fieldType == Schema.DisplayType.Id && typeId == DefinitionTypeId.MOCK_ID) {
            this.isMocking = true;
            result = true;
        } else {
            result = false;
        }

        return result;
    }

    /**
     * @description Checks if a definition type exists in a definition
     *   A definition type exists if a) definition type command = definition command
     *   and b) all cluster types of the definition type are found once in the definition clusters.
     * @param definitionType The definition type.
     * @param definition The definition.
     * @return A boolean value.
     */
    private Boolean definitionTypeExists(DefinitionType definitionType, Definition definition) {
        // if command is invalid, just exit
        if (definitionType.command != definition.command) {
            definition.isValid = false;
            return false;
        }

        // assess each Cluster Type of the Definition Type
        Integer numValidClusterTypes = 0;
        for (ClusterType ct : definitionType.clusterTypes) { // for every Cluster ype
            if (clusterTypeIsValid(ct, definition)) {
                numValidClusterTypes++;
            } else {
                return false;
            }
        }

        // if all Cluster Types are valid, Definition Type is found
        if (numValidClusterTypes == definitionType.clusterTypes.size()
            && numValidClusterTypes == definition.clusters.size()) {
            definition.isValid = true;
            definition.type = definitionType;
            return true;
        } else {
            definition.isValid = false;
            return false;
        }
    }

    /**
     * @description Deletes all definitions of every field.
     * @return An FObject instance.
     */
    public FObject deleteAllDefinitions() {
        forceeaDebug(INFO, MESSAGE_WILL_DELETE_ALL_FIELDS_DEFINITIONS);
        this.definitions.clear();
        this.fields.clear();
        this.willValidateFieldDefinitionsMessageIsDisplayed = true;
        return this;
    }

    /**
    * @description Deletes all definitions of a field.
    * @param sObjectField The SObjectField.
    * @return An FObject instance.
    */
    public FObject deleteFieldDefinitions(Schema.SObjectField sObjectField) {
        return deleteFieldDefinitions(sObjectField.getDescribe().getName());
    }

    /**
     * @description Deletes all definitions of a field.
     * @param fieldName The API name of a field.
     * @return An FObject instance.
     */
    public FObject deleteFieldDefinitions(String fieldName) {
        String thisFieldName = fieldName.trim();
        String fieldApiName = getFieldApiName(thisFieldName);

        // validate field
        if (String.isBlank(fieldApiName)) {
            addError(this.sObjectApiName, 'Invalid field [' +
                thisFieldName + '] in method deleteFieldDefinitions');
        }

        // get field position
        Integer fieldPosition = this.fields.indexOf(fieldApiName);
        if (fieldPosition == -1) { // field not found
            return this;
        }

        if (processMustTerminate()) {
            return this;
        }

        forceeaDebug(INFO, MESSAGE_WILL_DELETE_FIELD_DEFINITIONS + ' [' + fieldApiName + ']');

        // remove definitions
        List<Integer> definitionsToRemove = getDefinitionsToRemove(fieldApiName);
        for (Integer counter = definitionsToRemove.size() - 1; counter >= 0; counter--) {
            this.definitions.remove(definitionsToRemove.get(counter));
        }

        // remove field
        this.fields.remove(fieldPosition);

        return this;
    }

    /**
     * @description Deletes records of the SObject, using specific criteria (WHERE clause).
     * @param whereClause The WHERE clause of the SOQL query (e.g. MyField__c > 10).
     * @return A list of Database.DeleteResult objects.
     */
    public List<Database.DeleteResult> deleteRecords(String whereClause) {
        List<Database.DeleteResult> results = new List<Database.DeleteResult>();
        List<SObject> recordsToDelete = new List<SObject>();
        Set<Id> deletedRecordIdsSet = new Set<Id>();
        Integer numDeletedRecords = 0;

        if (processMustTerminate()) {
            return results;
        }

        forceeaDebug(INFO, MESSAGE_WILL_DELETE_RECORDS + ' of [' + this.sObjectApiName + ']');

        // set SOQL query
        String soqlQuery = 'SELECT Id FROM ' + this.sObjectApiName;
        String limitString = ' LIMIT ' + String.valueOf(this.queryLimit);
        if (String.isBlank(whereClause)) {
            soqlQuery += limitString;
        } else {
            soqlQuery += ' WHERE ' + whereClause + limitString;
        }

        try {
            recordsToDelete = Database.query(soqlQuery);
        } catch (QueryException ex) {
            addError(this.sObjectApiName, 'Found errors selecting records of [' +
                this.sObjectApiName + ']: ' + ex.getMessage());
        } finally {
            if (processMustTerminate()) {
                return results;
            }
        }

        // if there are no records to delete, just exit
        if (recordsToDelete.isEmpty()) {
            return results;
        }

        // delete records
        results = Database.delete(recordsToDelete, false);

        // iterate through each returned result
        Integer recordsCounter = 0;
        Integer errorsCounter = 0;
        for (Database.DeleteResult dr : results) {
            recordsCounter++;
            if (dr.isSuccess()) {
                deletedRecordIdsSet.add(dr.getId()); // add deleted record ID into deleted records IDs set
                numDeletedRecords++;
            } else { // failure
                errorsCounter++;
                if (this.errors.size() <= FObject.numMaxErrorRecordsToDisplay) {
                    for (Database.Error err : dr.getErrors()) {
                        addError(this.sObjectApiName, 'Found errors deleting record #' + recordsCounter + ': ' +
                            err.getMessage() + '. Fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }

        // display messages
        if (numDeletedRecords == recordsToDelete.size()) {
            forceeaDebug(INFO, 'Successfully deleted ' + recordsToDelete.size() +
                ' [' + this.sObjectApiName + '] records');
        } else { // there are errors
            addError(this.sObjectApiName, 'Found ' + errorsCounter +
                ' errors deleting records of [' + this.sObjectApiName + ']');
        }

        // remove deleted records from global records map
        for (String globalKey : FObject.globalInsertedRecordsMap.keySet()) {
            String instanceKey = '';
            String objectName = '';

            if (globalKey.contains('.')) { // this is a group
                objectName = globalKey.substringBefore('.');
                instanceKey = globalKey.substringAfter('.');
            } else { // is not a group
                objectName = globalKey;
            }

            if (objectName == this.sObjectApiName.toLowerCase()) { // the key belongs to this SObject
                Map<Id, SObject> insertedGlobalRecordsById = new Map<Id, SObject>(FObject.globalInsertedRecordsMap.get(globalKey));
                Map<Id, SObject> insertedRecordsById = new Map<Id, SObject>(this.instanceInsertedRecordsMap.get(instanceKey));
                for (Id deletedRecordId : deletedRecordIdsSet) {
                    insertedGlobalRecordsById.remove(deletedRecordId);
                    insertedRecordsById.remove(deletedRecordId);
                }
                // update the inserted records map
                FObject.globalInsertedRecordsMap.put(globalKey, insertedGlobalRecordsById.values());
                this.instanceInsertedRecordsMap.put(instanceKey, insertedRecordsById.values());
            }
        }

        return results;
    }

    /**
     * @description Displays the Field Value Matrix (FVM) values.
     */
    private void displayCreatedFieldValues() {
        forceeaDebug(DEBUG, MESSAGE_WILL_DISPLAY_CREATED_FIELD_VALUES + ' of [' + this.sObjectApiName + ']');

        Integer numRecords = 0;
        if (this.records <= FObject.numRecordsToDisplay) {
            numRecords = this.records;
        } else {
            numRecords = FObject.numRecordsToDisplay;
        }

        Integer counter1 = 0;
        for (String fieldName : this.fields) {
            List<String> values = new List<String>();
            for (Integer counter2 = 0; counter2 < numRecords; counter2++) {
                values.add(this.fieldValuesMatrix.get(counter1).get(counter2));
            }
            counter1++;
            displayFieldValues(fieldName, values);
        }
    }

    /**
     * @description Displays the field values as a comma separated string.
     * @param fieldName The field API name.
     * @param values The field values to display.
     */
    private void displayFieldValues(String fieldName, List<String> values) {
        String valuesString = String.join(values,'');
        Boolean valuesAreEmpty = String.isBlank(valuesString);

        if (!valuesAreEmpty) {
            forceeaDebug(DEBUG, '- Values of [' + fieldName + ']: ' + String.join(values,', '));
        }
    }

    /**
     * @description Displays the Forceea version and the User message.
     */
    private void displayInitializationMessage() {
        if (!FObject.initializationMessageIsDisplayed) {
            forceeaDebug(INFO, '=== v' + VERSION + ' ===');
            if (String.isNotBlank(FObject.userMessage)) {
                forceeaDebug(INFO, FObject.userMessage);
            }
            FObject.initializationMessageIsDisplayed = true;
        }
    }

    /**
     * @description Displays a separator for a method (insert, update)
     * @param mode The method name.
     */
    private void displaySeparatorOnMethodStart(String mode) {
        String message = ' ' + mode + ' [' + this.sObjectApiName + '] ';

        Integer totalBarLength = BAR_LENGTH - message.length();
        totalBarLength = totalBarLength < 2 ? 2 : totalBarLength;

        Integer leftBarLength = (Integer) totalBarLength / 2;
        Integer rightBarLength = totalBarLength - leftBarLength;
        String leftBar = BAR_SYMBOL.repeat(leftBarLength);
        String rightBar = BAR_SYMBOL.repeat(rightBarLength);

        forceeaDebug(DEBUG, leftBar + message + rightBar);
    }

    /**
     * @description Displays a separator for a method (insert, update)
     */
    private void displaySeparatorOnMethodFinish() {
        forceeaDebug(DEBUG, '.'.repeat(BAR_LENGTH));
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
     * @description Indicates if the IsActive standard field exists for the SObject.
     * @param fieldsMap The map with key: field name, value: the field object.
     * @return A Boolean value.
     */
    private Boolean existsIsActiveStandardField(Map<String, Field> fieldsMap) {
        return (fieldsMap.containsKey('isactive'));
    }

    /**
     * @description Determines is the field has multiple definitions.
     * @param fieldName The API name of the field.
     * @return A boolean value.
     */
    private Boolean fieldIsVirtual(String fieldName) {
        return (fieldName.toLowerCase().left(1) == '$');
    }

    /**
     * @description Determines is the field has multiple definitions.
     * @param fieldApiName The API name of the field.
     * @return A boolean value.
     */
    private Boolean fieldHasMultipleDefinitions(String fieldApiName) {
        Boolean result = false;
        Integer counter = 0;
        fieldApiName = fieldApiName.toLowerCase();

        for (Definition definition : this.definitions) {
            Boolean definitionIsValid = (definition.isForUpdate && this.isRecordsUpdate)
                || (!definition.isForUpdate && !this.isRecordsUpdate);

            if (definitionIsValid && definition.fieldApiName.toLowerCase() == fieldApiName) {
                counter++;
            }

            if (counter > 1) {
                result = true;
                break;
            }
        }

        return result;
    }

    /**
     * @description Posts an instance System.debug message.
     * @param errorLevel The System.LoggingLevel enum.
     * @param message The message to post.
     */
    private void forceeaDebug(String errorLevel, String message) {
        if (!FObject.showDebugLog) {
            return;
        }

	    String chars = '.=';
        message = message.right(1).containsAny(chars) ? message : message + '.';

        if (this.verboseMode != null) {
            FObject.postDebug(errorLevel, message, this.verboseMode);
        } else {
            FObject.postDebug(errorLevel, message, FObject.globalVerboseMode);
        }
    }

    /**
     * @description Posts a static System.debug message.
     * @param errorLevel The System.LoggingLevel enum.
     * @param message The message to post.
     */
    private static void forceeaStaticDebug(String errorLevel, String message) {
        if (!FObject.showDebugLog) {
            return;
        }

        FObject.postDebug(errorLevel, message, FObject.globalVerboseMode);
    }

    /**
     * @description Returns a map of all definitions of every field.
     * @return A map of key:string, value: List of string values.
     */
    public Map<String, List<String>> getAllDefinitions() {
        Map<String, List<String>> results = new Map<String, List<String>>();
        validateDefinitions();

        for (Definition def : this.definitions) {
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
     * @description Returns the first argument of a cluster.
     * @param parameter The parameter of the cluster.
     * @param clusters The list of definition clusters.
     * @return A string value.
     */
    private String getClusterArgument(String parameter, List<Cluster> clusters) {
        String result = '';
        String par = parameter.toLowerCase();

        for (Cluster cluster : clusters) {
            if (par == cluster.parameter) { // parameter is found
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
     * @param clusters The list of definition clusters.
     * @return A list of string values.
     */
    private List<String> getClusterArguments(String parameter, List<Cluster> clusters) {
        List<String> results = new List<String>();
        String par = parameter.toLowerCase();

        for (Cluster cluster : clusters) {
            if (par == cluster.parameter) { // parameter is found

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
     * @param definition The definition of the field.
     * @param fieldName The API name of the field.
     * @param fromObjectFieldName The lookup SObject and the lookup field API names.
     *   seperated with a dot, e.g. Account.Rating.
     * @return A list of string values.
     */
    private List<String> getCopiedLookupValues(
        Definition definition, String fieldName, String fromObjectFieldName) {
        List<String> values = new List<String>();
        fieldName = fieldName.trim();

        // check if the field API name is valid
        String fieldApiName = getFieldApiName(fieldName);
        if (String.isBlank(fieldApiName)) { // field is invalid
            addError(definition.fieldApiName, 'Invalid field [' + fieldName + '] in definition [' +
                definition.definitionString + ']');
        }
        if (processMustTerminate()) {
            return values;
        }

        if (fieldApiName == definition.fieldApiName) {
            addError(definition.fieldApiName, 'The field [' + fieldApiName + '] cannot be the same as ' +
                'the definition field in definition [' + definition.definitionString + ']');
        }
        if (processMustTerminate()) {
            return values;
        }

        // check if the lookup SObject is valid
        String lookupObjectName = fromObjectFieldName.trim().substringBefore('.');
        String lookupObjectApiName = FObject.getSObjectApiName(lookupObjectName);
        if (String.isBlank(lookupObjectApiName)) { // SObject is invalid
            addError(definition.fieldApiName, 'Invalid lookup SObject [' + lookupObjectName + '] in definition [' +
                definition.definitionString + ']');
        }
        if (processMustTerminate()) {
            return values;
        }

        // check if the lookup field is valid
        String lookupFieldName = fromObjectFieldName.trim().substringAfter('.');
        String lookupFieldApiName = FObject.getFieldApiName(lookupObjectName, lookupFieldName);
        if (String.isBlank(lookupFieldApiName)) {
            addError(definition.fieldApiName, 'Invalid lookup field [' + lookupFieldName + '] in definition [' +
                definition.definitionString + ']');
        }
        if (processMustTerminate()) {
            return values;
        }

        // get the lookup field values
        Integer fieldPosition = getFieldPosition(fieldApiName);

        List<String> lookupIds = new List<String>(this.fieldValuesMatrix.get(fieldPosition));
        Set<String> lookupIdsSet = new Set<String>(lookupIds);

        String soqlQuery = 'SELECT Id, ' + lookupFieldApiName +
            ' FROM ' + lookupObjectApiName +
            ' WHERE Id IN :lookupIdsSet LIMIT ' + String.valueOf(this.queryLimit);

        Map<Id, SObject> lookupRecordsMap; // the lookup SObject's records map
        try { //query the database and populate the lookup records map
            lookupRecordsMap = new Map<Id, SObject>(Database.query(soqlQuery));
        } catch (QueryException ex) {
            addError(fieldApiName, MESSAGE_FOUND_ERRORS_SELECTING_FROM_LOOKUP + ' [' + lookupObjectApiName +
                '] of [' + this.sObjectApiName + ']: ' + ex.getMessage());
        } finally {
            if (lookupRecordsMap.isEmpty() || processMustTerminate()) {
                return values;
            }
        }

        // get the field data type
        Schema.DisplayType valueType = this.sObjectFieldsMap.get(definition.fieldApiName.toLowerCase()).dataType;

        String val = '';
        Datetime dt;

        if (valueType == Schema.DisplayType.DATETIME) { // the field is Datatime
            for (String lookupId : lookupIds) {
                dt = (Datetime) lookupRecordsMap.get(lookupId).get(lookupFieldApiName); // get the datetime value
                val = String.valueOf(dt);
                if (String.isBlank(val)) {
                    values.add('');
                } else {
                    values.add(val);
                }
            }
        } else { // the field is not Datatime
            for (String lookupId : lookupIds) {
                val = String.valueOf(lookupRecordsMap.get(lookupId).get(lookupFieldApiName));
                if (String.isBlank(val)) {
                    values.add('');
                } else {
                    values.add(val);
                }
            }
        }

        return values;
    }

    /**
     * @description Copies the values of a field.
     * @param definition The definition of the field.
     * @param fieldName The API name of the field.
     * @return A list of string values.
     */
    private List<String> getCopiedValues(Definition definition, String fieldName) {
        List<String> values = new List<String>();
        fieldName = fieldName.trim();

        // check if the field API name is valid
        String fieldApiName = getFieldApiName(fieldName);
        if (String.isBlank(fieldApiName)) {
            addError(definition.fieldApiName, 'Invalid field [' + fieldName + '] in definition [' +
                definition.definitionString + ']');
        }
        if (processMustTerminate()) {
            return values;
        }

        if (fieldApiName == definition.fieldApiName) {
            addError(definition.fieldApiName, 'The field [' + fieldApiName + '] cannot be the same as ' +
                'the definition field in definition [' + definition.definitionString + ']');
        }
        if (processMustTerminate()) {
            return values;
        }

        // get the field values
        Integer fieldPosition = getFieldPosition(fieldApiName);
        values = this.fieldValuesMatrix.get(fieldPosition);

        return values;
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
     * @description Retrieves the default number of records of a new lookup FObject.
     * @param records The records of the current FObject.
     * @return An integer value.
     */
    private Integer getDefaultRecords(Integer records) {
        Decimal defaultRecords = 0;

        if (records <= 10) {
            defaultRecords = records;
        } else {
            defaultRecords = 10 + 0.1 * records;
        }

        return Integer.valueOf(defaultRecords);
    }


    /**
     * @description Retrieves the ndexes of the definitions to be removed.
     * @param fieldApiName The field API name.
     * @return The list of definition indexes.
     */
    private List<Integer> getDefinitionsToRemove(String fieldApiName) {
        List<Integer> results = new List<Integer>();
        Integer index = 0;

        for (Definition def : this.definitions) {
            if (def.fieldApiName == fieldApiName) {
                results.add(index);
            }
            index++;
        }

        return results;
    }

    /**
     * @description Retrieves the field details.
     * @param sObjectField The sObject field.
     * @return A Field object.
     */
    private static Field getDetailsFromSObjectField(Schema.SObjectField sObjectField) {
        Field result = new Field();
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

        // check if field is required
        if (dfr.isCreateable() && !dfr.isNillable() && !dfr.isDefaultedOnCreate()) {
            result.isRequired = true;
        } else {
            result.isRequired = false;
        }

        Schema.DisplayType dt = result.dataType;

        // check if field allows multiple definitions
        if (dt == Schema.DisplayType.String ||
            dt == Schema.DisplayType.Email ||
            dt == Schema.DisplayType.Url ||
            dt == Schema.DisplayType.Base64 ||
            dt == Schema.DisplayType.Phone ||
            dt == Schema.DisplayType.TextArea ||
            dt == Schema.DisplayType.Combobox) {
            result.allowsMultipleDefinitions = true;
        } else {
            result.allowsMultipleDefinitions = false;
        }

        if (dt == Schema.DisplayType.Picklist ||
            dt == Schema.DisplayType.MultiPicklist ||
            dt == Schema.DisplayType.Combobox) {
            if (dfr.getController() != null) {
                result.controllingFieldApiName = dfr.getController().getDescribe().getName(); // get controlling field
            }
            result.picklistValues = dfr.getPicklistValues();
        }

        return result;
    }

	/**
	 * @description Returns the DML description.
	 * @return A string of the DML description in the preferred tense.
	 */
	private String getDmlDescription(String suffix, String startsWith) {
		String result = '';

		if (this.isInsert) {
			result = 'insert' + suffix;
		} else if (this.isRecordsUpdate) {
			result = 'updat' + suffix;
		}

		return (startsWith.toLowerCase() == 'uppercase')? result.capitalize() : result;
	}

    /**
     * @description Returns a list of the errors found during the process of creating the records of an FObject.
     * @return A map of key: String, value: List<String> values.
     */
    public Map<String, List<String>> getErrors() {
        Map<String, List<String>> results = new Map<String, List<String>>();

        for (Error err : this.errors) {
            if (results.containsKey(err.id)) { // the key exists
                results.get(err.id).add(err.errorMessage); // add a new element in the list
            } else {
                results.put(err.id, new List<String> { // add a new element in the map
                    err.errorMessage
                });
            }
        }

        return results;
    }

    /**
     * @description Retrieves the API name of a specific SObject's field or a blank string if the field name is invalid.
     * @param fieldName The field name.
     * @return A string value.
     */
    private String getFieldApiName(String fieldName) {
        String result = '';
        if (String.isBlank(fieldName)) {
            return result;
        }

        String thisFieldName = fieldName.trim().toLowerCase();

        if (this.sObjectFieldsMap.containsKey(thisFieldName)) { // is valid field
            Field field = this.sObjectFieldsMap.get(thisFieldName);
            result = field.fieldApiName;
        } else if (fieldIsVirtual(thisFieldName)) {
            result = fieldName.trim();
        }

        return result;
    }

    /**
     * @description Retrieves the API name of a specific SObject's field or a blank string if the field name is invalid.
     * @param objectName The SObject name.
     * @param fieldName The field name.
     * @return A string value.
     */
    @TestVisible
    private static String getFieldApiName(String objectName, String fieldName) {
        String result = '';

        if (String.isBlank(objectName) || String.isBlank(fieldName)) {
            return result;
        }
        objectName = objectName.trim().toLowerCase();
        fieldName = fieldName.trim().toLowerCase();

        if (String.isNotBlank(FObject.getSObjectApiName(objectName))) { // the SObject name is valid
            Map<String, Field> fieldsMap = FObject.globalSObjectFieldsMap.get(objectName);
            if (fieldsMap.containsKey(fieldName)) {
                result = fieldsMap.get(fieldName).fieldApiName;
            }
        }

        return result;
    }

    /**
     * @description Returns a list of all definitions of a field.
     * @param sObjectField The SObjectField.
     * @return A list of string values.
     */
    public List<String> getFieldDefinitions(Schema.SObjectField sObjectField) {
        return getFieldDefinitions(sObjectField.getDescribe().getName());
    }

    /**
     * @description Returns a list of all definitions of a field.
     * @param fieldApiName The API name of the field.
     * @return A list of string values.
     */
    public List<String> getFieldDefinitions(String fieldApiName) {
        validateDefinitions();
        String thisFieldApiName = fieldApiName.trim();

        thisFieldApiName = thisFieldApiName.toLowerCase();

        List<String> values = new List<String>();
        for (Definition def : this.definitions) {
            if (def.fieldApiName.toLowerCase() == thisFieldApiName) {
                values.add(def.definitionString);
            }
        }

        return values;
    }

    /**
     * @description Retrieves the field dependencies mapping between a controlling field and a dependent field.
     *   https://salesforce.stackexchange.com/questions/4462/get-lists-of-dependent-picklist-options-in-apex/164491#164491
     * @param objectName The API name of the SObject.
     * @param controllingField The API name of the controlling field.
     * @param dependentField The API name of the dependent field.
     * @author Suriya Soundrapandian.
     * @return A map of the controlling field value and the dependent field values.
     */
    private Map<String, Set<String>> getFieldDependenciesMap(
        String objectName, String controllingField, String dependentField) {
        Map<String, Set<String>> results = new Map<String, Set<String>>();
        Schema.SObjectType objType = FObject.globalDescribe.get(objectName);
        Schema.DescribeSObjectResult describeResult = objType.getDescribe();
        Schema.DescribeFieldResult controllingFieldInfo = describeResult.fields.getMap().get(controllingField).getDescribe();
        Schema.DescribeFieldResult dependentFieldInfo = describeResult.fields.getMap().get(dependentField).getDescribe();
        List<Schema.PicklistEntry> controllingValues = controllingFieldInfo.getPicklistValues();
        List<Schema.PicklistEntry> dependentValues = dependentFieldInfo.getPicklistValues();

        for (Schema.PicklistEntry currControllingValue : controllingValues) {
            results.put(currControllingValue.getValue(), new Set<String>());
        }

        for (Schema.PicklistEntry currDependentValue : dependentValues) {
            String jsonString = JSON.serialize(currDependentValue);
            PicklistInfo info = (PicklistInfo) JSON.deserialize(jsonString, PicklistInfo.class);
            String hexString = EncodingUtil.convertToHex(EncodingUtil.base64Decode(info.validFor)).toUpperCase();
            Integer baseCount = 0;

            for (Integer curr : hexString.getChars()) {
                Integer val = 0;

                if (curr >= 65) {
                    val = curr - 65 + 10;
                } else {
                    val = curr - 48;
                }

                if ((val & 8) == 8) {
                    results.get(controllingValues[baseCount + 0].getValue()).add(currDependentValue.getValue());
                }
                if ((val & 4) == 4) {
                    results.get(controllingValues[baseCount + 1].getValue()).add(currDependentValue.getValue());
                }
                if ((val & 2) == 2) {
                    results.get(controllingValues[baseCount + 2].getValue()).add(currDependentValue.getValue());
                }
                if ((val & 1) == 1) {
                    results.get(controllingValues[baseCount + 3].getValue()).add(currDependentValue.getValue());
                }
                baseCount += 4;
            }
        }

        return results;
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
     * @description Returns the language.
     * @return An string value.
     */
    public static String getGlobalLanguage() {
        return FObject.language;
    }

    /**
     * @description Returns the locality.
     * @return An string value.
     */
    public static String getGlobalLocality() {
        return FObject.locality;
    }

    /**
     * @description Returns the group name.
     * @return The string of group name.
     */
    public String getGroupName() {
        return this.groupName;
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
     * @description Retrieves all inserted records of an SObject.
     * @param groupName The group name of the inserted records.
     * @return A list of SObjects.
     */
    public List<SObject> getInsertedGroupRecords(String groupName) {
        List<SObject> results = new List<SObject>();

        String thisGroupName = String.isBlank(groupName) ? '' : groupName;
        String key = thisGroupName.trim().toLowerCase();

        if (this.instanceInsertedRecordsMap.containsKey(key)) {
            results.addAll(this.instanceInsertedRecordsMap.get(key));
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
     * @param sObjectApiName The SObject API name.
     * @param groupName The group name of the inserted records.
     * @return A list of SObjects.
     */
    public static List<SObject> getInsertedGroupRecords(String sObjectApiName, String groupName) {
        List<SObject> results = new List<SObject>();

        Set<String> sObjectApiNamesSet = new Set<String>(FObject.sObjectApiNames);
        sObjectApiNamesSet = convertSetToLowercase(sObjectApiNamesSet);
        String thisSObjectApiName = sObjectApiName.trim().toLowerCase();

        if (!sObjectApiNamesSet.contains(thisSObjectApiName)) {
            FObject.processIsValid = false;
            String methodName = String.isBlank(groupName) ? 'getInsertedRecords' : 'getInsertedGroupRecords';
            FObject.postDebug(ERROR, DEBUG_LOG_PROMPT + SYMBOL_FAILURE + ' ' +
                'Invalid SObject [' + sObjectApiName + '] in static method ' + methodName, FObject.globalVerboseMode);
        }

        String thisGroupName = String.isBlank(groupName) ? '' : groupName;
        String key = thisSObjectApiName + '.' + thisGroupName.trim().toLowerCase();
        if (FObject.globalInsertedRecordsMap.containsKey(key)) {
            results.addAll(FObject.globalInsertedRecordsMap.get(key));
        }

        return results;
    }

    /**
     * @description Creates and inserts records for the lookup SObject.
     * @param lookupObjectApiName The API name of the lookup SObject.
     * @param lookupFieldApiName The API name of the lookup field.
     * @param groupName The group name for the inserted records.
     * @return A list of SObjects.
     */
    private List<SObject> getLookupRecords(String lookupObjectApiName, String lookupFieldApiName, String groupName) {
        List<SObject> results = new List<SObject>();
        FObject obj = new FObject(lookupObjectApiName, getDefaultRecords(this.records));

        // set lookup field's definition
        if (String.isNotBlank(lookupFieldApiName)) {
            Field field = obj.sObjectFieldsMap.get(lookupFieldApiName.toLowerCase());
            obj.setDefinitionFromField(field);
        }

        // set IsActive standard field
        if (this.excludeInactiveLookupRecords && obj.sObjectFieldsMap.containsKey('isactive')) {
            obj.setDefinition('IsActive', true, this.isFieldsUpdate, 'static value(true)');
        }

        obj.insertRecords(true, groupName);
        results = obj.getRecords();

        return results;
    }

    /**
     * @description Creates random IDs from a lookup SObject's records.
     * @param definition The definition string of the field.
     * @param command The lookup type (random or static).
     * @param source The source (forceea or salesforce) of the lookup SObject.
     * @param lookupObjectName The API name of the lookup SObject.
     * @param lookupFieldName The API name of the lookup field.
     * @param lookupValues The list of lookup values.
     * @param lookupExceptions The list of exception lookup values.
     * @param groupName The group name.
     * @param whereClause The where clause of the selection SOQL query.
     * @param lookupMode The where clause of the selection SOQL query.
     * @return A list of IDs.
     */
    private List<Id> getLookupValues(Definition definition, String command, String source,
        String lookupObjectName, String lookupFieldName, List<String> lookupValues,
        List<String> lookupExceptions, String groupName, String whereClause, String lookupMode) {

        List<Id> results = new List<Id>();
        List<SObject> lookupRecords = new List<SObject>(); // the lookup SObject's records
        String fieldApiName = definition.fieldApiName;

        // check if the SObject name is valid
        String lookupObjectApiName = FObject.getSObjectApiName(lookupObjectName);
        if (String.isBlank(lookupObjectApiName)) {
            addError(fieldApiName, 'Invalid lookup SObject [' + lookupObjectName + '] in definition [' +
                definition.definitionString + ']');
            if (processMustTerminate()) {
                return results;
            }
        }

        // get the SObject fields map
        if (!FObject.globalSObjectFieldsMap.containsKey(lookupObjectApiName.toLowerCase())) {
            FObject.setSObject(lookupObjectApiName);
        }

        // get stored fields details
        Map<String, Field> fieldsMap = FObject.globalSObjectFieldsMap.get(lookupObjectApiName.toLowerCase());

        // check if the lookup field API name is valid
        // the fieldName may be blank because of the definition random lookup(Object)
        String lookupFieldApiName = '';
        if (String.isNotBlank(lookupFieldName)) {
            if (fieldsMap.containsKey(lookupFieldName.toLowerCase())) { // if lookup field is found
                lookupFieldApiName = fieldsMap.get(lookupFieldName.toLowerCase()).fieldApiName;
            } else {
                addError(fieldApiName, 'Invalid lookup field [' + lookupFieldName + '] in definition [' +
                    definition.definitionString + ']');
                if (processMustTerminate()) {
                    return results;
                }
            }
        }

        // check if the source is valid
        if (!sourceIsValid(source)) {
            addError(fieldApiName, 'Invalid source [' + source + '] in definition [' +
                definition.definitionString + ']');
            if (processMustTerminate()) {
                return results;
            }
        }

        // validate lookup type
        if (String.isNotBlank(lookupMode) && !lookupModesSet.contains(lookupMode.toLowerCase())) {
            addError(fieldApiName,
                'Invalid syntax in definition [' + definition.definitionString + '] of field [' + fieldApiName + ']');
        }

        Boolean isActiveFieldExists = existsIsActiveStandardField(fieldsMap);

        if (source == SOURCE_FORCEEA) {
            Boolean thereAreNoInsertedRecords = false;
            String key = lookupObjectApiName.toLowerCase() + '.' + groupName.trim().toLowerCase() ;
            // if records have been inserted by Forceea for this group
            if (FObject.globalInsertedRecordsMap.containsKey(key)) {
                lookupRecords = FObject.globalInsertedRecordsMap.get(key);
            } else {
                thereAreNoInsertedRecords = true;
            }

            if (thereAreNoInsertedRecords && !definition.isSystemDeclared) {
                forceeaDebug(WARN, 'The required records of lookup [' + lookupObjectApiName +
                    '] have not been created by Forceea and will be created now');
                // create records for the lookup SObject
                lookupRecords = getLookupRecords(lookupObjectApiName, lookupFieldApiName, groupName);
            }
        }

        // if there are no inserted records and is a system-declared definition or if the source is salesforce
        if ((lookupRecords.isEmpty() && definition.isSystemDeclared) || source == SOURCE_SALESFORCE) {
            String soqlQuery = 'SELECT Id';
            // set soql query if there is a lookup field
            if (String.isNotBlank(lookupFieldName)) {
                soqlQuery += ', ' + lookupFieldApiName;
            }
            soqlQuery += ' FROM ' + lookupObjectApiName;
            if (String.isNotBlank(whereClause)) {
                soqlQuery += ' WHERE ' + whereClause;
            }
            if (this.excludeInactiveLookupRecords && isActiveFieldExists) { // must set IsActive field
                if (String.isBlank(whereClause)) {
                    soqlQuery += ' WHERE IsActive = true';
                } else {
                    soqlQuery += ' AND IsActive = true';
                }
            }
            soqlQuery += ' LIMIT ' + String.valueOf(this.queryLimit);

            try { //query the database and get the IDs
                lookupRecords = Database.query(soqlQuery);
            } catch (QueryException ex) {
                addError(fieldApiName, MESSAGE_FOUND_ERRORS_SELECTING_FROM_LOOKUP + ' [' + lookupObjectApiName +
                    '] of [' + this.sObjectApiName + ']: ' + ex.getMessage());
            } finally {
                if (processMustTerminate()) {
                    return results;
                }
            }
        }

        // if there are no inserted records and is a system-declared definition
        if (lookupRecords.isEmpty() && definition.isSystemDeclared) {
            lookupRecords = getLookupRecords(lookupObjectApiName, lookupFieldApiName, groupName); // create records for the lookup SObject
        }

        if (command == 'static') {
            results = getStaticLookupValues(lookupRecords, lookupValues, lookupFieldApiName);
        } else if (command == 'random') {
            results = getRandomLookupValues(lookupRecords, lookupValues, lookupExceptions, lookupFieldApiName, fieldApiName);
        } else if (command == 'serial') {
            results = getSerialLookupValues(lookupRecords, lookupMode);
        }

        return results;
    }

    /**
     * @description Creates mocked IDs.
     * @param sObjectType The SObject type.
     * @return A list of string values.
     */
    private List<String> getMockedIds(Schema.SObjectType sObjectType) {
        List<String> results = new List<String>();
        String prefix = SObjectType.getDescribe().getKeyPrefix() + 'mock';

        for (Integer counter = 0; counter < this.records; counter++) {
            String serialNumber = String.valueOf(FObject.mockingSerialNumber++);
            results.add(prefix + '0'.repeat(8 - serialNumber.length()) + serialNumber);
        }

        return results;
    }

    /**
     * @description Returns the next record number of the SObject.
     * @return The serialized record number of next record.
     */
    public Integer getNumberOfNextRecord() {
        return FObject.numFirstRecordsBySObject.get(this.sObjectApiName);
    }

    /**
     * @description Returns the number of records.
     * @return An integer value.
     */
    public Integer getNumberOfRecords() {
        return this.records;
    }

    /**
     * @description Retrieves the API name of an SObject or an empty string if the name is invalid.
     * @param sObjectApiName The SObject API name.
     * @return A string value.
     */
    private static String getSObjectApiName(String sObjectApiName) {
        String result = '';
        sObjectApiName = sObjectApiName.trim().toLowerCase();

        for (String objectApiName : FObject.sObjectApiNames) {
            if (objectApiName.toLowerCase() == sObjectApiName) { // SObject is found
                result = objectApiName;
                break;
            }
        }

        return result;
    }

    /**
     * @description Returns the API name of the Partition field.
     * @return A string value of the Partition field name.
     */
    public String getPartitionFieldName() {
        return this.partitionFieldName;
    }

    /**
     * @description Creates random picklist values, respecting the fields dependencies.
     * @param dependentFieldApiName The API name of the dependent field.
     * @param controllingFieldApiName The API name of the controlling field.
     * @param inclusions The picklist values to keep.
     * @param exceptions The picklist values to remove.
     * @return A list of string values.
     */
    private List<String> getPicklistValuesWithRespect(String dependentFieldApiName, String controllingFieldApiName,
        List<String> inclusions, List<String> exceptions) {
        List<String> results = new List<String>();

        // get the position of the controlling field
        Integer ctrlFieldPosition = getFieldPosition(controllingFieldApiName);

        // get the Field Dependencies map (key: controlling field value, value: dependent field values)
        Map<String, Set<String>> fieldDependenciesMap =
            getFieldDependenciesMap(this.sObjectApiName, controllingFieldApiName, dependentFieldApiName);

        // amend the Field Dependencies map based on the inclusions and exceptions
        if (inclusions != null) { // && !inclusions.isEmpty()
            // keep in the Field Dependencies map only the values of inclusions list
            for (String value : fieldDependenciesMap.keySet()) { // for each controlling field value
                // remove any value, except from inclusions
                fieldDependenciesMap.get(value).retainAll(inclusions);
            }
        } else if (exceptions != null) { // && !exceptions.isEmpty()
            // remove the values of the exceptions list from the Field Dependencies map
            for (String value : fieldDependenciesMap.keySet()) { // for each controlling field value
                fieldDependenciesMap.get(value).removeAll(exceptions); // remove the except values from the set
            }
        }

        // get the created values of controlling field
        List<String> ctrlFieldValues = this.fieldValuesMatrix.get(ctrlFieldPosition);

        List<String> depFieldValues = new List<String>();

        // the dependent field's values mapped to the controlling field's value
        Set<String> fieldDependenciesSet = new Set<String>();
        String ctrlValue = '';
        Integer rnd = 0;
        for (Integer counter = 0; counter < this.records; counter++) {
            // get the controlling field's value
            ctrlValue = ctrlFieldValues[counter];

            // get the dependent field's value set from the Field Dependencies map
            fieldDependenciesSet = fieldDependenciesMap.get(ctrlValue);
            // if there are no mapped values between controlling and dependent field
            if (fieldDependenciesSet == null || fieldDependenciesSet.isEmpty()) {
                results.add(''); // add an empty string to results
            } else { // there at least one value
                // get the dependent field's value list
                depFieldValues = new List<String>(fieldDependenciesSet);
                // get a random value
                rnd = (FObject.random * depFieldValues.size()).intValue();
                results.add(depFieldValues[rnd]);
            }
        }

        return results;
    }

    /**
     * @description Creates random picklist values when there are no fields dependencies.
     * @param picklistValues The piclist values list.
     * @return A list of string values.
     */
    private List<String> getPicklistValuesWithoutRespect(List<String> picklistValues) {
        List<String> values = new List<String>();

        Integer size = picklistValues.size();
        if (size == 0) {
            return values;
        } else if (size == 1) {
            for (Integer counter = 0; counter < this.records; counter++) {
                values.add(picklistValues[0]);
            }
        } else {
            Integer rnd = 0;
            for (Integer counter = 0; counter < this.records; counter++) {
                rnd = (FObject.random * size).intValue();
                values.add(picklistValues[rnd]);
            }
        }

        return values;
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
     * @description Creates random addresses having street (with number), postal code, city, state and country.
     * @return A list of FAddress objects.
     */
    private List<FAddress> getRandomAddresses() {
        List<FAddress> values = new List<FAddress>();
        Integer rnd = 0;

        FObject.loadAddresses();
        Integer librarySize = FObject.addressesLibrary.size();

        for (Integer counter = 0; counter < this.records; counter++) {
            rnd = (FObject.random * librarySize).intValue();
            values.add(new FAddress(FObject.addressesLibrary[rnd]));
        }

        return values;
    }

    /**
     * @description Creates random booleans.
     * @return A list of string values.
     */
    private List<String> getRandomBooleans() {
        List<String> values = new List<String>();

        for (Integer counter = 0; counter < this.records; counter++) {
            if (FObject.random > 0.5) {
                values.add('true');
            } else {
                values.add('false');
            }
        }

        return values;
    }

    /**
     * @description Creates random cities.
     * @param addressGroup The group of this address.
     * @return A list of string values.
     */
    private List<String> getRandomCities(String addressGroup) {
        List<String> values = new List<String>();

        // create addresses if needed
        List<FAddress> groupAddresses = this.addressesMap.get(addressGroup);
        if (groupAddresses == null || groupAddresses.isEmpty()) {
            // set random addresses
            this.addressesMap.put(addressGroup, getRandomAddresses());
            // get created addresses
            groupAddresses = this.addressesMap.get(addressGroup);
        }

        for (Integer counter = 0; counter < this.records; counter++) {
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
        List<FAddress> groupAddresses = this.addressesMap.get(addressGroup);
        if (groupAddresses == null || groupAddresses.isEmpty()) {
            // set random addresses
            this.addressesMap.put(addressGroup, getRandomAddresses());
            // get created addresses
            groupAddresses = this.addressesMap.get(addressGroup);
        }

        for (Integer counter = 0; counter < this.records; counter++) {
            values.add(groupAddresses[counter].country);
        }

        return values;
    }

    /**
     * @description Creates random dates.
     * @param fromDate The minimum date.
     * @param toDate The maximum date.
     * @param definition The field definition.
     * @return A list of string values.
     */
    private List<String> getRandomDates(Date fromDate, Date toDate, Definition definition) {
        List<String> values = new List<String>();

        // check arguments
        if (fromDate >= toDate) {
            addError(definition.fieldApiName, 'The [from] date is greater than or equal to ' +
                'the [to] date in definition [' + definition.definitionString + ']');
            return values;
        }

        Integer range = fromDate.daysBetween(toDate) + 1;
        Integer days = 0; // the number of days to add to fromDate
        for (Integer counter = 0; counter < this.records; counter++) {
            days = (FObject.random * range).intValue();
            values.add(String.valueOf(fromDate.addDays(days)));
        }

        return values;
    }

    /**
     * @description Returns a list of random datetime values.
     * @param fromDatetime The minimum datetime.
     * @param toDatetime The maximum datetime.
     * @param definition The field definition.
     * @return A list of string values.
     */
    private List<String> getRandomDatetimes(Datetime fromDatetime, Datetime toDatetime, Definition definition) {
        List<String> values = new List<String>();

        Boolean fromIsDate = false;
        Boolean toIsDate = false;
        if (fromDatetime.hour() == 0 && fromDatetime.minute() == 0 && fromDatetime.second() == 0) {
            fromIsDate = true;
        }
        if (toDatetime.hour() == 0 && toDatetime.minute() == 0 && toDatetime.second() == 0) {
            toIsDate = true;
        }

        if (fromIsDate && toIsDate && fromDatetime == toDatetime) { // from = to and both are dates
            toDatetime = toDatetime.addSeconds(86399); // add: 24h - 1s
        } else if (!fromIsDate && toIsDate) {
            toDatetime = toDatetime.addSeconds(86399); // add: 24h - 1s
        }

        Long fromDatetimePoint = fromDatetime.getTime(); // ms from 1/1/1970
        Long toDatetimePoint = toDatetime.getTime(); // ms from 1/1/1970

        // check arguments
        if (fromDatetimePoint >= toDatetimePoint) {
            addError(definition.fieldApiName, 'The [from] datetime is greater than or equal to ' +
                'the [to] datetime in definition [' + definition.definitionString + ']');
            return values;
        }

        Long range = toDatetimePoint - fromDatetimePoint;
        Long randomPoint; // a random value in ms
        for (Integer counter = 0; counter < this.records; counter++) {
            randomPoint = fromDatetimePoint + (FObject.random * range).longValue();
            values.add(String.valueOf(Datetime.newInstance(randomPoint)));
        }

        return values;
    }

    /**
     * @description Returns a list of random decimals.
     * @param fromNumber The minimum decimal.
     * @param toNumber The maximum decimal.
     * @param scale The number of decimal places.
     * @param definition The field definition.
     * @return A list of string values.
     */
    private List<String> getRandomNumbers(Decimal fromNumber, Decimal toNumber, Integer scale,
        Definition definition) {
        List<String> values = new List<String>();
        fromNumber = fromNumber.setScale(scale);
        toNumber = toNumber.setScale(scale);

        // check arguments
        if (fromNumber >= toNumber) {
            addError(definition.fieldApiName, 'The [from] number is greater than or equal to ' +
                'the [to] number in definition [' + definition.definitionString + ']');
        }

        Decimal range = toNumber - fromNumber;
        Decimal val = 0;
        for (Integer counter = 0; counter < this.records; counter++) {
            val = fromNumber + FObject.random * range;
            values.add(val.setScale(scale).toPlainString());
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

        for (Integer counter1 = 0; counter1 < this.records; counter1++) {
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
     * @description Returns a list of random emails.
     * @param definition The field definition.
     * @return A list of string values.
     */
    private List<String> getRandomEmails(Definition definition) {
        List<String> values = new List<String>();
        List<String> includes = new List<String>{
            'lower'
        };
        List<String> names = getRandomStrings(10, 10, 'lower', includes, definition);
        List<String> domains = getRandomDomains(5);

        for (Integer counter = 0; counter < this.records; counter++) {
            values.add(names[counter] + '@' + domains[counter]);
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

        if (this.namesMap.get(nameGroup) == null) { // there are no created names for this group
            this.namesMap.put(nameGroup, getRandomNames()); // create names
        }

        List<Name> groupNames = this.namesMap.get(nameGroup); // get the first names for the group

        // get the first names
        for (Integer counter = 0; counter < this.records; counter++) {
            values.add(groupNames[counter].FirstName);
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

        if (this.namesMap.get(nameGroup) == null) { // there are no created names for this group
            this.namesMap.put(nameGroup, getRandomNames()); // create names
        }

        List<Name> groupNames = this.namesMap.get(nameGroup); // get the first names for the group
        for (Integer counter = 0; counter < this.records; counter++) {
            values.add(groupNames[counter].LastName);
        }

        return values;
    }

    /**
     * @description Creates random picklist values from a list.
     * @param definition The field definition.
     * @return A list of string values.
     */
    private List<String> getRandomListValuesForPicklists(Definition definition) {
        List<String> arguments = getClusterArguments('value', definition.clusters);
        List<String> values = new List<String>();
        String fieldApiName = definition.fieldApiName;

        // get all picklist values
        List<String> picklistValues = new List<String>();
        for (Schema.PicklistEntry picklistEntry : this.sObjectFieldsMap.get(fieldApiName.toLowerCase()).pickListValues) {
            picklistValues.add(picklistEntry.getValue());
        }

        // get field data type
        Field depField = this.sObjectFieldsMap.get(fieldApiName.toLowerCase());

        // convert arguments to lowercase
        arguments = convertListToLowercase(arguments);

        // get controlling field's API name
        String ctrlFieldApiName = depField.controllingFieldApiName;

        if (depField.isRestrictedPicklist) { // if the field is restricted
            arguments = keepValuesInList(arguments, picklistValues); // remove arguments which are not valid picklist values
        }

        if (String.isBlank(ctrlFieldApiName) || // the controlling field is a Checkbox or there is no controlling field
            this.sObjectFieldsMap.get(ctrlFieldApiName.toLowerCase()).dataType == Schema.DisplayType.Boolean) {
            values = getPicklistValuesWithoutRespect(arguments);
        } else { // there is a controlling field
            values = getPicklistValuesWithRespect(fieldApiName, ctrlFieldApiName, arguments, null);
        }

        return values;
    }

    /**
     * @description Creates random field values from a list.
     * @param definition The field definition.
     * @return A list of string values.
     */
    private List<String> getRandomListValues(Definition definition) {
        Set<String> argumentsSet = new Set<String>(getClusterArguments('value', definition.clusters));

        List<String> values = new List<String>();
        String fieldApiName = definition.fieldApiName;
        Integer size = 0;
        Integer rnd = 0;

        if (fieldApiName == 'RecordTypeId') {
            // get the list of record type IDs
            List<Id> recordTypeIds = new List<Id>();
            for (String argument : argumentsSet) {
                if (this.recordTypesMap.containsKey(argument.toLowerCase())) { // if the argument is a valid record type
                    recordTypeIds.add(this.recordTypesMap.get(argument.toLowerCase())); // add the argument's ID to a list
                } else {
                    addError(fieldApiName, 'Invalid record type [' + argument + '] for definition [' +
                        definition.definitionString + ']');
                }
            }

            if (processMustTerminate()) {
                return values;
            }

            size = recordTypeIds.size();
            if (size == 1) {
                Id recordTypeId = recordTypeIds[0];
                for (Integer counter = 0; counter < this.records; counter++) {
                    values.add(recordTypeId);
                }
            } else {
                for (Integer counter = 0; counter < this.records; counter++) {
                    rnd = (FObject.random * size).intValue();
                    values.add(recordTypeIds[rnd]);
                }
            }

            return values;
        }

        // get field data type
        Schema.DisplayType fieldDataType = this.sObjectFieldsMap.get(definition.fieldApiName.toLowerCase()).dataType;

        // set values
        if (fieldDataType == Schema.DisplayType.Picklist || fieldDataType == Schema.DisplayType.MultiPicklist) {
            return getRandomListValuesForPicklists(definition); // is a picklist field
        } else { // is not a picklist field
            List<String> arguments = new List<String>(argumentsSet);
            size = arguments.size();
            for (Integer counter = 0; counter < this.records; counter++) {
                rnd = (FObject.random * size).intValue();
                values.add(arguments[rnd]);
            }
        }

        return values;
    }

    /**
     * @description Creates random IDs from a lookup SObject's records.
     * @param lookupRecords The list of lookup records.
     * @param lookupValues The list of lookup values.
     * @param lookupExceptions The list of exception lookup values.
     * @param lookupFieldApiName The API name of the lookup field.
     * @param fieldApiName The API name of the field.
     * @return A list of IDs.
     */
    private List<Id> getRandomLookupValues(List<SObject> lookupRecords, List<String> lookupValues,
        List<String> lookupExceptions, String lookupFieldApiName, String fieldApiName) {
        List<Id> results = new List<Id>();

        List<Id> lookupIds = new List<Id>();
        Boolean thereAreLookupValues = !(lookupValues == null || lookupValues.isEmpty());
        Boolean thereAreLookupExceptions = !(lookupExceptions == null || lookupExceptions.isEmpty());

        if (!thereAreLookupValues && !thereAreLookupExceptions) {
            for (SObject objRecord : lookupRecords) {
                lookupIds.add(objRecord.Id);
            }
        } else if (thereAreLookupValues && !thereAreLookupExceptions) {
            Set<String> lookupValuesSet = new Set<String>(lookupValues);
            lookupValuesSet = convertSetToLowercase(lookupValuesSet);
            String fieldValue = '';
            for (SObject objRecord : lookupRecords) {
                fieldValue = (String) objRecord.get(lookupFieldApiName);
                if (String.isNotBlank(fieldValue) && lookupValuesSet.contains(fieldValue.toLowerCase())) {
                    lookupIds.add(objRecord.Id);
                }
            }
        } else if (!thereAreLookupValues && thereAreLookupExceptions) {
            Set<String> lookupExceptionsSet = new Set<String>(lookupExceptions);
            lookupExceptionsSet = convertSetToLowercase(lookupExceptionsSet);
            String fieldValue = '';
            for (SObject objRecord : lookupRecords) {
                fieldValue = (String) objRecord.get(lookupFieldApiName);
                if (String.isNotBlank(fieldValue) && !lookupExceptionsSet.contains(fieldValue)) { // if exception value is not found
                    lookupIds.add(objRecord.Id);
                }
            }
        } else {
            addError(fieldApiName, 'System Error: Invalid lookup type');
        }

        // get the values
        Integer size = lookupIds.size();
        Integer rnd = 0;
        if (size == 0) {
            return results;
        }
        if (size == 1) {
            for (Integer counter = 0; counter < this.records; counter++) {
                results.add(lookupIds[0]);
            }
        } else if (size > 1) {
            for (Integer counter = 0; counter < this.records; counter++) {
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
    private List<Name> getRandomNames() {
        List<Name> results = new List<Name>();

        String firstName = '';
        String lastName = '';
        String gender = '';
        Integer firstNamesSize = 0; // the size of the first names list
        Integer lastNamesSize = 0; // the size of the last names list
        Integer vFirst = 0; // a random index for the first name
        Integer vLast = 0; // a random index for the last name
        Integer counterNames = 0; // a counter of created names
        Integer counterGroups = 0; // a counter of groups

        FObject.loadNames();
        Integer numGroups = FObject.lastNamesLibraryMap.size(); // the nuber of groups

        // get the size of each locality/gender group
        Integer groupSize = this.records / numGroups;

        for (String key : FObject.lastNamesLibraryMap.keySet()) { // for each group
            // get the data (first & last name lists)
            List<String> firstNames = FObject.firstNamesLibraryMap.get(key);
            List<String> lastNames = FObject.lastNamesLibraryMap.get(key);
            // get the size of lists
            firstNamesSize = firstNames.size();
            lastNamesSize = lastNames.size();
            // get gender
            gender = key;
            // check if this is the last group
            counterGroups++;
            if (counterGroups == numGroups) {
                groupSize = this.records - counterNames;
            } else {
                counterNames += groupSize;
            }
            // set values
            for (Integer counter = 0; counter < groupSize; counter++) {
                vFirst = (FObject.random * firstNamesSize).intValue();
                firstName = firstNames[vFirst];
                vLast = (FObject.random * lastNamesSize).intValue();
                lastName = lastNames[vLast];
                results.add(new Name(firstName, lastName, gender));
            }
        }

        // randomize names
        Integer rnd = 0;
        Name temp = new Name();
        Integer size = results.size();
        for (Integer counter = 0; counter < size; counter++) {
            rnd = (FObject.random * size).intValue(); // get a random index
            temp = results[counter] ;
            results[counter] = results[rnd];
            results[rnd] = temp;
        }

        return results;
    }

    /**
     * @description Creates random phone numbers.
     * @param formatString The format string which defines the phone numbers.
     * @return A list of strings (phone numbers).
     */
    private List<String> getRandomPhoneNumbers(String formatString) {
        List<String> results = new List<String>();

        String thisFormatString = formatString.trim();

        for (Integer counter = 0; counter < this.records; counter++) {
            results.add('');
        }

        for (Integer counter = 0; counter < thisFormatString.length(); counter++) {
            Integer charNumber = thisFormatString.charAt(counter);

            if (charNumber == 100) { // d
                results = addPhoneDigitsOfTypeLowerD(results);
            } else if (charNumber == 68) { // D
                results = addPhoneDigitsOfTypeUpperD(results);
            } else {
                results = addPhoneDigitsOfSameType(results, thisFormatString.mid(counter, 1));
            }
        }

        return results;
    }

    /**
     * @description Creates random picklist values.
     * @param fieldApiName The API name of a field.
     * @return A list of string values.
     */
    private List<String> getRandomPicklistValues(String fieldApiName) {
        List<String> results = new List<String>();

        if (fieldApiName == 'RecordTypeId') {
            // create a new list with the record type values
            List<Id> recordTypeIds = new List<Id>(this.recordTypesMap.values());

            Integer size = recordTypeIds.size();
            if (size == 1) {
                Id recordTypeId = recordTypeIds[0];
                for (Integer counter = 0; counter < this.records; counter++) {
                    results.add(recordTypeId);
                }
            } else {
                Integer rnd = 0;
                for (Integer counter = 0; counter < this.records; counter++) {
                    rnd = (FObject.random * size).intValue();
                    results.add(recordTypeIds[rnd]);
                }
            }
            return results;
        }

        // get dependent field and controlling field
        Field dependentField = this.sObjectFieldsMap.get(fieldApiName.toLowerCase());
        String ctrlFieldApiName = dependentField.controllingFieldApiName;

        if (String.isBlank(ctrlFieldApiName) || // the controlling field is a Checkbox or there is no controlling field
            this.sObjectFieldsMap.get(ctrlFieldApiName.toLowerCase()).dataType == Schema.DisplayType.Boolean) {
            // get all picklist values
            List<String> picklistValues = new List<String>(); // the picklist items
            for (Schema.PicklistEntry picklistEntry : this.sObjectFieldsMap.get(fieldApiName.toLowerCase()).pickListValues) {
                picklistValues.add(picklistEntry.getValue());
            }
            results = getPicklistValuesWithoutRespect(picklistValues);
        } else { // there is a controlling field
            results = getPicklistValuesWithRespect(fieldApiName, ctrlFieldApiName, null, null);
        }

        return results;
    }

    /**
     * @description Creates random picklist values, excluding specific values.
     * @param fieldApiName The API name of a field.
     * @param exceptions A list of exceptions from the picklist items.
     * @return A list of string values.
     */
    private List<String> getRandomPicklistValuesExcept(String fieldApiName, List<String> exceptions) {
        List<String> results = new List<String>();

        // convert exceptions to lowercase
        exceptions = new List<String>(convertListToLowercase(exceptions));

        if (fieldApiName == 'RecordTypeId') {
            // create a new list with the record type values, excluding exceptions
            List<Id> recordTypeIds = new List<Id>();
            Set<String> exceptionsSet = new Set<String>(exceptions);
            for (String recordTypeDevName : this.recordTypesMap.keySet()) {
                if (!exceptionsSet.contains(recordTypeDevName.toLowerCase())) {
                    recordTypeIds.add(this.recordTypesMap.get(recordTypeDevName));
                }
            }

            Integer size = recordTypeIds.size();
            if (size == 0) {
                return results;
            } else if (size == 1) {
                for (Integer counter = 0; counter < this.records; counter++) {
                    results.add(recordTypeIds[0]);
                }
            } else {
                Integer rnd = 0;
                for (Integer counter = 0; counter < this.records; counter++) {
                    rnd = (FObject.random * size).intValue();
                    results.add(recordTypeIds[rnd]);
                }
            }

            return results;
        }

        // get dependent and controlling fields
        Field depField = this.sObjectFieldsMap.get(fieldApiName.toLowerCase());
        String ctrlFieldApiName = depField.controllingFieldApiName;

        if (String.isBlank(ctrlFieldApiName) || // the controlling field is a Checkbox or there is no controlling field
            this.sObjectFieldsMap.get(ctrlFieldApiName.toLowerCase()).dataType == Schema.DisplayType.Boolean) {
            // get all picklist items
            List<String> picklistValues = new List<String>(); // the picklist items
            for (Schema.PicklistEntry picklistEntry : this.sObjectFieldsMap.get(fieldApiName.toLowerCase()).pickListValues) {
                picklistValues.add(picklistEntry.getValue());
            }
            picklistValues = new List<String>(removeValuesFromList(picklistValues, exceptions));
            results = getPicklistValuesWithoutRespect(picklistValues);
        } else { // there is a controlling field
            results = getPicklistValuesWithRespect(fieldApiName, ctrlFieldApiName, null, exceptions);
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
        List<FAddress> groupAddresses = this.addressesMap.get(addressGroup);
        if (groupAddresses == null || groupAddresses.isEmpty()) {
            this.addressesMap.put(addressGroup, getRandomAddresses());  // set random addresses
            groupAddresses = this.addressesMap.get(addressGroup); // get created addresses
        }

        for (Integer counter = 0; counter < this.records; counter++) {
            results.add(groupAddresses[counter].postalCode);
        }

        return results;
    }

    /**
     * @description Creates random states.
     * @param addressGroup The group of this address.
     * @return A list of string values.
     */
    private List<String> getRandomStates(String addressGroup) {
        List<String> results = new List<String>();

        // create addresses if needed
        List<FAddress> groupAddresses = this.addressesMap.get(addressGroup);
        if (groupAddresses == null || groupAddresses.isEmpty()) {
            // set random addresses
            this.addressesMap.put(addressGroup, getRandomAddresses());
            // get created addresses
            groupAddresses = this.addressesMap.get(addressGroup);
        }

        for (Integer counter = 0; counter < this.records; counter++) {
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
        List<FAddress> groupAddresses = this.addressesMap.get(addressGroup);
        if (groupAddresses == null || groupAddresses.isEmpty()) {
            // set random addresses
            this.addressesMap.put(addressGroup, getRandomAddresses());
            // get created addresses
            groupAddresses = this.addressesMap.get(addressGroup);
        }

        Integer rnd = 0;
        String street = '';

        for (Integer counter = 0; counter < this.records; counter++) {
            street = groupAddresses[counter].street;
            rnd = (FObject.random * 20).intValue() + 1; // get a random number from 1 to 20
            if (FObject.streetNumberGoesAfterStreet) { // number is after street
                street = street + ' ' + String.valueOf(rnd);
            } else { // number is before street
                street = String.valueOf(rnd) + ' ' + street;
            }
            results.add(street);
        }

        return results;
    }

    /**
     * @description Creates random strings.
     * @param minlength The minimum length of the string values.
     * @param maxlength The maximum length of the string values.
     * @param startsWith The type of the first character (upper/lower/digit).
     * @param includes The types of characters in the string (upper/lower/digit).
     * @param definition The field definition.
     * @return A list of string values.
     */
    private List<String> getRandomStrings(
        Integer minlength, Integer maxlength, String startsWith, List<String> includes, Definition definition) {
        List<String> results = new List<String>();
        String lowerChars = 'abcdefghijklmnopqrstuvwxyz';
        String upperChars = 'ABCDEFGHIJKLMNOPQRSUVWXYZ';
        String digits = '0123456789';
        String charsToSelect = ''; // the selection chars for the rest of the string

        // check arguments
        if (minlength <= 0) {
            addError(definition.fieldApiName, 'The minimum length should be greater than or equal to 1 ' +
                'in definition [' + definition.definitionString + ']');
        }
        if (minlength > maxlength) {
            addError(definition.fieldApiName, 'The minimum length should be less than or equal to ' +
                'the maximum length in definition [' + definition.definitionString + ']');
        }

        // define the chars to select from
        for (String item : convertListToLowercase(includes)) {
            if (item == 'lower') {
                charsToSelect += lowerChars;
            } else if (item == 'upper') {
                charsToSelect += upperChars;
            } else if (item == 'digit') {
                charsToSelect += digits;
            }
        }

        Integer rnd = 0; // a random position
        Integer resultLength = 0; // the random length of each string
        Integer size; // the size of a string
        String firstChar = '';
        String selectionsForFirstChar = ''; // the first char of the string
        String restChars = ''; // the rest chars of the string

        for (Integer counter1 = 0; counter1 < this.records; counter1++) {
            resultLength = minlength + (FObject.random * (maxlength - minlength + 1)).intValue();
            // get 1st char
            if (startsWith == 'lower') {
                selectionsForFirstChar = lowerChars;
            } else if (startsWith == 'upper') {
                selectionsForFirstChar = upperChars;
            } else if (startsWith == 'digit') {
                selectionsForFirstChar = digits;
            }
            size = selectionsForFirstChar.length();
            rnd = (FObject.random * size).intValue();
            firstChar = selectionsForFirstChar.substring(rnd, rnd + 1);
            size = charsToSelect.length();
            restChars = '';
            for (Integer counter2 = 1; counter2 < resultLength; counter2++) {
                rnd = (FObject.random * size).intValue();
                restChars += charsToSelect.substring(rnd, rnd + 1);
            }
            results.add(firstChar + restChars);
        }

        return results;
    }

    /**
     * @description Creates random texts.
     * @param minLength The length of the text.
     * @param maxLength The length of the text.
     * @param definition The field definition.
     * @return A list of string values.
     */
    private List<String> getRandomTexts(Integer minLength, Integer maxLength, Definition definition) {
        List<String> results = new List<String>();
        List<String> words = new List<String>{
            'lorem', 'ipsum', 'dolor', 'sit', 'amet', 'tempor', 'aboreant',
            'eu', 'nos', 'a', 'quo', 'magna', 'primis', 'labore', 'usi', 'virtute', 'fabellas', 'vis', 'duis',
            'scripta', 'laudem', 'commune', 'nam', 'laoreet', 'propriae', 'ea', 'partem',
            'inermis', 'ius', 'sint', 'impedit', 'eam', 'elit', 'nusquam'
        };
        Map<Integer, List<String>> wordsByLength = new Map<Integer, List<String>>{
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

        // check arguments
        if (minLength <= 0) {
            addError(definition.fieldApiName, 'The minimum length should be greater than or equal to 1 ' +
                'in definition [' + definition.definitionString + ']');
        }
        if (minLength >= maxLength) {
            addError(definition.fieldApiName, 'The minimum length should be less than the maximum length ' +
                'in definition [' + definition.definitionString + ']');
        }

        if (processMustTerminate()) {
            return results;
        }

        String result = '';
        Integer rnd = 0;
        Integer randomLength = 0;
        Integer newLength = 0;
        String previousWord = '';
        String newWord = '';
        Integer numWords = words.size();
        for (Integer counter = 0; counter < this.records; counter++) {
            result = '';
            randomLength = (FObject.random * (maxLength - minLength)).intValue() + minLength;

            do {
                rnd = (FObject.random * numWords).intValue();
                newWord = words.get(rnd);
                newLength = (result + newWord).length();
                if (previousWord != newWord && newLength <= randomLength) {
                    result += newWord + ' ';
                    previousWord = newWord;
                }
            } while (newLength <= (randomLength + 1));

            result = result.trim();
            if (result.length() < minLength) {
                Integer additionalLength = randomLength - result.length();

                List<String> additionalWords = wordsByLength.get(additionalLength);
                Integer i = 0;
                do {
                    newWord = additionalWords.get(i);
                    i++;
                } while (previousWord == newWord);
                result += ' ' + newWord;
            }
            results.add(result.trim().capitalize());
        }

        return results;
    }

    /**
     * @description Creates random URLs.
     * @return A list of string values.
     */
    private List<String> getRandomUrls() {
        List<String> results = new List<String>();
        List<String> domains = getRandomDomains(5);

        for (Integer counter = 0; counter < this.records; counter++) {
            results.add('http://www.' + domains[counter]);
        }

        return results;
    }

    /**
     * @description Creates an SObject record.
     * @param recordCounter The number of the record.
     * @return An SObject.
     */
    private SObject getRecord(Integer recordCounter) {
        SObject result = this.sObjType.newSObject();

        for (Integer fieldCounter = 0; fieldCounter < this.fields.size(); fieldCounter++) {
            String fieldName = this.fields.get(fieldCounter);

            if (fieldIsVirtual(fieldName)) {
                continue;
            }

            String fieldValue = this.fieldValuesMatrix.get(fieldCounter).get(recordCounter).trim();
            if (String.isBlank(fieldValue)) {
                continue;
            }

            Schema.DisplayType valueType = this.sObjectFieldsMap.get(fieldName.toLowerCase()).dataType;

            try {
	            setSObjectFieldValue(result, valueType, fieldName, fieldValue);
            } catch (TypeException ex) {
                addError(fieldName, 'Invalid value for record #' + recordCounter +
                    ' of field [' + fieldName + ']');
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
     * @description Creates serial date values.
     * @param fromDate The starting date value.
     * @param stepDays The number of days added to previous date value.
     * @return A list of string values.
     */
    private List<String> getSerialDates(Date fromDate, Integer stepDays) {
        List<String> results = new List<String>();
        Date val = fromDate.addDays((getNumberOfNextRecord() - 1) * stepDays);

        for (Integer counter = 0; counter < this.records; counter++) {
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

        for (Integer counter = 0; counter < this.records; counter++) {
            results.add(String.valueOf(val));
            val = val.addDays(stepDays);
            val = val.addHours(stepHours);
            val = val.addMinutes(stepMinutes);
            val = val.addSeconds(stepSeconds);
        }

        return results;
    }

    /**
     * @description Creates serial lookup IDs.
     * @param lookupRecords The list of lookup records.
     * @param lookupType The type of the lookup operation.
     * @return A list of IDs.
     */
    private List<Id> getSerialLookupValues(List<SObject> lookupRecords, String lookupType) {
        List<Id> results = new List<Id>();

        List<Id> lookupIds = new List<Id>();
        for (SObject objRecord : lookupRecords) {
            lookupIds.add(objRecord.Id);
        }

        Integer size = lookupIds.size();
        if (size == 0) {
            return results;
        }

        String type = lookupType.toLowerCase();
        Integer lookupCounter = 0;
        switch on type {
            when 'cyclical' {
                for (Integer recordCounter = 0; recordCounter < this.records; recordCounter++) {
                    if (lookupCounter == size) {
                        lookupCounter = 0;
                    }
                    results.add(lookupIds.get(lookupCounter));
                    lookupCounter++;
                }
            }
            when 'first' {
                for (Integer recordCounter = 0; recordCounter < this.records; recordCounter++) {
                    if (recordCounter >= size) {
                        lookupCounter = 0;
                    }
                    results.add(lookupIds.get(lookupCounter));
                    lookupCounter++;
                }
            }
            when 'last' {
                for (Integer recordCounter = 0; recordCounter < this.records; recordCounter++) {
                    if (recordCounter >= size) {
                        lookupCounter = (size - 1);
                    }
                    results.add(lookupIds.get(lookupCounter));
                    lookupCounter++;
                }
            }
            when 'null' {
                size = (size > this.records ? this.records : size);
                for (Integer recordCounter = 0; recordCounter < size; recordCounter++) {
                    results.add(lookupIds.get(recordCounter));
                }
            }
        }

        return results;
    }

    /**
     * @description Creates serial decimal values.
     * @param fromNumber The starting decimal value.
     * @param stepNumber The value added to previous decimal value.
     * @param scale The number of decimal places.
     * @return A list of string values.
     */
    private List<String> getSerialNumbers(Decimal fromNumber, Decimal stepNumber, Integer scale) {
        List<String> results = new List<String>();

        Decimal val = fromNumber + (getNumberOfNextRecord() - 1) * stepNumber;
        for (Integer counter = 0; counter < this.records; counter++) {
            results.add(val.setScale(scale).toPlainString());
            val += stepNumber;
        }

        return results;
    }

    /**
     * @description Returns the SObject API name.
     * @return A string value of the SObject name.
     */
    public String getSObjectName() {
        return this.sObjectApiName;
    }

	/**
	 * @description Retrieves the active Standard Pricebook ID.
	 * @return The Standard Price-book ID.
	 */
	private Id getStandardPriceBookId() {
		Id result;

		if (Test.isRunningTest()) {
			result = Test.getStandardPricebookId();
		} else {
			List<Pricebook2> standardPriceBooks = [
				SELECT Id
				FROM Pricebook2
				WHERE IsStandard = TRUE AND IsActive = TRUE
			];
			if (!standardPriceBooks.isEmpty()) {
				result = standardPriceBooks.get(0).Id;
			}
		}

		return result;
	}

    /**
     * @description Creates static lookup IDs.
     * @param lookupRecords The list of lookup records.
     * @param lookupValues The list of lookup values.
     * @param lookupFieldApiName The API name of the lookup field.
     * @return A list of IDs.
     */
    private List<Id> getStaticLookupValues(
        List<SObject> lookupRecords, List<String> lookupValues, String lookupFieldApiName) {
        List<Id> results = new List<Id>();
        String lookupId = '';

        for (SObject objRecord : lookupRecords) {
            // if lookup field value is found
            if (lookupValues[0].equalsIgnoreCase((String) objRecord.get(lookupFieldApiName))) {
                lookupId = objRecord.Id; // get record Id
                break;
            }
        }

        for (Integer counter = 0; counter < this.records; counter++) {
            results.add(lookupId);
        }

        return results;
    }

    /**
     * @description Creates static values.
     * @param definition The field definition.
     * @param argument The static value.
     * @return A list of string values.
     */
    private List<String> getStaticValues(Definition definition, String argument) {
        List<String> values = new List<String>();
        String fieldApiName = definition.fieldApiName;
        String argumentToLowercase = argument.toLowerCase();

        // get the field object
        Field depField = this.sObjectFieldsMap.get(fieldApiName.toLowerCase());

        // manage record types
        if (fieldApiName == 'RecordTypeId') {
            String recordTypeId = this.recordTypesMap.get(argumentToLowercase); // get the record type ID
            if (String.isBlank(recordTypeId)) {
                addError(fieldApiName, 'Invalid record type [' + argument + '] for definition [' +
                    definition.definitionString + ']');
            } else { // record type is found
                for (Integer counter = 0; counter < this.records; counter++) {
                    values.add(recordTypeId);
                }
            }
            return values;
        }

        if (fieldIsVirtual(fieldApiName)
            // or the field is not picklist
            || (depField.dataType != Schema.DisplayType.Picklist && depField.dataType != Schema.DisplayType.MultiPicklist)) {
            for (Integer counter = 0; counter < this.records; counter++) {
                values.add(argument);
            }
            return values;
        }

        // get all picklist values
        List<String> picklistValues = new List<String>();
        for (Schema.PicklistEntry picklistEntry : depField.picklistValues) {
            picklistValues.add(picklistEntry.getValue());
        }

        String ctrlFieldApiName = depField.controllingFieldApiName; // get controlling field's API name
        List<String> arguments = new List<String>{
            argument
        }; // set arguments list
        if (depField.isRestrictedPicklist) { // if the field is restricted
            arguments = keepValuesInList(arguments, picklistValues); // remove argument if not a valid picklist value
        }
        if (String.isBlank(ctrlFieldApiName) || // the controlling field is a Checkbox or there is no controlling field
            this.sObjectFieldsMap.get(ctrlFieldApiName.toLowerCase()).dataType == Schema.DisplayType.Boolean) {
            values = getPicklistValuesWithoutRespect(arguments);
        } else { // there is a controlling field
            values = getPicklistValuesWithRespect(fieldApiName, ctrlFieldApiName, arguments, null);
        }

        return values;
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
        } else if (queryLimit > 10000) {
            result = 10000;
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
		if (this.isInsert) {
			numRecords = this.numInsertedRecords;
		} else if (this.isRecordsUpdate) {
			numRecords = this.numUpdatedRecords;
		}

		String description = getDmlDescription('ed', 'uppercase') + ' ' + numRecords +
			' records of [' + this.sObjectApiName + ']';
		description = String.isNotBlank(this.groupName)
			? description + ' group [' + this.groupName + ']'
			: description;
		resetMilestoneTimer(description);
	}

	/**
	 * @description Handles the errors displayed fater a DML operation.
	 */
	private void handleErrorsOnDml() {
		Integer errors = 0;
		Integer counter = 0;
		Integer numSuccessfulRecords = 0;
		String dmlDescription = getDmlDescription('ing', 'lowercase');

		for (Database.SaveResult sr : this.saveResults) {
			counter++;
			if (sr.isSuccess()) {
                numSuccessfulRecords++;
				if (this.isInsert) {
					this.insertedRecords.add(this.recordsToInsert.get(counter - 1));
				} else if (this.isRecordsUpdate) {
					this.updatedRecords.add(this.recordsToUpdate.get(counter - 1));
				}
			} else {
				errors++;
				if (errors <= FObject.numMaxErrorRecordsToDisplay) {
					for (Database.Error err : sr.getErrors()) {
						addError(this.sObjectApiName, 'Found errors ' + dmlDescription +
							' record #' + counter + ': ' +
							err.getMessage() + '. Fields that affected this error: ' + err.getFields());
					}
				}
			}
		}

		if (this.isInsert) {
			this.numInsertedRecords = numSuccessfulRecords;
		} else if (this.isRecordsUpdate) {
			this.numUpdatedRecords = numSuccessfulRecords;
		}

		// if there are errors, display a message
		if (errors > 0) {
			addError(this.sObjectApiName, 'Found ' + errors + ' errors ' +
				dmlDescription + ' ' + this.saveResults.size() + ' records of [' + this.sObjectApiName + ']');
		}
	}

    /**
     * @description Initializes properties and displays messages for setting required fields.
     */
    private void handleInitializationOfRequiredFields() {
        if (!this.requiredFieldsMustBeSet) {
            forceeaDebug(WARN, MESSAGE_WILL_NOT_SET_DEFINITIONS_OF_REQUIRED_FIELDS +
                ' of [' + this.sObjectApiName + ']');
            return;
        }
        forceeaDebug(DEBUG, MESSAGE_WILL_SET_DEFINITIONS_OF_REQUIRED_FIELDS +
            ' of [' + this.sObjectApiName + ']');
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

        forceeaDebug(DEBUG, MESSAGE_WILL_UPDATE_RECORDS + ' of [' + this.sObjectApiName + ']');
        this.saveResults = Database.update(validRecordsToUpdate, allOrNone);
        handleErrorsOnDml();
    }

    /**
     * @description Stores the created records when we have ID mocking.
     */
    private void handleRecordsWithMockedIds() {
        forceeaDebug(DEBUG, MESSAGE_WILL_STORE_CREATED_RECORDS + ' of [' + this.sObjectApiName + ']');

        for (Integer counter = 0; counter < this.recordsToInsert.size(); counter++) {
            this.insertedRecords.add(this.recordsToInsert[counter]);
        }
    }

    /**
     * @description Updates records using field definitions for update.
     * @param groupName The group name.
     */
    private void handleRecordsWithUpdatedValues(String groupName) {
        this.recordsToUpdate = getRecordsToUpdate(groupName);

        // store the number of records
        Integer numRecords = this.records;
        this.records = this.recordsToUpdate.size();

        if (this.recordsToUpdate.isEmpty()) {
            return;
        }

        validateDefinitionsOnFieldValuesUpdate();
        if (processMustTerminate()) {
            return;
        }

        createValuesOnFieldValuesUpdate();
        if (this.numDefinitionsWithData == 0) {
            this.recordsToUpdate = new List<SObject>();
            return;
        }

        displayCreatedFieldValues();
        setRecordsToUpdateWithNewFieldValues();
        this.records = numRecords;
    }

    /**
     * @description Returns true if the ID value is not blank or mocked.
     * @param idValue A string of the ID value.
     * @return True, if the ID is valid.
     */
    private Boolean idIsValid(String idValue) {
        Boolean result = true;

        if (String.isBlank(idValue) || idValue.contains('mock')) {
            result = false;
        }

        return result;
    }

    /**
     * @description Initializes the Field Values Matrix.
     */
    private void initializeFieldValuesMatrix() {
        this.fieldValuesMatrix.clear();
        for (Integer counter1 = 0; counter1 < this.fields.size(); counter1++) {
            this.fieldValuesMatrix.add(new List<String>());
            for (Integer counter2 = 0; counter2 < this.records; counter2++) {
                this.fieldValuesMatrix[counter1].add('');
            }
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
	    if (processMustTerminate() || allOrNone == null) {
		    return results;
	    }

        setGroupName(groupName);
	    onBeforeInsertRecords();

	    handleCreationOfRecords();
	    if (processMustTerminate()) {
		    onAfterInsertRecords();
		    return results;
	    }

        if (this.isMocking) {
            handleRecordsWithMockedIds();
        } else {
            insertRecordsWithoutMockedIds(allOrNone);
	        results = new List<Database.SaveResult>(this.saveResults);
        }

	    onAfterInsertRecords();
	    return results ;
    }

    /**
     * @description Inserts the FObject records of a Template.
     * @param template The Template map.
     * @param allOrNone Specifies whether the operation allows partial success.
     */
    public static void insertRecordsFromTemplate(Map<String, FObject> template, Boolean allOrNone) {
        for (FObject obj : template.values()) {
            obj.insertRecords(allOrNone);
        }
    }

    /**
     * @description Inserts the created records when we don't have ID mocking.
     * @param allOrNone If true, the operation allows partial success.
     */
    private void insertRecordsWithoutMockedIds(Boolean allOrNone) {
        if (this.sObjectApiName == 'User' && !Test.isRunningTest() && !this.canInsertUsers) {
            forceeaDebug(WARN, MESSAGE_WILL_NOT_INSERT_RECORDS + ' of [User]');
            return;
        }

        forceeaDebug(DEBUG, MESSAGE_WILL_INSERT_CREATED_RECORDS + ' of [' + this.sObjectApiName + ']');
        this.saveResults = Database.insert(this.recordsToInsert, allOrNone);
        handleErrorsOnDml();
    }

    /**
     * @description Inserts entries for the Standard Price Book using the values of a virtual field.
     */
    private void insertStandardPricebookEntries() {
        if (String.isBlank(this.virtualFieldForStandardPriceBookEntries) || this.sObjectApiName != 'Product2') {
            return;
        }

        this.productsToInsertPricebookEntries = (List<Product2>) this.createdRecords;
        if (this.productsToInsertPricebookEntries.isEmpty()) {
            return;
        }

        Integer virtualFieldPosition = this.getFieldPosition(this.virtualFieldForStandardPriceBookEntries);

        List<String> virtualFieldValues = new List<String>();
        String fieldValue = '';
        for (Integer counter = 0; counter < this.productsToInsertPricebookEntries.size(); counter++) {
            fieldValue = this.fieldValuesMatrix.get(virtualFieldPosition).get(counter);
            virtualFieldValues.add(fieldValue);
        }

        if (!FObject.processIsValid || virtualFieldValues.isEmpty()) {
            return;
        }

	    insertStandardPricebookEntriesFromVirtualFieldValues(virtualFieldValues);
    }

	/**
	 * @description Inserts Standard Pricebook entries from virtual field values.
	 * @param values A list of string UnitPrice values.
	 */
	private void insertStandardPricebookEntriesFromVirtualFieldValues(List<String> values) {
		Id standardPriceBookId = getStandardPriceBookId();
		if (standardPriceBookId == null) {
			return;
		}

		Integer counter = 0;
		List<SObject> entries = new List<SObject>();
        for (SObject record : this.productsToInsertPricebookEntries) {
            SObject newPricebookEntry = getPricebookEntry(
                standardPriceBookId, record.Id, Decimal.valueOf(values.get(counter)));
            entries.add(newPricebookEntry);
            counter++;
        }

        addPricebookEntriesToGlobalMap(entries);
		Database.insert(entries, true);
	}

    /**
     * @description Keeps some case-insensitive values in a list and removes anything else.
     * @param listToProcess The list to be processed.
     * @param valuesToKeep The values to keep in the list.
     * @return A list of string values.
     */
    private List<String> keepValuesInList(List<String> listToProcess, List<String> valuesToKeep) {
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
     * @description The main method for loading addresses.
     */
    @TestVisible
    private static void loadAddresses() {
        FObject.language = FObject.language.toLowerCase();
        FObject.locality = FObject.locality.toLowerCase();

        if (FObject.locality == 'italy' && FObject.language == 'italian') {
            // loadAddressesFromItalyInItalian();
        } else if (FObject.locality == 'france' && FObject.language == 'french') {
            // loadAddressesFromFranceInFrench();
        } else if (FObject.locality == 'spain' && FObject.language == 'spanish') {
            // loadAddressesFromSpainInSpanish();
        } else if (FObject.locality == 'greece' && FObject.language == 'greek') {
            loadAddressesFromGreeceInGreek();
        } else if (FObject.locality == 'ireland' && FObject.language == 'english') {
            // loadAddressesFromIrelandInEnglish();
        } else if (FObject.locality == 'england' && FObject.language == 'english') {
            // loadAddressesFromEnglandInEnglish();
        } else {
            loadAddressesFromUnitedStatesInEnglish();
        }
    }

    /**
     * @description Load addresses from Greece in Greek.
     */
    private static void loadAddressesFromGreeceInGreek() {
        // do nothing if it's already loaded
        if (!FObject.addressesLibrary.isEmpty()) {
            return;
        }

        FObject.streetNumberGoesAfterStreet = true;
        String country = 'Ελλάδα';

        FObject.addressesLibrary.add(new FAddress('Αγγελάκη', '54636', 'Θεσσαλονίκη', '', country));
        FObject.addressesLibrary.add(new FAddress('Αγίας Σοφίας', '54622', 'Θεσσαλονίκη', '', country));
        FObject.addressesLibrary.add(new FAddress('Αγίου Ανδρέα', '26221', 'Πάτρα', '', country));
        FObject.addressesLibrary.add(new FAddress('Ακαδημίας', '10671', 'Αθήνα', '', country));
        FObject.addressesLibrary.add(new FAddress('Βασιλέως Κωνσταντίνου', '15122', 'Αθήνα', '', country));
        FObject.addressesLibrary.add(new FAddress('Βησσαρίωνος', '10672', 'Αθήνα', '', country));
        FObject.addressesLibrary.add(new FAddress('Γεωργίου Κασιμάτη', '18531', 'Πειραιάς', '', country));
        FObject.addressesLibrary.add(new FAddress('Ερμού', '10551', 'Αθήνα', '', country));
        FObject.addressesLibrary.add(new FAddress('Ερμού', '15124', 'Μαρούσι', '', country));
        FObject.addressesLibrary.add(new FAddress('Ερμού', '26221', 'Πάτρα', '', country));
        FObject.addressesLibrary.add(new FAddress('Ερυθρού Σταυρού', '15123', 'Μαρούσι', '', country));
        FObject.addressesLibrary.add(new FAddress('Ηροδότου', '10673', 'Αθήνα', '', country));
        FObject.addressesLibrary.add(new FAddress('Ηρώων Πολυτεχνείου', '18536', 'Πειραιάς', '', country));
        FObject.addressesLibrary.add(new FAddress('Ιλισίων', '14564', 'Κηφισιά', '', country));
        FObject.addressesLibrary.add(new FAddress('Κολοκοτρώνη', '14562', 'Κηφισιά', '', country));
        FObject.addressesLibrary.add(new FAddress('Κομνηνών', '54624', 'Θεσσαλονίκη', '', country));
        FObject.addressesLibrary.add(new FAddress('Κομνηνών', '54624', 'Θεσσαλονίκη', '', country));
        FObject.addressesLibrary.add(new FAddress('Λεβίδου', '14562', 'Κηφισιά', '', country));
        FObject.addressesLibrary.add(new FAddress('Λεωφόρος Πεντέλης', '15235', 'Βριλήσσια', '', country));
        FObject.addressesLibrary.add(new FAddress('Μητροπόλεως', '10563', 'Αθήνα', '', country));
        FObject.addressesLibrary.add(new FAddress('Μητροπόλεως', '54624', 'Θεσσαλονίκη', '', country));
        FObject.addressesLibrary.add(new FAddress('Μιχαλακοπούλου', '26223', 'Πάτρα', '', country));
        FObject.addressesLibrary.add(new FAddress('Παύλου Μελά ', '54621', 'Θεσσαλονίκη', '', country));
        FObject.addressesLibrary.add(new FAddress('Πολυτεχνείου', '54626', 'Θεσσαλονίκη', '', country));
        FObject.addressesLibrary.add(new FAddress('Σοφοκλέους', '10235', 'Αθήνα', '', country));
        FObject.addressesLibrary.add(new FAddress('Σποράδων', '11361', 'Αθήνα', '', country));
        FObject.addressesLibrary.add(new FAddress('Σταδίου', '10252', 'Αθήνα', '', country));
        FObject.addressesLibrary.add(new FAddress('Στουρνάρα', '10432', 'Αθήνα', '', country));
        FObject.addressesLibrary.add(new FAddress('Τσιμισκή', '54623', 'Θεσσαλονίκη', '', country));
        FObject.addressesLibrary.add(new FAddress('Φιλικής Εταιρίας', '18539', 'Πειραιάς', '', country));

        FObject.forceeaStaticDebug(INFO, MESSAGE_ADDRESSES + 'Greece in the Greek language');
    }

    /**
     * @description Load addresses from United States in English.
     */
    private static void loadAddressesFromUnitedStatesInEnglish() {
        // do nothing if it's already loaded
        if (!FObject.addressesLibrary.isEmpty()) {
            return;
        }

        FObject.streetNumberGoesAfterStreet = false;
        String country = 'United States';

        FObject.addressesLibrary.add(new FAddress('N Main Ave', '10013', 'New York', 'NY', country));
        FObject.addressesLibrary.add(new FAddress('Lawton St', '10013', 'New York', 'NY', country));
        FObject.addressesLibrary.add(new FAddress('Broadway', '10007', 'New York', 'NY', country));
        FObject.addressesLibrary.add(new FAddress('Outwater Ln', '92126', 'San Diego', 'CA', country));
        FObject.addressesLibrary.add(new FAddress('Fenton Parkway', '92108', 'San Diego', 'CA', country));
        FObject.addressesLibrary.add(new FAddress('Metropolitan Dr', '90021', 'Los Angeles', 'CA', country));
        FObject.addressesLibrary.add(new FAddress('Hawthorne Street', '94105', 'San Francisco', 'CA', country));
        FObject.addressesLibrary.add(new FAddress('Delancey Pl', '19103', 'Philadelphia', 'PA', country));
        FObject.addressesLibrary.add(new FAddress('Spring Garden St', '19130', 'Philadelphia', 'PA', country));
        FObject.addressesLibrary.add(new FAddress('Pennsylvania Avenue N.W.', '20004', 'Washington', 'DC', country));
        FObject.addressesLibrary.add(new FAddress('West Jackson Boulevard', '60604', 'Chicago', 'IL', country));

        FObject.forceeaStaticDebug(INFO, MESSAGE_ADDRESSES + 'United States in the English language');
    }

    /**
     * @description The main method for loading names.
     */
    private static void loadNames() {
        FObject.language = FObject.language.toLowerCase();
        FObject.locality = FObject.locality.toLowerCase();

        if (FObject.locality == 'italy' && FObject.language == 'italian') {
            //loadNamesFromItalyInItalian();
        } else if (FObject.locality == 'france' && FObject.language == 'french') {
            //loadNamesFromFranceInFrench();
        } else if (FObject.locality == 'spain' && FObject.language == 'spanish') {
            //loadNamesFromSpainInSpanish();
        } else if (FObject.locality == 'greece' && FObject.language == 'greek') {
            loadNamesFromGreeceInGreek();
        } else if (FObject.locality == 'ireland' && FObject.language == 'english') {
            //loadNamesFromIrelandInEnglish();
        } else if (FObject.locality == 'england' && FObject.language == 'english') {
            //loadNamesFromEnglandInEnglish();
        } else {
            loadNamesFromUnitedStatesInEnglish();
        }
    }

    /**
     * @description Load names from Greece in Greek.
     */
    private static void loadNamesFromGreeceInGreek() {
        String gender = '';

        // do nothing if it's already loaded
        if (!FObject.lastNamesLibraryMap.isEmpty()) {
            return;
        }

        // female names
        gender = 'f';
        List<String> fFirstNames = new List<String>{ // add 50 first names
            'Νάντια', 'Διονυσία', 'Τάνια', 'Αδαμαντία', 'Αλίκη', 'Βασιλική', 'Φανή', 'Καίτη', 'Χρύσα', 'Μάγδα', 'Ηλιάνα',
            'Όλγα', 'Γεωργία', 'Μαριάνθη', 'Άρτεμις', 'Άντζελα', 'Στέλλα', 'Ζωή', 'Ανθή', 'Ευθυμία', 'Αγγελική', 'Τόνια',
            'Ντίνα', 'Ρίτα', 'Ντόρα', 'Αλεξία', 'Παυλίνα', 'Ρένα', 'Σοφία', 'Στεφανία', 'Λένα', 'Τζίνα', 'Γιούλη', 'Νεκταρία',
            'Ρέα', 'Γιώτα', 'Λίζα', 'Ελένη', 'Άννα', 'Έλενα', 'Αικατερίνη', 'Ρούλα', 'Παναγιώτα',
            'Ευγενία', 'Εμμανουέλα', 'Μαριέττα', 'Μυρσίνη', 'Μαρκέλλα', 'Τριανταφυλλιά', 'Αφροδίτη'
        };
        List<String> fLastNames = new List<String>{ // add 200 last names
            'Βαλαέτη', 'Σφακάκη', 'Καλογιάννη', 'Παυλίδου', 'Οικονόμου', 'Ανέστου', 'Κολάρου', 'Θανασούλια', 'Μωραίτη',
            'Κανατούλα', 'Τσιλιδέλου', 'Ανάγνου', 'Μαρινέα', 'Πατέρου', 'Μυρτσίδου', 'Μποτονάκη', 'Μυλωνάκη', 'Αρβανίτη',
            'Κυριαζή', 'Πασχαλίδη', 'Καμηλιέρη', 'Παπαμιχάλη', 'Σούρτζη', 'Κωφοτόλη', 'Μακρίδου', 'Γιαννιού', 'Λεοτσάκου',
            'Ζακυνθινού', 'Τσιγαρίδα', 'Σαββάκη', 'Καρτσιώτου', 'Μπενάκη', 'Γκυτάκου', 'Πολυζώη', 'Σταθάκου', 'Κουμουτσέα',
            'Πανίτσα', 'Κυριακάκου', 'Αναγνώστου', 'Πουρναράκη', 'Μαυρωνά', 'Μητακίδου', 'Γρηγοράτου', 'Στεφανάκη',
            'Κορνελάτου', 'Καλλινίκου', 'Καρανάσου', 'Τσιντέα', 'Τζεβελέκου', 'Γεωργίου', 'Δημουλά', 'Ξηρουχάκη', 'Λουκανίδου',
            'Κυνηγαλάκη', 'Κιοβρέκη', 'Μιαούλη', 'Σαραμπάλου', 'Μεταλλίδου', 'Κατσαρού', 'Απιδιανάκη', 'Κολέτου', 'Μανανδράκη',
            'Βαφειάδου', 'Αξιάρχου', 'Κωσταλούπη', 'Αλεξιάδου', 'Αντωνένα', 'Νικολαϊδου', 'Ιγγλέζου', 'Δημοπούλου', 'Πελεκάνου',
            'Θεοδωράκη', 'Πορτίδου', 'Γιαννακού', 'Νανοπούλου', 'Θεριανού', 'Σουσώνη', 'Τσακμακλή', 'Τριλιούρη', 'Πιτσιλαδή',
            'Τσαχάκη', 'Τραγάκη', 'Θεολογίτη', 'Αλεβίζου', 'Γιαννακάκη', 'Κοπάνου', 'Ζωγράφου', 'Αναστάση', 'Μαλλιάπη',
            'Τσουμπρή', 'Πιτσίκα', 'Τζουμάκα', 'Αδριανή', 'Αλλιζώτη', 'Καραμάνου', 'Συκινιώτη', 'Κοτσίρη', 'Γιαλαμά', 'Τσιτσινάκη',
            'Τσαβάλου', 'Σκοτίδη', 'Σταύρου', 'Ανδρέου', 'Ζορμπάνου', 'Ζηνοπούλου', 'Κοροσίδου', 'Σκαλάτη', 'Λογοθέτη',
            'Ιακωβίδου', 'Βαρζακάκου', 'Αμπατζή', 'Γκιουλέα', 'Κουταβά', 'Μερκουρίου', 'Κυρίτση', 'Καζεπίδου', 'Μαμιδάκη',
            'Κουμπούρη', 'Ελευθεράκη', 'Αντωνιάδου', 'Φωτακέλη', 'Χριστοφίλη', 'Κομηνέα', 'Καφετζή', 'Πολεμίτου', 'Λαλιώτη',
            'Γεωργούση', 'Γιόκαλα', 'Ορφανού', 'Αφαντίτη', 'Κασιμάτη', 'Καψουλάκη', 'Κωτσοβού', 'Παντάκη', 'Ραπτάκη', 'Κουτσιάφτη',
            'Καλλέργη', 'Μπορμπιλά', 'Φρέντζα', 'Τσισκάκη', 'Ιωάννου', 'Βιλλιώτη', 'Καλογερά', 'Λαμπρίδου', 'Βολιώτου',
            'Φουσέκη', 'Βαρσάμη', 'Πίκουλα', 'Καμπουρίδη', 'Χανιώτη', 'Κληρονόμου', 'Σούλτου', 'Αποστολου', 'Νεράντζη', 'Μπαμίχα',
            'Μαρίνου', 'Χαμπέρη', 'Γαλάτουλα', 'Αλεξάτου', 'Καραμιχάλη', 'Λαζάρου', 'Αργυράκη', 'Παπασπύρου', 'Καταξένου',
            'Γιαβριμη', 'Δαλέκου', 'Ρεμαντά', 'Ελσούκαρη', 'Μαυροζούμη', 'Τσεκούρα', 'Τρουπάκη', 'Βλασσιάδου', 'Παρλάντζα',
            'Αμπαριώτη', 'Βερικάκη', 'Παπακώστα', 'Διαμαντή', 'Θεοδώρου', 'Κυριακίδου', 'Κανέλλη', 'Μπετέκου', 'Νταουντάκη',
            'Ανδρεαδάκη', 'Κουτσοκέρη', 'Πούλιου', 'Παπατρύφων', 'Πιεράτου', 'Νεκταρίου', 'Μπάμπαλη', 'Κλωθάκη', 'Νταλάκα',
            'Πανέτσου', 'Φράνγκου', 'Χρυσάνη', 'Αλιφραγκή', 'Μητρέλλου', 'Μηλιώνη', 'Αθανασίου', 'Ριζούδη', 'Τζανετή'
        };
        FObject.firstNamesLibraryMap.put(gender, fFirstNames);
        FObject.lastNamesLibraryMap.put(gender, fLastNames);

        // male names
        gender = 'm';
        List<String> mFirstNames = new List<String>{ // add 50 first names
            'Αδάμ', 'Ευγένιος', 'Αλέκος', 'Νώντας', 'Φάνης', 'Αργύρης', 'Άλκης', 'Διαμαντής', 'Θάνος', 'Παύλος', 'Φίλιππος', 'Αλέξης', 'Γιώργος', 'Κώστας',
            'Μάρκος', 'Θωμάς', 'Νίκος', 'Δήμος', 'Θεοδόσης', 'Στάθης', 'Φώτης', 'Κυριάκος', 'Χάρης', 'Λάμπρος', 'Άγγελος', 'Πέτρος', 'Στράτος', 'Γρηγόρης',
            'Μανώλης', 'Τάσος', 'Μιχάλης', 'Αντώνης', 'Ανδρέας', 'Δημήτρης', 'Γιάννης', 'Βαγγέλης', 'Νικήτας', 'Ηλίας', 'Αχιλλέας', 'Σταύρος',
            'Παναγιώτης', 'Φαίδων', 'Σάββας', 'Βασίλης', 'Ορέστης', 'Νεκτάριος', 'Πάνος', 'Στέφανος', 'Θεόφιλος', 'Στέλιος'
        };
        List<String> mLastNames = new List<String>{ // add 200 last names
            'Ψαλτήρας', 'Κονδύλης', 'Μοσχοβής', 'Κολώνιας', 'Μουρίκης', 'Μερτύκας', 'Χαρατσής', 'Μανιάτης', 'Τσιλίκης', 'Ταπάκης', 'Μανίκας', 'Χάλαρης',
            'Πούρνος', 'Κυρίδης', 'Ρέμπελος', 'Θανασάς', 'Τρυφέρης', 'Παράσχος', 'Κουρελάς', 'Νταλάκας', 'Μπίλιας', 'Σκαφίδας', 'Ψυράκης', 'Πανούσης',
            'Χαλικάς', 'Προβατάς', 'Λουκέρης', 'Καρλάκης', 'Τσαμάτης', 'Σέρτσος', 'Πλυμένος', 'Κολόνιας', 'Ηλιάδης', 'Σουλελές', 'Μαγουλάς', 'Λαζάρου',
            'Ταμβάκης', 'Δαμίγος', 'Ρομπότης', 'Σιγάλας', 'Μαλούχος', 'Περωτής', 'Μπούρας', 'Ταλούμης', 'Κρικώνης', 'Στάνιος', 'Γεράκης', 'Δούσσης',
            'Ντότσιας', 'Απέργης', 'Μπουζούμης', 'Ντάλλας', 'Πασσάκος', 'Μονιώδης', 'Βίλλιος', 'Μασσώνος', 'Γαβριήλ', 'Μάκαρης', 'Γαρμπής', 'Κοφινάς',
            'Μεγρέμης', 'Τομάζος', 'Λυριτζής', 'Τζαβάρας', 'Μπογρής', 'Λούτσος', 'Μπαδήμας', 'Κούμενος', 'Μύταρος', 'Μοσχάκης', 'Ντούλιας', 'Μπολάκης',
            'Δουλφής', 'Πατρώνας', 'Χαραμής', 'Παριάρος', 'Περβανάς', 'Κοσμίδης', 'Γκρέκος', 'Κόκκορης', 'Αρματάς', 'Μικέδης', 'Βιδάκης', 'Κυράνης',
            'Γόγωλος', 'Σαγκρής', 'Σκιαδάς', 'Γκίλλας', 'Σπανάκος', 'Τσιγάρας', 'Μικέλης', 'Πούμπρος', 'Φασόλης', 'Περράκης', 'Μπατζής', 'Ζαμάνης',
            'Κεχαγιάς', 'Δάουλας', 'Χαλιώτης', 'Γκιόκας', 'Μούρτζης', 'Ζαφύρης', 'Χρυσοχός', 'Λιόλιος', 'Μαρκάζος', 'Δόμινος', 'Παπαδιάς', 'Κοκότσης',
            'Τζώρτζης', 'Μαρουλής', 'Γατζίας', 'Φιορέτος', 'Μεϊδάνης', 'Χαιρέτης', 'Τομαράς', 'Λιάππης', 'Κεράνης', 'Μαμουνάς', 'Χασόγιας', 'Ντόκορος',
            'Κρασσάς', 'Σεραφείμ', 'Σκορδάς', 'Τεκέδης', 'Μανάφας', 'Γκλαβάς', 'Μπονίκος', 'Κάτσικας', 'Μπάκνης', 'Λέτσιος', 'Μαγιάτης', 'Ζιούβας',
            'Αχτίδας', 'Κλωνάρης', 'Τσότσος', 'Ριζάκης', 'Σιούλας', 'Παρμαξής', 'Κωλέτας', 'Στεφανής', 'Πανάγος', 'Πουλάκος', 'Λιούνης', 'Τραυλός',
            'Χαλικιάς', 'Σακέτος', 'Σοκόλης', 'Τσομώκος', 'Φωτίδας', 'Κούσκος', 'Καραβάς', 'Κρεμύδας', 'Δελόνας', 'Κιούπης', 'Ζαράνης', 'Φινδάνης',
            'Δαβιλάς', 'Λακιώτης', 'Σκόδρας', 'Κατσώλης', 'Κορκολής', 'Γρίτσης', 'Μπουρνής', 'Ντάφλος', 'Κολλιός', 'Μπολάνης', 'Αγγέλου', 'Καστανάς',
            'Λεμονής', 'Μπόκτορ', 'Μαργώνης', 'Καράπας', 'Περλεπές', 'Κούβαρης', 'Κιτσάκης', 'Πανoύσης', 'Καραλής', 'Καβύρης', 'Μωρέλας', 'Διβόλης',
            'Φραντζής', 'Κούκιας', 'Λελάκης', 'Δρούγας', 'Ζαρίφης', 'Στασινός', 'Φυλακτός', 'Ζερεφός', 'Κοντάκος', 'Αρμύρος', 'Μπαλλής', 'Μυλωνάς',
            'Παΐσιος', 'Χαλμπές', 'Καψάλας', 'Τσιόγκας', 'Στεφάνου', 'Τσούμπας', 'Σμυρνής', 'Συράκος'
        };
        FObject.firstNamesLibraryMap.put(gender, mFirstNames);
        FObject.lastNamesLibraryMap.put(gender, mLastNames);

        FObject.forceeaStaticDebug(INFO, MESSAGE_NAMES + 'Greece in the Greek language');
    }

    /**
     * @description Load names from United States in English.
     */
    private static void loadNamesFromUnitedStatesInEnglish() {
        String gender = '';

        // do nothing if it's already loaded
        if (!FObject.lastNamesLibraryMap.isEmpty()) {
            return;
        }

        // female names
        gender = 'f';
        List<String> fFirstNames = new List<String>{ // add 50 first names
            'Tracey', 'Amelia', 'Leah', 'Nicola', 'Theresa', 'Sophie', 'Olivia', 'Sally', 'Wendy', 'Fiona',
            'Deirdre', 'Jane', 'Lillian', 'Abigail', 'Ella', 'Claire', 'Lauren', 'Bernadette', 'Karen', 'Vanessa',
            'Grace', 'Alison', 'Rachel', 'Heather', 'Ava', 'Wanda', 'Natalie', 'Victoria', 'Joan', 'Dorothy',
            'Una', 'Rebecca', 'Donna', 'Emma', 'Sarah', 'Sonia', 'Samantha', 'Lily', 'Bella', 'Penelope', 'Julia',
            'Caroline', 'Felicity', 'Anne', 'Faith', 'Diane', 'Sue', 'Joanne', 'Kylie', 'Jasmine'
        };
        List<String> fLastNames = new List<String>{ // add 200 last names
            'Smith', 'Johnson', 'Williams', 'Jones', 'Brown', 'Davis', 'Miller', 'Wilson', 'Moore', 'Taylor',
            'Anderson', 'Thomas', 'Jackson', 'White', 'Harris', 'Martin', 'Thompson', 'Garcia', 'Martinez',
            'Robinson', 'Clark', 'Rodriguez', 'Lewis', 'Lee', 'Walker', 'Hall', 'Allen', 'Young', 'Hernandez',
            'King', 'Wright', 'Lopez', 'Hill', 'Scott', 'Green', 'Adams', 'Baker', 'Gonzalez', 'Nelson', 'Carter',
            'Mitchell', 'Perez', 'Roberts', 'Turner', 'Phillips', 'Campbell', 'Parker', 'Evans', 'Edwards',
            'Collins', 'Stewart', 'Sanchez', 'Morris', 'Rogers', 'Reed', 'Cook', 'Morgan', 'Bell', 'Murphy',
            'Bailey', 'Rivera', 'Cooper', 'Richardson', 'Cox', 'Howard', 'Ward', 'Torres', 'Peterson', 'Gray',
            'Ramirez', 'James', 'Watson', 'Brooks', 'Kelly', 'Sanders', 'Price', 'Bennett', 'Wood', 'Barnes',
            'Ross', 'Henderson', 'Coleman', 'Jenkins', 'Perry', 'Powell', 'Long', 'Patterson', 'Hughes', 'Flores',
            'Washington', 'Butler', 'Simmons', 'Foster', 'Gonzales', 'Bryant', 'Alexander', 'Russell', 'Griffin',
            'Diaz', 'Hayes', 'Myers', 'Ford', 'Hamilton', 'Graham', 'Sullivan', 'Wallace', 'Woods', 'Cole', 'West',
            'Jordan', 'Owens', 'Reynolds', 'Fisher', 'Ellis', 'Harrison', 'Gibson', 'Mcdonald', 'Cruz', 'Marshall',
            'Ortiz', 'Gomez', 'Murray', 'Freeman', 'Wells', 'Webb', 'Simpson', 'Stevens', 'Tucker', 'Porter',
            'Hunter', 'Hicks', 'Crawford', 'Henry', 'Boyd', 'Mason', 'Morales', 'Kennedy', 'Warren', 'Dixon',
            'Ramos', 'Reyes', 'Burns', 'Gordon', 'Shaw', 'Holmes', 'Rice', 'Robertson', 'Hunt', 'Black', 'Daniels',
            'Palmer', 'Mills', 'Nichols', 'Grant', 'Knight', 'Ferguson', 'Rose', 'Stone', 'Hawkins', 'Dunn',
            'Perkins', 'Hudson', 'Spencer', 'Gardner', 'Stephens', 'Payne', 'Pierce', 'Berry', 'Matthews', 'Arnold',
            'Wagner', 'Willis', 'Ray', 'Watkins', 'Olson', 'Carroll', 'Duncan', 'Snyder', 'Hart', 'Cunningham',
            'Bradley', 'Lane', 'Andrews', 'Ruiz', 'Harper', 'Fox', 'Riley', 'Armstrong', 'Carpenter', 'Weaver',
            'Greene', 'Lawrence', 'Elliott', 'Chavez', 'Sims', 'Austin', 'Peters', 'Kelley', 'Franklin', 'Lawson'
        };
        FObject.firstNamesLibraryMap.put(gender, fFirstNames);
        FObject.lastNamesLibraryMap.put(gender, fLastNames);

        // male names
        gender = 'm';
        List<String> mFirstNames = new List<String>{ // add 50 first names
            'Sebastian', 'Boris', 'Andrew', 'Paul', 'Jake', 'Edward', 'Neil', 'Ryan', 'Christian', 'Ian', 'Max',
            'Gavin', 'Matt', 'Jonathan', 'Nicholas', 'Adam', 'Frank', 'Brandon', 'Julian', 'Richard', 'Steven',
            'Colin', 'James', 'Trevor', 'Anthony', 'Victor', 'Nathan', 'Adrian', 'John', 'Joshua', 'Stewart',
            'Kevin', 'David', 'Austin', 'Tim', 'Dominic', 'Robert', 'Jason', 'Connor', 'Evan', 'Joe', 'Sam',
            'Blake', 'Liam', 'Stephen', 'Thomas', 'Phil', 'Christopher', 'Lucas', 'Isaac'
        };
        List<String> mLastNames = new List<String>(fLastNames); // add 200 last names
        FObject.firstNamesLibraryMap.put(gender, mFirstNames);
        FObject.lastNamesLibraryMap.put(gender, mLastNames);

        FObject.forceeaStaticDebug(INFO, MESSAGE_NAMES + 'United States in the English language');
    }

	/**
	 * @description Executes after the creation of records.
	 */
	private void onAfterCreateRecords() {
        this.recordsToInsert.addAll(this.createdRecords);
        this.mustCreateNewRecords = false;

        if (!this.createdRecords.isEmpty()) {
            Integer numFirstRecord = FObject.numFirstRecordsBySObject.get(this.sObjectApiName);
            FObject.numFirstRecordsBySObject.put(this.sObjectApiName, numFirstRecord + this.records);
        }

        resetMilestoneTimer('Created ' + this.createdRecords.size() + ' records of [' + this.sObjectApiName + ']');
        displaySeparatorOnMethodFinish();
    }

    /**
     * @description Executes after the insertion of records.
     */
    private void onAfterInsertRecords() {
        addRecordsToMapsOnInsert();
        insertStandardPricebookEntries();
        handleDmlMilestone();

	    this.isInsert = false;
        this.productsToInsertPricebookEntries.clear();
        this.recordsToInsert.clear();
        this.virtualFieldForStandardPriceBookEntries = '';
        this.cpuTimeOfDataGeneration = Limits.getCpuTime() - this.cpuTimeStartOfDataGeneration;

        displaySeparatorOnMethodFinish();
    }

    /**
     * @description Executes after the update of fields.
     */
    private void onAfterUpdateFields() {
        if (String.isBlank(this.groupName)) {
            resetMilestoneTimer('Updated the field values of ' + this.numUpdatedRecords + ' records');
        } else {
            resetMilestoneTimer('Updated the field values of ' + this.numUpdatedRecords +
                ' records of group [' + this.groupName + ']');
        }
        this.isFieldsUpdate = false;
        displaySeparatorOnMethodFinish();
    }

	/**
	 * @description Executes after the update of records.
	 */
	private void onAfterRecordsUpdate() {
		handleDmlMilestone();

		this.isRecordsUpdate = false;
		this.recordsToUpdate.clear();

        displaySeparatorOnMethodFinish();
    }

	/**
	 * @description Executes before the creation of records.
	 */
	private void onBeforeCreateRecords() {
        displaySeparatorOnMethodStart('Create records');

        this.createdRecords.clear();
        this.namesMap.clear();
        this.addressesMap.clear();

        setDefinitionOfRequiredFields();
	}

    /**
     * @description Executes before the insertion of records.
     */
    private void onBeforeInsertRecords() {
        displaySeparatorOnMethodStart('Insert records');

        this.saveResults.clear();
        this.insertedRecords.clear();
        this.numInsertedRecords = 0;
        this.isInsert = true;
    }

    /**
     * @description Executes before the update of fields.
     */
    private void onBeforeUpdateFields() {
        displaySeparatorOnMethodStart('Update fields');

        this.isFieldsUpdate = true;
        this.numDefinitionsWithData = 0;
        this.numUpdatedRecords = 0;
        this.numValidatedDefinitions = 0;

        this.addressesMap.clear();
        this.namesMap.clear();
    }

	/**
	 * @description Executes before the update of records.
	 */
	private void onBeforeRecordsUpdate() {
        displaySeparatorOnMethodStart('Update records');

        this.saveResults.clear();
		this.updatedRecords.clear();
		this.numUpdatedRecords = 0;
		this.isRecordsUpdate = true;
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
     * @param definition The field definition.
     */
    private void parseDefinition(Definition definition) {
        String definitionString = definition.definitionString.trim();
        String fieldApiName = definition.fieldApiName;
        String script = '';
        String errorMessage = '';
        definition.isValid = true;
        definition.isValidated = true;

        // parse command
        String command = definitionString.substringBefore(' ').trim();
        if (!definition.isSystemDeclared && !commandIsValid(command)) {
            errorMessage = 'Invalid command [' + command + '] in definition [' + definitionString + ']';
            addError(fieldApiName, errorMessage);
            definition.isValid = false;
            return;
        } else { // command is valid
            script = definitionString.removeStart(command + ' ');
            command = command.toLowerCase();
            definition.command = command;
        }

        // parse script
        do {
            script = parseCluster(definition, script);
        } while (String.isNotEmpty(script));

    }

    /**
     * @description Parses a script cluster.
     * @param definition The field definition.
     * @param script The script.
     * @return Returns the script without the cluster.
     */
    private String parseCluster(Definition definition, String script) {
        List<String> arguments = new List<String>();
        String result = script.trim();
        String argument = '';
        String chr = '';
        String parameter = ''; // the cluster parameter

        Integer doubleQuotesPosition = 0;
        Boolean mustContinue = true;
        Boolean commaExists = false;
        Boolean hasError = false;

        final String FIELD_API_NAME = definition.fieldApiName;
        final String ERROR_MESSSAGE = 'Invalid syntax in definition [' + definition.definitionString + '] ' +
            'of field [' + FIELD_API_NAME + ']';

        // get parameter
        if (result.indexOf('(') == -1) { // found no (
            addError(FIELD_API_NAME, ERROR_MESSSAGE);
            definition.isValid = false;
            return '';
        } else { // found (
            parameter = result.substringBefore('('); // get parameter
            if (!parameterIsValid(parameter)) { // is invalid
                addError(FIELD_API_NAME, 'Invalid parameter [' + parameter.trim() + '] in definition [' +
                    definition.definitionString + ']');
                return '';
            }
            result = result.removeStart(parameter + '('); // remove paramater and ( from script
            parameter = parameter.trim();
        }

        do {
            result = result.trim();

            chr = result.left(1); // get first char
            if (chr == '"') { // an argument in double quotation marks, e.g. "My argument"
                result = result.removeStart(chr); // remove opening "
                doubleQuotesPosition = getPositionOfClosingQuotes(result); // get position of closing "
                if (doubleQuotesPosition == -1) { // found no closing "
                    addError(FIELD_API_NAME, ERROR_MESSSAGE);
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

                    if (String.isBlank(argument)) {
                        addError(FIELD_API_NAME, ERROR_MESSSAGE);
                        return '';
                    }
                    arguments.add(argument); // add argument to a list
                }

                chr = result.left(1); // get next char - it should be , or )
                if (chr == ')') { // found (
                    result = result.removeStart(chr).trim(); // remove the )
                    mustContinue = false;
                } else if (chr == ',') { // found ,
                    result = result.removeStart(chr).trim(); // remove the comna
                } else { // found something else
                    addError(FIELD_API_NAME, ERROR_MESSSAGE);
                    return '';
                }
            } else if (chr.containsAny('(),')) { // invalid chars
                addError(FIELD_API_NAME, ERROR_MESSSAGE);
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
                    addError(FIELD_API_NAME, ERROR_MESSSAGE);
                    return '';
                }

                result = result.removeStart(argument + chr); // remove argument and ) or , from script
                arguments.add(argument.trim()); // add argument to a list
            } // argument without double quotes
        } while (mustContinue);

        // add cluster to definition
        Cluster newCluster = new Cluster(parameter.toLowerCase(), arguments);
        definition.clusters.add(newCluster);

        return result;
    }

    /**
     * @description Posts a System.debug message.
     * @param errorLevel The System.LoggingLevel enum.
     * @param message The message to post.
     * @param verboseLevel The verbose level.
     */
    private static void postDebug(String errorLevel, String message, VerboseLevel verboseLevel) {
        errorLevel = errorLevel.trim();
        errorLevel = errorLevel.toLowerCase();

        if (errorLevel == ERROR) {
            System.debug(LoggingLevel.ERROR, DEBUG_LOG_PROMPT + message);
        } else if (errorLevel == WARN) {
            System.debug(LoggingLevel.WARN, DEBUG_LOG_PROMPT + message);
        } else if (errorLevel == INFO && verboseLevel.ordinal() >= 1) {
            System.debug(LoggingLevel.INFO, DEBUG_LOG_PROMPT + message);
        } else if (errorLevel == DEBUG && verboseLevel.ordinal() == 1) {
            System.debug(LoggingLevel.DEBUG, DEBUG_LOG_PROMPT + message);
        }
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
     * @return True, if the process is invalid and must terminate.
     */
    private Boolean processMustTerminate() {
        if (!FObject.processIsValid) {
            if (Test.isRunningTest()) {
                if (!FObject.exceptionErrorMessageIsDisplayed) {
                    forceeaDebug(ERROR, MESSAGE_INVALID_PROCESS);
                    FObject.exceptionErrorMessageIsDisplayed = true;
                }
            } else {
                throw new FObjectException(MESSAGE_INVALID_PROCESS);
            }
            return true;
        } else { // process is valid
            return false;
        }
    }

    /**
     * @description Removes some case-insensitive values in a list.
     * @param listToProcess The list from which will be processed.
     * @param valuesToRemove The values to remove from the list.
     * @return A list of string values.
     */
    private List<String> removeValuesFromList(List<String> listToProcess, List<String> valuesToRemove) {
        List<String> results = new List<String>();
        String valueLowercase = '';
        Boolean mustInclude = true;

        for (String value : listToProcess) {
            mustInclude = true;
            valueLowercase = value.toLowerCase();
            for (String valueToRemove : convertListToLowercase(valuesToRemove)) {
                if (valueLowercase == valueToRemove) {
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
     * @description Resets the static maps for names and addresses.
     */
    private static void resetLanguageLocality() {
        FObject.firstNamesLibraryMap.clear();
        FObject.lastNamesLibraryMap.clear();
        FObject.addressesLibrary.clear();
    }

    /**
     * @description Resets the CPU timer and displays information
     *   about the elapsed time (in ms) since the previous reset.
     * @param infoText The information message to display.
     */
    private void resetMilestoneTimer(String infoText) {
        forceeaDebug(INFO, SYMBOL_MILESTONE + ' ' + infoText + ' in ' +
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
     * @description Declares a field definition.
     * @param sObjectField The SObjectField.
     * @param definition The field definition (command + script).
     * @return An FObject instance.
     */
    public FObject setDefinition(Schema.SObjectField sObjectField, String definition) {
        String fieldApiName = sObjectField.getDescribe().getName();
        String definitionString = definition.trim();

        Schema.SObjectField sof = this.sObjType.getDescribe().fields.getMap().get(fieldApiName);
        if (sof != sObjectField) {
            addError(this.sObjectApiName, 'Invalid field [' + fieldApiName +
                '] for SObject [' + this.sObjectApiName + '] in definition [' + definitionString + ']');
            return this;
        }

        setDefinition(fieldApiName, false, false, definition);
        return this;
    }

    /**
     * @description Declares a field definition.
     * @param fieldApiName The API name of a field.
     * @param definition The field definition (command + script).
     * @return An FObject instance.
     */
    public FObject setDefinition(String fieldApiName, String definition) {
        setDefinition(fieldApiName, false, false, definition);
        return this;
    }

    /**
     * @description Declares a field definition.
     * @param fieldApiName The API name of a field.
     * @param isSystemDeclared If true, the definition is declared by Forceea.
     * @param isForUpdate If true, the definition is for update.
     * @param definitionString The field definition.
     */
    private void setDefinition(
        String fieldApiName, Boolean isSystemDeclared, Boolean isForUpdate, String definitionString) {
        if (!FObject.processIsValid) {
            return;
        }
        String thisFieldName = fieldApiName.trim();
        String userFieldName = thisFieldName;

        thisFieldName = thisFieldName.toLowerCase();
        definitionString = definitionString.trim();
        String thisFieldApiName = getFieldApiName(thisFieldName);

        if (String.isBlank(thisFieldApiName)) { // field is invalid
            addError(this.sObjectApiName, 'Invalid field [' + userFieldName +
                '] for definition [' + definitionString + ']');
        } else { // field is valid
            // declare a new definition
            Definition def = new Definition(thisFieldName, thisFieldApiName, isSystemDeclared, isForUpdate, definitionString);
            def.fieldApiName = thisFieldApiName;
            // initialize variables
            Boolean fieldExists = false;
            Integer counter = 0;
            for (String field : this.fields) { // for each field
                if (('.' + thisFieldApiName) == field) { // the field is inactive
                    this.fields[counter] = thisFieldApiName; // activate it
                    fieldExists = true;
                    break;
                } else if (thisFieldApiName == field) { // the field is activated
                    fieldExists = true;
                    break;
                }
                counter++;
            }

            if (!fieldExists) {
                this.fields.add(thisFieldApiName); // add new field
            }

            this.definitions.add(def); // add new definition
        }

        this.definitionsAreValidated = false;
        this.mustCreateNewRecords = (isForUpdate) ? false : true;
    }

    /**
     * @description Declares a field definition for updating records.
     * @param sObjectField The SObjectField.
     * @param definition The field definition (command + script).
     * @return An FObject instance.
     */
    public FObject setDefinitionForUpdate(Schema.SObjectField sObjectField, String definition) {
        setDefinition(sObjectField.getDescribe().getName(), false, true, definition);
        return this;
    }

    /**
     * @description Declares a field definition for updating records.
     * @param fieldApiName The API name of a field.
     * @param definition The field definition (command + script).
     * @return An FObject instance.
     */
    public FObject setDefinitionForUpdate(String fieldApiName, String definition) {
        setDefinition(fieldApiName, false, true, definition);
        return this;
    }

    /**
     * @description Sets a field definition based on the field data type and the SObject.
     * @param field A field object.
     */
    @TestVisible
    private void setDefinitionFromField(Field field) {
        if (this.sObjectApiName == 'Account' && field.fieldApiName == 'Name') {
            setDefinition(field.fieldName, true, false,
                'static value(Company-)');
            setDefinition(field.fieldName, true, false,
                'serial type(number) from(1) step(1) scale(0)');
        } else if (this.sObjectApiName == 'Contact' && field.fieldApiName == 'FirstName') {
            setDefinition(field.fieldName, true, false,
                'random type(firstname) group(name)');
        } else if (this.sObjectApiName == 'Contact' && field.fieldApiName == 'LastName') {
            setDefinition(field.fieldName, true, false,
                'random type(lastname) group(name)');
        } else if (this.sObjectApiName == 'Lead' && field.fieldApiName == 'Company') {
            setDefinition(field.fieldName, true, false,
                'static value(Company-)');
            setDefinition(field.fieldName, true, false,
	            'serial type(number) from(1) step(1) scale(0)');
        } else if (this.sObjectApiName == 'Lead' && field.fieldApiName == 'FirstName') {
            setDefinition(field.fieldName, true, false,
                'random type(firstname) group(name)');
        } else if (this.sObjectApiName == 'Lead' && field.fieldApiName == 'LastName') {
            setDefinition(field.fieldName, true, false,
                'random type(lastname) group(name)');
        } else if (this.sObjectApiName == 'Opportunity' && field.fieldApiName == 'Name') {
            setDefinition(field.fieldName, true, false,
                'static value(Opportunity-)');
            setDefinition(field.fieldName, true, false,
                'serial type(number) from(1) step(1) scale(0)');
        } else if (field.dataType == Schema.DisplayType.Integer) {
            setDefinition(field.fieldName, true, false,
                'random type(number) from(1) to(100) scale(0)');
        } else if (field.dataType == Schema.DisplayType.Currency) {
            setDefinition(field.fieldName, true, false,
                'random type(number) from(1000) to(10000) scale(2)');
        } else if (field.dataType == Schema.DisplayType.Double) {
            setDefinition(field.fieldName, true, false,
                'random type(number) from(1000) to(10000) scale(3)');
        } else if (field.dataType == Schema.DisplayType.Date) {
            Integer thisYear = Date.today().year();
            String fromDate = String.valueOf(thisYear - 1) + '-01-01';
            String toDate = String.valueOf(thisYear + 1) + '-12-31';
            setDefinition(field.fieldName, true, false,
                'random type(date) from(' + fromDate + ') to(' + toDate + ')');
        } else if (field.dataType == Schema.DisplayType.Datetime) {
            Integer thisYear = Date.today().year();
            String fromDate = String.valueOf(thisYear - 1) + '-01-01';
            String toDate = String.valueOf(thisYear + 1) + '-12-31';
            setDefinition(field.fieldName, true, false,
                'random type(datetime) from(' + fromDate + ') to(' + toDate + ')');
        } else if (
            field.dataType == Schema.DisplayType.Picklist ||
                field.dataType == Schema.DisplayType.MultiPicklist ||
                field.dataType == Schema.DisplayType.Combobox) {
            setDefinition(field.fieldName, true, false,
                'random type(picklist)');
        } else if (field.dataType == Schema.DisplayType.String) {
            Integer minlength = (field.length < 5) ? field.length : 5;
            setDefinition(field.fieldName, true, false,
                'random type(string) minLength(' + minlength + ') maxLength(' +
                field.length + ') startWith(upper) include(lower,upper)');
        } else if (field.dataType == Schema.DisplayType.TextArea) {
            setDefinition(field.fieldName, true, false,
                'random type(text) minLength(30) maxLength(100)');
        } else if (field.dataType == Schema.DisplayType.Percent) {
            setDefinition(field.fieldName, true, false,
                'random type(number) from(0) to(100) scale(2)');
        } else if (field.dataType == Schema.DisplayType.Reference) {
            String source = SOURCE_FORCEEA;
            setDefinition(field.fieldName, true, false,
                'random lookup(' + field.parents[0] + ') source(' + source + ')');
        } else if (field.dataType == Schema.DisplayType.Boolean) {
            setDefinition(field.fieldName, true, false,
                'random type(boolean)');
        } else if (field.dataType == Schema.DisplayType.Email) {
            setDefinition(field.fieldName, true, false,
                'random type(email)');
        } else if (field.dataType == Schema.DisplayType.Phone) {
            setDefinition(field.fieldName, true, false,
                'static value(21011)');
            setDefinition(field.fieldName, true, false,
                'random type(number) from(11111) to(99999) scale(0)');
        } else if (field.dataType == Schema.DisplayType.Url) {
            setDefinition(field.fieldName, true, false,
                'random type(url)');
        } else if (field.dataType == Schema.DisplayType.Time) {
            setDefinition(field.fieldName, true, false,
                'static value(12:00:00)');
        }
    }

    /**
     * @description Sets the required fields.
     */
    private void setDefinitionOfRequiredFields() {
        handleInitializationOfRequiredFields();
        if (!this.requiredFieldsMustBeSet) {
            return;
        }

        if (this.sObjectApiName == 'User') {
            setDefinitionsOfRequiredFieldsForUser();
        } else {
            setDefinitionsOfRequiredFieldsForSObjectsExceptUser();
        }

        if (this.requiredFieldNames.isEmpty()) {
            forceeaDebug(INFO, 'Found no required fields');
        }

        if (FObject.isGlobalMocking) {
            this.fields.add('Id');
            Definition def = new Definition(
                'Id', 'Id', false, false, 'mock type(id)');
            this.definitions.add(def);
        }
    }

    /**
     * @description Declares the definitions of required fields for all SObjects except User.
     */
    private void setDefinitionsOfRequiredFieldsForSObjectsExceptUser() {
        for (Field field : this.sObjectFieldsMap.values()) {
            String fieldApiName = field.fieldApiName;
            if (field.isRequired && (!this.fields.contains(fieldApiName))) { // field required and not defined yet
                setDefinitionFromField(field);
                this.requiredFieldNames.add(fieldApiName);
                forceeaDebug(DEBUG, SYMBOL_SUCCESS + ' ' + MESSAGE_GENERATED_DEFINITION +
                    ' [' + fieldApiName + ']');
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
        requiredDefinitions.add('random type(firstname) group(name)');
        this.requiredFieldNames.add('LastName');
        requiredDefinitions.add('random type(lastname) group(name)');
        this.requiredFieldNames.add('Username');
        requiredDefinitions.add('random type(email)');
        this.requiredFieldNames.add('Email');
        requiredDefinitions.add('copy field(Username)');
        this.requiredFieldNames.add('EmailEncodingKey');
        requiredDefinitions.add('static value(UTF-8)');
        this.requiredFieldNames.add('TimeZonesIdKey');
        requiredDefinitions.add('static value(GMT)');
        this.requiredFieldNames.add('LocalesIdKey');
        requiredDefinitions.add('static value(en_US)');
        this.requiredFieldNames.add('LanguageLocaleKey');
        requiredDefinitions.add('static value(en_US)');
        this.requiredFieldNames.add('ProfileId');
        requiredDefinitions.add('static lookup(profile) field(name) value(Standard User) source(salesforce)');

        for (Integer counter = 0; counter < this.requiredFieldNames.size(); counter++) {
            String fieldName = this.requiredFieldNames.get(counter);
            if (!this.fields.contains(fieldName)) { // if field is not defined
                setDefinition(fieldName, true, false, requiredDefinitions.get(counter));
                forceeaDebug(DEBUG, SYMBOL_SUCCESS + ' ' + MESSAGE_GENERATED_DEFINITION + ' [' + fieldName + ']');
            }
        }
    }

    /**
     * @description Declares all definition types.
     */
    private static void setDefinitionTypes() {
        FObject.setDefinitionTypesOfMock();
        FObject.setDefinitionTypesOfRandomPrimitives();
        FObject.setDefinitionTypesOfRandomPicklist();
        FObject.setDefinitionTypesOfRandomAddress();
        FObject.setDefinitionTypesOfRandomNames();
        FObject.setDefinitionTypesOfRandomLookup();
        FObject.setDefinitionTypesOfRandomDetails();
        FObject.setDefinitionTypesOfRandomText();
        FObject.setDefinitionTypesOfRandomList();
        FObject.setDefinitionTypesOfStatic();
        FObject.setDefinitionTypesOfSerial();
        FObject.setDefinitionTypesOfCopy();
    }

    /**
     * @description Sets the definition types of copy.
     */
    private static void setDefinitionTypesOfCopy() {
        DefinitionType dt = new DefinitionType();

        // example: copy field(Rating)
        dt = new DefinitionType(DefinitionTypeId.COPY_FIELD, 'CopyField', 'copy');
        dt.clusterTypes.add(new ClusterType('field', ValueType.TYPE_STRING, null, false));
        FObject.definitionTypes.add(dt);

        // example: copy field(AccountId) from(Account.Rating)
        dt = new DefinitionType(DefinitionTypeId.COPY_LOOKUP, 'CopyLookupField', 'copy');
        dt.clusterTypes.add(new ClusterType('field', ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new ClusterType('from', ValueType.TYPE_STRING, null, false));
        FObject.definitionTypes.add(dt);
    }

    /**
     * @description Sets the definition types of random addresses.
     */
    private static void setDefinitionTypesOfRandomAddress() {
        DefinitionType dt = new DefinitionType();

        // example: random type(street) group(billing)
        dt = new DefinitionType(DefinitionTypeId.RANDOM_STREET, 'RandomStreet', 'random');
        dt.clusterTypes.add(new ClusterType('type', ValueType.TYPE_STRING, 'street', false));
        dt.clusterTypes.add(new ClusterType('group', ValueType.TYPE_STRING, null, false));
        FObject.definitionTypes.add(dt);

        // example: random type(postalcode) group(STRING)
        dt = new DefinitionType(DefinitionTypeId.RANDOM_POSTALCODE, 'RandomPostalCode', 'random');
        dt.clusterTypes.add(new ClusterType('type', ValueType.TYPE_STRING, 'postalcode', false));
        dt.clusterTypes.add(new ClusterType('group', ValueType.TYPE_STRING, null, false));
        FObject.definitionTypes.add(dt);

        // example: random type(city) group(billing)
        dt = new DefinitionType(DefinitionTypeId.RANDOM_CITY, 'RandomCity', 'random');
        dt.clusterTypes.add(new ClusterType('type', ValueType.TYPE_STRING, 'city', false));
        dt.clusterTypes.add(new ClusterType('group', ValueType.TYPE_STRING, null, false));
        FObject.definitionTypes.add(dt);

        // example: random type(state) group(billing)
        dt = new DefinitionType(DefinitionTypeId.RANDOM_STATE, 'RandomState', 'random');
        dt.clusterTypes.add(new ClusterType('type', ValueType.TYPE_STRING, 'state', false));
        dt.clusterTypes.add(new ClusterType('group', ValueType.TYPE_STRING, null, false));
        FObject.definitionTypes.add(dt);

        // example: random type(country) group(billing)
        dt = new DefinitionType(DefinitionTypeId.RANDOM_COUNTRY, 'RandomCountry', 'random');
        dt.clusterTypes.add(new ClusterType('type', ValueType.TYPE_STRING, 'country', false));
        dt.clusterTypes.add(new ClusterType('group', ValueType.TYPE_STRING, null, false));
        FObject.definitionTypes.add(dt);
    }

    /**
     * @description Sets the definition types of random details.
     */
    private static void setDefinitionTypesOfRandomDetails() {
        DefinitionType dt = new DefinitionType();

        // example: random type(email)
        dt = new DefinitionType(DefinitionTypeId.RANDOM_EMAIL, 'RandomEmail', 'random');
        dt.clusterTypes.add(new ClusterType('type', ValueType.TYPE_STRING, 'email', false));
        FObject.definitionTypes.add(dt);

        // example: random type(url)
        dt = new DefinitionType(DefinitionTypeId.RANDOM_URL, 'RandomUrl', 'random');
        dt.clusterTypes.add(new ClusterType('type', ValueType.TYPE_URL, 'url', false));
        FObject.definitionTypes.add(dt);

        // example: random type(phone) format("(353) dd dd ddd")
        dt = new DefinitionType(DefinitionTypeId.RANDOM_PHONE, 'RandomPhone', 'random');
        dt.clusterTypes.add(new ClusterType('type', ValueType.TYPE_STRING, 'phone', false));
        dt.clusterTypes.add(new ClusterType('format', ValueType.TYPE_STRING, null, false));
        FObject.definitionTypes.add(dt);
    }

    /**
     * @description Sets the definition types of random lists.
     */
    private static void setDefinitionTypesOfRandomList() {
        DefinitionType dt = new DefinitionType();

        // example: random type(list) value(1, 2, 3)
        dt = new DefinitionType(DefinitionTypeId.RANDOM_LIST_INTEGER, 'RandomListInteger', 'random');
        dt.clusterTypes.add(new ClusterType('type', ValueType.TYPE_STRING, 'list', false));
        dt.clusterTypes.add(new ClusterType('value', ValueType.TYPE_INTEGER, null, true));
        FObject.definitionTypes.add(dt);

        // example: random type(list) value(1.1, 2.2, 3.3)
        dt = new DefinitionType(DefinitionTypeId.RANDOM_LIST_DECIMAL, 'RandomListDecimal', 'random');
        dt.clusterTypes.add(new ClusterType('type', ValueType.TYPE_STRING, 'list', false));
        dt.clusterTypes.add(new ClusterType('value', ValueType.TYPE_DECIMAL, null, true));
        FObject.definitionTypes.add(dt);

        // example: random type(list) value(2017-1-1 01:01:01, 2017-2-2 02:02:02, 2017-3-3 03:03:03)
        dt = new DefinitionType(DefinitionTypeId.RANDOM_LIST_DATETIME, 'RandomListDatetime', 'random');
        dt.clusterTypes.add(new ClusterType('type', ValueType.TYPE_STRING, 'list', false));
        dt.clusterTypes.add(new ClusterType('value', ValueType.TYPE_DATETIME, null, true));
        FObject.definitionTypes.add(dt);

        // example: random type(list) value(01:01:01, 02:02:02, 03:03:03)
        dt = new DefinitionType(DefinitionTypeId.RANDOM_LIST_TIME, 'RandomListTime', 'random');
        dt.clusterTypes.add(new ClusterType('type', ValueType.TYPE_STRING, 'list', false));
        dt.clusterTypes.add(new ClusterType('value', ValueType.TYPE_TIME, null, true));
        FObject.definitionTypes.add(dt);

        // example: random type(list) value(2017-1-1, 2017-2-2, 2017-3-3)
        dt = new DefinitionType(DefinitionTypeId.RANDOM_LIST_DATE, 'RandomListDate', 'random');
        dt.clusterTypes.add(new ClusterType('type', ValueType.TYPE_STRING, 'list', false));
        dt.clusterTypes.add(new ClusterType('value', ValueType.TYPE_DATE, null, true));
        FObject.definitionTypes.add(dt);

        // example: random type(list) value(One, Two, Three)
        dt = new DefinitionType(DefinitionTypeId.RANDOM_LIST_STRING, 'RandomListString', 'random');
        dt.clusterTypes.add(new ClusterType('type', ValueType.TYPE_STRING, 'list', false));
        dt.clusterTypes.add(new ClusterType('value', ValueType.TYPE_STRING, null, true));
        FObject.definitionTypes.add(dt);
    }

    /**
     * @description Sets the definition types of random lookups.
     */
    private static void setDefinitionTypesOfRandomLookup() {
        DefinitionType dt = new DefinitionType();

        // example: random lookup(Account) source(forceea)
        dt = new DefinitionType(DefinitionTypeId.RANDOM_LOOKUP, 'RandomLookup', 'random');
        dt.clusterTypes.add(new ClusterType('lookup', ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new ClusterType('source', ValueType.TYPE_STRING, null, false));
        FObject.definitionTypes.add(dt);

        // example: random lookup(Account) field(Name) value(Company XYZ) source(forceea)
        dt = new DefinitionType(DefinitionTypeId.RANDOM_LOOKUP, 'RandomLookupFieldValue', 'random');
        dt.clusterTypes.add(new ClusterType('lookup', ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new ClusterType('field', ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new ClusterType('value', ValueType.TYPE_STRING, null, true));
        dt.clusterTypes.add(new ClusterType('source', ValueType.TYPE_STRING, null, false));
        FObject.definitionTypes.add(dt);

        // example: random lookup(Account) field(Name) except(Company XYZ) source(salesforce)
        dt = new DefinitionType(DefinitionTypeId.RANDOM_LOOKUP, 'RandomLookupFieldExcept', 'random');
        dt.clusterTypes.add(new ClusterType('lookup', ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new ClusterType('field', ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new ClusterType('except', ValueType.TYPE_STRING, null, true));
        dt.clusterTypes.add(new ClusterType('source', ValueType.TYPE_STRING, null, false));
        FObject.definitionTypes.add(dt);

        // example: random lookup(Account) group(one) source(salesforce)
        dt = new DefinitionType(DefinitionTypeId.RANDOM_LOOKUP, 'RandomLookupGroup', 'random');
        dt.clusterTypes.add(new ClusterType('lookup', ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new ClusterType('group', ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new ClusterType('source', ValueType.TYPE_STRING, null, false));
        FObject.definitionTypes.add(dt);

        // example: random lookup(Account) field(Name) value(Company XYZ) group(one) source(forceea)
        dt = new DefinitionType(DefinitionTypeId.RANDOM_LOOKUP, 'RandomLookupFieldValueGroup', 'random');
        dt.clusterTypes.add(new ClusterType('lookup', ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new ClusterType('field', ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new ClusterType('value', ValueType.TYPE_STRING, null, true));
        dt.clusterTypes.add(new ClusterType('group', ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new ClusterType('source', ValueType.TYPE_STRING, null, false));
        FObject.definitionTypes.add(dt);

        // example: random lookup(Account) field(Name) except(Company XYZ) group(one) source(forceea)
        dt = new DefinitionType(DefinitionTypeId.RANDOM_LOOKUP, 'RandomLookupFieldExceptGroup', 'random');
        dt.clusterTypes.add(new ClusterType('lookup', ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new ClusterType('field', ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new ClusterType('except', ValueType.TYPE_STRING, null, true));
        dt.clusterTypes.add(new ClusterType('group', ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new ClusterType('source', ValueType.TYPE_STRING, null, false));
        FObject.definitionTypes.add(dt);

        // example: random lookup(Account) where(Rating = 'Hot') source(salesforce)
        dt = new DefinitionType(DefinitionTypeId.RANDOM_LOOKUP_WHERE, 'RandomLookupWhereSalesforce', 'random');
        dt.clusterTypes.add(new ClusterType('lookup', ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new ClusterType('where', ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new ClusterType('source', ValueType.TYPE_STRING, 'salesforce', false));
        FObject.definitionTypes.add(dt);
    }

    /**
     * @description Sets the definition types of mocking.
    */
    private static void setDefinitionTypesOfMock() {
        DefinitionType dt = new DefinitionType();

        // example: mock type(id)
        dt = new DefinitionType(DefinitionTypeId.MOCK_ID, 'MockId', 'mock');
        dt.clusterTypes.add(new ClusterType('type', ValueType.TYPE_STRING, null, false));
        FObject.definitionTypes.add(dt);
    }

    /**
     * @description Sets the definition types of random names.
     */
    private static void setDefinitionTypesOfRandomNames() {
        DefinitionType dt = new DefinitionType();

        // example: random type(firstname) group(billing)
        dt = new DefinitionType(DefinitionTypeId.RANDOM_FIRSTNAME, 'RandomFirstName', 'random');
        dt.clusterTypes.add(new ClusterType('type', ValueType.TYPE_STRING, 'firstname', false));
        dt.clusterTypes.add(new ClusterType('group', ValueType.TYPE_STRING, null, false));
        FObject.definitionTypes.add(dt);

        // example: random type(lastname) group(billing)
        dt = new DefinitionType(DefinitionTypeId.RANDOM_LASTNAME, 'RandomLastName', 'random');
        dt.clusterTypes.add(new ClusterType('type', ValueType.TYPE_STRING, 'lastname', false));
        dt.clusterTypes.add(new ClusterType('group', ValueType.TYPE_STRING, null, false));
        FObject.definitionTypes.add(dt);
    }

    /**
     * @description Sets the definition types of random primitives.
     */
    private static void setDefinitionTypesOfRandomPrimitives() {
        DefinitionType dt = new DefinitionType();

        // example: random type(boolean)
        dt = new DefinitionType(DefinitionTypeId.RANDOM_BOOLEAN, 'RandomBoolean', 'random');
        dt.clusterTypes.add(new ClusterType('type', ValueType.TYPE_STRING, 'boolean', false));
        FObject.definitionTypes.add(dt);

        // example: random type(number) from(10) to(100) scale(0)
        dt = new DefinitionType(DefinitionTypeId.RANDOM_NUMBER, 'RandomNumber', 'random');
        dt.clusterTypes.add(new ClusterType('type', ValueType.TYPE_STRING, 'number', false));
        dt.clusterTypes.add(new ClusterType('from', ValueType.TYPE_DECIMAL, null, false));
        dt.clusterTypes.add(new ClusterType('to', ValueType.TYPE_DECIMAL, null, false));
        dt.clusterTypes.add(new ClusterType('scale', ValueType.TYPE_INTEGER, null, false));
        FObject.definitionTypes.add(dt);

        // example: random type(date) from(2010-01-01) to(2015-12-31)
        dt = new DefinitionType(DefinitionTypeId.RANDOM_DATE, 'RandomDate', 'random');
        dt.clusterTypes.add(new ClusterType('type', ValueType.TYPE_STRING, 'date', false));
        dt.clusterTypes.add(new ClusterType('from', ValueType.TYPE_DATE, null, false));
        dt.clusterTypes.add(new ClusterType('to', ValueType.TYPE_DATE, null, false));
        FObject.definitionTypes.add(dt);

        // example: random type(datetime) from(2010-01-01) to(2015-12-31)
        dt = new DefinitionType(DefinitionTypeId.RANDOM_DATETIME, 'RandomDatetimeDateDate', 'random');
        dt.clusterTypes.add(new ClusterType('type', ValueType.TYPE_STRING, 'datetime', false));
        dt.clusterTypes.add(new ClusterType('from', ValueType.TYPE_DATE, null, false));
        dt.clusterTypes.add(new ClusterType('to', ValueType.TYPE_DATE, null, false));
        FObject.definitionTypes.add(dt);

        // example: random type(datetime) from(2010-01-01) to(2015-12-31 01:01:01)
        dt = new DefinitionType(DefinitionTypeId.RANDOM_DATETIME, 'RandomDatetimeDateDatetime', 'random');
        dt.clusterTypes.add(new ClusterType('type', ValueType.TYPE_STRING, 'datetime', false));
        dt.clusterTypes.add(new ClusterType('from', ValueType.TYPE_DATE, null, false));
        dt.clusterTypes.add(new ClusterType('to', ValueType.TYPE_DATETIME, null, false));
        FObject.definitionTypes.add(dt);

        // example: random type(datetime) from(2010-01-01 01:01:01) to(2015-12-31 01:01:01)
        dt = new DefinitionType(DefinitionTypeId.RANDOM_DATETIME, 'RandomDatetimeDatetimeDate', 'random');
        dt.clusterTypes.add(new ClusterType('type', ValueType.TYPE_STRING, 'datetime', false));
        dt.clusterTypes.add(new ClusterType('from', ValueType.TYPE_DATETIME, null, false));
        dt.clusterTypes.add(new ClusterType('to', ValueType.TYPE_DATE, null, false));
        FObject.definitionTypes.add(dt);

        // example: random type(datetime) from(2010-01-01 01:01:01) to(2015-12-31)
        dt = new DefinitionType(DefinitionTypeId.RANDOM_DATETIME, 'RandomDatetimeDatetimeDatetime', 'random');
        dt.clusterTypes.add(new ClusterType('type', ValueType.TYPE_STRING, 'datetime', false));
        dt.clusterTypes.add(new ClusterType('from', ValueType.TYPE_DATETIME, null, false));
        dt.clusterTypes.add(new ClusterType('to', ValueType.TYPE_DATETIME, null, false));
        FObject.definitionTypes.add(dt);
    }

    /**
     * @description Sets the definition types of random pisklicts.
     */
    private static void setDefinitionTypesOfRandomPicklist() {
        DefinitionType dt = new DefinitionType();

        // example: random type(picklist)
        dt = new DefinitionType(DefinitionTypeId.RANDOM_PICKLIST, 'RandomPicklist', 'random');
        dt.clusterTypes.add(new ClusterType('type', ValueType.TYPE_STRING, 'picklist', false));
        FObject.definitionTypes.add(dt);

        // example: random type(picklist) except(a,b,c)
        dt = new DefinitionType(DefinitionTypeId.RANDOM_PICKLIST_EXCEPT, 'RandomPicklistExcept', 'random');
        dt.clusterTypes.add(new ClusterType('type', ValueType.TYPE_STRING, 'picklist', false));
        dt.clusterTypes.add(new ClusterType('except', ValueType.TYPE_STRING, null, true));
        FObject.definitionTypes.add(dt);
    }

    /**
     * @description Sets the definition types of random texts.
     */
    private static void setDefinitionTypesOfRandomText() {
        DefinitionType dt = new DefinitionType();

        // example: random type(string)
        dt = new DefinitionType(DefinitionTypeId.RANDOM_STRING, 'RandomString', 'random');
        dt.clusterTypes.add(new ClusterType('type', ValueType.TYPE_STRING, 'string', false));
        dt.clusterTypes.add(new ClusterType('minlength', ValueType.TYPE_INTEGER, null, false));
        dt.clusterTypes.add(new ClusterType('maxlength', ValueType.TYPE_INTEGER, null, false));
        dt.clusterTypes.add(new ClusterType('startwith', ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new ClusterType('include', ValueType.TYPE_STRING, null, true));
        FObject.definitionTypes.add(dt);

        // example: random type(text) minlength(20) maxlength(40)
        dt = new DefinitionType(DefinitionTypeId.RANDOM_TEXT, 'RandomText', 'random');
        dt.clusterTypes.add(new ClusterType('type', ValueType.TYPE_STRING, 'text', false));
        dt.clusterTypes.add(new ClusterType('minlength', ValueType.TYPE_INTEGER, null, false));
        dt.clusterTypes.add(new ClusterType('maxlength', ValueType.TYPE_INTEGER, null, false));
        FObject.definitionTypes.add(dt);
    }

    /**
     * @description Sets the definition types of serials.
     */
    private static void setDefinitionTypesOfSerial() {
        DefinitionType dt = new DefinitionType();

        // example: serial type(number) from(10.2) step(1.2) scale(2)
        dt = new DefinitionType(DefinitionTypeId.SERIAL_NUMBER, 'SerialNumber', 'serial');
        dt.clusterTypes.add(new ClusterType('type', ValueType.TYPE_STRING, 'number', false));
        dt.clusterTypes.add(new ClusterType('from', ValueType.TYPE_DECIMAL, null, false));
        dt.clusterTypes.add(new ClusterType('step', ValueType.TYPE_DECIMAL, null, false));
        dt.clusterTypes.add(new ClusterType('scale', ValueType.TYPE_INTEGER, null, false));
        FObject.definitionTypes.add(dt);

        // example: serial type(date) from(2017-01-01) step(1)
        dt = new DefinitionType(DefinitionTypeId.SERIAL_DATE, 'SerialDate', 'serial');
        dt.clusterTypes.add(new ClusterType('type', ValueType.TYPE_STRING, 'date', false));
        dt.clusterTypes.add(new ClusterType('from', ValueType.TYPE_DATE, null, false));
        dt.clusterTypes.add(new ClusterType('step', ValueType.TYPE_INTEGER, null, false));
        FObject.definitionTypes.add(dt);

        // example: serial type(datetime) from(2017-01-01) step(1.2)
        dt = new DefinitionType(DefinitionTypeId.SERIAL_DATETIME, 'SerialDatetimeFromDate', 'serial');
        dt.clusterTypes.add(new ClusterType('type', ValueType.TYPE_STRING, 'datetime', false));
        dt.clusterTypes.add(new ClusterType('from', ValueType.TYPE_DATE, null, false));
        dt.clusterTypes.add(new ClusterType('step', ValueType.TYPE_DECIMAL, null, false));
        FObject.definitionTypes.add(dt);

        // example: serial type(datetime) from(2017-01-01 01:01:01) step(1.2)
        dt = new DefinitionType(DefinitionTypeId.SERIAL_DATETIME, 'SerialDatetimeFromDatetime', 'serial');
        dt.clusterTypes.add(new ClusterType('type', ValueType.TYPE_STRING, 'datetime', false));
        dt.clusterTypes.add(new ClusterType('from', ValueType.TYPE_DATETIME, null, false));
        dt.clusterTypes.add(new ClusterType('step', ValueType.TYPE_DECIMAL, null, false));
        FObject.definitionTypes.add(dt);

        // example: serial lookup(Account) mode(cyclical) source(forceea)
        dt = new DefinitionType(DefinitionTypeId.SERIAL_LOOKUP, 'SerialLookup', 'serial');
        dt.clusterTypes.add(new ClusterType('lookup', ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new ClusterType('mode', ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new ClusterType('source', ValueType.TYPE_STRING, null, false));
        FObject.definitionTypes.add(dt);

        // example: serial lookup(Account) mode(cyclical) group(one) source(forceea)
        dt = new DefinitionType(DefinitionTypeId.SERIAL_LOOKUP, 'SerialLookupGroup', 'serial');
        dt.clusterTypes.add(new ClusterType('lookup', ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new ClusterType('mode', ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new ClusterType('group', ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new ClusterType('source', ValueType.TYPE_STRING, null, false));
        FObject.definitionTypes.add(dt);
    }

    /**
     * @description Sets the definition types of statics.
     */
    private static void setDefinitionTypesOfStatic() {
        DefinitionType dt = new DefinitionType();

        // example: static value(10)
        dt = new DefinitionType(DefinitionTypeId.STATIC_INTEGER, 'StaticInteger', 'static');
        dt.clusterTypes.add(new ClusterType('value', ValueType.TYPE_INTEGER, null, false));
        FObject.definitionTypes.add(dt);

        // example: static value(10.2)
        dt = new DefinitionType(DefinitionTypeId.STATIC_DECIMAL, 'StaticDecimal', 'static');
        dt.clusterTypes.add(new ClusterType('value', ValueType.TYPE_DECIMAL, null, false));
        FObject.definitionTypes.add(dt);

        // example: static value(01:01:01)
        dt = new DefinitionType(DefinitionTypeId.STATIC_TIME, 'StaticTime', 'static');
        dt.clusterTypes.add(new ClusterType('value', ValueType.TYPE_TIME, null, false));
        FObject.definitionTypes.add(dt);

        // example: static value(2017-1-1 01:01:01)
        dt = new DefinitionType(DefinitionTypeId.STATIC_DATETIME, 'StaticDatetime', 'static');
        dt.clusterTypes.add(new ClusterType('value', ValueType.TYPE_DATETIME, null, false));
        FObject.definitionTypes.add(dt);

        // example: static value(2017-1-1)
        dt = new DefinitionType(DefinitionTypeId.STATIC_DATE, 'StaticDate', 'static');
        dt.clusterTypes.add(new ClusterType('value', ValueType.TYPE_DATE, null, false));
        FObject.definitionTypes.add(dt);

        // example: static value(abc)
        dt = new DefinitionType(DefinitionTypeId.STATIC_STRING, 'StaticString', 'static');
        dt.clusterTypes.add(new ClusterType('value', ValueType.TYPE_STRING, null, false));
        FObject.definitionTypes.add(dt);

        // example: static lookup(Account) field(Name) value(Company XYZ) source(forceea)
        dt = new DefinitionType(DefinitionTypeId.STATIC_LOOKUP, 'StaticLookup', 'static');
        dt.clusterTypes.add(new ClusterType('lookup', ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new ClusterType('field', ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new ClusterType('value', ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new ClusterType('source', ValueType.TYPE_STRING, null, false));
        FObject.definitionTypes.add(dt);
    }

    /**
     * @description Sets the controlling fields' definition
     */
    private void setDependentFields() {
        Integer depFieldPosition = -1; // the position of dependent field's definition
        Integer ctrlFieldPosition = -1; // the position of controlling field's definition
        String depFieldApiName = ''; // the dependent field API name
        String ctrlFieldApiName = ''; // the controlling field API name
        Field field = new Field(); // the field details of the dependent field
        List<Definition> existingDefinitions = new List<Definition>(this.definitions);

        for (Definition def : existingDefinitions) { // for each definition
            if (fieldIsVirtual(def.fieldApiName)) {
                continue;
            }

            depFieldApiName = def.fieldApiName;
            field = this.sObjectFieldsMap.get(depFieldApiName.toLowerCase()); // get field details

            if (String.isBlank(field.controllingFieldApiName)) { // field doesn't have a controlling field
                continue; // go to next definition
            } else { // get controlling field's API name
                ctrlFieldApiName = field.controllingFieldApiName;
            }

            // the (dependent) field has a controlling field and it respects field dependencies
            Schema.DisplayType ctrlFieldType = this.sObjectFieldsMap.get(ctrlFieldApiName.toLowerCase()).dataType;

            // check the controlling field data type
            if (ctrlFieldType == Schema.DisplayType.Picklist || ctrlFieldType == Schema.DisplayType.MultiPicklist) {
                // get the position of dependent/controlling field definitions
                depFieldPosition = this.fields.indexOf(depFieldApiName);
                ctrlFieldPosition = this.fields.indexOf(ctrlFieldApiName);
            } else if (ctrlFieldType == Schema.DisplayType.Boolean) {
                forceeaDebug(WARN, 'The Checkbox field type is not supported ' +
                    'for the controlling field of dependent field [' + depFieldApiName + ']');
                continue;
            }

            if (ctrlFieldPosition == -1) { // controlling field is not defined
                String newDefinition = 'random type(picklist)';
                // create a new definition for the controlling field, before the definition of the dependent field
                forceeaDebug(INFO, 'Did not find a definition for the controlling field [' +
                    ctrlFieldApiName + '] of dependent field [' + depFieldApiName + '] and will generate a definition');
                setDefinition(ctrlFieldApiName, true, this.isFieldsUpdate, newDefinition);
            }
            upsertFieldBeforePosition(ctrlFieldApiName, depFieldPosition);
        }

        validateDefinitions();
    }

    /**
     * @description Sets Forceea settings based on default settings.
     */
    private static void setFrameworkSettings() {
        // get settings
        List<ForceeaSetting__mdt> forceeaSettings = [
            SELECT DeveloperName, RecordsToCreate__c, RecordsToDisplay__c,
                MaxErrorRecordsToDisplay__c, ShowDebugLog__c, UserMessage__c
            FROM ForceeaSetting__mdt
        ];

        // get default settings
        ForceeaSetting__mdt defaultSettings = new ForceeaSetting__mdt();
        for (ForceeaSetting__mdt item : forceeaSettings) {
            if (item.DeveloperName.toLowerCase() == 'default') {
                defaultSettings = item;
                break;
            }
        }

        if (defaultSettings == new ForceeaSetting__mdt()) { // there is no Default settings record
            FObject.numDefaultRecords = 201;
            FObject.numRecordsToDisplay = 20;
            FObject.numMaxErrorRecordsToDisplay = 20;
            FObject.showDebugLog = true;
            FObject.userMessage = '';
        } else {
            FObject.numDefaultRecords = defaultSettings.RecordsToCreate__c.intValue();
            FObject.numRecordsToDisplay = defaultSettings.RecordsToDisplay__c.intValue();
            FObject.numMaxErrorRecordsToDisplay = defaultSettings.MaxErrorRecordsToDisplay__c.intValue();
            FObject.showDebugLog = defaultSettings.ShowDebugLog__c;
            FObject.userMessage = defaultSettings.UserMessage__c;
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
     * @param isMocked If true, Forceeas sets ID mocking for all FObjects.
     */
    public static void setGlobalMocking(Boolean isMocked) {
        FObject.isGlobalMocking = isMocked;
    }

    /**
     * @description Sets the static properties.
     */
    private static void setGlobalProperties() {
        FObject.exceptionErrorMessageIsDisplayed = false;
        FObject.initializationMessageIsDisplayed = false;
        FObject.isAsync = false;
        FObject.isOnValidation = false;
        FObject.isGlobalMocking = false;
        FObject.globalQueryLimit = DEFAULT_QUERY_LIMIT;
        FObject.globalVerboseMode = VERBOSE_MODE;
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
     * @description Initializes instance properties.
     */
    private void setInstanceProperties() {
        this.cpuTimeOfObjectSetup = 0;
        this.cpuTimeStartOfObjectSetup = 0;
        this.cpuTimeOfDataGeneration = 0;
        this.cpuTimeStartOfDataGeneration = 0;
        this.definitionsAreValidated = false;
        this.excludeInactiveLookupRecords = true;
        this.groupName = '';
        this.isInsert = false;
        this.isMocking = false;
        this.isFieldsUpdate = false;
        this.isRecordsUpdate = false;
        this.mustCreateNewRecords = true;
        this.numValidatedDefinitions = 0;
        this.queryLimit = FObject.globalQueryLimit;
        this.requiredFieldsMustBeSet = true;
        this.sObjType = FObject.globalDescribe.get(this.sObjectApiName);
        this.virtualFieldForStandardPriceBookEntries = '';
        this.willValidateFieldDefinitionsMessageIsDisplayed = false;
    }

    /**
     * @description Sets the number of the first record to be created for serial values.
     * @param numberOfNextRecord The number of of the next record.
     * @return An FObject instance.
     */
    public FObject setNumberOfNextRecord(Integer numberOfNextRecord) {
        Integer numFirstRecord = (numberOfNextRecord <= 0) ? 1 : numberOfNextRecord;
        FObject.numFirstRecordsBySObject.put(this.sObjectApiName, numFirstRecord);

        return this;
    }

    /**
     * @description Sets the number of records.
     * @param numberOfRecords The number of records.
     * @return An FObject instance.
     */
    public FObject setNumberOfRecords(Integer numberOfRecords) {
        if (numberOfRecords <= 0)
        {
            this.records = 1;
        } else {
            this.records = numberOfRecords;
        }

        return this;
    }

    /**
     * @description Stores the SObject field details to the global fields map.
     * @param sObjectApiName The SObject API name.
     */
    private static void setSObject(String sObjectApiName) {
        Map<String, Field> fieldsMap = new Map<String, Field>();
        Schema.SObjectType objType = FObject.globalDescribe.get(sObjectApiName);

        for (Schema.SObjectField sof : objType.getDescribe().fields.getMap().values()) {
            Field field = FObject.getDetailsFromSObjectField(sof);
            fieldsMap.put(field.fieldApiName.toLowerCase(), field);
        }

        FObject.globalSObjectFieldsMap.put(sObjectApiName.toLowerCase(), fieldsMap); // add SObject fields to global map
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
    public void setRecordTypes() {
        if (!FObject.rtInfosBySObject.containsKey(this.sObjType)) {
            List<Schema.RecordTypeInfo> rtInfos = new List<Schema.RecordTypeInfo>();
            for (Schema.RecordTypeInfo rti : this.sObjType.getDescribe().getRecordTypeInfos()) {
                if (!rti.isMaster() && rti.isActive()) {
                    rtInfos.add(rti);
                }
            }
            FObject.rtInfosBySObject.put(this.sObjType, rtInfos);
        }

        for (Schema.RecordTypeInfo rti : FObject.rtInfosBySObject.get(this.sObjType)) {
            this.recordTypesMap.put(rti.getDeveloperName().toLowerCase(), rti.getRecordTypeId());
        }
    }

    /**
     * @description Set SObject fields map.
     */
    public void setSObjectFieldsMap() {
        if (!FObject.globalSObjectFieldsMap.containsKey(this.sObjectApiName.toLowerCase())) { // SObject is not defined
            FObject.setSObject(this.sObjectApiName); // store SObject field details to global fields map
        }
        this.sObjectFieldsMap = FObject.globalSObjectFieldsMap.get(this.sObjectApiName.toLowerCase()); // get stored fields details
    }

    /**
     * @description Sets if Forceea should set the required fields.
     * @param fieldsAreRequired If true, Forceea automatically defines the required fields.
     * @return An FObject instance.
     */
    public FObject setRequiredFields(Boolean fieldsAreRequired) {
        this.requiredFieldsMustBeSet = fieldsAreRequired;
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
	private void setSObjectFieldValue(
		SObject result, Schema.DisplayType valueType, String fieldName, String fieldValue) {
		switch on valueType {
			when String, Picklist {
				result.put(fieldName, fieldValue);
			}
			when Double {
				result.put(fieldName, Double.valueOf(fieldValue));
			}
			when Currency {
				result.put(fieldName, Decimal.valueOf(fieldValue));
			}
			when Boolean {
				result.put(fieldName, Boolean.valueOf(fieldValue));
			}
			when Date {
				result.put(fieldName, Date.valueOf(fieldValue));
			}
			when Percent {
				result.put(fieldName, Decimal.valueOf(fieldValue));
			}
			when Datetime {
				result.put(fieldName, Datetime.valueOf(fieldValue));
			}
			when Integer {
				result.put(fieldName, Integer.valueOf(fieldValue));
			}
			when Time {
				Time valueTime;
				String thisYear = String.valueOf(Date.today().year());
				valueTime = Datetime.valueOf(thisYear + '-01-01 ' + fieldValue).Time();
				result.put(fieldName, valueTime);
			}
			when Base64 {
				result.put(fieldName, Blob.valueOf(fieldValue));
			}
			when else { // any other type
				result.put(fieldName, fieldValue);
			}
		}
	}

    /**
     * @description Sets the API names of all SObjects.
     */
    private static void setSObjectApiNames() {
        for (Schema.SObjectType sot : FObject.globalDescribe.values()) {
            FObject.sObjectApiNames.add(sot.getDescribe().getName());
        }
    }

    /**
     * @description Inserts entries for the Standard Price Book using the values of a virtual field.
     * @param virtualFieldName The virtual field name.
     * @return An FObject instance.
     */
    public FObject setStandardPricebookEntries(String virtualFieldName) {
        String thisVirtualFieldName = virtualFieldName.trim();

	    if (!virtualFieldIsValid(thisVirtualFieldName)) {
		    addError(this.sObjectApiName, 'Invalid virtual field [' + virtualFieldName.trim() +
			    '] for method setStandardPricebookEntries');
		    return this;
	    }

        this.virtualFieldForStandardPriceBookEntries = thisVirtualFieldName;

        return this;
    }

	/**
	 * @description Validates a virtual field name.
	 * @param virtualFieldName The virtual field name.
	 * @return True, if the virtual field is valid.
	 */
    @TestVisible
	private Boolean virtualFieldIsValid(String virtualFieldName) {
		Boolean result = true;

        String fieldName = virtualFieldName.trim();
        String fieldWithoutDollar = fieldName.replace('$', '');

        Boolean firstCharIsNotDollar = fieldName.left(1) != '$';
        Boolean isBlank = String.isBlank(fieldName);
        Boolean containsWhiteSpace = fieldName.containsWhitespace();
        Boolean hasIllegalCharacters = !fieldWithoutDollar.isAlpha();

        if (firstCharIsNotDollar || isBlank || containsWhiteSpace || hasIllegalCharacters) {
            result = false;
        }
		return result;
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
     * @description Validates a source.
     * @param source The definition source.
     * @return A boolean value.
     */
    private Boolean sourceIsValid(String source) {
        return (FObject.sourcesSet.contains(source.toLowerCase()));
    }

    /**
     * @description Inserts or moves a field before a specific position of the fields list.
     *   If the field exists, it is moved before the position.
     *   If it doesn't exist, it is inserted before the position.
     * @param fieldApiName The field API name.
     * @param position The position of the fields list.
     */
    private void upsertFieldBeforePosition(String fieldApiName, Integer position) {
        Boolean mustAddField = false;

        if (this.fields.contains(fieldApiName)) { // field exists
            Integer fieldPosition = this.fields.indexOf(fieldApiName); // get field's position
            if (position < fieldPosition) { // field must be moved
                this.fields.remove(fieldPosition); // delete field
                mustAddField = true;
            }
        } else { // field does not exist
            mustAddField = true;
        }

        if (mustAddField) {
            if (position == 0) {
                this.fields.add(0, fieldApiName); // add field in the first position
            } else {
                this.fields.add(position - 1, fieldApiName); // add field in the previous position
            }
        }
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
        if (processMustTerminate()) {
            return this;
        }

        onBeforeUpdateFields();
        handleRecordsWithUpdatedValues(groupName);
        onAfterUpdateFields();

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
        if (processMustTerminate() || allOrNone == null) {
            return results;
        }

        onBeforeRecordsUpdate();
        handleRecordsOnUpdate(allOrNone);
	    results = new List<Database.SaveResult>(this.saveResults);
	    onAfterRecordsUpdate();

	    return results;
    }

    /**
     * @description Validates the field definitions.
     */
    private void validateDefinitions() {
        if (this.definitionsAreValidated) {
            return;
        }

        if (!this.willValidateFieldDefinitionsMessageIsDisplayed) {
            forceeaDebug(DEBUG, MESSAGE_WILL_VALIDATE_FIELD_DEFINITIONS + ' of [' + this.sObjectApiName + ']');
            this.willValidateFieldDefinitionsMessageIsDisplayed = true;
        }

        this.numValidatedDefinitions = 0;
        for (Definition definition : this.definitions) {
            if (definition.isValidated) {
                continue;
            }

            parseDefinition(definition);
            this.numValidatedDefinitions++;

            if (definitionIsValid(definition)) {
                forceeaDebug(DEBUG, SYMBOL_SUCCESS + ' Definition [' + definition.definitionString +
                    '] of [' + definition.fieldApiName + '] is valid');
            }
        }

        this.definitionsAreValidated = true;
        this.setDependentFields();
    }

    /**
	* @description Validates the field definitions when updating field values.
	*/
    private void validateDefinitionsOnFieldValuesUpdate() {
        this.willValidateFieldDefinitionsMessageIsDisplayed = false;
        validateDefinitions();

        if (this.numValidatedDefinitions > 0) {
            resetMilestoneTimer('Validated definitions');
        }
    }

    /**
     * @description Validates the arguments of a cluster.
     * @param clusterType The cluster type.
     * @param cluster The cluster to validate.
     * @return Returns true if the cluster arguments are valid, based on cluster type.
     */
    private Boolean valueIsValid(ClusterType clusterType, Cluster cluster) {
        Boolean result = true;

        // if Value must have only 1 item but it has more
        if (!clusterType.allowsMultipleArguments && cluster.arguments.size() > 1) {
            return false;
        }

        // Value has the correct number of arguments
        if ((String.isNotBlank(clusterType.value) && // if the parameter has a value
            cluster.arguments.size() == 1 && // and there is only 1 argument
            clusterType.value != cluster.arguments[0])) { // and this is not the expected value
            return false;
        }

        // check the data type of all cluster arguments
        for (String argument : cluster.arguments) {
            if (clusterType.valueType == ValueType.TYPE_INTEGER) {
                try {
                    Integer value = Integer.valueOf(argument);
                } catch (System.TypeException ex) {
                    result = false;
                    break;
                }
            } else if (clusterType.valueType == ValueType.TYPE_DECIMAL) {
                try {
                    Decimal value = Decimal.valueOf(argument);
                } catch (System.TypeException ex) {
                    result = false;
                    break;
                }
            } else if (clusterType.valueType == ValueType.TYPE_DATE) {
                try {
                    Date value = Date.valueOf(argument);
                } catch (System.TypeException ex) {
                    result = false;
                    break;
                }
            } else if (clusterType.valueType == ValueType.TYPE_DATETIME) {
                try {
                    Datetime value = Datetime.valueOf(argument);
                } catch (System.TypeException ex) {
                    result = false;
                    break;
                }
            } else if (clusterType.valueType == ValueType.TYPE_TIME) {
                try {
                    argument = '2018-01-01 ' + argument;
                    Datetime value = Datetime.valueOf(argument);
                } catch (System.TypeException ex) {
                    result = false;
                    break;
                }
            }
        }

        return result;
    }

}