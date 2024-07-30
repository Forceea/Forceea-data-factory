/*
  Forceea data factory (2.9.1)
  Copyright (C) 2024 Nikos Mitrakis

  This program is free software: you can redistribute it and/or modify it under the terms
  of the GNU General Public License as published by the Free Software Foundation,
  either version 3 of the License, or any later version.

  This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
  without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  See the GNU General Public License for more details.

  You can find a copy of the GNU General Public License at
  https://github.com/nmitrakis/Forceea/blob/master/LICENSE
*/

import {LightningElement} from 'lwc';
import {subscribe} from 'lightning/empApi';
import terminate from '@salesforce/apex/FObjectAsync.terminate';

const channelName = '/event/ForceeaAsyncNotification__e';
const fontSize = '<span style="font-size:1.2em;'
const symbol = '">&#9646;</span>&nbsp;';
const JOB_PENDING = fontSize + 'color:black' + symbol;
const JOB_COMPLETED = fontSize + 'color:green' + symbol;
const JOB_FAILED = fontSize + 'color:red' + symbol;
const JOB_TERMINATED = fontSize + 'color:darkorange' + symbol;

export default class ForceeaDataFactory extends LightningElement {
    isInsert = false;
    jobStatuses = [];
    logMessage = '';
    progress = 0;
    progressFooterMessage = '';
    statusMessage = '';
    userMessage = '';

    _jobHasFailed = false;
    _jobIsCompleted = false;
    _jobIsTerminated= false;
    _jobs = 50;
    _jobUnitsExecuted = [];
    _operationType = '';
    _processId = '';
    _processUnitsExecuted = 0;
    _processUnitsToExecute = 0;
    _totalJobUnits = [];

    constructor() {
        super();
        subscribe(channelName, -1, this.onMessageReceived.bind(this))
            .then(response => {
                this.initializeAll();
            });
    }

    getNumProcessUnitsExecuted() {
        return this._jobUnitsExecuted.reduce((sumOfUnits, units) => sumOfUnits + units, 0);
    }

    handleClick() {
        terminate();
    }

    handleInitialEvent() {
        if (this._processUnitsExecuted === 0) {
            this.jobStatuses.splice(this._jobs, this.jobStatuses.length - this._jobs);
            this.statusMessage = this.jobStatuses.join(' ');
        }
    }

    initializeAll() {
        this.logMessage = '';
        this._operationType = '';
        this.isInsert = false;
        this.initializeJobStatus();
        this.initializeProgress();
    }

    initializeJobStatus() {
        this.jobStatuses = [];
        this._jobUnitsExecuted = [];
        this._totalJobUnits = [];
        this._jobIsCompleted = false;
        this._jobHasFailed = false;
        this._jobIsTerminated = false;

        for (let counter = 0; counter < this._jobs; counter++) {
            this._jobUnitsExecuted[counter] = 0;
            this._totalJobUnits[counter] = 0;
            this.jobStatuses[counter] = JOB_PENDING + (counter + 1);
        }

        this.statusMessage = '';
    }

    initializeProgress() {
        this.progress = 0;
        this._processUnitsExecuted = 0;
        this._processUnitsToExecute = 0;
        this.progressFooterMessage = 'Waiting for data..';
    }

    onMessageReceived = function (response) {
        const eventDetails = response.data.payload;

        const {
            JobId__c: jobId,
            Jobs__c: jobs,
            JobUnitsExecuted__c: jobUnitsExecuted,
            JobIsCompleted__c: jobIsCompleted,
            JobHasFailed__c: jobHasFailed,
            JobIsTerminated__c: jobIsTerminated,
            Message__c: message,
            OperationType__c: operationType,
            ProcessId__c: processId,
            ProcessUnitsToExecute__c: processUnitsToExecute,
            TotalJobUnits__c: totalJobUnits
        } = eventDetails;

        this._jobIsCompleted = jobIsCompleted;
        this._jobHasFailed = jobHasFailed;
        this._jobIsTerminated = jobIsTerminated;
        this._jobs = jobs;

        if (operationType === 'initialize') {
            this._processId = processId;
            this.initializeAll();
            return;
        } else if (operationType === 'user-message') {
            this.updateUserMessage(message);
            return;
        } else if (processId && !this._processId) { // existing processId is empty
            this._processId = processId;
        } else if (processId && this._processId !== processId) { // abort any event from another process
            console.info('this event originated from another process and will be ignored');
            return;
        }

        this.handleInitialEvent();

        this._operationType = operationType;
        this.isInsert = (operationType === 'insert') ? true : false;
        this._jobUnitsExecuted[jobId - 1] = jobUnitsExecuted;
        this._totalJobUnits[jobId - 1] = totalJobUnits;
        this._processUnitsToExecute = processUnitsToExecute;
        this._processUnitsExecuted = this.getNumProcessUnitsExecuted();

        this.updateDisplay(jobId, message);
    }

    updateDisplay(jobId, message) {
        this.updateJobStatusMessage(jobId);
        this.updateLogMessage(message);
        this.updateProgress();
    }

    updateJobStatusMessage(jobId) {
        let thisJobId = jobId - 1;

        if (this._jobIsCompleted) {
            this.jobStatuses[thisJobId] = JOB_COMPLETED + jobId;
        } else if (this._jobHasFailed) {
            this.jobStatuses[thisJobId] = JOB_FAILED + jobId;
        } else if (this._jobIsTerminated) {
            this.jobStatuses[thisJobId] = JOB_TERMINATED + jobId;
        }
        this.statusMessage = this.jobStatuses.join(' ');
    }

    updateLogMessage(message) {
        this.logMessage = message + this.logMessage;
    }

    updateUserMessage(message) {
        this.userMessage = message + this.userMessage;
    }

    updateProgress() {
        if (this.progress > 100) {
            return;
        }

        let formattedProcessUnitsExecuted = this._processUnitsExecuted ? this._processUnitsExecuted.toLocaleString() : 0;
        let formattedProcessUnitsToExecute = this._processUnitsToExecute.toLocaleString();

        switch (this._operationType) {
            case 'insert':
                this.progress = (this._processUnitsExecuted / this._processUnitsToExecute) * 100;
                this.progressFooterMessage = 'Inserted ' + formattedProcessUnitsExecuted +
                    ' of ' + formattedProcessUnitsToExecute + ' iterations';
                break;
            case 'delete':
                this.progressFooterMessage = 'Deleted ' + formattedProcessUnitsExecuted + ' records';
                break;
            case 'update':
                this.progressFooterMessage = 'Updated ' + formattedProcessUnitsExecuted + ' records';
                break;
        }
    }

}