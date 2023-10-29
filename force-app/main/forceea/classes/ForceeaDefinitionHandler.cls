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
 * @description Provides functionality to the ForceeaDefinition class.
 */
public with sharing class ForceeaDefinitionHandler {

    /* CONSTANTS */

    private static final String MESSAGE_WILL_REPLACE_ALL_DEFINITIONS = 'Will replace all definition of';
    private static final String MESSAGE_WILL_REPLACE_DEFINITION_WITH_ID = 'Will replace the definition with ID';

    /* INSTANCE VARIABLES & PROPERTIES */

    private final ForceeaDefinition def { get; set; }
    private String definitionString { get; set; }
    private String fieldName { get; set; }
    private final FObject fObj { get; set; }
    private Boolean isSystemDeclared { get; set; }
    private Boolean isForUpdate { get; set; }
    private Schema.SObjectField sObjField { get; set; }

    /* CONSTRUCTORS */

    /**
     * @description The constructor for the class.
     */
    public ForceeaDefinitionHandler() { // NOPMD
    }

    /**
     * @description The constructor for the class.
     * @param def A ForceeaDefinition object.
     */
    public ForceeaDefinitionHandler(ForceeaDefinition def) {
        this.def = def;
    }

    /**
     * @description The constructor for the class.
     * @param fObj An FObject object.
     */
    public ForceeaDefinitionHandler(FObject fObj) {
        this.fObj = fObj;
    }

    /* METHODS */

    /**
     * @description Validates the data type of all cluster arguments.
     * @param clusterType The cluster type object.
     * @param arguments The list of arguments.
     * @return TRUE, if all cluster arguments match the cluster data type.
     */
    public Boolean allArgumentsMatch(Forceea.ClusterType clusterType, List<String> arguments) {
        ForceeaService.ValueType clusterValueType = clusterType.valueType;

        for (String argument : arguments) {
            ForceeaService.ValueType argumentValueType = new ForceeaService().getValueType(argument);

            if (argumentValueType == clusterValueType) {
                continue;
            }

            switch on clusterValueType {
                when TYPE_INTEGER {
                    if (argumentValueType == ForceeaService.ValueType.TYPE_DECIMAL) {
                        return false;
                    }
                } when TYPE_DECIMAL {
                    if (argumentValueType == ForceeaService.ValueType.TYPE_INTEGER) {
                        continue;
                    }
                } when TYPE_DATETIME {
                    if (argumentValueType == ForceeaService.ValueType.TYPE_DATE) {
                        return false;
                    }
                } when TYPE_DATE {
                    if (argumentValueType == ForceeaService.ValueType.TYPE_DATETIME) {
                        continue;
                    }
                }
            }

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
    public Boolean argumentsMatch(Forceea.ClusterType clusterType, Integer clusterIndex) {
        Forceea.Cluster cluster = this.def.clusters.get(clusterIndex);

        if (valueMustHaveOnlyOneItemButItHasMore(clusterType, cluster) || valueIsWrong(clusterType, cluster)) {
            return false;
        }

        if (valueIsBlank(clusterType, cluster) || valueTypeIsString(clusterType)) {
            return true;
        }

        return new ForceeaDefinitionHandler().allArgumentsMatch(clusterType, cluster.arguments);
    }

    /**
     * @description Clears the next position map, if this is a new field.
     * @param fieldApiName The field API name.
     */
    private void clearNextNewFieldPositionsByFieldNameMap(String fieldApiName) {
        if (!this.fObj.nextNewFieldPositionByFieldName.containsKey(fieldApiName)) {
            this.fObj.nextNewFieldPositionByFieldName.clear();
        }
    }

    /**
     * @description Informs whether the field is defined.
     * @param fieldApiName The API name of a field.
     * @param isForUpdate True, if the field is for update.
     * @return True, if the field is already defined.
     */
    private Boolean fieldIsDefined(String fieldApiName, Boolean isForUpdate) {
        List<String> fieldsToSearch = (isForUpdate) ? this.fObj.fieldsForUpdate : this.fObj.fields;

        for (String field : fieldsToSearch) {
            if (fieldApiName.equalsIgnoreCase(field)) {
                return true;
            }
        }

        return false;
    }

    /**
     * @description Informs whether the field is for replacement.
     * @param fieldApiName The field API name.
     * @return True, if the field is set for replacing its definitions, set with replaceDefinitions.
     */
    private Boolean fieldIsNotForReplacement(String fieldApiName) {
        return !this.fObj.fieldApiNameForReplacement.equalsIgnoreCase(fieldApiName);
    }

    private String getFieldApiName() {
        this.definitionString = getStringWithVariablesReplaced(this.definitionString);

        return ForceeaService.getFieldApiName(
            this.fObj,
            this.definitionString,
            this.fObj.sObjectApiName,
            this.fieldName,
            this.sObjField,
            '',
            'standard');
    }

    /**
     * @description Retrieves the index of the next definition for replacement.
     * @param fieldApiName The field API name.
     * @return An integer number >= 0.
     */
    private Integer getIndexForReplacement(String fieldApiName) {
        Integer result = this.fObj.definitions.size();

        if (this.fObj.nextNewFieldPositionByFieldName.containsKey(fieldApiName)) {
            result = this.fObj.nextNewFieldPositionByFieldName.get(fieldApiName);
            this.fObj.nextNewFieldPositionByFieldName.put(fieldApiName, result + 1);
        }

        return result;
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

        List<Forceea.Variable> variables = FObject.globalVariablesByName.values();
        variables.addAll(this.fObj.variables.values());

        for (Forceea.Variable var : variables) {
            result = result.replace('{@' + var.name + '}', FObject.getVariableStringValue(var));
        }

        return result;
    }

    /**
     * @description Removes existing field definitions and sets the position of the next definition.
     * @param fieldApiName The field API name.
     */
    private void handleReplacementOfDefinitionId(String fieldApiName) {
        if (this.fObj.definitionPositionForReplacement == -1) {
            return;
        }

        clearNextNewFieldPositionsByFieldNameMap(fieldApiName);

        Integer definitionIndexToRemove = this.fObj.definitionPositionForReplacement;
        this.fObj.definitions.remove(definitionIndexToRemove);
        this.fObj.forceeaDebug(ForceeaService.DEBUG, MESSAGE_WILL_REPLACE_DEFINITION_WITH_ID +
            ' [' + this.fObj.definitionIdForReplacement + ']');

        this.fObj.nextNewFieldPositionByFieldName.put(fieldApiName, definitionIndexToRemove);
        this.fObj.definitionPositionForReplacement = -1;
    }

    /**
     * @description Removes all existing field definitions and sets the position of the next definition.
     * @param fieldApiName The field API name.
     */
    private void handleReplacementOfFieldDefinitions(String fieldApiName) {
        if (fieldIsNotForReplacement(fieldApiName)) {
            return;
        }
        this.fObj.fieldApiNameForReplacement = '';

        clearNextNewFieldPositionsByFieldNameMap(fieldApiName);

        List<Integer> definitionIndexesToRemove = this.fObj.getDefinitionIndexes(fieldApiName);
        definitionIndexesToRemove.sort();
        this.fObj.removeDefinitionIndexes(fieldApiName);

        Integer firstDefinitionPosition = definitionIndexesToRemove.get(0);
        this.fObj.nextNewFieldPositionByFieldName.put(fieldApiName, firstDefinitionPosition);
        this.fObj.forceeaDebug(ForceeaService.DEBUG,
            MESSAGE_WILL_REPLACE_ALL_DEFINITIONS + ' [' + fieldApiName + ']');
    }

    private Boolean isEndOfDefinitionsList(Integer index) {
        return index == this.fObj.definitions.size();
    }

    /**
     * @description Declares a field definition.
     */
    public void setDefinition() {
        this.fObj.definitionsAreValidated = false;
        String fieldApiName = getFieldApiName();
        if (String.isBlank(fieldApiName)) {
            return;
        }

        handleReplacementOfFieldDefinitions(fieldApiName);
        handleReplacementOfDefinitionId(fieldApiName);
        clearNextNewFieldPositionsByFieldNameMap(fieldApiName);
        setDefinitionInCorrectPosition(fieldApiName);

        if (!fieldIsDefined(fieldApiName, this.isForUpdate)) {
            if (this.isForUpdate) {
                this.fObj.fieldsForUpdate.add(fieldApiName);
            } else {
                this.fObj.fields.add(fieldApiName);
            }
        }

        this.fObj.mustCreateNewRecords = (this.isForUpdate) ? false : true;
    }

    private void setDefinitionInCorrectPosition(String fieldApiName) {
        ForceeaDefinition newDefinition = new ForceeaDefinition(
            this.fObj, this.fieldName, fieldApiName, this.isSystemDeclared, this.isForUpdate, this.definitionString);

        Integer index = getIndexForReplacement(fieldApiName);
        if (isEndOfDefinitionsList(index)) {
            this.fObj.definitions.add(newDefinition);
        } else {
            this.fObj.definitions.add(index, newDefinition);
        }
    }

    /**
     * @description Sets the field definition string.
     * @param definitionString The field definition string.
     * @return The current ForceeaDefinitionHandler object.
     */
    public ForceeaDefinitionHandler setDefinitionString(String definitionString) {
        this.definitionString = definitionString;
        return this;
    }

    /**
     * @description Sets the fieldName variable.
     * @param fieldName The field name.
     * @return The current ForceeaDefinitionHandler object.
     */
    public ForceeaDefinitionHandler setFieldName(String fieldName) {
        this.fieldName = fieldName;
        return this;
    }

    /**
     * @description Sets the isForUpdate variable.
     * @param isForUpdate If true, the field definition is for update.
     * @return The current ForceeaDefinitionHandler object.
     */
    public ForceeaDefinitionHandler setIsForUpdate(Boolean isForUpdate) {
        this.isForUpdate = isForUpdate;
        return this;
    }

    /**
     * @description Sets the isSystemDeclared variable.
     * @param isSystemDeclared If true, the field definition is declared by Forceea.
     * @return The current ForceeaDefinitionHandler object.
     */
    public ForceeaDefinitionHandler setIsSystemDeclared(Boolean isSystemDeclared) {
        this.isSystemDeclared = isSystemDeclared;
        return this;
    }

    /**
     * @description Sets the sObjField variable.
     * @param sObjField The sObjField variable.
     * @return The current ForceeaDefinitionHandler object.
     */
    public ForceeaDefinitionHandler setSObjectField(Schema.SObjectField sObjField) {
        this.sObjField = sObjField;
        return this;
    }

    private Boolean valueIsBlank(Forceea.ClusterType clusterType, Forceea.Cluster cluster) {
        return clusterType.value == '' &&
            cluster.arguments.size() == 1 &&
            String.isBlank(cluster.arguments.get(0));
    }

    private Boolean valueIsWrong(Forceea.ClusterType clusterType, Forceea.Cluster cluster) {
        return clusterType.value != null && // the parameter has a value
            cluster.arguments.size() == 1 && // there is only 1 argument
            clusterType.value != cluster.arguments.get(0); // this is not the expected value
    }

    private Boolean valueMustHaveOnlyOneItemButItHasMore(Forceea.ClusterType clusterType, Forceea.Cluster cluster) {
        return !clusterType.allowsMultipleArguments &&
            cluster.arguments.size() > 1;
    }

    private Boolean valueTypeIsString(Forceea.ClusterType clusterType) {
        return clusterType.valueType == ForceeaService.ValueType.TYPE_STRING &&
            (clusterType.value == null || clusterType.value != '');
    }

}