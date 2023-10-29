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
 * @description Handles the DML deletions.
 */
public with sharing class ForceeaDeleteHandler {

    /* CONSTANTS */

    private static final String MESSAGE_WILL_DELETE_RECORDS = 'Will delete records';
    private static final String MESSAGE_WILL_NOT_DELETE_RECORDS = 'Will not delete records';

    /* INSTANCE VARIABLES & PROPERTIES */

    private final FObject fObj { get; set; }
    private String localGroupName { get; set; }
    private String sObjectApiName { get; set; }

    /* INSTANCE COLLECTIONS */

    private Set<Id> deletedRecordIds { get; set; }
    private Map<Id, SObject> insertedGlobalRecordsById { get; set; }
    private Map<Id, SObject> insertedInstanceRecordsById { get; set; }

    /* CONSTRUCTORS */

    /**
     * @description The constructor for the class.
     * @param fObj An FObject object.
     */
    public ForceeaDeleteHandler(FObject fObj) {
        this.fObj = fObj;
    }

    /* METHODS */

    /**
     * @description Deleted records when we don't have ID mocking.
     * @param whereClause The WHERE string.
     * @param allOrNone If true, the operation allows partial success.
     */
    private void deleteRecordsWithoutMockedIds(String whereClause, Boolean allOrNone) {
        if (this.fObj.sObjectApiName.equalsIgnoreCase('user')) {
            this.fObj.forceeaDebug(ForceeaService.WARN, MESSAGE_WILL_NOT_DELETE_RECORDS + ' of [User]');
            return;
        }

        this.fObj.forceeaDebug(ForceeaService.DEBUG,
            MESSAGE_WILL_DELETE_RECORDS + ' of [' + this.fObj.sObjectApiName + ']');
        this.fObj.deleteResults = getDeleteResults(whereClause, allOrNone);
        new ForceeaDomain(this.fObj).handleDmlProcessOnDelete();
    }

    private Set<Id> getDeletedRecordIds() {
        return (new Map<Id, SObject>(this.fObj.deletedRecords)).keySet();
    }

    /**
     * @description Retrieves the results of a delete operation.
     * @param whereClause The WHERE string.
     * @param allOrNone If true, the operation allows partial success.
     * @return A list of delete results.
     */
    private List<Database.DeleteResult> getDeleteResults(String whereClause, Boolean allOrNone) {
        Integer defaultQueryLimit = (this.fObj.isBigObject)
            ? FObject.DEFAULT_QUERY_LIMIT_FOR_BIG_OBJECT
            : FObject.DEFAULT_QUERY_LIMIT;
        Integer queryLimit = (this.fObj.queryLimit == null) ? defaultQueryLimit : this.fObj.queryLimit;

        this.fObj.recordsToDelete = getRecordsToDelete(whereClause, queryLimit);

        List<Database.DeleteResult> results = new List<Database.DeleteResult>();
        if (this.fObj.recordsToDelete.isEmpty()) {
            return results;
        }

        if (this.fObj.isBigObject) {
            return Database.deleteImmediate(this.fObj.recordsToDelete);
        } else {
            return Database.delete(this.fObj.recordsToDelete, allOrNone);
        }
    }

    /**
     * @description Retrieves the records to delete.
     * @param whereClause The SOQL query WHERE clause.
     * @param queryLimit The SOQL query LIMIT.
     * @return A list of SObject records to delete.
     */
    private List<SObject> getRecordsToDelete(String whereClause, Integer queryLimit) {
        return new ForceeaSelector(this.fObj)
            .setWhere(whereClause)
            .setLimit(queryLimit)
            .selectAll();
    }

    /**
     * @description Deletes records of the SObject, using specific criteria (WHERE clause).
     * @param whereClause The WHERE clause of the SOQL query (e.g. MyField__c > 10).
     * @param allOrNone If true, the operation allows partial success.
     * @return A list of Database.DeleteResult objects.
     */
    public List<Database.DeleteResult> getResults(String whereClause, Boolean allOrNone) {
        List<Database.DeleteResult> results = new List<Database.DeleteResult>();
        if (FObject.processMustTerminate() || allOrNone == null) {
            return results;
        }

        onBeforeDeleteRecords();
        deleteRecordsWithoutMockedIds(whereClause, allOrNone);
        results = new List<Database.DeleteResult>(this.fObj.deleteResults);

        onAfterDeleteRecords();
        return results;
    }

    /**
     * @description Initializes the maps for inserted global record IDs.
     * @param token The SObjectApiName or SObjectApiName.groupName in lower-case.
     */
    private void initializeMaps(String token) {
        this.insertedGlobalRecordsById = new Map<Id, SObject>(
            FObject.globalInsertedRecordsByGroup.get(token));

        this.insertedInstanceRecordsById = new Map<Id, SObject>(
            this.fObj.instanceInsertedRecordsByGroup.get(this.localGroupName));
    }

    /**
     * @description Initializes the variables for local group name and SObject API name.
     */
    private void initializeVariables() {
        this.localGroupName = '';
        this.sObjectApiName = '';
    }

    /**
     * @description Executes after the deletion of records.
     */
    private void onAfterDeleteRecords() {
        if (FObject.processMustTerminate()) {
            return;
        }

        removeRecordsFromMapsOnDelete();
        this.fObj.handleDmlMilestone();
        this.fObj.dmlIsDelete = false;
        this.fObj.recordsToDelete.clear();

        new ForceeaDebugHandler(this.fObj).displaySeparatorOnMethodFinish();
    }

    /**
     * @description Executes before the deletion of records.
     */
    private void onBeforeDeleteRecords() {
        this.fObj.deleteResults.clear();
        this.fObj.deletedRecords.clear();
        this.fObj.numDeletedRecords = 0;
        this.fObj.dmlIsDelete = true;
    }

    private void removeDeletedRecordIdsFromMaps() {
        for (Id recordId : this.deletedRecordIds) {
            this.insertedGlobalRecordsById.remove(recordId);
            this.insertedInstanceRecordsById.remove(recordId);
        }
    }

    /**
     * @description Removes the deleted records from the related maps of inserted records.
     */
    private void removeRecordsFromMapsOnDelete() {
        if (this.fObj.isBigObject) {
            return;
        }
        this.deletedRecordIds = getDeletedRecordIds();

        for (String token : FObject.globalInsertedRecordsByGroup.keySet()) {
            initializeVariables();
            setLocalAndGlobalGroup(token);
            if (stringIsNotEqualToSObjectApiName()) {
                continue;
            }

            initializeMaps(token);
            removeDeletedRecordIdsFromMaps();
            updateInsertedRecordsMap(token);
        }
    }

    /**
     * @description Populates the local and global map.
     * @param token The SObjectApiName or SObjectApiName.groupName in lower-case.
     */
    private void setLocalAndGlobalGroup(String token) {
        if (token.contains('.')) { // this is a local group
            this.sObjectApiName = token.substringBefore('.');
            this.localGroupName = token.substringAfter('.');
        } else { // this is a global group
            this.sObjectApiName = token;
        }
    }

    /**
     * @description Informs if the string is the same as the SObject API name.
     * @return True, if the string is the valid SObject API name.
     */
    private Boolean stringIsNotEqualToSObjectApiName() {
        return !this.sObjectApiName.equalsIgnoreCase(this.fObj.sObjectApiName);
    }

    /**
     * @description Update the inserted records map.
     * @param token The SObjectApiName or SObjectApiName.groupName in lower-case.
     */
    private void updateInsertedRecordsMap(String token) {
        FObject.globalInsertedRecordsByGroup.put(token, this.insertedGlobalRecordsById.values());
        this.fObj.instanceInsertedRecordsByGroup.put(this.localGroupName, this.insertedInstanceRecordsById.values());
    }

}