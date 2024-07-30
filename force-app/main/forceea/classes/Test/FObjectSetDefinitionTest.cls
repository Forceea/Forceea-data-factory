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
public class FObjectSetDefinitionTest {

    private static final String EXCEPTION_CONTINUE = 'continue';

    @IsTest
    private static void isValidForFieldDataType_base64_expectFailure() {
        FObject.setExceptionHandling(EXCEPTION_CONTINUE);
        String fieldApiName = 'Body';

        Map<String, Boolean> validByDefinition = new Map<String, Boolean>();
        validByDefinition.put('copy field(TestPicklistD__c)', true);
        validByDefinition.put('copy field(TestLookup__c) from(FObjectTwo__c.TestText__c)', true);
        validByDefinition.put('function-add field($Test)', false);
        validByDefinition.put('function-convert to(lower)', true);
        validByDefinition.put('mock type(id)', false);
        validByDefinition.put('random lookup(Account) field(FieldOne) except(One,Two,Three) source(forceea)', false);
        validByDefinition.put('random lookup(Account) field(FieldOne) value(One,Two,Three) source(forceea)', false);
        validByDefinition.put('random lookup(Account) source(forceea)', false);
        validByDefinition.put('random lookup(Account) where(Rating = \'Hot\') source(salesforce)', false);
        validByDefinition.put('random type(boolean)', true);
        validByDefinition.put('random type(city) group(one)', true);
        validByDefinition.put('random type(country) group(one)', true);
        validByDefinition.put('random type(date) From(2017-01-01) To(2017-12-31)', true);
        validByDefinition.put('random type(datetime) From(2017-01-01) To(2017-12-31)', true);
        validByDefinition.put('random type(email)', true);
        validByDefinition.put('random type(firstName) Group(one)', true);
        validByDefinition.put('random type(lastName) group(one)', true);
        validByDefinition.put('random type(list) value(1, 2, 3)', true);
        validByDefinition.put('random type(list) value(1.1, 2.2, 3.3)', true);
        validByDefinition.put('random type(list) value(01:01:01, 02:02:02, 3:03:03)', true);
        validByDefinition.put('random type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)', true);
        validByDefinition.put('random type(list) value(2017-01-01, 2017-02-02, 2017-03-03)', true);
        validByDefinition.put('random type(list) value(One, Two, Three)', true);
        validByDefinition.put('random type(number) from(1) to(100) scale(0)', true);
        validByDefinition.put('random type(phone) Format(30 210 dD DD ddD)', true);
        validByDefinition.put('random type(picklist) except(One,Two)', false);
        validByDefinition.put('random type(picklist)', false);
        validByDefinition.put('random type(postalCode) group(one)', true);
        validByDefinition.put('random type(state) group(one)', true);
        validByDefinition.put('random type(street) group(one)', true);
        validByDefinition.put('random type(string) minLength(10) maxLength(30) startWith(lower) include(lower,upper,digit)', true);
        validByDefinition.put('random type(text) minLength(10) maxlength(30)', true);
        validByDefinition.put('random type(time) from(05:15:21) to(17:18:22)', true);
        validByDefinition.put('random type(url)', true);
        validByDefinition.put('serial lookup(Account) mode(cyclical) source(forceea)', false);
        validByDefinition.put('serial type(date) from(2017-01-01) Step(2)', true);
        validByDefinition.put('serial type(datetime) from(2017-01-01 02:02:02) step(2.2)', true);
        validByDefinition.put('serial type(list) value(1, 2, 3) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(1, 2.2, 3) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(1.1, 2.2, 3.3) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(01:01:01, 02:02:02, 03:03:03) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(2017-01-01, 2017-02-02, 2017-03-03) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(One,Two,Three) mode(cyclical)', true);
        validByDefinition.put('serial type(number) from(10.2) step(1.2) scale(2)', true);
        validByDefinition.put('serial type(picklist) except(a) mode(cyclical)', false);
        validByDefinition.put('serial type(picklist) mode(cyclical)', false);
        validByDefinition.put('static lookup(Account) field(FieldOne) value(one) source(forceea)', false);
        validByDefinition.put('static value("")', true);
        validByDefinition.put('static value(01:01:01)', true);
        validByDefinition.put('static value(10)', true);
        validByDefinition.put('static value(10.1)', true);
        validByDefinition.put('static value(01:01:01)', true);
        validByDefinition.put('static value(2017-01-01 01:01:01)', true);
        validByDefinition.put('static value(2017-01-01)', true);
        validByDefinition.put('static value(One)', true);

        Test.startTest();
        Boolean expectedResult = true;
        Boolean actualResult = ForceeaUtilityTest.definitionsAreValid('Attachment', fieldApiName, validByDefinition);
        Test.stopTest();

        System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
    }

    @IsTest
    private static void isValidForFieldDataType_boolean_expectFailure() {
        FObject.setExceptionHandling(EXCEPTION_CONTINUE);
        String fieldApiName = 'TestCheckbox__c';

        Map<String, Boolean> validByDefinition = new Map<String, Boolean>();
        validByDefinition.put('copy field(TestPicklistD__c)', true);
        validByDefinition.put('copy field(TestLookup__c) from(FObjectTwo__c.TestText__c)', true);
        validByDefinition.put('function-add field($Test)', false);
        validByDefinition.put('function-convert to(lower)', false);
        validByDefinition.put('mock type(id)', false);
        validByDefinition.put('random lookup(Account) field(FieldOne) except(One,Two,Three) source(forceea)', false);
        validByDefinition.put('random lookup(Account) field(FieldOne) value(One,Two,Three) source(forceea)', false);
        validByDefinition.put('random lookup(Account) source(forceea)', false);
        validByDefinition.put('random lookup(Account) where(Rating = \'Hot\') source(salesforce)', false);
        validByDefinition.put('random type(boolean)', true);
        validByDefinition.put('random type(city) group(one)', false);
        validByDefinition.put('random type(country) group(one)', false);
        validByDefinition.put('random type(date) From(2017-01-01) To(2017-12-31)', false);
        validByDefinition.put('random type(datetime) From(2017-01-01) To(2017-12-31)', false);
        validByDefinition.put('random type(email)', false);
        validByDefinition.put('random type(firstName) Group(one)', false);
        validByDefinition.put('random type(lastName) group(one)', false);
        validByDefinition.put('random type(list) value(1, 2, 3)', false);
        validByDefinition.put('random type(list) value(1.1, 2.2, 3.3)', false);
        validByDefinition.put('random type(list) value(01:01:01, 02:02:02, 3:03:03)', false);
        validByDefinition.put('random type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)', false);
        validByDefinition.put('random type(list) value(2017-01-01, 2017-02-02, 2017-03-03)', false);
        validByDefinition.put('random type(list) value(One, Two, Three)', true);
        validByDefinition.put('random type(number) from(1) to(100) scale(0)', false);
        validByDefinition.put('random type(phone) Format(30 210 dD DD ddD)', false);
        validByDefinition.put('random type(picklist) except(One,Two)', false);
        validByDefinition.put('random type(picklist)', false);
        validByDefinition.put('random type(postalCode) group(one)', false);
        validByDefinition.put('random type(state) group(one)', false);
        validByDefinition.put('random type(street) group(one)', false);
        validByDefinition.put('random type(string) minLength(10) maxLength(30) startWith(lower) include(lower,upper,digit)', false);
        validByDefinition.put('random type(text) minLength(10) maxlength(30)', false);
        validByDefinition.put('random type(time) from(05:15:21) to(17:18:22)', false);
        validByDefinition.put('random type(url)', false);
        validByDefinition.put('serial lookup(Account) mode(cyclical) source(forceea)', false);
        validByDefinition.put('serial type(date) from(2017-01-01) Step(2)', false);
        validByDefinition.put('serial type(datetime) from(2017-01-01 02:02:02) step(2.2)', false);
        validByDefinition.put('serial type(list) value(1, 2, 3) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(1, 2.2, 3) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(1.1, 2.2, 3.3) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(01:01:01, 02:02:02, 03:03:03) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(2017-01-01, 2017-02-02, 2017-03-03) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(One,Two,Three) mode(cyclical)', true);
        validByDefinition.put('serial type(number) from(10.2) step(1.2) scale(2)', false);
        validByDefinition.put('serial type(picklist) except(a) mode(cyclical)', false);
        validByDefinition.put('serial type(picklist) mode(cyclical)', false);
        validByDefinition.put('static lookup(Account) field(FieldOne) value(one) source(forceea)', false);
        validByDefinition.put('static value("")', false);
        validByDefinition.put('static value(01:01:01)', false);
        validByDefinition.put('static value(10)', false);
        validByDefinition.put('static value(10.1)', false);
        validByDefinition.put('static value(01:01:01)', false);
        validByDefinition.put('static value(2017-01-01 01:01:01)', false);
        validByDefinition.put('static value(2017-01-01)', false);
        validByDefinition.put('static value(One)', true);

        Test.startTest();
        Boolean expectedResult = true;
        Boolean actualResult = ForceeaUtilityTest.definitionsAreValid(FObjectOne__c.SObjectType, fieldApiName, validByDefinition);
        Test.stopTest();

        System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
    }

    @IsTest
    private static void isValidForFieldDataType_combobox_expectFailure() {
        FObject.setExceptionHandling(EXCEPTION_CONTINUE);
        String fieldApiName = 'Subject';

        Map<String, Boolean> validByDefinition = new Map<String, Boolean>();
        validByDefinition.put('copy field(TestPicklistD__c)', true);
        validByDefinition.put('copy field(TestLookup__c) from(FObjectTwo__c.TestText__c)', true);
        validByDefinition.put('function-add field($Test)', false);
        validByDefinition.put('function-convert to(lower)', true);
        validByDefinition.put('mock type(id)', false);
        validByDefinition.put('random lookup(Account) field(FieldOne) except(One,Two,Three) source(forceea)', false);
        validByDefinition.put('random lookup(Account) field(FieldOne) value(One,Two,Three) source(forceea)', false);
        validByDefinition.put('random lookup(Account) source(forceea)', false);
        validByDefinition.put('random lookup(Account) where(Rating = \'Hot\') source(salesforce)', false);
        validByDefinition.put('random type(boolean)', true);
        validByDefinition.put('random type(city) group(one)', true);
        validByDefinition.put('random type(country) group(one)', true);
        validByDefinition.put('random type(date) From(2017-01-01) To(2017-12-31)', true);
        validByDefinition.put('random type(datetime) From(2017-01-01) To(2017-12-31)', true);
        validByDefinition.put('random type(email)', true);
        validByDefinition.put('random type(firstName) Group(one)', true);
        validByDefinition.put('random type(lastName) group(one)', true);
        validByDefinition.put('random type(list) value(1, 2, 3)', true);
        validByDefinition.put('random type(list) value(1.1, 2.2, 3.3)', true);
        validByDefinition.put('random type(list) value(01:01:01, 02:02:02, 3:03:03)', true);
        validByDefinition.put('random type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)', true);
        validByDefinition.put('random type(list) value(2017-01-01, 2017-02-02, 2017-03-03)', true);
        validByDefinition.put('random type(list) value(One, Two, Three)', true);
        validByDefinition.put('random type(number) from(1) to(100) scale(0)', true);
        validByDefinition.put('random type(phone) Format(30 210 dD DD ddD)', true);
        validByDefinition.put('random type(picklist) except(One,Two)', true);
        validByDefinition.put('random type(picklist)', true);
        validByDefinition.put('random type(postalCode) group(one)', true);
        validByDefinition.put('random type(state) group(one)', true);
        validByDefinition.put('random type(street) group(one)', true);
        validByDefinition.put('random type(string) minLength(10) maxLength(30) startWith(lower) include(lower,upper,digit)', true);
        validByDefinition.put('random type(text) minLength(10) maxlength(30)', true);
        validByDefinition.put('random type(time) from(05:15:21) to(17:18:22)', true);
        validByDefinition.put('random type(url)', true);
        validByDefinition.put('serial lookup(Account) mode(cyclical) source(forceea)', false);
        validByDefinition.put('serial type(date) from(2017-01-01) Step(2)', true);
        validByDefinition.put('serial type(datetime) from(2017-01-01 02:02:02) step(2.2)', true);
        validByDefinition.put('serial type(list) value(1, 2, 3) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(1, 2.2, 3) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(1.1, 2.2, 3.3) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(01:01:01, 02:02:02, 03:03:03) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(2017-01-01, 2017-02-02, 2017-03-03) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(One,Two,Three) mode(cyclical)', true);
        validByDefinition.put('serial type(number) from(10.2) step(1.2) scale(2)', true);
        validByDefinition.put('serial type(picklist) except(a) mode(cyclical)', true);
        validByDefinition.put('serial type(picklist) mode(cyclical)', true);
        validByDefinition.put('static lookup(Account) field(FieldOne) value(one) source(forceea)', false);
        validByDefinition.put('static value("")', true);
        validByDefinition.put('static value(01:01:01)', true);
        validByDefinition.put('static value(10)', true);
        validByDefinition.put('static value(10.1)', true);
        validByDefinition.put('static value(01:01:01)', true);
        validByDefinition.put('static value(2017-01-01 01:01:01)', true);
        validByDefinition.put('static value(2017-01-01)', true);
        validByDefinition.put('static value(One)', true);

        Test.startTest();
        Boolean expectedResult = true;
        Boolean actualResult = ForceeaUtilityTest.definitionsAreValid('Task', fieldApiName, validByDefinition);
        Test.stopTest();

        System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
    }

    @IsTest
    private static void isValidForFieldDataType_currency_expectFailure() {
        FObject.setExceptionHandling(EXCEPTION_CONTINUE);
        String fieldApiName = 'TestCurrency__c';

        Map<String, Boolean> validByDefinition = new Map<String, Boolean>();
        validByDefinition.put('copy field(TestPicklistD__c)', true);
        validByDefinition.put('copy field(TestLookup__c) from(FObjectTwo__c.TestText__c)', true);
        validByDefinition.put('function-add field($Test)', true);
        validByDefinition.put('function-convert to(lower)', false);
        validByDefinition.put('mock type(id)', false);
        validByDefinition.put('random lookup(Account) field(FieldOne) except(One,Two,Three) source(forceea)', false);
        validByDefinition.put('random lookup(Account) field(FieldOne) value(One,Two,Three) source(forceea)', false);
        validByDefinition.put('random lookup(Account) source(forceea)', false);
        validByDefinition.put('random lookup(Account) where(Rating = \'Hot\') source(salesforce)', false);
        validByDefinition.put('random type(boolean)', false);
        validByDefinition.put('random type(city) group(one)', false);
        validByDefinition.put('random type(country) group(one)', false);
        validByDefinition.put('random type(date) From(2017-01-01) To(2017-12-31)', false);
        validByDefinition.put('random type(datetime) From(2017-01-01) To(2017-12-31)', false);
        validByDefinition.put('random type(email)', false);
        validByDefinition.put('random type(firstName) Group(one)', false);
        validByDefinition.put('random type(lastName) group(one)', false);
        validByDefinition.put('random type(list) value(1, 2, 3)', true);
        validByDefinition.put('random type(list) value(1.1, 2.2, 3.3)', true);
        validByDefinition.put('random type(list) value(01:01:01, 02:02:02, 3:03:03)', false);
        validByDefinition.put('random type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)', false);
        validByDefinition.put('random type(list) value(2017-01-01, 2017-02-02, 2017-03-03)', false);
        validByDefinition.put('random type(list) value(One, Two, Three)', false);
        validByDefinition.put('random type(number) from(1) to(100) scale(0)', true);
        validByDefinition.put('random type(phone) Format(30 210 dD DD ddD)', false);
        validByDefinition.put('random type(picklist) except(One,Two)', false);
        validByDefinition.put('random type(picklist)', false);
        validByDefinition.put('random type(postalCode) group(one)', false);
        validByDefinition.put('random type(state) group(one)', false);
        validByDefinition.put('random type(street) group(one)', false);
        validByDefinition.put('random type(string) minLength(10) maxLength(30) startWith(lower) include(lower,upper,digit)', false);
        validByDefinition.put('random type(text) minLength(10) maxlength(30)', false);
        validByDefinition.put('random type(time) from(05:15:21) to(17:18:22)', false);
        validByDefinition.put('random type(url)', false);
        validByDefinition.put('serial lookup(Account) mode(cyclical) source(forceea)', false);
        validByDefinition.put('serial type(date) from(2017-01-01) Step(2)', false);
        validByDefinition.put('serial type(datetime) from(2017-01-01 02:02:02) step(2.2)', false);
        validByDefinition.put('serial type(list) value(1, 2, 3) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(1, 2.2, 3) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(1.1, 2.2, 3.3) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(01:01:01, 02:02:02, 03:03:03) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(2017-01-01, 2017-02-02, 2017-03-03) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(One,Two,Three) mode(cyclical)', false);
        validByDefinition.put('serial type(number) from(10.2) step(1.2) scale(2)', true);
        validByDefinition.put('serial type(picklist) except(a) mode(cyclical)', false);
        validByDefinition.put('serial type(picklist) mode(cyclical)', false);
        validByDefinition.put('static lookup(Account) field(FieldOne) value(one) source(forceea)', false);
        validByDefinition.put('static value("")', true);
        validByDefinition.put('static value(01:01:01)', false);
        validByDefinition.put('static value(10)', true);
        validByDefinition.put('static value(10.1)', true);
        validByDefinition.put('static value(01:01:01)', false);
        validByDefinition.put('static value(2017-01-01 01:01:01)', false);
        validByDefinition.put('static value(2017-01-01)', false);
        validByDefinition.put('static value(One)', false);

        Test.startTest();
        Boolean expectedResult = true;
        Boolean actualResult = ForceeaUtilityTest.definitionsAreValid('FObjectOne__c', fieldApiName, validByDefinition);
        Test.stopTest();

        System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
    }

