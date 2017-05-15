/* Forceea Data Factory Framework
 * v1.0.1.4
 * Developer: Nikos Mitrakis
 */

global class FObject {
	/* CONSTANTS */
	private static final Integer DEFAULT_RECORDS = 201;
	// if TRUE does not post any messages to Debug Log
	private static final Boolean DEVELOPMENT_MODE = false;

	/* ENUMS */
	private enum ValueType {
		fLookup, fInt, fDec, fText, fDate, fEmail, fURL, fPhone, fBoolean}
	private enum DefinitionTypeId {
		fRandomString, fRandomText, fRandomNumber, fRandomDate, fRandomLookup,
		fRandomPicklist, fRandomPicklistExcept, fRandomList,
		fRandomEmail, fRandomBoolean, fRandomURL, fRandomFirstName, fRandomLastName, 
		fStatic, fStaticLookup, fSerial, fSerialDecimal}

	/* CLASSES */

	/* scope  	an object representing the building blocks of a definition script
	 * notes        
	 * usage    */
	private class Cluster {
		String parameter {get; set;}
		List<String> value = new List<String>();
		private Cluster(String parameter, String value) {
			this.parameter = parameter;
			this.value.add(value);
		}

	}

	/* scope    a template for a cluster object
	 *          It declares the Parameter, the Value (if any) and if multiple Value items may exist
	 * notes   Cluster Types are defined in static method setDefinitionTypes
	 * usage   a list of Cluster Types is used in the DefinitionType class */
	private class ClusterType {
		String parameter {get; set;}
		ValueType valueType {get; set;}
		String value {get; set;}
		Boolean multipleValueItems {get; set;}
		private ClusterType(String parameter, ValueType valueType,
				String value, Boolean multipleValueItems) {
			this.parameter = parameter;
			this.valueType = valueType;
			this.value = value;
			this.multipleValueItems = multipleValueItems;
		}
	}

	/* scope    holds the information of a field definition object
	 * notes   
	 * usage		*/
	private class Definition {
		String fieldName {get; set;}
		String definitionString {get; set;}
		String command {get; set;}
		String script {get; set;}
		Boolean isValid {get; set;}
		DefinitionType type {get; set;}
		List<Cluster> clusters = new List<Cluster>();
		private Definition(String fieldName, String definition) {
			this.fieldName = fieldName;
			this.definitionString = definition;
			this.isValid = true;
		}
	}

	/* scope    declares an object with the content of a valid definition
	 *          e.g. definition: random from(IntegerValue) to (IntegerValue)
	 * notes    
	 * usage    */
	private class DefinitionType {
		DefinitionTypeId id {get; set;}
		String description {get; set;}
		String command {get; set;}
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

	/* scope    declares an error message object
	 * notes        
	 * usage    */	
	private class Error {
		String text {get; set;}
		String errorMessage {get; set;}
		private Error(String text, String errorMessage) {
			this.text = text;
			this.errorMessage = errorMessage;
		}
	}

	/* scope    declares an SObject field object
	 * notes        
	 * usage    */
	private class Field {
		String fieldName {get; set;}
		String label {get; set;}
		Schema.DisplayType type {get; set;}
		Boolean isRequired {get; set;}
		//Integer precision {get; set;}
		//Integer scale {get; set;}	
		//Boolean isCreateable {get; set;}
		//Boolean isNillable {get; set;}
		//Boolean isDefaultedOnCreate {get; set;}
		//Boolean isIdLookup {get; set;}
		//Boolean isUnique {get; set;}
		//Object defaultValue {get; set;}
		//canHaveMultipleTypesAsParents {get; set;}
		List<Schema.sObjectType> parents {get; set;}
		List<Schema.PicklistEntry> picklistValues = new List<Schema.PicklistEntry>();
	}

	/* scope    declares a variable object
	 * notes    this object is not used
	 * usage    */
	private class Variable {
		String type {get; set;}
		String name {get; set;}
		String definition {get; set;}
		private Variable(String type, String name, String definition) {
			this.type = type;
			this.name = name;
			this.definition = definition;
		}
	}

	/* STATIC LISTS & MAPS */

	private static List<String> commands = new List<String> {'random', 'static', 'serial'};
	// defined parameters
	private static Set<String> parametersSet = new Set<String>
	{'length', 'from', 'to', 'scale', 'value', 'step', 'lookup', 'startwith', 'include', 'words', 'object', 'field', 'type', 'except', 'source'};
	// defined cluster types
	private static List<DefinitionType> definitionTypes = new List<DefinitionType>();
	// created records of all objects
	private static Map<String,List<SObject>> globalRecordsMap = new Map<String, List<SObject>>();
	// field details of each declared FObject
	private static Map<String,Map<String,Field>> globalObjectFieldsMap = new Map<String, Map<String,Field>>();
	// defined objects
	private static List<String> objects = new List<String>();
	// the results of the Record types SOQL query
	private static List<RecordType> recordTypesQueryResults = new List<RecordType>();

	/* INSTANCE LISTS & MAPS */

	// record types of this object (DeveloperName, Id)
	private Map<String,Id> recordTypesMap = new Map<String,Id>();
	// defined fields
	private Set<String> fieldSet = new Set<String>();
	private List<String> fieldsList = new List<String>();
	private Map<String,Field> objectFieldsMap = new Map<String,Field>();
	// field definitions
	private List<Definition> definitions = new List<Definition>();
	// the FVM, each List<string> contains a field's values
	private List<List<String>> fieldValuesMatrix = new List<List<String>>();
	// generated SObject records
	private List<SObject> createdRecords = new List<SObject>();
	// errors in definitions
	private List<Error> errors = new List<Error>();
	// variables
	private List<Variable> variables = new List<Variable>();

	/* STATIC PROPERTIES */

	// true if this process has no errors (valid)
	private static Boolean processIsValid {get; set;}
	// the country of Address fields
	private static String globalCountry {get; set;}
	// the language of name fields
	private static String globalLanguage {get; set;}
	// true if will post to System.debug
	global static Boolean debugMode {get; set;}

	/* INSTANCE PROPERTIES */

	// the CPU limit time for the timer start and finish
	private Integer moduleStartTime {get; set;}
	private Integer instanceStartTime {get; set;}
	// the elapsed CPU time for an FObject module (block of code)
	private Integer moduleDuration {
		get {return Limits.getCpuTime() - moduleStartTime;}
		set;
	}
	// the elapsed CPU time for an FObject instance
	private Integer instanceDuration {
		get {return Limits.getCpuTime() - instanceStartTime;}
	}
	// the total CPU time
	private Integer totalDuration {
		get {return Limits.getCpuTime();}
	}
	// the API name of the SObject
	private Schema.SObjectType sObjType {get; set;}
	// the API name of the SObject
	private String objectName {get; set;}

	// auto define required fields
	global Boolean setRequiredFields {get; set;}
	// the number of records to create
	global Integer records {get; set;}
	// the country of Address fields
	global String country {get; set;}
	// the language of name fields
	global String language {get; set;}

	/* INITIALIZATION CODE */

	// static initialization code
	static {
		debugMode = true;
		postDebug('info', '********** FORCEEA 1.0 Data Factory **********');

		// declare defintion types
		setDefinitionTypes();

		// query for active RecordType records
		String soql = 'SELECT Id, Name, DeveloperName, sObjectType ';
		soql += 'FROM RecordType WHERE IsActive = true';

		// get record types
		try {
			recordTypesQueryResults = Database.query(soql);
		} catch (QueryException ex) {
			postDebug('error', 'Error in registering record types:' + ex.getMessage());
		}

		// declare properties
		globalLanguage = 'English';
		globalCountry = 'any';
	}

	// instance initialization code
	{
		// declare properties
		this.language = FObject.globalLanguage;
		this.country = FObject.globalcountry;

		// reset CPU limit timer
		this.moduleStartTime = Limits.getCpuTime();
		this.instanceStartTime = Limits.getCpuTime();
	}

	/* CONSTRUCTORS */

	global FObject(String objectName, Integer records) {
		// initialize properties
		this.objectName = objectName.toLowerCase();
		this.records = records;
		this.setRequiredFields = false;

		// validate object
		if (objectNameIsValid(objectName)) {
			processIsValid = true;
			postDebug('info', 'Will generate sample data for SObject [' + objectName + ']');
		} else { // object name is invalid
			processIsValid = false;
			addError(objectName, 'Invalid SObject [' + objectName + ']');
			if (processMustTerminate()) {return;}
		}

		// get object type
		this.sObjType = Schema.getGlobalDescribe().get(objectName);
		String sObjTypeString = String.valueOf(this.sObjType);

		// get record types
		for (RecordType rt: recordTypesQueryResults) {
			if (sObjTypeString == rt.SObjectType) {
				this.recordTypesMap.put(rt.DeveloperName, rt.Id);
				//System.debug('Found record type [' + rt.DeveloperName + ']');
			}
		}

		// if object is already defined
		if (globalObjectFieldsMap.containsKey(this.objectName)) {
			// get stored fields details
			postDebug('info', 'Will load stored field definitions');
			this.objectFieldsMap = globalObjectFieldsMap.get(this.objectName);

			// get stored record type details
			// *** TBD ***
			//
		} else { // get fields details
			// set SObject fields
			postDebug('info', 'Will retrieve field definitions');
			for (Schema.sObjectField sof: this.sObjType.getDescribe().fields.getMap().values()) {
				Schema.DescribeFieldResult dfr = sof.getDescribe(); // describe field
				// create a Field object and populate it
				Field objectField = new Field();
				objectField.fieldName = dfr.getName().toLowerCase();
				objectField.label = dfr.getLabel();
				objectField.type = dfr.getType();
				objectField.parents = dfr.getReferenceTo();

				// locate required fields
				if (dfr.isCreateable() && !dfr.isNillable() && !dfr.isDefaultedOnCreate()) {
					objectField.isRequired = true;
					postDebug('info', 'Found required field  [' + objectField.fieldName + ']');
				} else {objectField.isRequired = false;}

				//objectField.canHaveMultipleTypesAsParents = dfr.isNamePointing();
				//objectField.isUnique = dfr.isUnique();
				//objectField.defaultValue = dfr.getDefaultValue();
				//objectField.precision = dfr.getPrecision();
				//objectField.scale = dfr.getScale();
				//objectField.isCreateable = dfr.isCreateable();
				//objectField.isNillable = dfr.isNillable();
				//objectField.isDefaultedOnCreate = dfr.isDefaultedOnCreate();
				//objectField.isIdLookup = dfr.isIdLookup();

				//postDebug('debug', 'Field[' + objectField.fieldName + '] type[' + objectField.type + ']' + 
				//	': Creatable[' + dfr.isCreateable() + '] Nillable[' + dfr.isNillable() +
				//	'] DefaultedOnCreate[' + dfr.isDefaultedOnCreate() + ']');

				// if the field is picklist, get its values
				try {objectField.picklistValues = dfr.getPicklistValues();}
				catch (System.exception ex) {
					objectField.picklistValues = null;
				}

				// add field to the field map
				this.objectFieldsMap.put(objectField.fieldName, objectField);
			}
			// add SObject fields to global map
			globalObjectFieldsMap.put(this.objectName, this.objectFieldsMap);

			resetModuleTimer('Initialized');
		}
	}

	global FObject(String objectName) {
		this(objectName, DEFAULT_RECORDS);
	}

	/* METHODS */

	/* scope    add an error message to Errors list and post message to Debug Log
	 * input    text: the error reference (e.g. the field or parameter which created the error)
	 * input    errorMessage: the error message
	 * output   - */
	private void addError(String text, String errorMessage) {
		this.errors.add(new Error(text, errorMessage));
		processIsValid = false;
		postDebug('error', 'FORCEEA ' + errorMessage);
	}

	/* scope    add field values to Field Values Matrix
	 * input    fieldName: the API name of the field
	 * input    fieldValues: the list of field values
	 * output   - */
	private void addToFieldValuesMatrix(String fieldName, List<String> fieldValues) {
		Integer i = 0;
		for (String fd: this.fieldSet) { // for each defined field
			if (fd == fieldName) { // when field name matches
				// for each value in field's value list
				for (Integer j = 0; j < this.records; j++) {
					// append new value to existing value
					this.fieldValuesMatrix[i][j] += fieldValues[j];
				}
				break; // and then exit loop
			}
			i++;
		}
	}


	/* scope    batch insert records - doesn't run in Testing mode
	 * input    object name
	 * output   - */
	@future
	global static void batchInsertRecords(String objectName) {
		List<SObject> recordsToInsert = globalRecordsMap.get(objectName);

		// exit when is a Test
		if (Test.isRunningTest()) {return;}

		try { // insert data
			insert recordsToInsert;
		} catch (DmlException ex) {
			String errorMessage = 'FORCEEA ' + 'An error has occurred: ' +
					ex.getMessage();	
			System.debug(logginglevel.ERROR, errorMessage);
			processIsValid = false;
		}
	}

	/* scope    checks that a cluster type exists in a definition
	 *          and parameter(value) format is correct
	 * input    clusterType
	 * input    definition
	 * output   boolean - true if Cluster Type exists in this Definition */
	private Boolean clusterTypeIsValid(ClusterType clusterType, Definition definition) {
		Integer countOfParameter = 0; // counts how many times a cluster parameter is found
		Integer index; // the position of a definition cluster with a specified (cluster type's) parameter

		// find how many times Parameter exists (countOfParameter) and its position (index)
		Integer i = 0;
		for (Cluster c: definition.clusters) { // for every cluster in definition
			postDebug('fine', ' - checking cluster [' + c.parameter + '] [' + c.value + ']');
			if (clusterType.parameter == c.parameter) { // if parameter is valid            
				countOfParameter++;
				index = i;
			}
			i++;
		}
		postDebug('fine', '  parameter [' + clusterType.parameter + '] count: ' + countOfParameter);

		// if parameter is not found or found more than once
		if (countOfParameter != 1) {return false;}

		postDebug('fine', '(>) parameter [' + clusterType.parameter + '] is found');

		// check if cluster value is valid
		if (valueIsValid(clusterType, definition.clusters[index])) {
			postDebug('fine', '(>) value is valid');
			return true;
		}
		else {
			postDebug('fine', '(x) value is invalid');
			return false;
		}
	}

	/* scope    check if a definition command is valid
	 * input    command
	 * output   TRUE if command is valid */
	private Boolean commandIsValid(String command) {
		for (String cmd: commands) {
			if (cmd == command) {return true;}
		}
		return false;
	}

	/* scope    create the ith record
	 * input    i: the position of the record
	 * output   an SObject*/
	private SObject createRecord(Integer i) {
		// create a new sObject
		SObject sObj = this.sObjType.newSObject();
		// for every defined field
		for (Integer j = 0; j < this.fieldsList.size(); j++) {
			// get field
			String field = this.fieldsList[j];
			// get the value of the field
			Object value = (Object)this.fieldValuesMatrix[j][i];
			// get the type of the field
			Schema.DisplayType valueType = objectFieldsMap.get(this.fieldsList[j]).type;
			// put value in the object
			if (value instanceof String && valueType != Schema.DisplayType.String) {        
				String svalue = (String)value;
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
				else if (valueType == Schema.DisplayType.ID) // ID
					sObj.put(field, Id.valueOf(svalue));
				else if (valueType == Schema.DisplayType.Boolean) // Boolean
					sObj.put(field, Boolean.valueOf(svalue));
				else sObj.put(field, svalue);
			} else { // is string           
				sObj.put(field, value);
			}
			//System.debug('Value type:' + valueType + ' - value:' + value);
		}
		return sObj;
	}

	/* scope    create SObject records using the definitions
	 * input    -
	 * output   - */
	global void createRecords() {
		if (processMustTerminate()) {return;}

		// clear the list of created records
		this.createdRecords.clear();

		// check if should auto-define required fields
		setDefinitionOfRequiredFields();

		// validate definitions
		postDebug('info', 'Will validate field definitions');
		for (Definition def: definitions) { // for every defined field
			postDebug('debug', 'Validating definition [' + def.definitionString +
					'] of field [' + def.fieldName + ']');
			// check if field is valid
			if (!objectFieldsMap.containsKey(def.fieldName)) {
				addError(def.fieldName, 'Invalid field [' + def.fieldName +
						'] on definition [' + def.definitionString + ']');
			} else if (!definitionIsValid(def)) { //check if definition is valid
				addError(def.definitionString, 'Invalid definition [' + def.definitionString + '] of field [' +
						def.fieldName + ']');
			}
		}
		if (processMustTerminate()) {return;}
		resetModuleTimer('Validated definitions');

		// initialize the Field Values Matrix (FVM)
		initializeFieldValuesMatrix();

		// setup defined fields list
		this.fieldsList = new List<String>(this.fieldSet);

		// populate the Field Values Matrix
		if (processMustTerminate()) {return;}
		postDebug('info', 'Will populate the Field Values Matrix');
		for (Definition def: definitions) {
			List<String> fieldValues = getFieldValues(def); // get field values from definition
			addToFieldValuesMatrix(def.fieldName, fieldValues);
			postDebug('debug', 'Populated [' + def.fieldName + '] on definition [' + def.definitionString + ']'); 
		}
		if (processMustTerminate()) {return;}
		resetModuleTimer('Populated Field Values Matrix');
		showFVM();

		// create records
		for (Integer i = 0; i < this.records; i++) {
			this.createdRecords.add(createRecord(i)); // add created object to output list
		}
		resetModuleTimer('Created records');

		// add records to global records map
		globalRecordsMap.put(this.objectName, this.createdRecords);

		postDebug('info', 'Populated sample data for ' + this.records + ' [' +
				this.objectName + '] records in ' + this.instanceDuration + ' ms. Process duration: ' +
				this.totalDuration + ' ms');
	}

	/* scope    deletes all created records of the SObject, using specific criteria (WHERE clause)
	 * input    the WHERE clause
	 * output   boolean: true if definition is valid */
	global Database.DeleteResult[] deleteRecords(String whereClause) {
		if (processMustTerminate()) {return null;}

		List<SObject> recordsToDelete = new List<SObject>();
		Set<Id> deletedRecordsSet = new Set<Id>();
		Integer numRecordsDeleted = 0;

		postDebug('info','Will delete records of SObject [' + this.objectName + ']');

		// set SOQL query
		String soql = 'SELECT Id FROM ' + this.objectName + ' WHERE ' + whereClause + ' LIMIT 10000';

		try { // get records
			recordsToDelete = Database.query(soql);
		} catch (QueryException ex) {
			addError(soql, 'Found errors selecting records of SObject [' +
					this.objectName + ']: ' + ex.getMessage());
		}

		// if there are no records to delete, just exit
		if (recordsToDelete.isEmpty()) {return null;}

		//delete records
		List<Database.DeleteResult> deleteResults = Database.delete(recordsToDelete, false);

		// iterate through each returned result
		for (Database.DeleteResult dr: deleteResults) {
			if (dr.isSuccess()) {
				// add record ID into deleted records set
				deletedRecordsSet.add(dr.getId());
				numRecordsDeleted++;
			}
			else {
				// Operation failed, so get all errors                
				for (Database.Error err : dr.getErrors()) {
					addError(dr.getId(), err.getMessage() +
							'. Fields that affected this error: ' + err.getFields());
				}
			}
		}

		// if there are no errors, display a message
		if (numRecordsDeleted == recordsToDelete.size()) {
			postDebug('info', 'Successfully deleted ' + recordsToDelete.size() +
					' [' + this.objectName + '] records');
		} else { // there are errors
			Integer numErrorsFound = recordsToDelete.size() - numRecordsDeleted;
			addError(this.objectName, 'Found ' + numErrorsFound + ' errors deleting [' +
					+ this.objectName + '] records');
		}

		// remove deleted records from createdRecords
		List<SObject> createdRecordsAfterDelete = new List<SObject>();
		for (SObject cr: this.createdRecords) {
			if (!deletedRecordsSet.contains(cr.Id)) {
				createdRecordsAfterDelete.add(cr);
			}
		}

		// amend created records list
		this.createdRecords = createdRecordsAfterDelete;

		// add records to global records map
		globalRecordsMap.put(this.objectName, this.createdRecords);

		return deleteResults;
	}

	/* scope    checks if a definition is valid
	 * input    definition
	 * output   TRUE if the definition is valid */
	private Boolean definitionIsValid(Definition definition) {
		String definitionString = definition.definitionString;
		definitionString = definitionString.trim();

		// set command and script
		String command = definitionString.substringBefore(' ');
		String script = definitionString.removeStart(command + ' ');
		command = command.trim();
		command = command.toLowerCase();
		definition.command = command;
		script = script.trim();
		definition.script = script;

		// check if command is valid
		if (!commandIsValid(command)) {
			definition.IsValid = false;
			addError(command, 'Invalid command [' + definition.command + '] on definition [' +
					definition.definitionString + ']');
			return false;
		}

		// get the clusters text and add a <space> at the end
		String remainingClustersString = script + ' ';

		postDebug('fine', 'Command [' + command + '] script [' + remainingClustersString + ']');
		postDebug('fine', 'Will define clusters');

		// iterate through all clusters, check the validity of each parameter
		// and add each cluster to the list
		do {
			String clusterText = remainingClustersString.substringBefore(') '); // get the cluster text

			if (clusterText == remainingClustersString) { // there is no closing parenthesis
				clusterText = clusterText.trim();
				addError(clusterText, 'There is no closing parenthesis for cluster [' + clusterText + ']');
				definition.IsValid = false;
				return false;
			}

			// there is a closing parenthesis
			clusterText = clusterText + ')';

			// get the remaining text
			remainingClustersString = remainingClustersString.removeStart(clusterText + ' ');
			postDebug('fine', 'Cluster: [' + clusterText + ']' + ' remaining: [' +
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
			if (clusterText.substringBefore('(') == clusterText) {
				addError(clusterText, 'There is no opening parenthesis for cluster [' + clusterText + ']');
				definition.IsValid = false;
			} else if (!parameterIsValid(parameter)) {
				postDebug('debug', parameter);
				addError(clusterText, 'Invalid parameter for cluster [' + clusterText + ']');
				definition.IsValid = false;
			}

			if (!definition.isValid) {return false;}

			// add cluster to list
			definition.clusters.add(new Cluster(parameter, value));
		} while (String.isNotEmpty(remainingClustersString));

		postDebug('fine', 'found ' + definition.clusters.size() + ' cluster(s)');
		for (Integer i = 0; i < definition.clusters.size(); i++) {
			postDebug('fine', 'added cluster: parameter[' + definition.clusters[i].parameter +
					'] value[' + definition.clusters[i].value[0] + ']');
		}

		// find the definition type of this definition
		DefinitionType definitionType = new DefinitionType();

		postDebug('fine', 'searching for definition type...');
		for (DefinitionType dt: definitionTypes) {
			if (definitionTypeExists(dt, definition)) {
				definition.isValid = true;
				definition.type = dt;
				postDebug('fine', '> found definition type: ' + dt.id);
				return true;
			}
		}
		return false; // if no valid definition type is found
	}

	/* scope    checks that a definition type is valid
	 * input    definitionType
	 * input    definition
	 * output   boolean: true if the definition type exists in this definition */
	private Boolean definitionTypeExists(DefinitionType definitionType, Definition definition) {
		Integer numValidClusterTypes = 0;
		postDebug('fine', 'assesing definition type [' + definitionType.description + '] ...');

		// if command is invalid, just exit
		if (definitionType.command != definition.command) {
			definition.isValid = false;
			definition.type = null;
			postDebug('fine', 'x invalid command');
			return false;
		}

		postDebug('fine', '> command is valid');

		// assess each Cluster Type of the Definition Type
		for (ClusterType ct: definitionType.clusterTypes) { // for every Cluster ype
			postDebug('fine', '  validating cluster type [' + ct.parameter + '] [' + ct.value + ']');
			if (clusterTypeIsValid(ct, definition)) {
				numValidClusterTypes++;
			} else {return false;}
		}

		postDebug('fine', 'number of valid Cluster Types: ' + numValidClusterTypes);

		// if all Cluster Types are valid, Definition Type is found
		if (numValidClusterTypes == definitionType.clusterTypes.size() &&
				numValidClusterTypes == definition.clusters.size()) {
			definition.isValid = true;
			definition.type = definitionType;
			return true;
		} else {
			definition.isValid = false;
			definition.type = null;
			return false;
		}
	}

	/* scope    return the first cluster with a specific parameter
	 * input    parameter: a cluster parameter
	 * input    clusters: a list of definition clusters
	 * output   the cluster having the parameter */
	private Cluster getCluster(String parameter, List<Cluster> clusters) {
		for (Cluster clr: clusters) {
			if (parameter == clr.parameter) {return clr;}
		}
		return null;
	}

	/* scope    returns the first value item of a cluster with a specific parameter
	 * input    parameter
	 * input    clusters: a list of definition clusters
	 * output   the first value item of the cluster
	 */
	private String getClusterValue(String parameter, List<Cluster> clusters) {
		for (Cluster clr: clusters) {
			if (parameter == clr.parameter) {return clr.value[0];}
		}
		return null;
	}

	/* scope    returns the value list of a cluster with a specific parameter
	 * input    parameter
	 * input    clusters: a list of definition clusters
	 * output   the value list of the cluster */
	private List<String> getClusterValueList(String parameter, List<Cluster> clusters) {
		for (Cluster clr: clusters) {
			if (parameter == clr.parameter) {return clr.value;}
		}
		return null;
	}

	/* scope    returns the error message mapped to a search string
	 * input    text: the search string
	 * output   the error message */
	global String getError(String textID) {
		String searchTextID = textID.toLowerCase();
		for (Error err: this.errors) {
			if (err.text.toLowerCase() == searchTextID) {return err.errorMessage;}
		}
		return null;
	}

	/* scope    returns the default records of a related new FObject
	 * input    the records of the current FObject
	 * output   the default records */
	private Integer getDefaultRecords(Integer records) {
		Decimal defaultRecords;

		if (records <= 10) {defaultRecords = records;}
		else {defaultRecords = 10 + 0.1 * records;}

		return Integer.valueOf(defaultRecords);
	}

	/* scope    returns a list of the errors found during the process
	 * 			of creating the records of an FObject
	 * input    -
	 * output   the list of FObject errors */
	global List<String> getErrors() {
		List<String> errors = new List<String>();

		for (Error err: this.errors) {
			errors.add(err.errorMessage);
		}
		return errors;
	}

	/* scope    returns all field values from a field definition
	 * input    definition
	 * output   the list of field values */
	private List<String> getFieldValues(Definition definition) {
		List<String> fieldValues = new List<String>();
		List<Cluster> clusters = definition.clusters;
		DefinitionTypeId defID = definition.type.id;

		postDebug('fine', 'Definition Type Id: ' + defID);

		if (defID == DefinitionTypeId.fRandomNumber) {
			// get the first value item of the cluster containing parameter 'from'
			Decimal fromArgm = Decimal.valueOf(getClusterValue('from', clusters));
			// do the same for parameter 'to'
			Decimal toArgm = Decimal.valueOf(getClusterValue('to', clusters));
			// do the same for parameter 'scale'
			Integer scaleArgm = Integer.valueOf(getClusterValue('scale', clusters));
			// create random values
			fieldValues = getRandomNumbers(fromArgm, toArgm, scaleArgm);
		}  else if (defID == DefinitionTypeId.fRandomDate) {
			// get the first value item of the cluster containing parameter 'from'
			Date fromArgm = Date.valueOf(getClusterValue('from', clusters));
			// do the same for parameter 'to'
			Date toArgm = Date.valueOf(getClusterValue('to', clusters));
			// create random values
			fieldValues = getRandomDates(fromArgm, toArgm);
		} else if (defID == DefinitionTypeId.fRandomPicklist) {
			fieldValues = getRandomPicklistItems(definition.fieldName);
		} else if (defID == DefinitionTypeId.fRandomPicklistExcept) {
			// get the first value item of the cluster containing parameter 'except'
			Set<String> exceptions = new Set<String>(getClusterValueList('except', clusters));
			fieldValues = getRandomPicklistItemsExcept(definition.fieldName, exceptions);
		} else if (defID == DefinitionTypeId.fRandomList) {
			fieldValues = getRandomListItems(definition);
		} else if (defID == DefinitionTypeId.fRandomEmail) { // email
			String label = getClusterValue('value', clusters);
			fieldValues = getRandomEmails();
		} else if (defID == DefinitionTypeId.fRandomURL) { // URL
			String label = getClusterValue('value', clusters);
			fieldValues = getRandomURLs();
		} else if (defID == DefinitionTypeId.fRandomBoolean) { // boolean
			String label = getClusterValue('value', clusters);
			fieldValues = getRandomBooleans();
		} else if (defID == DefinitionTypeId.fRandomFirstName) { // first name
			String label = getClusterValue('value', clusters);
			fieldValues = getRandomFirstNames();
		} else if (defID == DefinitionTypeId.fRandomLastName) { // last name
			String label = getClusterValue('value', clusters);
			fieldValues = getRandomLastNames();
		} else if (defID == DefinitionTypeId.fRandomString) { // string
			Integer length = Integer.valueOf(getClusterValue('length', clusters));
			String startsWith = getClusterValue('startwith', clusters);
			List<String> includes = getClusterValueList('include', clusters);
			fieldValues = getRandomStrings(length, startsWith, includes);
		} else if (defID == DefinitionTypeId.fRandomText) { // text
			Integer words = Integer.valueOf(getClusterValue('words', clusters));
			fieldValues = getRandomTexts(words);
		} else if (defID == DefinitionTypeId.fRandomLookup) { // random lookup
			String source = getClusterValue('source', clusters);
			String lookupObject = getClusterValue('lookup', clusters);          
			String lookupField = getClusterValue('field', clusters);
			List<String> lookupValue = getClusterValueList('value', clusters);
			List<String> lookupExcept = getClusterValueList('except', clusters);
			fieldValues = getLookupItems('random', source, lookupObject, lookupField,
					lookupValue, null, lookupExcept);
		} else if (defID == DefinitionTypeId.fStaticLookup) { // static lookup
			String source = getClusterValue('source', clusters);
			String lookupObject = getClusterValue('lookup', clusters);          
			String lookupField = getClusterValue('field', clusters);
			String lookupValue = getClusterValue('value', clusters);
			fieldValues = getLookupItems('static', source, lookupObject, lookupField,
					null, lookupValue, null);
		}   else if (defID == DefinitionTypeId.fSerial) { //serial
			// get the first value item of the cluster containing parameter 'from'
			// and convert it to long
			Decimal fromArgm = long.valueOf(getClusterValue('from', clusters));
			// do the same for parameter 'step'
			Decimal stepArgm = long.valueOf(getClusterValue('step', clusters));
			// do the same for parameter 'scale'
			Integer scaleArgm = Integer.valueOf(getClusterValue('scale', clusters));
			// create serial values
			fieldValues = getSerialNumbers(fromArgm, stepArgm, scaleArgm);
		} else if (defID == DefinitionTypeId.fStatic) { // static
			String label = getClusterValue('value', clusters);
			fieldValues = getLabels(definition.fieldName, label);
		} else {
			addError(definition.script, 'Unknown Definition Type for definition [' +
					definition.definitionString + ']');
			fieldValues = null;
		}

		return fieldValues;
	}

	/* scope    returns a list of static text
	 * input    fieldName: the API name of a field
	 * input    label: the static text of the field values
	 * output   a list of (string) values */
	private List<String> getLabels(String fieldName, String label) {
		List<String> values = new List<String>();

		// handle record types
		if (fieldName == 'RecordTypeId') {
			// get the Id of this record type
			Id recordTypeId = this.recordTypesMap.get(label);
			// if record type does not exist
			if (recordTypeId == null) {
				// set an error and empty label
				addError(label, 'Unknown record type [' + label +']');
				label = '';
			} else { // record type is valid
				label = recordTypeId;
			}
		}

		// get the values
		for (Integer i = 0; i < this.records; i++) {
			values.add(label);
		}

		return values;
	}

	/* scope    returns a list of random booleans
	 * input    -
	 * output   a list of (string) values */
	private List<String> getRandomBooleans() {
		List<String> values = new List<String>();

		// get the values
		for (Integer i = 0; i < this.records; i++) {
			if (Math.random() > 0.5) {values.add('true');}
			else {values.add('false');}
		}

		return values;
	}

	/* scope    returns a list of random date/time
	 * input    fromDate:
	 * input    toDate:
	 * output   a list of (string) values */
	private List<String> getRandomDates(Date fromDate, Date toDate) {
		List<String> values = new List<String>();
		Datetime fromDatetime = fromDate;
		Datetime toDatetime = toDate;
		Long randomTime; // in ms

		Long fromTime = fromDatetime.getTime(); // ms from 1/1/1970
		Long toTime = toDatetime.getTime();

		if (fromDate > toDate) { // check if 'from' is less than 'to'
			Date temp = fromDate;
			fromDate= toDate;
			toDate = temp;
		}

		if (ToDate > Date.today()) // do not allow 'to' in the future
			ToDate = Date.today();

		// get the values
		Long range = toTime - fromTime;
		for (Integer i = 0; i < this.records; i++) {
			randomTime = fromTime + (Math.random() * range).longValue();
			values.add(String.valueOf(Datetime.newInstance(randomTime)));
		}

		return values;
	}

	/* scope    returns a list of random domains
	 * input    syllables: how many components(notes) the domain consists of
	 * output   a list of (string) values */
	private List<String> getRandomDomains(Integer syllables) {
		List<String> values = new List<String>();
		List<String> notes = new List<String> {'do', 're', 'mi', 'fa', 'sol', 'la', 'si'};
		String domain;

		// handle out of bounds
		if (syllables < 0) {syllables = 1;}
		else if (syllables > 7) {syllables = 7;}

		// get the values
		for (Integer i = 0; i < this.records; i++) {
			domain = '';
			// create domain
			for (Integer j = 0; j < syllables; j++) {
				Integer v = (Math.floor(Math.random() * 7)).intValue();
				domain += notes[v];
			}
			values.add(domain + '.com');
		}

		return values;
	}

	/* scope    returns a list of random emails
	 * input    -
	 * output   a list of (string) values */
	private List<String> getRandomEmails() {	
		List<String> values = new List<String>();
		List<String> includes = new List<String> {'lower'};
		List<String> names = getRandomStrings(10, 'lower', includes);
		List<String> domains = getRandomDomains(5);

		// get the values
		for (Integer i = 0; i < this.records; i++) {
			values.add(names[i] + '@' + domains[i]);
		}

		return values;
	}

	/* scope    returns a list of field values with random first name
	 * input    -
	 * output   a list of (string) values */
	private List<String> getRandomFirstNames() {
		List<String> values = new List<String>();

		// get the values
		for (Integer i = 0; i < this.records; i++) {
			//randomTime = fromTime + (Math.random() * range).longValue();
			String firstName = 'Firstname' + i;
			values.add(firstName);
		}

		return values;
	}

	/* scope    returns a list of field values with random last name
	 * input    -
	 * output   a list of (string) values */
	private List<String> getRandomLastNames() {
		List<String> values = new List<String>();

		// get the values
		for (Integer i = 0; i < this.records; i++) {
			//randomTime = fromTime + (Math.random() * range).longValue();
			String lastName = 'Lastname' + i;
			values.add(lastName);
		}

		return values;
	}

	/* scope    returns a list of random field values from a list
	 * input    definition
	 * output   a list of (string) values */
	private List<String> getRandomListItems(Definition definition) {
		List<String> values = new List<String>();

		// get list items
		List<String> listItems = getClusterValueList('value', definition.clusters);

		// get the size of the items list
		Integer count = listItems.size();

		// get the random values
		for (Integer i = 0; i < this.records; i++) {
			Integer v = (Math.floor(Math.random() * count)).intValue();
			values.add(listItems[v]);
		}

		return values;
	}

	/* scope    creates an Id list of random lookup object's records
	 * input    type: random or static
	 * input    source:
	 * input    lookupObject:
	 * input    lookupField:
	 * input    lookupValue:
	 * input    lookupExcept:
	 * output   a list of (Id) values */
	private List<Id> getLookupItems(String type, String source, String lookupSObject, String lookupField,
			List<String> lookupValues, String lookupValue, List<String> lookupExcept) {  
		List<Id> values = new List<Id>(); // the output values
		List<SObject> lookupRecords = new List<SObject>(); // the lookup SObject's records	
		List<Database.SaveResult> saveResults = new List<Database.SaveResult>();

		// clear lookup Object
		lookupSObject = lookupSObject.trim();
		lookupSObject = lookupSObject.toLowerCase();

		// check if object is valid
		if (!objectNameIsValid(lookupSObject)) {
			addError(lookupSObject, 'Invalid Lookup SObject [' + lookupSObject + ']');
		}

		if (processMustTerminate()) {return null;}

		if (source == 'forceea') {
			// check if object is defined
			Boolean objectIsDefined = false;
			for (String obj: objects) {
				if (obj == lookupSObject) {
					objectIsDefined = true;
					break;
				}
			}
			if (objectIsDefined) { // if SObject exists
				// *** check if field is valid ***

				// get the list of created records
				lookupRecords = globalRecordsMap.get(lookupSObject);              
			} else { // create the SObject
				postDebug('info', 'SObject [' + lookupSObject + '] is not defined internally');
				FObject newObject = new FObject(lookupSObject);
				newObject.setRequiredFields = true;
				// set records
				newObject.records = getDefaultRecords(this.records);		
				// set lookup field's definition
				if (lookupField != null) {
					Field fld = objectFieldsMap.get(lookupField);
					setDefinitionFromField(fld);
				}
				// insert records
				saveResults = newObject.insertRecords();
				// get lookupRecords - otherwise get nothing
				lookupRecords = newObject.getRecords();
			}
		}

		if ((lookupRecords.isEmpty()) || (source == 'salesforce')) {
			String soql;
			//query the database and get the Ids
			if (lookupField == null) {soql = 'SELECT Id';}
			else {soql = 'SELECT Id, ' + lookupField;}
			soql += ' FROM ' + lookupSObject + ' LIMIT 10000';
			try {
				lookupRecords = Database.query(soql);
			} catch (QueryException ex) {
				addError(soql, 'Selecting lookup SObject [' + lookupSObject +
						'] for SObject [' + this.objectName + ']: ' + ex.getMessage());
			}
		}

		if (type == 'static') {
			Id lookupId;
			for (SObject sobj: lookupRecords) {
				if (sobj.get(lookupField) == lookupValue) {
					lookupId = sobj.Id;
					break;
				}
			}
			// get the values
			for (Integer i = 0; i < this.records; i++) {
				// add the Id to the output list
				values.add(lookupId);
			}
		} else if (type == 'random') {			
			List<Id> lookupIds = new List<Id>();
			if ((lookupValues == null) && (lookupExcept == null)) {
				// random lookup() source()
				for (SObject sobj: lookupRecords) {     
					lookupIds.add(sobj.Id); //add Id to list
				}
			} else if ((lookupValues != null) && (lookupExcept == null)) {
				// random lookup() field() value() source()
				for (String str: lookupValues) {
					for (SObject sobj: lookupRecords) {
						if (sobj.get(lookupField) == str) { // if value is found
							lookupIds.add(sobj.Id); //add Id to list
						}
					}
				}
			} else if ((lookupValues == null) && (lookupExcept != null)) {
				// random lookup() field() except() source()
				for (String str: lookupExcept) {
					for (SObject sobj: lookupRecords) {
						if (sobj.get(lookupField) != str) { // if value is not found
							lookupIds.add(sobj.Id); //add Id to list
						}
					}
				}
			} else {addError('Lookup', 'Invalid Lookup Type');}

			// get the values
			Integer count = lookupIds.size();
			Integer v;
			for (Integer i = 0; i < this.records; i++) {
				// get a random position
				v = (Math.floor(Math.random() * count)).intValue();
				// add the Id to the output list
				values.add(lookupIds[v]);
			}
		} // else if: random

		return values;
	}

	/* scope    returns a list of random numbers
	 * input    fromNumber
	 * input    toNumber
	 * input    scale
	 * output   a list of (string) values */
	private List<String> getRandomNumbers(
			Decimal fromNumber, Decimal toNumber, Integer scale) {
		List<String> values = new List<String>();
		fromNumber = fromNumber.setScale(scale);
		toNumber = toNumber.setScale(scale);

		// raise an error if fromNumber is bigger than or equal to toNumber
		if (fromNumber >= toNumber) {
			Decimal temp = toNumber;
			toNumber = fromNumber;
			fromNumber = temp;
		}

		// get the values
		Decimal range = toNumber - fromNumber;
		for (Integer i = 0; i < this.records; i++) {
			Decimal v = fromNumber + Math.random() * range;
			v = v.setScale(scale);
			values.add(v.toPlainString());
		}

		return values;
	}

	/* scope    returns a list of random picklist items
	 * input    fieldName: the API name of a field
	 * output   a list of (string) values */
	private List<String> getRandomPicklistItems(String fieldName) {
		List<String> picklistItems = new List<String>(); // the picklist items
		List<String> values = new List<String>(); // the output values

		// handle record type
		if (fieldName == 'RecordTypeId') {
			// create a new list with object's record type values
			List<Id> recordTypeIDs = new List<Id>(this.recordTypesMap.values());
			// count how many record types exist
			Integer count = recordTypeIDs.size();
			// get the random record type IDs
			for (Integer i = 0; i < this.records; i++) {
				Integer v = (Math.floor(Math.random() * count)).intValue();
				values.add(recordTypeIDs.get(v));
			}

			return values;
		}

		// if the field is not a record type, get the picklist items
		List<Schema.PicklistEntry> picklistValues = this.objectFieldsMap.get(fieldName).pickListValues;
		for (Schema.PicklistEntry e: picklistValues) {
			picklistItems.add(e.getLabel());
		}

		// get the values
		Integer count = picklistItems.size();
		for (Integer i = 0; i < this.records; i++) {
			Integer v = (Math.floor(Math.random() * count)).intValue();
			values.add(picklistItems[v]);
		}

		return values;
	}

	/* scope    returns a list of random picklist items except certain values
	 * input    fieldName: the API name of a field
	 * input    exceptions: a list of exception from the picklist items
	 * output   a list of (string) values */
	private List<String> getRandomPicklistItemsExcept(String fieldName, Set<string> exceptions) {
		List<String> picklistItems = new List<String>(); // the picklist items
		List<String> values = new List<String>(); // the output values

		// handle record type
		if (fieldName == 'RecordTypeId') {
			// create a new list with record type values, excluding exceptions
			List<Id> recordTypeIDs = new List<Id>();
			for (String rt: this.recordTypesMap.keySet()) {
				for (String ex: exceptions) {
					if (rt == ex) {recordTypeIDs.add(this.recordTypesMap.get(ex));}
				}
			}
			// count how many record types exist
			Integer count = recordTypeIDs.size();
			// get the random record type IDs
			for (Integer i = 0; i < this.records; i++) {
				Integer v = (Math.floor(Math.random() * count)).intValue();
				values.add(recordTypeIDs.get(v));
			}

			return values;
		}

		// if the field is not a record type, get the picklist items
		List<Schema.PicklistEntry> picklistValues = this.objectFieldsMap.get(fieldName).pickListValues;
		for (Schema.PicklistEntry ple: picklistValues) {
			String label = ple.getLabel();
			if (!exceptions.contains(label)) { // exclude exceptions
				picklistItems.add(label);
			}
		}

		// get the values
		Integer count = picklistItems.size();
		for (Integer i = 0; i < this.records; i++) {
			Integer v = (Math.floor(Math.random() * count)).intValue();
			values.add(picklistItems[v]);
		}

		return values;
	}

	/* scope    returns a list of random strings
	 * input    -
	 * output   a list of (string) values */
	public List<String> getRandomStrings(
			Integer length, String startsWith, List<String> includes) {
		List<String> values = new List<String>(); // the output values
		String lowerChars = 'abcdefghijklmnopqrstuvwxyz';
		String upperChars = 'ABCDEFGHIJKLMNOPQRSUVWXYZ';
		String digits = '0123456789';
		String charsToSelect = ''; // the selection chars for the rest of the string
		String firstCharString = ''; // the first char of the string
		String restChars; // the rest chars of the string
		Integer v; //  a random position
		Integer count; // the size of a string

		// define chars
		for (String ch: includes) {
			if (ch == 'lower') {charsToSelect += lowerChars;}
			else if (ch == 'upper') {charsToSelect += upperChars;}
			else if (ch == 'digit') {charsToSelect += digits;}
		}

		// get the values	
		for (Integer i = 0; i < this.records; i++) {
			// get 1st char
			String firstChar;
			if (startsWith == 'lower') {firstCharString = lowerChars;}
			else if (startsWith == 'upper') {firstCharString = upperChars;}
			else if (startsWith == 'digit') {firstCharString = digits;}

			count = firstCharString.length();
			v = (Math.floor(Math.random() * count)).intValue();
			firstChar = firstCharString.substring(v, v + 1);

			// get the rest
			count = charsToSelect.length();
			restChars = '';
			for (Integer j = 1; j < length; j++) {
				v = (Math.floor(Math.random() * count)).intValue();
				restChars += charsToSelect.substring(v, v + 1);
			}
			values.add(firstChar + restChars);
		}
		return values;
	}

	/* scope    returns a list of random strings
	 * input    -
	 * output   a list of (string) values */
	private List<String> getRandomTexts(Integer words) {
		List<String> values = new List<String>();

		List<String> wordList = new List<String> {
			'lorem', 'ipsum', 'dolor', 'sit', 'amet', 'tempor', 'abhorreant', 'instructior', 'eu',
			'no', 'quo', 'magna', 'primis', 'labore', 'usu', 'virtute', 'fabellas', 'vis', 'duis',
			'scripta', 'salutandi', 'laudem', 'commune', 'nam', 'laoreet', 'propriae', 'corrumpit',
			'ea', 'partem', 'inermis', 'conclusionemque', 'ius', 'sint', 'impedit',
			'deterruisset', 'eam', 'ex', 'elit', 'nusquam'};

			Integer count = wordList.size();

			// get the values
			for (Integer i = 0; i < this.records; i++) {
				String txt = '';
				for (Integer j = 0; j < words; j++) {
					Integer v = (Math.floor(Math.random() * count)).intValue();
					txt += wordList[v] + ' ';
				}
				txt = txt.trim();
				values.add(txt.capitalize());
			}

			return values;
	}

	/* scope    returns a list of random URLs
	 * input    -
	 * output   a list of (string) values */
	private List<String> getRandomURLs() {
		List<String> values = new List<String>();
		List<String> domains = getRandomDomains(5);
		String url;

		// get the values
		for (Integer i = 0; i < this.records; i++) {
			values.add('http://www.' + domains[i]);
		}

		return values;
	}

	/* scope    returns a list of created SObject records
	 * input    -
	 * output   a list of SObject records */
	global List<SObject> getRecords() {
		// if no records have been created, do it
		if (this.createdRecords.isEmpty()) {
			createRecords();
		}

		if (processIsValid) {
			return this.createdRecords;
		} else {
			return null;
		}
	}

	/* scope    returns a list of serial numbers
	 * input    fromNumber: 
	 * input    stepNumber:
	 * input    scale:
	 * output   a list of (string) values */
	private List<String> getSerialNumbers(Decimal fromNumber, Decimal stepNumber, Integer scale) {
		List<String> values = new List<String>();
		Decimal v = fromNumber;

		// get the values
		for (Integer i = 0; i < this.records; i++) {
			v = v.setScale(scale);
			values.add(v.toPlainString());
			v += stepNumber;
		}

		return values;
	}

	/* scope    initializes the Field Values Matrix (FVM)
	 * input    -
	 * output   - */
	private void initializeFieldValuesMatrix() {
		for (Integer i = 0; i < this.fieldSet.size(); i++) {
			this.fieldValuesMatrix.add(new List<String>());
			for (Integer j = 0; j < this.records; j++) {
				this.fieldValuesMatrix[i].add('');
			}
		}
	}

	/* scope    inserts the created SObject records
	 * input    allOrNone: true if the operation will fail if any record fails to insert
	 * output   a list of Database.SaveResult */
	global List<Database.SaveResult> insertRecords() {
		if (processMustTerminate()) {return null;}

		List<Database.SaveResult> saveResults = new List<Database.SaveResult>();
		Integer numRecordsInserted = 0;

		// create records, if the haven't been created
		if (this.createdRecords.isEmpty()) {createRecords();}

		// do not allow inserting records of User SObject 
		if (!Test.isRunningTest() && (this.objectName == 'user')) {
			postDebug('warn', 'Will not insert records for SObject [' + this.objectName + ']');
			return null;
		}

		// insert records
		postDebug('info', 'Will insert the created records of SObject [' +
				this.objectName + ']');
		saveResults = Database.insert(this.createdRecords, false);

		// iterate through each returned result
		for (Database.SaveResult sr: saveResults) {
			if (sr.isSuccess()) {
				numRecordsInserted++;
			} else {
				// Operation failed, so get all errors                
				for (Database.Error err : sr.getErrors()) {
					addError(this.objectName, err.getMessage() + '. ' +
							'Fields that affected this error: ' + err.getFields());
				}
			}
		}

		// if there are no errors, display a message
		if (numRecordsInserted == this.createdRecords.size()) {
			postDebug('info', 'Successfully inserted ' + this.createdRecords.size() +
					' [' + this.objectName + '] records');
		} else { // there are errors
			Integer numErrorsFound = this.createdRecords.size() - numRecordsInserted;
			addError(this.objectName, 'Found ' + numErrorsFound + ' errors inserting [' +
					+ this.objectName + '] records');
		}

		return saveResults;
	}

	/* scope    checks if the API name of an SObject is valid
	 * input    objectName: the API name of the SObject
	 * output   true if SObject's API name is valid */
	private boolean objectNameIsValid(string objectName) {
		try {
			SObject sObj = Schema.getGlobalDescribe().get(objectName).newSObject();
			objects.add(this.objectName); // add this object to list
			return true;
		} catch (Exception ex) {
			return false;
		}
	}

	/* scope    check if a cluster parameter is valid
	 * input    parameter: the parameter of the cluster
	 * output   true if parameter is valid */
	private Boolean parameterIsValid(String parameter) {
		if (parametersSet.contains(parameter)) {
			return true;
		} else {
			return false;
		}
	}

	/* scope    posts a System.debug message
	 * input    errorLevel: the System.LoggingLevel enum
	 * input    message: the message to post
	 * output   - */
	private static void postDebug(String errorLevel, String message) {
		if (!debugMode) return;

		System.LoggingLevel level;
		Boolean showDebugMessage = true;

		// prepare errorLevel
		errorLevel = errorLevel.trim();
		errorLevel = errorLevel.toLowerCase();

		// select logging level
		if (errorLevel == 'error') {level = LoggingLevel.ERROR;}
		else if (errorLevel == 'warn') {level = LoggingLevel.WARN;}
		else if (errorLevel == 'info') {level = LoggingLevel.INFO;}
		else if (errorLevel == 'debug') {level = LoggingLevel.DEBUG;}
		else if ((errorLevel == 'fine') && (DEVELOPMENT_MODE)) {level = LoggingLevel.FINE;}
		else {showDebugMessage = false;}

		// show debug message
		if (showDebugMessage) {System.debug(level, 'FORCEEA ' + message);}
	}

	/* scope    terminates the process if it is invalid
	 * input    -
	 * output   true if process must terminate (is invalid) */
	private Boolean processMustTerminate() {    
		if (!processIsValid) {
			postDebug('error','***  Process is invalid and will terminate ***');
			//postDebug('error', 'The following errors were found:');
			//for (Error err: this.errors) {postDebug('error', '- ' + err.errorMessage);}

			if (Test.isRunningTest()) {return true;}
			else {
				throw new ForceeaException('Process is invalid and will terminate.');
				return true;
			}
		} else {return false;}
	}

	/* scope    resets the CPU timer and displays information
	 *          about the elapsed time (in ms) since the previous reset
	 * input    text: the message to display
	 * output   - */
	private void resetModuleTimer(String text) {
		postDebug('info', '@ ' + text + ' for SObject [' + this.objectName + '] in ' +
				this.moduleDuration +  ' ms');
		this.moduleStartTime = Limits.getCpuTime();
	}

	/* scope    declares a field definition
	 * input    fieldName: the API name of a field
	 * input    script: the definition script, e.g. random from(1) to(1000) scale(0)
	 * output   - */
	global void setDefinition(String fieldAPIName, String definition) {
		if (!processIsValid) return;

		// clear field name
		fieldAPIName = fieldAPIName.toLowerCase();
		fieldAPIName = fieldAPIName.trim();
		definition = definition.trim();

		// declare definition
		Definition def = new Definition(fieldAPIName, definition);
		this.fieldSet.add(fieldAPIName);
		this.definitions.add(def);
		postDebug('debug', 'Registered field [' + def.fieldName +
				'] on definition [' + def.definitionString + ']');
	}

	/* scope    sets a Definition using data from a Field
	 * input    field
	 * output   - */
	private void setDefinitionFromField(Field field) {
		// if SObject is Contact or Lead, set definitions of First Name and Last Name
		if ((this.objectName == 'contact') || (this.objectName == 'case')) {
			if (field.fieldName == 'firstname') {
				setDefinition(field.fieldName, 'random type(firstname)');
				return;
			} else if (field.fieldName == 'lastname') {
				setDefinition(field.fieldName, 'random type(lastname)');
				return;
			}
		}

		if (field.type == Schema.DisplayType.Integer) { // Integer
			setDefinition(field.fieldName, 'random from(1) to(100) scale(0)');
		} else if ((field.type == Schema.DisplayType.Currency) ||
				(field.type == Schema.DisplayType.Double)) { // Currency or Double
			setDefinition(field.fieldName, 'random from(1000) to(10000) scale(3)');
		} else if ((field.type == Schema.DisplayType.Date) ||
				(field.type == Schema.DisplayType.DateTime)) { // Date or DateTime
			setDefinition(field.fieldName, 'random from(2010-01-01) to(2016-12-31)');
		} else if ((field.type == Schema.DisplayType.Picklist) ||
				(field.type == Schema.DisplayType.MultiPicklist)) { // Picklist or MultiPicklist
			setDefinition(field.fieldName, 'random type(picklist)');
		} else if (field.type == Schema.DisplayType.Address) { // Address
			//setDefinition(field.fieldName, 'static value(' + field.label + ')');
			//setDefinition(field.fieldName, 'serial from(1) step(1) scale(0)');
		} else if (field.type == Schema.DisplayType.String) { // String
			setDefinition(field.fieldName, 'static value(' + field.fieldName + ')');
			setDefinition(field.fieldName, 'serial from(1) step(1) scale(0)');
		} else if (field.type == Schema.DisplayType.TextArea) { // TextArea
			setDefinition(field.fieldName, 'random type(text) words(20)');
		} else if (field.type == Schema.DisplayType.Percent) { // Percent
			setDefinition(field.fieldName, 'random from(0) to(1) scale(3)');
		} else if (field.type == Schema.DisplayType.Reference) { // Reference
			setDefinition(field.fieldName, 'random lookup(' + field.parents[0] + ') source(forceea)');
		} else if (field.type == Schema.DisplayType.Boolean) { // Boolean
			setDefinition(field.fieldName, 'random type(boolean)');
		} else if (field.type == Schema.DisplayType.Email) { // Email
			setDefinition(field.fieldName, 'random type(email)');
		} else if (field.type == Schema.DisplayType.Phone) { // Phone
			//setDefinition(field.fieldName, 'random type(phone)');
		} else if (field.type == Schema.DisplayType.URL) { // URL
			setDefinition(field.fieldName, 'random type(url)');
		}
	}

	/* scope    declares all required fields of the SObject
	 * input    -
	 * output   - */
	private void setDefinitionOfRequiredFields() {
		if (!setRequiredFields) {return;}
		postDebug('info', 'Will set the definition of required fields');       

		// copy fieldSet to a new set
		Set<String> definedFieldSet = new Set<String>(fieldSet);

		if (this.objectName == 'user') {
			List<String> fieldNames = new List<String> ();
			List<String> definitions = new List<String> ();
			postDebug('info', 'SObject is [' + this.objectName + '] and specific fields will be defined.');

			// prepare field definition lists
			fieldNames.add('Alias'); definitions.add('random type(string) length(8) startwith(upper) include(lower)');
			fieldNames.add('Lastname'); definitions.add('random type(lastname)');
			fieldNames.add('Username'); definitions.add('random type(email)');
			fieldNames.add('Email'); definitions.add('random type(email)');
			fieldNames.add('EmailEncodingKey'); definitions.add('static value(UTF-8)');
			fieldNames.add('TimeZonesIdKey'); definitions.add('static value(GMT)');
			fieldNames.add('LocalesIdKey'); definitions.add('static value(en_US)');
			fieldNames.add('LanguageLocaleKey'); definitions.add('static value(en_US)');
			fieldNames.add('ProfileId'); definitions.add('static lookup(Profile) field(Name) value(Standard User) source(salesforce)');

			// set field definitions
			for (Integer i = 0; i < fieldNames.size(); i++) {
				if (!definedFieldSet.contains(fieldNames[i].toLowerCase())) { // if field is not defined
					//setDefinition(objectFieldsMap.get(fieldNames[i]).fieldName, definitions[i]);
					//System.debug(fieldNames[i] + ' > ' + definitions[i]);
					setDefinition(fieldNames[i], definitions[i]);
				}
			}          
		} else { // SObject is anything else
			// for each Field in the fields map
			for (Field fld: this.objectFieldsMap.values()) {
				// if field is required and is not defined yet
				if (fld.isRequired && (!fieldSet.contains(fld.fieldName))) {
					setDefinitionFromField(fld);  // set a new definition for this Field  
				}       
			}
		}
	}

	/* scope    declares all Definition Types
	 * input    -
	 * output   - */
	private static void setDefinitionTypes() {
		DefinitionType dt;

		// RandomNumber
		// scope        create random numbers between two numbers
		// example      random from(10k) to(100m) scale(0)
		dt = new DefinitionType(DefinitionTypeId.fRandomNumber, 'RandomNumber', 'random');
		dt.clusterTypes.add(new ClusterType('from', ValueType.fDec, null, false));
		dt.clusterTypes.add(new ClusterType('to', ValueType.fDec, null, false));
		dt.clusterTypes.add(new ClusterType('scale', ValueType.fInt, null, false));
		definitionTypes.add(dt);

		// RandomDate
		// scope        create random datetime values between two dates
		// example      random from(2010-01-01) to(2015-12-31)
		// Datetime     format: yyyy-MM-dd HH:mm:ss
		dt = new DefinitionType(DefinitionTypeId.fRandomDate, 'RandomDate', 'random');
		dt.clusterTypes.add(new ClusterType('from', ValueType.fDate, null, false));
		dt.clusterTypes.add(new ClusterType('to', ValueType.fDate, null, false));
		definitionTypes.add(dt);

		// RandomPicklist
		// scope        create random picklist values from existing picklist
		// example      random type(list)
		dt = new DefinitionType(DefinitionTypeId.fRandomPicklist, 'RandomPicklist', 'random');
		dt.clusterTypes.add(new ClusterType('type', ValueType.fText, 'picklist', false));
		definitionTypes.add(dt);

		// RandomPicklistExcept
		// scope        create picklist value, select random item from existing picklist
		//              except from specific items
		// example      random type(list) except(a,b,c)
		dt = new DefinitionType(DefinitionTypeId.fRandomPicklistExcept, 'RandomPicklistExcept', 'random');
		dt.clusterTypes.add(new ClusterType('type', ValueType.fText, 'picklist', false));
		dt.clusterTypes.add(new ClusterType('except', ValueType.fText, null, true));
		definitionTypes.add(dt);

		// RandomBoolean
		// scope        create random boolean values
		// example      random type(boolean)
		dt = new DefinitionType(DefinitionTypeId.fRandomBoolean, 'RandomBoolean', 'random');
		dt.clusterTypes.add(new ClusterType('type', ValueType.fBoolean, 'boolean', false));
		definitionTypes.add(dt);

		// RandomEmail
		// scope        create random email values
		// example      random type(email)
		dt = new DefinitionType(DefinitionTypeId.fRandomEmail, 'RandomEmail', 'random');
		dt.clusterTypes.add(new ClusterType('type', ValueType.fText, 'email', false));
		definitionTypes.add(dt);

		// RandomFirstName
		// scope        create random first names
		// example      random type(firstname)
		dt = new DefinitionType(DefinitionTypeId.fRandomFirstName, 'RandomFirstName', 'random');
		dt.clusterTypes.add(new ClusterType('type', ValueType.fText, 'firstname', false));
		definitionTypes.add(dt);

		// RandomLastName
		// scope        create random last names
		// example      random type(lastname)
		dt = new DefinitionType(DefinitionTypeId.fRandomLastName, 'RandomLastName', 'random');
		dt.clusterTypes.add(new ClusterType('type', ValueType.fText, 'lastname', false));
		definitionTypes.add(dt);

		// RandomString
		// scope        create random strings
		// example      random type(string)
		dt = new DefinitionType(DefinitionTypeId.fRandomString, 'RandomString', 'random');
		dt.clusterTypes.add(new ClusterType('type', ValueType.fText, 'string', false));
		dt.clusterTypes.add(new ClusterType('length', ValueType.fInt, null, false));
		dt.clusterTypes.add(new ClusterType('startwith', ValueType.fText, null, false));
		dt.clusterTypes.add(new ClusterType('include', ValueType.fText, null, true));
		definitionTypes.add(dt);

		// RandomText
		// scope        create random texts
		// example      random type(text)
		dt = new DefinitionType(DefinitionTypeId.fRandomText, 'RandomText', 'random');
		dt.clusterTypes.add(new ClusterType('type', ValueType.fText, 'text', false));
		dt.clusterTypes.add(new ClusterType('words', ValueType.fInt, null, false));
		definitionTypes.add(dt);

		// RandomURL
		// scope        create random URLs
		// example      random type(url)
		dt = new DefinitionType(DefinitionTypeId.fRandomURL, 'RandomURL', 'random');
		dt.clusterTypes.add(new ClusterType('type', ValueType.fURL, 'url', false));
		definitionTypes.add(dt);

		// RandomLookupInternal(Forceea)
		// scope        create lookup(Id) value, select random item from other object
		// example      random lookup(Account) source(internal)
		dt = new DefinitionType(DefinitionTypeId.fRandomLookup, 'RandomLookupInternal', 'random');
		dt.clusterTypes.add(new ClusterType('lookup', ValueType.fText, null, false));
		dt.clusterTypes.add(new ClusterType('source', ValueType.fText, 'forceea', false));
		definitionTypes.add(dt);

		// RandomLookupInternalValue(Forceea)
		// scope        create lookup(Id) value, select random item from other object
		// example      random lookup(Account) field(Name) value(Company XYZ) source(internal) 
		dt = new DefinitionType(DefinitionTypeId.fRandomLookup, 'RandomLookupInternalValue', 'random');
		dt.clusterTypes.add(new ClusterType('lookup', ValueType.fText, null, false));
		dt.clusterTypes.add(new ClusterType('field', ValueType.fText, null, false));
		dt.clusterTypes.add(new ClusterType('value', ValueType.fText, null, true));
		dt.clusterTypes.add(new ClusterType('source', ValueType.fText, 'forceea', false));
		definitionTypes.add(dt);

		// RandomLookupInternalExcept(Forceea)
		// scope        
		// example      random lookup(Account) field(Name) value(Company XYZ) source(internal) 
		dt = new DefinitionType(DefinitionTypeId.fRandomLookup, 'RandomLookupInternalExcept', 'random');
		dt.clusterTypes.add(new ClusterType('lookup', ValueType.fText, null, false));
		dt.clusterTypes.add(new ClusterType('field', ValueType.fText, null, false));
		dt.clusterTypes.add(new ClusterType('except', ValueType.fText, null, true));
		dt.clusterTypes.add(new ClusterType('source', ValueType.fText, 'forceea', false));
		definitionTypes.add(dt);

		// RandomLookupExternal(Salesforce)
		// scope        create random lookup(Id) values
		// example      random lookup(Account) source(external)
		dt = new DefinitionType(DefinitionTypeId.fRandomLookup, 'RandomLookupExternal', 'random');
		dt.clusterTypes.add(new ClusterType('lookup', ValueType.fText, null, false));
		dt.clusterTypes.add(new ClusterType('source', ValueType.fText, 'salesforce', false));
		definitionTypes.add(dt);

		// RandomLookupExternalValue(Salesforce)
		// scope        create lookup(Id) value, select random item from other object
		// example      random lookup(Account) field(Name) value(Company XYZ) source(external) 
		dt = new DefinitionType(DefinitionTypeId.fRandomLookup, 'RandomLookupExternalValue', 'random');
		dt.clusterTypes.add(new ClusterType('lookup', ValueType.fText, null, false));
		dt.clusterTypes.add(new ClusterType('field', ValueType.fText, null, false));
		dt.clusterTypes.add(new ClusterType('value', ValueType.fText, null, true));
		dt.clusterTypes.add(new ClusterType('source', ValueType.fText, 'salesforce', false));
		definitionTypes.add(dt);

		// RandomLookupExternalExcept(Salesforce)
		// scope        
		// example      random lookup(Account) field(Name) value(Company XYZ) source(external) 
		dt = new DefinitionType(DefinitionTypeId.fRandomLookup, 'RandomLookupExternalExcept', 'random');
		dt.clusterTypes.add(new ClusterType('lookup', ValueType.fText, null, false));
		dt.clusterTypes.add(new ClusterType('field', ValueType.fText, null, false));
		dt.clusterTypes.add(new ClusterType('except', ValueType.fText, null, true));
		dt.clusterTypes.add(new ClusterType('source', ValueType.fText, 'salesforce', false));
		definitionTypes.add(dt);

		// RandomList
		// scope        create picklist value, select random item from a list
		// example      random type(list) value(a,b,c)
		dt = new DefinitionType(DefinitionTypeId.fRandomList, 'RandomList', 'random');
		dt.clusterTypes.add(new ClusterType('type', ValueType.fText, 'list', false));
		dt.clusterTypes.add(new ClusterType('value', ValueType.fText, null, true));
		definitionTypes.add(dt);

		// Static
		// scope        create value, select specific Text value
		// example      static value(abc)
		dt = new DefinitionType(DefinitionTypeId.fStatic, 'Static', 'static');
		dt.clusterTypes.add(new ClusterType('value', ValueType.fText, null, false));
		definitionTypes.add(dt);

		// StaticLookupInternal(Forceea)
		// scope        create lookup(Id) value, select random item from other object
		// example      static lookup(Account) field(Name) value(Company XYZ) source(internal) 
		dt = new DefinitionType(DefinitionTypeId.fStaticLookup, 'StaticLookupInternal', 'static');
		dt.clusterTypes.add(new ClusterType('lookup', ValueType.fText, null, false));
		dt.clusterTypes.add(new ClusterType('field', ValueType.fText, null, false));
		dt.clusterTypes.add(new ClusterType('value', ValueType.fText, null, false));
		dt.clusterTypes.add(new ClusterType('source', ValueType.fText, 'forceea', false));
		definitionTypes.add(dt);

		// StaticLookupExternal(Salesforce)
		// scope        create lookup(Id) value, select random item from other object
		// example      static lookup(Account) field(Name) value(Company XYZ) source(external) 
		dt = new DefinitionType(DefinitionTypeId.fStaticLookup, 'StaticLookupExternal', 'static');
		dt.clusterTypes.add(new ClusterType('lookup', ValueType.fText, null, false));
		dt.clusterTypes.add(new ClusterType('field', ValueType.fText, null, false));
		dt.clusterTypes.add(new ClusterType('value', ValueType.fText, null, false));
		dt.clusterTypes.add(new ClusterType('source', ValueType.fText, 'salesforce', false));
		definitionTypes.add(dt);

		// Serial
		// scope            create value, select specific Numeral value sequentially with 0 decimal
		// example      serial from(10.2) step(1.2) decimal(1)
		dt = new DefinitionType(DefinitionTypeId.fSerial, 'Serial', 'serial');
		dt.clusterTypes.add(new ClusterType('from', ValueType.fDec, null, false));
		dt.clusterTypes.add(new ClusterType('step', ValueType.fDec, null, false));
		dt.clusterTypes.add(new ClusterType('scale', ValueType.fInt, null, false));
		definitionTypes.add(dt);
	}

	/* scope    declares a variable
	 * input    type:
	 * input    name:
	 * input    definition
	 * output   - */
	private void setVariable(String type, String name, String definition) {
		Variable var = new Variable(type, name, definition);
		this.variables.add(var);
	}

	/* scope    dispays Field Value Matrix values
	 * input    -
	 * output   - */
	private void showFVM() {
		postDebug('info', 'Will display Field Values Matrix');
		Integer i = 0;
		Integer count;

		for (String fld: fieldSet) { // for each field
			String str = '';

			// display up to 100 records
			if (this.records < 101) {count = this.records;}
			else {count = 100;}

			for (Integer j = 0; j < count; j++) { // for each record
				str += this.fieldValuesMatrix[i][j] + ' | ';
			}
			i++;
			postDebug('debug', 'Created sample data for field [' + fld + ']: ' + str.removeEnd('| '));
		}
	}

	/* scope    checks if a the Value of a Cluster is valid
	 *          value examples: (5) (Test) (1,2,3,4) (test1,test2)
	 * input    clusterType: a Cluster Type
	 * input    cluster: the Cluster to validate
	 * output   true if value is valid */
	private Boolean valueIsValid(ClusterType clusterType, Cluster cluster) {        
		String valueText = cluster.value[0]; // the initial Value text
		List<String> valueItems = new List<String>(); // the list of Value items
		String remainingValue = cluster.value[0]; // the unprocessed part of Value text

		// initialize remaining Value
		remainingValue += ',';
		postDebug('fine', 'value is [' + remainingValue +']');

		// seperate Value to items
		Integer count = 0; // a counter
		do {
			String valueItem = remainingValue.substringBefore(','); // get the Value item
			//valueItem = valueItem.trim();
			valueItems.add(valueItem); // add item to the list
			remainingValue = remainingValue.removeStart(valueItem + ','); // get remaining text
			postDebug('fine', 'value item (' + count + ') is [' + valueItem + ']');
			count++;
		} while (String.isNotEmpty(remainingValue));

		// if Value must have only 1 item but it has more
		if (!clusterType.multipleValueItems && valueItems.size() > 1) {
			addError(cluster.value[0], 'Value [' + valueText + '] should not have many items.');
			return false;
		}

		// Value has the correct number of items
		// which may be 1 or more than 1, so set Value items
		cluster.value = valueItems; // // add items to Value list

		if ((clusterType.value != null) && (clusterType.value!= valueText)) {
			// this is not an error
			postDebug('fine', 'parameter [type] has not a correct value');
			return false;
		}

		// check Value type (e.g. number, text) of all Value items
		for (String cv: cluster.value) {     
			if (clusterType.valueType == valueType.fInt) { // is Integer
				Integer intValue;
				try {intValue = Integer.valueOf(cv);}
				catch (System.TypeException ex) {return false;}
			} else if (clusterType.valueType == valueType.fDec) { // is Decimal
				Decimal decValue;
				try {decValue = Decimal.valueOf(cv);}
				catch (System.TypeException ex) {return false;}
			} else if (clusterType.valueType == valueType.fDate) { // is Date
				Date dateValue;
				try {dateValue = Date.valueOf(cv);}
				catch (System.TypeException ex) {return false;}
			}
		}

		return true;
	}
}
