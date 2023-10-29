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
 * @description Handles debug logs.
 */
public with sharing class ForceeaDebugHandler {

    /* CONSTANTS */

    private static final Integer BAR_LENGTH = 60;
    private static final String BAR_SYMBOL = '=';
    private static final String MESSAGE_WILL_REMOVE_FIELD_DEFINITIONS = 'Will remove all definitions of field';
    private static final String VERSION = '2.9.0';

    /* INSTANCE VARIABLES & PROPERTIES */

    private final FObject fObj { get; set; }

    /* CONSTRUCTORS */

    /**
     * @description The constructor for the class.
     * @param fObj An FObject object.
     */
    public ForceeaDebugHandler(FObject fObj) {
        this.fObj = fObj;
    }

    /* METHODS */

    /**
     * @description Displays a debug log warning message if errors are found.
     * @param errors The number of errors found.
     * @param size The number of records.
     * @param dmlDescription The DML errors description.
     */
    public void displayDebugLogWarningOnDmlErrors(Integer errors, Integer size, String dmlDescription) {
        if (errors == 0) {
            return;
        }

        this.fObj.forceeaDebug(ForceeaService.WARN,
            'Found ' + ForceeaService.getCountable('error', errors) + ' ' + dmlDescription + ' ' +
            ForceeaService.getCountable('record', size) + ' of [' + this.fObj.sObjectApiName + ']');
    }

    /**
     * @description Displays the message "Inserted N standard pricebook entries".
     * @param pricebookEntriesSize The list of standard price book entries.
     */
    public void displayMessageInsertedStandardPriceBookEntries(Integer pricebookEntriesSize) {
        this.fObj.forceeaDebug(ForceeaService.INFO,
            'Inserted ' +
            ForceeaService.getCountable('standard pricebook entry', pricebookEntriesSize) +
            '.');
    }

    /**
     * @description Displays the message MESSAGE_WILL_DELETE_FIELD_DEFINITIONS.
     * @param token The token "SObjectName.FieldName".
     */
    public void displayMessageWillRemoveFieldDefinitions(String token) {
        if (this.fObj.isUpdate) {
            return;
        }

        this.fObj.forceeaDebug(ForceeaService.INFO, MESSAGE_WILL_REMOVE_FIELD_DEFINITIONS + ' [' + token + ']');
    }

    /**
     * @description Displays a separator with a text.
     * @param sObjectApiName The SObject API name.
     * @param text The text.
     * @param templateKey The Template key.
     */
    public static void displaySeparatorOnMethodStart(String sObjectApiName, String text, String templateKey) {
        String key = (String.isNotBlank(templateKey)) ? templateKey + ':' : '';
        String optimizer = (FObject.shouldOptimizeDml) ? 'DMLOpt ' : '';
        String message = ' ' + text + ' [' + key + sObjectApiName + '] ' + optimizer;

        Integer totalBarLength = BAR_LENGTH - message.length();
        totalBarLength = totalBarLength < 2 ? 2 : totalBarLength;

        Integer leftBarLength = Math.max((Integer) totalBarLength / 2, 5);
        Integer rightBarLength = Math.max(totalBarLength - leftBarLength, 5);
        String leftBar = BAR_SYMBOL.repeat(leftBarLength);
        String rightBar = BAR_SYMBOL.repeat(rightBarLength);

        FObject.forceeaDebugStatic(ForceeaService.DEBUG, leftBar + message + rightBar);
    }

    /**
     * @description Displays a separator for a method (insert, update)
     */
    public void displaySeparatorOnMethodFinish() {
        this.fObj.forceeaDebug(ForceeaService.DEBUG, '.'.repeat(BAR_LENGTH));
    }

    /**
     * @description Displays the Forceea version and the User message.
     */
    public void displayInitializationMessage() {
        if (FObject.initializationMessageIsDisplayed) {
            return;
        }

        Boolean messageWasDisplayed = this.fObj.forceeaDebug(ForceeaService.INFO, '=== v' + VERSION + ' ===');
        if (String.isNotBlank(FObject.userMessage) && messageWasDisplayed) {
            this.fObj.forceeaDebug(ForceeaService.INFO, FObject.userMessage);
        }

        FObject.initializationMessageIsDisplayed = messageWasDisplayed;
    }

    /**
     * @description Displays the message "The Forceea method [<identifier>] is DEPRECATED.".
     * @param methodIdentifier The method identifier (name).
     */
    public static void displayMethodIsDeprecatedMessage(String methodIdentifier) {
        FObject.executeDebugLog(LoggingLevel.DEBUG, 'The Forceea method [' + methodIdentifier + '] is DEPRECATED.');
    }

}