    @IsTest
    private static void isValidForFieldDataType_date_expectFailure() {
        FObject.setExceptionHandling(EXCEPTION_CONTINUE);
        String fieldApiName = 'TestDate__c';

        Map<String, Boolean> validByDefinition = new Map<String, Boolean>();
        validByDefinition.put('copy field(TestPicklistD__c)', true);
        validByDefinition.put('copy field(TestLookup__c) from(FObjectTwo__c.TestText__c)', true);
        validByDefinition.put('function-add field($Test)', true);
        validByDefinition.put('function-convert to(lower)', false);
        validByDefinition.put('mock type(id)', false);
        validByDefinition.put('random lookup(Account) field(FieldOne) except(One,Two,Three) source(forceea)', false);
        validByDefinition.put('random lookup(Account) field(FieldOne) value(One,Two,Three) source(forceea)', false);
        validByDefinition.put('random lookup(Account) source(forceea)', false);
        validByDefinition.put('random lookup(Account) where(Rating = \'Hot\') source(salesforce)', false);
        validByDefinition.put('random type(boolean)', false);
        validByDefinition.put('random type(city) group(one)', false);
        validByDefinition.put('random type(country) group(one)', false);
        validByDefinition.put('random type(date) From(2017-01-01) To(2017-12-31)', true);
        validByDefinition.put('random type(datetime) From(2017-01-01) To(2017-12-31)', false);
        validByDefinition.put('random type(email)', false);
        validByDefinition.put('random type(firstName) Group(one)', false);
        validByDefinition.put('random type(lastName) group(one)', false);
        validByDefinition.put('random type(list) value(1, 2, 3)', false);
        validByDefinition.put('random type(list) value(1.1, 2.2, 3.3)', false);
        validByDefinition.put('random type(list) value(01:01:01, 02:02:02, 3:03:03)', false);
        validByDefinition.put('random type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)', true);
        validByDefinition.put('random type(list) value(2017-01-01, 2017-02-02, 2017-03-03)', true);
        validByDefinition.put('random type(list) value(One, Two, Three)', false);
        validByDefinition.put('random type(number) from(1) to(100) scale(0)', false);
        validByDefinition.put('random type(phone) Format(30 210 dD DD ddD)', false);
        validByDefinition.put('random type(picklist) except(One,Two)', false);
        validByDefinition.put('random type(picklist)', false);
        validByDefinition.put('random type(postalCode) group(one)', false);
        validByDefinition.put('random type(state) group(one)', false);
        validByDefinition.put('random type(street) group(one)', false);
        validByDefinition.put('random type(string) minLength(10) maxLength(30) startWith(lower) include(lower,upper,digit)', false);
        validByDefinition.put('random type(text) minLength(10) maxlength(30)', false);
        validByDefinition.put('random type(time) from(05:15:21) to(17:18:22)', false);
        validByDefinition.put('random type(url)', false);
        validByDefinition.put('serial lookup(Account) mode(cyclical) source(forceea)', false);
        validByDefinition.put('serial type(date) from(2017-01-01) Step(2)', true);
        validByDefinition.put('serial type(datetime) from(2017-01-01 02:02:02) step(2.2)', true);
        validByDefinition.put('serial type(list) value(1, 2, 3) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(1, 2.2, 3) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(1.1, 2.2, 3.3) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(01:01:01, 02:02:02, 03:03:03) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(2017-01-01, 2017-02-02, 2017-03-03) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(One,Two,Three) mode(cyclical)', false);
        validByDefinition.put('serial type(number) from(10.2) step(1.2) scale(2)', false);
        validByDefinition.put('serial type(picklist) except(a) mode(cyclical)', false);
        validByDefinition.put('serial type(picklist) mode(cyclical)', false);
        validByDefinition.put('static lookup(Account) field(FieldOne) value(one) source(forceea)', false);
        validByDefinition.put('static value("")', true);
        validByDefinition.put('static value(01:01:01)', false);
        validByDefinition.put('static value(10)', false);
        validByDefinition.put('static value(10.1)', false);
        validByDefinition.put('static value(01:01:01)', false);
        validByDefinition.put('static value(2017-01-01 01:01:01)', true);
        validByDefinition.put('static value(2017-01-01)', true);
        validByDefinition.put('static value(One)', false);

        Test.startTest();
        Boolean expectedResult = true;
        Boolean actualResult = ForceeaUtilityTest.definitionsAreValid('FObjectOne__c', fieldApiName, validByDefinition);
        Test.stopTest();

        System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
    }

    @IsTest
    private static void isValidForFieldDataType_datetime_expectFailure() {
        FObject.setExceptionHandling(EXCEPTION_CONTINUE);
        String fieldApiName = 'TestDatetime__c';

        Map<String, Boolean> validByDefinition = new Map<String, Boolean>();
        validByDefinition.put('copy field(TestPicklistD__c)', true);
        validByDefinition.put('copy field(TestLookup__c) from(FObjectTwo__c.TestText__c)', true);
        validByDefinition.put('function-add field($Test)', true);
        validByDefinition.put('function-convert to(lower)', false);
        validByDefinition.put('mock type(id)', false);
        validByDefinition.put('random lookup(Account) field(FieldOne) except(One,Two,Three) source(forceea)', false);
        validByDefinition.put('random lookup(Account) field(FieldOne) value(One,Two,Three) source(forceea)', false);
        validByDefinition.put('random lookup(Account) source(forceea)', false);
        validByDefinition.put('random lookup(Account) where(Rating = \'Hot\') source(salesforce)', false);
        validByDefinition.put('random type(boolean)', false);
        validByDefinition.put('random type(city) group(one)', false);
        validByDefinition.put('random type(country) group(one)', false);
        validByDefinition.put('random type(date) From(2017-01-01) To(2017-12-31)', true);
        validByDefinition.put('random type(datetime) From(2017-01-01) To(2017-12-31)', true);
        validByDefinition.put('random type(email)', false);
        validByDefinition.put('random type(firstName) Group(one)', false);
        validByDefinition.put('random type(lastName) group(one)', false);
        validByDefinition.put('random type(list) value(1, 2, 3)', false);
        validByDefinition.put('random type(list) value(1.1, 2.2, 3.3)', false);
        validByDefinition.put('random type(list) value(01:01:01, 02:02:02, 3:03:03)', false);
        validByDefinition.put('random type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)', true);
        validByDefinition.put('random type(list) value(2017-01-01, 2017-02-02, 2017-03-03)', false);
        validByDefinition.put('random type(list) value(One, Two, Three)', false);
        validByDefinition.put('random type(number) from(1) to(100) scale(0)', false);
        validByDefinition.put('random type(phone) Format(30 210 dD DD ddD)', false);
        validByDefinition.put('random type(picklist) except(One,Two)', false);
        validByDefinition.put('random type(picklist)', false);
        validByDefinition.put('random type(postalCode) group(one)', false);
        validByDefinition.put('random type(state) group(one)', false);
        validByDefinition.put('random type(street) group(one)', false);
        validByDefinition.put('random type(string) minLength(10) maxLength(30) startWith(lower) include(lower,upper,digit)', false);
        validByDefinition.put('random type(text) minLength(10) maxlength(30)', false);
        validByDefinition.put('random type(time) from(05:15:21) to(17:18:22)', false);
        validByDefinition.put('random type(url)', false);
        validByDefinition.put('serial lookup(Account) mode(cyclical) source(forceea)', false);
        validByDefinition.put('serial type(date) from(2017-01-01) Step(2)', false);
        validByDefinition.put('serial type(datetime) from(2017-01-01 02:02:02) step(2.2)', true);
        validByDefinition.put('serial type(list) value(1, 2, 3) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(1, 2.2, 3) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(1.1, 2.2, 3.3) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(01:01:01, 02:02:02, 03:03:03) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(2017-01-01, 2017-02-02, 2017-03-03) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(One,Two,Three) mode(cyclical)', false);
        validByDefinition.put('serial type(number) from(10.2) step(1.2) scale(2)', false);
        validByDefinition.put('serial type(picklist) except(a) mode(cyclical)', false);
        validByDefinition.put('serial type(picklist) mode(cyclical)', false);
        validByDefinition.put('static lookup(Account) field(FieldOne) value(one) source(forceea)', false);
        validByDefinition.put('static value("")', true);
        validByDefinition.put('static value(01:01:01)', false);
        validByDefinition.put('static value(10)', false);
        validByDefinition.put('static value(10.1)', false);
        validByDefinition.put('static value(01:01:01)', false);
        validByDefinition.put('static value(2017-01-01 01:01:01)', true);
        validByDefinition.put('static value(2017-01-01)', false);
        validByDefinition.put('static value(One)', false);

        Test.startTest();
        Boolean expectedResult = true;
        Boolean actualResult = ForceeaUtilityTest.definitionsAreValid('FObjectOne__c', fieldApiName, validByDefinition);
        Test.stopTest();

        System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
    }

    @IsTest
    private static void isValidForFieldDataType_decimal_expectFailure() {
        FObject.setExceptionHandling(EXCEPTION_CONTINUE);
        String fieldApiName = 'TestDecimal__c';

        Map<String, Boolean> validByDefinition = new Map<String, Boolean>();
        validByDefinition.put('copy field(TestPicklistD__c)', true);
        validByDefinition.put('copy field(TestLookup__c) from(FObjectTwo__c.TestText__c)', true);
        validByDefinition.put('function-add field($Test)', true);
        validByDefinition.put('function-convert to(lower)', false);
        validByDefinition.put('mock type(id)', false);
        validByDefinition.put('random lookup(Account) field(FieldOne) except(One,Two,Three) source(forceea)', false);
        validByDefinition.put('random lookup(Account) field(FieldOne) value(One,Two,Three) source(forceea)', false);
        validByDefinition.put('random lookup(Account) source(forceea)', false);
        validByDefinition.put('random lookup(Account) where(Rating = \'Hot\') source(salesforce)', false);
        validByDefinition.put('random type(boolean)', false);
        validByDefinition.put('random type(city) group(one)', false);
        validByDefinition.put('random type(country) group(one)', false);
        validByDefinition.put('random type(date) From(2017-01-01) To(2017-12-31)', false);
        validByDefinition.put('random type(datetime) From(2017-01-01) To(2017-12-31)', false);
        validByDefinition.put('random type(email)', false);
        validByDefinition.put('random type(firstName) Group(one)', false);
        validByDefinition.put('random type(lastName) group(one)', false);
        validByDefinition.put('random type(list) value(1, 2, 3)', true);
        validByDefinition.put('random type(list) value(1.1, 2.2, 3.3)', true);
        validByDefinition.put('random type(list) value(01:01:01, 02:02:02, 3:03:03)', false);
        validByDefinition.put('random type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)', false);
        validByDefinition.put('random type(list) value(2017-01-01, 2017-02-02, 2017-03-03)', false);
        validByDefinition.put('random type(list) value(One, Two, Three)', false);
        validByDefinition.put('random type(number) from(1) to(100) scale(0)', true);
        validByDefinition.put('random type(phone) Format(30 210 dD DD ddD)', false);
        validByDefinition.put('random type(picklist) except(One,Two)', false);
        validByDefinition.put('random type(picklist)', false);
        validByDefinition.put('random type(postalCode) group(one)', false);
        validByDefinition.put('random type(state) group(one)', false);
        validByDefinition.put('random type(street) group(one)', false);
        validByDefinition.put('random type(string) minLength(10) maxLength(30) startWith(lower) include(lower,upper,digit)', false);
        validByDefinition.put('random type(text) minLength(10) maxlength(30)', false);
        validByDefinition.put('random type(time) from(05:15:21) to(17:18:22)', false);
        validByDefinition.put('random type(url)', false);
        validByDefinition.put('serial lookup(Account) mode(cyclical) source(forceea)', false);
        validByDefinition.put('serial type(date) from(2017-01-01) Step(2)', false);
        validByDefinition.put('serial type(datetime) from(2017-01-01 02:02:02) step(2.2)', false);
        validByDefinition.put('serial type(list) value(1, 2, 3) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(1, 2.2, 3) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(1.1, 2.2, 3.3) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(01:01:01, 02:02:02, 03:03:03) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(2017-01-01, 2017-02-02, 2017-03-03) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(One,Two,Three) mode(cyclical)', false);
        validByDefinition.put('serial type(number) from(10.2) step(1.2) scale(2)', true);
        validByDefinition.put('serial type(picklist) except(a) mode(cyclical)', false);
        validByDefinition.put('serial type(picklist) mode(cyclical)', false);
        validByDefinition.put('static lookup(Account) field(FieldOne) value(one) source(forceea)', false);
        validByDefinition.put('static value("")', true);
        validByDefinition.put('static value(01:01:01)', false);
        validByDefinition.put('static value(10)', true);
        validByDefinition.put('static value(10.1)', true);
        validByDefinition.put('static value(01:01:01)', false);
        validByDefinition.put('static value(2017-01-01 01:01:01)', false);
        validByDefinition.put('static value(2017-01-01)', false);
        validByDefinition.put('static value(One)', false);

        Test.startTest();
        Boolean expectedResult = true;
        Boolean actualResult = ForceeaUtilityTest.definitionsAreValid('FObjectOne__c', fieldApiName, validByDefinition);
        Test.stopTest();

        System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
    }

    @IsTest
    private static void isValidForFieldDataType_email_expectFailure() {
        FObject.setExceptionHandling(EXCEPTION_CONTINUE);
        String fieldApiName = 'TestEmail__c';

        Map<String, Boolean> validByDefinition = new Map<String, Boolean>();
        validByDefinition.put('copy field(TestPicklistD__c)', true);
        validByDefinition.put('copy field(TestLookup__c) from(FObjectTwo__c.TestText__c)', true);
        validByDefinition.put('function-add field($Test)', false);
        validByDefinition.put('function-convert to(lower)', true);
        validByDefinition.put('mock type(id)', false);
        validByDefinition.put('random lookup(Account) field(FieldOne) except(One,Two,Three) source(forceea)', false);
        validByDefinition.put('random lookup(Account) field(FieldOne) value(One,Two,Three) source(forceea)', false);
        validByDefinition.put('random lookup(Account) source(forceea)', false);
        validByDefinition.put('random lookup(Account) where(Rating = \'Hot\') source(salesforce)', false);
        validByDefinition.put('random type(boolean)', false);
        validByDefinition.put('random type(city) group(one)', false);
        validByDefinition.put('random type(country) group(one)', false);
        validByDefinition.put('random type(date) From(2017-01-01) To(2017-12-31)', false);
        validByDefinition.put('random type(datetime) From(2017-01-01) To(2017-12-31)', false);
        validByDefinition.put('random type(email)', true);
        validByDefinition.put('random type(firstName) Group(one)', false);
        validByDefinition.put('random type(lastName) group(one)', false);
        validByDefinition.put('random type(list) value(1, 2, 3)', true);
        validByDefinition.put('random type(list) value(1.1, 2.2, 3.3)', false);
        validByDefinition.put('random type(list) value(01:01:01, 02:02:02, 3:03:03)', false);
        validByDefinition.put('random type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)', false);
        validByDefinition.put('random type(list) value(2017-01-01, 2017-02-02, 2017-03-03)', false);
        validByDefinition.put('random type(list) value(One, Two, Three)', true);
        validByDefinition.put('random type(number) from(1) to(100) scale(0)', true);
        validByDefinition.put('random type(phone) Format(30 210 dD DD ddD)', false);
        validByDefinition.put('random type(picklist) except(One,Two)', false);
        validByDefinition.put('random type(picklist)', false);
        validByDefinition.put('random type(postalCode) group(one)', false);
        validByDefinition.put('random type(state) group(one)', false);
        validByDefinition.put('random type(street) group(one)', false);
        validByDefinition.put('random type(string) minLength(10) maxLength(30) startWith(lower) include(lower,upper,digit)', true);
        validByDefinition.put('random type(text) minLength(10) maxlength(30)', false);
        validByDefinition.put('random type(time) from(05:15:21) to(17:18:22)', false);
        validByDefinition.put('random type(url)', false);
        validByDefinition.put('serial lookup(Account) mode(cyclical) source(forceea)', false);
        validByDefinition.put('serial type(date) from(2017-01-01) Step(2)', false);
        validByDefinition.put('serial type(datetime) from(2017-01-01 02:02:02) step(2.2)', false);
        validByDefinition.put('serial type(list) value(1, 2, 3) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(1, 2.2, 3) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(1.1, 2.2, 3.3) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(01:01:01, 02:02:02, 03:03:03) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(2017-01-01, 2017-02-02, 2017-03-03) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(One,Two,Three) mode(cyclical)', true);
        validByDefinition.put('serial type(number) from(10.2) step(1.2) scale(2)', true);
        validByDefinition.put('serial type(picklist) except(a) mode(cyclical)', false);
        validByDefinition.put('serial type(picklist) mode(cyclical)', false);
        validByDefinition.put('static lookup(Account) field(FieldOne) value(one) source(forceea)', false);
        validByDefinition.put('static value("")', true);
        validByDefinition.put('static value(01:01:01)', false);
        validByDefinition.put('static value(10)', true);
        validByDefinition.put('static value(10.1)', false);
        validByDefinition.put('static value(01:01:01)', false);
        validByDefinition.put('static value(2017-01-01 01:01:01)', false);
        validByDefinition.put('static value(2017-01-01)', false);
        validByDefinition.put('static value(One)', true);

        Test.startTest();
        Boolean expectedResult = true;
        Boolean actualResult = ForceeaUtilityTest.definitionsAreValid('FObjectOne__c', fieldApiName, validByDefinition);
        Test.stopTest();

        System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
    }

