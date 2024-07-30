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
 * @description Handles the Dadela field definitions.
 */
@SuppressWarnings('PMD.FieldDeclarationsShouldBeAtStart')
public with sharing class ForceeaDefinition {

    /* CONSTANTS */

    private static final Integer DEFINITION_ID_LENGTH = 5;
    /**
     * @description The lookup types used in serial lookup.
     */
    private static final Set<String> LOOKUP_MODES = new Set<String>{
        'cyclical', 'first', 'last', 'null', 'permutation'
    };
    /**
     * @description The pseudo-random number.
     */
    private static final Double RANDOM { // NOPMD
        get {
            Integer bits = 32;
            seed = (seed * 25214903917L + 11L) & ((1L << 48) - 1L);
            Long uInt = (Long) (seed >>> (48 - bits));
            return (Double) (((Double) uInt + 1.0) * 0.0000000002328306435454494);
        }
    }

    /* COLLECTIONS */

    /**
     * @description The set of checksum strings of field definitions. A checksum is calculated
     *   using random letters with a seed number from the hashCod of the lowercase definition string.
     */
    private static Set<String> checksums = new Set<String>();
    /**
     * @description The definition clusters.
     */
    public List<Forceea.Cluster> clusters = new List<Forceea.Cluster>();
    /**
     * @description The the values for permutations.
     */
    private List<String> permutationValues = new List<String>();

    /* VARIABLES & PROPERTIES */

    /**
     * @description The definition command, e.g. "random".
     */
    public String command { get; set; }
    /**
     * @description The definition ID, e.g. "hSdFy1".
     */
    public String definitionId { get; set; }
    /**
     * @description The definition string, e.g. "random type(number) from(1) to(100) scale(0)".
     */
    public String definitionString { get; set; }
    /**
     * @description The user-defined field name, e.g. MyField__c.
     */
    private String fieldName { get; set; }
    /**
     * @description The field API name.
     */
    public String fieldApiName { get; set; }
    /**
     * @description The FObject.
     */
    public FObject fObj { get; set; }
    /**
     * @description If true, the definition has permutations.
     */
    public Boolean hasPermutation { get; set; }
    /**
     * @description If true, the definition restricts the created picklist values to existing values.
     */
    private Boolean hasRestrictedPicklistValues { get; set; }
    /**
     * @description If true, the definition field data type is valid.
     */
    private Boolean hasValidFieldDataType { get; set; }
    /**
     * @description If true, the definition is a function-x.
     */
    public Boolean isFunction { get; set; }
    /**
     * @description If true, the definition is valid for record updates.
     */
    public Boolean isForUpdate { get; set; }
    /**
     * @description If false: declared by user, if true: declared by Forceea.
     */
    public Boolean isSystemDeclared { get; set; }
    /**
     * @description If true, he definition is valid.
     */
    private Boolean isValid { get; set; }
    /**
     * @description If true, the definition has been validated.
     */
    public Boolean isValidated { get; set; }
    /**
     * @description If true, the field is virtual.
     */
    public Boolean isVirtualField { get; set; }
    /**
     * @description The map of maximum definition ID suffix numbers by key,
     *   where key: SObjectAPiNAme+FieldApiName+DefinitionString(lowercase) and value: maximum definition ID suffix number.
     */
    private static Map<String, Integer> maxSuffixNumbersByKey = new Map<String, Integer>();
    /**
     * @description The definition position in permutations.
     */
    public Integer positionForPermutations { get; set; }
    /**
     * @description the definition script, e.g. random(type) from(1) to(10) scale(0).
     */
    private String script { get; set; }
    /**
     * @description The seed of pseudo-random number generator.
     */
    private static Long seed {
        get;
        set {
            seed = (value ^ 25214903917L) & ((1L << 48) - 1L);
        }
    }
    /**
     * @description The SObject API name of definition.
     */
    public String sObjectApiName { get; set; }
    /**
     * @description The type of definition.
     */
    public ForceeaDefinitionType type { get; set; }

    /* CLASSES */

    private class ClusterTypeValidationResult {
        Integer index { get; set; }
        Integer countOfParameter { get; set; }
    }

    /* CONSTRUCTOR */

    /**
     * @description The constructor for the class.
     * @param fObj An FObject object.
     * @param fieldName The definition field name.
     * @param fieldApiName The definition field API name.
     * @param isSystemDeclared If true, the definition is declared by Forceea.
     * @param isForUpdate If true, the definition is for update.
     * @param definitionString The definition string.
     */
    public ForceeaDefinition(
        FObject fObj,
        String fieldName,
        String fieldApiName,
        Boolean isSystemDeclared,
        Boolean isForUpdate,
        String definitionString
    ) {
        this.command = '';
        this.definitionString = definitionString.trim();
        this.fieldName = fieldName.trim();
        this.fieldApiName = fieldApiName.trim();
        this.fObj = fObj;
        this.hasPermutation = false;
        this.hasRestrictedPicklistValues = false;
        this.hasValidFieldDataType = true;
        this.isForUpdate = isForUpdate;
        this.isFunction = false;
        this.isSystemDeclared = isSystemDeclared;
        this.isVirtualField = ForceeaService.fieldIsVirtual(this.fieldApiName);
        this.isValid = true;
        this.isValidated = false;
        this.script = '';
        this.sObjectApiName = this.fObj.sObjectApiName.trim();
        this.type = new ForceeaDefinitionType();
        this.definitionId = getDefinitionId();
    }

    /* METHODS */

    private Boolean argumentIsValid(Forceea.Cluster cluster) {
        Boolean result = true;

        switch on cluster.parameter.toLowerCase() {
            when 'mode' {
                if (!argumentIsValidForSerialMode(cluster.arguments)) {
                    result = false;
                }
            }
        }

        return result;
    }

    /**
     * @description Informs if the mode argument is valid.
     * @param arguments The cluster arguments.
     * @return True, if the mode is valid.
     */
    private Boolean argumentIsValidForSerialMode(List<String> arguments) {
        if (arguments.isEmpty() || arguments.size() != 1) {
            return false;
        }

        if (!LOOKUP_MODES.contains(arguments.get(0))) {
            return false;
        }

        return true;
    }

    /**
     * @description Clear the maxSuffixNumbersByKey map.
     */
    public static void clearMapMaxSuffixNumbersByKey() {
        maxSuffixNumbersByKey.clear();
    }

    /**
     * @description Checks that a cluster type exists in a definition.
     * @param clusterType The cluster type.
     * @return A boolean value.
     */
    private Boolean clusterTypeExists(Forceea.ClusterType clusterType) {
        ClusterTypeValidationResult results = getClusterTypeValidationResult(clusterType);
        if (results.index == -1 || parameterIsNotFoundOrIsFoundMoreThanOnce(results.countOfParameter)) {
            return false;
        }

        return new ForceeaDefinitionHandler(this).argumentsMatch(clusterType, results.index);
    }

    /**
     * @description Determines is the field has multiple definitions.
     * @return A boolean value.
     */
    private Boolean fieldHasMultipleDefinitions() {
        Boolean result = false;
        Integer counter = 0;
        String fieldApiName = this.fieldApiName.toLowerCase();

        for (ForceeaDefinition def : this.fObj.definitions) {
            Boolean definitionIsValid = (def.isForUpdate && fObj.dmlIsUpdate)
                || (!def.isForUpdate && !fObj.dmlIsUpdate);

            if (definitionIsValid && !def.isFunction && def.fieldApiName.toLowerCase() == fieldApiName) {
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
     * @description Generates a ckecksum.
     * @return The ckecksum string.
     */
    private String getChecksum() {
        String result = getRandomString();
        checksums.add(result);

        return result;
    }

    /**
     * @description Finds how many times the Parameter exists and its position (index).
     * @param clusterType An Forceea.ClusterType object.
     * @return An object of ClusterTypeValidationResult.
     */
    private ClusterTypeValidationResult getClusterTypeValidationResult(Forceea.ClusterType clusterType) {
        Integer countOfParameter = 0; // counts how many times a cluster parameter is found
        Integer counter = 0;
        Integer index = 0; // the position of a definition cluster with a specified cluster type parameter

        for (Forceea.Cluster cluster : this.clusters) {
            if (parameterIsValid(clusterType, cluster)) {
                countOfParameter++;
                index = counter;
            }
            if (!argumentIsValid(cluster)) {
                index = -1;
                break;
            }
            counter++;
        }

        ClusterTypeValidationResult result = new ClusterTypeValidationResult();
        result.countOfParameter = countOfParameter;
        result.index = index;

        return result;
    }

    /**
     * @description Generates the Definition ID, which equals: Checksum + Suffix Number.
     * @return The Definition ID string.
     */
    private String getDefinitionId() {
        if (String.isNotBlank(this.definitionId)) {
            return this.definitionId;
        }

        String definitionIdKey = getDefinitionIdKey();
        String checksum = getChecksum();
        Integer suffixNumber = getNextSuffixNumber(definitionIdKey);

        String result = checksum + String.valueOf(suffixNumber);
        maxSuffixNumbersByKey.put(definitionIdKey, suffixNumber);

        return result;
    }

    /**
     * @description Generates the Definition ID key,
     *   which is the lowercase concatenation of sObjectApiName, fieldApiName and definitionString.
     * @return The Definition ID string.
     */
    private String getDefinitionIdKey() {
        String result = this.sObjectApiName + this.fieldApiName + this.definitionString;
        return result.toLowerCase();
    }

    /**
     * @description Retrieves the definition string with the new source argument.
     * @param newSource The new source.
     * @param cluster The cluster.
     * @return The updated definition string with the new source.
     */
    private String getDefinitionStringWithNewSource(String newSource, Forceea.Cluster cluster) {
        String previousSource = cluster.arguments.get(0);
        return this.definitionString.replace(previousSource, newSource);
    }

    private Integer getHashCodeFromDefinitionDetails() {
        String hashString = (this.fieldApiName + this.definitionString).toLowerCase().trim();
        return hashString.hashCode();
    }

    /**
     * @description Retrieves the next suffix number related to a Definition ID key.
     * @param definitionIdKey The Definition ID key.
     * @return The maximum suffix number.
     */
    private Integer getNextSuffixNumber(String definitionIdKey) {
        Integer result = 0;

        if (maxSuffixNumbersByKey.containsKey(definitionIdKey)) {
            result = maxSuffixNumbersByKey.get(definitionIdKey);
        }

        return result + 1;
    }

    /**
     * @description Returns the permutation values of definition.
     * @return A list of string values.
     */
    private List<String> getPermutationValues() {
        List<String> results = new List<String>();

        switch on this.type.id {
            when SERIAL_NUMBER_MODE, SERIAL_PICKLIST,
                SERIAL_LIST_STRING, SERIAL_LIST_INTEGER, SERIAL_LIST_DECIMAL,
                SERIAL_LIST_DATE, SERIAL_LIST_DATETIME, SERIAL_LIST_TIME {
                results = new ForceeaGenerator(this).getListValuesForPermutations();
            } when SERIAL_LOOKUP {
                results = new ForceeaGenerator(this).getLookupValuesForPermutations();
            }
        }

        return results;
    }

    /**
     * @description Creates a random string of lowercase/uppercase characters (letters).
     * @return A list of string values.
     */
    private String getRandomString() {
        String result = '';
        final String charsToSelect = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSUVWXYZ';
        final Integer size = charsToSelect.length();

        seed = getHashCodeFromDefinitionDetails();

        for (Integer counter = 1; counter <= DEFINITION_ID_LENGTH; counter++) {
            Integer rnd = (RANDOM * size).intValue();
            result += charsToSelect.substring(rnd, rnd + 1);
        }

        return result;
    }

    /**
     * @description Retrieves the definition type.
     * @return The definition type.
     */
    private ForceeaDefinitionType getType() {
        ForceeaDefinitionType result;

        for (ForceeaDefinitionType defType : ForceeaDefinitionType.definitionTypes) {
            if (typeMatches(defType)) {
                return defType;
            }
        }

        return result;
    }

    private Boolean getValidationWhenFieldIsBase64(ForceeaService.DefinitionTypeId typeId) {
        switch on typeId {
            when FUNCTION_ADD,
                MOCK_ID,
                RANDOM_LOOKUP, RANDOM_LOOKUP_WHERE, RANDOM_PICKLIST, RANDOM_PICKLIST_EXCEPT,
                SERIAL_LOOKUP, SERIAL_PICKLIST,
                STATIC_LOOKUP {
                return false;
            } when else {
                return true;
            }
        }
    }

    private Boolean getValidationWhenFieldIsBoolean(ForceeaService.DefinitionTypeId typeId) {
        switch on typeId {
            when COPY_FIELD, COPY_LOOKUP,
                RANDOM_BOOLEAN, RANDOM_LIST_STRING,
                SERIAL_LIST_STRING,
                STATIC_STRING {
                return true;
            } when else {
                return false;
            }
        }
    }

    private Boolean getValidationWhenFieldIsDate(ForceeaService.DefinitionTypeId typeId) {
        switch on typeId {
            when COPY_FIELD, COPY_LOOKUP,
                FUNCTION_ADD,
                RANDOM_DATE, RANDOM_LIST_DATE, RANDOM_LIST_DATETIME,
                SERIAL_DATE, SERIAL_DATETIME, SERIAL_LIST_DATE, SERIAL_LIST_DATETIME,
                STATIC_BLANK, STATIC_DATE, STATIC_DATETIME {
                return true;
            } when else {
                return false;
            }
        }
    }

    private Boolean getValidationWhenFieldIsDatetime(ForceeaService.DefinitionTypeId typeId) {
        switch on typeId {
            when COPY_FIELD, COPY_LOOKUP,
                FUNCTION_ADD,
                RANDOM_DATE, RANDOM_DATETIME, RANDOM_LIST_DATETIME,
                SERIAL_DATETIME, SERIAL_LIST_DATETIME,
                STATIC_BLANK, STATIC_DATETIME {
                return true;
            } when else {
                return false;
            }
        }
    }

    private Boolean getValidationWhenFieldIsDecimal(ForceeaService.DefinitionTypeId typeId) {
        switch on typeId {
            when COPY_FIELD, COPY_LOOKUP,
                FUNCTION_ADD,
                RANDOM_LIST_DECIMAL, RANDOM_LIST_INTEGER, RANDOM_NUMBER,
                SERIAL_LIST_INTEGER, SERIAL_LIST_DECIMAL, SERIAL_NUMBER, SERIAL_NUMBER_MODE,
                STATIC_BLANK, STATIC_INTEGER, STATIC_DECIMAL {
                return true;
            } when else {
                return false;
            }
        }
    }

    private Boolean getValidationWhenFieldIsEmail(ForceeaService.DefinitionTypeId typeId) {
        switch on typeId {
            when COPY_FIELD, COPY_LOOKUP,
                FUNCTION_CONVERT,
                RANDOM_EMAIL, RANDOM_LIST_INTEGER, RANDOM_LIST_STRING, RANDOM_NUMBER, RANDOM_STRING,
                SERIAL_LIST_INTEGER, SERIAL_LIST_STRING, SERIAL_NUMBER, SERIAL_NUMBER_MODE,
                STATIC_BLANK, STATIC_INTEGER, STATIC_STRING {
                return true;
            } when else {
                return false;
            }
        }
    }

    private Boolean getValidationWhenFieldIsId(ForceeaService.DefinitionTypeId typeId) {
        switch on typeId {
            when MOCK_ID {
                this.fObj.isMocking = true;
                return true;
            } when else {
                return false;
            }
        }
    }

    private Boolean getValidationWhenFieldIsInteger(ForceeaService.DefinitionTypeId typeId) {
        switch on typeId {
            when COPY_FIELD, COPY_LOOKUP,
                FUNCTION_ADD,
                RANDOM_LIST_DECIMAL, RANDOM_LIST_INTEGER, RANDOM_NUMBER,
                SERIAL_LIST_INTEGER, SERIAL_LIST_DECIMAL, SERIAL_NUMBER, SERIAL_NUMBER_MODE,
                STATIC_BLANK, STATIC_INTEGER, STATIC_DECIMAL {
                return true;
            } when else {
                return false;
            }
        }
    }

    private Boolean getValidationWhenFieldIsPhone(ForceeaService.DefinitionTypeId typeId) {
        switch on typeId {
            when COPY_FIELD, COPY_LOOKUP,
                RANDOM_LIST_INTEGER, RANDOM_NUMBER, RANDOM_LIST_STRING, RANDOM_PHONE,
                SERIAL_LIST_INTEGER, SERIAL_NUMBER, SERIAL_NUMBER_MODE, SERIAL_LIST_STRING,
                STATIC_BLANK, STATIC_INTEGER, STATIC_STRING {
                return true;
            } when else {
                return false;
            }
        }
    }

    private Boolean getValidationWhenFieldIsReference(ForceeaService.DefinitionTypeId typeId) {
        switch on typeId {
            when COPY_FIELD, COPY_LOOKUP,
                RANDOM_LOOKUP, RANDOM_LOOKUP_WHERE,
                SERIAL_LIST_STRING, SERIAL_LOOKUP,
                STATIC_BLANK, STATIC_STRING, STATIC_LOOKUP {
                return true;
            } when else {
                return false;
            }
        }
    }

    private Boolean getValidationWhenFieldIsSelection(ForceeaService.DefinitionTypeId typeId) {
        switch on typeId {
            when FUNCTION_ADD,
                MOCK_ID,
                RANDOM_LOOKUP, RANDOM_LOOKUP_WHERE,
                SERIAL_LOOKUP,
                STATIC_LOOKUP {
                return false;
            } when else {
                return true;
            }
        }
    }

    private Boolean getValidationWhenFieldIsString(ForceeaService.DefinitionTypeId typeId) {
        switch on typeId {
            when MOCK_ID,
                RANDOM_PICKLIST, RANDOM_PICKLIST_EXCEPT,
                SERIAL_PICKLIST {
                return false;
            } when else {
                return true;
            }
        }
    }

    private Boolean getValidationWhenFieldIsTime(ForceeaService.DefinitionTypeId typeId) {
        switch on typeId {
            when COPY_FIELD, COPY_LOOKUP,
                RANDOM_LIST_TIME, RANDOM_TIME,
                SERIAL_LIST_TIME,
                STATIC_BLANK, STATIC_TIME {
                return true;
            } when else {
                return false;
            }
        }
    }

    private Boolean getValidationWhenFieldIsUrl(ForceeaService.DefinitionTypeId typeId) {
        switch on typeId {
            when COPY_FIELD, COPY_LOOKUP,
                FUNCTION_CONVERT,
                RANDOM_LIST_INTEGER, RANDOM_NUMBER, RANDOM_LIST_STRING, RANDOM_STRING, RANDOM_URL,
                SERIAL_LIST_INTEGER, SERIAL_NUMBER, SERIAL_NUMBER_MODE, SERIAL_LIST_STRING,
                STATIC_BLANK, STATIC_INTEGER, STATIC_STRING {
                return true;
            } when else {
                return false;
            }
        }
    }

    /**
     * @description Validates a field definition.
     * @return True, if the definition is valid.
     */
    public Boolean isValid() {
        return this.isValid;
    }

    /**
     * @description Validates the definition in regards to the data type of the definition field.
     * @return A boolean value.
     */
    private Boolean isValidForFieldDataType() {
        ForceeaService.DefinitionTypeId typeId = this.type.id;
        if (this.fieldApiName == ForceeaService.RECORD_TYPE_ID) {
            return isValidForRecordType(typeId);
        }

        return isValidForOtherFieldTypes(typeId);
    }

    private Boolean isValidForOtherFieldTypes(ForceeaService.DefinitionTypeId typeId) {
        Schema.DisplayType fieldType = FObject.globalFieldsMapBySObject
            .get(this.sObjectApiName.toLowerCase())
            .get(this.fieldApiName.toLowerCase()).dataType;

        switch on fieldType {
            when STRING, TEXTAREA {
                return getValidationWhenFieldIsString(typeId);
            } when DATE {
                return getValidationWhenFieldIsDate(typeId);
            } when INTEGER, LONG {
                return getValidationWhenFieldIsInteger(typeId);
            } when PERCENT, CURRENCY, DOUBLE {
                return getValidationWhenFieldIsDecimal(typeId);
            } when BOOLEAN {
                return getValidationWhenFieldIsBoolean(typeId);
            } when EMAIL {
                return getValidationWhenFieldIsEmail(typeId);
            } when PICKLIST, MULTIPICKLIST, COMBOBOX {
                return getValidationWhenFieldIsSelection(typeId);
            } when DATETIME {
                return getValidationWhenFieldIsDatetime(typeId);
            } when TIME {
                return getValidationWhenFieldIsTime(typeId);
            } when PHONE {
                return getValidationWhenFieldIsPhone(typeId);
            } when REFERENCE {
                return getValidationWhenFieldIsReference(typeId);
            } when URL {
                return getValidationWhenFieldIsUrl(typeId);
            } when BASE64 {
                return getValidationWhenFieldIsBase64(typeId);
            } when ID {
                return getValidationWhenFieldIsId(typeId);
            } when else {
                return false;
            }
        }
    }

    private Boolean isValidForRecordType(ForceeaService.DefinitionTypeId typeId) {
        if (typeId == ForceeaService.DefinitionTypeId.COPY_FIELD ||
            typeId == ForceeaService.DefinitionTypeId.COPY_LOOKUP ||
            typeId == ForceeaService.DefinitionTypeId.RANDOM_LIST_STRING ||
            typeId == ForceeaService.DefinitionTypeId.RANDOM_PICKLIST ||
            typeId == ForceeaService.DefinitionTypeId.RANDOM_PICKLIST_EXCEPT ||
            typeId == ForceeaService.DefinitionTypeId.SERIAL_LIST_STRING ||
            typeId == ForceeaService.DefinitionTypeId.SERIAL_PICKLIST ||
            typeId == ForceeaService.DefinitionTypeId.STATIC_STRING
        ) {
            return true;
        } else {
            return false;
        }
    }

    /**
     * @description Informs whether the definition mode is "permutation".
     * @return A boolean value.
     */
    private Boolean modeIsPermutation() {
        String mode = new ForceeaGenerator(this).getClusterArgument('mode');
        Boolean result = (mode.toLowerCase() == ForceeaService.MODE_PERMUTATION);

        return result;
    }

    /**
     * @description Informs whether the parameter is not found or is found more than once.
     * @param countOfParameter The parameter count.
     * @return True, if the parameter is not found once.
     */
    private Boolean parameterIsNotFoundOrIsFoundMoreThanOnce(Integer countOfParameter) {
        return countOfParameter != 1;
    }

    /**
     * @description Informs whether the parameter is valid.
     * @param clusterType The cluster type.
     * @param cluster The cluster.
     * @return True, if the parameter is valid.
     */
    private Boolean parameterIsValid(Forceea.ClusterType clusterType, Forceea.Cluster cluster) {
        return clusterType.parameter == cluster.parameter;
    }

    /**
     * @description Informs whether the parameter is "source".
     * @param cluster The cluster.
     * @return True, if the parameter is source.
     */
    private Boolean parameterIsSource(Forceea.Cluster cluster) {
        return cluster.parameter.equalsIgnoreCase(ForceeaGenerator.PARAMETER_SOURCE);
    }

    /**
     * @description Sets a new source.
     * @param newSource The new source (forceea or salesforce).
     */
    public void setNewSource(String newSource) {
        for (Forceea.Cluster cluster : this.clusters) {
            if (parameterIsSource(cluster)) {
                this.definitionString = getDefinitionStringWithNewSource(newSource, cluster);
                cluster.setSourceParameter(newSource);
            }
        }
    }

    /**
     * @description Sets a new source for a specific field.
     * @param fieldApiName The field API name.
     * @param newSource The new source (forceea or salesforce).
     */
    public void setNewSource(String fieldApiName, String newSource) {
        if (fieldApiName == this.fieldApiName) {
            setNewSource(newSource);
        }
    }

    /**
     * @description Sets the permutations for this definition.
     */
    public void setPermutations() {
        if (!modeIsPermutation()) {
            return;
        }

        List<String> results = getPermutationValues();
        if (!results.isEmpty()) {
            this.permutationValues = results;
            this.fObj.permutationsList.add(this.permutationValues);
            this.positionForPermutations = this.fObj.permutationsList.size() - 1;
        }
    }

    /**
     * @description Sets a definition as valid or invalid.
     * @param isValid If true, the definition is valid.
     */
    public void setValid(Boolean isValid) {
        this.isValid = isValid;
    }

    /**
     * @description Checks if the definition matches a definition type.
     * @param definitionType The definition type.
     * @return True if the definition matches the definition type.
     */
    private Boolean typeMatches(ForceeaDefinitionType definitionType) {
        Boolean result = false;

        if (definitionType.command != this.command) {
            return false;
        }

        // assess each Cluster Type
        Integer numValidClusterTypes = 0;
        for (Forceea.ClusterType clusterType : definitionType.clusterTypes) {
            if (clusterTypeExists(clusterType)) {
                numValidClusterTypes++;
            } else {
                return false;
            }
        }

        // if all Cluster Types are valid, the Definition Type is found
        if (numValidClusterTypes == definitionType.clusterTypes.size() && numValidClusterTypes == this.clusters.size()) {
            result = true;
        }

        return result;
    }

    /**
     * @description Validates a field definition.
     */
    public void validate() {
        if (this.isValidated) {
            return;
        }
        this.isValidated = true;

        validateType();
        validateVirtualField();
        validateDataType();
        validateMultipleDefinitions();

        if (!this.isValid) {
            this.fObj.setProcessAsValid(false);
        }
    }

    /**
     * @description Validates data type.
     */
    private void validateDataType() {
        if (!this.isValid || this.isVirtualField) {
            return;
        }

        if (!isValidForFieldDataType()) {
            this.fObj.addError(this.fieldApiName,
                ForceeaService.MESSAGE_INVALID_DEFINITION + ' [' + this.definitionString + '] ' +
                'for the data type of field [' + this.fieldApiName + ']');
            this.isValid = false;
            this.hasValidFieldDataType = false;
        }
    }

    /**
     * @description Validates definition type.
     */
    private void validateType() {
        if (!this.isValid) {
            return;
        }

        ForceeaDefinitionType defType = getType();

        if (defType == null) {
            this.fObj.addError(this.fieldApiName,
                ForceeaService.MESSAGE_INVALID_DEFINITION + ' [' + this.definitionString +
                '] of field [' + this.fieldApiName + ']');
            this.isValid = false;
        }

        this.type = defType;
    }

    /**
     * @description Validates when cannot accept multiple definitions.
     */
    private void validateMultipleDefinitions() {
        if (!this.isValid || this.isVirtualField) {
            return;
        }

        Forceea.FieldInfo field = ForceeaService.getField(this.sObjectApiName, this.fieldApiName);
        if (!field.allowsMultipleDefinitions && fieldHasMultipleDefinitions()) {
            this.fObj.addError(this.fieldApiName,
                'Field [' + this.fieldApiName + '] does not accept multiple definitions');
            this.isValid = false;
        }
    }

    /**
     * @description Validates when the field is virtual.
     */
    private void validateVirtualField() {
        if (!this.isValid || !this.isVirtualField) {
            return;
        }

        String typeArgument = new ForceeaGenerator(this).getClusterArgument('type');
        if (typeArgument.toLowerCase() == 'picklist') {
            this.fObj.addError(this.fieldApiName,
                ForceeaService.MESSAGE_INVALID_DEFINITION + ' [' + this.definitionString +
                '] of virtual field [' + this.fieldApiName + ']');
            this.isValid = false;
        }
    }

}