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
 * @description FObject Dadela Test Class
 */
@IsTest
public class FObjectDadelaTest {

    @IsTest
    private static void copyField_valid_expectSuccess() {
        FObject.setGlobalVerbose('debug');

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition(FObjectOne__c.TestDecimal__c, 'random type(number) from(" 1") to(" 100 ") scale(0)');
        obj.setDefinition(FObjectOne__c.TestText__c, 'copy field(TestDecimal__c)');
        obj.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c objRecord : records) {
            if (objRecord.TestDecimal__c.intValue() != Integer.valueOf(objRecord.TestText__c)) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'copy field - errors found');
    }

    @IsTest
    private static void copyField_invalidField_expectFailure() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition('TestDecimal__c', 'random type(number) from(1) to(100) scale(0)')
            .setDefinition('TestText__c', 'copy field(TestDecimalX__c)');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid field [TestDecimalX__c] in definition ' +
            '[copy field(TestDecimalX__c)]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'copy field - errors found');
    }

    @IsTest
    private static void copyField_fieldEqualsDefinitionField_expectFailure() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('TestDecimal__c', 'random type(number) from(1) to(100) scale(0)');
        obj.setDefinition('TestText__c', 'copy field(testText__c)');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'The field [TestText__c] cannot be the same as the definition field ' +
            'in definition [copy field(testText__c)]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'copy field - errors found');
    }

    @IsTest
    private static void copyLookupField_fromText_expectSuccess() {
        Test.startTest();
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10);
        obj2.setDefinition('TestpicklistA__c', 'random type(picklist)');
        obj2.insertRecords(true);
        List<FObjectTwo__c> records2 = (List<FObjectTwo__c>) obj2.getRecords();
        Map<Id, FObjectTwo__c> lookupRecordsMap = new Map<Id, FObjectTwo__c>(records2);

        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 10);
        obj1.setDefinition('Testlookup__c', 'random lookup(FObjectTwo__c) source(forceea)');
        obj1.setDefinition('Testtext__c', 'copy field(Testlookup__c) from(FObjectTwo__c.TestpicklistA__c)');
        obj1.insertRecords(true);
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (Integer counter = 0; counter < records1.size(); counter++) {
            Id lookupId = records1.get(counter).TestLookup__c;
            if (records1.get(counter).TestText__c != null &&
                records1.get(counter).TestText__c != lookupRecordsMap.get(lookupId).TestPicklistA__c) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'copy lookup field - errors found');
    }

    @IsTest
    private static void copyLookupField_fromDate_expectSuccess() {
        Test.startTest();

        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10);
        obj2.setDefinition('Testdate__c', 'random type(date) from(2018-01-01) to(2018-12-31)');
        obj2.insertRecords(true);
        List<FObjectTwo__c> records2 = (List<FObjectTwo__c>) obj2.getRecords();
        Map<Id, FObjectTwo__c> lookupRecordsMap = new Map<Id, FObjectTwo__c>(records2);

        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 10);
        obj1.setDefinition('Testlookup__c', 'random lookup(FObjectTwo__c) source(forceea)');
        obj1.setDefinition('Testdate__c', 'copy field(Testlookup__c) from(FObjectTwo__c.Testdate__c)');
        obj1.insertRecords(true);
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();

        Test.stopTest();

        Integer errors = 0;
        for (Integer counter = 0; counter < records1.size(); counter++) {
            Id lookupId = records1.get(counter).TestLookup__c;
            if (records1.get(counter).TestDate__c != null &&
                records1.get(counter).TestDate__c != lookupRecordsMap.get(lookupId).TestDate__c) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'copy lookup field - errors found');
    }

    @IsTest
    private static void copyLookupField_fromDatetimeToDatetime_expectSuccess() {
        Test.startTest();

        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10);
        obj2.setDefinition('Testdatetime__c', 'random type(datetime) from(2018-01-01) to(2018-12-31)');
        obj2.insertRecords(true);
        List<FObjectTwo__c> records2 = (List<FObjectTwo__c>) obj2.getInsertedRecords();
        Map<Id, FObjectTwo__c> lookupRecordsMap = new Map<Id, FObjectTwo__c>(records2);

        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 10);
        obj1.setDefinition('Testlookup__c', 'random lookup(FObjectTwo__c) source(forceea)');
        obj1.setDefinition('Testdatetime__c', 'copy field(Testlookup__c) from(FObjectTwo__c.Testdatetime__c)');
        obj1.insertRecords(true);
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();

        Test.stopTest();

        Integer errors = 0;
        for (Integer counter = 0; counter < records1.size(); counter++) {
            Id lookupId = records1.get(counter).TestLookup__c;
            if (String.valueOf(lookupRecordsMap.get(lookupId).TestDatetime__c) !=
                String.valueOf(records1.get(counter).TestDatetime__c)) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'copy lookup field - errors found');
    }

    @IsTest
    private static void copyLookupField_fromDatetimeToText_expectSuccess() {
        Test.startTest();

        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10);
        obj2.setDefinition('Testdatetime__c', 'random type(datetime) from(2018-01-01) to(2018-12-31)');
        obj2.insertRecords(true);
        List<FObjectTwo__c> records2 = (List<FObjectTwo__c>) obj2.getInsertedRecords();
        Map<Id, FObjectTwo__c> lookupRecordsMap = new Map<Id, FObjectTwo__c>(records2);

        FObject obj1 = new FObject('FObjectOne__c', 20);
        obj1.setDefinition('Testlookup__c', 'random lookup(FObjectTwo__c) source(forceea)');
        obj1.setDefinition('TestText__c', 'copy field(Testlookup__c) from(FObjectTwo__c.Testdatetime__c)');
        obj1.insertRecords(true);
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();

        Test.stopTest();

        Integer errors = 0;
        for (Integer counter = 0; counter < records1.size(); counter++) {
            Id lookupId = records1.get(counter).TestLookup__c;
            Datetime dt = lookupRecordsMap.get(lookupId).TestDatetime__c;
            if (String.valueOfGmt(dt) != records1.get(counter).TestText__c) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'copy lookup field - errors found');
    }

    @IsTest
    private static void copyLookupField_fromTime_expectSuccess() {
        Test.startTest();
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10);
        obj2.setDefinition('Testtime__c', 'static value(23:59:59)');
        obj2.insertRecords(true);
        List<FObjectTwo__c> records2 = (List<FObjectTwo__c>) obj2.getRecords();
        Map<Id, FObjectTwo__c> lookupRecordsMap = new Map<Id, FObjectTwo__c>(records2);

        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 10);
        obj1.setDefinition('Testlookup__c', 'random lookup(FObjectTwo__c) source(forceea)');
        obj1.setDefinition('Testtime__c', 'copy field(Testlookup__c) from(FObjectTwo__c.Testtime__c)');
        obj1.insertRecords(true);
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (Integer counter = 0; counter < records1.size(); counter++) {
            Id lookupId = records1.get(counter).TestLookup__c;
            if (records1.get(counter).TestTime__c != null &&
                records1.get(counter).TestTime__c != lookupRecordsMap.get(lookupId).TestTime__c) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'copy lookup field - errors found');
    }

    @IsTest
    private static void copyLookupField_fromCurrency_expectSuccess() {
        Test.startTest();
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10);
        obj2.setDefinition('TestCurrency__c', 'random type(number) from(1) to(100) scale(2)');
        obj2.insertRecords(true);
        List<FObjectTwo__c> records2 = (List<FObjectTwo__c>) obj2.getRecords();
        Map<Id, FObjectTwo__c> lookupRecordsMap = new Map<Id, FObjectTwo__c>(records2);

        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 10);
        obj1.setDefinition('Testlookup__c', 'random lookup(FObjectTwo__c) source(forceea)');
        obj1.setDefinition('TestCurrency__c', 'copy field(Testlookup__c) from(FObjectTwo__c.TestCurrency__c)');
        obj1.insertRecords(true);
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (Integer counter = 0; counter < records1.size(); counter++) {
            Id lookupId = records1.get(counter).TestLookup__c;
            if (records1.get(counter).TestCurrency__c != null &&
                records1.get(counter).TestCurrency__c != lookupRecordsMap.get(lookupId).TestCurrency__c) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'copy lookup field - errors found');
    }

    @IsTest
    private static void copyLookupField_fromCheckbox_expectSuccess() {
        Test.startTest();
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10);
        obj2.setDefinition('TestCheckbox__c', 'random type(boolean)');
        obj2.insertRecords(true);
        List<FObjectTwo__c> records2 = (List<FObjectTwo__c>) obj2.getRecords();
        Map<Id, FObjectTwo__c> lookupRecordsMap = new Map<Id, FObjectTwo__c>(records2);

        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 10);
        obj1.setDefinition('Testlookup__c', 'random lookup(FObjectTwo__c) source(forceea)');
        obj1.setDefinition('TestCheckbox__c', 'copy field(Testlookup__c) from(FObjectTwo__c.TestCheckbox__c)');
        obj1.insertRecords(true);
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (Integer counter = 0; counter < records1.size(); counter++) {
            Id lookupId = records1.get(counter).TestLookup__c;
            if (records1.get(counter).TestCheckbox__c != null &&
                records1.get(counter).TestCheckbox__c != lookupRecordsMap.get(lookupId).TestCheckbox__c) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'copy lookup field - errors found');
    }

    @IsTest
    private static void copyLookupField_fromUrl_expectSuccess() {
        Test.startTest();
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10);
        obj2.setDefinition('TestUrl__c', 'random type(url)');
        obj2.insertRecords(true);
        List<FObjectTwo__c> records2 = (List<FObjectTwo__c>) obj2.getRecords();
        Map<Id, FObjectTwo__c> lookupRecordsMap = new Map<Id, FObjectTwo__c>(records2);

        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 10);
        obj1.setDefinition('Testlookup__c', 'random lookup(FObjectTwo__c) source(forceea)');
        obj1.setDefinition('TestUrl__c', 'copy field(Testlookup__c) from(FObjectTwo__c.TestUrl__c)');
        obj1.insertRecords(true);
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (Integer counter = 0; counter < records1.size(); counter++) {
            Id lookupId = records1.get(counter).TestLookup__c;
            if (records1.get(counter).TestUrl__c != null &&
                records1.get(counter).TestUrl__c != lookupRecordsMap.get(lookupId).TestUrl__c) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'copy lookup field - errors found');
    }

    @IsTest
    private static void copyLookupField_invalidField_expectFailure() {
        String definitionString = 'copy field(TestlookupX__c) from(FObjectTwo__c.TestpicklistA__c)';

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('Testlookup__c', 'random lookup(FObjectTwo__c) source(forceea)');
        obj.setDefinition('Testtext__c', definitionString);
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid field [TestlookupX__c] in definition [' + definitionString + ']';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'copy lookup field - errors found');
    }

    @IsTest
    private static void copyLookupField_invalidLookupObject_expectFailure() {
        String definitionString = 'copy field(Testlookup__c) from(FObjecttwoX__c.TestpicklistA__c)';

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('Testlookup__c', 'random lookup(FObjectTwo__c) source(forceea)');
        obj.setDefinition('Testtext__c', definitionString);
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid lookup SObject [FObjecttwoX__c] in definition [' + definitionString + ']';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'copy lookup field - errors found');
    }

    @IsTest
    private static void copyLookupField_invalidLookupField_expectFailure() {
        String definitionString = 'copy field(Testlookup__c) from(FObjectTwo__c.TestpicklistX__c)';

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('Testlookup__c', 'random lookup(FObjectTwo__c) source(forceea)');
        obj.setDefinition('Testtext__c', definitionString);
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid lookup field [TestpicklistX__c] in definition [' + definitionString + ']';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'copy lookup field - errors found');
    }

    @IsTest
    private static void copyLookupField_lookupFieldEqualsDefinitionField_expectFailure() {
        String definitionString = 'copy field(TestText__c) from(FObjectTwo__c.TestpicklistA__c)';

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('Testlookup__c', 'random lookup(FObjectTwo__c) source(forceea)');
        obj.setDefinition('Testtext__c', definitionString);
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'The field [TestText__c] cannot be the same as the definition field ' +
            'in definition [' + definitionString + ']';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'copy lookup field - errors found');
    }

    @IsTest
    private static void mock_instanceMocking_expectSuccess() {
        Integer size = 10;

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c', size);
        obj.setDefinition(FObjectOne__c.Id, 'mock type(id)');
        List<Database.SaveResult> results = obj.insertRecords(true);
        List<FObjectOne__c> createdRecords = (List<FObjectOne__c>) obj.getRecords();
        List<FObjectOne__c> insertedRecords = (List<FObjectOne__c>) obj.getInsertedRecords();
        Test.stopTest();

        Integer errors = 0;
        if (createdRecords.size() != size) {
            errors += 1;
        }
        if (insertedRecords.size() != size) {
            errors += 2;
        }
        if (!results.isEmpty()) {
            errors += 4;
        }
        if (!FObject.processIsValid()) {
            errors += 8;
        }
        System.assertEquals(0, errors, 'mock - errors found');
    }

    @IsTest
    private static void mock_globalMockingWiothoutLookup_expectSuccess() {
        Integer size1 = 10;
        Integer size2 = 5;
        Integer size3 = 2;
        FObject.setGlobalMocking(true);

        Test.startTest();
        FObject obj1 = new FObject('FObjectOne__c', size1);
        List<Database.SaveResult> results1 = obj1.insertRecords(true);
        List<FObjectOne__c> createdRecords1 = (List<FObjectOne__c>) obj1.getRecords();
        List<FObjectOne__c> insertedRecords1 = (List<FObjectOne__c>) obj1.getInsertedRecords();

        FObject obj2 = new FObject('FObjectOne__c', size2);
        List<Database.SaveResult> results2 = obj2.insertRecords(true);
        List<FObjectOne__c> createdRecords2 = (List<FObjectOne__c>) obj2.getRecords();
        List<FObjectOne__c> insertedRecords2 = (List<FObjectOne__c>) obj2.getInsertedRecords();

        FObject obj3 = new FObject('FObjectTwo__c', size3);
        List<Database.SaveResult> results3 = obj3.insertRecords(true);
        List<FObjectOne__c> createdRecords3 = (List<FObjectOne__c>) obj3.getRecords();
        List<FObjectOne__c> insertedRecords3 = (List<FObjectOne__c>) obj3.getInsertedRecords();
        Test.stopTest();

        Integer errors = 0;
        if ((createdRecords1.size() + createdRecords2.size() + createdRecords3.size()) != (size1 + size2 + size3)) {
            errors += 1;
        }
        if ((insertedRecords1.size() + insertedRecords2.size() + insertedRecords3.size()) != (size1 + size2 + size3)) {
            errors += 2;
        }
        if (!results1.isEmpty() && !results2.isEmpty() && !results3.isEmpty()) {
            errors += 4;
        }
        if (!FObject.processIsValid()) {
            errors += 8;
        }
        System.assertEquals(0, errors, 'mock - errors found');
    }

    @IsTest
    private static void mock_globalMockingWithLookup_expectSuccess() {
        Integer size1 = 5;
        Integer size2 = 20;
        FObject.setGlobalMocking(true);

        Test.startTest();
        FObject obj1 = new FObject('FObjectTwo__c', size1);
        List<Database.SaveResult> results1 = obj1.insertRecords(true);
        List<FObjectOne__c> createdRecords1 = (List<FObjectOne__c>) obj1.getRecords();
        List<FObjectOne__c> insertedRecords1 = (List<FObjectOne__c>) obj1.getInsertedRecords();

        FObject obj2 = new FObject('FObjectOne__c', size2)
            .setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) source(forceea)');
        List<Database.SaveResult> results2 = obj2.insertRecords(true);
        List<FObjectOne__c> createdRecords2 = (List<FObjectOne__c>) obj2.getRecords();
        List<FObjectOne__c> insertedRecords2 = (List<FObjectOne__c>) obj2.getInsertedRecords();
        Test.stopTest();

        Integer errors = 0;
        if ((createdRecords1.size() + createdRecords2.size()) != (size1 + size2)) {
            errors += 1;
        }
        if ((insertedRecords1.size() + insertedRecords2.size()) != (size1 + size2)) {
            errors += 2;
        }
        if (!results1.isEmpty() && !results2.isEmpty()) {
            errors += 4;
        }
        if (!FObject.processIsValid()) {
            errors += 8;
        }
        System.assertEquals(0, errors, 'mock - errors found');
    }

    @IsTest
    private static void randomDate_fromLessThanTo_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('TestDate__c', 'random type("date ") from(2018-01-01) to(2018-01-10)');
        obj.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Date fromDate = Date.newInstance(2018, 1, 1);
        Date toDate = Date.newInstance(2018, 1, 10);
        for (FObjectOne__c objRecord : records) {
            if (objRecord.TestDate__c < fromDate || objRecord.TestDate__c > toDate) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random date - errors found');
    }

    @IsTest
    private static void randomDate_fromEqualsTo_expectFailure() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('TestDate__c', 'random type(date) from(2018-01-01) to(2018-1-1)');
        obj.insertRecords(true);

        String expectedResult = 'The [from] date is greater than or equal to the [to] date in definition [' +
            'random type(date) from(2018-01-01) to(2018-1-1)]';
        String actualResult = obj.getErrors().get('TestDate__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'random date - errors found');
    }

    @IsTest
    private static void randomDate_fromGreaterThanTo_expectFailure() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('TestDate__c', 'random type(date) from(2018-1-10) to(2018-01-01)');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'The [from] date is greater than or equal to the [to] date in definition [' +
            'random type(date) from(2018-1-10) to(2018-01-01)]';
        String actualResult = obj.getErrors().get('TestDate__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'random date - errors found');
    }

    @IsTest
    private static void randomDatetime_fromDatetimeLessThanToDatetimeSameDay_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('TestDatetime__c',
            'random type("datetime") from(2018-01-01 01:01:01) to(2018-01-01 02:02:02)');
        obj.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Long dtFrom = Datetime.newInstance(2018, 1, 1, 1, 1, 1).getTime();
        Long dtTo = Datetime.newInstance(2018, 1, 1, 2, 2, 2).getTime();
        for (FObjectOne__c objRecord : records) {
            if (objRecord.TestDatetime__c.getTime() < dtFrom || objRecord.TestDatetime__c.getTime() > dtTo) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random datetime - errors found');
    }

    @IsTest
    private static void randomDatetime_fromDatetimeLessThanToDatetimeDifferentDay_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('TestDatetime__c',
            'random type(datetime) from(" 2018-01-01 01:01:01") to(2018-01-02 02:02:02)');
        obj.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Long dtFrom = Datetime.newInstance(2018, 1, 1, 1, 1, 1).getTime();
        Long dtTo = Datetime.newInstance(2018, 1, 2, 2, 2, 2).getTime();
        for (FObjectOne__c objRecord : records) {
            if (objRecord.TestDatetime__c.getTime() < dtFrom || objRecord.TestDatetime__c.getTime() > dtTo) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random datetime - errors found');
    }

    @IsTest
    private static void randomDatetime_fromDatetimeLessThanToDateSameDay_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('TestDatetime__c', 'random type(datetime) from(2018-01-01 01:01:01) to(2018-01-01)');
        obj.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Long dtFrom = Datetime.newInstance(2018, 1, 1, 1, 1, 1).getTime();
        Long dtTo = Datetime.newInstance(2018, 1, 1, 23, 59, 59).getTime();
        for (FObjectOne__c objRecord : records) {
            if (objRecord.TestDatetime__c.getTime() < dtFrom || objRecord.TestDatetime__c.getTime() > dtTo) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random datetime - errors found');
    }

    @IsTest
    private static void randomDatetime_fromDatetimeLessThanToDateDifferentDay_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('TestDatetime__c', 'random type(datetime) from(2018-01-01 01:01:01) to(2018-01-05)');
        obj.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Long dtFrom = Datetime.newInstance(2018, 1, 1, 1, 1, 1).getTime();
        Long dtTo = Datetime.newInstance(2018, 1, 5, 23, 59, 59).getTime();
        for (FObjectOne__c objRecord : records) {
            if (objRecord.TestDatetime__c.getTime() < dtFrom || objRecord.TestDatetime__c.getTime() > dtTo) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random datetime - errors found');
    }

    @IsTest
    private static void randomDatetime_fromDateLessThanToDatetimeSameDay_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('TestDatetime__c', 'random type(datetime) from(2018-01-01) to(2018-01-01 01:01:01)');
        obj.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Long dtFrom = Datetime.newInstance(2018, 1, 1, 0, 0, 0).getTime();
        Long dtTo = Datetime.newInstance(2018, 1, 1, 1, 1, 1).getTime();
        for (FObjectOne__c objRecord : records) {
            if (objRecord.TestDatetime__c.getTime() < dtFrom || objRecord.TestDatetime__c.getTime() > dtTo) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random datetime - errors found');
    }

    @IsTest
    private static void randomDatetime_fromDateLessThanToDatetimeDifferentDay_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('TestDatetime__c', 'random type(datetime) from(2018-01-01) to(2018-01-05 01:01:01)');
        obj.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Long dtFrom = Datetime.newInstance(2018, 1, 1, 0, 0, 0).getTime();
        Long dtTo = Datetime.newInstance(2018, 1, 5, 1, 1, 1).getTime();
        for (FObjectOne__c objRecord : records) {
            if (objRecord.TestDatetime__c.getTime() < dtFrom || objRecord.TestDatetime__c.getTime() > dtTo) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random datetime - errors found');
    }

    @IsTest
    private static void randomDatetime_fromDateLessThanToDate_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('TestDatetime__c', 'random type(datetime) from(2018-1-1) to(2018-1-5)');
        obj.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Long dtFrom = Datetime.newInstance(2018, 1, 1, 0, 0, 0).getTime();
        Long dtTo = Datetime.newInstance(2018, 1, 5, 0, 0, 0).getTime();
        for (FObjectOne__c objRecord : records) {
            if (objRecord.TestDatetime__c.getTime() < dtFrom || objRecord.TestDatetime__c.getTime() > dtTo) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random datetime - errors found');
    }

    @IsTest
    private static void randomDatetime_fromDateEqualsToDate_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('TestDatetime__c', 'random type(datetime) from(2018-1-1) to(2018-1-1)');
        obj.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Long dtFrom = Datetime.newInstance(2018, 1, 1, 0, 0, 0).getTime();
        Long dtTo = Datetime.newInstance(2018, 1, 1, 23, 59, 59).getTime();
        for (FObjectOne__c objRecord : records) {
            if (objRecord.TestDatetime__c.getTime() < dtFrom || objRecord.TestDatetime__c.getTime() > dtTo) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random datetime - errors found');
    }

    @IsTest
    private static void randomDatetime_fromDatetimeEqualsToDatetime_expectFailure() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestDatetime__c', 'random type(datetime) from(2018-01-01 01:01:01) to(2018-01-01 01:01:01)');
        obj.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        String expectedResult = 'The [from] datetime is greater than or equal to the [to] datetime in definition ' +
            '[random type(datetime) from(2018-01-01 01:01:01) to(2018-01-01 01:01:01)]';
        String actualResult = obj.getErrors().get('TestDatetime__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'random datetime - errors found');
    }

    @IsTest
    private static void randomDatetime_fromDatetimeGreaterThanToDatetime_expectFailure() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestDatetime__c', 'random type(datetime) from(2018-01-01 02:02:02) to(2018-01-01 01:01:01)');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'The [from] datetime is greater than or equal to the [to] datetime in definition ' +
            '[random type(datetime) from(2018-01-01 02:02:02) to(2018-01-01 01:01:01)]';
        String actualResult = obj.getErrors().get('TestDatetime__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'random datetime - errors found');
    }

    @IsTest
    private static void randomDatetime_fromDatetimeGreaterThanToDate_expectFailure() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestDatetime__c', 'random type(datetime) from(2018-01-02 01:01:01) to(2018-01-01)');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'The [from] datetime is greater than or equal to the [to] datetime in definition ' +
            '[random type(datetime) from(2018-01-02 01:01:01) to(2018-01-01)]';
        String actualResult = obj.getErrors().get('TestDatetime__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'random datetime - errors found');
    }

    @IsTest
    private static void randomDatetime_fromDateGreaterThanToDatetime_expectFailure() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestDatetime__c', 'random type(datetime) from(2018-01-02) to(2018-01-01 01:01:01)');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'The [from] datetime is greater than or equal to the [to] datetime in definition ' +
            '[random type(datetime) from(2018-01-02) to(2018-01-01 01:01:01)]';
        String actualResult = obj.getErrors().get('TestDatetime__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'random datetime - errors found');
    }

    @IsTest
    private static void randomFirstName_incorrectLanguageAndLocality_expectSuccess() {
        ForceeaUtilityTest.loadNamesFromUnitesStatesInEnglish();

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        FObject.setGlobalLanguage('Language');
        FObject.setGlobalLocality('Locality');
        obj.setDefinition('TestText__c', 'random type(firstname) group(a)');
        List<FObjectOne__c> records = obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c objRecord : records) {
            if (!ForceeaUtilityTest.femaleFirstNames.contains(objRecord.TestText__c) &&
                !ForceeaUtilityTest.maleFirstNames.contains(objRecord.TestText__c)) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random name - errors found');
    }

    @IsTest
    private static void randomLastName_incorrectLanguageAndLocality_expectSuccess() {
        ForceeaUtilityTest.loadNamesFromUnitesStatesInEnglish();

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        FObject.setGlobalLanguage('Language');
        FObject.setGlobalLocality('Locality');
        obj.setDefinition('TestText__c', 'random type(lastname) group(a)');
        List<FObjectOne__c> records = obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c objRecord : records) {
            if (!ForceeaUtilityTest.femaleLastNames.contains(objRecord.TestText__c) &&
                !ForceeaUtilityTest.maleLastNames.contains(objRecord.TestText__c)) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random name - errors found');
    }

    @IsTest
    private static void randomFirstLastName_fromGreeceInGreek_expectSuccess() {
        ForceeaUtilityTest.loadNamesFromGreeceInGreek();

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        FObject.setGlobalLanguage('Greek');
        FObject.setGlobalLocality('Greece');
        obj.setDefinition('TestText__c', 'random type(firstname) group(a)');
        obj.setDefinition('TestTextArea__c', 'random type(lastname) group(a)');
        List<FObjectOne__c> records = obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c objRecord : records) {
            if (!ForceeaUtilityTest.femaleFirstNames.contains(objRecord.TestText__c) &&
                !ForceeaUtilityTest.maleFirstNames.contains(objRecord.TestText__c)) {
                errors++;
            }
            if (!ForceeaUtilityTest.femaleLastNames.contains(objRecord.TestTextArea__c) &&
                !ForceeaUtilityTest.maleLastNames.contains(objRecord.TestTextArea__c)) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random name - errors found');
    }

    @IsTest
    private static void randomFirstLastName_fromUnitedStatesInEnglish_expectSuccess() {
        ForceeaUtilityTest.loadNamesFromUnitesStatesInEnglish();

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        FObject.setGlobalLanguage('English');
        FObject.setGlobalLocality('United States');
        obj.setDefinition('TestText__c', 'random type(firstname) group(a)');
        obj.setDefinition('TestTextArea__c', 'random type(lastname) group(a)');
        List<FObjectOne__c> records = obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c objRecord : records) {
            if (!ForceeaUtilityTest.femaleFirstNames.contains(objRecord.TestText__c) &&
                !ForceeaUtilityTest.maleFirstNames.contains(objRecord.TestText__c)) {
                errors++;
            }
            if (!ForceeaUtilityTest.femaleLastNames.contains(objRecord.TestTextArea__c) &&
                !ForceeaUtilityTest.maleLastNames.contains(objRecord.TestTextArea__c)) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random name - errors found');
    }

    @IsTest
    private static void randomStreet_fromUnitedStatesInEnglish_expectSuccess() {
        FObject.setGlobalLanguage('English');
        FObject.setGlobalLocality('United States');
        FObject.loadAddresses();
        List<String> values = new List<String>();
        Set<String> valuesSet = new Set<String>();
        for (FObject.FAddress address : FObject.addressesLibrary) {
            values.add(address.street);
            valuesSet.add(address.street);
        }

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c', 200);
        obj.setDefinition('TestText__c', 'random type(street) group(shipping)');
        obj.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        String value = '';
        for (FObjectOne__c objRecord : records) {
            value = objRecord.TestText__c.substringAfter(' ');
            if (!valuesSet.contains(value)) {
                errors++;
            }
        }
        for (FObjectOne__c objRecord : records) {
            objRecord.TestText__c = objRecord.TestText__c.substringAfter(' ');
        }
        if (!ForceeaUtilityTest.isValidDistribution('TestText__c', values, records)) {
            errors++;
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random street - errors found');
    }

    @IsTest
    private static void randomStreet_fromGreeceInGreek_expectSuccess() {
        FObject.setGlobalLanguage('Greek');
        FObject.setGlobalLocality('Greece');
        FObject.loadAddresses();
        List<String> values = new List<String>();
        Set<String> valuesSet = new Set<String>();
        for (FObject.FAddress address : FObject.addressesLibrary) {
            values.add(address.street);
            valuesSet.add(address.street);
        }

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c', 500);
        obj.setDefinition('TestText__c', 'random type(street) group(shipping)');
        obj.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        String value = '';
        for (FObjectOne__c objRecord : records) {
            value = objRecord.TestText__c.substringBeforeLast(' ');
            if (!valuesSet.contains(value)) {
                errors++;
            }
        }
        for (FObjectOne__c objRecord : records) {
            objRecord.TestText__c = objRecord.TestText__c.substringBeforeLast(' ');
        }
        if (!ForceeaUtilityTest.isValidDistribution('TestText__c', values, records)) {
            errors++;
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random street - errors found');
    }

    @IsTest
    private static void randomCity_fromUnitedStatesInEnglish_expectSuccess() {
        FObject.setGlobalLanguage('English');
        FObject.setGlobalLocality('United States');
        FObject.loadAddresses();
        List<String> values = new List<String>();
        Set<String> valuesSet = new Set<String>();
        for (FObject.FAddress address : FObject.addressesLibrary) {
            values.add(address.city);
            valuesSet.add(address.city);
        }

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c', 200);
        obj.setDefinition('TestText__c', 'random type(city) group(shipping)');
        obj.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        String value = '';
        for (FObjectOne__c objRecord : records) {
            value = objRecord.TestText__c;
            if (!valuesSet.contains(value)) {
                errors++;
            }
        }
        for (FObjectOne__c objRecord : records) {
            objRecord.TestText__c = objRecord.TestText__c;
        }
        if (!ForceeaUtilityTest.isValidDistribution('TestText__c', values, records)) {
            errors++;
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random city - errors found');
    }

    @IsTest
    private static void randomCity_fromGreeceInGreek_expectSuccess() {
        FObject.setGlobalLanguage('Greek');
        FObject.setGlobalLocality('Greece');
        FObject.loadAddresses();
        List<String> values = new List<String>();
        Set<String> valuesSet = new Set<String>();
        for (FObject.FAddress address : FObject.addressesLibrary) {
            values.add(address.city);
            valuesSet.add(address.city);
        }

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c', 200);
        obj.setDefinition('TestText__c', 'random type(city) group(shipping)');
        obj.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        String value = '';
        for (FObjectOne__c objRecord : records) {
            value = objRecord.TestText__c;
            if (!valuesSet.contains(value)) {
                errors++;
            }
        }
        if (!ForceeaUtilityTest.isValidDistribution('TestText__c', values, records)) {
            errors++;
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random city - errors found');
    }

    @IsTest
    private static void randomPostalCode_fromUnitedStatesInEnglish_expectSuccess() {
        FObject.setGlobalLanguage('English');
        FObject.setGlobalLocality('United States');
        FObject.loadAddresses();
        List<String> values = new List<String>();
        Set<String> valuesSet = new Set<String>();
        for (FObject.FAddress address : FObject.addressesLibrary) {
            values.add(address.postalCode);
            valuesSet.add(address.postalCode);
        }

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c', 200);
        obj.setDefinition('TestText__c', 'random type(postalcode) group(shipping)');
        obj.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        String value = '';
        for (FObjectOne__c objRecord : records) {
            value = objRecord.TestText__c;
            if (!valuesSet.contains(value)) {
                errors++;
            }
        }
        for (FObjectOne__c objRecord : records) {
            objRecord.TestText__c = objRecord.TestText__c;
        }
        if (!ForceeaUtilityTest.isValidDistribution('TestText__c', values, records)) {
            errors++;
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random postalcode - errors found');
    }

    @IsTest
    private static void randomPostalCode_fromGreeceInGreek_expectSuccess() {
        FObject.setGlobalLanguage('Greek');
        FObject.setGlobalLocality('Greece');
        FObject.loadAddresses();
        List<String> values = new List<String>();
        Set<String> valuesSet = new Set<String>();
        for (FObject.FAddress address : FObject.addressesLibrary) {
            values.add(address.postalCode);
            valuesSet.add(address.postalCode);
        }

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c', 500);
        obj.setDefinition('TestText__c', 'random type(postalcode) group(shipping)');
        obj.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        String value = '';
        for (FObjectOne__c objRecord : records) {
            value = objRecord.TestText__c;
            if (!valuesSet.contains(value)) {
                errors++;
            }
        }
        for (FObjectOne__c objRecord : records) {
            objRecord.TestText__c = objRecord.TestText__c;
        }
        if (!ForceeaUtilityTest.isValidDistribution('TestText__c', values, records)) {
            errors++;
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random postalcode - errors found');
    }

    @IsTest
    private static void randomState_fromUnitedStatesInEnglish_expectSuccess() {
        FObject.setGlobalLanguage('English');
        FObject.setGlobalLocality('United States');
        FObject.loadAddresses();
        List<String> values = new List<String>();
        Set<String> valuesSet = new Set<String>();
        for (FObject.FAddress address : FObject.addressesLibrary) {
            values.add(address.state);
            valuesSet.add(address.state);
        }

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c', 200);
        obj.setDefinition('TestText__c', 'random type(state) group(shipping)');
        obj.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        String value = '';
        for (FObjectOne__c objRecord : records) {
            value = objRecord.TestText__c;
            if (!valuesSet.contains(value)) {
                errors++;
            }
        }
        for (FObjectOne__c objRecord : records) {
            objRecord.TestText__c = objRecord.TestText__c;
        }
        if (!ForceeaUtilityTest.isValidDistribution('TestText__c', values, records)) {
            errors++;
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random state - errors found');
    }

    @IsTest
    private static void randomCountry_fromUnitedStatesInEnglish_expectSuccess() {
        FObject.setGlobalLanguage('English');
        FObject.setGlobalLocality('United States');
        FObject.loadAddresses();
        List<String> values = new List<String>();
        Set<String> valuesSet = new Set<String>();
        for (FObject.FAddress address : FObject.addressesLibrary) {
            values.add(address.country);
            valuesSet.add(address.country);
        }

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c', 200);
        obj.setDefinition('TestText__c', 'random type(country) group(shipping)');
        obj.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        String value = '';
        for (FObjectOne__c objRecord : records) {
            value = objRecord.TestText__c;
            if (!valuesSet.contains(value)) {
                errors++;
            }
        }
        for (FObjectOne__c objRecord : records) {
            objRecord.TestText__c = objRecord.TestText__c;
        }
        if (!ForceeaUtilityTest.isValidDistribution('TestText__c', values, records)) {
            errors++;
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random country - errors found');
    }

    @IsTest
    private static void randomCountry_fromGreeceInGreek_expectSuccess() {
        FObject.setGlobalLanguage('Greek');
        FObject.setGlobalLocality('Greece');
        FObject.loadAddresses();
        List<String> values = new List<String>();
        Set<String> valuesSet = new Set<String>();
        for (FObject.FAddress address : FObject.addressesLibrary) {
            values.add(address.country);
            valuesSet.add(address.country);
        }

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c', 200);
        obj.setDefinition('TestText__c', 'random type(country) group(shipping)');
        obj.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        String value = '';
        for (FObjectOne__c objRecord : records) {
            value = objRecord.TestText__c;
            if (!valuesSet.contains(value)) {
                errors++;
            }
        }
        for (FObjectOne__c objRecord : records) {
            objRecord.TestText__c = objRecord.TestText__c;
        }
        if (!ForceeaUtilityTest.isValidDistribution('TestText__c', values, records)) {
            errors++;
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random country - errors found');
    }

    @IsTest
    private static void randomList_integerArguments_expectSuccess() {
        List<String> arguments = new List<String>{
            '1.0', '2.0', '3.0', '0.0'
        };

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestInteger__c', 'random type(list) value(1, 2, 3, 0)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        obj.insertRecords(true);
        Test.stopTest();

        Boolean expectedResult = true;
        Boolean actualResult = ForceeaUtilityTest.isValidDistribution('TestInteger__c', arguments, records);
        System.assertEquals(expectedResult, actualResult, 'random list - errors found');
    }

    @IsTest
    private static void randomList_decimalArguments_expectSuccess() {
        List<String> arguments = new List<String>{
            '1.0', '2.22', '0.0', '3.0'
        };

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestDecimal__c', 'random type(list) value(1, 2.22, 0.0, 3)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        obj.insertRecords(true);
        Test.stopTest();

        Boolean expectedResult = true;
        Boolean actualResult = ForceeaUtilityTest.isValidDistribution('TestDecimal__c', arguments, records);
        System.assertEquals(expectedResult, actualResult, 'random list - errors found');
    }

    @IsTest
    private static void randomList_dateArguments_expectSuccess() {
        List<String> arguments = new List<String>{
            '2018-01-01 00:00:00', '2017-01-01 00:00:00', '2016-01-01 00:00:00', '2015-01-01 00:00:00'
        };

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestDate__c', 'random type(list) value(2018-01-01, 2017-01-01, 2016-01-01, 2015-01-01)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        obj.insertRecords(true);
        Test.stopTest();

        Boolean expectedResult = true;
        Boolean actualResult = ForceeaUtilityTest.isValidDistribution('TestDate__c', arguments, records);
        System.assertEquals(expectedResult, actualResult, 'random list - errors found');
    }

    @IsTest
    private static void randomList_datetimeArguments_expectSuccess() {
        List<Datetime> arguments = new List<Datetime>();
        arguments.add(Datetime.newInstance(2018, 1, 1, 0, 0, 0));
        arguments.add(Datetime.newInstance(2017, 1, 1, 1, 1, 1));
        arguments.add(Datetime.newInstance(2016, 1, 1, 2, 2, 2));
        arguments.add(Datetime.newInstance(2015, 1, 1, 3, 3, 3));

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestDateTime__c',
            'random type(list) value(2018-01-01 00:00:00, 2017-01-01 01:01:01, 2016-01-01 02:02:02, 2015-01-01 03:03:03)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        obj.insertRecords(true);
        Test.stopTest();

        Boolean expectedResult = true;
        Boolean actualResult = ForceeaUtilityTest.isValidDistribution('TestDateTime__c', arguments, records);
        System.assertEquals(expectedResult, actualResult, 'random list - errors found');
    }

    @IsTest
    private static void randomList_doubleQuotes1_expectFailure() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('testText__c', 'random type(list) value("one, two)');
        obj.insertRecords(true);
        Test.stopTest();

        System.assert(!FObject.processIsValid(), 'random list - errors found');
    }

    @IsTest
    private static void randomList_doubleQuotes2_expectFailure() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('testText__c', 'random type(list) value(one", two)');
        obj.insertRecords(true);
        Test.stopTest();

        System.assert(!FObject.processIsValid(), 'random list - errors found');
    }

    @IsTest
    private static void randomList_doubleQuotes3_expectFailure() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('testText__c', 'random type(list) value(one, "two)');
        obj.insertRecords(true);
        Test.stopTest();

        System.assert(!FObject.processIsValid(), 'random list - errors found');
    }

    @IsTest
    private static void randomList_doubleQuotes4_expectFailure() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('testText__c', 'random type(list) value(one, two")');
        obj.insertRecords(true);
        Test.stopTest();

        System.assert(!FObject.processIsValid(), 'random list - errors found');
    }

    @IsTest
    private static void randomList_doubleQuotes5_expectFailure() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('testText__c', 'random type(list) value("one, "two")');
        List<FObjectOne__c> records = obj.getRecords();
        Test.stopTest();

        System.assert(!FObject.processIsValid(), 'random list - errors found');
    }

    @IsTest
    private static void randomList_doubleQuotes6_expectFailure() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('testText__c', 'random type(list) value(one", "two")');
        List<FObjectOne__c> records = obj.getRecords();
        Test.stopTest();

        System.assert(!FObject.processIsValid(), 'random list - errors found');
    }

    @IsTest
    private static void randomList_doubleQuotes7_expectFailure() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('testText__c', 'random type(list) value("one", "two)');
        List<FObjectOne__c> records = obj.getRecords();
        Test.stopTest();

        System.assert(!FObject.processIsValid(), 'random list - errors found');
    }

    @IsTest
    private static void randomList_doubleQuotes8_expectFailure() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('testText__c', 'random type(list) value("one", two")');
        List<FObjectOne__c> records = obj.getRecords();
        Test.stopTest();

        System.assert(!FObject.processIsValid(), 'random list - errors found');
    }

    @IsTest
    private static void randomList_doubleQuotes9_expectSucess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('testText__c', 'random type(list) value("one"two", three)');
        List<FObjectOne__c> records = obj.getRecords();
        Test.stopTest();

        System.assert(!FObject.processIsValid(), 'random list - errors found');
    }

    @IsTest
    private static void randomList_doubleQuotes10_expectSucess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('testText__c', 'random type(list) value("one"two", "three")');
        List<FObjectOne__c> records = obj.getRecords();
        Test.stopTest();

        System.assert(!FObject.processIsValid(), 'random list - errors found');
    }

    @IsTest
    private static void randomList_doubleQuotes11_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('TestText__c', 'random type(" list ") value(v1, "v2 ", " v3", " v4 ")');
        obj.setDefinition('TestText__c', 'static value(xyz)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        System.assert(FObject.processIsValid(), 'random list - errors found');
    }

    @IsTest
    private static void randomList_doubleQuotes1_expectSucess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('testText__c', 'random type(list) value(one, two)');
        List<FObjectOne__c> records = obj.getRecords();
        Test.stopTest();

        System.assert(FObject.processIsValid(), 'random list - errors found');
    }

    @IsTest
    private static void randomList_doubleQuotes2_expectSucess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('testText__c', 'random type(list) value("one", two)');
        List<FObjectOne__c> records = obj.getRecords();
        Test.stopTest();

        System.assert(FObject.processIsValid(), 'random list - errors found');
    }

    @IsTest
    private static void randomList_doubleQuotes3_expectSucess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('testText__c', 'random type(list) value(one, "two")');
        List<FObjectOne__c> records = obj.getRecords();
        Test.stopTest();

        System.assert(FObject.processIsValid(), 'random list - errors found');
    }

    @IsTest
    private static void randomList_doubleQuotes4_expectSucess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('testText__c', 'random type(list) value("one", "two")');
        List<FObjectOne__c> records = obj.getRecords();
        Test.stopTest();

        System.assert(FObject.processIsValid(), 'random list - errors found');
    }

    @IsTest
    private static void randomList_doubleQuotes5_expectSucess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('testText__c', 'random type(list) value(one, "two(2), three")');
        List<FObjectOne__c> records = obj.getRecords();
        Test.stopTest();

        System.assert(FObject.processIsValid(), 'random list - errors found');
    }

    @IsTest
    private static void randomList_doubleQuotes6_expectSucess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('testText__c', 'random type(list) value(one"two, "three")');
        List<FObjectOne__c> records = obj.getRecords();
        Test.stopTest();

        System.assert(FObject.processIsValid(), 'random list - errors found');
    }

    @IsTest
    private static void randomList_timeArguments_expectSuccess() {
        List<String> arguments = new List<String>{
            '01:01:01.000Z', '02:02:02.000Z', '03:03:03.000Z', '04:04:04.000Z'
        };

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestTime__c', 'random type(list) value(01:01:01, 02:02:02, 03:03:03, 04:04:04)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        obj.insertRecords(true);
        Test.stopTest();

        Boolean expectedResult = true;
        Boolean actualResult = ForceeaUtilityTest.isValidDistribution('TestTime__c', arguments, records);
        System.assertEquals(expectedResult, actualResult, 'random list - errors found');
    }

    @IsTest
    private static void randomList_stringArguments_expectSuccess() {
        List<String> arguments = new List<String>{
            'One', 'Two', 'Three', 'Twenty One'
        };

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestText__c', 'random type(list) value(One,Two,Three,Twenty One)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        obj.insertRecords(true);
        Test.stopTest();

        Boolean expectedResult = true;
        Boolean actualResult = ForceeaUtilityTest.isValidDistribution('TestText__c', arguments, records);
        System.assertEquals(expectedResult, actualResult, 'random list - errors found');
    }

    @IsTest
    private static void randomList_restrictedIndependentPicklistField_expectSuccess() {
        List<String> arguments = new List<String>{
            'a0', 'a1', 'a2'
        };

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestPicklistA__c', 'random type(list) value(a0, a1, a2, a4)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Boolean expectedResult = true;
        Boolean actualResult = ForceeaUtilityTest.isValidDistribution('TestPicklistA__c', arguments, records);
        System.assertEquals(expectedResult, actualResult, 'random list - errors found');
    }

    @IsTest
    private static void randomList_restrictedDependentPicklistField_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c', 100);
        obj.setDefinition(FObjectOne__c.TestPicklistB__c, 'random type(list) value(b0, b1, b2, b4, b5)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        // set mapping
        Set<String> picklistA0Mapping = new Set<String>{
            null
        };
        Set<String> picklistA1Mapping = new Set<String>{
            'b1'
        };
        Set<String> picklistA2Mapping = new Set<String>{
            'b1', 'b2'
        };
        Set<String> picklistA3Mapping = new Set<String>{
            'b1', 'b2', 'b3'
        };

        // get created field values
        List<String> picklistAValues = new List<String>();
        List<String> picklistBValues = new List<String>();
        for (FObjectOne__c objRecord : records) {
            picklistAValues.add(objRecord.TestPicklistA__c);
            picklistBValues.add(objRecord.TestPicklistB__c);
        }

        Integer errors = 0;
        for (Integer counter = 0; counter < records.size(); counter++) {
            if (picklistAValues[counter] == 'a0' && !picklistA0Mapping.contains(picklistBValues[counter])) {
                errors++;
            } else if (picklistAValues[counter] == 'a1' && !picklistA1Mapping.contains(picklistBValues[counter])) {
                errors++;
            } else if (picklistAValues[counter] == 'a2' && !picklistA2Mapping.contains(picklistBValues[counter])) {
                errors++;
            } else if (picklistAValues[counter] == 'a3' && !picklistA3Mapping.contains(picklistBValues[counter])) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random picklist - errors found');
    }

    @IsTest
    private static void randomList_unrestrictedIndependentPicklistField_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject('FObjectTwo__c');
        obj.setDefinition('TestPicklistEUnrestricted__c', 'random type(list) value(e1, e4, e5, d1, d2)');
        obj.insertRecords(true);
        List<FObjectTwo__c> records = (List<FObjectTwo__c>) obj.getRecords();
        Test.stopTest();

        Boolean expectedResult = true;
        List<String> arguments = new List<String>{
            'e1', 'e4', 'e5', 'd1', 'd2'
        };
        Boolean actualResult = ForceeaUtilityTest.isValidDistribution('TestPicklistEUnrestricted__c', arguments, records);
        System.assertEquals(expectedResult, actualResult, 'random list - errors found');
    }

    @IsTest
    private static void randomList_unrestrictedDependentPicklistField_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectTwo__c.SObjectType, 10);
        obj.setDefinition('TestPicklistFUnrestricted__c', 'random type(list) value(f0, f1, f4, f5, e1, e2)');
        List<Database.SaveResult> saveResults = obj.insertRecords(false);
        List<FObjectTwo__c> records = (List<FObjectTwo__c>) obj.getRecords();
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
        System.assertEquals(0, errors, 'random list - errors found');
    }

    @IsTest
    private static void randomList_controllingFieldIsCheckbox_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('TestCheckbox__c', 'static value(true)');
        obj.setDefinition('TestpicklistD__c', 'random type(list) value(d2, d3)');
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
        System.assertEquals(0, errors, 'random list - errors found');
    }

    @IsTest
    private static void randomList_oneRecordType_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('RecordTypeId', 'random type(list) value(RecordTypeA)');
        obj.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Boolean expectedResult = true;
        Id recordType1Id = Schema.SObjectType.FObjectOne__c.getRecordTypeInfosByName().get('Record Type A').getRecordTypeId();
        List<String> arguments = new List<String>{
            recordType1Id
        };
        Boolean actualResult = ForceeaUtilityTest.isValidDistribution('RecordTypeId', arguments, records);
        System.assertEquals(expectedResult, actualResult, 'random list - errors found');
    }

    @IsTest
    private static void randomList_manyRecordTypes_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('RecordTypeId', 'random type(list) value(RecordTypeA, RecordTypeB)');
        obj.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Boolean expectedResult = true;
        Id recordType1Id = Schema.SObjectType.FObjectOne__c.getRecordTypeInfosByName().get('Record Type A').getRecordTypeId();
        Id recordType2Id = Schema.SObjectType.FObjectOne__c.getRecordTypeInfosByName().get('Record Type B').getRecordTypeId();
        List<String> arguments = new List<String>{
            recordType1Id, recordType2Id
        };
        Boolean actualResult = ForceeaUtilityTest.isValidDistribution('RecordTypeId', arguments, records);
        System.assertEquals(expectedResult, actualResult, 'random list - errors found');
    }

    @IsTest
    private static void randomList_invalidRecordType_expectFailure() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('RecordTypeId', 'random type(list) value(RecordTypeX)');
        obj.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        String expectedResult = 'Invalid record type [RecordTypeX] for definition [random type(list) value(RecordTypeX)]';
        String actualResult = obj.getErrors().get('RecordTypeId').get(0);
        System.assertEquals(expectedResult, actualResult, 'random list - errors found');
    }

    @IsTest
    private static void randomLookupForceea_valid_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c', 500);
        obj.setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) source(Forceea)');
        obj.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Set<Id> refObjectIdsSet =
            (new Map<Id, FObjectTwo__c>([SELECT Id FROM FObjectTwo__c LIMIT 1000])).keySet();
        for (FObjectOne__c objRecord : records) {
            if (!refObjectIdsSet.contains(objRecord.TestLookup__c)) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random lookup forceea - errors found');
    }

    @IsTest
    private static void randomLookupForceea_isActiveUser_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject('FObjectFour__c', 10);
        obj.setDefinition('TestLookupUser__c', 'random lookup(User) source(forceea)');
        obj.insertRecords(true);
        List<User> users = obj.getInsertedRecords();
        Test.stopTest();

        Integer errors = 0;
        Set<Id> recordIdsSet = (new Map<Id, User>(users)).keySet();
        List<FObjectFour__c> records = [
            SELECT TestLookupUser__r.IsActive
            FROM FObjectFour__c
            WHERE Id IN :recordIdsSet
            LIMIT 100
        ];
        for (FObjectFour__c objRecord : records) {
            if (objRecord.TestLookupUser__r.IsActive == false) {
                errors += 1;
                break;
            }
        }
        if (!FObject.processIsValid()) {
            errors += 2;
        }
        System.assertEquals(0, errors, 'random lookup forceea - errors found');
    }

    @IsTest
    private static void randomLookupSalesforce_noRecords_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) source(Salesforce)');
        obj.insertRecords(false);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c objRecord : records) {
            if (String.isNotBlank(objRecord.TestLookup__c)) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random lookup salesforce - errors found');
    }

    @IsTest
    private static void randomLookupSalesforce_oneRecord_expectSuccess() {
        Test.startTest();
        FObject obj1 = new FObject('FObjectTwo__c', 1);
        obj1.insertRecords(true);
        List<FObjectTwo__c> records1 = (List<FObjectTwo__c>) obj1.getRecords();

        FObject obj2 = new FObject('FObjectOne__c');
        obj2.setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) source(Salesforce)');
        obj2.insertRecords(true);
        List<FObjectOne__c> records2 = (List<FObjectOne__c>) obj2.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c objRecord : records2) {
            if (objRecord.TestLookup__c != records1[0].Id) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random lookup salesforce - errors found');
    }

    @IsTest
    private static void randomLookupSalesforce_manyRecords_expectSuccess() {
        Test.startTest();
        FObject obj1 = new FObject('FObjectTwo__c', 20);
        obj1.insertRecords(true);

        FObject obj2 = new FObject('FObjectOne__c');
        obj2.setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) source(Salesforce)');
        obj2.insertRecords(true);
        List<FObjectOne__c> records2 = (List<FObjectOne__c>) obj2.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c objRecord : records2) {
            if (String.isBlank(objRecord.TestLookup__c)) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random lookup salesforce - errors found');
    }

    @IsTest
    private static void randomLookupSalesforce_isActiveUser_expectSuccess() {
        Test.startTest();
        FObject obj1 = new FObject('User', 10);
        obj1.setDefinition('IsActive', 'random type(boolean)');
        obj1.insertRecords(true);

        FObject obj2 = new FObject('FObjectFour__c');
        obj2.setDefinition('TestLookupUser__c', 'random lookup(User) source(salesforce)');
        obj2.insertRecords(true);
        Test.stopTest();

        Integer errors = 0;
        for (FObjectFour__c objRecord : [SELECT TestLookupUser__r.IsActive FROM FObjectFour__c LIMIT 1000]) {
            if (objRecord.TestLookupUser__r.IsActive == false) {
                errors += 1;
                break;
            }
        }
        if (!FObject.processIsValid()) {
            errors += 2;
        }
        System.assertEquals(0, errors, 'random lookup salesforce - errors found');
    }

    @IsTest
    private static void randomLookup_invalidObject_expectFailure() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('TestLookup__c', 'random lookup(InvalidObject) source(Forceea)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        String expectedResult = 'Invalid lookup SObject [InvalidObject] in definition ' +
            '[random lookup(InvalidObject) source(Forceea)]';
        String actualResult = obj.getErrors().get('TestLookup__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'random lookup - errors found');
    }

    @IsTest
    private static void randomLookup_nullObject_expectFailure() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('TestLookup__c', 'random lookup() source(Forceea)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        String expectedResult = 'Invalid syntax in definition [random lookup() source(Forceea)] of field [TestLookup__c]';
        String actualResult = obj.getErrors().get('TestLookup__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'random lookup - errors found');
    }

    @IsTest
    private static void randomLookup_invalidSource_expectFailure() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) source(ForceeaX)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        String expectedResult = 'Invalid source [ForceeaX] in definition [random lookup(FObjectTwo__c) source(ForceeaX)]';
        String actualResult = obj.getErrors().get('TestLookup__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'random lookup - errors found');
    }

    @IsTest
    private static void randomLookup_nullSource_expectFailure() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) source()');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        String expectedResult = 'Invalid syntax in definition [random lookup(FObjectTwo__c) source()] of field [TestLookup__c]';
        String actualResult = obj.getErrors().get('TestLookup__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'random lookup - errors found');
    }

    @IsTest
    private static void randomLookupGroupForceea_insertedGroupRecords_expectSuccess() {
        Test.startTest();
        // insert FObjectTwo__c records for group B
        FObject objB1 = new FObject('FObjectTwo__c', 5);
        objB1.insertRecords(true, 'B');
        List<FObjectTwo__c> recordsB1 = (List<FObjectTwo__c>) objB1.getRecords();
        Set<Id> recordIdsSetB1 = (new Map<Id, FObjectTwo__c>(recordsB1)).keySet();
        // insert FObjectTwo__c records without group
        FObject objB2 = new FObject('FObjectTwo__c', 5);
        objB2.insertRecords(true);
        List<FObjectTwo__c> recordsB2 = (List<FObjectTwo__c>) objB2.getRecords();
        Set<Id> recordIdsSetB2 = (new Map<Id, FObjectTwo__c>(recordsB2)).keySet();
        // insert FObjectOne__c records
        FObject objA = new FObject('FObjectOne__c', 300);
        objA.setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) source(Forceea)');
        objA.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) objA.getRecords();
        Test.stopTest();

        Set<Id> recordIdsSet = (new Map<Id, SObject>(FObject.getInsertedRecords('FObjectTwo__c'))).keySet();
        Integer errors = 0;
        for (FObjectOne__c objRecord : records) {
            if (!recordIdsSet.contains(objRecord.TestLookup__c)) {
                errors = 1;
                break;
            }
        }
        if (!ForceeaUtilityTest.isValidDistribution('TestLookup__c', new List<Id>(recordIdsSet), records)) {
            errors += 2;
        }
        if (!FObject.processIsValid()) {
            errors += 4;
        }
        System.assertEquals(0, errors, 'random lookup forceea - errors found');
    }

    @IsTest
    private static void randomLookupGroupForceea_insertTwoGroupsValidGroupName_expectSuccess() {
        Test.startTest();
        // insert FObjectTwo__c records for group B1
        FObject objB1 = new FObject('FObjectTwo__c', 20);
        objB1.insertRecords(true, 'B1');
        List<FObjectTwo__c> records1 = (List<FObjectTwo__c>) objB1.getRecords();
        Set<Id> recordIdsSet = (new Map<Id, FObjectTwo__c>(records1)).keySet();
        // insert FObjectTwo__c records for group B2
        FObject objB2 = new FObject('FObjectTwo__c', 30);
        objB2.insertRecords(true, 'B2');
        // insert FObjectTwo__c records without for group
        FObject objB3 = new FObject('FObjectTwo__c', 40);
        objB3.insertRecords(true);
        // insert FObjectOne__c records
        FObject objA = new FObject('FObjectOne__c');
        objA.setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) group(B1) source(Forceea)');
        objA.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) objA.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c objRecord : records) {
            if (!recordIdsSet.contains(objRecord.TestLookup__c)) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'sddlRandomLookupGroup - errors found');
    }

    @IsTest
    private static void randomLookupGroupForceea_blankGroupName_expectFailure() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) group() source(Forceea)');
        obj.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        String expectedResult = 'Invalid syntax in definition [random lookup(FObjectTwo__c) group() ' +
            'source(Forceea)] of field [TestLookup__c]';
        String actualResult = obj.getErrors().get('TestLookup__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'sddlRandomLookupGroup - errors found');
    }

    @IsTest
    private static void randomLookupGroupForceea_groupNotExists_expectSuccess() {
        Test.startTest();
        // insert FObjectTwo__c records
        FObject objB = new FObject('FObjectTwo__c', 20);
        objB.insertRecords(true, 'GroupB');
        // insert FObjectOne__c records
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) group(One) source(Forceea)');
        obj.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        List<FObjectTwo__c> lookupRecords1 = (List<FObjectTwo__c>) FObject.getInsertedRecords('FObjectTwo__c');
        Set<Id> recordIdsSet = (new Map<Id, FObjectTwo__c>(lookupRecords1)).keySet();
        List<FObjectTwo__c> lookupRecords2 = (List<FObjectTwo__c>) FObject.getInsertedGroupRecords('FObjectTwo__c', 'One');

        Integer errors = 0;
        for (FObjectOne__c objRecord : records) {
            if (!recordIdsSet.contains(objRecord.TestLookup__c)) {
                errors = 1;
                break;
            }
        }
        if (lookupRecords1.hashCode() == lookupRecords2.hashCode()) {
            errors += 2;
        }
        if (!FObject.processIsValid()) {
            errors += 4;
        }
        System.assertEquals(0, errors, 'sddlRandomLookupGroup - errors found');
    }

    @IsTest
    private static void randomLookupValueForceea_lookupRecordsExist_expectSuccess() {
        // Tests the creation of records with a lookup definition
        // when the lookup object has previously been created by Forceea
        Test.startTest();
        FObject obj1 = new FObject(FObjectTwo__c.SObjectType, 10);
        obj1.setDefinition('TestPicklistA__c', 'random type(picklist)');
        obj1.insertRecords(true);

        FObject obj2 = new FObject(FObjectOne__c.SObjectType, 10);
        obj2.setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) field(TestPicklistA__c) value(A1) source(Forceea)');
        obj2.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj2.getRecords();
        Test.stopTest();

        // get the set of FObjectOne__c.TestLookup__c values
        Set<Id> lookupFieldIdsSet = new Set<Id>();
        for (FObjectOne__c objRecord : records) {
            lookupFieldIdsSet.add(objRecord.TestLookup__c);
        }

        // get the set of FObjectTwo__c IDs
        List<FObjectTwo__c> lookupObjectRecords = new List<FObjectTwo__c>([
            SELECT Id, TestPicklistA__c
            FROM FObjectTwo__c
            WHERE Id IN :lookupFieldIdsSet
            LIMIT 1000
        ]);

        Integer errors = 0;
        for (FObjectTwo__c objRecord : lookupObjectRecords) {
            if (objRecord.TestPicklistA__c != 'a1') {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random lookup forceea - errors found');
    }

    @IsTest
    private static void randomLookupValueForceea_lookupRecordsDontExist_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) field(TestpicklistA__c) value(a1) source(Forceea)');
        obj.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        // get the set of FObjectOne__c.TestLookup__c values
        Set<Id> lookupFieldIdsSet = new Set<Id>();
        for (FObjectOne__c objRecord : records) {
            lookupFieldIdsSet.add(objRecord.TestLookup__c);
        }

        // get the set of FObjectTwo__c IDs
        List<FObjectTwo__c> lookupObjectRecords = new List<FObjectTwo__c>([
            SELECT Id, TestPicklistA__c
            FROM FObjectTwo__c
            WHERE Id IN :lookupFieldIdsSet
            LIMIT 1000
        ]);

        Integer errors = 0;
        for (FObjectTwo__c objRecord : lookupObjectRecords) {
            if (objRecord.TestPicklistA__c != 'a1') {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random lookup forceea - errors found');
    }

    @IsTest
    private static void randomLookupValueForceea_insertedGroupRecords_expectSuccess() {
        Test.startTest();
        // insert FObjectTwo__c records for group B
        FObject objB1 = new FObject('FObjectTwo__c', 5);
        objB1.setDefinition('TestPicklistA__c', 'static value(a0)');
        objB1.insertRecords(true, 'B');
        // insert FObjectTwo__c records without group
        FObject objB2 = new FObject('FObjectTwo__c', 5);
        objB2.setDefinition('TestPicklistA__c', 'random type(list) value(a1, a2, a3)');
        objB2.insertRecords(true);
        // insert FObjectOne__c records
        FObject objA = new FObject('FObjectOne__c');
        objA.setDefinition('TestLookup__c',
            'random lookup(FObjectTwo__c) field(TestPicklistA__c) value(a0) source(Forceea)');
        objA.insertRecords(true);
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c objRecord : [SELECT TestLookup__r.TestPicklistA__c FROM FObjectOne__c LIMIT 1000]) {
            if (objRecord.TestLookup__r.TestPicklistA__c != 'a0') {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random lookup forceea - errors found');
    }

    @IsTest
    private static void randomLookupValueSalesforce_lookupRecordsExist_expectSuccess() {
        Test.startTest();
        FObject objB = new FObject('FObjectTwo__c', 100);
        objB.setDefinition('testPicklistB__c', 'random type(picklist)');
        objB.insertRecords(true);

        FObject objA = new FObject(FObjectOne__c.SObjectType, 10);
        objA.setDefinition('TestLookup__c',
            'random lookup(FObjectTwo__c) field(TestPicklistB__c) value(b3) source(Salesforce)');
        objA.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) objA.getInsertedRecords();
        Test.stopTest();

        Integer errors = 0;
        Set<Id> refObjectIdsSet = (new Map<Id, FObjectTwo__c>(
        [SELECT Id FROM FObjectTwo__c WHERE TestPicklistB__c = 'b3' LIMIT 1000])).keySet();

        for (FObjectOne__c objRecord : records) {
            if (!refObjectIdsSet.contains(objRecord.TestLookup__c)) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random lookup salesforce - errors found');
    }

    @IsTest
    private static void randomLookupValueSalesforce_lookupRecordsDontExist_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('TestLookup__c',
            'random lookup(FObjectTwo__c) field(TestPicklistB__c) value(b3) source(Salesforce)');
        obj.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c objRecord : records) {
            if (String.isNotBlank(objRecord.TestLookup__c)) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random lookup salesforce - errors found');
    }

    @IsTest
    private static void randomLookupValue_invalidField_expectFailure() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition(
            'TestLookup__c', 'random lookup(FObjectTwo__c) field(FieldX) value(Hot) source(Forceea)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        String expectedResult = 'Invalid lookup field [FieldX] in definition ' +
            '[random lookup(FObjectTwo__c) field(FieldX) value(Hot) source(Forceea)]';
        String actualResult = obj.getErrors().get('TestLookup__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'random lookup - errors found');
    }

    @IsTest
    private static void randomLookupExceptForceea_validPicklistArguments_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) ' +
            'field(TestPicklistDRequired__c) except(d0,d1) source(Forceea)');
        obj.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        // get FObjectOne__c.TestLookup__c IDs
        Set<Id> lookupIdsSet = new Set<Id>();
        for (FObjectOne__c objRecord : records) {
            lookupIdsSet.add(objRecord.TestLookup__c);
        }

        // get FObjectTwo__c IDs
        List<String> exclusions = new List<String>{
            'd0', 'd1'
        };
        Set<Id> lookupObjectIdsSet =
            (new Map<Id, FObjectTwo__c>([
                SELECT Id
                FROM FObjectTwo__c
                WHERE TestPicklistDRequired__c NOT IN :exclusions
                LIMIT 1000
            ])).keySet();

        Integer errors = 0;
        for (Id lookupId : lookupIdsSet) {
            if (!lookupObjectIdsSet.contains(lookupId)) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random lookup except - errors found');
    }

    @IsTest
    private static void randomLookupExceptForceea_validAndInvalidPicklistArguments_expectSuccess() {
        Test.startTest();
        // create FObjectOne records
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) ' +
            'field(TestPicklistDRequired__c) except(d0,d1,s1) source(Forceea)');
        obj.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        // get FObjectOne__c.TestLookup__c IDs
        Set<Id> lookupIdsSet = new Set<Id>();
        for (FObjectOne__c objRecord : records) {
            lookupIdsSet.add(objRecord.TestLookup__c);
        }
        // get FObjectTwo__c IDs
        List<String> exclusions = new List<String>{
            'd0', 'd1'
        };
        Set<Id> lookupObjectIdsSet =
            (new Map<Id, FObjectTwo__c>([
                SELECT Id
                FROM FObjectTwo__c
                WHERE TestPicklistDRequired__c NOT IN :exclusions
                LIMIT 1000
            ])).keySet();

        Integer errors = 0;
        for (Id lookupId : lookupIdsSet) {
            if (!lookupObjectIdsSet.contains(lookupId)) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random lookup except - errors found');
    }

    @IsTest
    private static void randomLookupExceptForceea_invalidPicklistArguments_expectSuccess() {
        Test.startTest();
        // create FObjectOne records
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) ' +
            'field(TestPicklistDRequired__c) except(s1,s2) source(Forceea)');
        obj.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        // get FObjectOne__c.TestLookup__c IDs
        Set<Id> lookupIdsSet = new Set<Id>();
        for (FObjectOne__c objRecord : records) {
            lookupIdsSet.add(objRecord.TestLookup__c);
        }
        // get FObjectTwo__c IDs
        Set<Id> lookupObjectIdsSet = (new Map<Id, FObjectTwo__c>([SELECT Id FROM FObjectTwo__c LIMIT 1000])).keySet();
        Integer errors = 0;
        for (Id lookupId : lookupIdsSet) {
            if (!lookupObjectIdsSet.contains(lookupId)) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random lookup except - errors found');
    }

    @IsTest
    private static void randomLookupExceptSalesforce_validPicklistArguments_expectSuccess() {
        Test.startTest();
        // create FObjectTwo records
        FObject obj1 = new FObject(FObjectTwo__c.SObjectType, 10);
        obj1.setDefinition('TestPicklistA__c', 'random type(list) value(a2,a3)');
        obj1.insertRecords(true);
        List<FObjectTwo__c> records1 = (List<FObjectTwo__c>) obj1.getRecords();
        // create FObjectOne records
        FObject obj2 = new FObject(FObjectOne__c.SObjectType, 10);
        obj2.setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) ' +
            'field(TestPicklistA__c) except(a1,a2) source(Salesforce)');
        obj2.insertRecords(true);
        List<FObjectOne__c> records2 = (List<FObjectOne__c>) obj2.getRecords();
        Test.stopTest();

        // get FObjectOne__c.TestLookup__c IDs
        Set<Id> lookupIdsSet = new Set<Id>();
        for (FObjectOne__c objRecord : records2) {
            lookupIdsSet.add(objRecord.TestLookup__c);
        }
        // get FObjectTwo__c IDs
        List<String> exclusions = new List<String>{
            'a1', 'a2'
        };
        Set<Id> lookupObjectIdsSet =
            (new Map<Id, FObjectTwo__c>([
                SELECT Id
                FROM FObjectTwo__c
                WHERE TestPicklistA__c NOT IN :exclusions
                LIMIT 1000
            ])).keySet();

        Integer errors = 0;
        for (Id lookupId : lookupIdsSet) {
            if (!lookupObjectIdsSet.contains(lookupId)) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random lookup except - errors found');
    }

    @IsTest
    private static void randomLookupExceptSalesforce_validAndInvalidPicklistArguments_expectSuccess() {
        Test.startTest();
        // create FObjectTwo records
        FObject obj1 = new FObject(FObjectTwo__c.SObjectType, 10);
        obj1.setDefinition('TestPicklistA__c', 'random type(list) value(a2,a3,s1)');
        obj1.insertRecords(true);
        List<FObjectTwo__c> records1 = (List<FObjectTwo__c>) obj1.getRecords();
        // create FObjectOne records
        FObject obj2 = new FObject(FObjectOne__c.SObjectType, 10);
        obj2.setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) ' +
            'field(TestPicklistA__c) except(a1,a2) source(Salesforce)');
        obj2.insertRecords(true);
        List<FObjectOne__c> records2 = (List<FObjectOne__c>) obj2.getRecords();
        Test.stopTest();

        // get FObjectOne__c.TestLookup__c IDs
        Set<Id> lookupIdsSet = new Set<Id>();
        for (FObjectOne__c objRecord : records2) {
            lookupIdsSet.add(objRecord.TestLookup__c);
        }
        // get FObjectTwo__c IDs
        List<String> exclusions = new List<String>{
            'a1', 'a2'
        };
        Set<Id> lookupObjectIdsSet =
            (new Map<Id, FObjectTwo__c>([
                SELECT Id
                FROM FObjectTwo__c
                WHERE TestPicklistA__c NOT IN :exclusions
                LIMIT 1000
            ])).keySet();

        Integer errors = 0;
        for (Id lookupId : lookupIdsSet) {
            if (!lookupObjectIdsSet.contains(lookupId)) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random lookup except - errors found');
    }

    @IsTest
    private static void randomLookupExceptSalesforce_createLookupRecordsWithBlankPicklistValues_expectSuccess() {
        Test.startTest();
        // create FObjectTwo records
        FObject obj1 = new FObject(FObjectTwo__c.SObjectType, 10);
        obj1.setDefinition('TestPicklistA__c', 'random type(list) value(s1,s2)');
        obj1.insertRecords(true);
        List<FObjectTwo__c> records1 = (List<FObjectTwo__c>) obj1.getRecords();
        // create FObjectOne records
        FObject obj2 = new FObject(FObjectOne__c.SObjectType, 10);
        obj2.setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) ' +
            'field(TestPicklistA__c) except(a1,a2) source(Salesforce)');
        obj2.insertRecords(true);
        List<FObjectOne__c> records2 = (List<FObjectOne__c>) obj2.getRecords();
        Test.stopTest();

        // get FObjectOne__c.TestLookup__c IDs
        Set<Id> lookupIdsSet = new Set<Id>();
        for (FObjectOne__c objRecord : records2) {
            lookupIdsSet.add(objRecord.TestLookup__c);
        }
        // get FObjectTwo__c IDs
        Set<Id> lookupObjectIdsSet = (new Map<Id, FObjectTwo__c>([SELECT Id FROM FObjectTwo__c LIMIT 1000])).keySet();

        Integer errors = 0;
        for (Id lookupId : lookupIdsSet) {
            if (String.isNotBlank(lookupId)) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random lookup except - errors found');
    }

    @IsTest
    private static void randomLookupExceptGroup_insertedGroupRecords_expectSuccess() {
        Test.startTest();
        // insert FObjectTwo__c records for group B
        FObject objB = new FObject('FObjectTwo__c', 100);
        objB.setDefinition('TestPicklistA__c', 'random type(picklist)');
        objB.insertRecords(true, 'B');
        Set<Id> recordIdsSet = (new Map<Id, SObject>(objB.getRecords())).keySet();

        // insert FObjectOne__c records
        FObject objA = new FObject(FObjectOne__c.SObjectType, 10);
        objA.setDefinition('TestLookup__c',
            'random lookup(FObjectTwo__c) field(TestPicklistA__c) except(a0, a1, a2) group(b) source(Forceea)');
        objA.insertRecords(true);
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c objRecord : [SELECT TestLookup__r.TestPicklistA__c FROM FObjectOne__c LIMIT 1000]) {
            if (objRecord.TestLookup__r.TestPicklistA__c != 'a3') {
                errors += 1;
                break;
            }
        }
        if (!FObject.processIsValid()) {
            errors += 2;
        }
        System.assertEquals(0, errors, 'random lookup except group - errors found');
    }

    @IsTest
    private static void randomLookupExceptGroup_blankGroupName_expectFailure() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestLookup__c',
            'random lookup(FObjectTwo__c) field(TestPicklistA__c) except(a1, a2, a3) group() source(Forceea)');
        obj.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        String expectedResult = 'Invalid syntax in definition [random lookup(FObjectTwo__c) field(TestPicklistA__c) ' +
            'except(a1, a2, a3) group() source(Forceea)] of field [TestLookup__c]';
        String actualResult = obj.getErrors().get('TestLookup__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'random lookup except group - errors found');
    }

    @IsTest
    private static void randomLookupExceptGroup_groupNotExists_expectSuccess() {
        Test.startTest();
        // insert FObjectTwo__c records for group B
        FObject objB1 = new FObject('FObjectTwo__c', 100);
        objB1.setDefinition('TestPicklistA__c', 'static value(a0)');
        objB1.insertRecords(true, 'B');
        Set<Id> recordIdsSet1 = (new Map<Id, SObject>(objB1.getRecords())).keySet();

        // insert FObjectTwo__c records without group
        FObject objB2 = new FObject('FObjectTwo__c', 100);
        objB2.setDefinition('TestPicklistA__c', 'random type(list) value(a1, a2, a3)');
        objB2.insertRecords(true);
        Set<Id> recordIdsSet2 = (new Map<Id, SObject>(objB2.getRecords())).keySet();

        // insert FObjectOne__c records
        FObject objA = new FObject('FObjectOne__c');
        objA.setDefinition('TestLookup__c',
            'random lookup(FObjectTwo__c) field(TestPicklistA__c) except(a1, a2, a3) group(One) source(Forceea)');
        objA.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) objA.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c objRecord : records) {
            if (recordIdsSet1.contains(objRecord.TestLookup__c) || recordIdsSet2.contains(objRecord.TestLookup__c)) {
                errors += 1;
                break;
            }
        }
        for (FObjectOne__c objRecord : [SELECT TestLookup__r.TestPicklistA__c FROM FObjectOne__c LIMIT 1000]) {
            if (objRecord.TestLookup__r.TestPicklistA__c != 'a0') {
                errors += 2;
                break;
            }
        }
        if (!FObject.processIsValid()) {
            errors += 4;
        }
        System.assertEquals(0, errors, 'random lookup except group - errors found');
    }

    @IsTest
    private static void randomLookupWhere_noLookupRecordsCreatedByForceeaOrUser_expectSuccess() {
        Test.startTest();
        // create FObjectOne records
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        String whereClause = 'TestPicklistDRequired__c = \'d1\' AND TestPicklistEUnrestricted__c != \'s1\'';
        obj.setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) where(' + whereClause + ') source(salesforce)');
        obj.insertRecords(true);
        Test.stopTest();

        Integer errors = 0;
        List<FObjectTwo__c> lookupRecords = [SELECT Id FROM FObjectTwo__c LIMIT 1000];
        if (!lookupRecords.isEmpty()) {
            errors += 1;
        }
        for (SObject objRecord : obj.getRecords()) {
            if (String.isNotBlank((String) objRecord.get('TestLookup__c'))) {
                errors += 2;
                break;
            }
        }
        if (!obj.getErrors().isEmpty()) {
            errors += 4;
        }
        if (!FObject.processIsValid()) {
            errors += 8;
        }
        System.assertEquals(0, errors, 'random lookup where - errors found');
    }

    @IsTest
    private static void randomLookupWhere_lookupRecordsAlreadyCreatedByForceea_expectSuccess() {
        Test.startTest();
        // create FObjectTwo records
        FObject obj1 = new FObject(FObjectTwo__c.SObjectType, 10);
        obj1.setDefinition('TestPicklistDRequired__c', 'random type(list) value(d1,d2)');
        obj1.setDefinition('TestPicklistEUnrestricted__c', 'random type(list) value(s1,s2,s3)');
        obj1.insertRecords(true);
        // create FObjectOne records
        FObject obj2 = new FObject(FObjectOne__c.SObjectType, 10);
        String whereClause = 'TestPicklistDRequired__c = \'d1\' AND TestPicklistEUnrestricted__c != \'s1\'';
        obj2.setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) where(' + whereClause + ') source(salesforce)');
        obj2.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj2.getRecords();
        Test.stopTest();
        // get FObjectOne.TestLookup__c IDs
        List<Id> lookupIds = new List<Id>();
        for (FObjectOne__c objRecord : records) {
            lookupIds.add(objRecord.TestLookup__c);
        }
        // get FObjectTwo inserted records
        List<FObjectTwo__c> lookupRecords = [
            SELECT TestPicklistDRequired__c, TestPicklistEUnrestricted__c
            FROM FObjectTwo__c
            WHERE Id IN :lookupIds
            LIMIT 1000
        ];

        Integer errors = 0;
        if (!obj2.getErrors().isEmpty()) {
            errors++;
        }
        for (FObjectTwo__c objRecord : lookupRecords) {
            if (objRecord.TestPicklistDRequired__c != 'd1' && objRecord.TestPicklistEUnrestricted__c == 's1') {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random lookup where - errors found');
    }

    @IsTest
    private static void randomLookupWhere_lookupRecordsAlreadyCreatedByUser_expectSuccess() {
        Test.startTest();
        // create FObjectTwo records
        List<FObjectTwo__c> newLookupRecords = new List<FObjectTwo__c>();
        List<String> values1 = new List<String>{
            'd1', 'd2'
        };
        List<String> values2 = new List<String>{
            's1', 's2', 's3'
        };
        Integer rnd1 = 0;
        Integer rnd2 = 0;
        for (Integer counter = 1; counter <= 100; counter++) {
            FObjectTwo__c obj = new FObjectTwo__c();
            rnd1 = (Math.random() * values1.size()).intValue();
            obj.TestPicklistDRequired__c = values1[rnd1];
            rnd2 = (Math.random() * values2.size()).intValue();
            obj.TestPicklistEUnrestricted__c = values2[rnd2];
            newLookupRecords.add(obj);
        }
        insert newLookupRecords;
        // create FObjectOne records
        FObject obj2 = new FObject(FObjectOne__c.SObjectType, 10);
        String whereClause = 'TestPicklistDRequired__c = \'d1\' AND TestPicklistEUnrestricted__c != \'s1\'';
        obj2.setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) where(' + whereClause + ') source(salesforce)');
        obj2.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj2.getRecords();
        Test.stopTest();
        // get FObjectOne.TestLookup__c IDs
        List<Id> lookupIds = new List<Id>();
        for (FObjectOne__c objRecord : records) {
            lookupIds.add(objRecord.TestLookup__c);
        }
        // get FObjectTwo inserted records
        List<FObjectTwo__c> lookupRecords = [
            SELECT TestPicklistDRequired__c, TestPicklistEUnrestricted__c
            FROM FObjectTwo__c
            WHERE Id IN :lookupIds
            LIMIT 1000
        ];

        Integer errors = 0;
        for (FObjectTwo__c objRecord : lookupRecords) {
            if (objRecord.TestPicklistDRequired__c != 'd1' || objRecord.TestPicklistEUnrestricted__c == 's1') {
                errors++;
            }
        }
        if (!obj2.getErrors().isEmpty()) {
            errors++;
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random lookup where - errors found');
    }

    @IsTest
    private static void randomLookupWhere_invalidWhereClause_expectFailure() {
        Test.startTest();
        // create FObjectTwo records
        FObject obj1 = new FObject(FObjectTwo__c.SObjectType, 10);
        obj1.setDefinition('TestPicklistDRequired__c', 'random type(list) value(d1,d2)');
        obj1.setDefinition('TestPicklistEUnrestricted__c', 'random type(list) value(s1,s2,s3)');
        obj1.insertRecords(true);
        // create FObjectOne records
        FObject obj2 = new FObject(FObjectOne__c.SObjectType, 10);
        String whereClause = 'TestPicklistDRequired__c = \'d1\' AND wrongField != \'s1\'';
        obj2.setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) where(' +
            whereClause + ') source(salesforce)');
        obj2.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Found errors selecting records from the lookup SObject [FObjectTwo__c]' +
            ' of [FObjectOne__c]';
        String actualResult = obj2.getErrors().get('TestLookup__c').get(0);
        Boolean result = actualResult.startsWith(expectedResult);
        System.assert(result, 'random lookup where - errors found');
    }

    @IsTest
    private static void randomNumber_integerArgument_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject('Account'); // should use the Account object
        obj.setDefinition('NumberOfEmployees', 'random type(number) from(1) to(100) scale(0)');
        List<Account> records = (List<Account>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (Account objRecord : records) {
            if (objRecord.NumberOfEmployees < 1 || objRecord.NumberOfEmployees > 100) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random number - errors found');
    }

    @IsTest
    private static void randomNumber_decimalArgument_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('TestDecimal__c', 'random type(number) from(1) to(50.12) scale(2)');
        obj.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c objRecord : records) {
            if (objRecord.TestDecimal__c < 1 || objRecord.TestDecimal__c > 50.12) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random number - errors found');
    }

    @IsTest
    private static void randomNumber_fromEqualsTo_expectFailure() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('TestDecimal__c', 'random type(number) from(10) to(10) scale(2)');
        obj.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        String expectedResult = 'The [from] number is greater than or equal to the [to] number ' +
            'in definition [random type(number) from(10) to(10) scale(2)]';
        String actualResult = obj.getErrors().get('TestDecimal__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'random number - errors found');
    }

    @IsTest
    private static void randomNumber_fromGreaterThanTo_expectFailure() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestDecimal__c', 'random type(number) from(12) to(10) scale(2)');
        obj.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        String expectedResult = 'The [from] number is greater than or equal to the [to] number ' +
            'in definition [random type(number) from(12) to(10) scale(2)]';
        String actualResult = obj.getErrors().get('TestDecimal__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'random number - errors found');
    }

    @IsTest
    private static void randomPhone_valid_expectSuccess() {
        String formatString = '(30) 210 dd-11-1DD';

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c', 30)
            .setDefinition('TestPhone__c', 'random type(phone) format("' + formatString + '")');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer val = 0;
        Integer errors = 0;
        String str = '';
        List<String> formatChars = formatString.split('');

        for (FObjectOne__c objRecord : records) {
            String phoneNumber = objRecord.TestPhone__c;

            for (Integer counter = 0; counter < phoneNumber.length(); counter++) {
                val = phoneNumber.charAt(counter) - 48;
                str = formatChars.get(counter);

                if (str.charAt(0) == 100) { // d
                    if (val < 1 || val > 9) {
                        errors++;
                    }
                } else if (str.charAt(0) == 68) { // D
                    if (val < 0 || val > 9) {
                        errors++;
                    }
                }
            }
        }

        System.assertEquals(0, errors, 'random phone number - errors found');
    }

    @IsTest
    private static void randomPicklist_independentPicklistField_expectSuccess() {
        List<String> arguments = new List<String>{
            'a0', 'a1', 'a2', 'a3'
        };

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestPicklistA__c', 'random type(picklist)');
        obj.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Boolean expectedResult = true;
        Boolean actualResult = ForceeaUtilityTest.isValidDistribution('TestPicklistA__c', arguments, records);
        System.assertEquals(expectedResult, actualResult, 'random picklist - errors found');
    }

    @IsTest
    private static void randomPicklist_dependentPicklistField_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestPicklistC__c, 'random type(picklist)');
        obj.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        // set mapping
        Set<String> picklistA0Mapping = new Set<String>{
            null
        };
        Set<String> picklistA1Mapping = new Set<String>{
            'b1'
        };
        Set<String> picklistA2Mapping = new Set<String>{
            'b1', 'b2'
        };
        Set<String> picklistA3Mapping = new Set<String>{
            'b1', 'b2', 'b3'
        };
        Set<String> picklistB0Mapping = new Set<String>{
            ''
        };
        Set<String> picklistB1Mapping = new Set<String>{
            'c1'
        };
        Set<String> picklistB2Mapping = new Set<String>{
            'c1', 'c2'
        };
        Set<String> picklistB3Mapping = new Set<String>{
            'c1', 'c2', 'c3'
        };

        // get created field values
        List<String> picklistAValues = new List<String>();
        List<String> picklistBValues = new List<String>();
        List<String> picklistCValues = new List<String>();
        for (FObjectOne__c objRecord : records) {
            picklistAValues.add(objRecord.TestPicklistA__c);
            picklistBValues.add(objRecord.TestPicklistB__c);
            picklistCValues.add(objRecord.TestPicklistC__c);
        }

        Integer errors = 0;
        for (Integer counter = 0; counter < records.size(); counter++) {
            if (picklistAValues[counter] == 'a0' && !picklistA0Mapping.contains(picklistBValues[counter])) {
                errors++;
            } else if (picklistAValues[counter] == 'a1' && !picklistA1Mapping.contains(picklistBValues[counter])) {
                errors++;
            } else if (picklistAValues[counter] == 'a2' && !picklistA2Mapping.contains(picklistBValues[counter])) {
                errors++;
            } else if (picklistAValues[counter] == 'a3' && !picklistA3Mapping.contains(picklistBValues[counter])) {
                errors++;
            }

            if (picklistBValues[counter] == 'b0' && !picklistB0Mapping.contains(picklistCValues[counter])) {
                errors++;
            } else if (picklistBValues[counter] == 'b1' && !picklistB1Mapping.contains(picklistCValues[counter])) {
                errors++;
            } else if (picklistBValues[counter] == 'b2' && !picklistB2Mapping.contains(picklistCValues[counter])) {
                errors++;
            } else if (picklistBValues[counter] == 'b3' && !picklistB3Mapping.contains(picklistCValues[counter])) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random picklist - errors found');
    }

    @IsTest
    private static void randomPicklist_controllingFieldAfterDependentField_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('TestPicklistB__c', 'random type(picklist)');
        obj.setDefinition('TestPicklistA__c', 'random type(picklist)');
        obj.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        // set mapping
        Set<String> picklistA0Mapping = new Set<String>{
            null
        };
        Set<String> picklistA1Mapping = new Set<String>{
            'b1'
        };
        Set<String> picklistA2Mapping = new Set<String>{
            'b1', 'b2'
        };
        Set<String> picklistA3Mapping = new Set<String>{
            'b1', 'b2', 'b3'
        };

        // get created field values
        List<String> picklistAValues = new List<String>();
        List<String> picklistBValues = new List<String>();
        for (FObjectOne__c objRecord : records) {
            picklistAValues.add(objRecord.TestPicklistA__c);
            picklistBValues.add(objRecord.TestPicklistB__c);
        }

        Integer errors = 0;
        for (Integer counter = 0; counter < records.size(); counter++) {
            if (picklistAValues[counter] == 'a0' && !picklistA0Mapping.contains(picklistBValues[counter])) {
                errors++;
            } else if (picklistAValues[counter] == 'a1' && !picklistA1Mapping.contains(picklistBValues[counter])) {
                errors++;
            } else if (picklistAValues[counter] == 'a2' && !picklistA2Mapping.contains(picklistBValues[counter])) {
                errors++;
            } else if (picklistAValues[counter] == 'a3' && !picklistA3Mapping.contains(picklistBValues[counter])) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random picklist - errors found');
    }

    @IsTest
    private static void randomPicklist_controllingFieldIsCheckbox_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('TestCheckbox__c', 'static value(true)');
        obj.setDefinition('TestPicklistD__c', 'random type(picklist)');
        obj.insertRecords(false);
        Test.stopTest();

        Boolean expectedResult = false;
        Boolean actualResult = obj.getErrors().isEmpty();
        System.assertEquals(expectedResult, actualResult, 'random picklist - errors found');
    }

    @IsTest
    private static void randomPicklist_definitionsOfDependentPicklists_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('TestPicklistC__c', 'random type(picklist)');
        obj.setDefinition('RecordTypeId', 'static value(RecordTypeA)');
        obj.insertRecords(true);
        Test.stopTest();

        List<String> picklistADefinitions = obj.getAllDefinitions().get('TestPicklistA__c');
        List<String> picklistBDefinitions = obj.getAllDefinitions().get('TestPicklistB__c');

        Integer errors = 0;
        if (picklistADefinitions[0] != 'random type(picklist)') {
            errors += 1;
        }
        if (picklistBDefinitions[0] != 'random type(picklist)') {
            errors += 2;
        }
        if (!FObject.processIsValid()) {
            errors += 4;
        }
        System.assertEquals(0, errors, 'random picklist - errors found');
    }

    @IsTest
    private static void randomPicklist_oneRecordType_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject('FObjectThree__c');
        obj.setDefinition('RecordTypeId', 'random type(picklist)');
        obj.insertRecords(true);
        List<FObjectThree__c> records = (List<FObjectThree__c>) obj.getRecords();
        Test.stopTest();

        Map<Id, Schema.RecordTypeInfo> recordTypesMap = Schema.SObjectType.FObjectThree__c.getRecordTypeInfosById();
        List<Id> keys = new List<Id>(recordTypesMap.keySet());

        Integer errors = 0;
        for (FObjectThree__c objRecord : records) {
            if (objRecord.RecordTypeId != keys[0]) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random picklist - errors found');
    }

    @IsTest
    private static void randomPicklist_manyRecordTypes_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('RecordTypeId', 'random type(picklist)');
        obj.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Map<Id, Schema.RecordTypeInfo> recordTypesMap = Schema.SObjectType.FObjectOne__c.getRecordTypeInfosById();
        Set<Id> keySet = recordTypesMap.keySet();

        Integer errors = 0;
        for (FObjectOne__c objRecord : records) {
            if (!keySet.contains(objRecord.RecordTypeId)) {
                errors++;
            }
        }

        List<RecordType> recordTypes = [
            SELECT Id
            FROM RecordType
            WHERE SobjectType = 'FObjectOne__c' AND IsActive = TRUE
            LIMIT 1000
        ];
        Set<Id> valuesSet = (new Map<Id, RecordType>(recordTypes)).keySet();
        List<Id> values = new List<Id>(valuesSet);
        if (!ForceeaUtilityTest.isValidDistribution('RecordTypeId', values, records)) {
            errors++;
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random picklist - errors found');
    }

    @IsTest
    private static void randomPicklistExcept_independentPicklistField_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestPicklistA__c', 'random type(picklist) except(a1)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Set<String> picklistValuesSet = new Set<String>{
            'a0', 'a2', 'a3'
        };
        for (Integer counter = 0; counter < records.size(); counter++) {
            if (!picklistValuesSet.contains(records[counter].TestPicklistA__c)) {
                errors++;
            }
        }
        List<String> values = new List<String>(picklistValuesSet);
        if (!ForceeaUtilityTest.isValidDistribution('TestPicklistA__c', values, records)) {
            errors++;
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random picklist except - errors found');
    }

    @IsTest
    private static void randomPicklistExcept_dependentPicklistField_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestPicklistC__c', 'random type(picklist) except(c1)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        // set mapping
        Set<String> picklistA0Mapping = new Set<String>{
            null
        };
        Set<String> picklistA1Mapping = new Set<String>{
            'b1'
        };
        Set<String> picklistA2Mapping = new Set<String>{
            'b1', 'b2'
        };
        Set<String> picklistA3Mapping = new Set<String>{
            'b1', 'b2', 'b3'
        };
        Set<String> picklistB0Mapping = new Set<String>{
            null
        };
        Set<String> picklistB1Mapping = new Set<String>{
            null
        };
        Set<String> picklistB2Mapping = new Set<String>{
            'c2'
        };
        Set<String> picklistB3Mapping = new Set<String>{
            'c2', 'c3'
        };

        // get created field values
        List<String> picklistAValues = new List<String>();
        List<String> picklistBValues = new List<String>();
        List<String> picklistCValues = new List<String>();
        for (FObjectOne__c objRecord : records) {
            picklistAValues.add(objRecord.TestPicklistA__c);
            picklistBValues.add(objRecord.TestPicklistB__c);
            picklistCValues.add(objRecord.TestPicklistC__c);
        }

        Integer errors = 0;
        for (Integer counter = 0; counter < records.size(); counter++) {
            if (picklistAValues[counter] == 'a0' && !picklistA0Mapping.contains(picklistBValues[counter])) {
                errors++;
            } else if (picklistAValues[counter] == 'a1' && !picklistA1Mapping.contains(picklistBValues[counter])) {
                errors++;
            } else if (picklistAValues[counter] == 'a2' && !picklistA2Mapping.contains(picklistBValues[counter])) {
                errors++;
            } else if (picklistAValues[counter] == 'a3' && !picklistA3Mapping.contains(picklistBValues[counter])) {
                errors++;
            }

            if (picklistBValues[counter] == 'b0' && !picklistB0Mapping.contains(picklistCValues[counter])) {
                errors++;
            } else if (picklistBValues[counter] == 'b1' && !picklistB1Mapping.contains(picklistCValues[counter])) {
                errors++;
            } else if (picklistBValues[counter] == 'b2' && !picklistB2Mapping.contains(picklistCValues[counter])) {
                errors++;
            } else if (picklistBValues[counter] == 'b3' && !picklistB3Mapping.contains(picklistCValues[counter])) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random picklist except - error found');
    }

    @IsTest
    private static void randomPicklistExcept_checkDefinitionsOfDependentPicklists_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('RecordTypeId', 'static value(RecordTypeA)');
        obj.setDefinition('TestPicklistC__c', 'random type(picklist) except(c1)');
        Test.stopTest();

        List<String> picklistADefinitions = obj.getAllDefinitions().get('TestPicklistA__c');
        List<String> picklistBDefinitions = obj.getAllDefinitions().get('TestPicklistB__c');

        Integer errors = 0;
        if (picklistADefinitions[0] != 'random type(picklist)') {
            errors += 1;
        }
        if (picklistBDefinitions[0] != 'random type(picklist)') {
            errors += 2;
        }
        if (!FObject.processIsValid()) {
            errors += 4;
        }
        System.assertEquals(0, errors, 'random picklist except - errors found');
    }

    @IsTest
    private static void randomPicklistExcept_noPicklistValues_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestPicklistA__c', 'random type(picklist) except(a0,a1,a2,a3)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Set<String> picklistValuesSet = new Set<String>{
            'a0', 'a1', 'a2', 'a3'
        };
        for (Integer counter = 0; counter < records.size(); counter++) {
            if (picklistValuesSet.contains(records[counter].TestPicklistA__c)) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random picklist except - error found');
    }

    @IsTest
    private static void randomPicklistExcept_onePicklistValue_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestPicklistA__c', 'random type(picklist) except(a0,a2,a3)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Set<String> picklistValuesSet = new Set<String>{
            'a1'
        };
        for (Integer counter = 0; counter < records.size(); counter++) {
            if (!picklistValuesSet.contains(records[counter].TestPicklistA__c)) {
                errors++;
            }
        }
        List<String> values = new List<String>(picklistValuesSet);
        if (!ForceeaUtilityTest.isValidDistribution('TestPicklistA__c', values, records)) {
            errors++;
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random picklist except - error found');
    }

    @IsTest
    private static void randomPicklistExcept_controllingFieldIsCheckbox_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('TestCheckbox__c', 'static value(true)');
        obj.setDefinition('TestpicklistD__c', 'random type(picklist) except(d0, d1)');
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
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random picklist except - errors found');
    }

    @IsTest
    private static void randomPicklistExcept_noRecordType_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('RecordTypeId',
            'random type(picklist) except(RecordTypeA, RecordTypeB, RecordTypeC)');
        List<Database.SaveResult> saveResults = obj.insertRecords(false);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (Database.SaveResult sr : saveResults) {
            if (!sr.isSuccess()) {
                errors++;
            }
        }

        for (FObjectOne__c objRecord : records) {
            if (String.isNotBlank(objRecord.RecordTypeId)) {
                errors++;
            }
        }

        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random picklist except - errors found');
    }

    @IsTest
    private static void randomPicklistExcept_oneRecordType_expectSuccess() {
        Id recordTypeId =
            Schema.SObjectType.FObjectOne__c.getRecordTypeInfosByName().get('Record Type C').getRecordTypeId();

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('RecordTypeId', 'random type(picklist) except(RecordTypeA, RecordTypeB)');
        List<Database.SaveResult> saveResults = obj.insertRecords(false);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (Database.SaveResult sr : saveResults) {
            if (!sr.isSuccess()) {
                errors++;
            }
        }
        for (FObjectOne__c objRecord : records) {
            if (objRecord.RecordTypeId != recordTypeId) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random picklist except - errors found');
    }

    @IsTest
    private static void randomPicklistExcept_manyRecordTypes_expectSuccess() {
        Id recordTypeId1 =
            Schema.SObjectType.FObjectOne__c.getRecordTypeInfosByName().get('Record Type A').getRecordTypeId();
        Id recordTypeId2 =
            Schema.SObjectType.FObjectOne__c.getRecordTypeInfosByName().get('Record Type B').getRecordTypeId();
        List<Id> arguments = new List<String>{
            recordTypeId1, recordTypeId2
        };
        Set<Id> recordTypeIdsSet = new Set<Id>(arguments);

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('RecordTypeId', 'random type(picklist) except(RecordTypeC)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c objRecord : records) {
            if (!recordTypeIdsSet.contains(objRecord.RecordTypeId)) {
                errors++;
            }
        }
        if (!ForceeaUtilityTest.isValidDistribution('RecordTypeId', arguments, records)) {
            errors++;
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random picklist except - errors found');
    }

    @IsTest
    private static void randomString_includeOnlyDigits_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestText__c', 'random type(string) Minlength(5) Maxlength(10) ' +
            'startwith(Lower) include(Digit)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        String result = '';
        Integer errors = 0;
        Integer len = 0;
        for (FObjectOne__c objRecord : records) {
            len = objRecord.TestText__c.length();
            result = objRecord.TestText__c.right(len - 1);
            if (!result.isNumeric()) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random string - errors found');
    }

    @IsTest
    private static void randomString_includeOnlyLowercase_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestText__c', 'random type(string) Minlength(5) Maxlength(10) ' +
            'startwith(Upper) include(Lower)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        String result = '';
        Integer errors = 0;
        Integer len = 0;
        for (FObjectOne__c objRecord : records) {
            len = objRecord.TestText__c.length();
            result = objRecord.TestText__c.right(len - 1);
            if (!result.isAllLowerCase()) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random string - errors found');
    }

    @IsTest
    private static void randomString_includeOnlyUppercase_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestText__c', 'random type(string) Minlength(5) Maxlength(10) ' +
            'startwith(Lower) include(Upper)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        String result = '';
        Integer errors = 0;
        Integer len = 0;
        for (FObjectOne__c objRecord : records) {
            len = objRecord.TestText__c.length();
            result = objRecord.TestText__c.right(len - 1);
            if (!result.isAllUpperCase()) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random string - errors found');
    }

    @IsTest
    private static void randomString_startWithLower_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestText__c', 'random type(string) Minlength(5) Maxlength(10) ' +
            'startwith(Lower) include(Lower,Upper)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c objRecord : records) {
            if (!objRecord.TestText__c.left(1).isAllLowerCase()) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random string - errors found');
    }

    @IsTest
    private static void randomString_startWithUpper_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestText__c', 'random type(string) Minlength(5) Maxlength(10) ' +
            'startwith(Upper) include(Lower, Upper)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c objRecord : records) {
            if (!objRecord.TestText__c.left(1).isAllUpperCase()) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random string - errors found');
    }

    @IsTest
    private static void randomString_startWithDigit_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestText__c', 'random type(string) Minlength(5) Maxlength(10) ' +
            'startwith(Digit) include(Lower, Upper)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c objRecord : records) {
            if (!objRecord.TestText__c.left(1).isNumeric()) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random string - errors found');
    }

    @IsTest
    private static void randomString_minEqualsZero_expectFailure() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestText__c', 'Random Type(string) Minlength(0) Maxlength(5) ' +
            'Startwith(Upper) Include(Lower,Upper)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        String expectedResult = 'The minimum length should be greater than or equal to 1 ' +
            'in definition [Random Type(string) Minlength(0) Maxlength(5) Startwith(Upper) Include(Lower,Upper)]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'random string - error found');
    }

    @IsTest
    private static void randomString_minLessThanZero_expectFailure() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestText__c', 'Random Type(string) Minlength(-1) Maxlength(5) ' +
            'Startwith(Upper) Include(Lower,Upper)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        String expectedResult = 'The minimum length should be greater than or equal to 1 ' +
            'in definition [Random Type(string) Minlength(-1) Maxlength(5) Startwith(Upper) Include(Lower,Upper)]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'random string - error found');
    }

    @IsTest
    private static void randomString_minGreaterThanMax_expectFailure() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestText__c', 'Random Type(string) Minlength(10) Maxlength(5) ' +
            'Startwith(Upper) Include(Lower,Upper)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        String expectedResult = 'The minimum length should be less than or equal to the maximum length ' +
            'in definition [Random Type(string) Minlength(10) Maxlength(5) Startwith(Upper) Include(Lower,Upper)]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'random string - errors found');
    }

    @IsTest
    private static void randomText_validWords_expectSuccess() {
        List<String> words = new List<String>{
            'lorem', 'ipsum', 'dolor', 'sit', 'amet', 'tempor', 'aboreant',
            'eu', 'nos', 'a', 'e', 'quo', 'magna', 'primis', 'labore', 'usi', 'virtute', 'fabellas', 'vis', 'duis',
            'scripta', 'laudem', 'commune', 'nam', 'laoreet', 'propriae', 'ea', 'partem',
            'inermis', 'ius', 'sint', 'impedit', 'eam', 'elit', 'nusquam'
        };

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestText__c', 'Random Type(Text) Minlength(20) Maxlength(50)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        String text = '';
        for (FObjectOne__c objRecord : records) {
            text = objRecord.TestText__c;
            for (String word : words) {
                text = text.remove(word);
            }
            if (String.isBlank(text)) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random text - errors found');
    }

    @IsTest
    private static void randomText_minEqualsMaxPlus1_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestText__c', 'Random Type(Text) Minlength(20) Maxlength(21)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Integer textSize = 0;
        for (FObjectOne__c objRecord : records) {
            textSize = objRecord.TestText__c.length();
            if (textSize < 20 || textSize > 21) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random text - errors found');
    }

    @IsTest
    private static void randomText_minEqualsMaxPlus10_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c', 200);
        obj.setDefinition('TestText__c', 'Random Type(Text) Minlength(20) Maxlength(30)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Integer textSize = 0;
        for (FObjectOne__c objRecord : records) {
            textSize = objRecord.TestText__c.length();
            if (textSize < 20 || textSize > 30) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random text - errors found');
    }

    @IsTest
    private static void randomText_minEqualsMax_expectFailure() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestText__c', 'Random Type(Text) Minlength(20) Maxlength(20)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        String expectedResult = 'The minimum length should be less than the maximum length ' +
            'in definition [Random Type(Text) Minlength(20) Maxlength(20)]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'random text - error found');
    }

    @IsTest
    private static void randomText_minEqualsZero_expectFailure() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestText__c', 'Random Type(Text) Minlength(0) Maxlength(20)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        String expectedResult = 'The minimum length should be greater than or equal to 1 ' +
            'in definition [Random Type(Text) Minlength(0) Maxlength(20)]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'random text - error found');
    }

    @IsTest
    private static void randomText_minLessThanZero_expectFailure() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestText__c', 'Random Type(Text) Minlength(-1) Maxlength(20)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        String expectedResult = 'The minimum length should be greater than or equal to 1 ' +
            'in definition [Random Type(Text) Minlength(-1) Maxlength(20)]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'random text - error found');
    }

    @IsTest
    private static void randomUrl_valid_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestUrl__c', 'random type(url)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        List<String> notes = new List<String>{
            'do', 're', 'mi', 'fa', 'sol', 'la', 'si'
        };
        Integer errors = 0;
        String url = '';
        for (FObjectOne__c objRecord : records) {
            url = objRecord.TestUrl__c;
            for (String note : notes) {
                url = url.remove(note);
            }
            if (url != 'http://www..com') {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random url - errors found');
    }

    @IsTest
    private static void serialDate_positiveStep_expectSuccess() {
        Integer numOfRecords = 100;
        Date fromValue = Date.newInstance(2018, 1, 1);
        Integer stepValue = 5;

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c', numOfRecords);
        obj.setDefinition('TestDate__c', 'Serial Type(Date) From(2018-01-01) Step(5)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Date expectedResult = fromValue.addDays((numOfRecords - 1) * stepValue);
        Date actualResult = records[numOfRecords - 1].TestDate__c;
        System.assertEquals(expectedResult, actualResult, 'serial date - errors found');
    }

    @IsTest
    private static void serialDate_negativeStep_expectSuccess() {
        Integer numOfRecords = 100;
        Date fromValue = Date.newInstance(2018, 1, 1);
        Integer stepValue = -5;

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c', numOfRecords);
        obj.setDefinition('TestDate__c', 'Serial Type(Date) From(2018-01-01) Step(-5)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Date expectedResult = fromValue.addDays((numOfRecords - 1) * stepValue);
        Date actualResult = records[numOfRecords - 1].TestDate__c;
        System.assertEquals(expectedResult, actualResult, 'serial date - errors found');
    }

    @IsTest
    private static void serialDate_fromDatetime_expectSuccess() {
        Integer numOfRecords = 100;
        Date fromValue = Date.newInstance(2018, 1, 1);
        Integer stepValue = 2;

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c', numOfRecords);
        obj.setDefinition('TestDate__c', 'Serial Type(Date) From(2018-01-01 02:02:02) Step(2)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Date expectedResult = fromValue.addDays((numOfRecords - 1) * stepValue);
        Date actualResult = records[numOfRecords - 1].TestDate__c;
        System.assertEquals(expectedResult, actualResult, 'serial date - errors found');
    }

    @IsTest
    private static void serialDate_decimalStep_expectFailure() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('TestDate__c', 'Serial Type(Date) From(2018-01-01) Step(2.2)');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid definition [Serial Type(Date) ' +
            'From(2018-01-01) Step(2.2)] of field [TestDate__c]';
        String actualResult = obj.getErrors().get('TestDate__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'serial date - errors found');
    }

    @IsTest
    private static void serialDate_serializationInSameFObject_expectSuccess() {
        Integer numOfRecords = 10;

        Test.startTest();
        // create some serialized records
        FObject obj = new FObject('FObjectTwo__c', numOfRecords)
            .setDefinition(FObjectTwo__c.TestTextUnique__c, 'serial type(date) from(2020-1-1) step(1)');
        List<FObjectOne__c> records = obj.getRecords();

        // create some more serialized records of the same FObject
        obj.setDefinition(FObjectTwo__c.TestText__c, 'static value(test)');
        records.addAll((List<FObjectOne__c>) obj.getRecords());

        // insert records
        String errorMessage = '';
        try {
            obj.insertRecords(true);
        } catch (Exception ex) {
            errorMessage = ex.getMessage();
        }
        Test.stopTest();

        Boolean result = FObject.processIsValid() && String.isBlank(errorMessage);
        System.assert(result, 'serial data - errors found');
    }

    @IsTest
    private static void serialDate_serializationInDifferentFObjects_expectSuccess() {
        Integer numOfRecords = 10;

        Test.startTest();
        // create some serialized records
        FObject obj1 = new FObject('FObjectTwo__c', numOfRecords)
            .setDefinition(FObjectTwo__c.TestTextUnique__c, 'serial type(date) from(2020-1-1) step(1)');
        obj1.getRecords();

        // create some more serialized records of a different FObject
        FObject obj2 = new FObject('FObjectTwo__c', numOfRecords)
            .setDefinition(FObjectTwo__c.TestTextUnique__c, 'serial type(date) from(2020-1-1) step(1)');
        obj2.getRecords();

        // insert records
        String errorMessage = '';
        try {
            obj1.insertRecords(true);
            obj2.insertRecords(true);
        } catch (Exception ex) {
            errorMessage = ex.getMessage();
        }
        Test.stopTest();

        List<FObjectOne__c> records = [SELECT TestIntegerUnique__c FROM FObjectOne__c];

        Boolean result = FObject.processIsValid() && String.isBlank(errorMessage);
        System.assert(result, 'serial number - errors found');
    }

    @IsTest
    private static void serialDatetime_fromDatePositiveIntegerStep_expectSuccess() {
        Integer numOfRecords = 100;
        Datetime fromValue = Datetime.newInstance(2018, 1, 1);
        Decimal stepValue = 2;

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c', numOfRecords);
        obj.setDefinition('TestDatetime__c', 'Serial Type(Datetime) From(2018-01-01) Step(2)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Datetime expectedResult = fromValue.addDays((numOfRecords - 1) * 2);
        Datetime actualResult = records[numOfRecords - 1].TestDatetime__c;
        System.assertEquals(expectedResult, actualResult, 'serial datetime - errors found');
    }

    @IsTest
    private static void serialDatetime_fromDateNegativeIntegerStep_expectSuccess() {
        Integer numOfRecords = 100;
        Datetime fromValue = Datetime.newInstance(2018, 1, 1);

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c', numOfRecords);
        obj.setDefinition('TestDatetime__c', 'Serial Type(Datetime) From(2018-01-01) Step(-2)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Datetime expectedResult = fromValue.addDays((numOfRecords - 1) * (-2));
        Datetime actualResult = records[numOfRecords - 1].TestDatetime__c;
        System.assertEquals(expectedResult, actualResult, 'serial datetime - errors found');
    }

    @IsTest
    private static void serialDatetime_fromDatePositiveDecimalStep_expectSuccess() {
        Integer numOfRecords = 100;
        Datetime fromValue = Datetime.newInstance(2018, 1, 1);

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c', numOfRecords);
        obj.setDefinition('TestDatetime__c', 'Serial Type(Datetime) From(2018-01-01) Step(2.2)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Datetime expectedResult = fromValue.addDays((numOfRecords - 1) * 2);
        expectedResult = expectedResult.addHours((numOfRecords - 1) * 4);
        expectedResult = expectedResult.addMinutes((numOfRecords - 1) * 48);
        Datetime actualResult = records[numOfRecords - 1].TestDatetime__c;
        System.assertEquals(expectedResult, actualResult, 'serial datetime - errors found');
    }

    @IsTest
    private static void serialDatetime_fromDateNegativeDecimalStep_expectSuccess() {
        Integer numOfRecords = 100;
        Datetime fromValue = Datetime.newInstance(2018, 1, 1);

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c', numOfRecords);
        obj.setDefinition('TestDatetime__c', 'Serial Type(Datetime) From(2018-01-01) Step(-2.2)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Datetime expectedResult = fromValue.addDays((numOfRecords - 1) * (-2));
        expectedResult = expectedResult.addHours((numOfRecords - 1) * (-4));
        expectedResult = expectedResult.addMinutes((numOfRecords - 1) * (-48));
        Datetime actualResult = records[numOfRecords - 1].TestDatetime__c;
        System.assertEquals(expectedResult, actualResult, 'serial datetime - errors found');
    }

    @IsTest
    private static void serialDatetime_fromDatetimePositiveIntegerStep_expectSuccess() {
        Integer numOfRecords = 100;
        Datetime fromValue = Datetime.newInstance(2018, 1, 1, 2, 2, 2);

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c', numOfRecords);
        obj.setDefinition('TestDatetime__c', 'Serial Type(Datetime) From(2018-01-01 02:02:02) Step(2)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Datetime expectedResult = fromValue.addDays((numOfRecords - 1) * 2);
        Datetime actualResult = records[numOfRecords - 1].TestDatetime__c;
        System.assertEquals(expectedResult, actualResult, 'serial datetime - errors found');
    }

    @IsTest
    private static void serialDatetime_fromDatetimeNegativeIntegerStep_expectSuccess() {
        Integer numOfRecords = 100;
        Datetime fromValue = Datetime.newInstance(2018, 1, 1, 2, 2, 2);

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c', numOfRecords);
        obj.setDefinition('TestDatetime__c', 'Serial Type(Datetime) From(2018-01-01 02:02:02) Step(-2)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Datetime expectedResult = fromValue.addDays((numOfRecords - 1) * (-2));
        Datetime actualResult = records[numOfRecords - 1].TestDatetime__c;
        System.assertEquals(expectedResult, actualResult, 'serial datetime - errors found');
    }

    @IsTest
    private static void serialDatetime_fromDatetimePositiveDecimalStep_expectSuccess() {
        Integer numOfRecords = 100;
        Datetime fromValue = Datetime.newInstance(2018, 1, 1, 2, 2, 2);

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c', numOfRecords);
        obj.setDefinition('TestDatetime__c', 'Serial Type(Datetime) From(2018-01-01 02:02:02) Step(2.2)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Datetime expectedResult = fromValue.addDays((numOfRecords - 1) * 2);
        expectedResult = expectedResult.addHours((numOfRecords - 1) * 4);
        expectedResult = expectedResult.addMinutes((numOfRecords - 1) * 48);
        Datetime actualResult = records[numOfRecords - 1].TestDatetime__c;
        System.assertEquals(expectedResult, actualResult, 'serial datetime - errors found');
    }

    @IsTest
    private static void serialDatetime_fromDatetimeNegativeDecimalStep_expectSuccess() {
        Integer numOfRecords = 100;
        Datetime fromValue = Datetime.newInstance(2018, 1, 1, 2, 2, 2);

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c', numOfRecords);
        obj.setDefinition('TestDatetime__c', 'Serial Type(Datetime) From(2018-01-01 02:02:02) Step(-2.2)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Datetime expectedResult = fromValue.addDays((numOfRecords - 1) * (-2));
        expectedResult = expectedResult.addHours((numOfRecords - 1) * (-4));
        expectedResult = expectedResult.addMinutes((numOfRecords - 1) * (-48));
        Datetime actualResult = records[numOfRecords - 1].TestDatetime__c;
        System.assertEquals(expectedResult, actualResult, 'serial datetime - errors found');
    }

    @IsTest
    private static void serialDatetime_serializationInSameFObject_expectSuccess() {
        Integer numOfRecords = 10;

        Test.startTest();
        // create some serialized records
        FObject obj = new FObject('FObjectTwo__c', numOfRecords)
            .setDefinition(FObjectTwo__c.TestTextUnique__c,
                'serial type(datetime) from(2020-1-1 10:11:12) step(1)');
        List<FObjectOne__c> records = obj.getRecords();

        // create some more serialized records of the same FObject
        obj.setDefinition(FObjectTwo__c.TestText__c, 'static value(test)');
        records.addAll((List<FObjectOne__c>) obj.getRecords());

        // insert records
        String errorMessage = '';
        try {
            obj.insertRecords(true);
        } catch (Exception ex) {
            errorMessage = ex.getMessage();
        }
        Test.stopTest();

        Boolean result = FObject.processIsValid() && String.isBlank(errorMessage);
        System.assert(result, 'serial data - errors found');
    }

    @IsTest
    private static void serialDatetime_serializationInDifferentFObjects_expectSuccess() {
        Integer numOfRecords = 10;

        Test.startTest();
        // create some serialized records
        FObject obj1 = new FObject('FObjectTwo__c', numOfRecords)
            .setDefinition(FObjectTwo__c.TestTextUnique__c,
                'serial type(datetime) from(2020-1-1 10:11:12) step(1)');
        obj1.getRecords();

        // create some more serialized records of a different FObject
        FObject obj2 = new FObject('FObjectTwo__c', numOfRecords)
            .setDefinition(FObjectTwo__c.TestTextUnique__c,
                'serial type(datetime) from(2020-1-1 10:11:12) step(1)');
        obj2.getRecords();

        // insert records
        String errorMessage = '';
        try {
            obj1.insertRecords(true);
            obj2.insertRecords(true);
        } catch (Exception ex) {
            errorMessage = ex.getMessage();
        }
        Test.stopTest();

        List<FObjectOne__c> records = [SELECT TestIntegerUnique__c FROM FObjectOne__c];

        Boolean result = FObject.processIsValid() && String.isBlank(errorMessage);
        System.assert(result, 'serial number - errors found');
    }

    @IsTest
    private static void serialLookupCyclicalForceea_createLookupRecords_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10);
        obj2.insertRecords(true);
        List<FObjectTwo__c> records2 = obj2.getRecords();

        List<String> lookupIds = new List< String>();
        for (FObjectTwo__c objRecord : records2) {
            lookupIds.add(objRecord.Id);
        }

        Test.startTest();
        FObject obj1 = new FObject('FObjectOne__c', 20);
        obj1.setDefinition('TestLookup__c',
            'serial lookup(FObjectTwo__c) mode(cyclical) source(forceea)');
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Integer counter = 0;
        for (FObjectOne__c objRecord : records1) {
            if (objRecord.TestLookup__c != lookupIds.get(counter)) {
                errors++;
            }
            counter++;
            if (counter == records2.size()) {
                counter = 0;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'serial lookup - errors found');
    }

    @IsTest
    private static void serialLookupFirstForceea_createLookupRecords_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10);
        obj2.insertRecords(true);
        List<FObjectTwo__c> records2 = obj2.getRecords();

        List<String> lookupIds = new List< String>();
        for (FObjectTwo__c objRecord : records2) {
            lookupIds.add(objRecord.Id);
        }

        Test.startTest();
        FObject obj1 = new FObject('FObjectOne__c', 20);
        obj1.setDefinition('TestLookup__c',
            'serial lookup(FObjectTwo__c) mode(first) source(forceea)');
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Integer counter = 0;
        Integer lookupListSize = records2.size();
        for (FObjectOne__c objRecord : records1) {
            if ((counter < lookupListSize && objRecord.TestLookup__c != lookupIds.get(counter)) ||
                (counter >= lookupListSize && objRecord.TestLookup__c != lookupIds.get(0))) {
                errors++;
            }
            counter++;
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'serial lookup - errors found');
    }

    @IsTest
    private static void serialLookupLastForceea_createLookupRecords_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10);
        obj2.insertRecords(true);
        List<FObjectTwo__c> records2 = obj2.getRecords();

        List<String> lookupIds = new List< String>();
        for (FObjectTwo__c objRecord : records2) {
            lookupIds.add(objRecord.Id);
        }

        Test.startTest();
        FObject obj1 = new FObject('FObjectOne__c', 20);
        obj1.setDefinition('TestLookup__c',
            'serial lookup(FObjectTwo__c) mode(last) source(forceea)');
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Integer counter = 0;
        Integer lookupListSize = records2.size();
        for (FObjectOne__c objRecord : records1) {
            if ((counter < lookupListSize && objRecord.TestLookup__c != lookupIds.get(counter)) ||
                (counter >= lookupListSize && objRecord.TestLookup__c != lookupIds.get(lookupListSize - 1))) {
                errors++;
            }
            counter++;
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'serial lookup - errors found');
    }

    @IsTest
    private static void serialLookupNullForceea_createLookupRecords_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10);
        obj2.insertRecords(true);
        List<FObjectTwo__c> records2 = obj2.getRecords();

        List<String> lookupIds = new List< String>();
        for (FObjectTwo__c objRecord : records2) {
            lookupIds.add(objRecord.Id);
        }

        Test.startTest();
        FObject obj1 = new FObject('FObjectOne__c', 20);
        obj1.setDefinition('TestLookup__c',
            'serial lookup(FObjectTwo__c) mode(null) source(forceea)');
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Integer counter = 0;
        Integer lookupListSize = records2.size();
        for (FObjectOne__c objRecord : records1) {
            if ((counter < lookupListSize && objRecord.TestLookup__c != lookupIds.get(counter)) ||
                (counter >= lookupListSize && String.isNotBlank(objRecord.TestLookup__c))) {
                errors++;
            }
            counter++;
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'serial lookup - errors found');
    }

    @IsTest
    private static void serialLookupCyclicalGroupForceea_createLookupRecords_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10);
        obj2.insertRecords(true, 'one');
        List<FObjectTwo__c> records2 = obj2.getRecords();

        List<String> lookupIds = new List< String>();
        for (FObjectTwo__c objRecord : records2) {
            lookupIds.add(objRecord.Id);
        }

        Test.startTest();
        FObject obj1 = new FObject('FObjectOne__c', 20);
        obj1.setDefinition('TestLookup__c',
            'serial lookup(FObjectTwo__c) mode(cyclical) group(one) source(forceea)');
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Integer counter = 0;
        for (FObjectOne__c objRecord : records1) {
            if (objRecord.TestLookup__c != lookupIds.get(counter)) {
                errors++;
            }
            counter++;
            if (counter == records2.size()) {
                counter = 0;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'serial lookup - errors found');
    }

    @IsTest
    private static void serialLookupFirstGroupForceea_createLookupRecords_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10);
        obj2.insertRecords(true, 'one');
        List<FObjectTwo__c> records2 = obj2.getRecords();

        List<String> lookupIds = new List< String>();
        for (FObjectTwo__c objRecord : records2) {
            lookupIds.add(objRecord.Id);
        }

        Test.startTest();
        FObject obj1 = new FObject('FObjectOne__c', 20);
        obj1.setDefinition('TestLookup__c',
            'serial lookup(FObjectTwo__c) mode(first) group(one) source(forceea)');
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Integer counter = 0;
        Integer lookupListSize = records2.size();
        for (FObjectOne__c objRecord : records1) {
            if ((counter < lookupListSize && objRecord.TestLookup__c != lookupIds.get(counter)) ||
                (counter >= lookupListSize && objRecord.TestLookup__c != lookupIds.get(0))) {
                errors++;
            }
            counter++;
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'serial lookup - errors found');
    }

    @IsTest
    private static void serialLookupLastGroupForceea_createLookupRecords_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10);
        obj2.insertRecords(true, 'one');
        List<FObjectTwo__c> records2 = obj2.getRecords();

        List<String> lookupIds = new List< String>();
        for (FObjectTwo__c objRecord : records2) {
            lookupIds.add(objRecord.Id);
        }

        Test.startTest();
        FObject obj1 = new FObject('FObjectOne__c', 20);
        obj1.setDefinition('TestLookup__c',
            'serial lookup(FObjectTwo__c) mode(last) group(one) source(forceea)');
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Integer counter = 0;
        Integer lookupListSize = records2.size();
        for (FObjectOne__c objRecord : records1) {
            if ((counter < lookupListSize && objRecord.TestLookup__c != lookupIds.get(counter)) ||
                (counter >= lookupListSize && objRecord.TestLookup__c != lookupIds.get(lookupListSize - 1))) {
                errors++;
            }
            counter++;
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'serial lookup - errors found');
    }

    @IsTest
    private static void serialLookupNullGroupForceea_createLookupRecords_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10);
        obj2.insertRecords(true, 'one');
        List<FObjectTwo__c> records2 = obj2.getRecords();

        List<String> lookupIds = new List< String>();
        for (FObjectTwo__c objRecord : records2) {
            lookupIds.add(objRecord.Id);
        }

        Test.startTest();
        FObject obj1 = new FObject('FObjectOne__c', 20);
        obj1.setDefinition('TestLookup__c',
            'serial lookup(FObjectTwo__c) mode(null) group(one) source(forceea)');
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Integer counter = 0;
        Integer lookupListSize = records2.size();
        for (FObjectOne__c objRecord : records1) {
            if ((counter < lookupListSize && objRecord.TestLookup__c != lookupIds.get(counter)) ||
                (counter >= lookupListSize && String.isNotBlank(objRecord.TestLookup__c))) {
                errors++;
            }
            counter++;
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'serial lookup - errors found');
    }

    @IsTest
    private static void serialNumber_positiveIntegerStep_expectSuccess() {
        Integer numOfRecords = 201;
        Decimal fromValue = 10;
        Decimal stepValue = 2;

        Test.startTest();
        FObject obj = new FObject('Account'); // should use the Account object
        obj.setDefinition('NumberOfEmployees', 'Serial Type(Number) From(10) Step(2) Scale(0)');
        List<Account> records = (List<Account>) obj.getRecords();
        Test.stopTest();

        Decimal expectedResult = fromValue + (numOfRecords - 1) * stepValue;
        Decimal actualResult = records[numOfRecords - 1].NumberOfEmployees;
        System.assertEquals(expectedResult, actualResult, 'serial number - errors found');
    }

    @IsTest
    private static void serialNumber_negativeIntegerStep_expectSuccess() {
        Integer numOfRecords = 201;
        Decimal fromValue = 0;
        Decimal stepValue = -2;

        Test.startTest();
        FObject obj = new FObject('Account'); // should use the Account object
        obj.setDefinition('NumberOfEmployees', 'Serial Type(Number) From(0) Step(-2) Scale(2)');
        List<Account> records = (List<Account>) obj.getRecords();
        Test.stopTest();

        Decimal expectedResult = fromValue + (numOfRecords - 1) * stepValue;
        Decimal actualResult = records[numOfRecords - 1].NumberOfEmployees;
        System.assertEquals(expectedResult, actualResult, 'serial number - errors found');
    }

    @IsTest
    private static void serialNumber_positiveDecimalStep_expectSuccess() {
        Integer numOfRecords = 201;
        Decimal fromValue = 10;
        Decimal stepValue = 1.52;

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c', numOfRecords);
        obj.setDefinition('TestDecimal__c', 'Serial Type(Number) From(10) Step(1.52) Scale(2)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Decimal expectedResult = fromValue + (numOfRecords - 1) * stepValue;
        Decimal actualResult = records[numOfRecords - 1].TestDecimal__c;
        System.assertEquals(expectedResult, actualResult, 'serial number - errors found');
    }

    @IsTest
    private static void serialNumber_negativeDecimalStep_expectSuccess() {
        Integer numOfRecords = 201;
        Decimal fromValue = 10;
        Decimal stepValue = -1.52;

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c', numOfRecords);
        obj.setDefinition('TestDecimal__c', 'Serial Type(Number) From(10) Step(-1.52) Scale(2)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Decimal expectedResult = fromValue + (numOfRecords - 1) * stepValue;
        Decimal actualResult = records[numOfRecords - 1].TestDecimal__c;
        System.assertEquals(expectedResult, actualResult, 'serial number - errors found');
    }

    @IsTest
    private static void serialNumber_serializationInSameFObject_expectSuccess() {
        Integer numOfRecords = 100;

        Test.startTest();
        //create some serialized records
        FObject obj = new FObject('FObjectOne__c', numOfRecords);
        obj.setDefinition(FObjectOne__c.TestIntegerUnique__c,
            'serial type(number) from(1) step(1) scale(0)');
        List<FObjectOne__c> records = obj.getRecords();

        // create some more serialized records of the same FObject
        obj.setDefinition(FObjectOne__c.TestText__c, 'static value(test)');
        records.addAll((List<FObjectOne__c>) obj.getRecords());

        // insert records
        String errorMessage = '';
        try {
            obj.insertRecords(true);
        } catch (Exception ex) {
            errorMessage = ex.getMessage();
        }
        Test.stopTest();

        Boolean result = FObject.processIsValid() && String.isBlank(errorMessage);
        System.assert(result, 'serial number - errors found');
    }

    @IsTest
    private static void serialNumber_serializationInDifferentFObjects_expectSuccess() {
        Integer numOfRecords = 100;

        Test.startTest();
        //create some serialized records
        FObject obj1 = new FObject('FObjectOne__c', numOfRecords);
        obj1.setDefinition(FObjectOne__c.TestIntegerUnique__c,
            'serial type(number) from(1) step(1) scale(0)');
        List<FObjectOne__c> records1 = obj1.getRecords();

        // create some more serialized records of a different FObject
        FObject obj2 = new FObject('FObjectOne__c', numOfRecords);
        obj2.setDefinition(FObjectOne__c.TestIntegerUnique__c,
            'serial type(number) from(1) step(1) scale(0)');
        List<FObjectOne__c> records2 = obj2.getRecords();

        // insert records
        String errorMessage = '';
        try {
            obj1.insertRecords(true);
            obj2.insertRecords(true);
        } catch (Exception ex) {
            errorMessage = ex.getMessage();
        }
        Test.stopTest();

        List<FObjectOne__c> records = [SELECT TestIntegerUnique__c FROM FObjectOne__c];

        Boolean result = FObject.processIsValid() && String.isBlank(errorMessage);
        System.assert(result, 'serial number - errors found');
    }

    @IsTest
    private static void staticLookup_invalidSource_expectFailure() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestLookup__c', 'static lookup(FObjectTwo__c) ' +
            'field(TestPicklistA__c) value(a1) source(ForceeaX)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        String expectedResult = 'Invalid source [ForceeaX] in definition [static lookup(FObjectTwo__c) ' +
            'field(TestPicklistA__c) value(a1) source(ForceeaX)]';
        String actualResult = obj.getErrors().get('TestLookup__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'static lookup - errors found');
    }

    @IsTest
    private static void staticLookupForceea_createLookupRecords_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(FObjectOne__c.TestLookup__c,
            'static lookup(FObjectTwo__c) field(TestPicklistA__c) value(a1) source(Forceea)');
        obj.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        // get the TestLookup__c of the first FObjectOne__c record
        Id lookupId = records.get(0).TestLookup__c;

        // check if the lookupId exists in every record of FObjectOne__c
        Integer errors = 0;
        for (FObjectOne__c objRecord : records) {
            if (objRecord.TestLookup__c != lookupId) {
                errors++;
            }
        }

        // verify that the FObjectTwo__c record of lookupId has TestText__c = 'a1'
        FObjectTwo__c refObjectRecord = [
            SELECT Id, TestPicklistA__c
            FROM FObjectTwo__c
            WHERE Id = :lookupId
            LIMIT 1
        ];
        if (refObjectRecord.TestPicklistA__c != 'a1') {
            errors++;
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'static lookup - errors found');
    }

    @IsTest
    private static void staticLookupForceea_lookupRecordsExist_expectSuccess() {
        String whereValue = 'Hot';
        Integer errors = 0;

        Test.startTest();
        FObject obj1 = new FObject(FObjectTwo__c.SObjectType, 10);
        obj1.setDefinition('TestText__c', 'static value(' + whereValue + ')');
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        obj1.insertRecords(true);

        FObject obj2 = new FObject(FObjectOne__c.SObjectType, 10);
        obj2.setDefinition('TestLookup__c', 'static lookup(FObjectTwo__c) ' +
            'field(TestText__c) value(' + whereValue + ') source(Forceea)');
        List<FObjectOne__c> records2 = (List<FObjectOne__c>) obj2.getRecords();
        Test.stopTest();

        // get the TestLookup__c of the first FObjectOne__c record
        Id lookupId = records2.get(0).TestLookup__c;

        // check if the lookupId exists in every record of FObjectOne__c
        for (FObjectOne__c objRecord : records2) {
            if (objRecord.TestLookup__c != lookupId) {
                errors++;
            }
        }

        // verify that the FObjectTwo__c record of lookupId has TestText__c = 'Hot'
        FObjectTwo__c refObjectRecord = [
            SELECT Id, TestText__c
            FROM FObjectTwo__c
            WHERE Id = :lookupId
            LIMIT 1
        ];
        if (refObjectRecord.TestText__c != whereValue) {
            errors++;
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'static lookup - errors found');
    }

    @IsTest
    private static void staticLookupSalesforce_valid_expectSuccess() {
        String whereValue = 'Hot';
        Integer errors = 0;

        Test.startTest();
        FObject obj1 = new FObject(FObjectTwo__c.SObjectType, 10);
        obj1.setDefinition('TestText__c', 'static value(' + whereValue + ')');
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        obj1.insertRecords(true);

        FObject obj2 = new FObject(FObjectOne__c.SObjectType, 10);
        obj2.setDefinition('TestLookup__c', 'static lookup(FObjectTwo__c) ' +
            'field(TestText__c) value(' + whereValue + ') source(Salesforce)');
        obj2.insertRecords(true);
        List<FObjectOne__c> records2 = (List<FObjectOne__c>) obj2.getRecords();
        Test.stopTest();

        // get the TestLookup__c of the first FObjectOne__c record
        Id lookupId = records2.get(0).TestLookup__c;

        // check if the lookupid exists in every record of FObjectOne__c
        for (FObjectOne__c objRecord : records2) {
            if (objRecord.TestLookup__c != lookupId) {
                errors++;
            }
        }

        // verify that the FObjectTwo__c record of lookupId has TestText__c = 'Hot'
        FObjectTwo__c refObjectRecord = [
            SELECT Id, TestText__c
            FROM FObjectTwo__c
            WHERE Id = :lookupId
            LIMIT 1
        ];
        if (refObjectRecord.TestText__c != whereValue) {
            errors++;
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'static lookup - errors found');
    }

    @IsTest
    private static void staticLookup_insertedGroupRecords_expectSuccess() {
        Test.startTest();
        // insert FObjectTwo__c records for group B
        FObject objB1 = new FObject('FObjectTwo__c', 5);
        objB1.setDefinition('TestPicklistA__c', 'static value(a0)');
        objB1.insertRecords(true, 'B');
        // insert FObjectTwo__c records without group
        FObject objB2 = new FObject('FObjectTwo__c', 5);
        objB2.setDefinition('TestPicklistA__c', 'random type(list) value(a1, a2, a3)');
        objB2.insertRecords(true);
        // insert FObjectOne__c records
        FObject objA = new FObject('FObjectOne__c');
        objA.setDefinition('TestLookup__c',
            'static lookup(FObjectTwo__c) field(TestPicklistA__c) value(a0) source(Forceea)');
        objA.insertRecords(true);
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c objRecord : [SELECT TestLookup__r.TestPicklistA__c FROM FObjectOne__c LIMIT 1000]) {
            if (objRecord.TestLookup__r.TestPicklistA__c != 'a0') {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'static lookup - errors found');
    }

    @IsTest
    private static void staticLookup_invalidLookup_expectFailure() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestLookup__c', 'static lookup(FObjectTwo) ' +
            'field(TestPicklistA__c) value(a1) source(forceea)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        String expectedResult = 'Invalid lookup SObject [FObjectTwo] in definition [static lookup(FObjectTwo) ' +
            'field(TestPicklistA__c) value(a1) source(forceea)]';
        String actualResult = obj.getErrors().get('TestLookup__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'static lookup - errors found');
    }

    @IsTest
    private static void staticLookup_nullLookup_expectFailure() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('TestLookup__c', 'static lookup() field(TestPicklistA__c) value(a1) source(forceea)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        String expectedResult = 'Invalid syntax in definition [static lookup() field(TestPicklistA__c) value(a1) ' +
            'source(forceea)] of field [TestLookup__c]';
        String actualResult = obj.getErrors().get('TestLookup__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'static lookup - errors found');
    }

    @IsTest
    private static void static_recordType_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('RecordTypeId', 'static value(RecordTypeA)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        // get the record type ID of the first record
        Id recordTypeId = records.get(0).RecordTypeId;

        // check if the record type ID exists in every record
        Integer errors = 0;
        for (FObjectOne__c objRecord : records) {
            if (objRecord.RecordTypeId != recordTypeId) {
                errors++;
            }
        }

        // verify the name of the record type
        Map<Id, Schema.RecordTypeInfo> recordTypesMap = Schema.SObjectType.FObjectOne__c.getRecordTypeInfosById();
        String recordTypeName = recordTypesMap.get(recordTypeId).getName();
        if (recordTypeName != 'Record Type A') {
            errors++;
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'static value - errors found');
    }

    @IsTest
    private static void static_boolean_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('TestCheckbox__c', 'static value(true)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c objRecord : records) {
            if (objRecord.TestCheckbox__c == false) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'static value - errors found');
    }

    @IsTest
    private static void static_date_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('TestDate__c', 'static value(2018-10-01)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Date dt = Date.newInstance(2018, 10, 1);
        for (FObjectOne__c objRecord : records) {
            if (objRecord.TestDate__c != dt) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'static value - errors found');
    }

    @IsTest
    private static void static_datetime_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('TestDatetime__c', 'static value(2018-10-01 01:01:01)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Datetime dt = Datetime.newInstance(2018, 10, 1, 1, 1, 1);
        for (FObjectOne__c objRecord : records) {
            if (objRecord.TestDatetime__c != dt) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'static value - errors found');
    }

    @IsTest
    private static void static_decimal_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('TestDecimal__c', 'static value(100000.11)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c objRecord : records) {
            if (objRecord.TestDecimal__c != 100000.11) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'static value - errors found');
    }

    @IsTest
    private static void static_doubleQuotes1_expectFailure() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('testText__c', 'static value("one)');
        obj.insertRecords(true);
        Test.stopTest();

        System.assert(!FObject.processIsValid(), 'static value - did not find errors');
    }

    @IsTest
    private static void static_doubleQuotes2_expectFailure() {
        Test.startTest();
        FObject obj = new FObject('FObjectOne__c');
        obj.setDefinition('testText__c', 'static value(one ("two)');
        obj.insertRecords(true);
        Test.stopTest();

        System.assert(!FObject.processIsValid(), 'static value - did not find errors');
    }

    @IsTest
    private static void static_doubleQuotes_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('testText__c', 'static value(one " two)');
        obj.setDefinition('testText__c', 'static value(one "" two)');
        obj.setDefinition('testText__c', 'static value(one "two" three)');
        obj.setDefinition('testText__c', 'static value("one, two")');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        System.assert(FObject.processIsValid(), 'static value - errors found');
    }

    @IsTest
    private static void static_integer_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('TestInteger__c', 'static value(10)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c objRecord : records) {
            if (objRecord.TestInteger__c != 10) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'static value - errors found');
    }

    @IsTest
    private static void static_stringForTextField_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('testText__c', 'static value(Sales)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c objRecord : records) {
            if (objRecord.TestText__c != 'Sales') {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'static value - errors found');
    }

    @IsTest
    private static void static_stringForTextFieldBlankValues_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition(FObjectOne__c.TestText__c, 'static value(" ")');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c objRecord : records) {
            if (String.isNotBlank(objRecord.TestText__c)) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'static value - errors found');
    }

    @IsTest
    private static void static_validValueForRestrictedIndependentPicklistField_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('TestPicklistA__c', 'static value(a1)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c objRecord : records) {
            if (objRecord.TestPicklistA__c != 'a1') {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'static value - errors found');
    }

    @IsTest
    private static void static_invalidValueForRestrictedIndependentPicklistField_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('TestPicklistA__c', 'static value(a10)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c objRecord : records) {
            if (String.isNotBlank(objRecord.TestPicklistA__c)) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'static value - errors found');
    }

    @IsTest
    private static void static_validValueForRestrictedDependentPicklistField_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('TestPicklistB__c', 'static value(b2)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c objRecord : records) {
            if (!(String.isBlank(objRecord.TestPicklistB__c) || objRecord.TestPicklistB__c == 'b2')) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'static value - errors found');
    }

    @IsTest
    private static void static_invalidValueForRestrictedDependentPicklistField_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('TestPicklistB__c', 'static value(b10)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c objRecord : records) {
            if (String.isNotBlank(objRecord.TestPicklistB__c)) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'static value - errors found');
    }

    @IsTest
    private static void static_validValueForUnrestrictedIndependentPicklistField_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectTwo__c.SObjectType, 10);
        obj.setDefinition('TestPicklistEUnrestricted__c', 'static value(e1)');
        List<FObjectTwo__c> records = (List<FObjectTwo__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (FObjectTwo__c objRecord : records) {
            if (objRecord.TestPicklistEUnrestricted__c != 'e1') {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'static value - errors found');
    }

    @IsTest
    private static void static_invalidValueForUnrestrictedIndependentPicklistField_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectTwo__c.SObjectType, 10);
        obj.setDefinition('TestPicklistEUnrestricted__c', 'static value(a10)');
        List<FObjectTwo__c> records = (List<FObjectTwo__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (FObjectTwo__c objRecord : records) {
            if (objRecord.TestPicklistEUnrestricted__c != 'a10') {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'static value - errors found');
    }

    @IsTest
    private static void static_validValueForUnrestrictedDependentPicklistField_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectTwo__c.SObjectType, 10);
        obj.setDefinition('TestPicklistFUnrestricted__c', 'static value(f2)');
        List<FObjectTwo__c> records = (List<FObjectTwo__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (FObjectTwo__c objRecord : records) {
            if (!(String.isBlank(objRecord.TestPicklistFUnrestricted__c) || objRecord.TestPicklistFUnrestricted__c == 'f2')) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'static value - errors found');
    }

    @IsTest
    private static void static_invalidValueForUnrestrictedDependentPicklistField_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectTwo__c.SObjectType, 10);
        obj.setDefinition('TestPicklistFUnrestricted__c', 'static value(a10)');
        List<FObjectTwo__c> records = (List<FObjectTwo__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (FObjectTwo__c objRecord : records) {
            if (String.isNotBlank(objRecord.TestPicklistFUnrestricted__c)) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'static value - errors found');
    }

    @IsTest
    private static void static_controllingFieldIsCheckbox_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('testCheckbox__c', 'static value(true)');
        obj.setDefinition('testpicklistD__c', 'static value(d2)');
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
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random static - errors found');
    }

    @IsTest
    private static void static_invalidRecordType_expectFailure() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('RecordTypeId', 'static value(RecordTypeAX)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        String expectedResult = 'Invalid record type [RecordTypeAX] for definition [static value(RecordTypeAX)]';
        String actualResult = obj.getErrors().get('RecordTypeId').get(0);
        System.assertEquals(expectedResult, actualResult, 'static value - errors found');
    }

    @IsTest
    private static void static_twoArguments_expectFailure() {
        Test.startTest();
        FObject obj = new FObject(' FObjectOne__c ', 10);
        obj.setDefinition('testtext__c', 'Static Value(One, "Two and Three")');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        String expectedResult = 'Invalid definition [Static Value(One, "Two and Three")] of field [TestText__c]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'sddlStatic - errors found');
    }

    @IsTest
    private static void virtualFields_valid1_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition(' $Test1 ', 'serial type(number) from(1) step(1) scale(0)');
        obj.setDefinition(' $Test2 ', 'serial type(number) from(1) step(1) scale(0)');
        obj.setDefinition('TestText__c', 'copy field($Test1)');
        obj.setDefinition('TestText__c', 'static value(-)');
        obj.setDefinition('TestText__c', 'copy field($Test2)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Integer counter = 0;
        for (FObjectOne__c objRecord : records) {
            counter++;
            String str = String.valueOf(counter);
            if (objRecord.TestText__c != str + '-' + str) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'virtual field - errors found');
    }

    @IsTest
    private static void virtualFields_valid2_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(' $Test ', 'serial type(number) from(1) step(1) scale(0)')
            .setDefinition(FObjectOne__c.TestInteger__c, 'copy field($Test)')
            .setDefinition(FObjectOne__c.TestIntegerUnique__c, 'copy field($Test)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Integer counter = 1;
        for (FObjectOne__c objRecord : records) {
            if (objRecord.TestInteger__c != counter && objRecord.TestIntegerUnique__c != counter) {
                errors++;
            }
            counter++;
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'virtual field - errors found');
    }

    @IsTest
    private static void virtualFields_valid3_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10);
        obj2.insertRecords(true);
        List<FObjectTwo__c> obj2Records = (List<FObjectTwo__c>) obj2.getRecords();
        Set<Id> obj2Ids = (new Map<Id, FObjectTwo__c> (obj2Records)).keySet();

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 10);
        obj1.setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) source(forceea)');
        obj1.setDefinition('$TestLookup', 'random lookup(FObjectTwo__c) source(forceea)');
        obj1.setDefinition('TestText__c', 'copy field($TestLookup)');
        List<FObjectOne__c> obj1Records = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c objRecord : obj1Records) {
            if (!obj2Ids.contains(objRecord.TestText__c)) {
                errors++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'virtual field - errors found');
    }

}