    @IsTest
    private static void isValidForFieldDataType_id_expectFailure() {
        FObject.setExceptionHandling(EXCEPTION_CONTINUE);
        String fieldApiName = 'Id';

        Map<String, Boolean> validByDefinition = new Map<String, Boolean>();
        validByDefinition.put('copy field(TestPicklistD__c)', false);
        validByDefinition.put('copy field(TestLookup__c) from(FObjectTwo__c.TestText__c)', false);
        validByDefinition.put('function-add field($Test)', false);
        validByDefinition.put('function-convert to(lower)', false);
        validByDefinition.put('mock type(id)', true);
        validByDefinition.put('random lookup(Account) field(FieldOne) except(One,Two,Three) source(forceea)', false);
        validByDefinition.put('random lookup(Account) field(FieldOne) value(One,Two,Three) source(forceea)', false);
        validByDefinition.put('random lookup(Account) source(forceea)', false);
        validByDefinition.put('random lookup(Account) where(Rating = \'Hot\') source(salesforce)', false);
        validByDefinition.put('random type(boolean)', false);
        validByDefinition.put('random type(city) group(one)', false);
        validByDefinition.put('random type(country) group(one)', false);
        validByDefinition.put('random type(date) From(2017-01-01) To(2017-12-31)', false);
        validByDefinition.put('random type(datetime) From(2017-01-01) To(2017-12-31)', false);
        validByDefinition.put('random type(email)', false);
        validByDefinition.put('random type(firstName) Group(one)', false);
        validByDefinition.put('random type(lastName) group(one)', false);
        validByDefinition.put('random type(list) value(1, 2, 3)', false);
        validByDefinition.put('random type(list) value(1.1, 2.2, 3.3)', false);
        validByDefinition.put('random type(list) value(01:01:01, 02:02:02, 3:03:03)', false);
        validByDefinition.put('random type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)', false);
        validByDefinition.put('random type(list) value(2017-01-01, 2017-02-02, 2017-03-03)', false);
        validByDefinition.put('random type(list) value(One, Two, Three)', false);
        validByDefinition.put('random type(number) from(1) to(100) scale(0)', false);
        validByDefinition.put('random type(phone) Format(30 210 dD DD ddD)', false);
        validByDefinition.put('random type(picklist) except(One,Two)', false);
        validByDefinition.put('random type(picklist)', false);
        validByDefinition.put('random type(postalCode) group(one)', false);
        validByDefinition.put('random type(state) group(one)', false);
        validByDefinition.put('random type(street) group(one)', false);
        validByDefinition.put('random type(string) minLength(10) maxLength(30) startWith(lower) include(lower,upper,digit)', false);
        validByDefinition.put('random type(text) minLength(10) maxlength(30)', false);
        validByDefinition.put('random type(time) from(05:15:21) to(17:18:22)', false);
        validByDefinition.put('random type(url)', false);
        validByDefinition.put('serial lookup(Account) mode(cyclical) source(forceea)', false);
        validByDefinition.put('serial type(date) from(2017-01-01) Step(2)', false);
        validByDefinition.put('serial type(datetime) from(2017-01-01 02:02:02) step(2.2)', false);
        validByDefinition.put('serial type(list) value(1, 2, 3) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(1, 2.2, 3) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(1.1, 2.2, 3.3) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(01:01:01, 02:02:02, 03:03:03) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(2017-01-01, 2017-02-02, 2017-03-03) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(One,Two,Three) mode(cyclical)', false);
        validByDefinition.put('serial type(number) from(10.2) step(1.2) scale(2)', false);
        validByDefinition.put('serial type(picklist) except(a) mode(cyclical)', false);
        validByDefinition.put('serial type(picklist) mode(cyclical)', false);
        validByDefinition.put('static lookup(Account) field(FieldOne) value(one) source(forceea)', false);
        validByDefinition.put('static value("")', false);
        validByDefinition.put('static value(01:01:01)', false);
        validByDefinition.put('static value(10)', false);
        validByDefinition.put('static value(10.1)', false);
        validByDefinition.put('static value(01:01:01)', false);
        validByDefinition.put('static value(2017-01-01 01:01:01)', false);
        validByDefinition.put('static value(2017-01-01)', false);
        validByDefinition.put('static value(One)', false);

        Test.startTest();
        Boolean expectedResult = true;
        Boolean actualResult = ForceeaUtilityTest.definitionsAreValid('FObjectOne__c', fieldApiName, validByDefinition);
        Test.stopTest();

        System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
    }

    @IsTest
    private static void isValidForFieldDataType_integer_expectFailure() {
        FObject.setExceptionHandling(EXCEPTION_CONTINUE);
        String fieldApiName = 'TestInteger__c';

        Map<String, Boolean> validByDefinition = new Map<String, Boolean>();
        validByDefinition.put('copy field(TestPicklistD__c)', true);
        validByDefinition.put('copy field(TestLookup__c) from(FObjectTwo__c.TestText__c)', true);
        validByDefinition.put('function-add field($Test)', true);
        validByDefinition.put('function-convert to(lower)', false);
        validByDefinition.put('mock type(id)', false);
        validByDefinition.put('random lookup(Account) field(FieldOne) except(One,Two,Three) source(forceea)', false);
        validByDefinition.put('random lookup(Account) field(FieldOne) value(One,Two,Three) source(forceea)', false);
        validByDefinition.put('random lookup(Account) source(forceea)', false);
        validByDefinition.put('random lookup(Account) where(Rating = \'Hot\') source(salesforce)', false);
        validByDefinition.put('random type(boolean)', false);
        validByDefinition.put('random type(city) group(one)', false);
        validByDefinition.put('random type(country) group(one)', false);
        validByDefinition.put('random type(date) From(2017-01-01) To(2017-12-31)', false);
        validByDefinition.put('random type(datetime) From(2017-01-01) To(2017-12-31)', false);
        validByDefinition.put('random type(email)', false);
        validByDefinition.put('random type(firstName) Group(one)', false);
        validByDefinition.put('random type(lastName) group(one)', false);
        validByDefinition.put('random type(list) value(1, 2, 3)', true);
        validByDefinition.put('random type(list) value(1.1, 2.2, 3.3)', true);
        validByDefinition.put('random type(list) value(01:01:01, 02:02:02, 3:03:03)', false);
        validByDefinition.put('random type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)', false);
        validByDefinition.put('random type(list) value(2017-01-01, 2017-02-02, 2017-03-03)', false);
        validByDefinition.put('random type(list) value(One, Two, Three)', false);
        validByDefinition.put('random type(number) from(1) to(100) scale(0)', true);
        validByDefinition.put('random type(phone) Format(30 210 dD DD ddD)', false);
        validByDefinition.put('random type(picklist) except(One,Two)', false);
        validByDefinition.put('random type(picklist)', false);
        validByDefinition.put('random type(postalCode) group(one)', false);
        validByDefinition.put('random type(state) group(one)', false);
        validByDefinition.put('random type(street) group(one)', false);
        validByDefinition.put('random type(string) minLength(10) maxLength(30) startWith(lower) include(lower,upper,digit)', false);
        validByDefinition.put('random type(text) minLength(10) maxlength(30)', false);
        validByDefinition.put('random type(time) from(05:15:21) to(17:18:22)', false);
        validByDefinition.put('random type(url)', false);
        validByDefinition.put('serial lookup(Account) mode(cyclical) source(forceea)', false);
        validByDefinition.put('serial type(date) from(2017-01-01) Step(2)', false);
        validByDefinition.put('serial type(datetime) from(2017-01-01 02:02:02) step(2.2)', false);
        validByDefinition.put('serial type(list) value(1, 2, 3) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(1, 2.2, 3) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(1.1, 2.2, 3.3) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(01:01:01, 02:02:02, 03:03:03) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(2017-01-01, 2017-02-02, 2017-03-03) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(One,Two,Three) mode(cyclical)', false);
        validByDefinition.put('serial type(number) from(10.2) step(1.2) scale(2)', true);
        validByDefinition.put('serial type(picklist) except(a) mode(cyclical)', false);
        validByDefinition.put('serial type(picklist) mode(cyclical)', false);
        validByDefinition.put('static lookup(Account) field(FieldOne) value(one) source(forceea)', false);
        validByDefinition.put('static value("")', true);
        validByDefinition.put('static value(01:01:01)', false);
        validByDefinition.put('static value(10)', true);
        validByDefinition.put('static value(10.1)', true);
        validByDefinition.put('static value(01:01:01)', false);
        validByDefinition.put('static value(2017-01-01 01:01:01)', false);
        validByDefinition.put('static value(2017-01-01)', false);
        validByDefinition.put('static value(One)', false);

        Test.startTest();
        Boolean expectedResult = true;
        Boolean actualResult = ForceeaUtilityTest.definitionsAreValid('FObjectOne__c', fieldApiName, validByDefinition);
        Test.stopTest();

        System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
    }

    @IsTest
    private static void isValidForFieldDataType_multiPicklist_expectFailure() {
        FObject.setExceptionHandling(EXCEPTION_CONTINUE);
        String fieldApiName = 'TestMultiPicklistA__c';

        Map<String, Boolean> validByDefinition = new Map<String, Boolean>();
        validByDefinition.put('copy field(TestPicklistD__c)', true);
        validByDefinition.put('copy field(TestLookup__c) from(FObjectTwo__c.TestText__c)', true);
        validByDefinition.put('function-add field($Test)', false);
        validByDefinition.put('function-convert to(lower)', true);
        validByDefinition.put('mock type(id)', false);
        validByDefinition.put('random lookup(Account) field(FieldOne) except(One,Two,Three) source(forceea)', false);
        validByDefinition.put('random lookup(Account) field(FieldOne) value(One,Two,Three) source(forceea)', false);
        validByDefinition.put('random lookup(Account) source(forceea)', false);
        validByDefinition.put('random lookup(Account) where(Rating = \'Hot\') source(salesforce)', false);
        validByDefinition.put('random type(boolean)', true);
        validByDefinition.put('random type(city) group(one)', true);
        validByDefinition.put('random type(country) group(one)', true);
        validByDefinition.put('random type(date) From(2017-01-01) To(2017-12-31)', true);
        validByDefinition.put('random type(datetime) From(2017-01-01) To(2017-12-31)', true);
        validByDefinition.put('random type(email)', true);
        validByDefinition.put('random type(firstName) Group(one)', true);
        validByDefinition.put('random type(lastName) group(one)', true);
        validByDefinition.put('random type(list) value(1, 2, 3)', true);
        validByDefinition.put('random type(list) value(1.1, 2.2, 3.3)', true);
        validByDefinition.put('random type(list) value(01:01:01, 02:02:02, 3:03:03)', true);
        validByDefinition.put('random type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)', true);
        validByDefinition.put('random type(list) value(2017-01-01, 2017-02-02, 2017-03-03)', true);
        validByDefinition.put('random type(list) value(One, Two, Three)', true);
        validByDefinition.put('random type(number) from(1) to(100) scale(0)', true);
        validByDefinition.put('random type(phone) Format(30 210 dD DD ddD)', true);
        validByDefinition.put('random type(picklist) except(One,Two)', true);
        validByDefinition.put('random type(picklist)', true);
        validByDefinition.put('random type(postalCode) group(one)', true);
        validByDefinition.put('random type(state) group(one)', true);
        validByDefinition.put('random type(street) group(one)', true);
        validByDefinition.put('random type(string) minLength(10) maxLength(30) startWith(lower) include(lower,upper,digit)', true);
        validByDefinition.put('random type(text) minLength(10) maxlength(30)', true);
        validByDefinition.put('random type(time) from(05:15:21) to(17:18:22)', true);
        validByDefinition.put('random type(url)', true);
        validByDefinition.put('serial lookup(Account) mode(cyclical) source(forceea)', false);
        validByDefinition.put('serial type(date) from(2017-01-01) Step(2)', true);
        validByDefinition.put('serial type(datetime) from(2017-01-01 02:02:02) step(2.2)', true);
        validByDefinition.put('serial type(list) value(1, 2, 3) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(1, 2.2, 3) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(1.1, 2.2, 3.3) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(01:01:01, 02:02:02, 03:03:03) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(2017-01-01, 2017-02-02, 2017-03-03) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(One,Two,Three) mode(cyclical)', true);
        validByDefinition.put('serial type(number) from(10.2) step(1.2) scale(2)', true);
        validByDefinition.put('serial type(picklist) except(a) mode(cyclical)', true);
        validByDefinition.put('serial type(picklist) mode(cyclical)', true);
        validByDefinition.put('static lookup(Account) field(FieldOne) value(one) source(forceea)', false);
        validByDefinition.put('static value("")', true);
        validByDefinition.put('static value(01:01:01)', true);
        validByDefinition.put('static value(10)', true);
        validByDefinition.put('static value(10.1)', true);
        validByDefinition.put('static value(01:01:01)', true);
        validByDefinition.put('static value(2017-01-01 01:01:01)', true);
        validByDefinition.put('static value(2017-01-01)', true);
        validByDefinition.put('static value(One)', true);

        Test.startTest();
        Boolean expectedResult = true;
        Boolean actualResult = ForceeaUtilityTest.definitionsAreValid('FObjectOne__c', fieldApiName, validByDefinition);
        Test.stopTest();

        System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
    }

