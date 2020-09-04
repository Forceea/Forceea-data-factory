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
public with sharing class FObjectAsync {

    /* CONSTANTS */

    private static final Integer DEFAULT_NUMBER_OF_JOBS = 30;
    private static final String MESSAGE_CANNOT_EXEC_PROCESS_BY_USER =
        'Forceea cannot execute the async process initiated by user';
    private static final String MESSAGE_CANNOT_EXEC_PROCESS_BECAUSE = 'because another process is being executed.';

    /* STATIC VARIABLES & PROPERTIES */

    private static Boolean processIsValid { get; set; }
    private static Boolean processIsTerminated { get; set; }

    /* INSTANCE COLLECTIONS */

    private Map<String, ForceeaService.FObjectAsync> asyncTemplate = new Map<String, ForceeaService.FObjectAsync>();
    private Map<String, FObject> template = new Map<String, FObject>();

    /* INSTANCE VARIABLES & PROPERTIES */

    private ForceeaService.AsyncTransaction asyncTrans { get; set; }
    private Boolean hasPartitioning { get; set; }
    private Integer numIterationsToExecute { get; set; }
    private Integer numJobs { get; set; }
    private Integer numMaxIterationsPerBatch { get; set; }
    private ForceeaService.OperationType operationType { get; set; }
    private String partitionFieldValue { get; set; }
    private String processId { get; set; }
    private Boolean shouldBenchmark { get; set; }

    /* INITIALIZATION */

    // static initialization
    static {
        FObjectAsync.processIsValid = true;
        FObjectAsync.processIsTerminated = false;
    }

    // instance initialization
    {
        this.asyncTrans = new ForceeaService.AsyncTransaction();
        this.hasPartitioning = false;
        this.numIterationsToExecute = 1;
        this.numJobs = this.getDefaultNumberOfJobs();
        this.numMaxIterationsPerBatch = 0;
        this.partitionFieldValue = '';
        this.processId = '';
        this.shouldBenchmark = true;
    }

    /* CONSTRUCTORS */

    public FObjectAsync(Map<String, FObject> template) {
        this.template = template;
        this.asyncTemplate = getAsyncTemplate(this.template);
        ForceeaService.setProcessCustomSetting(false);
    }

    /* METHODS */

    /**
     * @description Informs if there is another active async process.
     * @return newValue The value for updating the IsTerminated__c field.
     */
    private static Boolean anotherProcessIsActive() {
        Boolean result = false;

        if (!ForceeaService.getJobs().isEmpty()) {
            result = true;
            String message = MESSAGE_CANNOT_EXEC_PROCESS_BY_USER + ' [' + UserInfo.getName() + '], '+
                MESSAGE_CANNOT_EXEC_PROCESS_BECAUSE;
            ForceeaService.publishUserMessage(ForceeaService.asyncMessageType.MESSAGE_TYPE_INFO, message);
        }

        return result;
    }

    /**
     * @description Deletes records asynchronously.
     * @return An instance of FObjectAsync.
     */
    public FObjectAsync deleteRecords() {
        if (FObjectAsync.anotherProcessIsActive() || !ForceeaService.recordsCanBeDeletedInThisOrg()) {
            return this;
        }

        this.operationType = ForceeaService.OperationType.ASYNC_DELETE;
        this.numJobs = getNumberOfJobs();
        initializeAsyncProcess(this.numJobs);

        String userMessage = 'User [' + UserInfo.getName() + '] initiated the async Delete process with ID:' +
            this.processId + '.';
        ForceeaService.publishUserMessage(ForceeaService.asyncMessageType.MESSAGE_TYPE_INFO, userMessage);

        List<ForceeaService.FObjectAsync> asyncFObjects = getAsyncFObjectsFromTemplate();
        enqueueJobsOnDelete(asyncFObjects);

        return this;
    }

    /**
     * @description Enqueues jobs when deleting records asynchronously.
     * @param asyncFObjects An list of ForceeaService.FObjectAsync.
     */
    private void enqueueJobsOnDelete(List<ForceeaService.FObjectAsync> asyncFObjects) {
        List<ForceeaService.FObjectAsync> asyncFObjectsToDelete = getReversedList(asyncFObjects);

        if (hasBlankPartitionFieldInAnySObject(asyncFObjectsToDelete) || String.isBlank(this.partitionFieldValue)) {
            //System.debug('.. will use 1 delete job');
            this.numJobs = 1;
            this.hasPartitioning = false;
        } else {
            this.hasPartitioning = true;
        }

        for (Integer jobId = 1; jobId <= this.numJobs; jobId++) {
            this.asyncTrans = new ForceeaService.AsyncTransaction();
            this.asyncTrans.numJobUnitsToExecute = 1;
            this.asyncTrans.numProcessUnitsToExecute = this.numJobs;
            this.asyncTrans.operationType = this.operationType;
            this.asyncTrans.sObjectsToDelete = asyncFObjectsToDelete;
            this.asyncTrans.sObjectToDeleteIndex = 0;
            this.asyncTrans.sector = jobId;
            this.asyncTrans.hasPartitioning = this.hasPartitioning;
            setOtherAsyncTransactionDetails(jobId);
            ForceeaService.enqueueJob(this.asyncTrans);
        }
    }

    /**
     * @description Enqueues jobs when inserting records asynchronously.
     */
    private void enqueueJobsOnInsert() {
        // initilaize map
        //System.debug('..initilaize map: numOfFirstRecordsBySObject');
        Map<String, Integer> numOfFirstRecordsBySObject = new Map<String, Integer>();
        for (FObject sObj : this.template.values()) {
            numOfFirstRecordsBySObject.put(sObj.getSObjectName(), 1);
        }

        //System.debug('..enqueue jobs');
        for (Integer jobId = 1; jobId <= numJobs; jobId++) {
            //System.debug('jobId: ' + jobId);
            this.asyncTrans = new ForceeaService.AsyncTransaction();
            this.asyncTrans.language = FObject.getGlobalLanguage();
            this.asyncTrans.locality = FObject.getGlobalLocality();
            this.asyncTrans.numFirstRecordsBySObject = new Map<String, Integer>(numOfFirstRecordsBySObject);
            //System.debug('- numOfFirstRecordsBySObject: ' + this.asyncTrans.numFirstRecordsBySObject);
            this.asyncTrans.numJobUnitsToExecute = this.getNumberOfIterationsForThisJob(jobId);
            this.asyncTrans.numMaxUnitsPerBatch = this.numMaxIterationsPerBatch;
            this.asyncTrans.numProcessUnitsToExecute = this.numIterationsToExecute;
            this.asyncTrans.numTotalJobUnits = this.asyncTrans.numJobUnitsToExecute;
            this.asyncTrans.operationType = this.operationType;
            this.asyncTrans.seed = FObject.seed + (100000L * jobId);
            setOtherAsyncTransactionDetails(jobId);

            ForceeaService.enqueueJob(this.asyncTrans);
            numOfFirstRecordsBySObject = getNextRecordNumbersBySObjectMap(numOfFirstRecordsBySObject);
        }
    }

    /**
     * @description Constructs an async template from a standard template.
     * @param template The standard template.
     * @return A map with key: the standard template key, value: an instance of ForceeaService.FObjectAsync.
     */
    private Map<String, ForceeaService.FObjectAsync> getAsyncTemplate(Map<String, FObject> template) {
        Map<String, ForceeaService.FObjectAsync> results = new Map<String, ForceeaService.FObjectAsync>();

        for (String key : template.keySet()) {
            ForceeaService.FObjectAsync obj = new ForceeaService.FObjectAsync();
            obj.numOfRecords = template.get(key).getNumberOfRecords();
            obj.partitionFieldName = template.get(key).getPartitionFieldName();
            obj.sObjectApiName = template.get(key).getSObjectName();
            obj.setRequiredFields = template.get(key).requiredFieldsShouldBeAutomaticallyConfigured();

            obj.definitions = new List<ForceeaService.FieldDefinition>();
            for (ForceeaDefinition def : template.get(key).definitions) {
                ForceeaService.FieldDefinition fd = new ForceeaService.FieldDefinition();
                fd.definitionString = def.definitionString;
                fd.fieldApiName = def.fieldApiName;
                obj.definitions.add(fd);
            }
            results.put(key, obj);
        }

        return results;
    }

    /**
     * @description Retrieves a list of ForceeaService.FObjectAsync from the template.
     * @return A list of ForceeaService.FObjectAsync.
     */
    private List<ForceeaService.FObjectAsync> getAsyncFObjectsFromTemplate() {
        List<ForceeaService.FObjectAsync> results = new List<ForceeaService.FObjectAsync>();

        for (ForceeaService.FObjectAsync obj : this.asyncTemplate.values()) {
            ForceeaService.FObjectAsync newObj = new ForceeaService.FObjectAsync();
            newObj.definitions = obj.definitions;
            newObj.partitionFieldName = obj.partitionFieldName;
            newObj.sObjectApiName = obj.sObjectApiName;
            results.add(newObj);
        }

        return results;
    }

    /**
     * @description Calculates the default number of async jobs.
     * @return The default number of async jobs.
     */
    private Integer getDefaultNumberOfJobs() {
        Integer result = 0;

        Integer maxNumberOfJobs = Limits.getLimitQueueableJobs() - Limits.getQueueableJobs();
        result = (maxNumberOfJobs >= DEFAULT_NUMBER_OF_JOBS)
            ? DEFAULT_NUMBER_OF_JOBS
            : maxNumberOfJobs;

        return result;
    }

    /**
     * @description Returns a map of First Records from the map of previous First Records.
     * @param numFirstRecordsBySObject The map of Nummber of First records per SObject.
     * @return A map with key: SObject API name, value: number of First Record.
     */
    private Map<String, Integer> getNextRecordNumbersBySObjectMap(Map<String, Integer> numFirstRecordsBySObject) {
        Map<String, Integer> results = new Map<String, Integer>(numFirstRecordsBySObject);
        List<FObject> fObjects = this.template.values();

        for (FObject obj : fObjects) {
            String sObjectApiName = obj.getSObjectName();
            //System.debug('sObjectApiName: ' + sObjectApiName);

            Integer previousFirstRecord = results.get(sObjectApiName);
            Integer newFirstRecord = previousFirstRecord + obj.getNumberOfRecords() * this.asyncTrans.numJobUnitsToExecute;
            //System.debug('previousRecord: ' + previousFirstRecord);
            //System.debug('numJobUnitsToExecute: ' + this.asyncTrans.numJobUnitsToExecute);
            //System.debug('getNumberOfRecords: ' + obj.getNumberOfRecords());
            //System.debug('==>>> new first record: ' + newFirstRecord);

            results.put(sObjectApiName, newFirstRecord);
        }

        return results;
    }

    /**
     * @description Calculates the actual number of async jobs.
     * @return The actual number of async jobs.
     */
    private Integer getNumberOfJobs() {
        Integer result = 0;

        Integer availableJobs = Limits.getLimitQueueableJobs() - Limits.getQueueableJobs();
        result = availableJobs <= this.numJobs ? availableJobs : this.numJobs;
        if (this.operationType == ForceeaService.OperationType.ASYNC_INSERT) {
            result = this.numIterationsToExecute < result ? this.numIterationsToExecute : result;
        }

        return result;
    }

    /**
     * @description Calculates the number of iterations for a job.
     * @param jobId The job ID.
     * @return The number of job iterations.
     */
    private Integer getNumberOfIterationsForThisJob(Integer jobId) {
        Decimal numberOfIterationsPerJob = this.numIterationsToExecute / this.numJobs;
        Integer numCeiling = (Integer) numberOfIterationsPerJob.round(System.RoundingMode.HALF_DOWN);

        if (jobId == this.numJobs) {
            return (this.numIterationsToExecute - (jobId - 1) * numCeiling);
        } else {
            return numCeiling;
        }
    }

    /**
     * @description Retrieves the Partition field value.
     * @return The Partition field value string.
     */
    @TestVisible
    private String getPartitionFieldValue() {
        return this.partitionFieldValue;
    }

    /**
     * @description Creates the process ID.
    * @return The Process ID string.
    */
    private String getProcessId() {
        Decimal rnd = Math.random() * 1000000000L;
        String result = String.valueOf(rnd.longValue());
        return result;
    }

    /**
     * @description Retrieves a reversed list of ForceeaService.FObjectAsync.
     * @param asyncFObjects The list of ForceeaService.FObjectAsync.
     * @return The reversed list.
     */
    private List<ForceeaService.FObjectAsync> getReversedList(List<ForceeaService.FObjectAsync> asyncFObjects) {
        List<ForceeaService.FObjectAsync> results = new List<ForceeaService.FObjectAsync>();

        for (Integer counter = asyncFObjects.size() - 1; counter >= 0; counter--) {
            results.add(asyncFObjects.get(counter));
        }

        return results;
    }

    /**
     * @description Calculates the required storage for inserting records asynchronously.
     * @return The estimated storage in MB.
     */
    private Integer getStorageInMb() {
        Integer result = 0;

        Decimal value = 0;
        for (ForceeaService.FObjectAsync fObjAsync : this.asyncTemplate.values()) {
            value += this.numIterationsToExecute * fObjAsync.numOfRecords * 2;
        }
        value = value / 1024;
        result = (Integer) value;
        result = (result == 0) ?1 : result;

        return result;
    }

    /**
     * @description Informs if there is any ForceeaService.FObjectAsync object with blank Partition field.
     * @param asyncFObjects The list of ForceeaService.FObjectAsync.
     * @return True, if there is at least one SObject to be deleted with a blank Partition Field.
     */
    private Boolean hasBlankPartitionFieldInAnySObject(List<ForceeaService.FObjectAsync> asyncFObjects) {
        //System.debug('> FObjectAsync.hasBlankPartitionFieldInAnySObject');
        Boolean result = false;

        for (ForceeaService.FObjectAsync asyncFObject : asyncFObjects) {
            //System.debug('partitionFieldName: ' + asyncFObject.partitionFieldName);

            if (String.isBlank(asyncFObject.partitionFieldName)) {
                result = true;
                break;
            }
        }

        return result;
    }

    /**
     * @description Initializes the asynchronous process.
     * @param numJobs The number of jobs.
     */
    private void initializeAsyncProcess(Integer numJobs) {
        this.processId = getProcessId();
        ForceeaAsyncNotification__e platformEvent = new ForceeaAsyncNotification__e(
            Jobs__c = numJobs,
            OperationType__c = 'initialize',
            ProcessId__c = this.processId
        );
        EventBus.publish(platformEvent);
    }

    /**
     * @description Inserts records asynchronously.
     * @return An instance of FObjectAsync.
     */
    public FObjectAsync insertRecords() {
        if (FObjectAsync.anotherProcessIsActive()) {
            return this;
        }

        this.operationType = ForceeaService.OperationType.ASYNC_INSERT;
        initializeAsyncProcess(this.numJobs);

        String userMessage = 'User [' + UserInfo.getName() + '] initiated the async Insert process with ID:' + this.processId +
            ', which needs at least ' + getStorageInMb() + ' MB of data storage to complete.';
        ForceeaService.publishUserMessage(ForceeaService.asyncMessageType.MESSAGE_TYPE_INFO, userMessage);

        this.numJobs = this.getNumberOfJobs();
        enqueueJobsOnInsert();

        return this;
    }

    /**
     * @description Determines if the async process is terminated.
     * @return True, if the async process is terminated.
     */
    public static Boolean processIsTerminated() {
        return FObjectAsync.processIsTerminated;
    }

    /**
     * @description Determines if the async process is valid.
     * @return True, if the async process is valid.
     */
    @TestVisible
    private static Boolean processIsValid() {
        return FObjectAsync.processIsValid;
    }

    /**
     * @description Sets the number of iterations to execute.
     * @param numberOfIterations The number of iterations.
     * @return An instance of FObjectAsync.
     */
    public FObjectAsync setNumberOfIterations(Integer numberOfIterations) {
        this.numIterationsToExecute = numberOfIterations > 0 ? numberOfIterations : 1;
        return this;
    }

    /**
     * @description Sets the number of iterations per batch.
     * @param numberOfMaxIterationsPerBatch The number of iterations per batch.
     * @return An instance of FObjectAsync.
     */
    public FObjectAsync setMaxNumberOfIterationsPerBatch(Integer numberOfMaxIterationsPerBatch) {
        this.numMaxIterationsPerBatch = numberOfMaxIterationsPerBatch > 1 ? numberOfMaxIterationsPerBatch : 1;
        return this;
    }

    /**
     * @description Sets the number of jobs.
     * @param numberOfJobs The number of jobs.
     * @return An instance of FObjectAsync.
     */
    public FObjectAsync setNumberOfJobs(Integer numberOfJobs) {
        this.numJobs = numberOfJobs > 0 ? numberOfJobs : 1;
        return this;
    }

    /**
     * @description Sets the number of jobs.
     * @param jobId The job ID.
     */
    private void setOtherAsyncTransactionDetails(Integer jobId) {
        this.asyncTrans.isBenchmark = this.shouldBenchmark ? true : false;
        this.asyncTrans.jobId = jobId;
        this.asyncTrans.numJobs = this.numJobs;
        this.asyncTrans.partitionFieldValue = this.partitionFieldValue;
        this.asyncTrans.processId = ForceeaService.processId;
        this.asyncTrans.sector = jobId;
        this.asyncTrans.template = this.asyncTemplate;
    }

    /**
     * @description Sets the value of Partition field.
     * @param partitionFieldValue The Partition field value.
     * @return An instance of FObjectAsync.
     */
    public FObjectAsync setPartitionFieldValue(String partitionFieldValue) {
        this.partitionFieldValue = partitionFieldValue.trim();
        return this;
    }

    /**
     * @description Sets the validity of the async process.
     * @param isValid If true, the async process is valid.
     */
    public static void setProcessIsValid(Boolean isValid) {
        FObjectAsync.processIsValid = isValid;
    }

    @TestVisible
    private FObjectAsync shouldBenchmark(Boolean doBenchmarking) {
        this.shouldBenchmark = doBenchmarking;
        return this;
    }

    /**
     * @description Terminates the async process.
     */
    @AuraEnabled
    public static void terminate() {
        ForceeaService.setProcessCustomSetting(true);
        FObjectAsync.processIsTerminated = true;
        ForceeaService.publishUserMessage(ForceeaService.asyncMessageType.MESSAGE_TYPE_INFO,
            'User [' + UserInfo.getName() + '] initiated the async process termination.');
    }

}