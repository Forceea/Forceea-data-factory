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
 * @description Provides definition testing.
 */
@IsTest
public with sharing class ForceeaDefinitionTypeHandler {

    /* INSTANCE VARIABLES & PROPERTIES */

    private Forceea.FieldInfo field { get; set; }
    private final FObject fObj { get; set; }

    /* CONSTRUCTORS */

    /**
     * @description The constructor for the class.
     * @param fObj An FObject object.
     */
    public ForceeaDefinitionTypeHandler(FObject fObj) {
        this.fObj = fObj;
    }

    /* METHODS */

    private Boolean isAccountName() {
        return this.fObj.sObjectApiName == 'Account' && this.field.fieldApiName == 'Name';
    }

    private Boolean isContactFirstName() {
        return this.fObj.sObjectApiName == 'Contact' && this.field.fieldApiName == 'FirstName';
    }

    private Boolean isContactLastName() {
        return this.fObj.sObjectApiName == 'Contact' && this.field.fieldApiName == 'LastName';
    }

    private Boolean isLeadCompany() {
        return this.fObj.sObjectApiName == 'Lead' && this.field.fieldApiName == 'Company';
    }

    private Boolean isLeadFirstName() {
        return this.fObj.sObjectApiName == 'Lead' && this.field.fieldApiName == 'FirstName';
    }

    private Boolean isLeadLastName() {
        return this.fObj.sObjectApiName == 'Lead' && this.field.fieldApiName == 'LastName';
    }

    private Boolean isOpportunityName() {
        return this.fObj.sObjectApiName == 'Opportunity' && this.field.fieldApiName == 'Name';
    }

    private void setDefinitionForAccountName() {
        this.fObj.setDefinition(this.field.fieldName, null, true, false,
            'static value(Company-)');
        this.fObj.setDefinition(this.field.fieldName, null, true, false,
            'serial type(number) from(1) step(1) scale(0)');
    }

    private void setDefinitionForContactFirstName() {
        this.fObj.setDefinition(this.field.fieldName, null, true, false,
            'random type(firstName) group(name)');
    }

    private void setDefinitionForContactLastName() {
        this.fObj.setDefinition(this.field.fieldName, null, true, false,
            'random type(lastName) group(name)');
    }

    private void setDefinitionForDateTypes() {
        switch on this.field.dataType {
            when DATE {
                setDefinitionForTypeDate();
            } when DATETIME {
                setDefinitionForTypeDatetime();
            } when TIME {
                setDefinitionForTypeTime();
            }
        }
    }

    /**
     * @description Sets a field definition based on the field data type and the SObject.
     * @param field The Forceea.FieldInfo object.
     */
    public void setDefinitionForField(Forceea.FieldInfo field) {
        this.field = field;

        if (isAccountName()) {
            setDefinitionForAccountName();
        } else if (isContactFirstName()) {
            setDefinitionForContactFirstName();
        } else if (isContactLastName()) {
            setDefinitionForContactLastName();
        } else if (isLeadCompany()) {
            setDefinitionForLeadCompany();
        } else if (isLeadFirstName()) {
            setDefinitionForLeadFirstName();
        } else if (isLeadLastName()) {
            setDefinitionForLeadLastName();
        } else if (isOpportunityName()) {
            setDefinitionForOppName();
        } else {
            setDefinitionForTypes();
        }
    }

    private void setDefinitionForLeadCompany() {
        this.fObj.setDefinition(this.field.fieldName, null, true, false,
            'static value(Company-)');
        this.fObj.setDefinition(this.field.fieldName, null, true, false,
            'serial type(number) from(1) step(1) scale(0)');
    }

    private void setDefinitionForLeadFirstName() {
        this.fObj.setDefinition(this.field.fieldName, null, true, false,
            'random type(firstName) group(name)');
    }

    private void setDefinitionForLeadLastName() {
        this.fObj.setDefinition(this.field.fieldName, null, true, false,
            'random type(lastName) group(name)');
    }

    private void setDefinitionForNumberTypes() {
        switch on this.field.dataType {
            when INTEGER {
                setDefinitionForTypeInteger();
            } when CURRENCY {
                setDefinitionForTypeCurrency();
            } when DOUBLE {
                setDefinitionForTypeDouble();
            } when PERCENT {
                setDefinitionForTypePercent();
            }
        }
    }

    private void setDefinitionForOppName() {
        this.fObj.setDefinition(this.field.fieldName, null, true, false,
            'static value(Opportunity-)');
        this.fObj.setDefinition(this.field.fieldName, null, true, false,
            'serial type(number) from(1) step(1) scale(0)');
    }

    private void setDefinitionForOtherTypes() {
        switch on this.field.dataType {
            when REFERENCE {
                setDefinitionForTypeReference();
            } when BOOLEAN {
                setDefinitionForTypeBoolean();
            } when EMAIL {
                setDefinitionForTypeEmail();
            } when PHONE {
                setDefinitionForTypePhone();
            } when URL {
                setDefinitionForTypeUrl();
            }
        }
    }

    private void setDefinitionForTextTypes() {
        switch on this.field.dataType {
            when STRING {
                setDefinitionForTypeString();
            } when TEXTAREA {
                setDefinitionForTypeTextArea();
            }
        }
    }

    private void setDefinitionForTypeBoolean() {
        this.fObj.setDefinition(this.field.fieldName, null, true, false,
            'random type(boolean)');
    }

    private void setDefinitionForTypeCurrency() {
        this.fObj.setDefinition(this.field.fieldName, null, true, false,
            'random type(number) from(1000) to(10000) scale(2)');
    }

    private void setDefinitionForTypeDate() {
        Integer thisYear = Date.today().year();
        String fromDate = String.valueOf(thisYear - 1) + '-01-01';
        String toDate = String.valueOf(thisYear + 1) + '-12-31';

        this.fObj.setDefinition(this.field.fieldName, null, true, false,
            'random type(date) from(' + fromDate + ') to(' + toDate + ')');
    }

    private void setDefinitionForTypeDatetime() {
        Integer thisYear = Date.today().year();
        String fromDate = String.valueOf(thisYear - 1) + '-01-01';
        String toDate = String.valueOf(thisYear + 1) + '-12-31';

        this.fObj.setDefinition(this.field.fieldName, null, true, false,
            'random type(datetime) from(' + fromDate + ') to(' + toDate + ')');
    }

    private void setDefinitionForTypeDouble() {
        this.fObj.setDefinition(this.field.fieldName, null, true, false,
            'random type(number) from(1000) to(10000) scale(3)');
    }

    private void setDefinitionForTypeEmail() {
        this.fObj.setDefinition(this.field.fieldName, null, true, false,
            'random type(email)');
    }

    private void setDefinitionForTypeInteger() {
        this.fObj.setDefinition(this.field.fieldName, null, true, false,
            'random type(number) from(1) to(100) scale(0)');
    }

    private void setDefinitionForTypePercent() {
        this.fObj.setDefinition(this.field.fieldName, null, true, false,
            'random type(number) from(0) to(100) scale(2)');
    }

    private void setDefinitionForTypePhone() {
        this.fObj.setDefinition(this.field.fieldName, null, true, false,
            'random type(phone) format(DD dDD dd-DD-DDD)');
    }

    private void setDefinitionForTypeReference() {
        this.fObj.setDefinition(this.field.fieldName, null, true, false,
            'random lookup(' + this.field.parents[0] + ') source(' + ForceeaService.SOURCE_FORCEEA + ')');
    }

    private void setDefinitionForTypeSelection() {
        this.fObj.setDefinition(this.field.fieldName, null, true, false,
            'random type(picklist)');
    }

    private void setDefinitionForTypeString() {
        Integer minlength = (this.field.length < 5) ? this.field.length : 5;
        this.fObj.setDefinition(this.field.fieldName, null, true, false,
            'random type(string) minLength(' + minlength + ') maxLength(' +
            this.field.length + ') startWith(upper) include(lower,upper)');
    }

    private void setDefinitionForTypes() {
        switch on this.field.dataType {
            when INTEGER, CURRENCY, DOUBLE, PERCENT {
                setDefinitionForNumberTypes();
            } when DATE, DATETIME, TIME {
                setDefinitionForDateTypes();
            } when PICKLIST, MULTIPICKLIST, COMBOBOX {
                setDefinitionForTypeSelection();
            } when STRING, TEXTAREA {
                setDefinitionForTextTypes();
            } when REFERENCE, BOOLEAN, EMAIL, PHONE, URL {
                setDefinitionForOtherTypes();
            }
        }
    }

    private void setDefinitionForTypeTextArea() {
        this.fObj.setDefinition(this.field.fieldName, null, true, false,
            'random type(text) minLength(30) maxLength(100)');
    }

    private void setDefinitionForTypeTime() {
        this.fObj.setDefinition(this.field.fieldName, null, true, false,
            'random type(time) from(00:00:00) to(23:59:59)');
    }

    private void setDefinitionForTypeUrl() {
        this.fObj.setDefinition(this.field.fieldName, null, true, false,
            'random type(url)');
    }

}