    @IsTest
    private static void isValidForFieldDataType_percent_expectFailure() {
        FObject.setExceptionHandling(EXCEPTION_CONTINUE);
        String fieldApiName = 'TestPercent__c';

        Map<String, Boolean> validByDefinition = new Map<String, Boolean>();
        validByDefinition.put('copy field(TestPicklistD__c)', true);
        validByDefinition.put('copy field(TestLookup__c) from(FObjectTwo__c.TestText__c)', true);
        validByDefinition.put('function-add field($Test)', true);
        validByDefinition.put('function-convert to(lower)', false);
        validByDefinition.put('mock type(id)', false);
        validByDefinition.put('random lookup(Account) field(FieldOne) except(One,Two,Three) source(forceea)', false);
        validByDefinition.put('random lookup(Account) field(FieldOne) value(One,Two,Three) source(forceea)', false);
        validByDefinition.put('random lookup(Account) source(forceea)', false);
        validByDefinition.put('random lookup(Account) where(Rating = \'Hot\') source(salesforce)', false);
        validByDefinition.put('random type(boolean)', false);
        validByDefinition.put('random type(city) group(one)', false);
        validByDefinition.put('random type(country) group(one)', false);
        validByDefinition.put('random type(date) From(2017-01-01) To(2017-12-31)', false);
        validByDefinition.put('random type(datetime) From(2017-01-01) To(2017-12-31)', false);
        validByDefinition.put('random type(email)', false);
        validByDefinition.put('random type(firstName) Group(one)', false);
        validByDefinition.put('random type(lastName) group(one)', false);
        validByDefinition.put('random type(list) value(1, 2, 3)', true);
        validByDefinition.put('random type(list) value(1.1, 2.2, 3.3)', true);
        validByDefinition.put('random type(list) value(01:01:01, 02:02:02, 3:03:03)', false);
        validByDefinition.put('random type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)', false);
        validByDefinition.put('random type(list) value(2017-01-01, 2017-02-02, 2017-03-03)', false);
        validByDefinition.put('random type(list) value(One, Two, Three)', false);
        validByDefinition.put('random type(number) from(1) to(100) scale(0)', true);
        validByDefinition.put('random type(phone) Format(30 210 dD DD ddD)', false);
        validByDefinition.put('random type(picklist) except(One,Two)', false);
        validByDefinition.put('random type(picklist)', false);
        validByDefinition.put('random type(postalCode) group(one)', false);
        validByDefinition.put('random type(state) group(one)', false);
        validByDefinition.put('random type(street) group(one)', false);
        validByDefinition.put('random type(string) minLength(10) maxLength(30) startWith(lower) include(lower,upper,digit)', false);
        validByDefinition.put('random type(text) minLength(10) maxlength(30)', false);
        validByDefinition.put('random type(time) from(05:15:21) to(17:18:22)', false);
        validByDefinition.put('random type(url)', false);
        validByDefinition.put('serial lookup(Account) mode(cyclical) source(forceea)', false);
        validByDefinition.put('serial type(date) from(2017-01-01) Step(2)', false);
        validByDefinition.put('serial type(datetime) from(2017-01-01 02:02:02) step(2.2)', false);
        validByDefinition.put('serial type(list) value(1, 2, 3) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(1, 2.2, 3) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(1.1, 2.2, 3.3) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(01:01:01, 02:02:02, 03:03:03) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(2017-01-01, 2017-02-02, 2017-03-03) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(One,Two,Three) mode(cyclical)', false);
        validByDefinition.put('serial type(number) from(10.2) step(1.2) scale(2)', true);
        validByDefinition.put('serial type(picklist) except(a) mode(cyclical)', false);
        validByDefinition.put('serial type(picklist) mode(cyclical)', false);
        validByDefinition.put('static lookup(Account) field(FieldOne) value(one) source(forceea)', false);
        validByDefinition.put('static value("")', true);
        validByDefinition.put('static value(01:01:01)', false);
        validByDefinition.put('static value(10)', true);
        validByDefinition.put('static value(10.1)', true);
        validByDefinition.put('static value(01:01:01)', false);
        validByDefinition.put('static value(2017-01-01 01:01:01)', false);
        validByDefinition.put('static value(2017-01-01)', false);
        validByDefinition.put('static value(One)', false);

        Test.startTest();
        Boolean expectedResult = true;
        Boolean actualResult = ForceeaUtilityTest.definitionsAreValid('FObjectOne__c', fieldApiName, validByDefinition);
        Test.stopTest();

        System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
    }

    @IsTest
    private static void isValidForFieldDataType_picklist_expectFailure() {
        FObject.setExceptionHandling(EXCEPTION_CONTINUE);
        String fieldApiName = 'TestPicklistC__c';

        Map<String, Boolean> validByDefinition = new Map<String, Boolean>();
        validByDefinition.put('copy field(TestPicklistD__c)', true);
        validByDefinition.put('copy field(TestLookup__c) from(FObjectTwo__c.TestText__c)', true);
        validByDefinition.put('function-add field($Test)', false);
        validByDefinition.put('function-convert to(lower)', true);
        validByDefinition.put('mock type(id)', false);
        validByDefinition.put('random lookup(Account) field(FieldOne) except(One,Two,Three) source(forceea)', false);
        validByDefinition.put('random lookup(Account) field(FieldOne) value(One,Two,Three) source(forceea)', false);
        validByDefinition.put('random lookup(Account) source(forceea)', false);
        validByDefinition.put('random lookup(Account) where(Rating = \'Hot\') source(salesforce)', false);
        validByDefinition.put('random type(boolean)', true);
        validByDefinition.put('random type(city) group(one)', true);
        validByDefinition.put('random type(country) group(one)', true);
        validByDefinition.put('random type(date) From(2017-01-01) To(2017-12-31)', true);
        validByDefinition.put('random type(datetime) From(2017-01-01) To(2017-12-31)', true);
        validByDefinition.put('random type(email)', true);
        validByDefinition.put('random type(firstName) Group(one)', true);
        validByDefinition.put('random type(lastName) group(one)', true);
        validByDefinition.put('random type(list) value(1, 2, 3)', true);
        validByDefinition.put('random type(list) value(1.1, 2.2, 3.3)', true);
        validByDefinition.put('random type(list) value(01:01:01, 02:02:02, 3:03:03)', true);
        validByDefinition.put('random type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)', true);
        validByDefinition.put('random type(list) value(2017-01-01, 2017-02-02, 2017-03-03)', true);
        validByDefinition.put('random type(list) value(One, Two, Three)', true);
        validByDefinition.put('random type(number) from(1) to(100) scale(0)', true);
        validByDefinition.put('random type(phone) Format(30 210 dD DD ddD)', true);
        validByDefinition.put('random type(picklist) except(One,Two)', true);
        validByDefinition.put('random type(picklist)', true);
        validByDefinition.put('random type(postalCode) group(one)', true);
        validByDefinition.put('random type(state) group(one)', true);
        validByDefinition.put('random type(street) group(one)', true);
        validByDefinition.put('random type(string) minLength(10) maxLength(30) startWith(lower) include(lower,upper,digit)', true);
        validByDefinition.put('random type(text) minLength(10) maxlength(30)', true);
        validByDefinition.put('random type(time) from(05:15:21) to(17:18:22)', true);
        validByDefinition.put('random type(url)', true);
        validByDefinition.put('serial lookup(Account) mode(cyclical) source(forceea)', false);
        validByDefinition.put('serial type(date) from(2017-01-01) Step(2)', true);
        validByDefinition.put('serial type(datetime) from(2017-01-01 02:02:02) step(2.2)', true);
        validByDefinition.put('serial type(list) value(1, 2, 3) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(1, 2.2, 3) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(1.1, 2.2, 3.3) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(01:01:01, 02:02:02, 03:03:03) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(2017-01-01, 2017-02-02, 2017-03-03) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(One,Two,Three) mode(cyclical)', true);
        validByDefinition.put('serial type(number) from(10.2) step(1.2) scale(2)', true);
        validByDefinition.put('serial type(picklist) except(a) mode(cyclical)', true);
        validByDefinition.put('serial type(picklist) mode(cyclical)', true);
        validByDefinition.put('static lookup(Account) field(FieldOne) value(one) source(forceea)', false);
        validByDefinition.put('static value("")', true);
        validByDefinition.put('static value(01:01:01)', true);
        validByDefinition.put('static value(10)', true);
        validByDefinition.put('static value(10.1)', true);
        validByDefinition.put('static value(01:01:01)', true);
        validByDefinition.put('static value(2017-01-01 01:01:01)', true);
        validByDefinition.put('static value(2017-01-01)', true);
        validByDefinition.put('static value(One)', true);

        Test.startTest();
        Boolean expectedResult = true;
        Boolean actualResult = ForceeaUtilityTest.definitionsAreValid('FObjectOne__c', fieldApiName, validByDefinition);
        Test.stopTest();

        System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
    }

    @IsTest
    private static void isValidForFieldDataType_phone_expectFailure() {
        FObject.setExceptionHandling(EXCEPTION_CONTINUE);
        String fieldApiName = 'TestPhone__c';

        Map<String, Boolean> validByDefinition = new Map<String, Boolean>();
        validByDefinition.put('copy field(TestPicklistD__c)', true);
        validByDefinition.put('copy field(TestLookup__c) from(FObjectTwo__c.TestText__c)', true);
        validByDefinition.put('function-add field($Test)', false);
        validByDefinition.put('function-convert to(lower)', false);
        validByDefinition.put('mock type(id)', false);
        validByDefinition.put('random lookup(Account) field(FieldOne) except(One,Two,Three) source(forceea)', false);
        validByDefinition.put('random lookup(Account) field(FieldOne) value(One,Two,Three) source(forceea)', false);
        validByDefinition.put('random lookup(Account) source(forceea)', false);
        validByDefinition.put('random lookup(Account) where(Rating = \'Hot\') source(salesforce)', false);
        validByDefinition.put('random type(boolean)', false);
        validByDefinition.put('random type(city) group(one)', false);
        validByDefinition.put('random type(country) group(one)', false);
        validByDefinition.put('random type(date) From(2017-01-01) To(2017-12-31)', false);
        validByDefinition.put('random type(datetime) From(2017-01-01) To(2017-12-31)', false);
        validByDefinition.put('random type(email)', false);
        validByDefinition.put('random type(firstName) Group(one)', false);
        validByDefinition.put('random type(lastName) group(one)', false);
        validByDefinition.put('random type(list) value(1, 2, 3)', true);
        validByDefinition.put('random type(list) value(1.1, 2.2, 3.3)', false);
        validByDefinition.put('random type(list) value(01:01:01, 02:02:02, 3:03:03)', false);
        validByDefinition.put('random type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)', false);
        validByDefinition.put('random type(list) value(2017-01-01, 2017-02-02, 2017-03-03)', false);
        validByDefinition.put('random type(list) value(One, Two, Three)', true);
        validByDefinition.put('random type(number) from(1) to(100) scale(0)', true);
        validByDefinition.put('random type(phone) Format(30 210 dD DD ddD)', true);
        validByDefinition.put('random type(picklist) except(One,Two)', false);
        validByDefinition.put('random type(picklist)', false);
        validByDefinition.put('random type(postalCode) group(one)', false);
        validByDefinition.put('random type(state) group(one)', false);
        validByDefinition.put('random type(street) group(one)', false);
        validByDefinition.put('random type(string) minLength(10) maxLength(30) startWith(lower) include(lower,upper,digit)', false);
        validByDefinition.put('random type(text) minLength(10) maxlength(30)', false);
        validByDefinition.put('random type(time) from(05:15:21) to(17:18:22)', false);
        validByDefinition.put('random type(url)', false);
        validByDefinition.put('serial lookup(Account) mode(cyclical) source(forceea)', false);
        validByDefinition.put('serial type(date) from(2017-01-01) Step(2)', false);
        validByDefinition.put('serial type(datetime) from(2017-01-01 02:02:02) step(2.2)', false);
        validByDefinition.put('serial type(list) value(1, 2, 3) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(1, 2.2, 3) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(1.1, 2.2, 3.3) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(01:01:01, 02:02:02, 03:03:03) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(2017-01-01, 2017-02-02, 2017-03-03) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(One,Two,Three) mode(cyclical)', true);
        validByDefinition.put('serial type(number) from(10.2) step(1.2) scale(2)', true);
        validByDefinition.put('serial type(picklist) except(a) mode(cyclical)', false);
        validByDefinition.put('serial type(picklist) mode(cyclical)', false);
        validByDefinition.put('static lookup(Account) field(FieldOne) value(one) source(forceea)', false);
        validByDefinition.put('static value("")', true);
        validByDefinition.put('static value(01:01:01)', false);
        validByDefinition.put('static value(10)', true);
        validByDefinition.put('static value(10.1)', false);
        validByDefinition.put('static value(01:01:01)', false);
        validByDefinition.put('static value(2017-01-01 01:01:01)', false);
        validByDefinition.put('static value(2017-01-01)', false);
        validByDefinition.put('static value(One)', true);

        Test.startTest();
        Boolean expectedResult = true;
        Boolean actualResult = ForceeaUtilityTest.definitionsAreValid('FObjectOne__c', fieldApiName, validByDefinition);
        Test.stopTest();

        System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
    }

    @IsTest
    private static void isValidForFieldDataType_recordType_expectFailure() {
        FObject.setExceptionHandling(EXCEPTION_CONTINUE);
        String fieldApiName = 'RecordTypeId';

        Map<String, Boolean> validByDefinition = new Map<String, Boolean>();
        validByDefinition.put('copy field(TestPicklistD__c)', true);
        validByDefinition.put('copy field(TestLookup__c) from(FObjectTwo__c.TestText__c)', true);
        validByDefinition.put('function-add field($Test)', false);
        validByDefinition.put('function-convert to(lower)', false);
        validByDefinition.put('mock type(id)', false);
        validByDefinition.put('random lookup(Account) field(FieldOne) except(One,Two,Three) source(forceea)', false);
        validByDefinition.put('random lookup(Account) field(FieldOne) value(One,Two,Three) source(forceea)', false);
        validByDefinition.put('random lookup(Account) source(forceea)', false);
        validByDefinition.put('random lookup(Account) where(Rating = \'Hot\') source(salesforce)', false);
        validByDefinition.put('random type(boolean)', false);
        validByDefinition.put('random type(city) group(one)', false);
        validByDefinition.put('random type(country) group(one)', false);
        validByDefinition.put('random type(date) From(2017-01-01) To(2017-12-31)', false);
        validByDefinition.put('random type(datetime) From(2017-01-01) To(2017-12-31)', false);
        validByDefinition.put('random type(email)', false);
        validByDefinition.put('random type(firstName) Group(one)', false);
        validByDefinition.put('random type(lastName) group(one)', false);
        validByDefinition.put('random type(list) value(1, 2, 3)', false);
        validByDefinition.put('random type(list) value(1.1, 2.2, 3.3)', false);
        validByDefinition.put('random type(list) value(01:01:01, 02:02:02, 3:03:03)', false);
        validByDefinition.put('random type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)', false);
        validByDefinition.put('random type(list) value(2017-01-01, 2017-02-02, 2017-03-03)', false);
        validByDefinition.put('random type(list) value(One, Two, Three)', true);
        validByDefinition.put('random type(number) from(1) to(100) scale(0)', false);
        validByDefinition.put('random type(phone) Format(30 210 dD DD ddD)', false);
        validByDefinition.put('random type(picklist) except(One,Two)', true);
        validByDefinition.put('random type(picklist)', true);
        validByDefinition.put('random type(postalCode) group(one)', false);
        validByDefinition.put('random type(state) group(one)', false);
        validByDefinition.put('random type(street) group(one)', false);
        validByDefinition.put('random type(string) minLength(10) maxLength(30) startWith(lower) include(lower,upper,digit)', false);
        validByDefinition.put('random type(text) minLength(10) maxlength(30)', false);
        validByDefinition.put('random type(time) from(05:15:21) to(17:18:22)', false);
        validByDefinition.put('random type(url)', false);
        validByDefinition.put('serial lookup(Account) mode(cyclical) source(forceea)', false);
        validByDefinition.put('serial type(date) from(2017-01-01) Step(2)', false);
        validByDefinition.put('serial type(datetime) from(2017-01-01 02:02:02) step(2.2)', false);
        validByDefinition.put('serial type(list) value(1, 2, 3) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(1, 2.2, 3) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(1.1, 2.2, 3.3) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(01:01:01, 02:02:02, 03:03:03) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(2017-01-01, 2017-02-02, 2017-03-03) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(One,Two,Three) mode(cyclical)', true);
        validByDefinition.put('serial type(number) from(10.2) step(1.2) scale(2)', false);
        validByDefinition.put('serial type(picklist) except(a) mode(cyclical)', true);
        validByDefinition.put('serial type(picklist) mode(cyclical)', true);
        validByDefinition.put('static lookup(Account) field(FieldOne) value(one) source(forceea)', false);
        validByDefinition.put('static value("")', false);
        validByDefinition.put('static value(01:01:01)', false);
        validByDefinition.put('static value(10)', false);
        validByDefinition.put('static value(10.1)', false);
        validByDefinition.put('static value(01:01:01)', false);
        validByDefinition.put('static value(2017-01-01 01:01:01)', false);
        validByDefinition.put('static value(2017-01-01)', false);
        validByDefinition.put('static value(One)', true);

        Test.startTest();
        Boolean expectedResult = true;
        Boolean actualResult = ForceeaUtilityTest.definitionsAreValid('FObjectOne__c', fieldApiName, validByDefinition);
        Test.stopTest();

        System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
    }

