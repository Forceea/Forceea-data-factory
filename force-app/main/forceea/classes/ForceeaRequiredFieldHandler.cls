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
 * @description Handles the definitions of require fields.
 */
public with sharing class ForceeaRequiredFieldHandler {

    /* INSTANCE VARIABLES & PROPERTIES */

    private final FObject fObj;

    /* CONSTRUCTORS */

    /**
     * @description The constructor for the class.
     * @param fObj An FObject object.
     */
    public ForceeaRequiredFieldHandler(FObject fObj) {
        this.fObj = fObj;
    }

    /* METHODS */

    /**
     * @description Declares the definitions of required fields for all SObjects except User.
     */
    public void setDefinitionsOfRequiredFieldsForSObjectsExceptUser() {
        for (Forceea.FieldInfo field : FObject.globalFieldsMapBySObject.get(this.fObj.sObjectApiName.toLowerCase()).values()) {
            String fieldApiName = field.fieldApiName;

            if (field.isRequired && (!this.fObj.fields.contains(fieldApiName))) {
                new ForceeaDefinitionTypeHandler(this.fObj).setDefinitionForField(field);

                this.fObj.requiredFieldNames.add(fieldApiName);
                this.fObj.forceeaDebug(ForceeaService.DEBUG, FObject.SYMBOL_SUCCESS + ' ' +
                    ForceeaService.MESSAGE_GENERATED_DEFINITION + ' of [' + fieldApiName + ']');
            }
        }
    }

    /**
     * @description Declares the definitions of required fields for User.
     */
    public void setDefinitionsOfRequiredFieldsForUser() {
        List<String> requiredDefinitions = new List<String>();

        this.fObj.requiredFieldNames.add('Alias');
        requiredDefinitions.add('random type(string) minLength(8) maxLength(8) startWith(upper) include(lower)');

        this.fObj.requiredFieldNames.add('FirstName');
        requiredDefinitions.add('random type(firstName) group(name)');

        this.fObj.requiredFieldNames.add('LastName');
        requiredDefinitions.add('random type(lastName) group(name)');

        this.fObj.requiredFieldNames.add('Username');
        requiredDefinitions.add('random type(email)');

        this.fObj.requiredFieldNames.add('Email');
        requiredDefinitions.add('copy field(Username)');

        this.fObj.requiredFieldNames.add('EmailEncodingKey');
        requiredDefinitions.add('static value(UTF-8)');

        this.fObj.requiredFieldNames.add('TimeZoneSidKey');
        requiredDefinitions.add('static value(GMT)');

        this.fObj.requiredFieldNames.add('LocaleSidKey');
        requiredDefinitions.add('static value(en_US)');

        this.fObj.requiredFieldNames.add('LanguageLocaleKey');
        requiredDefinitions.add('static value(en_US)');

        this.fObj.requiredFieldNames.add('ProfileId');
        requiredDefinitions.add('static lookup(profile) field(name) value(Standard User) source(salesforce)');

        for (Integer counter = 0; counter < this.fObj.requiredFieldNames.size(); counter++) {
            String fieldName = this.fObj.requiredFieldNames.get(counter);

            if (!this.fObj.fields.contains(fieldName)) {
                this.fObj.setDefinition(fieldName, null, true, false, requiredDefinitions.get(counter));
                this.fObj.forceeaDebug(ForceeaService.DEBUG,
                    FObject.SYMBOL_SUCCESS + ' ' + ForceeaService.MESSAGE_GENERATED_DEFINITION +
                    ' of [' + fieldName + ']');
            }
        }
    }

}