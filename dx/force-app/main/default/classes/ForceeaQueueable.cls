/*
  Forceea data factory (v2.8.0)
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
public with sharing class ForceeaQueueable implements Queueable {

    /* CONSTANTS */

    @TestVisible
    private static final Integer BENCHMARK_QUERY_LIMIT = 100;
    private static final Integer BIG_OBJECT_QUERY_LIMIT = 49999;
    private static final String ERROR_MESSAGE_DELETE_OPERATION_TOO_LARGE = 'DELETE_OPERATION_TOO_LARGE';
    private static final List<String> ERROR_CODES_TO_RETRY_ON_UPDATE_OR_DELETE = new List<String>{
        'UNABLE_TO_LOCK_ROW', ERROR_MESSAGE_DELETE_OPERATION_TOO_LARGE
    };
    @TestVisible
    private static final Decimal LIMITS_THRESHOLD = 0.95;
    private static final Integer NUMBER_OF_SECTORS = 50;
    private static final Integer MAX_ERRORS = 5;
    private static final String WHERE_KEYWORD = ' WHERE ';
    private static final String WHERE_AND = ' AND ';

    /* INSTANCE COLLECTIONS */

    private List<Forceea.FieldDefinition> definitionsOnUpdateOrDelete { get; set; }
    private Map<String, Integer> numFirstRecordsBySObject { get; set; }
    private Map<String, Integer> tempNumFirstRecordsBySObject { get; set; }
    private Map<String, Integer> sObjectApiNames { get; set; }
    private List<Forceea.FObjectAsynchronous> sObjectsToUpdateOrDelete { get; set; }
    private Map<String, Forceea.FObjectAsynchronous> template { get; set; }
    private List<String> whereClauses = new List<String>();

    /* INSTANCE VARIABLES & PROPERTIES */

    @TestVisible
    private Integer batchId { get; set; }
    private String bigObjectIndexFieldsString { get; set; }
    private Datetime dateTimeNow { get; set; }
    @TestVisible
    private String errorMessage { get; set; }
    private Boolean hasFailed { get; set; }
    private Boolean hasMoreRecordsToUpdateOrDelete { get; set; }
    private Boolean hasPartitioning { get; set; }
    private Boolean isBenchmark { get; set; }
    private Boolean isBigObject { get; set; }
    private Boolean isExcludedOnAsyncUpdateOrDelete { get; set; }
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
    private Integer numMaxRecordOnAsyncDelete { get; set; }
    private Integer numMaxRecordOnAsyncUpdate { get; set; }
    @TestVisible
    private Integer numMaxUnitsPerBatch { get; set; }
    private Integer numProcessUnitsToExecute { get; set; }
    private Integer numRecordsFoundToUpdateOrDelete { get; set; }
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
    private Integer sObjectToUpdateOrDeleteIndex { get; set; }
    private Integer timeFrameForUpdateInMinutes { get; set; }
    private String whereClauseOnDelete { get; set; }
    private String whereClauseOnUpdate { get; set; }
    private String verbose { get; set; }

    /* CONSTRUCTORS */

    public ForceeaQueueable(Forceea.AsyncTransaction asyncTransaction) {
        setParametersOnConstructor(asyncTransaction);
    }

    public ForceeaQueueable(String jsonString) {
        Forceea.AsyncTransaction asyncTransaction = (Forceea.AsyncTransaction) JSON.deserialize(jsonString, Forceea.AsyncTransaction.class);
        setParametersOnConstructor(asyncTransaction);
    }

    /* METHODS */

    /**
     * @description Creates a new batch.
     */
    private void createNewBatch() {
        try {
            this.batchId++;
            Forceea.AsyncTransaction asyncTrans = this.getAsyncTransaction();
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
    private void decideIfShouldCheckNextSectorOnUpdateOrDelete() {
        Integer nextSector = this.sector + this.numJobs;
        this.shouldCheckNextSector = shouldContinueToNextSectorOnUpdateOrDelete(nextSector);
    }

    /**
     * @description Decides if the same sector should be checked when deleting.
     */
    private void decideIfShouldCheckSameSectorOnUpdateOrDelete() {
        Boolean shouldTryAgain = !this.operationIsSuccessful && this.shouldTryAgainAfterError;
        this.hasMoreRecordsToUpdateOrDelete = this.numRecordsFoundToUpdateOrDelete == this.queryLimit;
        this.shouldCheckSameSector = (shouldTryAgain || this.hasMoreRecordsToUpdateOrDelete) ? true : false;
    }

    /**
     * @description Decides if a new batch should be created when deleting.
     */
    private void decideIfShouldCreateNewBatchOnUpdateOrDelete() {
        this.shouldCreateNewBatch = false;

        Boolean conditionOnSuccess = this.operationIsSuccessful && (
            (this.shouldMoveToNextSObject && !this.isTheLastSObject) ||
                this.shouldCheckSameSector ||
                (this.shouldCheckNextSector && this.numRecordsFoundToUpdateOrDelete > 0)
        );
        Boolean conditionOnFailure = !this.operationIsSuccessful && this.shouldTryAgainAfterError;
        if (conditionOnSuccess || conditionOnFailure) {
            this.shouldCreateNewBatch = true;
        }

        if (this.isBenchmark) {
            setNumOfMaxUnitsOnBenchmark();
        }
        if (this.operationIsSuccessful && this.numRecordsFoundToUpdateOrDelete > 0) { // benchmarking has finished
            deactivateBenchmarking();
        }
    }

    /**
     * @description Decides if this is the last SObject when deleting.
     */
    private void decideIfThisIsTheLastSObjectOnUpdateOrDelete() {
        this.isTheLastSObject = this.sObjectToUpdateOrDeleteIndex == this.sObjectsToUpdateOrDelete.size() - 1;
    }

    /**
     * @description Decides what happens as a next step when updating or deleting.
     */
    private void decideWhatHappensNextOnUpdateOrDelete() {
        if (this.shouldCreateNewBatch) {
            if (this.operationIsSuccessful) {
                publishLogMessageOnSuccess();
            }

            if (this.shouldMoveToNextSObject && !this.isTheLastSObject) {
                this.isBenchmark = true;
                this.sector = this.jobId;
                this.sObjectToUpdateOrDeleteIndex++;
            }

            createNewBatch();
            return;
        }

        if (jobIsCompleted()) {
            publishLogMessageOnSuccess();
            this.jobIsCompleted = true;
            publishLogMessageOnSuccess();
        }
    }

    /**
     * @description Decides for the next batch when deleting.
     */
    private void decideForNextBatchOnUpdateOrDelete() {
        decideIfShouldCheckSameSectorOnUpdateOrDelete();
        decideIfShouldCheckNextSectorOnUpdateOrDelete();
        decideIfThisIsTheLastSObjectOnUpdateOrDelete();
        decideIfShouldCreateNewBatchOnUpdateOrDelete();
        decideWhatHappensNextOnUpdateOrDelete();
    }

    /**
     * @description Decides for the next batch when inserting.
     */
    private void decideForNextBatchOnInsert() {
        Boolean hasMoreIterationsToInsert = this.operationIsSuccessful
            && this.operationType == ForceeaService.OperationType.ASYNC_INSERT
            && this.numJobUnitsToExecute > 0;

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
            }
        }
    }

    /**
     * @description The main execution method.
     * @param context The queueable context.
     */
    public void execute(QueueableContext context) {
        FObject.setGlobalVerbose(this.verbose);
        handleOnTerminated();
        if (this.isTerminated) {
            return;
        }

        switch on this.operationType {
            when ASYNC_INSERT {
                handleOnInsert();
            }
            when ASYNC_UPDATE, ASYNC_DELETE {
                handleOnUpdateOrDelete();
            }
        }
    }

    /**
     * @description Generates the WHERE clause when the async update operation is executed.
     */
    private void setRecordTypeClause() {
        String clause = '';
        Integer counter = 0;
        final Map<String, String> valuesByField = getValuesByField();

        if (!valuesByField.isEmpty()) {
            for (String fieldName : valuesByField.keySet()) {
                if (counter > 1) {
                    clause += WHERE_AND;
                }
                clause += fieldName + ' = \'' + valuesByField.get(fieldName) + '\'';
                counter++;
            }
        }

        this.whereClauses.add(clause);
    }

    /**
     * @description Creates an async transaction.
     * @return An instance of ForceeaAsynTransaction.
     */
    private Forceea.AsyncTransaction getAsyncTransaction() {
        Forceea.AsyncTransaction result = new Forceea.AsyncTransaction();

        result.batchId = this.batchId;
        result.dateTimeNow = this.dateTimeNow;
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
        result.sObjectToUpdateOrDeleteIndex = this.sObjectToUpdateOrDeleteIndex;
        result.sObjectsToUpdateOrDelete = this.sObjectsToUpdateOrDelete;
        result.template = this.template;
        result.timeFrameForUpdateInMinutes = this.timeFrameForUpdateInMinutes;

        return result;
    }

    /**
     * @description Retrieves the global limits.
     * @return The query LIMIT when benchmarking on update or delete.
     */
    private Integer getBenchmarkQueryLimitOnUpdateOrDelete() {
        Integer userMaxLimit = 0;
        if (isUpdate()) {
            userMaxLimit = this.numMaxRecordOnAsyncUpdate;
        } else {
            userMaxLimit = this.numMaxRecordOnAsyncDelete;
        }

        if (userMaxLimit == 0) {
            return BENCHMARK_QUERY_LIMIT;
        }
        return (userMaxLimit < BENCHMARK_QUERY_LIMIT) ? userMaxLimit : BENCHMARK_QUERY_LIMIT;
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
                message += 'deleting records of [' + this.sObjectApiName + ']: ';
                if (isDeleteOperationTooLarge()) {
                    message += ERROR_MESSAGE_DELETE_OPERATION_TOO_LARGE + '. Will try again with reduced number of records.';
                } else {
                    message += this.errorMessage;
                }
            }
            when ASYNC_UPDATE {
                message += 'updating records of [' + this.sObjectApiName + ']: ' + this.errorMessage;
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
                    message += ' inserted ' +
                        ForceeaService.getCountable('iteration', this.numBatchUnitsToExecute) + '.';
                }
            }
            when ASYNC_DELETE {
                message += ' deleted ' +
                    ForceeaService.getCountable('record', this.numBatchUnitsToExecute) +
                    ' of [' + this.sObjectApiName + '].';
            }
            when ASYNC_UPDATE {
                message += ' updated ' +
                    ForceeaService.getCountable('record', this.numBatchUnitsToExecute) +
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
        Decimal result = LIMITS_THRESHOLD * Limits.getLimitCpuTime();
        return (Integer) result;
    }

    private Integer getMaxIterationsForCpuTime() {
        Integer allowedCpuTime = getMaxCpuTime() - this.limitGlobalSetupCpuTime - this.limitFObjectSetupCpuTime;

        Integer result = 1;
        if (this.limitDataGenerationCpuTime > 0) {
            result = (Integer) allowedCpuTime / this.limitDataGenerationCpuTime;
        }

        return result;
    }

    private Integer getMaxIterationsForDmlRows() {
        Integer result = 1;

        if (Limits.getDmlRows() > 0) {
            result = (Integer) Limits.getLimitDmlRows() / Limits.getDmlRows();
        }

        return result;
    }

    private Integer getMaxIterationsForHeapSize() {
        Integer result = 1;

        if (Limits.getHeapSize() > 0) {
            result = (Integer) Limits.getLimitHeapSize() / Limits.getHeapSize();
        }

        return result;
    }

    /**
     * @description Retrieves the max number of iterations per batch.
     * @return The max number of iterations per batch.
     */
    private Integer getMaxNumOfIterationsPerBatch() {
        if (this.numMaxUnitsPerBatch > 0) {
            return this.numMaxUnitsPerBatch;
        }

        Integer maxIterationsForCpuTime = getMaxIterationsForCpuTime();
        Integer maxIterationsForDmlRows = getMaxIterationsForDmlRows();
        Integer maxIterationsForHeapSize = getMaxIterationsForHeapSize();

        List<Integer> maxIterations = new List<Integer>{
            maxIterationsForCpuTime,
            maxIterationsForDmlRows,
            maxIterationsForHeapSize
        };
        maxIterations.sort();

        return maxIterations.get(0);
    }

    private Integer getMaxNumOfRecordsFromMultipliers(ForceeaQueueable queueable, List<Decimal> multipliers) {
        multipliers.sort();

        List<Integer> results = new List<Integer>{
            Integer.valueOf(multipliers.get(0) * queueable.numBatchUnitsExecuted * ForceeaQueueable.LIMITS_THRESHOLD),
            Integer.valueOf(Limits.getLimitDmlRows() * ForceeaQueueable.LIMITS_THRESHOLD)
        };

        results.sort();
        return results.get(0);
    }

    /**
     * @description Calculates the max number of records than can be updated or deleted per batch.
     * @return The max number of records.
     */
    @TestVisible
    private Integer getMaxNumOfRecordsToUpdatedOrDeletePerBatch() {
        if (this.numMaxUnitsPerBatch > 1) {
            return this.numMaxUnitsPerBatch;
        }

        Integer userMaxLimit = 0;
        if (isUpdate()) {
            userMaxLimit = this.numMaxRecordOnAsyncUpdate;
        } else {
            userMaxLimit = this.numMaxRecordOnAsyncDelete;
        }

        return (userMaxLimit > 0) ? userMaxLimit : getMaxNumOfRecordsToUpdateOrDeletePerBatchFromQueueable(this);
    }

    /**
     * @description Calculates the max number of records than can be updated or deleted per batch.
     * @param queueable A ForceeaQueueable instance.
     * @return The max number of records.
     */
    @TestVisible
    private Integer getMaxNumOfRecordsToUpdateOrDeletePerBatchFromQueueable(ForceeaQueueable queueable) {
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

        return getMaxNumOfRecordsFromMultipliers(queueable, multipliers);
    }

    /**
     * @description Returns a new FObject from an instance of Forceea.FObjectAsync.
     * @param async An instance of Forceea.FObjectAsync.
     * @return An FObject instance.
     */
    private FObject getNewFObject(Forceea.FObjectAsynchronous async) {
        Integer numRecords = async.numOfRecords * this.numBatchUnitsToExecute;

        FObject newFObject = new FObject(async.sObjectApiName, numRecords)
            .setRequiredFields(async.setRequiredFields);

        Long seed = this.seed + this.batchId;
        FObject.setSeed(seed);
        FObject.setGlobalLanguage(this.language);
        FObject.setGlobalLocality(this.locality);

        for (Forceea.FieldDefinition def : async.definitions) {
            newFObject.setDefinition(def.fieldApiName, def.definitionString);
        }

        if (String.isNotBlank(async.partitionFieldName)) {
            newFObject.setDefinition(async.partitionFieldName,
                'static value(' + this.partitionFieldValue + String.valueOf(this.sector) + ')');
        }

        return newFObject;
    }

    /**
     * @description Returns the maximum number of records that can be deleted in each batch
     *   when the delete operation raises the DELETE_OPERATION_TOO_LARGE error.
     * @return An integer number.
     */
    private Integer getNumMaxUnitsPerBatchOnDeleteOperationTooLarge() {
        return ForceeaService.getNumberReducedByPercent(this.numMaxUnitsPerBatch, 20);
    }

    /**
     * @description Generates the query FROM clause.
     * @return The query FROM clause string.
     */
    private String getQueryFromClause() {
        return ' FROM ' + this.sObjectApiName;
    }

    /**
     * @description Generates the query LIMIT clause.
     * @return The query LIMIT clause string.
     */
    private String getQueryLimitClause() {
        if (this.isBigObject) {
            this.numMaxUnitsPerBatch = BIG_OBJECT_QUERY_LIMIT;
        }
        this.queryLimit = (this.isBenchmark)
            ? getBenchmarkQueryLimitOnUpdateOrDelete()
            : this.numMaxUnitsPerBatch;

        return ' LIMIT ' + this.queryLimit;
    }

    /**
     * @description Generates the query SELECT clause.
     * @return The query SELECT clause string.
     */
    private String getQuerySelectClause() {
        String selectString = (this.isBigObject) ? this.bigObjectIndexFieldsString : 'Id';
        return 'SELECT ' + selectString;
    }

    /**
     * @description Creates a SOQL query.
     * @param partitionFieldName The Partition field API name.
     * @return The SOQL query string.
     */
    private String getQueryString(String partitionFieldName) {
        return getQuerySelectClause() + getQueryFromClause() + getQueryWhereClause(partitionFieldName) + getQueryLimitClause();
    }

    /**
     * @description Generates the SOQL WHERE clause.
     * @param partitionFieldName The Partition field name.
     * @return The SOQL WHERE clause.
     */
    private String getQueryWhereClause(String partitionFieldName) {
        setPartitionFieldClause(partitionFieldName);
        setRecordTypeClause();
        setUserDefinedClause();
        setLastModifiedDateClause();

        return getWhereClause();
    }

    /**
     * @description Retrieves the records for deletion.
     * @return A list of SObjects.
     */
    private List<SObject> getRecordsToUpdateOrDelete() {
        Forceea.FObjectAsynchronous obj = this.sObjectsToUpdateOrDelete.get(this.sObjectToUpdateOrDeleteIndex);
        setPropertiesFromFObjectAsynchronous(obj);

        List<SObject> results = new List<SObject>();
        try {
            if (!this.isExcludedOnAsyncUpdateOrDelete) {
                String soqlQuery = getQueryString(obj.partitionFieldName);
                results = Database.query(soqlQuery);
            }
        } catch (Exception ex) {
            this.operationIsSuccessful = false;
            this.errorMessage = ex.getMessage();
            publishLogMessageOnFailure();
        }

        this.numRecordsFoundToUpdateOrDelete = results.size();
        return results;
    }

    /**
     * @description Retrieves the values from a static field definition.
     * @param definition The field definition.
     * @return The static value.
     */
    private String getStaticValueFromDefinition(Forceea.FieldDefinition definition) {
        String result = '';

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
     * @return A map with key: fieldName, value: field value, used in SOQL WHERE field = value.
     */
    private Map<String, String> getValuesByField() {
        List<String> fieldNames = new List<String>{
            'RecordTypeId'
        };

        Map<String, String> results = new Map<String, String>();

        for (Forceea.FieldDefinition def : this.definitionsOnUpdateOrDelete) {
            if (fieldNames.contains(def.fieldApiName)) {
                String value = getStaticValueFromDefinition(def);
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
     * @description Retrieves the WHERE clause.
     * @return The WHERE clause string.
     */
    private String getWhereClause() {
        String result = getStringOfWhereClausesWithoutWhereKeyword();
        return (String.isNotBlank(result)) ? WHERE_KEYWORD + result : result;
    }

    /**
     * @description Retrieves the string of WHERE clauses without the WHERE keyword.
     * @return The WHERE clause string.
     */
    private String getStringOfWhereClausesWithoutWhereKeyword() {
        String result = '';
        Integer counter = 0;

        for (String clause : this.whereClauses) {
            if (String.isBlank(clause)) {
                continue;
            }
            result += (counter > 0) ? WHERE_AND + clause : clause;
            counter++;
        }

        return result;
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
    private void handleOnUpdateOrDelete() {
        List<SObject> recordsToUpdateOrDelete = new List<SObject>();

        this.shouldCheckNextSector = true;
        while (this.shouldCheckNextSector) {
            recordsToUpdateOrDelete = getRecordsToUpdateOrDelete();
            if (!this.operationIsSuccessful) {
                return;
            }

            if (recordsToUpdateOrDelete.isEmpty()) { // go to next sector
                decideForNextBatchOnUpdateOrDelete();
            } else {
                onBeforeUpdateOrDelete();
                updateOrDeleteRecords(recordsToUpdateOrDelete);
                onAfterUpdateOrDelete();
                decideForNextBatchOnUpdateOrDelete();
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
        setNumOfBatchUnitsToExecute();
        FObject.setAsync(true);
        ForceeaDefinition.clearMapMaxSuffixNumbersByKey();

        for (Forceea.FObjectAsynchronous fObjAsync : this.template.values()) {
            FObject newFObject = getNewFObject(fObjAsync);

            this.sObjectApiName = newFObject.getSObjectName();
            if (this.isBenchmark) {
                newFObject.setNumberOfRecords(fObjAsync.numOfRecords);
            }
            if (fObjAsync.numOfRecordsIsAuto) {
                newFObject.setNumberOfRecords(0);
                newFObject.setNumberOfRecords('auto');
            }

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

    private Boolean isDeleteOperationTooLarge() {
        return this.errorMessage.contains(ERROR_MESSAGE_DELETE_OPERATION_TOO_LARGE);
    }

    private Boolean isUpdate() {
        return this.operationType == ForceeaService.OperationType.ASYNC_UPDATE;
    }

    private Boolean jobIsCompleted() {
        return this.shouldMoveToNextSObject && this.isTheLastSObject;
    }

    /**
     * @description Handles the process after deletion.
     */
    private void onAfterUpdateOrDelete() {
        if (!this.operationIsSuccessful || !this.isBenchmark) {
            return;
        }

        this.limitGlobalSetupCpuTime = Limits.getCpuTime() - this.limitGlobalSetupCpuTime;
        this.limitDmlRows = Limits.getDmlRows() - this.limitDmlRows;
    }

    /**
     * @description Handles the process after insertion.
     */
    private void onAfterInsert() {
        if (this.isBenchmark) {
            Database.rollback(this.savePoint);
            this.numFirstRecordsBySObject = this.tempNumFirstRecordsBySObject;
        }
    }

    /**
     * @description Handles the process before deletion.
     */
    private void onBeforeUpdateOrDelete() {
        if (!this.isBenchmark) {
            return;
        }

        this.limitGlobalSetupCpuTime = Limits.getCpuTime();
        this.limitDmlRows = Limits.getDmlRows();
    }

    /**
     * @description Handles the process after insertion.
     */
    private void onBeforeInsert() {
        FObject.numFirstRecordsBySObject = this.numFirstRecordsBySObject;

        if (this.isBenchmark && this.numMaxUnitsPerBatch == 1) {
            this.isBenchmark = false;
        }

        if (this.isBenchmark) {
            this.savePoint = Database.setSavepoint();
            this.tempNumFirstRecordsBySObject = new Map<String, Integer>(this.numFirstRecordsBySObject);
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
            when ASYNC_UPDATE {
                operationType = 'update';
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
        this.shouldTryAgainAfterError = shouldTryAgainAfterErrorOnUpdateOrDelete();
        return publishLogMessage();
    }

    /**
     * @description Publishes a LOG message on success.
     */
    private void publishLogMessageOnSuccess() {
        publishLogMessage();
    }

    /**
     * @description Sets class properties from Forceea.FObjectAsynchronous.
     * @param obj
     */
    private void setPropertiesFromFObjectAsynchronous(Forceea.FObjectAsynchronous obj) {
        this.bigObjectIndexFieldsString = obj.bigObjectIndexFieldsString;
        this.isExcludedOnAsyncUpdateOrDelete = obj.isExcludedOnUpdateOrDelete;
        this.numMaxRecordOnAsyncDelete = obj.numMaxRecordOnDelete;
        this.numMaxRecordOnAsyncUpdate = obj.numMaxRecordOnUpdate;
        this.sObjectApiName = obj.sObjectApiName;
        this.timeFrameForUpdateInMinutes = obj.timeFrameForUpdateInMinutes;
        this.whereClauseOnDelete = obj.whereClauseOnDelete;
        this.whereClauseOnUpdate = obj.whereClauseOnUpdate;

        this.isBigObject = ForceeaService.isBigObject(this.sObjectApiName);
        if (this.isBigObject) {
            deactivateBenchmarking();
        }
    }

    /**
     * @description Sets the LastModifiedDate WHERE clause.
     */
    private void setLastModifiedDateClause() {
        if (this.operationType != ForceeaService.OperationType.ASYNC_UPDATE) {
            return;
        }

        Datetime dt = this.dateTimeNow.addMinutes(-this.timeFrameForUpdateInMinutes);
        String timeString = String.valueOfGmt(dt);
        timeString = timeString.substringBefore(' ') + 'T' + timeString.substringAfter(' ') + 'Z';

        this.whereClauses.add('LastModifiedDate <= ' + timeString);
    }

    /**
     * @description Sets the number of batch units to execute.
     */
    private void setNumOfBatchUnitsToExecute() {
        if (this.isBenchmark) {
            this.numBatchUnitsToExecute = 1;
        }

        this.numBatchUnitsToExecute = this.numJobUnitsToExecute > this.numMaxUnitsPerBatch
            ? this.numMaxUnitsPerBatch
            : this.numJobUnitsToExecute;
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
            when ASYNC_DELETE, ASYNC_UPDATE {
                this.numMaxUnitsPerBatch = getMaxNumOfRecordsToUpdatedOrDeletePerBatch();
            }
        }
    }

    /**
     * @description Sets various properties when the constructor is executed.
     * @param asyncTransaction A Forceea.AsyncTransaction object.
     */
    private void setParametersOnConstructor(Forceea.AsyncTransaction asyncTransaction) {
        this.batchId = asyncTransaction.batchId;
        this.dateTimeNow = asyncTransaction.dateTimeNow;
        this.errorMessage = '';
        this.numFirstRecordsBySObject = asyncTransaction.numFirstRecordsBySObject;
        this.hasFailed = false;
        this.hasMoreRecordsToUpdateOrDelete = false;
        this.hasPartitioning = asyncTransaction.hasPartitioning;
        this.isBenchmark = asyncTransaction.isBenchmark;
        this.isExcludedOnAsyncUpdateOrDelete = asyncTransaction.isExcludedOnAsyncUpdateOrDelete;
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
        this.numMaxRecordOnAsyncDelete = asyncTransaction.numMaxRecordOnAsyncDelete;
        this.numMaxRecordOnAsyncUpdate = asyncTransaction.numMaxRecordOnAsyncUpdate;
        this.numMaxUnitsPerBatch = asyncTransaction.numMaxUnitsPerBatch;
        this.numProcessUnitsToExecute = asyncTransaction.numProcessUnitsToExecute;
        this.numRecordsFoundToUpdateOrDelete = 0;
        this.numTotalJobUnits = asyncTransaction.numTotalJobUnits;
        this.operationIsSuccessful = true;
        this.operationType = asyncTransaction.operationType;
        if (this.operationType != ForceeaService.OperationType.ASYNC_INSERT) {
            Integer index = asyncTransaction.sObjectToUpdateOrDeleteIndex;
            if (!asyncTransaction.sObjectsToUpdateOrDelete.isEmpty()) {
                this.definitionsOnUpdateOrDelete = asyncTransaction.sObjectsToUpdateOrDelete.get(index).definitions;
            }
        }
        this.partitionFieldValue = asyncTransaction.partitionFieldValue;
        this.processId = asyncTransaction.processId;
        this.queryLimit = BENCHMARK_QUERY_LIMIT;
        this.sector = asyncTransaction.sector;
        this.seed = asyncTransaction.seed;
        this.shouldCheckNextSector = false;
        this.shouldCheckSameSector = false;
        this.shouldCreateNewBatch = false;
        this.shouldMoveToNextSObject = false;
        this.shouldTryAgainAfterError = false;
        this.sObjectApiName = asyncTransaction.sObjectApiName;
        this.sObjectApiNames = new Map<String, Integer>();
        this.sObjectToUpdateOrDeleteIndex = asyncTransaction.sObjectToUpdateOrDeleteIndex;
        this.sObjectsToUpdateOrDelete = asyncTransaction.sObjectsToUpdateOrDelete;
        this.template = asyncTransaction.template;
        this.timeFrameForUpdateInMinutes = asyncTransaction.timeFrameForUpdateInMinutes;
        this.verbose = asyncTransaction.verbose;
    }

    private void setPartitionFieldClause(String partitionFieldName) {
        if (!this.hasPartitioning) {
            return;
        }

        String clause = partitionFieldName + ' = \'' +
            String.escapeSingleQuotes(this.partitionFieldValue + String.valueOf(this.sector)) + '\'';
        this.whereClauses.add(clause);
    }

    private void setUserDefinedClause() {
        if (isUpdate()) {
            this.whereClauses.add(this.whereClauseOnUpdate);
        } else {
            this.whereClauses.add(this.whereClauseOnDelete);
        }
    }

    /**
     * @description Decides if must continue to the next sector when updating or deleting.
     * @param newSector The number of the new sector.
     * @return True, if should continue to the next sector.
     */
    private Boolean shouldContinueToNextSectorOnUpdateOrDelete(Integer newSector) {
        Boolean result = true;

        if (this.numRecordsFoundToUpdateOrDelete == this.queryLimit) {
            return false;
        }

        if (newSector > NUMBER_OF_SECTORS || !this.hasPartitioning) {
            this.shouldMoveToNextSObject = true;
            result = false;
        } else {
            this.sector = newSector;
        }

        return result;
    }

    /**
     * @description Decides if must try again after an error on Update or Delete.
     * @return True, if should try again.
     */
    @TestVisible
    private Boolean shouldTryAgainAfterErrorOnUpdateOrDelete() {
        if (this.operationType == ForceeaService.OperationType.ASYNC_INSERT) {
            return false;
        }

        Boolean shouldTryMultipleTimes = false;

        for (String errorCode : ERROR_CODES_TO_RETRY_ON_UPDATE_OR_DELETE) {
            if (this.errorMessage.contains(errorCode)) {
                shouldTryMultipleTimes = true;
                if (isDeleteOperationTooLarge()) {
                    this.numMaxUnitsPerBatch = getNumMaxUnitsPerBatchOnDeleteOperationTooLarge();
                }
                break;
            }
        }

        Boolean shouldTryAgain = shouldTryMultipleTimes && this.numErrors <= MAX_ERRORS ? true : false;
        this.hasFailed = true;

        return shouldTryAgain;
    }

    /**
     * @description Updates or deletes records.
     * @param recordsToUpdateOrDelete The list of records to update or delete.
     */
    private void updateOrDeleteRecords(List<SObject> recordsToUpdateOrDelete) {
        try {
            if (this.operationType == ForceeaService.OperationType.ASYNC_UPDATE) {
                Database.update(recordsToUpdateOrDelete, true);
            } else {
                if (this.isBigObject) {
                    Database.deleteImmediate(recordsToUpdateOrDelete);
                } else {
                    Database.delete(recordsToUpdateOrDelete, true);
                }
            }
        } catch (Exception ex) {
            this.operationIsSuccessful = false;
            this.errorMessage = ex.getMessage();
            publishLogMessageOnFailure();
            return;
        }

        this.numBatchUnitsExecuted = recordsToUpdateOrDelete.size();
        this.numJobUnitsExecuted += this.numBatchUnitsExecuted;
        this.numBatchUnitsToExecute = this.numBatchUnitsExecuted;
    }

    /**
     * @description Updates records.
     * @param recordsToUpdate
     */
    private void updateRecords(List<SObject> recordsToUpdate) {
        try {
            Database.update(recordsToUpdate, true);
        } catch (Exception ex) {
            this.operationIsSuccessful = false;
            this.errorMessage = ex.getMessage();
            publishLogMessageOnFailure();
            return;
        }

        this.numBatchUnitsExecuted = recordsToUpdate.size();
        this.numJobUnitsExecuted += this.numBatchUnitsExecuted;
        this.numBatchUnitsToExecute = this.numBatchUnitsExecuted;
    }

}