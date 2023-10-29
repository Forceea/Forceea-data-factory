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
@IsTest
@SuppressWarnings('PMD.MethodNamingConventions')
public class ForceeaGeneratorStaticLookupTest {

    @IsTest
    private static void staticLookupForceea_valid_expectSuccess() {
        FObject.setSeed(1);
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 20)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)')
            .setDefinition(FObjectTwo__c.TestPicklistA__c, 'random type(list) value(a1,a2)');
        obj2.insertRecords(true);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 100)
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .setDefinition(FObjectOne__c.TestLookup__c, 'static lookup(FObjectTwo__c) source(Forceea)');
        obj.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        // get the TestLookup__c of the first FObjectOne__c record
        Id lookupId = obj2.getInsertedRecords().get(0).Id;

        // check if the lookupId exists in every record of FObjectOne__c
        Integer errors = 0;
        for (FObjectOne__c objRecord : records) {
            if (objRecord.TestLookup__c != lookupId) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'static lookup - errors found');
    }

    @IsTest
    private static void staticLookupValueForceea_valid_expectSuccess() {
        FObject.setSeed(1);
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)')
            .setDefinition(FObjectTwo__c.TestPicklistA__c, 'static value(a1)');
        obj2.insertRecords(true);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 100)
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .setDefinition(FObjectOne__c.TestLookup__c,
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
        System.assertEquals(0, errors, 'static lookup - errors found');
    }

    @IsTest
    private static void staticLookupValueForceea_lookupRecordsExist_expectSuccess() {
        FObject.setSeed(1);
        String whereValue = 'Hot';
        Integer errors = 0;

        Test.startTest();
        FObject obj1 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)')
            .setDefinition(FObjectTwo__c.TestText__c, 'static value(' + whereValue + ')');
        obj1.getRecords();
        obj1.insertRecords(true);

        FObject obj2 = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .setDefinition(FObjectOne__c.TestLookup__c, 'static lookup(FObjectTwo__c) ' +
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
        System.assertEquals(0, errors, 'static lookup - errors found');
    }

    @IsTest
    private static void staticLookupValueForceea_lookupRecordsNotExist_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setVariable('value', 'Invalid')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .setDefinition(FObjectOne__c.TestLookup__c, 'static lookup(FObjectTwo__c) ' +
                'field(TestText__c) value({@value}) source(forceea)');
        Test.stopTest();

        // check if the lookupId exists in every record of FObjectOne__c
        Integer errors = 0;
        for (FObjectOne__c objRecord : (List<FObjectOne__c>) obj.getRecords()) {
            if (String.isNotBlank(objRecord.TestLookup__c)) {
                errors++;
            }
        }

        System.assertEquals(0, errors, 'static lookup - errors found');
    }

    @IsTest
    private static void staticLookupValueForceeaVirtualField_valid_expectSuccess() {
        FObject.setSeed(1);
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)')
            .setDefinition(FObjectTwo__c.TestPicklistA__c, 'static value(a1)');
        obj2.insertRecords(true);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 100)
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .setDefinition('$Test',
                'static lookup(FObjectTwo__c) field(TestPicklistA__c) value(a1) source(Forceea)')
            .setDefinition(FObjectOne__c.TestLookup__c, 'copy field($Test)');
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
        System.assertEquals(0, errors, 'static lookup - errors found');
    }

    @IsTest
    private static void staticLookupGroupForceea_valid_expectSuccess() {
        FObject.setSeed(1);

        Test.startTest();
        // insert FObjectTwo__c records for group B
        FObject objB1 = new FObject(FObjectTwo__c.SObjectType, 5)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)')
            .setDefinition(FObjectTwo__c.TestPicklistA__c, 'random type(list) value(a0,a1,a2)');
        objB1.insertRecords(true, 'B');
        // insert FObjectTwo__c records without group
        FObject objB2 = new FObject(FObjectTwo__c.SObjectType, 5)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)')
            .setDefinition(FObjectTwo__c.TestPicklistA__c, 'random type(list) value(a2, a3)');
        objB2.insertRecords(true);
        // insert FObjectOne__c records
        FObject objA = new FObject(FObjectOne__c.SObjectType)
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .setDefinition(FObjectOne__c.TestLookup__c,
                'static lookup(FObjectTwo__c) field(TestPicklistA__c) value(a0,a1) group(B) source(forceea)');
        objA.insertRecords(true);
        Test.stopTest();

        Integer errors = 0;
        Set<String> values = new Set<String>{
            'a0', 'a1'
        };
        for (FObjectOne__c objRecord : [SELECT TestLookup__r.TestPicklistA__c FROM FObjectOne__c LIMIT 1000]) {
            if (!values.contains(objRecord.TestLookup__r.TestPicklistA__c)) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'static lookup - errors found');
    }

    @IsTest
    private static void staticLookupValueSalesforce_valid_expectSuccess() {
        FObject.setSeed(1);
        String whereValue = 'Hot';
        Integer errors = 0;

        Test.startTest();
        FObject obj1 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)')
            .setDefinition(FObjectTwo__c.TestText__c, 'static value(' + whereValue + ')');
        obj1.getRecords();
        obj1.insertRecords(true);

        FObject obj2 = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .setDefinition(FObjectOne__c.TestLookup__c, 'static lookup(FObjectTwo__c) ' +
                'field(TestText__c) value(' + whereValue + ') source(Salesforce)');
        obj2.insertRecords(true);
        List<FObjectOne__c> records2 = (List<FObjectOne__c>) obj2.getRecords();
        Test.stopTest();

        // get the TestLookup__c of the first FObjectOne__c record
        Id lookupId = records2.get(0).TestLookup__c;

        // check if the lookup ID exists in every record of FObjectOne__c
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
        System.assertEquals(0, errors, 'static lookup - errors found');
    }

    @IsTest
    private static void staticLookupValueSalesforce_lookupRecordsNotExist_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setVariable('value', 'Invalid')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .setDefinition(FObjectOne__c.TestLookup__c, 'static lookup(FObjectTwo__c) ' +
                'field(TestText__c) value({@value}) source(salesforce)');
        Test.stopTest();

        // check if the lookupId exists in every record of FObjectOne__c
        Integer errors = 0;
        for (FObjectOne__c objRecord : (List<FObjectOne__c>) obj.getRecords()) {
            if (String.isNotBlank(objRecord.TestLookup__c)) {
                errors++;
            }
        }

        System.assertEquals(0, errors, 'static lookup - errors found');
    }

    @IsTest
    private static void staticLookupValueSalesforceVirtualField_valid_expectSuccess() {
        FObject.setSeed(1);
        String whereValue = 'Hot';
        Integer errors = 0;

        Test.startTest();
        FObject obj1 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)')
            .setDefinition(FObjectTwo__c.TestText__c, 'static value(' + whereValue + ')');
        obj1.getRecords();
        obj1.insertRecords(true);

        FObject obj2 = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .setDefinition('$Test',
                'static lookup(FObjectTwo__c) field(TestText__c) value(' + whereValue + ') source(Salesforce)')
            .setDefinition(FObjectOne__c.TestLookup__c, 'copy field($Test)');
        obj2.insertRecords(true);
        List<FObjectOne__c> records2 = (List<FObjectOne__c>) obj2.getRecords();
        Test.stopTest();

        // get the TestLookup__c of the first FObjectOne__c record
        Id lookupId = records2.get(0).TestLookup__c;

        // check if the lookup ID exists in every record of FObjectOne__c
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
        System.assertEquals(0, errors, 'static lookup - errors found');
    }

    @IsTest
    private static void staticLookupExceptForceea_valid_expectSuccess() {
        FObject.setSeed(1);
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 20)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)')
            .setDefinition(FObjectTwo__c.TestPicklistA__c, 'random type(list) value(a1,a2,a3)');
        obj2.insertRecords(true);

        Id lookupId;
        for (FObjectTwo__c record : (List<FObjectTwo__c>) obj2.getInsertedRecords()) {
            if (record.TestPicklistA__c == 'a3') {
                lookupId = record.Id;
                break;
            }
        }

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 100)
            .setDefinition(FObjectOne__c.TestLookup__c,
                'static lookup(FObjectTwo__c) field(TestPicklistA__c) except(a1,a2) source(forceea)');
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c objRecord : (List<FObjectOne__c>) obj.getRecords()) {
            if (objRecord.TestLookup__c != lookupId) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'static lookup - errors found');
    }

    @IsTest
    private static void staticLookupExceptSalesforce_valid_expectSuccess() {
        FObject.setSeed(1);
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 20)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)')
            .setDefinition(FObjectTwo__c.TestPicklistA__c, 'random type(list) value(a1,a2,a3)');
        obj2.insertRecords(true);

        Id lookupId;
        for (FObjectTwo__c record : (List<FObjectTwo__c>) obj2.getInsertedRecords()) {
            if (record.TestPicklistA__c == 'a3') {
                lookupId = record.Id;
                break;
            }
        }

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 100)
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .setDefinition(FObjectOne__c.TestLookup__c,
                'static lookup(FObjectTwo__c) field(TestPicklistA__c) except(a1,a2) source(salesforce)');
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c objRecord : (List<FObjectOne__c>) obj.getRecords()) {
            if (objRecord.TestLookup__c != lookupId) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'static lookup - errors found');
    }

    @IsTest
    private static void staticLookupWhere_valid_expectSuccess() {
        FObject.setSeed(1);
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 20)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)')
            .setDefinition(FObjectTwo__c.TestPicklistA__c, 'random type(list) value(a1,a2,a3)');
        obj2.insertRecords(true);

        Id lookupId;
        for (FObjectTwo__c record : (List<FObjectTwo__c>) obj2.getInsertedRecords()) {
            if (record.TestPicklistA__c == 'a3') {
                lookupId = record.Id;
                break;
            }
        }

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 100)
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .setDefinition(FObjectOne__c.TestLookup__c,
                'static lookup(FObjectTwo__c) where(TestPicklistA__c = \'a3\') source(salesforce)');
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c objRecord : (List<FObjectOne__c>) obj.getRecords()) {
            if (objRecord.TestLookup__c != lookupId) {
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
        FObject.setExceptionHandling('continue');
        FObject.setSeed(1);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(FObjectOne__c.TestLookup__c, 'static lookup(FObjectTwo) ' +
            'field(TestPicklistA__c) value(a1) source(forceea)');
        obj.getRecords();
        Test.stopTest();

        String expectedResult = 'Invalid lookup SObject [FObjectTwo] in definition [static lookup(FObjectTwo) ' +
            'field(TestPicklistA__c) value(a1) source(forceea)]';
        String actualResult = obj.getErrors().get('TestLookup__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'static lookup - errors found');
    }

    @IsTest
    private static void staticLookup_nullLookup_expectFailure() {
        FObject.setExceptionHandling('continue');
        FObject.setSeed(1);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType)
            .setDefinition(FObjectOne__c.TestLookup__c, 'static lookup() field(TestPicklistA__c) value(a1) source(forceea)');
        obj.getRecords();
        Test.stopTest();

        String expectedResult = 'Invalid definition [static lookup() field(TestPicklistA__c) value(a1) ' +
            'source(forceea)] of field [TestLookup__c]';
        String actualResult = obj.getErrors().get('TestLookup__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'static lookup - errors found');
    }

    @IsTest
    private static void staticLookup_invalidSource_expectFailure() {
        FObject.setExceptionHandling('continue');
        FObject.setSeed(1);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType)
            .setDefinition(FObjectOne__c.TestLookup__c, 'static lookup(FObjectTwo__c) ' +
                'field(TestPicklistA__c) value(a1) source(ForceeaX)');
        obj.getRecords();
        Test.stopTest();

        String expectedResult = 'Invalid source [ForceeaX] in definition [static lookup(FObjectTwo__c) ' +
            'field(TestPicklistA__c) value(a1) source(ForceeaX)]';
        String actualResult = obj.getErrors().get('TestLookup__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'static lookup - errors found');
    }

}