    @IsTest
    private static void isValidForFieldDataType_reference_expectFailure() {
        FObject.setExceptionHandling(EXCEPTION_CONTINUE);
        String fieldApiName = 'TestLookup__c';

        Map<String, Boolean> validByDefinition = new Map<String, Boolean>();
        validByDefinition.put('copy field(TestPicklistD__c)', true);
        validByDefinition.put('copy field(TestLookup__c) from(FObjectTwo__c.TestText__c)', true);
        validByDefinition.put('function-add field($Test)', false);
        validByDefinition.put('function-convert to(lower)', false);
        validByDefinition.put('mock type(id)', false);
        validByDefinition.put('random lookup(Account) field(FieldOne) except(One,Two,Three) source(forceea)', true);
        validByDefinition.put('random lookup(Account) field(FieldOne) value(One,Two,Three) source(forceea)', true);
        validByDefinition.put('random lookup(Account) source(forceea)', true);
        validByDefinition.put('random lookup(Account) where(Rating = \'Hot\') source(salesforce)', true);
        validByDefinition.put('random type(boolean)', false);
        validByDefinition.put('random type(city) group(one)', false);
        validByDefinition.put('random type(country) group(one)', false);
        validByDefinition.put('random type(date) From(2017-01-01) To(2017-12-31)', false);
        validByDefinition.put('random type(datetime) From(2017-01-01) To(2017-12-31)', false);
        validByDefinition.put('random type(email)', false);
        validByDefinition.put('random type(firstName) Group(one)', false);
        validByDefinition.put('random type(lastName) group(one)', false);
        validByDefinition.put('random type(list) value(1, 2, 3)', false);
        validByDefinition.put('random type(list) value(1.1, 2.2, 3.3)', false);
        validByDefinition.put('random type(list) value(01:01:01, 02:02:02, 3:03:03)', false);
        validByDefinition.put('random type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)', false);
        validByDefinition.put('random type(list) value(2017-01-01, 2017-02-02, 2017-03-03)', false);
        validByDefinition.put('random type(list) value(One, Two, Three)', false);
        validByDefinition.put('random type(number) from(1) to(100) scale(0)', false);
        validByDefinition.put('random type(phone) Format(30 210 dD DD ddD)', false);
        validByDefinition.put('random type(picklist) except(One,Two)', false);
        validByDefinition.put('random type(picklist)', false);
        validByDefinition.put('random type(postalCode) group(one)', false);
        validByDefinition.put('random type(state) group(one)', false);
        validByDefinition.put('random type(street) group(one)', false);
        validByDefinition.put('random type(string) minLength(10) maxLength(30) startWith(lower) include(lower,upper,digit)', false);
        validByDefinition.put('random type(text) minLength(10) maxlength(30)', false);
        validByDefinition.put('random type(time) from(05:15:21) to(17:18:22)', false);
        validByDefinition.put('random type(url)', false);
        validByDefinition.put('serial lookup(Account) mode(cyclical) source(forceea)', true);
        validByDefinition.put('serial type(date) from(2017-01-01) Step(2)', false);
        validByDefinition.put('serial type(datetime) from(2017-01-01 02:02:02) step(2.2)', false);
        validByDefinition.put('serial type(list) value(1, 2, 3) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(1, 2.2, 3) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(1.1, 2.2, 3.3) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(01:01:01, 02:02:02, 03:03:03) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(2017-01-01, 2017-02-02, 2017-03-03) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(One,Two,Three) mode(cyclical)', true);
        validByDefinition.put('serial type(number) from(10.2) step(1.2) scale(2)', false);
        validByDefinition.put('serial type(picklist) except(a) mode(cyclical)', false);
        validByDefinition.put('serial type(picklist) mode(cyclical)', false);
        validByDefinition.put('static lookup(Account) field(FieldOne) value(one) source(forceea)', true);
        validByDefinition.put('static value("")', true);
        validByDefinition.put('static value(01:01:01)', false);
        validByDefinition.put('static value(10)', false);
        validByDefinition.put('static value(10.1)', false);
        validByDefinition.put('static value(01:01:01)', false);
        validByDefinition.put('static value(2017-01-01 01:01:01)', false);
        validByDefinition.put('static value(2017-01-01)', false);
        validByDefinition.put('static value(One)', true);

        Test.startTest();
        Boolean expectedResult = true;
        Boolean actualResult = ForceeaUtilityTest.definitionsAreValid('FObjectOne__c', fieldApiName, validByDefinition);
        Test.stopTest();

        System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
    }

    @IsTest
    private static void isValidForFieldDataType_string_expectFailure() {
        FObject.setExceptionHandling(EXCEPTION_CONTINUE);
        String fieldApiName = 'TestText__c';

        Map<String, Boolean> validByDefinition = new Map<String, Boolean>();
        validByDefinition.put('copy field(TestPicklistD__c)', true);
        validByDefinition.put('copy field(TestLookup__c) from(FObjectTwo__c.TestText__c)', true);
        validByDefinition.put('function-add field($Test)', true);
        validByDefinition.put('function-convert to(lower)', true);
        validByDefinition.put('mock type(id)', false);
        validByDefinition.put('random lookup(Account) field(FieldOne) except(One,Two,Three) source(forceea)', true);
        validByDefinition.put('random lookup(Account) field(FieldOne) value(One,Two,Three) source(forceea)', true);
        validByDefinition.put('random lookup(Account) source(forceea)', true);
        validByDefinition.put('random lookup(Account) where(Rating = \'Hot\') source(salesforce)', true);
        validByDefinition.put('random type(boolean)', true);
        validByDefinition.put('random type(city) group(one)', true);
        validByDefinition.put('random type(country) group(one)', true);
        validByDefinition.put('random type(date) From(2017-01-01) To(2017-12-31)', true);
        validByDefinition.put('random type(datetime) From(2017-01-01) To(2017-12-31)', true);
        validByDefinition.put('random type(email)', true);
        validByDefinition.put('random type(firstName) Group(one)', true);
        validByDefinition.put('random type(lastName) group(one)', true);
        validByDefinition.put('random type(list) value(1, 2, 3)', true);
        validByDefinition.put('random type(list) value(1.1, 2.2, 3.3)', true);
        validByDefinition.put('random type(list) value(01:01:01, 02:02:02, 3:03:03)', true);
        validByDefinition.put('random type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)', true);
        validByDefinition.put('random type(list) value(2017-01-01, 2017-02-02, 2017-03-03)', true);
        validByDefinition.put('random type(list) value(One, Two, Three)', true);
        validByDefinition.put('random type(number) from(1) to(100) scale(0)', true);
        validByDefinition.put('random type(phone) Format(30 210 dD DD ddD)', true);
        validByDefinition.put('random type(picklist) except(One,Two)', false);
        validByDefinition.put('random type(picklist)', false);
        validByDefinition.put('random type(postalCode) group(one)', true);
        validByDefinition.put('random type(state) group(one)', true);
        validByDefinition.put('random type(street) group(one)', true);
        validByDefinition.put('random type(string) minLength(10) maxLength(30) startWith(lower) include(lower,upper,digit)', true);
        validByDefinition.put('random type(text) minLength(10) maxlength(30)', true);
        validByDefinition.put('random type(time) from(05:15:21) to(17:18:22)', true);
        validByDefinition.put('random type(url)', true);
        validByDefinition.put('serial lookup(Account) mode(cyclical) source(forceea)', true);
        validByDefinition.put('serial type(date) from(2017-01-01) Step(2)', true);
        validByDefinition.put('serial type(datetime) from(2017-01-01 02:02:02) step(2.2)', true);
        validByDefinition.put('serial type(list) value(1, 2, 3) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(1, 2.2, 3) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(1.1, 2.2, 3.3) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(01:01:01, 02:02:02, 03:03:03) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(2017-01-01, 2017-02-02, 2017-03-03) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(One,Two,Three) mode(cyclical)', true);
        validByDefinition.put('serial type(number) from(10.2) step(1.2) scale(2)', true);
        validByDefinition.put('serial type(picklist) except(a) mode(cyclical)', false);
        validByDefinition.put('serial type(picklist) mode(cyclical)', false);
        validByDefinition.put('static lookup(Account) field(FieldOne) value(one) source(forceea)', true);
        validByDefinition.put('static value("")', true);
        validByDefinition.put('static value(01:01:01)', true);
        validByDefinition.put('static value(10)', true);
        validByDefinition.put('static value(10.1)', true);
        validByDefinition.put('static value(01:01:01)', true);
        validByDefinition.put('static value(2017-01-01 01:01:01)', true);
        validByDefinition.put('static value(2017-01-01)', true);
        validByDefinition.put('static value(One)', true);

        Test.startTest();
        Boolean expectedResult = true;
        Boolean actualResult = ForceeaUtilityTest.definitionsAreValid('FObjectOne__c', fieldApiName, validByDefinition);
        Test.stopTest();

        System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
    }

    @IsTest
    private static void isValidForFieldDataType_textArea_expectFailure() {
        FObject.setExceptionHandling(EXCEPTION_CONTINUE);
        String fieldApiName = 'TestTextArea__c';

        Map<String, Boolean> validByDefinition = new Map<String, Boolean>();
        validByDefinition.put('copy field(TestPicklistD__c)', true);
        validByDefinition.put('copy field(TestLookup__c) from(FObjectTwo__c.TestText__c)', true);
        validByDefinition.put('function-add field($Test)', true);
        validByDefinition.put('function-convert to(lower)', true);
        validByDefinition.put('mock type(id)', false);
        validByDefinition.put('random lookup(Account) field(FieldOne) except(One,Two,Three) source(forceea)', true);
        validByDefinition.put('random lookup(Account) field(FieldOne) value(One,Two,Three) source(forceea)', true);
        validByDefinition.put('random lookup(Account) source(forceea)', true);
        validByDefinition.put('random lookup(Account) where(Rating = \'Hot\') source(salesforce)', true);
        validByDefinition.put('random type(boolean)', true);
        validByDefinition.put('random type(city) group(one)', true);
        validByDefinition.put('random type(country) group(one)', true);
        validByDefinition.put('random type(date) From(2017-01-01) To(2017-12-31)', true);
        validByDefinition.put('random type(datetime) From(2017-01-01) To(2017-12-31)', true);
        validByDefinition.put('random type(email)', true);
        validByDefinition.put('random type(firstName) Group(one)', true);
        validByDefinition.put('random type(lastName) group(one)', true);
        validByDefinition.put('random type(list) value(1, 2, 3)', true);
        validByDefinition.put('random type(list) value(1.1, 2.2, 3.3)', true);
        validByDefinition.put('random type(list) value(01:01:01, 02:02:02, 3:03:03)', true);
        validByDefinition.put('random type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)', true);
        validByDefinition.put('random type(list) value(2017-01-01, 2017-02-02, 2017-03-03)', true);
        validByDefinition.put('random type(list) value(One, Two, Three)', true);
        validByDefinition.put('random type(number) from(1) to(100) scale(0)', true);
        validByDefinition.put('random type(phone) Format(30 210 dD DD ddD)', true);
        validByDefinition.put('random type(picklist) except(One,Two)', false);
        validByDefinition.put('random type(picklist)', false);
        validByDefinition.put('random type(postalCode) group(one)', true);
        validByDefinition.put('random type(state) group(one)', true);
        validByDefinition.put('random type(street) group(one)', true);
        validByDefinition.put('random type(string) minLength(10) maxLength(30) startWith(lower) include(lower,upper,digit)', true);
        validByDefinition.put('random type(text) minLength(10) maxlength(30)', true);
        validByDefinition.put('random type(time) from(05:15:21) to(17:18:22)', true);
        validByDefinition.put('random type(url)', true);
        validByDefinition.put('serial lookup(Account) mode(cyclical) source(forceea)', true);
        validByDefinition.put('serial type(date) from(2017-01-01) Step(2)', true);
        validByDefinition.put('serial type(datetime) from(2017-01-01 02:02:02) step(2.2)', true);
        validByDefinition.put('serial type(list) value(1, 2, 3) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(1, 2.2, 3) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(1.1, 2.2, 3.3) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(01:01:01, 02:02:02, 03:03:03) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(2017-01-01, 2017-02-02, 2017-03-03) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(One,Two,Three) mode(cyclical)', true);
        validByDefinition.put('serial type(number) from(10.2) step(1.2) scale(2)', true);
        validByDefinition.put('serial type(picklist) except(a) mode(cyclical)', false);
        validByDefinition.put('serial type(picklist) mode(cyclical)', false);
        validByDefinition.put('static lookup(Account) field(FieldOne) value(one) source(forceea)', true);
        validByDefinition.put('static value("")', true);
        validByDefinition.put('static value(01:01:01)', true);
        validByDefinition.put('static value(10)', true);
        validByDefinition.put('static value(10.1)', true);
        validByDefinition.put('static value(01:01:01)', true);
        validByDefinition.put('static value(2017-01-01 01:01:01)', true);
        validByDefinition.put('static value(2017-01-01)', true);
        validByDefinition.put('static value(One)', true);

        Test.startTest();
        Boolean expectedResult = true;
        Boolean actualResult = ForceeaUtilityTest.definitionsAreValid('FObjectOne__c', fieldApiName, validByDefinition);
        Test.stopTest();

        System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
    }

    @IsTest
    private static void isValidForFieldDataType_textAreaLong_expectFailure() {
        FObject.setExceptionHandling(EXCEPTION_CONTINUE);
        String fieldApiName = 'TestTextAreaLong__c';

        Map<String, Boolean> validByDefinition = new Map<String, Boolean>();
        validByDefinition.put('copy field(TestPicklistD__c)', true);
        validByDefinition.put('copy field(TestLookup__c) from(FObjectTwo__c.TestText__c)', true);
        validByDefinition.put('function-add field($Test)', true);
        validByDefinition.put('function-convert to(lower)', true);
        validByDefinition.put('mock type(id)', false);
        validByDefinition.put('random lookup(Account) field(FieldOne) except(One,Two,Three) source(forceea)', true);
        validByDefinition.put('random lookup(Account) field(FieldOne) value(One,Two,Three) source(forceea)', true);
        validByDefinition.put('random lookup(Account) source(forceea)', true);
        validByDefinition.put('random lookup(Account) where(Rating = \'Hot\') source(salesforce)', true);
        validByDefinition.put('random type(boolean)', true);
        validByDefinition.put('random type(city) group(one)', true);
        validByDefinition.put('random type(country) group(one)', true);
        validByDefinition.put('random type(date) From(2017-01-01) To(2017-12-31)', true);
        validByDefinition.put('random type(datetime) From(2017-01-01) To(2017-12-31)', true);
        validByDefinition.put('random type(email)', true);
        validByDefinition.put('random type(firstName) Group(one)', true);
        validByDefinition.put('random type(lastName) group(one)', true);
        validByDefinition.put('random type(list) value(1, 2, 3)', true);
        validByDefinition.put('random type(list) value(1.1, 2.2, 3.3)', true);
        validByDefinition.put('random type(list) value(01:01:01, 02:02:02, 3:03:03)', true);
        validByDefinition.put('random type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)', true);
        validByDefinition.put('random type(list) value(2017-01-01, 2017-02-02, 2017-03-03)', true);
        validByDefinition.put('random type(list) value(One, Two, Three)', true);
        validByDefinition.put('random type(number) from(1) to(100) scale(0)', true);
        validByDefinition.put('random type(phone) Format(30 210 dD DD ddD)', true);
        validByDefinition.put('random type(picklist) except(One,Two)', false);
        validByDefinition.put('random type(picklist)', false);
        validByDefinition.put('random type(postalCode) group(one)', true);
        validByDefinition.put('random type(state) group(one)', true);
        validByDefinition.put('random type(street) group(one)', true);
        validByDefinition.put('random type(string) minLength(10) maxLength(30) startWith(lower) include(lower,upper,digit)', true);
        validByDefinition.put('random type(text) minLength(10) maxlength(30)', true);
        validByDefinition.put('random type(time) from(05:15:21) to(17:18:22)', true);
        validByDefinition.put('random type(url)', true);
        validByDefinition.put('serial lookup(Account) mode(cyclical) source(forceea)', true);
        validByDefinition.put('serial type(date) from(2017-01-01) Step(2)', true);
        validByDefinition.put('serial type(datetime) from(2017-01-01 02:02:02) step(2.2)', true);
        validByDefinition.put('serial type(list) value(1, 2, 3) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(1, 2.2, 3) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(1.1, 2.2, 3.3) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(01:01:01, 02:02:02, 03:03:03) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(2017-01-01, 2017-02-02, 2017-03-03) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(One,Two,Three) mode(cyclical)', true);
        validByDefinition.put('serial type(number) from(10.2) step(1.2) scale(2)', true);
        validByDefinition.put('serial type(picklist) except(a) mode(cyclical)', false);
        validByDefinition.put('serial type(picklist) mode(cyclical)', false);
        validByDefinition.put('static lookup(Account) field(FieldOne) value(one) source(forceea)', true);
        validByDefinition.put('static value("")', true);
        validByDefinition.put('static value(01:01:01)', true);
        validByDefinition.put('static value(10)', true);
        validByDefinition.put('static value(10.1)', true);
        validByDefinition.put('static value(01:01:01)', true);
        validByDefinition.put('static value(2017-01-01 01:01:01)', true);
        validByDefinition.put('static value(2017-01-01)', true);
        validByDefinition.put('static value(One)', true);

        Test.startTest();
        Boolean expectedResult = true;
        Boolean actualResult = ForceeaUtilityTest.definitionsAreValid('FObjectOne__c', fieldApiName, validByDefinition);
        Test.stopTest();

        System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
    }

