/*
  Forceea data factory (v2.5)
  Copyright (C) 2022 Nikos Mitrakis

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
public class ForceeaGeneratorSerialLookupTest {

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

}
