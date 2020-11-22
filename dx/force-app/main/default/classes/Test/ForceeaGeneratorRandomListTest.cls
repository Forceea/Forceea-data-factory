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
public class ForceeaGeneratorRandomListTest {

    @IsTest
    private static void randomList_integerArguments_expectSuccess() {
        List<String> arguments = new List<String>{
            '1.0', '2.0', '3.0', '0.0'
        };

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType)
            .setDefinition('TestInteger__c', 'random type(list) value(1, 2, 3, 0)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
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
        FObject obj = new FObject(FObjectOne__c.SObjectType)
            .setDefinition('TestDecimal__c', 'random type(list) value(1, 2.22, 0.0, 3)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
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
        FObject obj = new FObject(FObjectOne__c.SObjectType)
            .setDefinition('TestDate__c', 'random type(list) value(2018-01-01, 2017-01-01, 2016-01-01, 2015-01-01)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
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
        FObject obj = new FObject(FObjectOne__c.SObjectType)
            .setDefinition('TestDateTime__c',
                'random type(list) value(2018-01-01 00:00:00, 2017-01-01 01:01:01, 2016-01-01 02:02:02, 2015-01-01 03:03:03)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        obj.insertRecords(true);
        Test.stopTest();

        Boolean expectedResult = true;
        Boolean actualResult = ForceeaUtilityTest.isValidDistribution('TestDateTime__c', arguments, records);
        System.assertEquals(expectedResult, actualResult, 'random list - errors found');
    }

    @IsTest
    private static void randomList_timeArguments_expectSuccess() {
        List<String> arguments = new List<String>{
            '01:01:01.000Z', '02:02:02.000Z', '03:03:03.000Z', '04:04:04.000Z'
        };

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType)
            .setDefinition('TestTime__c', 'random type(list) value(01:01:01, 02:02:02, 03:03:03, 04:04:04)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        obj.insertRecords(true);
        Test.stopTest();

        Boolean expectedResult = true;
        Boolean actualResult = ForceeaUtilityTest.isValidDistribution('TestTime__c', arguments, records);
        System.assertEquals(expectedResult, actualResult, 'random list - errors found');
    }

    @IsTest
    private static void randomList_doubleQuotes1_expectFailure() {
        FObject.setExceptionHandling('continue');

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition(FObjectOne__c.TestText__c, 'random type(list) value("one, two)');
        obj.insertRecords(true);
        Test.stopTest();

        System.assert(!FObject.processIsValid(), 'random list - errors found');
    }

    @IsTest
    private static void randomList_doubleQuotes2_expectFailure() {
        FObject.setExceptionHandling('continue');

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition(FObjectOne__c.TestText__c, 'random type(list) value(one", two)');
        obj.insertRecords(true);
        Test.stopTest();

        System.assert(!FObject.processIsValid(), 'random list - errors found');
    }

    @IsTest
    private static void randomList_doubleQuotes3_expectFailure() {
        FObject.setExceptionHandling('continue');

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition(FObjectOne__c.TestText__c, 'random type(list) value(one, "two)');
        obj.insertRecords(true);
        Test.stopTest();

        System.assert(!FObject.processIsValid(), 'random list - errors found');
    }

    @IsTest
    private static void randomList_doubleQuotes4_expectFailure() {
        FObject.setExceptionHandling('continue');

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition(FObjectOne__c.TestText__c, 'random type(list) value(one, two")');
        obj.insertRecords(true);
        Test.stopTest();

        System.assert(!FObject.processIsValid(), 'random list - errors found');
    }

    @IsTest
    private static void randomList_doubleQuotes5_expectFailure() {
        FObject.setExceptionHandling('continue');

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition(FObjectOne__c.TestText__c, 'random type(list) value("one, "two")');
        List<FObjectOne__c> records = obj.getRecords();
        Test.stopTest();

        System.assert(!FObject.processIsValid(), 'random list - errors found');
    }

    @IsTest
    private static void randomList_doubleQuotes6_expectFailure() {
        FObject.setExceptionHandling('continue');

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition(FObjectOne__c.TestText__c, 'random type(list) value(one", "two")');
        List<FObjectOne__c> records = obj.getRecords();
        Test.stopTest();

        System.assert(!FObject.processIsValid(), 'random list - errors found');
    }

    @IsTest
    private static void randomList_doubleQuotes7_expectFailure() {
        FObject.setExceptionHandling('continue');

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition(FObjectOne__c.TestText__c, 'random type(list) value("one", "two)');
        List<FObjectOne__c> records = obj.getRecords();
        Test.stopTest();

        System.assert(!FObject.processIsValid(), 'random list - errors found');
    }

    @IsTest
    private static void randomList_doubleQuotes8_expectFailure() {
        FObject.setExceptionHandling('continue');

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition(FObjectOne__c.TestText__c, 'random type(list) value("one", two")');
        List<FObjectOne__c> records = obj.getRecords();
        Test.stopTest();

        System.assert(!FObject.processIsValid(), 'random list - errors found');
    }

    @IsTest
    private static void randomList_doubleQuotes9_expectFailure() {
        FObject.setExceptionHandling('continue');

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition(FObjectOne__c.TestText__c, 'random type(list) value("one"two", three)');
        List<FObjectOne__c> records = obj.getRecords();
        Test.stopTest();

        System.assert(!FObject.processIsValid(), 'random list - errors found');
    }

    @IsTest
    private static void randomList_doubleQuotes10_expectFailure() {
        FObject.setExceptionHandling('continue');

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition(FObjectOne__c.TestText__c, 'random type(list) value("one"two", "three")');
        List<FObjectOne__c> records = obj.getRecords();
        Test.stopTest();

        System.assert(!FObject.processIsValid(), 'random list - errors found');
    }

    @IsTest
    private static void randomList_doubleQuotes11_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition(FObjectOne__c.TestText__c, 'random type(" list ") value(v1, "v2 ", " v3", " v4 ")');
        obj.setDefinition(FObjectOne__c.TestText__c, 'static value(xyz)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        System.assert(FObject.processIsValid(), 'random list - errors found');
    }

    @IsTest
    private static void randomList_doubleQuotes1_expectSucess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition(FObjectOne__c.TestText__c, 'random type(list) value(one, two)');
        List<FObjectOne__c> records = obj.getRecords();
        Test.stopTest();

        System.assert(FObject.processIsValid(), 'random list - errors found');
    }

    @IsTest
    private static void randomList_doubleQuotes2_expectSucess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition(FObjectOne__c.TestText__c, 'random type(list) value("one", two)');
        List<FObjectOne__c> records = obj.getRecords();
        Test.stopTest();

        System.assert(FObject.processIsValid(), 'random list - errors found');
    }

    @IsTest
    private static void randomList_doubleQuotes3_expectSucess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition(FObjectOne__c.TestText__c, 'random type(list) value(one, "two")');
        List<FObjectOne__c> records = obj.getRecords();
        Test.stopTest();

        System.assert(FObject.processIsValid(), 'random list - errors found');
    }

