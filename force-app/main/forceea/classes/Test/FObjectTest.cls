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
public class FObjectTest {

    @IsTest
    private static void createRecords_canInsertUsersDefault_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject('User', 1);
        Test.stopTest();

        System.assert(!obj.canInsertUsers, 'createRecords - errors found');
    }

    @IsTest
    private static void createRecords_canInsertUsersSetTrue_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(User.SObjectType, 1);
        obj.canInsertUsers(true);
        Test.stopTest();

        System.assert(obj.canInsertUsers, 'createRecords - errors found');
    }

    @IsTest
    private static void createRecords_getRecordsBeforeInsertRecords_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition(FObjectOne__c.TestInteger__c, 'serial type(number) from(1) step(1) scale(0)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');

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
        System.assertEquals(0, errors, 'createRecords - errors found');
    }

    @IsTest
    private static void createRecords_insertRecordsBeforeGetRecords_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition(FObjectOne__c.TestInteger__c, 'serial type(number) from(1) step(1) scale(0)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
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
        System.assertEquals(0, errors, 'createRecords - errors found');
    }

    @IsTest
    private static void createRecords_callOnceAfterInsertRecords_expectSuccess() {
        Integer size1 = 201;
        Integer size2 = 100;

        Test.startTest();

        FObject obj = new FObject(FObjectOne__c.SObjectType, size1);
        obj
            .setDefinition(FObjectOne__c.TestInteger__c, 'serial type(number) from(1) step(1) scale(0)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .createRecords()
            .insertRecords(true);
        List<FObjectOne__c> insertedRecords1 = [SELECT TestInteger__c FROM FObjectOne__c LIMIT 1000];

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
        System.assertEquals(0, errors, 'createRecords - errors found');
    }

    @IsTest
    private static void createRecords_callTwiceAfterInsertRecords_expectSuccess() {
        Integer size1 = 10;
        Integer size2 = 5;
        Integer size3 = 2;

        Test.startTest();

        FObject obj = new FObject(FObjectOne__c.SObjectType, size1);
        obj.setDefinition(FObjectOne__c.TestInteger__c, 'serial type(number) from(1) step(1) scale(0)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
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
        System.assertEquals(0, errors, 'createRecords - errors found');
    }

    @IsTest
    private static void createRecords_discontinuousRecordNumber_expectSuccess() {
        Integer size1 = 21;
        Integer size2 = 10;

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, size1);
        obj.setDefinition(FObjectOne__c.TestInteger__c, 'serial type(number) from(1) step(1) scale(0)')
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
        System.assertEquals(0, errors, 'createRecords - errors found');
    }

    @IsTest
    private static void createRecords_invalidRecordNumber_expectFailure() {
        FObject.setExceptionHandling('continue');

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.createRecords(0);
        Test.stopTest();

        System.assert(!FObject.processIsValid(), 'createRecords - errors found');
    }

    @IsTest
    private static void createRecords_noDefinitions_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .createRecords();
        List<Database.SaveResult> saveResults = obj.insertRecords(true);
        Test.stopTest();

        Integer errors = 0;
        for (Database.SaveResult sr : saveResults) {
            if (!sr.isSuccess()) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'insertRecords - errors found');
    }

    @IsTest
    private static void createRecords_validateDefaultQueryLimit_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(FObjectOne__c.TestInteger__c, 'serial type(number) from(1) step(1) scale(0)');
        Test.stopTest();

        System.assert(obj.getQueryLimit() == FObject.DEFAULT_QUERY_LIMIT, 'createRecords - errors found');
    }

    @IsTest
    private static void createRecords_validateQueryLimitLessThanMin_expectSuccess() {
        Integer myLimit = 0;

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType)
            .setQueryLimit(myLimit);
        Test.stopTest();

        System.assert(obj.getQueryLimit() == 1, 'createRecords - errors found');
    }

    @IsTest
    private static void createRecords_validateQueryLimitMoreThanMax_expectSuccess() {
        Integer myLimit = 51000;

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType)
            .setQueryLimit(myLimit);
        Test.stopTest();

        System.assert(obj.getQueryLimit() == 50000, 'createRecords - errors found');
    }

    @IsTest
    private static void createRecords_validateQueryLimit_expectSuccess() {
        Integer myLimit = 200;

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType)
            .setQueryLimit(myLimit);
        Test.stopTest();

        System.assert(obj.getQueryLimit() == myLimit, 'createRecords - errors found');
    }

    @IsTest
    private static void createRecords_validateGlobalQueryLimitLessThanMin_expectSuccess() {
        Integer myLimit = 0;

        FObject.setGlobalQueryLimit(myLimit);
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        Test.stopTest();

        System.assert(obj.getQueryLimit() == 1, 'createRecords - errors found');
    }

    @IsTest
    private static void createRecords_validateGlobalQueryLimitMoreThanMax_expectSuccess() {
        Integer myLimit = 51000;

        FObject.setGlobalQueryLimit(myLimit);
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        Test.stopTest();

        System.assert(obj.getQueryLimit() == 50000, 'createRecords - errors found');
    }

    @IsTest
    private static void createRecords_validateGlobalQueryLimit_expectSuccess() {
        Integer myLimit = 200;

        FObject.setGlobalQueryLimit(myLimit);
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        Test.stopTest();

        System.assert(obj.getQueryLimit() == myLimit, 'createRecords - errors found');
    }

    @IsTest
    private static void createRecords_validateRecordNumber_expectSuccess() {
        Integer size1 = 20;
        Integer size2 = 10;

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, size1);
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
        System.assertEquals(0, errors, 'createRecords - errors found');
    }

    @IsTest
    private static void customSettings_defaultDataset_expectSuccess() {
        insert new ForceeaSettings__c(
            Name = 'default',
            RecordsToCreate__c = 100,
            RecordsToDisplay__c = 20,
            MaxErrorRecordsToDisplay__c = 30,
            UserMessage__c = 'Welcome'
        );

        Test.startTest();
        new FObject(FObjectOne__c.SObjectType)
            .createRecords();
        Test.stopTest();

        Integer errors = 0;
        if (FObject.numRecordsToCreate != 100) {
            errors += 1;
        }
        if (FObject.numRecordsToDisplay != 20) {
            errors += 2;
        }
        if (FObject.numMaxErrorRecordsToDisplay != 30) {
            errors += 4;
        }
        if (FObject.userMessage != 'Welcome') {
            errors += 8;
        }
        System.assertEquals(0, errors, 'setVerbose - errors found');
    }

    @IsTest
    private static void fObjectConstructor_invalidSObject_expectFailure() {
        FObject.setExceptionHandling('continue');

        Test.startTest();
        FObject obj = new FObject(' FObjectOneX__c ');
        Test.stopTest();

        String expectedResult = 'Invalid SObject [FObjectOneX__c]';
        String actualResult = obj.getErrors().get('FObjectOneX__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'FObject constructor - errors found');
    }

    @IsTest
    private static void fObjectConstructor_blankSObject_expectFailure() {
        FObject.setExceptionHandling('continue');

        Test.startTest();
        FObject obj = new FObject('');
        Test.stopTest();

        String expectedResult = 'Invalid SObject []';
        String actualResult = obj.getErrors().get('').get(0);
        System.assertEquals(expectedResult, actualResult, 'FObject constructor - errors found');
    }

    @IsTest
    private static void fObjectConstructor_defaultNumRecords_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(FObjectOne__c.TestDecimal__c, ' Random type(number ) from( 100) to(1000000 ) scale(3) ');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        System.assertEquals(201, records.size(), 'FObject constructor - errors found');
    }

    @IsTest
    private static void fObjectConstructor_validNumRecords_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition(FObjectOne__c.TestDecimal__c, 'Random Type (number ) from( 100) to(1000000 ) scale(3)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        System.assertEquals(10, records.size(), 'FObject constructor - errors found');
    }

    @IsTest
    private static void fObjectConstructor_recordWithoutGroup_expectSuccess() {
        FObjectOne__c record = new FObjectOne__c(TestTextRequired__c = 'test');
        insert record;

        Test.startTest();
        FObject obj = new FObject(record);
        Test.stopTest();

        Integer errors = 0;
        if (obj.getInsertedRecords().size() != 1) {
            errors += 1;
        }
        if (obj.getSObjectApiName() != 'FObjectOne__c') {
            errors += 2;
        }
        System.assertEquals(0, errors, 'FObject constructor - errors found');
    }

    @IsTest
    private static void fObjectConstructor_recordWithGroup_expectSuccess() {
        FObjectOne__c record = new FObjectOne__c(TestTextRequired__c = 'test');
        insert record;

        Test.startTest();
        FObject obj = new FObject(record, 'Group1');
        Test.stopTest();

        Integer errors = 0;
        if (obj.getInsertedGroupRecords('group1').size() != 1) {
            errors += 1;
        }
        if (obj.getSObjectApiName() != 'FObjectOne__c') {
            errors += 2;
        }
        System.assertEquals(0, errors, 'FObject constructor - errors found');
    }

    @IsTest
    private static void fObjectConstructor_nullRecord_expectSuccess() {
        FObjectOne__c record;

        Test.startTest();
        FObject obj = new FObject(record, 'Group1');
        Test.stopTest();

        Integer errors = 0;
        if (String.isNotBlank(obj.getSObjectApiName())) {
            errors++;
        }
        System.assertEquals(0, errors, 'FObject constructor - errors found');
    }

    @IsTest
    private static void fObjectConstructor_recordsWithoutGroup_expectSuccess() {
        List<FObjectOne__c> records = new List<FObjectOne__c>();
        for (Integer counter = 1; counter <= 10; counter++) {
            records.add(new FObjectOne__c(
                TestTextRequired__c = 'Test' + String.valueOf(counter)
            ));
        }
        insert records;

        Test.startTest();
        FObject obj = new FObject(records);
        Test.stopTest();

        Integer errors = 0;
        if (obj.getInsertedRecords().size() != records.size()) {
            errors += 1;
        }
        if (obj.getSObjectApiName() != 'FObjectOne__c') {
            errors += 2;
        }
        System.assertEquals(0, errors, 'FObject constructor - errors found');
    }

    @IsTest
    private static void fObjectConstructor_recordsWithoutGroupForUpdate_expectSuccess() {
        final String text = 'Test';

        List<FObjectOne__c> records = new List<FObjectOne__c>();
        for (Integer counter = 1; counter <= 10; counter++) {
            records.add(new FObjectOne__c(
                TestTextRequired__c = 'Tests' + String.valueOf(counter)
            ));
        }
        insert records;

        Test.startTest();
        FObject obj = new FObject(records)
            .setVariable('text', text)
            .setDefinitionForUpdate(FObjectOne__c.TestTextRequired__c, 'static value({@text})')
            .updateFields('');
        obj.updateRecords(true);
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c record : [SELECT TestTextRequired__c FROM FObjectOne__c]) {
            if (record.TestTextRequired__c != text) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'FObject constructor - errors found');
    }

    @IsTest
    private static void fObjectConstructor_recordsWithGroup_expectSuccess() {
        List<FObjectOne__c> records = new List<FObjectOne__c>();
        for (Integer counter = 1; counter <= 10; counter++) {
            records.add(new FObjectOne__c(
                TestTextRequired__c = 'Test' + String.valueOf(counter)
            ));
        }
        insert records;

        Test.startTest();
        FObject obj = new FObject(records, 'Group1');
        Test.stopTest();

        Integer errors = 0;
        if (obj.getInsertedGroupRecords('group1').size() != records.size()) {
            errors += 1;
        }
        if (obj.getSObjectApiName() != 'FObjectOne__c') {
            errors += 2;
        }
        System.assertEquals(0, errors, 'FObject constructor - errors found');
    }

    @IsTest
    private static void fObjectConstructor_recordsWithGroupForUpdate_expectSuccess() {
        final String text = 'Test';
        final String recordGroup = 'Group1';

        List<FObjectOne__c> records = new List<FObjectOne__c>();
        for (Integer counter = 1; counter <= 10; counter++) {
            records.add(new FObjectOne__c(
                TestTextRequired__c = 'Tests' + String.valueOf(counter)
            ));
        }
        insert records;

        Test.startTest();
        FObject obj = new FObject(records, recordGroup)
            .setVariable('text', text)
            .setDefinitionForUpdate(FObjectOne__c.TestTextRequired__c, 'static value({@text})')
            .updateFields(recordGroup);
        obj.updateRecords(true);
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c record : [SELECT TestTextRequired__c FROM FObjectOne__c]) {
            if (record.TestTextRequired__c != text) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'FObject constructor - errors found');
    }

    @IsTest
    private static void getGlobalQueryLimit_standard_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        Integer result = obj.getGlobalQueryLimit();
        Test.stopTest();

        System.assertEquals(FObject.DEFAULT_QUERY_LIMIT, result, 'getGlobalQueryLimit - error found');
    }

    @IsTest
    private static void getGlobalVerbose_none_expectSuccess() {
        Test.startTest();
        String result = FObject.getGlobalVerbose();
        Test.stopTest();

        System.assertEquals('none', result, 'getGlobalVerbose - error found');
    }

    @IsTest
    private static void getGlobalVerbose_info_expectSuccess() {
        String mode = 'Info';
        FObject.setGlobalVerbose(mode); // DO NOT REMOVE

        Test.startTest();
        String result = FObject.getGlobalVerbose();
        Test.stopTest();

        System.assertEquals(mode.toLowerCase(), result, 'getGlobalVerbose - error found');
    }

    @IsTest
    private static void getGlobalVerbose_debug_expectSuccess() {
        String mode = 'Debug';
        FObject.setGlobalVerbose(mode); // DO NOT REMOVE

        Test.startTest();
        String result = FObject.getGlobalVerbose();
        Test.stopTest();

        System.assertEquals(mode.toLowerCase(), result, 'getGlobalVerbose - error found');
    }

    @IsTest
    private static void getGroupName_isInsert_expectSuccess() {
        String groupName = 'MyGroup';

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 5)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(test)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj.insertRecords(true, groupName);
        Test.stopTest();

        System.assert(obj.getGroupName() == groupName, 'getFieldApiName - errors found');
    }

    @IsTest
    private static void getGroupName_invalidInSetGroupName_expectSuccess() {
        String groupName = 'MyGroup';

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 5)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(test)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .setGroupName(groupName);
        obj.insertRecords(true);
        Test.stopTest();

        System.assert(obj.getGroupName() == groupName, 'getFieldApiName - errors found');
    }


    @IsTest
    private static void getNumberOfRecords_valid_expectSuccess() {
        Integer numberOfRecords = 100;

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setNumberOfRecords(numberOfRecords);

        System.assert(obj.getNumberOfRecords() == numberOfRecords, 'getNumberOfRecords - errors found');
    }

    @IsTest
    private static void getNumberOfRecords_invalid_expectSuccess() {
        Integer numberOfRecords = -10;

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setNumberOfRecords(numberOfRecords);

        System.assert(obj.getNumberOfRecords() == 1, 'getNumberOfRecords - errors found');
    }

    @IsTest
    private static void getRecords_withoutNewDefinitions_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition(FObjectOne__c.TestText__c, 'static value(sample)');
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
        FObject obj = new FObject(FObjectOne__c.SObjectType, size1)
            .setDefinition(FObjectOne__c.TestInteger__c, 'serial type(number) from(1) step(1) scale(0)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj.getRecords();

        obj.setNumberOfRecords(size2);
        obj.removeDefinitions('TestInteger__c');
        obj.setDefinition(FObjectOne__c.TestInteger__c, 'serial type(number) from(1) step(1) scale(0)');
        List<FObjectOne__c> records2 = (List<FObjectOne__c>) obj.getRecords();
        obj.insertRecords(true);
        Test.stopTest();

        List<FObjectOne__c> insertedRecords = [SELECT TestInteger__c FROM FObjectOne__c LIMIT 1000];
        Integer errors = 0;
        if (records1.size() + records2.size() != insertedRecords.size()) {
            errors++;
        }
        if (records2[records2.size() - 1].TestInteger__c != (size1 + size2)) {
            errors++;
        }
        System.assertEquals(0, errors, 'getRecords - errors found');
    }

    @IsTest
    private static void getRecords_insertRecordsBeforeGetRecords_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(sample)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
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
        System.assertEquals(0, errors, 'getRecords - errors found');
    }

    @IsTest
    private static void getRecords_insertRecordsTwice_expectSuccess() {
        Integer size1 = 201;
        Integer size2 = 100;

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, size1)
            .setDefinition(FObjectOne__c.TestInteger__c, 'serial type(number) from(1) step(1) scale(0)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
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
        System.assertEquals(0, errors, 'getRecords - errors found');
    }

    @IsTest
    private static void getRecords_afterRecordsAreDeleted_expectSuccess() {
        FObject.setSeed(1);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestText__c, 'random type(list) value(v1,v2,v3)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj.getRecords();
        obj.insertRecords(true);
        obj.deleteRecords('TestText__c = \'v1\'', true);
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
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestDecimal__c, 'random type(number) from(1) to(100) scale(0)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');

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
        System.assertEquals(0, errors, 'getRecords - errors found');
    }

    @IsTest
    private static void getRecords_setNumberOfNextRecords1_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(number) from(1) step(1) scale(0)')
            .createRecords()

            .setDefinition(FObjectOne__c.TestText__c, 'static value(-test)')
            .setDefinition(FObjectOne__c.TestInteger__c, 'serial type(number) from(1) step(1) scale(0)')
            .createRecords()

            .setNumberOfNextRecord(1)
            .removeDefinitions(FObjectOne__c.TestInteger__c)
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(number) from(1) step(1) scale(0)')
            .setDefinition(FObjectOne__c.TestInteger__c, 'serial type(number) from(1) step(1) scale(0)');
        Test.stopTest();

        Integer errors = 0;
        Integer counter = 1;
        List<FObjectOne__c> records = obj.getRecords();
        for (FObjectOne__c record : records) {
            String str = String.valueOf(counter);
            if (record.TestInteger__c != counter && record.TestText__c != str + '-test' + str) {
                errors++;
            }
            counter++;
        }
        System.assertEquals(0, errors, 'getRecords - errors found');
    }

    @IsTest
    private static void getRecords_setNumberOfNextRecords2_expectSuccess() {
        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(Test-)')
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(number) from(1) step(1) scale(0)')
            .createRecords();
        FObject obj2 = new FObject(FObjectOne__c.SObjectType, 10)
            .setNumberOfNextRecord(1)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(Test-)')
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(number) from(1) step(1) scale(0)')
            .createRecords();
        Test.stopTest();

        Integer errors = 0;
        Integer counter = 1;
        List<FObjectOne__c> records1 = obj1.getRecords();
        List<FObjectOne__c> records2 = obj2.getRecords();
        for (FObjectOne__c record : records1) {
            String str = String.valueOf(counter);
            if (record.TestText__c != str &&
                records1.get(counter - 1).TestText__c != records2.get(counter - 1).TestText__c) {
                errors++;
            }
            counter++;
        }
        System.assertEquals(0, errors, 'getRecords - errors found');
    }

    @IsTest
    private static void getVariable_number_expectSuccess() {
        String name = 'myVar';

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType)
            .setVariable(name, 100);
        Test.stopTest();

        System.assertEquals('100', obj.getVariable(name), 'getVariable - errors found');
    }

    @IsTest
    private static void getVariable_boolean_expectSuccess() {
        String name = 'myVar';

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType)
            .setVariable(name, false);
        Test.stopTest();

        System.assertEquals('false', obj.getVariable(name), 'getVariable - errors found');
    }

    @IsTest
    private static void getGlobalVariable_number_expectSuccess() {
        String name = 'myVar';

        Test.startTest();
        FObject.setGlobalVariable(name, 100);
        Test.stopTest();

        System.assertEquals('100', FObject.getGlobalVariable(name), 'getVariable - errors found');
    }

    @IsTest
    private static void getGlobalVariable_boolean_expectSuccess() {
        String name = 'myVar';

        Test.startTest();
        FObject.setGlobalVariable(name, false);
        Test.stopTest();

        System.assertEquals('false', FObject.getGlobalVariable(name), 'getVariable - errors found');
    }

    @IsTest
    private static void prng_checkGenerator_expectSuccess() {
        Test.startTest();
        FObject.setSeed(19660805);
        FObject obj1 = new FObject(FObjectOne__c.SObjectType)
            .setDefinition(FObjectOne__c.TestInteger__c,'random type(number) from(1) to(100) scale(0)')
            .createRecords();
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();

        FObject.setSeed(19660805);
        FObject obj2 = new FObject(FObjectOne__c.SObjectType)
            .setDefinition(FObjectOne__c.TestInteger__c,'random type(number) from(1) to(100) scale(0)')
            .createRecords();
        List<FObjectOne__c> records2 = (List<FObjectOne__c>) obj2.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (Integer counter = 0; counter < 100; counter++) {
            if (records1.get(counter).TestInteger__c != records2.get(counter).TestInteger__c ||
                records1.get(counter).TestTextRequired__c != records2.get(counter).TestTextRequired__c) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'PRNG - errors found');
    }

    @IsTest
    private static void setGlobalVerbose_debug_expectSuccess() {
        FObject.setGlobalVerbose('debug'); // DO NOT REMOVE

        Test.startTest();
        new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .createRecords();
        Test.stopTest();

        Integer counter = 0;
        for (String log : FObject.getGlobalDebugLogs()) {
            if (log.startsWith('- Definition [')) {
                counter++;
            }
        }
        System.assert(counter > 0, 'setVerbose - errors found');
    }

    @IsTest
    private static void setGlobalVerbose_info_expectSuccess() {
        FObject.setGlobalVerbose('info');  // DO NOT REMOVE

        Test.startTest();
        new FObject(FObjectOne__c.SObjectType, 10)
            .createRecords();
        Test.stopTest();

        Integer errors = 0;
        for (String log : FObject.getGlobalDebugLogs()) {
            if (log.startsWith('- Definition [')) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'setVerbose - errors found');
    }

    @IsTest
    private static void setGlobalVerbose_none_expectSuccess() {
        FObject.setGlobalVerbose('none'); // DO NOT REMOVE

        Test.startTest();
        new FObject(FObjectOne__c.SObjectType, 10)
            .createRecords();
        Test.stopTest();

        System.assert(FObject.getGlobalDebugLogs().isEmpty(), 'setVerbose - errors found');
    }

    @IsTest
    private static void setSource_previousForceeaNewSalesforce_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 5)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        obj2.insertRecords(true);

        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 10)
            .setVariable('source', ForceeaService.SOURCE_FORCEEA)
            .setDefinition(FObjectOne__c.TestLookup__c, 'random lookup(FObjectTwo__c) source({@source})')
            .setDefinition(FObjectOne__c.TestLookupOther__c, 'random lookup(FObjectTwo__c) source({@source})')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj1.insertRecords(true);

        Test.startTest();
        obj1
            .setNumberOfRecords(20)
            .setSource(ForceeaService.SOURCE_SALESFORCE);
        obj1.insertRecords(true);
        Integer soqlQueries = Limits.getQueries();
        Test.stopTest();

        System.assert(newSourceIsValid(ForceeaService.SOURCE_SALESFORCE, obj1, soqlQueries, 2, 30),
            'The source was not set correctly');
    }

    @IsTest
    private static void setSource_previousForceeaNewSalesforce1Def_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 5)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        obj2.insertRecords(true);

        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 10)
            .setVariable('source', ForceeaService.SOURCE_FORCEEA)
            .setDefinition(FObjectOne__c.TestLookup__c, 'random lookup(FObjectTwo__c) source({@source})')
            .setDefinition(FObjectOne__c.TestLookupOther__c, 'random lookup(FObjectTwo__c) source({@source})')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj1.insertRecords(true);

        Test.startTest();
        obj1
            .setNumberOfRecords(20)
            .setSource(FObjectOne__c.TestLookup__c, ForceeaService.SOURCE_SALESFORCE);
        obj1.insertRecords(true);
        Integer soqlQueries = Limits.getQueries();
        Test.stopTest();

        System.assert(newSourceIsValidFor1Def(ForceeaService.SOURCE_SALESFORCE, obj1, soqlQueries, 1, 30),
            'The source was not set correctly');
    }

    @IsTest
    private static void setSource_previousForceeaNewSalesforceBeforeDef_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 5)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        obj2.insertRecords(true);

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 10)
            .setVariable('source', ForceeaService.SOURCE_FORCEEA)
            .setSource(ForceeaService.SOURCE_SALESFORCE)
            .setDefinition(FObjectOne__c.TestLookup__c, 'random lookup(FObjectTwo__c) source({@source})')
            .setDefinition(FObjectOne__c.TestLookupOther__c, 'random lookup(FObjectTwo__c) source({@source})')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj1.insertRecords(true);
        Integer soqlQueries = Limits.getQueries();
        Test.stopTest();

        System.assert(newSourceIsValid(ForceeaService.SOURCE_FORCEEA, obj1, soqlQueries, 0, 10),
            'The source was not set correctly');
    }

    @IsTest
    private static void setSource_previousSalesforceNewForceea_expectSuccess() {
        FObject obj2 = new FObject(FObjectTwo__c.SObjectType, 5)
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');
        obj2.insertRecords(true);

        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 10)
            .setVariable('source', ForceeaService.SOURCE_SALESFORCE)
            .setDefinition(FObjectOne__c.TestLookup__c, 'random lookup(FObjectTwo__c) source({@source})')
            .setDefinition(FObjectOne__c.TestLookupOther__c, 'random lookup(FObjectTwo__c) source({@source})')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj1.insertRecords(true);

        Test.startTest();
        obj1
            .setSource(ForceeaService.SOURCE_FORCEEA);
        obj1.insertRecords(true);
        Integer soqlQueries = Limits.getQueries();
        Test.stopTest();

        System.assert(newSourceIsValid(ForceeaService.SOURCE_FORCEEA, obj1, soqlQueries, 0, 20),
            'The source was not set correctly');
    }

    @IsTest
    private static void setStandardPricebookEntries_virtualFieldNotExists_expectFailure() {
        String errorMessage = 'Invalid virtual field [$WrongStandardPrice] in method [setStandardPricebookEntries]';

        Test.startTest();
        FObject obj = new FObject(Product2.SObjectType, 10)
            .setRequiredFields(true)
            .setDefinition(Product2.Name, 'static value("Product-")')
            .setDefinition(Product2.Name, 'serial type(number) from(1) step(1) scale(0)')
            .setDefinition(Product2.Description, 'random type(text) minLength(25) maxLength(50)')
            .setDefinition('$StandardPrice', 'serial type(number) from(1) step(1) scale(0)')
            .setStandardPricebookEntries('$WrongStandardPrice');

        Integer errors = 0;
        Integer dmlErrors = 0;
        try {
            obj.insertRecords(true);
            if (!obj.getErrors().get('Product2').get(0).startsWith(errorMessage)) {
                errors++;
            }
        } catch (DmlException exp) {
            dmlErrors++;
        }
        Test.stopTest();

        Assert.areEqual(0, errors, 'setStandardPricebookEntries - errors found');
    }

    @IsTest
    private static void setStandardPricebookEntries_nonProduct2SObject_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestText__c, 'random type(list) value(v1,v2,v3)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj.insertRecords(true);
        Test.stopTest();

        List<PricebookEntry> entries = [SELECT Id FROM PricebookEntry];
        System.assert(entries.isEmpty(), 'setStandardPricebookEntries - errors found');
    }

    @IsTest
    private static void setVerbose_debug_expectSuccess() {
        Test.startTest();
        new FObject(FObjectOne__c.SObjectType, 10)
            .setVerbose('debug') // DO NOT REMOVE
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .createRecords();
        Test.stopTest();

        Integer counter = 0;
        for (String log : FObject.getGlobalDebugLogs()) {
            if (log.startsWith('- Definition [')) {
                counter++;
            }
        }
        System.assert(counter > 0, 'setVerbose - errors found');
    }

    @IsTest
    private static void setVerbose_info_expectSuccess() {
        Test.startTest();
        new FObject(FObjectOne__c.SObjectType, 10)
            .setVerbose('info') // DO NOT REMOVE
            .createRecords();
        Test.stopTest();

        Integer errors = 0;
        for (String log : FObject.getGlobalDebugLogs()) {
            if (log.startsWith('- Definition [')) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'setVerbose - errors found');
    }

    @IsTest
    private static void setVerbose_none_expectSuccess() {
        Test.startTest();
        new FObject(FObjectOne__c.SObjectType, 10)
            .setVerbose('none') // DO NOT REMOVE
            .createRecords();
        Test.stopTest();

        System.assert(FObject.getGlobalDebugLogs().isEmpty(), 'setVerbose - errors found');
    }

    @IsTest
    private static void variable_boolean_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setVariable('var', true)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(test: {@var} !test)');
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c objRecord : (List<FObjectOne__c>) obj.getRecords()) {
            if (objRecord.TestText__c != 'test: ' + obj.getVariable('var') + ' !test') {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'variables - errors found');
    }

    @IsTest
    private static void variable_date_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setVariable('var', Date.today())
            .setDefinition(FObjectOne__c.TestText__c, 'static value(test: {@var} !test)');
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c objRecord : (List<FObjectOne__c>) obj.getRecords()) {
            if (objRecord.TestText__c != 'test: ' + obj.getVariable('var') + ' !test') {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'variables - errors found');
    }

    @IsTest
    private static void variable_datetime_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setVariable('var', Datetime.now())
            .setDefinition(FObjectOne__c.TestText__c, 'static value(test: {@var} !test)');
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c objRecord : (List<FObjectOne__c>) obj.getRecords()) {
            if (objRecord.TestText__c != 'test: ' + obj.getVariable('var') + ' !test') {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'variables - errors found');
    }

    @IsTest
    private static void variable_decimal_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setVariable('var', 12.34)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(test{@var} !test)');
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c objRecord : (List<FObjectOne__c>) obj.getRecords()) {
            if (objRecord.TestText__c != 'test' + obj.getVariable('var') + ' !test') {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'variables - errors found');
    }

    @IsTest
    private static void variable_integer_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setVariable('var', 1234)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(test{@var} !test)');
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c objRecord : (List<FObjectOne__c>) obj.getRecords()) {
            if (objRecord.TestText__c != 'test' + obj.getVariable('var') + ' !test') {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'variables - errors found');
    }

    @IsTest
    private static void variable_string_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setVariable('var', 'test')
            .setDefinition(FObjectOne__c.TestText__c, 'static value(test{@var} !test)');
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c objRecord : (List<FObjectOne__c>) obj.getRecords()) {
            if (objRecord.TestText__c != 'test' + obj.getVariable('var') + ' !test') {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'variables - errors found');
    }

    @IsTest
    private static void variable_allDataTypes_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setVariable('varBoolean', false)
            .setVariable('varDate', Date.today())
            .setVariable('varDatetime', Datetime.now())
            .setVariable('varDec', 12.34)
            .setVariable('varInt', 123)
            .setVariable('varStr', 'abc')
            .setDefinition(FObjectOne__c.TestCheckbox__c, 'static value({@varBoolean})')
            .setDefinition(FObjectOne__c.TestDate__c, 'static value({@varDate})')
            .setDefinition(FObjectOne__c.TestDatetime__c, 'static value({@varDatetime})')
            .setDefinition(FObjectOne__c.TestDecimal__c, 'static value({@varDec})')
            .setDefinition(FObjectOne__c.TestInteger__c, 'static value({@varInt})')
            .setDefinition(FObjectOne__c.TestText__c, 'static value(test: {@varStr} !test)');
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c objRecord : (List<FObjectOne__c>) obj.getRecords()) {
            if (String.valueOf(objRecord.TestCheckbox__c) != obj.getVariable('varBoolean') ||
                String.valueOf(objRecord.TestDate__c) != obj.getVariable('varDate') ||
                String.valueOf(objRecord.TestDatetime__c) != obj.getVariable('varDatetime') ||
                String.valueOf(objRecord.TestDecimal__c) != obj.getVariable('varDec') ||
                String.valueOf(objRecord.TestInteger__c.setScale(0)) != obj.getVariable('varInt') ||
                objRecord.TestText__c != 'test: ' + obj.getVariable('varStr') + ' !test'
                ) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'variables - errors found');
    }

    @IsTest
    private static void variable_globalVariable_expectSuccess() {
        FObject.setGlobalVariable('varBoolean', true);
        FObject.setGlobalVariable('varInteger', 1);
        FObject.setGlobalVariable('varDecimal', 1.23);
        FObject.setGlobalVariable('varDate', Date.today());
        FObject.setGlobalVariable('varDatetime', Datetime.now());
        FObject.setGlobalVariable('varString', 'test');

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition('$Boolean', 'static value({@varBoolean})')
            .setDefinition('$Integer', 'static value({@varInteger})')
            .setDefinition('$Decimal', 'static value({@varDecimal})')
            .setDefinition('$Date', 'static value({@varDate})')
            .setDefinition('$Datetime', 'static value({@varDatetime})')
            .setDefinition('$String', 'static value({@varString})')

            .setDefinition(FObjectOne__c.TestCheckbox__c, 'copy field($Boolean)')
            .setDefinition(FObjectOne__c.TestInteger__c, 'copy field($Integer)')
            .setDefinition(FObjectOne__c.TestDecimal__c, 'copy field($Decimal)')
            .setDefinition(FObjectOne__c.TestDate__c, 'copy field($Date)')
            .setDefinition(FObjectOne__c.TestDatetime__c, 'copy field($Datetime)')
            .setDefinition(FObjectOne__c.TestText__c, 'copy field($String)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj.insertRecords(true);
        Test.stopTest();

        System.assert(FObject.processIsValid(), 'variables - errors found');
    }

    @IsTest
    private static void variable_refVirtualField_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setVariable('varBoolean', true)
            .setVariable('varInteger', 1)
            .setVariable('varDecimal', 1.23)
            .setVariable('varDate', Date.today())
            .setVariable('varDatetime', Datetime.now())
            .setVariable('varString', 'test')

            .setDefinition('$Boolean', 'static value({@varBoolean})')
            .setDefinition('$Integer', 'static value({@varInteger})')
            .setDefinition('$Decimal', 'static value({@varDecimal})')
            .setDefinition('$Date', 'static value({@varDate})')
            .setDefinition('$Datetime', 'static value({@varDatetime})')
            .setDefinition('$String', 'static value({@varString})')

            .setDefinition(FObjectOne__c.TestCheckbox__c, 'copy field($Boolean)')
            .setDefinition(FObjectOne__c.TestInteger__c, 'copy field($Integer)')
            .setDefinition(FObjectOne__c.TestDecimal__c, 'copy field($Decimal)')
            .setDefinition(FObjectOne__c.TestDate__c, 'copy field($Date)')
            .setDefinition(FObjectOne__c.TestDatetime__c, 'copy field($Datetime)')
            .setDefinition(FObjectOne__c.TestText__c, 'copy field($String)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj.insertRecords(true);
        Test.stopTest();

        System.assert(FObject.processIsValid(), 'variables - errors found');
    }

    /* UTILITY METHODS */

    private static Boolean definitionStringsAreValid(String newSource, FObject fObj) {
        String definition1 = fObj.getDefinitions(FObjectOne__c.TestLookup__c).get(0);
        String definition2 = fObj.getDefinitions(FObjectOne__c.TestLookupOther__c).get(0);
        String newSourceCluster = 'source(' + newSource + ')';

        return definition1.contains(newSourceCluster) && definition2.contains(newSourceCluster);
    }

    private static Boolean definitionStringsIsValid(String newSource, FObject fObj) {
        String newSourceCluster = 'source(' + newSource + ')';
        return fObj
            .getDefinitions(FObjectOne__c.TestLookup__c)
            .get(0)
            .contains(newSourceCluster);
    }

    private static Boolean newSourceIsValid(String newSource, FObject fObj,
        Integer numOfActualSoqlQueries, Integer numOfExpectedSoqlQueries,
        Integer numOfExpectedInsertedRecords) {

        return definitionStringsAreValid(newSource, fObj) &&
            numOfQueriesIsCorrect(numOfActualSoqlQueries, numOfExpectedSoqlQueries) &&
            numOfInsertedRecordsIsCorrect(numOfExpectedInsertedRecords);
    }

    private static Boolean newSourceIsValidFor1Def(String newSource, FObject fObj,
        Integer numOfActualSoqlQueries, Integer numOfExpectedSoqlQueries,
        Integer numOfExpectedInsertedRecords) {

        return definitionStringsIsValid(newSource, fObj) &&
            numOfQueriesIsCorrect(numOfActualSoqlQueries, numOfExpectedSoqlQueries) &&
            numOfInsertedRecordsIsCorrect(numOfExpectedInsertedRecords);
    }

    private static Boolean numOfInsertedRecordsIsCorrect(Integer numOfExpectedInsertedRecords) {
        return FObject.getInsertedRecords(FObjectOne__c.SObjectType).size() == numOfExpectedInsertedRecords;
    }

    private static Boolean numOfQueriesIsCorrect(Integer numOfActualSoqlQueries, Integer numOfExpectedSoqlQueries) {
        return numOfExpectedSoqlQueries == numOfActualSoqlQueries;
    }

}