    @IsTest
    private static void isValidForFieldDataType_textAreaRich_expectFailure() {
        FObject.setExceptionHandling(EXCEPTION_CONTINUE);
        String fieldApiName = 'TestTextAreaRich__c';

        Map<String, Boolean> validByDefinition = new Map<String, Boolean>();
        validByDefinition.put('copy field(TestPicklistD__c)', true);
        validByDefinition.put('copy field(TestLookup__c) from(FObjectTwo__c.TestText__c)', true);
        validByDefinition.put('function-add field($Test)', true);
        validByDefinition.put('function-convert to(lower)', true);
        validByDefinition.put('mock type(id)', false);
        validByDefinition.put('random lookup(Account) field(FieldOne) except(One,Two,Three) source(forceea)', true);
        validByDefinition.put('random lookup(Account) field(FieldOne) value(One,Two,Three) source(forceea)', true);
        validByDefinition.put('random lookup(Account) source(forceea)', true);
        validByDefinition.put('random lookup(Account) where(Rating = \'Hot\') source(salesforce)', true);
        validByDefinition.put('random type(boolean)', true);
        validByDefinition.put('random type(city) group(one)', true);
        validByDefinition.put('random type(country) group(one)', true);
        validByDefinition.put('random type(date) From(2017-01-01) To(2017-12-31)', true);
        validByDefinition.put('random type(datetime) From(2017-01-01) To(2017-12-31)', true);
        validByDefinition.put('random type(email)', true);
        validByDefinition.put('random type(firstName) Group(one)', true);
        validByDefinition.put('random type(lastName) group(one)', true);
        validByDefinition.put('random type(list) value(1, 2, 3)', true);
        validByDefinition.put('random type(list) value(1.1, 2.2, 3.3)', true);
        validByDefinition.put('random type(list) value(01:01:01, 02:02:02, 3:03:03)', true);
        validByDefinition.put('random type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)', true);
        validByDefinition.put('random type(list) value(2017-01-01, 2017-02-02, 2017-03-03)', true);
        validByDefinition.put('random type(list) value(One, Two, Three)', true);
        validByDefinition.put('random type(number) from(1) to(100) scale(0)', true);
        validByDefinition.put('random type(phone) Format(30 210 dD DD ddD)', true);
        validByDefinition.put('random type(picklist) except(One,Two)', false);
        validByDefinition.put('random type(picklist)', false);
        validByDefinition.put('random type(postalCode) group(one)', true);
        validByDefinition.put('random type(state) group(one)', true);
        validByDefinition.put('random type(street) group(one)', true);
        validByDefinition.put('random type(string) minLength(10) maxLength(30) startWith(lower) include(lower,upper,digit)', true);
        validByDefinition.put('random type(text) minLength(10) maxlength(30)', true);
        validByDefinition.put('random type(time) from(05:15:21) to(17:18:22)', true);
        validByDefinition.put('random type(url)', true);
        validByDefinition.put('serial lookup(Account) mode(cyclical) source(forceea)', true);
        validByDefinition.put('serial type(date) from(2017-01-01) Step(2)', true);
        validByDefinition.put('serial type(datetime) from(2017-01-01 02:02:02) step(2.2)', true);
        validByDefinition.put('serial type(list) value(1, 2, 3) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(1, 2.2, 3) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(1.1, 2.2, 3.3) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(01:01:01, 02:02:02, 03:03:03) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(2017-01-01, 2017-02-02, 2017-03-03) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(One,Two,Three) mode(cyclical)', true);
        validByDefinition.put('serial type(number) from(10.2) step(1.2) scale(2)', true);
        validByDefinition.put('serial type(picklist) except(a) mode(cyclical)', false);
        validByDefinition.put('serial type(picklist) mode(cyclical)', false);
        validByDefinition.put('static lookup(Account) field(FieldOne) value(one) source(forceea)', true);
        validByDefinition.put('static value("")', true);
        validByDefinition.put('static value(01:01:01)', true);
        validByDefinition.put('static value(10)', true);
        validByDefinition.put('static value(10.1)', true);
        validByDefinition.put('static value(01:01:01)', true);
        validByDefinition.put('static value(01:01:01)', true);
        validByDefinition.put('static value(2017-01-01 01:01:01)', true);
        validByDefinition.put('static value(2017-01-01)', true);
        validByDefinition.put('static value(One)', true);

        Test.startTest();
        Boolean expectedResult = true;
        Boolean actualResult = ForceeaUtilityTest.definitionsAreValid('FObjectOne__c', fieldApiName, validByDefinition);
        Test.stopTest();

        System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
    }

    @IsTest
    private static void isValidForFieldDataType_time_expectSuccess() {
        FObject.setExceptionHandling(EXCEPTION_CONTINUE);
        String fieldApiName = 'TestTime__c';

        Map<String, Boolean> validByDefinition = new Map<String, Boolean>();
        validByDefinition.put('copy field(TestPicklistD__c)', true);
        validByDefinition.put('copy field(TestLookup__c) from(FObjectTwo__c.TestText__c)', true);
        validByDefinition.put('function-add field($Test)', false);
        validByDefinition.put('function-convert to(lower)', false);
        validByDefinition.put('mock type(id)', false);
        validByDefinition.put('random lookup(Account) field(FieldOne) except(One,Two,Three) source(forceea)', false);
        validByDefinition.put('random lookup(Account) field(FieldOne) value(One,Two,Three) source(forceea)', false);
        validByDefinition.put('random lookup(Account) source(forceea)', false);
        validByDefinition.put('random lookup(Account) where(Rating = \'Hot\') source(salesforce)', false);
        validByDefinition.put('random type(boolean)', false);
        validByDefinition.put('random type(city) group(one)', false);
        validByDefinition.put('random type(country) group(one)', false);
        validByDefinition.put('random type(date) From(2017-01-01) To(2017-12-31)', false);
        validByDefinition.put('random type(datetime) From(2017-01-01) To(2017-12-31)', false);
        validByDefinition.put('random type(email)', false);
        validByDefinition.put('random type(firstName) Group(one)', false);
        validByDefinition.put('random type(lastName) group(one)', false);
        validByDefinition.put('random type(list) value(1, 2, 3)', false);
        validByDefinition.put('random type(list) value(1.1, 2.2, 3.3)', false);
        validByDefinition.put('random type(list) value(01:01:01, 02:02:02, 3:03:03)', true);
        validByDefinition.put('random type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)', false);
        validByDefinition.put('random type(list) value(2017-01-01, 2017-02-02, 2017-03-03)', false);
        validByDefinition.put('random type(list) value(One, Two, Three)', false);
        validByDefinition.put('random type(number) from(1) to(100) scale(0)', false);
        validByDefinition.put('random type(phone) Format(30 210 dD DD ddD)', false);
        validByDefinition.put('random type(picklist) except(One,Two)', false);
        validByDefinition.put('random type(picklist)', false);
        validByDefinition.put('random type(postalCode) group(one)', false);
        validByDefinition.put('random type(state) group(one)', false);
        validByDefinition.put('random type(street) group(one)', false);
        validByDefinition.put('random type(string) minLength(10) maxLength(30) startWith(lower) include(lower,upper,digit)', false);
        validByDefinition.put('random type(text) minLength(10) maxlength(30)', false);
        validByDefinition.put('random type(time) from(05:15:21) to(17:18:22)', true);
        validByDefinition.put('random type(url)', false);
        validByDefinition.put('serial lookup(Account) mode(cyclical) source(forceea)', false);
        validByDefinition.put('serial type(date) from(2017-01-01) Step(2)', false);
        validByDefinition.put('serial type(datetime) from(2017-01-01 02:02:02) step(2.2)', false);
        validByDefinition.put('serial type(list) value(1, 2, 3) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(1, 2.2, 3) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(1.1, 2.2, 3.3) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(01:01:01, 02:02:02, 03:03:03) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(2017-01-01, 2017-02-02, 2017-03-03) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(One,Two,Three) mode(cyclical)', false);
        validByDefinition.put('serial type(number) from(10.2) step(1.2) scale(2)', false);
        validByDefinition.put('serial type(picklist) except(a) mode(cyclical)', false);
        validByDefinition.put('serial type(picklist) mode(cyclical)', false);
        validByDefinition.put('static lookup(Account) field(FieldOne) value(one) source(forceea)', false);
        validByDefinition.put('static value("")', true);
        validByDefinition.put('static value(01:01:01)', false);
        validByDefinition.put('static value(10)', false);
        validByDefinition.put('static value(10.1)', false);
        validByDefinition.put('static value(01:01:01)', true);
        validByDefinition.put('static value(2017-01-01 01:01:01)', false);
        validByDefinition.put('static value(2017-01-01)', false);
        validByDefinition.put('static value(One)', false);

        Test.startTest();
        Boolean expectedResult = true;
        Boolean actualResult = ForceeaUtilityTest.definitionsAreValid('FObjectOne__c', fieldApiName, validByDefinition);
        Test.stopTest();

        System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
    }

    @IsTest
    private static void isValidForFieldDataType_url_expectFailure() {
        FObject.setExceptionHandling(EXCEPTION_CONTINUE);
        String fieldApiName = 'TestUrl__c';

        Map<String, Boolean> validByDefinition = new Map<String, Boolean>();
        validByDefinition.put('copy field(TestPicklistD__c)', true);
        validByDefinition.put('copy field(TestLookup__c) from(FObjectTwo__c.TestText__c)', true);
        validByDefinition.put('function-add field($Test)', false);
        validByDefinition.put('function-convert to(lower)', true);
        validByDefinition.put('mock type(id)', false);
        validByDefinition.put('random lookup(Account) field(FieldOne) except(One,Two,Three) source(forceea)', false);
        validByDefinition.put('random lookup(Account) field(FieldOne) value(One,Two,Three) source(forceea)', false);
        validByDefinition.put('random lookup(Account) source(forceea)', false);
        validByDefinition.put('random lookup(Account) where(Rating = \'Hot\') source(salesforce)', false);
        validByDefinition.put('random type(boolean)', false);
        validByDefinition.put('random type(city) group(one)', false);
        validByDefinition.put('random type(country) group(one)', false);
        validByDefinition.put('random type(date) From(2017-01-01) To(2017-12-31)', false);
        validByDefinition.put('random type(datetime) From(2017-01-01) To(2017-12-31)', false);
        validByDefinition.put('random type(email)', false);
        validByDefinition.put('random type(firstName) Group(one)', false);
        validByDefinition.put('random type(lastName) group(one)', false);
        validByDefinition.put('random type(list) value(1, 2, 3)', true);
        validByDefinition.put('random type(list) value(1.1, 2.2, 3.3)', false);
        validByDefinition.put('random type(list) value(01:01:01, 02:02:02, 3:03:03)', false);
        validByDefinition.put('random type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)', false);
        validByDefinition.put('random type(list) value(2017-01-01, 2017-02-02, 2017-03-03)', false);
        validByDefinition.put('random type(list) value(One, Two, Three)', true);
        validByDefinition.put('random type(number) from(1) to(100) scale(0)', true);
        validByDefinition.put('random type(phone) Format(30 210 dD DD ddD)', false);
        validByDefinition.put('random type(picklist) except(One,Two)', false);
        validByDefinition.put('random type(picklist)', false);
        validByDefinition.put('random type(postalCode) group(one)', false);
        validByDefinition.put('random type(state) group(one)', false);
        validByDefinition.put('random type(street) group(one)', false);
        validByDefinition.put('random type(string) minLength(10) maxLength(30) startWith(lower) include(lower,upper,digit)', true);
        validByDefinition.put('random type(text) minLength(10) maxlength(30)', false);
        validByDefinition.put('random type(time) from(05:15:21) to(17:18:22)', false);
        validByDefinition.put('random type(url)', true);
        validByDefinition.put('serial lookup(Account) mode(cyclical) source(forceea)', false);
        validByDefinition.put('serial type(date) from(2017-01-01) Step(2)', false);
        validByDefinition.put('serial type(datetime) from(2017-01-01 02:02:02) step(2.2)', false);
        validByDefinition.put('serial type(list) value(1, 2, 3) mode(cyclical)', true);
        validByDefinition.put('serial type(list) value(1, 2.2, 3) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(1.1, 2.2, 3.3) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(01:01:01, 02:02:02, 03:03:03) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(2017-01-01, 2017-02-02, 2017-03-03) mode(cyclical)', false);
        validByDefinition.put('serial type(list) value(One,Two,Three) mode(cyclical)', true);
        validByDefinition.put('serial type(number) from(10.2) step(1.2) scale(2)', true);
        validByDefinition.put('serial type(picklist) except(a) mode(cyclical)', false);
        validByDefinition.put('serial type(picklist) mode(cyclical)', false);
        validByDefinition.put('static lookup(Account) field(FieldOne) value(one) source(forceea)', false);
        validByDefinition.put('static value("")', true);
        validByDefinition.put('static value(01:01:01)', false);
        validByDefinition.put('static value(10)', true);
        validByDefinition.put('static value(10.1)', false);
        validByDefinition.put('static value(01:01:01)', false);
        validByDefinition.put('static value(2017-01-01 01:01:01)', false);
        validByDefinition.put('static value(2017-01-01)', false);
        validByDefinition.put('static value(One)', true);

        Test.startTest();
        Boolean expectedResult = true;
        Boolean actualResult = ForceeaUtilityTest.definitionsAreValid('FObjectOne__c', fieldApiName, validByDefinition);
        Test.stopTest();

        System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
    }

