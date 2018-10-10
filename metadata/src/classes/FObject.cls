/*
  FORCEEA data factory framework (version 1.3.1)
  Copyright (C) 2018 Nikos Mitrakis

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
 * @description Forceea data factory framework
 * @version 1.3.1
 */
public with sharing virtual class FObject {

  /* CONSTANTS */

  private static final String VERSION = '1.3.1';
  private static final String MESSSAGE_NAMES = 'Loaded first & last names from ';
  private static final String MESSSAGE_ADDRESSES = 'Loaded addresses from ';
  private static final String FAILURE_SYMBOL = '►';
  public static final String SUCCESS_SYMBOL = '●';
  private static final String ERROR = 'error';
  public static final String WARN = 'warn';
  public static final String INFO = 'info';
  public static final String DEBUG = 'debug';
  private static final VerboseLevel VERBOSE_MODE = VerboseLevel.VERBOSE_NONE;

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
    SERIAL_NUMBER, SERIAL_DATE, SERIAL_DATETIME,
    COPY_FIELD, COPY_LOOKUP
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
    'copy', 'random', 'static', 'serial'
  };
  // the defined cluster types
  private static List<DefinitionType> definitionTypes = new List<DefinitionType>();
  // the libraries for first names - key: gender, value: first names
  private static Map<String, List<String>> firstNamesLibraryMap = new Map<String, List<String>>();
  // the inserted records of all objects
  // key: objectApiName or objectApiName.groupName (lowercase), value: list of records
  public static Map<String, List<SObject>> globalInsertedRecordsMap = new Map<String, List<SObject>>();
  // the field details of each declared FObject
  // key: object API name (lowercase), value: (key:field API name (lowercase), value: Field)
  private static Map<String, Map<String, Field>> globalObjectFieldsMap = new Map<String, Map<String, Field>>();
  // the libraries for last names - key: gender, value: last names
  private static Map<String, List<String>> lastNamesLibraryMap = new Map<String, List<String>>();
  // the valid script parameters
  private static Set<String> parametersSet = new Set<String>{
    'scale', 'except', 'field', 'format', 'from', 'group', 'include', 'lookup', 'maxlength', 'minlength',
    'number', 'object', 'source', 'startwith', 'step', 'to', 'type', 'value', 'where'
  };
  // the results of the Record types SOQL query
  private static List<RecordType> recordTypesQueryResults = new List<RecordType>();
  // the API names of all sObjects
  private static List<String> sObjectApiNames = new List<String>();

  /* INSTANCE COLLECTIONS */

  // the addresses - key: address group, value: address
  protected Map<String, List<FAddress>> addressesMap = new Map<String, List<FAddress>>();
  // the lastcreated object records
  protected List<SObject> createdRecords = new List<SObject>();
  // the declared field definitions
  protected List<Definition> definitions = new List<Definition>();
  // the definition errors
  private List<Error> errors = new List<Error>();
  // the fields with declared definitions
  protected List<String> fields = new List<String>();
  // the FVM, each List<string> contains a field's values
  private List<List<String>> fieldValuesMatrix = new List<List<String>>();
  // the first & last names - key: name group, value: name
  protected Map<String, List<Name>> namesMap = new Map<String, List<Name>>();
  // all object fields - key: field API name (lowercase), value: field object
  public Map<String, Field> objectFieldsMap = new Map<String, Field>();
  // the records to be inserted
  protected List<SObject> recordsToInsert = new List<SObject>();
  // the record types of this object - key: DeveloperName, value: Id)
  private Map<String, Id> recordTypesMap = new Map<String, Id>();

  /* STATIC PROPERTIES */

  // if true, the "Process is invalid and will terminate" error message has been displayed
  private static Boolean exceptionErrorMessageIsDisplayed { get; set; }
  // the level of verbose mode
  private static VerboseLevel globalVerboseMode { get; set; }
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
  // the maximum number of error records to display
  private static Integer maxErrorRecordsToDisplay { get; set; }
  // if true, the process has no errors (valid)
  public static Boolean processIsValid { get; private set; }
  // the default number of records to create
  private static Integer recordsToCreate { get; set; }
  // the number of created records to display
  private static Integer recordsToDisplay { get; set; }
  // if true, it displays messages in Debug Log
  @TestVisible private static Boolean showDebugLog { get; set; }
  // if true, the street number is after street, e.g. Abcd 12
  private static Boolean streetNumberAfterStreet { get; set; }
  // the message to display when initializing the FObject
  private static String userMessage { get; set; }
  // a pseudorandom number that is greater than or equal to 0.0 and less than 1.0
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
  // the process is anynchronous
  public static Boolean isAsync { get; set; }

  /* INSTANCE PROPERTIES */

  // true if all definitions are validated
  private Boolean definitionsAreValidated { get; set; }
  // exclude the lookup records with IsActive = false
  public Boolean excludeInactiveLookupRecords { get; set; }
  // true if found required fields
  private Boolean foundRequiredFields { get; set; }
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
  // true if new records must be created
  protected Boolean mustCreateNewRecords { get; set; }
  // the user-defined object name
  private String objectName { get; set; }
  // the API object name
  public String objectApiName { get; set; }
  // the number of the next record to be created
  protected Integer recordNumber { get; set; }
  // the number of records to create
  public Integer records { get; set; }
  // true if Forceea sets all equired fields
  public Boolean setRequiredFields { get; set; }
  // the object type
  private Schema.SObjectType sObjType { get; set; }
  // the level of verbose mode
  private VerboseLevel verboseMode { get; set; }
  // true if the "Process is invalid and will terminate" error message has been displayed
  private Boolean willValidateFieldDefinitionsMessageIsDisplayed { get; set; }

  /* CLASSES */

  /**
   * @description A definition cluster <cluster> ::= <parameter>(<argument[,...n]>)
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
   * @description A template for a valid cluster
   *   Cluster Types are defined in static method setDefinitionTypes
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
   * @description A field definition, <definition> ::= <command> <script>, <script> ::= <cluster>[,...n]
   */
  public class Definition {
    String fieldName { get; set; } // the user-defined field name
    public String fieldApiName { get; set; }
    public String definitionString { get; set; } // the user-defined field definition
    String command { get; set; } // the definition command
    String script { get; set; } // the definition script
    Boolean isSystemDeclared { get; set; } // false: declared by user, true: declared by Forceea
    Boolean isValid { get; set; } // the definition is valid
    Boolean isValidated { get; set; } // the definition has been validated
    Boolean hasValidFieldDataType { get; set; } // the definition field data type is valid
    Boolean hasRestrictedPicklistValues { get; set; } // the definition restricts the created picklist values to existing values
    DefinitionType type { get; set; } // the type of the definition
    List<Cluster> clusters = new List<Cluster>(); // the list of clusters of the definition

    private Definition(String fieldName, String fieldApiName, Boolean isSystemDeclared, String definitionString) {
      this.fieldName = fieldName;
      this.fieldApiName = fieldApiName;
      this.definitionString = definitionString;
      this.command = '';
      this.script = '';
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
   * @description A template for a valid definition
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
   * @description An error message
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
  public class Field {
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
    public List<Schema.sObjectType> parents = new List<Schema.sObjectType>();
    private List<Schema.PicklistEntry> picklistValues = new List<Schema.PicklistEntry>();
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
    // get Forceea settings
    List<ForceeaSetting__mdt> forceeaSettings = [
      SELECT DeveloperName, RecordsToCreate__c, RecordsToDisplay__c,
        MaxErrorRecordsToDisplay__c, ShowDebugLog__c, UserMessage__c
      FROM ForceeaSetting__mdt
    ];

    // get the Default settings
    ForceeaSetting__mdt defaultSettings = new ForceeaSetting__mdt();
    for (ForceeaSetting__mdt item : forceeaSettings) {
      if (item.DeveloperName.toLowerCase() == 'default') {
        defaultSettings = item;
        break;
      }
    }

    // set settings

    FObject.globalVerboseMode = VERBOSE_MODE;
    FObject.processIsValid = true;

    if (defaultSettings == new ForceeaSetting__mdt()) { // there is no Default settings record
      FObject.processIsValid = false;

      FObject.recordsToCreate = 201;
      FObject.recordsToDisplay = 20;
      FObject.maxErrorRecordsToDisplay = 20;
      FObject.showDebugLog = true;
      FObject.userMessage = '';
      FObject.forceeaStaticDebug(WARN, 'FORCEEA Found no Default settings');
    } else {
      FObject.recordsToCreate = defaultSettings.RecordsToCreate__c.intValue();
      FObject.recordsToDisplay = defaultSettings.RecordsToDisplay__c.intValue();
      FObject.maxErrorRecordsToDisplay = defaultSettings.MaxErrorRecordsToDisplay__c.intValue();
      FObject.showDebugLog = defaultSettings.ShowDebugLog__c;
      FObject.userMessage = defaultSettings.UserMessage__c;
    }

    // declare definition types
    setDefinitionTypes();

    // query for all active RecordType records
    String soql = 'SELECT Id, Name, DeveloperName, sObjectType FROM RecordType WHERE IsActive = true';

    // get record types
    try {
      FObject.recordTypesQueryResults = Database.query(soql);
    } catch (QueryException ex) {
      FObject.forceeaStaticDebug(ERROR, FAILURE_SYMBOL + ' ► Error in registering record types: ' + ex.getMessage());
    }

    // declare properties
    FObject.language = 'English';
    FObject.locality = 'United States';
    FObject.exceptionErrorMessageIsDisplayed = false;

    // get the API names of all Salesforce objects
    for (Schema.SObjectType sot : Schema.getGlobalDescribe().values()) {
      FObject.sObjectApiNames.add(sot.getDescribe().getName());
    }

    // set the PRNG seed
    FObject.seed = Datetime.now().getTime();

    FObject.forceeaStaticDebug(INFO, '==== v' + VERSION + ' =====', true);
    if (String.isNotBlank(FObject.userMessage)) {
      FObject.forceeaStaticDebug(INFO, FObject.userMessage, true);
    }
  }

  // instance initialization
  {
    // reset timer
    this.milestoneStartTime = Limits.getCpuTime();
  }

  /* CONSTRUCTORS */

  public FObject(String objectName) {
    this(objectName, 0);
  }

  public FObject(String objectName, Integer records) {
    FObject.processIsValid = true;
    FObject.isAsync = false;

    String thisObjectName = objectName.trim();
    String userObjectName = thisObjectName;
    String objectApiName = FObject.getObjectApiName(thisObjectName);

    if (String.isBlank(objectApiName)) { // object name is invalid
      FObject.processIsValid = false;
      addError(userObjectName, 'Invalid object [' + userObjectName + ']');
      if (processMustTerminate()) {
        return;
      }
    }

    this.objectApiName = objectApiName; // set the object API name
    this.objectName = thisObjectName.toLowerCase();

    // check the number of records
    if (records < 0) {
      addError(objectApiName, 'Invalid number of records for object [' + objectApiName + ']');
      if (processMustTerminate()) {
        return;
      }
    } else if (records == 0) { // get the default records
      this.records = FObject.recordsToCreate;
    } else {
      this.records = records;
    }

    this.definitionsAreValidated = false;
    this.mustCreateNewRecords = true;
    this.setRequiredFields = true;
    this.excludeInactiveLookupRecords = true;
    this.foundRequiredFields = false;
    this.willValidateFieldDefinitionsMessageIsDisplayed = false;
    this.recordNumber = 1;

    FObject.forceeaStaticDebug(INFO, '=== Object [' + this.objectApiName + '] ===', true);

    // get object type
    this.sObjType = Schema.getGlobalDescribe().get(this.objectApiName);
    String sObjTypeString = String.valueOf(this.sObjType);

    // get record types
    for (RecordType rt : FObject.recordTypesQueryResults) { // for each record type entry
      if (sObjTypeString == rt.SObjectType) { // if object type matches
        this.recordTypesMap.put(rt.DeveloperName.toLowerCase(), rt.Id); // add record type to map
      }
    }

    if (!FObject.globalObjectFieldsMap.containsKey(this.objectApiName.toLowerCase())) { // if object is not defined
      FObject.setObject(this.objectApiName); // store object's field details to global fields map
    }
    this.objectFieldsMap = FObject.globalObjectFieldsMap.get(this.objectApiName.toLowerCase()); // get stored fields details
  }

  /* METHODS */

  /**
   * @description Adds an error message to Errors list and posts message to Debug Log
   * @param text The error reference (e.g. the field or parameter which created the error)
   * @param errorMessage The error message.
   * @return None.
   */
  protected void addError(String errorId, String errorMessage) {
    this.errors.add(new Error(errorId, errorMessage));
    FObject.processIsValid = false;
    System.debug(LoggingLevel.ERROR, 'FORCEEA ' + FAILURE_SYMBOL + ' ' + errorMessage);
  }

  /**
   * @description Adds field values to Field Values Matrix.
   * @param fieldName The API name of the field.
   * @param fieldValues The list of field values.
   * @return None.
   */
  protected void addToFieldValuesMatrix(String fieldApiName, List<String> fieldValues) {
    Integer counter1 = 0;

    for (String field : this.fields) { // for each defined field
      if (field == fieldApiName) { // when field API name matches
        // for each value in field's value list
        for (Integer counter2 = 0; counter2 < this.records; counter2++) {
          // append new value to existing value
          this.fieldValuesMatrix[counter1][counter2] += fieldValues[counter2];
        }
        break; // exit loop
      }
      counter1++;
    }
  }

  /**
   * @description Checks that a cluster type exists in a definition.
   * @param clusterType The cluster type.
   * @param definition The field definition.
   * @return Returns a boolean value.
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
   * @return Returns a boolean value.
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
   * @return Returns a list of string values.
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
   * @return Returns a set of string values.
   */
  private static Set<String> convertSetToLowercase(Set<String> setToConvert) {
    Set<String> results = new Set<String>();

    for (String value : setToConvert) {
      results.add(value.toLowerCase());
    }

    return results;
  }

  /**
  * @description Creates object records using the field definitions.
  * @return None.
  */
  protected virtual void createNewRecords() {
    if (processMustTerminate() || !this.mustCreateNewRecords) {
      return;
    }

    // clear the list of previously created records
    this.createdRecords.clear();
    this.namesMap.clear(); // TODO must clear?
    this.addressesMap.clear(); // TODO must clear?

    // check if must create the definitions of required fields
    setDefinitionOfRequiredFields();

    // validate user-defined and system-defined definitions
    validateDefinitions();
    if (processMustTerminate()) {
      return;
    }

    resetMilestoneTimer('Validated definitions');

    // populate the Field Values Matrix
    initializeFieldValuesMatrix();

    forceeaDebug(DEBUG, 'Creating records for object [' + this.objectApiName + ']');

    Integer numberOfFieldsWithData = 0;

    for (String field : this.fields) { // for each field
      for (Definition def : this.definitions) { // for each definition
        if (field != def.fieldApiName) {
          continue; // go to next defintion if this defintion is not assigned to this field
        }

        List<String> fieldValues = createFieldValues(def); // get field values from definition
        if (processMustTerminate()) {
          return;
        }

        if (!fieldValues.isEmpty()) { // if field values are populated
          // add the field values to FVM
          addToFieldValuesMatrix(def.fieldApiName, fieldValues);
          forceeaDebug(DEBUG, SUCCESS_SYMBOL + ' Created data for field [' + def.fieldApiName +
            '] with definition [' + def.definitionString + ']');
          numberOfFieldsWithData++;
        } else { // do not add field values to FVM
          forceeaDebug(WARN, 'Did not create data for field [' + def.fieldApiName +
            '] with definition [' + def.definitionString + ']');
        }
      }
    }

    if (numberOfFieldsWithData > 0) { // display data if there are created fields
      displayCreatedRecords();
    }

    // create records
    for (Integer counter = 0; counter < this.records; counter++) {
      this.createdRecords.add(getRecord(counter)); // add created object to output list
      if (!FObject.processIsValid) {
        break;
      }
    }

    if (processMustTerminate()) {
      return;
    }

    // add the created records to the list of records for insertion
    this.recordsToInsert.addAll(this.createdRecords);
    // must not create new records
    this.mustCreateNewRecords = false;
    // set record number
    if (!this.createdRecords.isEmpty()) {
      this.recordNumber = this.recordNumber + this.records;
    }

    resetMilestoneTimer('Created ' + this.createdRecords.size() + ' records');
  }

  /**
   * @description Creates records using the declared field definitions.
   * @param None.
   * @return None.
   */
  public void createRecords() {
    this.mustCreateNewRecords = true;
    createNewRecords();
  }

  /**
   * @description Creates records starting with the record with a specific ID.
   * @param recordNumber The number of the next record to be created.
   * @return None.
   */
  public virtual void createRecords(Integer recordNumber) {
    this.mustCreateNewRecords = true;

    if (recordNumber <= 0) {
      addError(this.objectApiName, 'Invalid record number in method createRecords');
      if (processMustTerminate()) {
        return;
      }
    } else {
      this.recordNumber = recordNumber;
    }
    createNewRecords();
  }

  /**
   * @description Validates a field definition.
   * @param definition The field definition.
   * @return Returns a boolean value.
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
      // check if the field data type is valid
      if (!definitionIsValidForFieldDataType(definition)) { // has invalid field data type
        definition.hasValidFieldDataType = false;
        errorMessage = 'Invalid definition [' + definition.definitionString + '] ' +
          'for the data type of field [' + fieldApiName + ']';
        addError(fieldApiName, errorMessage);
        definition.isValid = false;
        result = false;
      } else { // has valid field data type
        // check if field allows multiple definitions
        Field thisField = this.objectFieldsMap.get(fieldApiName.toLowerCase());
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
   * @return Returns a boolean value.
   */
  private Boolean definitionIsValidForFieldDataType(Definition definition) {
    Boolean result = false;

    // get the field type
    Schema.DisplayType fieldType = this.objectFieldsMap.get(definition.fieldApiName.toLowerCase()).dataType;
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
      if (typeId == DefinitionTypeId.RANDOM_PICKLIST ||
        typeId == DefinitionTypeId.RANDOM_PICKLIST_EXCEPT ||
        typeId == DefinitionTypeId.RANDOM_LOOKUP ||
        typeId == DefinitionTypeId.RANDOM_LOOKUP_WHERE ||
        typeId == DefinitionTypeId.STATIC_LOOKUP) {
        result = false;
      }
    } else if (fieldType == Schema.DisplayType.Date && (
      typeId == DefinitionTypeId.STATIC_DATE ||
        typeId == DefinitionTypeId.RANDOM_LIST_DATE ||
        typeId == DefinitionTypeId.RANDOM_DATE ||
        typeId == DefinitionTypeId.SERIAL_DATE ||
        typeId == DefinitionTypeId.COPY_LOOKUP ||
        typeId == DefinitionTypeId.COPY_FIELD)) {
      result = true;
    } else if (fieldType == Schema.DisplayType.Integer && (
      typeId == DefinitionTypeId.STATIC_INTEGER ||
        typeId == DefinitionTypeId.RANDOM_LIST_INTEGER ||
        typeId == DefinitionTypeId.RANDOM_LIST_DECIMAL ||
        typeId == DefinitionTypeId.RANDOM_NUMBER ||
        typeId == DefinitionTypeId.SERIAL_NUMBER ||
        typeId == DefinitionTypeId.COPY_LOOKUP ||
        typeId == DefinitionTypeId.COPY_FIELD)) {
      result = true;
    } else if ((
      fieldType == Schema.DisplayType.Percent ||
        fieldType == Schema.DisplayType.Currency ||
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
      if (typeId == DefinitionTypeId.RANDOM_LOOKUP ||
        typeId == DefinitionTypeId.RANDOM_LOOKUP_WHERE ||
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
      typeId == DefinitionTypeId.STATIC_LOOKUP ||
        typeId == DefinitionTypeId.RANDOM_LOOKUP ||
        typeId == DefinitionTypeId.RANDOM_LOOKUP_WHERE ||
        typeId == DefinitionTypeId.COPY_LOOKUP ||
        typeId == DefinitionTypeId.COPY_FIELD)) {
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
      if (typeId == DefinitionTypeId.STATIC_LOOKUP ||
        typeId == DefinitionTypeId.RANDOM_LOOKUP ||
        typeId == DefinitionTypeId.RANDOM_LOOKUP_WHERE) {
        result = false;
      }
    } else if (fieldType == Schema.DisplayType.Base64) {
      result = true;
      if (typeId == DefinitionTypeId.RANDOM_PICKLIST ||
        typeId == DefinitionTypeId.RANDOM_PICKLIST_EXCEPT ||
        typeId == DefinitionTypeId.RANDOM_LOOKUP ||
        typeId == DefinitionTypeId.RANDOM_LOOKUP_WHERE ||
        typeId == DefinitionTypeId.STATIC_LOOKUP) {
        result = false;
      }
    } else if (fieldType == Schema.DisplayType.Time && (
      typeId == DefinitionTypeId.STATIC_TIME ||
        typeId == DefinitionTypeId.RANDOM_LIST_TIME ||
        typeId == DefinitionTypeId.COPY_LOOKUP ||
        typeId == DefinitionTypeId.COPY_FIELD)) {
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
   * @return Returns a boolean value.
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
   * @param None.
   * @return None.
   */
  public void deleteAllDefinitions() {
    forceeaDebug(INFO, 'Deleting the definitions of all fields');

    this.definitions.clear();
    this.fields.clear();

    this.willValidateFieldDefinitionsMessageIsDisplayed = true;
  }

  /**
   * @description Deletes all definitions of a field.
   * @param fieldName The user-defined name of the field.
   * @return None.
   */
  public void deleteFieldDefinitions(String fieldName) {
    // fix field name
    String thisFieldName = fieldName.trim();

    // get the field API name
    String fieldApiName = getFieldApiName(thisFieldName);

    if (String.isBlank(fieldApiName)) { // field is invalid
      addError(this.objectApiName, 'Invalid field [' + thisFieldName + '] in method deleteFieldDefinitions');
    }

    if (processMustTerminate()) {
      return;
    }

    forceeaDebug(INFO, 'Deleting the definitions of field [' + fieldApiName + ']');
    Integer index = 0;
    List<Integer> indexesToRemove = new List<Integer>();

    for (Definition def : this.definitions) { // for each definition
      if (def.fieldApiName == fieldApiName) { // if field is found
        indexesToRemove.add(index); // store the index of this field
      }
      index++;
    }
    for (Integer count = indexesToRemove.size() - 1; count >= 0; count--) {
      this.definitions.remove(indexesToRemove.get(count)); // remove definition
    }

    // de-activate field
    Integer counter = 0;
    for (String field : this.fields) {
      if (field == fieldApiName) {
        this.fields[counter] = '.' + field;
        break;
      }
      counter++;
    }
  }

  /**
   * @description Deletes records of the object, using specific criteria (WHERE clause).
   * @param whereClause The WHERE clause of the SOQL query (e.g. MyField__c > 10).
   * @return Returns a list of Database.DeleteResult objects.
   */
  public List<Database.DeleteResult> deleteRecords(String whereClause) {
    List<Database.DeleteResult> results = new List<Database.DeleteResult>();
    List<SObject> recordsToDelete = new List<SObject>();
    Set<Id> deletedRecordIdsSet = new Set<Id>();
    Integer numDeletedRecords = 0;

    if (processMustTerminate()) {
      return results;
    }

    forceeaDebug(INFO, 'Deleting records for object [' + this.objectApiName + ']');

    // set SOQL query
    String soql = 'SELECT Id FROM ' + this.objectApiName;
    if (String.isBlank(whereClause)) {
      soql += ' LIMIT 10000';
    } else {
      soql += ' WHERE ' + whereClause + ' LIMIT 10000';
    }

    try {
      recordsToDelete = Database.query(soql);
    } catch (QueryException ex) {
      addError(this.objectApiName, 'Found errors selecting records of object [' +
        this.objectApiName + ']: ' + ex.getMessage());
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
        if (this.errors.size() <= FObject.maxErrorRecordsToDisplay) {
          for (Database.Error err : dr.getErrors()) {
            addError(this.objectApiName, 'Found errors deleting record #' + recordsCounter + ': ' +
              err.getMessage() + '. Fields that affected this error: ' + err.getFields());
          }
        }
      }
    }

    // display messages
    if (numDeletedRecords == recordsToDelete.size()) {
      forceeaDebug(INFO, 'Successfully deleted ' + recordsToDelete.size() +
        ' [' + this.objectApiName + '] records');
    } else { // there are errors
      addError(this.objectApiName, 'Found ' + errorsCounter +
        ' errors deleting records for object [' + this.objectApiName + ']');
    }

    // remove deleted records from global records map
    for (String mapKey : FObject.globalInsertedRecordsMap.keySet()) { // for each inserted record
      // get the object API name
      String objectName = '';
      if (mapKey.contains('.')) { // this is a group
        objectName = mapKey.substringBefore('.');
      } else { // is not a group
        objectName = mapKey;
      }

      if (objectName == this.objectApiName.toLowerCase()) { // the key belongs to this object
        Map<Id, sObject> insertedRecordsMap = new Map<Id, sObject>
          (FObject.globalInsertedRecordsMap.get(mapKey));
        for (Id deletedRecordId : deletedRecordIdsSet) { // for each deleted record ID
          insertedRecordsMap.remove(deletedRecordId); // remove the record from the inserted records map
        }
        // update the inserted records map
        FObject.globalInsertedRecordsMap.put(mapKey, insertedRecordsMap.values());
      }
    } // end: for mapKey

    return results;
  }

  /**
   * @description Dispays the Field Value Matrix (FVM) values.
   * @param None.
   * @return None.
   */
  protected void displayCreatedRecords() {
    forceeaDebug(DEBUG, 'Displaying the created records for object [' + this.objectApiName + ']');
    Integer counter1 = 0;
    Integer numOfRecords = 0;
    String str = '';

    // limit the displayed records
    if (this.records <= FObject.recordsToDisplay) {
      numOfRecords = this.records;
    } else {
      numOfRecords = FObject.recordsToDisplay;
    }

    for (String field : this.fields) { // for each field
      // add dividers between records
      str = '';
      for (Integer counter2 = 0; counter2 < numOfRecords; counter2++) {
        str += this.fieldValuesMatrix[counter1][counter2] + ', ';
      }
      counter1++;
      forceeaDebug(DEBUG, 'Records for field [' + field + ']: ' + str.removeEnd(', '));
    }
  }

  /**
   * @description Determines is the field has multiple definitions.
   * @param fieldName The API name of the field.
   * @return Returns a boolean value.
   */
  private Boolean fieldHasMultipleDefinitions(String fieldApiName) {
    Boolean result = false;
    Integer counter = 0;
    fieldApiName = fieldApiName.toLowerCase();

    for (Definition definition : this.definitions) {
      if (definition.fieldApiName.toLowerCase() == fieldApiName) {
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
   * @return None.
   */
  protected void forceeaDebug(String errorLevel, String message) {
    if (!FObject.showDebugLog) {
      return;
    }

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
   * @return None.
   */
  private static void forceeaStaticDebug(String errorLevel, String message) {
    if (!FObject.showDebugLog) {
      return;
    }

    FObject.postDebug(errorLevel, message, FObject.globalVerboseMode);
  }

  private static void forceeaStaticDebug(String errorLevel, String message, Boolean alwaysDisplay) {
    if (!FObject.showDebugLog) {
      return;
    }

    if (alwaysDisplay) {
      FObject.postDebug(errorLevel, message, VerboseLevel.VERBOSE_INFO);
    } else {
      FObject.postDebug(errorLevel, message, FObject.globalVerboseMode);
    }
  }

  /**
   * @description Returns a map of all definitions of every field.
   * @param None.
   * @return Returns a map of key:string, value:List of string values.
   */
  public Map<String, List<String>> getAllDefinitions() {
    Map<String, List<String>> valuesMap = new Map<String, List<String>>();

    validateDefinitions();

    for (Definition def : this.definitions) { // for each definition
      String field = def.fieldApiName; // get the field name
      if (valuesMap.containsKey(field)) { // field is already in the result map
        valuesMap.get(field).add(def.definitionString);
      } else { // field is not in the Map
        valuesMap.put(field, new List<String>{
          def.definitionString
        });
      }
    }

    return valuesMap;
  }

  /**
   * @description Returns the first argument of a cluster.
   * @param parameter The parameter of the cluster.
   * @param clusters The list of definition clusters.
   * @return Returns a string value.
   */
  private String getClusterArgument(String parameter, List<Cluster> clusters) {
    String result = '';
    String par = parameter.toLowerCase();

    for (Cluster cluster : clusters) {
      if (par == cluster.parameter) { // parameter is found
        result = cluster.arguments[0].removeStart('"').removeEnd('"');
        break;
      }
    }

    return result;
  }

  /**
   * @description Returns the arguments of a cluster.
   * @param parameter The parameter of the cluster.
   * @param clusters The list of definition clusters.
   * @return Returns a list of string values.
   */
  private List<String> getClusterArguments(String parameter, List<Cluster> clusters) {
    List<String> results = new List<String>();
    String par = parameter.toLowerCase();

    for (Cluster cluster : clusters) {
      if (par == cluster.parameter) { // parameter is found
        for (String arg : cluster.arguments) {
          results.add(arg.removeStart('"').removeEnd('"'));
        }
        break;
      }
    }

    return results;
  }

  /**
   * @description Copies the values of another lookup object's field.
   * @param definition The definition of the field.
   * @param fieldName The API name of the field.
   * @param fromObjectFieldName The lookup objet and the lookup field API names
   *   seperated with a dot, e.g. Account.Rating
   * @return Returns a list of string values.
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

    // check if the lookup object is valid
    String lookupObjectName = fromObjectFieldName.trim().substringBefore('.');
    String lookupObjectApiName = FObject.getObjectApiName(lookupObjectName);
    if (String.isBlank(lookupObjectApiName)) { // object is invalid
      addError(definition.fieldApiName, 'Invalid lookup object [' + lookupObjectName + '] in definition [' +
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
      ' WHERE Id IN :lookupIdsSet LIMIT 10000';

    Map<Id, SObject> lookupRecordsMap; // the lookup object's records map
    try { //query the database and populate the lookup records map
      lookupRecordsMap = new Map<Id, SObject>(Database.query(soqlQuery));
    } catch (QueryException ex) {
      addError(fieldApiName, 'Found errors selecting records from the lookup object [' + lookupObjectApiName +
        '] for object [' + this.objectApiName + ']: ' + ex.getMessage());
    } finally {
      if (lookupRecordsMap.isEmpty() || processMustTerminate()) {
        return values;
      }
    }

    // get the field data type
    Schema.DisplayType valueType = this.objectFieldsMap.get(definition.fieldApiName.toLowerCase()).dataType;

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
   * @return Returns a list of string values.
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

    if (fieldPosition == -1) { // field is not found
      forceeaDebug(WARN, 'Did not copy data from field [' + fieldApiName + '] to field ['
        + definition.fieldApiName + ']');
      return values;
    }
    values = this.fieldValuesMatrix.get(fieldPosition);

    return values;
  }

  /**
   * @description Retrieves the default number of records of a new lookup FObject.
   * @param records The records of the current FObject.
   * @return Returns an integer value.
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
   * @description Retrieves the field details.
   * @param sObjectField The sObject field.
   * @return Returns a Field object.
   */
  private static Field getDetailsFromSObjectField(Schema.sObjectField sObjectField) {
    Schema.DescribeFieldResult dfr = sObjectField.getDescribe();

    Field objectField = new Field();
    objectField.fieldName = dfr.getName().toLowerCase();
    objectField.fieldApiName = dfr.getName();
    objectField.label = dfr.getLabel();
    objectField.dataType = dfr.getType();
    objectField.isRestrictedPicklist = dfr.isRestrictedPicklist();
    objectField.canHaveMultipleTypesAsParents = dfr.isNamePointing();
    objectField.length = dfr.getLength();
    objectField.parents = dfr.getReferenceTo();
    objectField.isAccessible = dfr.isAccessible();
    objectField.isCreateable = dfr.isCreateable();

    // check if field is required
    if (dfr.isCreateable() && !dfr.isNillable() && !dfr.isDefaultedOnCreate()) {
      objectField.isRequired = true;
    } else {
      objectField.isRequired = false;
    }

    Schema.DisplayType dt = objectField.dataType;

    // check if field allows multiple definitions
    if (dt == Schema.DisplayType.String ||
      dt == Schema.DisplayType.Email ||
      dt == Schema.DisplayType.Url ||
      dt == Schema.DisplayType.Base64 ||
      dt == Schema.DisplayType.Phone ||
      dt == Schema.DisplayType.TextArea ||
      dt == Schema.DisplayType.Combobox) {
      objectField.allowsMultipleDefinitions = true;
    } else {
      objectField.allowsMultipleDefinitions = false;
    }

    if (dt == Schema.DisplayType.Picklist ||
      dt == Schema.DisplayType.MultiPicklist ||
      dt == Schema.DisplayType.Combobox) {
      if (dfr.getController() != null) {
        objectField.controllingFieldApiName = dfr.getController().getDescribe().getName(); // get controlling field
      }
      objectField.picklistValues = dfr.getPicklistValues();
    }

    return objectField;
  }

  /**
   * @description Returns a list of the errors found during the process
   *   of creating the records of an FObject.
   * @param None.
   * @return Returns a map of key:String, value:List<String> values.
   */
  public Map<String, List<String>> getErrors() {
    Map<String, List<String>> results = new Map<String, List<String>>();

    for (Error err : this.errors) {
      if (results.containsKey(err.id)) { // the key exists
        // add a new element in the list
        results.get(err.id).add(err.errorMessage);
      } else {
        // add a new element in the map
        results.put(err.id, new List<String>{
          err.errorMessage
        });
      }
    }

    return results;
  }

  /**
   * @description Retrieves the API name of a specific object's field
   *   or a blank string i the field name is invalid.
   * @param fieldName The field name.
   * @return Returns a string value.
   */
  private String getFieldApiName(String fieldName) {
    String result = '';
    if (String.isBlank(fieldName)) {
      return result;
    }

    String thisFieldName = fieldName.trim().toLowerCase();

    if (this.objectFieldsMap.containsKey(thisFieldName)) {
      Field field = this.objectFieldsMap.get(thisFieldName);
      result = field.fieldApiName;
    }
    return result;
  }

  /**
   * @description Retrieves the API name of a specific object's field
   *   or a blank string i the field name is invalid.
   * @param objectName The object name.
   * @param fieldName The field name.
   * @return Returns a string value.
   */
  public static String getFieldApiName(String objectName, String fieldName) {
    String result = '';

    if (String.isBlank(objectName) || String.isBlank(fieldName)) {
      return result;
    }
    objectName = objectName.trim().toLowerCase();
    fieldName = fieldName.trim().toLowerCase();

    if (String.isNotBlank(FObject.getObjectApiName(objectName))) { // the object name is valid
      if (!FObject.globalObjectFieldsMap.containsKey(objectName)) { // the object's field details don't exist
        FObject.setObject(objectName);
      }
      Map<String, Field> fieldsMap = FObject.globalObjectFieldsMap.get(objectName);
      if (fieldsMap.containsKey(fieldName)) {
        result = fieldsMap.get(fieldName).fieldApiName;
      }
    }

    return result;
  }

  /**
   * @description Returns a list of all definitions of a field.
   * @param fieldName The API name of the field.
   * @return Returns a list of string values.
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
   * @param objectName The API name of the object.
   * @param controllingField The API name of the controlling field.
   * @param dependentField The API name of the dependent field.
   * @author Suriya Soundrapandian.
   * @return A map of the controlling field value and the dependent field values.
   */
  private Map<String, Set<String>> getFieldDependenciesMap(
    String objectName, String controllingField, String dependentField) {
    Map<String, Set<String>> results = new Map<String, Set<String>>();
    Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);
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
   * @description Creates values based on a field definition.
   * @param definition A field definition.
   * @return Returns a list of string values.
   */
  protected List<String> createFieldValues(Definition definition) {
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
          Date.valueOf(getClusterArgument('from', clusters)), Time.newInstance(0, 0, 0, 0));
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
        lookupObject, lookupField, lookupValues, lookupExceptValues, groupName, null);
    } else if (defId == DefinitionTypeId.RANDOM_LOOKUP_WHERE) {
      String source = getClusterArgument('source', clusters);
      String lookupObject = getClusterArgument('lookup', clusters);
      String whereClause = getClusterArgument('where', clusters);
      results = getLookupValues(definition, 'random', source, lookupObject, null, null, null, null, whereClause);
    } else if (defId == DefinitionTypeId.STATIC_LOOKUP) {
      String source = getClusterArgument('source', clusters);
      String lookupObject = getClusterArgument('lookup', clusters);
      String lookupField = getClusterArgument('field', clusters);
      List<String> lookupValues = getClusterArguments('value', clusters);
      results = getLookupValues(definition, 'static', source, lookupObject, lookupField, lookupValues, null, null, null);
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
    }

    return results;
  }

  /**
   * @description Retrieves the position of a field.
   * @param fieldApiName The API name of the field.
   * @return Returns an integer.
   */
  private Integer getFieldPosition(String fieldApiName) {
    Integer result = 0;
    Integer counter = 0;
    Boolean isFound = false;

    for (String field : this.fields) {
      if (field == fieldApiName) {
        result = counter;
        isFound = true;
        break;
      }
      counter++;
    }

    if (!isFound) {
      return -1;
    } else {
      return result;
    }
  }

  /**
   * @description Retrieves all inserted records of an object.
   * @param None.
   * @return Returns a list of sObject records.
   */
  public List<SObject> getInsertedRecords() {
    List<SObject> results = new List<SObject>();
    String mapKey = this.objectApiName.toLowerCase();
    if (FObject.globalInsertedRecordsMap.containsKey(mapKey)) {
      results = FObject.globalInsertedRecordsMap.get(mapKey);
    }

    return results;
  }

  /**
   * @description Retrieves all inserted records of an object.
   * @param objectApiName The object API name.
   * @return Returns a list of sObject records.
   */
  public static List<SObject> getInsertedRecords(String objectApiName) {
    List<SObject> results = new List<SObject>();
    Set<String> objectApiNamesSet = new Set<String>(FObject.sObjectApiNames);
    objectApiNamesSet = convertSetToLowercase(objectApiNamesSet);
    String thisObjectApiName = objectApiName.trim().toLowerCase();

    if (!objectApiNamesSet.contains(thisObjectApiName)) { // object name is invalid
      FObject.processIsValid = false;
      System.debug(LoggingLevel.ERROR, 'FORCEEA ' + FAILURE_SYMBOL + ' ' + 'Invalid object [' + objectApiName + ']' +
        'in static method getInsertedRecords');
    }

    String mapKey = objectApiName.trim().toLowerCase();
    if (FObject.globalInsertedRecordsMap.containsKey(mapKey)) {
      results = FObject.globalInsertedRecordsMap.get(mapKey);
    }

    return results;
  }

  /**
   * @description Retrieves all inserted records of an object.
   * @param groupName The group name of the inserted records.
   * @return Returns a list of sObject records.
   */
  public List<SObject> getInsertedGroupRecords(String groupName) {
    List<SObject> results = new List<SObject>();

    String mapKey = this.objectApiName.toLowerCase() + '.' + groupName.trim().toLowerCase();
    if (FObject.globalInsertedRecordsMap.containsKey(mapKey)) {
      results = FObject.globalInsertedRecordsMap.get(mapKey);
    }

    return results;
  }

  /**
   * @description Retrieves all inserted records of an object.
   * @param objectApiName The object API name.
   * @param groupName The group name of the inserted records.
   * @return Returns a list of sObject records.
   */
  public static List<SObject> getInsertedGroupRecords(String objectApiName, String groupName) {
    List<SObject> results = new List<SObject>();
    Set<String> objectApiNamesSet = new Set<String>(FObject.sObjectApiNames);
    objectApiNamesSet = convertSetToLowercase(objectApiNamesSet);
    String thisObjectApiName = objectApiName.trim().toLowerCase();

    if (!objectApiNamesSet.contains(thisObjectApiName)) { // object name is invalid
      FObject.processIsValid = false;
      System.debug(LoggingLevel.ERROR, 'FORCEEA ' + FAILURE_SYMBOL + ' ' + 'Invalid object [' + objectApiName + ']' +
        'in static method getInsertedGroupRecords');
    }

    String mapKey = thisObjectApiName + '.' + groupName.trim().toLowerCase();
    if (FObject.globalInsertedRecordsMap.containsKey(mapKey)) {
      results = FObject.globalInsertedRecordsMap.get(mapKey);
    }

    return results;
  }

  /**
   * @description Creates and inserts records for the lookup object.
   * @param lookupObjectApiName The API name of the lookup object.
   * @param lookupFieldApiName The API name of the lookup field.
   * @param groupName The group name for the inserted records.
   * @return Returns a list of sObject records.
   */
  private List<SObject> getLookupRecords(String lookupObjectApiName, String lookupFieldApiName, String groupName) {
    List<SObject> results = new List<SObject>();
    FObject obj = new FObject(lookupObjectApiName, getDefaultRecords(this.records));

    // set lookup field's definition
    if (String.isNotBlank(lookupFieldApiName)) { // if there is a lookup field
      Field field = obj.objectFieldsMap.get(lookupFieldApiName.toLowerCase());
      obj.setDefinitionFromField(field); // set lookup field's definition
    }

    // set IsActive standard field
    if (this.excludeInactiveLookupRecords && obj.objectFieldsMap.containsKey('isactive')) {
      obj.setDefinition('IsActive', true, 'static value(true)'); // set the definition of IsActive field
    }

    obj.insertRecords(true, groupName); // insert records
    results = obj.getRecords();

    return results;
  }

  /**
   * @description Creates random IDs from a lookup object's records.
   * @param definition The definition string of the field.
   * @param type The lookup type (random or static).
   * @param source The source (forceea or salesforce) of the lookup object.
   * @param lookupObjectName The API name of the lookup object.
   * @param lookupFieldName The API name of the lookup field.
   * @param lookupValues The list of lookup values.
   * @param lookupExceptions The list of exception lookup values.
   * @param whereClause The where clause of the selection SOQL query.
   * @return Returns a list of ID values.
   */
  private List<Id> getLookupValues(Definition definition, String type, String source,
    String lookupObjectName, String lookupFieldName,
    List<String> lookupValues, List<String> lookupExceptions, String groupName, String whereClause) {

    List<Id> values = new List<Id>();
    List<SObject> lookupRecords = new List<SObject>(); // the lookup object's records
    String fieldApiName = definition.fieldApiName;
    source = source.toLowerCase();

    // check if the object name is valid
    String lookupObjectApiName = FObject.getObjectApiName(lookupObjectName);
    if (String.isBlank(lookupObjectApiName)) {
      addError(fieldApiName, 'Invalid lookup object [' + lookupObjectName + '] in definition [' +
        definition.definitionString + ']');
      if (processMustTerminate()) {
        return values;
      }
    }

    // get the object fields map
    if (!FObject.globalObjectFieldsMap.containsKey(lookupObjectApiName.toLowerCase())) { // object is not defined
      FObject.setObject(lookupObjectApiName); // store to global fields map
    }
    // get stored fields details
    Map<String, Field> fieldsMap = FObject.globalObjectFieldsMap.get(lookupObjectApiName.toLowerCase());

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
          return values;
        }
      }
    }

    // check IsActive standard field
    Boolean isActiveFieldExists = false;
    if (this.excludeInactiveLookupRecords && fieldsMap.containsKey('isactive')) {
      isActiveFieldExists = true;
    }

    if (source == 'forceea') {
      Boolean noInsertedRecords = false;
      if (String.isNotBlank(groupName)) { // there is a group
        String mapKey = lookupObjectApiName.toLowerCase() + '.' + groupName.trim().toLowerCase() ;
        // if records have been inserted by Forceea for this group
        if (FObject.globalInsertedRecordsMap.containsKey(mapKey)) {
          lookupRecords = FObject.globalInsertedRecordsMap.get(mapKey); // get these records
        } else { // no records have been inserted for this group
          noInsertedRecords = true;
        }
      } else { // there is no group
        String mapKey = lookupObjectApiName.toLowerCase();
        if (FObject.globalInsertedRecordsMap.containsKey(mapKey)) { // if records have been inserted by Forceea
          lookupRecords = FObject.globalInsertedRecordsMap.get(mapKey); // get these records
        } else { // no records have been inserted
          noInsertedRecords = true;
        }
      }

      if (noInsertedRecords && !definition.isSystemDeclared) {
        forceeaDebug(WARN, 'The required records of lookup object [' + lookupObjectApiName +
          '] have not been created by Forceea and will be created now');
        // create records for the lookup object
        lookupRecords = getLookupRecords(lookupObjectApiName, lookupFieldApiName, groupName);
      }
    }

    // if there are no inserted records and is a system-declared definition
    // or if the source is salesforce
    if ((lookupRecords.isEmpty() && definition.isSystemDeclared) || source == 'salesforce') {
      String soqlQuery = 'SELECT Id';
      // set soql query if there is a lookup field
      if (String.isNotBlank(lookupFieldName)) {
        soqlQuery += ', ' + lookupFieldApiName;
      }
      soqlQuery += ' FROM ' + lookupObjectApiName;
      if (String.isNotBlank(whereClause)) {
        soqlQuery += ' WHERE ' + whereClause;
      }
      if (this.excludeInactiveLookupRecords && isActiveFieldExists) { // set IsActive field
        if (String.isBlank(whereClause)) {
          soqlQuery += ' WHERE IsActive = true';
        } else {
          soqlQuery += ' AND IsActive = true';
        }
      }
      soqlQuery += ' LIMIT 10000';

      try { //query the database and get the IDs
        lookupRecords = Database.query(soqlQuery);
      } catch (QueryException ex) {
        addError(fieldApiName, 'Found errors selecting records from the lookup object [' + lookupObjectApiName +
          '] for object [' + this.objectApiName + ']: ' + ex.getMessage());
      } finally {
        if (processMustTerminate()) {
          return values;
        }
      }
    }

    // if there are no inserted records and is a system-declared definition
    if (lookupRecords.isEmpty() && definition.isSystemDeclared) {
      lookupRecords = getLookupRecords(lookupObjectApiName, lookupFieldApiName, groupName); // create records for the lookup object
    }

    if (type == 'static') {
      String lookupId = '';
      for (SObject objRecord : lookupRecords) { // for each record
        // if lookup field value is found
        if (lookupValues[0].equalsIgnoreCase((String) objRecord.get(lookupFieldApiName))) {
          lookupId = objRecord.Id; // get record Id
          break;
        }
      }
      for (Integer counter = 0; counter < this.records; counter++) {
        values.add(lookupId);
      }
    } else if (type == 'random') {
      List<Id> lookupIds = new List<Id>();
      if ((lookupValues == null || lookupValues.isEmpty()) &&
        (lookupExceptions == null || lookupExceptions.isEmpty())) {
        for (SObject objRecord : lookupRecords) {
          lookupIds.add(objRecord.Id);
        }
      } else if ((lookupValues != null || !lookupValues.isEmpty()) &&
        (lookupExceptions == null || lookupExceptions.isEmpty())) {
        Set<String> lookupValuesSet = new Set<String>(lookupValues);
        lookupValuesSet = convertSetToLowercase(lookupValuesSet);
        String fieldValue = '';
        for (SObject objRecord : lookupRecords) {
          fieldValue = (String) objRecord.get(lookupFieldApiName);
          if (String.isNotBlank(fieldValue) && lookupValuesSet.contains(fieldValue.toLowerCase())) {
            lookupIds.add(objRecord.Id);
          }
        }

      } else if ((lookupValues == null || lookupValues.isEmpty()) &&
        (lookupExceptions != null || !lookupExceptions.isEmpty())) {
        Set<String> lookupExceptionsSet = new Set<String>(lookupExceptions);
        lookupExceptionsSet = convertSetToLowercase(lookupExceptionsSet);
        String fieldValue = '';
        for (SObject objRecord : lookupRecords) { // for each record
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
        return values;
      } else if (size == 1) {
        for (Integer counter = 0; counter < this.records; counter++) {
          values.add(lookupIds[0]);
        }
      } else if (size > 1) {
        for (Integer counter = 0; counter < this.records; counter++) {
          rnd = (FObject.random * size).intValue();
          values.add(lookupIds[rnd]);
        }
      }
    } // end: if type == 'random'

    return values;
  }

  /**
   * @description Retrieves the API name of an object or an empty string if the name is invalid.
   * @param objectName The user-defined name of an object.
   * @return Returns a string value.
   */
  private static String getObjectApiName(String objectName) {
    String result = '';
    objectName = objectName.trim().toLowerCase();

    for (String objectApiName : FObject.sObjectApiNames) {
      if (objectApiName.toLowerCase() == objectName) { // object is found
        result = objectApiName;
        break;
      }
    }

    return result;
  }

  /**
   * @description Creates random picklist values, respecting the fields dependencies.
   * @param dependentFieldApiName The API name of the dependent field.
   * @param controllingFieldApiName The API name of the controlling field.
   * @param inclusions The picklist values to keep.
   * @param exceptions The picklist values to remove.
   * @return Returns a list of string values.
   */
  private List<String> getPicklistValuesWithRespect(String dependentFieldApiName, String controllingFieldApiName,
    List<String> inclusions, List<String> exceptions) {
    List<String> values = new List<String>();

    // get the position of the controlling field
    Integer ctrlFieldPosition = getFieldPosition(controllingFieldApiName);

    // get the Field Dependencies map (key: controlling field value, value: dependent field values)
    Map<String, Set<String>> fieldDependenciesMap =
      getFieldDependenciesMap(this.objectApiName, controllingFieldApiName, dependentFieldApiName);

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
        values.add(''); // add an empty string to results
      } else { // there at least one value
        // get the dependent field's value list
        depFieldValues = new List<String>(fieldDependenciesSet);
        // get a random value
        rnd = (FObject.random * depFieldValues.size()).intValue();
        values.add(depFieldValues[rnd]);
      }
    }

    return values;
  }

  /**
   * @description Creates random picklist values when there are no fields dependencies.
   * @param picklistValues The piclist values list.
   * @return Returns a list of string values.
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
   * @description Creates random addresses having street (with number), postal code, city, state and country.
   * @param None.
   * @return Returns a list of FAddress objects.
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
   * @param None.
   * @return Returns a list of string values.
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
   * @return Returns a list of string values.
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
   * @return Returns a list of string values.
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
   * @return Returns a list of string values.
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
   * @param fromDate The minimum datetime.
   * @param toDate The maximum datetime.
   * @return Returns a list of string values.
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
   * @return Returns a list of string values.
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
   * @return Returns a list of string values.
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
   * @param None.
   * @return Returns a list of string values.
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
   * @return Returns a list of string values.
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
   * @return Returns a list of string values.
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
   * @return Returns a list of string values.
   */
  private List<String> getRandomListValuesForPicklists(Definition definition) {
    List<String> arguments = getClusterArguments('value', definition.clusters);
    List<String> values = new List<String>();
    String fieldApiName = definition.fieldApiName;

    // get all picklist values
    List<String> picklistValues = new List<String>();
    for (Schema.PicklistEntry picklistEntry : this.objectFieldsMap.get(fieldApiName.toLowerCase()).pickListValues) {
      picklistValues.add(picklistEntry.getValue());
    }

    // get field's data type
    Field depField = this.objectFieldsMap.get(fieldApiName.toLowerCase());

    // convert arguments to lowercase
    arguments = convertListToLowercase(arguments);

    // get controlling field's API name
    String ctrlFieldApiName = depField.controllingFieldApiName;

    if (depField.isRestrictedPicklist) { // if the field is restricted
      arguments = keepValuesInList(arguments, picklistValues); // remove arguments which are not valid picklist values
    }

    if (String.isBlank(ctrlFieldApiName) || // the controlling field is a Checkbox or there is no controlling field
      this.objectFieldsMap.get(ctrlFieldApiName.toLowerCase()).dataType == Schema.DisplayType.Boolean) {
      values = getPicklistValuesWithoutRespect(arguments);
    } else { // there is a controlling field
      values = getPicklistValuesWithRespect(fieldApiName, ctrlFieldApiName, arguments, null);
    }

    return values;
  }

  /**
   * @description Creates random field values from a list.
   * @param definition The field definition.
   * @return Returns a list of string values.
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

    // get field's data type
    Schema.DisplayType fieldDataType = this.objectFieldsMap.get(definition.fieldApiName.toLowerCase()).dataType;

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
   * @description Creates random names.
   * @param None.
   * @return Returns a list of Name objects.
   */
  private List<Name> getRandomNames() {
    List<Name> values = new List<Name>();
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
        values.add(new Name(firstName, lastName, gender));
      }
    }

    // randomize names
    Integer rnd = 0;
    Name temp = new Name();
    Integer size = values.size();
    for (Integer counter = 0; counter < size; counter++) {
      rnd = (FObject.random * size).intValue(); // get a random index
      temp = values[counter] ;
      values[counter] = values[rnd];
      values[rnd] = temp;
    }

    return values;
  }

  /**
   * @description Creates random phone numbers.
   * @param formatString The format string which defines the phone numbers.
   * @return Returns a list of phone numbers.
   */
  private List<String> getRandomPhoneNumbers(String formatString) {
    List<String> values = new List<String>();

    List<String> chars = formatString.split('');
    Integer rnd = 0;

    for (Integer counter1 = 0; counter1 < this.records; counter1++) {
      String val = '';
      for (Integer counter2 = 0; counter2 < chars.size(); counter2++) {
        if (chars[counter2] == 'd') {
          rnd = 1 + (FObject.random * 9).intValue(); // get a random number betwwen 1 and 9
          val += String.valueOf(rnd);
        } else if (chars[counter2] == 'D') {
          rnd = (FObject.random * 10).intValue(); // get a random number betwwen 0 and 9
          val += String.valueOf(rnd);
        } else {
          val += chars[counter2];
        }
      }
      values.add(val);
    }

    return values;
  }

  /**
   * @description Creates random picklist values.
   * @param fieldApiName The API name of a field.
   * @return Returns a list of string values.
   */
  private List<String> getRandomPicklistValues(String fieldApiName) {
    List<String> values = new List<String>();

    if (fieldApiName == 'RecordTypeId') {
      // create a new list with the record type values
      List<Id> recordTypeIds = new List<Id>(this.recordTypesMap.values());

      Integer size = recordTypeIds.size();
      if (size == 1) {
        Id recordTypeId = recordTypeIds[0];
        for (Integer counter = 0; counter < this.records; counter++) {
          values.add(recordTypeId);
        }
      } else {
        Integer rnd = 0;
        for (Integer counter = 0; counter < this.records; counter++) {
          rnd = (FObject.random * size).intValue();
          values.add(recordTypeIds[rnd]);
        }
      }
      return values;
    }

    // get dependent field and controlling field
    Field dependentField = this.objectFieldsMap.get(fieldApiName.toLowerCase());
    String ctrlFieldApiName = dependentField.controllingFieldApiName;

    if (String.isBlank(ctrlFieldApiName) || // the controlling field is a Checkbox or there is no controlling field
      this.objectFieldsMap.get(ctrlFieldApiName.toLowerCase()).dataType == Schema.DisplayType.Boolean) {
      // get all picklist values
      List<String> picklistValues = new List<String>(); // the picklist items
      for (Schema.PicklistEntry picklistEntry : this.objectFieldsMap.get(fieldApiName.toLowerCase()).pickListValues) {
        picklistValues.add(picklistEntry.getValue());
      }
      values = getPicklistValuesWithoutRespect(picklistValues);
    } else { // there is a controlling field
      values = getPicklistValuesWithRespect(fieldApiName, ctrlFieldApiName, null, null);
    }

    return values;
  }

  /**
   * @description Creates random picklist values, excluding specific values.
   * @param fieldName The API name of a field.
   * @param exceptions A list of exceptions from the picklist items.
   * @return Returns a list of string values.
   */
  private List<String> getRandomPicklistValuesExcept(String fieldApiName, List<String> exceptions) {
    List<String> values = new List<String>();

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
        return values;
      } else if (size == 1) {
        for (Integer counter = 0; counter < this.records; counter++) {
          values.add(recordTypeIds[0]);
        }
      } else {
        Integer rnd = 0;
        for (Integer counter = 0; counter < this.records; counter++) {
          rnd = (FObject.random * size).intValue();
          values.add(recordTypeIds[rnd]);
        }
      }

      return values;
    } // RecordTypeId

    // get dependent and controlling fields
    Field depField = this.objectFieldsMap.get(fieldApiName.toLowerCase());
    String ctrlFieldApiName = depField.controllingFieldApiName;

    if (String.isBlank(ctrlFieldApiName) || // the controlling field is a Checkbox or there is no controlling field
      this.objectFieldsMap.get(ctrlFieldApiName.toLowerCase()).dataType == Schema.DisplayType.Boolean) {
      // get all picklist items
      List<String> picklistValues = new List<String>(); // the picklist items
      for (Schema.PicklistEntry picklistEntry : this.objectFieldsMap.get(fieldApiName.toLowerCase()).pickListValues) {
        picklistValues.add(picklistEntry.getValue());
      }
      picklistValues = new List<String>(removeValuesFromList(picklistValues, exceptions));
      values = getPicklistValuesWithoutRespect(picklistValues);
    } else { // there is a controlling field
      values = getPicklistValuesWithRespect(fieldApiName, ctrlFieldApiName, null, exceptions);
    }

    return values;
  }

  /**
   * @description Creates random postal codes.
   * @param addressGroup The group of this address.
   * @return Returns a list of string values.
   */
  private List<String> getRandomPostalCodes(String addressGroup) {
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
      values.add(groupAddresses[counter].PostalCode);
    }

    return values;
  }

  /**
   * @description Creates random states.
   * @param addressGroup The group of this address.
   * @return Returns a list of string values.
   */
  private List<String> getRandomStates(String addressGroup) {
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
      values.add(groupAddresses[counter].State);
    }

    return values;
  }

  /**
   * @description Creates random streets.
   * @param addressGroup The group of this address.
   * @return Returns a list of string values.
   */
  private List<String> getRandomStreets(String addressGroup) {
    List<String> values = new List<String>();

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
      street = groupAddresses[counter].Street;
      rnd = (FObject.random * 20).intValue() + 1; // get a random number from 1 to 20
      if (FObject.streetNumberAfterStreet) { // number is after street
        street = street + ' ' + String.valueOf(rnd);
      } else { // number is before street
        street = String.valueOf(rnd) + ' ' + street;
      }
      values.add(street);
    }

    return values;
  }

  /**
   * @description Creates random strings.
   * @param minlength The minimum length of the string values.
   * @param maxlength The maximum length of the string values.
   * @param startsWith The type of the first character (upper/lower/digit).
   * @param includes The types of characters in the string (upper/lower/digit).
   * @return Returns a list of string values.
   */
  private List<String> getRandomStrings(
    Integer minlength, Integer maxlength,
    String startsWith, List<String> includes, Definition definition) {
    List<String> values = new List<String>();
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
      values.add(firstChar + restChars);
    }

    return values;
  }

  /**
   * @description Creates random texts.
   * @param minLength The length of the text.
   * @param maxLength The length of the text.
   * @param definition The definition of random type(text) script.
   * @return Returns a list of string values.
   */
  private List<String> getRandomTexts(Integer minLength, Integer maxLength, Definition definition) {
    List<String> values = new List<String>();
    List<String> words = new List<String>{
      'lorem', 'ipsum', 'dolor', 'sit', 'amet', 'tempor', 'aboreant',
      'instructor', 'eu', 'nos', 'a', 'quo', 'magna', 'primis', 'labore', 'usi', 'virtute', 'fabellas', 'vis', 'duis',
      'scripta', 'salutandi', 'laudem', 'commune', 'nam', 'laoreet', 'propriae', 'corrumpit', 'ea', 'partem',
      'inermis', 'conclusion', 'ius', 'sint', 'impedit', 'deterruis', 'eam', 'elit', 'nusquam'
    };
    Map<Integer, List<String>> wordsMap = new Map<Integer, List<String>>{
      0 => new List<String>{
        ''
      },
      1 => new List<String>{
        'a'
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
      },
      9 => new List<String>{
        'deterruis', 'corrumpit', 'salutandi'
      },
      10 => new List<String>{
        'instructor', 'conclusion'
      }
    };
    String result = '';
    Integer rnd = 0;
    Integer randomLength = 0;
    Integer newLength = 0;
    String previousWord = '';
    String selectedWord = '';

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
      return values;
    }

    Integer numWords = words.size();
    for (Integer counter = 0; counter < this.records; counter++) {
      result = '';
      randomLength = (FObject.random * (maxLength - minLength)).intValue() + minLength;
      do {
        rnd = (FObject.random * numWords).intValue();
        selectedWord = words[rnd];
        newLength = result.length() + selectedWord.length();
        if (previousWord != selectedWord && newLength <= randomLength) {
          result += selectedWord + ' ';
        }
      } while (newLength < randomLength);

      result = result.trim();
      if (result.length() < randomLength) {
        Integer additionalLength = randomLength - result.length() - 1;
        List<String> additionalWords = wordsMap.get(additionalLength);
        rnd = (FObject.random * additionalWords.size()).intValue();
        result += ' ' + additionalWords[rnd];
      }

      // capitalize text and add it to the output list
      values.add(result.capitalize());
    }

    return values;
  }

  /**
   * @description Creates random URLs.
   * @param None.
   * @return Returns a list of string values.
   */
  private List<String> getRandomUrls() {
    List<String> values = new List<String>();
    List<String> domains = getRandomDomains(5);

    for (Integer counter = 0; counter < this.records; counter++) {
      values.add('http://www.' + domains[counter]);
    }

    return values;
  }

  /**
   * @description Creates an sObject record.
   * @param recordCounter The number of the record.
   * @return Returns an sObject object.
   */
  protected SObject getRecord(Integer recordCounter) {
    SObject result = this.sObjType.newSObject(); // create a new object
    String fieldApiName = '';
    String fieldValue = ''; // the value of a field
    Schema.DisplayType valueType;

    for (Integer fieldCounter = 0; fieldCounter < this.fields.size(); fieldCounter++) { // for every defined field
      fieldApiName = this.fields[fieldCounter]; // get field
      fieldValue = this.fieldValuesMatrix.get(fieldCounter).get(recordCounter); // get the field value
      valueType = this.objectFieldsMap.get(this.fields[fieldCounter].toLowerCase()).dataType; // get the field data type

      // set field value
      try {
        if (valueType == Schema.DisplayType.Double) {
          result.put(fieldApiName, Double.valueOf(fieldValue));
        } else if (valueType == Schema.DisplayType.Currency) {
          result.put(fieldApiName, Decimal.valueOf(fieldValue));
        } else if (valueType == Schema.DisplayType.Date) {
          result.put(fieldApiName, Date.valueOf(fieldValue));
        } else if (valueType == Schema.DisplayType.Boolean) {
          result.put(fieldApiName, Boolean.valueOf(fieldValue));
        } else if (valueType == Schema.DisplayType.Percent) {
          result.put(fieldApiName, Decimal.valueOf(fieldValue));
        } else if (valueType == Schema.DisplayType.Datetime) {
          result.put(fieldApiName, Datetime.valueOf(fieldValue));
        } else if (valueType == Schema.DisplayType.Integer) {
          result.put(fieldApiName, Integer.valueOf(fieldValue));
        } else if (valueType == Schema.DisplayType.Time) {
          Time valueTime;
          valueTime = Datetime.valueOf('2018-01-01 ' + fieldValue).time();
          result.put(fieldApiName, valueTime);
        } else if (valueType == Schema.DisplayType.Base64) {
          result.put(fieldApiName, Blob.valueOf(fieldValue));
        } else { // any other type
          result.put(fieldApiName, fieldValue);
        }
      } catch (TypeException ex) {
        addError(fieldApiName, 'Invalid value for record #' + recordCounter + ' of field [' + fieldApiName + ']');
      }
    }

    return result;
  }

  /**
   * @description Retrieves the new created records of an object.
   * @param None.
   * @return Returns a list of sObject records.
   */
  public List<SObject> getRecords() {
    createNewRecords();
    List<SObject> results = new List<SObject>(this.createdRecords);

    return results;
  }

  /**
   * @description Creates serial decimal values.
   * @param fromNumber The starting decimal value.
   * @param stepNumber The value added to previous decimal value.
   * @param scale The number of decimal places.
   * @return Returns a list of string values.
   */
  private List<String> getSerialNumbers(Decimal fromNumber, Decimal stepNumber, Integer scale) {
    List<String> values = new List<String>();

    Decimal val = fromNumber + (this.recordNumber - 1) * stepNumber;
    for (Integer counter = 0; counter < this.records; counter++) {
      values.add(val.setScale(scale).toPlainString());
      val += stepNumber;
    }

    return values;
  }

  /**
   * @description Creates serial date values.
   * @param fromDate The starting date value.
   * @param step The number of days added to previous date value.
   * @return Returns a list of string values.
   */
  private List<String> getSerialDates(Date fromDate, Integer stepDays) {
    List<String> values = new List<String>();
    Date val = fromDate.addDays((this.recordNumber - 1) * stepDays);

    for (Integer counter = 0; counter < this.records; counter++) {
      values.add(String.valueOf(val));
      val = val.addDays(stepDays);
    }

    return values;
  }

  /**
   * @description Creates serial datetime values.
   * @param fromDate The starting datetime value.
   * @param step The number of days added to previous datetime value.
   * @return Returns a list of string values.
   */
  private List<String> getSerialDatetimes(Datetime fromDatetime, Decimal step) {
    List<String> values = new List<String>();

    // get the days/hours/minutes/seconds of the step
    Integer stepDays = step.intValue();

    Decimal stepHoursDecimal = (step - stepDays) * 24;
    Integer stepHours = stepHoursDecimal.intValue();

    Decimal stepMinutesDecimal = (stepHoursDecimal - stepHours) * 60;
    Integer stepMinutes = stepMinutesDecimal.intValue();

    Decimal stepSecondsDecimal = (stepMinutesDecimal - stepMinutes) * 60;
    Integer stepSeconds = stepSecondsDecimal.intValue();

    Datetime val = fromDatetime;
    val = val.addDays((this.recordNumber - 1) * stepDays);
    val = val.addHours((this.recordNumber - 1) * stepHours);
    val = val.addMinutes((this.recordNumber - 1) * stepMinutes);
    val = val.addSeconds((this.recordNumber - 1) * stepSeconds);

    for (Integer counter = 0; counter < this.records; counter++) {
      values.add(String.valueOf(val));
      val = val.addDays(stepDays);
      val = val.addHours(stepHours);
      val = val.addMinutes(stepMinutes);
      val = val.addSeconds(stepSeconds);
    }

    return values;
  }

  /**
   * @description Creates static values.
   * @param definition The field definition.
   * @param argument The static value.
   * @return Returns a list of string values.
   */
  private List<String> getStaticValues(Definition definition, String argument) {
    List<String> values = new List<String>();
    String fieldApiName = definition.fieldApiName;
    String argumentToLowercase = argument.toLowerCase();

    // get field object
    Field depField = this.objectFieldsMap.get(fieldApiName.toLowerCase());

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

    if (depField.dataType != Schema.DisplayType.Picklist &&
      depField.dataType != Schema.DisplayType.MultiPicklist) { // the field is not picklist
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
      this.objectFieldsMap.get(ctrlFieldApiName.toLowerCase()).dataType == Schema.DisplayType.Boolean) {
      values = getPicklistValuesWithoutRespect(arguments);
    } else { // there is a controlling field
      values = getPicklistValuesWithRespect(fieldApiName, ctrlFieldApiName, arguments, null);
    }

    return values;
  }

  /**
   * @description Initializes the Field Values Matrix (FVM).
   * @param None.
   * @return None.
   */
  protected void initializeFieldValuesMatrix() {
    this.fieldValuesMatrix.clear();
    for (Integer counter1 = 0; counter1 < this.fields.size(); counter1++) {
      this.fieldValuesMatrix.add(new List<String>());
      for (Integer counter2 = 0; counter2 < this.records; counter2++) {
        this.fieldValuesMatrix[counter1].add('');
      }
    }
  }

  /**
   * @description Inserts the created records.
   * @param allOrNone Specifies whether the operation allows partial success. If you specify false
   *   for this parameter and a record fails, the remainder of the DML operation can still succeed.
   * @param groupName The group name of the inserted records.
   * @return A list of Database.SaveResult objects.
   */
  public virtual List<Database.SaveResult> insertRecords(Boolean allOrNone, String groupName) {
    List<Database.SaveResult> results = new List<Database.SaveResult>();
    List<SObject> insertedRecords = new List<SObject>(); // the successfully inserted records
    Integer numRecordsInserted = 0; // the number of successfully inserted records

    if (processMustTerminate()) {
      return results;
    }

    // create records
    if (this.recordsToInsert.isEmpty()) {
      this.mustCreateNewRecords = true;
    } else {
      this.mustCreateNewRecords = false;
    }
    createNewRecords();

    if (processMustTerminate()) {
      return results;
    }

    // do not allow inserting User records when not in testing
    if (!Test.isRunningTest() && (this.objectApiName == 'User')) {
      forceeaDebug(WARN, 'Will not insert records for object [' + this.objectApiName + ']');
      return results;
    }

    // insert records
    forceeaDebug(DEBUG, 'Inserting the created records for object [' + this.objectApiName + ']');
    results = Database.insert(this.recordsToInsert, allOrNone);

    // iterate through each returned result
    Integer counter = 0;
    Integer errors = 0;
    for (Database.SaveResult sr : results) {
      counter++;
      if (sr.isSuccess()) {
        numRecordsInserted++;
        insertedRecords.add(this.recordsToInsert[counter - 1]);
      } else { // failure
        errors++;
        if (errors <= FObject.maxErrorRecordsToDisplay) {
          for (Database.Error err : sr.getErrors()) {
            addError(this.objectApiName, 'Found errors inserting record #' + counter + ': ' +
              err.getMessage() + '. Fields that affected this error: ' + err.getFields());
          }
        }
      }
    }
    // if there are errors, display a message
    if (numRecordsInserted != this.recordsToInsert.size()) {
      addError(this.objectApiName, 'Found ' + errors + ' errors inserting ' +
        this.recordsToInsert.size() + ' records for object [' + this.objectApiName + ']');
    }

    // add the inserted records to global records map
    List<SObject> objectRecords = new List<SObject>();
    if (FObject.globalInsertedRecordsMap.containsKey(this.objectApiName.toLowerCase())) { // if there are inserted records
      objectRecords = FObject.globalInsertedRecordsMap.get(this.objectApiName.toLowerCase()); // get these records
    }
    objectRecords.addAll(insertedRecords);
    FObject.globalInsertedRecordsMap.put(this.objectApiName.toLowerCase(), objectRecords);

    // add the inserted group records to global records map
    List<SObject> objectRecordsPerGroup = new List<SObject>();
    groupName = (groupName == null) ? '' : groupName; // set group name to an empty string if it is null
    String mapKey = this.objectApiName.toLowerCase() + '.' + groupName.trim().toLowerCase();
    if (FObject.globalInsertedRecordsMap.containsKey(mapKey)) { // if there are inserted records for this group
      objectRecordsPerGroup = FObject.globalInsertedRecordsMap.get(mapKey); // get these records
    }
    objectRecordsPerGroup.addAll(insertedRecords);
    FObject.globalInsertedRecordsMap.put(mapKey, objectRecordsPerGroup);

    this.recordsToInsert.clear();

    if (String.isBlank(groupName)) {
      resetMilestoneTimer('Inserted ' + numRecordsInserted + ' records');
    } else {
      resetMilestoneTimer('Inserted ' + numRecordsInserted + ' records of group [' + groupName.trim() + ']');
    }

    return results;
  }

  /**
   * @description Inserts the created records.
   * @param allOrNone Specifies whether the operation allows partial success. If you specify false
   *   for this parameter and a record fails, the remainder of the DML operation can still succeed.
   * @return A list of Database.SaveResult objects.
   */
  public List<Database.SaveResult> insertRecords(Boolean allOrNone) {
    return insertRecords(allOrNone, '');
  }

  /**
   * @description Keeps some case-insensitive values in a list and removes anything else.
   * @param listToProcess The list to be processed.
   * @param valuesToKeep The values to keep in the list.
   * @return Returns a list of string values.
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
   * @param None.
   * @return None.
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
   * @param None.
   * @return None.
   */
  private static void loadAddressesFromGreeceInGreek() {
    // do nothing if it's already loaded
    if (!FObject.addressesLibrary.isEmpty()) {
      return;
    }

    FObject.streetNumberAfterStreet = true;
    String country = 'Ελλάδα';

    // add data
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

    FObject.forceeaStaticDebug(INFO, MESSSAGE_ADDRESSES + 'Greece in the Greek language');
  }

  /**
   * @description Load addresses from United States in English.
   * @param None.
   * @return None.
   */
  private static void loadAddressesFromUnitedStatesInEnglish() {
    // do nothing if it's already loaded
    if (!FObject.addressesLibrary.isEmpty()) {
      return;
    }

    FObject.streetNumberAfterStreet = false;
    String country = 'United States';

    // add data
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

    FObject.forceeaStaticDebug(INFO, MESSSAGE_ADDRESSES + 'United States in the English language');
  }

  /**
   * @description The main method for loading names.
   * @param None.
   * @return None.
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
   * @param None.
   * @return None.
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

    FObject.forceeaStaticDebug(INFO, MESSSAGE_NAMES + 'Greece in the Greek language');
  }

  /**
   * @description Load names from United States in English.
   * @param None.
   * @return None.
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

    FObject.forceeaStaticDebug(INFO, MESSSAGE_NAMES + 'United States in the English language');
  }

  /**
   * @description Validates the parameter of a cluster.
   * @param parameter The parameter of a cluster.
   * @return Returns a boolean value.
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
   * @param definition The definition object to parse.
   * @return None.
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

  private String parseCluster(Definition definition, String script) {
    List<String> arguments = new List<String>();
    String result = script.trim();
    String argument = '';
    String chr = '';
    String parameter = ''; // the cluster parameter

    Integer doubleQuotesPosition = 0;
    Integer commaPosition = 0;
    Integer leftParenthesisPosition = 0;
    Integer rightParenthesisPosition = 0;
    Boolean mustContinue = true;
    Boolean commaExists = false;
    Boolean doubleQuotesExists = false;
    Boolean leftParenthesisExists = false;
    Boolean rightParenthesisExists = false;
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
        doubleQuotesPosition = result.indexOf('"'); // get position of closing "
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
          result = result.removeStart(chr).trim(); // remove the commna
        } else { // found something else
          addError(FIELD_API_NAME, ERROR_MESSSAGE);
          return '';
        }
      } else if (chr.containsAny('(),')) { // invalid chars
        addError(FIELD_API_NAME, ERROR_MESSSAGE);
        return '';
      } else { // an argument without double quotation marks
        // get the position of chars ( ) , "
        commaPosition = result.indexOf(','); // get the position of next ,
        doubleQuotesPosition = result.indexOf('"'); // get the position of next "
        leftParenthesisPosition = result.indexOf('('); // get the position of next )
        rightParenthesisPosition = result.indexOf(')'); // get the position of next )
        commaExists = (commaPosition != -1) ? true : false;
        doubleQuotesExists = (doubleQuotesPosition != -1) ? true : false;
        leftParenthesisExists = (leftParenthesisPosition != -1) ? true : false;
        rightParenthesisExists = (rightParenthesisPosition != -1) ? true : false;

        // decide action based on next chars
        hasError = false;

        if (rightParenthesisExists && commaExists) {
          if (rightParenthesisPosition < commaPosition) { // found )
            chr = ')';
            mustContinue = false;
          } else { // found ,
            chr = ',';
          }
        } else if (rightParenthesisExists && !commaExists) { // found )
          chr = ')'; // found )
          mustContinue = false;
        } else {
          hasError = true;
        }

        argument = result.substringBefore(chr);

        // if the argument has the invalid chars ( or " or is empty
        if (argument.containsAny('"(') || String.isBlank(argument)) {
          hasError = true;
        }

        if (hasError) {
          addError(FIELD_API_NAME, ERROR_MESSSAGE);
          return '';
        }

        result = result.removeStart(argument + chr); // remove argument and ) or , from script
        arguments.add(argument.trim()); // add argument to a list
      }
    } while (mustContinue);

    // add cluster to definition
    Cluster newCluster = new Cluster(parameter.toLowerCase(), arguments);
    definition.clusters.add(newCluster);

    return result; // the script without the cluster
  }

  /**
   * @description Posts a System.debug message.
   * @param errorLevel The System.LoggingLevel enum.
   * @param message The message to post.
   * @param verboseLevel The verbose level.
   * @return None.
   */
  private static void postDebug(String errorLevel, String message, VerboseLevel verboseLevel) {
    // prepare errorLevel
    errorLevel = errorLevel.trim();
    errorLevel = errorLevel.toLowerCase();

    if (errorLevel == ERROR) {
      System.debug(LoggingLevel.ERROR, 'FORCEEA ' + message);
    } else if (errorLevel == WARN) {
      System.debug(LoggingLevel.WARN, 'FORCEEA ' + message);
    } else if (errorLevel == INFO && verboseLevel.ordinal() >= 1) {
      System.debug(LoggingLevel.INFO, 'FORCEEA ' + message);
    } else if (errorLevel == DEBUG && verboseLevel.ordinal() == 1) {
      System.debug(LoggingLevel.DEBUG, 'FORCEEA ' + message);
    }
  }

  /**
   * @description Terminates the process if it is invalid.
   * @param None.
   * @return True, if the process is invalid.
   * @throws Returns true if the process is invalid.
   */
  protected Boolean processMustTerminate() {
    final String MESSAGE = 'Process is invalid and will terminate';

    if (!FObject.processIsValid) {
      if (Test.isRunningTest()) {
        if (!FObject.exceptionErrorMessageIsDisplayed) {
          forceeaDebug(ERROR, MESSAGE);
          FObject.exceptionErrorMessageIsDisplayed = true;
        }
      } else {
        throw new ForceeaException(message);
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
   * @return Returns a list of string values.
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
   * @description Resets the CPU timer and displays information
   *   about the elapsed time (in ms) since the previous reset.
   * @param infoText The information message to display.
   * @return None.
   */
  protected void resetMilestoneTimer(String infoText) {
    forceeaDebug(INFO, '>> ' + infoText + ' for object [' + this.objectApiName + '] in ' +
      this.milestoneDuration + ' ms. Transaction duration: ' + Limits.getCpuTime() + ' ms');
    this.milestoneStartTime = Limits.getCpuTime();
  }

  /**
   * @description Declares a field definition.
   * @param fieldName The API name of a field.
   * @param definition The field definition (command + script).
   * @return None.
   */
  public void setDefinition(String fieldName, String definition) {
    setDefinition(fieldName, false, definition);
  }

  /**
   * @description Declares a field definition in a specific position.
   * @param fieldName The API name of a field.
   * @param definitionString The field definition (command + script) string.
   * @param position The position of the definition.
   * @return None.
   */
  protected virtual void setDefinition(String fieldName, Boolean isSystemDeclared, String definitionString) {
    String thisFieldName = fieldName.trim();
    String userFieldName = thisFieldName;

    thisFieldName = thisFieldName.toLowerCase();
    definitionString = definitionString.trim();
    String fieldApiName = getFieldApiName(thisFieldName);

    if (String.isBlank(fieldApiName)) { // field is invalid
      addError(this.objectApiName, 'Invalid field [' + userFieldName + '] for definition [' + definitionString + ']');
    } else { // field is valid
      // declare a new definition
      Definition def = new Definition(thisFieldName, fieldApiName, isSystemDeclared, definitionString);
      def.fieldApiName = fieldApiName;
      // initialize variables
      Boolean fieldExists = false;
      Integer counter = 0;
      for (String field : this.fields) { // for each field
        if (('.' + fieldApiName) == field) { // the field is inactive
          this.fields[counter] = fieldApiName; // activate it
          fieldExists = true;
          break;
        } else if (fieldApiName == field) { // the field is activated
          fieldExists = true;
          break;
        }
        counter++;
      }

      if (!fieldExists) {
        this.fields.add(fieldApiName); // add new field
      }

      this.definitions.add(def); // add new definition

      forceeaDebug(DEBUG, SUCCESS_SYMBOL + ' Registered field [' + def.fieldApiName +
        '] with definition [' + def.definitionString + ']');
    }

    this.definitionsAreValidated = false;
    this.mustCreateNewRecords = true;
  }

  /**
   * @description Sets a field definition based on the field data type and the object.
   * @param field A field object.
   * @return None.
   */
  @TestVisible
  private void setDefinitionFromField(Field field) {
    if (this.objectApiName == 'Account' && field.fieldApiName == 'Name') {
      setDefinition(field.fieldApiName, true, 'static value(Company)');
      setDefinition(field.fieldApiName, true, 'random type(number) from(1) to(10000) scale(0)');
    } else if (this.objectApiName == 'Contact' && field.fieldApiName == 'FirstName') {
      setDefinition(field.fieldApiName, true, 'random type(firstname) group(name)');
    } else if (this.objectApiName == 'Contact' && field.fieldApiName == 'LastName') {
      setDefinition(field.fieldApiName, true, 'random type(lastname) group(name)');
    } else if (this.objectApiName == 'Lead' && field.fieldApiName == 'Company') {
      setDefinition(field.fieldApiName, true, 'static value(Company)');
      setDefinition(field.fieldApiName, true, 'random type(number) from(1) to(10000) scale(0)');
    } else if (this.objectApiName == 'Lead' && field.fieldApiName == 'FirstName') {
      setDefinition(field.fieldApiName, true, 'random type(firstname) group(name)');
    } else if (this.objectApiName == 'Lead' && field.fieldApiName == 'LastName') {
      setDefinition(field.fieldApiName, true, 'random type(lastname) group(name)');
    } else if (this.objectApiName == 'Opportunity' && field.fieldApiName == 'Name') {
      setDefinition(field.fieldApiName, true, 'static value(Opportunity-)');
      setDefinition(field.fieldApiName, true, 'serial type(number) from(1) step(1) scale(0)');
    } else if (field.dataType == Schema.DisplayType.Integer) {
      setDefinition(field.fieldName, true, 'random type(number) from(1) to(100) scale(0)');
    } else if (field.dataType == Schema.DisplayType.Currency) {
      setDefinition(field.fieldName, true, 'random type(number) from(1000) to(10000) scale(2)');
    } else if (field.dataType == Schema.DisplayType.Double) {
      setDefinition(field.fieldName, true, 'random type(number) from(1000) to(10000) scale(3)');
    } else if (field.dataType == Schema.DisplayType.Date) {
      Integer thisYear = Date.today().year();
      String fromDate = String.valueOf(thisYear - 1) + '-01-01';
      String toDate = String.valueOf(thisYear + 1) + '-12-31';
      setDefinition(field.fieldName, true, 'random type(date) from(' + fromDate + ') to(' + toDate + ')');
    } else if (field.dataType == Schema.DisplayType.Datetime) {
      Integer thisYear = Date.today().year();
      String fromDate = String.valueOf(thisYear - 1) + '-01-01';
      String toDate = String.valueOf(thisYear + 1) + '-12-31';
      setDefinition(field.fieldName, true, 'random type(datetime) from(' + fromDate + ') to(' + toDate + ')');
    } else if (
      field.dataType == Schema.DisplayType.Picklist ||
        field.dataType == Schema.DisplayType.MultiPicklist ||
        field.dataType == Schema.DisplayType.Combobox) {
      setDefinition(field.fieldName, true, 'random type(picklist)');
    } else if (field.dataType == Schema.DisplayType.String) {
      Integer minlength = (field.length < 5) ? field.length : 5;
      setDefinition(field.fieldName, true, 'random type(string) minlength(' + minlength + ') maxlength(' +
        field.length + ') startwith(upper) include(lower,upper)');
    } else if (field.dataType == Schema.DisplayType.TextArea) {
      setDefinition(field.fieldName, true, 'random type(text) minlength(30) maxlength(100)');
    } else if (field.dataType == Schema.DisplayType.Percent) {
      setDefinition(field.fieldName, true, 'random type(number) from(0) to(100) scale(2)');
    } else if (field.dataType == Schema.DisplayType.Reference) {
      String source = (FObject.isAsync) ? 'salesforce' : 'forceea';
      setDefinition(field.fieldName, true, 'random lookup(' + field.parents[0] + ') source(' + source + ')');
    } else if (field.dataType == Schema.DisplayType.Boolean) {
      setDefinition(field.fieldName, true, 'random type(boolean)');
    } else if (field.dataType == Schema.DisplayType.Email) {
      setDefinition(field.fieldName, true, 'random type(email)');
    } else if (field.dataType == Schema.DisplayType.Phone) {
      setDefinition(field.fieldApiName, true, 'static value(21011)');
      setDefinition(field.fieldApiName, true, 'random type(number) from(11111) to(99999) scale(0)');
    } else if (field.dataType == Schema.DisplayType.Url) {
      setDefinition(field.fieldName, true, 'random type(url)');
    } else if (field.dataType == Schema.DisplayType.Time) {
      setDefinition(field.fieldName, true, 'static value(12:00:00)');
    }

    this.foundRequiredFields = true;
  }

  /**
   * @description Sets the object required fields.
   * @param None.
   * @return None.
   */
  protected void setDefinitionOfRequiredFields() {
    if (this.setRequiredFields) {
      forceeaDebug(DEBUG, 'Setting the definition of required fields for object [' + this.objectApiName + ']');
    } else {
      forceeaDebug(WARN, 'Will not set the definition of required fields for object [' + this.objectApiName + ']');
      return;
    }

    // depending on the object, set definitions
    List<String> requiredFieldNames = new List<String>();
    if (this.objectApiName == 'User') {
      this.foundRequiredFields = true;

      List<String> requiredDefinitions = new List<String>();
      forceeaDebug(INFO, 'Object is [' + this.objectApiName + '] and specific fields will be defined');

      // prepare field definition lists
      requiredFieldNames.add('Alias');
      requiredDefinitions.add('random type(string) minlength(8) maxlength(8) startwith(upper) include(lower)');
      requiredFieldNames.add('FirstName');
      requiredDefinitions.add('random type(firstname) group(name)');
      requiredFieldNames.add('LastName');
      requiredDefinitions.add('random type(lastname) group(name)');
      requiredFieldNames.add('Username');
      requiredDefinitions.add('random type(email)');
      requiredFieldNames.add('Email');
      requiredDefinitions.add('copy field(Username)');
      requiredFieldNames.add('EmailEncodingKey');
      requiredDefinitions.add('static value(UTF-8)');
      requiredFieldNames.add('TimeZonesIdKey');
      requiredDefinitions.add('static value(GMT)');
      requiredFieldNames.add('LocalesIdKey');
      requiredDefinitions.add('static value(en_US)');
      requiredFieldNames.add('LanguageLocaleKey');
      requiredDefinitions.add('static value(en_US)');
      requiredFieldNames.add('ProfileId');
      requiredDefinitions.add('static lookup(profile) field(name) value(Standard User) source(salesforce)');
      // set field definitions
      for (Integer counter = 0; counter < requiredFieldNames.size(); counter++) {
        if (!this.fields.contains(requiredFieldNames[counter])) { // if field is not defined
          setDefinition(requiredFieldNames[counter], true, requiredDefinitions[counter]);
        }
      }
    } else { // object is anything else
      for (Field field : this.objectFieldsMap.values()) { // for each field in the fields map
        // if field is required and is not defined yet
        if (field.isRequired && (!this.fields.contains(field.fieldApiName))) {
          setDefinitionFromField(field); // set a new definition for this Field
          requiredFieldNames.add(field.fieldApiName);
        }
      }
    }

    if (!this.foundRequiredFields) {
      forceeaDebug(INFO, 'Found no additional required fields');
    }
  }

  /**
   * @description Declares all definition types.
   * @param None.
   * @return None.
   */
  private static void setDefinitionTypes() {
    DefinitionType dt = new DefinitionType();

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

    // example: random type(picklist)
    dt = new DefinitionType(DefinitionTypeId.RANDOM_PICKLIST, 'RandomPicklist', 'random');
    dt.clusterTypes.add(new ClusterType('type', ValueType.TYPE_STRING, 'picklist', false));
    FObject.definitionTypes.add(dt);
    // example: random type(picklist) except(a,b,c)
    dt = new DefinitionType(DefinitionTypeId.RANDOM_PICKLIST_EXCEPT, 'RandomPicklistExcept', 'random');
    dt.clusterTypes.add(new ClusterType('type', ValueType.TYPE_STRING, 'picklist', false));
    dt.clusterTypes.add(new ClusterType('except', ValueType.TYPE_STRING, null, true));
    FObject.definitionTypes.add(dt);

    // example: random type(boolean)
    dt = new DefinitionType(DefinitionTypeId.RANDOM_BOOLEAN, 'RandomBoolean', 'random');
    dt.clusterTypes.add(new ClusterType('type', ValueType.TYPE_STRING, 'boolean', false));
    FObject.definitionTypes.add(dt);

    // example: random type(email)
    dt = new DefinitionType(DefinitionTypeId.RANDOM_EMAIL, 'RandomEmail', 'random');
    dt.clusterTypes.add(new ClusterType('type', ValueType.TYPE_STRING, 'email', false));
    FObject.definitionTypes.add(dt);

    // example: random type(phone) format("(353) dd dd ddd")
    dt = new DefinitionType(DefinitionTypeId.RANDOM_PHONE, 'RandomPhone', 'random');
    dt.clusterTypes.add(new ClusterType('type', ValueType.TYPE_STRING, 'phone', false));
    dt.clusterTypes.add(new ClusterType('format', ValueType.TYPE_STRING, null, false));
    FObject.definitionTypes.add(dt);

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

    // example: random type(url)
    dt = new DefinitionType(DefinitionTypeId.RANDOM_URL, 'RandomUrl', 'random');
    dt.clusterTypes.add(new ClusterType('type', ValueType.TYPE_URL, 'url', false));
    FObject.definitionTypes.add(dt);

    // example: random lookup(Account) source(forceea)
    dt = new DefinitionType(DefinitionTypeId.RANDOM_LOOKUP, 'RandomLookupForceea', 'random');
    dt.clusterTypes.add(new ClusterType('lookup', ValueType.TYPE_STRING, null, false));
    dt.clusterTypes.add(new ClusterType('source', ValueType.TYPE_STRING, 'forceea', false));
    FObject.definitionTypes.add(dt);
    // example: random lookup(Account) field(Name) value(Company XYZ) source(forceea)
    dt = new DefinitionType(DefinitionTypeId.RANDOM_LOOKUP, 'RandomLookupFieldValueForceea', 'random');
    dt.clusterTypes.add(new ClusterType('lookup', ValueType.TYPE_STRING, null, false));
    dt.clusterTypes.add(new ClusterType('field', ValueType.TYPE_STRING, null, false));
    dt.clusterTypes.add(new ClusterType('value', ValueType.TYPE_STRING, null, true));
    dt.clusterTypes.add(new ClusterType('source', ValueType.TYPE_STRING, 'forceea', false));
    FObject.definitionTypes.add(dt);
    // example: random lookup(Account) field(Name) except(Company XYZ) source(forceea)
    dt = new DefinitionType(DefinitionTypeId.RANDOM_LOOKUP, 'RandomLookupFieldExceptForceea', 'random');
    dt.clusterTypes.add(new ClusterType('lookup', ValueType.TYPE_STRING, null, false));
    dt.clusterTypes.add(new ClusterType('field', ValueType.TYPE_STRING, null, false));
    dt.clusterTypes.add(new ClusterType('except', ValueType.TYPE_STRING, null, true));
    dt.clusterTypes.add(new ClusterType('source', ValueType.TYPE_STRING, 'forceea', false));
    FObject.definitionTypes.add(dt);

    // example: random lookup(Account) group(one) source(forceea)
    dt = new DefinitionType(DefinitionTypeId.RANDOM_LOOKUP, 'RandomLookupGroupForceea', 'random');
    dt.clusterTypes.add(new ClusterType('lookup', ValueType.TYPE_STRING, null, false));
    dt.clusterTypes.add(new ClusterType('group', ValueType.TYPE_STRING, null, false));
    dt.clusterTypes.add(new ClusterType('source', ValueType.TYPE_STRING, 'forceea', false));
    FObject.definitionTypes.add(dt);
    // example: random lookup(Account) field(Name) value(Company XYZ) group(one) source(forceea)
    dt = new DefinitionType(DefinitionTypeId.RANDOM_LOOKUP, 'RandomLookupFieldValueGroupForceea', 'random');
    dt.clusterTypes.add(new ClusterType('lookup', ValueType.TYPE_STRING, null, false));
    dt.clusterTypes.add(new ClusterType('field', ValueType.TYPE_STRING, null, false));
    dt.clusterTypes.add(new ClusterType('value', ValueType.TYPE_STRING, null, true));
    dt.clusterTypes.add(new ClusterType('group', ValueType.TYPE_STRING, null, false));
    dt.clusterTypes.add(new ClusterType('source', ValueType.TYPE_STRING, 'forceea', false));
    FObject.definitionTypes.add(dt);
    // example: random lookup(Account) field(Name) except(Company XYZ) group(one) source(forceea)
    dt = new DefinitionType(DefinitionTypeId.RANDOM_LOOKUP, 'RandomLookupFieldExceptGroupForceea', 'random');
    dt.clusterTypes.add(new ClusterType('lookup', ValueType.TYPE_STRING, null, false));
    dt.clusterTypes.add(new ClusterType('field', ValueType.TYPE_STRING, null, false));
    dt.clusterTypes.add(new ClusterType('except', ValueType.TYPE_STRING, null, true));
    dt.clusterTypes.add(new ClusterType('group', ValueType.TYPE_STRING, null, false));
    dt.clusterTypes.add(new ClusterType('source', ValueType.TYPE_STRING, 'forceea', false));
    FObject.definitionTypes.add(dt);

    // example: random lookup(Account) source(salesforce)
    dt = new DefinitionType(DefinitionTypeId.RANDOM_LOOKUP, 'RandomLookupSalesforce', 'random');
    dt.clusterTypes.add(new ClusterType('lookup', ValueType.TYPE_STRING, null, false));
    dt.clusterTypes.add(new ClusterType('source', ValueType.TYPE_STRING, 'salesforce', false));
    FObject.definitionTypes.add(dt);
    // example: random lookup(Account) field(Name) value(Company XYZ) source(salesforce)
    dt = new DefinitionType(DefinitionTypeId.RANDOM_LOOKUP, 'RandomLookupFieldValueSalesforce', 'random');
    dt.clusterTypes.add(new ClusterType('lookup', ValueType.TYPE_STRING, null, false));
    dt.clusterTypes.add(new ClusterType('field', ValueType.TYPE_STRING, null, false));
    dt.clusterTypes.add(new ClusterType('value', ValueType.TYPE_STRING, null, true));
    dt.clusterTypes.add(new ClusterType('source', ValueType.TYPE_STRING, 'salesforce', false));
    FObject.definitionTypes.add(dt);
    // example: random lookup(Account) field(Name) except(Company XYZ) source(salesforce)
    dt = new DefinitionType(DefinitionTypeId.RANDOM_LOOKUP, 'RandomLookupFieldExceptSalesforce', 'random');
    dt.clusterTypes.add(new ClusterType('lookup', ValueType.TYPE_STRING, null, false));
    dt.clusterTypes.add(new ClusterType('field', ValueType.TYPE_STRING, null, false));
    dt.clusterTypes.add(new ClusterType('except', ValueType.TYPE_STRING, null, true));
    dt.clusterTypes.add(new ClusterType('source', ValueType.TYPE_STRING, 'salesforce', false));
    FObject.definitionTypes.add(dt);
    // example: random lookup(Account) where(Rating = 'Hot') source(salesforce)
    dt = new DefinitionType(DefinitionTypeId.RANDOM_LOOKUP_WHERE, 'RandomLookupWhereSalesforce', 'random');
    dt.clusterTypes.add(new ClusterType('lookup', ValueType.TYPE_STRING, null, false));
    dt.clusterTypes.add(new ClusterType('where', ValueType.TYPE_STRING, null, false));
    dt.clusterTypes.add(new ClusterType('source', ValueType.TYPE_STRING, 'salesforce', false));
    FObject.definitionTypes.add(dt);

    // order: RandomListInteger, RandomListDecimal, RandomListDatetime, RandomListDate, RandomListString
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
    dt = new DefinitionType(DefinitionTypeId.STATIC_LOOKUP, 'StaticLookupForceea', 'static');
    dt.clusterTypes.add(new ClusterType('lookup', ValueType.TYPE_STRING, null, false));
    dt.clusterTypes.add(new ClusterType('field', ValueType.TYPE_STRING, null, false));
    dt.clusterTypes.add(new ClusterType('value', ValueType.TYPE_STRING, null, false));
    dt.clusterTypes.add(new ClusterType('source', ValueType.TYPE_STRING, 'forceea', false));
    FObject.definitionTypes.add(dt);
    // example: static lookup(Account) field(Name) value(Company XYZ) source(salesforce)
    dt = new DefinitionType(DefinitionTypeId.STATIC_LOOKUP, 'StaticLookupSalesforce', 'static');
    dt.clusterTypes.add(new ClusterType('lookup', ValueType.TYPE_STRING, null, false));
    dt.clusterTypes.add(new ClusterType('field', ValueType.TYPE_STRING, null, false));
    dt.clusterTypes.add(new ClusterType('value', ValueType.TYPE_STRING, null, false));
    dt.clusterTypes.add(new ClusterType('source', ValueType.TYPE_STRING, 'salesforce', false));
    FObject.definitionTypes.add(dt);

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
   * @description Sets the controlling fields' definition
   * @param None.
   * @return None.
   */
  private void setDependentFields() {
    // initialize
    Integer depFieldPosition = -1; // the position of dependent field's definition
    Integer ctrlFieldPosition = -1; // the position of controlling field's definition
    String depFieldApiName = ''; // the dependent field API name
    String ctrlFieldApiName = ''; // the controlling field API name
    Field field = new Field(); // the field details of the dependent field
    List<Definition> existingDefinitions = new List<Definition>(this.definitions);

    for (Definition def : existingDefinitions) { // for each definition
      depFieldApiName = def.fieldApiName;
      field = this.objectFieldsMap.get(depFieldApiName.toLowerCase()); // get field details

      if (String.isBlank(field.controllingFieldApiName)) { // field doesn't have a controlling field
        continue; // go to next definition
      } else { // get controlling field's API name
        ctrlFieldApiName = field.controllingFieldApiName;
      }

      // the (dependent) field has a controlling field
      // and it respects field dependencies
      Schema.DisplayType ctrlFieldType = this.objectFieldsMap.get(ctrlFieldApiName.toLowerCase()).dataType;

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
        setDefinition(ctrlFieldApiName, true, newDefinition);
      }
      upsertFieldBeforePosition(ctrlFieldApiName, depFieldPosition);
    }

    validateDefinitions();
  }

  /**
   * @description Sets the verbose mode at the class level.
   * @param mode The verbose mode (none, info, debug).
   * @return None.
   */
  public static void setGlobalVerbose(String mode) {
    mode = mode.toLowerCase();

    if (mode == 'none') {
      FObject.globalVerboseMode = VerboseLevel.VERBOSE_NONE;
    } else if (mode == 'debug') {
      FObject.globalVerboseMode = VerboseLevel.VERBOSE_DEBUG;
    } if (mode == 'info') {
      FObject.globalVerboseMode = VerboseLevel.VERBOSE_INFO;
    }
  }

  public static void resetLanguageLocality() {
    FObject.firstNamesLibraryMap.clear();
    FObject.lastNamesLibraryMap.clear();
    FObject.addressesLibrary.clear();
  }

  /**
   * @description Stores the object's field details to the global fields map
   * @param objectApiName The object API name.
   * @return None.
   */
  private static void setObject(String objectApiName) {
    Map<String, Field> fieldsMap = new Map<String, Field>();
    Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectApiName); // get object type

    for (Schema.SObjectField sof : objType.getDescribe().fields.getMap().values()) { // for each sObject field
      Field field = FObject.getDetailsFromSObjectField(sof); // get the field object
      fieldsMap.put(field.fieldApiName.toLowerCase(), field); // add field to map
    }

    FObject.globalObjectFieldsMap.put(objectApiName.toLowerCase(), fieldsMap); // add object fields to global map
  }

  /**
   * @description Sets the verbose mode at the instance level.
   * @param mode The verbose mode (none, info, debug).
   * @return None.
   */
  public void setVerbose(String mode) {
    mode = mode.toLowerCase();

    if (mode == 'none') {
      this.verboseMode = VerboseLevel.VERBOSE_NONE;
    } else if (mode == 'debug') {
      this.verboseMode = VerboseLevel.VERBOSE_DEBUG;
    } if (mode == 'info') {
      this.verboseMode = VerboseLevel.VERBOSE_INFO;
    }
  }

  /**
   * @description Inserts or moves a field before a specific position of the fields list.
   *   If the field exists, it is moved before the position.
   *   If it doesn't exist, it is inserted before the position.
   * @param fieldApiName The field API name.
   * @param position The position of the fields list.
   * @return None.
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
   * @description Validates the field definitions.
   * @param None.
   * @return None.
   */
  protected void validateDefinitions() {
    if (this.definitionsAreValidated) {
      return;
    }

    if (!this.willValidateFieldDefinitionsMessageIsDisplayed) {
      forceeaDebug(DEBUG, 'Validating the field definitions for object [' + this.objectApiName + ']');
      this.willValidateFieldDefinitionsMessageIsDisplayed = true;
    }

    for (Definition definition : this.definitions) { // for each definition
      if (definition.isValidated) { // go to next definition if the definition is already validated
        continue;
      }

      parseDefinition(definition); // parse each definition and get its command and clusters (parameter/arguments)

      if (definitionIsValid(definition)) {
        forceeaDebug(DEBUG, SUCCESS_SYMBOL + ' Definition [' + definition.definitionString +
          '] of field [' + definition.fieldApiName + '] is valid');
      }
    }

    this.definitionsAreValidated = true;
    setDependentFields();
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