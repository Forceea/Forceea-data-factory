/*
  Forceea data factory (v2.0.0)
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

public with sharing class ForceeaService {

    /* CONSTANTS */

    private static final String FORCEEA_PROCESS_SETTING_NAME = 'Standard';

    /* ENUMS */

    public enum asyncMessageType {
        MESSAGE_TYPE_ERROR, MESSAGE_TYPE_INFO, MESSAGE_TYPE_WARN, MESSAGE_TYPE_SUCCESS
    }
    public enum OperationType {
        ASYNC_INSERT, ASYNC_DELETE
    }

    /* STATIC VARIABLES & PROPERTIES */

    // the ID of the ForceeaQueueable class
    private static Id classId {
        get {
            if (classId == null) {
                classId = [SELECT Id FROM ApexClass WHERE Name = 'ForceeaQueueable'].Id;
            }
            return classId;
        }
        set;
    }
    // the async Process ID
    public static String processId = '';

    /* CLASSES */

    public class FieldDefinition {
        public String definitionString = '';
        public String fieldApiName = '';
    }

    public class FObjectAsync {
        public List<FieldDefinition> definitions = new List<FieldDefinition>();

        public Integer numOfRecords = 0;
        public String sObjectApiName = '';
        public String partitionFieldName = '';
    }

    public class AsyncTransaction {
        public Map<String, Integer> numFirstRecordsBySObject = new Map<String, Integer>();
        public List<ForceeaService.FObjectAsync> sObjectsToDelete = new List<ForceeaService.FObjectAsync>();
        public Map<String, ForceeaService.FObjectAsync> template = new Map<String, ForceeaService.FObjectAsync>();

        public Integer batchId = 1;
        public Boolean hasPartitioning = true;
        public Boolean isBenchmark = false;
        public Integer jobId = 0;
        public String locality = '';
        public String language = '';
        public Integer numErrors = 0;
        public Integer numJobs = 0;
        public Integer numJobUnitsExecuted = 0; // the iterations that have been inserted in the job
        public Integer numJobUnitsToExecute = 0; // the units that should be executed in the job
        public Integer numTotalJobUnits = 0; // the units that should be executed in the job
        public Integer numMaxUnitsPerBatch = 1; // the max units allowed to be executed per batch
        public Integer numProcessUnitsToExecute = 0; // the total units (iterations/records) that should be executed
        public ForceeaService.OperationType operationType;
        public String partitionFieldValue = '';
        public String processId = '';
        public Long seed = 0;
        public Integer sector = 0;
        public Integer sObjectToDeleteIndex = 0;
        public String sObjectApiName = '';
    }

    /* METHODS */

    /**
     * @description Informs if the async process is terminated or not.
     * @return True, if the async process has been terminated.
     */
    public static Boolean asyncProcessIsTerminated() {
        ForceeaProcess__c setting = ForceeaService.getForceeaProcessSetting();
        if (setting != null) {
            return ForceeaProcess__c.getInstance(FORCEEA_PROCESS_SETTING_NAME).IsTerminated__c;
        }

        return false;
    }

    /**
     * @description Enqueues a transaction for asynchronous processing.
     * @param fObjectTransaction An instance of AsyncTransaction.
     */
    public static void enqueueJob(ForceeaService.AsyncTransaction fObjectTransaction) {
        System.enqueueJob(new ForceeaQueueable(fObjectTransaction));
    }

    /**
     * @description Retrieves the AsyncApexJob records.
     * @return The ForceeaProcess__c custom setting "Standard" record.
     */
    private static ForceeaProcess__c getForceeaProcessSetting() {
        for (ForceeaProcess__c setting : ForceeaProcess__c.getAll().values()) {
            if (setting.Name == FORCEEA_PROCESS_SETTING_NAME) {
                return setting;
            }
        }

        return null;
    }

    /**
     * @description Enqueues a transaction for asynchronous processing.
     * @param messageType An asyncMessageType (MESSAGE_TYPE_ ERROR/INFO/WARN/SUCCESS.
     * @return An HTML string <b><span style="color:{color}>;">{CurrentDatetime}</span></b>.
     */
    public static String getHtmlMessageHeader(ForceeaService.asyncMessageType messageType) {
        String color = '';
        switch on messageType {
            when MESSAGE_TYPE_ERROR {
                color += 'red';
            }
            when MESSAGE_TYPE_INFO {
                color += 'black';
            }
            when MESSAGE_TYPE_SUCCESS {
                color += 'green';
            }
            when MESSAGE_TYPE_WARN {
                color += 'darkorange';
            }
        }

        return '<b><span style="color:' + color + ';">' + Datetime.now() + '</span></b> ';
    }

    /**
     * @description Retrieves the AsyncApexJob records.
     * @return A list of AsyncApexJob records.
     */
    public static List<AsyncApexJob> getJobs() {
        Set<String> statuses = new Set<String>{
            'Preparing', 'Processing', 'Queued'
        };
        return [
            SELECT Id
            FROM AsyncApexJob
            WHERE ApexClassId = :ForceeaService.classId AND Status IN :statuses
        ];
    }

    /**
     * @description Constructs the plural of a countable noun.
     * @param text The countable noun.
     * @param count The number of occurrences.
     * @return The ForceeaProcess__c custom setting "Standard" record.
     */
    public static String getPlural(String text, Integer count) {
        Boolean isOne = (count == 1 || count == -1);
        String result = (isOne) ? text : text + 's';
        return result;
    }

    /**
     * @description Inserts a new record of Process custom setting.
     * @param newValue The new value.
     */
    private static void insertNewProcessCustomSettingRecord(Boolean newValue) {
        insert new ForceeaProcess__c(
            Name = FORCEEA_PROCESS_SETTING_NAME,
            IsTerminated__c = newValue
        );
    }

    /**
     * @description Publishes a platform event with a message to the user.
     * @param messageType The message type.
     * @param message The message.
     */
    public static void publishUserMessage(ForceeaService.asyncMessageType messageType, String message) {
        if (String.isBlank(message)) {
            return;
        }

        ForceeaAsyncNotification__e platformEvent = new ForceeaAsyncNotification__e(
            Message__c = ForceeaService.getHtmlMessageHeader(messageType) + message + '<br/>',
            OperationType__c = 'user-message'
        );
        EventBus.publish(platformEvent);
    }

    /**
     * @description Updates the Forceea Process custom setting field value IsTerminated.
     * @param isTerminated The new value of field IsTerminated.
     */
    public static void setProcessCustomSetting(Boolean isTerminated) {
        Boolean newValue = isTerminated;
        ForceeaProcess__c existingSettingRecord = getForceeaProcessSetting();

        if (existingSettingRecord != null) {
            updateExistingProcessCustomSettingRecord(existingSettingRecord, newValue);
        } else {
            insertNewProcessCustomSettingRecord(newValue);
        }
    }

    /**
     * @description Updates the IsTerminated__c field of an existing Process custom setting record.
     * @param existingRecord The existing record of Process custom setting.
     * @param newValue The value for updating the IsTerminated__c field.
     */
    private static void updateExistingProcessCustomSettingRecord(
        ForceeaProcess__c existingRecord, Boolean newValue) {

        Boolean oldValue = existingRecord.IsTerminated__c;
        if (oldValue == newValue) {
            return;
        }

        try { // new value is different from old
            existingRecord.IsTerminated__c = newValue;
            update existingRecord;
        } catch (Exception ex) {
            ForceeaService.publishUserMessage(ForceeaService.asyncMessageType.MESSAGE_TYPE_WARN,
                'Forceea cannot update the Process custom setting');
        }
    }

}