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
/**
 * @description Handles the Field Values Matrix.
 */
public with sharing class ForceeaFieldValuesMatrixHandler {

    /* CONSTANTS */

    private static final String BLANK_VALUE = '...';
    private static final String MESSAGE_VALUES = 'Values of';
    private static final String MESSAGE_WILL_DISPLAY_CREATED_FIELD_VALUES = 'Will display the created field values';

    /* INSTANCE VARIABLES & PROPERTIES */

    private FObject fObj { get; set; }

    /* CONSTRUCTORS */

    /**
     * @description The constructor for the class.
     * @param fObj An FObject object.
     */
    public ForceeaFieldValuesMatrixHandler(FObject fObj) {
        this.fObj = fObj;
    }

    /* METHODS */

    /**
     * @description Adds field values to Field Values Matrix.
     * @param fieldApiName The API name of the field.
     * @param fieldValues The list of field values.
     * @param definitionIsFunction If true, the definition is a function-x.
     */
    private void addToFieldValuesMatrix(String fieldApiName, List<String> fieldValues, Boolean definitionIsFunction) {
        Integer fieldPosition = 0;

        for (String field : getFieldsToProcess()) {
            if (field == fieldApiName) {
                updateFieldValuesMatrix(fieldPosition, fieldValues, definitionIsFunction);
                break;
            }
            fieldPosition++;
        }
    }

    /**
     * @description Creates and displays the field values.
     */
    public void createAndDisplayFieldValues() {
        for (String fieldName : getFieldsToProcess()) {
            for (ForceeaDefinition def : this.fObj.definitions) {
                Boolean skipIfValid = (this.fObj.isUpdate) ? !def.isForUpdate : def.isForUpdate;
                if (fieldName != def.fieldApiName || skipIfValid) {
                    continue;
                }

                List<String> fieldValues = new ForceeaGenerator(def).getValues();
                if (FObject.processMustTerminate()) {
                    return;
                }

                addToFieldValuesMatrix(def.fieldApiName, fieldValues, def.isFunction);
                this.fObj.numDefinitionsWithData++;
            }
        }

        displayFieldValues();
    }

    /**
     * @description Displays the Field Value Matrix (FVM) values.
     */
    private void displayFieldValues() {
        this.fObj.forceeaDebug(ForceeaService.DEBUG, MESSAGE_WILL_DISPLAY_CREATED_FIELD_VALUES +
            ' of [' + this.fObj.sObjectApiName + ']');
        Integer counterField = 0;

        for (String fieldName : getFieldsToProcess()) {
            List<String> values = new List<String>();
            for (Integer counterRecord = 0; counterRecord < getNumRecordsToDisplay(); counterRecord++) {
                String value = this.fObj.fieldValuesMatrix.get(counterField).get(counterRecord);
                value = (String.isBlank(value)) ? BLANK_VALUE : value;
                values.add(value);
            }
            counterField++;
            this.fObj.forceeaDebug(ForceeaService.DEBUG, FObject.SYMBOL_SUCCESS + ' ' + MESSAGE_VALUES +
                ' [' + fieldName + ']: ' + String.join(values, ', '));
        }
    }

    /**
     * @description Retrieves the fields to process, based on update.
     * @return An list of strings.
     */
    public List<String> getFieldsToProcess() {
        return (this.fObj.isUpdate) ? this.fObj.fieldsForUpdate : this.fObj.fields;
    }

    /**
     * @description Retrieves the number of records to display.
     * @return An integer value.
     */
    private Integer getNumRecordsToDisplay() {
        return (this.fObj.records <= FObject.numRecordsToDisplay) ? this.fObj.records : FObject.numRecordsToDisplay;
    }

    /**
     * @description Initializes the Field Values Matrix.
     */
    public void initializeFieldValuesMatrix() {
        this.fObj.fieldValuesMatrix.clear();

        for (Integer fieldCounter = 0; fieldCounter < getFieldsToProcess().size(); fieldCounter++) {
            List<String> values = new List<String>();
            for (Integer recordCounter = 0; recordCounter < this.fObj.records; recordCounter++) {
                values.add('');
            }
            this.fObj.fieldValuesMatrix.add(values);
        }
    }

    /**
     * @description Updates the Field Values Matrix for a specific field counter.
     * @param fieldPosition The field position.
     * @param fieldValues The list of field values.
     * @param definitionIsFunction If true, the definition is a function-x.
     */
    private void updateFieldValuesMatrix(Integer fieldPosition, List<String> fieldValues, Boolean definitionIsFunction) {
        if (fieldValues.isEmpty()) {
            return;
        }

        for (Integer recordCounter = 0; recordCounter < this.fObj.records; recordCounter++) {
            if (definitionIsFunction) {
                this.fObj.fieldValuesMatrix[fieldPosition][recordCounter] = fieldValues[recordCounter];
            } else {
                this.fObj.fieldValuesMatrix[fieldPosition][recordCounter] += fieldValues[recordCounter];
            }
        }
    }

}