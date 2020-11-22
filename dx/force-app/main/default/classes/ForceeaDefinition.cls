/*
  Forceea data factory (v2.3.0)
  Copyright (C) 2020 Nikos Mitrakis

  This program is free software: you can redistribute it and/or modify it under the terms
  of the GNU General Public License as published by the Free Software Foundation,
  either version 3 of the License, or any later version.

  This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
  without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  See the GNU General Public License for more details.

  You can find a copy of the GNU General Public License at
  https://github.com/Forceea/Forceea-data-factory/blob/master/LICENSE
*/
public with sharing class ForceeaDefinition {

    /* COLLECTIONS */

    public List<ForceeaCluster> clusters = new List<ForceeaCluster>(); // the definition clusters
    private List<String> permutationValues = new List<String>(); // the values for permutations

    /* VARIABLES & PROPERTIES */

    public String command { get; set; }
    public String definitionString { get; set; } // the user-defined field definition, e.g. serial type(number)..
    private String fieldName { get; set; } // the user-defined field name, e.g. myField__c
    public String fieldApiName { get; set; } // the user-defined field name, e.g. MyField__c
    public FObject fObj { get; set; } // the FObject
    public Boolean hasPermutation { get; set; } // if true, the definition has permutations
    private Boolean hasRestrictedPicklistValues { get; set; } // the definition restricts the created picklist values to existing values
    private Boolean hasValidFieldDataType { get; set; } // the definition field data type is valid
    public Boolean isFunction { get; set; } // if true, the definition is a function-x
    public Boolean isForUpdate { get; set; } // if true, the definition is valid for record updates
    public Boolean isSystemDeclared { get; set; } // false: declared by user, true: declared by Forceea
    private Boolean isValid { get; set; } // the definition is valid
    public Boolean isValidated { get; set; } // the definition has been validated
    public Boolean isVirtualField { get; set; } // the field is virtual
    public Integer positionForPermutations { get; set; } // the definition position in permutations
    public String sObjectApiName { get; set; } // the SObject API name of definition
    private String script { get; set; } // the definition script, e.g. random(type) from(1) to(10) scale(0)
    public ForceeaDefinitionType type { get; set; } // the type of the definition

    /* CLASSES */

    private class ClusterTypeValidationResult {
        Integer index { get; set; }
        Integer countOfParameter { get; set; }
    }

    /* CONSTRUCTOR */

    public ForceeaDefinition(FObject fObj, String sObjectApiName, String fieldName, String fieldApiName, Boolean isSystemDeclared,
        Boolean isForUpdate, String definitionString) {
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
        this.sObjectApiName = sObjectApiName.trim();
        this.type = new ForceeaDefinitionType();
    }

    /* METHODS */

    // check the data type of all cluster arguments
    private Boolean allArgumentsMatch(ForceeaClusterType clusterType, List<String> arguments) {
        ForceeaService.ValueType clusterValueType = clusterType.valueType;

        ForceeaService.ValueType argumentValueType;
        for (String argument : arguments) {
            argumentValueType = getArgumentValueType(argument);
            if (argumentValueType == clusterValueType) {
                continue;
            }

            if (clusterValueType == ForceeaService.ValueType.TYPE_INTEGER &&
                argumentValueType == ForceeaService.ValueType.TYPE_DECIMAL) {
                return false;
            }

            if (clusterValueType == ForceeaService.ValueType.TYPE_DECIMAL &&
                argumentValueType == ForceeaService.ValueType.TYPE_INTEGER) {
                continue;
            }

            if (clusterValueType == ForceeaService.ValueType.TYPE_DATETIME &&
                argumentValueType == ForceeaService.ValueType.TYPE_DATE) {
                return false;
            }

            if (clusterValueType == ForceeaService.ValueType.TYPE_DATE &&
                argumentValueType == ForceeaService.ValueType.TYPE_DATETIME) {
                continue;
            }

            return false;
        }

        return true;
    }

    private Boolean argumentIsValid(ForceeaCluster cluster) {
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

        if (!ForceeaGenerator.lookupModesSet.contains(arguments.get(0))) {
            return false;
        }

        return true;
    }

    /**
     * @description Validates the arguments of a cluster.
     * @param clusterType The cluster type.
     * @param clusterIndex The cluster index.
     * @return True if the cluster arguments are valid, based on the cluster type.
     */
    private Boolean argumentsMatch(ForceeaClusterType clusterType, Integer clusterIndex) {
        ForceeaCluster cluster = this.clusters.get(clusterIndex);

        if (valueMustHaveOnlyOneItemButItHasMore(clusterType, cluster) || valueIsWrong(clusterType, cluster)) {
            return false;
        }

        if (valueIsBlank(clusterType, cluster) || valueTypeIsString(clusterType)) {
            return true;
        }

        return allArgumentsMatch(clusterType, cluster.arguments);
    }

    /**
     * @description Checks that a cluster type exists in a definition.
     * @param clusterType The cluster type.
     * @return A boolean value.
     */
    private Boolean clusterTypeExists(ForceeaClusterType clusterType) {
        ClusterTypeValidationResult results = getClusterTypeValidationResult(clusterType);
        if (results.index == -1 || parameterIsNotFoundOrIsFoundMoreThanOnce(results.countOfParameter)) {
            return false;
        }

        return argumentsMatch(clusterType, results.index);
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

    private ForceeaService.ValueType getArgumentValueType(String argument) {
        ForceeaService.ValueType result;

        // IMPORTANT: DO NOT CHANGE THE ORDER OF TYPES

        try {
            Integer value = Integer.valueOf(argument);
            return ForceeaService.ValueType.TYPE_INTEGER;
        } catch (System.TypeException ex) { }

        try {
            Decimal value = Decimal.valueOf(argument);
            return ForceeaService.ValueType.TYPE_DECIMAL;
        } catch (System.TypeException ex) { }

        try {
            Datetime value = Datetime.valueOf(argument);
            return ForceeaService.ValueType.TYPE_DATETIME;
        } catch (System.TypeException ex) { }

        try {
            Date value = Date.valueOf(argument);
            return ForceeaService.ValueType.TYPE_DATE;
        } catch (System.TypeException ex) { }

        try {
            Datetime value = Datetime.valueOf('2020-01-01 ' + argument);
            return ForceeaService.ValueType.TYPE_TIME;
        } catch (System.TypeException ex) { }

        return ForceeaService.ValueType.TYPE_STRING;
    }

    // find how many times the Parameter exists and its position (index)
    private ClusterTypeValidationResult getClusterTypeValidationResult(ForceeaClusterType clusterType) {
        Integer countOfParameter = 0; // counts how many times a cluster parameter is found
        Integer counter = 0;
        Integer index = 0; // the position of a definition cluster with a specified cluster type parameter

        for (ForceeaCluster cluster : this.clusters) {
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
     * @description Retrieves the definition type.
     * @return The definition type.
     */
    private ForceeaDefinitionType getType() {
        ForceeaDefinitionType result;

        for (ForceeaDefinitionType defType : FObject.definitionTypes) {
            if (typeMatches(defType)) {
                return defType;
            }
        }

        return result;
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

        Boolean result = false;
        Schema.DisplayType fieldType = FObject.globalFieldsMapBySObject
            .get(this.sObjectApiName.toLowerCase())
            .get(this.fieldApiName.toLowerCase()).dataType;

        switch on fieldType {
            when STRING, TEXTAREA {
                result = true;
                if (typeId == ForceeaService.DefinitionTypeId.MOCK_ID ||
                    typeId == ForceeaService.DefinitionTypeId.RANDOM_LOOKUP ||
                    typeId == ForceeaService.DefinitionTypeId.RANDOM_LOOKUP_WHERE ||
                    typeId == ForceeaService.DefinitionTypeId.RANDOM_PICKLIST ||
                    typeId == ForceeaService.DefinitionTypeId.RANDOM_PICKLIST_EXCEPT ||
                    typeId == ForceeaService.DefinitionTypeId.SERIAL_LOOKUP ||
                    typeId == ForceeaService.DefinitionTypeId.SERIAL_PICKLIST ||
                    typeId == ForceeaService.DefinitionTypeId.STATIC_LOOKUP
                    ) {
                    result = false;
                }
            }
            when DATE {
                if (typeId == ForceeaService.DefinitionTypeId.COPY_FIELD ||
                    typeId == ForceeaService.DefinitionTypeId.COPY_LOOKUP ||
                    typeId == ForceeaService.DefinitionTypeId.FUNCTION_ADD ||
                    typeId == ForceeaService.DefinitionTypeId.RANDOM_DATE ||
                    typeId == ForceeaService.DefinitionTypeId.RANDOM_LIST_DATE ||
                    typeId == ForceeaService.DefinitionTypeId.RANDOM_LIST_DATETIME ||
                    typeId == ForceeaService.DefinitionTypeId.SERIAL_DATE ||
                    typeId == ForceeaService.DefinitionTypeId.SERIAL_DATETIME ||
                    typeId == ForceeaService.DefinitionTypeId.SERIAL_LIST_DATE ||
                    typeId == ForceeaService.DefinitionTypeId.SERIAL_LIST_DATETIME ||
                    typeId == ForceeaService.DefinitionTypeId.STATIC_BLANK ||
                    typeId == ForceeaService.DefinitionTypeId.STATIC_DATE ||
                    typeId == ForceeaService.DefinitionTypeId.STATIC_DATETIME
                    ) {
                    result = true;
                }
            }
            when INTEGER, LONG {
                if (typeId == ForceeaService.DefinitionTypeId.COPY_FIELD ||
                    typeId == ForceeaService.DefinitionTypeId.COPY_LOOKUP ||
                    typeId == ForceeaService.DefinitionTypeId.FUNCTION_ADD ||
                    typeId == ForceeaService.DefinitionTypeId.RANDOM_LIST_DECIMAL ||
                    typeId == ForceeaService.DefinitionTypeId.RANDOM_LIST_INTEGER ||
                    typeId == ForceeaService.DefinitionTypeId.RANDOM_NUMBER ||
                    typeId == ForceeaService.DefinitionTypeId.SERIAL_LIST_DECIMAL ||
                    typeId == ForceeaService.DefinitionTypeId.SERIAL_LIST_INTEGER ||
                    typeId == ForceeaService.DefinitionTypeId.SERIAL_NUMBER ||
                    typeId == ForceeaService.DefinitionTypeId.STATIC_BLANK ||
                    typeId == ForceeaService.DefinitionTypeId.STATIC_DECIMAL ||
                    typeId == ForceeaService.DefinitionTypeId.STATIC_INTEGER
                    ) {
                    result = true;
                }
            }
            when PERCENT, CURRENCY, DOUBLE {
                if (typeId == ForceeaService.DefinitionTypeId.COPY_FIELD ||
                    typeId == ForceeaService.DefinitionTypeId.COPY_LOOKUP ||
                    typeId == ForceeaService.DefinitionTypeId.FUNCTION_ADD ||
                    typeId == ForceeaService.DefinitionTypeId.RANDOM_LIST_DECIMAL ||
                    typeId == ForceeaService.DefinitionTypeId.RANDOM_LIST_INTEGER ||
                    typeId == ForceeaService.DefinitionTypeId.RANDOM_NUMBER ||
                    typeId == ForceeaService.DefinitionTypeId.SERIAL_LIST_DECIMAL ||
                    typeId == ForceeaService.DefinitionTypeId.SERIAL_LIST_INTEGER ||
                    typeId == ForceeaService.DefinitionTypeId.SERIAL_NUMBER ||
                    typeId == ForceeaService.DefinitionTypeId.STATIC_BLANK ||
                    typeId == ForceeaService.DefinitionTypeId.STATIC_DECIMAL ||
                    typeId == ForceeaService.DefinitionTypeId.STATIC_INTEGER
                    ) {
                    result = true;
                }
            }
            when BOOLEAN {
                if (typeId == ForceeaService.DefinitionTypeId.COPY_FIELD ||
                    typeId == ForceeaService.DefinitionTypeId.COPY_LOOKUP ||
                    typeId == ForceeaService.DefinitionTypeId.RANDOM_BOOLEAN ||
                    typeId == ForceeaService.DefinitionTypeId.RANDOM_LIST_STRING ||
                    typeId == ForceeaService.DefinitionTypeId.SERIAL_LIST_STRING ||
                    typeId == ForceeaService.DefinitionTypeId.STATIC_STRING
                    ) {
                    result = true;
                }
            }
            when EMAIL {
                if (typeId == ForceeaService.DefinitionTypeId.COPY_FIELD ||
                    typeId == ForceeaService.DefinitionTypeId.COPY_LOOKUP ||
                    typeId == ForceeaService.DefinitionTypeId.FUNCTION_CONVERT ||
                    typeId == ForceeaService.DefinitionTypeId.RANDOM_EMAIL ||
                    typeId == ForceeaService.DefinitionTypeId.RANDOM_LIST_INTEGER ||
                    typeId == ForceeaService.DefinitionTypeId.RANDOM_LIST_STRING ||
                    typeId == ForceeaService.DefinitionTypeId.RANDOM_NUMBER ||
                    typeId == ForceeaService.DefinitionTypeId.RANDOM_STRING ||
                    typeId == ForceeaService.DefinitionTypeId.SERIAL_LIST_INTEGER ||
                    typeId == ForceeaService.DefinitionTypeId.SERIAL_LIST_STRING ||
                    typeId == ForceeaService.DefinitionTypeId.SERIAL_NUMBER ||
                    typeId == ForceeaService.DefinitionTypeId.STATIC_BLANK ||
                    typeId == ForceeaService.DefinitionTypeId.STATIC_INTEGER ||
                    typeId == ForceeaService.DefinitionTypeId.STATIC_STRING
                    ) {
                    result = true;
                }
            }
            when PICKLIST, MULTIPICKLIST, COMBOBOX {
                result = true;
                if (typeId == ForceeaService.DefinitionTypeId.FUNCTION_ADD ||
                    typeId == ForceeaService.DefinitionTypeId.MOCK_ID ||
                    typeId == ForceeaService.DefinitionTypeId.RANDOM_LOOKUP ||
                    typeId == ForceeaService.DefinitionTypeId.RANDOM_LOOKUP_WHERE ||
                    typeId == ForceeaService.DefinitionTypeId.SERIAL_LOOKUP ||
                    typeId == ForceeaService.DefinitionTypeId.STATIC_LOOKUP
                    ) {
                    result = false;
                }
            }
            when DATETIME {
                if (typeId == ForceeaService.DefinitionTypeId.COPY_FIELD ||
                    typeId == ForceeaService.DefinitionTypeId.COPY_LOOKUP ||
                    typeId == ForceeaService.DefinitionTypeId.FUNCTION_ADD ||
                    typeId == ForceeaService.DefinitionTypeId.RANDOM_DATE ||
                    typeId == ForceeaService.DefinitionTypeId.RANDOM_DATETIME ||
                    typeId == ForceeaService.DefinitionTypeId.RANDOM_LIST_DATETIME ||
                    typeId == ForceeaService.DefinitionTypeId.SERIAL_DATETIME ||
                    typeId == ForceeaService.DefinitionTypeId.SERIAL_LIST_DATETIME ||
                    typeId == ForceeaService.DefinitionTypeId.STATIC_BLANK ||
                    typeId == ForceeaService.DefinitionTypeId.STATIC_DATETIME
                    ) {
                    result = true;
                }
            }
            when TIME {
                if (typeId == ForceeaService.DefinitionTypeId.COPY_FIELD ||
                    typeId == ForceeaService.DefinitionTypeId.COPY_LOOKUP ||
                    typeId == ForceeaService.DefinitionTypeId.RANDOM_LIST_TIME ||
                    typeId == ForceeaService.DefinitionTypeId.RANDOM_TIME ||
                    typeId == ForceeaService.DefinitionTypeId.SERIAL_LIST_TIME ||
                    typeId == ForceeaService.DefinitionTypeId.STATIC_BLANK ||
                    typeId == ForceeaService.DefinitionTypeId.STATIC_TIME
                    ) {
                    result = true;
                }
            }
            when PHONE {
                if (typeId == ForceeaService.DefinitionTypeId.COPY_FIELD ||
                    typeId == ForceeaService.DefinitionTypeId.COPY_LOOKUP ||
                    typeId == ForceeaService.DefinitionTypeId.RANDOM_LIST_INTEGER ||
                    typeId == ForceeaService.DefinitionTypeId.RANDOM_LIST_STRING ||
                    typeId == ForceeaService.DefinitionTypeId.RANDOM_NUMBER ||
                    typeId == ForceeaService.DefinitionTypeId.RANDOM_PHONE ||
                    typeId == ForceeaService.DefinitionTypeId.SERIAL_LIST_INTEGER ||
                    typeId == ForceeaService.DefinitionTypeId.SERIAL_LIST_STRING ||
                    typeId == ForceeaService.DefinitionTypeId.SERIAL_NUMBER ||
                    typeId == ForceeaService.DefinitionTypeId.STATIC_BLANK ||
                    typeId == ForceeaService.DefinitionTypeId.STATIC_INTEGER ||
                    typeId == ForceeaService.DefinitionTypeId.STATIC_STRING
                    ) {
                    result = true;
                }
            }
            when REFERENCE {
                if (typeId == ForceeaService.DefinitionTypeId.COPY_FIELD ||
                    typeId == ForceeaService.DefinitionTypeId.COPY_LOOKUP ||
                    typeId == ForceeaService.DefinitionTypeId.RANDOM_LOOKUP ||
                    typeId == ForceeaService.DefinitionTypeId.RANDOM_LOOKUP_WHERE ||
                    typeId == ForceeaService.DefinitionTypeId.SERIAL_LIST_STRING ||
                    typeId == ForceeaService.DefinitionTypeId.SERIAL_LOOKUP ||
                    typeId == ForceeaService.DefinitionTypeId.STATIC_BLANK ||
                    typeId == ForceeaService.DefinitionTypeId.STATIC_LOOKUP ||
                    typeId == ForceeaService.DefinitionTypeId.STATIC_STRING
                    ) {
                    result = true;
                }
            }
            when URL {
                if (typeId == ForceeaService.DefinitionTypeId.COPY_FIELD ||
                    typeId == ForceeaService.DefinitionTypeId.COPY_LOOKUP ||
                    typeId == ForceeaService.DefinitionTypeId.FUNCTION_CONVERT ||
                    typeId == ForceeaService.DefinitionTypeId.RANDOM_LIST_INTEGER ||
                    typeId == ForceeaService.DefinitionTypeId.RANDOM_LIST_STRING ||
                    typeId == ForceeaService.DefinitionTypeId.RANDOM_NUMBER ||
                    typeId == ForceeaService.DefinitionTypeId.RANDOM_STRING ||
                    typeId == ForceeaService.DefinitionTypeId.RANDOM_URL ||
                    typeId == ForceeaService.DefinitionTypeId.SERIAL_LIST_INTEGER ||
                    typeId == ForceeaService.DefinitionTypeId.SERIAL_LIST_STRING ||
                    typeId == ForceeaService.DefinitionTypeId.SERIAL_NUMBER ||
                    typeId == ForceeaService.DefinitionTypeId.STATIC_BLANK ||
                    typeId == ForceeaService.DefinitionTypeId.STATIC_INTEGER ||
                    typeId == ForceeaService.DefinitionTypeId.STATIC_STRING
                    ) {
                    result = true;
                }
            }
            when BASE64 {
                result = true;
                if (typeId == ForceeaService.DefinitionTypeId.FUNCTION_ADD ||
                    typeId == ForceeaService.DefinitionTypeId.MOCK_ID ||
                    typeId == ForceeaService.DefinitionTypeId.RANDOM_LOOKUP ||
                    typeId == ForceeaService.DefinitionTypeId.RANDOM_LOOKUP_WHERE ||
                    typeId == ForceeaService.DefinitionTypeId.RANDOM_PICKLIST ||
                    typeId == ForceeaService.DefinitionTypeId.RANDOM_PICKLIST_EXCEPT ||
                    typeId == ForceeaService.DefinitionTypeId.SERIAL_LOOKUP ||
                    typeId == ForceeaService.DefinitionTypeId.SERIAL_PICKLIST ||
                    typeId == ForceeaService.DefinitionTypeId.STATIC_LOOKUP
                    ) {
                    result = false;
                }
            }
            when ID {
                if (typeId == ForceeaService.DefinitionTypeId.MOCK_ID) {
                    this.fObj.isMocking = true;
                    result = true;
                }
            }
        }

        return result;
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

    private Boolean parameterIsNotFoundOrIsFoundMoreThanOnce(Integer countOfParameter) {
        return countOfParameter != 1;
    }

    private Boolean parameterIsValid(ForceeaClusterType clusterType, ForceeaCluster cluster) {
        return clusterType.parameter == cluster.parameter;
    }

    public void setPermutations() {
        if (!modeIsPermutation()) {
            return;
        }

        List<String> results = new List<String>();
        switch on this.type.id {
            when SERIAL_LIST_STRING, SERIAL_LIST_INTEGER, SERIAL_LIST_DECIMAL,
                SERIAL_LIST_DATE, SERIAL_LIST_DATETIME, SERIAL_LIST_TIME, SERIAL_PICKLIST {
                results = new ForceeaGenerator(this).getListValuesForPermutations();
            }
            when SERIAL_LOOKUP {
                results = new ForceeaGenerator(this).getLookupValuesForPermutations();
            }
        }
        if (results.isEmpty()) {
            return;
        }

        this.permutationValues = results;
        this.fObj.permutationsList.add(this.permutationValues);
        this.positionForPermutations = this.fObj.permutationsList.size() - 1;
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
        for (ForceeaClusterType clusterType : definitionType.clusterTypes) {
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
            this.fObj.setProcessValid(false);
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

        ForceeaFieldInfo field = ForceeaService.getField(this.sObjectApiName, this.fieldApiName);
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

    private Boolean valueIsWrong(ForceeaClusterType clusterType, ForceeaCluster cluster) {
        return clusterType.value != null && // the parameter has a value
            cluster.arguments.size() == 1 && // there is only 1 argument
            clusterType.value != cluster.arguments.get(0); // this is not the expected value
    }

    private Boolean valueIsBlank(ForceeaClusterType clusterType, ForceeaCluster cluster) {
        return clusterType.value == '' &&
            cluster.arguments.size() == 1 &&
            String.isBlank(cluster.arguments.get(0));
    }

    private Boolean valueMustHaveOnlyOneItemButItHasMore(ForceeaClusterType clusterType, ForceeaCluster cluster) {
        return !clusterType.allowsMultipleArguments &&
            cluster.arguments.size() > 1;
    }

    private Boolean valueTypeIsString(ForceeaClusterType clusterType) {
        return clusterType.valueType == ForceeaService.ValueType.TYPE_STRING &&
            (clusterType.value == null || clusterType.value != '');
    }

}
