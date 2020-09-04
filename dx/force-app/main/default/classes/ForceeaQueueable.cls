/*
  Forceea data factory (v2.2.0)
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
public with sharing class ForceeaQueueable implements Queueable {

    /* CONSTANTS */

    private static final List<String> ERROR_CODES_TO_RETRY = new List<String>{
        'UNABLE_TO_LOCK_ROW'
    };
    @TestVisible
    private static final Decimal LIMITS_THRESHOLD = 0.95;
    @TestVisible
    private static final Integer LIMIT_ON_BENCHMARK = 200;
    private static final Integer NUMBER_OF_SECTORS = 50;
    private static final Integer MAX_ERRORS = 5;

    /* INSTANCE COLLECTIONS */

    private List<ForceeaService.FieldDefinition> definitionsOnDelete { get; set; }
    private Map<String, Integer> numFirstRecordsBySObject { get; set; }
    private Map<String, Integer> tempNumFirstRecordsBySObject { get; set; }
    private Map<String, Integer> sObjectApiNames { get; set; }
    private List<ForceeaService.FObjectAsync> sObjectsToDelete { get; set; }
    private Map<String, ForceeaService.FObjectAsync> template { get; set; }

    /* INSTANCE VARIABLES & PROPERTIES */

    @TestVisible
    private Integer batchId { get; set; }
    @TestVisible
    private String errorMessage { get; set; }
    private Boolean hasFailed { get; set; }
    private Boolean hasMoreRecordsToDelete { get; set; }
    private Boolean hasPartitioning { get; set; }
    private Boolean isBenchmark { get; set; }
    @TestVisible
    private Boolean isTerminated { get; set; }
    private Boolean isTheLastSObject { get; set; }
    @TestVisible
    private Integer jobId { get; set; }
    private Boolean jobIsCompleted { get; set; }
    private String language { get; set; }
    private String locality { get; set; }
    private Integer limitDataGenerationCpuTime { get; set; }
    @TestVisible
    private Integer limitDmlRows { get; set; }
    private Integer limitFObjectSetupCpuTime { get; set; }
    @TestVisible
    private Integer limitGlobalSetupCpuTime { get; set; }
    @TestVisible
    private Integer numBatchUnitsExecuted { get; set; }
    private Integer numBatchUnitsToExecute { get; set; }
    @TestVisible
    private Integer numErrors { get; set; }
    private Integer numJobs { get; set; }
    private Integer numJobUnitsExecuted { get; set; }
    private Integer numJobUnitsToExecute { get; set; }
    @TestVisible
    private Integer numMaxUnitsPerBatch { get; set; }
    private Integer numProcessUnitsToExecute { get; set; }
    private Integer numRecordsFoundForDeletion { get; set; }
    private Integer numTotalJobUnits { get; set; }
    private Boolean operationIsSuccessful { get; set; }
    @TestVisible
    private ForceeaService.OperationType operationType { get; set; }
    private String partitionFieldValue { get; set; }
    private String processId { get; set; }
    private Integer queryLimit { get; set; }
    private Savepoint savePoint;
    private Integer sector { get; set; }
    private Long seed { get; set; }
    private Boolean shouldCheckNextSector { get; set; }
    private Boolean shouldCheckSameSector { get; set; }
    private Boolean shouldCreateNewBatch { get; set; }
    private Boolean shouldMoveToNextSObject { get; set; }
    private Boolean shouldTryAgainAfterError { get; set; }
    @TestVisible
    private String sObjectApiName { get; set; }
    private Integer sObjectToDeleteIndex { get; set; }

    /* CONSTRUCTOR */

    public ForceeaQueueable(ForceeaService.AsyncTransaction asyncTransaction) {
        this.batchId = asyncTransaction.batchId;
        this.errorMessage = '';
        this.numFirstRecordsBySObject = asyncTransaction.numFirstRecordsBySObject;
        this.hasFailed = false;
        this.hasMoreRecordsToDelete = false;
        this.hasPartitioning = asyncTransaction.hasPartitioning;
        this.isBenchmark = asyncTransaction.isBenchmark;
        this.isTerminated = false;
        this.isTheLastSObject = false;
        this.jobId = asyncTransaction.jobId;
        this.jobIsCompleted = false;
        this.language = asyncTransaction.language;
        this.limitDataGenerationCpuTime = 0;
        this.limitDmlRows = 0;
        this.limitFObjectSetupCpuTime = 0;
        this.limitGlobalSetupCpuTime = 0;
        this.locality = asyncTransaction.locality;
        this.numBatchUnitsExecuted = 0;
        this.numBatchUnitsToExecute = 0;
        this.numErrors = asyncTransaction.numErrors;
        this.numJobs = asyncTransaction.numJobs;
        this.numJobUnitsExecuted = asyncTransaction.numJobUnitsExecuted;
        this.numJobUnitsToExecute = asyncTransaction.numJobUnitsToExecute;
        this.numMaxUnitsPerBatch = asyncTransaction.numMaxUnitsPerBatch;
        this.numProcessUnitsToExecute = asyncTransaction.numProcessUnitsToExecute;
        this.numRecordsFoundForDeletion = 0;
        this.numTotalJobUnits = asyncTransaction.numTotalJobUnits;
        this.operationIsSuccessful = true;
        this.operationType = asyncTransaction.operationType;
        if (this.operationType == ForceeaService.OperationType.ASYNC_DELETE) {
            this.definitionsOnDelete =
                asyncTransaction.sObjectsToDelete.get(asyncTransaction.sObjectToDeleteIndex).definitions;
            //System.debug('asyncTransaction.sObjectToDeleteIndex: ' + asyncTransaction.sObjectToDeleteIndex);
            //System.debug('asyncTransaction.sObjectsToDelete: ' + asyncTransaction.sObjectsToDelete);
            //System.debug('definitionsOnDelete: ' + this.definitionsOnDelete);
        }
        this.partitionFieldValue = asyncTransaction.partitionFieldValue;
        this.processId = asyncTransaction.processId;
        this.queryLimit = LIMIT_ON_BENCHMARK;
        this.sector = asyncTransaction.sector;
        this.seed = asyncTransaction.seed;
        this.shouldCheckNextSector = false;
        this.shouldCheckSameSector = false;
        this.shouldCreateNewBatch = false;
        this.shouldMoveToNextSObject = false;
        this.shouldTryAgainAfterError = false;
        this.sObjectApiName = asyncTransaction.sObjectApiName;
        this.sObjectApiNames = new Map<String, Integer>();
        this.sObjectToDeleteIndex = asyncTransaction.sObjectToDeleteIndex;
        this.sObjectsToDelete = asyncTransaction.sObjectsToDelete;
        this.template = asyncTransaction.template;
    }

    /* METHODS */

    /**
     * @description Creates a new batch.
     */
    private void createNewBatch() {
        //System.debug('> createNewBatch');

        try {
            this.batchId++;
            ForceeaService.AsyncTransaction asyncTrans = this.getAsyncTransaction();
            if (Test.isRunningTest()) {
                return;
            }
            ForceeaService.enqueueJob(asyncTrans);
        } catch (Exception ex) {
            this.operationIsSuccessful = false;
            this.errorMessage = ex.getMessage();
            publishLogMessageOnFailure();
        }
    }

    /**
     * @description Deactivates benchmarking.
     */
    private void deactivateBenchmarking() {
        if (this.isBenchmark) {
            this.isBenchmark = false;
        }
    }

    /**
     * @description Decides if the next sector should be checked when deleting.
     */
    private void decideIfShouldCheckNextSectorOnDelete() {
        Integer nextSector = this.sector + this.numJobs;
        this.shouldCheckNextSector = shouldContinueToNextSectorOnDelete(nextSector);
        //System.debug('shouldCheckNextSector: ' + this.shouldCheckNextSector);
    }

    /**
     * @description Decides if the same sector should be checked when deleting.
     */
    private void decideIfShouldCheckSameSectorOnDelete() {
        Boolean shouldTryAgain = !this.operationIsSuccessful && this.shouldTryAgainAfterError;
        this.hasMoreRecordsToDelete = this.numRecordsFoundForDeletion == this.queryLimit;
        this.shouldCheckSameSector = (shouldTryAgain || this.hasMoreRecordsToDelete) ? true : false;
        //System.debug('hasMoreRecordsToDelete: ' + this.hasMoreRecordsToDelete);
        //System.debug('shouldCheckSameSector: ' + this.shouldCheckSameSector);
    }

    /**
     * @description Decides if a new batch should be created when deleting.
     */
    private void decideIfShouldCreateNewBatchOnDelete() {
        this.shouldCreateNewBatch = false;
        //System.debug('hasMoreRecordsToDelete: ' + this.hasMoreRecordsToDelete);

        Boolean conditionOnSuccess = this.operationIsSuccessful && (
            (this.shouldMoveToNextSObject && !this.isTheLastSObject) ||
                this.shouldCheckSameSector ||
                (this.shouldCheckNextSector && this.numRecordsFoundForDeletion > 0)
        );
        Boolean conditionOnFailure = !this.operationIsSuccessful && this.shouldTryAgainAfterError;
        if (conditionOnSuccess || conditionOnFailure) {
            this.shouldCreateNewBatch = true;
        }
        //System.debug('shouldCreateNewBatch: ' + this.shouldCreateNewBatch);

        if (this.isBenchmark) {
            setNumOfMaxUnitsOnBenchmark();
        }
        if (this.operationIsSuccessful && this.numRecordsFoundForDeletion > 0) { // benchmarking has finished
            deactivateBenchmarking();
        }
    }

    /**
     * @description Decides if this is the last SObject when deleting.
     */
    private void decideIfThisIsTheLastSObjectOnDelete() {
        this.isTheLastSObject = this.sObjectToDeleteIndex == this.sObjectsToDelete.size() - 1;
        //System.debug('thisIsTheLastSObject: ' + isTheLastSObject);
        //System.debug('sObjectToDeleteIndex: ' + this.sObjectToDeleteIndex);
    }

    /**
     * @description Decides what happens as a next step when deleting.
     */
    private void decideWhatHappensNextOnDelete() {
        //System.debug('> decideWhatHappensNext');
        if (this.shouldCreateNewBatch) {
            publishLogMessageOnSuccess();

            if (this.shouldMoveToNextSObject && !this.isTheLastSObject) {
                //System.debug('will go to next SObject');
                this.isBenchmark = true;
                this.sector = this.jobId;
                this.sObjectToDeleteIndex++;
            }
            //System.debug('numMaxUnitsPerBatch: ' + this.numMaxUnitsPerBatch);

            createNewBatch();
            return;
        }

        if (this.shouldMoveToNextSObject && this.isTheLastSObject) { // job is completed
            publishLogMessageOnSuccess();
            this.jobIsCompleted = true;
            publishLogMessageOnSuccess();
            //System.debug('jobIsCompleted: ' + this.jobIsCompleted);
        }
    }

    /**
     * @description Decides for the next batch when deleting.
     */
    private void decideForNextBatchOnDelete() {
        decideIfShouldCheckSameSectorOnDelete();
        decideIfShouldCheckNextSectorOnDelete();
        decideIfThisIsTheLastSObjectOnDelete();
        decideIfShouldCreateNewBatchOnDelete();
        decideWhatHappensNextOnDelete();
    }

    /**
     * @description Decides for the next batch when inserting.
     */
    private void decideForNextBatchOnInsert() {
        Boolean hasMoreIterationsToInsert = this.operationIsSuccessful
            && this.operationType == ForceeaService.OperationType.ASYNC_INSERT
            && this.numJobUnitsToExecute > 0;
        //System.debug('shouldTryAgainAfterError: ' + this.shouldTryAgainAfterError);
        //System.debug('hasMoreIterationsToInsert: ' + hasMoreIterationsToInsert);

        Boolean conditionOnSuccess = this.operationIsSuccessful &&
            (this.shouldCheckNextSector || hasMoreIterationsToInsert);
        Boolean conditionOnFailure = !this.operationIsSuccessful && this.shouldTryAgainAfterError;

        if (conditionOnSuccess || conditionOnFailure) {
            setNumOfMaxUnitsOnBenchmark();
            deactivateBenchmarking();
            createNewBatch();
        } else {
            this.jobIsCompleted = true;
            if (this.operationIsSuccessful) {
                publishLogMessageOnSuccess();
                //System.debug('jobIsCompleted: ' + this.jobIsCompleted);
            }
        }
    }

    /**
     * @description Deletes records.
     * @param recordsToDelete The list of records to delete.
     */
    private void deleteRecords(List<SObject> recordsToDelete) {
        try {
            Database.delete(recordsToDelete, true);
        } catch (Exception ex) {
            this.operationIsSuccessful = false;
            this.errorMessage = ex.getMessage();
            publishLogMessageOnFailure();
            return;
        }

        this.numBatchUnitsExecuted = recordsToDelete.size();
        this.numJobUnitsExecuted += this.numBatchUnitsExecuted;
        this.numBatchUnitsToExecute = this.numBatchUnitsExecuted;
        //System.debug('> deleted ' + this.numBatchUnitsExecuted + ' records for ' + this.sObjectApiName);
    }

    /**
     * @description The main execution method.
     * @param context The queueable context.
     */
    public void execute(QueueableContext context) {
        //System.debug('=== ForceeaQueueable.execute, job:' + this.jobId + ', batch: ' + this.batchId);

        handleOnTerminated();
        if (this.isTerminated) {
            return;
        }

        switch on this.operationType {
            when ASYNC_INSERT {
                handleOnInsert();
            }
            when ASYNC_DELETE {
                handleOnDelete();
            }
        }
    }

    /**
     * @description Creates an async transaction.
     * @return An instance of ForceeaService.AsyncTransaction.
     */
    private ForceeaService.AsyncTransaction getAsyncTransaction() {
        ForceeaService.AsyncTransaction result = new ForceeaService.AsyncTransaction();

        result.batchId = this.batchId;
        result.isBenchmark = this.isBenchmark;
        result.hasPartitioning = this.hasPartitioning;
        result.jobId = this.jobId;
        result.language = this.language;
        result.locality = this.locality;
        result.numFirstRecordsBySObject = this.numFirstRecordsBySObject;
        result.numJobs = this.numJobs;
        result.numJobUnitsExecuted = this.numJobUnitsExecuted;
        result.numJobUnitsToExecute = this.numJobUnitsToExecute;
        result.numMaxUnitsPerBatch = this.numMaxUnitsPerBatch;
        result.numProcessUnitsToExecute = this.numProcessUnitsToExecute;
        result.numTotalJobUnits = this.numTotalJobUnits;
        result.operationType = this.operationType;
        result.partitionFieldValue = this.partitionFieldValue;
        result.processId = this.processId;
        result.sector = this.sector;
        result.seed = this.seed;
        result.sObjectApiName = this.sObjectApiName;
        result.sObjectToDeleteIndex = this.sObjectToDeleteIndex;
        result.sObjectsToDelete = this.sObjectsToDelete;
        result.template = this.template;

        return result;
    }

    /**
     * @description Retrieves the global limits.
     */
    private void getLimitsOnBenchmark() {
        if (!this.isBenchmark) {
            return;
        }

        this.limitGlobalSetupCpuTime = FObject.getCpuTimeOfGlobalSetup();
        this.limitDmlRows = Limits.getDmlRows();
        //System.debug('limit GlobalSetupCpuTime: ' + this.limitGlobalSetupCpuTime);
        //System.debug('limit FObjectSetupCpuTime: ' + this.limitFObjectSetupCpuTime);
        //System.debug('limit DataGenerationCpuTime: ' + this.limitDataGenerationCpuTime);
        //System.debug('limit DmlRows: ' + this.limitDmlRows);
    }

    /**
     * @description Creates a Log message.
     * @return The log message.
     */
    @TestVisible
    private String getLogMessage() {
        String result = '';

        if (this.isTerminated) {
            String message = 'Job[' + this.jobId + '] is terminated.';
            return ForceeaService.getHtmlMessageHeader(
                ForceeaService.asyncMessageType.MESSAGE_TYPE_WARN) + message + '<br/>';
        }

        if (this.operationIsSuccessful) {
            result = getLogMessageOnSuccess();
        } else {
            result = getLogMessageOnFailure();
        }

        return result + '<br/>';
    }

    /**
     * @description Creates a Log message on failure.
     * @return The log message.
     */
    @TestVisible
    private String getLogMessageOnFailure() {
        String message = 'Job[' + this.jobId + '] Batch[' + this.batchId + '] found errors ';
        switch on this.operationType {
            when ASYNC_INSERT {
                message += 'inserting records of [' + this.sObjectApiName + ']: ' + this.errorMessage;
            }
            when ASYNC_DELETE {
                message += 'deleting records of [' + this.sObjectApiName + ']: ' + this.errorMessage;
            }
        }
        this.numErrors++;

        return ForceeaService.getHtmlMessageHeader(ForceeaService.asyncMessageType.MESSAGE_TYPE_ERROR) + message;
    }

    /**
     * @description Creates a Log message on success.
     * @return The log message on successful operation.
     */
    private String getLogMessageOnSuccess() {
        String message = 'Job[' + this.jobId + '] Batch[' + this.batchId + ']';
        ForceeaService.asyncMessageType messageType = ForceeaService.asyncMessageType.MESSAGE_TYPE_INFO;

        switch on this.operationType {
            when ASYNC_INSERT {
                if (this.isBenchmark) {
                    message += ' optimized performance.';
                } else {
                    message += ' inserted ' + this.numBatchUnitsToExecute + ' ';
                    message += ForceeaService.getPlural('iteration', this.numBatchUnitsToExecute) + '.';
                }
            }
            when ASYNC_DELETE {
                message += ' deleted ' + this.numBatchUnitsToExecute + ' ';
                message += ForceeaService.getPlural('record', this.numBatchUnitsToExecute) +
                    ' of [' + this.sObjectApiName + '].';
            }
        }

        if (this.jobIsCompleted) {
            message = 'Job[' + jobId + '] is completed.';
            messageType = ForceeaService.asyncMessageType.MESSAGE_TYPE_SUCCESS;
        }

        return ForceeaService.getHtmlMessageHeader(messageType) + message;
    }

    /**
     * @description Retrieves the max CPU time.
     * @return The max CPU time.
     */
    @TestVisible
    private Integer getMaxCpuTime() {
        Decimal dec = LIMITS_THRESHOLD * Limits.getLimitCpuTime();
        return (Integer) dec;
    }

    /**
     * @description Retrieves the max number of iterations per batch.
     * @return The max number of iterations per batch.
     */
    private Integer getMaxNumOfIterationsPerBatch() {
        if (this.numMaxUnitsPerBatch > 0) {
            return this.numMaxUnitsPerBatch;
        }

        Integer allowedCpuTime = getMaxCpuTime() - this.limitGlobalSetupCpuTime - this.limitFObjectSetupCpuTime;
        //System.debug('allowedCpuTime: ' + allowedCpuTime);
        //System.debug('limitDataGenerationCpuTime: ' + this.limitDataGenerationCpuTime);
        //System.debug('getDmlRows: ' + Limits.getDmlRows());

        Integer maxIterationsForCpuTime = 1;
        if (this.limitDataGenerationCpuTime > 0) {
            maxIterationsForCpuTime = (Integer) allowedCpuTime / this.limitDataGenerationCpuTime;
        }
        //System.debug('maxIterationsForCpuTime: ' + maxIterationsForCpuTime);

        Integer maxIterationsForDmlRows = 1;
        if (Limits.getDmlRows() > 0) {
            maxIterationsForDmlRows = (Integer) Limits.getLimitDmlRows() / Limits.getDmlRows();
        }
        //System.debug('maxIterationsForDmlRows: ' + maxIterationsForDmlRows);

        List<Integer> maxIterations = new List<Integer>{
            maxIterationsForCpuTime,
            maxIterationsForDmlRows
        };
        maxIterations.sort();

        //System.debug('maxIterations: ' + maxIterations);
        //System.debug('MaxNumOfIterationsPerBatch: ' + maxIterations.get(0));
        return maxIterations.get(0);
    }

    /**
     * @description Calculates the max number of records than can be deleted per batch.
     * @return The max number of records.
     */
    @TestVisible
    private Integer getMaxNumOfRecordsToDeletePerBatch() {
        if (this.numMaxUnitsPerBatch > 1) {
            return this.numMaxUnitsPerBatch;
        }

        return ForceeaQueueable.getMaxRecordsToDeletePerBatch(this);
    }

    /**
     * @description Calculates the max number of records than can be deleted per batch.
     * @param queueable A ForceeaQueueable instance.
     * @return The max number of records.
     */
    @TestVisible
    private static Integer getMaxRecordsToDeletePerBatch(ForceeaQueueable queueable) {
        Decimal multiplierForCpuTime = 1;
        if (queueable.limitGlobalSetupCpuTime > 0) {
            multiplierForCpuTime = (Integer) queueable.getMaxCpuTime() / queueable.limitGlobalSetupCpuTime;
        }

        Decimal multiplierForDmlRows = 1;
        if (queueable.limitDmlRows > 0) {
            multiplierForDmlRows = (Integer) Limits.getLimitDmlRows() / queueable.limitDmlRows;
        }

        List<Decimal> multipliers = new List<Decimal>{
            multiplierForCpuTime,
            multiplierForDmlRows
        };
        multipliers.sort();
        //System.debug('multiplier: ' + multipliers.get(0));

        Integer result = Integer.valueOf(
            multipliers.get(0) * queueable.numBatchUnitsExecuted * ForceeaQueueable.LIMITS_THRESHOLD);

        return (result > Limits.getLimitDmlRows()) ? Limits.getLimitDmlRows() : result;
    }

    /**
     * @description Returns a new FObject from an instance of ForceeaService.FObjectAsync.
     * @param async An instance of ForceeaService.FObjectAsync.
     * @return An FObject instance.
     */
    private FObject getNewFObject(ForceeaService.FObjectAsync async) {
        Integer numRecords = async.numOfRecords * this.numBatchUnitsToExecute;
        //System.debug('getNewFObject - async.numRecords: ' + async.numOfRecords);
        //System.debug('getNewFObject - this.numBatchUnitsToExecute: ' + this.numBatchUnitsToExecute);
        //System.debug('getNewFObject - numRecords: ' + numRecords);

        FObject newFObject = new FObject(async.sObjectApiName, numRecords)
            .setRequiredFields(async.setRequiredFields);

        Long seed = this.seed + this.batchId;
        FObject.setSeed(seed);
        FObject.setGlobalLanguage(this.language);
        FObject.setGlobalLocality(this.locality);

        for (ForceeaService.FieldDefinition def : async.definitions) {
            newFObject.setDefinition(def.fieldApiName, def.definitionString);
        }

        if (String.isNotBlank(async.partitionFieldName)) {
            newFObject.setDefinition(async.partitionFieldName,
                'static value(' + this.partitionFieldValue + String.valueOf(this.sector) + ')');
        }

        return newFObject;
    }

    /**
     * @description Calculates the SOQL query LIMIT.
     * @return The SOQL query LIMIT.
     */
    private Integer getQueryLimit() {
        return (this.isBenchmark) ? LIMIT_ON_BENCHMARK : this.numMaxUnitsPerBatch;
    }

    /**
     * @description Creates a SOQL query.
     * @param partitionFieldName The Partition field API name.
     * @param partitionFieldValue The Partition field vale.
     * @return The SOQL query string.
     */
    private String getQueryString(String partitionFieldName, String partitionFieldValue) {
        this.queryLimit = getQueryLimit();

        List<String> fieldNames = new List<String>{
            'RecordTypeId'
        };
        final Map<String, String> valuesByField = getValuesByField(fieldNames);
        //System.debug('valuesByField: ' + valuesByField);

        String result = 'SELECT Id FROM ' + this.sObjectApiName;
        result += getQueryWhereClauseOnDelete(valuesByField, partitionFieldName, partitionFieldValue);
        result += ' LIMIT ' + this.queryLimit;

        //System.debug('SOQL Query: ' + result);
        return result;
    }

    /**
     * @description Generates the SOQL WHERE clause.
     * @param valuesByField The map of values by field.
     * @param partitionFieldName The Partition field name.
     * @param partitionFieldValue The Partition field vale.
     * @return The SOQL WHERE clause.
     */
    private String getQueryWhereClauseOnDelete(Map<String, String> valuesByField,
        String partitionFieldName, String partitionFieldValue) {
        //System.debug('> getQueryWhereClauseOnDelete');

        String additionalClause = '';
        Integer counter = 0;

        if (!valuesByField.isEmpty()) {
            for (String fieldName : valuesByField.keySet()) {
                if (counter > 1) {
                    additionalClause += ' AND ';
                }
                additionalClause += fieldName + ' = \'' + valuesByField.get(fieldName) + '\'';
                counter++;
            }
        }

        String result = '';
        //System.debug('hasPartitioning: ' + this.hasPartitioning);

        if (this.hasPartitioning) {
            result = ' WHERE ' + partitionFieldName + ' = \'' +
                String.escapeSingleQuotes(partitionFieldValue + String.valueOf(this.sector)) + '\'';
            if (String.isNotBlank(additionalClause)) {
                result += ' AND ' + additionalClause;
            }
        } else if (String.isNotBlank(additionalClause)) {
            result = ' WHERE ' + additionalClause;
        }

        return result;
    }

    /**
    * @description Retrieves the records for deletion.
    * @return A list of SObjects.
    */
    private List<SObject> getRecordsToDelete() {
        List<SObject> results = new List<SObject>();
        ForceeaService.FObjectAsync obj = this.sObjectsToDelete.get(this.sObjectToDeleteIndex);
        this.sObjectApiName = obj.sObjectApiName;

        try {
            String soqlQuery = getQueryString(obj.partitionFieldName, this.partitionFieldValue);
            results = Database.query(soqlQuery);
            //System.debug('sector: ' + this.sector + ', records to delete: ' + results.size());
        } catch (Exception ex) {
            //System.debug('getRecordsToDelete - error');
            this.operationIsSuccessful = false;
            this.errorMessage = ex.getMessage();
            publishLogMessageOnFailure();
        }

        this.numRecordsFoundForDeletion = results.size();
        return results;
    }

    /**
     * @description Retrieves the values from a static field definition.
     * @param definition The field definition.
     * @return The static value.
     */
    private String getStaticValueFromDefinition(ForceeaService.FieldDefinition definition) {
        String result = '';
        //System.debug('getStaticValueFromDefinition: ' + definition);

        if (definition.definitionString.toLowerCase().startsWith('static')) {
            result = definition.definitionString.trim();
            result = result.removeStart('static ');
            result = result.removeStart('value(');
            result = result.removeEnd(')');
        }

        return result;
    }

    /**
     * @description Generates the valuesByField map.
     * @param fieldNames The list of field names to retrieve.
     * @return A map with key: fieldName, value: field value, used in SOQL WHERE field = value.
     */
    private Map<String, String> getValuesByField(List<String> fieldNames) {
        Map<String, String> results = new Map<String, String>();
        //System.debug('definitionsOnDelete: ' + this.definitionsOnDelete);

        for (ForceeaService.FieldDefinition def : this.definitionsOnDelete) {
            if (fieldNames.contains(def.fieldApiName)) {
                String value = getStaticValueFromDefinition(def);
                //System.debug('value: ' + value);
                if (String.isNotBlank(value)) {
                    String fieldName = def.fieldApiName == 'RecordTypeId'
                        ? 'RecordType.DeveloperName'
                        : def.fieldApiName;
                    results.put(fieldName, value);
                }
            }
        }

        return results;
    }

    /**
     * @description Handles the process when terminated.
     */
    @TestVisible
    private void handleOnTerminated() {
        this.isTerminated = false;
        if (ForceeaService.asyncProcessIsTerminated()) {
            this.isTerminated = true;
            publishLogMessageOnSuccess();
        }
    }

    /**
     * @description Handles the deletion process.
     */
    private void handleOnDelete() {
        //System.debug('=== DELETE ===');
        List<SObject> recordsToDelete = new List<SObject>();

        this.shouldCheckNextSector = true;
        while (this.shouldCheckNextSector) {
            recordsToDelete = getRecordsToDelete();
            if (!this.operationIsSuccessful) {
                return;
            }

            if (recordsToDelete.isEmpty()) { // go to next sector
                decideForNextBatchOnDelete();
            } else {
                onBeforeDelete();
                deleteRecords(recordsToDelete);
                onAfterDelete();
                decideForNextBatchOnDelete();
                if (!this.operationIsSuccessful) {
                    return;
                }
                this.shouldCheckNextSector = false;
            }
        }
    }

    /**
     * @description Handles the insertion process.
     */
    private void handleOnInsert() {
        if (!FObject.processIsValid()) {
            return;
        }

        onBeforeInsert();
        insertRecords();
        onAfterInsert();
        decideForNextBatchOnInsert();
    }

    /**
     * @description Inserts records.
     */
    private void insertRecords() {
        //System.debug('=====================================================================');
        //System.debug(' INSERT Job: ' + this.jobId + ', iterations to exec: ' + this.numJobUnitsToExecute);
        //System.debug('=====================================================================');

        setNumOfBatchUnitsToExecute();
        FObject.setAsync(true);

        for (ForceeaService.FObjectAsync fObjAsync : this.template.values()) {
            FObject newFObject = getNewFObject(fObjAsync);

            this.sObjectApiName = newFObject.getSObjectName();
            if (this.isBenchmark) {
                newFObject.setNumberOfRecords(fObjAsync.numOfRecords);
            }

            //System.debug('Job Units Executed: ' + this.numJobUnitsExecuted);
            //System.debug('Records: ' + newFObject.getNumberOfRecords());
            //System.debug('will insert ' + newFObject.getNumberOfRecords() + ' records for [' + this.sObjectApiName + ']');

            try {
                newFObject.createRecords();
                newFObject.insertRecords(true);
            } catch (Exception ex) {
                FObjectAsync.setProcessIsValid(false);
                this.operationIsSuccessful = false;
                String errorMessageString = (!newFObject.getErrors().isEmpty())
                    ? ' - ' + String.join(newFObject.getErrors().values().get(0), ', ')
                    : '';
                this.errorMessage = ex.getMessage() + errorMessageString + '.';
                publishLogMessageOnFailure();
                return;
            }

            if (this.isBenchmark) {
                this.limitFObjectSetupCpuTime += newFObject.getCpuTimeOfSObjectSetup();
                this.limitDataGenerationCpuTime += newFObject.getCpuTimeOfDataGeneration();
            }
        }

        getLimitsOnBenchmark();

        if (!this.isBenchmark) {
            this.numJobUnitsToExecute -= this.numBatchUnitsToExecute;
            this.numJobUnitsExecuted += this.numBatchUnitsToExecute;
        }

        if (this.operationIsSuccessful) {
            publishLogMessageOnSuccess();
        }
    }

    /**
     * @description Handles the process after deletion.
     */
    private void onAfterDelete() {
        if (!this.operationIsSuccessful || !this.isBenchmark) {
            return;
        }

        this.limitGlobalSetupCpuTime = Limits.getCpuTime() - this.limitGlobalSetupCpuTime;
        this.limitDmlRows = Limits.getDmlRows() - this.limitDmlRows;
        //System.debug('limitGlobalSetupCpuTime: ' + this.limitGlobalSetupCpuTime);
        //System.debug('limitDmlRows: ' + this.limitDmlRows);
        //System.debug('numMaxUnitsPerBatch: ' + this.numMaxUnitsPerBatch);
    }

    /**
     * @description Handles the process before deletion.
    */
    private void onBeforeDelete() {
        if (!this.isBenchmark) {
            return;
        }

        //System.debug('===================== BENCHMARK =====================');
        this.limitGlobalSetupCpuTime = Limits.getCpuTime();
        this.limitDmlRows = Limits.getDmlRows();
    }

    /**
     * @description Handles the process after insertion.
     */
    private void onAfterInsert() {
        if (this.isBenchmark) {
            Database.rollback(this.savePoint);
            this.numFirstRecordsBySObject = this.tempNumFirstRecordsBySObject;
            //System.debug('numFirstRecordsBySObject: ' + this.numFirstRecordsBySObject);
        }
    }

    /**
     * @description Handles the process after insertion.
     */
    private void onBeforeInsert() {
        //System.debug('> ForceeaQueueable.onBeforeInsert');
        //System.debug('numFirstRecordsBySObject: ' + this.numFirstRecordsBySObject);
        FObject.numFirstRecordsBySObject = this.numFirstRecordsBySObject;
        //System.debug('FObject.numFirstRecordsBySObject: ' + FObject.numFirstRecordsBySObject);
        //System.debug('numMaxUnitsPerBatch: ' + this.numMaxUnitsPerBatch);

        if (this.isBenchmark && this.numMaxUnitsPerBatch == 1) {
            this.isBenchmark = false;
        }

        if (this.isBenchmark) {
            //System.debug('=== BENCHMARK');
            this.savePoint = Database.setSavepoint();
            this.tempNumFirstRecordsBySObject = new Map<String, Integer>(this.numFirstRecordsBySObject);
            //System.debug('tempNumFirstRecordsBySObject: ' + this.tempNumFirstRecordsBySObject);
        }
    }

    /**
     * @description Publishes a LOG message.
     * @return The Log message.
     */
    private String publishLogMessage() {
        String operationType = '';
        switch on this.operationType {
            when ASYNC_INSERT {
                operationType = 'insert';
            }
            when ASYNC_DELETE {
                operationType = 'delete';
            }
        }

        ForceeaAsyncNotification__e platformEvent = new ForceeaAsyncNotification__e();
        platformEvent.BatchId__c = this.batchId;
        platformEvent.JobId__c = this.jobId;
        platformEvent.Jobs__c = this.numJobs;
        platformEvent.JobUnitsExecuted__c = this.numJobUnitsExecuted;
        platformEvent.JobIsCompleted__c = this.jobIsCompleted;
        platformEvent.JobHasFailed__c = this.hasFailed;
        platformEvent.JobIsTerminated__c = this.isTerminated;
        platformEvent.Message__c = getLogMessage();
        platformEvent.OperationType__c = operationType;
        platformEvent.ProcessId__c = this.processId;
        platformEvent.ProcessUnitsToExecute__c = this.numProcessUnitsToExecute;
        platformEvent.TotalJobUnits__c = this.numTotalJobUnits;

        EventBus.publish(platformEvent);
        if (Test.isRunningTest()) {
            Test.getEventBus().deliver();
        }
        //System.debug(platformEvent);

        return platformEvent.Message__c;
    }

    /**
     * @description Publishes a Log message on failure.
     * @return The Log message.
     */
    @TestVisible
    private String publishLogMessageOnFailure() {
        this.operationIsSuccessful = false;
        this.numErrors++;
        this.shouldTryAgainAfterError = shouldTryAgainAfterErrorOnDelete();
        this.hasFailed = true;
        return publishLogMessage();
    }

    /**
     * @description Publishes a LOG message on success.
     */
    private void publishLogMessageOnSuccess() {
        publishLogMessage();
    }

    /**
     * @description Sets the number of batch units to execute.
     */
    private void setNumOfBatchUnitsToExecute() {
        //System.debug('> setNumOfBatchUnitsToExecute');
        //System.debug('numJobUnitsToExecute:' + this.numJobUnitsToExecute);
        //System.debug('numMaxUnitsPerBatch:' + this.numMaxUnitsPerBatch);

        if (this.isBenchmark) {
            this.numBatchUnitsToExecute = 1;
        }

        this.numBatchUnitsToExecute = this.numJobUnitsToExecute > this.numMaxUnitsPerBatch
            ? this.numMaxUnitsPerBatch
            : this.numJobUnitsToExecute;
        //System.debug('setNumBatchUnitsToExecute - numBatchUnitsToExecute: ' + this.numBatchUnitsToExecute);
    }

    /**
     * @description Sets the number of max units.
     */
    private void setNumOfMaxUnitsOnBenchmark() {
        if (!this.isBenchmark) {
            return;
        }

        switch on this.operationType {
            when ASYNC_INSERT {
                this.numMaxUnitsPerBatch = getMaxNumOfIterationsPerBatch();
            }
            when ASYNC_DELETE {
                this.numMaxUnitsPerBatch = getMaxNumOfRecordsToDeletePerBatch();
            }
        }
    }

    /**
     * @description Decides if must continue to the next sector when deleting.
     * @return True, if should continue to the next sector.
     */
    private Boolean shouldContinueToNextSectorOnDelete(Integer newSector) {
        Boolean result = true;

        // always: numRecordsFoundForDeletion <= queryLimit
        if (this.numRecordsFoundForDeletion == this.queryLimit) {
            return false;
        }

        // is numRecordsFoundForDeletion < queryLimit
        if (newSector > NUMBER_OF_SECTORS || !this.hasPartitioning) {
            this.shouldMoveToNextSObject = true;
            result = false;
        } else {
            this.sector = newSector;
        }

        //System.debug('shouldMoveToNextSObject: ' + this.shouldMoveToNextSObject);
        return result;
    }

    /**
     * @description Decides if must try again after an error on Delete.
     * @return True, if should try again.
     */
    @TestVisible
    private Boolean shouldTryAgainAfterErrorOnDelete() {
        if (this.operationType == ForceeaService.OperationType.ASYNC_INSERT) {
            return false;
        }

        Boolean shouldTryMultipleTimes = false;
        for (String errorCode : ERROR_CODES_TO_RETRY) {
            if (this.errorMessage.contains(errorCode)) {
                shouldTryMultipleTimes = true;
                break;
            }
        }

        return (shouldTryMultipleTimes && this.numErrors <= MAX_ERRORS) ? true : false;
    }

}