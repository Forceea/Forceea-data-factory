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
 * @description Provides domain functionality.
 */
public with sharing class ForceeaDomain {

    /* CONSTANTS */

    private static final String MESSAGE_WILL_INSERT_CREATED_RECORDS = 'Will insert the created records';
    private static final String MESSAGE_WILL_NOT_INSERT_RECORDS = 'Will not insert records';
    private static final String MESSAGE_WILL_STORE_CREATED_RECORDS = 'Will store the created records with mocked IDs';
    private static final String MESSAGE_WILL_UPDATE_RECORDS = 'Will update the records';

    /* STATIC VARIABLES & PROPERTIES */

    // the number of inserted records with the DML Optimizer
    private static Integer numInsertedRecordsWithOptimizer { get; set; }

    /* INSTANCE VARIABLES & PROPERTIES */

    private String dmlDescription { get; set; }
    private final FObject fObj { get; set; }
    private Integer numOfSuccessfulRecords { get; set; }
    private Integer numOfErrors { get; set; }

    /* CLASSES */

    private class FObjectFromTemplate {

        private final FObject fObj { get; set; }

        private FObjectFromTemplate(FObject fObjectFromTemplate) {
            this.fObj = fObjectFromTemplate;
        }

        /**
         * @description Informs if the FObject contains a self-lookup definition.
         * @return True, if the FObject has any definition with "lookup(<SObjectApiName>)".
         */
        private Boolean containsSelfLookupDefinition() {
            String keyToSearch = 'lookup(' + this.fObj.sObjectApiName + ')';

            for (ForceeaDefinition def : this.fObj.definitions) {
                if (def.definitionString.containsIgnoreCase(keyToSearch)) {
                    return true;
                }
            }

            return false;
        }

        /**
         * @description Informs whether the FObject contains a mock command.
         * @return True, if the ock command exists.
         */
        private Boolean hasMockCommand() {
            for (ForceeaDefinition def : this.fObj.definitions) {
                if (def.definitionString.trim().startsWithIgnoreCase('mock')) {
                    return true;
                }
            }

            return false;
        }

        /**
         * @description Informs whether the FObject has calculations for standard Pricebook entries.
         * @return True, if the FObject is related to Product2 SObject with a virtual field for standard pricebook entries.
         */
        private Boolean hasStandardPriceBookEntries() {
            return this.fObj.sObjectApiName == FObject.PRODUCT2 &&
                String.isNotBlank(this.fObj.virtualFieldForStandardPriceBookEntries);
        }

    }

    /* CONSTRUCTORS */

    /**
     * @description The constructor for the class.
     * @param fObj An FObject object.
     */
    public ForceeaDomain(FObject fObj) {
        this.fObj = fObj;
        this.numOfErrors = 0;
    }

    /* METHODS */

    /**
     * @description Adds a record in the list of records to be deleted.
     * @param recordCounter The record counter.
     */
    private void addRecordInListForDeletion(Integer recordCounter) {
        this.numOfSuccessfulRecords++;
        FObject obj = this.fObj;
        obj.deletedRecords.add(obj.recordsToDelete.get(recordCounter - 1));
    }

    /**
     * @description Adds a record in the list of records to be inserted or updated.
     * @param recordCounter The record counter.
     */
    private void addRecordInListForInsertionOrUpdate(Integer recordCounter) {
        this.numOfSuccessfulRecords++;
        FObject obj = this.fObj;

        if (obj.dmlIsInsert) {
            obj.insertedRecords.add(obj.recordsToInsert.get(recordCounter - 1));
        } else if (obj.dmlIsUpdate) {
            obj.updatedRecords.add(obj.recordsToUpdate.get(recordCounter - 1));
        }
    }

    private static void addRecordsToInsertedRecordsByGroupWithOptimizer(String sObjectApiName) {
        for (String groupName : FObject.insertedRecordsByGroupWithOptimizer.keySet()) {
            List<SObject> recordsToAdd = FObject.insertedRecordsByGroupWithOptimizer.get(groupName);

            ForceeaService.putSObjectsIntoMap(
                FObject.globalInsertedRecordsByGroup, ForceeaService.getKey(sObjectApiName, ''), recordsToAdd);

            if (String.isBlank(groupName)) {
                continue;
            }
            ForceeaService.putSObjectsIntoMap(
                FObject.globalInsertedRecordsByGroup, ForceeaService.getKey(sObjectApiName, groupName), recordsToAdd);
        }
    }

    private static void addRecordsToInsertedRecordsByTemplateKeyWithOptimizer() {
        for (String key : FObject.insertedRecordsByTemplateKeyWithOptimizer.keySet()) {
            List<SObject> recordsToAdd = FObject.insertedRecordsByTemplateKeyWithOptimizer.get(key);
            FObject fObj = FObject.fObjectsToInsertByTemplateKey.get(key);

            ForceeaService.putSObjectsIntoMap(fObj.instanceInsertedRecordsByGroup, '', recordsToAdd);

            if (String.isNotBlank(fObj.groupName)) {
                ForceeaService.putSObjectsIntoMap(
                    fObj.instanceInsertedRecordsByGroup, fObj.groupName.toLowerCase(), recordsToAdd);
            }
        }
    }

    private static void addRecordsToMapsOnInsertWithOptimizer(String sObjectApiName) {
        addRecordsToInsertedRecordsByGroupWithOptimizer(sObjectApiName);
        addRecordsToInsertedRecordsByTemplateKeyWithOptimizer();
    }

    /**
     * @description Displays an error messages on Debug Log.
     * @param error The error message.
     * @param counter The record counter.
     */
    private void displayDebugLogErrorMessage(Database.Error error, Integer counter) {
        this.fObj.forceeaDebug(ForceeaService.WARN,
            'Found errors ' + this.dmlDescription + ' record #' + counter + ': ' + error.getMessage());
    }

    /**
     * @description If is allowed, it displays any error messages on Debug Log.
     * @param errors A list of Database.Error objects.
     * @param counter The record counter.
     */
    private void displayDebugLogErrorMessages(List<Database.Error> errors, Integer counter) {
        this.numOfErrors++;
        if (this.numOfErrors > FObject.numMaxErrorRecordsToDisplay) {
            return;
        }

        for (Database.Error error : errors) {
            displayDebugLogErrorMessage(error, counter);
        }
    }

    /**
     * @description Displays a debug log warning message if errors are found.
     * @param errors The number of errors found.
     * @param size The number of records.
     * @param dmlDescription The DML errors description.
     */
    private void displayDebugLogWarningOnDmlErrors(Integer errors, Integer size, String dmlDescription) {
        if (errors == 0) {
            return;
        }

        this.fObj.forceeaDebug(ForceeaService.WARN,
            'Found ' + ForceeaService.getCountable('error', errors) + ' ' + dmlDescription + ' ' +
            ForceeaService.getCountable('record', size) + ' of [' + this.fObj.sObjectApiName + ']');
    }

    /**
     * @description Retrieves the results of an insert operation.
     * @param allOrNone If true, the operation allows partial success.
     * @return A list of save results.
     */
    private List<Database.SaveResult> getInsertResults(Boolean allOrNone) {
        FObject obj = this.fObj;

        if (obj.isBigObject) {
            return Database.insertImmediate(obj.recordsToInsert);
        } else {
            return Database.insert(obj.recordsToInsert, allOrNone);
        }
    }

    /**
     * @description Retrieves a map with key: SObject record ID, value: group name of the FObject related to this group.
     * @return The map recordsToInsertByGroupWithOptimizer.
     */
    private static Map<Id, String> getMapGroupsByRecordId() {
        Map<Id, String> results = new Map<Id, String>();

        for (String groupName : FObject.recordsToInsertByGroupWithOptimizer.keySet()) {
            for (SObject record : FObject.recordsToInsertByGroupWithOptimizer.get(groupName)) {
                results.put(record.Id, groupName);
            }
        }

        return results;
    }

    /**
     * @description Generates a map for the template keys by record ID.
     * @return A map with key: record ID, value: template key.
     */
    private static Map<Id, String> getMapTemplateKeysByRecordId() {
        Map<Id, String> results = new Map<Id, String>();

        for (String key : FObject.recordsToInsertByTemplateKeyWithOptimizer.keySet()) {
            for (SObject record : FObject.recordsToInsertByTemplateKeyWithOptimizer.get(key)) {
                results.put(record.Id, key);
            }
        }

        return results;
    }

    /**
     * @description Retrieves a map with key: SObject API name, value: list of FObjects of this SObject.
     * @param template The Template map.
     * @return A map of FObjects by SObject.
     */
    private static Map<String, List<FObject>> getMapWithFObjectsToInsertBySObjectKey(Map<String, FObject> template) {
        Map<String, List<FObject>> results = new Map<String, List<FObject>>();
        Set<String> keys = template.keySet();
        Map<String, Integer> countersBySObjectName = new Map<String, Integer>();

        for (String key : keys) {
            FObject fObjFromTemplate = template.get(key);
            fObjFromTemplate.templateKey = key;

            String sObjectApiName = fObjFromTemplate.sObjectApiName;
            if (!results.containsKey(sObjectApiName)) {
                countersBySObjectName.put(sObjectApiName, 0);
            }

            FObjectFromTemplate obj = new FObjectFromTemplate(fObjFromTemplate);
            if (obj.containsSelfLookupDefinition() || obj.hasMockCommand() || obj.hasStandardPriceBookEntries()) {
                Integer counter = countersBySObjectName.get(sObjectApiName) + 1;
                countersBySObjectName.put(sObjectApiName, counter);
                results.put(sObjectApiName + '.' + String.valueOf(counter), new List<FObject>{
                    fObjFromTemplate
                });
            } else {
                List<FObject> fObjects =
                    results.containsKey(sObjectApiName) ? results.get(sObjectApiName) : new List<FObject>();
                fObjects.add(fObjFromTemplate);
                results.put(sObjectApiName, fObjects);
            }
        }

        return results;
    }

    /**
     * @description Handles the errors displayed after a delete DML operation.
     */
    public void handleDmlProcessOnDelete() {
        setVariablesOnDmlHandling();

        Integer counter = 0;
        for (Database.DeleteResult dmlResult : this.fObj.deleteResults) {
            counter++;
            handleRecordOnDelete(dmlResult, counter);
        }

        this.fObj.numDeletedRecords = this.numOfSuccessfulRecords;
        new ForceeaDebugHandler(this.fObj)
            .displayDebugLogWarningOnDmlErrors(this.numOfErrors, this.fObj.deleteResults.size(), this.dmlDescription);
    }

    /**
     * @description Handles the errors displayed after an insert/update DML operation.
     */
    private void handleDmlProcessOnInsertUpdate() {
        setVariablesOnDmlHandling();
        FObject obj = this.fObj;
        Integer counter = 0;

        for (Database.SaveResult dmlResult : obj.saveResults) {
            counter++;
            handleRecordOnInsertUpdate(dmlResult, counter);
        }

        if (obj.dmlIsInsert) {
            obj.numInsertedRecords = this.numOfSuccessfulRecords;
        } else if (obj.dmlIsUpdate) {
            obj.numUpdatedRecords = this.numOfSuccessfulRecords;
        }

        new ForceeaDebugHandler(this.fObj)
            .displayDebugLogWarningOnDmlErrors(this.numOfErrors, obj.deleteResults.size(), this.dmlDescription);
    }

    /**
     * @description Handles the errors displayed after inserting records with DML Optimizer.
     * @param sObjectApiName The SObject API name.
     */
    private static void handleErrorsOnDmlWithOptimizer(String sObjectApiName) {
        Integer errors = 0;
        Integer counter = 0;
        Integer numSuccessfulRecords = 0;
        Map<Id, String> groupsByRecordId = getMapGroupsByRecordId();
        Map<Id, String> templateKeysByRecordId = getMapTemplateKeysByRecordId();

        for (Database.SaveResult sr : FObject.saveResultsWithOptimizer) {
            counter++;
            String templateKey = templateKeysByRecordId.get(sr.getId());
            ForceeaService.putSaveResultIntoMap(FObject.saveResultsByTemplateKeyWithOptimizer, templateKey, sr);

            if (sr.isSuccess()) {
                numSuccessfulRecords++;
                SObject insertedSObj = FObject.recordsToInsertWithOptimizer.get(counter - 1);

                String groupName = groupsByRecordId.get(sr.getId());
                ForceeaService.putSObjectIntoMap(FObject.insertedRecordsByGroupWithOptimizer, groupName, insertedSObj);
                ForceeaService.putSObjectIntoMap(FObject.insertedRecordsByTemplateKeyWithOptimizer, templateKey, insertedSObj);
            } else {
                errors++;
                if (errors <= FObject.numMaxErrorRecordsToDisplay) {
                    for (Database.Error err : sr.getErrors()) {
                        FObject.forceeaDebugStatic(ForceeaService.ERROR,
                            'Found errors inserting record #' + counter + ': ' + err.getMessage());
                    }
                }
            }
        }

        numInsertedRecordsWithOptimizer = numSuccessfulRecords;

        if (errors > 0) {
            FObject.forceeaDebugStatic(ForceeaService.WARN,
                'Found ' + ForceeaService.getCountable('error', errors) + ' inserting ' +
                ForceeaService.getCountable('record', FObject.saveResultsWithOptimizer.size()) +
                ' of [' + sObjectApiName + ']');
        }
    }

    /**
     * @description Handles the successful or failed DML result of a record.
     * @param result A Database.DeleteResult object.
     * @param counter The record counter.
     */
    private void handleRecordOnDelete(Database.DeleteResult result, Integer counter) {
        if (result.isSuccess()) {
            addRecordInListForDeletion(counter);
        } else {
            displayDebugLogErrorMessages(result.getErrors(), counter);
        }
    }

    /**
     * @description Handles the successful or failed DML result of a record.
     * @param result A Database.SaveResult object.
     * @param counter The record counter.
     */
    private void handleRecordOnInsertUpdate(Database.SaveResult result, Integer counter) {
        if (result.isSuccess()) {
            addRecordInListForInsertionOrUpdate(counter);
        } else {
            displayDebugLogErrorMessages(result.getErrors(), counter);
        }
    }

    /**
     * @description Handles the update of records.
     * @param allOrNone If true, the operation allows partial success.
     */
    public void handleRecordsOnUpdate(Boolean allOrNone) {
        List<SObject> validRecordsToUpdate = new List<SObject>();
        FObject obj = this.fObj;

        for (SObject record : obj.recordsToUpdate) {
            if (idIsValid(record.Id)) {
                validRecordsToUpdate.add(record);
            }
        }

        obj.forceeaDebug(ForceeaService.DEBUG, MESSAGE_WILL_UPDATE_RECORDS + ' of [' + obj.sObjectApiName + ']');
        obj.saveResults = Database.update(validRecordsToUpdate, allOrNone);
        handleDmlProcessOnInsertUpdate();
    }

    /**
     * @description Informs whether the ID value is valid (not blank or mocked).
     * @param idValue A string of the ID value.
     * @return True, if the ID is valid.
     */
    private Boolean idIsValid(String idValue) {
        return String.isNotBlank(idValue) && idValue.mid(3, 6) != '0'.repeat(6);
    }

    /**
     * @description Inserts the records of the FObjects, which are related to the same SObject.
     * @param fObjectsToInsert Specifies whether the operation allows partial success. If you specify false
     * @return A map with key: template key, value: a list of SaveResult.
     */
    private static Map<String, List<Database.SaveResult>> insertRecordsFromListWithOptimizer(
        List<FObject> fObjectsToInsert) {
        onBeforeInsertRecordsFromListWithOptimizer();

        for (FObject fObj : fObjectsToInsert) {
            if (fObj.numNextRecord != null) {
                fObj.setNumberOfNextRecord(fObj.numNextRecord);
            }
            fObj.mustCreateNewRecords = true;
            fObj.createNewRecords();
            FObject.fObjectsToInsertByTemplateKey.put(fObj.templateKey, fObj);
        }

        String sObjectApiName = fObjectsToInsert.get(0).sObjectApiName;
        insertRecordsWithoutMockedIdsWithOptimizer(sObjectApiName);
        onAfterInsertRecordsFromListWithOptimizer(sObjectApiName);

        return FObject.saveResultsByTemplateKeyWithOptimizer;
    }

    /**
     * @description Inserts the FObject records of a Template for all FObjects with DML Optimizer.
     * @param template The Template map.
     * @return A map with key: template key, value: a list of SaveResult.
     */
    public static Map<String, List<Database.SaveResult>> insertRecordsFromTemplateWithOptimizer(
        Map<String, FObject> template) {
        Map<String, List<FObject>> fObjectsBySObjectKey = getMapWithFObjectsToInsertBySObjectKey(template);
        Map<String, List<Database.SaveResult>> results = new Map<String, List<Database.SaveResult>>();

        for (String key : fObjectsBySObjectKey.keySet()) {
            List<FObject> fObjectsToInsert = fObjectsBySObjectKey.get(key);

            FObject fObj = fObjectsToInsert.get(0);
            if (fObjectsToInsert.size() == 1) {
                FObject.shouldOptimizeDml = false;
                results.put(fObj.templateKey, fObj.insertRecords(FObject.allOrNone, fObj.groupName));
                FObject.shouldOptimizeDml = true;
                continue;
            }

            Map<String, List<Database.SaveResult>> saveResultsByTemplateKey =
                insertRecordsFromListWithOptimizer(fObjectsToInsert);
            for (String templateKey : saveResultsByTemplateKey.keySet()) {
                results.put(templateKey, saveResultsByTemplateKey.get(templateKey));
            }
        }

        return results;
    }

    /**
     * @description Inserts the FObject records of a Template for all FObjects without DML Optimizer.
     * @param template The Template map.
     * @return A map with key: template key, value: a list of SaveResult.
     */
    public static Map<String, List<Database.SaveResult>> insertRecordsFromTemplateWithoutOptimizer(
        Map<String, FObject> template) {
        Map<String, List<Database.SaveResult>> results = new Map<String, List<Database.SaveResult>>();

        for (String key : template.keySet()) {
            FObject fObjFromTemplate = template.get(key);
            if (fObjFromTemplate.numNextRecord != null) {
                fObjFromTemplate.setNumberOfNextRecord(fObjFromTemplate.numNextRecord);
            }
            results.put(key, fObjFromTemplate.insertRecords(FObject.allOrNone, fObjFromTemplate.groupName));
        }

        return results;
    }

    /**
     * @description Stores the created records when we have ID mocking.
     */
    public void insertRecordsWithMockedIds() {
        FObject obj = this.fObj;
        obj.forceeaDebug(ForceeaService.DEBUG, MESSAGE_WILL_STORE_CREATED_RECORDS + ' of [' + obj.sObjectApiName + ']');

        for (Integer counter = 0; counter < obj.recordsToInsert.size(); counter++) {
            obj.insertedRecords.add(obj.recordsToInsert[counter]);
        }
    }

    /**
     * @description Inserts the created records when we don't have ID mocking.
     * @param allOrNone If true, the operation allows partial success.
     */
    public void insertRecordsWithoutMockedIds(Boolean allOrNone) {
        FObject obj = this.fObj;

        if (shouldNotInsertUsers(obj)) {
            obj.forceeaDebug(ForceeaService.WARN, MESSAGE_WILL_NOT_INSERT_RECORDS + ' of [User]');
            return;
        }

        obj.forceeaDebug(ForceeaService.DEBUG,
            MESSAGE_WILL_INSERT_CREATED_RECORDS + ' of [' + obj.sObjectApiName + ']');
        obj.saveResults = getInsertResults(allOrNone);
        handleDmlProcessOnInsertUpdate();
    }

    private static void insertRecordsWithoutMockedIdsWithOptimizer(String sObjectApiName) {
        FObject.forceeaDebugStatic(ForceeaService.DEBUG,
            MESSAGE_WILL_INSERT_CREATED_RECORDS + ' of [' + sObjectApiName + ']');

        FObject.saveResultsWithOptimizer = Database.insert(FObject.recordsToInsertWithOptimizer, FObject.allOrNone);
        handleErrorsOnDmlWithOptimizer(sObjectApiName);

        String text = 'Inserted ' + ForceeaService.getCountable('record', numInsertedRecordsWithOptimizer) +
            ' of [' + sObjectApiName + ']';
        FObject.forceeaDebugStatic(ForceeaService.INFO, FObject.SYMBOL_MILESTONE + ' ' + text +
            '. Transaction duration: ' + Limits.getCpuTime() + 'ms.');
    }

    private static void onAfterInsertRecordsFromListWithOptimizer(String sObjectApiName) {
        addRecordsToMapsOnInsertWithOptimizer(sObjectApiName);
    }

    private static void onBeforeInsertRecordsFromListWithOptimizer() {
        FObject.shouldOptimizeDml = true;

        FObject.recordsToInsertWithOptimizer.clear();
        FObject.recordsToInsertByGroupWithOptimizer.clear();
        FObject.recordsToInsertByTemplateKeyWithOptimizer.clear();

        FObject.insertedRecordsByGroupWithOptimizer.clear();
        FObject.insertedRecordsByTemplateKeyWithOptimizer.clear();

        FObject.saveResultsByTemplateKeyWithOptimizer.clear();
        FObject.saveResultsWithOptimizer.clear();
        FObject.fObjectsToInsertByTemplateKey.clear();
    }

    /**
     * @description Sets the variables used when we insert, update or delete records.
     */
    private void setVariablesOnDmlHandling() {
        this.numOfErrors = 0;
        this.numOfSuccessfulRecords = 0;
        this.dmlDescription = ForceeaService.getDmlDescription(this.fObj, 'ing', 'lowercase');
    }

    /**
     * @description Decides if User records should be created or not.
     * @param obj An FObject object.
     * @return True, if Forceea should not create records of the User SObject.
     */
    private Boolean shouldNotInsertUsers(FObject obj) {
        return obj.sObjectApiName.equalsIgnoreCase('user') && !Test.isRunningTest() && !obj.canInsertUsers;
    }

}