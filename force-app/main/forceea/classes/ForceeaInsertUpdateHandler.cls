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
 * @description Handles the DML insertions/updates.
 */
public with sharing class ForceeaInsertUpdateHandler {

    /* CONSTANTS */

    private static final String MESSAGE_WILL_UPDATE_FIELD_VALUES = 'Will update the field values';
    private static final String TOKEN_PRICEBOOK_ENTRY = 'pricebookentry.';

    /* INSTANCE VARIABLES & PROPERTIES */

    private FObject fObj { get; set; }

    /* CONSTRUCTORS */

    /**
     * @description The constructor for the class.
     * @param fObj An FObject object.
     */
    public ForceeaInsertUpdateHandler(FObject fObj) {
        this.fObj = fObj;
    }

    /* METHODS */

    /**
     * @description Adds a list of PricebookEntry records to the global inserted map.
     * @param recordsToAdd The list of PricebookEntry records to add.
     */
    private void addPricebookEntriesToGlobalMap(List<SObject> recordsToAdd) {
        List<SObject> records = new List<SObject>();

        String key = TOKEN_PRICEBOOK_ENTRY;
        if (FObject.globalInsertedRecordsByGroup.containsKey(key)) {
            records = FObject.globalInsertedRecordsByGroup.get(key);
        }

        records.addAll(recordsToAdd);
        FObject.globalInsertedRecordsByGroup.put(key, records);
    }

    private void deleteAllDefinitionsForUpdateOfAllFields() {
        List<String> fieldsToRemove = new List<String>(this.fObj.fieldsForUpdate);

        for (String fieldName : fieldsToRemove) {
            this.fObj.removeAllDefinitionsOfField(fieldName);
        }
    }

    /**
     * @description Retrieves the position of a field.
     * @param fieldApiName The API name of the field.
     * @return An integer value.
     */
    private Integer getFieldPosition(String fieldApiName) {
        Integer result = -1;
        Integer counter = 0;

        for (String field : this.fObj.fields) {
            if (field == fieldApiName) {
                result = counter;
                break;
            }
            counter++;
        }

        return result;
    }

    /**
     * @description Inserts the created records.
     * @param allOrNone Specifies whether the operation allows partial success. If you specify false
     *   for this parameter and a record fails, the remainder of the DML operation can still succeed.
     * @param groupName The group name of the inserted records.
     * @return A list of Database.SaveResult objects.
     */
    public List<Database.SaveResult> getInsertResults(Boolean allOrNone, String groupName) {
        List<Database.SaveResult> results = new List<Database.SaveResult>();
        if (FObject.processMustTerminate() || allOrNone == null) {
            return results;
        }

        onBeforeInsertRecords(groupName);
        handleCreationOfRecords();

        if (FObject.processMustTerminate()) {
            onAfterInsertRecords();
            return results;
        }

        if (this.fObj.isMocking) {
            new ForceeaDomain(this.fObj).insertRecordsWithMockedIds();
        } else {
            new ForceeaDomain(this.fObj).insertRecordsWithoutMockedIds(allOrNone);
            results = new List<Database.SaveResult>(this.fObj.saveResults);
        }

        onAfterInsertRecords();
        return results;
    }

    /**
     * @description Creates a PricebookEntry record.
     * @param productId The product ID.
     * @param unitPrice The unit price.
     * @return An PricebookEntry SObject record.
     */
    private SObject getPricebookEntry(Id productId, Decimal unitPrice) {
        SObject result = PricebookEntry.SObjectType.newSObject();

        result.put('IsActive', true);
        result.put('Pricebook2Id', this.fObj.standardPriceBookId);
        result.put('Product2Id', productId);
        result.put('UnitPrice', unitPrice);

        return result;
    }

    /**
     * @description Retrieves the records to update.
     * @param groupName The group name.
     * @return A list of SObjects.
     */
    private List<SObject> getRecordsToUpdate(String groupName) {
        List<SObject> results = new List<SObject>();

        if (groupName == null) {
            results = this.fObj.createdRecords;
        } else if (String.isBlank(groupName)) {
            results = this.fObj.getInsertedRecords();
        } else {
            results = this.fObj.getInsertedGroupRecords(groupName);
        }

        return results;
    }

    /**
     * @description Retrieves the list of Standard Pricebook entries to insert.
     * @param virtualFieldValues The list of virtual field values.
     * @return An PricebookEntry SObject record.
     */
    private List<SObject> getStandardPricebookEntriesToInsert(List<String> virtualFieldValues) {
        List<SObject> results = new List<SObject>();
        Integer counter = 0;

        for (SObject record : this.fObj.productsToInsertPricebookEntries) {
            SObject newPricebookEntry = getPricebookEntry(record.Id, Decimal.valueOf(virtualFieldValues.get(counter)));
            results.add(newPricebookEntry);
            counter++;
        }

        return results;
    }

    /**
     * @description Updates the created records.
     * @param allOrNone Specifies whether the operation allows partial success. If you specify false
     *   for this parameter and a record fails, the remainder of the DML operation can still succeed.
     * @return A list of Database.SaveResult objects.
     */
    public List<Database.SaveResult> getUpdateResults(Boolean allOrNone) {
        List<Database.SaveResult> results = new List<Database.SaveResult>();
        if (FObject.processMustTerminate() || allOrNone == null) {
            return results;
        }

        onBeforeUpdateRecords();
        new ForceeaDomain(this.fObj).handleRecordsOnUpdate(allOrNone);
        onAfterUpdateRecords();

        return new List<Database.SaveResult>(this.fObj.saveResults);
    }

    /**
     * @description Creates new records if applicable.
     */
    private void handleCreationOfRecords() {
        if (this.fObj.recordsToInsert.isEmpty()) {
            this.fObj.mustCreateNewRecords = true;
        } else {
            this.fObj.mustCreateNewRecords = false;
        }
        this.fObj.createNewRecords();
    }

    /**
     * @description Updates records using field definitions for update.
     * @param groupName The group name.
     */
    private void handleRecordsWithUpdatedValues(String groupName) {
        this.fObj.recordsToUpdate = getRecordsToUpdate(groupName);
        this.fObj.records = this.fObj.recordsToUpdate.size();
        if (this.fObj.recordsToUpdate.isEmpty()) {
            return;
        }

        validateDefinitionsOnUpdate();
        if (FObject.processMustTerminate()) {
            return;
        }

        ForceeaFieldValuesMatrixHandler handler = new ForceeaFieldValuesMatrixHandler(this.fObj);
        handler.initializeFieldValuesMatrix();
        handler.createAndDisplayFieldValues();

        if (this.fObj.numDefinitionsWithData == 0) {
            this.fObj.recordsToUpdate = new List<SObject>();
            return;
        }

        setRecordsToUpdateWithNewFieldValues();
    }

    /**
     * @description Inserts entries for the Standard Price Book using the values of a virtual field.
     */
    private void insertStandardPricebookEntries() {
        if (String.isBlank(this.fObj.virtualFieldForStandardPriceBookEntries) ||
            this.fObj.sObjectApiName != FObject.PRODUCT2
        ) {
            return;
        }

        this.fObj.productsToInsertPricebookEntries = (List<Product2>) this.fObj.createdRecords;
        if (this.fObj.productsToInsertPricebookEntries.isEmpty()) {
            return;
        }

        Integer virtualFieldPosition = getFieldPosition(this.fObj.virtualFieldForStandardPriceBookEntries);
        if (virtualFieldPosition == -1) {
            this.fObj.addError(this.fObj.sObjectApiName, FObject.MESSAGE_INVALID_VIRTUAL_FIELD + ' [' +
                this.fObj.virtualFieldForStandardPriceBookEntries + '] ' +
                FObject.MESSAGE_METHOD_SET_STANDARD_PRICEBOOK_ENTRIES);
            return;
        }

        List<String> virtualFieldValues = new List<String>();
        String fieldValue = '';
        for (Integer counter = 0; counter < this.fObj.productsToInsertPricebookEntries.size(); counter++) {
            fieldValue = this.fObj.fieldValuesMatrix.get(virtualFieldPosition).get(counter);
            virtualFieldValues.add(fieldValue);
        }

        insertStandardPricebookEntriesFromVirtualFieldValues(virtualFieldValues);
    }

    /**
     * @description Inserts Standard Pricebook entries from virtual field values.
     * @param virtualFieldValues A list of string UnitPrice values.
     */
    private void insertStandardPricebookEntriesFromVirtualFieldValues(List<String> virtualFieldValues) {
        if (!FObject.processIsValid ||
            String.isBlank(this.fObj.standardPriceBookId) ||
            virtualFieldValues.isEmpty() ||
            this.fObj.isMocking
        ) {
            return;
        }
        List<SObject> pricebookEntriesToInsert = getStandardPricebookEntriesToInsert(virtualFieldValues);
        addPricebookEntriesToGlobalMap(pricebookEntriesToInsert);
        Database.insert(pricebookEntriesToInsert, true);
        new ForceeaDebugHandler(this.fObj)
            .displayMessageInsertedStandardPriceBookEntries(pricebookEntriesToInsert.size());
    }

    /**
     * @description Executes after the insertion of records.
     */
    private void onAfterInsertRecords() {
        if (FObject.processMustTerminate()) {
            return;
        }

        this.fObj.addRecordsToMapsOnInsert();
        insertStandardPricebookEntries();
        this.fObj.handleDmlMilestone();
        this.fObj.dmlIsInsert = false;
        this.fObj.productsToInsertPricebookEntries.clear();
        this.fObj.recordsToInsert.clear();
        this.fObj.virtualFieldForStandardPriceBookEntries = '';
        this.fObj.cpuTimeOfDataGeneration = Limits.getCpuTime() - this.fObj.cpuTimeStartOfDataGeneration;
        new ForceeaDebugHandler(this.fObj).displaySeparatorOnMethodFinish();
    }

    /**
     * @description Executes after the update of fields.
     * @param groupName The group name.
     */
    private void onAfterUpdateFields(String groupName) {
        if (String.isBlank(groupName)) {
            this.fObj.resetMilestoneTimer('Updated the field values of ' + this.fObj.numUpdatedRecords + ' records');
        } else {
            this.fObj.resetMilestoneTimer('Updated the field values of ' + this.fObj.numUpdatedRecords +
                ' records of group [' + groupName + ']');
        }

        deleteAllDefinitionsForUpdateOfAllFields();
        setVariablesOnAfterUpdateFields();
        new ForceeaDebugHandler(this.fObj).displaySeparatorOnMethodFinish();
    }

    /**
     * @description Executes after the update of records.
     */
    private void onAfterUpdateRecords() {
        this.fObj.handleDmlMilestone();

        this.fObj.dmlIsUpdate = false;
        this.fObj.recordsToUpdate.clear();

        new ForceeaDebugHandler(this.fObj).displaySeparatorOnMethodFinish();
    }

    /**
     * @description Executes before the insertion of records.
     * @param groupName The group name.
     */
    private void onBeforeInsertRecords(String groupName) {
        this.fObj.setGroupName(groupName);
        this.fObj.saveResults.clear();
        this.fObj.insertedRecords.clear();
        this.fObj.numInsertedRecords = 0;
        this.fObj.dmlIsInsert = true;
        ForceeaService.setStandardPriceBookId(this.fObj);
    }

    /**
     * @description Executes before the update of fields.
     */
    private void onBeforeUpdateFields() {
        ForceeaDebugHandler.displaySeparatorOnMethodStart(
            this.fObj.sObjectApiName, 'Update fields', this.fObj.templateKey);

        this.fObj.isUpdate = true;
        this.fObj.numDefinitionsWithData = 0;
        this.fObj.numUpdatedRecords = 0;
        this.fObj.numValidatedDefinitions = 0;

        this.fObj.addressesByGroup.clear();
        this.fObj.namesByGroup.clear();
    }

    /**
     * @description Executes before the update of records.
     */
    private void onBeforeUpdateRecords() {
        ForceeaDebugHandler.displaySeparatorOnMethodStart(
            this.fObj.sObjectApiName, 'Update records', this.fObj.templateKey);

        this.fObj.saveResults.clear();
        this.fObj.updatedRecords.clear();
        this.fObj.numUpdatedRecords = 0;
        this.fObj.dmlIsUpdate = true;
    }

    /**
     * @description Amend the records to update with the new field values.
     */
    private void setRecordsToUpdateWithNewFieldValues() {
        this.fObj.forceeaDebug(ForceeaService.DEBUG,
            MESSAGE_WILL_UPDATE_FIELD_VALUES + ' of [' + this.fObj.sObjectApiName + ']');

        for (Integer counter = 0; counter < this.fObj.recordsToUpdate.size(); counter++) {
            SObject recordWithUpdatedValues = this.fObj.getRecord(counter);
            if (!FObject.processIsValid) {
                break;
            }

            SObject recordToUpdate = this.fObj.recordsToUpdate.get(counter);
            Map<String, Object> populatedFieldsByName = recordWithUpdatedValues.getPopulatedFieldsAsMap();

            Integer numUpdatedFields = 0;
            for (String fieldName : populatedFieldsByName.keySet()) {
                Object fieldValue = populatedFieldsByName.get(fieldName);
                recordToUpdate.put(fieldName, fieldValue);
                numUpdatedFields++;
            }

            if (numUpdatedFields > 0) {
                this.fObj.numUpdatedRecords++;
            }
        }
    }

    /**
     * @description Sets various variables on after update.
     */
    private void setVariablesOnAfterUpdateFields() {
        this.fObj.fieldsForUpdate.clear();
        this.fObj.isUpdate = false;
    }

    /**
     * @description Updates the fields of group records.
     * @param groupName The group name.
     */
    public void updateFields(String groupName) {
        onBeforeUpdateFields();
        handleRecordsWithUpdatedValues(groupName);
        onAfterUpdateFields(groupName);
    }

    /**
     * @description Validates the field definitions when updating field values.
     */
    private void validateDefinitionsOnUpdate() {
        new ForceeaParser(this.fObj).validateDefinitions();

        if (this.fObj.numValidatedDefinitions > 0) {
            this.fObj.resetMilestoneTimer('Validated definitions');
        }
    }

}