    @IsTest
    private static void randomList_doubleQuotes4_expectSucess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition(FObjectOne__c.TestText__c, 'random type(list) value("one", "two")');
        List<FObjectOne__c> records = obj.getRecords();
        Test.stopTest();

        System.assert(FObject.processIsValid(), 'random list - errors found');
    }

    @IsTest
    private static void randomList_doubleQuotes5_expectSucess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition(FObjectOne__c.TestText__c, 'random type(list) value(one, "two(2), three")');
        List<FObjectOne__c> records = obj.getRecords();
        Test.stopTest();

        System.assert(FObject.processIsValid(), 'random list - errors found');
    }

    @IsTest
    private static void randomList_doubleQuotes6_expectSucess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition(FObjectOne__c.TestText__c, 'random type(list) value(one"two, "three")');
        List<FObjectOne__c> records = obj.getRecords();
        Test.stopTest();

        System.assert(FObject.processIsValid(), 'random list - errors found');
    }

    @IsTest
    private static void randomList_stringArguments_expectSuccess() {
        List<String> arguments = new List<String>{
            'One', 'Two', 'Three', 'Twenty One'
        };

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType)
            .setDefinition(FObjectOne__c.TestText__c, 'random type(list) value(One,Two,Three,Twenty One)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
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
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition('TestPicklistA__c', 'random type(list) value(A0, A1, a2, a4)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Boolean expectedResult = true;
        Boolean actualResult = ForceeaUtilityTest.isValidDistribution('TestPicklistA__c', arguments, records);
        System.assertEquals(expectedResult, actualResult, 'random list - errors found');
    }

    @IsTest
    private static void randomList_restrictedDependentPicklistField_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 100);
        obj.setDefinition(FObjectOne__c.TestPicklistB__c, 'random type(list) value(B0, b1, B2, b4, b5)');
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
        System.assertEquals(0, errors, 'random picklist - errors found');
    }

    @IsTest
    private static void randomList_unrestrictedIndependentPicklistField_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject('FObjectTwo__c')
            .setDefinition('TestPicklistEUnrestricted__c', 'random type(list) value(e1, e4, e5, d1, d2)')
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
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
        FObject obj = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition('TestPicklistFUnrestricted__c', 'random type(list) value(f0, f1, f4, f5, e1, e2)')
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        List<Database.SaveResult> saveResults = obj.insertRecords(false);
        List<FObjectTwo__c> records = (List<FObjectTwo__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (Database.SaveResult sr : saveResults) {
            if (!sr.isSuccess()) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'random list - errors found');
    }

    @IsTest
    private static void randomList_controllingFieldIsCheckbox_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition('TestCheckbox__c', 'static value(true)')
            .setDefinition('TestpicklistD__c', 'random type(list) value(d2, d3)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        List<Database.SaveResult> saveResults = obj.insertRecords(false);
        Test.stopTest();

        Integer errors = 0;
        for (Database.SaveResult sr : saveResults) {
            if (!sr.isSuccess()) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'random list - errors found');
    }

    @IsTest
    private static void randomList_oneRecordType_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType)
            .setDefinition('RecordTypeId', 'random type(list) value(RecordtypeA)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
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
        FObject obj = new FObject(FObjectOne__c.SObjectType)
            .setDefinition('RecordTypeId', 'random type(list) value(RecordTypeA, RecordTypeB)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
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
        FObject.setExceptionHandling('continue');

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('RecordTypeId', 'random type(list) value(RecordTypeX)');
        obj.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        String expectedResult = 'Invalid record type [RecordTypeX] in definition [random type(list) value(RecordTypeX)]';
        String actualResult = obj.getErrors().get('RecordTypeId').get(0);
        System.assertEquals(expectedResult, actualResult, 'random list - errors found');
    }

    @IsTest
    private static void randomListVirtualField_integerArguments_expectSuccess() {
        List<String> arguments = new List<String>{
            '1', '2', '3', '0'
        };

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType)
            .setDefinition('$Test1Integer', 'random type(list) value(1, 2, 3, 0)')
            .setDefinition(FObjectOne__c.TestText__c, 'copy field($test1Integer)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        obj.insertRecords(true);
        Test.stopTest();

        Boolean expectedResult = true;
        Boolean actualResult = ForceeaUtilityTest.isValidDistribution('TestText__c', arguments, records);
        System.assertEquals(expectedResult, actualResult, 'random list - errors found');
    }

    @IsTest
    private static void randomListVirtualField_decimalArguments_expectSuccess() {
        List<String> arguments = new List<String>{
            '1.1', '2.22', '0.0', '3.335'
        };

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType)
            .setDefinition('$TestDecimal', 'random type(list) value(1.1, 2.22, 3.335, 0)')
            .setDefinition(FObjectOne__c.TestDecimal__c, 'copy field($TestDecimal)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        obj.insertRecords(true);
        Test.stopTest();

        Boolean expectedResult = true;
        Boolean actualResult = ForceeaUtilityTest.isValidDistribution('TestDecimal__c', arguments, records);
        System.assertEquals(expectedResult, actualResult, 'random list - errors found');
    }

    @IsTest
    private static void randomListVirtualField_dateArguments_expectSuccess() {
        List<String> arguments = new List<String>{
            '2018-01-01 00:00:00', '2017-01-01 00:00:00', '2016-01-01 00:00:00', '2015-01-01 00:00:00'
        };

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType)
            .setDefinition('$TestDate', 'random type(list) value(2018-01-01, 2017-01-01, 2016-01-01, 2015-01-01)')
            .setDefinition('TestDate__c', 'copy field($TestDate)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        obj.insertRecords(true);
        Test.stopTest();

        Boolean expectedResult = true;
        Boolean actualResult = ForceeaUtilityTest.isValidDistribution('TestDate__c', arguments, records);
        System.assertEquals(expectedResult, actualResult, 'random list - errors found');
    }

    @IsTest
    private static void randomListVirtualField_datetimeArguments_expectSuccess() {
        List<Datetime> arguments = new List<Datetime>();
        arguments.add(Datetime.newInstance(2018, 1, 1, 0, 0, 0));
        arguments.add(Datetime.newInstance(2017, 1, 1, 1, 1, 1));
        arguments.add(Datetime.newInstance(2016, 1, 1, 2, 2, 2));
        arguments.add(Datetime.newInstance(2015, 1, 1, 3, 3, 3));

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType)
            .setDefinition('$TestDatetime',
                'random type(list) value(2018-01-01 00:00:00, 2017-01-01 01:01:01, 2016-01-01 02:02:02, 2015-01-01 03:03:03)')
            .setDefinition(FObjectOne__c.TestDatetime__c, 'copy field($TestDatetime)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        obj.insertRecords(true);
        Test.stopTest();

        Boolean expectedResult = true;
        Boolean actualResult = ForceeaUtilityTest.isValidDistribution('TestDateTime__c', arguments, records);
        System.assertEquals(expectedResult, actualResult, 'random list - errors found');
    }

    @IsTest
    private static void randomListVirtualField_timeArguments_expectSuccess() {
        List<String> arguments = new List<String>{
            '01:01:01.000Z', '02:02:02.000Z', '03:03:03.000Z', '04:04:04.000Z'
        };

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType)
            .setDefinition('$TestTime', 'random type(list) value(01:01:01, 02:02:02, 03:03:03, 04:04:04)')
            .setDefinition(FObjectOne__c.TestTime__c, 'copy field($TestTime)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        obj.insertRecords(true);
        Test.stopTest();

        Boolean expectedResult = true;
        Boolean actualResult = ForceeaUtilityTest.isValidDistribution('TestTime__c', arguments, records);
        System.assertEquals(expectedResult, actualResult, 'random list - errors found');
    }

    @IsTest
    private static void randomListVirtualField_stringArguments_expectSuccess() {
        List<String> arguments = new List<String>{
            'One', 'Two', 'Three', 'Twenty One'
        };

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType)
            .setDefinition('$TestString', 'random type(list) value(One,Two,Three,Twenty One)')
            .setDefinition(FObjectOne__c.TestText__c, 'copy field($TestString)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        obj.insertRecords(true);
        Test.stopTest();

        Boolean expectedResult = true;
        Boolean actualResult = ForceeaUtilityTest.isValidDistribution('TestText__c', arguments, records);
        System.assertEquals(expectedResult, actualResult, 'random list - errors found');
    }

}
