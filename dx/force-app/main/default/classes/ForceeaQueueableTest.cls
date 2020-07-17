/*
  Forceea data factory (v2.1.1)
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
@IsTest
public class ForceeaQueueableTest {

    public class MyException extends Exception {}

    @IsTest
    private static void getLogMessage_isTerminated_expectSuccess() {
        ForceeaService.AsyncTransaction async = new ForceeaService.AsyncTransaction();
        ForceeaQueueable fq = new ForceeaQueueable(async);
        fq.operationType = ForceeaService.OperationType.ASYNC_INSERT;
        fq.isTerminated = true;
        fq.jobId = 1;

        Test.startTest();
        String message = fq.getLogMessage();
        Test.stopTest();

        Boolean result = message.contains('Job[1] is terminated.');
        System.assert(result == true, 'getLogMessage - errors found');
    }

    @IsTest
    private static void getLogMessageOnFailure_delete_expectSuccess() {
        ForceeaService.AsyncTransaction async = new ForceeaService.AsyncTransaction();
        ForceeaQueueable fq = new ForceeaQueueable(async);
        fq.operationType = ForceeaService.OperationType.ASYNC_DELETE;
        fq.jobId = 1;
        fq.batchId = 1;
        fq.sObjectApiName = 'Account';

        Test.startTest();
        fq.errorMessage = 'My Error';
        String message = fq.getLogMessageOnFailure();
        Test.stopTest();

        Boolean result = message.contains('Job[1] Batch[1] found errors deleting records of [Account]: My Error');
        System.assert(result == true, 'getLogMessageOnFailure - errors found');
    }

    @IsTest
    private static void getLogMessageOnFailure_insert_expectSuccess() {
        ForceeaService.AsyncTransaction async = new ForceeaService.AsyncTransaction();
        ForceeaQueueable fq = new ForceeaQueueable(async);
        fq.operationType = ForceeaService.OperationType.ASYNC_INSERT;
        fq.jobId = 1;
        fq.batchId = 1;
        fq.sObjectApiName = 'Account';

        Test.startTest();
        fq.errorMessage = 'My Error';
        String message = fq.getLogMessageOnFailure();
        Test.stopTest();

        Boolean result = message.contains('Job[1] Batch[1] found errors inserting records of [Account]: My Error');
        System.assert(result == true, 'getLogMessageOnFailure - errors found');
    }

    @IsTest
    private static void getMaxNumOfRecordsToDeletePerBatch_withMaxUnitsPerBatch_expectSuccess() {
        ForceeaService.AsyncTransaction async = new ForceeaService.AsyncTransaction();
        ForceeaQueueable fq = new ForceeaQueueable(async);
        fq.numMaxUnitsPerBatch = 10;

        Integer limitGlobalSetupCpuTime = 10;
        Integer limitDmlRows = 10;
        Integer numBatchUnitsExecuted = 100;

        Test.startTest();
        fq.limitGlobalSetupCpuTime = limitGlobalSetupCpuTime;
        fq.limitDmlRows = limitDmlRows;
        fq.numBatchUnitsExecuted = numBatchUnitsExecuted;
        Integer actualResult = fq.getMaxNumOfRecordsToDeletePerBatch();
        Test.stopTest();

        Integer expectedResult = fq.numMaxUnitsPerBatch;
        System.assertEquals(expectedResult, actualResult, 'getMaxNumOfRecordsToDeletePerBatch - errors found');
    }

    @IsTest
    private static void getMaxNumOfRecordsToDeletePerBatch_withoutMaxUnitsPerBatch_expectSuccess() {
        ForceeaService.AsyncTransaction async = new ForceeaService.AsyncTransaction();
        ForceeaQueueable fq = new ForceeaQueueable(async);

        Integer limitGlobalSetupCpuTime = 10;
        Integer limitDmlRows = 10;
        Integer numBatchUnitsExecuted = 100;

        Test.startTest();
        fq.limitGlobalSetupCpuTime = limitGlobalSetupCpuTime;
        fq.limitDmlRows = limitDmlRows;
        fq.numBatchUnitsExecuted = numBatchUnitsExecuted;
        Integer actualResult = fq.getMaxNumOfRecordsToDeletePerBatch();
        Test.stopTest();

        Integer expectedResult = ForceeaQueueable.getMaxRecordsToDeletePerBatch(fq);
        System.assertEquals(expectedResult, actualResult, 'getMaxNumOfRecordsToDeletePerBatch - errors found');
    }

    @IsTest
    private static void handleOnTerminated_isNotTerminated_expectSuccess() {
        ForceeaService.AsyncTransaction async = new ForceeaService.AsyncTransaction();
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
        ForceeaService.AsyncTransaction async = new ForceeaService.AsyncTransaction();
        ForceeaQueueable fq = new ForceeaQueueable(async);

        Test.startTest();
        fq.handleOnTerminated();
        Test.stopTest();

        Boolean isTerminated = fq.isTerminated;
        System.assert(isTerminated == true, 'handleOnTerminated - errors found');
    }

    @IsTest
    private static void publishLogMessageOnFailure_invalidProcess_expectSuccess() {
        ForceeaService.AsyncTransaction async = new ForceeaService.AsyncTransaction();
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
        fq.sObjectApiName = 'Account';
        fq.errorMessage = 'This is an error';
        Test.stopTest();

        Boolean result = fq.publishLogMessageOnFailure()
            .contains('Job[1] Batch[1] found errors inserting records of [Account]: This is an error');
        System.assert(result == true, 'publishLogMessageOnFailure - errors found');
    }

    @IsTest
    private static void shouldTryAgainAfterError_1error_expectSuccess() {
        ForceeaService.AsyncTransaction async = new ForceeaService.AsyncTransaction();
        ForceeaQueueable fq = new ForceeaQueueable(async);

        Integer limitGlobalSetupCpuTime = 10;
        Integer limitDmlRows = 10;
        Integer numBatchUnitsExecuted = 100;

        Test.startTest();
        fq.errorMessage = 'Error message: UNABLE_TO_LOCK_ROW.';
        fq.numErrors = 1;
        fq.limitGlobalSetupCpuTime = limitGlobalSetupCpuTime;
        fq.limitDmlRows = limitDmlRows;
        fq.numBatchUnitsExecuted = numBatchUnitsExecuted;
        Boolean result = fq.shouldTryAgainAfterErrorOnDelete();
        Test.stopTest();

        System.assert(result == true, 'shouldTryAgainAfterError - errors found');
    }

    @IsTest
    private static void shouldTryAgainAfterError_5errors_expectSuccess() {
        ForceeaService.AsyncTransaction async = new ForceeaService.AsyncTransaction();
        ForceeaQueueable fq = new ForceeaQueueable(async);

        Integer limitGlobalSetupCpuTime = 10;
        Integer limitDmlRows = 10;
        Integer numBatchUnitsExecuted = 100;

        Test.startTest();
        fq.errorMessage = 'Error message: UNABLE_TO_LOCK_ROW.';
        fq.numErrors = 5;
        fq.limitGlobalSetupCpuTime = limitGlobalSetupCpuTime;
        fq.limitDmlRows = limitDmlRows;
        fq.numBatchUnitsExecuted = numBatchUnitsExecuted;
        Boolean result = fq.shouldTryAgainAfterErrorOnDelete();
        Test.stopTest();

        System.assert(result == true, 'shouldTryAgainAfterError - errors found');
    }

    @IsTest
    private static void shouldTryAgainAfterError_6errors_expectSuccess() {
        ForceeaService.AsyncTransaction async = new ForceeaService.AsyncTransaction();
        ForceeaQueueable fq = new ForceeaQueueable(async);

        Integer limitGlobalSetupCpuTime = 10;
        Integer limitDmlRows = 10;
        Integer numBatchUnitsExecuted = 100;

        Test.startTest();
        fq.errorMessage = 'Error message: UNABLE_TO_LOCK_ROW.';
        fq.numErrors = 6;
        fq.limitGlobalSetupCpuTime = limitGlobalSetupCpuTime;
        fq.limitDmlRows = limitDmlRows;
        fq.numBatchUnitsExecuted = numBatchUnitsExecuted;
        Boolean result = fq.shouldTryAgainAfterErrorOnDelete();
        Test.stopTest();

        System.assert(result == false, 'shouldTryAgainAfterError - errors found');
    }

}