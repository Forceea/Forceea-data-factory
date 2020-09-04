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
public class ForceeaGeneratorTest {

    @IsTest
    private static void mock_instanceMocking_expectSuccess() {
        Integer size = 10;

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, size);
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
        System.assertEquals(0, errors, 'mock - errors found');
    }

    @IsTest
    private static void mock_instanceMockingWithSetRequiredFields_expectSuccess() {
        Integer size1 = 10;
        Integer size2 = 5;

        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, size2)
            .setDefinition(FObjectTwo__c.Id, 'mock type(id)');
        List<Database.SaveResult> results2 = obj2.insertRecords(true);
        List<FObjectOne__c> createdRecords2 = (List<FObjectOne__c>) obj2.getRecords();
        List<FObjectOne__c> insertedRecords2 = (List<FObjectOne__c>) obj2.getInsertedRecords();

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType, size1)
            .setRequiredFields(false)
            .setDefinition(FObjectOne__c.Id, 'mock type(id)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        List<Database.SaveResult> results1 = obj1.insertRecords(true);
        List<FObjectOne__c> createdRecords1 = (List<FObjectOne__c>) obj1.getRecords();
        List<FObjectOne__c> insertedRecords1 = (List<FObjectOne__c>) obj1.getInsertedRecords();
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c record : (List<FObjectOne__c>) obj1.getInsertedRecords()) {
            String str = record.Id;
            if (!str.contains('mock')) {
                errors += 1;
                break;
            }
        }
        for (FObjectTwo__c record : (List<FObjectTwo__c>) obj2.getInsertedRecords()) {
            String str = record.Id;
            if (!str.contains('mock')) {
                errors += 2;
                break;
            }
        }
        if ((createdRecords1.size() + createdRecords2.size()) != (size1 + size2)) {
            errors += 4;
        }
        if ((insertedRecords1.size() + insertedRecords2.size()) != (size1 + size2)) {
            errors += 8;
        }
        if (!results1.isEmpty() && !results2.isEmpty()) {
            errors += 16;
        }
        System.assertEquals(0, errors, 'mock - errors found');
    }

    @IsTest
    private static void mock_globalMockingWithoutLookup_expectSuccess() {
        Integer size1 = 10;
        Integer size2 = 5;
        Integer size3 = 2;
        FObject.setGlobalMocking(true);

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType, size1);
        List<Database.SaveResult> results1 = obj1.insertRecords(true);
        List<FObjectOne__c> createdRecords1 = (List<FObjectOne__c>) obj1.getRecords();
        List<FObjectOne__c> insertedRecords1 = (List<FObjectOne__c>) obj1.getInsertedRecords();

        FObject obj2 = new FObject(FObjectOne__c.SObjectType, size2);
        List<Database.SaveResult> results2 = obj2.insertRecords(true);
        List<FObjectOne__c> createdRecords2 = (List<FObjectOne__c>) obj2.getRecords();
        List<FObjectOne__c> insertedRecords2 = (List<FObjectOne__c>) obj2.getInsertedRecords();

        FObject obj3 = new FObject(FObjectTwo__c.SObjectType, size3);
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
        System.assertEquals(0, errors, 'mock - errors found');
    }

    @IsTest
    private static void mock_globalMockingWithSetRequiredFields_expectSuccess() {
        Integer size1 = 10;
        Integer size2 = 5;
        FObject.setGlobalMocking(true);

        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, size2);
        List<Database.SaveResult> results2 = obj2.insertRecords(true);
        List<FObjectOne__c> createdRecords2 = (List<FObjectOne__c>) obj2.getRecords();
        List<FObjectOne__c> insertedRecords2 = (List<FObjectOne__c>) obj2.getInsertedRecords();

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType, size1)
            .setRequiredFields(false)
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        List<Database.SaveResult> results1 = obj1.insertRecords(true);
        List<FObjectOne__c> createdRecords1 = (List<FObjectOne__c>) obj1.getRecords();
        List<FObjectOne__c> insertedRecords1 = (List<FObjectOne__c>) obj1.getInsertedRecords();
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c record : (List<FObjectOne__c>) obj1.getInsertedRecords()) {
            String str = record.Id;
            if (!str.contains('mock')) {
                errors += 1;
                break;
            }
        }
        for (FObjectTwo__c record : (List<FObjectTwo__c>) obj2.getInsertedRecords()) {
            String str = record.Id;
            if (!str.contains('mock')) {
                errors += 2;
                break;
            }
        }
        if ((createdRecords1.size() + createdRecords2.size()) != (size1 + size2)) {
            errors += 4;
        }
        if ((insertedRecords1.size() + insertedRecords2.size()) != (size1 + size2)) {
            errors += 8;
        }
        if (!results1.isEmpty() && !results2.isEmpty()) {
            errors += 16;
        }
        System.assertEquals(0, errors, 'mock - errors found');
    }

    @IsTest
    private static void mock_globalMockingWithLookup_expectSuccess() {
        Integer size1 = 5;
        Integer size2 = 20;
        FObject.setGlobalMocking(true);

        Test.startTest();
        FObject obj1 = new FObject(FObjectTwo__c.SObjectType, size1);
        List<Database.SaveResult> results1 = obj1.insertRecords(true);
        List<FObjectOne__c> createdRecords1 = (List<FObjectOne__c>) obj1.getRecords();
        List<FObjectOne__c> insertedRecords1 = (List<FObjectOne__c>) obj1.getInsertedRecords();

        FObject obj2 = new FObject(FObjectOne__c.SObjectType, size2)
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
        System.assertEquals(0, errors, 'mock - errors found');
    }

    @IsTest
    private static void permutations_listAuto1Call_expectSuccess() {
        FObject obj = new FObject(FObjectOne__c.SObjectType, 100)
            .setNumberOfRecords('auto')
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(list) value(A,B,C,D,E) mode(permutation)')
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(list) value(1,2,3,4) mode(permutation)');

        Test.startTest();
        obj.createRecords();
        Test.stopTest();

        Integer errors = 0;
        List<String> results = new List<String>();
        for (FObjectOne__c record : (List<FObjectOne__c>) obj.getRecords()) {
            results.add(record.TestText__c + record.TestPicklistA__c);
        }

        if (listHasDuplicateItems(results)) {
            errors += 1;
        }
        if (results.size() != 20) {
            errors += 2;
        }
        System.assertEquals(0, errors, 'permutations - errors found');
    }

    @IsTest
    private static void permutations_listAuto2Calls_expectSuccess() {
        FObject obj = new FObject(FObjectOne__c.SObjectType, 100)
            .setNumberOfRecords('auto')
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(list) value(A,B,C,D,E) mode(permutation)')
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(list) value(1,2,3,4) mode(permutation)');
        obj.createRecords();

        Test.startTest();
        obj.deleteDefinitions(FObjectOne__c.TestText__c)
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(list) value(A,B,C) mode(permutation)')
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(list) value(1,2,3,4) mode(permutation)')
            .createRecords();
        Test.stopTest();

        Integer errors = 0;
        List<String> results = new List<String>();
        for (FObjectOne__c record : (List<FObjectOne__c>) obj.getRecords()) {
            results.add(record.TestText__c + record.TestPicklistA__c);
        }

        if (listHasDuplicateItems(results)) {
            errors += 1;
        }
        if (results.size() != 12) {
            errors += 2;
        }
        System.assertEquals(0, errors, 'permutations - errors found');
    }

    @IsTest
    private static void permutations_independentPicklistAuto1Call_expectSuccess() {
        FObject obj = new FObject(FObjectOne__c.SObjectType, 100)
            .setNumberOfRecords('auto')
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(list) value(A,B,C,D,E) mode(permutation)')
            .setDefinition(FObjectOne__c.TestPicklistA__c, 'serial type(picklist) mode(permutation)');

        Test.startTest();
        obj.createRecords();
        Test.stopTest();

        Integer errors = 0;
        List<String> results = new List<String>();
        for (FObjectOne__c record : (List<FObjectOne__c>) obj.getRecords()) {
            results.add(record.TestText__c + record.TestPicklistA__c);
        }

        if (listHasDuplicateItems(results)) {
            errors += 1;
        }
        if (results.size() != 20) {
            errors += 2;
        }
        System.assertEquals(0, errors, 'permutations - errors found');
    }

    @ IsTest
    private static void permutations_independentPicklistAuto2Calls_expectSuccess() {
        FObject obj = new FObject(FObjectOne__c.SObjectType, 100)
            .setNumberOfRecords('auto')
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(list) value(A,B,C,D,E) mode(permutation)')
            .setDefinition(FObjectOne__c.TestPicklistA__c, 'serial type(picklist) mode(permutation)');
        obj.createRecords();

        Test.startTest();
        obj.deleteDefinitions(FObjectOne__c.TestText__c)
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(list) value(A,B,C) mode(permutation)')
            .createRecords();
        Test.stopTest();

        Integer errors = 0;
        List<String> results = new List<String>();
        for (FObjectOne__c record : (List<FObjectOne__c>) obj.getRecords()) {
            results.add(record.TestText__c + record.TestPicklistA__c);
        }

        if (listHasDuplicateItems(results)) {
            errors += 1;
        }
        if (results.size() != 12) {
            errors += 2;
        }
        System.assertEquals(0, errors, 'permutations - errors found');
    }

    @IsTest
    private static void permutations_lookupAuto_expectSuccess() {
        new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)')
            .insertRecords(true);

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 100)
            .setNumberOfRecords('auto')
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(list) value(A, B, C) mode(permutation)')
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(list) value(1, 2) mode(permutation)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .setDefinition(FObjectOne__c.TestLookup__c, 'serial lookup(FObjectTwo__c) mode(permutation) source(salesforce)');
        obj1.insertRecords(true);
        Test.stopTest();

        Integer errors = 0;
        List<String> results = new List<String>();
        for (FObjectOne__c record : (List<FObjectOne__c>) obj1.getInsertedRecords()) {
            results.add(record.TestText__c + record.TestLookup__c);
        }

        if (listHasDuplicateItems(results)) {
            errors += 1;
        }
        if (results.size() != 60) {
            errors += 2;
        }
        System.assertEquals(0, errors, 'permutations - errors found');
    }

    @IsTest
    private static void permutations_lookupDefault_expectSuccess() {
        new FObject(FObjectTwo__c.SObjectType, 10)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)')
            .insertRecords(true);

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 20)
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(list) value(A, B, C) mode(permutation)')
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(list) value(1, 2) mode(permutation)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .setDefinition(FObjectOne__c.TestLookup__c, 'serial lookup(FObjectTwo__c) mode(permutation) source(salesforce)');
        obj1.insertRecords(true);
        Test.stopTest();

        Integer errors = 0;
        List<String> results = new List<String>();
        for (FObjectOne__c record : (List<FObjectOne__c>) obj1.getInsertedRecords()) {
            results.add(record.TestText__c + record.TestLookup__c);
        }

        if (listHasDuplicateItems(results)) {
            errors += 1;
        }
        if (results.size() != obj1.getNumberOfRecords()) {
            errors += 2;
        }
        System.assertEquals(0, errors, 'permutations - errors found');
    }

    @IsTest
    private static void permutations_noLookupRecords_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 20)
            .setNumberOfRecords('auto')

            .setDefinition(FObjectOne__c.TestLookup__c, 'serial lookup(FObjectTwo__c) mode(permutation) source(salesforce)')
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(list) value(A, B, C) mode(permutation)')
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(list) value(1, 2) mode(permutation)')
            .createRecords();
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c record : (List<FObjectOne__c>) obj.getInsertedRecords()) {
            if (String.isNotBlank(record.TestLookup__c)) {
                errors += 1;
                break;
            }
        }
        System.assertEquals(0, errors, 'permutations - errors found');
    }

    //* METHODS */

    private static Boolean listHasDuplicateItems(List<String> listToCheck) {
        Set<String> setToCheck = new Set<String>(listToCheck);
        return setToCheck.size() != listToCheck.size();
    }

}
