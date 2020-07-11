/*
  Forceea data factory (v2.1.0)
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
public with sharing class ForceeaGenerator {

    /* COLLECTIONS */

    // lookup types used in serial lookup
    public static Set<String> lookupModesSet = new Set<String>{
        'cyclical', 'first', 'last', 'null', 'permutation'
    };
    // the valid sources
    private static Set<String> sourcesSet = new Set<String>{
        ForceeaService.SOURCE_FORCEEA, ForceeaService.SOURCE_SALESFORCE
    };
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

    /* VARIABLES & PROPERTIES */

    private ForceeaDefinition def { get; set; }
    private FObject fObj { get; set; }
    private Integer numRecords { get; set; }

    /* CONSTRUCTOR */

    public ForceeaGenerator(ForceeaDefinition def) {
        this.def = def;
        this.fObj = def.fObj;
        this.numRecords = def.fObj.getNumberOfRecords();
    }

    /* METHODS */

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
     * @description Informs if the IsActive standard field exists for the SObject.
     * @param sObjectApiName The SObject API name.
     * @return True, if the SObject contains an IsActive field.
     */
    private Boolean existsIsActiveStandardField(String sObjectApiName) {
        return FObject.globalFieldsMapBySObject
            .get(sObjectApiName.toLowerCase())
            .containsKey('isactive');
    }

    /**
     * @description Informs whether the field is a Checkbox.
     * @param fieldApiName The field API name.
     * @return A Boolean value.
     */
    private Boolean fieldIsCheckbox(String fieldApiName) {
        return (this.fObj.sObjectFieldsByFieldApiName.get(fieldApiName.toLowerCase()).dataType == Schema.DisplayType.BOOLEAN);
    }

    /**
     * @description Returns the first argument of a cluster.
     * @param parameter The parameter of the cluster.
     * @return A string value.
     */
    public String getClusterArgument(String parameter) {
        String result = '';
        String par = parameter.toLowerCase();

        for (FObject.Cluster cluster : this.def.clusters) {
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
     * @return A list of string values.
     */
    private List<String> getClusterArguments(String parameter) {
        List<String> results = new List<String>();
        String par = parameter.toLowerCase();

        for (FObject.Cluster cluster : this.def.clusters) {
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
     * @param referenceFieldName The API name of the reference field.
     * @param fromSObjectDotField The lookup SObject and the lookup field API names, separated by . (e.g. Account.Rating).
     * @return A list of string values.
     */
    private List<String> getCopiedLookupValues(String referenceFieldName, String fromSObjectDotField) {
        List<String> results = new List<String>();

        String fieldApiName = ForceeaService.getFieldApiName(
            this.fObj, this.def.definitionString, referenceFieldName, this.def.fieldApiName, 'lookup');
        if (String.isBlank(fieldApiName)) {
            return results;
        }

        if (fieldApiName.equalsIgnoreCase(this.def.fieldApiName)) {
            this.fObj.addError(this.def.fieldApiName, 'The field [' + fieldApiName +
                '] cannot be the same as the definition field in definition [' + this.def.definitionString + ']');
            return results;
        }

        String lookupSObjectName = fromSObjectDotField.trim().substringBefore('.');
        String lookupObjectApiName = ForceeaService.getSObjectApiName(
            this.fObj, this.def.definitionString, lookupSObjectName, this.def.fieldApiName, 'lookup');
        if (this.fObj.processMustTerminate()) {
            return results;
        }

        String lookupFieldApiName = ForceeaService.getFieldApiName(
            this.fObj, this.def.definitionString,
            fromSObjectDotField.trim().substringAfter('.'), this.def.fieldApiName, 'lookup');
        if (String.isBlank(lookupFieldApiName)) {
            return results;
        }

        // get the lookup field values
        Integer fieldPosition = getFieldPosition(fieldApiName);

        List<String> lookupIds = new List<String>(this.fObj.fieldValuesMatrix.get(fieldPosition));
        Set<String> lookupIdsSet = new Set<String>(lookupIds);

        String soqlQuery = 'SELECT Id, ' + lookupFieldApiName +
            ' FROM ' + lookupObjectApiName +
            ' WHERE Id IN :lookupIdsSet LIMIT ' + String.valueOf(this.fObj.queryLimit);

        Map<Id, SObject> lookupRecordsMap; // the lookup SObject's records map
        try { //query the database and populate the lookup records map
            lookupRecordsMap = new Map<Id, SObject>(Database.query(soqlQuery));
        } catch (QueryException ex) {
            this.fObj.addError(fieldApiName,
                ForceeaService.MESSAGE_FOUND_ERRORS_SELECTING_FROM_LOOKUP + ' [' + lookupObjectApiName +
                '] of [' + this.fObj.sObjectApiName + ']: ' + ex.getMessage());
        } finally {
            if (lookupRecordsMap.isEmpty() || this.fObj.processMustTerminate()) {
                return results;
            }
        }

        // get the field data type
        Schema.DisplayType valueType = getFieldDataType();

        String val = '';
        Datetime dt;

        if (valueType == Schema.DisplayType.DATETIME) { // the field is Datatime
            for (String lookupId : lookupIds) {
                dt = (Datetime) lookupRecordsMap.get(lookupId).get(lookupFieldApiName); // get the datetime value
                val = String.valueOf(dt);
                if (String.isBlank(val)) {
                    results.add('');
                } else {
                    results.add(val);
                }
            }
        } else { // the field is not Datatime
            for (String lookupId : lookupIds) {
                val = String.valueOf(lookupRecordsMap.get(lookupId).get(lookupFieldApiName));
                if (String.isBlank(val)) {
                    results.add('');
                } else {
                    results.add(val);
                }
            }
        }

        return results;
    }

    /**
     * @description Copies the values of a field.
     * @param fieldName The API name of the field.
     * @return A list of string values.
     */
    private List<String> getCopiedFieldValues(String fieldName) {
        List<String> results = new List<String>();
        fieldName = fieldName.trim();

        String fieldApiName = ForceeaService.getFieldApiName(
            this.fObj, this.def.definitionString, fieldName,
            this.def.fieldApiName, 'copy');
        if (String.isBlank(fieldApiName)) {
            return results;
        }

        if (fieldApiName == this.def.fieldApiName) {
            this.fObj.addError(this.def.fieldApiName, 'The field [' + fieldApiName + '] cannot be the same as ' +
                'the definition field in definition [' + this.def.definitionString + ']');
            return results;
        }

        Integer thisFieldPosition = getFieldPosition(this.def.fieldApiName);
        Integer fieldPosition = getFieldPosition(fieldApiName);

        if (thisFieldPosition < fieldPosition || fieldPosition == -1) {
            results = getCopiedFieldValuesFromExisting(fieldApiName);
        } else {
            results = this.fObj.fieldValuesMatrix.get(fieldPosition);
        }

        return results;
    }

    /**
     * @description Copies the existing values of a field.
     * @param fieldName The API name of the field.
     * @return A list of string values.
     */
    private List<String> getCopiedFieldValuesFromExisting(String fieldName) {
        List<String> results = new List<String>();

        for (Integer counter = 0; counter < this.fObj.recordsToUpdate.size(); counter++) {
            if (!FObject.processIsValid()) {
                break;
            }

            SObject obj = this.fObj.recordsToUpdate.get(counter);

            if (obj.get(fieldName) == null) {
                results.add('');
            } else {
                results.add(String.valueOf(obj.get(fieldName)));
            }
        }

        return results;
    }

    /**
     * @description Creates copy values.
     * @return A list of string values.
     */
    private List<String> getCopyValues() {
        List<String> results = new List<String>();

        switch on this.def.type.id {
            when COPY_FIELD {
                String field = getClusterArgument(ForceeaService.PARAMETER_FIELD);
                results = getCopiedFieldValues(field);
            }
            when COPY_LOOKUP {
                String referenceFieldName = getClusterArgument(ForceeaService.PARAMETER_FIELD);
                String fromSObjectDotField = getClusterArgument(ForceeaService.PARAMETER_FROM);
                results = getCopiedLookupValues(referenceFieldName, fromSObjectDotField);
            }
        }

        return results;
    }

    /**
     * @description Create values for function-add.
     * @return A list of string values.
     */
    private List<String> getFunctionAddValues() {
        String fieldName = getClusterArgument(ForceeaService.PARAMETER_FIELD);
        Integer currentFieldPosition = getFieldPosition(this.def.fieldApiName);
        List<String> currentValues = this.fObj.fieldValuesMatrix.get(currentFieldPosition);
        List<String> valuesToAdd = getCopiedFieldValues(fieldName);

        List<String> results = new List<String>();
        if (this.fObj.processMustTerminate()) {
            return results;
        }

        Boolean errorsFound = false;
        for (Integer counter = 0; counter < this.numRecords; counter++) {
            String currentStringValue = currentValues.get(counter);
            String stringValueToAdd = valuesToAdd.get(counter);
            Decimal valueToAdd = 0;

            try {
                valueToAdd = Decimal.valueOf(stringValueToAdd);
            } catch (TypeException exp) {
                errorsFound = true;
                break;
            }

            try {
                Decimal currentValue = Decimal.valueOf(currentStringValue) + valueToAdd;
                results.add(currentValue.toPlainString());
                continue;
            } catch (TypeException exp) { }

            try {
                Decimal currentValueTime = Datetime.valueOf(currentStringValue).getTime() + valueToAdd * 86400 * 1000;
                Datetime value = Datetime.newInstance((Long) currentValueTime);
                results.add(String.valueOf(value));
                continue;
            } catch (TypeException exp) { }

            try {
                Date currentValue = Date.valueOf(currentStringValue);
                Integer daysToAdd = (Integer) valueToAdd.round(System.RoundingMode.HALF_DOWN);
                Date value = currentValue.addDays(daysToAdd);
                results.add(String.valueOf(value));
                continue;
            } catch (TypeException exp) { }

            errorsFound = true;
        }

        return results;
    }

    /**
     * @description Creates function values.
     * @return A list of string values.
     */
    private List<String> getFunctionValues() {
        List<String> results = new List<String>();

        if (this.fObj.processMustTerminate()) {
            return results;
        }

        switch on this.def.type.id {
            when FUNCTION_ADD {
                results = getFunctionAddValues();
            }
        }

        return results;
    }

    /**
     * @description Retrieves the data type of the current field.
     * @return The DisplayType of the definition field or ANYTYPE if it's a Virtual Field.
     */
    private Schema.DisplayType getFieldDataType() {
        if (this.def.isVirtualField) {
            return Schema.DisplayType.ANYTYPE;
        }

        return this.fObj.sObjectFieldsByFieldApiName.get(this.def.fieldApiName.toLowerCase()).dataType;
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
        Schema.SObjectType objType = FObject.globalDescribeBySObject.get(objectName);
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
            FObject.PicklistInfo info = (FObject.PicklistInfo) JSON.deserialize(jsonString, FObject.PicklistInfo.class);
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
     * @description Retrieves the list of standard picklist values, excluding exceptions.
     * @return A list of picklist values.
     */
    private List<String> getFieldPicklistValuesExcludingExceptions() {
        List<String> picklistValues = new List<String>();
        String fieldApiName = this.def.fieldApiName.toLowerCase();

        for (Schema.PicklistEntry picklistEntry : this.fObj.sObjectFieldsByFieldApiName.get(fieldApiName).picklistValues) {
            picklistValues.add(picklistEntry.getValue());
        }

        List<String> exceptions = getClusterArguments(ForceeaService.PARAMETER_EXCEPT);
        return ForceeaService.removeValuesFromList(picklistValues, exceptions);
    }

    /**
     * @description Retrieves the position of a field.
     * @param fieldApiName The API name of the field.
     * @return An integer value.
     */
    private Integer getFieldPosition(String fieldApiName) {
        Integer result = -1;
        Integer counter = 0;

        for (String field : this.fObj.getFieldsToProcess()) {
            if (field == fieldApiName) {
                result = counter;
                break;
            }
            counter++;
        }

        return result;
    }

    /**
     * @description Creates list values for permutations.
     * @return A list of string values.
     */
    public List<String> getListValuesForPermutations() {
        List<String> results = new List<String>();
        this.def.hasPermutation = true;

        if (this.def.fieldApiName  == ForceeaService.RECORD_TYPE_ID) {
            return getRecordTypeIdsExcludingExceptions();
        }

        switch on getClusterArgument('type').toLowerCase() {
            when 'list' {
                results = getClusterArguments(ForceeaService.PARAMETER_VALUE);
            }
            when 'picklist' {
                results = getFieldPicklistValuesExcludingExceptions();
            }
        }

        return results;
    }

    /**
     * @description Retrieves IDs from a lookup records.
     * @param lookupRecords The list of lookup records.
     * @param lookupValues The list of lookup values.
     * @param lookupExceptions The list of exception lookup values.
     * @param lookupFieldApiName The API name of the lookup field.
     * @param fieldApiName The API name of the field.
     * @return A list of IDs.
     */
    private List<String> getLookupIds(List<SObject> lookupRecords, List<String> lookupValues, List<String> lookupExceptions,
        String lookupFieldApiName, String fieldApiName) {
        List<String> results = new List<String>();

        Boolean thereAreLookupValues = !(lookupValues == null || lookupValues.isEmpty());
        Boolean thereAreLookupExceptions = !(lookupExceptions == null || lookupExceptions.isEmpty());

        if (!thereAreLookupValues && !thereAreLookupExceptions) {
            for (SObject objRecord : lookupRecords) {
                results.add(objRecord.Id);
            }
        } else if (thereAreLookupValues && !thereAreLookupExceptions) {
            Set<String> lookupValuesSet = new Set<String>(lookupValues);
            lookupValuesSet = ForceeaService.convertSetToLowercase(lookupValuesSet);
            String fieldValue = '';
            for (SObject objRecord : lookupRecords) {
                fieldValue = (String) objRecord.get(lookupFieldApiName);
                if (String.isNotBlank(fieldValue) && lookupValuesSet.contains(fieldValue.toLowerCase())) {
                    results.add(objRecord.Id);
                }
            }
        } else if (!thereAreLookupValues && thereAreLookupExceptions) {
            Set<String> lookupExceptionsSet = new Set<String>(lookupExceptions);
            lookupExceptionsSet = ForceeaService.convertSetToLowercase(lookupExceptionsSet);
            String fieldValue = '';
            for (SObject objRecord : lookupRecords) {
                fieldValue = (String) objRecord.get(lookupFieldApiName);
                if (String.isNotBlank(fieldValue) && !lookupExceptionsSet.contains(fieldValue)) { // if exception value is not found
                    results.add(objRecord.Id);
                }
            }
        } else {
            this.fObj.addError(fieldApiName, 'System Error: Invalid lookup type');
        }

        return results;
    }

    /**
     * @description Retrieves lookup records from forceea source.
     * @param lookupSObjectApiName The API name of the lookup SObject.
     * @param lookupFieldApiName The API name of the lookup field.
     * @param groupName The group name.
     * @return A list of SObjects.
     */
    private List<SObject> getLookupRecordsFromForceea(
        String lookupSObjectApiName, String lookupFieldApiName, String groupName) {
        List<SObject> results = new List<SObject>();
        String key = lookupSObjectApiName.toLowerCase() + '.' + groupName.trim().toLowerCase() ;

        if (FObject.globalInsertedRecordsBySObjectGroup.containsKey(key)) {
            results = FObject.globalInsertedRecordsBySObjectGroup.get(key);
        }

        if (results.isEmpty() && this.def.isSystemDeclared) {
            results = getLookupRecordsFromSalesforce(lookupSObjectApiName, lookupFieldApiName, null);
        }

        return results;
    }

    /**
     * @description Retrieves lookup records from salesforce source.
     * @param lookupSObjectApiName The API name of the lookup SObject.
     * @param lookupFieldApiName The API name of the lookup field.
     * @param whereClause The where clause.
     * @return A list of SObjects.
     */
    private List<SObject> getLookupRecordsFromSalesforce(
        String lookupSObjectApiName, String lookupFieldApiName, String whereClause) {
        Boolean isActiveFieldExists = existsIsActiveStandardField(lookupSObjectApiName);

        String soqlQuery = 'SELECT Id';
        if (String.isNotBlank(lookupFieldApiName)) {
            soqlQuery += ', ' + lookupFieldApiName;
        }

        soqlQuery += ' FROM ' + lookupSObjectApiName;
        if (String.isNotBlank(whereClause)) {
            soqlQuery += ' WHERE ' + whereClause;
        }

        if (this.fObj.excludeInactiveLookupRecords && isActiveFieldExists) {
            if (String.isBlank(whereClause)) {
                soqlQuery += ' WHERE IsActive = true';
            } else {
                soqlQuery += ' AND IsActive = true';
            }
        }

        soqlQuery += ' LIMIT ' + String.valueOf(this.fObj.queryLimit);

        List<SObject> results = new List<SObject>();
        try {
            results = Database.query(soqlQuery);
        } catch (QueryException ex) {
            String key = (String.isBlank(lookupFieldApiName)) ? this.def.fieldApiName : lookupFieldApiName;
            this.fObj.addError(key, ForceeaService.MESSAGE_FOUND_ERRORS_SELECTING_FROM_LOOKUP + ' [' +
                lookupSObjectApiName + '] of [' + this.fObj.sObjectApiName + ']: ' + ex.getMessage());
        }

        return results;
    }

    /**
     * @description Creates IDs from a lookup SObject's records.
     * @param command The definition command.
     * @param source The definition source.
     * @param lookupSObjectName The API name of the lookup SObject.
     * @param lookupFieldName The API name of the lookup field.
     * @param lookupValues The list of lookup values.
     * @param lookupExceptions The list of exception lookup values.
     * @param groupName The group name.
     * @param whereClause The where clause of SOQL query.
     * @param lookupMode The serial lookup mode.
     * @param shouldGetUniqueValues If true, will retrieve permutations.
     * @return A list of IDs.
     */
    private List<String> getLookupValues(String command, String source,
        String lookupSObjectName, String lookupFieldName, List<String> lookupValues,
        List<String> lookupExceptions, String groupName, String whereClause, String lookupMode, Boolean shouldGetUniqueValues) {
        List<String> results = new List<String>();
        String fieldApiName = this.def.fieldApiName;

        String lookupSObjectApiName = ForceeaService.getSObjectApiName(
            this.fObj, this.def.definitionString, lookupSObjectName, this.def.fieldApiName, 'lookup');
        if (String.isBlank(lookupSObjectApiName)) {
            this.fObj.addError(fieldApiName,
                ForceeaService.MESSAGE_INVALID_LOOKUP_SOBJECT + ' [' + lookupSObjectName +
                    '] in definition [' + def.definitionString + ']');
            return results;
        }

        // get the SObject fields map
        if (!FObject.globalFieldsMapBySObject.containsKey(lookupSObjectApiName.toLowerCase())) {
            FObject.setSObject(lookupSObjectApiName);
        }

        // get stored fields details
        Map<String, FObject.Field> fieldsMap = FObject.globalFieldsMapBySObject.get(lookupSObjectApiName.toLowerCase());

        // check if the lookup field API name is valid
        // - the fieldName may be blank because of the definition random lookup(Object)
        String lookupFieldApiName = '';
        if (String.isNotBlank(lookupFieldName)) {
            if (fieldsMap.containsKey(lookupFieldName.toLowerCase())) {
                lookupFieldApiName = fieldsMap.get(lookupFieldName.toLowerCase()).fieldApiName;
            } else {
                this.fObj.addError(fieldApiName,
                    'Invalid lookup field [' + lookupFieldName + '] in definition [' + def.definitionString + ']');
                return results;
            }
        }

        if (!sourceIsValid(source)) {
            this.fObj.addError(fieldApiName,
                'Invalid source [' + source + '] in definition [' + def.definitionString + ']');
            return results;
        }

        List<SObject> lookupRecords = new List<SObject>();
        switch on source.toLowerCase() {
            when 'forceea' {
                lookupRecords = getLookupRecordsFromForceea(lookupSObjectApiName, lookupFieldApiName, groupName);
            }
            when 'salesforce' {
                lookupRecords = getLookupRecordsFromSalesforce(lookupSObjectApiName, lookupFieldName, whereClause);
            }
        }
        if (this.fObj.processMustTerminate()) {
            return results;
        }

        if (shouldGetUniqueValues) {
            return getLookupIds(lookupRecords, lookupValues, lookupExceptions, lookupFieldApiName, fieldApiName);
        }

        switch on command {
            when 'static' {
                results = getStaticLookupValues(
                    lookupRecords, lookupValues, lookupExceptions, lookupFieldApiName, fieldApiName);
            }
            when 'random' {
                results = getRandomLookupValues(
                    lookupRecords, lookupValues, lookupExceptions, lookupFieldApiName, fieldApiName);
            }
            when 'serial' {
                if (this.def.hasPermutation) {
                    results = getPermutationValues(this.def.positionForPermutations);
                } else {
                    results = getSerialLookupValues(
                        lookupRecords, lookupValues, lookupExceptions, lookupFieldApiName, fieldApiName, lookupMode);
                }
            }
        }

        return results;
    }

    /**
     * @description Creates lookup values for permutations.
     * @return A list of string values.
     */
    public List<String> getLookupValuesForPermutations() {
        this.def.hasPermutation = true;

        String source = getClusterArgument(ForceeaService.PARAMETER_SOURCE);
        String lookupObject = getClusterArgument(ForceeaService.PARAMETER_LOOKUP);
        String lookupFieldName = getClusterArgument(ForceeaService.PARAMETER_FIELD);
        List<String> lookupValues = getClusterArguments(ForceeaService.PARAMETER_VALUE);
        List<String> exceptions = getClusterArguments(ForceeaService.PARAMETER_EXCEPT);
        String groupName = getClusterArgument(ForceeaService.PARAMETER_GROUP);
        String whereClause = getClusterArgument(ForceeaService.PARAMETER_WHERE);

        return getLookupValues(ForceeaService.COMMAND_SERIAL, source, lookupObject, lookupFieldName, lookupValues,
            exceptions, groupName, whereClause, ForceeaService.MODE_PERMUTATION, true);
    }

    /**
     * @description Creates mocked IDs.
     * @param sObjectType The SObject type.
     * @return A list of string values.
     */
    private List<String> getMockedIds(Schema.SObjectType sObjectType) {
        List<String> results = new List<String>();
        String prefix = sObjectType.getDescribe().getKeyPrefix() + 'mock';

        for (Integer counter = 0; counter < this.numRecords; counter++) {
            String serialNumber = String.valueOf(FObject.mockingSerialNumber++);
            results.add(prefix + '0'.repeat(8 - serialNumber.length()) + serialNumber);
        }

        return results;
    }

    /**
     * @description Creates mock values.
     * @return A list of string values.
     */
    private List<String> getMockValues() {
        List<String> results = new List<String>();

        switch on this.def.type.id {
            when MOCK_ID {
                Schema.SObjectType objType = FObject.globalDescribeBySObject.get(this.fObj.sObjectName);
                results = getMockedIds(objType);
            }
        }

        return results;
    }

    /**
     * @description Returns the next record number of the SObject.
     * @return The serialized record number of next record.
     */
    public Integer getNumberOfNextRecord() {
        return FObject.numFirstRecordsBySObject.get(this.fObj.sObjectApiName);
    }

    /**
     * @description Returns the permutation values of a specific permutation list.
     * @return The list of permutation values.
     */
    private List<String> getPermutationValues(Integer permutationPosition) {
        List<String> results = new List<String>();
        if (permutationPosition == null || permutationPosition < 0) {
            return results;
        }

        for (Integer counter = 0; counter < this.fObj.permutationValues.size(); counter++) {
            results.add(this.fObj.permutationValues.get(counter).get(permutationPosition));
        }

        return results;
    }

    /**
     * @description Creates random picklist values, respecting the fields dependencies.
     * @param dependentFieldApiName The API name of the dependent field.
     * @param controllingFieldApiName The API name of the controlling field.
     * @param inclusions The picklist values to keep.
     * @param exceptions The picklist values to remove.
     * @return A list of string values.
     */
    private List<String> getPicklistValuesWithRespectToDependencies(
        String dependentFieldApiName, String controllingFieldApiName, List<String> inclusions, List<String> exceptions) {
        exceptions = ForceeaService.convertListToLowercase(exceptions);
        Integer controllingFieldPosition = getFieldPosition(controllingFieldApiName);

        // get the Field Dependencies map (key: controlling field value, value: dependent field values)
        Map<String, Set<String>> fieldDependenciesMap =
            getFieldDependenciesMap(this.fObj.sObjectApiName, controllingFieldApiName, dependentFieldApiName);

        // amend the Field Dependencies map based on the inclusions and exceptions
        if (inclusions != null) { // && !inclusions.isEmpty()
            // keep in the Field Dependencies map only the values of inclusions list
            for (String value : fieldDependenciesMap.keySet()) {
                // remove any value, except from inclusions
                fieldDependenciesMap.get(value).retainAll(inclusions);
            }
        } else if (!exceptions.isEmpty()) {
            // remove the values of the exceptions list from the Field Dependencies map
            for (String value : fieldDependenciesMap.keySet()) {
                fieldDependenciesMap.get(value).removeAll(exceptions); // remove the except values from the set
            }
        }

        List<String> controllingFieldValues = this.fObj.fieldValuesMatrix.get(controllingFieldPosition);
        List<String> dependentFieldValues = new List<String>();

        // the dependent field's values mapped to the controlling field's value
        List<String> results = new List<String>();
        Set<String> fieldDependenciesSet = new Set<String>();
        String controllingFieldValue = '';
        Integer rnd = 0;

        for (Integer counter = 0; counter < this.numRecords; counter++) {
            controllingFieldValue = controllingFieldValues[counter];

            // get the dependent field's value set from the Field Dependencies map
            fieldDependenciesSet = fieldDependenciesMap.get(controllingFieldValue);
            // if there are no mapped values between controlling and dependent field
            if (fieldDependenciesSet == null || fieldDependenciesSet.isEmpty()) {
                results.add(''); // add an empty string to results
            } else { // there at least one value
                dependentFieldValues = new List<String>(fieldDependenciesSet);
                rnd = (FObject.random * dependentFieldValues.size()).intValue();
                results.add(dependentFieldValues[rnd]);
            }
        }

        return results;
    }

    /**
     * @description Creates random addresses having street (with number), postal code, city, state and country.
     * @return A list of ForceeaAddress objects.
     */
    private List<ForceeaAddress> getRandomAddresses() {
        List<ForceeaAddress> results = new List<ForceeaAddress>();

        ForceeaAddress.loadAddresses();
        Integer librarySize = FObject.addressesLibrary.size();

        for (Integer counter = 0; counter < this.numRecords; counter++) {
            Integer rnd = (FObject.random * librarySize).intValue();
            results.add(FObject.addressesLibrary.get(rnd));
        }

        return results;
    }

    /**
     * @description Creates random booleans.
     * @return A list of string values.
     */
    private List<String> getRandomBooleans() {
        List<String> values = new List<String>();

        for (Integer counter = 0; counter < this.numRecords; counter++) {
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
        List<ForceeaAddress> groupAddresses = this.fObj.addressesByGroup.get(addressGroup);
        if (groupAddresses == null || groupAddresses.isEmpty()) {
            // set random addresses
            this.fObj.addressesByGroup.put(addressGroup, getRandomAddresses());
            // get created addresses
            groupAddresses = this.fObj.addressesByGroup.get(addressGroup);
        }

        for (Integer counter = 0; counter < this.numRecords; counter++) {
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
        List<ForceeaAddress> groupAddresses = this.fObj.addressesByGroup.get(addressGroup);
        if (groupAddresses == null || groupAddresses.isEmpty()) {
            // set random addresses
            this.fObj.addressesByGroup.put(addressGroup, getRandomAddresses());
            // get created addresses
            groupAddresses = this.fObj.addressesByGroup.get(addressGroup);
        }

        for (Integer counter = 0; counter < this.numRecords; counter++) {
            values.add(groupAddresses[counter].country);
        }

        return values;
    }

    /**
     * @description Creates random dates.
     * @param fromDate The minimum date.
     * @param toDate The maximum date.
     * @return A list of string values.
     */
    private List<String> getRandomDates(Date fromDate, Date toDate) {
        List<String> values = new List<String>();

        // check arguments
        if (fromDate >= toDate) {
            this.fObj.addError(this.def.fieldApiName, 'The [from] date is greater than or equal to ' +
                'the [to] date in definition [' + this.def.definitionString + ']');
            return values;
        }

        Integer range = fromDate.daysBetween(toDate) + 1;
        Integer days = 0; // the number of days to add to fromDate
        for (Integer counter = 0; counter < this.numRecords; counter++) {
            days = (FObject.random * range).intValue();
            values.add(String.valueOf(fromDate.addDays(days)));
        }

        return values;
    }

    /**
     * @description Returns a list of random datetime values.
     * @param fromDatetime The minimum datetime.
     * @param toDatetime The maximum datetime.
     * @return A list of string values.
    */
    private List<String> getRandomDatetimes(Datetime fromDatetime, Datetime toDatetime) {
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
            this.fObj.addError(this.def.fieldApiName, 'The [from] datetime is greater than or equal to ' +
                'the [to] datetime in definition [' + this.def.definitionString + ']');
            return values;
        }

        Long range = toDatetimePoint - fromDatetimePoint;
        Long randomPoint; // a random value in ms
        for (Integer counter = 0; counter < this.numRecords; counter++) {
            randomPoint = fromDatetimePoint + (FObject.random * range).longValue();
            values.add(String.valueOf(Datetime.newInstance(randomPoint)));
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

        for (Integer counter1 = 0; counter1 < this.numRecords; counter1++) {
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
     * @return A list of string values.
     */
    private List<String> getRandomEmails() {
        List<String> values = new List<String>();
        List<String> includes = new List<String>{
            'lower'
        };
        List<String> names = getRandomStrings(10, 10, 'lower', includes);
        List<String> domains = getRandomDomains(5);

        for (Integer counter = 0; counter < this.numRecords; counter++) {
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

        if (this.fObj.namesByGroup.get(nameGroup) == null) { // there are no created names for this group
            this.fObj.namesByGroup.put(nameGroup, getRandomNames()); // create names
        }

        List<ForceeaName> groupNames = this.fObj.namesByGroup.get(nameGroup); // get the first names for the group

        // get the first names
        for (Integer counter = 0; counter < this.numRecords; counter++) {
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

        if (this.fObj.namesByGroup.get(nameGroup) == null) { // there are no created names for this group
            this.fObj.namesByGroup.put(nameGroup, getRandomNames()); // create names
        }

        List<ForceeaName> groupNames = this.fObj.namesByGroup.get(nameGroup); // get the first names for the group
        for (Integer counter = 0; counter < this.numRecords; counter++) {
            values.add(groupNames[counter].LastName);
        }

        return values;
    }

    /**
     * @description Creates random list values.
     * @return A list of string values.
     */
    private List<String> getRandomListValues() {
        List<String> results = new List<String>();
        List<String> arguments = getClusterArguments(ForceeaService.PARAMETER_VALUE);

        if (this.def.fieldApiName == ForceeaService.RECORD_TYPE_ID) {
            List<String> recordTypeIds = getRecordTypeIdsFromDeveloperNames(arguments);
            if (this.fObj.processMustTerminate()) {
                return results;
            }
            return getRandomValuesFromList(recordTypeIds);
        }

        switch on getFieldDataType() {
            when PICKLIST, MULTIPICKLIST {
                return getRandomListValuesForPicklists();
            }
            when else {
                return getRandomValuesFromList(arguments);
            }
        }
    }

    /**
     * @description Creates random picklist values from a list.
     * @return A list of string values.
     */
    private List<String> getRandomListValuesForPicklists() {
        List<String> arguments = getClusterArguments(ForceeaService.PARAMETER_VALUE);
        List<String> values = new List<String>();
        String fieldApiName = this.def.fieldApiName;

        // get all picklist values
        List<String> picklistValues = new List<String>();
        for (Schema.PicklistEntry picklistEntry : this.fObj.sObjectFieldsByFieldApiName.get(fieldApiName.toLowerCase()).picklistValues) {
            picklistValues.add(picklistEntry.getValue());
        }

        // get field data type
        FObject.Field depField = this.fObj.sObjectFieldsByFieldApiName.get(fieldApiName.toLowerCase());

        // get controlling field's API name
        String ctrlFieldApiName = depField.controllingFieldApiName;

        if (depField.isRestrictedPicklist) {
            arguments = ForceeaService.convertToMasterValues(arguments, picklistValues);
        }

        if (String.isBlank(ctrlFieldApiName) || // the controlling field is a Checkbox or there is no controlling field
            this.fObj.sObjectFieldsByFieldApiName.get(ctrlFieldApiName.toLowerCase()).dataType == Schema.DisplayType.BOOLEAN) {
            values = getRandomValuesFromList(arguments);
        } else { // there is a controlling field
            values = getPicklistValuesWithRespectToDependencies(fieldApiName, ctrlFieldApiName, arguments, null);
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
    private List<String> getRandomLookupValues(List<SObject> lookupRecords, List<String> lookupValues,
        List<String> lookupExceptions, String lookupFieldApiName, String fieldApiName) {
        List<String> results = new List<String>();

        List<String> lookupIds = getLookupIds(lookupRecords, lookupValues, lookupExceptions,
            lookupFieldApiName, fieldApiName);

        Integer size = lookupIds.size();
        Integer rnd = 0;
        if (size == 0) {
            return results;
        }
        if (size == 1) {
            for (Integer counter = 0; counter < this.numRecords; counter++) {
                results.add(lookupIds[0]);
            }
        } else if (size > 1) {
            for (Integer counter = 0; counter < this.numRecords; counter++) {
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
    private List<ForceeaName> getRandomNames() {
        List<ForceeaName> results = new List<ForceeaName>();

        String firstName = '';
        String lastName = '';
        String gender = '';
        Integer firstNamesSize = 0; // size of the first names list
        Integer lastNamesSize = 0; // size of the last names list
        Integer vFirst = 0; // random index for the first name
        Integer vLast = 0; // random index for the last name
        Integer counterNames = 0; // counter of created names
        Integer counterGroups = 0; // counter of groups

        ForceeaName.loadNames();
        Integer numGroups = FObject.lastNamesLibraryByGender.size();

        // get the size of each locality/gender group
        Integer groupSize = this.numRecords / numGroups;

        for (String key : FObject.lastNamesLibraryByGender.keySet()) {
            // get the data (first & last name lists)
            List<String> firstNames = FObject.firstNamesLibraryByGender.get(key);
            List<String> lastNames = FObject.lastNamesLibraryByGender.get(key);

            firstNamesSize = firstNames.size();
            lastNamesSize = lastNames.size();
            gender = key;

            // check if this is the last group
            counterGroups++;
            if (counterGroups == numGroups) {
                groupSize = this.numRecords - counterNames;
            } else {
                counterNames += groupSize;
            }

            // set values
            for (Integer counter = 0; counter < groupSize; counter++) {
                vFirst = (FObject.random * firstNamesSize).intValue();
                firstName = firstNames[vFirst];
                vLast = (FObject.random * lastNamesSize).intValue();
                lastName = lastNames[vLast];
                results.add(new ForceeaName(firstName, lastName, gender));
            }
        }

        ForceeaName temp = new ForceeaName();
        Integer size = results.size();
        for (Integer counter = 0; counter < size; counter++) {
            Integer rnd = (FObject.random * size).intValue();
            temp = results[counter] ;
            results[counter] = results[rnd];
            results[rnd] = temp;
        }

        return results;
    }

    /**
     * @description Returns a list of random decimals.
     * @param fromNumber The minimum decimal.
     * @param toNumber The maximum decimal.
     * @param scale The scale.
     * @return A list of string values.
     */
    private List<String> getRandomNumbers(Decimal fromNumber, Decimal toNumber, Integer scale) {
        List<String> values = new List<String>();

        fromNumber = fromNumber.setScale(scale);
        toNumber = toNumber.setScale(scale);

        // check arguments
        if (fromNumber >= toNumber) {
            this.fObj.addError(this.def.fieldApiName, 'The [from] number is greater than or equal to ' +
                'the [to] number in definition [' + this.def.definitionString + ']');
        }

        Decimal range = toNumber - fromNumber;
        Decimal val = 0;
        for (Integer counter = 0; counter < this.numRecords; counter++) {
            val = fromNumber + FObject.random * range;
            values.add(val.setScale(scale).toPlainString());
        }

        return values;
    }

    /**
     * @description Creates random picklist values.
     * @return A list of string values.
     */
    private List<String> getRandomPicklistValues() {
        String fieldApiName = this.def.fieldApiName;
        if (fieldApiName == ForceeaService.RECORD_TYPE_ID) {
            return getRandomRecordTypes();
        }

        // get dependent and controlling fields
        FObject.Field dependentField = this.fObj.sObjectFieldsByFieldApiName.get(fieldApiName.toLowerCase());
        String controllingFieldApiName = dependentField.controllingFieldApiName;

        List<String> results = new List<String>();
        List<String> exceptions = getClusterArguments(ForceeaService.PARAMETER_EXCEPT);
        if (String.isBlank(controllingFieldApiName) || this.fObj.isUpdate || fieldIsCheckbox(controllingFieldApiName)) {
            List<String> picklistValues = getFieldPicklistValuesExcludingExceptions();
            results = getRandomValuesFromList(picklistValues);
        } else { // there is a controlling field
            results = getPicklistValuesWithRespectToDependencies(fieldApiName, controllingFieldApiName, null, exceptions);
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

        for (Integer counter = 0; counter < this.numRecords; counter++) {
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
     * @description Creates random postal codes.
     * @param addressGroup The group of this address.
     * @return A list of string values.
     */
    private List<String> getRandomPostalCodes(String addressGroup) {
        List<String> results = new List<String>();

        // create addresses if needed
        List<ForceeaAddress> groupAddresses = this.fObj.addressesByGroup.get(addressGroup);
        if (groupAddresses == null || groupAddresses.isEmpty()) {
            this.fObj.addressesByGroup.put(addressGroup, getRandomAddresses());  // set random addresses
            groupAddresses = this.fObj.addressesByGroup.get(addressGroup);
        }

        for (Integer counter = 0; counter < this.numRecords; counter++) {
            results.add(groupAddresses[counter].postalCode);
        }

        return results;
    }

    /**
     * @description Creates random Record Type IDs, excluding specific values.
     * @return A list of IDs as string values.
     */
    private List<String> getRandomRecordTypes() {
        List<String> recordTypeIds = getRecordTypeIdsExcludingExceptions();
        return getRandomValuesFromList(recordTypeIds);
    }

    /**
     * @description Creates random states.
     * @param addressGroup The group of this address.
     * @return A list of string values.
     */
    private List<String> getRandomStates(String addressGroup) {
        List<String> results = new List<String>();

        // create addresses if needed
        List<ForceeaAddress> groupAddresses = this.fObj.addressesByGroup.get(addressGroup);
        if (groupAddresses == null || groupAddresses.isEmpty()) {
            // set random addresses
            this.fObj.addressesByGroup.put(addressGroup, getRandomAddresses());
            // get created addresses
            groupAddresses = this.fObj.addressesByGroup.get(addressGroup);
        }

        for (Integer counter = 0; counter < this.numRecords; counter++) {
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
        List<ForceeaAddress> groupAddresses = this.fObj.addressesByGroup.get(addressGroup);
        if (groupAddresses == null || groupAddresses.isEmpty()) {
            // set random addresses
            this.fObj.addressesByGroup.put(addressGroup, getRandomAddresses());
            // get created addresses
            groupAddresses = this.fObj.addressesByGroup.get(addressGroup);
        }

        Integer rnd = 0;
        String street = '';

        for (Integer counter = 0; counter < this.numRecords; counter++) {
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
     * @return A list of string values.
     */
    private List<String> getRandomStrings(
        Integer minlength, Integer maxlength, String startsWith, List<String> includes) {
        List<String> results = new List<String>();
        String lowerChars = 'abcdefghijklmnopqrstuvwxyz';
        String upperChars = 'ABCDEFGHIJKLMNOPQRSUVWXYZ';
        String digits = '0123456789';
        String charsToSelect = ''; // the selection chars for the rest of the string

        // check arguments
        if (minlength <= 0) {
            this.fObj.addError(this.def.fieldApiName, 'The minimum length should be greater than or equal to 1 ' +
                'in definition [' + this.def.definitionString + ']');
        }
        if (minlength > maxlength) {
            this.fObj.addError(this.def.fieldApiName, 'The minimum length should be less than or equal to ' +
                'the maximum length in definition [' + this.def.definitionString + ']');
        }

        // define the chars to select from
        for (String item : ForceeaService.convertListToLowercase(includes)) {
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

        for (Integer counter1 = 0; counter1 < this.numRecords; counter1++) {
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
     * @return A list of string values.
     */
    private List<String> getRandomTexts(Integer minLength, Integer maxLength) {
        List<String> results = new List<String>();

        // check arguments
        if (minLength <= 0) {
            this.fObj.addError(this.def.fieldApiName, 'The minimum length should be greater than or equal to 1 ' +
                'in definition [' + this.def.definitionString + ']');
        }
        if (minLength >= maxLength) {
            this.fObj.addError(this.def.fieldApiName, 'The minimum length should be less than the maximum length ' +
                'in definition [' + this.def.definitionString + ']');
        }

        if (this.fObj.processMustTerminate()) {
            return results;
        }

        String result = '';
        Integer rnd = 0;
        Integer randomLength = 0;
        Integer newLength = 0;
        String previousWord = '';
        String newWord = '';
        Integer numWords = words.size();

        for (Integer counter = 0; counter < this.numRecords; counter++) {
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
     * @description Returns a list of random time values.
     * @param fromDatetime The minimum datetime.
     * @param toDatetime The maximum datetime.
     * @return A list of string values.
     */
    private List<String> getRandomTimes(Datetime fromDatetime, Datetime toDatetime) {
        List<String> values = new List<String>();

        Long fromDatetimePoint = fromDatetime.getTime(); // ms from 1/1/1970
        Long toDatetimePoint = toDatetime.getTime(); // ms from 1/1/1970
        if (fromDatetimePoint >= toDatetimePoint) {
            this.fObj.addError(this.def.fieldApiName, 'The [from] time is greater than or equal to ' +
                'the [to] time in definition [' + this.def.definitionString + ']');
            return values;
        }

        Long range = toDatetimePoint - fromDatetimePoint;
        Long randomPoint = 0;
        for (Integer counter = 0; counter < this.numRecords; counter++) {
            randomPoint = fromDatetimePoint + (FObject.random * range).longValue();
            Datetime dt = Datetime.newInstance(randomPoint);
            Integer hour = dt.hour();
            Integer min = dt.minute();
            Integer sec = dt.second();
            values.add(String.valueOf(Time.newInstance(hour, min, sec, 0)));
        }

        return values;
    }

    /**
     * @description Creates random URLs.
     * @return A list of string values.
     */
    private List<String> getRandomUrls() {
        List<String> results = new List<String>();
        List<String> domains = getRandomDomains(5);

        for (Integer counter = 0; counter < this.numRecords; counter++) {
            results.add('http://www.' + domains[counter]);
        }

        return results;
    }

    /**
     * @description Creates random values.
     * @return A list of string values.
     */
    private List<String> getRandomValues() {
        List<String> results = new List<String>();

        switch on this.def.type.id {
            when RANDOM_NUMBER {
                Decimal fromArgm = Decimal.valueOf(getClusterArgument(ForceeaService.PARAMETER_FROM));
                Decimal toArgm = Decimal.valueOf(getClusterArgument(ForceeaService.PARAMETER_TO));
                Integer scaleArgm = Integer.valueOf(getClusterArgument(ForceeaService.PARAMETER_SCALE));
                results = getRandomNumbers(fromArgm, toArgm, scaleArgm);
            }
            when RANDOM_DATE {
                Date fromArgm = Date.valueOf(getClusterArgument(ForceeaService.PARAMETER_FROM));
                Date toArgm = Date.valueOf(getClusterArgument(ForceeaService.PARAMETER_TO));
                results = getRandomDates(fromArgm, toArgm);
            }
            when RANDOM_DATETIME {
                Datetime fromArgm;
                Datetime toArgm;
                try {
                    fromArgm = Datetime.valueOf(getClusterArgument(ForceeaService.PARAMETER_FROM));
                } catch (TypeException ex) {
                    fromArgm = Datetime.newInstance(
                        Date.valueOf(getClusterArgument(ForceeaService.PARAMETER_FROM)), Time.newInstance(0, 0, 0, 0));
                }
                try {
                    toArgm = Datetime.valueOf(getClusterArgument(ForceeaService.PARAMETER_TO));
                } catch (TypeException ex) {
                    toArgm = Datetime.newInstance(
                        Date.valueOf(getClusterArgument(ForceeaService.PARAMETER_TO)), Time.newInstance(0, 0, 0, 0));
                }
                results = getRandomDatetimes(fromArgm, toArgm);
            }
            when RANDOM_TIME {
                Datetime fromArgm;
                Datetime toArgm;
                try {
                    fromArgm = Datetime.valueOf('2020-1-1 ' + getClusterArgument(ForceeaService.PARAMETER_FROM));
                } catch (TypeException ex) {
                    fromArgm = Datetime.valueOf('2020-1-1 00:00:00');
                }
                try {
                    toArgm = Datetime.valueOf('2020-1-1 ' + getClusterArgument(ForceeaService.PARAMETER_TO));
                } catch (TypeException ex) {
                    fromArgm = Datetime.valueOf('2020-1-1 23:59:59');
                }
                results = getRandomTimes(fromArgm, toArgm);
            }
            when RANDOM_PICKLIST, RANDOM_PICKLIST_EXCEPT {
                results = getRandomPicklistValues();
            }
            when RANDOM_LIST_STRING, RANDOM_LIST_INTEGER, RANDOM_LIST_DECIMAL,
                RANDOM_LIST_DATE, RANDOM_LIST_TIME, RANDOM_LIST_DATETIME {
                results = getRandomListValues();
            }
            when RANDOM_EMAIL {
                results = getRandomEmails();
            }
            when RANDOM_URL {
                results = getRandomUrls();
            }
            when RANDOM_BOOLEAN {
                results = getRandomBooleans();
            }
            when RANDOM_FIRSTNAME {
                String nameGroup = getClusterArgument(ForceeaService.PARAMETER_GROUP);
                results = getRandomFirstNames(nameGroup);
            }
            when RANDOM_LASTNAME {
                String nameGroup = getClusterArgument(ForceeaService.PARAMETER_GROUP);
                results = getRandomLastNames(nameGroup);
            }
            when RANDOM_STREET {
                String addressGroup = getClusterArgument(ForceeaService.PARAMETER_GROUP);
                results = getRandomStreets(addressGroup);
            }
            when RANDOM_POSTALCODE {
                String addressGroup = getClusterArgument(ForceeaService.PARAMETER_GROUP);
                results = getRandomPostalCodes(addressGroup);
            }
            when RANDOM_CITY {
                String addressGroup = getClusterArgument(ForceeaService.PARAMETER_GROUP);
                results = getRandomCities(addressGroup);
            }
            when RANDOM_STATE {
                String addressGroup = getClusterArgument(ForceeaService.PARAMETER_GROUP);
                results = getRandomStates(addressGroup);
            }
            when RANDOM_COUNTRY {
                String addressGroup = getClusterArgument(ForceeaService.PARAMETER_GROUP);
                results = getRandomCountries(addressGroup);
            }
            when RANDOM_STRING {
                Integer minlength = Integer.valueOf(getClusterArgument('minlength'));
                Integer maxlength = Integer.valueOf(getClusterArgument('maxlength'));
                String startsWith = getClusterArgument('startwith');
                List<String> includes = getClusterArguments('include');
                results = getRandomStrings(minlength, maxlength, startsWith, includes);
            }
            when RANDOM_TEXT {
                Integer minLength = Integer.valueOf(getClusterArgument('minlength'));
                Integer maxLength = Integer.valueOf(getClusterArgument('maxlength'));
                results = getRandomTexts(minLength, maxLength);
            }
            when RANDOM_PHONE {
                String formatString = getClusterArgument('format');
                results = getRandomPhoneNumbers(formatString);
            }
            when RANDOM_LOOKUP {
                String source = getClusterArgument(ForceeaService.PARAMETER_SOURCE);
                String lookupObject = getClusterArgument(ForceeaService.PARAMETER_LOOKUP);
                String lookupField = getClusterArgument(ForceeaService.PARAMETER_FIELD);
                List<String> lookupValues = getClusterArguments(ForceeaService.PARAMETER_VALUE);
                List<String> lookupExceptValues = getClusterArguments(ForceeaService.PARAMETER_EXCEPT);
                String groupName = getClusterArgument(ForceeaService.PARAMETER_GROUP);
                results = getLookupValues(ForceeaService.COMMAND_RANDOM, source,
                    lookupObject, lookupField, lookupValues, lookupExceptValues,
                    groupName, null, null, false);
            }
            when RANDOM_LOOKUP_WHERE {
                String source = getClusterArgument(ForceeaService.PARAMETER_SOURCE);
                String lookupObject = getClusterArgument(ForceeaService.PARAMETER_LOOKUP);
                String whereClause = getClusterArgument(ForceeaService.PARAMETER_WHERE);
                results = getLookupValues(ForceeaService.COMMAND_RANDOM, source, lookupObject, null, null,
                    null, '', whereClause, null, false);
            }
        }

        return results;
    }

    /**
     * @description Creates random values from a list.
     * @param values A list of input values.
     * @return A list of values.
     */
    private List<String> getRandomValuesFromList(List<String> values) {
        List<String> results = new List<String>();
        Integer size = values.size();

        switch on size {
            when 0 {
                return results;
            }
            when 1 {
                String value = values.get(0);
                for (Integer counter = 0; counter < this.numRecords; counter++) {
                    results.add(value);
                }
                return results;
            }
        }

        Integer rnd = 0;
        for (Integer counter = 0; counter < this.numRecords; counter++) {
            rnd = (FObject.random * size).intValue();
            results.add(values.get(rnd));
        }

        return results;
    }

    /**
     * @description Retrieves the Record Type IDs, excluding exceptions of Developer Names.
     * @return A list of Recors Type IDs.
     */
    private List<String> getRecordTypeIdsExcludingExceptions() {
        List<String> results = new List<String>();
        List<String> exceptions = ForceeaService.convertListToLowercase(
            getClusterArguments(ForceeaService.PARAMETER_EXCEPT)
        );

        if (exceptions.isEmpty()) {
            results.addAll(this.fObj.recordTypeIdsByDeveloperName.values());
            return results;
        }

        for (String name : this.fObj.recordTypeIdsByDeveloperName.keySet()) {
            if (!exceptions.contains(name)) {
                results.add(this.fObj.recordTypeIdsByDeveloperName.get(name));
            }
        }

        return results;
    }

    /**
     * @description Retrieves the Record Type IDs related to case-insensitive developer names.
     * @param developerNames A list of Record Type developer names.
     * @return A list of Record Type IDs.
     */
    private List<String> getRecordTypeIdsFromDeveloperNames(List<String> developerNames) {
        List<String> results = new List<String>();

        for (String name : developerNames) {
            String nameToLowerCase = name.toLowerCase();

            if (this.fObj.recordTypeIdsByDeveloperName.containsKey(nameToLowerCase)) {
                results.add(this.fObj.recordTypeIdsByDeveloperName.get(nameToLowerCase));
            } else {
                this.fObj.addError(this.def.fieldApiName,
                    'Invalid record type [' + name + '] for definition [' + this.def.definitionString + ']');
            }
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

        for (Integer counter = 0; counter < this.numRecords; counter++) {
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

        for (Integer counter = 0; counter < this.numRecords; counter++) {
            results.add(String.valueOf(val));
            val = val.addDays(stepDays);
            val = val.addHours(stepHours);
            val = val.addMinutes(stepMinutes);
            val = val.addSeconds(stepSeconds);
        }

        return results;
    }

    /**
     * @description Creates serial string values.
     * @param values The string values.
     * @param permutationPosition The definition position in permutations.
     * @return A list of string values.
     */
    private List<String> getSerialListValues(List<String> values, Integer permutationPosition) {
        List<String> results = new List<String>();

        if (values.isEmpty()) {
            return results;
        }

        String mode = getClusterArgument(ForceeaService.PARAMETER_MODE);
        Integer counter = 0;
        Integer size = values.size();

        switch on mode.toLowerCase() {
            when 'cyclical' {
                for (Integer recordCounter = 0; recordCounter < this.numRecords; recordCounter++) {
                    if (counter == size) {
                        counter = 0;
                    }
                    results.add(values.get(counter));
                    counter++;
                }
            }
            when 'first' {
                for (Integer recordCounter = 0; recordCounter < this.numRecords; recordCounter++) {
                    if (recordCounter >= size) {
                        counter = 0;
                    }
                    results.add(values.get(counter));
                    counter++;
                }
            }
            when 'last' {
                for (Integer recordCounter = 0; recordCounter < this.numRecords; recordCounter++) {
                    if (recordCounter >= size) {
                        counter = (size - 1);
                    }
                    results.add(values.get(counter));
                    counter++;
                }
            }
            when 'null' {
                size = (size > this.numRecords ? this.numRecords : size);
                for (Integer recordCounter = 0; recordCounter < size; recordCounter++) {
                    results.add(values.get(recordCounter));
                }
            }
            when 'permutation' {
                results = getPermutationValues(permutationPosition);
            }
        }

        return results;
    }

    /**
     * @description Creates serial lookup IDs.
     * @param lookupRecords The list of lookup records.
     * @param lookupValues The list of lookup values.
     * @param lookupExceptions The list of exception lookup values.
     * @param lookupFieldApiName The API name of the lookup field.
     * @param fieldApiName The API name of the field.
     * @param lookupMode The lookup mode.
     * @return A list of IDs.
     */
    private List<String> getSerialLookupValues(
        List<SObject> lookupRecords, List<String> lookupValues,
        List<String> lookupExceptions, String lookupFieldApiName, String fieldApiName,  String lookupMode) {
        List<String> results = new List<String>();

        List<String> lookupIds = getLookupIds(lookupRecords, lookupValues, lookupExceptions,
            lookupFieldApiName, fieldApiName);

        Integer size = lookupIds.size();
        if (size == 0) {
            return results;
        }

        Integer lookupCounter = 0;
        switch on lookupMode.toLowerCase() {
            when 'cyclical' {
                for (Integer recordCounter = 0; recordCounter < this.numRecords; recordCounter++) {
                    if (lookupCounter == size) {
                        lookupCounter = 0;
                    }
                    results.add(lookupIds.get(lookupCounter));
                    lookupCounter++;
                }
            }
            when 'first' {
                for (Integer recordCounter = 0; recordCounter < this.numRecords; recordCounter++) {
                    if (recordCounter >= size) {
                        lookupCounter = 0;
                    }
                    results.add(lookupIds.get(lookupCounter));
                    lookupCounter++;
                }
            }
            when 'last' {
                for (Integer recordCounter = 0; recordCounter < this.numRecords; recordCounter++) {
                    if (recordCounter >= size) {
                        lookupCounter = (size - 1);
                    }
                    results.add(lookupIds.get(lookupCounter));
                    lookupCounter++;
                }
            }
            when 'null' {
                size = (size > this.numRecords ? this.numRecords : size);
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
     * @param scale The scale.
     * @return A list of string values.
     */
    private List<String> getSerialNumbers(Decimal fromNumber, Decimal stepNumber, Integer scale) {
        List<String> results = new List<String>();

        Decimal val = fromNumber + (getNumberOfNextRecord() - 1) * stepNumber;
        for (Integer counter = 0; counter < this.numRecords; counter++) {
            results.add(val.setScale(scale).toPlainString());
            val += stepNumber;
        }

        return results;
    }

    /**
     * @description Creates serial picklist values.
     * @param permutationPosition The definition position in permutations.
     * @return A list of string values.
     */
    private List<String> getSerialPicklistValues(Integer permutationPosition) {
        List<String> results = new List<String>();
        List<String> picklistValues = new List<String>();

        switch on this.def.fieldApiName {
            when 'RecordTypeId' {
                picklistValues = getRecordTypeIdsExcludingExceptions();
            }
            when else {
                picklistValues = getFieldPicklistValuesExcludingExceptions();
            }
        }

        if (picklistValues.isEmpty()) {
            return results;
        }

        return getSerialListValues(picklistValues, permutationPosition);
    }

    /**
     * @description Creates serial values.
     * @return A list of string values.
     */
    private List<String> getSerialValues() {
        List<String> results = new List<String>();

        switch on this.def.type.id {
            when SERIAL_PICKLIST {
                results = getSerialPicklistValues(this.def.positionForPermutations);
            }
            when SERIAL_LIST {
                List<String> values = getClusterArguments(ForceeaService.PARAMETER_VALUE);
                results = getSerialListValues(values, this.def.positionForPermutations);
            }
            when SERIAL_NUMBER {
                Decimal fromArgm = Decimal.valueOf(getClusterArgument(ForceeaService.PARAMETER_FROM));
                Decimal stepArgm = Decimal.valueOf(getClusterArgument('step'));
                Integer scaleArgm = Integer.valueOf(getClusterArgument(ForceeaService.PARAMETER_SCALE));
                results = getSerialNumbers(fromArgm, stepArgm, scaleArgm);
            }
            when SERIAL_DATE {
                Date fromArgm = Date.valueOf(getClusterArgument(ForceeaService.PARAMETER_FROM));
                Integer stepArgm = Integer.valueOf(getClusterArgument('step'));
                results = getSerialDates(fromArgm, stepArgm);
            }
            when SERIAL_DATETIME {
                Datetime fromArgm;
                try {
                    fromArgm = Datetime.valueOf(getClusterArgument(ForceeaService.PARAMETER_FROM));
                } catch (TypeException ex) {
                    fromArgm = Datetime.newInstance(
                        Date.valueOf(getClusterArgument(ForceeaService.PARAMETER_FROM)), Time.newInstance(0, 0, 0, 0));
                }
                Decimal stepArgm = Decimal.valueOf(getClusterArgument('step'));
                results = getSerialDatetimes(fromArgm, stepArgm);
            }
            when SERIAL_LOOKUP {
                String source = getClusterArgument(ForceeaService.PARAMETER_SOURCE);
                String lookupObject = getClusterArgument(ForceeaService.PARAMETER_LOOKUP);
                String lookupField = getClusterArgument(ForceeaService.PARAMETER_FIELD);
                String whereClause = getClusterArgument(ForceeaService.PARAMETER_WHERE);
                String lookupMode = getClusterArgument(ForceeaService.PARAMETER_MODE);
                List<String> lookupValues = getClusterArguments(ForceeaService.PARAMETER_VALUE);
                List<String> exceptions = getClusterArguments(ForceeaService.PARAMETER_EXCEPT);
                String groupName = getClusterArgument(ForceeaService.PARAMETER_GROUP);
                results = getLookupValues(ForceeaService.COMMAND_SERIAL, source, lookupObject, lookupField, lookupValues,
                    exceptions, groupName, whereClause, lookupMode, false);
            }
        }

        return results;
    }

    /**
     * @description Creates static lookup IDs.
     * @param lookupRecords The list of lookup records.
     * @param lookupValues The list of lookup values.
     * @param lookupExceptions The list of exception lookup values.
     * @param lookupFieldApiName The API name of the lookup field.
     * @param fieldApiName The API name of the field.
     * @return A list of IDs.
     */
    private List<String> getStaticLookupValues(List<SObject> lookupRecords, List<String> lookupValues,
        List<String> lookupExceptions, String lookupFieldApiName, String fieldApiName) {
        List<String> lookupIds = getLookupIds(lookupRecords, lookupValues, lookupExceptions,
            lookupFieldApiName, fieldApiName);
        return getStaticValuesFromValue(lookupIds.get(0));
    }

    /**
     * @description Creates static values.
     * @return A list of string values.
     */
    private List<String> getStaticValues() {
        List<String> results = new List<String>();

        switch on this.def.type.id {
            when STATIC_STRING , STATIC_INTEGER , STATIC_DECIMAL , STATIC_DATE, STATIC_TIME,  STATIC_DATETIME{
                String value = getClusterArgument(ForceeaService.PARAMETER_VALUE);
                results = getStaticValues(value);
            }
            when STATIC_LOOKUP{
                String lookupObject = getClusterArgument(ForceeaService.PARAMETER_LOOKUP);
                String lookupField = getClusterArgument(ForceeaService.PARAMETER_FIELD);
                List<String> lookupValues = getClusterArguments(ForceeaService.PARAMETER_VALUE);
                List<String> lookupExceptions = getClusterArguments(ForceeaService.PARAMETER_EXCEPT);
                String groupName = getClusterArgument(ForceeaService.PARAMETER_GROUP);
                String whereClause = getClusterArgument(ForceeaService.PARAMETER_WHERE);
                String source = getClusterArgument(ForceeaService.PARAMETER_SOURCE);
                results = getLookupValues('static', source, lookupObject, lookupField, lookupValues,
                    lookupExceptions, groupName, whereClause, null, false);
            }
        }

        return results;
    }

    /**
     * @description Creates static values.
     * @param argument The static value.
     * @return A list of string values.
     */
    private List<String> getStaticValues(String argument) {
        List<String> results = new List<String>();
        String fieldApiName = this.def.fieldApiName;

        if (fieldApiName == ForceeaService.RECORD_TYPE_ID) {
            List<String> recordTypeIds = getRecordTypeIdsFromDeveloperNames(new List<String> {argument});
            if (this.fObj.processMustTerminate()) {
                return results;
            }
            return getStaticValuesFromValue(recordTypeIds.get(0));
        }

        FObject.Field depField = this.fObj.sObjectFieldsByFieldApiName.get(fieldApiName.toLowerCase());
        Set<Schema.DisplayType> types = new Set<DisplayType>{
            Schema.DisplayType.PICKLIST, Schema.DisplayType.MULTIPICKLIST
        };
        if (this.def.isVirtualField || !types.contains(depField.dataType)) {
            for (Integer counter = 0; counter < this.numRecords; counter++) {
                results.add(argument);
            }
            return results;
        }

        List<String> picklistValues = new List<String>();
        for (Schema.PicklistEntry picklistEntry : depField.picklistValues) {
            picklistValues.add(picklistEntry.getValue());
        }

        String ctrlFieldApiName = depField.controllingFieldApiName; // get controlling field's API name
        List<String> arguments = new List<String>{
            argument
        };

        if (depField.isRestrictedPicklist) { // if the field is restricted remove argument if not a valid picklist value
            arguments = ForceeaService.keepValuesInList(arguments, picklistValues);
        }

        if (String.isBlank(ctrlFieldApiName) || // the controlling field is a Checkbox or there is no controlling field
            this.fObj.sObjectFieldsByFieldApiName.get(ctrlFieldApiName.toLowerCase()).dataType == Schema.DisplayType.BOOLEAN) {
            results = getRandomValuesFromList(arguments);
        } else { // there is a controlling field
            results = getPicklistValuesWithRespectToDependencies(fieldApiName, ctrlFieldApiName, arguments, null);
        }

        return results;
    }

    /**
     * @description Creates a list of values equal to a specific value.
     * @param value The value.
     * @return A list of string values.
     */
    private List<String> getStaticValuesFromValue(String value) {
        List<String> results = new List<String>();

        for (Integer counter = 0; counter < this.numRecords; counter++) {
            results.add(value);
        }

        return results;
    }

    /**
     * @description Creates field values.
     * @return A list of string values.
     */
    public List<String> getValues() {
        List<String> results = new List<String>();

        if (this.def.isFunction) {
            return getFunctionValues();
        }

        switch on this.def.command.toLowerCase() {
            when 'copy' {
                results = getCopyValues();
            }
            when 'mock' {
                results = getMockValues();
            }
            when 'random' {
                results = getRandomValues();
            }
            when 'serial' {
                results = getSerialValues();
            }
            when 'static' {
                results = getStaticValues();
            }
        }

        return results;
    }

    /**
     * @description Validates a source.
     * @param source The definition source.
     * @return A boolean value.
     */
    private Boolean sourceIsValid(String source) {
        return (ForceeaGenerator.sourcesSet.contains(source.toLowerCase()));
    }

}