    @IsTest
    private static void setDefinition_scriptIsBlank_expectFailure() {
        FObject.setExceptionHandling(EXCEPTION_CONTINUE);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(FObjectOne__c.TestText__c, '');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid command [] in definition []';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_definitionsWithSpacesAndCase_expectSuccess() {
        String field1 = 'TestDecimal__c';
        String field2 = 'TestText__c';
        String field3 = 'TestPicklistA__c';
        String field4 = 'TestPicklistC__c';
        String field5 = 'TestPicklistB__c ';
        String definition1 = 'Random from( 100)  Type("number" ) to( "1000000" ) scale(3 )';
        String definition2 = 'Serial Type(Number) from (1) scale (0)  step (1) ';
        String definition3 = 'random except( a1,  "a2") Type ( "picklist")  ';
        String definition4 = ' random value( c1,c2 ) type ( list )';
        String definition5 = ' Random  type( picklist ) ';

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(field1, definition1);
        obj.setDefinition(field2, definition2);
        obj.setDefinition(field3, definition3);
        obj.setDefinition(field4, definition4);
        obj.setDefinition(field5, definition5);
        obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        if (obj.getErrors().containsKey(field1)) {
            errors += 1;
        }
        if (obj.getErrors().containsKey(field2)) {
            errors += 2;
        }
        if (obj.getErrors().containsKey(field3)) {
            errors += 4;
        }
        if (obj.getErrors().containsKey(field4)) {
            errors += 8;
        }
        if (obj.getErrors().containsKey(field5)) {
            errors += 16;
        }
        System.assertEquals(0, errors, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_missingOpeningParenthesis1_expectFailure() {
        FObject.setExceptionHandling(EXCEPTION_CONTINUE);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(FObjectOne__c.TestText__c, 'Static Value arg1) ');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid definition [Static Value arg1)] of field [TestText__c]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_missingOpeningParenthesis2_expectFailure() {
        FObject.setExceptionHandling(EXCEPTION_CONTINUE);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(FObjectOne__c.TestText__c, 'Static Value "arg1")');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid definition [Static Value "arg1")] of field [TestText__c]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_missingOpeningParenthesis3_expectFailure() {
        FObject.setExceptionHandling(EXCEPTION_CONTINUE);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(FObjectOne__c.TestText__c, 'Static Value arg1, arg2) ');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid definition [Static Value arg1, arg2)] of field [TestText__c]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_missingOpeningParenthesis4_expectFailure() {
        FObject.setExceptionHandling(EXCEPTION_CONTINUE);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(FObjectOne__c.TestText__c, 'Static Value "arg1", arg2)');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid definition [Static Value "arg1", arg2)] of field [TestText__c]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_missingClosingParenthesis1_expectFailure() {
        FObject.setExceptionHandling(EXCEPTION_CONTINUE);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(FObjectOne__c.TestText__c, 'Static Value(arg1');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid definition [Static Value(arg1] of field [TestText__c]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_missingClosingParenthesis2_expectFailure() {
        FObject.setExceptionHandling(EXCEPTION_CONTINUE);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(FObjectOne__c.TestText__c, ' Static  Value("arg1" ');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid definition [Static  Value("arg1"] of field [TestText__c]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_missingClosingParenthesis3_expectFailure() {
        FObject.setExceptionHandling(EXCEPTION_CONTINUE);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(FObjectOne__c.TestText__c, 'Static Value(arg1, arg2');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid definition [Static Value(arg1, arg2] of field [TestText__c]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_missingClosingParenthesis4_expectFailure() {
        FObject.setExceptionHandling(EXCEPTION_CONTINUE);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(FObjectOne__c.TestText__c, 'Static Value("arg1", arg2');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid definition [Static Value("arg1", arg2] of field [TestText__c]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_missingClosingDoubleQuotes1_expectFailure() {
        FObject.setExceptionHandling(EXCEPTION_CONTINUE);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(FObjectOne__c.TestText__c, 'Static Value("arg1)');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid definition [Static Value("arg1)] of field [TestText__c]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_missingClosingDoubleQuotes2_expectFailure() {
        FObject.setExceptionHandling(EXCEPTION_CONTINUE);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(FObjectOne__c.TestText__c, 'Random type(list) value(arg1, "arg2)');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid definition [Random type(list) value(arg1, "arg2)] of field [TestText__c]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_missingClosingDoubleQuotes3_expectFailure() {
        FObject.setExceptionHandling(EXCEPTION_CONTINUE);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(FObjectOne__c.TestText__c, 'Random type(list) value("arg1, arg2)');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid definition [Random type(list) value("arg1, arg2)] of field [TestText__c]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_invalidComma_expectFailure() {
        FObject.setExceptionHandling(EXCEPTION_CONTINUE);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(FObjectOne__c.TestText__c, 'Random Type(List) ,Value(arg1, "arg2")');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid parameter [,Value] in definition [Random Type(List) ,Value(arg1, "arg2")]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_invalidDoubleQuotes1_expectFailure() {
        FObject.setExceptionHandling(EXCEPTION_CONTINUE);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(FObjectOne__c.TestText__c, 'Random Type(List) "Value(arg1, "arg2")');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid parameter ["Value] in definition [Random Type(List) "Value(arg1, "arg2")]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_invalidDoubleQuotes2_expectFailure() {
        FObject.setExceptionHandling(EXCEPTION_CONTINUE);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(FObjectOne__c.TestText__c, 'random type(list) value" (arg1, "arg2")');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid parameter [value"] in definition [random type(list) value" (arg1, "arg2")]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_invalidDoubleQuotes4_expectFailure() {
        FObject.setExceptionHandling(EXCEPTION_CONTINUE);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(FObjectOne__c.TestText__c, 'Random type(list) value(arg1, ""arg2")');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid definition [Random type(list) value(arg1, ""arg2")] of field [TestText__c]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_invalidDoubleQuotes5_expectFailure() {
        FObject.setExceptionHandling(EXCEPTION_CONTINUE);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(FObjectOne__c.TestText__c, 'Random type(list) value(arg1, "arg2"")');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid definition [Random type(list) value(arg1, "arg2"")] of field [TestText__c]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_invalidDoubleQuotes6_expectFailure() {
        FObject.setExceptionHandling(EXCEPTION_CONTINUE);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(FObjectOne__c.TestText__c, 'Random type(list) value(arg1, "arg2")"');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid definition [Random type(list) value(arg1, "arg2")"] of field [TestText__c]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_fieldIsBlank_expectFailure() {
        FObject.setExceptionHandling(EXCEPTION_CONTINUE);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition('', 'Static Value(Company)');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid field [] in definition [Static Value(Company)]';
        String actualResult = obj.getErrors().get('FObjectOne__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_fieldIsInvalid_expectFailure() {
        FObject.setExceptionHandling(EXCEPTION_CONTINUE);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition('TestTextX__c', 'Static Value(Company)');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid field [TestTextX__c] in definition [Static Value(Company)]';
        String actualResult = obj.getErrors().get('FObjectOne__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_fieldBelongsToAnotherSObject_expectFailure() {
        FObject.setExceptionHandling(EXCEPTION_CONTINUE);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType)
            .setDefinition(FObjectOne__c.TestText__c, 'static  value(test1-)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static  value(test)')
            .setDefinition(FObjectTwo__c.TestText__c, 'static value(Invalid field)');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid field [TestText__c] for SObject [FObjectOne__c]';
        String actualResult = obj.getErrors().get('FObjectOne__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_invalidCommand_expectFailure() {
        FObject.setExceptionHandling(EXCEPTION_CONTINUE);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(FObjectOne__c.TestText__c, 'StaticX Value(Company)');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid command [StaticX] in definition [StaticX Value(Company)]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_invalidParameter1_expectFailure() {
        FObject.setExceptionHandling(EXCEPTION_CONTINUE);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(FObjectOne__c.TestText__c, 'Static ValueX(Company) ');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid parameter [ValueX] in definition [Static ValueX(Company)]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_invalidParameter2_expectFailure() {
        FObject.setExceptionHandling(EXCEPTION_CONTINUE);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(FObjectOne__c.TestText__c, 'Static (Company)');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid parameter [] in definition [Static (Company)]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_invalidParameter3_expectFailure() {
        FObject.setExceptionHandling(EXCEPTION_CONTINUE);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(FObjectOne__c.TestText__c, 'Static abc)(Company)');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid parameter [abc)] in definition [Static abc)(Company)]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_invalidParameter4_expectFailure() {
        FObject.setExceptionHandling(EXCEPTION_CONTINUE);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(FObjectOne__c.TestText__c, 'Static )(Company)');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid parameter [)] in definition [Static )(Company)]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_invalidParameter5_expectFailure() {
        FObject.setExceptionHandling(EXCEPTION_CONTINUE);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(FObjectOne__c.TestText__c, 'Static abc"(Company)');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid parameter [abc"] in definition [Static abc"(Company)]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_invalidParameter6_expectFailure() {
        FObject.setExceptionHandling(EXCEPTION_CONTINUE);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(FObjectOne__c.TestText__c, 'Static "(Company)');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid parameter ["] in definition [Static "(Company)]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_multipleDefinitionsForId_expectFailure() {
        FObject.setExceptionHandling(EXCEPTION_CONTINUE);
        String fieldApiName = 'Id';

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(fieldApiName, 'mock type(id)');
        obj.setDefinition(fieldApiName, 'static value(one)');
        obj.getRecords();
        Test.stopTest();

        String expectedResult = 'Field [' + fieldApiName + '] does not accept multiple definitions';
        String actualResult = obj.getErrors().get(fieldApiName).get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_multipleDefinitionsForCheckbox_expectFailure() {
        FObject.setExceptionHandling(EXCEPTION_CONTINUE);

        String fieldApiName = 'TestCheckbox__c';

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(fieldApiName, 'random type(boolean)');
        obj.setDefinition(fieldApiName, 'static value(true)');
        obj.getRecords();
        Test.stopTest();

        String expectedResult = 'Field [' + fieldApiName + '] does not accept multiple definitions';
        String actualResult = obj.getErrors().get(fieldApiName).get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_multipleDefinitionsForCombobox_expectSuccess() {
        String fieldApiName = 'Subject';

        Test.startTest();
        FObject obj = new FObject('Event', 10);
        obj.setDefinition(fieldApiName, 'random type(picklist)');
        obj.setDefinition(fieldApiName, 'static value(One)');
        obj.setDefinition('Type', 'random type(picklist)');
        obj.setDefinition('WhoId', 'random lookup(Contact) source(forceea)');
        obj.setDefinition('ActivityDatetime', 'random type(datetime) from(2017-10-1) to(2017-12-31)');
        obj.setDefinition('DurationInMinutes', 'random type(number) from(1) to(10) scale(0)');
        obj.getRecords();
        Test.stopTest();

        Assert.isTrue(obj.getErrors().isEmpty(), 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_multipleDefinitionsForCurrency_expectFailure() {
        FObject.setExceptionHandling(EXCEPTION_CONTINUE);
        String fieldApiName = 'TestCurrency__c';

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(fieldApiName, 'random type(number) from(1) to(10) scale(2)');
        obj.setDefinition(fieldApiName, 'random type(number) from(1) to(10) scale(2)');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Field [' + fieldApiName + '] does not accept multiple definitions';
        String actualResult = obj.getErrors().get(fieldApiName).get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_multipleDefinitionsForDate_expectFailure() {
        FObject.setExceptionHandling(EXCEPTION_CONTINUE);
        String fieldApiName = 'TestDate__c';

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(fieldApiName, 'random type(date) from(2018-1-1) to(2018-2-1)');
        obj.setDefinition(fieldApiName, 'static value(2018-1-1)');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Field [' + fieldApiName + '] does not accept multiple definitions';
        String actualResult = obj.getErrors().get(fieldApiName).get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_multipleDefinitionsForDatetime_expectFailure() {
        FObject.setExceptionHandling(EXCEPTION_CONTINUE);
        String fieldApiName = 'TestDatetime__c';

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(fieldApiName, 'random type(date) from(2018-1-1) to(2018-2-1)');
        obj.setDefinition(fieldApiName, 'static value(2018-1-1 01:01:01)');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Field [' + fieldApiName + '] does not accept multiple definitions';
        String actualResult = obj.getErrors().get(fieldApiName).get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_multipleDefinitionsForEmail_expectSuccess() {
        String fieldApiName = 'TestEmail__c';

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(fieldApiName, 'static value(myname@)');
        obj.setDefinition(fieldApiName, 'static value(company.com)');
        obj.getRecords();
        Test.stopTest();

        System.assert(obj.getErrors().isEmpty(), 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_multipleDefinitionsForLookup_expectFailure() {
        FObject.setExceptionHandling(EXCEPTION_CONTINUE);
        String fieldApiName = 'TestLookup__c';

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(fieldApiName, 'random lookup(FObjectTwo__c) source(salesforce)');
        obj.setDefinition(fieldApiName, 'random lookup(FObjectTwo__c) source(salesforce)');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Field [' + fieldApiName + '] does not accept multiple definitions';
        String actualResult = obj.getErrors().get(fieldApiName).get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_multipleDefinitionsForMultiPicklist_expectFailure() {
        FObject.setExceptionHandling(EXCEPTION_CONTINUE);
        String fieldApiName = 'TestMultiPicklistA__c';

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(fieldApiName, 'static value(a1)');
        obj.setDefinition(fieldApiName, 'random type(list) value(a0,a1,a2,a3)');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Field [' + fieldApiName + '] does not accept multiple definitions';
        String actualResult = obj.getErrors().get(fieldApiName).get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_multipleDefinitionsForNumber_expectFailure() {
        FObject.setExceptionHandling(EXCEPTION_CONTINUE);
        String fieldApiName = 'TestDecimal__c';

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(fieldApiName, 'random type(number) from(1) to (10) scale(2)');
        obj.setDefinition(fieldApiName, 'static value(10)');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Field [' + fieldApiName + '] does not accept multiple definitions';
        String actualResult = obj.getErrors().get(fieldApiName).get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_multipleDefinitionsForPercent_expectFailure() {
        FObject.setExceptionHandling(EXCEPTION_CONTINUE);
        String fieldApiName = 'TestPercent__c';

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(fieldApiName, 'random type(number) from(0) to (1) scale(2)');
        obj.setDefinition(fieldApiName, 'static value(0.2)');
        obj.getRecords();
        Test.stopTest();

        String expectedResult = 'Field [' + fieldApiName + '] does not accept multiple definitions';
        String actualResult = obj.getErrors().get(fieldApiName).get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_multipleDefinitionsForPhone_expectSuccess() {
        String fieldApiName = 'TestPhone__c';

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(fieldApiName, 'static value(210)');
        obj.setDefinition(fieldApiName, 'random type(number) from(111111) to (999999) scale(0)');
        obj.getRecords();
        Test.stopTest();

        System.assert(obj.getErrors().isEmpty(), 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_multipleDefinitionsForPicklist_expectFailure() {
        FObject.setExceptionHandling(EXCEPTION_CONTINUE);
        String fieldApiName = 'TestPicklistA__c';

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(fieldApiName, 'static value(a1)');
        obj.setDefinition(fieldApiName, 'random type(list) value(a0,a1,a2,a3)');
        obj.getRecords();
        Test.stopTest();

        String expectedResult = 'Field [' + fieldApiName + '] does not accept multiple definitions';
        String actualResult = obj.getErrors().get(fieldApiName).get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_multipleDefinitionsForText_expectSuccess() {
        String fieldApiName = 'TestText__c';

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(fieldApiName, 'static value(Company1)');
        obj.setDefinition(fieldApiName, 'static value(Company2)');
        obj.getRecords();
        Test.stopTest();

        System.assert(obj.getErrors().isEmpty(), 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_multipleDefinitionsForTextArea_expectSuccess() {
        String fieldApiName = 'TestTextArea__c';

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(fieldApiName, 'static value(Company1)');
        obj.setDefinition(fieldApiName, 'static value(Company2)');
        obj.getRecords();
        Test.stopTest();

        System.assert(obj.getErrors().isEmpty(), 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_multipleDefinitionsForTextAreaLong_expectSuccess() {
        String fieldApiName = 'TestTextAreaLong__c';

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(fieldApiName, 'static value(Company1)');
        obj.setDefinition(fieldApiName, 'static value(Company2)');
        obj.getRecords();
        Test.stopTest();

        System.assert(obj.getErrors().isEmpty(), 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_multipleDefinitionsForTextAreaRich_expectSuccess() {
        String fieldApiName = 'TestTextAreaRich__c';

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(fieldApiName, 'static value(Company1)');
        obj.setDefinition(fieldApiName, 'static value(Company2)');
        obj.getRecords();
        Test.stopTest();

        System.assert(obj.getErrors().isEmpty(), 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_multipleDefinitionsForTime_expectFailure() {
        FObject.setExceptionHandling(EXCEPTION_CONTINUE);
        String fieldApiName = 'TestTime__c';

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(fieldApiName, 'static value(10:10:10)');
        obj.setDefinition(fieldApiName, 'static value(11:11:11)');
        obj.getRecords();
        Test.stopTest();

        String expectedResult = 'Field [' + fieldApiName + '] does not accept multiple definitions';
        String actualResult = obj.getErrors().get(fieldApiName).get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_multipleDefinitionsForUrl_expectSuccess() {
        String fieldApiName = 'TestUrl__c';

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(fieldApiName, 'static value(http:///www.company)');
        obj.setDefinition(fieldApiName, 'serial type(number) from(1) step(1) scale(0)');
        obj.setDefinition(fieldApiName, 'static value(.com)');
        obj.getRecords();
        Test.stopTest();

        System.assert(obj.getErrors().isEmpty(), 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinitionFromField_accountName_expectSuccess() {
        String fieldApiName = 'Name';

        Test.startTest();
        FObject obj = new FObject('Account');
        Forceea.FieldInfo field = new Forceea.FieldInfo();
        field.fieldName = fieldApiName;
        field.fieldApiName = fieldApiName;
        new ForceeaDefinitionTypeHandler(obj).setDefinitionForField(field);
        Test.stopTest();

        List<String> definitions = obj.getDefinitions(Account.Name);
        String expectedResult = 'static value(Company-) serial type(number) from(1) step(1) scale(0)';
        String actualResult = definitions.get(0) + ' ' + definitions.get(1);
        System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
    }

    @IsTest
    private static void setDefinitionFromField_contactFirstName_expectSuccess() {
        String fieldApiName = 'FirstName';

        Test.startTest();
        FObject obj = new FObject(Contact.SObjectType);
        Forceea.FieldInfo field = new Forceea.FieldInfo();
        field.fieldName = fieldApiName;
        field.fieldApiName = fieldApiName;
        new ForceeaDefinitionTypeHandler(obj).setDefinitionForField(field);
        Test.stopTest();

        String expectedResult = 'random type(firstName) group(name)';
        String actualResult = obj.getDefinitions(Contact.FirstName).get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
    }

    @IsTest
    private static void setDefinitionFromField_firstAndLastHaveSameGroup_expectSuccess() {
        // check that the auto-generated definition for names has the group argument of the first "pair" name
        String fieldApiName = 'FirstName';

        Test.startTest();
        FObject obj = new FObject(Contact.SObjectType);
        Forceea.FieldInfo field = new Forceea.FieldInfo();
        field.fieldName = fieldApiName;
        field.fieldApiName = fieldApiName;
        new ForceeaDefinitionTypeHandler(obj).setDefinitionForField(field);
        Test.stopTest();

        String expectedResult = 'random type(firstName) group(name)';
        String actualResult = obj.getDefinitions(fieldApiName).get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
    }

    @IsTest
    private static void setDefinitionFromField_contactLastName_expectSuccess() {
        String fieldApiName = 'LastName';

        Test.startTest();
        FObject obj = new FObject(Contact.SObjectType);
        Forceea.FieldInfo field = new Forceea.FieldInfo();
        field.fieldName = fieldApiName;
        field.fieldApiName = fieldApiName;
        new ForceeaDefinitionTypeHandler(obj).setDefinitionForField(field);
        Test.stopTest();

        String expectedResult = 'random type(lastName) group(name)';
        String actualResult = obj.getDefinitions(fieldApiName).get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
    }

    @IsTest
    private static void setDefinitionFromField_leadCompany_expectSuccess() {
        String fieldApiName = 'Company';

        Test.startTest();
        FObject obj = new FObject('Lead');
        Forceea.FieldInfo field = new Forceea.FieldInfo();
        field.fieldName = fieldApiName;
        field.fieldApiName = fieldApiName;
        new ForceeaDefinitionTypeHandler(obj).setDefinitionForField(field);
        Test.stopTest();

        List<String> definitions = obj.getDefinitions(fieldApiName);
        String expectedResult = 'static value(Company-) serial type(number) from(1) step(1) scale(0)';
        String actualResult = definitions[0] + ' ' + definitions[1];
        System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
    }

    @IsTest
    private static void setDefinitionFromField_leadfirstName_expectSuccess() {
        String fieldApiName = 'firstName';

        Test.startTest();
        FObject obj = new FObject('Lead');
        Forceea.FieldInfo field = new Forceea.FieldInfo();
        field.fieldName = fieldApiName;
        field.fieldApiName = fieldApiName;
        new ForceeaDefinitionTypeHandler(obj).setDefinitionForField(field);
        Test.stopTest();

        String expectedResult = 'random type(firstName) group(name)';
        String actualResult = obj.getDefinitions(fieldApiName).get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
    }

    @IsTest
    private static void setDefinitionFromField_leadlastName_expectSuccess() {
        String fieldApiName = 'lastName';

        Test.startTest();
        FObject obj = new FObject('Lead');
        Forceea.FieldInfo field = new Forceea.FieldInfo();
        field.fieldName = fieldApiName;
        field.fieldApiName = fieldApiName;
        new ForceeaDefinitionTypeHandler(obj).setDefinitionForField(field);
        Test.stopTest();

        String expectedResult = 'random type(lastName) group(name)';
        String actualResult = obj.getDefinitions(fieldApiName).get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
    }

    @IsTest
    private static void setDefinitionFromField_opportunityName_expectSuccess() {
        String fieldApiName = 'Name';

        Test.startTest();
        FObject obj = new FObject('Opportunity');
        Forceea.FieldInfo field = new Forceea.FieldInfo();
        field.fieldName = fieldApiName;
        field.fieldApiName = fieldApiName;
        new ForceeaDefinitionTypeHandler(obj).setDefinitionForField(field);
        Test.stopTest();

        List<String> definitions = obj.getDefinitions(fieldApiName);
        String expectedResult = 'static value(Opportunity-) serial type(number) from(1) step(1) scale(0)';
        String actualResult = definitions[0] + ' ' + definitions[1];
        System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
    }

    @IsTest
    private static void setDefinitionFromField_boolean_expectSuccess() {
        String fieldApiName = 'TestCheckbox__c';

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        Forceea.FieldInfo field = new Forceea.FieldInfo();
        field.fieldName = fieldApiName;
        field.fieldApiName = fieldApiName;
        field.dataType = Schema.DisplayType.BOOLEAN;
        new ForceeaDefinitionTypeHandler(obj).setDefinitionForField(field);
        Test.stopTest();

        String expectedResult = 'random type(boolean)';
        String actualResult = obj.getDefinitions(fieldApiName).get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
    }

    @IsTest
    private static void setDefinitionFromField_combobox_expectSuccess() {
        String fieldApiName = 'Subject';

        Test.startTest();
        FObject obj = new FObject(Event.SObjectType);
        Forceea.FieldInfo field = new Forceea.FieldInfo();
        field.fieldName = fieldApiName;
        field.fieldApiName = fieldApiName;
        field.dataType = Schema.DisplayType.Combobox;
        new ForceeaDefinitionTypeHandler(obj).setDefinitionForField(field);
        Test.stopTest();

        String expectedResult = 'random type(picklist)';
        String actualResult = obj.getDefinitions(fieldApiName).get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
    }

    @IsTest
    private static void setDefinitionFromField_currency_expectSuccess() {
        String fieldApiName = 'TestCurrency__c';

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        Forceea.FieldInfo field = new Forceea.FieldInfo();
        field.fieldName = fieldApiName;
        field.fieldApiName = fieldApiName;
        field.dataType = Schema.DisplayType.Currency;
        new ForceeaDefinitionTypeHandler(obj).setDefinitionForField(field);
        Test.stopTest();

        String expectedResult = 'random type(number) from(1000) to(10000) scale(2)';
        String actualResult = obj.getDefinitions(fieldApiName).get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
    }

    @IsTest
    private static void setDefinitionFromField_date_expectSuccess() {
        String fieldApiName = 'TestDate__c';

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        Forceea.FieldInfo field = new Forceea.FieldInfo();
        field.fieldName = fieldApiName;
        field.fieldApiName = fieldApiName;
        field.dataType = Schema.DisplayType.Date;
        new ForceeaDefinitionTypeHandler(obj).setDefinitionForField(field);
        Test.stopTest();

        Integer thisYear = Date.today().year();
        String fromDate = String.valueOf(thisYear - 1) + '-01-01';
        String toDate = String.valueOf(thisYear + 1) + '-12-31';

        String expectedResult = 'random type(date) from(' + fromDate + ') to(' + toDate + ')';
        String actualResult = obj.getDefinitions(fieldApiName).get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
    }

    @IsTest
    private static void setDefinitionFromField_datetime_expectSuccess() {
        String fieldApiName = 'TestDatetime__c';

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        Forceea.FieldInfo field = new Forceea.FieldInfo();
        field.fieldName = fieldApiName;
        field.fieldApiName = fieldApiName;
        field.dataType = Schema.DisplayType.Datetime;
        new ForceeaDefinitionTypeHandler(obj).setDefinitionForField(field);
        Test.stopTest();

        Integer thisYear = Date.today().year();
        String fromDate = String.valueOf(thisYear - 1) + '-01-01';
        String toDate = String.valueOf(thisYear + 1) + '-12-31';

        String expectedResult = 'random type(datetime) from(' + fromDate + ') to(' + toDate + ')';
        String actualResult = obj.getDefinitions(fieldApiName).get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
    }

    @IsTest
    private static void setDefinitionFromField_time_expectSuccess() {
        String fieldApiName = 'TestTime__c';

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        Forceea.FieldInfo field = new Forceea.FieldInfo();
        field.fieldName = fieldApiName;
        field.fieldApiName = fieldApiName;
        field.dataType = Schema.DisplayType.Time;
        new ForceeaDefinitionTypeHandler(obj).setDefinitionForField(field);
        Test.stopTest();

        String expectedResult = 'random type(time) from(00:00:00) to(23:59:59)';
        String actualResult = obj.getDefinitions(fieldApiName).get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
    }

    @IsTest
    private static void setDefinitionFromField_double_expectSuccess() {
        String fieldApiName = 'TestDecimal__c';

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        Forceea.FieldInfo field = new Forceea.FieldInfo();
        field.fieldName = fieldApiName;
        field.fieldApiName = fieldApiName;
        field.dataType = Schema.DisplayType.Double;
        new ForceeaDefinitionTypeHandler(obj).setDefinitionForField(field);
        Test.stopTest();

        String expectedResult = 'random type(number) from(1000) to(10000) scale(3)';
        String actualResult = obj.getDefinitions(fieldApiName).get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
    }

    @IsTest
    private static void setDefinitionFromField_email_expectSuccess() {
        String fieldApiName = 'TestEmail__c';

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        Forceea.FieldInfo field = new Forceea.FieldInfo();
        field.fieldName = fieldApiName;
        field.fieldApiName = fieldApiName;
        field.dataType = Schema.DisplayType.EMAIL;
        new ForceeaDefinitionTypeHandler(obj).setDefinitionForField(field);
        Test.stopTest();

        String expectedResult = 'random type(email)';
        String actualResult = obj.getDefinitions(fieldApiName).get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
    }

    @IsTest
    private static void setDefinitionFromField_integer_expectSuccess() {
        String fieldApiName = 'TestInteger__c';

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        Forceea.FieldInfo field = new Forceea.FieldInfo();
        field.fieldName = fieldApiName;
        field.fieldApiName = fieldApiName;
        field.dataType = Schema.DisplayType.Integer;
        new ForceeaDefinitionTypeHandler(obj).setDefinitionForField(field);
        Test.stopTest();

        String expectedResult = 'random type(number) from(1) to(100) scale(0)';
        String actualResult = obj.getDefinitions(fieldApiName).get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
    }

    @IsTest
    private static void setDefinitionFromField_multiPicklist_expectSuccess() {
        String fieldApiName = 'TestMultiPicklistA__c';

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        Forceea.FieldInfo field = new Forceea.FieldInfo();
        field.fieldName = fieldApiName;
        field.fieldApiName = fieldApiName;
        field.dataType = Schema.DisplayType.MultiPicklist;
        new ForceeaDefinitionTypeHandler(obj).setDefinitionForField(field);
        Test.stopTest();

        String expectedResult = 'random type(picklist)';
        String actualResult = obj.getDefinitions(fieldApiName).get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
    }

    @IsTest
    private static void setDefinitionFromField_percent_expectSuccess() {
        String fieldApiName = 'TestPercent__c';

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        Forceea.FieldInfo field = new Forceea.FieldInfo();
        field.fieldName = fieldApiName;
        field.fieldApiName = fieldApiName;
        field.dataType = Schema.DisplayType.Percent;
        new ForceeaDefinitionTypeHandler(obj).setDefinitionForField(field);
        Test.stopTest();

        String expectedResult = 'random type(number) from(0) to(100) scale(2)';
        String actualResult = obj.getDefinitions(fieldApiName).get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
    }

    @IsTest
    private static void setDefinitionFromField_picklist_expectSuccess() {
        String fieldApiName = 'TestPicklistA__c';

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        Forceea.FieldInfo field = new Forceea.FieldInfo();
        field.fieldName = fieldApiName;
        field.fieldApiName = fieldApiName;
        field.dataType = Schema.DisplayType.MultiPicklist;
        new ForceeaDefinitionTypeHandler(obj).setDefinitionForField(field);
        Test.stopTest();

        String expectedResult = 'random type(picklist)';
        String actualResult = obj.getDefinitions(fieldApiName).get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
    }

    @IsTest
    private static void setDefinitionFromField_phone_expectSuccess() {
        String fieldApiName = 'TestPhone__c';

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        Forceea.FieldInfo field = new Forceea.FieldInfo();
        field.fieldName = fieldApiName;
        field.fieldApiName = fieldApiName;
        field.dataType = Schema.DisplayType.Phone;
        new ForceeaDefinitionTypeHandler(obj).setDefinitionForField(field);
        Test.stopTest();

        String expectedResult = 'random type(phone) format(DD dDD dd-DD-DDD)';
        String actualResult = obj.getDefinitions(fieldApiName).get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
    }

    @IsTest
    private static void setDefinitionFromField_reference_expectSuccess() {
        String fieldApiName = 'TestLookup__c';
        Schema.SObjectType parentType = Schema.FObjectTwo__c.getSObjectType();
        List<Schema.SObjectType> parents = new List<Schema.SObjectType>{
            parentType
        };

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        Forceea.FieldInfo field = new Forceea.FieldInfo();
        field.fieldName = fieldApiName;
        field.fieldApiName = fieldApiName;
        field.dataType = Schema.DisplayType.Reference;
        field.parents = parents;
        new ForceeaDefinitionTypeHandler(obj).setDefinitionForField(field);
        Test.stopTest();

        String expectedResult = 'random lookup(FObjectTwo__c) source(forceea)';
        String actualResult = obj.getDefinitions(fieldApiName).get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
    }

    @IsTest
    private static void setDefinitionFromField_string_expectSuccess() {
        String fieldApiName = 'TestText__c';

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        Forceea.FieldInfo field = new Forceea.FieldInfo();
        field.fieldName = fieldApiName;
        field.fieldApiName = fieldApiName;
        field.length = 20;
        field.dataType = Schema.DisplayType.STRING;
        new ForceeaDefinitionTypeHandler(obj).setDefinitionForField(field);
        Test.stopTest();

        String expectedResult = 'random type(string) minLength(5) maxLength(20) startWith(upper) include(lower,upper)';
        String actualResult = obj.getDefinitions(fieldApiName).get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
    }

    @IsTest
    private static void setDefinitionFromField_textArea_expectSuccess() {
        String fieldApiName = 'TestTextArea__c';

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        Forceea.FieldInfo field = new Forceea.FieldInfo();
        field.fieldName = fieldApiName;
        field.fieldApiName = fieldApiName;
        field.dataType = Schema.DisplayType.TextArea;
        new ForceeaDefinitionTypeHandler(obj).setDefinitionForField(field);
        Test.stopTest();

        String expectedResult = 'random type(text) minLength(30) maxLength(100)';
        String actualResult = obj.getDefinitions(fieldApiName).get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
    }

    @IsTest
    private static void setDefinitionFromField_url_expectSuccess() {
        String fieldApiName = 'TestUrl__c';

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        Forceea.FieldInfo field = new Forceea.FieldInfo();
        field.fieldName = fieldApiName;
        field.fieldApiName = fieldApiName;
        field.dataType = Schema.DisplayType.URL;
        new ForceeaDefinitionTypeHandler(obj).setDefinitionForField(field);
        Test.stopTest();

        String expectedResult = 'random type(url)';
        String actualResult = obj.getDefinitions(fieldApiName).get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
    }

    @IsTest
    private static void setDefinitionsOfRequiredFieldsForUser_withoutUserDefinitions_expectSuccess() {
        List<String> fields = new List<String>{
            'Alias', 'FirstName', 'LastName', 'Username', 'Email', 'EmailEncodingKey',
            'TimeZonesIdKey', 'LocalesIdKey', 'LanguageLocaleKey', 'ProfileId'
        };

        List<String> expectedDefinitions = new List<String>();
        expectedDefinitions.add('random type(string) minLength(8) maxLength(8) startWith(upper) include(lower)');
        expectedDefinitions.add('random type(firstName) group(name)');
        expectedDefinitions.add('random type(lastName) group(name)');
        expectedDefinitions.add('random type(email)');
        expectedDefinitions.add('copy field(Username)');
        expectedDefinitions.add('static value(UTF-8)');
        expectedDefinitions.add('static value(GMT)');
        expectedDefinitions.add('static value(en_US)');
        expectedDefinitions.add('static value(en_US)');
        expectedDefinitions.add('static lookup(profile) field(name) value(Standard User) source(salesforce)');

        Test.startTest();
        FObject obj = new FObject(User.SObjectType, 1)
            .setRequiredFields(true);
        obj.getRecords();
        Test.stopTest();

        List<String> actualDefinitions = new List<String>();
        for (String fieldApiName : fields) {
            actualDefinitions.add(obj.getDefinitions(fieldApiName).get(0));
        }

        Boolean isValid = actualDefinitions.hashCode() == expectedDefinitions.hashCode();
        System.assert(isValid, 'setDefinitionsOfRequiredFieldsForUser - errors found');
    }

    @IsTest
    private static void setDefinitionsOfRequiredFieldsForUser_withUserDefinitions_expectSuccess() {
        List<String> fields = new List<String>{
            'Alias', 'FirstName', 'LastName', 'Username', 'Email', 'EmailEncodingKey',
            'TimeZonesIdKey', 'LocalesIdKey', 'LanguageLocaleKey', 'ProfileId'
        };

        List<String> expectedDefinitions = new List<String>();
        expectedDefinitions.add('static value(alias)');
        expectedDefinitions.add('static value(first)');
        expectedDefinitions.add('static value(last)');
        expectedDefinitions.add('static value(user@domain1.com)');
        expectedDefinitions.add('static value(user@domain2.com)');
        expectedDefinitions.add('static value(ISO-8859-1)');
        expectedDefinitions.add('static value(Australia/Sydney)');
        expectedDefinitions.add('static value(en_GB)');
        expectedDefinitions.add('static value(da)');
        expectedDefinitions.add('static lookup(profile) field(name) value(System Administrator) source(salesforce)');

        Test.startTest();
        FObject obj = new FObject(User.SObjectType, 1);
        for (Integer counter = 0; counter < fields.size(); counter++) {
            obj.setDefinition(fields.get(counter), expectedDefinitions.get(counter));
        }
        obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        List<String> actualDefinitions = new List<String>();
        for (String fieldApiName : fields) {
            actualDefinitions.add(obj.getDefinitions(fieldApiName).get(0));
            if (obj.getDefinitions(fieldApiName).size() > 1) {
                errors++;
            }
        }
        if (actualDefinitions.hashCode() != expectedDefinitions.hashCode()) {
            errors += 16;
        }
        System.assertEquals(0, errors, 'setDefinitionsOfRequiredFieldsForUser - errors found');
    }

}