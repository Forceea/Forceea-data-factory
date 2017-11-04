/**
 * @description Forceea data factory framework
 * @version 1.1
 */
global class FObject {

  /* CONSTANTS */

  private static final Integer DEFAULT_RECORDS = 201;
  private static final Integer DISPLAY_RECORDS = 20;
  private static final Integer MAX_ERROR_RECORDS_IN_DEBUG_LOG = 100;
  private static final String VERSION = '1.1';
  private static final String MESSSAGE_NAMES = 'Loaded first & last names from ';
  private static final String MESSSAGE_ADDRESSES = 'Loaded addresses from ';
  private static final String FAILURE_SYMBOL = '►';
  private static final String SUCCESS_SYMBOL = '●';

  private static final DetailedErrorLevel ERROR_LEVEL = DetailedErrorLevel.LEVEL_DEBUG;
  private static final Boolean DEBUG_MODE = true;

  /* ENUMS */
  private enum ValueType { TYPE_LOOKUP, TYPE_INTEGER, TYPE_DECIMAL, TYPE_STRING, TYPE_DATE,
    TYPE_EMAIL, TYPE_URL, TYPE_PHONE, TYPE_BOOLEAN }
  private enum DetailedErrorLevel { LEVEL_DEBUG, LEVEL_FINE, LEVEL_FINER }
  private enum DefinitionTypeId {
    RANDOM_STRING, RANDOM_TEXT, RANDOM_NUMBER, RANDOM_DATE, RANDOM_DATETIME, RANDOM_LOOKUP,
    RANDOM_PICKLIST, RANDOM_PICKLISTEXCEPT, RANDOM_LIST,
    RANDOM_STREET, RANDOM_CITY, RANDOM_STATE, RANDOM_POSTALCODE, RANDOM_COUNTRY,
    RANDOM_EMAIL, RANDOM_BOOLEAN, RANDOM_URL, RANDOM_FIRSTNAME, RANDOM_LASTNAME,
    STATIC_STRING, STATIC_LOOKUP, SERIAL_DECIMAL
  }

  /* STATIC COLLECTIONS */

  // API names of all Salesforce objects
  private static List<String> salesforceObjectsApiName = new List<String>();
  // valid SDDL commands
  private static List<String> commands = new List<String> { 'random', 'static', 'serial' };
  // valid SDDL parameters
  private static Set<String> parametersSet = new Set<String> {
    'scale',  'except', 'field', 'from', 'group', 'include', 'lookup', 'maxlength', 'minlength',
    'number', 'object',  'source', 'startwith', 'step', 'to', 'type', 'value'
  };
  // defined cluster types
  private static List<DefinitionType> definitionTypes = new List<DefinitionType>();
  // created records of all objects
  private static Map<String, List<SObject>> globalRecordsMap = new Map<String, List<SObject>>();
  // field details of each declared FObject
  private static Map<String, Map<String, Field>> globalObjectFieldsMap = new Map<String, Map<String, Field>>();
  // defined objects
  private static List<String> objects = new List<String>();
  // the results of the Record types SOQL query
  private static List<RecordType> recordTypesQueryResults = new List<RecordType>();

  // the libraries for first & last names, key: locality
  private static Map<String, List<String>> firstNamesLibrary = new Map<String, List<String>>();
  private static Map<String, List<String>> lastNamesLibrary = new Map<String, List<String>>();
  // the library of addresses, key: locality
  private static List<FAddress> addressesLibrary = new List<FAddress>();

  /* INSTANCE COLLECTIONS */

  // record types of this object (DeveloperName, Id)
  private Map<String, Id> recordTypesMap = new Map<String, Id>();
  // defined fields
  private Set<String> fieldSet = new Set<String>();
  private List<String> fieldsList = new List<String>();
  private Map<String, Field> objectFieldsMap = new Map<String, Field>();
  // field definitions
  private List<Definition> definitions = new List<Definition>();
  // the FVM, each List<string> contains a field's values
  private List<List<String>> fieldValuesMatrix = new List<List<String>>();
  // generated object records
  private List<SObject> createdRecords = new List<SObject>();
  // errors in definitions
  private List<Error> errors = new List<Error>();
  // first & last names (key:name group)
  private Map<String, List<Name>> names = new Map<String, List<Name>>();
  // addresses (key:address group)
  private Map<String, List<FAddress>> addresses = new Map<String, List<FAddress>>();

  /* STATIC PROPERTIES */

  // TRUE if the "Process is invalid and will terminate." error message has been displayed
  private static Boolean ExceptionErrorMessageIsDisplayed { get; set; }
  // TRUE if this process has no errors (valid)
  private static Boolean ProcessIsValid { get; set; }
  // if TRUE, it posts to System.debug
  global static Boolean DebugMode { get; set; }
  // the language of data (like name fields and addresses)
  global static String Language {
    get;
    set {
      // reset libraries
      firstNamesLibrary.clear();
      lastNamesLibrary.clear();
      addressesLibrary.clear();
      Language = value;
    }
  }
  // the locality of data (like name fields and addresses)
  global static String Locality {
    get;
    set {
      // reset libraries
      firstNamesLibrary.clear();
      lastNamesLibrary.clear();
      addressesLibrary.clear();
      Locality = value;
    }
  }
  // true if the street number is after street, e.g. Abcd 12
  private static Boolean StreetNumberAfterStreet { get; set; }

  /* INSTANCE PROPERTIES */

  // the CPU limit time for the timer start and finish
  private Integer MilestoneStartTime { get; set; }
  private Integer InstanceStartTime { get; set; }
  // the elapsed CPU time for a milestone
  private Integer MilestoneDuration {
    get {
      return Limits.getCpuTime() - MilestoneStartTime;
    }
    set;
  }
  // the object type
  private Schema.SObjectType SObjType { get; set; }
  // the user defined object name
  private String ObjectName { get; set; }
  // the API object name
  private String ObjectApiName { get; set; }
  // true if auto defines required fields
  global Boolean SetRequiredFields { get; set; }
  // the number of records to create
  global Integer Records { get; set; }
  // TRUE if all definitions are validated
  private Boolean DefinitionsAreValidated { get; set; }

  /* CLASSES */

  /**
   * @description An address object.
   */
  private class FAddress {
    String Street { get; set; }
    String PostalCode { get; set; }
    String City { get; set; }
    String State { get; set; }
    String Country { get; set; }

    private FAddress(String street, String postalCode, String city, String state, String country) {
      this.Street = street;
      this.City = city;
      this.PostalCode = postalCode;
      this.State = state;
      this.Country = country;
    }

    private FAddress(FAddress address) {
      this.Street = address.Street;
      this.PostalCode = address.PostalCode;
      this.City = address.City;
      this.State = address.State;
      this.Country = address.Country;
    }
  }

  /**
   * @description A definition cluster <cluster> ::= <parameter>(<argument[,...n]>)
   */
  private class Cluster {
    String Parameter { get; set; }
    List<String> arguments = new List<String>();

    private Cluster(String parameter, String value) {
      this.Parameter = parameter;
      this.arguments.add(value);
    }
  }

  /**
   * @description  A template for a valid cluster
   *  Cluster Types are defined in static method setDefinitionTypes
   */
  private class ClusterType {
    String Parameter { get; set; }
    ValueType ValueType { get; set; }
    String Value { get; set; }
    Boolean MultipleValueItems { get; set; }

    private ClusterType(String parameter, ValueType valueType,
        String value, Boolean multipleValueItems) {
      this.Parameter = parameter; // e.g. type
      this.ValueType = valueType; // e.g. TYPE_STRING
      this.Value = value; // e.g. street
      this.MultipleValueItems = multipleValueItems; // e.g. false
    }
  }

  /**
   * @description A field definition
   *  <definition> ::= <command> <script>, <script> ::= <cluster>[,...n]
  */
  private class Definition {
    String FieldName { get; set; } // the user defined field name 
    String FieldApiName { get; set; }
    String DefinitionString { get; set; } // the user defined field definition 
    String Command { get; set; } // the definition command
    String Script { get; set; } // the definition script
    Boolean IsSystemDefined { get; set; }
    Boolean IsValid { get; set; }
    Boolean IsValidated { get; set; }
    DefinitionType Type { get; set; }
    List<Cluster> clusters = new List<Cluster>();

    private Definition(String fieldName, String fieldApiName,
        Boolean isSystemDefined, String definition) {
      this.FieldName = fieldName;
      this.FieldApiName = fieldApiName;
      this.DefinitionString = definition;
      this.IsSystemDefined = isSystemDefined;
      this.IsValid = false;
      this.IsValidated = false;

      if (this.IsSystemDefined) {
        this.IsValid = true;
        this.IsValidated = true;
      } 
    }
  }

  /**
   * @description A template for a valid definition
  */
  private class DefinitionType {
    DefinitionTypeId Id { get; set; } // e.g. DefinitionTypeId.RANDOM_STREET (enum)
    String Description { get; set; } // e.g. RandomStreet
    String Command { get; set; } // e.g. random
    List<ClusterType> clusterTypes = new List<ClusterType>();

    private DefinitionType(DefinitionTypeId id, String description, String command) {
      this.Id = id;
      this.Description = description;
      this.Command = command;
    }

    private DefinitionType() {
      this.Id = null;
      this.Description = null;
      this.Command = null;
    }
  }

  /**
   * @description An error message
  */
  private class Error {
    String Id { get; set; }
    String ErrorMessage { get; set; }

    private Error(String errorId, String errorMessage) {
      this.Id = errorId;
      this.ErrorMessage = errorMessage;
    }
  }

  /**
   * @description An object field
  */
  @TestVisible
  private class Field {
    String FieldName { get; set; } // the user defined field name
    public String FieldApiName { get; set; } // the API field name
    String Label { get; set; } // the system defined field label
    Schema.DisplayType Type { get; set; }
    Boolean IsRequired { get; set; }
    Integer Length { get; set; } // the length of a string
    //Integer precision { get; set; }
    //Integer scale { get; set; }
    //Boolean isCreateable { get; set; }
    //Boolean isNillable { get; set; }
    //Boolean isDefaultedOnCreate { get; set; }
    //Boolean isIdLookup { get; set; }
    //Boolean isUnique { get; set; }
    //Object defaultValue { get; set; }
    List<Schema.sObjectType> parents { get; set; }
    List<Schema.PicklistEntry> picklistValues = new List<Schema.PicklistEntry>();
    Schema.SObjectField controllerField { get; set; }
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

  /* INITIALIZATION */

  // static initialization
  static {
    FObject.DebugMode = DEBUG_MODE;
    postDebug('info', 'v' + VERSION);

    // declare defintion types
    setDefinitionTypes();

    // query for active RecordType records
    String soql = 'SELECT Id, Name, DeveloperName, sObjectType ' +
      'FROM RecordType WHERE IsActive = true';

    // get record types
    try {
      recordTypesQueryResults = Database.query(soql);
    } catch (QueryException ex) {
      postDebug('error', FAILURE_SYMBOL + ' Error in registering record types: ' + ex.getMessage());
    }

    // declare properties
    FObject.Language = 'English';
    FObject.Locality = 'United States';
    FObject.ExceptionErrorMessageIsDisplayed = false;

    // get the API names of all Salesforce objects
    for (Schema.SObjectType sot : Schema.getGlobalDescribe().values()) {
      salesforceObjectsApiName.add(sot.getDescribe().getName());
    }

    postDebug('info', '>> Setup settings in ' + Limits.getCpuTime() + ' ms');
  }

  // instance initialization
  {
    // reset timer
    this.MilestoneStartTime = Limits.getCpuTime();
  }

  /* CONSTRUCTORS */

  global FObject(String objectName) {
    this(objectName, DEFAULT_RECORDS);
  }

  global FObject(String objectName, Integer records) {
    // initialize properties
    this.ObjectName = objectName.toLowerCase();
    this.Records = records;
    this.SetRequiredFields = false;
    this.definitionsAreValidated = false;

    // validate object
    if (objectNameIsValid(objectName)) {
      FObject.ProcessIsValid = true;
      postDebug('info', 'Will generate sample data for object [' + this.ObjectApiName + ']');
    } else { // object name is invalid
      FObject.ProcessIsValid = false;
      addError(objectName, 'Invalid object [' + objectName + ']');
      if (processMustTerminate()) {
        return;
      }
    }

    // get object type
    this.SObjType = Schema.getGlobalDescribe().get(objectName);
    String sObjTypeString = String.valueOf(this.sObjType);

    // get record types
    for (RecordType rt : recordTypesQueryResults) {
      if (sObjTypeString == rt.SObjectType) {
        this.recordTypesMap.put(rt.DeveloperName.toLowerCase(), rt.Id);
        //postDebug('info', 'Found record type [' + rt.DeveloperName + ']');
      }
    }

    // if object is already defined
    if (globalObjectFieldsMap.containsKey(this.ObjectApiName)) {
      // get stored fields details
      postDebug('info', 'Will load stored field definitions');
      this.objectFieldsMap = globalObjectFieldsMap.get(this.ObjectApiName);
      // TODO get stored record type details
    } else { // get fields details
      // set object fields
      postDebug('debug', 'Will retrieve field details');
      for (Schema.sObjectField sof : this.sObjType.getDescribe().fields.getMap().values()) {
        Schema.DescribeFieldResult dfr = sof.getDescribe(); // describe field
        Field objectField = new Field(); // create a Field object and populate it
        objectField.FieldName = dfr.getName().toLowerCase();
        objectField.FieldApiName = dfr.getName();
        objectField.Label = dfr.getLabel();
        objectField.Type = dfr.getType();
        objectField.Parents = dfr.getReferenceTo();
        objectField.ControllerField = dfr.getController();
        objectField.Length = dfr.getLength();
        //objectField.canHaveMultipleTypesAsParents = dfr.isNamePointing();
        //objectField.isUnique = dfr.isUnique();
        //objectField.defaultValue = dfr.getDefaultValue();
        //objectField.precision = dfr.getPrecision();
        //objectField.scale = dfr.getScale();
        //objectField.isCreateable = dfr.isCreateable();
        //objectField.isNillable = dfr.isNillable();
        //objectField.isDefaultedOnCreate = dfr.isDefaultedOnCreate();
        //objectField.isIdLookup = dfr.isIdLookup();

        // System.debug('controllerField for field [' + objectField.fieldName + ']: '
        //  + objectField.controllerField);

        // locate required fields
        if (dfr.isCreateable() && !dfr.isNillable() && !dfr.isDefaultedOnCreate()) {
          objectField.IsRequired = true;
          postDebug('fine', 'Found required field  [' + objectField.FieldApiName + ']');
        } else {
          objectField.IsRequired = false;
        }

        // if the field is picklist, get its values
        try {
          objectField.PicklistValues = dfr.getPicklistValues();
        } catch (System.exception ex) {
          objectField.PicklistValues = null;
        }

        // add field to the field map
        this.objectFieldsMap.put(objectField.FieldApiName, objectField);
      } // endelse get fields details
      
      // add object fields to global map
      globalObjectFieldsMap.put(this.ObjectApiName, this.objectFieldsMap);

      resetMilestoneTimer('Initialized settings');
    }
  }

  /* METHODS */

  /**
    * @description Adds an error message to Errors list and posts message to Debug Log
    * @param text The error reference (e.g. the field or parameter which created the error)
    * @param errorMessage The error message.
    * @return None.
    */
  private void addError(String errorId, String errorMessage) {
    this.errors.add(new Error(errorId, errorMessage));
    FObject.ProcessIsValid = false;
    postDebug('error', FAILURE_SYMBOL + ' ' + errorMessage);
  }

  /**
    * @description Adds field values to Field Values Matrix.
    * @param fieldName The API name of the field.
    * @param fieldValues The list of field values.
    * @return None.
    */
  private void addToFieldValuesMatrix(String fieldApiName, List<String> fieldValues) {
    Integer i = 0;
    for (String fld : this.fieldSet) { // for each defined field
      if (fld == fieldApiName) { // when field API name matches
        // for each value in field's value list
        for (Integer j = 0; j < this.Records; j++) {
          // append new value to existing value
          this.fieldValuesMatrix[i][j] += fieldValues[j];
        }
        break; // and then exit loop
      }
      i++;
    }
  }

  /**
    * @description Checks that a cluster type exists in a definition.
    * @param clusterType The cluster type.
    * @param definition The field definition.
    * @return TRUE if the cluster type exists in the definition.
    */
  private Boolean clusterTypeIsValid(ClusterType clusterType, Definition definition) {
    Integer countOfParameter = 0; // counts how many times a cluster parameter is found
    Integer index; // the position of a definition cluster with a specified (cluster type's) parameter

    // find how many times Parameter exists (countOfParameter) and its position (index)
    Integer i = 0;
    for (Cluster cls : definition.clusters) { // for every cluster in definition
      postDebug('finer', '...validating cluster: parameter [' + cls.Parameter +
        '] - arguments [' + cls.arguments + ']');
      if (clusterType.Parameter == cls.Parameter) { // if parameter is valid
        countOfParameter++;
        index = i;
      }
      i++;
    }
    postDebug('finer', '...count of parameter [' + clusterType.Parameter + ']: ' + countOfParameter);

    // if parameter is not found or found more than once
    if (countOfParameter != 1) {
      return false;
    }

    postDebug('finer', '...' + SUCCESS_SYMBOL + ' parameter [' + clusterType.Parameter + '] is found');

    // check if cluster value is valid
    if (valueIsValid(clusterType, definition.clusters[index], definition.FieldApiName)) {
      postDebug('finer', '...' + SUCCESS_SYMBOL + ' value is valid');
      return true;
    } else {
      postDebug('finer', '...' + FAILURE_SYMBOL + ' value is invalid');
      return false;
    }
  }

  /**
    * @description Validates a definition command.
    * @param command The definition command.
    * @return TRUE if the command is valid.
    */
  private Boolean commandIsValid(String command) {
    for (String cmd : commands) {
      if (cmd == command) {
        return true;
      }
    }
    return false;
  }

  /**
    * @description Creates the ith record.
    * @param i The number of the record.
    * @return The generated object.
    */
  private SObject createRecord(Integer i) {
    // create a new object
    SObject sObj = this.sObjType.newSObject();
    String field = '';
    Object value = null;
    String svalue = '';

    for (Integer j = 0; j < this.fieldsList.size(); j++) { // for every defined field
      // get field
      field = this.fieldsList[j];
      // get the value of the field
      value = (Object)this.fieldValuesMatrix[j][i];
      // get the type of the field
      Schema.DisplayType valueType = objectFieldsMap.get(this.fieldsList[j]).Type;
      // put value in the object
      if (value instanceof String && valueType != Schema.DisplayType.String) {
        svalue = (String)value;
        if (valueType == Schema.DisplayType.Date) // Date
          sObj.put(field, Date.valueOf(svalue));
        else if (valueType == Schema.DisplayType.Datetime) // Datetime
          sObj.put(field, Datetime.valueOfGmt(svalue));
        else if (valueType == Schema.DisplayType.Percent || // Decimal
          valueType == Schema.DisplayType.Currency)
          sObj.put(field, Decimal.valueOf(svalue));
        else if (valueType == Schema.DisplayType.Double) // Double
          sObj.put(field, Double.valueOf(svalue));
        else if (valueType == Schema.DisplayType.Integer) // Integer
          sObj.put(field, Integer.valueOf(svalue));
        else if (valueType == Schema.DisplayType.Id) // Id
          sObj.put(field, Id.valueOf(svalue));
        else if (valueType == Schema.DisplayType.Boolean) // Boolean
          sObj.put(field, Boolean.valueOf(svalue));
        else {
          sObj.put(field, svalue);
        }
      } else { // is string
        sObj.put(field, value);
      }
      //System.debug('Value type:' + valueType + ' - value:' + value);
    }
    return sObj;
  }

  /**
    * @description Creates object records using the definitions.
    * @param None.
    * @return None.
    */
  global void createRecords() {
    if (processMustTerminate()) {
      return;
    }

    // clear the list of previously created records
    this.CreatedRecords.clear();
    this.names.clear();
    this.addresses.clear();

    setDefinitionOfRequiredFields();
    validateDefinitions();

    if (processMustTerminate()) {
      return;
    }
    resetMilestoneTimer('Validated definitions');

    // initialize the Field Values Matrix (FVM)
    initializeFieldValuesMatrix();

    // initialize the defined fields list
    this.fieldsList = new List<String>(this.fieldSet);

    if (processMustTerminate()) {
      return;
    }
    postDebug('debug', 'Will populate the Field Values Matrix');

    // populate the Field Values Matrix
    for (Definition def : this.definitions) {
      List<String> fieldValues = getFieldValues(def); // get field values from definition
      
      if (!fieldValues.isEmpty()) { // if values are populated
        addToFieldValuesMatrix(def.FieldApiName, fieldValues);
        postDebug('info', SUCCESS_SYMBOL + ' Populated [' + def.FieldApiName +
          '] in definition [' + def.DefinitionString + ']');
      } else {
        postDebug('warn', FAILURE_SYMBOL + ' Did not populate [' + def.FieldApiName +
          '] in definition [' + def.DefinitionString + ']');
        //FObject.ProcessIsValid = false;
      }
    }

    if (processMustTerminate()) {
      return;
    }
    resetMilestoneTimer('Populated Field Values Matrix');

    // show the Field Values Matrix
    showFVM();

    // create records
    for (Integer i = 0; i < this.Records; i++) {
      this.CreatedRecords.add(createRecord(i)); // add created object to output list
    }

    // add records to global records map
    globalRecordsMap.put(this.ObjectApiName, this.CreatedRecords);

    resetMilestoneTimer('Created records');
  }

  /**
    * @description Validates a field definition.
    * @param definition The field definition.
    * @return TRUE if the definition is valid.
    */
  private Boolean definitionIsValid(Definition definition) {
    definition.IsValidated = true; // set definition as validated
    definition.IsValid = true;
    String definitionString = definition.DefinitionString;

    // set command and script
    String command = definitionString.substringBefore(' ');
    String script = definitionString.removeStart(command + ' ');
    command = command.trim();
    command = command.toLowerCase();
    definition.Command = command;
    script = script.trim();

    // check if command is valid
    if (!definition.IsSystemDefined && !commandIsValid(command)) {
      definition.IsValid = false;
      addError(definition.FieldApiName, 'Invalid command [' + command + '] in definition [' +
        definition.DefinitionString + ']');
      return false;
    } else {
      postDebug('fine', '   ' + SUCCESS_SYMBOL + ' command [' + command + '] is valid');
    }

    postDebug('finer', '...validating the clusters of script [' + script + ']');

    // get the clusters text and add a <space> at the end
    String remainingClustersString = script + ' ';

    // iterate through all clusters, check the validity of each parameter
    // and add each cluster to the list
    do {
      String clusterText = remainingClustersString.substringBefore(') '); // get the cluster text

      if (!definition.IsSystemDefined && clusterText == remainingClustersString) { // there is no closing parenthesis
        clusterText = clusterText.trim();
        addError(definition.FieldApiName, 'There is no closing parenthesis for cluster [' + clusterText + ']');
        definition.IsValid = false;
        return false;
      }
      // there is a closing parenthesis
      clusterText = clusterText + ')';
      // get the remaining text
      remainingClustersString = remainingClustersString.removeStart(clusterText + ' ');
      postDebug('finer', '...cluster [' + clusterText + ']' + ' remaining [' +
        remainingClustersString + ']');
      // set parameter text
      String parameter = clusterText.substringBefore('(');
      // set value text
      String value = clusterText.removeStart(parameter);
      value = value.trim();
      value = value.removeStart('(');
      value = value.removeEnd(')');
      value = value.trim();
      parameter = parameter.trim();
      parameter = parameter.toLowerCase();
      // check if everything is valid
      if (!definition.IsSystemDefined && clusterText.substringBefore('(') == clusterText) {
        addError(definition.FieldApiName, 'There is no opening parenthesis for cluster [' + clusterText + ']');
        definition.IsValid = false;
      } else if (!definition.IsSystemDefined && !parameterIsValid(parameter)) {
        addError(definition.FieldApiName, 'Invalid parameter for cluster [' + clusterText + ']');
        definition.IsValid = false;
      }
      if (!definition.isValid) {
        return false;
      }
      // add cluster to list
      definition.Clusters.add(new Cluster(parameter, value));
    } while (String.isNotEmpty(remainingClustersString));

    postDebug('finer', '...found ' + definition.Clusters.size() + ' cluster(s)');

    // set corrected definition string
    String correctedDefinitionScript = ' ';
    for (Integer i = 0; i < definition.Clusters.size(); i++) {
      correctedDefinitionScript += definition.Clusters[i].Parameter + '(' +
        definition.Clusters[i].Arguments[0] + ') ';
      postDebug('finer', '...added the cluster: parameter [' + definition.Clusters[i].Parameter +
        '] - value [' + definition.Clusters[i].Arguments[0] + ']');
    }
    definition.Script = correctedDefinitionScript.removeEnd(' ');

    // find the definition type of this definition
    DefinitionType definitionType = new DefinitionType();
    postDebug('finer', '...searching for the definition type');
    for (DefinitionType dt : definitionTypes) {
      if (definitionTypeExists(dt, definition)) {
        definition.IsValid = true;
        definition.Type = dt;
        postDebug('fine', '...found the definition type [' + dt.Id + ']');
        return true;
      }
    }

    return false; // if no valid definition type is found
  }

  /**
    * @description Checks if a definition type exists in a definition
    *   A definition type exists if a) definition type command = definition command
    *   and b) all cluster types of the definition type are found once in the definition clusters.
    * @param definitionType The definition type.
    * @param definition The definition.
    * @return TRUE if the definition type exists in the definition.
    */
  private Boolean definitionTypeExists(DefinitionType definitionType, Definition definition) {
    postDebug('finer', '...validating definition type [' + definitionType.description + ']');

    // if command is invalid, just exit
    if (definitionType.command != definition.command) {
      definition.isValid = false;
      definition.type = null;
      postDebug('finer', '   ' + FAILURE_SYMBOL + ' command is invalid');
      return false;
    }

    // assess each Cluster Type of the Definition Type
    Integer numValidClusterTypes = 0;
    for (ClusterType ct : definitionType.clusterTypes) { // for every Cluster ype
      postDebug('finer', '...validating cluster type: parameter [' + ct.parameter + '] - value [' + ct.value + ']');
      if (clusterTypeIsValid(ct, definition)) {
        numValidClusterTypes++;
      } else {
        return false;
      }
    }
    postDebug('finer', '...number of valid cluster types: ' + numValidClusterTypes);

    // if all Cluster Types are valid, Definition Type is found
    if (numValidClusterTypes == definitionType.clusterTypes.size()
        && numValidClusterTypes == definition.clusters.size()) {
      definition.isValid = true;
      definition.type = definitionType;
      return true;
    } else {
      definition.isValid = false;
      definition.type = null;
      return false;
    }
  }

  /**
    * @description Deletes all definitions of every field.
    * @param None.
    * @return None.
    */
  global void deleteAllDefinitions() {
    postDebug('info', 'Will delete all definitions of all fields');
    this.definitions.clear();
  }

  /**
    * @description Deletes all definitions of a field.
    * @param fieldName The user defined name of the field.
    * @return None.
    */
  global void deleteFieldDefinitions(String fieldName) {
    // fix field name
    fieldName = fieldName.trim();

    // get the field API name
    String fieldApiName = getFieldApiName(fieldName);

    if (String.isBlank(fieldApiName)) { // field is invalid
      addError(this.ObjectApiName, 'Invalid field [' + fieldName + ']');
      system.debug('this.ObjectApiName='+this.ObjectApiName);
    }

    if (processMustTerminate()) {
      return;
    }

    // delete field definitions
    postDebug('info', 'Will delete all definitions of field [' + fieldApiName + ']');
    Integer index = 0;
    List<Integer> indexList = new List<Integer>();
    for (Definition def : this.definitions) { // for each definition
      if (def.FieldApiName == fieldApiName) { // if field is found
        indexList.add(index); // store the index of this field
      }
      index++;
    }

    for (Integer count = indexList.size() - 1; count >= 0; count--) {
      this.definitions.remove(count); // remove definition
    }
  }

  /**
    * @description Deletes all created records of the object, using specific criteria (WHERE clause).
    * @param whereClause The WHERE clause of the SOQL query (e.g. MyField__c > 10).
    * @return None.
    */
  global Database.DeleteResult[] deleteRecords(String whereClause) {
    List<SObject> recordsToDelete = new List<SObject>();
    Set<Id> deletedRecordsSet = new Set<Id>();
    Integer numRecordsDeleted = 0;

    if (processMustTerminate()) {
      return null;
    }
    postDebug('info', 'Will delete records of object [' + this.ObjectApiName + ']');

    // set SOQL query
    String soql = 'SELECT Id FROM ' + this.ObjectApiName + ' WHERE ' + whereClause + ' LIMIT 50000';
    try { // get records
      recordsToDelete = Database.query(soql);
    } catch (QueryException ex) {
      addError(this.ObjectApiName, 'Found errors selecting records of object [' +
        this.ObjectApiName + ']: ' + ex.getMessage());
    }

    // if there are no records to delete, just exit
    if (recordsToDelete.isEmpty()) {
      return null;
    }

    //delete records
    List<Database.DeleteResult> deleteResults = Database.delete(recordsToDelete, false);

    // iterate through each returned result
    Integer recordsCount = 0;
    Integer errorsCount = 0;
    for (Database.DeleteResult dr : deleteResults) {
      recordsCount++;
      if (dr.isSuccess()) {
        // add record ID into deleted records set
        deletedRecordsSet.add(dr.getId());
        numRecordsDeleted++;
      } else { // failure
        errorsCount++;
        if (errorsCount <= MAX_ERROR_RECORDS_IN_DEBUG_LOG) {
          for (Database.Error err : dr.getErrors()) {
            addError(this.ObjectApiName , 'Found errors deleting record #' + recordsCount + ': ' +
              err.getMessage() + '. Fields that affected this error: ' + err.getFields());
          }
        }
      }
    }

    // if there are no errors, display a message
    if (numRecordsDeleted == recordsToDelete.size()) {
      postDebug('info', 'Successfully deleted ' + recordsToDelete.size() +
        ' [' + this.ObjectApiName + '] records');
    } else { // there are errors
      addError(this.ObjectApiName, 'Found ' + errorsCount +
        ' errors deleting records of object [' + this.ObjectApiName + ']');
    }

    // remove deleted records from createdRecords
    List<SObject> createdRecordsAfterDelete = new List<SObject>();
    for (SObject cr : this.CreatedRecords) {
      if (!deletedRecordsSet.contains(cr.Id)) {
        createdRecordsAfterDelete.add(cr);
      }
    }

    // amend created records list
    this.CreatedRecords = createdRecordsAfterDelete;

    // add records to global records map
    globalRecordsMap.put(this.ObjectApiName, this.CreatedRecords);

    return deleteResults;
  }

  /**
   * @description Returns a map of all definitions of every field.
   * @param None.
   * @return A list of all definitions.
   */
  global Map<String, List<String>> getAllDefinitions() {
    Map<String, List<String>> valuesMap = new Map<String, List<String>>();

    validateDefinitions();

    for (Definition def : this.definitions) { // for each definition
      String field = def.fieldApiName; // get the field name
      if (valuesMap.containsKey(field)) { // field is already in the result map
        valuesMap.get(field).add(def.definitionString);
      } else { // field is not in the Map
        valuesMap.put(field, new List<String> {def.definitionString});
      }
    }

    return valuesMap;
  }

  /**
    * @description Returns the first value item of a cluster with a specific parameter.
    * @param parameter The parameter of the cluster.
    * @param clusters The list of definition clusters.
    * @return The first value item of the cluster.
    */
  private String getClusterValue(String parameter, List<Cluster> clusters) {
    for (Cluster clr : clusters) {
      if (parameter == clr.parameter) {
        return clr.arguments[0];
      }
    }
    return null;
  }
  /**
    * @description Returns the value list of a cluster with a specific parameter.
    * @param parameter The parameter of the cluster.
    * @param clusters The list of definition clusters.
    * @return The value list of the cluster.
    */
  private List<String> getClusterValueList(String parameter, List<Cluster> clusters) {
    for (Cluster clr : clusters) {
      if (parameter == clr.parameter) {
        return clr.arguments;
      }
    }

    return null;
  }

  /**
   * @description Returns the default records of a related new FObject.
   * @param records The records of the current FObject.
   * @return The default records.
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
   * @description Returns a list of the errors found during the process
   *   of creating the records of an FObject.
   * @param None.
   * @return A map of the FObject errors, with key: the error ID and value: the error description.
   */
  global Map<String, List<String>> getErrors() {
    Map<String, List<String>> results = new Map<String, List<String>>();
    List<String> errorMessages = new List<String>();
    
    for (Error err : this.errors) {
      if (results.containsKey(err.Id)) { // the key exists
        // add a new element in the list
        results.get(err.Id).add(err.ErrorMessage);
      } else {
        // add a new element in the map
        results.put(err.id, new List<String> {err.ErrorMessage});
      }
    }

    return results;
  }

  /**
   * @description Returns the API name of a field.
   * @param fieldName The user defined field name.
   * @return The field API name if the filed name is valid or empty if it's invalid.
   */
  private String getFieldApiName(String fieldName) {
    String fieldNotFound = '';
    for (Field fld : this.objectFieldsMap.values()) {
      if (fld.FieldApiName.toLowerCase() == fieldName) { // field is valid
        return fld.FieldApiName; 
      }
    }
    return fieldNotFound;
  }

  /**
   * @description Returns a list of all definitions of a field.
   * @param fieldName The API name of the field.
   * @return A list of all definitions.
   */
  global List<String> getFieldDefinitions(String fieldApiName) {
    validateDefinitions();
    fieldApiName = fieldApiName.toLowerCase();

    List<String> values = new List<String>();
    for (Definition def : this.definitions) {
      if (def.FieldApiName.toLowerCase() == fieldApiName) {
        values.add(def.DefinitionString);
      }
    }

    return values;
  }

  /**
    * @description Returns all field values from a field definition.
    * @param None.
    * @param definition A field definition.
    * @return A list of string values.
    */
  private List<String> getFieldValues(Definition definition) {
    List<String> fieldValues = new List<String>();
    List<Cluster> clusters = definition.clusters;
    DefinitionTypeId defID = definition.Type.Id;

    postDebug('finer', 'Definition Type Id: ' + defID);

    if (defID == DefinitionTypeId.RANDOM_NUMBER) { // number
      Decimal fromArgm = Decimal.valueOf(getClusterValue('from', clusters));
      Decimal toArgm = Decimal.valueOf(getClusterValue('to', clusters));
      Integer scaleArgm = Integer.valueOf(getClusterValue('scale', clusters));
      fieldValues = getRandomNumbers(fromArgm, toArgm, scaleArgm, definition);
    } else if (defID == DefinitionTypeId.RANDOM_DATE) { // date
      Date fromArgm = Date.valueOf(getClusterValue('from', clusters));
      Date toArgm = Date.valueOf(getClusterValue('to', clusters));
      fieldValues = getRandomDates(fromArgm, toArgm, definition);
    } else if (defID == DefinitionTypeId.RANDOM_DATETIME) { // datetime
      Datetime fromArgm = Date.valueOf(getClusterValue('from', clusters));
      Datetime toArgm = Date.valueOf(getClusterValue('to', clusters));
      fieldValues = getRandomDatetimes(fromArgm, toArgm, definition);
    } else if (defID == DefinitionTypeId.RANDOM_PICKLIST) { // pick list
      fieldValues = getRandomPicklistItems(definition.fieldApiName);
    } else if (defID == DefinitionTypeId.RANDOM_PICKLISTEXCEPT) { // pick list except
      Set<String> exceptions = new Set<String>(getClusterValueList('except', clusters));
      fieldValues = getRandomPicklistItemsExcept(definition.fieldApiName, exceptions);
    } else if (defID == DefinitionTypeId.RANDOM_LIST) { // list
      fieldValues = getRandomListItems(definition);
    } else if (defID == DefinitionTypeId.RANDOM_EMAIL) { // email
      fieldValues = getRandomEmails(definition);
    } else if (defID == DefinitionTypeId.RANDOM_URL) { // URL
      fieldValues = getRandomUrls();
    } else if (defID == DefinitionTypeId.RANDOM_BOOLEAN) { // boolean
      fieldValues = getRandomBooleans();
    } else if (defID == DefinitionTypeId.RANDOM_FIRSTNAME) { // first name
      String nameGroup = getClusterValue('group', clusters);
      fieldValues = getRandomFirstNames(nameGroup);
    } else if (defID == DefinitionTypeId.RANDOM_LASTNAME) { // last name
      String nameGroup = getClusterValue('group', clusters);
      fieldValues = getRandomLastNames(nameGroup);
    } else if (defID == DefinitionTypeId.RANDOM_STREET) { // street
      String addressGroup = getClusterValue('group', clusters);
      fieldValues = getRandomStreets(addressGroup);
    } else if (defID == DefinitionTypeId.RANDOM_POSTALCODE) { // postal code
      String addressGroup = getClusterValue('group', clusters);
      fieldValues = getRandomPostalCodes(addressGroup);
    } else if (defID == DefinitionTypeId.RANDOM_CITY) { // city
      String addressGroup = getClusterValue('group', clusters);
      fieldValues = getRandomCities(addressGroup);
    } else if (defID == DefinitionTypeId.RANDOM_STATE) { // state
      String addressGroup = getClusterValue('group', clusters);
      fieldValues = getRandomStates(addressGroup);
    } else if (defID == DefinitionTypeId.RANDOM_COUNTRY) { // country
      String addressGroup = getClusterValue('group', clusters);
      fieldValues = getRandomCountries(addressGroup);
    } else if (defID == DefinitionTypeId.RANDOM_STRING) { // string
      Integer minlength = Integer.valueOf(getClusterValue('minlength', clusters));
      Integer maxlength = Integer.valueOf(getClusterValue('maxlength', clusters));
      String startsWith = getClusterValue('startwith', clusters);
      List<String> includes = getClusterValueList('include', clusters);
      fieldValues = getRandomStrings(
        minlength, maxlength, startsWith, includes, definition);
    } else if (defID == DefinitionTypeId.RANDOM_TEXT) { // text
      Integer minLength = Integer.valueOf(getClusterValue('minlength', clusters));
      Integer maxLength = Integer.valueOf(getClusterValue('maxlength', clusters));
      fieldValues = getRandomTexts(minLength, maxLength, definition.DefinitionString);
    } else if (defID == DefinitionTypeId.RANDOM_LOOKUP) { // random lookup
      String source = getClusterValue('source', clusters);
      String lookupObject = getClusterValue('lookup', clusters);
      String lookupField = getClusterValue('field', clusters);
      List<String> lookupValues = getClusterValueList('value', clusters);
      List<String> lookupExceptValues = getClusterValueList('except', clusters);
      fieldValues = getLookupItems(
        'random', source, lookupObject, lookupField, lookupValues, lookupExceptValues, definition.FieldApiName);
    } else if (defID == DefinitionTypeId.STATIC_LOOKUP) { // static lookup
      String source = getClusterValue('source', clusters);
      String lookupObject = getClusterValue('lookup', clusters);
      String lookupField = getClusterValue('field', clusters);
      List<String> lookupValues = getClusterValueList('value', clusters);
      fieldValues = getLookupItems('static', source, lookupObject, lookupField, lookupValues, null, definition.FieldApiName);
    } else if (defID == DefinitionTypeId.SERIAL_DECIMAL) { // serial
      // get the first value item of the cluster containing parameter 'from'
      // and convert it to long
      Decimal fromArgm = Decimal.valueOf(getClusterValue('from', clusters));
      // do the same for parameter 'step'
      Decimal stepArgm = Decimal.valueOf(getClusterValue('step', clusters));
      // do the same for parameter 'scale'
      Integer scaleArgm = Integer.valueOf(getClusterValue('scale', clusters));
      // create serial values
      fieldValues = getSerialNumbers(fromArgm, stepArgm, scaleArgm);
    } else if (defID == DefinitionTypeId.STATIC_STRING) { // static
      String label = getClusterValue('value', clusters);
      fieldValues = getLabels(definition.FieldApiName, label);
    } else {
      addError(this.ObjectApiName, 'Unknown Definition Type for definition [' +
        definition.DefinitionString + ']: System Error');
      fieldValues = null;
    }

    return fieldValues;
  }

  /**
    * @description Returns a list of static text.
    * @param fieldName The API name of a field.
    * @param label The static text of the field values.
    * @return A list of string values.
    */
  private List<String> getLabels(String fieldApiName, String label) {
    List<String> values = new List<String>();

    // manage record types
    if (fieldApiName == 'RecordTypeId') {
      // get the Id of this record type
      Id recordTypeId = this.recordTypesMap.get(label);
      // if record type does not exist
      if (recordTypeId == null) {
        // set an error and empty label
        addError(fieldApiName, 'Invalid record type [' + label + ']');
        label = '';
      } else { // record type is valid
        label = recordTypeId;
      }
    }

    for (Integer i = 0; i < this.Records; i++) {
      values.add(label);
    }

    return values;
  }

  /**
    * @description Creates an ID list of random lookup object's records.
    * @param type The lookup type: random or static.
    * @param source The source (forceea or salesforce) of the lookup object.
    * @param lookupObject The API name of the lookup object.
    * @param lookupField The API name of the lookup field.
    * @param lookupValues The list of lookup values.
    * @param lookupExcept The list of exception lookup values.
    * @return A list of ID values.
    */
  private List<Id> getLookupItems(String type, String source, String lookupObject,
      String lookupField, List<String> lookupValues, List<String> lookupExcept, String fieldApiName) {
    List<Id> values = new List<Id>(); // the output values
    List<SObject> lookupRecords = new List<SObject>(); // the lookup object's records
    List<Database.SaveResult> saveResults = new List<Database.SaveResult>();

    // clear lookup Object
    lookupObject = lookupObject.trim();
    lookupObject = lookupObject.toLowerCase();

    // check if object is valid
    String lookupObjectApiName = getObjectApiName(lookupObject);

    if (String.isBlank(lookupObjectApiName)) { // lookup object is invalid
      addError(lookupObject, 'Invalid lookup object [' + lookupObject + ']');
    }

    if (processMustTerminate()) {
      return null;
    }

    if (source == 'forceea') {
      // check if object is defined
      Boolean objectIsDefined = false;
      for (String obj : FObject.objects) {
        if (obj == lookupObjectApiName) {
          objectIsDefined = true;
          break;
        }
      }
      if (objectIsDefined) { // if object exists
        // get the list of created records
        lookupRecords = globalRecordsMap.get(lookupObjectApiName);
      } else { // create the object
        postDebug('warn', 'Object [' + lookupObjectApiName + '] is not defined internally');
        FObject newSObject = new FObject(lookupObjectApiName);
        newSObject.SetRequiredFields = true;
        // set records
        newSObject.records = getDefaultRecords(this.Records);
        // set lookup field's definition
        if (lookupField != null) {
          Field fld = objectFieldsMap.get(lookupField);
          setDefinitionFromField(fld);
        }
        // insert records
        saveResults = newSObject.insertRecords();
        // get lookupRecords - otherwise get nothing
        lookupRecords = newSObject.getRecords();
      }
    } // endif source == 'forceea'

    if ((lookupRecords.isEmpty()) || (source == 'salesforce')) {
      String soql = 'SELECT Id';
      // set soql if there is a lookup field
      if (!String.isBlank(lookupField)) {
        soql += ', ' + lookupField;
      }
      soql += ' FROM ' + lookupObjectApiName + ' LIMIT 50000';
      //query the database and get the IDs
      try {
        lookupRecords = Database.query(soql);
      } catch (QueryException ex) {
        addError(fieldApiName, 'Found errors selecting records from the lookup object [' + lookupObjectApiName +
         '] of object [' + this.ObjectApiName + ']: ' + ex.getMessage());
      }
      //for (SObject obj : lookupRecords) {
      //  postDebug('info', 'lookup records: ' + obj.Id + ', ' + obj.get('Name'));
      //}
    }

    if (type == 'static') {
      Id lookupId;
      for (SObject sobj : lookupRecords) { // for each record
        // if lookup field value is found
        if (sobj.get(lookupField) == lookupValues[0]) {
          lookupId = sobj.Id; // get record Id
          break;
        }
      }
      for (Integer i = 0; i < this.Records; i++) { // get the values
        values.add(lookupId); // add the Id to the output list
      }
    } else if (type == 'random') {
      List<Id> lookupIds = new List<Id>();
      if ((lookupValues == null) && (lookupExcept == null)) {
        // SDDL: random lookup() source()
        for (SObject sobj : lookupRecords) {
          lookupIds.add(sobj.Id); //add ID to the list
        }
      } else if ((lookupValues != null) && (lookupExcept == null)) {
        // SDDL: random lookup() field() value() source()
        for (String str : lookupValues) { // for each lookup value
          for (SObject sobj : lookupRecords) { // for each record
            if (sobj.get(lookupField) == str) { // if value is found
              lookupIds.add(sobj.Id); // add ID to the list
            }
          }
        }
      } else if ((lookupValues == null) && (lookupExcept != null)) {
        // SDDL: random lookup() field() except() source()
        for (String str : lookupExcept) { // for each exception value
          for (SObject sobj : lookupRecords) { // for each record
            if (sobj.get(lookupField) != str) { // if exception value is not found
              lookupIds.add(sobj.Id); // add ID to the list
            }
          }
        }
      } else {
        addError(lookupField, 'Invalid Lookup Type: System Error');
      }

      // get the values
      Integer count = lookupIds.size();
      for (Integer i = 0; i < this.Records; i++) {
        // get a random position
        Integer v = (Math.random() * count).intValue();
        // add the ID to the output list
        values.add(lookupIds[v]);
      }
    } // endif type == 'random'

    return values;
  }

  /**
   * @description Returns the API name of an object.
   * @param objectName The user defined name of an object.
   * @return The API name is the object or an empty string ('') if the name is invalid.
   */
  private String getObjectApiName(string objectName) {
    String result = '';
    objectName = objectName.toLowerCase();

    for (String objectApiName : salesforceObjectsApiName) {
      if (objectApiName.toLowerCase() == objectName) { // object is found
        return objectApiName;
      }
    }

    return result;
  }

 /**
   * @description Returns a list of random addresses
   *  having street (with number), postal code, city, state and country.
   * @param None.
   * @return A list of FAddress objects.
   */
  private List<FAddress> getRandomAddresses() {
    List<FAddress> values = new List<FAddress>();
    Integer v = 0; // a random value

    loadAddresses();
    Integer librarySize = addressesLibrary.size();

    // get values
    for (Integer i = 0; i < this.Records; i++) {
      v = (Math.random() * librarySize).intValue();
      values.add(new FAddress(addressesLibrary[v]));
    }

    return values;
  }

  /**
    * @description @description Returns a list of random booleans.
    * @param None.
    * @return A list of string (TRUE, FALSE) values.
    */
  private List<String> getRandomBooleans() {
    List<String> values = new List<String>();

    for (Integer i = 0; i < this.Records; i++) {
      if (Math.random() > 0.5) {
        values.add('true');
      } else {
        values.add('false');
      }
    }

    return values;
  }

 /**
   * @description Returns a list of random cities.
   * @param addressGroup The group of this address.
   * @return A list of string (cities) values.
   */
  private List<String> getRandomCities(String addressGroup) {
    List<String> values = new List<String>();

    // create addresses if needed
    List<FAddress> groupAddresses = this.addresses.get(addressGroup);
    if (groupAddresses == null || groupAddresses.isEmpty()) {
      // set random addresses
      this.addresses.put(addressGroup, getRandomAddresses());
      // get created addresses
      groupAddresses = this.addresses.get(addressGroup);
    }

    // get values
    for (Integer i = 0; i < this.Records; i++) {
      values.add(groupAddresses[i].City);
    }

    return values;
  }

  /**
   * @description Returns a list of random addresses.
   * @param addressGroup The group of this address.
   * @return A list of string (first name) values.
   */
  private List<String> getRandomCountries(String addressGroup) {
    List<String> values = new List<String>();

    // create addresses if needed
    List<FAddress> groupAddresses = this.addresses.get(addressGroup);
    if (groupAddresses == null || groupAddresses.isEmpty()) {
      // set random addresses
      this.addresses.put(addressGroup, getRandomAddresses());
      // get created addresses
      groupAddresses = this.addresses.get(addressGroup);
    }

    // get values
    for (Integer i = 0; i < this.Records; i++) {
      values.add(groupAddresses[i].Country);
    }

    return values;
  }

  /**
    * @description Returns a list of random date values.
    * @param fromDate The minimum date.
    * @param toDate The maximum date.
    * @return A list of string date values.
    */
  private List<String> getRandomDates(Date fromDate, Date toDate, Definition definition) {
    List<String> values = new List<String>();
    
    // check arguments
    if (fromDate >= toDate) {
      addError(definition.FieldApiName, 'The [from] date is greater than or equal to ' +
        'the [to] date in definition [' + definition.DefinitionString + ']');
      return values;
    }

    Integer range = fromDate.daysBetween(toDate) + 1;
    Integer days = 0; // the number of days to add to fromDate
    for (Integer i = 0; i < this.Records; i++) {
      days = (Math.random() * range).intValue();
      values.add(String.valueOf(fromDate.addDays(days)));
    }

    return values;
  }

  /**
    * @description Returns a list of random datetime values.
    * @param fromDate The minimum datetime.
    * @param toDate The maximum datetime.
    * @return A list of string datetime values.
    */
  private List<String> getRandomDatetimes(Datetime fromDatetime, Datetime toDatetime, Definition definition) {
    List<String> values = new List<String>();
    Long fromDatetimePoint = fromDatetime.getTime(); // ms from 1/1/1970
    Long toDatetimePoint = 0; // ms from 1/1/1970

    if (toDatetime.hour() == 0 && toDatetime.minute() == 0 && toDatetime.second() == 0 ) {
      toDatetime = toDatetime.addSeconds(86399); // add: 24h - 1s
      toDatetimePoint = toDatetime.getTime();
    } else {
      toDatetimePoint = toDatetime.getTime();
    }

    // check arguments
    if (fromDatetimePoint > toDatetimePoint) {
      addError(definition.FieldApiName, 'The [from] date is greater than ' +
        'the [to] date in definition [' + definition.DefinitionString + ']');
      return values;
    }

    //System.debug('fromDatetime: ' + fromDatetime);
    //System.debug('toDatetime: ' + toDatetime);

    Long range = toDatetimePoint - fromDatetimePoint;
    Long randomPoint; // a random value in ms
    for (Integer i = 0; i < this.Records; i++) {
      randomPoint = fromDatetimePoint + (Math.random() * range).longValue();
      values.add(String.valueOf(Datetime.newInstance(randomPoint)));
    }

    return values;
  }

  /**
    * @description Returns a list of random decimals.
    * @param fromNumber The minimum decimal.
    * @param toNumber The maximum decimal.
    * @param scale The number of decimal places.
    * @return A list of string (decimal) values.
    */
  private List<String> getRandomNumbers(Decimal fromNumber, Decimal toNumber, Integer scale,
      Definition definition) {
    List<String> values = new List<String>();
    fromNumber = fromNumber.setScale(scale);
    toNumber = toNumber.setScale(scale);

    // check arguments
    if (fromNumber >= toNumber) {
      addError(definition.FieldApiName, 'The [from] number is greater than or equal to ' +
        'the [to] number in definition [' + definition.DefinitionString + ']');
    }

    Decimal range = toNumber - fromNumber;
    Decimal val = 0;
    for (Integer i = 0; i < this.Records; i++) {
      val = fromNumber + Math.random() * range;
      values.add(val.setScale(scale).toPlainString());
    }

    return values;
  }

  /**
    * @description Returns a list of random domains.
    * @param syllables The number of syllables(musical notes) the domain consists of.
    * @return A list of string (domain) values.
    */
  @TestVisible
  private List<String> getRandomDomains(Integer syllables) {
    List<String> values = new List<String>();
    List<String> notes = new List<String> {'do', 're', 'mi', 'fa', 'sol', 'la', 'si'};

    // manage negative syllables
    if (syllables <= 0) {
      syllables = 1;
    }

    for (Integer i = 0; i < this.Records; i++) {
      String domain = '';
      // create domain
      for (Integer j = 0; j < syllables; j++) {
        Integer v = (Math.random() * 7).intValue();
        domain += notes[v];
      }
      values.add(domain + '.com');
    }

    return values;
  }

  /**
    * @description Returns a list of random emails.
    * @param None.
    * @return A list of string (domain) values.
    */
  private List<String> getRandomEmails(Definition definition) {
    List<String> values = new List<String>();
    List<String> includes = new List<String> { 'lower' };
    List<String> names = getRandomStrings(10, 10, 'lower', includes, definition);
    List<String> domains = getRandomDomains(5);

    for (Integer i = 0; i < this.Records; i++) {
      values.add(names[i] + '@' + domains[i]);
    }

    return values;
  }

  /**
   * @description Returns a list of random first names.
   * @param nameGroup The group of this name.
   * @return A list of string (first name) values.
   */
  private List<String> getRandomFirstNames(String nameGroup) {
    List<String> values = new List<String>();

    if (this.names.get(nameGroup) == null) { // there are no created names for this group
      this.names.put(nameGroup, getRandomNames()); // create names
    }

    List<Name> groupNames = this.names.get(nameGroup); // get the first names for the group

    // get the first names
    for (Integer i = 0; i < this.Records; i++) {
      values.add(groupNames[i].FirstName);
    }

    return values;
  }

  /**
   * @description Returns a list of random last names.
   * @param nameGroup The group of this name.
   * @return A list of string (last name) values.
   */
  private List<String> getRandomLastNames(String nameGroup) {
    List<String> values = new List<String>();

    if (this.names.get(nameGroup) == null) { // there are no created names for this group
      this.names.put(nameGroup, getRandomNames()); // create names
    }

    List<Name> groupNames = this.names.get(nameGroup); // get the first names for the group

    // get the last names
    for (Integer i = 0; i < this.Records; i++) {
      values.add(groupNames[i].LastName);
    }

    return values;
  }

  /**
    * @description returns a list of random field values from a list.
    * @param definition The definition.
    * @return a list of (string) values.
    */
  private List<String> getRandomListItems(Definition definition) {
    // get list items
    List<String> listItems = getClusterValueList('value', definition.clusters);

    // get the size of the items list
    Integer count = listItems.size();

    // get the values
    List<String> values = new List<String>();
    Integer v = 0;
    for (Integer i = 0; i < this.Records; i++) {
      v = (Math.random() * count).intValue();
      values.add(listItems[v]);
    }

    return values;
  }

 /**
   * @description Returns a list of random names.
   * @param None.
   * @return A list of Name objects.
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

    loadNames();
    Integer numGroups = lastNamesLibrary.size(); // the nuber of groups

    // get the size of each locality/gender group
    Integer groupSize = this.Records / numGroups;

    for (String key : lastNamesLibrary.keySet()) { // for each group
      // get the data (first & last name lists)
      List<String> firstNames = firstNamesLibrary.get(key);
      List<String> lastNames = lastNamesLibrary.get(key);
      // get the size of lists
      firstNamesSize = firstNames.size();
      lastNamesSize = lastNames.size();
      // get gender
      gender = key;
      // check if this is the last group
      counterGroups++;
      if (counterGroups == numGroups) {
        groupSize = this.Records - counterNames;
      } else {
        counterNames += groupSize;
      }
      // get values
      for (Integer i = 0; i < groupSize; i++) {
        vFirst = (Math.random() * firstNamesSize).intValue();
        firstName = firstNames[vFirst];
        vLast = (Math.random() * lastNamesSize).intValue();
        lastName = lastNames[vLast];
        values.add(new Name(firstName, lastName, gender));
      }
    }

    // randomize names
    Integer v = 0;
    Name temp = new Name();
    Integer size = values.size();
    for (Integer i = 0; i < size; i++) {
      v = (Math.random() * size).intValue(); // get a random index
      temp = values[i] ;
      values[i] = values[v];
      values[v] = temp;
    }

    return values;
  }

  /**
    * @description Returns a list of random picklist items.
    * @param fieldName The API name of a field.
    * @return A list of string (picklist item) values.
    */
  private List<String> getRandomPicklistItems(String fieldApiName) {
    List<String> picklistItems = new List<String>(); // the picklist items
    List<String> values = new List<String>(); // the output values

    if (fieldApiName == 'RecordTypeId') { // manage record type
      // create a new list with object's record type values
      List<Id> recordTypeIDs = new List<Id>(this.recordTypesMap.values());
      // count how many record types exist
      Integer count = recordTypeIDs.size();
      // get the random record type IDs
      Integer v = 0;
      for (Integer i = 0; i < this.Records; i++) {
        v = (Math.random() * count).intValue();
        values.add(recordTypeIDs.get(v));
      }
      return values;
    }

    // if the field is not a record type, get the picklist items
    List<Schema.PicklistEntry> picklistValues = this.objectFieldsMap.get(fieldApiName).pickListValues;
    for (Schema.PicklistEntry ple : picklistValues) {
      picklistItems.add(ple.getLabel());
    }

    // get the values
    Integer count = picklistItems.size();
    Integer v = 0;
    for (Integer i = 0; i < this.Records; i++) {
      v = (Math.random() * count).intValue();
      values.add(picklistItems[v]);
    }

    return values;
  }

  /**
    * @description Returns a list of random picklist items excluding specific items.
    * @param fieldName The API name of a field.
    * @param exceptions A list of exceptions from the picklist items.
    * @return A list of string (picklist item) values.
    */
  private List<String> getRandomPicklistItemsExcept(String fieldApiName, Set<string> exceptions) {
    List<String> picklistItems = new List<String>(); // the picklist items
    List<String> values = new List<String>(); // the output values
    Integer v = 0;

    if (fieldApiName == 'RecordTypeId') { // manage record type
      // create a new list with record type values, excluding exceptions
      List<Id> recordTypeIDs = new List<Id>();
      for (String rt : this.recordTypesMap.keySet()) {
        for (String ex : exceptions) {
          if (rt == ex) {
            recordTypeIDs.add(this.recordTypesMap.get(ex));
          }
        }
      }
      // count how many record types exist
      Integer count = recordTypeIDs.size();
      // get the random record type IDs
      v = 0;
      for (Integer i = 0; i < this.Records; i++) {
        v = (Math.random() * count).intValue();
        values.add(recordTypeIDs.get(v));
      }
      return values;
    }

    // if the field is not a record type, get the picklist items
    List<Schema.PicklistEntry> picklistValues = this.objectFieldsMap.get(fieldApiName).pickListValues;
    String label = '';
    for (Schema.PicklistEntry ple : picklistValues) {
      label = ple.getLabel();
      if (!exceptions.contains(label)) { // exclude exceptions
        picklistItems.add(label);
      }
    }

    // get values
    Integer count = picklistItems.size();
    for (Integer i = 0; i < this.Records; i++) {
      v = (Math.random() * count).intValue();
      values.add(picklistItems[v]);
    }

    return values;
  }

  /**
   * @description Returns a list of random Postal Codes.
  * @param addressGroup The group of this address.
   * @return A list of string (Postal Code) values.
   */
  private List<String> getRandomPostalCodes(String addressGroup) {
    List<String> values = new List<String>();

    // create addresses if needed
    List<FAddress> groupAddresses = this.addresses.get(addressGroup);
    if (groupAddresses == null || groupAddresses.isEmpty()) {
      // set random addresses
      this.addresses.put(addressGroup, getRandomAddresses());
      // get created addresses
      groupAddresses = this.addresses.get(addressGroup);
    }

    // get values
    for (Integer i = 0; i < this.Records; i++) {
      values.add(groupAddresses[i].PostalCode);
    }

    return values;
  }

  /**
   * @description Returns a list of random states.
   * @param addressGroup The group of this address.
   * @return A list of string (states) values.
   */
  private List<String> getRandomStates(String addressGroup) {
    List<String> values = new List<String>();

    // create addresses if needed
    List<FAddress> groupAddresses = this.addresses.get(addressGroup);
    if (groupAddresses == null || groupAddresses.isEmpty()) {
      // set random addresses
      this.addresses.put(addressGroup, getRandomAddresses());
      // get created addresses
      groupAddresses = this.addresses.get(addressGroup);
    }

    // get values
    for (Integer i = 0; i < this.Records; i++) {
      values.add(groupAddresses[i].State);
    }

    return values;
  }

 /**
  * @description Returns a list of random streets.
  * @param addressGroup The group of this address.
  * @return A list of string (streets) values.
  */
  private List<String> getRandomStreets(String addressGroup) {
    List<String> values = new List<String>();

    // create addresses if needed
    List<FAddress> groupAddresses = this.addresses.get(addressGroup);
    if (groupAddresses == null || groupAddresses.isEmpty()) {
      // set random addresses
      this.addresses.put(addressGroup, getRandomAddresses());
      // get created addresses
      groupAddresses = this.addresses.get(addressGroup);
    }

    Integer v = 0;
    String street = '';

    // get values
    for (Integer i = 0; i < this.Records; i++) {
      street = groupAddresses[i].Street;
      v = (Math.random() * 20).intValue() + 1; // get a random number from 1 to 20
      if (FObject.StreetNumberAfterStreet) { // number is after street
        street = street + ' ' + String.valueOf(v);
      } else { // // number is before street
        street = String.valueOf(v) + ' ' + street;
      }
      values.add(street);
    }

    return values;
  }

  /**
   * @description Returns a list of random strings.
   * @param minlength The minimum length of the string values.
   * @param maxlength The maximum length of the string values.
   * @param startsWith The type of the first character (upper/lower/digit).
   * @param includes The types of characters in the string (upper/lower/digit).
   * @return A list of string values.
   */
  private List<String> getRandomStrings(
      Integer minlength, Integer maxlength,
      String startsWith, List<String> includes, Definition definition) {
    List<String> values = new List<String>(); // the output values
    String lowerChars = 'abcdefghijklmnopqrstuvwxyz';
    String upperChars = 'ABCDEFGHIJKLMNOPQRSUVWXYZ';
    String digits = '0123456789';
    String charsToSelect = ''; // the selection chars for the rest of the string
    String firstCharString = ''; // the first char of the string
    String restChars; // the rest chars of the string
    Integer count; // the size of a string

    // check arguments
    if (minLength > maxLength) {
      addError(definition.FieldApiName, 'The minimum length is greater than ' +
        'the maximum length in definition [' + definition + ']');
    }

    // define chars
    for (String ch : includes) {
      if (ch == 'lower') {
        charsToSelect += lowerChars;
      } else if (ch == 'upper') {
        charsToSelect += upperChars;
      } else if (ch == 'digit') {
        charsToSelect += digits;
      }
    }

    // get the values
    Integer v = 0; // a random position
    Integer resultLength = 0; // the random length of each string
    String firstChar = '';
    for (Integer i = 0; i < this.Records; i++) {
      resultLength = minlength + (Math.random() * (maxlength - minlength + 1)).intValue();
      // get 1st char
      if (startsWith == 'lower') {
        firstCharString = lowerChars;
      } else if (startsWith == 'upper') {
        firstCharString = upperChars;
      } else if (startsWith == 'digit') {
        firstCharString = digits;
      }

      count = firstCharString.length();
      v = (Math.random() * count).intValue();
      firstChar = firstCharString.substring(v, v + 1);
      // get the rest
      count = charsToSelect.length();
      restChars = '';
      for (Integer j = 1; j < resultLength; j++) {
        v = (Math.random() * count).intValue();
        restChars += charsToSelect.substring(v, v + 1);
      }
      values.add(firstChar + restChars);
    }

    return values;
  }

  /**
   * @description Returns a list of random texts.
   * @param minLength The length of the text.
   * @param maxLength The length of the text.
   * @param definition The definition of random type(text) script.
   * @return A list of string (text) values.
   */
  private List<String> getRandomTexts(Integer minLength, Integer maxLength, String definition) {
    List<String> values = new List<String>();
    List<String> words = new List<String> {
      'lorem', 'ipsum', 'dolor', 'sit', 'amet', 'tempor', 'aboreant', 'instructor', 'eu',
      'nos', 'quo', 'magna', 'primis', 'labore', 'usi', 'virtute', 'fabellas', 'vis', 'duis',
      'scripta', 'salutandi', 'laudem', 'commune', 'nam', 'laoreet', 'propriae', 'corrumpit',
      'ea', 'partem', 'inermis', 'conclusion', 'ius', 'sint', 'impedit',
      'deterruis', 'eam', 'elit', 'nusquam'
    };
    Integer numWords = words.size();
    Integer v = 0;
    Integer resultLength = 0;
    String result = '';
    String previousWord = '';
    String selectedWord = '';

    // check arguments
    if (minLength >= maxLength) {
      addError('random type(text)', 'The minimum length should be less than the maximum length ' +
        'in definition [' + definition + ']');
    } else if (maxLength - minLength < 10) { // increase the difference, if it's less than 10
      maxLength = minLength + 10;
    } 

    // get the values
    for (Integer i = 0; i < this.Records; i++) {
      result = '';
      resultLength = 0;
      do {
        v = (Math.random() * numWords).intValue();
        selectedWord = words[v]; // get the new word
        if (previousWord != selectedWord) { // if it's different from the previous word
          result += selectedWord + ' ';
          resultLength = result.length();
        }
      } while (resultLength < minLength + 1);

      // capitalize text and add it to the output list
      result = result.trim();
      values.add(result.capitalize());
    }

    return values;
  }

  /**
   * @description Returns a list of random URLs.
   * @param None.
   * @return A list of string (text) values.
   */
  @TestVisible
  private List<String> getRandomUrls() {
    List<String> values = new List<String>();
    List<String> domains = getRandomDomains(5);

    // get the values
    for (Integer i = 0; i < this.Records; i++) {
      values.add('http://www.' + domains[i]);
    }

    return values;
  }

  /**
    * @description Returns a list of objects.
    * @param None.
    * @return A list of objects.
    */
  global List<SObject> getRecords() {
    // if no records have been created, then create them
    if (this.CreatedRecords.isEmpty()) {
      createRecords();
    }

    if (FObject.ProcessIsValid) {
      return this.CreatedRecords;
    } else {
      return null;
    }
  }

  /**
    * @description Returns a list of serial decimals.
    * @param fromNumber The minimum decimal.
    * @param stepNumber The value added to previous decimal value.
    * @param scale The number of decimal places.
    * @return A list of string (decimal) values.
    */
  private List<String> getSerialNumbers(Decimal fromNumber, Decimal stepNumber, Integer scale) {
    List<String> values = new List<String>();

    // get the values
    Decimal val = fromNumber;
    for (Integer i = 0; i < this.Records; i++) {
      values.add(val.setScale(scale).toPlainString());
      val += stepNumber;
    }

    return values;
  }

  /**
    * @description Initializes the Field Values Matrix (FVM).
    * @param None.
    * @return None.
    */
  private void initializeFieldValuesMatrix() {
    this.fieldValuesMatrix.clear();
    for (Integer i = 0; i < this.fieldSet.size(); i++) {
      this.fieldValuesMatrix.add(new List<String>());
      for (Integer j = 0; j < this.Records; j++) {
        this.fieldValuesMatrix[i].add('');
      }
    }
  }

  /**
    * @description Inserts the created object records.
    * @param None.
    * @return A list of Database.SaveResult.
    */
  global List<Database.SaveResult> insertRecords() {
    List<Database.SaveResult> saveResults = new List<Database.SaveResult>();
    Integer numRecordsInserted = 0;

    if (processMustTerminate()) {
      return null;
    }

    // create records, if the haven't been created
    if (this.CreatedRecords.isEmpty()) {
      createRecords();
    }

    if (processMustTerminate()) {
      return null;
    }

    // do not allow inserting records of User object
    if (!Test.isRunningTest() && (this.ObjectApiName == 'User')) {
      postDebug('warn', 'Will not insert records for object [' + this.ObjectName + ']');
      return null;
    }

    // insert records
    postDebug('debug', 'Will insert the created records of object [' + this.ObjectApiName + ']');
    saveResults = Database.insert(this.CreatedRecords, false);

    // iterate through each returned result
    Integer recordsCount = 0;
    Integer errorsCount = 0;
    for (Database.SaveResult sr : saveResults) {
      recordsCount++;
      if (sr.isSuccess()) {
        // TODO: add record ID into deleted records set
        numRecordsInserted++;
      } else { // failure
        errorsCount++;
        if (errorsCount <= MAX_ERROR_RECORDS_IN_DEBUG_LOG) {
          for (Database.Error err : sr.getErrors()) {
            addError(this.ObjectApiName, 'Found errors inserting record #' + recordsCount + ': ' +
              err.getMessage() + '. Fields that affected this error: ' + err.getFields());
          }
        }
      }
    }

    // if there are no errors, display a message
    if (numRecordsInserted == this.CreatedRecords.size()) {
      resetMilestoneTimer('Inserted ' + this.CreatedRecords.size() + ' records');
    } else { // there are errors
      addError(this.ObjectApiName, 'Found ' + errorsCount + ' errors inserting ' +
        this.CreatedRecords.size() + ' records of object [' + this.ObjectApiName + ']');
    }

    return saveResults;
  }

 /**
   * @description The main method for loading addresses.
   * @param None.
   * @return None.
   */
  private static void loadAddresses() {
    FObject.Language = FObject.Language.toLowerCase();
    FObject.Locality = FObject.Locality.toLowerCase();

    if (FObject.Locality == 'italy' && FObject.Language == 'italian') {
      // loadAddressesFromItalyInItalian();
    } else if (FObject.Locality == 'france' && FObject.Language == 'french') {
      // loadAddressesFromFranceInFrench();
    } else if (FObject.Locality == 'spain'&& FObject.Language == 'spanish') {
      // loadAddressesFromSpainInSpanish();
    } else if (FObject.Locality == 'greece' && FObject.Language == 'greek') {
      loadAddressesFromGreeceInGreek();
    } else if (FObject.Locality == 'ireland' && FObject.Language == 'english') {
      // loadAddressesFromIrelandInEnglish();
    } else if (FObject.Locality == 'england' && FObject.Language == 'english') {
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
    if (!addressesLibrary.isEmpty()) {
      return;
    }

    FObject.StreetNumberAfterStreet = true;
    String country = 'Ελλάδα';

    // add data
    addressesLibrary.add(new FAddress('Σοφοκλέους', '10235', 'Αθήνα', '', country));
    addressesLibrary.add(new FAddress('Βασιλέως Κωνσταντίνου ', '15122', 'Αθήνα', '', country));
    addressesLibrary.add(new FAddress('Βησσαρίωνος ', '10672', 'Αθήνα', '', country));
    addressesLibrary.add(new FAddress('Ερμού ', '10551', 'Αθήνα', '', country));
    addressesLibrary.add(new FAddress('Ακαδημίας ', '10671', 'Αθήνα', '', country));
    addressesLibrary.add(new FAddress('Στουρνάρα', '10432', 'Αθήνα', '', country));
    addressesLibrary.add(new FAddress('Λεβίδου ', '14562', 'Κηφισιά', '', country));
    addressesLibrary.add(new FAddress('Κολοκοτρώνη ', '14562', 'Κηφισιά', '', country));
    addressesLibrary.add(new FAddress('Ιλισίων ', '14564', 'Κηφισιά', '', country));
    addressesLibrary.add(new FAddress('Σποράδων ', '11361', 'Αθήνα', '', country));
    addressesLibrary.add(new FAddress('Ηρώων Πολυτεχνείου', '18536', 'Πειραιάς', '', country));
    addressesLibrary.add(new FAddress('Φιλικής Εταιρίας', '18539', 'Πειραιάς', '', country));
    addressesLibrary.add(new FAddress('Γεωργίου Κασιμάτη', '18531', 'Πειραιάς', '', country));
    addressesLibrary.add(new FAddress('Μητροπόλεως ', '54624', 'Θεσσαλονίκη', '', country));
    addressesLibrary.add(new FAddress('Τσιμισκή ', '54623', 'Θεσσαλονίκη', '', country));
    addressesLibrary.add(new FAddress('Αγίας Σοφίας', '54622', 'Θεσσαλονίκη', '', country));
    addressesLibrary.add(new FAddress('Αγγελάκη ', '54636', 'Θεσσαλονίκη', '', country));

    postDebug('info', MESSSAGE_ADDRESSES + 'Greece in the Greek language');
  }

  /**
   * @description Load addresses from United States in English.
   * @param None.
   * @return None.
   */
  private static void loadAddressesFromUnitedStatesInEnglish() {
    // do nothing if it's already loaded
    if (!addressesLibrary.isEmpty()) {
      return;
    }

    FObject.StreetNumberAfterStreet = false;
    String country = 'USA';

    // add data
    addressesLibrary.add(new FAddress('N Main Ave', '10013', 'New York', 'NY', country));
    addressesLibrary.add(new FAddress('Lawton St', '10013', 'New York', 'NY', country));
    addressesLibrary.add(new FAddress('Broadway', '10007', 'New York', 'NY', country));
    addressesLibrary.add(new FAddress('Outwater Ln', '92126', 'San Diego', 'CA', country));
    addressesLibrary.add(new FAddress('Fenton Parkway', '92108', 'San Diego', 'CA', country));
    addressesLibrary.add(new FAddress('Metropolitan Dr', '90021', 'Los Angeles', 'CA', country));
    addressesLibrary.add(new FAddress('Hawthorne Street', '94105', 'San Francisco', 'CA', country));
    addressesLibrary.add(new FAddress('Delancey Pl', '19103', 'Philadelphia', 'PA', country));
    addressesLibrary.add(new FAddress('Spring Garden St', '19130', 'Philadelphia', 'PA', country));
    addressesLibrary.add(new FAddress('Pennsylvania Avenue N.W.', '20004', 'Washington', 'DC', country));
    addressesLibrary.add(new FAddress('West Jackson Boulevard', '60604', 'Chicago', 'IL', country));

    postDebug('info', MESSSAGE_ADDRESSES + 'United States in the English language');
  }

  /**
   * @description The main method for loading names.
   * @param None.
   * @return None.
   */
  private static void loadNames() {
    FObject.Language = FObject.Language.toLowerCase();
    FObject.Locality = FObject.Locality.toLowerCase();

    if (FObject.Locality == 'italy' && FObject.Language == 'italian') {
      //loadNamesFromItalyInItalian();
    } else if (FObject.Locality == 'france' && FObject.Language == 'french') {
      //loadNamesFromFranceInFrench();
    } else if (FObject.Locality == 'spain'&& FObject.Language == 'spanish') {
      //loadNamesFromSpainInSpanish();
    } else if (FObject.Locality == 'greece' && FObject.Language == 'greek') {
      loadNamesFromGreeceInGreek();
    } else if (FObject.Locality == 'ireland' && FObject.Language == 'english') {
      //loadNamesFromIrelandInEnglish();
    } else if (FObject.Locality == 'england' && FObject.Language == 'english') {
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
    if (!lastNamesLibrary.isEmpty()) {
      return;
    }

    // female names
    gender = 'f';
    List<String> fFirstNames = new List<String> { // add 50 first names
      'Νάντια', 'Διονυσία', 'Τάνια', 'Αδαμαντία', 'Αλίκη', 'Βασιλική', 'Φανή', 'Καίτη', 'Χρύσα', 'Μάγδα', 'Ηλιάνα',
      'Όλγα', 'Γεωργία', 'Μαριάνθη', 'Άρτεμις', 'Άντζελα', 'Στέλλα', 'Ζωή', 'Ανθή', 'Ευθυμία', 'Αγγελική', 'Τόνια',
      'Ντίνα', 'Ρίτα', 'Ντόρα', 'Αλεξία', 'Παυλίνα', 'Ρένα', 'Σοφία', 'Στεφανία', 'Λένα', 'Τζίνα', 'Γιούλη', 'Νεκταρία',
      'Ρέα', 'Γιώτα', 'Λίζα', 'Ελένη', 'Άννα', 'Έλενα', 'Αικατερίνη', 'Ρούλα', 'Παναγιώτα',
      'Ευγενία', 'Εμμανουέλα', 'Μαριέττα', 'Μυρσίνη', 'Μαρκέλλα', 'Τριανταφυλλιά', 'Αφροδίτη'
    };
    List<String> fLastNames = new List<String> { // add 200 last names
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
    firstNamesLibrary.put(gender, fFirstNames);
    lastNamesLibrary.put(gender, fLastNames);

    // male names
    gender = 'm';
    List<String> mFirstNames = new List<String> { // add 50 first names
      'Αδάμ', 'Ευγένιος', 'Αλέκος', 'Νώντας', 'Φάνης', 'Αργύρης', 'Άλκης', 'Διαμαντής', 'Θάνος', 'Παύλος', 'Φίλιππος', 'Αλέξης', 'Γιώργος', 'Κώστας',
      'Μάρκος', 'Θωμάς', 'Νίκος', 'Δήμος', 'Θεοδόσης', 'Στάθης', 'Φώτης', 'Κυριάκος', 'Χάρης', 'Λάμπρος', 'Άγγελος', 'Πέτρος', 'Στράτος', 'Γρηγόρης',
      'Μανώλης', 'Τάσος', 'Μιχάλης', 'Αντώνης', 'Ανδρέας', 'Δημήτρης', 'Γιάννης', 'Βαγγέλης', 'Νικήτας', 'Ηλίας', 'Αχιλλέας', 'Σταύρος',
      'Παναγιώτης', 'Φαίδων', 'Σάββας', 'Βασίλης', 'Ορέστης', 'Νεκτάριος', 'Πάνος', 'Στέφανος', 'Θεόφιλος', 'Στέλιος'
    };
    List<String> mLastNames = new List<String> { // add 200 last names
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
    firstNamesLibrary.put(gender, mFirstNames);
    lastNamesLibrary.put(gender, mLastNames);

    postDebug('info', MESSSAGE_NAMES + 'Greece in the Greek language');
  }

  /**
   * @description Load names from United States in English.
   * @param None.
   * @return None.
   */
  private static void loadNamesFromUnitedStatesInEnglish() {
    String gender = '';

    // do nothing if it's already loaded
    if (!lastNamesLibrary.isEmpty()) {
      return;
    }

    // female names
    gender = 'f';
    List<String> fFirstNames = new List<String> { // add 50 first names
      'Tracey', 'Amelia', 'Leah', 'Nicola', 'Theresa', 'Sophie', 'Olivia', 'Sally', 'Wendy', 'Fiona',
      'Deirdre', 'Jane', 'Lillian', 'Abigail', 'Ella', 'Claire', 'Lauren', 'Bernadette', 'Karen', 'Vanessa',
      'Grace', 'Alison', 'Rachel', 'Heather', 'Ava', 'Wanda', 'Natalie', 'Victoria', 'Joan', 'Dorothy',
      'Una', 'Rebecca', 'Donna', 'Emma', 'Sarah', 'Sonia', 'Samantha', 'Lily', 'Bella', 'Penelope', 'Julia',
      'Caroline', 'Felicity', 'Anne', 'Faith', 'Diane', 'Sue', 'Joanne', 'Kylie', 'Jasmine'
    };
    List<String> fLastNames = new List<String> { // add 200 last names
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
    firstNamesLibrary.put(gender, fFirstNames);
    lastNamesLibrary.put(gender, fLastNames);

    // male names
    gender = 'm';
    List<String> mFirstNames = new List<String> { // add 50 first names
      'Sebastian', 'Boris', 'Andrew', 'Paul', 'Jake', 'Edward', 'Neil', 'Ryan', 'Christian', 'Ian', 'Max',
      'Gavin', 'Matt', 'Jonathan', 'Nicholas', 'Adam', 'Frank', 'Brandon', 'Julian', 'Richard', 'Steven',
      'Colin', 'James', 'Trevor', 'Anthony', 'Victor', 'Nathan', 'Adrian', 'John', 'Joshua', 'Stewart',
      'Kevin', 'David', 'Austin', 'Tim', 'Dominic', 'Robert', 'Jason', 'Connor', 'Evan', 'Joe', 'Sam',
      'Blake', 'Liam', 'Stephen', 'Thomas', 'Phil', 'Christopher', 'Lucas', 'Isaac'
    };
    List<String> mLastNames = new List<String>(fLastNames); // add 200 last names
    firstNamesLibrary.put(gender, mFirstNames);
    lastNamesLibrary.put(gender, mLastNames);

    postDebug('info', MESSSAGE_NAMES + 'United States in the English language');
  }

  /**
    * @description Validates the API name of an object.
    * @param objectName The API name of an object.
    * @return true if the object's API name is valid.
    */
  private boolean objectNameIsValid(string objectName) {
    String objectApiName = getObjectApiName(objectName);

    if (!String.isBlank(objectApiName)) { // object is found
      this.ObjectApiName = objectApiName; // set the API name
      objects.add(objectApiName); // add this object to the list
      return true;
    }
    return false;
  }

  /**
    * @description Validates the parameter of a cluster.
    * @param parameter The parameter of a cluster.
    * @return TRUE if the parameter is valid.
    */
  private Boolean parameterIsValid(String parameter) {
    if (parametersSet.contains(parameter)) {
      return true;
    } else {
      return false;
    }
  }

  /**
   * @description Posts a System.debug message.
   * @param errorLevel The System.LoggingLevel enum.
   * @param message The message to post.
   * @return None.
   */
  private static void postDebug(String errorLevel, String message) {
    //System.debug('=== Method: postDebug ===');

    if (!FObject.DebugMode) {
      return;
    }

    System.LoggingLevel level;
    Boolean showDebugMessage = true;

    // prepare errorLevel
    errorLevel = errorLevel.trim();
    errorLevel = errorLevel.toLowerCase();

    // select logging level
    if (errorLevel == 'error') {
      level = LoggingLevel.ERROR;
    } else if (errorLevel == 'warn') {
      level = LoggingLevel.WARN;
    } else if (errorLevel == 'info') {
      level = LoggingLevel.INFO;
    } else if (errorLevel == 'debug') {
      level = LoggingLevel.DEBUG;
    } else if (errorLevel == 'fine' && ERROR_LEVEL.ordinal() >= 1) {
      level = LoggingLevel.FINE;
    } else if (errorLevel == 'finer' && ERROR_LEVEL.ordinal() == 2) {
      level = LoggingLevel.finer;
    } else {
      showDebugMessage = false;
    }

    // show debug message
    if (showDebugMessage) {
      System.debug(level, 'FORCEEA ' + message);
    }
  }

  /**
    * @description Terminates the process if it is invalid.
    * @param None.
    * @return TRUE if the process is invalid.
    * @throws ForceeaException When process is invalid.
    */
  private Boolean processMustTerminate() {
    String message = 'Process is invalid and will terminate.';
    if (!FObject.ProcessIsValid) {
      if (Test.isRunningTest()) {
        if (!exceptionErrorMessageIsDisplayed) {
          postDebug('error', message);
          exceptionErrorMessageIsDisplayed = true;
        }
        return true;
      } else {
        //postDebug('warn', 'Errors found');
        //for (String key : this.getErrors().keySet()) {
        //  List<String> errors = this.getErrors().get(key);
        //  for (String value : errors) {
        //    postDebug('warn', FAILURE_SYMBOL + ' ID:' + key + ', Message:' + value);
        //  }
        //}
        throw new ForceeaException(message);
        return true;
      }
    } else { // process is valid
      return false;
    }
  }

  /**
    * @description Resets the CPU timer and displays information
    *   about the elapsed time (in ms) since the previous reset.
    * @param infoText The information message to display.
    * @return None.
    */
  private void resetMilestoneTimer(String infoText) {
    postDebug('info', '>> ' + infoText + ' for object [' + this.ObjectApiName + '] in ' +
      this.MilestoneDuration +  ' ms. Transaction duration: ' + Limits.getCpuTime() + ' ms');
    this.MilestoneStartTime = Limits.getCpuTime();
  }

  /**
    * @description Declares a field definition.
    * @param fieldName The API name of a field.
    * @param definition The field definition (command + script).
    * @returns None.
    */
  global void setDefinition(String fieldName, String definition) {
    setDefinition(fieldName, false, definition);
  }

  /**
    * @description Declares a field definition.
    * @param fieldName The API name of a field.
    * @param definition The field definition (command + script).
    * @returns None.
    */
  private void setDefinition(String fieldName, Boolean isSystemDefined, String definition) {
    if (!FObject.ProcessIsValid) {
      return;
    }

    // clear input
    fieldName = fieldName.toLowerCase();
    fieldName = fieldName.trim();
    definition = definition.trim();

    // get the field API name
    String fieldApiName = getFieldApiName(fieldName);

    if (String.isBlank(fieldApiName)) { // field is invalid
      addError(this.ObjectApiName, 'Invalid field [' + fieldName + '] in definition ['
        + definition + ']');
    } else { // field is valid, declare definition
      Definition def = new Definition(fieldName, fieldApiName, isSystemDefined, definition);
      def.FieldApiName = fieldApiName;
      this.fieldSet.add(fieldApiName);
      this.definitions.add(def);
      postDebug('debug', SUCCESS_SYMBOL + ' Registered field [' + def.FieldApiName + '] in definition [' + def.definitionString + ']');
    }
    this.definitionsAreValidated = false;
  }

  /**
   * @param field A field object.
   * @return None.
   */
  @TestVisible
  private void setDefinitionFromField(Field field) {
    if (this.ObjectApiName == 'Account' && field.FieldApiName == 'Name') {
      setDefinition(field.FieldApiName, true, 'static value(Company)');
      setDefinition(field.FieldApiName, true, 'random type(number) from(1) to(10000) scale(0)');
    } else if (this.ObjectApiName == 'Contact' && field.FieldApiName == 'FirstName') {
      setDefinition(field.FieldApiName, true, 'random type(firstname) group(name)');
    } else if (this.ObjectApiName == 'Contact' && field.FieldApiName == 'LastName') {
      setDefinition(field.FieldApiName, true, 'random type(lastname) group(name)');
    } else if (this.ObjectApiName == 'Lead' && field.FieldApiName == 'Company') {
      setDefinition(field.FieldApiName, true, 'static value(Company)');
      setDefinition(field.FieldApiName, true, 'random type(number) from(1) to(10000) scale(0)');
    } else if (this.ObjectApiName == 'Lead' && field.FieldApiName == 'FirstName') {
      setDefinition(field.FieldApiName, true, 'random type(firstname) group(name)');
    } else if (this.ObjectApiName == 'Lead' && field.FieldApiName == 'LastName') {
      setDefinition(field.FieldApiName, true, 'random type(lastname) group(name)');
    } else if (this.ObjectApiName == 'Opportunity' && field.FieldApiName == 'Name') {
      setDefinition(field.FieldApiName, true, 'static value(Opportunity-)');
      setDefinition(field.FieldApiName, true, 'serial from(1) step(1) scale(0)');
    } else if (field.Type == Schema.DisplayType.Integer) { // Integer
      setDefinition(field.fieldName, true, 'random type(number) from(1) to(100) scale(0)');
    } else if (field.Type == Schema.DisplayType.Currency) { // Currency
      setDefinition(field.fieldName, true, 'random type(number) from(1000) to(10000) scale(2)');
    } else if (field.Type == Schema.DisplayType.Double) { // Double
      setDefinition(field.fieldName, true, 'random type(number) from(1000) to(10000) scale(3)');
    } else if (field.Type == Schema.DisplayType.Date) { // Date
      setDefinition(field.fieldName, true, 'random type (date) from(2010-01-01) to(2017-12-31)');
    } else if (field.Type == Schema.DisplayType.DateTime) { // DateTime
      setDefinition(field.fieldName, true, 'random type (datetime) from(2010-01-01) to(2017-12-31)');
    } else if (field.Type == Schema.DisplayType.Picklist) { // Picklist
      setDefinition(field.fieldName, true, 'random type(picklist)');
    } else if (field.Type == Schema.DisplayType.MultiPicklist) { // Picklist or MultiPicklist
      setDefinition(field.fieldName, true, 'random type(picklist)');
    } else if (field.Type == Schema.DisplayType.Address) { // Address
      // do nothing
    } else if (field.Type == Schema.DisplayType.String) { // String
      Integer minlength = (field.Length < 5) ? field.Length : 5;
      setDefinition(field.fieldName, true, 'random type(string) minlength(' + minlength + ') maxlength(' +
        field.Length + ') startwith(upper) include(lower,upper)');
    } else if (field.Type == Schema.DisplayType.TextArea) { // TextArea
      setDefinition(field.fieldName, true, 'random type(text) minlength(50) maxlength(250)');
    } else if (field.Type == Schema.DisplayType.Percent) { // Percent
      setDefinition(field.fieldName, true, 'random type(number) from(0) to(1) scale(3)');
    } else if (field.Type == Schema.DisplayType.Reference) { // Reference
      setDefinition(field.fieldName, true, 'random lookup(' + field.parents[0] + ') source(forceea)');
    } else if (field.Type == Schema.DisplayType.Boolean) { // Boolean
      setDefinition(field.fieldName, true, 'random type(boolean)');
    } else if (field.Type == Schema.DisplayType.Email) { // Email
      setDefinition(field.fieldName, true, 'random type(email)');
    } else if (field.Type == Schema.DisplayType.Phone) { // Phone
      // do nothing
    } else if (field.Type == Schema.DisplayType.URL) { // URL
      setDefinition(field.fieldName, true, 'random type(url)');
    }
  }

  /**
    * @description Declares all required fields of the object.
    * @param None.
    * @return None.
    */
  private void setDefinitionOfRequiredFields() {
    if (!SetRequiredFields) {
      return;
    }
    postDebug('debug', 'Will set the definition of required fields');

    // depending on the object, set definitions
    if (this.ObjectApiName == 'User') {
      List<String> requiredFieldNames = new List<String> ();
      List<String> requiredDefinitions = new List<String> ();
      postDebug('info', 'Object is [' + this.ObjectApiName + '] and specific fields will be defined');

      // prepare field definition lists
      requiredFieldNames.add('Alias');
      requiredDefinitions.add('random type(string) minlength(8) maxlength(8) startwith(upper) include(lower)');

      requiredFieldNames.add('Lastname');
      requiredDefinitions.add('random type(lastname) group(name)');

      requiredFieldNames.add('Username');
      requiredDefinitions.add('random type(email)');

      requiredFieldNames.add('Email');
      requiredDefinitions.add('random type(email)');

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
      for (Integer i = 0; i < requiredFieldNames.size(); i++) {
        if (!this.FieldSet.contains(requiredFieldNames[i])) { // if field is not defined
          setDefinition(requiredFieldNames[i], true, requiredDefinitions[i]);
        }
      }
    } else { // object is anything else
      // for each field in the fields map
      for (Field fld : this.objectFieldsMap.values()) {
        // if field is required and is not defined yet
        if (fld.IsRequired && (!fieldSet.contains(fld.FieldApiName))) {
          setDefinitionFromField(fld); // set a new definition for this Field
        }
      }
    }
  }

  /**
    * @description Declares all definition types.
    * @param None.
    * @return None.
    */
  private static void setDefinitionTypes() {
    DefinitionType dt;

    // RandomNumber
    // example: random from(10) to(100) scale(0)
    dt = new DefinitionType(DefinitionTypeId.RANDOM_NUMBER, 'RandomNumber', 'random');
    dt.clusterTypes.add(new ClusterType('type', ValueType.TYPE_STRING, 'number', false));
    dt.clusterTypes.add(new ClusterType('from', ValueType.TYPE_DECIMAL, null, false));
    dt.clusterTypes.add(new ClusterType('to', ValueType.TYPE_DECIMAL, null, false));
    dt.clusterTypes.add(new ClusterType('scale', ValueType.TYPE_INTEGER, null, false));
    definitionTypes.add(dt);

    // RandomDate
    // example: random type(date) from(2010-01-01) to(2015-12-31) format: YYYY-MM-DD
    dt = new DefinitionType(DefinitionTypeId.RANDOM_DATE, 'RandomDate', 'random');
    dt.clusterTypes.add(new ClusterType('type', ValueType.TYPE_STRING, 'date', false));
    dt.clusterTypes.add(new ClusterType('from', ValueType.TYPE_DATE, null, false));
    dt.clusterTypes.add(new ClusterType('to', ValueType.TYPE_DATE, null, false));
    definitionTypes.add(dt);

    // RandomDatetime
    // example: random type(datetime) from(2010-01-01) to(2015-12-31) format: YYYY-MM-DD
    dt = new DefinitionType(DefinitionTypeId.RANDOM_DATETIME, 'RandomDatetime', 'random');
    dt.clusterTypes.add(new ClusterType('type', ValueType.TYPE_STRING, 'datetime', false));
    dt.clusterTypes.add(new ClusterType('from', ValueType.TYPE_DATE, null, false));
    dt.clusterTypes.add(new ClusterType('to', ValueType.TYPE_DATE, null, false));
    definitionTypes.add(dt);

    // RandomPicklist
    // example: random type(list)
    dt = new DefinitionType(DefinitionTypeId.RANDOM_PICKLIST, 'RandomPicklist', 'random');
    dt.clusterTypes.add(new ClusterType('type', ValueType.TYPE_STRING, 'picklist', false));
    definitionTypes.add(dt);

    // RandomPicklistExcept
    // example: random type(list) except(a,b,c)
    dt = new DefinitionType(DefinitionTypeId.RANDOM_PICKLISTEXCEPT, 'RandomPicklistExcept', 'random');
    dt.clusterTypes.add(new ClusterType('type', ValueType.TYPE_STRING, 'picklist', false));
    dt.clusterTypes.add(new ClusterType('except', ValueType.TYPE_STRING, null, true));
    definitionTypes.add(dt);

    // RandomBoolean
    // example: random type(boolean)
    dt = new DefinitionType(DefinitionTypeId.RANDOM_BOOLEAN, 'RandomBoolean', 'random');
    dt.clusterTypes.add(new ClusterType('type', ValueType.TYPE_BOOLEAN, 'boolean', false));
    definitionTypes.add(dt);

    // RandomEmail
    // example: random type(email)
    dt = new DefinitionType(DefinitionTypeId.RANDOM_EMAIL, 'RandomEmail', 'random');
    dt.clusterTypes.add(new ClusterType('type', ValueType.TYPE_STRING, 'email', false));
    definitionTypes.add(dt);

    // RandomFirstName
    // example: random type(firstname) group(STRING)
    dt = new DefinitionType(DefinitionTypeId.RANDOM_FIRSTNAME, 'RandomFirstName', 'random');
    dt.clusterTypes.add(new ClusterType('type', ValueType.TYPE_STRING, 'firstname', false));
    dt.clusterTypes.add(new ClusterType('group', ValueType.TYPE_STRING, null, false));
    definitionTypes.add(dt);

    // RandomLastName
    // example: random type(lastname) group(STRING)
    dt = new DefinitionType(DefinitionTypeId.RANDOM_LASTNAME, 'RandomLastName', 'random');
    dt.clusterTypes.add(new ClusterType('type', ValueType.TYPE_STRING, 'lastname', false));
    dt.clusterTypes.add(new ClusterType('group', ValueType.TYPE_STRING, null, false));
    definitionTypes.add(dt);

    // RandomStreet
    // example: random type(street) group(STRING)
    dt = new DefinitionType(DefinitionTypeId.RANDOM_STREET, 'RandomStreet', 'random');
    dt.clusterTypes.add(new ClusterType('type', ValueType.TYPE_STRING, 'street', false));
    dt.clusterTypes.add(new ClusterType('group', ValueType.TYPE_STRING, null, false));
    definitionTypes.add(dt);

    // RandomPostalCode
    // example: random type(postalcode) group(STRING)
    dt = new DefinitionType(DefinitionTypeId.RANDOM_POSTALCODE, 'RandomPostalCode', 'random');
    dt.clusterTypes.add(new ClusterType('type', ValueType.TYPE_STRING, 'postalcode', false));
    dt.clusterTypes.add(new ClusterType('group', ValueType.TYPE_STRING, null, false));
    definitionTypes.add(dt);

    // RandomCity
    // example: random type(city) group(STRING)
    dt = new DefinitionType(DefinitionTypeId.RANDOM_CITY, 'RandomCity', 'random');
    dt.clusterTypes.add(new ClusterType('type', ValueType.TYPE_STRING, 'city', false));
    dt.clusterTypes.add(new ClusterType('group', ValueType.TYPE_STRING, null, false));
    definitionTypes.add(dt);

    // RandomState
    // example: random type(state) group(STRING)
    dt = new DefinitionType(DefinitionTypeId.RANDOM_STATE, 'RandomState', 'random');
    dt.clusterTypes.add(new ClusterType('type', ValueType.TYPE_STRING, 'state', false));
    dt.clusterTypes.add(new ClusterType('group', ValueType.TYPE_STRING, null, false));
    definitionTypes.add(dt);

    // RandomCountry
    // example: random type(country) group(STRING)
    dt = new DefinitionType(DefinitionTypeId.RANDOM_COUNTRY, 'RandomCountry', 'random');
    dt.clusterTypes.add(new ClusterType('type', ValueType.TYPE_STRING, 'country', false));
    dt.clusterTypes.add(new ClusterType('group', ValueType.TYPE_STRING, null, false));
    definitionTypes.add(dt);

    // RandomString
    // example: random type(string)
    dt = new DefinitionType(DefinitionTypeId.RANDOM_STRING, 'RandomString', 'random');
    dt.clusterTypes.add(new ClusterType('type', ValueType.TYPE_STRING, 'string', false));
    dt.clusterTypes.add(new ClusterType('minlength', ValueType.TYPE_INTEGER, null, false));
    dt.clusterTypes.add(new ClusterType('maxlength', ValueType.TYPE_INTEGER, null, false));
    dt.clusterTypes.add(new ClusterType('startwith', ValueType.TYPE_STRING, null, false));
    dt.clusterTypes.add(new ClusterType('include', ValueType.TYPE_STRING, null, true));
    definitionTypes.add(dt);

    // RandomText
    // example: random type(text) minlength(20) maxlength(40)
    dt = new DefinitionType(DefinitionTypeId.RANDOM_TEXT, 'RandomText', 'random');
    dt.clusterTypes.add(new ClusterType('type', ValueType.TYPE_STRING, 'text', false));
    dt.clusterTypes.add(new ClusterType('minlength', ValueType.TYPE_INTEGER, null, false));
    dt.clusterTypes.add(new ClusterType('maxlength', ValueType.TYPE_INTEGER, null, false));
    definitionTypes.add(dt);

    // RandomURL
    // example: random type(url)
    dt = new DefinitionType(DefinitionTypeId.RANDOM_URL, 'RandomURL', 'random');
    dt.clusterTypes.add(new ClusterType('type', ValueType.TYPE_URL, 'url', false));
    definitionTypes.add(dt);

    // RandomLookupInternal(Forceea)
    // example: random lookup(Account) source(forceea)
    dt = new DefinitionType(DefinitionTypeId.RANDOM_LOOKUP, 'RandomLookupInternal', 'random');
    dt.clusterTypes.add(new ClusterType('lookup', ValueType.TYPE_STRING, null, false));
    dt.clusterTypes.add(new ClusterType('source', ValueType.TYPE_STRING, 'forceea', false));
    definitionTypes.add(dt);

    // RandomLookupInternalValue(Forceea)
    // example: random lookup(Account) field(Name) value(Company XYZ) source(forceea)
    dt = new DefinitionType(DefinitionTypeId.RANDOM_LOOKUP, 'RandomLookupInternalValue', 'random');
    dt.clusterTypes.add(new ClusterType('lookup', ValueType.TYPE_STRING, null, false));
    dt.clusterTypes.add(new ClusterType('field', ValueType.TYPE_STRING, null, false));
    dt.clusterTypes.add(new ClusterType('value', ValueType.TYPE_STRING, null, true));
    dt.clusterTypes.add(new ClusterType('source', ValueType.TYPE_STRING, 'forceea', false));
    definitionTypes.add(dt);

    // RandomLookupInternalExcept(Forceea)
    // example: random lookup(Account) field(Name) value(Company XYZ) source(forceea)
    dt = new DefinitionType(DefinitionTypeId.RANDOM_LOOKUP, 'RandomLookupInternalExcept', 'random');
    dt.clusterTypes.add(new ClusterType('lookup', ValueType.TYPE_STRING, null, false));
    dt.clusterTypes.add(new ClusterType('field', ValueType.TYPE_STRING, null, false));
    dt.clusterTypes.add(new ClusterType('except', ValueType.TYPE_STRING, null, true));
    dt.clusterTypes.add(new ClusterType('source', ValueType.TYPE_STRING, 'forceea', false));
    definitionTypes.add(dt);

    // RandomLookupExternal(Salesforce)
    // example: random lookup(Account) source(salesforce)
    dt = new DefinitionType(DefinitionTypeId.RANDOM_LOOKUP, 'RandomLookupExternal', 'random');
    dt.clusterTypes.add(new ClusterType('lookup', ValueType.TYPE_STRING, null, false));
    dt.clusterTypes.add(new ClusterType('source', ValueType.TYPE_STRING, 'salesforce', false));
    definitionTypes.add(dt);

    // RandomLookupExternalValue(Salesforce)
    // example: random lookup(Account) field(Name) value(Company XYZ) source(salesforce)
    dt = new DefinitionType(DefinitionTypeId.RANDOM_LOOKUP, 'RandomLookupExternalValue', 'random');
    dt.clusterTypes.add(new ClusterType('lookup', ValueType.TYPE_STRING, null, false));
    dt.clusterTypes.add(new ClusterType('field', ValueType.TYPE_STRING, null, false));
    dt.clusterTypes.add(new ClusterType('value', ValueType.TYPE_STRING, null, true));
    dt.clusterTypes.add(new ClusterType('source', ValueType.TYPE_STRING, 'salesforce', false));
    definitionTypes.add(dt);

    // RandomLookupExternalExcept(Salesforce)
    // example: random lookup(Account) field(Name) value(Company XYZ) source(salesforce)
    dt = new DefinitionType(DefinitionTypeId.RANDOM_LOOKUP, 'RandomLookupExternalExcept', 'random');
    dt.clusterTypes.add(new ClusterType('lookup', ValueType.TYPE_STRING, null, false));
    dt.clusterTypes.add(new ClusterType('field', ValueType.TYPE_STRING, null, false));
    dt.clusterTypes.add(new ClusterType('except', ValueType.TYPE_STRING, null, true));
    dt.clusterTypes.add(new ClusterType('source', ValueType.TYPE_STRING, 'salesforce', false));
    definitionTypes.add(dt);

    // RandomList
    // example: random type(list) value(a,b,c)
    dt = new DefinitionType(DefinitionTypeId.RANDOM_LIST, 'RandomList', 'random');
    dt.clusterTypes.add(new ClusterType('type', ValueType.TYPE_STRING, 'list', false));
    dt.clusterTypes.add(new ClusterType('value', ValueType.TYPE_STRING, null, true));
    definitionTypes.add(dt);

    // Static
    // example: static value(abc)
    dt = new DefinitionType(DefinitionTypeId.STATIC_STRING, 'Static', 'static');
    dt.clusterTypes.add(new ClusterType('value', ValueType.TYPE_STRING, null, false));
    definitionTypes.add(dt);

    // StaticLookupInternal(Forceea)
    // example: static lookup(Account) field(Name) value(Company XYZ) source(forceea)
    dt = new DefinitionType(DefinitionTypeId.STATIC_LOOKUP, 'StaticLookupInternal', 'static');
    dt.clusterTypes.add(new ClusterType('lookup', ValueType.TYPE_STRING, null, false));
    dt.clusterTypes.add(new ClusterType('field', ValueType.TYPE_STRING, null, false));
    dt.clusterTypes.add(new ClusterType('value', ValueType.TYPE_STRING, null, false));
    dt.clusterTypes.add(new ClusterType('source', ValueType.TYPE_STRING, 'forceea', false));
    definitionTypes.add(dt);

    // StaticLookupExternal(Salesforce)
    // example: static lookup(Account) field(Name) value(Company XYZ) source(salesforce)
    dt = new DefinitionType(DefinitionTypeId.STATIC_LOOKUP, 'StaticLookupExternal', 'static');
    dt.clusterTypes.add(new ClusterType('lookup', ValueType.TYPE_STRING, null, false));
    dt.clusterTypes.add(new ClusterType('field', ValueType.TYPE_STRING, null, false));
    dt.clusterTypes.add(new ClusterType('value', ValueType.TYPE_STRING, null, false));
    dt.clusterTypes.add(new ClusterType('source', ValueType.TYPE_STRING, 'salesforce', false));
    definitionTypes.add(dt);

    // Serial
    // example: serial from(10.2) step(1.2) decimal(1)
    dt = new DefinitionType(DefinitionTypeId.SERIAL_DECIMAL, 'SerialDecimal', 'serial');
    dt.clusterTypes.add(new ClusterType('from', ValueType.TYPE_DECIMAL, null, false));
    dt.clusterTypes.add(new ClusterType('step', ValueType.TYPE_DECIMAL, null, false));
    dt.clusterTypes.add(new ClusterType('scale', ValueType.TYPE_INTEGER, null, false));
    definitionTypes.add(dt);
  }

  /**
   * @description Dispays the Field Value Matrix (FVM) values.
   * @param None.
   * @return None.
   */
  private void showFVM() {
    postDebug('debug', 'Will display Field Values Matrix');
    Integer i = 0;
    Integer count;
    String str = '';

    for (String fld : fieldSet) { // for each field
      // limit the displayed records
      if (this.Records <= DISPLAY_RECORDS) {
        count = this.Records;
      } else {
        count = DISPLAY_RECORDS;
      }
      // add dividers between records
      str = '';
      for (Integer j = 0; j < count; j++) {
        str += this.fieldValuesMatrix[i][j] + ', ';
      }
      i++;
      postDebug('debug', 'Created sample data for field [' + fld + ']: ' + str.removeEnd(', '));
    }
  }

/**
   * @description Validates definitions.
   * @param None.
   * @return None.
   */
  private void validateDefinitions() {
    if (this.DefinitionsAreValidated) {
      return;
    }

    postDebug('debug', 'Will validate field definitions');
    for (Definition def : definitions) { // for every defined field
      postDebug('debug', 'Validating definition [' + def.DefinitionString +
        '] of field [' + def.FieldApiName + ']');
      if (!definitionIsValid(def)) { // definition is invalid
        addError(def.FieldApiName, 'Invalid definition [' + def.DefinitionString +
          '] of field [' + def.FieldApiName + ']');
      } else { // defintion is valid
        postDebug('info', SUCCESS_SYMBOL + ' Definition [' + def.DefinitionString + '] is valid');
      }
    }

    this.definitionsAreValidated = true;
  }

  /**
   * @description Validates the value (arguments) of a cluster.
   * @param clusterType The cluster type.
   * @param cluster The cluster to validate.
   * @return TRUE if the cluster argumentsis are valid, based on cluster type.
   */
  private Boolean valueIsValid(ClusterType clusterType, Cluster cluster, String fieldApiName) {
    String valueText = cluster.arguments[0]; // the initial Value text
    List<String> arguments = new List<String>(); // the list of arguments
    String remainingValue = cluster.arguments[0]; // the unprocessed part of Value text

    // initialize remaining Value
    remainingValue += ',';
    postDebug('finer', '...value is [' + remainingValue + ']');

    // seperate arguments
    Integer count = 0; // a counter
    String argument = '';
    do {
      argument = remainingValue.substringBefore(',');
      arguments.add(argument);
      remainingValue = remainingValue.removeStart(argument + ','); // get remaining text
      postDebug('finer', '...value item (' + count + ') is [' + argument + ']');
      count++;
    } while (String.isNotEmpty(remainingValue));

    // if Value must have only 1 item but it has more
    if (!clusterType.multipleValueItems && arguments.size() > 1) {
      addError(fieldApiName, 'Parameter [' + clusterType.parameter + '] should have only one argument');
      return false;
    }

    // Value has the correct number of arguments
    cluster.arguments = arguments; // add arguments to Value list

    // if Parameter should have an argument
    if ((clusterType.value != null)
        && (clusterType.value != valueText)) { // and this is not the valid argument
      postDebug('finer', '...parameter [' + clusterType.parameter + '] has an invalid argument');
      return false;
    }

    // check Value data type of all Value items
    for (String cv : cluster.arguments) {
      if (clusterType.valueType == valueType.TYPE_INTEGER) { // is Integer
        Integer intValue;
        try {
          intValue = Integer.valueOf(cv);
        } catch (System.TypeException ex) {
          return false;
        }
      } else if (clusterType.valueType == valueType.TYPE_DECIMAL) { // is Decimal
        Decimal decValue;
        try {
          decValue = Decimal.valueOf(cv);
        } catch (System.TypeException ex) {
          return false;
        }
      } else if (clusterType.valueType == valueType.TYPE_DATE) { // is Date
        Date dateValue;
        try {
          dateValue = Date.valueOf(cv);
        } catch (System.TypeException ex) {
          return false;
        }
      }
    }

    return true;
  }
}
