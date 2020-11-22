/*
  Forceea data factory (v2.3.0)
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
public class ForceeaGeneratorRandomTest {

    @IsTest
    private static void randomBoolean_valid_expectSuccess() {
        FObject.setSeed(1);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .setDefinition(FObjectOne__c.TestCheckbox__c, 'random type(boolean)');
        obj.insertRecords(true);
        Test.stopTest();

        Integer errors = 0;
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random boolean - errors found');
    }

    @IsTest
    private static void randomBooleanVirtualField_valid_expectSuccess() {
        FObject.setSeed(1);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition('$Test', 'random type(boolean)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .setDefinition(FObjectOne__c.TestCheckbox__c, 'copy field($Test)');
        obj.insertRecords(true);
        Test.stopTest();

        Integer errors = 0;
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'random boolean - errors found');
    }

    @IsTest
    private static void randomDate_fromLessThanTo_expectSuccess() {
        FObject.setSeed(1);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .setDefinition('TestDate__c', 'random type("date ") from(2018-01-01) to(2018-01-10)');
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
        System.assertEquals(0, errors, 'random date - errors found');
    }

    @IsTest
    private static void randomDate_fromEqualsTo_expectFailure() {
        FObject.setExceptionHandling('continue');
        FObject.setSeed(1);

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
        FObject.setExceptionHandling('continue');
        FObject.setSeed(1);

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
    private static void randomDateVirtualField_valid_expectSuccess() {
        FObject.setSeed(1);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition('$TestDate', 'random type(date) from(2018-01-01) to(2018-01-10)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .setDefinition('TestDate__c', 'copy field($TestDate)');
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
        System.assertEquals(0, errors, 'random date - errors found');
    }

    @IsTest
    private static void randomDatetime_fromDatetimeLessThanToDatetimeSameDay_expectSuccess() {
        FObject.setSeed(1);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .setDefinition('TestDatetime__c',
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
        System.assertEquals(0, errors, 'random datetime - errors found');
    }

    @IsTest
    private static void randomDatetime_fromDatetimeLessThanToDatetimeDifferentDay_expectSuccess() {
        FObject.setSeed(1);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .setDefinition('TestDatetime__c',
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
        System.assertEquals(0, errors, 'random datetime - errors found');
    }

    @IsTest
    private static void randomDatetime_fromDatetimeLessThanToDateSameDay_expectSuccess() {
        FObject.setSeed(1);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .setDefinition('TestDatetime__c', 'random type(datetime) from(2018-01-01 01:01:01) to(2018-01-01)');
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
        System.assertEquals(0, errors, 'random datetime - errors found');
    }

    @IsTest
    private static void randomDatetime_fromDatetimeLessThanToDateDifferentDay_expectSuccess() {
        FObject.setSeed(1);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .setDefinition('TestDatetime__c', 'random type(datetime) from(2018-01-01 01:01:01) to(2018-01-05)');
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
        System.assertEquals(0, errors, 'random datetime - errors found');
    }

    @IsTest
    private static void randomDatetime_fromDateLessThanToDatetimeSameDay_expectSuccess() {
        FObject.setSeed(1);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .setDefinition('TestDatetime__c', 'random type(datetime) from(2018-01-01) to(2018-01-01 01:01:01)');
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
        System.assertEquals(0, errors, 'random datetime - errors found');
    }

    @IsTest
    private static void randomDatetime_fromDateLessThanToDatetimeDifferentDay_expectSuccess() {
        FObject.setSeed(1);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .setDefinition('TestDatetime__c', 'random type(datetime) from(2018-01-01) to(2018-01-05 01:01:01)');
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
        System.assertEquals(0, errors, 'random datetime - errors found');
    }

    @IsTest
    private static void randomDatetime_fromDateLessThanToDate_expectSuccess() {
        FObject.setSeed(1);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .setDefinition('TestDatetime__c', 'random type(datetime) from(2018-1-1) to(2018-1-5)');
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
        System.assertEquals(0, errors, 'random datetime - errors found');
    }

    @IsTest
    private static void randomDatetime_fromDateEqualsToDate_expectSuccess() {
        FObject.setSeed(1);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .setDefinition('TestDatetime__c', 'random type(datetime) from(2018-1-1) to(2018-1-1)');
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
        System.assertEquals(0, errors, 'random datetime - errors found');
    }

    @IsTest
    private static void randomDatetime_fromDatetimeEqualsToDatetime_expectFailure() {
        FObject.setExceptionHandling('continue');
        FObject.setSeed(1);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
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
        FObject.setExceptionHandling('continue');
        FObject.setSeed(1);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
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
        FObject.setExceptionHandling('continue');
        FObject.setSeed(1);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
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
        FObject.setExceptionHandling('continue');
        FObject.setSeed(1);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition('TestDatetime__c', 'random type(datetime) from(2018-01-02) to(2018-01-01 01:01:01)');
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'The [from] datetime is greater than or equal to the [to] datetime in definition ' +
            '[random type(datetime) from(2018-01-02) to(2018-01-01 01:01:01)]';
        String actualResult = obj.getErrors().get('TestDatetime__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'random datetime - errors found');
    }

    @IsTest
    private static void randomDatetimeVirtualField_valid_expectSuccess() {
        FObject.setSeed(1);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition('$TestDatetime',
                'random type(datetime) from(2018-01-01 01:01:01) to(2018-01-01 02:02:02)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .setDefinition('TestDatetime__c', 'copy field($TestDatetime)');
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
        System.assertEquals(0, errors, 'random datetime - errors found');
    }

    @IsTest
    private static void randomTime_fromTimeLessThanToTime_expectSuccess() {
        FObject.setSeed(1);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 100);
        obj.setDefinition(FObjectOne__c.TestTime__c, 'random type(time) from(08:00:00) to(17:02:02)');
        Test.stopTest();

        Time timeFrom = Time.newInstance(8, 0, 0, 0);
        Time timeTo = Time.newInstance(17, 2, 2, 0);

        Integer errors = 0;
        for (FObjectOne__c objRecord : (List<FObjectOne__c>) obj.getRecords()) {
            if (objRecord.TestTime__c < timeFrom || objRecord.TestTime__c > timeTo) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'random time - errors found');
    }

    @IsTest
    private static void randomTime_fromTimeEqualsToTime_expectFailure() {
        FObject.setExceptionHandling('continue');
        FObject.setSeed(1);

        Test.startTest();
        String definition = 'random type(time) from(17:02:02) to(17:02:02)';
        FObject obj = new FObject(FObjectOne__c.SObjectType)
            .setDefinition(FObjectOne__c.TestTime__c, definition);
        List<FObjectOne__c> records = obj.getRecords();
        Test.stopTest();

        String expectedResult = 'The [from] time is greater than or equal to the [to] time in definition [' + definition + ']';
        String actualResult = obj.getErrors().get('TestTime__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'random time- errors found');
    }

    @IsTest
    private static void randomTime_fromTimeLessThanToTime_expectFailure() {
        FObject.setExceptionHandling('continue');
        FObject.setSeed(1);

        Test.startTest();
        String definition = 'random type(time) from(17:02:02) to(08:00:00)';
        FObject obj = new FObject(FObjectOne__c.SObjectType)
            .setDefinition(FObjectOne__c.TestTime__c, definition);
        List<FObjectOne__c> records = obj.getRecords();
        Test.stopTest();

        String expectedResult = 'The [from] time is greater than or equal to the [to] time in definition [' + definition + ']';
        String actualResult = obj.getErrors().get('TestTime__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'random time- errors found');
    }

    @IsTest
    private static void randomTime_invalidArgument_expectFailure() {
        FObject.setExceptionHandling('continue');
        FObject.setSeed(1);

        Test.startTest();
        String definition = 'random type(time) from(1d7:02:02) to(08:00:00)';
        FObject obj = new FObject(FObjectOne__c.SObjectType, 100)
            .setDefinition(FObjectOne__c.TestTime__c, definition);
        List<FObjectOne__c> records = obj.getRecords();
        Test.stopTest();

        String expectedResult = 'Invalid definition [' + definition + '] of field [TestTime__c]';
        String actualResult = obj.getErrors().get('TestTime__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'random time- errors found');
    }

    @IsTest
    private static void randomTimeVirtualField_valid_expectSuccess() {
        FObject.setSeed(1);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 100)
            .setDefinition('$TestTime', 'random type(time) from(08:00:00) to(17:02:02)')
            .setDefinition(FObjectOne__c.TestTime__c, 'copy field($TestTime)');
        Test.stopTest();

        Time timeFrom = Time.newInstance(8, 0, 0, 0);
        Time timeTo = Time.newInstance(17, 2, 2, 0);

        Integer errors = 0;
        for (FObjectOne__c objRecord : (List<FObjectOne__c>) obj.getRecords()) {
            if (objRecord.TestTime__c < timeFrom || objRecord.TestTime__c > timeTo) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'random time - errors found');
    }

    @IsTest
    private static void randomEmail_default_expectSuccess() {
        FObject.setSeed(1);

        Test.startTest();
        new FObject(FObjectOne__c.SObjectType)
            .setDefinition(FObjectOne__c.TestEmail__c, 'random type(email)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .insertRecords(true);
        Test.stopTest();
        System.assert(FObject.processIsValid(), 'random email - errors found');
    }

    @IsTest
    private static void randomEmailVirtualField_default_expectSuccess() {
        FObject.setSeed(1);

        Test.startTest();
        new FObject(FObjectOne__c.SObjectType)
            .setDefinition('$TestEmail', 'random type(email)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .setDefinition(FObjectOne__c.TestEmail__c, 'copy field($TestEmail)')
            .insertRecords(true);
        Test.stopTest();
        System.assert(FObject.processIsValid(), 'random email - errors found');
    }

    @IsTest
    private static void randomFirstName_incorrectLanguageAndLocality_expectSuccess() {
        FObject.setSeed(1);
        ForceeaUtilityTest.loadNamesFromUnitesStatesInEnglish();

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        FObject.setGlobalLanguage('Language');
        FObject.setGlobalLocality('Locality');
        obj.setDefinition(FObjectOne__c.TestText__c, 'random type(firstname) group(a)');
        List<FObjectOne__c> records = obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c objRecord : records) {
            if (!ForceeaUtilityTest.femaleFirstNames.contains(objRecord.TestText__c) &&
                !ForceeaUtilityTest.maleFirstNames.contains(objRecord.TestText__c)) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'random name - errors found');
    }

    @IsTest
    private static void randomLastName_incorrectLanguageAndLocality_expectSuccess() {
        FObject.setSeed(1);
        ForceeaUtilityTest.loadNamesFromUnitesStatesInEnglish();

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        FObject.setGlobalLanguage('Language');
        FObject.setGlobalLocality('Locality');
        obj.setDefinition(FObjectOne__c.TestText__c, 'random type(lastname) group(a)');
        List<FObjectOne__c> records = obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c objRecord : records) {
            if (!ForceeaUtilityTest.femaleLastNames.contains(objRecord.TestText__c) &&
                !ForceeaUtilityTest.maleLastNames.contains(objRecord.TestText__c)) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'random name - errors found');
    }

    @IsTest
    private static void randomFirstLastName_fromGreeceInGreek_expectSuccess() {
        FObject.setSeed(1);
        ForceeaUtilityTest.loadNamesFromGreeceInGreek();

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        FObject.setGlobalLanguage('Greek');
        FObject.setGlobalLocality('Greece');
        obj.setDefinition(FObjectOne__c.TestText__c, 'random type(firstname) group(a)');
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
        System.assertEquals(0, errors, 'random name - errors found');
    }

    @IsTest
    private static void randomFirstLastName_fromUnitedStatesInEnglish_expectSuccess() {
        FObject.setSeed(1);
        ForceeaUtilityTest.loadNamesFromUnitesStatesInEnglish();

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        FObject.setGlobalLanguage('English');
        FObject.setGlobalLocality('United States');
        obj.setDefinition(FObjectOne__c.TestText__c, 'random type(firstname) group(a)');
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
        System.assertEquals(0, errors, 'random name - errors found');
    }

    @IsTest
    private static void randomFirstLastNameVirtualField_default_expectSuccess() {
        FObject.setSeed(1);
        ForceeaUtilityTest.loadNamesFromUnitesStatesInEnglish();
        FObject.setGlobalLanguage('English');
        FObject.setGlobalLocality('United States');

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition('$FirstName', 'random type(firstname) group(a)')
            .setDefinition('$LastName', 'random type(lastname) group(a)')
            .setDefinition(FObjectOne__c.TestText__c, 'copy field($FirstName)')
            .setDefinition(FObjectOne__c.TestTextArea__c, 'copy field($LastName)');
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
        System.assertEquals(0, errors, 'random name - errors found');
    }

    @IsTest
    private static void randomStreet_fromUnitedStatesInEnglish_expectSuccess() {
        FObject.setSeed(1);
        FObject.setGlobalLanguage('English');
        FObject.setGlobalLocality('United States');
        ForceeaAddress.loadAddresses();

        List<String> values = new List<String>();
        Set<String> valuesSet = new Set<String>();
        for (ForceeaAddress address : FObject.addressesLibrary) {
            values.add(address.street);
            valuesSet.add(address.street);
        }

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 200)
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .setDefinition(FObjectOne__c.TestText__c, 'random type(street) group(shipping)');
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
        System.assertEquals(0, errors, 'random street - errors found');
    }

    @IsTest
    private static void randomStreet_fromGreeceInGreek_expectSuccess() {
        FObject.setSeed(1);
        FObject.setGlobalLanguage('Greek');
        FObject.setGlobalLocality('Greece');
        ForceeaAddress.loadAddresses();

        List<String> values = new List<String>();
        Set<String> valuesSet = new Set<String>();
        for (ForceeaAddress address : FObject.addressesLibrary) {
            values.add(address.street);
            valuesSet.add(address.street);
        }

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 500)
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .setDefinition(FObjectOne__c.TestText__c, 'random type(street) group(shipping)');
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
        System.assertEquals(0, errors, 'random street - errors found');
    }

    @IsTest
    private static void randomStreetVirtualField_valid_expectSuccess() {
        FObject.setSeed(1);
        FObject.setGlobalLanguage('English');
        FObject.setGlobalLocality('United States');
        ForceeaAddress.loadAddresses();

        List<String> values = new List<String>();
        Set<String> valuesSet = new Set<String>();
        for (ForceeaAddress address : FObject.addressesLibrary) {
            values.add(address.street);
            valuesSet.add(address.street);
        }

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 200)
            .setDefinition('$TestAddress', 'random type(street) group(shipping)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .setDefinition(FObjectOne__c.TestText__c, 'copy field($TestAddress)');
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
        System.assertEquals(0, errors, 'random address - errors found');
    }

    @IsTest
    private static void randomCity_fromUnitedStatesInEnglish_expectSuccess() {
        FObject.setSeed(1);
        FObject.setGlobalLanguage('English');
        FObject.setGlobalLocality('United States');
        ForceeaAddress.loadAddresses();

        List<String> values = new List<String>();
        Set<String> valuesSet = new Set<String>();
        for (ForceeaAddress address : FObject.addressesLibrary) {
            values.add(address.city);
            valuesSet.add(address.city);
        }

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 200)
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .setDefinition(FObjectOne__c.TestText__c, 'random type(city) group(shipping)');
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
        System.assertEquals(0, errors, 'random city - errors found');
    }

    @IsTest
    private static void randomCity_fromGreeceInGreek_expectSuccess() {
        FObject.setSeed(1);
        FObject.setGlobalLanguage('Greek');
        FObject.setGlobalLocality('Greece');
        ForceeaAddress.loadAddresses();

        List<String> values = new List<String>();
        Set<String> valuesSet = new Set<String>();
        for (ForceeaAddress address : FObject.addressesLibrary) {
            values.add(address.city);
            valuesSet.add(address.city);
        }

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 200)
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .setDefinition(FObjectOne__c.TestText__c, 'random type(city) group(shipping)');
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
        System.assertEquals(0, errors, 'random city - errors found');
    }

    @IsTest
    private static void randomCityVirtualField_valid_expectSuccess() {
        FObject.setSeed(1);
        FObject.setGlobalLanguage('English');
        FObject.setGlobalLocality('United States');
        ForceeaAddress.loadAddresses();

        List<String> values = new List<String>();
        Set<String> valuesSet = new Set<String>();
        for (ForceeaAddress address : FObject.addressesLibrary) {
            values.add(address.city);
            valuesSet.add(address.city);
        }

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 200)
            .setDefinition('$TestAddress', 'random type(city) group(shipping)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .setDefinition(FObjectOne__c.TestText__c, 'copy field($TestAddress)');
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
        System.assertEquals(0, errors, 'random address - errors found');
    }

    @IsTest
    private static void randomPostalCode_fromUnitedStatesInEnglish_expectSuccess() {
        FObject.setSeed(1);
        FObject.setGlobalLanguage('English');
        FObject.setGlobalLocality('United States');
        ForceeaAddress.loadAddresses();

        List<String> values = new List<String>();
        Set<String> valuesSet = new Set<String>();
        for (ForceeaAddress address : FObject.addressesLibrary) {
            values.add(address.postalCode);
            valuesSet.add(address.postalCode);
        }

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 200)
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .setDefinition(FObjectOne__c.TestText__c, 'random type(postalcode) group(shipping)');
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
        System.assertEquals(0, errors, 'random postalcode - errors found');
    }

    @IsTest
    private static void randomPostalCode_fromGreeceInGreek_expectSuccess() {
        FObject.setSeed(1);
        FObject.setGlobalLanguage('Greek');
        FObject.setGlobalLocality('Greece');
        ForceeaAddress.loadAddresses();

        List<String> values = new List<String>();
        Set<String> valuesSet = new Set<String>();
        for (ForceeaAddress address : FObject.addressesLibrary) {
            values.add(address.postalCode);
            valuesSet.add(address.postalCode);
        }

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 500)
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .setDefinition(FObjectOne__c.TestText__c, 'random type(postalcode) group(shipping)');
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
        System.assertEquals(0, errors, 'random postalcode - errors found');
    }

    @IsTest
    private static void randomPostalCodeVirtualField_valid_expectSuccess() {
        FObject.setSeed(1);
        FObject.setGlobalLanguage('English');
        FObject.setGlobalLocality('United States');
        ForceeaAddress.loadAddresses();

        List<String> values = new List<String>();
        Set<String> valuesSet = new Set<String>();
        for (ForceeaAddress address : FObject.addressesLibrary) {
            values.add(address.postalCode);
            valuesSet.add(address.postalCode);
        }

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 200)
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .setDefinition('$TestAddress', 'random type(postalcode) group(shipping)')
            .setDefinition(FObjectOne__c.TestText__c, 'copy field($TestAddress)');
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
        System.assertEquals(0, errors, 'random postalcode - errors found');
    }

    @IsTest
    private static void randomState_fromUnitedStatesInEnglish_expectSuccess() {
        FObject.setSeed(1);
        FObject.setGlobalLanguage('English');
        FObject.setGlobalLocality('United States');
        ForceeaAddress.loadAddresses();

        List<String> values = new List<String>();
        Set<String> valuesSet = new Set<String>();
        for (ForceeaAddress address : FObject.addressesLibrary) {
            values.add(address.state);
            valuesSet.add(address.state);
        }

        Test.startTest();
        FObject obj = new FObject('FObjectOne__c', 200)
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .setDefinition('TestText__c', 'random type(state) group(shipping)');
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
        System.assertEquals(0, errors, 'random state - errors found');
    }

    @IsTest
    private static void randomStateVirtualField_valid_expectSuccess() {
        FObject.setSeed(1);
        FObject.setGlobalLanguage('English');
        FObject.setGlobalLocality('United States');
        ForceeaAddress.loadAddresses();

        List<String> values = new List<String>();
        Set<String> valuesSet = new Set<String>();
        for (ForceeaAddress address : FObject.addressesLibrary) {
            values.add(address.state);
            valuesSet.add(address.state);
        }

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 200)
            .setDefinition('$TestAddress', 'random type(state) group(shipping)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .setDefinition(FObjectOne__c.TestText__c, 'copy field($TestAddress)');
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
        System.assertEquals(0, errors, 'random address - errors found');
    }

    @IsTest
    private static void randomCountryVirtualField_valid_expectSuccess() {
        FObject.setSeed(1);
        FObject.setGlobalLanguage('English');
        FObject.setGlobalLocality('United States');
        ForceeaAddress.loadAddresses();

        List<String> values = new List<String>();
        Set<String> valuesSet = new Set<String>();
        for (ForceeaAddress address : FObject.addressesLibrary) {
            values.add(address.country);
            valuesSet.add(address.country);
        }

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 200)
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .setDefinition('$TestAddress', 'random type(country) group(shipping)')
            .setDefinition(FObjectOne__c.TestText__c, 'copy field($TestAddress)');
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
        System.assertEquals(0, errors, 'random country - errors found');
    }

    @IsTest
    private static void randomCountry_fromGreeceInGreek_expectSuccess() {
        FObject.setSeed(1);
        FObject.setGlobalLanguage('Greek');
        FObject.setGlobalLocality('Greece');
        ForceeaAddress.loadAddresses();

        List<String> values = new List<String>();
        Set<String> valuesSet = new Set<String>();
        for (ForceeaAddress address : FObject.addressesLibrary) {
            values.add(address.country);
            valuesSet.add(address.country);
        }

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 200)
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .setDefinition(FObjectOne__c.TestText__c, 'random type(country) group(shipping)');
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
        System.assertEquals(0, errors, 'random country - errors found');
    }

    @IsTest
    private static void randomNumber_integerArgument_expectSuccess() {
        FObject.setSeed(1);

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
        System.assertEquals(0, errors, 'random number - errors found');
    }

    @IsTest
    private static void randomNumber_decimalArgument_expectSuccess() {
        FObject.setSeed(1);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .setDefinition('TestDecimal__c', 'random type(number) from(1) to(50.12) scale(2)');
        obj.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c objRecord : records) {
            if (objRecord.TestDecimal__c < 1 || objRecord.TestDecimal__c > 50.12) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'random number - errors found');
    }

    @IsTest
    private static void randomNumber_fromEqualsTo_expectFailure() {
        FObject.setExceptionHandling('continue');
        FObject.setSeed(1);

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
        FObject.setExceptionHandling('continue');
        FObject.setSeed(1);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
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
    private static void randomNumberVirtualField_valid_expectSuccess() {
        FObject.setSeed(1);

        Test.startTest();
        FObject obj = new FObject('Account') // should use the Account object
            .setDefinition('$Test', 'random type(number) from(1) to(100) scale(0)')
            .setDefinition(Account.NumberOfEmployees, 'copy field($Test)');
        List<Account> records = (List<Account>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (Account objRecord : records) {
            if (objRecord.NumberOfEmployees < 1 || objRecord.NumberOfEmployees > 100) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'random number - errors found');
    }

    @IsTest
    private static void randomPhone_valid_expectSuccess() {
        FObject.setSeed(1);
        String formatString = '(30) 210 dd-11-1DD';

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 30)
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
    private static void randomPhoneVirtualField_valid_expectSuccess() {
        FObject.setSeed(1);
        String formatString = '(30) 210 dd-11-1DD';

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 30)
            .setDefinition('$Test', 'random type(phone) format("' + formatString + '")')
            .setDefinition(FObjectOne__c.TestPhone__c, 'copy field($Test)');
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
    private static void randomString_includeOnlyDigits_expectSuccess() {
        FObject.setSeed(1);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(FObjectOne__c.TestText__c, 'random type(string) Minlength(5) Maxlength(10) ' +
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
        System.assertEquals(0, errors, 'random string - errors found');
    }

    @IsTest
    private static void randomString_includeOnlyLowercase_expectSuccess() {
        FObject.setSeed(1);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(FObjectOne__c.TestText__c, 'random type(string) Minlength(5) Maxlength(10) ' +
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
        System.assertEquals(0, errors, 'random string - errors found');
    }

    @IsTest
    private static void randomString_includeOnlyUppercase_expectSuccess() {
        FObject.setSeed(1);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(FObjectOne__c.TestText__c, 'random type(string) Minlength(5) Maxlength(10) ' +
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
        System.assertEquals(0, errors, 'random string - errors found');
    }

    @IsTest
    private static void randomString_startWithLower_expectSuccess() {
        FObject.setSeed(1);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(FObjectOne__c.TestText__c, 'random type(string) Minlength(5) Maxlength(10) ' +
            'startwith(Lower) include(Lower,Upper)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c objRecord : records) {
            if (!objRecord.TestText__c.left(1).isAllLowerCase()) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'random string - errors found');
    }

    @IsTest
    private static void randomString_startWithUpper_expectSuccess() {
        FObject.setSeed(1);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(FObjectOne__c.TestText__c, 'random type(string) Minlength(5) Maxlength(10) ' +
            'startwith(Upper) include(Lower, Upper)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c objRecord : records) {
            if (!objRecord.TestText__c.left(1).isAllUpperCase()) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'random string - errors found');
    }

    @IsTest
    private static void randomString_startWithDigit_expectSuccess() {
        FObject.setSeed(1);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(FObjectOne__c.TestText__c, 'random type(string) Minlength(5) Maxlength(10) ' +
            'startwith(Digit) include(Lower, Upper)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c objRecord : records) {
            if (!objRecord.TestText__c.left(1).isNumeric()) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'random string - errors found');
    }

    @IsTest
    private static void randomString_minEqualsZero_expectFailure() {
        FObject.setExceptionHandling('continue');
        FObject.setSeed(1);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(FObjectOne__c.TestText__c, 'Random Type(string) Minlength(0) Maxlength(5) ' +
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
        FObject.setExceptionHandling('continue');
        FObject.setSeed(1);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(FObjectOne__c.TestText__c, 'Random Type(string) Minlength(-1) Maxlength(5) ' +
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
        FObject.setExceptionHandling('continue');
        FObject.setSeed(1);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(FObjectOne__c.TestText__c, 'Random Type(string) Minlength(10) Maxlength(5) ' +
            'Startwith(Upper) Include(Lower,Upper)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        String expectedResult = 'The minimum length should be less than or equal to the maximum length ' +
            'in definition [Random Type(string) Minlength(10) Maxlength(5) Startwith(Upper) Include(Lower,Upper)]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'random string - errors found');
    }

    @IsTest
    private static void randomStringVirtualField_valid_expectSuccess() {
        FObject.setSeed(1);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition('$Test', 'random type(string) Minlength(5) Maxlength(10) ' +
                'startwith(Lower) include(Digit)')
            .setDefinition(FObjectOne__c.TestText__c, 'copy field($Test)');
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
        System.assertEquals(0, errors, 'random string - errors found');
    }

    @IsTest
    private static void randomText_validWords_expectSuccess() {
        FObject.setSeed(1);

        List<String> words = new List<String>{
            'lorem', 'ipsum', 'dolor', 'sit', 'amet', 'tempor', 'aboreant',
            'eu', 'nos', 'a', 'e', 'quo', 'magna', 'primis', 'labore', 'usi', 'virtute', 'fabellas', 'vis', 'duis',
            'scripta', 'laudem', 'commune', 'nam', 'laoreet', 'propriae', 'ea', 'partem',
            'inermis', 'ius', 'sint', 'impedit', 'eam', 'elit', 'nusquam'
        };

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(FObjectOne__c.TestText__c, 'Random Type(Text) Minlength(20) Maxlength(50)');
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
        System.assertEquals(0, errors, 'random text - errors found');
    }

    @IsTest
    private static void randomText_minEqualsMaxPlus1_expectSuccess() {
        FObject.setSeed(1);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(FObjectOne__c.TestText__c, 'Random Type(Text) Minlength(20) Maxlength(21)');
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
        System.assertEquals(0, errors, 'random text - errors found');
    }

    @IsTest
    private static void randomText_minEqualsMaxPlus10_expectSuccess() {
        FObject.setSeed(1);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 200);
        obj.setDefinition(FObjectOne__c.TestText__c, 'Random Type(Text) Minlength(20) Maxlength(30)');
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
        System.assertEquals(0, errors, 'random text - errors found');
    }

    @IsTest
    private static void randomText_minEqualsMax_expectFailure() {
        FObject.setExceptionHandling('continue');
        FObject.setSeed(1);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(FObjectOne__c.TestText__c, 'Random Type(Text) Minlength(20) Maxlength(20)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        String expectedResult = 'The minimum length should be less than the maximum length ' +
            'in definition [Random Type(Text) Minlength(20) Maxlength(20)]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'random text - error found');
    }

    @IsTest
    private static void randomText_minEqualsZero_expectFailure() {
        FObject.setExceptionHandling('continue');
        FObject.setSeed(1);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(FObjectOne__c.TestText__c, 'Random Type(Text) Minlength(0) Maxlength(20)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        String expectedResult = 'The minimum length should be greater than or equal to 1 ' +
            'in definition [Random Type(Text) Minlength(0) Maxlength(20)]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'random text - error found');
    }

    @IsTest
    private static void randomText_minLessThanZero_expectFailure() {
        FObject.setExceptionHandling('continue');
        FObject.setSeed(1);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(FObjectOne__c.TestText__c, 'Random Type(Text) Minlength(-1) Maxlength(20)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        String expectedResult = 'The minimum length should be greater than or equal to 1 ' +
            'in definition [Random Type(Text) Minlength(-1) Maxlength(20)]';
        String actualResult = obj.getErrors().get('TestText__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'random text - error found');
    }

    @IsTest
    private static void randomTextVirtualField_valid_expectSuccess() {
        FObject.setSeed(1);
        List<String> words = new List<String>{
            'lorem', 'ipsum', 'dolor', 'sit', 'amet', 'tempor', 'aboreant',
            'eu', 'nos', 'a', 'e', 'quo', 'magna', 'primis', 'labore', 'usi', 'virtute', 'fabellas', 'vis', 'duis',
            'scripta', 'laudem', 'commune', 'nam', 'laoreet', 'propriae', 'ea', 'partem',
            'inermis', 'ius', 'sint', 'impedit', 'eam', 'elit', 'nusquam'
        };

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType)
            .setDefinition('$Test', 'Random Type(Text) Minlength(20) Maxlength(50)')
            .setDefinition(FObjectOne__c.TestText__c, 'copy field($Test)');
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
        System.assertEquals(0, errors, 'random text - errors found');
    }

    @IsTest
    private static void randomUrl_valid_expectSuccess() {
        FObject.setSeed(1);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
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
        System.assertEquals(0, errors, 'random url - errors found');
    }

    @IsTest
    private static void randomUrlVirtualField_valid_expectSuccess() {
        FObject.setSeed(1);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType)
            .setDefinition('$Test', 'random type(url)')
            .setDefinition(FObjectOne__c.TestUrl__c, 'copy field($Test)');
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
        System.assertEquals(0, errors, 'random url - errors found');
    }

}
