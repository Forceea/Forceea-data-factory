/*
  Forceea data factory (v2.9.1)
  Copyright (C) 2024 Nikos Mitrakis

  This program is free software: you can redistribute it and/or modify it under the terms
  of the GNU General Public License as published by the Free Software Foundation,
  either version 3 of the License, or any later version.

  This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
  without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  See the GNU General Public License for more details.

  You can find a copy of the GNU General Public License at
  https://github.com/Forceea/Forceea-data-factory/blob/master/LICENSE
*/
@IsTest
@SuppressWarnings('PMD.MethodNamingConventions')
public class ForceeaQueueableTest {

    /* CONSTANTS */

    private static final String ERROR_MESSAGE_UNABLE_TO_LOCK_ROW = 'Error message: UNABLE_TO_LOCK_ROW.';

    /* METHODS */

    @IsTest
    private static void getLogMessage_isTerminated_expectSuccess() {
        Forceea.AsyncTransaction async = new Forceea.AsyncTransaction();
        async.operationType = ForceeaService.OperationType.ASYNC_INSERT;
        async.jobId = 1;
        ForceeaQueueable fq = new ForceeaQueueable(async);
        fq.isTerminated = true;

        Test.startTest();
        String message = fq.getLogMessage();
        Test.stopTest();

        Boolean result = message.contains('Job[1] is terminated.');
        System.assert(result == true, 'getLogMessage - errors found');
    }

    @IsTest
    private static void getLogMessageOnFailure_delete_expectSuccess() {
        Forceea.AsyncTransaction async = new Forceea.AsyncTransaction();
        async.operationType = ForceeaService.OperationType.ASYNC_DELETE;
        async.jobId = 1;
        async.batchId = 1;
        async.sObjectApiName = 'FObjectOne__c';
        ForceeaQueueable fq = new ForceeaQueueable(async);

        Test.startTest();
        fq.errorMessage = 'My Error';
        String message = fq.getLogMessageOnFailure();
        Test.stopTest();

        Boolean result = message.contains('Job[1] Batch[1] found errors deleting records of [FObjectOne__c]: My Error');
        System.assert(result == true, 'getLogMessageOnFailure - errors found');
    }

    @IsTest
    private static void getLogMessageOnFailure_insert_expectSuccess() {
        Forceea.AsyncTransaction async = new Forceea.AsyncTransaction();
        async.operationType = ForceeaService.OperationType.ASYNC_INSERT;
        async.jobId = 1;
        async.batchId = 1;
        async.sObjectApiName = 'FObjectOne__c';
        ForceeaQueueable fq = new ForceeaQueueable(async);

        Test.startTest();
        fq.errorMessage = 'My Error';
        String message = fq.getLogMessageOnFailure();
        Test.stopTest();

        Boolean result = message.contains('Job[1] Batch[1] found errors inserting records of [FObjectOne__c]: My Error');
        System.assert(result == true, 'getLogMessageOnFailure - errors found');
    }

    @IsTest
    private static void getMaxNumOfRecordsToDeletePerBatch_withMaxUnitsPerBatch_expectSuccess() {
        Forceea.AsyncTransaction async = new Forceea.AsyncTransaction();
        ForceeaQueueable fq = new ForceeaQueueable(async);
        fq.numMaxUnitsPerBatch = 10;

        Integer limitGlobalSetupCpuTime = 10;
        Integer limitDmlRows = 10;
        Integer numBatchUnitsExecuted = 100;

        Test.startTest();
        fq.limitGlobalSetupCpuTime = limitGlobalSetupCpuTime;
        fq.limitDmlRows = limitDmlRows;
        fq.numBatchUnitsExecuted = numBatchUnitsExecuted;
        Integer actualResult = fq.getMaxNumOfRecordsToUpdatedOrDeletePerBatch();
        Test.stopTest();

        Integer expectedResult = fq.numMaxUnitsPerBatch;
        System.assertEquals(expectedResult, actualResult, 'getMaxNumOfRecordsToDeletePerBatch - errors found');
    }

    @IsTest
    private static void getMaxNumOfRecordsToDeletePerBatch_withoutMaxUnitsPerBatch_expectSuccess() {
        Forceea.AsyncTransaction async = new Forceea.AsyncTransaction();
        ForceeaQueueable fq = new ForceeaQueueable(async);

        Integer limitGlobalSetupCpuTime = 10;
        Integer limitDmlRows = 10;
        Integer numBatchUnitsExecuted = 100;

        Test.startTest();
        fq.limitGlobalSetupCpuTime = limitGlobalSetupCpuTime;
        fq.limitDmlRows = limitDmlRows;
        fq.numBatchUnitsExecuted = numBatchUnitsExecuted;
        Integer actualResult = fq.getMaxNumOfRecordsToUpdatedOrDeletePerBatch();
        Test.stopTest();

        Integer expectedResult = new ForceeaQueueable(async).getMaxNumOfRecordsToUpdateOrDeletePerBatchFromQueueable(fq);
        System.assertEquals(expectedResult, actualResult, 'getMaxNumOfRecordsToDeletePerBatch - errors found');
    }

    @IsTest
    private static void handleOnTerminated_isNotTerminated_expectSuccess() {
        Forceea.AsyncTransaction async = new Forceea.AsyncTransaction();
        ForceeaQueueable fq = new ForceeaQueueable(async);

        Test.startTest();
        fq.handleOnTerminated();
        Test.stopTest();

        Boolean isTerminated = fq.isTerminated;
        System.assert(isTerminated == false, 'handleOnTerminated - errors found');
    }

