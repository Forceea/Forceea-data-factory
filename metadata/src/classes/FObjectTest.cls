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

/**
 * @description FObject Test Class
 */
@IsTest
public class FObjectTest {

    /* createRecords */

    @IsTest
    private static void createRecords_canInsertUsersDefault_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject('User', 1);
        Test.stopTest();

        System.assert(FObject.processIsValid() && !obj.canInsertUsers, 'createRecords - errors found');
    }

    @IsTest
    private static void createRecords_canInsertUsersSetTrue_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject('User', 1);
        obj.canInsertUsers(true);
        Test.stopTest();

        System.assert(FObject.processIsValid() && obj.canInsertUsers, 'createRecords - errors found');
    }

    @IsTest
    private static void createRecords_getRecordsBeforeInsertRecords_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c', 10);
        obj.setDefinition('TestInteger__c', 'serial type(number) from(1) step(1) scale(0)');
        obj.createRecords();
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        obj.insertRecords(true);
        Test.stopTest();

        Integer errors = 0;
        Set<Id> recordIdsSet = (new Map<Id, SObject>(records)).keySet();

        for (FObjectOne__c objRecord : [SELECT Id FROM FObjectOne__c LIMIT 1000]) {
            if (!recordIdsSet.contains(objRecord.Id)) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'createRecords - errors found');
    }

    @IsTest
    private static void createRecords_insertRecordsBeforeGetRecords_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c', 10);
        obj.setDefinition('TestInteger__c', 'serial type(number) from(1) step(1) scale(0)')
            .createRecords();
        obj.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Set<Id> recordIdsSet = (new Map<Id, SObject>(records)).keySet();
        for (FObjectOne__c objRecord : [SELECT Id FROM FObjectOne__c LIMIT 1000]) {
            if (!recordIdsSet.contains(objRecord.Id)) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'createRecords - errors found');
    }

    @IsTest
    private static void createRecords_callOnceAfterInsertRecords_expectSuccess() {
        Integer size1 = 201;
        Integer size2 = 100;

        Test.startTest();

        FObject obj = new FObject('FObjectOne__c', size1);
        obj.setDefinition('TestInteger__c', 'serial type(number) from(1) step(1) scale(0)')
            .createRecords()
            .insertRecords(true);
        List<FObjectOne__c> insertedRecords1 = [SELECT Id, TestInteger__c FROM FObjectOne__c LIMIT 1000];

        obj.setNumberOfRecords(size2)
            .createRecords();
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();

        Test.stopTest();

        Integer errors = 0;
        if (insertedRecords1.size() != size1) {
            errors += 1;
        }
        if (records.size() != size2) {
            errors += 2;
        }
        if (records[size2 - 1].TestInteger__c != (size1 + size2)) {
            errors += 4;
        }
        if (!FObject.processIsValid()) {
            errors += 8;
        }
        System.assertEquals(0, errors, 'createRecords - errors found');
    }

    @IsTest
    private static void createRecords_callTwiceAfterInsertRecords_expectSuccess() {
        Integer size1 = 10;
        Integer size2 = 5;
        Integer size3 = 2;

        Test.startTest();

        FObject obj = new FObject('FObjectOne__c', size1);
        obj.setDefinition('TestInteger__c', 'serial type(number) from(1) step(1) scale(0)')
            .createRecords();
        List<Database.SaveResult> saveResults1 = obj.insertRecords(true);

        obj.setNumberOfRecords(size2).createRecords();
        obj.setNumberOfRecords(size3).createRecords();

        List<Database.SaveResult> saveResults2 = obj.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();

        Test.stopTest();

        List<FObjectOne__c> insertedRecords = [SELECT Id, TestInteger__c FROM FObjectOne__c LIMIT 1000];
        Integer errors = 0;
        if (saveResults1.size() != size1) {
            errors += 1;
        }
        if (saveResults2.size() != (size2 + size3)) {
            errors += 2;
        }
        if (insertedRecords.size() != (size1 + size2 + size3)) {
            errors += 4;
        }
        if (records.size() != size3) {
            errors += 8;
        }
        if (records[size3 - 1].TestInteger__c != (size1 + size2 + size3)) {
            errors += 16;
        }
        if (!FObject.processIsValid()) {
            errors += 16;
        }
        System.assertEquals(0, errors, 'createRecords - errors found');
    }

    @IsTest
    private static void createRecords_discontinuousRecordNumber_expectSuccess() {
        Integer size1 = 21;
        Integer size2 = 10;

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c', size1);
        obj.setDefinition('TestInteger__c', 'serial type(number) from(1) step(1) scale(0)')
            .createRecords();
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj.getRecords();
        obj.setNumberOfRecords(size2);
        obj.createRecords(size1 + 2);
        List<FObjectOne__c> records2 = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        records2.addAll(records1);
        Integer errors = 0;
        for (FObjectOne__c objRecord : records2) {
            if (objRecord.TestInteger__c == size1 + 1) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'createRecords - errors found');
    }

    @IsTest
    private static void createRecords_invalidRecordNumber_expectFailure() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c', 10);
        obj.createRecords(0);
        Test.stopTest();

        System.assert(!FObject.processIsValid(), 'createRecords - errors found');
    }

    @IsTest
    private static void createRecords_noDefinitions_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c', 10);
        obj.createRecords();
        List<Database.SaveResult> saveResults = obj.insertRecords(true);
        Test.stopTest();

        Integer errors = 0;
        for (Database.SaveResult sr : saveResults) {
            if (!sr.isSuccess()) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'insertRecords - errors found');
    }

    @IsTest
    private static void createRecords_validateDefaultQueryLimit_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestInteger__c', 'serial type(number) from(1) step(1) scale(0)');
        Test.stopTest();

        System.assert(obj.queryLimit == FObject.DEFAULT_QUERY_LIMIT, 'createRecords - errors found');
    }

    // query LIMIT

    @IsTest
    private static void createRecords_validateQueryLimitLessThanMin_expectSuccess() {
        Integer myLimit = 0;

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c')
            .setQueryLimit(myLimit);
        Test.stopTest();

        System.assert(obj.queryLimit == 1, 'createRecords - errors found');
    }

    @IsTest
    private static void createRecords_validateQueryLimitMoreThanMax_expectSuccess() {
        Integer myLimit = 11000;

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c')
            .setQueryLimit(myLimit);
        Test.stopTest();

        System.assert(obj.queryLimit == 10000, 'createRecords - errors found');
    }

    @IsTest
    private static void createRecords_validateQueryLimit_expectSuccess() {
        Integer myLimit = 200;

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c')
            .setQueryLimit(myLimit);
        Test.stopTest();

        System.assert(obj.queryLimit == myLimit, 'createRecords - errors found');
    }

    @IsTest
    private static void createRecords_validateGlobalQueryLimitLessThanMin_expectSuccess() {
        Integer myLimit = 0;

        FObject.setGlobalQueryLimit(myLimit);
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        Test.stopTest();

        System.assert(obj.queryLimit == 1, 'createRecords - errors found');
    }

    @IsTest
    private static void createRecords_validateGlobalQueryLimitMoreThanMax_expectSuccess() {
        Integer myLimit = 11000;

        FObject.setGlobalQueryLimit(myLimit);
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        Test.stopTest();

        System.assert(obj.queryLimit == 10000, 'createRecords - errors found');
    }

    @IsTest
    private static void createRecords_validateGlobalQueryLimit_expectSuccess() {
        Integer myLimit = 200;

        FObject.setGlobalQueryLimit(myLimit);
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        Test.stopTest();

        System.assert(obj.queryLimit == myLimit, 'createRecords - errors found');
    }

    @IsTest
    private static void createRecords_validateRecordNumber_expectSuccess() {
        Integer size1 = 20;
        Integer size2 = 10;

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c', size1);
        obj.setDefinition(FObjectOne__c.TestInteger__c, 'serial type(number) from(1) step(1) scale(0)');
        obj.createRecords();
        obj.setNumberOfRecords(size2);
        obj.createRecords(size1 + 1);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        if (records[size2 - 1].TestInteger__c != (size1 + size2)) {
            errors++;
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'createRecords - errors found');
    }

    /* definitionIsValidForFieldDataType */

    @IsTest
    private static void definitionIsValidForFieldDataType_base64_expectFailure() {
        String fieldApiName = 'Body';

        List<String> validDefinitions = new List<String>();
        validDefinitions.add('Copy Field(TestPicklistD__c)');
        validDefinitions.add('Copy Field(TestLookup__c) From(FObjectTwo__c.TestText__c)');
        validDefinitions.add('Random Type(Boolean)');
        validDefinitions.add('Random Type(City) Group(one)');
        validDefinitions.add('Random Type(Country) Group(one)');
        validDefinitions.add('Random Type(Date) From(2017-01-01) To(2017-12-31)');
        validDefinitions.add('Random Type(Datetime) From(2017-01-01) To(2017-12-31)');
        validDefinitions.add('Random Type(Email)');
        validDefinitions.add('Random Type(Phone) Format(30 210 dD DD ddD)');
        validDefinitions.add('Random Type(FirstName) Group(one)');
        validDefinitions.add('Random Type(LastName) Group(one)');
        validDefinitions.add('Random Type(List) Value(1, 2, 3)');
        validDefinitions.add('Random Type(List) Value(1.1, 2.2, 3.3)');
        validDefinitions.add('Random Type(List) Value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
        validDefinitions.add('Random Type(List) Value(2017-01-01, 2017-02-02, 2017-03-03)');
        validDefinitions.add('Random Type(List) Value(One, Two, Three)');
        validDefinitions.add('Random Type(Number) From(1) To(100) Scale(0)');
        validDefinitions.add('Random Type(Postalcode) Group(one)');
        validDefinitions.add('Random Type(State) Group(one)');
        validDefinitions.add('Random Type(Street) Group(one)');
        validDefinitions.add('Random Type(String) Minlength(10) Maxlength(30) Startwith(Lower) Include(Lower,Upper,Digit)');
        validDefinitions.add('Random Type(Text) Minlength(10) Maxlength(30)');
        validDefinitions.add('Random Type(Url)');
        validDefinitions.add('Serial Type(Date) From(2017-01-01) Step(2)');
        validDefinitions.add('Serial Type(Datetime) From(2017-01-01 02:02:02) Step(2.2)');
        validDefinitions.add('Serial Type(Number) From(10.2) Step(1.2) Scale(2)');
        validDefinitions.add('Static Value(01:01:01)');
        validDefinitions.add('Static Value(10.1)');
        validDefinitions.add('Static Value(10)');
        validDefinitions.add('Static Value(2017-01-01 01:01:01)');
        validDefinitions.add('Static Value(2017-01-01)');
        validDefinitions.add('Static Value(One)');

        List<String> invalidDefinitions = new List<String>();
        invalidDefinitions.add('Mock type(id)');
        invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Except(One,Two,Three) Source(Forceea)');
        invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Value(One,Two,Three) Source(Forceea)');
        invalidDefinitions.add('Random Lookup(Account) Source(Forceea)');
        invalidDefinitions.add('Random lookup(Account) Where(Rating = \'Hot\') source(salesforce)');
        invalidDefinitions.add('Random Type(Picklist) Except(One,Two)');
        invalidDefinitions.add('Random Type(Picklist)');
        invalidDefinitions.add('Serial Lookup(Account) mode(cyclical) source(forceea)');
        invalidDefinitions.add('Static Lookup(Account) Field(FieldOne) Value(One) Source(Forceea)');

        Test.startTest();
        Boolean expectedResult = false;
        Boolean actualResult = definitionsAreValid(
            new FObject('Attachment'), fieldApiName, validDefinitions, invalidDefinitions);
        Test.stopTest();

        System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
    }

    @IsTest
    private static void definitionIsValidForFieldDataType_boolean_expectFailure() {
        String fieldApiName = 'TestCheckbox__c';

        List<String> validDefinitions = new List<String>();
        validDefinitions.add('Copy Field(TestPicklistD__c)');
        validDefinitions.add('Copy Field(TestLookup__c) From(FObjectTwo__c.TestText__c)');
        validDefinitions.add('Random Type(Boolean)');
        validDefinitions.add('Random Type(List) Value(One, Two, Three)');
        validDefinitions.add('Static Value(One)');

        List<String> invalidDefinitions = new List<String>();
        invalidDefinitions.add('Mock type(id)');
        invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Except(One,Two,Three) Source(Forceea)');
        invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Value(One,Two,Three) Source(Forceea)');
        invalidDefinitions.add('Random Lookup(Account) Source(Forceea)');
        invalidDefinitions.add('Random lookup(Account) Where(Rating = \'Hot\') source(salesforce)');
        invalidDefinitions.add('Random Type(City) Group(one)');
        invalidDefinitions.add('Random Type(Country) Group(one)');
        invalidDefinitions.add('Random Type(Date) From(2017-01-01) To(2017-12-31)');
        invalidDefinitions.add('Random Type(Datetime) From(2017-01-01) To(2017-12-31)');
        invalidDefinitions.add('Random Type(Email)');
        invalidDefinitions.add('Random Type(Phone) Format(30 210 dD DD ddD)');
        invalidDefinitions.add('Random Type(FirstName) Group(one)');
        invalidDefinitions.add('Random Type(LastName) Group(one)');
        invalidDefinitions.add('Random Type(List) Value(1, 2, 3)');
        invalidDefinitions.add('Random Type(List) Value(1.1, 2.2, 3.3)');
        invalidDefinitions.add('Random Type(List) Value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
        invalidDefinitions.add('Random Type(List) Value(2017-01-01, 2017-02-02, 2017-03-03)');
        invalidDefinitions.add('Random Type(Picklist) Except(One,Two)');
        invalidDefinitions.add('Random Type(Picklist)');
        invalidDefinitions.add('Random Type(Postalcode) Group(one)');
        invalidDefinitions.add('Random Type(State) Group(one)');
        invalidDefinitions.add('Random Type(Street) Group(one)');
        invalidDefinitions.add('Random Type(String) Minlength(10) Maxlength(30) Startwith(Lower) Include(Lower,Upper,Digit)');
        invalidDefinitions.add('Random Type(Text) Minlength(10) Maxlength(30)');
        invalidDefinitions.add('Random Type(Url)');
        invalidDefinitions.add('Serial Lookup(Account) mode(cyclical) source(forceea)');
        invalidDefinitions.add('Serial Type(Date) From(2017-01-01) Step(2)');
        invalidDefinitions.add('Serial Type(Datetime) From(2017-01-01 02:02:02) Step(2.2)');
        invalidDefinitions.add('Serial Type(Number) From(10.2) Step(1.2) Scale(2)');
        invalidDefinitions.add('Static Lookup(Account) Field(FieldOne) Value(One) Source(Forceea)');
        invalidDefinitions.add('Static Value(01:01:01)');
        invalidDefinitions.add('Static Value(10.1)');
        invalidDefinitions.add('Static Value(10)');
        invalidDefinitions.add('Static Value(2017-01-01 01:01:01)');
        invalidDefinitions.add('Static Value(2017-01-01)');
        invalidDefinitions.add('Random Type(Number) From(1) To(100) Scale(0)');

        Test.startTest();
        Boolean expectedResult = false;
        Boolean actualResult = definitionsAreValid(
            new FObject('FObjectOne__c'), fieldApiName, validDefinitions, invalidDefinitions);
        Test.stopTest();

        System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
    }

    @IsTest
    private static void definitionIsValidForFieldDataType_combobox_expectFailure() {
        String fieldApiName = 'Subject';

        List<String> validDefinitions = new List<String>();
        validDefinitions.add('Copy Field(WhoId)');
        validDefinitions.add('Random Type(Boolean)');
        validDefinitions.add('Random Type(City) Group(one)');
        validDefinitions.add('Random Type(Country) Group(one)');
        validDefinitions.add('Random Type(Date) From(2017-01-01) To(2017-12-31)');
        validDefinitions.add('Random Type(Datetime) From(2017-01-01) To(2017-12-31)');
        validDefinitions.add('Random Type(Email)');
        validDefinitions.add('Random Type(Phone) Format(30 210 dD DD ddD)');
        validDefinitions.add('Random Type(FirstName) Group(one)');
        validDefinitions.add('Random Type(LastName) Group(one)');
        validDefinitions.add('Random Type(List) Value(1, 2, 3)');
        validDefinitions.add('Random Type(List) Value(1.1, 2.2, 3.3)');
        validDefinitions.add('Random Type(List) Value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
        validDefinitions.add('Random Type(List) Value(2017-01-01, 2017-02-02, 2017-03-03)');
        validDefinitions.add('Random Type(List) Value(One, Two, Three)');
        validDefinitions.add('Random Type(Number) From(1) To(100) Scale(0)');
        validDefinitions.add('random type(picklist) except(One,Two)');
        validDefinitions.add('Random Type(Picklist)');
        validDefinitions.add('Random Type(Postalcode) Group(one)');
        validDefinitions.add('Random Type(State) Group(one)');
        validDefinitions.add('Random Type(Street) Group(one)');
        validDefinitions.add('Random Type(String) Minlength(10) Maxlength(30) Startwith(Lower) Include(Lower,Upper,Digit)');
        validDefinitions.add('Random Type(Text) Minlength(10) Maxlength(30)');
        validDefinitions.add('Random Type(Url)');
        validDefinitions.add('Serial Type(Date) From(2017-01-01) Step(2)');
        validDefinitions.add('Serial Type(Datetime) From(2017-01-01 02:02:02) Step(2.2)');
        validDefinitions.add('Serial Type(Number) From(10.2) Step(1.2) Scale(2)');
        validDefinitions.add('Static Value(01:01:01)');
        validDefinitions.add('Static Value(10.1)');
        validDefinitions.add('Static Value(10)');
        validDefinitions.add('Static Value(2017-01-01 01:01:01)');
        validDefinitions.add('Static Value(2017-01-01)');
        validDefinitions.add('Static Value(One)');

        List<String> invalidDefinitions = new List<String>();
        invalidDefinitions.add('Mock type(id)');
        invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Except(One,Two,Three) Source(Forceea)');
        invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Value(One,Two,Three) Source(Forceea)');
        invalidDefinitions.add('Random Lookup(Account) Source(Forceea)');
        invalidDefinitions.add('Random lookup(Account) Where(Rating = \'Hot\') source(salesforce)');
        invalidDefinitions.add('Serial Lookup(Account) mode(cyclical) source(forceea)');
        invalidDefinitions.add('Static Lookup(Account) Field(FieldOne) Value(One) Source(Forceea)');

        Test.startTest();
        Boolean expectedResult = false;
        Boolean actualResult = definitionsAreValid(
            new FObject('Event'), fieldApiName, validDefinitions, invalidDefinitions);
        Test.stopTest();

        System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
    }

    @IsTest
    private static void definitionIsValidForFieldDataType_currency_expectFailure() {
        String fieldApiName = 'TestCurrency__c';

        List<String> validDefinitions = new List<String>();
        validDefinitions.add('Copy Field(TestPicklistD__c)');
        validDefinitions.add('Copy Field(TestLookup__c) From(FObjectTwo__c.TestText__c)');
        validDefinitions.add('Random Type(List) Value(1, 2, 3)');
        validDefinitions.add('Random Type(List) Value(1.1, 2.2, 3.3)');
        validDefinitions.add('Random Type(Number) From(1) To(100) Scale(0)');
        validDefinitions.add('Serial Type(Number) From(10.2) Step(1.2) Scale(2)');
        validDefinitions.add('Static Value(10.1)');
        validDefinitions.add('Static Value(10)');

        List<String> invalidDefinitions = new List<String>();
        invalidDefinitions.add('Mock type(id)');
        invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Except(One,Two,Three) Source(Forceea)');
        invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Value(One,Two,Three) Source(Forceea)');
        invalidDefinitions.add('Random Lookup(Account) Source(Forceea)');
        invalidDefinitions.add('Random lookup(Account) Where(Rating = \'Hot\') source(salesforce)');
        invalidDefinitions.add('Random Type(Boolean)');
        invalidDefinitions.add('Random Type(City) Group(one)');
        invalidDefinitions.add('Random Type(Country) Group(one)');
        invalidDefinitions.add('Random Type(Date) From(2017-01-01) To(2017-12-31)');
        invalidDefinitions.add('Random Type(Datetime) From(2017-01-01) To(2017-12-31)');
        invalidDefinitions.add('Random Type(Email)');
        invalidDefinitions.add('Random Type(Phone) Format(30 210 dD DD ddD)');
        invalidDefinitions.add('Random Type(FirstName) Group(one)');
        invalidDefinitions.add('Random Type(LastName) Group(one)');
        invalidDefinitions.add('Random Type(List) Value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
        invalidDefinitions.add('Random Type(List) Value(2017-01-01, 2017-02-02, 2017-03-03)');
        invalidDefinitions.add('Random Type(List) Value(One, Two, Three)');
        invalidDefinitions.add('Random Type(Picklist) Except(One,Two)');
        invalidDefinitions.add('Random Type(Picklist)');
        invalidDefinitions.add('Random Type(Postalcode) Group(one)');
        invalidDefinitions.add('Random Type(State) Group(one)');
        invalidDefinitions.add('Random Type(Street) Group(one)');
        invalidDefinitions.add('Random Type(String) Minlength(10) Maxlength(30) Startwith(Lower) Include(Lower,Upper,Digit)');
        invalidDefinitions.add('Random Type(Text) Minlength(10) Maxlength(30)');
        invalidDefinitions.add('Random Type(Url)');
        invalidDefinitions.add('Serial Lookup(Account) mode(cyclical) source(forceea)');
        invalidDefinitions.add('Serial Type(Date) From(2017-01-01) Step(2)');
        invalidDefinitions.add('Serial Type(Datetime) From(2017-01-01 02:02:02) Step(2.2)');
        invalidDefinitions.add('Static Lookup(Account) Field(FieldOne) Value(One) Source(Forceea)');
        invalidDefinitions.add('Static Value(01:01:01)');
        invalidDefinitions.add('Static Value(2017-01-01 01:01:01)');
        invalidDefinitions.add('Static Value(2017-01-01)');
        invalidDefinitions.add('Static Value(One)');

        Test.startTest();
        Boolean expectedResult = false;
        Boolean actualResult = definitionsAreValid(
            new FObject('FObjectOne__c'), fieldApiName, validDefinitions, invalidDefinitions);
        Test.stopTest();

        System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
    }

    @IsTest
    private static void definitionIsValidForFieldDataType_date_expectFailure() {
        String fieldApiName = 'TestDate__c';

        List<String> validDefinitions = new List<String>();
        validDefinitions.add('Copy Field(TestPicklistD__c)');
        validDefinitions.add('Copy Field(TestLookup__c) From(FObjectTwo__c.TestText__c)');
        validDefinitions.add('Random Type(Date) From(2017-01-01) To(2017-12-31)');
        validDefinitions.add('Random Type(List) Value(2017-01-01, 2017-02-02, 2017-03-03)');
        validDefinitions.add('Serial Type(Date) From(2017-01-01) Step(2)');
        validDefinitions.add('Static Value(2017-01-01)');

        List<String> invalidDefinitions = new List<String>();
        invalidDefinitions.add('Mock type(id)');
        invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Except(One,Two,Three) Source(Forceea)');
        invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Value(One,Two,Three) Source(Forceea)');
        invalidDefinitions.add('Random Lookup(Account) Source(Forceea)');
        invalidDefinitions.add('Random lookup(Account) Where(Rating = \'Hot\') source(salesforce)');
        invalidDefinitions.add('Random Type(Boolean)');
        invalidDefinitions.add('Random Type(City) Group(one)');
        invalidDefinitions.add('Random Type(Country) Group(one)');
        invalidDefinitions.add('Random Type(Datetime) From(2017-01-01) To(2017-12-31)');
        invalidDefinitions.add('Random Type(Email)');
        invalidDefinitions.add('Random Type(Phone) Format(30 210 dD DD ddD)');
        invalidDefinitions.add('Random Type(FirstName) Group(one)');
        invalidDefinitions.add('Random Type(LastName) Group(one)');
        invalidDefinitions.add('Random Type(List) Value(1, 2, 3)');
        invalidDefinitions.add('Random Type(List) Value(1.1, 2.2, 3.3)');
        invalidDefinitions.add('Random Type(List) Value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
        invalidDefinitions.add('Random Type(List) Value(One, Two, Three)');
        invalidDefinitions.add('Random Type(Number) From(1) To(100) Scale(0)');
        invalidDefinitions.add('Random Type(Picklist) Except(One,Two)');
        invalidDefinitions.add('Random Type(Picklist)');
        invalidDefinitions.add('Random Type(Postalcode) Group(one)');
        invalidDefinitions.add('Random Type(State) Group(one)');
        invalidDefinitions.add('Random Type(Street) Group(one)');
        invalidDefinitions.add('Random Type(String) Minlength(10) Maxlength(30) Startwith(Lower) Include(Lower,Upper,Digit)');
        invalidDefinitions.add('Random Type(Text) Minlength(10) Maxlength(30)');
        invalidDefinitions.add('Random Type(Url)');
        invalidDefinitions.add('Serial Lookup(Account) mode(cyclical) source(forceea)');
        invalidDefinitions.add('Serial Type(Datetime) From(2017-01-01 02:02:02) Step(2.2)');
        invalidDefinitions.add('Serial Type(Number) From(10.2) Step(1.2) Scale(2)');
        invalidDefinitions.add('Static Lookup(Account) Field(FieldOne) Value(One) Source(Forceea)');
        invalidDefinitions.add('Static Value(01:01:01)');
        invalidDefinitions.add('Static Value(10.1)');
        invalidDefinitions.add('Static Value(10)');
        invalidDefinitions.add('Static Value(2017-01-01 01:01:01)');
        invalidDefinitions.add('Static Value(One)');

        Test.startTest();
        Boolean expectedResult = false;
        Boolean actualResult = definitionsAreValid(
            new FObject('FObjectOne__c'), fieldApiName, validDefinitions, invalidDefinitions);
        Test.stopTest();

        System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
    }

    @IsTest
    private static void definitionIsValidForFieldDataType_datetime_expectFailure() {
        String fieldApiName = 'TestDatetime__c';

        List<String> validDefinitions = new List<String>();
        validDefinitions.add('Copy Field(TestPicklistD__c)');
        validDefinitions.add('Copy Field(TestLookup__c) From(FObjectTwo__c.TestText__c)');
        validDefinitions.add('Random Type(Datetime) From(2017-01-01) To(2017-12-31)');
        validDefinitions.add('Random Type(List) Value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
        validDefinitions.add('Random Type(List) Value(2017-01-01, 2017-02-02, 2017-03-03)');
        validDefinitions.add('Serial Type(Date) From(2017-01-01) Step(2)');
        validDefinitions.add('Serial Type(Datetime) From(2017-01-01 02:02:02) Step(2.2)');
        validDefinitions.add('Static Value(2017-01-01 01:01:01)');

        List<String> invalidDefinitions = new List<String>();
        invalidDefinitions.add('Mock type(id)');
        invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Except(One,Two,Three) Source(Forceea)');
        invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Value(One,Two,Three) Source(Forceea)');
        invalidDefinitions.add('Random Lookup(Account) Source(Forceea)');
        invalidDefinitions.add('Random lookup(Account) Where(Rating = \'Hot\') source(salesforce)');
        invalidDefinitions.add('Random Type(Boolean)');
        invalidDefinitions.add('Random Type(City) Group(one)');
        invalidDefinitions.add('Random Type(Country) Group(one)');
        invalidDefinitions.add('Random Type(Date) From(2017-01-01) To(2017-12-31)');
        invalidDefinitions.add('Random Type(Email)');
        invalidDefinitions.add('Random Type(Phone) Format(30 210 dD DD ddD)');
        invalidDefinitions.add('Random Type(FirstName) Group(one)');
        invalidDefinitions.add('Random Type(LastName) Group(one)');
        invalidDefinitions.add('Random Type(List) Value(1, 2, 3)');
        invalidDefinitions.add('Random Type(List) Value(1.1, 2.2, 3.3)');
        invalidDefinitions.add('Random Type(List) Value(One, Two, Three)');
        invalidDefinitions.add('Random Type(Number) From(1) To(100) Scale(0)');
        invalidDefinitions.add('Random Type(Picklist) Except(One,Two)');
        invalidDefinitions.add('Random Type(Picklist)');
        invalidDefinitions.add('Random Type(Postalcode) Group(one)');
        invalidDefinitions.add('Random Type(State) Group(one)');
        invalidDefinitions.add('Random Type(Street) Group(one)');
        invalidDefinitions.add('Random Type(String) Minlength(10) Maxlength(30) Startwith(Lower) Include(Lower,Upper,Digit)');
        invalidDefinitions.add('Random Type(Text) Minlength(10) Maxlength(30)');
        invalidDefinitions.add('Random Type(Url)');
        invalidDefinitions.add('Serial Lookup(Account) mode(cyclical) source(forceea)');
        invalidDefinitions.add('Serial Type(Number) From(10.2) Step(1.2) Scale(2)');
        invalidDefinitions.add('Static Lookup(Account) Field(FieldOne) Value(One) Source(Forceea)');
        invalidDefinitions.add('Static Value(01:01:01)');
        invalidDefinitions.add('Static Value(10.1)');
        invalidDefinitions.add('Static Value(10)');
        invalidDefinitions.add('Static Value(2017-01-01)');
        invalidDefinitions.add('Static Value(One)');

        Test.startTest();
        Boolean expectedResult = false;
        Boolean actualResult = definitionsAreValid(
            new FObject('FObjectOne__c'), fieldApiName, validDefinitions, invalidDefinitions);
        Test.stopTest();

        System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
    }

    @IsTest
    private static void definitionIsValidForFieldDataType_decimal_expectFailure() {
        String fieldApiName = 'TestDecimal__c';

        List<String> validDefinitions = new List<String>();
        validDefinitions.add('Copy Field(TestPicklistD__c)');
        validDefinitions.add('Copy Field(TestLookup__c) From(FObjectTwo__c.TestText__c)');
        validDefinitions.add('Random Type(List) Value(1, 2, 3)');
        validDefinitions.add('Random Type(List) Value(1.1, 2.2, 3.3)');
        validDefinitions.add('Random Type(Number) From(1) To(100) Scale(0)');
        validDefinitions.add('Serial Type(Number) From(10.2) Step(1.2) Scale(2)');
        validDefinitions.add('Static Value(10.1)');
        validDefinitions.add('Static Value(10)');

        List<String> invalidDefinitions = new List<String>();
        invalidDefinitions.add('Mock type(id)');
        invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Except(One,Two,Three) Source(Forceea)');
        invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Value(One,Two,Three) Source(Forceea)');
        invalidDefinitions.add('Random Lookup(Account) Source(Forceea)');
        invalidDefinitions.add('Random lookup(Account) Where(Rating = \'Hot\') source(salesforce)');
        invalidDefinitions.add('Random Type(Boolean)');
        invalidDefinitions.add('Random Type(City) Group(one)');
        invalidDefinitions.add('Random Type(Country) Group(one)');
        invalidDefinitions.add('Random Type(Date) From(2017-01-01) To(2017-12-31)');
        invalidDefinitions.add('Random Type(Datetime) From(2017-01-01) To(2017-12-31)');
        invalidDefinitions.add('Random Type(Email)');
        invalidDefinitions.add('Random Type(Phone) Format(30 210 dD DD ddD)');
        invalidDefinitions.add('Random Type(FirstName) Group(one)');
        invalidDefinitions.add('Random Type(LastName) Group(one)');
        invalidDefinitions.add('Random Type(List) Value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
        invalidDefinitions.add('Random Type(List) Value(2017-01-01, 2017-02-02, 2017-03-03)');
        invalidDefinitions.add('Random Type(List) Value(One, Two, Three)');
        invalidDefinitions.add('Random Type(Picklist) Except(One,Two)');
        invalidDefinitions.add('Random Type(Picklist)');
        invalidDefinitions.add('Random Type(Postalcode) Group(one)');
        invalidDefinitions.add('Random Type(State) Group(one)');
        invalidDefinitions.add('Random Type(Street) Group(one)');
        invalidDefinitions.add('Random Type(String) Minlength(10) Maxlength(30) Startwith(Lower) Include(Lower,Upper,Digit)');
        invalidDefinitions.add('Random Type(Text) Minlength(10) Maxlength(30)');
        invalidDefinitions.add('Random Type(Url)');
        invalidDefinitions.add('Serial Lookup(Account) mode(cyclical) source(forceea)');
        invalidDefinitions.add('Serial Type(Date) From(2017-01-01) Step(2)');
        invalidDefinitions.add('Serial Type(Datetime) From(2017-01-01 02:02:02) Step(2.2)');
        invalidDefinitions.add('Static Lookup(Account) Field(FieldOne) Value(One) Source(Forceea)');
        invalidDefinitions.add('Static Value(01:01:01)');
        invalidDefinitions.add('Static Value(2017-01-01 01:01:01)');
        invalidDefinitions.add('Static Value(2017-01-01)');
        invalidDefinitions.add('Static Value(One)');

        Test.startTest();
        Boolean expectedResult = false;
        Boolean actualResult = definitionsAreValid(
            new FObject('FObjectOne__c'), fieldApiName, validDefinitions, invalidDefinitions);
        Test.stopTest();

        System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
    }

    @IsTest
    private static void definitionIsValidForFieldDataType_email_expectFailure() {
        String fieldApiName = 'TestEmail__c';

        List<String> validDefinitions = new List<String>();
        validDefinitions.add('Copy Field(TestPicklistD__c)');
        validDefinitions.add('Copy Field(TestLookup__c) From(FObjectTwo__c.TestText__c)');
        validDefinitions.add('Random Type(Boolean)');
        validDefinitions.add('Random Type(Email)');
        validDefinitions.add('Random Type(List) Value(1, 2, 3)');
        validDefinitions.add('Random Type(List) Value(One, Two, Three)');
        validDefinitions.add('Random Type(Number) From(1) To(100) Scale(0)');
        validDefinitions.add('Random Type(String) Minlength(10) Maxlength(30) Startwith(Lower) Include(Lower,Upper,Digit)');
        validDefinitions.add('Serial Type(Number) From(10.2) Step(1.2) Scale(2)');
        validDefinitions.add('Static Value(10)');
        validDefinitions.add('Static Value(One)');

        List<String> invalidDefinitions = new List<String>();
        invalidDefinitions.add('Mock type(id)');
        invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Except(One,Two,Three) Source(Forceea)');
        invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Value(One,Two,Three) Source(Forceea)');
        invalidDefinitions.add('Random Lookup(Account) Source(Forceea)');
        invalidDefinitions.add('Random lookup(Account) Where(Rating = \'Hot\') source(salesforce)');
        invalidDefinitions.add('Random Type(City) Group(one)');
        invalidDefinitions.add('Random Type(Country) Group(one)');
        invalidDefinitions.add('Random Type(Date) From(2017-01-01) To(2017-12-31)');
        invalidDefinitions.add('Random Type(Datetime) From(2017-01-01) To(2017-12-31)');
        invalidDefinitions.add('Random Type(Phone) Format(30 210 dD DD ddD)');
        invalidDefinitions.add('Random Type(FirstName) Group(one)');
        invalidDefinitions.add('Random Type(LastName) Group(one)');
        invalidDefinitions.add('Random Type(List) Value(1.1, 2.2, 3.3)');
        invalidDefinitions.add('Random Type(List) Value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
        invalidDefinitions.add('Random Type(List) Value(2017-01-01, 2017-02-02, 2017-03-03)');
        invalidDefinitions.add('Random Type(Picklist) Except(One,Two)');
        invalidDefinitions.add('Random Type(Picklist)');
        invalidDefinitions.add('Random Type(Postalcode) Group(one)');
        invalidDefinitions.add('Random Type(State) Group(one)');
        invalidDefinitions.add('Random Type(Street) Group(one)');
        invalidDefinitions.add('Random Type(Text) Minlength(10) Maxlength(30)');
        invalidDefinitions.add('Random Type(Url)');
        invalidDefinitions.add('Serial Lookup(Account) mode(cyclical) source(forceea)');
        invalidDefinitions.add('Serial Type(Date) From(2017-01-01) Step(2)');
        invalidDefinitions.add('Serial Type(Datetime) From(2017-01-01 02:02:02) Step(2.2)');
        invalidDefinitions.add('Static Lookup(Account) Field(FieldOne) Value(One) Source(Forceea)');
        invalidDefinitions.add('Static Value(01:01:01)');
        invalidDefinitions.add('Static Value(10.1)');
        invalidDefinitions.add('Static Value(2017-01-01 01:01:01)');
        invalidDefinitions.add('Static Value(2017-01-01)');

        Test.startTest();
        Boolean expectedResult = false;
        Boolean actualResult = definitionsAreValid(
            new FObject('FObjectOne__c'), fieldApiName, validDefinitions, invalidDefinitions);
        Test.stopTest();

        System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
    }

    @IsTest
    private static void definitionIsValidForFieldDataType_id_expectFailure() {
        String fieldApiName = 'Id';

        List<String> validDefinitions = new List<String>();
        validDefinitions.add('Mock type(id)');

        List<String> invalidDefinitions = new List<String>();
        invalidDefinitions.add('Copy Field(TestPicklistD__c)');
        invalidDefinitions.add('Copy Field(TestLookup__c) From(FObjectTwo__c.TestText__c)');
        invalidDefinitions.add('Random Type(List) Value(1, 2, 3)');
        invalidDefinitions.add('Random Type(List) Value(One, Two, Three)');
        invalidDefinitions.add('Random Type(Number) From(1) To(100) Scale(0)');
        invalidDefinitions.add('Random Type(String) Minlength(10) Maxlength(30) Startwith(Lower) Include(Lower,Upper,Digit)');
        invalidDefinitions.add('Random Type(Url)');
        invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Except(One,Two,Three) Source(Forceea)');
        invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Value(One,Two,Three) Source(Forceea)');
        invalidDefinitions.add('Random Lookup(Account) Source(Forceea)');
        invalidDefinitions.add('Random lookup(Account) Where(Rating = \'Hot\') source(salesforce)');
        invalidDefinitions.add('Random Type(Boolean)');
        invalidDefinitions.add('Random Type(City) Group(one)');
        invalidDefinitions.add('Random Type(Country) Group(one)');
        invalidDefinitions.add('Random Type(Date) From(2017-01-01) To(2017-12-31)');
        invalidDefinitions.add('Random Type(Datetime) From(2017-01-01) To(2017-12-31)');
        invalidDefinitions.add('Random Type(Email)');
        invalidDefinitions.add('Random Type(Phone) Format(30 210 dD DD ddD)');
        invalidDefinitions.add('Random Type(FirstName) Group(one)');
        invalidDefinitions.add('Random Type(LastName) Group(one)');
        invalidDefinitions.add('Random Type(List) Value(1.1, 2.2, 3.3)');
        invalidDefinitions.add('Random Type(List) Value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
        invalidDefinitions.add('Random Type(List) Value(2017-01-01, 2017-02-02, 2017-03-03)');
        invalidDefinitions.add('Random Type(Picklist) Except(One,Two)');
        invalidDefinitions.add('Random Type(Picklist)');
        invalidDefinitions.add('Random Type(Postalcode) Group(one)');
        invalidDefinitions.add('Random Type(State) Group(one)');
        invalidDefinitions.add('Random Type(Street) Group(one)');
        invalidDefinitions.add('Random Type(Text) Minlength(10) Maxlength(30)');
        invalidDefinitions.add('Serial Lookup(Account) mode(cyclical) source(forceea)');
        invalidDefinitions.add('Serial Type(Number) From(10.2) Step(1.2) Scale(2)');
        invalidDefinitions.add('Serial Type(Date) From(2017-01-01) Step(2)');
        invalidDefinitions.add('Serial Type(Datetime) From(2017-01-01 02:02:02) Step(2.2)');
        invalidDefinitions.add('Static Lookup(Account) Field(FieldOne) Value(One) Source(Forceea)');
        invalidDefinitions.add('Static Value(10)');
        invalidDefinitions.add('Static Value(One)');
        invalidDefinitions.add('Static Value(01:01:01)');
        invalidDefinitions.add('Static Value(10.1)');
        invalidDefinitions.add('Static Value(2017-01-01 01:01:01)');
        invalidDefinitions.add('Static Value(2017-01-01)');

        Test.startTest();
        Boolean expectedResult = false;
        Boolean actualResult = definitionsAreValid(
            new FObject('FObjectOne__c'), fieldApiName, validDefinitions, invalidDefinitions);
        Test.stopTest();

        System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
    }

    @IsTest
    private static void definitionIsValidForFieldDataType_integer_expectFailure() {
        String fieldApiName = 'TestInteger__c';

        List<String> validDefinitions = new List<String>();
        validDefinitions.add('Copy Field(TestPicklistD__c)');
        validDefinitions.add('Copy Field(TestLookup__c) From(FObjectTwo__c.TestText__c)');
        validDefinitions.add('Random Type(List) Value(1, 2, 3)');
        validDefinitions.add('Random Type(Number) From(1) To(100) Scale(0)');
        validDefinitions.add('Static Value(10.1)');
        validDefinitions.add('Static Value(10)');

        List<String> invalidDefinitions = new List<String>();
        invalidDefinitions.add('Mock type(id)');
        invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Except(One,Two,Three) Source(Forceea)');
        invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Value(One,Two,Three) Source(Forceea)');
        invalidDefinitions.add('Random Lookup(Account) Source(Forceea)');
        invalidDefinitions.add('Random lookup(Account) Where(Rating = \'Hot\') source(salesforce)');
        invalidDefinitions.add('Random Type(Boolean)');
        invalidDefinitions.add('Random Type(City) Group(one)');
        invalidDefinitions.add('Random Type(Country) Group(one)');
        invalidDefinitions.add('Random Type(Date) From(2017-01-01) To(2017-12-31)');
        invalidDefinitions.add('Random Type(Datetime) From(2017-01-01) To(2017-12-31)');
        invalidDefinitions.add('Random Type(Email)');
        invalidDefinitions.add('Random Type(List) Value(1.1, 2.2, 3.3)');
        invalidDefinitions.add('Random Type(Phone) Format(30 210 dD DD ddD)');
        invalidDefinitions.add('Random Type(FirstName) Group(one)');
        invalidDefinitions.add('Random Type(LastName) Group(one)');
        invalidDefinitions.add('Random Type(List) Value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
        invalidDefinitions.add('Random Type(List) Value(2017-01-01, 2017-02-02, 2017-03-03)');
        invalidDefinitions.add('Random Type(List) Value(One, Two, Three)');
        invalidDefinitions.add('Random Type(Picklist) Except(One,Two)');
        invalidDefinitions.add('Random Type(Picklist)');
        invalidDefinitions.add('Random Type(Postalcode) Group(one)');
        invalidDefinitions.add('Random Type(State) Group(one)');
        invalidDefinitions.add('Random Type(Street) Group(one)');
        invalidDefinitions.add('Random Type(String) Minlength(10) Maxlength(30) Startwith(Lower) Include(Lower,Upper,Digit)');
        invalidDefinitions.add('Random Type(Text) Minlength(10) Maxlength(30)');
        invalidDefinitions.add('Random Type(Url)');
        invalidDefinitions.add('Serial Lookup(Account) mode(cyclical) source(forceea)');
        invalidDefinitions.add('Serial Type(Date) From(2017-01-01) Step(2)');
        invalidDefinitions.add('Serial Type(Datetime) From(2017-01-01 02:02:02) Step(2.2)');
        invalidDefinitions.add('Serial Type(Number) From(10.2) Step(1.2) Scale(2)');
        invalidDefinitions.add('Static Lookup(Account) Field(FieldOne) Value(One) Source(Forceea)');
        invalidDefinitions.add('Static Value(01:01:01)');
        invalidDefinitions.add('Static Value(2017-01-01 01:01:01)');
        invalidDefinitions.add('Static Value(2017-01-01)');
        invalidDefinitions.add('Static Value(One)');

        Test.startTest();
        Boolean expectedResult = false;
        Boolean actualResult = definitionsAreValid(
            new FObject('FObjectOne__c'), fieldApiName, validDefinitions, invalidDefinitions);
        Test.stopTest();

        System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
    }

    @IsTest
    private static void definitionIsValidForFieldDataType_multiPicklist_expectFailure() {
        String fieldApiName = 'TestMultiPicklistA__c';

        List<String> validDefinitions = new List<String>();
        validDefinitions.add('Copy Field(TestPicklistD__c)');
        validDefinitions.add('Copy Field(TestLookup__c) From(FObjectTwo__c.TestText__c)');
        validDefinitions.add('Random Type(Boolean)');
        validDefinitions.add('Random Type(City) Group(one)');
        validDefinitions.add('Random Type(Country) Group(one)');
        validDefinitions.add('Random Type(Date) From(2017-01-01) To(2017-12-31)');
        validDefinitions.add('Random Type(Datetime) From(2017-01-01) To(2017-12-31)');
        validDefinitions.add('Random Type(Email)');
        validDefinitions.add('Random Type(Phone) Format(30 210 dD DD ddD)');
        validDefinitions.add('Random Type(FirstName) Group(one)');
        validDefinitions.add('Random Type(LastName) Group(one)');
        validDefinitions.add('Random Type(List) Value(1, 2, 3)');
        validDefinitions.add('Random Type(List) Value(1.1, 2.2, 3.3)');
        validDefinitions.add('Random Type(List) Value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
        validDefinitions.add('Random Type(List) Value(2017-01-01, 2017-02-02, 2017-03-03)');
        validDefinitions.add('Random Type(List) Value(One, Two, Three)');
        validDefinitions.add('random type(picklist) except(One,Two)');
        validDefinitions.add('Random Type(Picklist)');
        validDefinitions.add('Random Type(Postalcode) Group(one)');
        validDefinitions.add('Random Type(State) Group(one)');
        validDefinitions.add('Random Type(Street) Group(one)');
        validDefinitions.add('Random Type(String) Minlength(10) Maxlength(30) Startwith(Lower) Include(Lower,Upper,Digit)');
        validDefinitions.add('Random Type(Text) Minlength(10) Maxlength(30)');
        validDefinitions.add('Random Type(Url)');
        validDefinitions.add('Serial Type(Date) From(2017-01-01) Step(2)');
        validDefinitions.add('Serial Type(Datetime) From(2017-01-01 02:02:02) Step(2.2)');
        validDefinitions.add('Serial Type(Number) From(10.2) Step(1.2) Scale(2)');
        validDefinitions.add('Static Value(01:01:01)');
        validDefinitions.add('Static Value(10.1)');
        validDefinitions.add('Static Value(10)');
        validDefinitions.add('Static Value(2017-01-01 01:01:01)');
        validDefinitions.add('Static Value(2017-01-01)');
        validDefinitions.add('Static Value(One)');
        validDefinitions.add('Random Type(Number) From(1) To(100) Scale(0)');

        List<String> invalidDefinitions = new List<String>();
        invalidDefinitions.add('Mock type(id)');
        invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Except(One,Two,Three) Source(Forceea)');
        invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Value(One,Two,Three) Source(Forceea)');
        invalidDefinitions.add('Random Lookup(Account) Source(Forceea)');
        invalidDefinitions.add('Random Lookup(Account) Where(Rating = \'Hot\') source(salesforce)');
        invalidDefinitions.add('Serial Lookup(Account) mode(cyclical) source(forceea)');
        invalidDefinitions.add('Static Lookup(Account) Field(FieldOne) Value(One) Source(Forceea)');

        Test.startTest();
        Boolean expectedResult = false;
        Boolean actualResult = definitionsAreValid(
            new FObject('FObjectOne__c'), fieldApiName, validDefinitions, invalidDefinitions);
        Test.stopTest();

        System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
    }

    @IsTest
    private static void definitionIsValidForFieldDataType_percent_expectFailure() {
        String fieldApiName = 'TestPercent__c';

        List<String> validDefinitions = new List<String>();
        validDefinitions.add('Copy Field(TestPicklistD__c)');
        validDefinitions.add('Copy Field(TestLookup__c) From(FObjectTwo__c.TestText__c)');
        validDefinitions.add('Random Type(List) Value(1, 2, 3)');
        validDefinitions.add('Random Type(List) Value(1.1, 2.2, 3.3)');
        validDefinitions.add('Random Type(Number) From(1) To(100) Scale(0)');
        validDefinitions.add('Serial Type(Number) From(10.2) Step(1.2) Scale(2)');
        validDefinitions.add('Static Value(10.1)');

        List<String> invalidDefinitions = new List<String>();
        invalidDefinitions.add('Mock type(id)');
        invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Except(One,Two,Three) Source(Forceea)');
        invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Value(One,Two,Three) Source(Forceea)');
        invalidDefinitions.add('Random Lookup(Account) Source(Forceea)');
        invalidDefinitions.add('Random lookup(Account) Where(Rating = \'Hot\') source(salesforce)');
        invalidDefinitions.add('Random Type(Boolean)');
        invalidDefinitions.add('Random Type(City) Group(one)');
        invalidDefinitions.add('Random Type(Country) Group(one)');
        invalidDefinitions.add('Random Type(Date) From(2017-01-01) To(2017-12-31)');
        invalidDefinitions.add('Random Type(Datetime) From(2017-01-01) To(2017-12-31)');
        invalidDefinitions.add('Random Type(Email)');
        invalidDefinitions.add('Random Type(Phone) Format(30 210 dD DD ddD)');
        invalidDefinitions.add('Random Type(FirstName) Group(one)');
        invalidDefinitions.add('Random Type(LastName) Group(one)');
        invalidDefinitions.add('Random Type(List) Value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
        invalidDefinitions.add('Random Type(List) Value(2017-01-01, 2017-02-02, 2017-03-03)');
        invalidDefinitions.add('Random Type(List) Value(One, Two, Three)');
        invalidDefinitions.add('Random Type(Picklist) Except(One,Two)');
        invalidDefinitions.add('Random Type(Picklist)');
        invalidDefinitions.add('Random Type(Postalcode) Group(one)');
        invalidDefinitions.add('Random Type(State) Group(one)');
        invalidDefinitions.add('Random Type(Street) Group(one)');
        invalidDefinitions.add('Random Type(String) Minlength(10) Maxlength(30) Startwith(Lower) Include(Lower,Upper,Digit)');
        invalidDefinitions.add('Random Type(Text) Minlength(10) Maxlength(30)');
        invalidDefinitions.add('Random Type(Url)');
        invalidDefinitions.add('Serial Lookup(Account) mode(cyclical) source(forceea)');
        invalidDefinitions.add('Serial Type(Date) From(2017-01-01) Step(2)');
        invalidDefinitions.add('Serial Type(Datetime) From(2017-01-01 02:02:02) Step(2.2)');
        invalidDefinitions.add('Static Lookup(Account) Field(FieldOne) Value(One) Source(Forceea)');
        invalidDefinitions.add('Static Value(01:01:01)');
        invalidDefinitions.add('Static Value(10)');
        invalidDefinitions.add('Static Value(2017-01-01 01:01:01)');
        invalidDefinitions.add('Static Value(2017-01-01)');
        invalidDefinitions.add('Static Value(One)');

        Test.startTest();
        Boolean expectedResult = false;
        Boolean actualResult = definitionsAreValid(
            new FObject('FObjectOne__c'), fieldApiName, validDefinitions, invalidDefinitions);
        Test.stopTest();

        System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
    }

    @IsTest
    private static void definitionIsValidForFieldDataType_picklist_expectFailure() {
        String fieldApiName = 'TestPicklistC__c';

        List<String> validDefinitions = new List<String>();
        validDefinitions.add('Copy Field(TestPicklistD__c)');
        validDefinitions.add('Copy Field(TestLookup__c) From(FObjectTwo__c.TestText__c)');
        validDefinitions.add('Random Type(Boolean)');
        validDefinitions.add('Random Type(City) Group(one)');
        validDefinitions.add('Random Type(Country) Group(one)');
        validDefinitions.add('Random Type(Date) From(2017-01-01) To(2017-12-31)');
        validDefinitions.add('Random Type(Datetime) From(2017-01-01) To(2017-12-31)');
        validDefinitions.add('Random Type(Email)');
        validDefinitions.add('Random Type(Phone) Format(30 210 dD DD ddD)');
        validDefinitions.add('Random Type(FirstName) Group(one)');
        validDefinitions.add('Random Type(LastName) Group(one)');
        validDefinitions.add('Random Type(List) Value(1, 2, 3)');
        validDefinitions.add('Random Type(List) Value(1.1, 2.2, 3.3)');
        validDefinitions.add('Random Type(List) Value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
        validDefinitions.add('Random Type(List) Value(2017-01-01, 2017-02-02, 2017-03-03)');
        validDefinitions.add('Random Type(List) Value(One, Two, Three)');
        validDefinitions.add('Random Type(Number) From(1) To(100) Scale(0)');
        validDefinitions.add('random type(picklist) except(One,Two)');
        validDefinitions.add('Random Type(Picklist)');
        validDefinitions.add('Random Type(Postalcode) Group(one)');
        validDefinitions.add('Random Type(State) Group(one)');
        validDefinitions.add('Random Type(Street) Group(one)');
        validDefinitions.add('Random Type(String) Minlength(10) Maxlength(30) Startwith(Lower) Include(Lower,Upper,Digit)');
        validDefinitions.add('Random Type(Text) Minlength(10) Maxlength(30)');
        validDefinitions.add('Random Type(Url)');
        validDefinitions.add('Serial Type(Date) From(2017-01-01) Step(2)');
        validDefinitions.add('Serial Type(Datetime) From(2017-01-01 02:02:02) Step(2.2)');
        validDefinitions.add('Serial Type(Number) From(10.2) Step(1.2) Scale(2)');
        validDefinitions.add('Static Value(01:01:01)');
        validDefinitions.add('Static Value(10.1)');
        validDefinitions.add('Static Value(10)');
        validDefinitions.add('Static Value(2017-01-01 01:01:01)');
        validDefinitions.add('Static Value(2017-01-01)');
        validDefinitions.add('Static Value(One)');

        List<String> invalidDefinitions = new List<String>();
        invalidDefinitions.add('Mock type(id)');
        invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Except(One,Two,Three) Source(Forceea)');
        invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Value(One,Two,Three) Source(Forceea)');
        invalidDefinitions.add('Random Lookup(Account) Source(Forceea)');
        invalidDefinitions.add('Random Lookup(Account) Where(Rating = \'Hot\') source(salesforce)');
        invalidDefinitions.add('Serial Lookup(Account) mode(cyclical) source(forceea)');
        invalidDefinitions.add('Static Lookup(Account) Field(FieldOne) Value(One) Source(Forceea)');

        Test.startTest();
        Boolean expectedResult = false;
        Boolean actualResult = definitionsAreValid(
            new FObject('FObjectOne__c'), fieldApiName, validDefinitions, invalidDefinitions);
        Test.stopTest();

        System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
    }

    @IsTest
    private static void definitionIsValidForFieldDataType_phone_expectFailure() {
        String fieldApiName = 'TestPhone__c';

        List<String> validDefinitions = new List<String>();
        validDefinitions.add('Copy Field(TestPicklistD__c)');
        validDefinitions.add('Copy Field(TestLookup__c) From(FObjectTwo__c.TestText__c)');
        validDefinitions.add('Random Type(Phone) Format(30 210 dD DD ddD)');
        validDefinitions.add('Random Type(List) Value(One, Two, Three)');
        validDefinitions.add('Random Type(Number) From(1) To(100) Scale(0)');
        validDefinitions.add('Serial Type(Number) From(10.2) Step(1.2) Scale(2)');
        validDefinitions.add('Static Value(10)');
        validDefinitions.add('Static Value(One)');

        List<String> invalidDefinitions = new List<String>();
        invalidDefinitions.add('Mock type(id)');
        invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Except(One,Two,Three) Source(Forceea)');
        invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Value(One,Two,Three) Source(Forceea)');
        invalidDefinitions.add('Random Lookup(Account) Source(Forceea)');
        invalidDefinitions.add('Random lookup(Account) Where(Rating = \'Hot\') source(salesforce)');
        invalidDefinitions.add('Random Type(Boolean)');
        invalidDefinitions.add('Random Type(City) Group(one)');
        invalidDefinitions.add('Random Type(Country) Group(one)');
        invalidDefinitions.add('Random Type(Date) From(2017-01-01) To(2017-12-31)');
        invalidDefinitions.add('Random Type(Datetime) From(2017-01-01) To(2017-12-31)');
        invalidDefinitions.add('Random Type(Email)');
        invalidDefinitions.add('Random Type(FirstName) Group(one)');
        invalidDefinitions.add('Random Type(LastName) Group(one)');
        invalidDefinitions.add('Random Type(List) Value(1, 2, 3)');
        invalidDefinitions.add('Random Type(List) Value(1.1, 2.2, 3.3)');
        invalidDefinitions.add('Random Type(List) Value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
        invalidDefinitions.add('Random Type(List) Value(2017-01-01, 2017-02-02, 2017-03-03)');
        invalidDefinitions.add('Random Type(Picklist) Except(One,Two)');
        invalidDefinitions.add('Random Type(Picklist)');
        invalidDefinitions.add('Random Type(Postalcode) Group(one)');
        invalidDefinitions.add('Random Type(State) Group(one)');
        invalidDefinitions.add('Random Type(Street) Group(one)');
        invalidDefinitions.add('Random Type(String) Minlength(10) Maxlength(30) Startwith(Lower) Include(Lower,Upper,Digit)');
        invalidDefinitions.add('Random Type(Text) Minlength(10) Maxlength(30)');
        invalidDefinitions.add('Random Type(Url)');
        invalidDefinitions.add('Serial Lookup(Account) mode(cyclical) source(forceea)');
        invalidDefinitions.add('Serial Type(Date) From(2017-01-01) Step(2)');
        invalidDefinitions.add('Serial Type(Datetime) From(2017-01-01 02:02:02) Step(2.2)');
        invalidDefinitions.add('Static Lookup(Account) Field(FieldOne) Value(One) Source(Forceea)');
        invalidDefinitions.add('Static Value(01:01:01)');
        invalidDefinitions.add('Static Value(10.1)');
        invalidDefinitions.add('Static Value(2017-01-01 01:01:01)');
        invalidDefinitions.add('Static Value(2017-01-01)');

        Test.startTest();
        Boolean expectedResult = false;
        Boolean actualResult = definitionsAreValid(
            new FObject('FObjectOne__c'), fieldApiName, validDefinitions, invalidDefinitions);
        Test.stopTest();

        System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
    }

    @IsTest
    private static void definitionIsValidForFieldDataType_recordType_expectFailure() {
        String fieldApiName = 'RecordTypeId';

        List<String> validDefinitions = new List<String>();
        validDefinitions.add('Random Type(List) Value(One, Two, Three)');
        validDefinitions.add('random type(picklist) except(One,Two)');
        validDefinitions.add('Random Type(Picklist)');
        validDefinitions.add('Static Value(One)');

        List<String> invalidDefinitions = new List<String>();
        invalidDefinitions.add('Copy Field(TestPicklistD__c)');
        invalidDefinitions.add('Copy Field(TestLookup__c) From(FObjectTwo__c.TestText__c)');
        invalidDefinitions.add('Mock type(id)');
        invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Except(One,Two,Three) Source(Forceea)');
        invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Value(One,Two,Three) Source(Forceea)');
        invalidDefinitions.add('Random Lookup(Account) Source(Forceea)');
        invalidDefinitions.add('Random lookup(Account) Where(Rating = \'Hot\') source(salesforce)');
        invalidDefinitions.add('Random Type(Boolean)');
        invalidDefinitions.add('Random Type(City) Group(one)');
        invalidDefinitions.add('Random Type(Country) Group(one)');
        invalidDefinitions.add('Random Type(Date) From(2017-01-01) To(2017-12-31)');
        invalidDefinitions.add('Random Type(Datetime) From(2017-01-01) To(2017-12-31)');
        invalidDefinitions.add('Random Type(Email)');
        invalidDefinitions.add('Random Type(Phone) Format(30 210 dD DD ddD)');
        invalidDefinitions.add('Random Type(FirstName) Group(one)');
        invalidDefinitions.add('Random Type(LastName) Group(one)');
        invalidDefinitions.add('Random Type(List) Value(1, 2, 3)');
        invalidDefinitions.add('Random Type(List) Value(1.1, 2.2, 3.3)');
        invalidDefinitions.add('Random Type(List) Value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
        invalidDefinitions.add('Random Type(List) Value(2017-01-01, 2017-02-02, 2017-03-03)');
        invalidDefinitions.add('Random Type(Number) From(1) To(100) Scale(0)');
        invalidDefinitions.add('Random Type(Postalcode) Group(one)');
        invalidDefinitions.add('Random Type(State) Group(one)');
        invalidDefinitions.add('Random Type(Street) Group(one)');
        invalidDefinitions.add('Random Type(String) Minlength(10) Maxlength(30) Startwith(Lower) Include(Lower,Upper,Digit)');
        invalidDefinitions.add('Random Type(Text) Minlength(10) Maxlength(30)');
        invalidDefinitions.add('Random Type(Url)');
        invalidDefinitions.add('Serial Lookup(Account) mode(cyclical) source(forceea)');
        invalidDefinitions.add('Serial Type(Date) From(2017-01-01) Step(2)');
        invalidDefinitions.add('Serial Type(Datetime) From(2017-01-01 02:02:02) Step(2.2)');
        invalidDefinitions.add('Serial Type(Number) From(10.2) Step(1.2) Scale(2)');
        invalidDefinitions.add('Static Lookup(Account) Field(FieldOne) Value(One) Source(Forceea)');
        invalidDefinitions.add('Static Value(01:01:01)');
        invalidDefinitions.add('Static Value(10.1)');
        invalidDefinitions.add('Static Value(10)');
        invalidDefinitions.add('Static Value(2017-01-01 01:01:01)');
        invalidDefinitions.add('Static Value(2017-01-01)');

        Test.startTest();
        Boolean expectedResult = false;
        Boolean actualResult = definitionsAreValid(
            new FObject('FObjectOne__c'), fieldApiName, validDefinitions, invalidDefinitions);
        Test.stopTest();

        System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
    }

    @IsTest
    private static void definitionIsValidForFieldDataType_reference_expectFailure() {
        String fieldApiName = 'TestLookup__c';

        List<String> validDefinitions = new List<String>();
        validDefinitions.add('Random Lookup(Account) Field(FieldOne) Except(One,Two,Three) Source(Forceea)');
        validDefinitions.add('Random Lookup(Account) Field(FieldOne) Value(One,Two,Three) Source(Forceea)');
        validDefinitions.add('Random Lookup(Account) Source(Forceea)');
        validDefinitions.add('Random lookup(Account) Where(Rating = \'Hot\') source(salesforce)');
        validDefinitions.add('Serial Lookup(Account) mode(cyclical) source(forceea)');
        validDefinitions.add('Static Lookup(Account) Field(FieldOne) Value(One) Source(Forceea)');

        List<String> invalidDefinitions = new List<String>();
        invalidDefinitions.add('Copy Field(TestPicklistD__c)');
        invalidDefinitions.add('Copy Field(TestLookup__c) From(FObjectTwo__c.TestText__c)');
        invalidDefinitions.add('Mock type(id)');
        invalidDefinitions.add('Random Type(Boolean)');
        invalidDefinitions.add('Random Type(City) Group(one)');
        invalidDefinitions.add('Random Type(Country) Group(one)');
        invalidDefinitions.add('Random Type(Date) From(2017-01-01) To(2017-12-31)');
        invalidDefinitions.add('Random Type(Datetime) From(2017-01-01) To(2017-12-31)');
        invalidDefinitions.add('Random Type(Email)');
        invalidDefinitions.add('Random Type(Phone) Format(30 210 dD DD ddD)');
        invalidDefinitions.add('Random Type(FirstName) Group(one)');
        invalidDefinitions.add('Random Type(LastName) Group(one)');
        invalidDefinitions.add('Random Type(List) Value(1, 2, 3)');
        invalidDefinitions.add('Random Type(List) Value(1.1, 2.2, 3.3)');
        invalidDefinitions.add('Random Type(List) Value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
        invalidDefinitions.add('Random Type(List) Value(2017-01-01, 2017-02-02, 2017-03-03)');
        invalidDefinitions.add('Random Type(List) Value(One, Two, Three)');
        invalidDefinitions.add('Random Type(Number) From(1) To(100) Scale(0)');
        invalidDefinitions.add('Random Type(Picklist) Except(One,Two)');
        invalidDefinitions.add('Random Type(Picklist)');
        invalidDefinitions.add('Random Type(Postalcode) Group(one)');
        invalidDefinitions.add('Random Type(State) Group(one)');
        invalidDefinitions.add('Random Type(Street) Group(one)');
        invalidDefinitions.add('Random Type(String) Minlength(10) Maxlength(30) Startwith(Lower) Include(Lower,Upper,Digit)');
        invalidDefinitions.add('Random Type(Text) Minlength(10) Maxlength(30)');
        invalidDefinitions.add('Random Type(Url)');
        invalidDefinitions.add('Serial Type(Date) From(2017-01-01) Step(2)');
        invalidDefinitions.add('Serial Type(Datetime) From(2017-01-01 02:02:02) Step(2.2)');
        invalidDefinitions.add('Serial Type(Number) From(10.2) Step(1.2) Scale(2)');
        invalidDefinitions.add('Static Value(01:01:01)');
        invalidDefinitions.add('Static Value(10.1)');
        invalidDefinitions.add('Static Value(10)');
        invalidDefinitions.add('Static Value(2017-01-01 01:01:01)');
        invalidDefinitions.add('Static Value(2017-01-01)');
        invalidDefinitions.add('Static Value(One)');

        Test.startTest();
        Boolean expectedResult = false;
        Boolean actualResult = definitionsAreValid(
            new FObject('FObjectOne__c'), fieldApiName, validDefinitions, invalidDefinitions);
        Test.stopTest();

        System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
    }

    @IsTest
    private static void definitionIsValidForFieldDataType_string_expectFailure() {
        String fieldApiName = 'TestText__c';

        List<String> validDefinitions = new List<String>();
        validDefinitions.add('Copy Field(TestPicklistD__c)');
        validDefinitions.add('Copy Field(TestLookup__c) From(FObjectTwo__c.TestText__c)');
        validDefinitions.add('Random Type(Boolean)');
        validDefinitions.add('Random Type(City) Group(one)');
        validDefinitions.add('Random Type(Country) Group(one)');
        validDefinitions.add('Random Type(Date) From(2017-01-01) To(2017-12-31)');
        validDefinitions.add('Random Type(Datetime) From(2017-01-01) To(2017-12-31)');
        validDefinitions.add('Random Type(Email)');
        validDefinitions.add('Random Type(Phone) Format(30 210 dD DD ddD)');
        validDefinitions.add('Random Type(FirstName) Group(one)');
        validDefinitions.add('Random Type(LastName) Group(one)');
        validDefinitions.add('Random Type(List) Value(1, 2, 3)');
        validDefinitions.add('Random Type(List) Value(1.1, 2.2, 3.3)');
        validDefinitions.add('Random Type(List) Value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
        validDefinitions.add('Random Type(List) Value(2017-01-01, 2017-02-02, 2017-03-03)');
        validDefinitions.add('Random Type(List) Value(One, Two, Three)');
        validDefinitions.add('Random Type(Number) From(1) To(100) Scale(0)');
        validDefinitions.add('Random Type(Postalcode) Group(one)');
        validDefinitions.add('Random Type(State) Group(one)');
        validDefinitions.add('Random Type(Street) Group(one)');
        validDefinitions.add('Random Type(String) Minlength(10) Maxlength(30) Startwith(Lower) Include(Lower,Upper,Digit)');
        validDefinitions.add('Random Type(Text) Minlength(10) Maxlength(30)');
        validDefinitions.add('Random Type(Url)');
        validDefinitions.add('Serial Type(Date) From(2017-01-01) Step(2)');
        validDefinitions.add('Serial Type(Datetime) From(2017-01-01 02:02:02) Step(2.2)');
        validDefinitions.add('Serial Type(Number) From(10.2) Step(1.2) Scale(2)');
        validDefinitions.add('Static Value(01:01:01)');
        validDefinitions.add('Static Value(10.1)');
        validDefinitions.add('Static Value(10)');
        validDefinitions.add('Static Value(2017-01-01 01:01:01)');
        validDefinitions.add('Static Value(2017-01-01)');
        validDefinitions.add('Static Value(One)');

        List<String> invalidDefinitions = new List<String>();
        invalidDefinitions.add('Mock type(id)');
        invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Except(One,Two,Three) Source(Forceea)');
        invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Value(One,Two,Three) Source(Forceea)');
        invalidDefinitions.add('Random Lookup(Account) Source(Forceea)');
        invalidDefinitions.add('Random lookup(Account) Where(Rating = \'Hot\') source(salesforce)');
        invalidDefinitions.add('Random Type(Picklist) Except(One,Two)');
        invalidDefinitions.add('Random Type(Picklist)');
        invalidDefinitions.add('Serial Lookup(Account) mode(cyclical) source(forceea)');
        invalidDefinitions.add('Static Lookup(Account) Field(FieldOne) Value(One) Source(Forceea)');

        Test.startTest();
        Boolean expectedResult = false;
        Boolean actualResult = definitionsAreValid(
            new FObject('FObjectOne__c'), fieldApiName, validDefinitions, invalidDefinitions);
        Test.stopTest();

        System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
    }

    @IsTest
    private static void definitionIsValidForFieldDataType_textArea_expectFailure() {
        String fieldApiName = 'TestTextArea__c';

        List<String> validDefinitions = new List<String>();
        validDefinitions.add('Copy Field(TestPicklistD__c)');
        validDefinitions.add('Copy Field(TestLookup__c) From(FObjectTwo__c.TestText__c)');
        validDefinitions.add('Random Type(Boolean)');
        validDefinitions.add('Random Type(City) Group(one)');
        validDefinitions.add('Random Type(Country) Group(one)');
        validDefinitions.add('Random Type(Date) From(2017-01-01) To(2017-12-31)');
        validDefinitions.add('Random Type(Datetime) From(2017-01-01) To(2017-12-31)');
        validDefinitions.add('Random Type(Email)');
        validDefinitions.add('Random Type(Phone) Format(30 210 dD DD ddD)');
        validDefinitions.add('Random Type(FirstName) Group(one)');
        validDefinitions.add('Random Type(LastName) Group(one)');
        validDefinitions.add('Random Type(List) Value(1, 2, 3)');
        validDefinitions.add('Random Type(List) Value(1.1, 2.2, 3.3)');
        validDefinitions.add('Random Type(List) Value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
        validDefinitions.add('Random Type(List) Value(2017-01-01, 2017-02-02, 2017-03-03)');
        validDefinitions.add('Random Type(List) Value(One, Two, Three)');
        validDefinitions.add('Random Type(Number) From(1) To(100) Scale(0)');
        validDefinitions.add('Random Type(Postalcode) Group(one)');
        validDefinitions.add('Random Type(State) Group(one)');
        validDefinitions.add('Random Type(Street) Group(one)');
        validDefinitions.add('Random Type(String) Minlength(10) Maxlength(30) Startwith(Lower) Include(Lower,Upper,Digit)');
        validDefinitions.add('Random Type(Text) Minlength(10) Maxlength(30)');
        validDefinitions.add('Random Type(Url)');
        validDefinitions.add('Serial Type(Date) From(2017-01-01) Step(2)');
        validDefinitions.add('Serial Type(Datetime) From(2017-01-01 02:02:02) Step(2.2)');
        validDefinitions.add('Serial Type(Number) From(10.2) Step(1.2) Scale(2)');
        validDefinitions.add('Static Value(01:01:01)');
        validDefinitions.add('Static Value(10.1)');
        validDefinitions.add('Static Value(10)');
        validDefinitions.add('Static Value(2017-01-01 01:01:01)');
        validDefinitions.add('Static Value(2017-01-01)');
        validDefinitions.add('Static Value(One)');

        List<String> invalidDefinitions = new List<String>();
        invalidDefinitions.add('Mock type(id)');
        invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Except(One,Two,Three) Source(Forceea)');
        invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Value(One,Two,Three) Source(Forceea)');
        invalidDefinitions.add('Random Lookup(Account) Source(Forceea)');
        invalidDefinitions.add('Random lookup(Account) Where(Rating = \'Hot\') source(salesforce)');
        invalidDefinitions.add('Random Type(Picklist) Except(One,Two)');
        invalidDefinitions.add('Random Type(Picklist)');
        invalidDefinitions.add('Serial Lookup(Account) mode(cyclical) source(forceea)');
        invalidDefinitions.add('Static Lookup(Account) Field(FieldOne) Value(One) Source(Forceea)');

        Test.startTest();
        Boolean expectedResult = false;
        Boolean actualResult = definitionsAreValid(
            new FObject('FObjectOne__c'), fieldApiName, validDefinitions, invalidDefinitions);
        Test.stopTest();

        System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
    }

    @IsTest
    private static void definitionIsValidForFieldDataType_textAreaLong_expectFailure() {
        String fieldApiName = 'TestTextAreaLong__c';

        List<String> validDefinitions = new List<String>();
        validDefinitions.add('Copy Field(TestPicklistD__c)');
        validDefinitions.add('Copy Field(TestLookup__c) From(FObjectTwo__c.TestText__c)');
        validDefinitions.add('Random Type(Boolean)');
        validDefinitions.add('Random Type(City) Group(one)');
        validDefinitions.add('Random Type(Country) Group(one)');
        validDefinitions.add('Random Type(Date) From(2017-01-01) To(2017-12-31)');
        validDefinitions.add('Random Type(Datetime) From(2017-01-01) To(2017-12-31)');
        validDefinitions.add('Random Type(Email)');
        validDefinitions.add('Random Type(Phone) Format(30 210 dD DD ddD)');
        validDefinitions.add('Random Type(FirstName) Group(one)');
        validDefinitions.add('Random Type(LastName) Group(one)');
        validDefinitions.add('Random Type(List) Value(1, 2, 3)');
        validDefinitions.add('Random Type(List) Value(1.1, 2.2, 3.3)');
        validDefinitions.add('Random Type(List) Value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
        validDefinitions.add('Random Type(List) Value(2017-01-01, 2017-02-02, 2017-03-03)');
        validDefinitions.add('Random Type(List) Value(One, Two, Three)');
        validDefinitions.add('Random Type(Number) From(1) To(100) Scale(0)');
        validDefinitions.add('Random Type(Postalcode) Group(one)');
        validDefinitions.add('Random Type(State) Group(one)');
        validDefinitions.add('Random Type(Street) Group(one)');
        validDefinitions.add('Random Type(String) Minlength(10) Maxlength(30) Startwith(Lower) Include(Lower,Upper,Digit)');
        validDefinitions.add('Random Type(Text) Minlength(10) Maxlength(30)');
        validDefinitions.add('Random Type(Url)');
        validDefinitions.add('Serial Type(Date) From(2017-01-01) Step(2)');
        validDefinitions.add('Serial Type(Datetime) From(2017-01-01 02:02:02) Step(2.2)');
        validDefinitions.add('Serial Type(Number) From(10.2) Step(1.2) Scale(2)');
        validDefinitions.add('Static Value(01:01:01)');
        validDefinitions.add('Static Value(10.1)');
        validDefinitions.add('Static Value(10)');
        validDefinitions.add('Static Value(2017-01-01 01:01:01)');
        validDefinitions.add('Static Value(2017-01-01)');
        validDefinitions.add('Static Value(One)');

        List<String> invalidDefinitions = new List<String>();
        invalidDefinitions.add('Mock type(id)');
        invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Except(One,Two,Three) Source(Forceea)');
        invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Value(One,Two,Three) Source(Forceea)');
        invalidDefinitions.add('Random Lookup(Account) Source(Forceea)');
        invalidDefinitions.add('Random lookup(Account) Where(Rating = \'Hot\') source(salesforce)');
        invalidDefinitions.add('Random Type(Picklist) Except(One,Two)');
        invalidDefinitions.add('Random Type(Picklist)');
        invalidDefinitions.add('Serial Lookup(Account) mode(cyclical) source(forceea)');
        invalidDefinitions.add('Static Lookup(Account) Field(FieldOne) Value(One) Source(Forceea)');

        Test.startTest();
        Boolean expectedResult = false;
        Boolean actualResult = definitionsAreValid(
            new FObject('FObjectOne__c'), fieldApiName, validDefinitions, invalidDefinitions);
        Test.stopTest();

        System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
    }

    @IsTest
    private static void definitionIsValidForFieldDataType_textAreaRich_expectFailure() {
        String fieldApiName = 'TestTextAreaRich__c';

        List<String> validDefinitions = new List<String>();
        validDefinitions.add('Copy Field(TestPicklistD__c)');
        validDefinitions.add('Copy Field(TestLookup__c) From(FObjectTwo__c.TestText__c)');
        validDefinitions.add('Random Type(Boolean)');
        validDefinitions.add('Random Type(City) Group(one)');
        validDefinitions.add('Random Type(Country) Group(one)');
        validDefinitions.add('Random Type(Date) From(2017-01-01) To(2017-12-31)');
        validDefinitions.add('Random Type(Datetime) From(2017-01-01) To(2017-12-31)');
        validDefinitions.add('Random Type(Email)');
        validDefinitions.add('Random Type(Phone) Format(30 210 dD DD ddD)');
        validDefinitions.add('Random Type(FirstName) Group(one)');
        validDefinitions.add('Random Type(LastName) Group(one)');
        validDefinitions.add('Random Type(List) Value(1, 2, 3)');
        validDefinitions.add('Random Type(List) Value(1.1, 2.2, 3.3)');
        validDefinitions.add('Random Type(List) Value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
        validDefinitions.add('Random Type(List) Value(2017-01-01, 2017-02-02, 2017-03-03)');
        validDefinitions.add('Random Type(List) Value(One, Two, Three)');
        validDefinitions.add('Random Type(Number) From(1) To(100) Scale(0)');
        validDefinitions.add('Random Type(Postalcode) Group(one)');
        validDefinitions.add('Random Type(State) Group(one)');
        validDefinitions.add('Random Type(Street) Group(one)');
        validDefinitions.add('Random Type(String) Minlength(10) Maxlength(30) Startwith(Lower) Include(Lower,Upper,Digit)');
        validDefinitions.add('Random Type(Text) Minlength(10) Maxlength(30)');
        validDefinitions.add('Random Type(Url)');
        validDefinitions.add('Serial Type(Date) From(2017-01-01) Step(2)');
        validDefinitions.add('Serial Type(Datetime) From(2017-01-01 02:02:02) Step(2.2)');
        validDefinitions.add('Serial Type(Number) From(10.2) Step(1.2) Scale(2)');
        validDefinitions.add('Static Value(01:01:01)');
        validDefinitions.add('Static Value(10.1)');
        validDefinitions.add('Static Value(10)');
        validDefinitions.add('Static Value(2017-01-01 01:01:01)');
        validDefinitions.add('Static Value(2017-01-01)');
        validDefinitions.add('Static Value(One)');

        List<String> invalidDefinitions = new List<String>();
        invalidDefinitions.add('Mock type(id)');
        invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Except(One,Two,Three) Source(Forceea)');
        invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Value(One,Two,Three) Source(Forceea)');
        invalidDefinitions.add('Random Lookup(Account) Source(Forceea)');
        invalidDefinitions.add('Random lookup(Account) Where(Rating = \'Hot\') source(salesforce)');
        invalidDefinitions.add('Random Type(Picklist) Except(One,Two)');
        invalidDefinitions.add('Random Type(Picklist)');
        invalidDefinitions.add('Serial Lookup(Account) mode(cyclical) source(forceea)');
        invalidDefinitions.add('Static Lookup(Account) Field(FieldOne) Value(One) Source(Forceea)');

        Test.startTest();
        Boolean expectedResult = false;
        Boolean actualResult = definitionsAreValid(
            new FObject('FObjectOne__c'), fieldApiName, validDefinitions, invalidDefinitions);
        Test.stopTest();

        System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
    }

    @IsTest
    private static void definitionIsValidForFieldDataType_time_expectSuccess() {
        String fieldApiName = 'TestTime__c';

        List<String> validDefinitions = new List<String>();
        validDefinitions.add('Static Value(01:01:01)');
        validDefinitions.add('Random Type(List) Value(01:01:01, 02:02:02, 03:03:03)');
        validDefinitions.add('Copy Field(TestPicklistD__c)');

        List<String> invalidDefinitions = new List<String>();
        invalidDefinitions.add('Copy Field(TestLookup__c) From(FObjectTwo__c.TestText__c)');
        invalidDefinitions.add('Mock type(id)');
        invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Except(One,Two,Three) Source(Forceea)');
        invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Value(One,Two,Three) Source(Forceea)');
        invalidDefinitions.add('Random Lookup(Account) Source(Forceea)');
        invalidDefinitions.add('Random lookup(Account) Where(Rating = \'Hot\') source(salesforce)');
        invalidDefinitions.add('Random Type(Boolean)');
        invalidDefinitions.add('Random Type(City) Group(one)');
        invalidDefinitions.add('Random Type(Country) Group(one)');
        invalidDefinitions.add('Random Type(Date) From(2017-01-01) To(2017-12-31)');
        invalidDefinitions.add('Random Type(Datetime) From(2017-01-01) To(2017-12-31)');
        invalidDefinitions.add('Random Type(Email)');
        invalidDefinitions.add('Random Type(Phone) Format(30 210 dD DD ddD)');
        invalidDefinitions.add('Random Type(FirstName) Group(one)');
        invalidDefinitions.add('Random Type(LastName) Group(one)');
        invalidDefinitions.add('Random Type(List) Value(1, 2, 3)');
        invalidDefinitions.add('Random Type(List) Value(1.1, 2.2, 3.3)');
        invalidDefinitions.add('Random Type(List) Value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
        invalidDefinitions.add('Random Type(List) Value(2017-01-01, 2017-02-02, 2017-03-03)');
        invalidDefinitions.add('Random Type(List) Value(One, Two, Three)');
        invalidDefinitions.add('Random Type(Number) From(1) To(100) Scale(0)');
        invalidDefinitions.add('Random Type(Picklist) Except(One,Two)');
        invalidDefinitions.add('Random Type(Picklist)');
        invalidDefinitions.add('Random Type(Postalcode) Group(one)');
        invalidDefinitions.add('Random Type(State) Group(one)');
        invalidDefinitions.add('Random Type(Street) Group(one)');
        invalidDefinitions.add('Random Type(String) Minlength(10) Maxlength(30) Startwith(Lower) Include(Lower,Upper,Digit)');
        invalidDefinitions.add('Random Type(Text) Minlength(10) Maxlength(30)');
        invalidDefinitions.add('Random Type(Url)');
        invalidDefinitions.add('Serial Lookup(Account) mode(cyclical) source(forceea)');
        invalidDefinitions.add('Serial Type(Date) From(2017-01-01) Step(2)');
        invalidDefinitions.add('Serial Type(Datetime) From(2017-01-01 02:02:02) Step(2.2)');
        invalidDefinitions.add('Serial Type(Number) From(10.2) Step(1.2) Scale(2)');
        invalidDefinitions.add('Static Lookup(Account) Field(FieldOne) Value(One) Source(Forceea)');
        invalidDefinitions.add('Static Value(10.1)');
        invalidDefinitions.add('Static Value(10)');
        invalidDefinitions.add('Static Value(2017-01-01 01:01:01)');
        invalidDefinitions.add('Static Value(2017-01-01)');
        invalidDefinitions.add('Static Value(One)');

        Test.startTest();
        Boolean expectedResult = false;
        Boolean actualResult = definitionsAreValid(
            new FObject('FObjectOne__c'), fieldApiName, validDefinitions, invalidDefinitions);
        Test.stopTest();

        System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
    }

    @IsTest
    private static void definitionIsValidForFieldDataType_url_expectFailure() {
        String fieldApiName = 'TestUrl__c';

        List<String> validDefinitions = new List<String>();
        validDefinitions.add('Copy Field(TestPicklistD__c)');
        validDefinitions.add('Copy Field(TestLookup__c) From(FObjectTwo__c.TestText__c)');
        validDefinitions.add('Random Type(List) Value(1, 2, 3)');
        validDefinitions.add('Random Type(List) Value(One, Two, Three)');
        validDefinitions.add('Random Type(Number) From(1) To(100) Scale(0)');
        validDefinitions.add('Random Type(String) Minlength(10) Maxlength(30) Startwith(Lower) Include(Lower,Upper,Digit)');
        validDefinitions.add('Random Type(Url)');
        validDefinitions.add('Serial Type(Number) From(10.2) Step(1.2) Scale(2)');
        validDefinitions.add('Static Value(10)');
        validDefinitions.add('Static Value(One)');

        List<String> invalidDefinitions = new List<String>();
        invalidDefinitions.add('Mock type(id)');
        invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Except(One,Two,Three) Source(Forceea)');
        invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Value(One,Two,Three) Source(Forceea)');
        invalidDefinitions.add('Random Lookup(Account) Source(Forceea)');
        invalidDefinitions.add('Random lookup(Account) Where(Rating = \'Hot\') source(salesforce)');
        invalidDefinitions.add('Random Type(Boolean)');
        invalidDefinitions.add('Random Type(City) Group(one)');
        invalidDefinitions.add('Random Type(Country) Group(one)');
        invalidDefinitions.add('Random Type(Date) From(2017-01-01) To(2017-12-31)');
        invalidDefinitions.add('Random Type(Datetime) From(2017-01-01) To(2017-12-31)');
        invalidDefinitions.add('Random Type(Email)');
        invalidDefinitions.add('Random Type(Phone) Format(30 210 dD DD ddD)');
        invalidDefinitions.add('Random Type(FirstName) Group(one)');
        invalidDefinitions.add('Random Type(LastName) Group(one)');
        invalidDefinitions.add('Random Type(List) Value(1.1, 2.2, 3.3)');
        invalidDefinitions.add('Random Type(List) Value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
        invalidDefinitions.add('Random Type(List) Value(2017-01-01, 2017-02-02, 2017-03-03)');
        invalidDefinitions.add('Random Type(Picklist) Except(One,Two)');
        invalidDefinitions.add('Random Type(Picklist)');
        invalidDefinitions.add('Random Type(Postalcode) Group(one)');
        invalidDefinitions.add('Random Type(State) Group(one)');
        invalidDefinitions.add('Random Type(Street) Group(one)');
        invalidDefinitions.add('Random Type(Text) Minlength(10) Maxlength(30)');
        invalidDefinitions.add('Serial Lookup(Account) mode(cyclical) source(forceea)');
        invalidDefinitions.add('Serial Type(Date) From(2017-01-01) Step(2)');
        invalidDefinitions.add('Serial Type(Datetime) From(2017-01-01 02:02:02) Step(2.2)');
        invalidDefinitions.add('Static Lookup(Account) Field(FieldOne) Value(One) Source(Forceea)');
        invalidDefinitions.add('Static Value(01:01:01)');
        invalidDefinitions.add('Static Value(10.1)');
        invalidDefinitions.add('Static Value(2017-01-01 01:01:01)');
        invalidDefinitions.add('Static Value(2017-01-01)');

        Test.startTest();
        Boolean expectedResult = false;
        Boolean actualResult = definitionsAreValid(
            new FObject('FObjectOne__c'), fieldApiName, validDefinitions, invalidDefinitions);
        Test.stopTest();

        System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
    }

    @IsTest
    private static void definitionIsValidForFieldDataType_valid_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c', 10);
        obj.setDefinition('Id', 'Mock type(id)')
            .setDefinition('TestCheckbox__c', 'Random Type(Boolean)')
            .setDefinition('TestCurrency__c', 'Random Type(Number) From(1) To(100) Scale(0)')
            .setDefinition('TestDate__c', 'Random Type(Date) From(2017-01-01) To(2017-12-31)')
            .setDefinition('TestDatetime__c', 'Random Type(Datetime) From(2017-01-01) To(2017-12-31)')
            .setDefinition('TestDecimal__c', 'Random Type(Number) From(1) To(100) Scale(0)')
            .setDefinition('TestEmail__c', 'Random Type(Email)')
            .setDefinition('TestLookup__c', 'Random lookup(FObjectTwo__c) source(Salesforce)')
            .setDefinition('TestMultiPicklistA__c', 'Random Type(Picklist)')
            .setDefinition('TestPercent__c', 'Random Type(Number) From(0) To(1) Scale(2)')
            .setDefinition('TestPhone__c', 'Random Type(Phone) Format(30 210 dD DD ddD)')
            .setDefinition('TestPicklistC__c', 'Random type(Picklist)')
            .setDefinition('TestText__c', 'Copy Field(TestPicklistC__c)')
            .setDefinition('TestText__c',
            'Random Type(String) Minlength(10) Maxlength(30) Startwith(Lower) Include(Lower,Upper,Digit)')
            .setDefinition('TestTextArea__c',
            'Random Type(String) Minlength(10) Maxlength(30) Startwith(Lower) Include(Lower,Upper,Digit)')
            .setDefinition('TestTextAreaLong__c',
            'Random Type(String) Minlength(10) Maxlength(30) Startwith(Lower) Include(Lower,Upper,Digit)')
            .setDefinition('TestTextAreaRich__c',
            'Random Type(String) Minlength(10) Maxlength(30) Startwith(Lower) Include(Lower,Upper,Digit)')
            .setDefinition('TestTime__c', 'Static value(02:02:02)')
            .setDefinition('TestUrl__c', 'Random Type(Url)')
            .getRecords();
        Test.stopTest();

        System.assert(obj.getErrors().isEmpty(), 'definitionIsValidForFieldDataType - errors found');
    }

    /* deleteAllDefinitions */

    @IsTest
    private static void deleteAllDefinitions_declareNoDefinitions_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.deleteAllDefinitions();
        Test.stopTest();

        System.assertEquals(true, obj.getAllDefinitions().isEmpty(), 'deleteAllDefinitions - errors found');
    }

    @IsTest
    private static void deleteAllDefinitions_declareSomeDefinitions_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c', 10);
        obj.setDefinition('TestText__c', 'static value(TestName_)')
            .setDefinition('TestDecimal__c', 'random type(number) from(1) to(100) scale(0)')
            .setDefinition('TestPicklistA__c', 'random type(picklist)')
            .setDefinition('TestPicklistB__c', 'random type(picklist)')
            .deleteAllDefinitions();
        Test.stopTest();

        System.assertEquals(true, obj.getAllDefinitions().isEmpty(), 'deleteAllDefinitions - errors found');
    }

    @IsTest
    private static void deleteAllDefinitions_recordsAreClearedAfterNewDefinition_expectSuccess() {
        Test.startTest();

        FObject obj = new FObject('FObjectOne__c', 10);
        obj.setDefinition('TestText__c', 'static value(TestName_)');
        obj.setDefinition('TestText__c', 'random type(number) from(1) to(100) scale(0)');
        obj.setDefinition('TestPicklistA__c', 'random type(picklist)');
        obj.setDefinition('TestPicklistB__c', 'random type(picklist)');
        List<FObjectOne__c> objRecords1 = obj.getRecords();
        Integer hash1 = objRecords1.hashCode();

        obj.deleteAllDefinitions();

        obj.setDefinition('TestText__c', 'static value(TestName_)');
        obj.setDefinition('TestText__c', 'random type(number) from(1) to(100) scale(0)');
        obj.setDefinition('TestPicklistA__c', 'random type(picklist)');
        obj.setDefinition('TestPicklistB__c', 'random type(picklist)');
        List<FObjectOne__c> objRecords2 = obj.getRecords();
        Integer hash2 = objRecords2.hashCode();

        Test.stopTest();

        System.assertNotEquals(hash1, hash2, 'deleteAllDefinitions - errors found');
    }

    /* deleteFieldDefinitions */

    @IsTest
    private static void deleteFieldDefinitions_declareNoDefinitions_expectSuccess() {
        Test.startTest();

        FObject obj = new FObject('FObjectOne__c', 10);
        obj.setDefinition('TestDecimal__c', 'random type(number) from(1) to(100) scale(0)')
            .setDefinition('TestPicklistA__c', 'random type(picklist)')
            .setDefinition('TestPicklistB__c', 'random type(picklist)')
            .deleteFieldDefinitions(FObjectOne__c.TestText__c);

        Test.stopTest();

        Boolean expectedResult = true;
        Boolean actualResult = obj.getFieldDefinitions(FObjectOne__c.TestText__c).isEmpty();
        System.assertEquals(expectedResult, actualResult, 'deleteFieldDefinitions - errors found');
    }

    @IsTest
    private static void deleteFieldDefinitions_declareSomeDefinitions_expectSuccess() {
        Test.startTest();

        FObject obj = new FObject('FObjectOne__c', 10);
        obj.setDefinition('TestDecimal__c', 'random type(number) from(1) to(100) scale(0)');
        obj.setDefinition('TestText__c', 'static value(TestName_)');
        obj.setDefinition('TestText__c', 'random type(number) from(1) to(100) scale(0)');
        obj.setDefinition('TestPicklistA__c', 'random type(picklist)');
        obj.setDefinition('TestPicklistB__c', 'random type(picklist)');
        obj.deleteFieldDefinitions(FObjectOne__c.TestText__c);

        Test.stopTest();

        Integer errors = 0;
        if (!obj.getFieldDefinitions('TestText__c').isEmpty()) {
            errors += 1;
        }
        if (obj.getFieldDefinitions('TestDecimal__c').size() != 1) {
            errors += 2;
        }
        if (obj.getFieldDefinitions('TestPicklistA__c').size() != 1) {
            errors += 4;
        }
        if (obj.getFieldDefinitions('TestPicklistB__c').size() != 1) {
            errors += 8;
        }
        System.assertEquals(0, errors, 'deleteFieldDefinitions - errors found');
    }

    @IsTest
    private static void deleteFieldDefinitions_invalidField_expectFailure() {
        Test.startTest();

        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestText__c', 'static value(TestName_)');
        obj.setDefinition('TestText__c', 'random type(number) from(1) to(100) scale(0)');
        obj.setDefinition('TestDecimal__c', 'random type(number) from(1) to(100) scale(0)');
        obj.deleteFieldDefinitions('TestTextX__c');

        Test.stopTest();

        System.assertEquals('Invalid field [TestTextX__c] in method deleteFieldDefinitions',
            obj.getErrors().get('FObjectOne__c').get(0),
            'deleteFieldDefinitions - wrong error message for invalid field');
    }

    @IsTest
    private static void deleteFieldDefinitions_recordsAreClearedAfterNewDefinition_expectSuccess() {
        Test.startTest();

        FObject obj = new FObject('FObjectOne__c', 10);
        obj.setDefinition('TestText__c', 'static value(TestName_)');
        obj.setDefinition('TestText__c', 'random type(number) from(1) to(100) scale(0)');
        obj.setDefinition('TestDecimal__c', 'random type(number) from(1) to(100) scale(0)');

        List<FObjectOne__c> objRecords1 = obj.getRecords();
        Integer hash1 = objRecords1.hashCode();

        obj.deleteFieldDefinitions(FObjectOne__c.TestText__c);

        obj.setDefinition('TestText__c', 'static value(TestName_)');
        obj.setDefinition('TestText__c', 'random type(number) from(1) to(100) scale(0)');

        List<FObjectOne__c> objRecords2 = obj.getRecords();
        Integer hash2 = objRecords2.hashCode();

        Test.stopTest();

        System.assertNotEquals(hash1, hash2, 'deleteFieldDefinitions - errors found');
    }

    /* deleteRecords */

    @IsTest
    private static void deleteRecords_whereClauseIsBlank_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c', 10);
        obj.setDefinition('TestPicklistA__c', 'random type(picklist)');
        obj.insertRecords(true);
        obj.deleteRecords('');
        Test.stopTest();

        List<FObjectOne__c> recordsAfterDelete = [SELECT Id FROM FObjectOne__c LIMIT 1000];
        Set<Id> recordIdsAfterDeleteSet = (new Map<Id, FObjectOne__c>(recordsAfterDelete)).keySet();
        Integer errors = 0;
        for (FObjectOne__c objRecord : (List<FObjectOne__c>) obj.getInsertedRecords()) {
            if (!recordIdsAfterDeleteSet.contains(objRecord.Id)) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'deleteRecords - errors found');
    }

    @IsTest
    private static void deleteRecords_whereClauseIsValid_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c', 10);
        obj.setDefinition('TestPicklistA__c', 'random type(picklist)');
        obj.insertRecords(true);
        obj.deleteRecords('TestPicklistA__c = \'a1\'');
        Test.stopTest();

        List<FObjectOne__c> recordsAfterDelete = [SELECT Id FROM FObjectOne__c LIMIT 1000];
        Set<Id> recordIdsAfterDeleteSet = (new Map<Id, FObjectOne__c>(recordsAfterDelete)).keySet();
        Integer errors = 0;
        for (FObjectOne__c objRecord : (List<FObjectOne__c>) obj.getInsertedRecords()) {
            if (!recordIdsAfterDeleteSet.contains(objRecord.Id)) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'deleteRecords - errors found');
    }

    @IsTest
    private static void deleteRecords_recordGroup_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c', 10);
        obj.setDefinition('TestPicklistA__c', 'random type(picklist)');
        obj.insertRecords(true, 'Group1');
        obj.deleteRecords('TestPicklistA__c = \'a1\'');
        Test.stopTest();

        List<FObjectOne__c> recordsAfterDelete1 = [SELECT Id FROM FObjectOne__c LIMIT 1000];
        Set<Id> recordIdsAfterDelete1Set = (new Map<Id, FObjectOne__c>(recordsAfterDelete1)).keySet();
        Integer hash1 = recordIdsAfterDelete1Set.hashCode();
        List<FObjectOne__c> recordsAfterDelete2 = obj.getInsertedRecords();
        Set<Id> recordIdsAfterDelete2Set = (new Map<Id, FObjectOne__c>(recordsAfterDelete2)).keySet();
        Integer hash2 = recordIdsAfterDelete2Set.hashCode();
        List<FObjectOne__c> recordsAfterDelete3 = obj.getInsertedGroupRecords('GROUP1');
        Set<Id> recordIdsAfterDelete3Set = (new Map<Id, FObjectOne__c>(recordsAfterDelete3)).keySet();
        Integer hash3 = recordIdsAfterDelete3Set.hashCode();

        Integer errors = 0;
        for (FObjectOne__c objRecord : (List<FObjectOne__c>) obj.getInsertedRecords()) {
            if (!recordIdsAfterDelete1Set.contains(objRecord.Id)) {
                errors += 1;
                break;
            }
        }
        if (hash1 != hash2) {
            errors += 2;
        }
        if (hash2 != hash3) {
            errors += 4;
        }
        if (!FObject.processIsValid()) {
            errors += 8;
        }
        System.assertEquals(0, errors, 'deleteRecords - errors found');
    }

    @IsTest
    private static void deleteRecords_noRecordsFound_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c', 10);
        obj.setDefinition('TestPicklistA__c', 'random type(picklist)');
        obj.insertRecords(false, 'Group1');
        List<FObjectOne__c> recordsBeforeDelete = obj.getInsertedGroupRecords('GROUP1');
        Set<Id> recordIdsBeforeDeleteSet = (new Map<Id, FObjectOne__c>(recordsBeforeDelete)).keySet();
        Integer hash = recordIdsBeforeDeleteSet.hashCode();
        obj.deleteRecords('TestPicklistA__c = \'a5\'');
        Test.stopTest();

        List<FObjectOne__c> recordsAfterDelete1 = [SELECT Id FROM FObjectOne__c LIMIT 1000];
        Set<Id> recordIdsAfterDelete1Set = (new Map<Id, FObjectOne__c>(recordsAfterDelete1)).keySet();
        Integer hash1 = recordIdsAfterDelete1Set.hashCode();
        List<FObjectOne__c> recordsAfterDelete2 = obj.getInsertedRecords();
        Set<Id> recordIdsAfterDelete2Set = (new Map<Id, FObjectOne__c>(recordsAfterDelete2)).keySet();
        Integer hash2 = recordIdsAfterDelete2Set.hashCode();
        List<FObjectOne__c> recordsAfterDelete3 = obj.getInsertedGroupRecords('GROUP1');
        Set<Id> recordIdsAfterDelete3Set = (new Map<Id, FObjectOne__c>(recordsAfterDelete3)).keySet();
        Integer hash3 = recordIdsAfterDelete3Set.hashCode();

        Integer errors = 0;
        for (FObjectOne__c objRecord : (List<FObjectOne__c>) obj.getInsertedRecords()) {
            if (!recordIdsAfterDelete1Set.contains(objRecord.Id)) {
                errors += 1;
                break;
            }
        }
        if (hash != hash1) {
            errors += 2;
        }
        if (hash1 != hash2) {
            errors += 4;
        }
        if (hash2 != hash3) {
            errors += 8;
        }
        if (!FObject.processIsValid()) {
            errors += 16;
        }
        System.assertEquals(0, errors, 'deleteRecords - errors found');
    }

    @IsTest
    private static void deleteRecords_whereClauseIsInvalid_expectFailure() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestPicklistA__c', 'random type(picklist)');
        obj.insertRecords(true);
        obj.deleteRecords('TestPicklistA__c == a1');
        Test.stopTest();

        String expectedResult = 'Found errors selecting records of [FObjectOne__c]';
        String actualResult = obj.getErrors().get('FObjectOne__c').get(0);
        Boolean result = actualResult.startsWith(expectedResult);
        System.assertEquals(true, result, 'deleteRecords - errors found');
    }

    @IsTest
    private static void deleteRecords_deleteException_expectFailure() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestPicklistA__c', 'random type(picklist)');
        obj.insertRecords(true);
        Test.setReadOnlyApplicationMode(true);
        Database.DeleteResult[] deleteResults = obj.deleteRecords('TestPicklistA__c = \'a1\'');
        Test.stopTest();

        Integer errors = 0;
        for (Database.DeleteResult dr : deleteResults) {
            if (dr.isSuccess()) {
                errors++;
            }
        }
        if (FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'deleteRecords - errors found');
    }

    /* excludeInactiveLookupRecords */

    @IsTest
    private static void excludeInactiveLookupRecords_method_expectSuccess() {
        FObject.setGlobalMocking(true);

        Test.startTest();
        FObject objUser = new FObject('User', 10);
        objUser.insertRecords(true);

        FObject objFour = new FObject('FObjectFour__c', 10)
            .excludeInactiveLookupRecords(true)
            .setDefinition('TestLookupUser__c', 'random lookup(User) source(forceea)');
        objFour.insertRecords(true);
        Test.stopTest();

        List<FObjectFour__c> records = [SELECT TestLookupUser__r.IsActive FROM FObjectFour__c];
        Integer errors = 0;
        for (FObjectFour__c record : records) {
            if (!record.TestLookupUser__r.IsActive) {
                errors += 1;
                break;
            }
        }
        if (!FObject.processIsValid()) {
            errors += 2;
        }
        System.assertEquals(0, errors, 'excludeInactiveLookupRecords - errors found');
    }

    @IsTest
    private static void excludeInactiveLookupRecords_property_expectSuccess() {
        FObject.setGlobalMocking(true);

        Test.startTest();
        FObject objUser = new FObject('User', 10);
        objUser.insertRecords(true);

        FObject objFour = new FObject('FObjectFour__c', 10)
            .setDefinition('TestLookupUser__c', 'random lookup(User) source(forceea)');
        objFour.excludeInactiveLookupRecords(true);
        objFour.insertRecords(true);
        Test.stopTest();

        List<FObjectFour__c> records = [SELECT TestLookupUser__r.IsActive FROM FObjectFour__c];
        Integer errors = 0;
        for (FObjectFour__c record : records) {
            if (!record.TestLookupUser__r.IsActive) {
                errors += 1;
                break;
            }
        }
        if (!FObject.processIsValid()) {
            errors += 2;
        }
        System.assertEquals(0, errors, 'excludeInactiveLookupRecords - errors found');
    }

    /* FObject */

    @IsTest
    private static void fObject_invalidObject_expectFailure() {
        Test.startTest();
        FObject obj = new FObject(' FObjectOneX__c ');
        Test.stopTest();

        String expectedResult = 'Invalid SObject [FObjectOneX__c]';
        String actualResult = obj.getErrors().get('FObjectOneX__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'FObject constructor - errors found');
    }

    @IsTest
    private static void fObject_blankObject_expectFailure() {
        Test.startTest();
        FObject obj = new FObject('');
        Test.stopTest();

        String expectedResult = 'Invalid SObject []';
        String actualResult = obj.getErrors().get('').get(0);
        System.assertEquals(expectedResult, actualResult, 'FObject constructor - errors found');
    }

    @IsTest
    private static void fObject_constructorWithDefaultRecords_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(' FObjectOne__c ');
        obj.setDefinition(' TestDecimal__c ', ' Random type(number ) from( 100) to(1000000 ) scale(3) ');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        System.assertEquals(201, records.size(), 'FObject constructor - errors found');
    }

    @IsTest
    private static void fObject_constructorWithRecords_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c', 10);
        obj.setDefinition('TestDecimal__c', 'Random Type (number ) from( 100) to(1000000 ) scale(3)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        System.assertEquals(10, records.size(), 'FObject constructor - errors found');
    }

    /* forceeaDebug */

    @IsTest
    private static void forceeaDebug_valid_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c', 10);
        FObject.showDebugLog = false;

        obj.setDefinition('TestText__c', 'random type(firstname) group(one)')
            .insertRecords(true);
        Test.stopTest();

        System.assert(!FObject.showDebugLog && FObject.processIsValid(), 'forceeaDebug - errors found');
    }

    /* getAllDefinitions */

    @IsTest
    private static void getAllDefinitions_multipleChecks_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c', 10);
        obj.setDefinition('TestText__c', 'Random Type(Date) From(2017-01-01) To(2017-12-31)');
        obj.setDefinition('TestText__c', 'static value(One)');
        obj.setDefinition('TestDatetime__c', 'Random Type(Datetime) From(2017-01-01) To(2017-12-31)');
        obj.setDefinition('TestDecimal__c', 'Random Type(Number) From(1) To(100) Scale(0)');
        obj.setDefinition('TestEmail__c', 'Random Type(Email)');
        Map<String, List<String>> definitions = obj.getAllDefinitions();
        Test.stopTest();

        List<String> fields = new List<String>(definitions.keySet());

        Integer errors = 0;
        if (definitions.size() != 4 || definitions.get('TestText__c').size() != 2) {
            errors += 1;
        }
        if (fields.size() != 4) {
            errors += 2;
        }
        if (fields[3] != 'TestEmail__c') {
            errors += 4;
        }
        if (definitions.get('TestText__c').get(1) != 'static value(One)') {
            errors += 8;
        }
        if (!FObject.processIsValid()) {
            errors += 16;
        }
        System.assertEquals(0, errors, 'getAllDefinitions - errors found');
    }

    /* getDefaultRecords */

    @IsTest
    private static void getDefaultRecords_lessThan11Records_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c', 10);
        obj.setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) source(forceea)');
        obj.insertRecords(true);
        Test.stopTest();

        List<FObjectTwo__c> lookupRecords = [SELECT Id FROM FObjectTwo__c LIMIT 1000];
        Integer expectedResult = 10;
        Integer actualResult = lookupRecords.size();
        System.assertEquals(expectedResult, actualResult, 'getDefaultRecords - errors found');
    }

    @IsTest
    private static void getDefaultRecords_moreThan10Records_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c', 20);
        obj.setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) source(forceea)');
        obj.insertRecords(true);
        Test.stopTest();

        List<FObjectTwo__c> lookupRecords = [SELECT Id FROM FObjectTwo__c LIMIT 1000];
        Integer expectedResult = 12;
        Integer actualResult = lookupRecords.size();
        System.assertEquals(expectedResult, actualResult, 'getDefaultRecords - errors found');
    }

    @IsTest
    private static void getGroupName_isInsert_expectSuccess() {
        String groupName = 'MyGroup';

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c', 5);
        obj.setDefinition(FObjectOne__c.TestText__c, 'static value(test)');
        obj.insertRecords(true, groupName);
        Test.stopTest();

        Boolean result = FObject.processIsValid && obj.getGroupName() == groupName;
        System.assert(result, 'getFieldApiName - errors found');
    }

    @IsTest
    private static void getGroupName_invalidInSetGroupName_expectSuccess() {
        String groupName = 'MyGroup';

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c', 5);
        obj.setDefinition(FObjectOne__c.TestText__c, 'static value(test)')
            .setGroupName(groupName);
        obj.insertRecords(true);
        Test.stopTest();

        Boolean result = FObject.processIsValid && obj.getGroupName() == groupName;
        System.assert(result, 'getFieldApiName - errors found');
    }

    @IsTest
    private static void getFieldApiName_valid_expectSuccess() {
        Test.startTest();
        String fieldApiName1 = FObject.getFieldApiName('FObjectOne__c', null);
        String fieldApiName2 = FObject.getFieldApiName('FObjectOne__c', '');
        Test.stopTest();

        Boolean result = String.isBlank(fieldApiName1) && String.isBlank(fieldApiName2);
        System.assert(result, 'getFieldApiName - errors found');
    }

    /* getInsertedRecords */

    @IsTest
    private static void getInsertedRecords_twoInstancesOfSameObject_expectSuccess() {
        Integer size1 = 10;
        Integer size2 = 5;

        Test.startTest();
        FObject obj1 = new FObject('FObjectOne__c', size1)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(a1)');
        obj1.insertRecords(true);

        FObject obj2 = new FObject('FObjectOne__c', size2)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(a1)');
        obj2.insertRecords(true);
        Test.stopTest();

        List<FObjectOne__c> records1 = ((List<FObjectOne__c>) obj1.getInsertedRecords());
        List<FObjectOne__c> records2 = ((List<FObjectOne__c>) obj2.getInsertedRecords());
        System.assert(records1.size() == size1 && records2.size() == size2, 'getInsertedRecords - errors found');
    }

    @IsTest
    private static void getInsertedRecords_twoInsertionsAllOrNoneTrue_expectSuccess() {
        List<FObjectOne__c> records1 = new List<FObjectOne__c>();
        List<FObjectOne__c> records2 = new List<FObjectOne__c>();

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c', 10)
            .setDefinition('TestText__c', 'static value(a1)');
        obj.insertRecords(true);
        records1.addAll((List<FObjectOne__c>) obj.getRecords());

        obj.deleteAllDefinitions();

        obj.setDefinition('TestText__c', 'static value(a2)')
            .insertRecords(true);
        records1.addAll((List<FObjectOne__c>) obj.getRecords());
        Test.stopTest();

        records2 = (List<FObjectOne__c>) obj.getInsertedRecords();

        Integer hash1 = records1.hashCode();
        Integer hash2 = records2.hashCode();
        System.assertEquals(hash1, hash2, 'getInsertedRecords - errors found');
    }

    @IsTest
    private static void getInsertedRecords_twoInsertionsAllOrNoneFalse_expectSuccess() {
        List<FObjectOne__c> records1 = new List<FObjectOne__c>();
        List<FObjectOne__c> records2 = new List<FObjectOne__c>();

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c', 100);
        obj.setDefinition('TestText__c', 'static value(a1)');
        obj.insertRecords(false);
        records1.addAll((List<FObjectOne__c>) obj.getRecords());

        obj.deleteAllDefinitions();

        obj.setDefinition('TestText__c', 'static value(a2)');
        obj.insertRecords(false);
        records1.addAll((List<FObjectOne__c>) obj.getRecords());
        Test.stopTest();

        records2 = (List<FObjectOne__c>) obj.getInsertedRecords();

        Integer hash1 = records1.hashCode();
        Integer hash2 = records2.hashCode();
        System.assertEquals(hash1, hash2, 'getInsertedRecords - errors found');
    }

    /* getInsertedGroupRecords */

    @IsTest
    private static void getInsertedGroupRecords_sameInstance_expectSuccess() {
        String group1 = 'GroupA';
        String group2 = 'GroupB';

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestIntegerUnique__c, 'serial type(number) from(1) step(1) scale(0)');
        obj.insertRecords(true, group1);

        obj.deleteFieldDefinitions(FObjectOne__c.TestIntegerUnique__c)
            .setDefinition(FObjectOne__c.TestIntegerUnique__c, 'serial type(number) from(1) step(1) scale(0)');
        obj.insertRecords(true, group2);
        Test.stopTest();

        System.assert(insertedGroupRecordsAreValidForSameInstance(obj, group1, group2), 'getInsertedGroupRecords - errors found');
    }

    @IsTest
    private static void getInsertedGroupRecords_differentInstances_expectSuccess() {
        String group1 = 'GroupA';
        String group2 = 'GroupB';

        Test.startTest();
        FObject.setSeed(1);
        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.Id, 'mock type(id)')
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(number) from(1) step(1) scale(0)');
        obj1.insertRecords(true, group1);

        FObject.setSeed(1);
        FObject obj2 = new FObject(FObjectOne__c.SObjectType, 10)
            .setNumberOfNextRecord(1)
            .setDefinition(FObjectOne__c.Id, 'mock type(id)')
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(number) from(1) step(1) scale(0)');
        obj2.insertRecords(true, group2);
        Test.stopTest();

        System.assert(insertedGroupRecordsAreValidForDifferentInstances(obj1, obj2, group1, group2), 'getInsertedGroupRecords - errors found');
    }

    /* getInsertedRecordsStatic */

    @IsTest
    private static void getInsertedRecordsStatic_invalidObject_expectFailure() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c', 10)
            .setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) source(forceea)');
        obj.insertRecords(true);
        Test.stopTest();

        List<FObjectTwo__c> lookupRecords = (List<FObjectTwo__c>) FObject.getInsertedRecords('FObjectTwoX__c');
        System.assert(!FObject.processIsValid(), 'getInsertedRecords - errors found');
    }

    @IsTest
    private static void getInsertedRecordsStatic_lookupRecords_expectSuccess() {
        Integer size1 = 5;
        Integer size2 = 10;
        Integer size3 = 15;

        Test.startTest();
        FObject obj1 = new FObject('FObjectTwo__c', size1);
        obj1.setDefinition('TestText__c', 'serial type(number) from(1) step(1) scale(0)');
        obj1.insertRecords(true);
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) FObject.getInsertedRecords('FObjectTwo__c');

        FObject obj2 = new FObject('FObjectOne__c', size2);
        obj2.setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) source(forceea)');
        obj2.insertRecords(true);
        List<FObjectOne__c> records2 = (List<FObjectOne__c>) FObject.getInsertedRecords('FObjectOne__c');

        FObject obj3 = new FObject('FObjectOne__c', size3);
        obj3.setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) source(forceea)');
        obj3.insertRecords(true);
        List<FObjectOne__c> records3 = (List<FObjectOne__c>) FObject.getInsertedRecords('FObjectOne__c');
        Test.stopTest();

        Integer errors = 0;
        if (records1.size() != size1) {
            errors += 1;
        }
        if (records2.size() != size2) {
            errors += 2;
        }
        if (records3.size() != (size2 + size3)) {
            errors += 4;
        }
        if (!FObject.processIsValid()) {
            errors += 8;
        }
        System.assertEquals(0, errors, 'getInsertedRecords - errors found');
    }

    @IsTest
    private static void getInsertedGroupRecordsStatic_valid_expectSuccess() {
        Integer size1 = 5;
        Integer size2 = 10;
        Integer size3 = 20;

        Test.startTest();
        FObject obj1 = new FObject('FObjectOne__c', size1);
        obj1.setDefinition('TestText__c', 'random type(list) value(v1,v2)');
        obj1.insertRecords(true, 'GroupA');

        obj1.deleteFieldDefinitions('TestText__c')
            .setNumberOfRecords(size2)
            .setDefinition('TestText__c', 'random type(list) value(v3,v4)');
        obj1.insertRecords(true, 'GroupB');

        FObject obj2 = new FObject('FObjectOne__c', size3)
            .setDefinition('TestText__c', 'random type(list) value(v1,v2)');
        obj2.insertRecords(true);
        Test.stopTest();

        List<FObjectOne__c> recordsA1 = (List<FObjectOne__c>) obj1.getInsertedGroupRecords('GROUPA');
        List<FObjectOne__c> recordsA2 =
            (List<FObjectOne__c>) FObject.getInsertedGroupRecords('FObjectOne__c', 'GROUPA');

        List<FObjectOne__c> recordsB1 = (List<FObjectOne__c>) obj1.getInsertedGroupRecords('GROUPB');
        List<FObjectOne__c> recordsB2 =
            (List<FObjectOne__c>) FObject.getInsertedGroupRecords('FObjectOne__c', 'GROUPB');

        List<FObjectOne__c> recordsBlank1 = (List<FObjectOne__c>) obj1.getInsertedGroupRecords('');
        List<FObjectOne__c> recordsBlank2 = (List<FObjectOne__c>) obj1.getInsertedGroupRecords(null);
        List<FObjectOne__c> recordsBlank3 = (List<FObjectOne__c>) obj1.getInsertedRecords();
        List<FObjectOne__c> recordsC = (List<FObjectOne__c>) obj1.getInsertedGroupRecords('GroupC');

        Integer errors = 0;
        if (recordsA1.hashCode() != recordsA2.hashCode()) {
            errors += 1;
        }
        if (recordsB1.hashCode() != recordsB2.hashCode()) {
            errors += 2;
        }
        Integer hash1 = recordsBlank1.hashCode();
        Integer hash2 = recordsBlank2.hashCode();
        Integer hash3 = recordsBlank3.hashCode();
        if (hash1 != hash2 && hash2 != hash3) {
            errors += 4;
        }
        if (!recordsC.isEmpty()) {
            errors += 8;
        }
        if (!FObject.processIsValid()) {
            errors += 16;
        }
        System.assertEquals(0, errors, 'getInsertedGroupRecords - errors found');
    }

    @IsTest
    private static void getInsertedGroupRecordsStatic_invalidObject_expectFailure() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) source(forceea)');
        obj.insertRecords(true, 'One');
        Test.stopTest();

        List<FObjectTwo__c> lookupRecords = (List<FObjectTwo__c>) FObject.getInsertedGroupRecords('FObjectTwoX__c', 'One');
        Boolean expectedResult = false;
        Boolean actualResult = FObject.processIsValid();
        System.assertEquals(expectedResult, actualResult, 'getInsertedGroupRecords - errors found');
    }

    /* getNumberOfRecords */

    @IsTest
    private static void getNumberOfRecords_valid_expectSuccess() {
        Integer numberOfRecords = 100;

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c', 10)
            .setNumberOfRecords(numberOfRecords);

        Boolean result = FObject.processIsValid() && (obj.getNumberOfRecords() == numberOfRecords);
        System.assert(result == true, 'getNumberOfRecords - errors found');
    }

    @IsTest
    private static void getNumberOfRecords_invalid_expectSuccess() {
        Integer numberOfRecords = -10;

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c', 10)
            .setNumberOfRecords(numberOfRecords);

        Boolean result = FObject.processIsValid() && (obj.getNumberOfRecords() == 1);
        System.assert(result == true, 'getNumberOfRecords - errors found');
    }

    /* getPartitionFieldName */

    @IsTest
    private static void getPartitionFieldName_inInsert_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c', 20)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(test)')
            .setPartitionFieldName(FObjectOne__c.ForceeaPartition__c);
        Test.stopTest();

        Boolean result = FObject.processIsValid && obj.getPartitionFieldName() == 'ForceeaPartition__c';
        System.assert(result, 'getPartitionFieldName - errors found');
    }

    /* getRecords */

    @IsTest
    private static void getRecords_withoutNewDefinitions_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c', 10);
        obj.setDefinition('TestText__c', 'static value(sample)');
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj.getRecords();
        Integer hash1 = records1.hashCode();

        obj.setNumberOfRecords(100);
        List<FObjectOne__c> records2 = (List<FObjectOne__c>) obj.getRecords();
        Integer hash2 = records2.hashCode();
        Test.stopTest();

        Boolean expectedResult = true;
        Boolean actualResult = (records1.size() == records2.size()) && (hash1 == hash2);
        System.assertEquals(expectedResult, actualResult, 'getRecords - errors found');
    }

    @IsTest
    private static void getRecords_insertRecordsAfterNewDefinitions_expectSuccess() {
        Integer size1 = 201;
        Integer size2 = 100;

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c', size1);
        obj.setDefinition('TestInteger__c', 'serial type(number) from(1) step(1) scale(0)');
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj.getRecords();

        obj.setNumberOfRecords(size2);
        obj.deleteFieldDefinitions('TestInteger__c');
        obj.setDefinition('TestInteger__c', 'serial type(number) from(1) step(1) scale(0)');
        List<FObjectOne__c> records2 = (List<FObjectOne__c>) obj.getRecords();
        obj.insertRecords(true);
        Test.stopTest();

        List<FObjectOne__c> insertedRecords = [SELECT Id, TestInteger__c FROM FObjectOne__c LIMIT 1000];
        Integer errors = 0;
        if (records1.size() + records2.size() != insertedRecords.size()) {
            errors++;
        }
        if (records2[records2.size() - 1].TestInteger__c != (size1 + size2)) {
            errors++;
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'getRecords - errors found');
    }

    @IsTest
    private static void getRecords_insertRecordsBeforeGetRecords_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c', 10);
        obj.setDefinition('TestText__c', 'static value(sample)');
        obj.insertRecords(true);
        List<FObjectOne__c> records = obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Set<Id> recordIdsSet = (new Map<Id, SObject>(records)).keySet();
        for (FObjectOne__c objRecord : [SELECT Id FROM FObjectOne__c LIMIT 1000]) {
            if (!recordIdsSet.contains(objRecord.Id)) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'getRecords - errors found');
    }

    @IsTest
    private static void getRecords_insertRecordsTwice_expectSuccess() {
        Integer size1 = 201;
        Integer size2 = 100;

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c', size1);
        obj.setDefinition(FObjectOne__c.TestInteger__c,
            'serial type(number) from(1) step(1) scale(0)');
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj.getRecords();
        obj.insertRecords(true);

        obj.setNumberOfRecords(size2);
        obj.insertRecords(true);
        List<FObjectOne__c> records2 = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        List<FObjectOne__c> insertedRecords = [SELECT Id, TestInteger__c FROM FObjectOne__c LIMIT 1000];
        Integer errors = 0;
        if (records1.size() + records2.size() != insertedRecords.size()) {
            errors++;
        }
        if (records2[records2.size() - 1].TestInteger__c != (size1 + size2)) {
            errors++;
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'getRecords - errors found');
    }

    @IsTest
    private static void getRecords_afterRecordsAreDeleted_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c', 10);
        obj.setDefinition('TestText__c', 'random type(list) value(v1,v2,v3)');
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj.getRecords();
        obj.insertRecords(true);
        obj.deleteRecords('TestText__c = \'v1\'');
        Test.stopTest();

        Boolean condition1 = true;
        for (FObjectOne__c objRecord : [SELECT TestText__c FROM FObjectOne__c LIMIT 1000]) {
            if (objRecord.TestText__c == 'v1') {
                condition1 = false;
                break;
            }
        }
        List<FObjectOne__c> records2 = (List<FObjectOne__c>) obj.getRecords();
        Boolean expectedResult = true;
        Boolean condition2 = (records1.size() == records2.size());
        Boolean actualResult = condition1 && condition2;
        System.assertEquals(expectedResult, actualResult, 'getRecords - errors found');
    }

    @IsTest
    private static void getRecords_amendFieldValues_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c', 10);
        obj.setDefinition('TestDecimal__c', 'random type(number) from(1) to(100) scale(0)');

        for (FObjectOne__c objRecord : (List<FObjectOne__c>) obj.getRecords()) {
            objRecord.TestDecimal__c = objRecord.TestDecimal__c * 0.1;
        }
        obj.createRecords();
        for (FObjectOne__c objRecord : (List<FObjectOne__c>) obj.getRecords()) {
            objRecord.TestDecimal__c = 100;
        }
        obj.insertRecords(true);
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c objRecord : [SELECT TestDecimal__c FROM FObjectOne__c LIMIT 1000]) {
            if (objRecord.TestDecimal__c > 10 && objRecord.TestDecimal__c < 100) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'getRecords - errors found');
    }

    /* insertRecords */

    @IsTest
    private static void insertRecords_allOrNoneTrue_expectFailure() {
        Boolean hasErrors = false;

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setRequiredFields(false);

        obj.setDefinition('TestPicklistC__c', 'static value(a1)');
        try {
            obj.insertRecords(true);
        } catch (DmlException ex) {
            hasErrors = true;
        }
        Test.stopTest();

        System.assertEquals(true, hasErrors, 'insertRecords - errors found');
    }

    @IsTest
    private static void insertRecords_allOrNoneFalse_expectFailure() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setRequiredFields(false);
        obj.setDefinition('TestPicklistC__c', 'static value(a1)');
        List<Database.SaveResult> saveResults = obj.insertRecords(false);
        Test.stopTest();

        Integer errors = 0;
        for (Database.SaveResult sr : saveResults) {
            if (sr.isSuccess()) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'insertRecords - errors found');
    }

    @IsTest
    private static void insertRecords_attachments_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject('Attachment', 10);
        obj.setDefinition('Name', 'static value(Attachment)');
        obj.setDefinition('Name', 'serial type(number) from(1) step(1) scale(0)');
        obj.setDefinition('Body', 'random type(number) from(1) to(100) scale(2)');
        obj.insertRecords(true);
        Test.stopTest();

        Decimal value = 0;
        Integer errors = 0;
        for (Attachment objRecord : [SELECT Body FROM Attachment LIMIT 100]) {
            value = Decimal.valueOf(objRecord.Body.toString());
            if (value < 1 || value > 100) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'insertRecords - errors found');
    }

    @IsTest
    private static void insertRecords_createRecordsAsUser_expectSuccess() {
        Test.startTest();
        FObject userObj = new FObject('User', 1);
        userObj.setDefinition('Title', 'static value(Developer)');
        userObj.setDefinition('ProfileId',
            'static lookup(Profile) field(Name) value(System Administrator) source(salesforce)');
        List<Database.SaveResult> saveResults = userObj.insertRecords(true);

        if (saveResults[0].isSuccess()) {
            List<User> users = (List<User>) userObj.getRecords();
            System.runAs(users[0]) {
                FObject obj = new FObject('FObjectOne__c');
                saveResults = obj.insertRecords(false);
            }
        }
        Test.stopTest();

        Integer errors = 0;
        for (Database.SaveResult sr : saveResults) {
            if (!sr.isSuccess()) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'insertRecords - errors found');
    }

    @IsTest
    private static void insertRecords_negativeRecords_expectFailure() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c', -1);
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid number of records of [FObjectOne__c]';
        String actualResult = obj.getErrors().get('FObjectOne__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'insertRecords - errors found');
    }

    @IsTest
    private static void insertRecords_userWithProfile_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject('User', 1);
        obj.setDefinition('ProfileId', 'static lookup(Profile) field(Name) value(System Administrator) source(salesforce)');
        obj.setDefinition('Title', 'static value(Forceea Developer)');
        List<Database.SaveResult> saveResults = obj.insertRecords(false);
        Test.stopTest();

        Integer errors = 0;
        for (Database.SaveResult sr : saveResults) {
            if (!sr.isSuccess()) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'insertRecords - errors found');
    }

    @IsTest
    private static void insertRecords_noDefinitions_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c', 10);
        List<Database.SaveResult> saveResults = obj.insertRecords(false);
        Test.stopTest();

        Integer errors = 0;
        for (Database.SaveResult sr : saveResults) {
            if (!sr.isSuccess()) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'insertRecords - errors found');
    }

    @IsTest
    private static void insertRecords_missingRequiredFields_expectFailure() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setRequiredFields = false;
        List<Database.SaveResult> saveResults = obj.insertRecords(false);
        Test.stopTest();

        Integer errors = 0;
        for (Database.SaveResult sr : saveResults) {
            if (sr.isSuccess()) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'insertRecords - errors found');
    }

    @IsTest
    private static void insertRecords_comboBoxWithPicklist_expectSuccess() {
        FObject obj = new FObject('Event', 10);
        obj.setDefinition('Subject', 'random type(picklist)');
        obj.setDefinition('Type', 'random type(picklist)');
        obj.setDefinition('WhoId', 'random lookup(Contact) source(forceea)');
        obj.setDefinition('ActivityDatetime', 'random type(datetime) from(2017-10-1) to(2017-12-31)');
        obj.setDefinition('DurationInMinutes', 'random type(number) from(1) to(10) scale(0)');
        List<Database.SaveResult> saveResults = obj.insertRecords(false);

        Integer errors = 0;
        for (Database.SaveResult sr : saveResults) {
            if (!sr.isSuccess()) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'insertRecords - errors found');
    }

    @IsTest
    private static void insertRecords_comboBoxWithPicklistExcept_expectSuccess() {
        FObject obj = new FObject('Event', 10);
        obj.setDefinition('Subject', 'random type(picklist) except(Call, Email)');
        obj.setDefinition('Type', 'random type(picklist)');
        obj.setDefinition('WhoId', 'random lookup(Contact) source(forceea)');
        obj.setDefinition('ActivityDatetime', 'random type(datetime) from(2017-10-1) to(2017-12-31)');
        obj.setDefinition('DurationInMinutes', 'random type(number) from(1) to(10) scale(0)');
        List<Database.SaveResult> saveResults = obj.insertRecords(false);

        Integer errors = 0;
        for (Database.SaveResult sr : saveResults) {
            if (!sr.isSuccess()) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'insertRecords - errors found');
    }

    @IsTest
    private static void insertRecords_comboBoxWithList_expectSuccess() {
        FObject obj = new FObject('Event', 10);
        obj.setDefinition('Subject', 'random type(list) value(Call, Email)');
        obj.setDefinition('Type', 'random type(picklist)');
        obj.setDefinition('WhoId', 'random lookup(Contact) source(forceea)');
        obj.setDefinition('ActivityDatetime', 'random type(datetime) from(2017-10-1) to(2017-12-31)');
        obj.setDefinition('DurationInMinutes', 'random type(number) from(1) to(10) scale(0)');
        List<Database.SaveResult> saveResults = obj.insertRecords(false);

        Integer errors = 0;
        for (Database.SaveResult sr : saveResults) {
            if (!sr.isSuccess()) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'insertRecords - errors found');
    }

    @IsTest
    private static void insertRecords_comboBoxWithStaticExistingValue_expectSuccess() {
        FObject obj = new FObject('Event', 10);
        obj.setDefinition('Subject', 'static value(Call)');
        obj.setDefinition('Type', 'random type(picklist)');
        obj.setDefinition('WhoId', 'random lookup(Contact) source(forceea)');
        obj.setDefinition('ActivityDatetime', 'random type(datetime) from(2017-10-1) to(2017-12-31)');
        obj.setDefinition('DurationInMinutes', 'random type(number) from(1) to(10) scale(0)');
        List<Database.SaveResult> saveResults = obj.insertRecords(false);

        Integer errors = 0;
        for (Database.SaveResult sr : saveResults) {
            if (!sr.isSuccess()) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'insertRecords - errors found');
    }

    @IsTest
    private static void insertRecords_comboBoxWithStaticNewValue_expectSuccess() {
        FObject obj = new FObject('Event', 10);
        obj.setDefinition('Subject', 'static value(CallX)');
        obj.setDefinition('Type', 'random type(picklist)');
        obj.setDefinition('WhoId', 'random lookup(Contact) source(forceea)');
        obj.setDefinition('ActivityDatetime', 'random type(datetime) from(2017-10-1) to(2017-12-31)');
        obj.setDefinition('DurationInMinutes', 'random type(number) from(1) to(10) scale(0)');
        List<Database.SaveResult> saveResults = obj.insertRecords(false);

        Integer errors = 0;
        for (Database.SaveResult sr : saveResults) {
            if (!sr.isSuccess()) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'insertRecords - errors found');
    }

    /* Pseudo-random Number Generator */

    @IsTest
    private static void prng_checkGenerator_expectSuccess() {
        Test.startTest();
        FObject obj1 = new FObject('FObjectOne__c');
        FObject.setSeed(19660805);
        obj1.setDefinition('TestInteger__c', 'random type(number) from(1) to(100) scale(0)');
        obj1.createRecords();
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();

        FObject obj2 = new FObject('FObjectOne__c');
        FObject.setSeed(19660805);
        obj2.setDefinition('TestInteger__c', 'random type(number) from(1) to(100) scale(0)');
        obj2.createRecords();
        List<FObjectOne__c> records2 = (List<FObjectOne__c>) obj2.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (Integer counter = 0; counter < 100; counter++) {
            if (records1.get(counter).TestInteger__c != records2.get(counter).TestInteger__c ||
                records1.get(counter).TestTextRequired__c != records2.get(counter).TestTextRequired__c) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'PRNG - errors found');
    }

    /* method setDefinition */

    @IsTest
    private static void setDefinition_scriptIsBlank_expectFailure() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestText__c', '');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult1 = 'Invalid command [] in definition []';
        String expectedResult2 = 'Invalid definition [] of field [TestText__c]';
        String actualResult1 = obj.getErrors().get('TestText__c').get(0);
        String actualResult2 = obj.getErrors().get('TestText__c').get(1);
        System.assertEquals(expectedResult1 + expectedResult2, actualResult1 + actualResult2, 'setDefinition - errors found');
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
        FObject obj = new FObject(' FObjectOne__c ');
        obj.setDefinition(field1, definition1);
        obj.setDefinition(field2, definition2);
        obj.setDefinition(field3, definition3);
        obj.setDefinition(field4, definition4);
        obj.setDefinition(field5, definition5);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
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
        if (!FObject.processIsValid()) {
            errors += 32;
        }
        System.assertEquals(0, errors, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_missingOpeningParenthesis1_expectFailure() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestText__c', 'Static Value arg1) ');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid syntax in definition [Static Value arg1)] of field [TestText__c]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_missingOpeningParenthesis2_expectFailure() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestText__c', 'Static Value "arg1")');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid syntax in definition [Static Value "arg1")] of field [TestText__c]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_missingOpeningParenthesis3_expectFailure() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestText__c', 'Static Value arg1, arg2) ');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid syntax in definition [Static Value arg1, arg2)] of field [TestText__c]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_missingOpeningParenthesis4_expectFailure() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestText__c', 'Static Value "arg1", arg2)');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid syntax in definition [Static Value "arg1", arg2)] of field [TestText__c]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_missingClosingParenthesis1_expectFailure() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestText__c', 'Static Value(arg1');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid syntax in definition [Static Value(arg1] of field [TestText__c]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_missingClosingParenthesis2_expectFailure() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestText__c', ' Static  Value("arg1" ');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid syntax in definition [Static  Value("arg1"] of field [TestText__c]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_missingClosingParenthesis3_expectFailure() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestText__c', 'Static Value(arg1, arg2');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid syntax in definition [Static Value(arg1, arg2] of field [TestText__c]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_missingClosingParenthesis4_expectFailure() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestText__c', 'Static Value("arg1", arg2');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid syntax in definition [Static Value("arg1", arg2] of field [TestText__c]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_missingClosingDoubleQuotes1_expectFailure() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestText__c', 'Static Value("arg1)');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid syntax in definition [Static Value("arg1)] of field [TestText__c]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_missingClosingDoubleQuotes2_expectFailure() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestText__c', 'Random Type(List) Value(arg1, "arg2)');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid syntax in definition [Random Type(List) Value(arg1, "arg2)] of field [TestText__c]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_missingClosingDoubleQuotes3_expectFailure() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestText__c', 'Random Type(List) Value("arg1, arg2)');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid syntax in definition [Random Type(List) Value("arg1, arg2)] of field [TestText__c]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_invalidComma_expectFailure() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestText__c', 'Random Type(List) ,Value(arg1, "arg2")');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid parameter [,Value] in definition [Random Type(List) ,Value(arg1, "arg2")]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_invalidDoubleQuotes1_expectFailure() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestText__c', 'Random Type(List) "Value(arg1, "arg2")');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid parameter ["Value] in definition [Random Type(List) "Value(arg1, "arg2")]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_invalidDoubleQuotes2_expectFailure() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestText__c', 'Random Type(List) Value" (arg1, "arg2")');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid parameter [Value"] in definition [Random Type(List) Value" (arg1, "arg2")]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }


    @IsTest
    private static void setDefinition_invalidDoubleQuotes4_expectFailure() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestText__c', 'Random Type(List) Value(arg1, ""arg2")');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid syntax in definition [Random Type(List) Value(arg1, ""arg2")] of field [TestText__c]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_invalidDoubleQuotes5_expectFailure() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestText__c', 'Random Type(List) Value(arg1, "arg2"")');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid syntax in definition [Random Type(List) Value(arg1, "arg2"")] of field [TestText__c]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_invalidDoubleQuotes6_expectFailure() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestText__c', 'Random Type(List) Value(arg1, "arg2")"');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid syntax in definition [Random Type(List) Value(arg1, "arg2")"] of field [TestText__c]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_fieldIsBlank_expectFailure() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('', 'Static Value(Company)');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid field [] for definition [Static Value(Company)]';
        String actualResult = obj.getErrors().get('FObjectOne__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_fieldIsInvalid_expectFailure() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestTextX__c', 'Static Value(Company)');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid field [TestTextX__c] for definition [Static Value(Company)]';
        String actualResult = obj.getErrors().get('FObjectOne__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_fieldBelongsToAnotherSObject_expectFailure() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c')
            .setDefinition(FObjectOne__c.TestText__c, 'static value(test1-)')
            .setDefinition(FObjectTwo__c.TestText__c, 'static value(test2)');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid field [TestText__c] for SObject [FObjectOne__c] in definition [' +
            'static value(test2)]';
        String actualResult = obj.getErrors().get('FObjectOne__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_invalidCommand_expectFailure() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestText__c', 'StaticX Value(Company)');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid command [StaticX] in definition [StaticX Value(Company)]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_invalidParameter1_expectFailure() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestText__c', 'Static ValueX(Company) ');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid parameter [ValueX] in definition [Static ValueX(Company)]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_invalidParameter2_expectFailure() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestText__c', 'Static (Company)');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid parameter [] in definition [Static (Company)]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_invalidParameter3_expectFailure() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestText__c', 'Static abc)(Company)');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid parameter [abc)] in definition [Static abc)(Company)]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_invalidParameter4_expectFailure() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestText__c', 'Static )(Company)');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid parameter [)] in definition [Static )(Company)]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_invalidParameter5_expectFailure() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestText__c', 'Static abc"(Company)');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid parameter [abc"] in definition [Static abc"(Company)]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_invalidParameter6_expectFailure() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestText__c', 'Static "(Company)');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid parameter ["] in definition [Static "(Company)]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_multipleDefinitionsForId_expectFailure() {
        String fieldApiName = 'Id';

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition(fieldApiName, 'mock type(id)');
        obj.setDefinition(fieldApiName, 'static value(one)');
        List<FObjectOne__c> records = obj.getRecords();
        Test.stopTest();

        String expectedResult = 'Field [' + fieldApiName + '] does not accept multiple definitions';
        String actualResult = obj.getErrors().get(fieldApiName).get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_multipleDefinitionsForCheckbox_expectFailure() {
        String fieldApiName = 'TestCheckbox__c';

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition(fieldApiName, 'random type(boolean)');
        obj.setDefinition(fieldApiName, 'static value(true)');
        List<FObjectOne__c> records = obj.getRecords();
        Test.stopTest();

        String expectedResult = 'Field [' + fieldApiName + '] does not accept multiple definitions';
        String actualResult = obj.getErrors().get(fieldApiName).get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_multipleDefinitionsForCombobox_expectSuccess() {
        String fieldApiName = 'Subject';

        Test.startTest();
        FObject obj = new FObject('Event');
        obj.setDefinition(fieldApiName, 'random type(picklist)');
        obj.setDefinition(fieldApiName, 'static value(One)');
        obj.setDefinition('Type', 'random type(picklist)');
        obj.setDefinition('WhoId', 'random lookup(Contact) source(forceea)');
        obj.setDefinition('ActivityDatetime', 'random type(datetime) from(2017-10-1) to(2017-12-31)');
        obj.setDefinition('DurationInMinutes', 'random type(number) from(1) to(10) scale(0)');
        List<FObjectOne__c> records = obj.getRecords();
        Test.stopTest();

        System.assert(obj.getErrors().isEmpty(), 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_multipleDefinitionsForCurrency_expectFailure() {
        String fieldApiName = 'TestCurrency__c';

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
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
        String fieldApiName = 'TestDate__c';

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
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
        String fieldApiName = 'TestDatetime__c';

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
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
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition(fieldApiName, 'static value(myname@)');
        obj.setDefinition(fieldApiName, 'static value(company.com)');
        List<FObjectOne__c> records = obj.getRecords();
        Test.stopTest();

        System.assert(obj.getErrors().isEmpty(), 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_multipleDefinitionsForLookup_expectFailure() {
        String fieldApiName = 'TestLookup__c';

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
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
        String fieldApiName = 'TestMultiPicklistA__c';

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
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
        String fieldApiName = 'TestDecimal__c';

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
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
        String fieldApiName = 'TestPercent__c';

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition(fieldApiName, 'random type(number) from(0) to (1) scale(2)');
        obj.setDefinition(fieldApiName, 'static value(0.2)');
        List<FObjectOne__c> records = obj.getRecords();
        Test.stopTest();

        String expectedResult = 'Field [' + fieldApiName + '] does not accept multiple definitions';
        String actualResult = obj.getErrors().get(fieldApiName).get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_multipleDefinitionsForPhone_expectSuccess() {
        String fieldApiName = 'TestPhone__c';

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition(fieldApiName, 'static value(210)');
        obj.setDefinition(fieldApiName, 'random type(number) from(111111) to (999999) scale(0)');
        List<FObjectOne__c> records = obj.getRecords();
        Test.stopTest();

        System.assert(obj.getErrors().isEmpty(), 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_multipleDefinitionsForPicklist_expectFailure() {
        String fieldApiName = 'TestPicklistA__c';

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition(fieldApiName, 'static value(a1)');
        obj.setDefinition(fieldApiName, 'random type(list) value(a0,a1,a2,a3)');
        List<FObjectOne__c> records = obj.getRecords();
        Test.stopTest();

        String expectedResult = 'Field [' + fieldApiName + '] does not accept multiple definitions';
        String actualResult = obj.getErrors().get(fieldApiName).get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_multipleDefinitionsForText_expectSuccess() {
        String fieldApiName = 'TestText__c';

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition(fieldApiName, 'static value(Company1)');
        obj.setDefinition(fieldApiName, 'static value(Company2)');
        List<FObjectOne__c> records = obj.getRecords();
        Test.stopTest();

        System.assert(obj.getErrors().isEmpty(), 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_multipleDefinitionsForTextArea_expectSuccess() {
        String fieldApiName = 'TestTextArea__c';

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition(fieldApiName, 'static value(Company1)');
        obj.setDefinition(fieldApiName, 'static value(Company2)');
        List<FObjectOne__c> records = obj.getRecords();
        Test.stopTest();

        System.assert(obj.getErrors().isEmpty(), 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_multipleDefinitionsForTextAreaLong_expectSuccess() {
        String fieldApiName = 'TestTextAreaLong__c';

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition(fieldApiName, 'static value(Company1)');
        obj.setDefinition(fieldApiName, 'static value(Company2)');
        List<FObjectOne__c> records = obj.getRecords();
        Test.stopTest();

        System.assert(obj.getErrors().isEmpty(), 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_multipleDefinitionsForTextAreaRich_expectSuccess() {
        String fieldApiName = 'TestTextAreaRich__c';

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition(fieldApiName, 'static value(Company1)');
        obj.setDefinition(fieldApiName, 'static value(Company2)');
        List<FObjectOne__c> records = obj.getRecords();
        Test.stopTest();

        System.assert(obj.getErrors().isEmpty(), 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_multipleDefinitionsForTime_expectFailure() {
        String fieldApiName = 'TestTime__c';

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition(fieldApiName, 'static value(10:10:10)');
        obj.setDefinition(fieldApiName, 'static value(11:11:11)');
        List<FObjectOne__c> records = obj.getRecords();
        Test.stopTest();

        String expectedResult = 'Field [' + fieldApiName + '] does not accept multiple definitions';
        String actualResult = obj.getErrors().get(fieldApiName).get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
    }

    @IsTest
    private static void setDefinition_multipleDefinitionsForUrl_expectSuccess() {
        String fieldApiName = 'TestUrl__c';

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition(fieldApiName, 'static value(http:///www.company)');
        obj.setDefinition(fieldApiName, 'serial type(number) from(1) step(1) scale(0)');
        obj.setDefinition(fieldApiName, 'static value(.com)');
        List<FObjectOne__c> records = obj.getRecords();
        Test.stopTest();

        System.assert(obj.getErrors().isEmpty(), 'setDefinition - errors found');
    }

    /* method setDefinitionFromField */

    @IsTest
    private static void setDefinitionFromField_accountName_expectSuccess() {
        String fieldApiName = 'Name';

        Test.startTest();
        FObject obj = new FObject('Account');
        FObject.Field field = new FObject.Field();
        field.fieldName = fieldApiName;
        field.fieldApiName = fieldApiName;
        obj.setDefinitionFromField(field);
        Test.stopTest();

        List<String> definitions = obj.getFieldDefinitions(Account.Name);
        String expectedResult = 'static value(Company-) serial type(number) from(1) step(1) scale(0)';
        String actualResult = definitions.get(0) + ' ' + definitions.get(1);
        System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
    }

    @IsTest
    private static void setDefinitionFromField_contactFirstName_expectSuccess() {
        String fieldApiName = 'FirstName';

        Test.startTest();
        FObject obj = new FObject('Contact');
        FObject.Field field = new FObject.Field();
        field.fieldName = fieldApiName;
        field.fieldApiName = fieldApiName;
        obj.setDefinitionFromField(field);
        Test.stopTest();

        String expectedResult = 'random type(firstname) group(name)';
        String actualResult = obj.getFieldDefinitions(Contact.FirstName).get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
    }

    @IsTest
    private static void setDefinitionFromField_firstAndLastHaveSameGroup_expectSuccess() {
        // check that the auto-generated definition for names has the group argument of the first "pair" name
        String fieldApiName = 'FirstName';

        Test.startTest();
        FObject obj = new FObject('Contact');
        FObject.Field field = new FObject.Field();
        field.fieldName = fieldApiName;
        field.fieldApiName = fieldApiName;
        obj.setDefinitionFromField(field);
        Test.stopTest();

        String expectedResult = 'random type(firstname) group(name)';
        String actualResult = obj.getFieldDefinitions(fieldApiName).get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
    }

    @IsTest
    private static void setDefinitionFromField_contactLastName_expectSuccess() {
        String fieldApiName = 'LastName';

        Test.startTest();
        FObject obj = new FObject('Contact');
        FObject.Field field = new FObject.Field();
        field.fieldName = fieldApiName;
        field.fieldApiName = fieldApiName;
        obj.setDefinitionFromField(field);
        Test.stopTest();

        String expectedResult = 'random type(lastname) group(name)';
        String actualResult = obj.getFieldDefinitions(fieldApiName).get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
    }

    @IsTest
    private static void setDefinitionFromField_leadCompany_expectSuccess() {
        String fieldApiName = 'Company';

        Test.startTest();
        FObject obj = new FObject('Lead');
        FObject.Field field = new FObject.Field();
        field.fieldName = fieldApiName;
        field.fieldApiName = fieldApiName;
        obj.setDefinitionFromField(field);
        Test.stopTest();

        List<String> definitions = obj.getFieldDefinitions(fieldApiName);
        String expectedResult = 'static value(Company-) serial type(number) from(1) step(1) scale(0)';
        String actualResult = definitions[0] + ' ' + definitions[1];
        System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
    }

    @IsTest
    private static void setDefinitionFromField_leadFirstName_expectSuccess() {
        String fieldApiName = 'FirstName';

        Test.startTest();
        FObject obj = new FObject('Lead');
        FObject.Field field = new FObject.Field();
        field.fieldName = fieldApiName;
        field.fieldApiName = fieldApiName;
        obj.setDefinitionFromField(field);
        Test.stopTest();

        String expectedResult = 'random type(firstname) group(name)';
        String actualResult = obj.getFieldDefinitions(fieldApiName).get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
    }

    @IsTest
    private static void setDefinitionFromField_leadLastName_expectSuccess() {
        String fieldApiName = 'LastName';

        Test.startTest();
        FObject obj = new FObject('Lead');
        FObject.Field field = new FObject.Field();
        field.fieldName = fieldApiName;
        field.fieldApiName = fieldApiName;
        obj.setDefinitionFromField(field);
        Test.stopTest();

        String expectedResult = 'random type(lastname) group(name)';
        String actualResult = obj.getFieldDefinitions(fieldApiName).get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
    }

    @IsTest
    private static void setDefinitionFromField_opportunityName_expectSuccess() {
        String fieldApiName = 'Name';

        Test.startTest();
        FObject obj = new FObject('Opportunity');
        FObject.Field field = new FObject.Field();
        field.fieldName = fieldApiName;
        field.fieldApiName = fieldApiName;
        obj.setDefinitionFromField(field);
        Test.stopTest();

        List<String> definitions = obj.getFieldDefinitions(fieldApiName);
        String expectedResult = 'static value(Opportunity-) serial type(number) from(1) step(1) scale(0)';
        String actualResult = definitions[0] + ' ' + definitions[1];
        System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
    }

    @IsTest
    private static void setDefinitionFromField_boolean_expectSuccess() {
        String fieldApiName = 'TestCheckbox__c';

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        FObject.Field field = new FObject.Field();
        field.fieldName = fieldApiName;
        field.fieldApiName = fieldApiName;
        field.dataType = Schema.DisplayType.Boolean;
        obj.setDefinitionFromField(field);
        Test.stopTest();

        String expectedResult = 'random type(boolean)';
        String actualResult = obj.getFieldDefinitions(fieldApiName).get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
    }

    @IsTest
    private static void setDefinitionFromField_combobox_expectSuccess() {
        String fieldApiName = 'Subject';

        Test.startTest();
        FObject obj = new FObject('Event');
        FObject.Field field = new FObject.Field();
        field.fieldName = fieldApiName;
        field.fieldApiName = fieldApiName;
        field.dataType = Schema.DisplayType.Combobox;
        obj.setDefinitionFromField(field);
        Test.stopTest();

        String expectedResult = 'random type(picklist)';
        String actualResult = obj.getFieldDefinitions(fieldApiName).get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
    }

    @IsTest
    private static void setDefinitionFromField_currency_expectSuccess() {
        String fieldApiName = 'TestCurrency__c';

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        FObject.Field field = new FObject.Field();
        field.fieldName = fieldApiName;
        field.fieldApiName = fieldApiName;
        field.dataType = Schema.DisplayType.Currency;
        obj.setDefinitionFromField(field);
        Test.stopTest();

        String expectedResult = 'random type(number) from(1000) to(10000) scale(2)';
        String actualResult = obj.getFieldDefinitions(fieldApiName).get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
    }

    @IsTest
    private static void setDefinitionFromField_date_expectSuccess() {
        String fieldApiName = 'TestDate__c';

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        FObject.Field field = new FObject.Field();
        field.fieldName = fieldApiName;
        field.fieldApiName = fieldApiName;
        field.dataType = Schema.DisplayType.Date;
        obj.setDefinitionFromField(field);
        Test.stopTest();

        Integer thisYear = Date.today().year();
        String fromDate = String.valueOf(thisYear - 1) + '-01-01';
        String toDate = String.valueOf(thisYear + 1) + '-12-31';

        String expectedResult = 'random type(date) from(' + fromDate + ') to(' + toDate + ')';
        String actualResult = obj.getFieldDefinitions(fieldApiName).get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
    }

    @IsTest
    private static void setDefinitionFromField_datetime_expectSuccess() {
        String fieldApiName = 'TestDatetime__c';

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        FObject.Field field = new FObject.Field();
        field.fieldName = fieldApiName;
        field.fieldApiName = fieldApiName;
        field.dataType = Schema.DisplayType.Datetime;
        obj.setDefinitionFromField(field);
        Test.stopTest();

        Integer thisYear = Date.today().year();
        String fromDate = String.valueOf(thisYear - 1) + '-01-01';
        String toDate = String.valueOf(thisYear + 1) + '-12-31';

        String expectedResult = 'random type(datetime) from(' + fromDate + ') to(' + toDate + ')';
        String actualResult = obj.getFieldDefinitions(fieldApiName).get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
    }

    @IsTest
    private static void setDefinitionFromField_double_expectSuccess() {
        String fieldApiName = 'TestDecimal__c';

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        FObject.Field field = new FObject.Field();
        field.fieldName = fieldApiName;
        field.fieldApiName = fieldApiName;
        field.dataType = Schema.DisplayType.Double;
        obj.setDefinitionFromField(field);
        Test.stopTest();

        String expectedResult = 'random type(number) from(1000) to(10000) scale(3)';
        String actualResult = obj.getFieldDefinitions(fieldApiName).get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
    }

    @IsTest
    private static void setDefinitionFromField_email_expectSuccess() {
        String fieldApiName = 'TestEmail__c';

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        FObject.Field field = new FObject.Field();
        field.fieldName = fieldApiName;
        field.fieldApiName = fieldApiName;
        field.dataType = Schema.DisplayType.Email;
        obj.setDefinitionFromField(field);
        Test.stopTest();

        String expectedResult = 'random type(email)';
        String actualResult = obj.getFieldDefinitions(fieldApiName).get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
    }

    @IsTest
    private static void setDefinitionFromField_integer_expectSuccess() {
        String fieldApiName = 'TestInteger__c';

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        FObject.Field field = new FObject.Field();
        field.fieldName = fieldApiName;
        field.fieldApiName = fieldApiName;
        field.dataType = Schema.DisplayType.Integer;
        obj.setDefinitionFromField(field);
        Test.stopTest();

        String expectedResult = 'random type(number) from(1) to(100) scale(0)';
        String actualResult = obj.getFieldDefinitions(fieldApiName).get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
    }

    @IsTest
    private static void setDefinitionFromField_multiPicklist_expectSuccess() {
        String fieldApiName = 'TestMultiPicklistA__c';

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        FObject.Field field = new FObject.Field();
        field.fieldName = fieldApiName;
        field.fieldApiName = fieldApiName;
        field.dataType = Schema.DisplayType.MultiPicklist;
        obj.setDefinitionFromField(field);
        Test.stopTest();

        String expectedResult = 'random type(picklist)';
        String actualResult = obj.getFieldDefinitions(fieldApiName).get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
    }

    @IsTest
    private static void setDefinitionFromField_percent_expectSuccess() {
        String fieldApiName = 'TestPercent__c';

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        FObject.Field field = new FObject.Field();
        field.fieldName = fieldApiName;
        field.fieldApiName = fieldApiName;
        field.dataType = Schema.DisplayType.Percent;
        obj.setDefinitionFromField(field);
        Test.stopTest();

        String expectedResult = 'random type(number) from(0) to(100) scale(2)';
        String actualResult = obj.getFieldDefinitions(fieldApiName).get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
    }

    @IsTest
    private static void setDefinitionFromField_picklist_expectSuccess() {
        String fieldApiName = 'TestPicklistA__c';

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        FObject.Field field = new FObject.Field();
        field.fieldName = fieldApiName;
        field.fieldApiName = fieldApiName;
        field.dataType = Schema.DisplayType.MultiPicklist;
        obj.setDefinitionFromField(field);
        Test.stopTest();

        String expectedResult = 'random type(picklist)';
        String actualResult = obj.getFieldDefinitions(fieldApiName).get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
    }

    @IsTest
    private static void setDefinitionFromField_reference_expectSuccess() {
        String fieldApiName = 'TestLookup__c';
        Schema.SobjectType parentType = Schema.FObjectTwo__c.getSObjectType();
        List<Schema.SobjectType> parents = new List<Schema.SobjectType>{
            parentType
        };

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        FObject.Field field = new FObject.Field();
        field.fieldName = fieldApiName;
        field.fieldApiName = fieldApiName;
        field.dataType = Schema.DisplayType.Reference;
        field.parents = parents;
        obj.setDefinitionFromField(field);
        Test.stopTest();

        String expectedResult = 'random lookup(FObjectTwo__c) source(forceea)';
        String actualResult = obj.getFieldDefinitions(fieldApiName).get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
    }

    @IsTest
    private static void setDefinitionFromField_string_expectSuccess() {
        String fieldApiName = 'TestText__c';

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        FObject.Field field = new FObject.Field();
        field.fieldName = fieldApiName;
        field.fieldApiName = fieldApiName;
        field.length = 20;
        field.dataType = Schema.DisplayType.String;
        obj.setDefinitionFromField(field);
        Test.stopTest();

        String expectedResult = 'random type(string) minLength(5) maxLength(20) startWith(upper) include(lower,upper)';
        String actualResult = obj.getFieldDefinitions(fieldApiName).get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
    }

    @IsTest
    private static void setDefinitionFromField_textArea_expectSuccess() {
        String fieldApiName = 'TestTextArea__c';

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        FObject.Field field = new FObject.Field();
        field.fieldName = fieldApiName;
        field.fieldApiName = fieldApiName;
        field.dataType = Schema.DisplayType.TextArea;
        obj.setDefinitionFromField(field);
        Test.stopTest();

        String expectedResult = 'random type(text) minLength(30) maxLength(100)';
        String actualResult = obj.getFieldDefinitions(fieldApiName).get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
    }

    @IsTest
    private static void setDefinitionFromField_time_expectSuccess() {
        String fieldApiName = 'TestTime__c';

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        FObject.Field field = new FObject.Field();
        field.fieldName = fieldApiName;
        field.fieldApiName = fieldApiName;
        field.dataType = Schema.DisplayType.Time;
        obj.setDefinitionFromField(field);
        Test.stopTest();

        String expectedResult = 'static value(12:00:00)';
        String actualResult = obj.getFieldDefinitions(fieldApiName).get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
    }

    @IsTest
    private static void setDefinitionFromField_url_expectSuccess() {
        String fieldApiName = 'TestUrl__c';

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        FObject.Field field = new FObject.Field();
        field.fieldName = fieldApiName;
        field.fieldApiName = fieldApiName;
        field.dataType = Schema.DisplayType.Url;
        obj.setDefinitionFromField(field);
        Test.stopTest();

        String expectedResult = 'random type(url)';
        String actualResult = obj.getFieldDefinitions(fieldApiName).get(0);
        System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
    }

    /* setStandardPricebookEntries */

    @IsTest
    private static void setStandardPricebookEntries_exists_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(Product2.SObjectType, 10)
            .setDefinition(Product2.Name, 'static value("Product-")')
            .setDefinition(Product2.Name, 'serial type(number) from(1) step(1) scale(0)')
            .setDefinition(Product2.Description, 'random type(text) minLength(25) maxLength(50)')
            .setDefinition('$StandardPrice', 'serial type(number) from(1) step(1) scale(0)')
            .setStandardPricebookEntries('$StandardPrice');
        obj.insertRecords(true);
        Test.stopTest();

        Integer errors = 0;
        Integer counter = 1;
        List<PricebookEntry> entries = [SELECT UnitPrice FROM PricebookEntry];
        for (PricebookEntry record : entries) {
            if (record.UnitPrice != counter) {
                errors++;
            }
            counter++;
        }

        if (entries.isEmpty() || !FObject.processIsValid()) {
            errors++;
        }

        System.assertEquals(0, errors, 'setStandardPricebookEntries - errors found');
    }

    @IsTest
    private static void setStandardPricebookEntries_getInsertedEntries_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(Product2.SObjectType, 10)
            .setDefinition(Product2.Name, 'static value("Product-")')
            .setDefinition(Product2.Name, 'serial type(number) from(1) step(1) scale(0)')
            .setDefinition(Product2.Description, 'random type(text) minLength(25) maxLength(50)')
            .setDefinition('$StandardPrice', 'serial type(number) from(1) step(1) scale(0)')
            .setStandardPricebookEntries('$StandardPrice');
        obj.insertRecords(true);
        Test.stopTest();

        Integer counter = 1;
        Integer errors = 0;
        List<PricebookEntry> records = (List<PricebookEntry>) FObject.getInsertedRecords(PricebookEntry.SObjectType);

        for (PricebookEntry record : records) {
            if (record.UnitPrice != counter) {
                errors++;
            }
            counter++;
        }

        if (records.size() != obj.getNumberOfRecords()) {
            errors = +32;
        }

        if (!FObject.processIsValid()) {
            errors = +64;
        }

        System.assertEquals(0, errors, 'setStandardPricebookEntries - errors found');
    }

    @IsTest
    private static void setStandardPricebookEntries_notMethodInvoked_expectFailure() {
        Test.startTest();
        FObject obj = new FObject('Product2', 10)
            .setDefinition('Name', 'static value("Product ")')
            .setDefinition('Name', 'serial type(number) from(100) step(1) scale(0)')
            .setDefinition('Description', 'static value(12.34)');
        obj.insertRecords(true);
        Test.stopTest();

        List<PricebookEntry> entries = [SELECT Id FROM PricebookEntry];
        System.assert(entries.isEmpty(), 'setStandardPricebookEntries - errors found');
    }

    /* setVerbose */

    @IsTest
    private static void setVerbose_valid_expectSuccess() {
        Test.startTest();
        FObject.setGlobalVerbose('none');
        FObject obj = new FObject('FObjectOne__c', 10);
        obj.setVerbose('none');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();

        FObject.setGlobalVerbose('info');
        obj = new FObject('FObjectOne__c', 10);
        obj.setVerbose('info');
        records = (List<FObjectOne__c>) obj.getRecords();

        obj = new FObject('FObjectOne__c', 10);
        records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        System.assert(obj.getErrors().isEmpty(), 'setVerbose - errors found');
    }

    /* updateFields */

    // create records

    @IsTest
    private static void updateFields_create1Def_forUpdate0Def_updateCreated_expectSuccess() {
        FObject obj = new FObject('FObjectOne__c', 10)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(one)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();

        Test.startTest();
        obj
            .setNumberOfRecords(1)
            .updateFields();
        Test.stopTest();

        System.assert(updateIsValidForCreatedRecords(records, 'one'), 'updateFields - errors found');
    }

    @IsTest
    private static void updateFields_create1Def_forUpdate1Def_updateCreated_expectSuccess() {
        FObject obj = new FObject('FObjectOne__c', 10)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(one)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();

        Test.startTest();
        String updatedValue = 'two';
        obj
            .setNumberOfRecords(1)
            .setDefinitionForUpdate(FObjectOne__c.TestText__c, 'static value(' + updatedValue + ')')
            .updateFields();
        Test.stopTest();

        System.assert(updateIsValidForCreatedRecords(records, updatedValue), 'updateFields - errors found');
    }

    @IsTest
    private static void updateFields_create1Def_forUpdate2Def_updateCreated_expectSuccess() {
        FObject obj = new FObject('FObjectOne__c', 10)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(one)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();

        Test.startTest();
        String updatedValue = 'two';
        obj
            .setNumberOfRecords(1)
            .setNumberOfNextRecord(1)
            .setDefinitionForUpdate(FObjectOne__c.TestText__c, 'static value(' + updatedValue + ')')
            .setDefinitionForUpdate(FObjectOne__c.TestText__c, 'serial type(number) from(1) step(1) scale(0)')
            .updateFields();
        Test.stopTest();

        System.assert(updateIsValidForCreatedRecords(records, updatedValue), 'updateFields - errors found');
    }

    // insert records

    @IsTest
    private static void updateFields_insert1Def_forUpdate0Def_updateGlobal_expectSuccess() {
        String groupName = '';

        FObject obj = new FObject('FObjectOne__c', 10)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(one)');
        obj.insertRecords(true, groupName);

        Test.startTest();
        obj
            .setNumberOfRecords(1)
            .updateFields(groupName);
        Test.stopTest();

        System.assert(updateIsValidForInsertedRecords(groupName, 'one'), 'updateFields - errors found');
    }

    @IsTest
    private static void updateFields_insert1Def_forUpdate0Def_updateGroup_expectSuccess() {
        String groupName = 'MyGroup';

        FObject obj = new FObject('FObjectOne__c', 10)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(one)');
        obj.insertRecords(true, groupName);

        Test.startTest();
        obj
            .setNumberOfRecords(1)
            .updateFields(groupName);
        Test.stopTest();

        System.assert(updateIsValidForInsertedRecords(groupName, 'one'), 'updateFields - errors found');
    }

    @IsTest
    private static void updateFields_insert1Def_forUpdate1Def_updateGlobal_expectSuccess() {
        String groupName = '';

        FObject obj = new FObject('FObjectOne__c', 10)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(one)');
        obj.insertRecords(true, groupName);

        Test.startTest();
        String updatedValue = 'two';
        obj
            .setNumberOfRecords(1)
            .setDefinitionForUpdate(FObjectOne__c.TestText__c, 'static value(' + updatedValue + ')')
            .updateFields(groupName);
        Test.stopTest();

        System.assert(updateIsValidForInsertedRecords(groupName, updatedValue), 'updateFields - errors found');
    }

    @IsTest
    private static void updateFields_insert1Def_forUpdate1Def_updateGroup_expectSuccess() {
        String groupName = 'MyGroup';

        FObject obj = new FObject('FObjectOne__c', 10)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(one)');
        obj.insertRecords(true, groupName);

        Test.startTest();
        String updatedValue = 'two';
        obj
            .setNumberOfRecords(1)
            .setDefinitionForUpdate(FObjectOne__c.TestText__c, 'static value(' + updatedValue + ')')
            .updateFields(groupName);
        Test.stopTest();

        System.assert(updateIsValidForInsertedRecords(groupName, updatedValue), 'updateFields - errors found');
    }

    @IsTest
    private static void updateFields_insert1Def_forUpdate2Def_updateGlobal_expectSuccess() {
        String groupName = '';

        FObject obj = new FObject('FObjectOne__c', 10)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(one)');
        obj.insertRecords(true, groupName);

        Test.startTest();
        String updatedValue = 'two';
        obj
            .setNumberOfRecords(1)
            .setNumberOfNextRecord(1)
            .setDefinitionForUpdate(FObjectOne__c.TestText__c, 'static value(' + updatedValue + ')')
            .setDefinitionForUpdate(FObjectOne__c.TestText__c, 'serial type(number) from(1) step(1) scale(0)')
            .updateFields(groupName);
        Test.stopTest();

        System.assert(updateIsValidForInsertedRecords(groupName, updatedValue), 'updateFields - errors found');
    }

    @IsTest
    private static void updateFields_insert1Def_forUpdate2Def_updateGroup_expectSuccess() {
        String groupName = 'MyGroup';

        FObject obj = new FObject('FObjectOne__c', 10)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(one)');
        obj.insertRecords(true, groupName);

        Test.startTest();
        String updatedValue = 'two';
        obj
            .setNumberOfRecords(1)
            .setNumberOfNextRecord(1)
            .setDefinitionForUpdate(FObjectOne__c.TestText__c, 'static value(' + updatedValue + ')')
            .setDefinitionForUpdate(FObjectOne__c.TestText__c, 'serial type(number) from(1) step(1) scale(0)')
            .updateFields(groupName);
        Test.stopTest();

        System.assert(updateIsValidForInsertedRecords(groupName, updatedValue), 'updateFields - errors found');
    }

    @IsTest
    private static void updateFields_dependentPicklists_expectSuccess() {
        FObject obj = new FObject('FObjectOne__c')
            .setDefinition(FObjectOne__c.TestText__c, 'static value(one)');
        obj.insertRecords(true);

        Test.startTest();
        String groupName = '';
        String updatedValue = 'two';
        obj
            .setNumberOfRecords(1)
            .setNumberOfNextRecord(1)
            .setDefinitionForUpdate(FObjectOne__c.TestText__c, 'static value(' + updatedValue + ')')
            .setDefinitionForUpdate(FObjectOne__c.TestText__c, 'serial type(number) from(1) step(1) scale(0)')
            .setDefinitionForUpdate(FObjectOne__c.TestPicklistB__c, 'random type(picklist)')
            .updateFields(groupName);
        obj.updateRecords(true);
        Test.stopTest();

        System.assert(Fobject.processIsValid(), 'updateFields - errors found');
    }

    /* updateRecords */

    // data types

    @IsTest
    private static void updateRecords_integerValues_expectSuccess() {
        FObject obj = new FObject('FObjectOne__c', 10)
            .setDefinition(FObjectOne__c.TestInteger__c, 'random type(number) from(1) to(100) scale(0)');
        obj.insertRecords(true);

        Test.startTest();
        obj.setDefinitionForUpdate(FObjectOne__c.TestInteger__c, 'serial type(number) from(1) step(1) scale(0)')
            .setNumberOfRecords(1)
            .setNumberOfNextRecord(1)
            .updateFields()
            .updateRecords(true);
        Test.stopTest();

        Integer errors = 0;
        Integer counter = 1;
        for (FObjectOne__c record : (List<FObjectOne__c>) obj.getInsertedRecords()) {
            if (record.TestInteger__c != counter) {
                errors++;
            }
            counter++;
        }
        System.assert(FObject.processIsValid && errors == 0, 'updateRecords - errors found');
    }

    @IsTest
    private static void updateRecords_decimalValues_expectSuccess() {
        FObject obj = new FObject('FObjectOne__c', 10)
            .setDefinition(FObjectOne__c.TestDecimal__c, 'random type(number) from(1) to(100) scale(2)');
        obj.insertRecords(true);

        Test.startTest();
        obj.setDefinitionForUpdate(FObjectOne__c.TestDecimal__c, 'serial type(number) from(1) step(1.52) scale(2)')
            .setNumberOfNextRecord(1)
            .setNumberOfRecords(1)
            .updateFields()
            .updateRecords(true);
        Test.stopTest();

        Integer errors = 0;
        Decimal counter = 1;
        for (FObjectOne__c record : (List<FObjectOne__c>) obj.getInsertedRecords()) {
            if (record.TestDecimal__c != counter) {
                errors++;
            }
            counter += 1.52;
        }
        System.assert(FObject.processIsValid && errors == 0, 'updateRecords - errors found');
    }

    @IsTest
    private static void updateRecords_dateValues_expectSuccess() {
        FObject obj = new FObject('FObjectOne__c', 10)
            .setDefinition(FObjectOne__c.TestDate__c, 'random type(date) from(2020-01-01) to(2020-12-31)');
        obj.insertRecords(true);

        Test.startTest();
        obj.setDefinitionForUpdate(FObjectOne__c.TestDate__c, 'serial type(date) from(2020-01-01) step(1)')
            .setNumberOfNextRecord(1)
            .setNumberOfRecords(1)
            .updateFields()
            .updateRecords(true);
        Test.stopTest();

        Integer errors = 0;
        Date counter = Date.newInstance(2020, 1, 1);
        for (FObjectOne__c record : (List<FObjectOne__c>) obj.getInsertedRecords()) {
            if (record.TestDate__c != counter) {
                errors++;
            }
            counter = counter.addDays(1);
        }
        System.assert(FObject.processIsValid && errors == 0, 'updateRecords - errors found');
    }

    @IsTest
    private static void updateRecords_datetimeValues_expectSuccess() {
        FObject obj = new FObject('FObjectOne__c', 10)
            .setDefinition(FObjectOne__c.TestDatetime__c,
                'random type(datetime) from(2020-01-01) to(2020-12-31)');
        obj.insertRecords(true);

        Test.startTest();
        obj.setDefinitionForUpdate(FObjectOne__c.TestDatetime__c,
            'serial type(datetime) from(2020-01-01) step(1)')
            .setNumberOfNextRecord(1)
            .setNumberOfRecords(1)
            .updateFields()
            .updateRecords(true);
        Test.stopTest();

        Integer errors = 0;
        Datetime counter = Datetime.newInstance(2020, 1, 1);
        for (FObjectOne__c record : (List<FObjectOne__c>) obj.getInsertedRecords()) {
            if (record.TestDatetime__c != counter) {
                errors++;
            }
            counter = counter.addDays(1);
        }
        System.assert(FObject.processIsValid && errors == 0, 'updateRecords - errors found');
    }

    @IsTest
    private static void updateRecords_stringValues_expectSuccess() {
        FObject obj = new FObject('FObjectOne__c', 10)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(test)');
        obj.insertRecords(true);

        Test.startTest();
        obj
            .setDefinitionForUpdate(FObjectOne__c.TestText__c, 'static value(test)')
            .setDefinitionForUpdate(FObjectOne__c.TestText__c, 'serial type(number) from(1) step(1) scale(0)')
            .setNumberOfNextRecord(1)
            .setNumberOfRecords(1)
            .updateFields()
            .updateRecords(true);
        Test.stopTest();

        Integer errors = 0;
        Integer counter = 1;
        for (FObjectOne__c record : (List<FObjectOne__c>) obj.getInsertedRecords()) {
            if (record.TestText__c != 'test' + String.valueOf(counter)) {
                errors++;
            }
            counter++;
        }
        System.assert(FObject.processIsValid && errors == 0, 'updateRecords - errors found');
    }

    // create records

    @IsTest
    private static void updateRecords_create0Def_forUpdate0Def_noUpdate_expectSuccess() {
        FObject obj = new FObject('FObjectOne__c', 10)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(one)');

        Test.startTest();
        obj
            .setNumberOfRecords(1)
            .updateRecords(true);
        Test.stopTest();

        List<FObjectOne__c> updatedRecords = (List<FObjectOne__c>) obj.getUpdatedRecords();
        System.assert(updatedRecords.isEmpty(), 'updateRecords - errors found');
    }

    @IsTest
    private static void updateRecords_create0Def_forUpdate0Def_update_expectSuccess() {
        FObject obj = new FObject('FObjectOne__c', 10)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(one)');

        Test.startTest();
        obj
            .setNumberOfRecords(1)
            .updateFields()
            .updateRecords(true);
        Test.stopTest();

        List<FObjectOne__c> updatedRecords = (List<FObjectOne__c>) obj.getUpdatedRecords();
        System.assert(updatedRecords.isEmpty(), 'updateRecords - errors found');
    }

    @IsTest
    private static void updateRecords_create0Def_forUpdate1Def_noUpdate_expectSuccess() {
        FObject obj = new FObject('FObjectOne__c', 10)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(one)');

        Test.startTest();
        obj
            .setNumberOfRecords(1)
            .setDefinitionForUpdate(FObjectOne__c.TestText__c, 'static value(two)')
            .updateRecords(true);
        Test.stopTest();

        List<FObjectOne__c> updatedRecords = (List<FObjectOne__c>) obj.getUpdatedRecords();
        System.assert(updatedRecords.isEmpty(), 'updateRecords - errors found');
    }

    @IsTest
    private static void updateRecords_create0Def_forUpdate1Def_update_expectSuccess() {
        FObject obj = new FObject('FObjectOne__c', 10)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(one)');

        Test.startTest();
        obj
            .setNumberOfRecords(1)
            .setDefinitionForUpdate(FObjectOne__c.TestText__c, 'static value(two)')
            .updateFields()
            .updateRecords(true);
        Test.stopTest();

        List<FObjectOne__c> updatedRecords = (List<FObjectOne__c>) obj.getUpdatedRecords();
        System.assert(updatedRecords.isEmpty(), 'updateRecords - errors found');
    }

    @IsTest
    private static void updateRecords_create1Def_forUpdate0Def_noUpdate_expectSuccess() {
        FObject obj = new FObject('FObjectOne__c', 10)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(one)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();

        Test.startTest();
        obj
            .setNumberOfRecords(1)
            .updateRecords(true);
        Test.stopTest();

        List<FObjectOne__c> updatedRecords = (List<FObjectOne__c>) obj.getUpdatedRecords();
        System.assert(updatedRecords.isEmpty(), 'updateRecords - errors found');
    }

    @IsTest
    private static void updateRecords_create1Def_forUpdate0Def_update_expectSuccess() {
        FObject obj = new FObject('FObjectOne__c', 10)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(one)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();

        Test.startTest();
        obj
            .setNumberOfRecords(1)
            .updateFields()
            .updateRecords(true);
        Test.stopTest();

        List<FObjectOne__c> updatedRecords = (List<FObjectOne__c>) obj.getUpdatedRecords();
        System.assert(updatedRecords.isEmpty(), 'updateRecords - errors found');
    }

    @IsTest
    private static void updateRecords_create1Def_forUpdate1Def_noUpdate_expectSuccess() {
        FObject obj = new FObject('FObjectOne__c', 10)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(one)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();

        Test.startTest();
        obj
            .setNumberOfRecords(1)
            .setDefinitionForUpdate(FObjectOne__c.TestText__c, 'static value(two)')
            .updateRecords(true);
        Test.stopTest();

        List<FObjectOne__c> updatedRecords = (List<FObjectOne__c>) obj.getUpdatedRecords();
        System.assert(updatedRecords.isEmpty(), 'updateRecords - errors found');
    }

    @IsTest
    private static void updateRecords_create1Def_forUpdate1Def_update_expectSuccess() {
        FObject obj = new FObject('FObjectOne__c', 10)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(one)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();

        Test.startTest();
        obj
            .setNumberOfRecords(1)
            .setDefinitionForUpdate(FObjectOne__c.TestText__c, 'static value(two)')
            .updateFields()
            .updateRecords(true);
        Test.stopTest();

        List<FObjectOne__c> updatedRecords = (List<FObjectOne__c>) obj.getUpdatedRecords();
        System.assert(updatedRecords.isEmpty(), 'updateRecords - errors found');
    }

    // insert records

    @IsTest
    private static void updateRecords_insert1Def_forUpdate0Def_noUpdate_expectSuccess() {
        FObject obj = new FObject('FObjectOne__c', 10)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(one)');
        obj.insertRecords(true);

        Test.startTest();
        obj
            .setNumberOfRecords(1)
            .updateRecords(true);
        Test.stopTest();

        List<FObjectOne__c> updatedRecords = (List<FObjectOne__c>) obj.getUpdatedRecords();
        System.assert(updatedRecords.isEmpty(), 'updateRecords - errors found');
    }

    @IsTest
    private static void updateRecords_insert1Def_forUpdate0Def_update_expectSuccess() {
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(number) from(1) step(1) scale(0)');
        obj.insertRecords(true);

        Test.startTest();
        obj
            .setNumberOfRecords(1)
            .updateFields()
            .updateRecords(true);
        Test.stopTest();

        List<FObjectOne__c> updatedRecords = (List<FObjectOne__c>) obj.getUpdatedRecords();
        System.assert(updatedRecords.isEmpty(), 'updateRecords - errors found');
    }

    @IsTest
    private static void updateRecords_insert1Def_forUpdate1Def_noUpdate_expectSuccess() {
        FObject obj = new FObject('FObjectOne__c', 10)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(one)');
        obj.insertRecords(true);

        Test.startTest();
        obj
            .setNumberOfRecords(1)
            .setDefinitionForUpdate(FObjectOne__c.TestText__c, 'static value(two)')
            .updateRecords(true);
        Test.stopTest();

        List<FObjectOne__c> updatedRecords = (List<FObjectOne__c>) obj.getUpdatedRecords();
        System.assert(updatedRecords.isEmpty(), 'updateRecords - errors found');
    }

    @IsTest
    private static void updateRecords_insert1Def_forUpdate1Def_update_expectSuccess() {
        FObject obj = new FObject('FObjectOne__c', 10)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(one)');
        obj.insertRecords(true);

        Test.startTest();
        String updatedValue = 'two';
        obj
            .setNumberOfRecords(1)
            .setDefinitionForUpdate(FObjectOne__c.TestText__c, 'static value(' + updatedValue + ')')
            .updateFields()
            .updateRecords(true);
        Test.stopTest();

        System.assert(updateIsValidForInsertedRecords('', updatedValue), 'updateRecords - errors found');
    }

    @IsTest
    private static void updateRecords_insert1Def_forUpdate2Def_update_expectSuccess() {
        FObject obj = new FObject('FObjectOne__c', 10)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(one)');
        obj.insertRecords(true);

        Test.startTest();
        String updatedValue = 'two';
        obj
            .setNumberOfRecords(1)
            .setNumberOfNextRecord(1)
            .setDefinitionForUpdate(FObjectOne__c.TestText__c, 'static value(' + updatedValue + ')')
            .setDefinitionForUpdate(FObjectOne__c.TestText__c, 'serial type(number) from(1) step(1) scale(0)')
            .updateFields()
            .updateRecords(true);
        Test.stopTest();

        System.assert(updateIsValidForInsertedRecords('', updatedValue), 'updateRecords - errors found');
    }

    /* virtual field */

    @IsTest
    private static void updateRecords_virtualField_expectSuccess() {
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestInteger__c, 'random type(number) from(1) to(100) scale(0)');
        obj.insertRecords(true, 'MyGroup');

        Test.startTest();
        obj.setNumberOfRecords(1)
            .setNumberOfNextRecord(1)
            .setDefinitionForUpdate('$SerialValues', 'serial type(number) from(1) step(1) scale(0)')
            .setDefinitionForUpdate(FObjectOne__c.TestInteger__c, 'copy field($SerialValues)')
            .setDefinitionForUpdate(FObjectOne__c.TestIntegerUnique__c, 'copy field($SerialValues)')
            .updateFields()
            .updateRecords(true);
        Test.stopTest();

        Integer errors = 0;
        Integer counter = 1;
        for (FObjectOne__c record : (List<FObjectOne__c>) obj.getInsertedRecords()) {
            if (record.TestInteger__c != counter && record.TestIntegerUnique__c != counter) {
                errors++;
            }
            counter++;
        }
        System.assert(FObject.processIsValid && errors == 0, 'updateRecords - errors found');
    }

    @IsTest
    private static void virtualField_firstCharIsNotDollar_expectFailure() {
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);

        Test.startTest();
        Boolean isValid = obj.virtualFieldIsValid('Testtest');
        Test.stopTest();

        System.assert(isValid == false, 'virtualField - errors found');
    }

    @IsTest
    private static void virtualField_isBlank_expectFailure() {
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);

        Test.startTest();
        Boolean isValid = obj.virtualFieldIsValid(' ');
        Test.stopTest();

        System.assert(isValid == false, 'virtualField - errors found');
    }

    @IsTest
    private static void virtualField_containsWhiteSpace_expectFailure() {
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);

        Test.startTest();
        Boolean isValid = obj.virtualFieldIsValid('$Test test');
        Test.stopTest();

        System.assert(isValid == false, 'virtualField - errors found');
    }

    @IsTest
    private static void virtualField_hasIllegalCharacters_expectFailure() {
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);

        Test.startTest();
        Boolean isValid = obj.virtualFieldIsValid('$Test2test');
        Test.stopTest();

        System.assert(isValid == false, 'virtualField - errors found');
    }

    /* HELPER METHODS */

    /**
     * @description Validates the field definitions.
     * @param obj The FObject.
     * @param fieldApiName The field API name.
     * @param validDefinitions The list of valid definitions.
     * @param invalidDefinitions The list of invalid definitions.
     * @return A boolean value.
     */
    private static Boolean definitionsAreValid(
        FObject obj, String fieldApiName, List<String> validDefinitions, List<String> invalidDefinitions) {
        Boolean result = true;

        for (String definition : validDefinitions) {
            obj.setDefinition(fieldApiName, definition);
        }
        for (String definition : invalidDefinitions) {
            obj.setDefinition(fieldApiName, definition);
        }
        obj.getRecords();

        String expectedResult = '';
        Integer counter = 0;
        Integer errors = 0;
        for (String actualResult : obj.getErrors().get(fieldApiName)) {
            if (!actualResult.startsWith('Invalid definition [')) {
                continue;
            }
            expectedResult = 'Invalid definition [' + invalidDefinitions[counter] + '] for the data type of field [' +
                fieldApiName + ']';
            if (expectedResult != actualResult) {
                errors++;
            }
            counter++;
        }

        if (errors != invalidDefinitions.size()) {
            result = false;
        }

        return result;
    }

    private static Boolean insertedGroupRecordsAreValidForSameInstance(FObject obj, String group1, String group2) {
        List<FObjectOne__c> recordsA1 =
            (List<FObjectOne__c>) obj.getInsertedGroupRecords(group1.toUpperCase());
        List<FObjectOne__c> recordsA2 =
            (List<FObjectOne__c>) FObject.getInsertedGroupRecords(FObjectOne__c.SObjectType, group1.toLowerCase());

        List<FObjectOne__c> recordsB1 =
            (List<FObjectOne__c>) obj.getInsertedGroupRecords(group2.toUpperCase());
        List<FObjectOne__c> recordsB2 =
            (List<FObjectOne__c>) FObject.getInsertedGroupRecords(FObjectOne__c.SObjectType, group2.toLowerCase());

        List<FObjectOne__c> recordsInstanceBlank1 = (List<FObjectOne__c>) obj.getInsertedGroupRecords('');
        List<FObjectOne__c> recordsInstanceBlank2 = (List<FObjectOne__c>) obj.getInsertedGroupRecords(' ');
        List<FObjectOne__c> recordsInstanceBlank3 = (List<FObjectOne__c>) obj.getInsertedGroupRecords(null);
        List<FObjectOne__c> recordsInstanceBlank4 = (List<FObjectOne__c>) obj.getInsertedRecords();

        List<FObjectOne__c> recordsStaticBlank1 =
            (List<FObjectOne__c>) FObject.getInsertedGroupRecords(FObjectOne__c.SObjectType, '');
        List<FObjectOne__c> recordsStaticBlank2 =
            (List<FObjectOne__c>) FObject.getInsertedGroupRecords(FObjectOne__c.SObjectType, ' ');
        List<FObjectOne__c> recordsStaticBlank3 =
            (List<FObjectOne__c>) FObject.getInsertedGroupRecords(FObjectOne__c.SObjectType, null);
        List<FObjectOne__c> recordsStaticBlank4 =
            (List<FObjectOne__c>) FObject.getInsertedRecords(FObjectOne__c.SObjectType);

        Integer errors = 0;
        if (recordsA1.hashCode() != recordsA2.hashCode()) {
            errors += 1;
        }
        if (recordsB1.hashCode() != recordsB2.hashCode()) {
            errors += 2;
        }
        if (recordsInstanceBlank1.hashCode() != recordsInstanceBlank2.hashCode() &&
            recordsInstanceBlank2.hashCode() != recordsInstanceBlank3.hashCode() &&
            recordsInstanceBlank3.hashCode() != recordsInstanceBlank4.hashCode()
            ) {
            errors += 4;
        }
        if (recordsStaticBlank1.hashCode() != recordsStaticBlank2.hashCode() &&
            recordsStaticBlank2.hashCode() != recordsStaticBlank3.hashCode() &&
            recordsStaticBlank3.hashCode() != recordsStaticBlank4.hashCode()
            ) {
            errors += 8;
        }
        Integer expectedSize = obj.getNumberOfRecords();
        if (recordsA1.size() != expectedSize && recordsB1.size() != expectedSize &&
            recordsInstanceBlank4.size() != 2 * expectedSize && recordsStaticBlank4.size() != 2 * expectedSize
            ) {
            errors += 16;
        }
        if (!FObject.processIsValid()) {
            errors += 32;
        }

        return errors == 0;
    }

    private static Boolean insertedGroupRecordsAreValidForDifferentInstances(
        FObject obj1, FObject obj2, String group1, String group2) {
        List<FObjectOne__c> recordsA1 =
            (List<FObjectOne__c>) obj1.getInsertedGroupRecords(group1.toUpperCase());
        List<FObjectOne__c> recordsA2 =
            (List<FObjectOne__c>) FObject.getInsertedGroupRecords('FObjectOne__c', group1.toLowerCase());

        List<FObjectOne__c> recordsB1 =
            (List<FObjectOne__c>) obj2.getInsertedGroupRecords(group2.toUpperCase());
        List<FObjectOne__c> recordsB2 =
            (List<FObjectOne__c>) FObject.getInsertedGroupRecords('FObjectOne__c', group2.toLowerCase());

        List<FObjectOne__c> recordsInstanceBlank1 = (List<FObjectOne__c>) obj1.getInsertedRecords();
        List<FObjectOne__c> recordsInstanceBlank2 = (List<FObjectOne__c>) obj2.getInsertedRecords();
        List<FObjectOne__c> recordsStatic =
            (List<FObjectOne__c>) FObject.getInsertedRecords('FObjectOne__c');

        Integer errors = 0;
        for (Integer counter = 0; counter < recordsA1.size(); counter++) {
            if (recordsA1.get(counter).TestText__c != recordsB1.get(counter).TestText__c &&
                recordsA2.get(counter).TestText__c != recordsB2.get(counter).TestText__c &&
                recordsInstanceBlank1.get(counter).TestText__c != recordsInstanceBlank2.get(counter).TestText__c
                ) {
                errors++;
            }
        }

        Integer expectedSize1 = obj1.getNumberOfRecords();
        Integer expectedSize2 = obj2.getNumberOfRecords();
        if (recordsA1.size() != expectedSize1 &&
            recordsB1.size() != expectedSize2 &&
            recordsStatic.size() != (expectedSize1 + expectedSize2)
            ) {
            errors += 512;
        }
        if (!FObject.processIsValid()) {
            errors += 1024;
        }

        return errors == 0;
    }

    /**
     * @description Validates the update of created records.
     * @param records The updated records.
     * @param updatedValue The value of the updated field.
     * @return A boolean value.
     */
    private static Boolean updateIsValidForCreatedRecords(List<FObjectOne__c> records, String updatedValue) {
        Boolean result = false;
        Integer errors = 0;
        Integer counter = 1;

        for (FObjectOne__c record : records) {
            if ((record.TestText__c != updatedValue && record.TestText__c != updatedValue + String.valueOf(counter))
                || String.isEmpty(record.TestTextRequired__c)) {
                errors++;
            }
            counter++;
        }

        if (errors == 0 && FObject.processIsValid()) {
            result = true;
        }

        return result;
    }

    /**
     * @description Validates the update of inserted records.
     * @param groupName The group name.
     * @param updatedValue The value of the updated field.
     * @return A boolean value.
     */
    private static Boolean updateIsValidForInsertedRecords(String groupName, String updatedValue) {
        Boolean result = false;
        Integer errors = 0;
        Integer counter = 1;

        List<FObjectOne__c> records = (List<FObjectOne__c>) FObject.getInsertedGroupRecords('FObjectOne__c', groupName);
        for (FObjectOne__c record : records) {
            String updatedWithNumberValue = updatedValue + String.valueOf(counter);
            if ((record.TestText__c != updatedValue && record.TestText__c != updatedWithNumberValue) ||
                String.isEmpty(record.TestTextRequired__c)) {
                errors++;
            }
            counter++;
        }

        if (errors == 0 && FObject.processIsValid()) {
            result = true;
        }

        return result;
    }

}