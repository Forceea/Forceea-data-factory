/*
  Forceea data factory (v2.1.1)
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
public with sharing class ForceeaDefinition {

    /* COLLECTIONS */

    public List<FObject.Cluster> clusters = new List<FObject.Cluster>(); // the definition clusters
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
    public FObject.DefinitionType type { get; set; } // the type of the definition

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
        this.type = new FObject.DefinitionType();
    }

    /* METHODS */

    private Boolean argumentIsValid(FObject.Cluster cluster) {
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
    private Boolean argumentMatches(FObject.ClusterType clusterType, Integer clusterIndex) {
        Boolean result = false;
        FObject.Cluster cluster = this.clusters.get(clusterIndex);

        // check if value must have only 1 item but it has more
        if (!clusterType.allowsMultipleArguments && cluster.arguments.size() > 1) {
            return result;
        }

        // value has the correct number of arguments
        if (String.isNotBlank(clusterType.value) && // if the parameter has a value
            cluster.arguments.size() == 1 && // and there is only 1 argument
            clusterType.value != cluster.arguments.get(0)) { // and this is not the expected value
            return result;
        }

        if (clusterType.value == '' && cluster.arguments.size() == 1 && String.isBlank(cluster.arguments.get(0))) {
            return true;
        }

        if (clusterType.valueType == FObject.ValueType.TYPE_STRING) {
            return true;
        }

        // check the data type of all cluster arguments
        for (String argument : cluster.arguments) {
            switch on clusterType.valueType {
                when TYPE_INTEGER {
                    try {
                        Integer value = Integer.valueOf(argument);
                        result = true;
                    } catch (System.TypeException ex) {
                    }
                }
                when TYPE_DECIMAL {
                    try {
                        Decimal value = Decimal.valueOf(argument);
                        result = true;
                    } catch (System.TypeException ex) {
                    }
                }
                when TYPE_DATE {
                    try {
                        Date value = Date.valueOf(argument);
                        result = true;
                    } catch (System.TypeException ex) {
                    }
                }
                when TYPE_DATETIME {
                    try {
                        Datetime value = Datetime.valueOf(argument);
                        result = true;
                    } catch (System.TypeException ex) {
                    }
                }
                when TYPE_TIME {
                    try {
                        argument = '2018-01-01 ' + argument;
                        Datetime value = Datetime.valueOf(argument);
                        result = true;
                    } catch (System.TypeException ex) {
                    }
                }
            }
        }

        return result;
    }

    /**
     * @description Checks that a cluster type exists in a definition.
     * @param clusterType The cluster type.
     * @return A boolean value.
     */
    private Boolean clusterTypeMatches(FObject.ClusterType clusterType) {
        Boolean result = false;

        Integer countOfParameter = 0; // counts how many times a cluster parameter is found
        Integer index; // the position of a definition cluster with a specified cluster type parameter

        // find how many times the Parameter exists and its position (index)
        Integer counter = 0;
        for (FObject.Cluster cluster : this.clusters) {
            if (clusterType.parameter == cluster.parameter) { // if parameter is valid
                countOfParameter++;
                index = counter;
            }
            if (!argumentIsValid(cluster)) {
                return false;
            }
            counter++;
        }

        // if parameter is not found or found more than once
        if (countOfParameter != 1) {
            return false;
        }

        result = argumentMatches(clusterType, index);
        return result;
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
            Boolean definitionIsValid = (def.isForUpdate && this.fObj.dmlIsUpdate)
                || (!def.isForUpdate && !this.fObj.dmlIsUpdate);

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
     * @description Retrieves the definition type.
     * @return The definition type.
     */
    private FObject.DefinitionType getType() {
        FObject.DefinitionType result;

        for (FObject.DefinitionType defType : FObject.definitionTypes) {
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
        Boolean result = false;
        Schema.DisplayType fieldType = this.fObj.sObjectFieldsByFieldApiName.get(this.fieldApiName.toLowerCase()).dataType;
        FObject.DefinitionTypeId typeId = this.type.id;

        if (this.fieldApiName == ForceeaService.RECORD_TYPE_ID) {
            if (
                typeId == FObject.DefinitionTypeId.COPY_FIELD ||
                    typeId == FObject.DefinitionTypeId.COPY_LOOKUP ||
                    typeId == FObject.DefinitionTypeId.RANDOM_LIST_STRING ||
                    typeId == FObject.DefinitionTypeId.RANDOM_PICKLIST ||
                    typeId == FObject.DefinitionTypeId.RANDOM_PICKLIST_EXCEPT ||
                    typeId == FObject.DefinitionTypeId.SERIAL_LOOKUP ||
                    typeId == FObject.DefinitionTypeId.SERIAL_PICKLIST ||
                    typeId == FObject.DefinitionTypeId.STATIC_STRING
                ) {
                return true;
            }
        }

        switch on fieldType {
            when STRING, TEXTAREA {
                result = true;
                if (
                    typeId == FObject.DefinitionTypeId.MOCK_ID ||
                        typeId == FObject.DefinitionTypeId.RANDOM_LOOKUP ||
                        typeId == FObject.DefinitionTypeId.RANDOM_LOOKUP_WHERE ||
                        typeId == FObject.DefinitionTypeId.RANDOM_PICKLIST ||
                        typeId == FObject.DefinitionTypeId.RANDOM_PICKLIST_EXCEPT ||
                        typeId == FObject.DefinitionTypeId.SERIAL_LOOKUP ||
                        typeId == FObject.DefinitionTypeId.STATIC_LOOKUP ||
                        typeId == FObject.DefinitionTypeId.SERIAL_PICKLIST
                    ) {
                    result = false;
                }
            }
            when DATE {
                if (typeId == FObject.DefinitionTypeId.COPY_FIELD ||
                    typeId == FObject.DefinitionTypeId.COPY_LOOKUP ||
                    typeId == FObject.DefinitionTypeId.FUNCTION_ADD ||
                    typeId == FObject.DefinitionTypeId.RANDOM_DATE ||
                    typeId == FObject.DefinitionTypeId.RANDOM_LIST_DATE ||
                    typeId == FObject.DefinitionTypeId.SERIAL_DATE ||
                    typeId == FObject.DefinitionTypeId.STATIC_BLANK ||
                    typeId == FObject.DefinitionTypeId.STATIC_DATE
                    ) {
                    result = true;
                }
            }
            when INTEGER, LONG {
                if (typeId == FObject.DefinitionTypeId.COPY_FIELD ||
                    typeId == FObject.DefinitionTypeId.COPY_LOOKUP ||
                    typeId == FObject.DefinitionTypeId.FUNCTION_ADD ||
                    typeId == FObject.DefinitionTypeId.RANDOM_LIST_DECIMAL ||
                    typeId == FObject.DefinitionTypeId.RANDOM_LIST_INTEGER ||
                    typeId == FObject.DefinitionTypeId.RANDOM_NUMBER ||
                    typeId == FObject.DefinitionTypeId.SERIAL_NUMBER ||
                    typeId == FObject.DefinitionTypeId.STATIC_BLANK ||
                    typeId == FObject.DefinitionTypeId.STATIC_INTEGER
                    ) {
                    result = true;
                }
            }
            when PERCENT, CURRENCY, DOUBLE {
                if (typeId == FObject.DefinitionTypeId.COPY_FIELD ||
                    typeId == FObject.DefinitionTypeId.COPY_LOOKUP ||
                    typeId == FObject.DefinitionTypeId.FUNCTION_ADD ||
                    typeId == FObject.DefinitionTypeId.RANDOM_LIST_DECIMAL ||
                    typeId == FObject.DefinitionTypeId.RANDOM_LIST_INTEGER ||
                    typeId == FObject.DefinitionTypeId.RANDOM_NUMBER ||
                    typeId == FObject.DefinitionTypeId.SERIAL_NUMBER ||
                    typeId == FObject.DefinitionTypeId.STATIC_BLANK ||
                    typeId == FObject.DefinitionTypeId.STATIC_DECIMAL ||
                    typeId == FObject.DefinitionTypeId.STATIC_INTEGER
                    ) {
                    result = true;
                }
            }
            when BOOLEAN {
                if (typeId == FObject.DefinitionTypeId.COPY_FIELD ||
                    typeId == FObject.DefinitionTypeId.COPY_LOOKUP ||
                    typeId == FObject.DefinitionTypeId.RANDOM_BOOLEAN ||
                    typeId == FObject.DefinitionTypeId.RANDOM_LIST_STRING ||
                    typeId == FObject.DefinitionTypeId.STATIC_STRING
                    ) {
                    result = true;
                }
            }
            when EMAIL {
                if (typeId == FObject.DefinitionTypeId.COPY_FIELD ||
                    typeId == FObject.DefinitionTypeId.COPY_LOOKUP ||
                    typeId == FObject.DefinitionTypeId.RANDOM_BOOLEAN ||
                    typeId == FObject.DefinitionTypeId.RANDOM_EMAIL ||
                    typeId == FObject.DefinitionTypeId.RANDOM_LIST_INTEGER ||
                    typeId == FObject.DefinitionTypeId.RANDOM_LIST_STRING ||
                    typeId == FObject.DefinitionTypeId.RANDOM_NUMBER ||
                    typeId == FObject.DefinitionTypeId.RANDOM_STRING ||
                    typeId == FObject.DefinitionTypeId.RANDOM_TIME ||
                    typeId == FObject.DefinitionTypeId.SERIAL_LIST ||
                    typeId == FObject.DefinitionTypeId.SERIAL_NUMBER ||
                    typeId == FObject.DefinitionTypeId.STATIC_BLANK ||
                    typeId == FObject.DefinitionTypeId.STATIC_INTEGER ||
                    typeId == FObject.DefinitionTypeId.STATIC_STRING
                    ) {
                    result = true;
                }
            }
            when PICKLIST, MULTIPICKLIST, COMBOBOX {
                result = true;
                if (typeId == FObject.DefinitionTypeId.MOCK_ID ||
                    typeId == FObject.DefinitionTypeId.RANDOM_LOOKUP ||
                    typeId == FObject.DefinitionTypeId.RANDOM_LOOKUP_WHERE ||
                    typeId == FObject.DefinitionTypeId.SERIAL_LOOKUP ||
                    typeId == FObject.DefinitionTypeId.STATIC_LOOKUP
                    ) {
                    result = false;
                }
            }
            when DATETIME {
                if (typeId == FObject.DefinitionTypeId.COPY_FIELD ||
                    typeId == FObject.DefinitionTypeId.COPY_LOOKUP ||
                    typeId == FObject.DefinitionTypeId.FUNCTION_ADD ||
                    typeId == FObject.DefinitionTypeId.RANDOM_LIST_DATE ||
                    typeId == FObject.DefinitionTypeId.RANDOM_LIST_DATETIME ||
                    typeId == FObject.DefinitionTypeId.RANDOM_DATE ||
                    typeId == FObject.DefinitionTypeId.RANDOM_DATETIME ||
                    typeId == FObject.DefinitionTypeId.SERIAL_DATE ||
                    typeId == FObject.DefinitionTypeId.SERIAL_DATETIME ||
                    typeId == FObject.DefinitionTypeId.STATIC_BLANK ||
                    typeId == FObject.DefinitionTypeId.STATIC_DATE ||
                    typeId == FObject.DefinitionTypeId.STATIC_DATETIME
                    ) {
                    result = true;
                }
            }
            when TIME {
                if (typeId == FObject.DefinitionTypeId.COPY_FIELD ||
                    typeId == FObject.DefinitionTypeId.COPY_LOOKUP ||
                    typeId == FObject.DefinitionTypeId.RANDOM_LIST_TIME ||
                    typeId == FObject.DefinitionTypeId.RANDOM_TIME ||
                    typeId == FObject.DefinitionTypeId.STATIC_BLANK ||
                    typeId == FObject.DefinitionTypeId.STATIC_TIME
                    ) {
                    result = true;
                }
            }
            when PHONE {
                if (typeId == FObject.DefinitionTypeId.COPY_FIELD ||
                    typeId == FObject.DefinitionTypeId.COPY_LOOKUP ||
                    typeId == FObject.DefinitionTypeId.RANDOM_LIST_STRING ||
                    typeId == FObject.DefinitionTypeId.RANDOM_NUMBER ||
                    typeId == FObject.DefinitionTypeId.RANDOM_PHONE ||
                    typeId == FObject.DefinitionTypeId.SERIAL_LIST ||
                    typeId == FObject.DefinitionTypeId.SERIAL_NUMBER ||
                    typeId == FObject.DefinitionTypeId.STATIC_BLANK ||
                    typeId == FObject.DefinitionTypeId.STATIC_INTEGER ||
                    typeId == FObject.DefinitionTypeId.STATIC_STRING
                    ) {
                    result = true;
                }
            }
            when REFERENCE {
                if (typeId == FObject.DefinitionTypeId.COPY_FIELD ||
                    typeId == FObject.DefinitionTypeId.COPY_LOOKUP ||
                    typeId == FObject.DefinitionTypeId.RANDOM_LOOKUP ||
                    typeId == FObject.DefinitionTypeId.RANDOM_LOOKUP_WHERE ||
                    typeId == FObject.DefinitionTypeId.SERIAL_LOOKUP ||
                    typeId == FObject.DefinitionTypeId.STATIC_LOOKUP
                    ) {
                    result = true;
                }
            }
            when URL {
                if (typeId == FObject.DefinitionTypeId.COPY_FIELD ||
                    typeId == FObject.DefinitionTypeId.COPY_LOOKUP ||
                    typeId == FObject.DefinitionTypeId.RANDOM_LIST_INTEGER ||
                    typeId == FObject.DefinitionTypeId.RANDOM_LIST_STRING ||
                    typeId == FObject.DefinitionTypeId.RANDOM_NUMBER ||
                    typeId == FObject.DefinitionTypeId.RANDOM_STRING ||
                    typeId == FObject.DefinitionTypeId.RANDOM_URL ||
                    typeId == FObject.DefinitionTypeId.SERIAL_LIST ||
                    typeId == FObject.DefinitionTypeId.SERIAL_NUMBER ||
                    typeId == FObject.DefinitionTypeId.STATIC_BLANK ||
                    typeId == FObject.DefinitionTypeId.STATIC_INTEGER ||
                    typeId == FObject.DefinitionTypeId.STATIC_STRING
                    ) {
                    result = true;
                }
            }
            when BASE64 {
                result = true;
                if (
                    typeId == FObject.DefinitionTypeId.MOCK_ID ||
                        typeId == FObject.DefinitionTypeId.RANDOM_LOOKUP ||
                        typeId == FObject.DefinitionTypeId.RANDOM_LOOKUP_WHERE ||
                        typeId == FObject.DefinitionTypeId.RANDOM_PICKLIST ||
                        typeId == FObject.DefinitionTypeId.RANDOM_PICKLIST_EXCEPT ||
                        typeId == FObject.DefinitionTypeId.SERIAL_LOOKUP ||
                        typeId == FObject.DefinitionTypeId.SERIAL_PICKLIST ||
                        typeId == FObject.DefinitionTypeId.STATIC_LOOKUP
                    ) {
                    result = false;
                }
            }
            when ID {
                if (typeId == FObject.DefinitionTypeId.MOCK_ID) {
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

    public void setPermutations() {
        if (!modeIsPermutation()) {
            return;
        }

        List<String> results = new List<String>();
        switch on this.type.id {
            when SERIAL_LIST, SERIAL_PICKLIST {
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
	 * @param defType The definition type.
	 * @return True if the definition matches the definition type.
	 */
    private Boolean typeMatches(FObject.DefinitionType defType) {
        Boolean result = false;

        if (defType.command != this.command) {
            return false;
        }

        // assess each Cluster Type
        Integer numValidClusterTypes = 0;
        for (FObject.ClusterType ct : defType.clusterTypes) {
            if (clusterTypeMatches(ct)) {
                numValidClusterTypes++;
            } else {
                return false;
            }
        }

        // if all Cluster Types are valid, the Definition Type is found
        if (numValidClusterTypes == defType.clusterTypes.size() && numValidClusterTypes == this.clusters.size()) {
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

        FObject.DefinitionType defType = getType();

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

        FObject.Field fieldObj = this.fObj.sObjectFieldsByFieldApiName.get(this.fieldApiName.toLowerCase());
        if (!fieldObj.allowsMultipleDefinitions && fieldHasMultipleDefinitions()) {
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