    @IsTest
    private static void handleOnTerminated_isTerminated_expectSuccess() {
        FObjectAsync.terminate();
        Forceea.AsyncTransaction async = new Forceea.AsyncTransaction();
        ForceeaQueueable fq = new ForceeaQueueable(async);

        Test.startTest();
        fq.handleOnTerminated();
        Test.stopTest();

        Boolean isTerminated = fq.isTerminated;
        System.assert(isTerminated == true, 'handleOnTerminated - errors found');
    }

    @IsTest
    private static void publishLogMessageOnFailure_invalidProcess_expectSuccess() {
        Forceea.AsyncTransaction async = new Forceea.AsyncTransaction();
        ForceeaQueueable fq = new ForceeaQueueable(async);

        Integer limitGlobalSetupCpuTime = 10;
        Integer limitDmlRows = 10;
        Integer numBatchUnitsExecuted = 100;

        Test.startTest();
        fq.batchId = 1;
        fq.jobId = 1;
        fq.limitGlobalSetupCpuTime = limitGlobalSetupCpuTime;
        fq.limitDmlRows = limitDmlRows;
        fq.numBatchUnitsExecuted = numBatchUnitsExecuted;
        fq.operationType = ForceeaService.OperationType.ASYNC_INSERT;
        fq.sObjectApiName = 'FObjectOne__c';
        fq.errorMessage = 'This is an error';
        Test.stopTest();

        Boolean result = fq.publishLogMessageOnFailure()
            .contains('Job[1] Batch[1] found errors inserting records of [FObjectOne__c]: This is an error');
        System.assert(result == true, 'publishLogMessageOnFailure - errors found');
    }

    @IsTest
    private static void shouldTryAgainAfterErrorOnInsert_1error_expectSuccess() {
        ForceeaQueueable fq = getForceeaQueueable(ForceeaService.OperationType.ASYNC_INSERT);

        Test.startTest();
        fq.errorMessage = ERROR_MESSAGE_UNABLE_TO_LOCK_ROW;
        Boolean result = fq.shouldTryAgainAfterError();
        Test.stopTest();

        Assert.isTrue(result, 'shouldTryAgainAfterError - errors found');
    }

    @IsTest
    private static void shouldTryAgainAfterErrorOnDelete_1error_expectSuccess() {
        ForceeaQueueable fq = getForceeaQueueable(ForceeaService.OperationType.ASYNC_DELETE);

        Test.startTest();
        fq.errorMessage = ERROR_MESSAGE_UNABLE_TO_LOCK_ROW;
        Boolean result = fq.shouldTryAgainAfterError();
        Test.stopTest();

        Assert.isTrue(result, 'shouldTryAgainAfterError - errors found');
    }

    @IsTest
    private static void shouldTryAgainAfterErrorOnUpdate_1error_expectSuccess() {
        ForceeaQueueable fq = getForceeaQueueable(ForceeaService.OperationType.ASYNC_UPDATE);

        Test.startTest();
        fq.errorMessage = ERROR_MESSAGE_UNABLE_TO_LOCK_ROW;
        Boolean result = fq.shouldTryAgainAfterError();
        Test.stopTest();

        Assert.isTrue(result, 'shouldTryAgainAfterError - errors found');
    }

    @IsTest
    private static void shouldTryAgainAfterError_5errors_expectSuccess() {
        ForceeaQueueable fq = getForceeaQueueable(ForceeaService.OperationType.ASYNC_INSERT);

        Test.startTest();
        fq.errorMessage = ERROR_MESSAGE_UNABLE_TO_LOCK_ROW;
        fq.numErrors = 5;
        Boolean result = fq.shouldTryAgainAfterError();
        Test.stopTest();

        Assert.isTrue(result, 'shouldTryAgainAfterError - errors found');
    }

    @IsTest
    private static void shouldTryAgainAfterError_6errors_expectSuccess() {
        ForceeaQueueable fq = getForceeaQueueable(ForceeaService.OperationType.ASYNC_INSERT);

        Test.startTest();
        fq.errorMessage = ERROR_MESSAGE_UNABLE_TO_LOCK_ROW;
        fq.numErrors = 6;
        Boolean result = fq.shouldTryAgainAfterError();
        Test.stopTest();

        Assert.isFalse(result, 'shouldTryAgainAfterError - errors found');
    }

    /* HELPER METHODS */

    private static Boolean getShouldTryAgainAfterError(String errorMessage, ForceeaService.OperationType operationType) {
        Forceea.AsyncTransaction async = new Forceea.AsyncTransaction();
        ForceeaQueueable fq = new ForceeaQueueable(async);

        fq.operationType = operationType;
        fq.errorMessage = errorMessage;
        fq.numErrors = 1;
        fq.limitGlobalSetupCpuTime = 10;
        fq.limitDmlRows = 10;
        fq.numBatchUnitsExecuted = 100;

        return fq.shouldTryAgainAfterError();
    }

    private static ForceeaQueueable getForceeaQueueable(ForceeaService.OperationType operationType) {
        Forceea.AsyncTransaction async = new Forceea.AsyncTransaction();
        ForceeaQueueable result = new ForceeaQueueable(async);

        result.operationType = operationType;
        result.numErrors = 1;
        result.limitGlobalSetupCpuTime = 10;
        result.limitDmlRows = 10;
        result.numBatchUnitsExecuted = 100;

        return result;
    }

}