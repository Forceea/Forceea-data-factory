/*
  Forceea data factory (v2.2.0)
  Copyright (C) 2020 Nikos Mitrakis

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
public class ForceeaGeneratorSerialTest {

    @IsTest
    private static void serialDate_positiveStep_expectSuccess() {
        Integer numRecords = 100;
        Date fromValue = Date.newInstance(2018, 1, 1);
        Integer stepValue = 5;

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, numRecords);
        obj.setDefinition('TestDate__c', 'Serial Type(Date) From(2018-01-01) Step(5)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Date expectedResult = fromValue.addDays((numRecords - 1) * stepValue);
        Date actualResult = records[numRecords - 1].TestDate__c;
        System.assertEquals(expectedResult, actualResult, 'serial date - errors found');
    }

    @IsTest
    private static void serialDate_negativeStep_expectSuccess() {
        Integer numRecords = 100;
        Date fromValue = Date.newInstance(2018, 1, 1);
        Integer stepValue = -5;

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, numRecords)
            .setDefinition('TestDate__c', 'Serial Type(Date) From(2018-01-01) Step(-5)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Date expectedResult = fromValue.addDays((numRecords - 1) * stepValue);
        Date actualResult = records[numRecords - 1].TestDate__c;
        System.assertEquals(expectedResult, actualResult, 'serial date - errors found');
    }

    @IsTest
    private static void serialDate_fromDatetime_expectSuccess() {
        Integer numRecords = 100;
        Date fromValue = Date.newInstance(2018, 1, 1);
        Integer stepValue = 2;

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, numRecords)
            .setDefinition('TestDate__c', 'Serial Type(Date) From(2018-01-01 02:02:02) Step(2)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Date expectedResult = fromValue.addDays((numRecords - 1) * stepValue);
        Date actualResult = records[numRecords - 1].TestDate__c;
        System.assertEquals(expectedResult, actualResult, 'serial date - errors found');
    }

    @IsTest
    private static void serialDate_decimalStep_expectFailure() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition('TestDate__c', 'Serial Type(Date) From(2018-01-01) Step(2.2)');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid definition [Serial Type(Date) ' +
            'From(2018-01-01) Step(2.2)] of field [TestDate__c]';
        String actualResult = obj.getErrors().get('TestDate__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'serial date - errors found');
    }

    @IsTest
    private static void serialDate_serializationInSameFObject_expectSuccess() {
        Integer numRecords = 10;

        Test.startTest();
        // create some serialized records
        FObject obj = new FObject(FObjectTwo__c.SObjectType, numRecords)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)')
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
        Integer numRecords = 10;

        Test.startTest();
        // create some serialized records
        FObject obj1 = new FObject(FObjectTwo__c.SObjectType, numRecords)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)')
            .setDefinition(FObjectTwo__c.TestTextUnique__c, 'serial type(date) from(2020-1-1) step(1)');
        obj1.getRecords();

        // create some more serialized records of a different FObject
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, numRecords)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)')
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

        Boolean result = FObject.processIsValid() && String.isBlank(errorMessage);
        System.assert(result, 'serial number - errors found');
    }

    @IsTest
    private static void serialDateVirtualField_valid_expectSuccess() {
        Integer numRecords = 10;
        Date fromValue = Date.newInstance(2018, 1, 1);
        Integer stepValue = 5;

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, numRecords)
            .setDefinition('$myTest1', 'serial type(date) from(2018-01-01) step(5)')
            .setDefinition(FObjectOne__c.TestDate__c, 'copy field($MYtest1)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Date expectedResult = fromValue.addDays((numRecords - 1) * stepValue);
        Date actualResult = records[numRecords - 1].TestDate__c;

        if (expectedResult != actualResult) {
            errors++;
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'virtual field - errors found');
    }

    @IsTest
    private static void serialDatetime_fromDatePositiveIntegerStep_expectSuccess() {
        Integer numRecords = 100;
        Datetime fromValue = Datetime.newInstance(2018, 1, 1);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, numRecords);
        obj.setDefinition('TestDatetime__c', 'serial type(datetime) from(2018-01-01) step(2)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Datetime expectedResult = fromValue.addDays((numRecords - 1) * 2);
        Datetime actualResult = records[numRecords - 1].TestDatetime__c;
        System.assertEquals(expectedResult, actualResult, 'serial datetime - errors found');
    }

    @IsTest
    private static void serialDatetime_fromDateNegativeIntegerStep_expectSuccess() {
        Integer numRecords = 100;
        Datetime fromValue = Datetime.newInstance(2018, 1, 1);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, numRecords);
        obj.setDefinition('TestDatetime__c', 'serial type(datetime) from(2018-01-01) step(-2)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Datetime expectedResult = fromValue.addDays((numRecords - 1) * (-2));
        Datetime actualResult = records[numRecords - 1].TestDatetime__c;
        System.assertEquals(expectedResult, actualResult, 'serial datetime - errors found');
    }

    @IsTest
    private static void serialDatetime_fromDatePositiveDecimalStep_expectSuccess() {
        Integer numRecords = 100;
        Datetime fromValue = Datetime.newInstance(2018, 1, 1);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, numRecords);
        obj.setDefinition('TestDatetime__c', 'serial type(datetime) from(2018-01-01) step(2.2)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Datetime expectedResult = fromValue.addDays((numRecords - 1) * 2);
        expectedResult = expectedResult.addHours((numRecords - 1) * 4);
        expectedResult = expectedResult.addMinutes((numRecords - 1) * 48);
        Datetime actualResult = records[numRecords - 1].TestDatetime__c;
        System.assertEquals(expectedResult, actualResult, 'serial datetime - errors found');
    }

    @IsTest
    private static void serialDatetime_fromDateNegativeDecimalStep_expectSuccess() {
        Integer numRecords = 100;
        Datetime fromValue = Datetime.newInstance(2018, 1, 1);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, numRecords);
        obj.setDefinition('TestDatetime__c', 'serial type(datetime) from(2018-01-01) step(-2.2)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Datetime expectedResult = fromValue.addDays((numRecords - 1) * (-2));
        expectedResult = expectedResult.addHours((numRecords - 1) * (-4));
        expectedResult = expectedResult.addMinutes((numRecords - 1) * (-48));
        Datetime actualResult = records[numRecords - 1].TestDatetime__c;
        System.assertEquals(expectedResult, actualResult, 'serial datetime - errors found');
    }

    @IsTest
    private static void serialDatetime_fromDatetimePositiveIntegerStep_expectSuccess() {
        Integer numRecords = 100;
        Datetime fromValue = Datetime.newInstance(2018, 1, 1, 2, 2, 2);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, numRecords);
        obj.setDefinition('TestDatetime__c', 'Serial Type(Datetime) From(2018-01-01 02:02:02) Step(2)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Datetime expectedResult = fromValue.addDays((numRecords - 1) * 2);
        Datetime actualResult = records[numRecords - 1].TestDatetime__c;
        System.assertEquals(expectedResult, actualResult, 'serial datetime - errors found');
    }

    @IsTest
    private static void serialDatetime_fromDatetimeNegativeIntegerStep_expectSuccess() {
        Integer numRecords = 100;
        Datetime fromValue = Datetime.newInstance(2018, 1, 1, 2, 2, 2);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, numRecords);
        obj.setDefinition('TestDatetime__c', 'Serial Type(Datetime) From(2018-01-01 02:02:02) Step(-2)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Datetime expectedResult = fromValue.addDays((numRecords - 1) * (-2));
        Datetime actualResult = records[numRecords - 1].TestDatetime__c;
        System.assertEquals(expectedResult, actualResult, 'serial datetime - errors found');
    }

    @IsTest
    private static void serialDatetime_fromDatetimePositiveDecimalStep_expectSuccess() {
        Integer numRecords = 100;
        Datetime fromValue = Datetime.newInstance(2018, 1, 1, 2, 2, 2);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, numRecords);
        obj.setDefinition('TestDatetime__c', 'Serial Type(Datetime) From(2018-01-01 02:02:02) Step(2.2)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Datetime expectedResult = fromValue.addDays((numRecords - 1) * 2);
        expectedResult = expectedResult.addHours((numRecords - 1) * 4);
        expectedResult = expectedResult.addMinutes((numRecords - 1) * 48);
        Datetime actualResult = records[numRecords - 1].TestDatetime__c;
        System.assertEquals(expectedResult, actualResult, 'serial datetime - errors found');
    }

    @IsTest
    private static void serialDatetime_fromDatetimeNegativeDecimalStep_expectSuccess() {
        Integer numRecords = 100;
        Datetime fromValue = Datetime.newInstance(2018, 1, 1, 2, 2, 2);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, numRecords);
        obj.setDefinition('TestDatetime__c', 'Serial Type(Datetime) From(2018-01-01 02:02:02) Step(-2.2)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Datetime expectedResult = fromValue.addDays((numRecords - 1) * (-2));
        expectedResult = expectedResult.addHours((numRecords - 1) * (-4));
        expectedResult = expectedResult.addMinutes((numRecords - 1) * (-48));
        Datetime actualResult = records[numRecords - 1].TestDatetime__c;
        System.assertEquals(expectedResult, actualResult, 'serial datetime - errors found');
    }

    @IsTest
    private static void serialDatetime_serializationInSameFObject_expectSuccess() {
        Integer numRecords = 10;

        Test.startTest();
        // create some serialized records
        FObject obj = new FObject(FObjectTwo__c.SObjectType, numRecords)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)')
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
        Integer numRecords = 10;

        Test.startTest();
        // create some serialized records
        FObject obj1 = new FObject(FObjectTwo__c.SObjectType, numRecords)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)')
            .setDefinition(FObjectTwo__c.TestTextUnique__c,
                'serial type(datetime) from(2020-1-1 10:11:12) step(1)');
        obj1.getRecords();

        // create some more serialized records of a different FObject
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, numRecords)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)')
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

        Boolean result = FObject.processIsValid() && String.isBlank(errorMessage);
        System.assert(result, 'serial number - errors found');
    }

    @IsTest
    private static void serialDatetimeVirtualField_valid_expectSuccess() {
        Integer numRecords = 100;
        Datetime fromValue = Datetime.newInstance(2018, 1, 1);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, numRecords)
            .setDefinition('$Test', 'serial type(datetime) from(2018-01-01) step(2)')
            .setDefinition(FObjectOne__c.TestDatetime__c, 'copy field($Test)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Datetime expectedResult = fromValue.addDays((numRecords - 1) * 2);
        Datetime actualResult = records[numRecords - 1].TestDatetime__c;
        System.assertEquals(expectedResult, actualResult, 'serial datetime - errors found');
    }

    @IsTest
    private static void serialList_cyclical_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 30)
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(list) value(a1,a2,a3) mode(cyclical)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        List<String> values = new List<String>{
            'a1', 'a2', 'a3'
        };

        Integer errors = 0;
        Integer counter = 0;
        for (FObjectOne__c objRecord : records) {
            if (objRecord.TestText__c != values.get(counter)) {
                errors++;
            }
            counter++;
            if (counter == values.size()) {
                counter = 0;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'serial list - errors found');
    }

    @IsTest
    private static void serialList_cyclicalBlankMode_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 30)
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(list) value(a1,a2,a3) mode()')
            .createRecords();
        Test.stopTest();

        Integer errors = 0;
        if (obj.getErrors().get('TestText__c').isEmpty() ||
            !obj.getErrors().get('TestText__c').get(0).startsWith(ForceeaService.MESSAGE_INVALID_DEFINITION)) {
            errors += 1;
        }
        if (FObject.processIsValid()) {
            errors += 2;
        }
        System.assertEquals(0, errors, 'serial list - errors found');
    }

    @IsTest
    private static void serialList_cyclicalInvalidMode_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 30)
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(list) value(a1,a2,a3) mode(xyz)')
            .createRecords();
        Test.stopTest();

        Integer errors = 0;
        if (obj.getErrors().get('TestText__c').isEmpty() ||
            !obj.getErrors().get('TestText__c').get(0).startsWith(ForceeaService.MESSAGE_INVALID_DEFINITION)) {
            errors += 1;
        }
        if (FObject.processIsValid()) {
            errors += 2;
        }
        System.assertEquals(0, errors, 'serial list - errors found');
    }

    @IsTest
    private static void serialListVirtualField_cyclical_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 30)
            .setDefinition('$Test', 'serial type(list) value(a1,a2,a3) mode(cyclical)')
            .setDefinition(FObjectOne__c.TestText__c, 'copy field($Test)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        List<String> values = new List<String>{
            'a1', 'a2', 'a3'
        };

        Integer errors = 0;
        Integer counter = 0;
        for (FObjectOne__c objRecord : records) {
            if (objRecord.TestText__c != values.get(counter)) {
                errors++;
            }
            counter++;
            if (counter == values.size()) {
                counter = 0;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'serial list - errors found');
    }

    @IsTest
    private static void serialList_first_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 30)
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(list) value(a1,a2,a3) mode(first)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        List<String> values = new List<String>{
            'a1', 'a2', 'a3'
        };

        Integer errors = 0;
        Integer counter = 0;
        Integer index = 0;
        for (FObjectOne__c objRecord : records) {
            if (objRecord.TestText__c != values.get(index)) {
                errors++;
            }
            counter++;
            index++;
            if (counter >= values.size()) {
                index = 0;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'serial list - errors found');
    }

    @IsTest
    private static void serialListVirtualField_first_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 30)
            .setDefinition('$Test', 'serial type(list) value(a1,a2,a3) mode(first)')
            .setDefinition(FObjectOne__c.TestText__c, 'copy field($Test)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        List<String> values = new List<String>{
            'a1', 'a2', 'a3'
        };

        Integer errors = 0;
        Integer counter = 0;
        Integer index = 0;
        for (FObjectOne__c objRecord : records) {
            if (objRecord.TestText__c != values.get(index)) {
                errors++;
            }
            counter++;
            index++;
            if (counter >= values.size()) {
                index = 0;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'serial list - errors found');
    }

    @IsTest
    private static void serialList_last_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 30)
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(list) value(a1,a2,a3) mode(last)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        List<String> values = new List<String>{
            'a1', 'a2', 'a3'
        };

        Integer errors = 0;
        Integer counter = 0;
        Integer index = 0;
        for (FObjectOne__c objRecord : records) {
            if (objRecord.TestText__c != values.get(index)) {
                errors++;
            }
            counter++;
            index++;
            if (counter >= values.size()) {
                index = values.size() - 1;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'serial list - errors found');
    }

    @IsTest
    private static void serialListVirtualField_last_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 30)
            .setDefinition('$Test', 'serial type(list) value(a1,a2,a3) mode(last)')
            .setDefinition(FObjectOne__c.TestText__c, 'copy field($Test)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        List<String> values = new List<String>{
            'a1', 'a2', 'a3'
        };

        Integer errors = 0;
        Integer counter = 0;
        Integer index = 0;
        for (FObjectOne__c objRecord : records) {
            if (objRecord.TestText__c != values.get(index)) {
                errors++;
            }
            counter++;
            index++;
            if (counter >= values.size()) {
                index = values.size() - 1;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'serial list - errors found');
    }

    @IsTest
    private static void serialList_null_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 30)
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(list) value(a1,a2,a3) mode(null)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        List<String> values = new List<String>{
            'a1', 'a2', 'a3'
        };

        Integer errors = 0;
        Integer counter = 0;
        String str = '';
        for (FObjectOne__c objRecord : records) {
            if (counter < values.size()) {
                str = values.get(counter);
            } else {
                str = '';
            }
            if ((String.isNotBlank(objRecord.TestText__c) && objRecord.TestText__c != str) ||
                (String.isBlank(objRecord.TestText__c) && String.isNotBlank(str))) {
                errors++;
            }
            counter++;
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'serial list - errors found');
    }

    @IsTest
    private static void serialListVirtualField_null_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType)
            .setDefinition('$Test', 'serial type(list) value(a1,a2,a3) mode(null)')
            .setDefinition(FObjectOne__c.TestText__c, 'copy field($Test)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        List<String> values = new List<String>{
            'a1', 'a2', 'a3'
        };

        Integer errors = 0;
        Integer counter = 0;
        String str = '';
        for (FObjectOne__c objRecord : records) {
            if (counter < values.size()) {
                str = values.get(counter);
            } else {
                str = '';
            }
            if ((String.isNotBlank(objRecord.TestText__c) && objRecord.TestText__c != str) ||
                (String.isBlank(objRecord.TestText__c) && String.isNotBlank(str))) {
                errors++;
            }
            counter++;
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'serial list - errors found');
    }

    @IsTest
    private static void serialList_permutation_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType)
            .setNumberOfRecords('auto')
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(list) value(a1,a2,a3) mode(permutation)')
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(list) value(b1,b2,b3) mode(permutation)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        List<String> values1 = new List<String>{
            'a1', 'a2', 'a3'
        };
        List<String> values2 = new List<String>{
            'b1', 'b2', 'b3'
        };

        Integer errors = 0;
        Integer counter1 = 0;
        Integer counter2 = 0;
        for (FObjectOne__c objRecord : records) {
            String str1 = values1.get(counter1);
            String str2 = values2.get(counter2);
            String str = str1 + str2;
            if (str != objRecord.TestText__c) {
                errors++;
            }

            counter2++;
            if (counter2 == values2.size()) {
                counter2 = 0;
                counter1++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'serial list - errors found');
    }

    @IsTest
    private static void serialListVirtualField_permutation_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType)
            .setNumberOfRecords('auto')
            .setDefinition('$Test', 'serial type(list) value(a1,a2,a3) mode(permutation)')
            .setDefinition('$Test', 'serial type(list) value(b1,b2,b3) mode(permutation)')
            .setDefinition(FObjectOne__c.TestText__c, 'copy field($Test)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        List<String> values1 = new List<String>{
            'a1', 'a2', 'a3'
        };
        List<String> values2 = new List<String>{
            'b1', 'b2', 'b3'
        };

        Integer errors = 0;
        Integer counter1 = 0;
        Integer counter2 = 0;
        for (FObjectOne__c objRecord : records) {
            String str1 = values1.get(counter1);
            String str2 = values2.get(counter2);
            String str = str1 + str2;
            if (str != objRecord.TestText__c) {
                errors++;
            }

            counter2++;
            if (counter2 == values2.size()) {
                counter2 = 0;
                counter1++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'serial list - errors found');
    }

    @IsTest
    private static void serialLookup_cyclicalForceea_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        obj2.insertRecords(true);
        List<Id> lookupIds = ForceeaUtilityTest.getLookupIds(obj2);

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 20)
            .setDefinition(FObjectOne__c.TestLookup__c, 'serial lookup(FObjectTwo__c) mode(cyclical) source(forceea)');
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Integer counter = 0;
        for (FObjectOne__c objRecord : records1) {
            if (objRecord.TestLookup__c != lookupIds.get(counter)) {
                errors++;
            }
            counter++;
            if (counter == lookupIds.size()) {
                counter = 0;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'serial lookup - errors found');
    }

    @IsTest
    private static void serialLookupVirtualField_cyclicalForceea_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        obj2.insertRecords(true);
        List<Id> lookupIds = ForceeaUtilityTest.getLookupIds(obj2);

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 20)
            .setDefinition('$Lookup', 'serial lookup(FObjectTwo__c) mode(cyclical) source(forceea)')
            .setDefinition(FObjectOne__c.TestLookup__c, 'copy field($Lookup)');
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Integer counter = 0;
        for (FObjectOne__c objRecord : records1) {
            if (objRecord.TestLookup__c != lookupIds.get(counter)) {
                errors++;
            }
            counter++;
            if (counter == lookupIds.size()) {
                counter = 0;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'serial lookup - errors found');
    }

    @IsTest
    private static void serialLookup_firstForceea_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        obj2.insertRecords(true);
        List<Id> lookupIds = ForceeaUtilityTest.getLookupIds(obj2);

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 20)
            .setDefinition(FObjectOne__c.TestLookup__c, 'serial lookup(FObjectTwo__c) mode(first) source(forceea)');
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Integer counter = 0;
        Integer lookupListSize = lookupIds.size();
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
    private static void serialLookupVirtualField_firstForceea_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        obj2.insertRecords(true);
        List<Id> lookupIds = ForceeaUtilityTest.getLookupIds(obj2);

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 20)
            .setDefinition('$Lookup', 'serial lookup(FObjectTwo__c) mode(first) source(forceea)')
            .setDefinition(FObjectOne__c.TestLookup__c, 'copy field($Lookup)');
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Integer counter = 0;
        Integer lookupListSize = lookupIds.size();
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
    private static void serialLookup_lastForceea_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        obj2.insertRecords(true);
        List<Id> lookupIds = ForceeaUtilityTest.getLookupIds(obj2);

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 20)
            .setDefinition(FObjectOne__c.TestLookup__c, 'serial lookup(FObjectTwo__c) mode(last) source(forceea)');
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Integer counter = 0;
        Integer lookupListSize = lookupIds.size();
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
    private static void serialLookupVirtualField_lastForceea_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        obj2.insertRecords(true);
        List<Id> lookupIds = ForceeaUtilityTest.getLookupIds(obj2);

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 20)
            .setDefinition('$Lookup', 'serial lookup(FObjectTwo__c) mode(last) source(forceea)')
            .setDefinition(FObjectOne__c.TestLookup__c, 'copy field($Lookup)');
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Integer counter = 0;
        Integer lookupListSize = lookupIds.size();
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
    private static void serialLookup_nullForceea_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        obj2.insertRecords(true);
        List<Id> lookupIds = ForceeaUtilityTest.getLookupIds(obj2);

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 20)
            .setDefinition(FObjectOne__c.TestLookup__c, 'serial lookup(FObjectTwo__c) mode(null) source(forceea)');
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Integer counter = 0;
        Integer lookupListSize = lookupIds.size();
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
    private static void serialLookupVirtualField_nullForceea_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        obj2.insertRecords(true);
        List<Id> lookupIds = ForceeaUtilityTest.getLookupIds(obj2);

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 20)
            .setDefinition('$Lookup', 'serial lookup(FObjectTwo__c) mode(null) source(forceea)')
            .setDefinition(FObjectOne__c.TestLookup__c, 'copy field($Lookup)');
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Integer counter = 0;
        Integer lookupListSize = lookupIds.size();
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
    private static void serialLookup_permutationForceea_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        obj2.insertRecords(true);
        List<Id> lookupIds = ForceeaUtilityTest.getLookupIds(obj2);

        List<String> values = new List<String>{
            'a1', 'a2', 'a3'
        };

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType)
            .setNumberOfRecords('auto')
            .setDefinition(FObjectOne__c.TestLookup__c, 'serial lookup(FObjectTwo__c) mode(permutation) source(forceea)')
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(list) value(a1,a2,a3) mode(permutation)');
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Integer counter1 = 0;
        Integer counter2 = 0;
        for (FObjectOne__c objRecord : records1) {
            String str1 = lookupIds.get(counter1);
            String str2 = values.get(counter2);
            if (str1 != objRecord.TestLookup__c || str2 != objRecord.TestText__c) {
                errors++;
            }

            counter2++;
            if (counter2 == values.size()) {
                counter2 = 0;
                counter1++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'serial lookup - errors found');
    }

    @IsTest
    private static void serialLookupVirtualField_permutationForceea_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        obj2.insertRecords(true);
        List<Id> lookupIds = ForceeaUtilityTest.getLookupIds(obj2);

        List<String> values = new List<String>{
            'a1', 'a2', 'a3'
        };

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType)
            .setNumberOfRecords('auto')
            .setDefinition('$Lookup', 'serial lookup(FObjectTwo__c) mode(permutation) source(forceea)')
            .setDefinition('$Text', 'serial type(list) value(a1,a2,a3) mode(permutation)')
            .setDefinition(FObjectOne__c.TestLookup__c, 'copy field($Lookup)')
            .setDefinition(FObjectOne__c.TestText__c, 'copy field($Text)');
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Integer counter1 = 0;
        Integer counter2 = 0;
        for (FObjectOne__c objRecord : records1) {
            String str1 = lookupIds.get(counter1);
            String str2 = values.get(counter2);
            if (str1 != objRecord.TestLookup__c || str2 != objRecord.TestText__c) {
                errors++;
            }

            counter2++;
            if (counter2 == values.size()) {
                counter2 = 0;
                counter1++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'serial lookup - errors found');
    }

    @IsTest
    private static void serialLookup_cyclicalGroupForceea_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        obj2.insertRecords(true, 'one');
        List<Id> lookupIds = ForceeaUtilityTest.getLookupIds(obj2);

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 20)
            .setDefinition(FObjectOne__c.TestLookup__c, 'serial lookup(FObjectTwo__c) mode(cyclical) group(one) source(forceea)');
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Integer counter = 0;
        for (FObjectOne__c objRecord : records1) {
            if (objRecord.TestLookup__c != lookupIds.get(counter)) {
                errors++;
            }
            counter++;
            if (counter == lookupIds.size()) {
                counter = 0;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'serial lookup - errors found');
    }

    @IsTest
    private static void serialLookup_firstGroupForceea_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        obj2.insertRecords(true, 'one');
        List<Id> lookupIds = ForceeaUtilityTest.getLookupIds(obj2);

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 20);
        obj1.setDefinition(FObjectOne__c.TestLookup__c, 'serial lookup(FObjectTwo__c) mode(first) group(one) source(forceea)');
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Integer counter = 0;
        Integer lookupListSize = lookupIds.size();
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
    private static void serialLookup_lastGroupForceea_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        obj2.insertRecords(true, 'one');
        List<Id> lookupIds = ForceeaUtilityTest.getLookupIds(obj2);

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 20);
        obj1.setDefinition(FObjectOne__c.TestLookup__c, 'serial lookup(FObjectTwo__c) mode(last) group(one) source(forceea)');
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Integer counter = 0;
        Integer lookupListSize = lookupIds.size();
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
    private static void serialLookup_nullGroupForceea_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        obj2.insertRecords(true, 'one');
        List<Id> lookupIds = ForceeaUtilityTest.getLookupIds(obj2);

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 20);
        obj1.setDefinition(FObjectOne__c.TestLookup__c, 'serial lookup(FObjectTwo__c) mode(null) group(one) source(forceea)');
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Integer counter = 0;
        Integer lookupListSize = lookupIds.size();
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
    private static void serialLookup_permutationGroupForceea_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        obj2.insertRecords(true, 'one');
        List<Id> lookupIds = ForceeaUtilityTest.getLookupIds(obj2);

        List<String> values = new List<String>{
            'a1', 'a2', 'a3'
        };

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType)
            .setNumberOfRecords('auto')
            .setDefinition(FObjectOne__c.TestLookup__c, 'serial lookup(FObjectTwo__c) mode(permutation) group(one) source(forceea)')
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(list) value(a1,a2,a3) mode(permutation)');
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Integer counter1 = 0;
        Integer counter2 = 0;
        for (FObjectOne__c objRecord : records1) {
            String str1 = lookupIds.get(counter1);
            String str2 = values.get(counter2);
            if (str1 != objRecord.TestLookup__c || str2 != objRecord.TestText__c) {
                errors++;
            }

            counter2++;
            if (counter2 == values.size()) {
                counter2 = 0;
                counter1++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'serial lookup - errors found');
    }

    @IsTest
    private static void serialLookup_cyclicalSalesforce_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        obj2.insertRecords(true);
        List<Id> lookupIds = ForceeaUtilityTest.getLookupIds(obj2);

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 20)
            .setDefinition(FObjectOne__c.TestLookup__c, 'serial lookup(FObjectTwo__c) mode(cyclical) source(salesforce)');
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Integer counter = 0;
        for (FObjectOne__c objRecord : records1) {
            if (objRecord.TestLookup__c != lookupIds.get(counter)) {
                errors++;
            }
            counter++;
            if (counter == lookupIds.size()) {
                counter = 0;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'serial lookup - errors found');
    }

    @IsTest
    private static void serialLookupVirtualField_cyclicalSalesforce_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        obj2.insertRecords(true);
        List<Id> lookupIds = ForceeaUtilityTest.getLookupIds(obj2);

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 20)
            .setDefinition('$Lookup', 'serial lookup(FObjectTwo__c) mode(cyclical) source(salesforce)')
            .setDefinition(FObjectOne__c.TestLookup__c, 'copy field($Lookup)');
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Integer counter = 0;
        for (FObjectOne__c objRecord : records1) {
            if (objRecord.TestLookup__c != lookupIds.get(counter)) {
                errors++;
            }
            counter++;
            if (counter == lookupIds.size()) {
                counter = 0;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'serial lookup - errors found');
    }

    @IsTest
    private static void serialLookup_firstSalesforce_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        obj2.insertRecords(true);
        List<Id> lookupIds = ForceeaUtilityTest.getLookupIds(obj2);

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 20)
            .setDefinition(FObjectOne__c.TestLookup__c, 'serial lookup(FObjectTwo__c) mode(first) source(salesforce)');
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Integer counter = 0;
        Integer lookupListSize = lookupIds.size();
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
    private static void serialLookupVirtualField_firstSalesforce_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        obj2.insertRecords(true);
        List<Id> lookupIds = ForceeaUtilityTest.getLookupIds(obj2);

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 20)
            .setDefinition('$Lookup', 'serial lookup(FObjectTwo__c) mode(first) source(salesforce)')
            .setDefinition(FObjectOne__c.TestLookup__c, 'copy field($Lookup)');
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Integer counter = 0;
        Integer lookupListSize = lookupIds.size();
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
    private static void serialLookup_lastSalesforce_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        obj2.insertRecords(true, 'one');
        List<Id> lookupIds = ForceeaUtilityTest.getLookupIds(obj2);

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 20)
            .setDefinition(FObjectOne__c.TestLookup__c, 'serial lookup(FObjectTwo__c) mode(last) source(salesforce)');
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Integer counter = 0;
        Integer lookupListSize = lookupIds.size();
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
    private static void serialLookupVirtualField_lastSalesforce_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        obj2.insertRecords(true, 'one');
        List<Id> lookupIds = ForceeaUtilityTest.getLookupIds(obj2);

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 20)
            .setDefinition('$Lookup', 'serial lookup(FObjectTwo__c) mode(last) source(salesforce)')
            .setDefinition(FObjectOne__c.TestLookup__c, 'copy field($Lookup)');
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Integer counter = 0;
        Integer lookupListSize = lookupIds.size();
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
    private static void serialLookup_nullSalesforce_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        obj2.insertRecords(true);
        List<Id> lookupIds = ForceeaUtilityTest.getLookupIds(obj2);

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 20)
            .setDefinition(FObjectOne__c.TestLookup__c, 'serial lookup(FObjectTwo__c) mode(null) source(salesforce)');
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Integer counter = 0;
        Integer lookupListSize = lookupIds.size();
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
    private static void serialLookupVirtualField_nullSalesforce_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        obj2.insertRecords(true);
        List<Id> lookupIds = ForceeaUtilityTest.getLookupIds(obj2);

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 20)
            .setDefinition('$Lookup', 'serial lookup(FObjectTwo__c) mode(null) source(salesforce)')
            .setDefinition(FObjectOne__c.TestLookup__c, 'copy field($Lookup)');
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Integer counter = 0;
        Integer lookupListSize = lookupIds.size();
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
    private static void serialLookup_permutationSalesforce_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        obj2.insertRecords(true);
        List<Id> lookupIds = ForceeaUtilityTest.getLookupIds(obj2);

        List<String> values = new List<String>{
            'a1', 'a2', 'a3'
        };

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType)
            .setNumberOfRecords('auto')
            .setDefinition(FObjectOne__c.TestLookup__c, 'serial lookup(FObjectTwo__c) mode(permutation) source(salesforce)')
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(list) value(a1,a2,a3) mode(permutation)');
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Integer counter1 = 0;
        Integer counter2 = 0;
        for (FObjectOne__c objRecord : records1) {
            String str1 = lookupIds.get(counter1);
            String str2 = values.get(counter2);
            if (str1 != objRecord.TestLookup__c || str2 != objRecord.TestText__c) {
                errors++;
            }

            counter2++;
            if (counter2 == values.size()) {
                counter2 = 0;
                counter1++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'serial lookup - errors found');
    }

    @IsTest
    private static void serialLookupVirtualField_permutationSalesforce_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        obj2.insertRecords(true);
        List<Id> lookupIds = ForceeaUtilityTest.getLookupIds(obj2);

        List<String> values = new List<String>{
            'a1', 'a2', 'a3'
        };

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType)
            .setNumberOfRecords('auto')
            .setDefinition('$Lookup', 'serial lookup(FObjectTwo__c) mode(permutation) source(salesforce)')
            .setDefinition('$Text', 'serial type(list) value(a1,a2,a3) mode(permutation)')
            .setDefinition(FObjectOne__c.TestLookup__c, 'copy field($Lookup)')
            .setDefinition(FObjectOne__c.TestText__c, 'copy field($Text)');
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Integer counter1 = 0;
        Integer counter2 = 0;
        for (FObjectOne__c objRecord : records1) {
            String str1 = lookupIds.get(counter1);
            String str2 = values.get(counter2);
            if (str1 != objRecord.TestLookup__c || str2 != objRecord.TestText__c) {
                errors++;
            }

            counter2++;
            if (counter2 == values.size()) {
                counter2 = 0;
                counter1++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'serial lookup - errors found');
    }

    @IsTest
    private static void serialLookupField_cyclicalForceea_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)')
            .setDefinition(FObjectTwo__c.TestText__c, 'serial type(list) value(a1,a2,a3) mode(cyclical)');
        obj2.insertRecords(true);
        List<Id> lookupIds = ForceeaUtilityTest.getLookupIds(obj2, new List<String>{
            'a1', 'a3'
        });

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 20)
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .setDefinition(FObjectOne__c.TestLookup__c,
                'serial lookup(FObjectTwo__c) field(TestText__c) value(a3,a1) mode(cyclical) source(forceea)');
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();
        obj1.insertRecords(true);

        Integer counter = 0;
        Integer errors = 0;
        for (FObjectOne__c objRecord : records1) {
            if (objRecord.TestLookup__c != lookupIds.get(counter)) {
                errors++;
            }
            counter++;
            if (counter == lookupIds.size()) {
                counter = 0;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'serial lookup - errors found');
    }

    @IsTest
    private static void serialLookupFieldVirtualField_cyclicalForceea_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)')
            .setDefinition(FObjectTwo__c.TestText__c, 'serial type(list) value(a1,a2,a3) mode(cyclical)');
        obj2.insertRecords(true);
        List<Id> lookupIds = ForceeaUtilityTest.getLookupIds(obj2, new List<String>{
            'a1', 'a3'
        });

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 20)
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .setDefinition('$Lookup',
                'serial lookup(FObjectTwo__c) field(TestText__c) value(a3,a1) mode(cyclical) source(forceea)')
            .setDefinition(FObjectOne__c.TestLookup__c, 'copy field($Lookup)');
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();
        obj1.insertRecords(true);

        Integer counter = 0;
        Integer errors = 0;
        for (FObjectOne__c objRecord : records1) {
            if (objRecord.TestLookup__c != lookupIds.get(counter)) {
                errors++;
            }
            counter++;
            if (counter == lookupIds.size()) {
                counter = 0;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'serial lookup - errors found');
    }

    @IsTest
    private static void serialLookupField_firstForceea_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)')
            .setDefinition(FObjectTwo__c.TestText__c, 'serial type(list) value(a1,a2,a3) mode(cyclical)');
        obj2.insertRecords(true);
        List<Id> lookupIds = ForceeaUtilityTest.getLookupIds(obj2, new List<String>{
            'a1', 'a3'
        });

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 20)
            .setDefinition(FObjectOne__c.TestLookup__c,
                'serial lookup(FObjectTwo__c) field(TestText__c) value(a3,a1) mode(first) source(forceea)');
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();

        Integer counter = 0;
        Integer errors = 0;
        Integer lookupListSize = lookupIds.size();
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
    private static void serialLookupFieldVirtualField_firstForceea_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)')
            .setDefinition(FObjectTwo__c.TestText__c, 'serial type(list) value(a1,a2,a3) mode(cyclical)');
        obj2.insertRecords(true);
        List<Id> lookupIds = ForceeaUtilityTest.getLookupIds(obj2, new List<String>{
            'a1', 'a3'
        });

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 20)
            .setDefinition('$Lookup',
                'serial lookup(FObjectTwo__c) field(TestText__c) value(a3,a1) mode(first) source(forceea)')
            .setDefinition(FObjectOne__c.TestLookup__c, 'copy field($Lookup)');
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();

        Integer counter = 0;
        Integer errors = 0;
        Integer lookupListSize = lookupIds.size();
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
    private static void serialLookupField_lastForceea_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)')
            .setDefinition(FObjectTwo__c.TestText__c, 'serial type(list) value(a1,a2,a3) mode(cyclical)');
        obj2.insertRecords(true);
        List<Id> lookupIds = ForceeaUtilityTest.getLookupIds(obj2, new List<String>{
            'a1', 'a3'
        });

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 20)
            .setDefinition(FObjectOne__c.TestLookup__c,
                'serial lookup(FObjectTwo__c) field(TestText__c) value(a3,a1) mode(last) source(forceea)');
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();

        Integer counter = 0;
        Integer errors = 0;
        Integer lookupListSize = lookupIds.size();
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
    private static void serialLookupFieldVirtualField_lastForceea_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)')
            .setDefinition(FObjectTwo__c.TestText__c, 'serial type(list) value(a1,a2,a3) mode(cyclical)');
        obj2.insertRecords(true);
        List<Id> lookupIds = ForceeaUtilityTest.getLookupIds(obj2, new List<String>{
            'a1', 'a3'
        });

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 20)
            .setDefinition('$Lookup',
                'serial lookup(FObjectTwo__c) field(TestText__c) value(a3,a1) mode(last) source(forceea)')
            .setDefinition(FObjectOne__c.TestLookup__c, 'copy field($Lookup)');
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();

        Integer counter = 0;
        Integer errors = 0;
        Integer lookupListSize = lookupIds.size();
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
    private static void serialLookupField_nullForceea_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)')
            .setDefinition(FObjectTwo__c.TestText__c, 'serial type(list) value(a1,a2,a3) mode(cyclical)');
        obj2.insertRecords(true);
        List<Id> lookupIds = ForceeaUtilityTest.getLookupIds(obj2, new List<String>{
            'a1', 'a3'
        });

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 20)
            .setDefinition(FObjectOne__c.TestLookup__c,
                'serial lookup(FObjectTwo__c) field(TestText__c) value(a3,a1) mode(null) source(forceea)');
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Integer counter = 0;
        Integer lookupListSize = lookupIds.size();
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
    private static void serialLookupFieldVirtualField_nullForceea_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)')
            .setDefinition(FObjectTwo__c.TestText__c, 'serial type(list) value(a1,a2,a3) mode(cyclical)');
        obj2.insertRecords(true);
        List<Id> lookupIds = ForceeaUtilityTest.getLookupIds(obj2, new List<String>{
            'a1', 'a3'
        });

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 20)
            .setDefinition('$Lookup',
                'serial lookup(FObjectTwo__c) field(TestText__c) value(a3,a1) mode(null) source(forceea)')
            .setDefinition(FObjectOne__c.TestLookup__c, 'copy field($Lookup)');
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Integer counter = 0;
        Integer lookupListSize = lookupIds.size();
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
    private static void serialLookupField_permutationForceea_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)')
            .setDefinition(FObjectTwo__c.TestText__c, 'serial type(list) value(a1,a2,a3) mode(cyclical)');
        obj2.insertRecords(true);
        List<Id> lookupIds = ForceeaUtilityTest.getLookupIds(obj2, new List<String>{
            'a1', 'a3'
        });

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 20)
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .setNumberOfRecords('auto')
            .setDefinition(FObjectOne__c.TestLookup__c,
                'serial lookup(FObjectTwo__c) field(TestText__c) value(a3,a1) mode(permutation) source(forceea)');
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        obj1.insertRecords(true);
        Test.stopTest();

        Integer errors = 0;
        Integer counter = 0;
        Integer lookupListSize = lookupIds.size();
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
    private static void serialLookupFieldVirtualField_permutationForceea_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)')
            .setDefinition(FObjectTwo__c.TestText__c, 'serial type(list) value(a1,a2,a3) mode(cyclical)');
        obj2.insertRecords(true);
        List<Id> lookupIds = ForceeaUtilityTest.getLookupIds(obj2, new List<String>{
            'a1', 'a3'
        });

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 20)
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .setDefinition('$Lookup',
                'serial lookup(FObjectTwo__c) field(TestText__c) value(a3,a1) mode(null) source(forceea)')
            .setDefinition(FObjectOne__c.TestLookup__c, 'copy field($Lookup)');
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        obj1.insertRecords(true);
        Test.stopTest();

        Integer errors = 0;
        Integer counter = 0;
        Integer lookupListSize = lookupIds.size();
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
    private static void serialLookupField_cyclicalSalesforce_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)')
            .setDefinition(FObjectTwo__c.TestText__c, 'serial type(list) value(a1,a2,a3) mode(cyclical)');
        obj2.insertRecords(true);
        List<Id> lookupIds = ForceeaUtilityTest.getLookupIds(obj2, new List<String>{
            'a1', 'a3'
        });

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 20)
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .setDefinition(FObjectOne__c.TestLookup__c,
                'serial lookup(FObjectTwo__c) field(TestText__c) value(a3,a1) mode(cyclical) source(salesforce)');
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();
        obj1.insertRecords(true);

        Integer counter = 0;
        Integer errors = 0;
        for (FObjectOne__c objRecord : records1) {
            if (objRecord.TestLookup__c != lookupIds.get(counter)) {
                errors++;
            }
            counter++;
            if (counter == lookupIds.size()) {
                counter = 0;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'serial lookup - errors found');
    }

    @IsTest
    private static void serialLookupFieldVirtualField_cyclicalSalesforce_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)')
            .setDefinition(FObjectTwo__c.TestText__c, 'serial type(list) value(a1,a2,a3) mode(cyclical)');
        obj2.insertRecords(true);
        List<Id> lookupIds = ForceeaUtilityTest.getLookupIds(obj2, new List<String>{
            'a1', 'a3'
        });

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 20)
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .setDefinition('$Lookup',
                'serial lookup(FObjectTwo__c) field(TestText__c) value(a3,a1) mode(cyclical) source(salesforce)')
            .setDefinition(FObjectOne__c.TestLookup__c, 'copy field($Lookup)');
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();
        obj1.insertRecords(true);

        Integer counter = 0;
        Integer errors = 0;
        for (FObjectOne__c objRecord : records1) {
            if (objRecord.TestLookup__c != lookupIds.get(counter)) {
                errors++;
            }
            counter++;
            if (counter == lookupIds.size()) {
                counter = 0;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'serial lookup - errors found');
    }

    @IsTest
    private static void serialLookupFieldExcept_cyclicalForceea_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)')
            .setDefinition(FObjectTwo__c.TestText__c, 'serial type(list) value(a1,a2,a3) mode(cyclical)');
        obj2.insertRecords(true);
        List<Id> lookupIds = ForceeaUtilityTest.getLookupIds(obj2, new List<String>{
            'a1'
        });

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 20)
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .setDefinition(FObjectOne__c.TestLookup__c,
                'serial lookup(FObjectTwo__c) field(TestText__c) except(a3,a2) mode(cyclical) source(forceea)');
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();
        obj1.insertRecords(true);

        Integer counter = 0;
        Integer errors = 0;
        for (FObjectOne__c objRecord : records1) {
            if (objRecord.TestLookup__c != lookupIds.get(counter)) {
                errors++;
            }
            counter++;
            if (counter == lookupIds.size()) {
                counter = 0;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'serial lookup - errors found');
    }

    @IsTest
    private static void serialLookupFieldExcept_firstForceea_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)')
            .setDefinition(FObjectTwo__c.TestText__c, 'serial type(list) value(a1,a2,a3) mode(cyclical)');
        obj2.insertRecords(true);
        List<Id> lookupIds = ForceeaUtilityTest.getLookupIds(obj2, new List<String>{
            'a1'
        });

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 20)
            .setDefinition(FObjectOne__c.TestLookup__c,
                'serial lookup(FObjectTwo__c) field(TestText__c) except(a3,a2) mode(first) source(forceea)');
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();

        Integer counter = 0;
        Integer errors = 0;
        Integer lookupListSize = lookupIds.size();
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
    private static void serialLookupFieldExcept_cyclicalSalesforce_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)')
            .setDefinition(FObjectTwo__c.TestText__c, 'serial type(list) value(a1,a2,a3) mode(cyclical)');
        obj2.insertRecords(true);
        List<Id> lookupIds = ForceeaUtilityTest.getLookupIds(obj2, new List<String>{
            'a1'
        });

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 20)
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .setDefinition(FObjectOne__c.TestLookup__c,
                'serial lookup(FObjectTwo__c) field(TestText__c) except(a3,a2) mode(cyclical) source(salesforce)');
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();
        obj1.insertRecords(true);

        Integer counter = 0;
        Integer errors = 0;
        for (FObjectOne__c objRecord : records1) {
            if (objRecord.TestLookup__c != lookupIds.get(counter)) {
                errors++;
            }
            counter++;
            if (counter == lookupIds.size()) {
                counter = 0;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'serial lookup - errors found');
    }

    @IsTest
    private static void serialLookupFieldExcept_permutationForceea_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)')
            .setDefinition(FObjectTwo__c.TestText__c, 'serial type(list) value(a1,a2,a3) mode(cyclical)');
        obj2.insertRecords(true);
        List<Id> lookupIds = ForceeaUtilityTest.getLookupIds(obj2, new List<String>{
            'a1'
        });

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 20)
            .setNumberOfRecords('auto')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .setDefinition(FObjectOne__c.TestLookup__c,
                'serial lookup(FObjectTwo__c) field(TestText__c) except(a3,a2) mode(permutation) source(forceea)');
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        obj1.insertRecords(true);
        Test.stopTest();

        Integer errors = 0;
        Integer counter = 0;
        Integer lookupListSize = lookupIds.size();
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
    private static void serialLookupWhere_cyclicalSalesforce_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)')
            .setDefinition(FObjectTwo__c.TestIntegerUnique__c, 'serial type(number) from(1) step(1) scale(0)');
        obj2.insertRecords(true);
        List<Id> lookupIds = ForceeaUtilityTest.getLookupIdsFromIntegerUnique(obj2);

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 20)
            .setDefinition(FObjectOne__c.TestLookup__c,
                'serial lookup(FObjectTwo__c) where(TestIntegerUnique__c < 6) mode(cyclical) source(salesforce)');
        Test.stopTest();

        Integer errors = 0;
        Integer counter = 0;
        for (FObjectOne__c objRecord : (List<FObjectOne__c>) obj1.getRecords()) {
            if (objRecord.TestLookup__c != lookupIds.get(counter)) {
                errors++;
            }
            counter++;
            if (counter == lookupIds.size()) {
                counter = 0;
            }
        }

        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'serial lookup where - errors found');
    }

    @IsTest
    private static void serialLookupWhereVirtualField_cyclicalSalesforce_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)')
            .setDefinition(FObjectTwo__c.TestIntegerUnique__c, 'serial type(number) from(1) step(1) scale(0)');
        obj2.insertRecords(true);
        List<Id> lookupIds = ForceeaUtilityTest.getLookupIdsFromIntegerUnique(obj2);

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 20)
            .setDefinition('$Lookup',
                'serial lookup(FObjectTwo__c) where(TestIntegerUnique__c < 6) mode(cyclical) source(salesforce)')
            .setDefinition(FObjectOne__c.TestLookup__c, 'copy field($Lookup)');
        Test.stopTest();

        Integer errors = 0;
        Integer counter = 0;
        for (FObjectOne__c objRecord : (List<FObjectOne__c>) obj1.getRecords()) {
            if (objRecord.TestLookup__c != lookupIds.get(counter)) {
                errors++;
            }
            counter++;
            if (counter == lookupIds.size()) {
                counter = 0;
            }
        }

        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'serial lookup where - errors found');
    }

    @IsTest
    private static void serialLookupWhere_firstSalesforce_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)')
            .setDefinition(FObjectTwo__c.TestIntegerUnique__c, 'serial type(number) from(1) step(1) scale(0)');
        obj2.insertRecords(true);
        List<Id> lookupIds = ForceeaUtilityTest.getLookupIdsFromIntegerUnique(obj2);

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 20)
            .setDefinition(FObjectOne__c.TestLookup__c,
                'serial lookup(FObjectTwo__c) where(TestIntegerUnique__c < 6) mode(first) source(salesforce)');
        Test.stopTest();

        Integer errors = 0;
        Integer counter = 0;
        Integer index = 0;
        for (FObjectOne__c objRecord : (List<FObjectOne__c>) obj1.getRecords()) {
            if (objRecord.TestLookup__c != lookupIds.get(index)) {
                errors++;
            }
            counter++;
            index++;
            if (counter >= lookupIds.size()) {
                index = 0;
            }
        }

        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'serial lookup where - errors found');
    }

    @IsTest
    private static void serialLookupWhereVirtualField_firstSalesforce_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)')
            .setDefinition(FObjectTwo__c.TestIntegerUnique__c, 'serial type(number) from(1) step(1) scale(0)');
        obj2.insertRecords(true);
        List<Id> lookupIds = ForceeaUtilityTest.getLookupIdsFromIntegerUnique(obj2);

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 20)
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .setDefinition('$Lookup',
                'serial lookup(FObjectTwo__c) where(TestIntegerUnique__c < 6) mode(first) source(salesforce)')
            .setDefinition(FObjectOne__c.TestLookup__c, 'copy field($Lookup)');
        Test.stopTest();

        Integer errors = 0;
        Integer counter = 0;
        Integer index = 0;
        for (FObjectOne__c objRecord : (List<FObjectOne__c>) obj1.getRecords()) {
            if (objRecord.TestLookup__c != lookupIds.get(index)) {
                errors++;
            }
            counter++;
            index++;
            if (counter >= lookupIds.size()) {
                index = 0;
            }
        }

        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'serial lookup where - errors found');
    }

    @IsTest
    private static void serialLookupWhere_lastSalesforce_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)')
            .setDefinition(FObjectTwo__c.TestIntegerUnique__c, 'serial type(number) from(1) step(1) scale(0)');
        obj2.insertRecords(true);
        List<Id> lookupIds = ForceeaUtilityTest.getLookupIdsFromIntegerUnique(obj2);

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 20)
            .setDefinition(FObjectOne__c.TestLookup__c,
                'serial lookup(FObjectTwo__c) where(TestIntegerUnique__c < 6) mode(last) source(salesforce)');
        Test.stopTest();

        Integer errors = 0;
        Integer counter = 0;
        Integer index = 0;
        for (FObjectOne__c objRecord : (List<FObjectOne__c>) obj1.getRecords()) {
            if (objRecord.TestLookup__c != lookupIds.get(index)) {
                errors++;
            }
            counter++;
            index++;
            if (counter >= lookupIds.size()) {
                index = lookupIds.size() - 1;
            }
        }

        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'serial lookup where - errors found');
    }

    @IsTest
    private static void serialLookupWhereVirtualField_lastSalesforce_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)')
            .setDefinition(FObjectTwo__c.TestIntegerUnique__c, 'serial type(number) from(1) step(1) scale(0)');
        obj2.insertRecords(true);
        List<Id> lookupIds = ForceeaUtilityTest.getLookupIdsFromIntegerUnique(obj2);

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 20)
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .setDefinition('$Lookup',
                'serial lookup(FObjectTwo__c) where(TestIntegerUnique__c < 6) mode(last) source(salesforce)')
            .setDefinition(FObjectOne__c.TestLookup__c, 'copy field($Lookup)');
        Test.stopTest();

        Integer errors = 0;
        Integer counter = 0;
        Integer index = 0;
        for (FObjectOne__c objRecord : (List<FObjectOne__c>) obj1.getRecords()) {
            if (objRecord.TestLookup__c != lookupIds.get(index)) {
                errors++;
            }
            counter++;
            index++;
            if (counter >= lookupIds.size()) {
                index = lookupIds.size() - 1;
            }
        }

        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'serial lookup where - errors found');
    }

    @IsTest
    private static void serialLookupWhere_nullSalesforce_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)')
            .setDefinition(FObjectTwo__c.TestIntegerUnique__c, 'serial type(number) from(1) step(1) scale(0)');
        obj2.insertRecords(true);
        List<Id> lookupIds = ForceeaUtilityTest.getLookupIdsFromIntegerUnique(obj2);

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 20)
            .setDefinition(FObjectOne__c.TestLookup__c,
                'serial lookup(FObjectTwo__c) where(TestIntegerUnique__c < 6) mode(null) source(salesforce)');
        Test.stopTest();

        Integer errors = 0;
        Integer counter = 0;
        Integer lookupListSize = lookupIds.size();
        for (FObjectOne__c objRecord : (List<FObjectOne__c>) obj1.getRecords()) {
            if ((counter < lookupListSize && objRecord.TestLookup__c != lookupIds.get(counter)) ||
                (counter >= lookupListSize && String.isNotBlank(objRecord.TestLookup__c))) {
                errors++;
            }
            counter++;
        }

        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'serial lookup where - errors found');
    }

    @IsTest
    private static void serialLookupWhereVirtualField_nullSalesforce_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)')
            .setDefinition(FObjectTwo__c.TestIntegerUnique__c, 'serial type(number) from(1) step(1) scale(0)');
        obj2.insertRecords(true);
        List<Id> lookupIds = ForceeaUtilityTest.getLookupIdsFromIntegerUnique(obj2);

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 20)
            .setDefinition('$Lookup',
                'serial lookup(FObjectTwo__c) where(TestIntegerUnique__c < 6) mode(null) source(salesforce)')
            .setDefinition(FObjectOne__c.TestLookup__c, 'copy field($Lookup)');
        Test.stopTest();

        Integer errors = 0;
        Integer counter = 0;
        Integer lookupListSize = lookupIds.size();
        for (FObjectOne__c objRecord : (List<FObjectOne__c>) obj1.getRecords()) {
            if ((counter < lookupListSize && objRecord.TestLookup__c != lookupIds.get(counter)) ||
                (counter >= lookupListSize && String.isNotBlank(objRecord.TestLookup__c))) {
                errors++;
            }
            counter++;
        }

        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'serial lookup where - errors found');
    }

    @IsTest
    private static void serialLookupWhere_permutationSalesforce_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)')
            .setDefinition(FObjectTwo__c.TestIntegerUnique__c, 'serial type(number) from(1) step(1) scale(0)');
        obj2.insertRecords(true);
        List<Id> lookupIds = ForceeaUtilityTest.getLookupIdsFromIntegerUnique(obj2);

        List<String> values = new List<String>{
            'a1', 'a2', 'a3'
        };

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType)
            .setNumberOfRecords('auto')
            .setDefinition(FObjectOne__c.TestLookup__c,
                'serial lookup(FObjectTwo__c) where(TestIntegerUnique__c < 6) mode(permutation) source(salesforce)')
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(list) value(a1,a2,a3) mode(permutation)');
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Integer counter1 = 0;
        Integer counter2 = 0;
        for (FObjectOne__c objRecord : records1) {
            String str1 = lookupIds.get(counter1);
            String str2 = values.get(counter2);
            if (str1 != objRecord.TestLookup__c || str2 != objRecord.TestText__c) {
                errors++;
            }

            counter2++;
            if (counter2 == values.size()) {
                counter2 = 0;
                counter1++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'serial lookup - errors found');
    }

    @IsTest
    private static void serialLookupWhereVirtualField_permutationSalesforce_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)')
            .setDefinition(FObjectTwo__c.TestIntegerUnique__c, 'serial type(number) from(1) step(1) scale(0)');
        obj2.insertRecords(true);
        List<Id> lookupIds = ForceeaUtilityTest.getLookupIdsFromIntegerUnique(obj2);

        List<String> values = new List<String>{
            'a1', 'a2', 'a3'
        };

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType)
            .setNumberOfRecords('auto')
            .setDefinition('$Lookup',
                'serial lookup(FObjectTwo__c) where(TestIntegerUnique__c < 6) mode(permutation) source(salesforce)')
            .setDefinition(FObjectOne__c.TestLookup__c, 'copy field($Lookup)')
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(list) value(a1,a2,a3) mode(permutation)');
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Integer counter1 = 0;
        Integer counter2 = 0;
        for (FObjectOne__c objRecord : records1) {
            String str1 = lookupIds.get(counter1);
            String str2 = values.get(counter2);
            if (str1 != objRecord.TestLookup__c || str2 != objRecord.TestText__c) {
                errors++;
            }

            counter2++;
            if (counter2 == values.size()) {
                counter2 = 0;
                counter1++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'serial lookup - errors found');
    }

    @IsTest
    private static void serialNumber_positiveIntegerStep_expectSuccess() {
        Integer numRecords = 201;
        Decimal fromValue = 10;
        Decimal stepValue = 2;

        Test.startTest();
        FObject obj = new FObject(Account.SObjectType) // should use the Account object
            .setDefinition(Account.NumberOfEmployees, 'Serial Type(Number) From(10) Step(2) Scale(0)');
        List<Account> records = (List<Account>) obj.getRecords();
        Test.stopTest();

        Decimal expectedResult = fromValue + (numRecords - 1) * stepValue;
        Decimal actualResult = records[numRecords - 1].NumberOfEmployees;
        System.assertEquals(expectedResult, actualResult, 'serial number - errors found');
    }

    @IsTest
    private static void serialNumberVirtualField_positiveIntegerStep_expectSuccess() {
        Integer numRecords = 201;
        Decimal fromValue = 10;
        Decimal stepValue = 2;

        Test.startTest();
        FObject obj = new FObject(Account.SObjectType)
            .setDefinition('$Integer', 'Serial Type(Number) From(10) Step(2) Scale(0)')
            .setDefinition(Account.NumberOfEmployees, 'copy field($Integer)');
        List<Account> records = (List<Account>) obj.getRecords();
        Test.stopTest();

        Decimal expectedResult = fromValue + (numRecords - 1) * stepValue;
        Decimal actualResult = records[numRecords - 1].NumberOfEmployees;
        System.assertEquals(expectedResult, actualResult, 'serial number - errors found');
    }

    @IsTest
    private static void serialNumber_negativeIntegerStep_expectSuccess() {
        Integer numRecords = 201;
        Decimal fromValue = 0;
        Decimal stepValue = -2;

        Test.startTest();
        FObject obj = new FObject(Account.SObjectType) // should use the Account object
            .setDefinition(Account.NumberOfEmployees, 'Serial Type(Number) From(0) Step(-2) Scale(2)');
        List<Account> records = (List<Account>) obj.getRecords();
        Test.stopTest();

        Decimal expectedResult = fromValue + (numRecords - 1) * stepValue;
        Decimal actualResult = records[numRecords - 1].NumberOfEmployees;
        System.assertEquals(expectedResult, actualResult, 'serial number - errors found');
    }

    @IsTest
    private static void serialNumber_positiveDecimalStep_expectSuccess() {
        Integer numRecords = 201;
        Decimal fromValue = 10;
        Decimal stepValue = 1.52;

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, numRecords)
            .setDefinition(FObjectOne__c.TestDecimal__c, 'Serial Type(Number) From(10) Step(1.52) Scale(2)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Decimal expectedResult = fromValue + (numRecords - 1) * stepValue;
        Decimal actualResult = records[numRecords - 1].TestDecimal__c;
        System.assertEquals(expectedResult, actualResult, 'serial number - errors found');
    }

    @IsTest
    private static void serialNumber_negativeDecimalStep_expectSuccess() {
        Integer numRecords = 201;
        Decimal fromValue = 10;
        Decimal stepValue = -1.52;

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, numRecords);
        obj.setDefinition(FObjectOne__c.TestDecimal__c, 'Serial Type(Number) From(10) Step(-1.52) Scale(2)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Decimal expectedResult = fromValue + (numRecords - 1) * stepValue;
        Decimal actualResult = records[numRecords - 1].TestDecimal__c;
        System.assertEquals(expectedResult, actualResult, 'serial number - errors found');
    }

    @IsTest
    private static void serialNumber_serializationInSameFObject_expectSuccess() {
        Integer numRecords = 100;

        Test.startTest();
        //create some serialized records
        FObject obj = new FObject(FObjectOne__c.SObjectType, numRecords)
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .setDefinition(FObjectOne__c.TestIntegerUnique__c, 'serial type(number) from(1) step(1) scale(0)');
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
        Integer numRecords = 100;

        Test.startTest();
        //create some serialized records
        FObject obj1 = new FObject(FObjectOne__c.SObjectType, numRecords)
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .setDefinition(FObjectOne__c.TestIntegerUnique__c, 'serial type(number) from(1) step(1) scale(0)');
        List<FObjectOne__c> records1 = obj1.getRecords();

        // create some more serialized records of a different FObject
        FObject obj2 = new FObject(FObjectOne__c.SObjectType, numRecords)
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .setDefinition(FObjectOne__c.TestIntegerUnique__c, 'serial type(number) from(1) step(1) scale(0)');
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

        Boolean result = FObject.processIsValid() && String.isBlank(errorMessage);
        System.assert(result, 'serial number - errors found');
    }

    @IsTest
    private static void serialPicklist_cyclical_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 30)
            .setDefinition(FObjectOne__c.TestPicklistA__c, 'serial type(picklist) mode(cyclical)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        List<String> values = new List<String>{
            'a0', 'a1', 'a2', 'a3'
        };

        Integer errors = 0;
        Integer counter = 0;
        for (FObjectOne__c objRecord : records) {
            if (objRecord.TestPicklistA__c != values.get(counter)) {
                errors++;
            }
            counter++;
            if (counter == values.size()) {
                counter = 0;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'serial picklist - errors found');
    }

    @IsTest
    private static void serialPicklistRecordType_cyclical_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 30)
            .setDefinition(FObjectOne__c.RecordTypeId, 'serial type(picklist) mode(cyclical)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        List<String> recordTypeIds = new List<String>();
        for (RecordType rt : [
            SELECT Id
            FROM RecordType
            WHERE SobjectType = 'FObjectOne__c'
            ORDER BY DeveloperName
        ]) {
            recordTypeIds.add(rt.Id);
        }

        Integer errors = 0;
        Integer counter = 0;
        for (FObjectOne__c objRecord : records) {
            if (objRecord.RecordTypeId != recordTypeIds.get(counter)) {
                errors++;
            }
            counter++;
            if (counter == recordTypeIds.size()) {
                counter = 0;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'serial picklist - errors found');
    }

    @IsTest
    private static void serialPicklistVirtualField_cyclical_expectFailure() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType)
            .setDefinition('$Picklist', 'serial type(picklist) mode(cyclical)')
            .setDefinition(FObjectOne__c.TestPicklistA__c, 'copy field($Picklist)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Boolean result = !FObject.processIsValid();
        System.assert(result, 'serial picklist - errors found');
    }

    @IsTest
    private static void serialPicklist_first_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 30)
            .setDefinition(FObjectOne__c.TestPicklistA__c, 'serial type(picklist) mode(first)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        List<String> values = new List<String>{
            'a0', 'a1', 'a2', 'a3'
        };

        Integer errors = 0;
        Integer counter = 0;
        Integer index = 0;
        for (FObjectOne__c objRecord : records) {
            if (objRecord.TestPicklistA__c != values.get(index)) {
                errors++;
            }
            counter++;
            index++;
            if (counter >= values.size()) {
                index = 0;
            }
        }
        System.assertEquals(0, errors, 'serial picklist - errors found');
    }

    @IsTest
    private static void serialPicklistRecordType_first_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 30)
            .setDefinition(FObjectOne__c.RecordTypeId, 'serial type(picklist) mode(first)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        List<String> recordTypeIds = new List<String>();
        for (RecordType rt : [
            SELECT Id
            FROM RecordType
            WHERE SobjectType = 'FObjectOne__c'
            ORDER BY DeveloperName
        ]) {
            recordTypeIds.add(rt.Id);
        }

        Integer errors = 0;
        Integer counter = 0;
        Integer index = 0;
        for (FObjectOne__c objRecord : records) {
            if (objRecord.RecordTypeId != recordTypeIds.get(index)) {
                errors++;
            }
            counter++;
            index++;
            if (counter >= recordTypeIds.size()) {
                index = 0;
            }
        }
        System.assertEquals(0, errors, 'serial picklist - errors found');
    }

    @IsTest
    private static void serialPicklistVirtualField_first_expectFailure() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType)
            .setDefinition('$Picklist', 'serial type(picklist) mode(first)')
            .setDefinition(FObjectOne__c.TestPicklistA__c, 'copy field($Picklist)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Boolean result = !FObject.processIsValid();
        System.assert(result, 'serial picklist - errors found');
    }

    @IsTest
    private static void serialPicklist_last_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 30)
            .setDefinition(FObjectOne__c.TestPicklistA__c, 'serial type(picklist) mode(last)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        List<String> values = new List<String>{
            'a0', 'a1', 'a2', 'a3'
        };

        Integer errors = 0;
        Integer counter = 0;
        Integer index = 0;
        for (FObjectOne__c objRecord : records) {
            if (objRecord.TestPicklistA__c != values.get(index)) {
                errors++;
            }
            counter++;
            index++;
            if (counter >= values.size()) {
                index = values.size() - 1;
            }
        }
        System.assertEquals(0, errors, 'serial picklist - errors found');
    }

    @IsTest
    private static void serialPicklistRecordType_last_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 30)
            .setDefinition(FObjectOne__c.RecordTypeId, 'serial type(picklist) mode(last)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        List<String> recordTypeIds = new List<String>();
        for (RecordType rt : [
            SELECT Id
            FROM RecordType
            WHERE SobjectType = 'FObjectOne__c'
            ORDER BY DeveloperName
        ]) {
            recordTypeIds.add(rt.Id);
        }

        Integer errors = 0;
        Integer counter = 0;
        Integer index = 0;
        for (FObjectOne__c objRecord : records) {
            if (objRecord.RecordTypeId != recordTypeIds.get(index)) {
                errors++;
            }
            counter++;
            index++;
            if (counter >= recordTypeIds.size()) {
                index = recordTypeIds.size() - 1;
            }
        }
        System.assertEquals(0, errors, 'serial picklist - errors found');
    }

    @IsTest
    private static void serialPicklistVirtualField_last_expectFailure() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType)
            .setDefinition('$Picklist', 'serial type(picklist) mode(last)')
            .setDefinition(FObjectOne__c.TestPicklistA__c, 'copy field($Picklist)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Boolean result = !FObject.processIsValid();
        System.assert(result, 'serial picklist - errors found');
    }

    @IsTest
    private static void serialPicklist_null_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 30)
            .setDefinition(FObjectOne__c.TestPicklistA__c, 'serial type(picklist) mode(null)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        List<String> values = new List<String>{
            'a0', 'a1', 'a2', 'a3'
        };

        Integer errors = 0;
        Integer counter = 0;
        String str = '';
        for (FObjectOne__c objRecord : records) {
            if (counter < values.size()) {
                str = values.get(counter);
            } else {
                str = '';
            }
            if ((String.isNotBlank(objRecord.TestPicklistA__c) && objRecord.TestPicklistA__c != str) ||
                (String.isBlank(objRecord.TestPicklistA__c) && String.isNotBlank(str))) {
                errors++;
            }
            counter++;
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'serial picklist - errors found');
    }

    @IsTest
    private static void serialPicklistRecordType_null_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 30)
            .setDefinition(FObjectOne__c.RecordTypeId, 'serial type(picklist) mode(null)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        List<String> recordTypeIds = new List<String>();
        for (RecordType rt : [
            SELECT Id
            FROM RecordType
            WHERE SobjectType = 'FObjectOne__c'
            ORDER BY DeveloperName
        ]) {
            recordTypeIds.add(rt.Id);
        }

        Integer errors = 0;
        Integer counter = 0;
        String str = '';
        for (FObjectOne__c objRecord : records) {
            if (counter < recordTypeIds.size()) {
                str = recordTypeIds.get(counter);
            } else {
                str = '';
            }
            if ((String.isNotBlank(objRecord.RecordTypeId) && objRecord.RecordTypeId != str) ||
                (String.isBlank(objRecord.RecordTypeId) && String.isNotBlank(str))) {
                errors++;
            }
            counter++;
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'serial picklist - errors found');
    }

    @IsTest
    private static void serialPicklistVirtualField_null_expectFailure() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType)
            .setDefinition('$Picklist', 'serial type(picklist) mode(null)')
            .setDefinition(FObjectOne__c.TestPicklistA__c, 'copy field($Picklist)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Boolean result = !FObject.processIsValid();
        System.assert(result, 'serial picklist - errors found');
    }

    @IsTest
    private static void serialPicklist_permutation_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType)
            .setNumberOfRecords('auto')
            .setDefinition(FObjectOne__c.TestPicklistA__c, 'serial type(picklist) mode(permutation)')
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(list) value(b1,b2,b3) mode(permutation)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        List<String> values1 = new List<String>{
            'a0', 'a1', 'a2', 'a3'
        };
        List<String> values2 = new List<String>{
            'b1', 'b2', 'b3'
        };

        Integer errors = 0;
        Integer counter1 = 0;
        Integer counter2 = 0;
        for (FObjectOne__c objRecord : records) {
            String str1 = values1.get(counter1);
            String str2 = values2.get(counter2);
            String str = str1 + str2;
            if (str != (objRecord.TestPicklistA__c + objRecord.TestText__c)) {
                errors++;
            }

            counter2++;
            if (counter2 == values2.size()) {
                counter2 = 0;
                counter1++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'serial list - errors found');
    }

    @IsTest
    private static void serialPicklistRecordType_permutation_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType)
            .setNumberOfRecords('auto')
            .setDefinition(FObjectOne__c.RecordTypeId, 'serial type(picklist) mode(permutation)')
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(list) value(b1,b2,b3) mode(permutation)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        List<String> recordTypeIds = new List<String>();
        for (RecordType rt : [
            SELECT Id
            FROM RecordType
            WHERE SobjectType = 'FObjectOne__c'
            ORDER BY DeveloperName
        ]) {
            recordTypeIds.add(rt.Id);
        }
        List<String> values2 = new List<String>{
            'b1', 'b2', 'b3'
        };

        Integer errors = 0;
        Integer counter1 = 0;
        Integer counter2 = 0;
        for (FObjectOne__c objRecord : records) {
            String str1 = recordTypeIds.get(counter1);
            String str2 = values2.get(counter2);
            String str = str1 + str2;
            if (str != (objRecord.RecordTypeId + objRecord.TestText__c)) {
                errors++;
            }

            counter2++;
            if (counter2 == values2.size()) {
                counter2 = 0;
                counter1++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'serial list - errors found');
    }

    @IsTest
    private static void serialPicklistVirtualField_permutation_expectFailure() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType)
            .setDefinition('$Picklist', 'serial type(picklist) mode(permutation)')
            .setDefinition(FObjectOne__c.TestPicklistA__c, 'copy field($Picklist)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Boolean result = !FObject.processIsValid();
        System.assert(result, 'serial picklist - errors found');
    }

    @IsTest
    private static void serialPicklistExcept_cyclical_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 30)
            .setDefinition(FObjectOne__c.TestPicklistA__c, 'serial type(picklist) except(A1,a2) mode(cyclical)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        List<String> values = new List<String>{
            'a0', 'a3'
        };

        Integer errors = 0;
        Integer counter = 0;
        for (FObjectOne__c objRecord : records) {
            if (objRecord.TestPicklistA__c != values.get(counter)) {
                errors++;
            }
            counter++;
            if (counter == values.size()) {
                counter = 0;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'serial picklist - errors found');
    }

    @IsTest
    private static void serialPicklistRecordTypeExcept_cyclical_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 30)
            .setDefinition(FObjectOne__c.RecordTypeId, 'serial type(picklist) except(recordtypea) mode(cyclical)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        List<String> recordTypeIds = new List<String>();
        for (RecordType rt : [
            SELECT Id
            FROM RecordType
            WHERE SobjectType = 'FObjectOne__c' AND DeveloperName != 'RecordTypeA'
            ORDER BY DeveloperName
        ]) {
            recordTypeIds.add(rt.Id);
        }

        Integer errors = 0;
        Integer counter = 0;
        for (FObjectOne__c objRecord : records) {
            if (objRecord.RecordTypeId != recordTypeIds.get(counter)) {
                errors++;
            }
            counter++;
            if (counter == recordTypeIds.size()) {
                counter = 0;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'serial picklist - errors found');
    }

    @IsTest
    private static void serialPicklistExcept_first_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 30)
            .setDefinition(FObjectOne__c.TestPicklistA__c, 'serial type(picklist) except(A1,a2) mode(first)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        List<String> values = new List<String>{
            'a0', 'a3'
        };

        Integer errors = 0;
        Integer counter = 0;
        Integer index = 0;
        for (FObjectOne__c objRecord : records) {
            if (objRecord.TestPicklistA__c != values.get(index)) {
                errors++;
            }
            counter++;
            index++;
            if (counter >= values.size()) {
                index = 0;
            }
        }
        System.assertEquals(0, errors, 'serial picklist - errors found');
    }

    @IsTest
    private static void serialPicklistRecordTypeExcept_first_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 30)
            .setDefinition(FObjectOne__c.RecordTypeId, 'serial type(picklist) except(recordtypea) mode(first)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        List<String> recordTypeIds = new List<String>();
        for (RecordType rt : [
            SELECT Id
            FROM RecordType
            WHERE SobjectType = 'FObjectOne__c' AND DeveloperName != 'RecordTypeA'
            ORDER BY DeveloperName
        ]) {
            recordTypeIds.add(rt.Id);
        }

        Integer errors = 0;
        Integer counter = 0;
        Integer index = 0;
        for (FObjectOne__c objRecord : records) {
            if (objRecord.RecordTypeId != recordTypeIds.get(index)) {
                errors++;
            }
            counter++;
            index++;
            if (counter >= recordTypeIds.size()) {
                index = 0;
            }
        }
        System.assertEquals(0, errors, 'serial picklist - errors found');
    }

    @IsTest
    private static void serialPicklistExcept_last_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 30)
            .setDefinition(FObjectOne__c.TestPicklistA__c, 'serial type(picklist) except(A1,a2) mode(last)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        List<String> values = new List<String>{
            'a0', 'a3'
        };

        Integer errors = 0;
        Integer counter = 0;
        Integer index = 0;
        for (FObjectOne__c objRecord : records) {
            if (objRecord.TestPicklistA__c != values.get(index)) {
                errors++;
            }
            counter++;
            index++;
            if (counter >= values.size()) {
                index = values.size() - 1;
            }
        }
        System.assertEquals(0, errors, 'serial picklist - errors found');
    }

    @IsTest
    private static void serialPicklistRecordTypeExcept_last_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 30)
            .setDefinition(FObjectOne__c.RecordTypeId, 'serial type(picklist) except(recordtypea) mode(last)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        List<String> recordTypeIds = new List<String>();
        for (RecordType rt : [
            SELECT Id
            FROM RecordType
            WHERE SobjectType = 'FObjectOne__c' AND DeveloperName != 'RecordTypeA'
            ORDER BY DeveloperName
        ]) {
            recordTypeIds.add(rt.Id);
        }

        Integer errors = 0;
        Integer counter = 0;
        Integer index = 0;
        for (FObjectOne__c objRecord : records) {
            if (objRecord.RecordTypeId != recordTypeIds.get(index)) {
                errors++;
            }
            counter++;
            index++;
            if (counter >= recordTypeIds.size()) {
                index = recordTypeIds.size() - 1;
            }
        }
        System.assertEquals(0, errors, 'serial picklist - errors found');
    }

    @IsTest
    private static void serialPicklistExcept_null_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 30)
            .setDefinition(FObjectOne__c.TestPicklistA__c, 'serial type(picklist) except(A1,a2) mode(null)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        List<String> values = new List<String>{
            'a0', 'a3'
        };

        Integer errors = 0;
        Integer counter = 0;
        String str = '';
        for (FObjectOne__c objRecord : records) {
            if (counter < values.size()) {
                str = values.get(counter);
            } else {
                str = '';
            }
            if ((String.isNotBlank(objRecord.TestPicklistA__c) && objRecord.TestPicklistA__c != str) ||
                (String.isBlank(objRecord.TestPicklistA__c) && String.isNotBlank(str))) {
                errors++;
            }
            counter++;
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'serial picklist - errors found');
    }

    @IsTest
    private static void serialPicklistRecordTypeExcept_null_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 30)
            .setDefinition(FObjectOne__c.RecordTypeId, 'serial type(picklist) except(recordtypea) mode(null)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        List<String> recordTypeIds = new List<String>();
        for (RecordType rt : [
            SELECT Id
            FROM RecordType
            WHERE SobjectType = 'FObjectOne__c' AND DeveloperName != 'RecordTypeA'
            ORDER BY DeveloperName
        ]) {
            recordTypeIds.add(rt.Id);
        }

        Integer errors = 0;
        Integer counter = 0;
        String str = '';
        for (FObjectOne__c objRecord : records) {
            if (counter < recordTypeIds.size()) {
                str = recordTypeIds.get(counter);
            } else {
                str = '';
            }
            if ((String.isNotBlank(objRecord.RecordTypeId) && objRecord.RecordTypeId != str) ||
                (String.isBlank(objRecord.RecordTypeId) && String.isNotBlank(str))) {
                errors++;
            }
            counter++;
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'serial picklist - errors found');
    }

    @IsTest
    private static void serialPicklistExcept_permutation_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType)
            .setNumberOfRecords('auto')
            .setDefinition(FObjectOne__c.TestPicklistA__c, 'serial type(picklist) except(A1,a2) mode(permutation)')
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(list) value(b1,b2,b3) mode(permutation)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        List<String> values1 = new List<String>{
            'a0', 'a3'
        };
        List<String> values2 = new List<String>{
            'b1', 'b2', 'b3'
        };

        Integer errors = 0;
        Integer counter1 = 0;
        Integer counter2 = 0;
        for (FObjectOne__c objRecord : records) {
            String str1 = values1.get(counter1);
            String str2 = values2.get(counter2);
            String str = str1 + str2;
            if (str != (objRecord.TestPicklistA__c + objRecord.TestText__c)) {
                errors++;
            }

            counter2++;
            if (counter2 == values2.size()) {
                counter2 = 0;
                counter1++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'serial list - errors found');
    }

    @IsTest
    private static void serialPicklistRecordTypeExcept_permutation_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType)
            .setNumberOfRecords('auto')
            .setDefinition(FObjectOne__c.RecordTypeId, 'serial type(picklist) except(recordtypea) mode(permutation)')
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(list) value(b1,b2,b3) mode(permutation)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        List<String> recordTypeIds = new List<String>();
        for (RecordType rt : [
            SELECT Id
            FROM RecordType
            WHERE SobjectType = 'FObjectOne__c' AND DeveloperName != 'RecordTypeA'
            ORDER BY DeveloperName
        ]) {
            recordTypeIds.add(rt.Id);
        }
        List<String> values2 = new List<String>{
            'b1', 'b2', 'b3'
        };

        Integer errors = 0;
        Integer counter1 = 0;
        Integer counter2 = 0;
        for (FObjectOne__c objRecord : records) {
            String str1 = recordTypeIds.get(counter1);
            String str2 = values2.get(counter2);
            String str = str1 + str2;
            if (str != (objRecord.RecordTypeId + objRecord.TestText__c)) {
                errors++;
            }

            counter2++;
            if (counter2 == values2.size()) {
                counter2 = 0;
                counter1++;
            }
        }
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'serial list - errors found');
    }

}
