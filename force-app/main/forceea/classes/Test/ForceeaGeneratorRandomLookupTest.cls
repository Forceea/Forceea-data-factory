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
public class ForceeaGeneratorRandomLookupTest {

    @IsTest
    private static void randomLookupForceea_valid_expectSuccess() {
        FObject.setSeed(1);

        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        obj2.insertRecords(true);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 500)
            .setDefinition(FObjectOne__c.TestLookup__c, 'random lookup(FObjectTwo__c) source(Forceea)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Set<Id> refObjectIdsSet = (new Map<Id, FObjectTwo__c>([SELECT Id FROM FObjectTwo__c LIMIT 1000])).keySet();
        for (FObjectOne__c objRecord : records) {
            if (!refObjectIdsSet.contains(objRecord.TestLookup__c)) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'random lookup forceea - errors found');
    }

    @IsTest
    private static void randomLookupSalesforce_noRecords_expectSuccess() {
        FObject.setSeed(1);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(FObjectOne__c.TestLookup__c, 'random lookup(FObjectTwo__c) source(Salesforce)');
        obj.insertRecords(false);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c objRecord : records) {
            if (String.isNotBlank(objRecord.TestLookup__c)) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'random lookup salesforce - errors found');
    }

    @IsTest
    private static void randomLookupSalesforce_oneRecord_expectSuccess() {
        FObject.setSeed(1);

        Test.startTest();
        FObject obj1 = new FObject(FObjectTwo__c.SObjectType, 1)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        obj1.insertRecords(true);
        List<FObjectTwo__c> records1 = (List<FObjectTwo__c>) obj1.getRecords();

        FObject obj2 = new FObject(FObjectOne__c.SObjectType)
            .setDefinition(FObjectOne__c.TestLookup__c, 'random lookup(FObjectTwo__c) source(Salesforce)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj2.insertRecords(true);
        List<FObjectOne__c> records2 = (List<FObjectOne__c>) obj2.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c objRecord : records2) {
            if (objRecord.TestLookup__c != records1[0].Id) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'random lookup salesforce - errors found');
    }

    @IsTest
    private static void randomLookupSalesforce_manyRecords_expectSuccess() {
        FObject.setSeed(1);

        Test.startTest();
        FObject obj1 = new FObject(FObjectTwo__c.SObjectType, 20)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        obj1.insertRecords(true);

        FObject obj2 = new FObject(FObjectOne__c.SObjectType)
            .setDefinition(FObjectOne__c.TestLookup__c, 'random lookup(FObjectTwo__c) source(Salesforce)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj2.insertRecords(true);
        List<FObjectOne__c> records2 = (List<FObjectOne__c>) obj2.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c objRecord : records2) {
            if (String.isBlank(objRecord.TestLookup__c)) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'random lookup salesforce - errors found');
    }

    @IsTest
    private static void randomLookup_invalidObject_expectFailure() {
        FObject.setExceptionHandling('continue');

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition(FObjectOne__c.TestLookup__c, 'random lookup(InvalidObject) source(Forceea)');
        obj.getRecords();
        Test.stopTest();

        String expectedResult = 'Invalid lookup SObject [InvalidObject] in definition ' +
            '[random lookup(InvalidObject) source(Forceea)]';
        String actualResult = obj.getErrors().get('TestLookup__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'random lookup - errors found');
    }

    @IsTest
    private static void randomLookup_nullObject_expectFailure() {
        FObject.setExceptionHandling('continue');

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition(FObjectOne__c.TestLookup__c, 'random lookup() source(Forceea)');
        obj.getRecords();
        Test.stopTest();

        String expectedResult = 'Invalid definition [random lookup() source(Forceea)] of field [TestLookup__c]';
        String actualResult = obj.getErrors().get('TestLookup__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'random lookup - errors found');
    }

    @IsTest
    private static void randomLookup_invalidSource_expectFailure() {
        FObject.setExceptionHandling('continue');

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(FObjectOne__c.TestLookup__c, 'random lookup(FObjectTwo__c) source(ForceeaX)');
        obj.getRecords();
        Test.stopTest();

        String expectedResult = 'Invalid source [ForceeaX] in definition [random lookup(FObjectTwo__c) source(ForceeaX)]';
        String actualResult = obj.getErrors().get('TestLookup__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'random lookup - errors found');
    }

    @IsTest
    private static void randomLookup_nullSource_expectFailure() {
        FObject.setExceptionHandling('continue');

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(FObjectOne__c.TestLookup__c, 'random lookup(FObjectTwo__c) source()');
        obj.getRecords();
        Test.stopTest();

        String expectedResult = 'Invalid definition [random lookup(FObjectTwo__c) source()] of field [TestLookup__c]';
        String actualResult = obj.getErrors().get('TestLookup__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'random lookup - errors found');
    }

    @IsTest
    private static void randomLookupGroupForceea_insertedGroupRecords_expectSuccess() {
        FObject.setSeed(1);

        Test.startTest();
        // insert FObjectTwo__c records for group B
        FObject objB1 = new FObject(FObjectTwo__c.SObjectType, 5)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        objB1.insertRecords(true, 'B');
        objB1.getRecords();

        // insert FObjectTwo__c records without group
        FObject objB2 = new FObject(FObjectTwo__c.SObjectType, 5)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        objB2.insertRecords(true);
        objB2.getRecords();

        // insert FObjectOne__c records
        FObject objA = new FObject(FObjectOne__c.SObjectType, 300)
            .setDefinition(FObjectOne__c.TestLookup__c, 'random lookup(FObjectTwo__c) source(Forceea)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
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
        System.assertEquals(0, errors, 'random lookup forceea - errors found');
    }

    @IsTest
    private static void randomLookupGroupForceea_insertTwoGroupsValidGroupName_expectSuccess() {
        FObject.setSeed(1);

        Test.startTest();
        // insert FObjectTwo__c records for group B1
        FObject objB1 = new FObject(FObjectTwo__c.SObjectType, 20)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        objB1.insertRecords(true, 'B1');
        List<FObjectTwo__c> records1 = (List<FObjectTwo__c>) objB1.getRecords();
        Set<Id> recordIdsSet = (new Map<Id, FObjectTwo__c>(records1)).keySet();
        // insert FObjectTwo__c records for group B2
        FObject objB2 = new FObject(FObjectTwo__c.SObjectType, 30)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        objB2.insertRecords(true, 'B2');
        // insert FObjectTwo__c records without for group
        FObject objB3 = new FObject(FObjectTwo__c.SObjectType, 40)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        objB3.insertRecords(true);
        // insert FObjectOne__c records
        FObject objA = new FObject(FObjectOne__c.SObjectType)
            .setDefinition(FObjectOne__c.TestLookup__c, 'random lookup(FObjectTwo__c) group(B1) source(Forceea)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        objA.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) objA.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c objRecord : records) {
            if (!recordIdsSet.contains(objRecord.TestLookup__c)) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'random lookup group - errors found');
    }

    @IsTest
    private static void randomLookupGroupForceea_blankGroupName_expectFailure() {
        FObject.setExceptionHandling('continue');

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition(FObjectOne__c.TestLookup__c, 'random lookup(FObjectTwo__c) group() source(Forceea)');
        obj.insertRecords(true);
        obj.getRecords();
        Test.stopTest();

        String expectedResult = 'Invalid definition [random lookup(FObjectTwo__c) group() ' +
            'source(Forceea)] of field [TestLookup__c]';
        String actualResult = obj.getErrors().get('TestLookup__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'random lookup group - errors found');
    }

    @IsTest
    private static void randomLookupGroupForceea_groupNotExists_expectSuccess() {
        FObject.setSeed(1);

        Test.startTest();
        // insert FObjectTwo__c records
        FObject objB = new FObject(FObjectTwo__c.SObjectType, 20)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        objB.insertRecords(true, 'One');

        // insert FObjectOne__c records
        FObject obj = new FObject(FObjectOne__c.SObjectType)
            .setDefinition(FObjectOne__c.TestLookup__c, 'random lookup(FObjectTwo__c) group(One) source(Forceea)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
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
        if (lookupRecords1.hashCode() != lookupRecords2.hashCode()) {
            errors += 2;
        }
        System.assertEquals(0, errors, 'random lookup group - errors found');
    }

    @IsTest
    private static void randomLookupValueForceea_lookupRecordsExist_expectSuccess() {
        FObject.setSeed(1);

        // Tests the creation of records with a lookup definition
        // when the lookup object has previously been created by Forceea
        Test.startTest();
        FObject obj1 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistA__c, 'random type(picklist)')
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        obj1.insertRecords(true);

        FObject obj2 = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestLookup__c,
                'random lookup(FObjectTwo__c) field(TestPicklistA__c) value(A1) source(Forceea)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
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
        System.assertEquals(0, errors, 'random lookup forceea - errors found');
    }

    @IsTest
    private static void randomLookupValueForceea_lookupRecordsDontExist_expectSuccess() {
        FObject.setSeed(1);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestLookup__c,
                'random lookup(FObjectTwo__c) field(TestpicklistA__c) value(a1) source(Forceea)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
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
        System.assertEquals(0, errors, 'random lookup forceea - errors found');
    }

    @IsTest
    private static void randomLookupValueForceea_insertedGroupRecords_expectSuccess() {
        FObject.setSeed(1);

        Test.startTest();
        // insert FObjectTwo__c records for group B
        FObject objB1 = new FObject(FObjectTwo__c.SObjectType, 5)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)')
            .setDefinition(FObjectTwo__c.TestPicklistA__c, 'static value(a0)');
        objB1.insertRecords(true, 'B');

        // insert FObjectTwo__c records without group
        FObject objB2 = new FObject(FObjectTwo__c.SObjectType, 5)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)')
            .setDefinition(FObjectTwo__c.TestPicklistA__c, 'random type(list) value(a1, a2, a3)');
        objB2.insertRecords(true);

        // insert FObjectOne__c records
        FObject objA = new FObject(FObjectOne__c.SObjectType)
            .setDefinition(FObjectOne__c.TestLookup__c,
                'random lookup(FObjectTwo__c) field(TestPicklistA__c) value(a0) source(Forceea)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        objA.insertRecords(true);
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c objRecord : [SELECT TestLookup__r.TestPicklistA__c FROM FObjectOne__c LIMIT 1000]) {
            if (objRecord.TestLookup__r.TestPicklistA__c != 'a0') {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'random lookup forceea - errors found');
    }

    @IsTest
    private static void randomLookupValueSalesforce_lookupRecordsExist_expectSuccess() {
        FObject.setSeed(1);

        Test.startTest();
        FObject objB = new FObject(FObjectTwo__c.SObjectType, 100)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)')
            .setDefinition(FObjectTwo__c.TestPicklistB__c, 'random type(picklist)');
        objB.insertRecords(true);

        FObject objA = new FObject(FObjectOne__c.SObjectType, 10);
        objA.setDefinition(FObjectOne__c.TestLookup__c,
            'random lookup(FObjectTwo__c) field(TestPicklistB__c) value(b3) source(Salesforce)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
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
        System.assertEquals(0, errors, 'random lookup salesforce - errors found');
    }

    @IsTest
    private static void randomLookupValueSalesforce_lookupRecordsDontExist_expectSuccess() {
        FObject.setSeed(1);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition(FObjectOne__c.TestLookup__c,
            'random lookup(FObjectTwo__c) field(TestPicklistB__c) value(b3) source(Salesforce)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c objRecord : records) {
            if (String.isNotBlank(objRecord.TestLookup__c)) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'random lookup salesforce - errors found');
    }

    @IsTest
    private static void randomLookupValue_invalidField_expectFailure() {
        FObject.setExceptionHandling('continue');

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition(FObjectOne__c.TestLookup__c,
            'random lookup(FObjectTwo__c) field(FieldX) value(Hot) source(Forceea)');
        obj.getRecords();
        Test.stopTest();

        String expectedResult = 'Invalid lookup field [FieldX] in definition ' +
            '[random lookup(FObjectTwo__c) field(FieldX) value(Hot) source(Forceea)]';
        String actualResult = obj.getErrors().get('TestLookup__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'random lookup - errors found');
    }

    @IsTest
    private static void randomLookupExceptForceea_validPicklistArguments_expectSuccess() {
        FObject.setSeed(1);
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        obj2.insertRecords(true);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestLookup__c, 'random lookup(FObjectTwo__c) ' +
                'field(TestPicklistDRequired__c) except(d0,d1) source(Forceea)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
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
        System.assertEquals(0, errors, 'random lookup except - errors found');
    }

    @IsTest
    private static void randomLookupExceptForceea_validAndInvalidPicklistArguments_expectSuccess() {
        FObject.setSeed(1);

        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        obj2.insertRecords(true);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestLookup__c,
                'random lookup(FObjectTwo__c) field(TestPicklistDRequired__c) except(d0,d1,s1) source(Forceea)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
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
        System.assertEquals(0, errors, 'random lookup except - errors found');
    }

    @IsTest
    private static void randomLookupExceptForceea_invalidPicklistArguments_expectSuccess() {
        FObject.setSeed(1);
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        obj2.insertRecords(true);

        Test.startTest();
        // create FObjectOne records
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestLookup__c, 'random lookup(FObjectTwo__c) ' +
                'field(TestPicklistDRequired__c) except(s1,s2) source(Forceea)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
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
        System.assertEquals(0, errors, 'random lookup except - errors found');
    }

    @IsTest
    private static void randomLookupExceptSalesforce_validPicklistArguments_expectSuccess() {
        FObject.setSeed(1);

        Test.startTest();
        // create FObjectTwo records
        FObject obj1 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistA__c, 'random type(list) value(a2,a3)')
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        obj1.insertRecords(true);
        obj1.getRecords();
        // create FObjectOne records
        FObject obj2 = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestLookup__c, 'random lookup(FObjectTwo__c) field(TestPicklistA__c) except(a1,a2) source(Salesforce)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
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
        System.assertEquals(0, errors, 'random lookup except - errors found');
    }

    @IsTest
    private static void randomLookupExceptSalesforce_validAndInvalidPicklistArguments_expectSuccess() {
        FObject.setSeed(1);

        Test.startTest();
        // create FObjectTwo records
        FObject obj1 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistA__c, 'random type(list) value(a2,a3,s1)')
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        obj1.insertRecords(true);
        // create FObjectOne records
        FObject obj2 = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestLookup__c, 'random lookup(FObjectTwo__c) ' +
                'field(TestPicklistA__c) except(a1,a2) source(Salesforce)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
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
        System.assertEquals(0, errors, 'random lookup except - errors found');
    }

    @IsTest
    private static void randomLookupExceptSalesforce_createLookupRecordsWithBlankPicklistValues_expectSuccess() {
        FObject.setSeed(1);

        Test.startTest();
        // create FObjectTwo records
        FObject obj1 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistA__c, 'random type(list) value(s1,s2)')
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        obj1.insertRecords(true);
        // create FObjectOne records
        FObject obj2 = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestLookup__c,
                'random lookup(FObjectTwo__c) field(TestPicklistA__c) except(a1,a2) source(Salesforce)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj2.insertRecords(true);
        List<FObjectOne__c> records2 = (List<FObjectOne__c>) obj2.getRecords();
        Test.stopTest();

        // get FObjectOne__c.TestLookup__c IDs
        Set<Id> lookupIdsSet = new Set<Id>();
        for (FObjectOne__c objRecord : records2) {
            lookupIdsSet.add(objRecord.TestLookup__c);
        }

        Integer errors = 0;
        for (Id lookupId : lookupIdsSet) {
            if (String.isNotBlank(lookupId)) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'random lookup except - errors found');
    }

    @IsTest
    private static void randomLookupExceptGroup_insertedGroupRecords_expectSuccess() {
        FObject.setSeed(1);

        Test.startTest();
        // insert FObjectTwo__c records for group B
        FObject objB = new FObject(FObjectTwo__c.SObjectType, 100)
            .setDefinition(FObjectTwo__c.TestPicklistA__c, 'random type(picklist)')
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        objB.insertRecords(true, 'B');
        objB.getRecords();

        // insert FObjectOne__c records
        FObject objA = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestLookup__c,
                'random lookup(FObjectTwo__c) field(TestPicklistA__c) except(a0, a1, a2) group(b) source(Forceea)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        objA.insertRecords(true);
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c objRecord : [SELECT TestLookup__r.TestPicklistA__c FROM FObjectOne__c LIMIT 1000]) {
            if (objRecord.TestLookup__r.TestPicklistA__c != 'a3') {
                errors++;
                break;
            }
        }
        System.assertEquals(0, errors, 'random lookup except group - errors found');
    }

    @IsTest
    private static void randomLookupExceptGroup_blankGroupName_expectFailure() {
        FObject.setExceptionHandling('continue');

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(FObjectOne__c.TestLookup__c,
            'random lookup(FObjectTwo__c) field(TestPicklistA__c) except(a1, a2, a3) group() source(Forceea)');
        obj.insertRecords(true);
        obj.getRecords();
        Test.stopTest();

        String expectedResult = 'Invalid definition [random lookup(FObjectTwo__c) field(TestPicklistA__c) ' +
            'except(a1, a2, a3) group() source(Forceea)] of field [TestLookup__c]';
        String actualResult = obj.getErrors().get('TestLookup__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'random lookup except group - errors found');
    }

    @IsTest
    private static void randomLookupExceptGroup_groupNotExists_expectSuccess() {
        FObject.setSeed(1);

        Test.startTest();
        FObject objB1 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistA__c, 'static value(a0)')
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        objB1.insertRecords(true, 'B');
        objB1.getRecords();

        // insert FObjectTwo__c records without group
        FObject objB2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistA__c, 'random type(list) value(a1, a2, a3)')
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        objB2.insertRecords(true);
        objB2.getRecords();

        // insert FObjectOne__c records
        FObject objA = new FObject(FObjectOne__c.SObjectType)
            .setDefinition(FObjectOne__c.TestLookup__c,
                'random lookup(FObjectTwo__c) field(TestPicklistA__c) except(a1, a2, a3) group(One) source(Forceea)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        objA.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) objA.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c objRecord : records) {
            if (objRecord.TestLookup__c != null) {
                errors += 1;
                break;
            }
        }
        System.assertEquals(0, errors, 'random lookup except group - errors found');
    }

    @IsTest
    private static void randomLookupWhere_noLookupRecordsCreatedByForceeaOrUser_expectSuccess() {
        FObject.setSeed(1);

        Test.startTest();
        // create FObjectOne records
        String whereClause = 'TestPicklistDRequired__c = \'d1\' AND TestPicklistEUnrestricted__c != \'s1\'';
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestLookup__c, 'random lookup(FObjectTwo__c) where(' + whereClause + ') source(salesforce)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
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
        System.assertEquals(0, errors, 'random lookup where - errors found');
    }

    @IsTest
    private static void randomLookupWhere_lookupRecordsAlreadyCreatedByForceea_expectSuccess() {
        FObject.setSeed(1);

        Test.startTest();
        // create FObjectTwo records
        FObject obj1 = new FObject(FObjectTwo__c.SObjectType, 10);
        obj1.setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(list) value(d1,d2)');
        obj1.setDefinition(FObjectTwo__c.TestPicklistEUnrestricted__c, 'random type(list) value(s1,s2,s3)');
        obj1.insertRecords(true);
        // create FObjectOne records
        String whereClause = 'TestPicklistDRequired__c = \'d1\' AND TestPicklistEUnrestricted__c != \'s1\'';
        FObject obj2 = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestLookup__c,
                'random lookup(FObjectTwo__c) where(' + whereClause + ') source(salesforce)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
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
        System.assertEquals(0, errors, 'random lookup where - errors found');
    }

    @IsTest
    private static void randomLookupWhere_lookupRecordsAlreadyCreatedByUser_expectSuccess() {
        FObject.setSeed(1);

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
        String whereClause = 'TestPicklistDRequired__c = \'d1\' AND TestPicklistEUnrestricted__c != \'s1\'';
        FObject obj2 = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestLookup__c, 'random lookup(FObjectTwo__c) where(' + whereClause + ') source(salesforce)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
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
        System.assertEquals(0, errors, 'random lookup where - errors found');
    }

    @IsTest
    private static void randomLookupWhere_invalidWhereClause_expectFailure() {
        FObject.setExceptionHandling('continue');

        Test.startTest();
        FObject obj1 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(list) value(d1,d2)')
            .setDefinition(FObjectTwo__c.TestPicklistEUnrestricted__c, 'random type(list) value(s1,s2,s3)');
        obj1.insertRecords(true);

        FObject obj2 = new FObject(FObjectOne__c.SObjectType, 10);
        String whereClause = 'TestPicklistDRequired__c = \'d1\' AND wrongField != \'s1\'';
        obj2.setDefinition(FObjectOne__c.TestLookup__c, 'random lookup(FObjectTwo__c) where(' +
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
    private static void randomLookupForceeaVirtualField_valid_expectSuccess() {
        FObject.setSeed(1);

        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        obj2.insertRecords(true);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 500)
            .setDefinition('$TestLookup', 'random lookup(FObjectTwo__c) source(Forceea)')
            .setDefinition(FObjectOne__c.TestLookup__c, 'copy field($TestLookup)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Set<Id> refObjectIdsSet = (new Map<Id, FObjectTwo__c>([SELECT Id FROM FObjectTwo__c LIMIT 1000])).keySet();
        for (FObjectOne__c objRecord : records) {
            if (!refObjectIdsSet.contains(objRecord.TestLookup__c)) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'random lookup forceea - errors found');
    }

    @IsTest
    private static void randomLookupExceptForceeaVirtualField_valid_expectSuccess() {
        FObject.setSeed(1);

        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(list) value(d2,d3)');
        obj2.insertRecords(true);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition('$TestLookup', 'random lookup(FObjectTwo__c) ' +
                'field(TestPicklistDRequired__c) except(d0,d1) source(Forceea)')
            .setDefinition(FObjectOne__c.TestLookup__c, 'copy field($TestLookup)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
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
        System.assertEquals(0, errors, 'random lookup except - errors found');
    }

    @IsTest
    private static void randomLookupValueSalesforceVirtualField_valid_expectSuccess() {
        FObject.setSeed(1);

        Test.startTest();
        FObject objB = new FObject(FObjectTwo__c.SObjectType, 100)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)')
            .setDefinition(FObjectTwo__c.testPicklistB__c, 'random type(picklist)');
        objB.insertRecords(true);

        FObject objA = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition('$TestLookup',
                'random lookup(FObjectTwo__c) field(TestPicklistB__c) value(b3) source(Salesforce)')
            .setDefinition(FObjectOne__c.TestLookup__c, 'copy field($TestLookup)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
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
        System.assertEquals(0, errors, 'random lookup salesforce - errors found');
    }

    @IsTest
    private static void randomLookupExceptSalesforceVirtualField_valid_expectSuccess() {
        FObject.setSeed(1);

        Test.startTest();
        // create FObjectTwo records
        FObject obj1 = new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistA__c, 'random type(list) value(a2,a3)')
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        obj1.insertRecords(true);
        obj1.getRecords();

        // create FObjectOne records
        FObject obj2 = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition('$TestLookup', 'random lookup(FObjectTwo__c) ' +
                'field(TestPicklistA__c) except(a1,a2) source(Salesforce)')
            .setDefinition(FObjectOne__c.TestLookup__c, 'copy field($TestLookup)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
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
        System.assertEquals(0, errors, 'random lookup except - errors found');
    }

    @IsTest
    private static void randomLookupWhereVirtualField_valid_expectSuccess() {
        FObject.setSeed(1);

        Test.startTest();
        // create FObjectTwo records
        FObject obj1 = new FObject(FObjectTwo__c.SObjectType, 10);
        obj1.setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(list) value(d1,d2)');
        obj1.setDefinition(FObjectTwo__c.TestPicklistEUnrestricted__c, 'random type(list) value(s1,s2,s3)');
        obj1.insertRecords(true);
        // create FObjectOne records
        String whereClause = 'TestPicklistDRequired__c = \'d1\' AND TestPicklistEUnrestricted__c != \'s1\'';
        FObject obj2 = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition('$TestLookup',
                'random lookup(FObjectTwo__c) where(' + whereClause + ') source(salesforce)')
            .setDefinition(FObjectOne__c.TestLookup__c, 'copy field($TestLookup)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
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
        System.assertEquals(0, errors, 'random lookup where - errors found');
    }

}