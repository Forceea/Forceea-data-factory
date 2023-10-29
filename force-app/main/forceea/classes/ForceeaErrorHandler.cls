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
 * @description Handles errors.
 */
public with sharing class ForceeaErrorHandler {

    /* INSTANCE VARIABLES & PROPERTIES */

    private final ForceeaDefinition def { get; set; }
    private final FObject fObj { get; set; }

    /* CONSTRUCTORS */

    /**
     * @description The constructor for the class.
     * @param fObj An FObject object.
     */
    public ForceeaErrorHandler(FObject fObj) {
        this.fObj = fObj;
    }

    /**
     * @description The constructor for the class.
     * @param def A ForceeaDefinition object.
     */
    public ForceeaErrorHandler(ForceeaDefinition def) {
        this.fObj = def.fObj;
        this.def = def;
    }

    /**
     * @description The constructor for the class.
     * @param fObj An FObject object.
     * @param def A ForceeaDefinition object.
     */
    public ForceeaErrorHandler(FObject fObj, ForceeaDefinition def) {
        this.fObj = fObj;
        this.def = def;
    }

    /* METHODS */

    /**
     * @description Adds an FObject error related to invalid lookup field.
     * @param lookupFieldName The lookup field name.
     */
    public void addErrorInvalidLookupField(String lookupFieldName) {
        String errorMessage = 'Invalid lookup field [' + lookupFieldName.trim() +
            '] in definition [' + this.def.definitionString + ']';
        this.fObj.addError(this.def.fieldApiName, errorMessage);
    }

    /**
     * @description Adds an FObject error related to invalid lookup source.
     * @param lookupSource The lookup source name.
     */
    public void addErrorInvalidLookupSource(String lookupSource) {
        String errorMessage = 'Invalid source [' + lookupSource + '] in definition [' + this.def.definitionString + ']';
        this.fObj.addError(this.def.fieldApiName, errorMessage);
    }

    /**
     * @description Adds an FObject error related to invalid lookup SObject.
     * @param lookupSObjectName The lookup SObject name.
     */
    public void addErrorInvalidLookupSObject(String lookupSObjectName) {
        String errorMessage = ForceeaService.MESSAGE_INVALID_LOOKUP_SOBJECT + ' [' + lookupSObjectName +
            '] in definition [' + this.def.definitionString + ']';
        this.fObj.addError(this.def.fieldApiName, errorMessage);
    }

    /**
     * @description Retrieves a list of the errors found during the process of creating the records of an FObject.
     * @return A map of key: String, value: List<String> values.
     */
    public Map<String, List<String>> getErrors() {
        Map<String, List<String>> results = new Map<String, List<String>>();

        for (FObject.Error err : this.fObj.errors) {
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
     * @description Validates the min length value.
     * @param minLength The min length value.
     * @return True, if the value is validated.
     */
    public ForceeaErrorHandler validateMinLength(Integer minLength) {
        if (minLength > 0) {
            return this;
        }

        this.fObj.addError(this.def.fieldApiName,
            'The minimum length should be greater than or equal to 1 in definition [' +
            this.def.definitionString + ']');

        return this;
    }

    /**
     * @description Validates the min length value.
     * @param minLength The min length value.
     * @param maxLength The max length value.
     * @return True, if the values are validated.
     */
    public ForceeaErrorHandler validateMaxLength(Integer minLength, Integer maxLength) {
        if (minLength < maxLength) {
            return this;
        }

        this.fObj.addError(this.def.fieldApiName,
            'The minimum length should be less than the maximum length in definition [' +
            this.def.definitionString + ']');

        return this;
    }
}