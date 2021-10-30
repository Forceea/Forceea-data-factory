/*
  Forceea data factory (v2.6.0)
  Copyright (C) 2021 Nikos Mitrakis

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
public class FObjectDmlTest {

    @IsTest
    private static void deleteRecords_whereClauseIsBlank_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 100)
            .setDefinition('TestPicklistA__c', 'random type(picklist)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj.insertRecords(true);
        obj.deleteRecords('', true);
        Test.stopTest();

        List<FObjectOne__c> recordsAfterDelete = [SELECT Id FROM FObjectOne__c LIMIT 1000];
        Set<Id> recordIdsAfterDelete = (new Map<Id, FObjectOne__c>(recordsAfterDelete)).keySet();
        Integer errors = 0;
        for (FObjectOne__c objRecord : (List<FObjectOne__c>) obj.getInsertedRecords()) {
            if (!recordIdsAfterDelete.contains(objRecord.Id)) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'deleteRecords - errors found');
    }

    @IsTest
    private static void deleteRecords_whereClauseIsValid_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 100)
            .setDefinition('TestPicklistA__c', 'random type(picklist)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj.insertRecords(true);
        obj.deleteRecords('TestPicklistA__c = \'a1\'', true);
        Test.stopTest();

        List<FObjectOne__c> recordsAfterDelete = [SELECT Id FROM FObjectOne__c];
        Set<Id> recordIdsAfterDelete = (new Map<Id, FObjectOne__c>(recordsAfterDelete)).keySet();
        Integer errors = 0;
        for (FObjectOne__c objRecord : (List<FObjectOne__c>) obj.getInsertedRecords()) {
            if (!recordIdsAfterDelete.contains(objRecord.Id)) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'deleteRecords - errors found');
    }

    @IsTest
    private static void deleteRecords_recordGroup_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 100)
            .setDefinition(FObjectOne__c.TestPicklistA__c, 'random type(picklist)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj.insertRecords(true, 'Group1');
        obj.deleteRecords('TestPicklistA__c = \'a1\'', true);
        Test.stopTest();

        List<FObjectOne__c> recordsAfterDelete1 = [SELECT Id FROM FObjectOne__c];
        Set<Id> recordIdsAfterDelete1 = (new Map<Id, FObjectOne__c>(recordsAfterDelete1)).keySet();
        Integer hash1 = recordIdsAfterDelete1.hashCode();

        List<FObjectOne__c> recordsAfterDelete2 = obj.getInsertedRecords();
        Set<Id> recordIdsAfterDelete2 = (new Map<Id, FObjectOne__c>(recordsAfterDelete2)).keySet();
        Integer hash2 = recordIdsAfterDelete2.hashCode();

        List<FObjectOne__c> recordsAfterDelete3 = obj.getInsertedGroupRecords('GROUP1');
        Set<Id> recordIdsAfterDelete3 = (new Map<Id, FObjectOne__c>(recordsAfterDelete3)).keySet();
        Integer hash3 = recordIdsAfterDelete3.hashCode();

        Integer errors = 0;
        for (FObjectOne__c objRecord : recordsAfterDelete1) {
            if (!recordIdsAfterDelete2.contains(objRecord.Id) || !recordIdsAfterDelete3.contains(objRecord.Id)) {
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
        System.assertEquals(0, errors, 'deleteRecords - errors found');
    }

    @IsTest
    private static void deleteRecords_noRecordsFound_expectSuccess() {
        FObject obj = new FObject(FObjectOne__c.SObjectType, 100)
            .setDefinition(FObjectOne__c.TestPicklistA__c, 'random type(picklist)');
        obj.insertRecords(false, 'Group1');

        List<FObjectOne__c> recordsBeforeDelete = obj.getInsertedGroupRecords('GROUP1');
        Set<Id> recordIdsBeforeDelete = (new Map<Id, FObjectOne__c>(recordsBeforeDelete)).keySet();
        Integer hash = recordIdsBeforeDelete.hashCode();

        Test.startTest();
        obj.deleteRecords('TestPicklistA__c = \'a5\'', true);
        Test.stopTest();

        List<FObjectOne__c> recordsAfterDelete1 = [SELECT Id FROM FObjectOne__c];
        Set<Id> recordIdsAfterDelete1 = (new Map<Id, FObjectOne__c>(recordsAfterDelete1)).keySet();
        Integer hash1 = recordIdsAfterDelete1.hashCode();

        List<FObjectOne__c> recordsAfterDelete2 = obj.getInsertedRecords();
        Set<Id> recordIdsAfterDelete2 = (new Map<Id, FObjectOne__c>(recordsAfterDelete2)).keySet();
        Integer hash2 = recordIdsAfterDelete2.hashCode();

        List<FObjectOne__c> recordsAfterDelete3 = obj.getInsertedGroupRecords('GROUP1');
        Set<Id> recordIdsAfterDelete3 = (new Map<Id, FObjectOne__c>(recordsAfterDelete3)).keySet();
        Integer hash3 = recordIdsAfterDelete3.hashCode();

        Integer errors = 0;
        for (FObjectOne__c objRecord : recordsBeforeDelete) {
            if (!recordIdsAfterDelete1.contains(objRecord.Id) ||
                !recordIdsAfterDelete2.contains(objRecord.Id) ||
                !recordIdsAfterDelete3.contains(objRecord.Id)) {
                errors += 1;
                break;
            }
        }
        if (hash != hash1) {
            errors += 2;
        }
        if (hash != hash2) {
            errors += 4;
        }
        if (hash != hash3) {
            errors += 8;
        }
        System.assertEquals(0, errors, 'deleteRecords - errors found');
    }

    @IsTest
    private static void deleteRecords_deleteException_expectFailure() {
        FObject obj = new FObject(FObjectOne__c.SObjectType)
            .setDefinition('TestPicklistA__c', 'random type(picklist)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj.insertRecords(true);

        Test.startTest();
        Test.setReadOnlyApplicationMode(true);
        List<Database.DeleteResult> deleteResults = obj.deleteRecords('TestPicklistA__c = \'a1\'', false);
        Test.stopTest();

        Integer errors = 0;
        for (Database.DeleteResult dr : deleteResults) {
            if (dr.isSuccess()) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'deleteRecords - errors found');
    }

    @IsTest
    private static void getInsertedRecord_globalGroupIndexZero_expectSuccess() {
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition('TestText__c', 'static value(test)')
            .setDefinition('TestText__c', 'serial type(number) from(1) step(1) scale(0)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');

        Test.startTest();
        obj.insertRecords(true);
        FObjectOne__c result = (FObjectOne__c) obj.getInsertedRecord();
        Test.stopTest();

        System.assertEquals('test1', result.TestText__c, 'getInsertedRecord - errors found');
    }

    @IsTest
    private static void getInsertedRecord_groupIndexZero_expectSuccess() {
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition('TestText__c', 'static value(test)')
            .setDefinition('TestText__c', 'serial type(number) from(1) step(1) scale(0)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');

        Test.startTest();
        obj.insertRecords(true, 'group1');
        FObjectOne__c result = (FObjectOne__c) obj.getInsertedGroupRecord('group1');
        Test.stopTest();

        System.assertEquals('test1', result.TestText__c, 'getInsertedRecord - errors found');
    }

    @IsTest
    private static void getInsertedRecords_twoInstancesOfSameObject_expectSuccess() {
        Integer size1 = 10;
        Integer size2 = 5;

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType, size1)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(a1)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj1.insertRecords(true);

        FObject obj2 = new FObject(FObjectOne__c.SObjectType, size2)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(a1)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
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
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition('TestText__c', 'static value(a1)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj.insertRecords(true);
        records1.addAll((List<FObjectOne__c>) obj.getRecords());

        obj.removeAllDefinitions();

        obj.setDefinition('TestText__c', 'static value(a2)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
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
        FObject obj = new FObject(FObjectOne__c.SObjectType, 100)
            .setDefinition('TestText__c', 'static value(a1)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj.insertRecords(false);
        records1.addAll((List<FObjectOne__c>) obj.getRecords());

        obj.removeAllDefinitions();

        obj
            .setDefinition('TestText__c', 'static value(a2)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            .insertRecords(false);
        records1.addAll((List<FObjectOne__c>) obj.getRecords());
        Test.stopTest();

        records2 = (List<FObjectOne__c>) obj.getInsertedRecords();

        Integer hash1 = records1.hashCode();
        Integer hash2 = records2.hashCode();
        System.assertEquals(hash1, hash2, 'getInsertedRecords - errors found');
    }

    @IsTest
    private static void getInsertedGroupRecords_sameInstance_expectSuccess() {
        String group1 = 'GroupA';
        String group2 = 'GroupB';

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestIntegerUnique__c, 'serial type(number) from(1) step(1) scale(0)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj.insertRecords(true, group1);

        obj.removeDefinitions(FObjectOne__c.TestIntegerUnique__c)
            .setDefinition(FObjectOne__c.TestIntegerUnique__c, 'serial type(number) from(1) step(1) scale(0)');
        obj.insertRecords(true, group2);
        Test.stopTest();

        System.assert(ForceeaUtilityTest.insertedGroupRecordsAreValidForSameInstance(obj, group1, group2), 'getInsertedGroupRecords - errors found');
    }

    @IsTest
    private static void getInsertedGroupRecords_differentInstances_expectSuccess() {
        String group1 = 'GroupA';
        String group2 = 'GroupB';

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.Id, 'mock type(id)')
            .setDefinition(FObjectOne__c.TestText__c, 'static value(Test-)')
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(number) from(1) step(1) scale(0)');
        obj1.insertRecords(true, group1);

        FObject obj2 = new FObject(FObjectOne__c.SObjectType, 10)
            .setNumberOfNextRecord(1)
            .setDefinition(FObjectOne__c.Id, 'mock type(id)')
            .setDefinition(FObjectOne__c.TestText__c, 'static value(Test-)')
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(number) from(1) step(1) scale(0)');
        obj2.insertRecords(true, group2);
        Test.stopTest();

        System.assert(ForceeaUtilityTest.insertedGroupRecordsAreValidForDifferentInstances(obj1, obj2, group1, group2),
            'getInsertedGroupRecords - errors found');
    }

    @IsTest
    private static void getInsertedGroupRecords_differentInstancesWithTemplateNotOptimized_expectSuccess() {
        String group1 = 'GroupA';
        String group2 = 'GroupB';

        Map<String, FObject> template = new Map<String, FObject>();
        template.put('one1', new FObject(FObjectOne__c.SObjectType, 10)
            .setGroupName(group1)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(Test-)')
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(number) from(1) step(1) scale(0)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
        );
        template.put('one2', new FObject(FObjectOne__c.SObjectType, 10)
            .setNumberOfNextRecord(1)
            .setGroupName(group2)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(Test-)')
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(number) from(1) step(1) scale(0)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
        );

        Test.startTest();
        FObject.insertRecordsFromTemplate(template, true);
        Test.stopTest();

        FObject obj1 = template.get('one1');
        FObject obj2 = template.get('one2');
        System.assert(ForceeaUtilityTest.insertedGroupRecordsAreValidForDifferentInstances(obj1, obj2, group1, group2),
            'getInsertedGroupRecords - errors found');
    }

    @IsTest
    private static void getInsertedGroupRecords_differentInstancesWithTemplateOptimized_expectSuccess() {
        String group1 = 'GroupA';
        String group2 = 'GroupB';

        FObject.setDmlOptimizer(true);

        Map<String, FObject> template = new Map<String, FObject>();
        template.put('one1', new FObject(FObjectOne__c.SObjectType, 10)
            .setGroupName(group1)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(Test-)')
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(number) from(1) step(1) scale(0)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
        );
        template.put('one2', new FObject(FObjectOne__c.SObjectType, 10)
            .setNumberOfNextRecord(1)
            .setGroupName(group2)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(Test-)')
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(number) from(1) step(1) scale(0)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
        );

        Test.startTest();
        FObject.insertRecordsFromTemplate(template, true);
        Test.stopTest();

        FObject obj1 = template.get('one1');
        FObject obj2 = template.get('one2');
        System.assert(ForceeaUtilityTest.insertedGroupRecordsAreValidForDifferentInstances(obj1, obj2, group1, group2),
            'getInsertedGroupRecords - errors found');
    }

    @IsTest
    private static void getInsertedRecordsStatic_invalidObject_expectFailure() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) source(forceea)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
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
        FObject obj1 = new FObject(FObjectTwo__c.SObjectType, size1)
            .setDefinition('TestText__c', 'serial type(number) from(1) step(1) scale(0)')
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)');

        obj1.insertRecords(true);
        List<FObjectOne__c> records1 = (List<FObjectOne__c>) FObject.getInsertedRecords('FObjectTwo__c');

        FObject obj2 = new FObject(FObjectOne__c.SObjectType, size2)
            .setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) source(forceea)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj2.insertRecords(true);
        List<FObjectOne__c> records2 = (List<FObjectOne__c>) FObject.getInsertedRecords('FObjectOne__c');

        FObject obj3 = new FObject(FObjectOne__c.SObjectType, size3)
            .setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) source(forceea)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
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
        System.assertEquals(0, errors, 'getInsertedRecords - errors found');
    }

    @IsTest
    private static void getInsertedGroupRecordsStatic_valid_expectSuccess() {
        Integer size1 = 5;
        Integer size2 = 10;
        Integer size3 = 20;

        Test.startTest();
        FObject obj1 = new FObject(FObjectOne__c.SObjectType, size1)
            .setDefinition(FObjectOne__c.TestText__c, 'random type(list) value(v1,v2)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj1.insertRecords(true, 'GroupA');

        obj1.removeDefinitions(FObjectOne__c.TestText__c)
            .setNumberOfRecords(size2)
            .setDefinition(FObjectOne__c.TestText__c, 'random type(list) value(v3,v4)');
        obj1.insertRecords(true, 'GroupB');

        FObject obj2 = new FObject(FObjectOne__c.SObjectType, size3)
            .setDefinition(FObjectOne__c.TestText__c, 'random type(list) value(v1,v2)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj2.insertRecords(true);
        Test.stopTest();

        List<FObjectOne__c> recordsA1 = (List<FObjectOne__c>) obj1.getInsertedGroupRecords('GROUPA');
        List<FObjectOne__c> recordsA2 =
            (List<FObjectOne__c>) FObject.getInsertedGroupRecords(FObjectOne__c.SObjectType, 'GROUPA');

        List<FObjectOne__c> recordsB1 = (List<FObjectOne__c>) obj1.getInsertedGroupRecords('GROUPB');
        List<FObjectOne__c> recordsB2 =
            (List<FObjectOne__c>) FObject.getInsertedGroupRecords(FObjectOne__c.SObjectType, 'GROUPB');

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
        System.assertEquals(0, errors, 'getInsertedGroupRecords - errors found');
    }

    @IsTest
    private static void getInsertedGroupRecordsStatic_invalidObject_expectFailure() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType)
            .setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) source(forceea)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj.insertRecords(true, 'One');
        Test.stopTest();

        List<FObjectTwo__c> lookupRecords = (List<FObjectTwo__c>) FObject.getInsertedGroupRecords('FObjectTwoX__c', 'One');
        Boolean expectedResult = false;
        Boolean actualResult = FObject.processIsValid();
        System.assertEquals(expectedResult, actualResult, 'getInsertedGroupRecords - errors found');
    }

    @IsTest
    private static void insertRecords_controllingPicklistBeforeDependent_expectSuccess() {
        Test.startTest();
        new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestPicklistA__c, 'random type(picklist)')
            .setDefinition(FObjectOne__c.TestPicklistB__c, 'random type(picklist)')
            .createRecords();
        Test.stopTest();

        String logValue = 'Moved definition of controlling field [TestPicklistA__c] before definition ' +
            'of its dependent field [TestPicklistB__c].';
        Integer errors = 0;
        if (FObject.getGlobalDebugLogs().contains(logValue)) {
            errors++;
        }
        System.assertEquals(0, errors, 'insertRecords - errors found');
    }

    @IsTest
    private static void insertRecords_controllingPicklistAfterDependent_expectSuccess() {
        FObject.setGlobalVerbose('debug'); // DO NOT REMOVE

        Test.startTest();
        new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestPicklistB__c, 'random type(picklist)')
            .setDefinition(FObjectOne__c.TestPicklistA__c, 'random type(picklist)')
            .createRecords();
        Test.stopTest();

        String logValue = 'Moved definition of controlling field [TestPicklistA__c] before definition ' +
            'of its dependent field [TestPicklistB__c].';
        Integer errors = 0;
        if (!FObject.getGlobalDebugLogs().contains(logValue)) {
            errors++;
        }
        System.assertEquals(0, errors, 'insertRecords - errors found');
    }

    @IsTest
    private static void insertRecords_dependentPicklistWithoutControlling_expectSuccess() {
        FObject.setGlobalVerbose('debug'); // DO NOT REMOVE

        Test.startTest();
        new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestPicklistB__c, 'random type(picklist)')
            .createRecords();
        Test.stopTest();

        String logValue1 = 'Did not find a definition ' +
            'for the controlling field [TestPicklistA__c] of dependent field [TestPicklistB__c] ' +
            'and will generate a definition.';
        String logValue2 = 'Moved definition of controlling field [TestPicklistA__c] before definition ' +
            'of its dependent field [TestPicklistB__c].';
        Integer errors = 0;
        if (!FObject.getGlobalDebugLogs().contains(logValue1) || !FObject.getGlobalDebugLogs().contains(logValue2)) {
            errors++;
        }
        System.assertEquals(0, errors, 'insertRecords - errors found');
    }

    @IsTest
    private static void insertRecords_allOrNoneTrue_expectFailure() {
        Boolean hasErrors = false;

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType)
            .setRequiredFields(false)
            .setDefinition(FObjectOne__c.TestPicklistC__c, 'static value(a1)');
        try {
            obj.insertRecords(true);
        } catch (DmlException ex) {
            hasErrors = true;
        }
        Test.stopTest();

        Integer errors = 0;
        if (!hasErrors) {
            errors++;
        }
        System.assertEquals(0, errors, 'insertRecords - errors found');
    }

    @IsTest
    private static void insertRecords_allOrNoneFalse_expectFailure() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestPicklistC__c, 'static value(a1)');
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
        FObject obj = new FObject(Attachment.SObjectType, 10)
            .setDefinition(Attachment.Name, 'static value(Attachment-)')
            .setDefinition(Attachment.Name, 'serial type(number) from(1) step(1) scale(0)')
            .setDefinition(Attachment.Body, 'random type(number) from(1) to(100) scale(2)');
        Test.stopTest();

        Decimal value = 0;
        Integer errors = 0;
        for (Attachment objRecord : (List<Attachment>) obj.getRecords()) {
            value = Decimal.valueOf(objRecord.Body.toString());
            if (value < 1 || value > 100) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'insertRecords - errors found');
    }

    @IsTest
    private static void insertRecords_negativeRecords_expectFailure() {
        FObject.setExceptionHandling('continue');

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, -1);
        obj.insertRecords(true);
        Test.stopTest();

        String expectedResult = 'Invalid number of records of [FObjectOne__c]';
        String actualResult = obj.getErrors().get('FObjectOne__c').get(0);
        System.assertEquals(expectedResult, actualResult, 'insertRecords - errors found');
    }

    @IsTest
    private static void insertRecords_noDefinitions_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        List<Database.SaveResult> saveResults = obj.insertRecords(false);
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
    private static void insertRecords_missingRequiredFields_expectFailure() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
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

    @IsTest
    private static void insertRecordsFromTemplate_noErrorsAllOrNoneTrue_expectSuccess() {
        Map<String, FObject> template = new Map<String, FObject>(template1());
        Integer numRecordsA1 = template.get('Ones').getNumberOfRecords();
        Integer numRecordsA2 = template.get('Twos').getNumberOfRecords();
        Integer numRecordsA3 = template.get('Threes').getNumberOfRecords();
        Integer numRecordsB = template.get('FObjectTwos').getNumberOfRecords();

        Test.startTest();
        FObject.insertRecordsFromTemplate(template, true);
        Integer dmlStatements = Limits.getDmlStatements();
        Test.stopTest();

        Integer errors = 0;
        if (FObject.getInsertedRecords(FObjectOne__c.SObjectType).size() != (numRecordsA1 + numRecordsA2 + numRecordsA3)) {
            errors += 1;
        }
        if (FObject.getInsertedGroupRecords(FObjectOne__c.SObjectType, 'Group2').size() != numRecordsA2) {
            errors += 2;
        }
        if (FObject.getInsertedRecords(FObjectTwo__c.SObjectType).size() != numRecordsB) {
            errors += 4;
        }
        if (dmlStatements != 4) {
            errors += 8;
        }
        System.assertEquals(0, errors, 'insertRecordsFromTemplate - errors found');
    }

    @IsTest
    private static void insertRecordsFromTemplate_noErrorsAllOrNoneFalse_expectSuccess() {
        Map<String, FObject> template = new Map<String, FObject>(template1());
        Integer numRecordsA1 = template.get('Ones').getNumberOfRecords();
        Integer numRecordsA2 = template.get('Twos').getNumberOfRecords();
        Integer numRecordsA3 = template.get('Threes').getNumberOfRecords();
        Integer numRecordsB = template.get('FObjectTwos').getNumberOfRecords();

        Test.startTest();
        FObject.setDmlOptimizer(false);
        Map<String, List<Database.SaveResult>> saveResults = FObject.insertRecordsFromTemplate(template, false);
        Integer dmlStatements = Limits.getDmlStatements();
        Test.stopTest();

        Integer errors = 0;
        if (FObject.getInsertedRecords(FObjectOne__c.SObjectType).size() != (numRecordsA1 + numRecordsA2 + numRecordsA3)) {
            errors += 1;
        }
        if (FObject.getInsertedGroupRecords(FObjectOne__c.SObjectType, 'Group2').size() != numRecordsA2) {
            errors += 2;
        }
        if (FObject.getInsertedRecords(FObjectTwo__c.SObjectType).size() != numRecordsB) {
            errors += 4;
        }
        if (dmlStatements != 4) {
            errors += 8;
        }
        for (Database.SaveResult sr : saveResults.get('Ones')) {
            if (!sr.isSuccess()) {
                errors += 16;
                break;
            }
        }
        for (Database.SaveResult sr : saveResults.get('FObjectTwos')) {
            if (!sr.isSuccess()) {
                errors += 32;
                break;
            }
        }
        System.assertEquals(0, errors, 'insertRecordsFromTemplate - errors found');
    }

    @IsTest
    private static void insertRecordsFromTemplate_errorsAllOrNoneTrue_expectFailure() {
        Map<String, FObject> template = new Map<String, FObject>(template1());
        template.get('Ones')
            .setDefinition(FObjectOne__c.TestIntegerUnique__c, 'static value(1)');
        Integer numRecordsB = template.get('FObjectTwos').getNumberOfRecords();

        Test.startTest();
        String errorMessage = '';
        try {
            FObject.insertRecordsFromTemplate(template, true);
        } catch (Exception ex) {
            errorMessage = ex.getMessage();
        }
        Integer dmlStatements = Limits.getDmlStatements();
        Test.stopTest();

        Integer errors = 0;
        if (String.isBlank(errorMessage)) {
            errors += 1;
        }
        if (FObject.getInsertedRecords(FObjectOne__c.SObjectType).size() != 0) {
            errors += 2;
        }
        if (FObject.getInsertedRecords(FObjectTwo__c.SObjectType).size() != numRecordsB) {
            errors += 4;
        }
        if (dmlStatements != 2) {
            errors += 8;
        }
        System.assertEquals(0, errors, 'insertRecordsFromTemplate - errors found');
    }

    @IsTest
    private static void insertRecordsFromTemplate_errorsAllOrNoneFalse_expectFailure() {
        Map<String, FObject> template = new Map<String, FObject>(template1());
        Integer numRecordsA2 = template.get('Twos').getNumberOfRecords();
        Integer numRecordsA3 = template.get('Threes').getNumberOfRecords();
        Integer numRecordsB = template.get('FObjectTwos').getNumberOfRecords();
        template.get('Ones')
            .setDefinition(FObjectOne__c.TestIntegerUnique__c, 'static value(1)');

        Test.startTest();
        Map<String, List<Database.SaveResult>> saveResults = FObject.insertRecordsFromTemplate(template, false);
        Integer dmlStatements = Limits.getDmlStatements();
        Test.stopTest();

        Integer errors = 0;
        if (FObject.getInsertedRecords(FObjectOne__c.SObjectType).size() != 1 + numRecordsA2 + numRecordsA3) {
            errors += 1;
        }
        if (FObject.getInsertedRecords(FObjectTwo__c.SObjectType).size() != numRecordsB) {
            errors += 2;
        }
        if (dmlStatements != 4) {
            errors += 4;
        }
        if (!saveResults.get('Ones').get(0).isSuccess() || saveResults.get('Ones').get(1).isSuccess()) {
            errors += 8;
        }
        for (Database.SaveResult sr : saveResults.get('FObjectTwos')) {
            if (!sr.isSuccess()) {
                errors += 16;
                break;
            }
        }
        System.assertEquals(0, errors, 'insertRecordsFromTemplate - errors found');
    }

    @IsTest
    private static void insertRecordsFromTemplate_emptyTemplate_expectSuccess() {
        Map<String, FObject> template = new Map<String, FObject>();

        Test.startTest();
        Map<String, List<Database.SaveResult>> results = FObject.insertRecordsFromTemplate(template, false);
        Test.stopTest();

        System.assert(results.isEmpty(), 'insertRecordsFromTemplate - errors found');
    }

    @IsTest
    private static void insertRecordsFromTemplate_nullAllOrNone_expectSuccess() {
        Map<String, FObject> template = new Map<String, FObject>(template1());

        Test.startTest();
        Map<String, List<Database.SaveResult>> results = FObject.insertRecordsFromTemplate(template, null);
        Test.stopTest();

        System.assert(results.isEmpty(), 'insertRecordsFromTemplate - errors found');
    }

    @IsTest
    private static void insertRecordsFromTemplateOptimised_noErrorsAllOrNoneTrue_expectSuccess() {
        Map<String, FObject> template = new Map<String, FObject>(template1());
        Integer numRecordsA1 = template.get('Ones').getNumberOfRecords();
        Integer numRecordsA2 = template.get('Twos').getNumberOfRecords();
        Integer numRecordsA3 = template.get('Threes').getNumberOfRecords();
        Integer numRecordsB = template.get('FObjectTwos').getNumberOfRecords();

        Test.startTest();
        FObject.setDmlOptimizer(true);
        FObject.insertRecordsFromTemplate(template, true);
        Integer dmlStatements = Limits.getDmlStatements();
        Test.stopTest();

        Integer errors = 0;
        if (FObject.getInsertedRecords(FObjectOne__c.SObjectType).size() != (numRecordsA1 + numRecordsA2 + numRecordsA3)) {
            errors += 1;
        }
        if (FObject.getInsertedGroupRecords(FObjectOne__c.SObjectType, 'Group2').size() != numRecordsA2) {
            errors += 2;
        }
        if (FObject.getInsertedRecords(FObjectTwo__c.SObjectType).size() != numRecordsB) {
            errors += 4;
        }
        if (dmlStatements != 2) {
            errors += 8;
        }
        System.assertEquals(0, errors, 'insertRecordsFromTemplate - errors found');
    }

    @IsTest
    private static void insertRecordsFromTemplateOptimised_noErrorsAllOrNoneFalse_expectSuccess() {
        Map<String, FObject> template = new Map<String, FObject>(template1());
        Integer numRecordsA1 = template.get('Ones').getNumberOfRecords();
        Integer numRecordsA2 = template.get('Twos').getNumberOfRecords();
        Integer numRecordsA3 = template.get('Threes').getNumberOfRecords();
        Integer numRecordsB = template.get('FObjectTwos').getNumberOfRecords();

        Test.startTest();
        FObject.setDmlOptimizer(true);
        Map<String, List<Database.SaveResult>> saveResults = FObject.insertRecordsFromTemplate(template, false);
        Integer dmlStatements = Limits.getDmlStatements();
        Test.stopTest();

        Integer errors = 0;
        if (FObject.getInsertedRecords(FObjectOne__c.SObjectType).size() != (numRecordsA1 + numRecordsA2 + numRecordsA3)) {
            errors += 1;
        }
        if (FObject.getInsertedGroupRecords(FObjectOne__c.SObjectType, 'Group2').size() != numRecordsA2) {
            errors += 2;
        }
        if (FObject.getInsertedRecords(FObjectTwo__c.SObjectType).size() != numRecordsB) {
            errors += 4;
        }
        if (dmlStatements != 2) {
            errors += 8;
        }
        if (!saveResults.containsKey('Ones') || !saveResults.containsKey('Twos') || !saveResults.containsKey('Threes')) {
            errors += 16;
        }
        for (Database.SaveResult sr : saveResults.get('Ones')) {
            if (!sr.isSuccess()) {
                errors += 32;
                break;
            }
        }
        for (Database.SaveResult sr : saveResults.get('Twos')) {
            if (!sr.isSuccess()) {
                errors += 64;
                break;
            }
        }
        System.assertEquals(0, errors, 'insertRecordsFromTemplate - errors found');
    }

    @IsTest
    private static void insertRecordsFromTemplateOptimised_errorsAllOrNoneTrue_expectFailure() {
        Map<String, FObject> template = new Map<String, FObject>(template1());
        template.get('Ones')
            .setDefinition(FObjectOne__c.TestIntegerUnique__c, 'static value(1)');
        Integer numRecordsB = template.get('FObjectTwos').getNumberOfRecords();

        Test.startTest();
        String errorMessage = '';
        try {
            FObject.setDmlOptimizer(true);
            FObject.insertRecordsFromTemplate(template, true);
        } catch (Exception ex) {
            errorMessage = ex.getMessage();
        }
        Integer dmlStatements = Limits.getDmlStatements();
        Test.stopTest();

        Integer errors = 0;
        if (String.isBlank(errorMessage)) {
            errors += 1;
        }
        if (FObject.getInsertedRecords(FObjectOne__c.SObjectType).size() != 0) {
            errors += 2;
        }
        if (FObject.getInsertedRecords(FObjectTwo__c.SObjectType).size() != numRecordsB) {
            errors += 4;
        }
        if (dmlStatements != 2) {
            errors += 8;
        }
        System.assertEquals(0, errors, 'insertRecordsFromTemplate - errors found');
    }

    @IsTest
    private static void insertRecordsFromTemplateOptimised_errorsAllOrNoneFalse_expectFailure() {
        Map<String, FObject> template = new Map<String, FObject>(template1());
        Integer numRecordsA1 = template.get('Ones').getNumberOfRecords();
        Integer numRecordsA2 = template.get('Twos').getNumberOfRecords();
        Integer numRecordsA3 = template.get('Threes').getNumberOfRecords();
        Integer numRecordsB = template.get('FObjectTwos').getNumberOfRecords();
        template.get('Ones')
            .setDefinition(FObjectOne__c.TestIntegerUnique__c, 'static value(1)');

        Test.startTest();
        FObject.setDmlOptimizer(true);
        Map<String, List<Database.SaveResult>> saveResults = FObject.insertRecordsFromTemplate(template, false);
        Integer dmlStatements = Limits.getDmlStatements();
        Test.stopTest();

        Integer errors = 0;
        if (FObject.getInsertedRecords(FObjectOne__c.SObjectType).size() != numRecordsA1 + numRecordsA2 + numRecordsA3 - 1) {
            errors += 1;
        }
        if (FObject.getInsertedRecords(FObjectTwo__c.SObjectType).size() != numRecordsB) {
            errors += 2;
        }
        if (dmlStatements != 2) {
            errors += 4;
        }
        if (!saveResults.containsKey('Ones') || !saveResults.containsKey('Twos') || !saveResults.containsKey('Threes') ||
            saveResults.get('Ones').get(1).isSuccess()) {
            errors += 8;
        }
        for (Database.SaveResult sr : saveResults.get('FObjectTwos')) {
            if (!sr.isSuccess()) {
                errors += 16;
                break;
            }
        }
        System.assertEquals(0, errors, 'insertRecordsFromTemplate - errors found');
    }

    @IsTest
    private static void insertRecordsFromTemplateOptimized_selfLookup_expectSuccess() {
        Map<String, FObject> template = new Map<String, FObject>();
        template.putAll(template1());
        template.putAll(template3());

        Integer numRecordsA1 = template.get('Ones').getNumberOfRecords();
        Integer numRecordsA2 = template.get('Twos').getNumberOfRecords();
        Integer numRecordsA3 = template.get('Threes').getNumberOfRecords();
        Integer numRecordsB = template.get('FObjectTwos').getNumberOfRecords();
        Integer numRecordsC1 = template.get('FoursA').getNumberOfRecords();
        Integer numRecordsC2 = template.get('FoursB').getNumberOfRecords();

        Test.startTest();
        FObject.setDmlOptimizer(true);
        Map<String, List<Database.SaveResult>> saveResults = FObject.insertRecordsFromTemplate(template, true);
        Integer dmlStatements = Limits.getDmlStatements();
        Test.stopTest();

        Integer errors = 0;
        if (template.get('FObjectTwos').getInsertedRecords().size() != numRecordsB ||
            template.get('Ones').getInsertedRecords().size() != numRecordsA1 ||
            template.get('Twos').getInsertedRecords().size() != numRecordsA2 ||
            template.get('Threes').getInsertedRecords().size() != numRecordsA3) {
            errors += 1;
        }
        if (template.get('FoursA').getInsertedRecords().size() != numRecordsC1 ||
            template.get('FoursB').getInsertedRecords().size() != numRecordsC2) {
            errors += 2;
        }
        if (dmlStatements != 4) {
            errors += 4;
        }
        if (!saveResults.containsKey('Ones') || !saveResults.containsKey('Twos') || !saveResults.containsKey('Threes') ||
            !saveResults.containsKey('FObjectTwos') ||
            !saveResults.containsKey('FoursA') || !saveResults.containsKey('FoursB')) {
            errors += 8;
        }
        System.assertEquals(0, errors, 'insertRecordsFromTemplate - errors found');
    }

    @IsTest
    private static void insertRecordsFromTemplateOptimized_globalMocking_expectSuccess() {
        FObject.setGlobalMocking(true);

        Map<String, FObject> template = new Map<String, FObject>();
        template.putAll(template1());
        template.putAll(template3());

        Integer numRecordsA1 = template.get('Ones').getNumberOfRecords();
        Integer numRecordsA2 = template.get('Twos').getNumberOfRecords();
        Integer numRecordsA3 = template.get('Threes').getNumberOfRecords();
        Integer numRecordsB = template.get('FObjectTwos').getNumberOfRecords();
        Integer numRecordsC1 = template.get('FoursA').getNumberOfRecords();
        Integer numRecordsC2 = template.get('FoursB').getNumberOfRecords();

        Test.startTest();
        FObject.setDmlOptimizer(true);
        Map<String, List<Database.SaveResult>> saveResults = FObject.insertRecordsFromTemplate(template, true);
        Integer dmlStatements = Limits.getDmlStatements();
        Test.stopTest();

        Integer errors = 0;
        if (template.get('FObjectTwos').getInsertedRecords().size() != numRecordsB ||
            template.get('Ones').getInsertedRecords().size() != numRecordsA1 ||
            template.get('Twos').getInsertedRecords().size() != numRecordsA2 ||
            template.get('Threes').getInsertedRecords().size() != numRecordsA3) {
            errors += 1;
        }
        if (template.get('FoursA').getInsertedRecords().size() != numRecordsC1 ||
            template.get('FoursB').getInsertedRecords().size() != numRecordsC2) {
            errors += 2;
        }
        if (dmlStatements != 0) {
            errors += 4;
        }
        if (!saveResults.containsKey('Ones') || !saveResults.containsKey('Twos') || !saveResults.containsKey('Threes') ||
            !saveResults.containsKey('FObjectTwos') ||
            !saveResults.containsKey('FoursA') || !saveResults.containsKey('FoursB')) {
            errors += 8;
        }
        System.assertEquals(0, errors, 'insertRecordsFromTemplate - errors found');
    }

    @IsTest
    private static void insertRecordsFromTemplateOptimized_idMocking_expectSuccess() {
        Map<String, FObject> template = new Map<String, FObject>();
        template.putAll(template1());
        template.putAll(template3());
        template.get('Twos')
            .setDefinition(FObjectOne__c.Id, 'mock type(id)');

        Integer numRecordsA1 = template.get('Ones').getNumberOfRecords();
        Integer numRecordsA2 = template.get('Twos').getNumberOfRecords();
        Integer numRecordsA3 = template.get('Threes').getNumberOfRecords();
        Integer numRecordsB = template.get('FObjectTwos').getNumberOfRecords();
        Integer numRecordsC1 = template.get('FoursA').getNumberOfRecords();
        Integer numRecordsC2 = template.get('FoursB').getNumberOfRecords();

        Test.startTest();
        FObject.setDmlOptimizer(true);
        Map<String, List<Database.SaveResult>> saveResults = FObject.insertRecordsFromTemplate(template, true);
        Integer dmlStatements = Limits.getDmlStatements();
        Test.stopTest();

        Integer errors = 0;
        if (template.get('FObjectTwos').getInsertedRecords().size() != numRecordsB ||
            template.get('Ones').getInsertedRecords().size() != numRecordsA1 ||
            template.get('Twos').getInsertedRecords().size() != numRecordsA2 ||
            template.get('Threes').getInsertedRecords().size() != numRecordsA3) {
            errors += 1;
        }
        if (template.get('FoursA').getInsertedRecords().size() != numRecordsC1 ||
            template.get('FoursB').getInsertedRecords().size() != numRecordsC2) {
            errors += 2;
        }
        if (dmlStatements != 4) {
            errors += 4;
        }
        if (!saveResults.containsKey('Ones') || !saveResults.containsKey('Twos') || !saveResults.containsKey('Threes') ||
            !saveResults.containsKey('FObjectTwos') ||
            !saveResults.containsKey('FoursA') || !saveResults.containsKey('FoursB')) {
            errors += 8;
        }
        System.assertEquals(0, errors, 'insertRecordsFromTemplate - errors found');
    }

    @IsTest
    private static void insertRecordsFromTemplateOptimisedInstance_noErrorsAllOrNoneTrue_expectSuccess() {
        Map<String, FObject> template = new Map<String, FObject>();
        template.putAll(template1());
        template.putAll(template2());

        FObject objA1 = template.get('Ones');
        FObject objA2 = template.get('Twos');
        FObject objA3 = template.get('Threes');
        FObject objA4 = template.get('FObjectTwos');
        FObject objB1 = template.get('B1');
        FObject objB2 = template.get('B2');
        FObject objB3 = template.get('B3');
        FObject objB4 = template.get('B4');

        Integer numRecordsA1 = objA1.getNumberOfRecords();
        Integer numRecordsA2 = objA2.getNumberOfRecords();
        Integer numRecordsA3 = objA3.getNumberOfRecords();
        Integer numRecordsA4 = objA4.getNumberOfRecords();
        Integer numRecordsB1 = objB1.getNumberOfRecords();
        Integer numRecordsB2 = objB2.getNumberOfRecords();
        Integer numRecordsB3 = objB3.getNumberOfRecords();
        Integer numRecordsB4 = objB4.getNumberOfRecords();

        Test.startTest();
        FObject.setDmlOptimizer(true);
        FObject.insertRecordsFromTemplate(template, true);
        Integer dmlStatements = Limits.getDmlStatements();
        Test.stopTest();

        Integer errors = 0;
        if (objA1.getInsertedRecords().size() != numRecordsA1 ||
            objA2.getInsertedRecords().size() != numRecordsA2 ||
            objA3.getInsertedRecords().size() != numRecordsA3 ||
            objA4.getInsertedRecords().size() != numRecordsA4) {
            errors += 1;
        }
        if (objA1.getInsertedGroupRecords('').size() != numRecordsA1 ||
            objA2.getInsertedGroupRecords('group2').size() != numRecordsA2 ||
            objA3.getInsertedGroupRecords('').size() != numRecordsA3 ||
            objA4.getInsertedGroupRecords('').size() != numRecordsA4) {
            errors += 2;
        }
        if (objB1.getInsertedRecords().size() != numRecordsB1 ||
            objB2.getInsertedRecords().size() != numRecordsB2 ||
            objB3.getInsertedRecords().size() != numRecordsB3 ||
            objB4.getInsertedRecords().size() != numRecordsB4) {
            errors += 4;
        }
        if (objB1.getInsertedGroupRecords('').size() != numRecordsB1 ||
            objB2.getInsertedGroupRecords('group2').size() != numRecordsB2 ||
            objB3.getInsertedGroupRecords('').size() != numRecordsB3 ||
            objB4.getInsertedGroupRecords('').size() != numRecordsB4) {
            errors += 8;
        }
        if (dmlStatements != 2) {
            errors += 16;
        }
        System.assertEquals(0, errors, 'insertRecordsFromTemplate - errors found');
    }

    @IsTest
    private static void insertRecordsFromTemplateOptimisedInstance_errorsAllOrNoneFalse_expectSuccess() {
        Map<String, FObject> template = new Map<String, FObject>();
        template.putAll(template1());
        template.putAll(template2());

        FObject objA1 = template.get('Ones');
        FObject objA2 = template.get('Twos');
        FObject objA3 = template.get('Threes');
        FObject objA4 = template.get('FObjectTwos');
        FObject objB1 = template.get('B1');
        FObject objB2 = template.get('B2');
        FObject objB3 = template.get('B3');
        FObject objB4 = template.get('B4');

        Integer numRecordsA2 = objA2.getNumberOfRecords();
        Integer numRecordsA3 = objA3.getNumberOfRecords();
        Integer numRecordsA4 = objA4.getNumberOfRecords();
        Integer numRecordsB1 = objB1.getNumberOfRecords();
        Integer numRecordsB2 = objB2.getNumberOfRecords();
        Integer numRecordsB3 = objB3.getNumberOfRecords();
        Integer numRecordsB4 = objB4.getNumberOfRecords();

        template.get('Ones')
            .setDefinition(FObjectOne__c.TestIntegerUnique__c, 'static value(1)');

        Test.startTest();
        FObject.setDmlOptimizer(true);
        Map<String, List<Database.SaveResult>> saveResults = FObject.insertRecordsFromTemplate(template, false);
        Integer dmlStatements = Limits.getDmlStatements();
        Test.stopTest();

        Integer errors = 0;
        if (objA1.getInsertedRecords().size() != 1 ||
            objA2.getInsertedRecords().size() != numRecordsA2 ||
            objA3.getInsertedRecords().size() != numRecordsA3 ||
            objA4.getInsertedRecords().size() != numRecordsA4) {
            errors += 1;
        }
        if (objA1.getInsertedGroupRecords('').size() != 1 ||
            objA2.getInsertedGroupRecords('group2').size() != numRecordsA2 ||
            objA3.getInsertedGroupRecords('').size() != numRecordsA3 ||
            objA4.getInsertedGroupRecords('').size() != numRecordsA4) {
            errors += 2;
        }
        if (objB1.getInsertedRecords().size() != numRecordsB1 ||
            objB2.getInsertedRecords().size() != numRecordsB2 ||
            objB3.getInsertedRecords().size() != numRecordsB3 ||
            objB4.getInsertedRecords().size() != numRecordsB4) {
            errors += 4;
        }
        if (objB1.getInsertedGroupRecords('').size() != numRecordsB1 ||
            objB2.getInsertedGroupRecords('group2').size() != numRecordsB2 ||
            objB3.getInsertedGroupRecords('').size() != numRecordsB3 ||
            objB4.getInsertedGroupRecords('').size() != numRecordsB4) {
            errors += 8;
        }
        if (dmlStatements != 2) {
            errors += 16;
        }
        if (!saveResults.containsKey('Ones') || !saveResults.containsKey('Twos') || !saveResults.containsKey('Threes')) {
            errors += 32;
        }
        if (!saveResults.get('Ones').get(0).isSuccess()) {
            errors += 64;
        }
        if (!saveResults.get('Twos').get(0).isSuccess() || !saveResults.get('Twos').get(1).isSuccess()) {
            errors += 128;
        }
        if (!saveResults.get('Threes').get(3).isSuccess()) {
            errors += 256;
        }
        System.assertEquals(0, errors, 'insertRecordsFromTemplate - errors found');
    }

    @IsTest
    private static void insertRecordsFromTemplateWithKeys_removedKeys_expectSuccess() {
        Map<String, FObject> template = new Map<String, FObject>(template1());
        List<String> keys = new List<String>{
            'Ones', 'Twos'
        };

        Test.startTest();
        FObject.insertRecordsFromTemplateWithKeys(template, true, keys);
        Test.stopTest();

        Integer errors = 0;
        if (template.containsKey('Ones') || template.containsKey('Twos')) {
            errors += 1;
        }
        if (!template.containsKey('Threes') || !template.containsKey('FObjectTwos')) {
            errors += 2;
        }
        System.assertEquals(0, errors, 'insertRecordsFromTemplate - errors found');
    }

    @IsTest
    private static void insertRecordsFromTemplateWithKeys_noErrorsAllOrNoneTrue_expectSuccess() {
        Map<String, FObject> template = new Map<String, FObject>(template1());
        Integer numRecordsA1 = template.get('Ones').getNumberOfRecords();
        Integer numRecordsA2 = template.get('Twos').getNumberOfRecords();
        Integer numRecordsA3 = template.get('Threes').getNumberOfRecords();
        List<String> keys = new List<String>{
            'Ones', 'Twos', 'Threes'
        };

        Test.startTest();
        FObject.setDmlOptimizer(false);
        FObject.insertRecordsFromTemplateWithKeys(template, true, keys);
        Integer dmlStatements = Limits.getDmlStatements();
        Test.stopTest();

        Integer errors = 0;
        if (FObject.getInsertedRecords(FObjectOne__c.SObjectType).size() != (numRecordsA1 + numRecordsA2 + numRecordsA3)) {
            errors += 1;
        }
        if (FObject.getInsertedGroupRecords(FObjectOne__c.SObjectType, 'Group2').size() != numRecordsA2) {
            errors += 2;
        }
        if (!FObject.getInsertedRecords(FObjectTwo__c.SObjectType).isEmpty()) {
            errors += 4;
        }
        if (dmlStatements != 3) {
            errors += 8;
        }
        if (!templateHasAllKeysExcludingKeys(template, keys)) {
            errors += 16;
        }
        System.assertEquals(0, errors, 'insertRecordsFromTemplate - errors found');
    }

    @IsTest
    private static void insertRecordsFromTemplateWithKeys_noErrorsAllOrNoneFalse_expectSuccess() {
        Map<String, FObject> template = new Map<String, FObject>(template1());
        Integer numRecordsA1 = template.get('Ones').getNumberOfRecords();
        Integer numRecordsA2 = template.get('Twos').getNumberOfRecords();
        Integer numRecordsA3 = template.get('Threes').getNumberOfRecords();
        List<String> keys = new List<String>{
            'Ones', 'Twos', 'Threes'
        };

        Test.startTest();
        FObject.setDmlOptimizer(false);
        FObject.insertRecordsFromTemplateWithKeys(template, true, keys);
        Integer dmlStatements = Limits.getDmlStatements();
        Test.stopTest();

        Integer errors = 0;
        if (FObject.getInsertedRecords(FObjectOne__c.SObjectType).size() != (numRecordsA1 + numRecordsA2 + numRecordsA3)) {
            errors += 1;
        }
        if (FObject.getInsertedGroupRecords(FObjectOne__c.SObjectType, 'Group2').size() != numRecordsA2) {
            errors += 2;
        }
        if (!FObject.getInsertedRecords(FObjectTwo__c.SObjectType).isEmpty()) {
            errors += 4;
        }
        if (dmlStatements != 3) {
            errors += 8;
        }
        if (!templateHasAllKeysExcludingKeys(template, keys)) {
            errors += 16;
        }
        System.assertEquals(0, errors, 'insertRecordsFromTemplate - errors found');
    }

    @IsTest
    private static void insertRecordsFromTemplateWithKeys_errorsAllOrNoneTrue_expectFailure() {
        Map<String, FObject> template = new Map<String, FObject>(template1());
        Integer numRecordsA1 = template.get('Ones').getNumberOfRecords();
        template.get('Twos')
            .setDefinition(FObjectOne__c.TestIntegerUnique__c, 'static value(1)');
        List<String> keys = new List<String>{
            'Ones', 'Twos', 'Threes'
        };

        Test.startTest();
        String errorMessage = '';
        try {
            FObject.insertRecordsFromTemplateWithKeys(template, true, keys);
        } catch (Exception ex) {
            errorMessage = ex.getMessage();
        }
        Integer dmlStatements = Limits.getDmlStatements();
        Test.stopTest();

        Integer errors = 0;
        if (String.isBlank(errorMessage)) {
            errors += 1;
        }
        if (FObject.getInsertedRecords(FObjectOne__c.SObjectType).size() != numRecordsA1) {
            errors += 2;
        }
        if (FObject.getInsertedRecords(FObjectTwo__c.SObjectType).size() != 0) {
            errors += 4;
        }
        if (dmlStatements != 2) {
            errors += 8;
        }
        if (!templateHasAllKeysExcludingKeys(template, keys)) {
            errors += 16;
        }
        System.assertEquals(0, errors, 'insertRecordsFromTemplate - errors found');
    }

    @IsTest
    private static void insertRecordsFromTemplateWithKeys_errorsAllOrNoneFalse_expectSuccess() {
        Map<String, FObject> template = new Map<String, FObject>(template1());
        Integer numRecordsA2 = template.get('Twos').getNumberOfRecords();
        Integer numRecordsA3 = template.get('Threes').getNumberOfRecords();
        template.get('Ones')
            .setDefinition(FObjectOne__c.TestIntegerUnique__c, 'static value(1)');
        List<String> keys = new List<String>{
            'Ones', 'Twos', 'Threes'
        };

        Test.startTest();
        Map<String, List<Database.SaveResult>> saveResults =
            FObject.insertRecordsFromTemplateWithKeys(template, false, keys);
        Integer dmlStatements = Limits.getDmlStatements();
        Test.stopTest();

        Integer errors = 0;
        if (FObject.getInsertedRecords(FObjectOne__c.SObjectType).size() != 1 + numRecordsA2 + numRecordsA3) {
            errors += 1;
        }
        if (FObject.getInsertedRecords(FObjectTwo__c.SObjectType).size() != 0) {
            errors += 2;
        }
        if (dmlStatements != 3) {
            errors += 4;
        }
        if (!saveResults.get('Ones').get(0).isSuccess() || saveResults.get('Ones').get(1).isSuccess()) {
            errors += 8;
        }
        if (!saveResults.get('Twos').get(0).isSuccess() || !saveResults.get('Twos').get(2).isSuccess()) {
            errors += 16;
        }
        if (!templateHasAllKeysExcludingKeys(template, keys)) {
            errors += 32;
        }
        System.assertEquals(0, errors, 'insertRecordsFromTemplate - errors found');
    }

    @IsTest
    private static void insertRecordsFromTemplateWithKeys_emptyTemplate_expectSuccess() {
        Map<String, FObject> template = new Map<String, FObject>();
        List<String> keys = new List<String>{
            'Ones', 'Twos', 'Threes'
        };

        Test.startTest();
        Map<String, List<Database.SaveResult>> saveResults =
            FObject.insertRecordsFromTemplateWithKeys(template, true, keys);
        Test.stopTest();

        System.assert(saveResults.isEmpty(), 'insertRecordsFromTemplate - errors found');
    }

    @IsTest
    private static void insertRecordsFromTemplateWithKeys_nullKeys_expectSuccess() {
        Map<String, FObject> template = new Map<String, FObject>(template1());

        Test.startTest();
        Map<String, List<Database.SaveResult>> saveResults =
            FObject.insertRecordsFromTemplateWithKeys(template, true, null);
        Test.stopTest();

        System.assert(saveResults.isEmpty(), 'insertRecordsFromTemplate - errors found');
    }

    @IsTest
    private static void insertRecordsFromTemplateWithKeys_emptyKeys_expectSuccess() {
        Map<String, FObject> template = new Map<String, FObject>(template1());

        Test.startTest();
        Map<String, List<Database.SaveResult>> saveResults =
            FObject.insertRecordsFromTemplateWithKeys(template, true, new List<String>());
        Test.stopTest();

        System.assert(saveResults.isEmpty(), 'insertRecordsFromTemplate - errors found');
    }

    @IsTest
    private static void insertRecordsFromTemplateWithKeys_nullAllOrNone_expectSuccess() {
        Map<String, FObject> template = new Map<String, FObject>(template1());
        List<String> keys = new List<String>{
            'Ones', 'Twos', 'Threes'
        };

        Test.startTest();
        Map<String, List<Database.SaveResult>> saveResults =
            FObject.insertRecordsFromTemplateWithKeys(template, null, keys);
        Test.stopTest();

        System.assert(saveResults.isEmpty(), 'insertRecordsFromTemplateBeforeKey - errors found');
    }

    @IsTest
    private static void insertRecordsFromTemplateWithKeysOptimised_removedKeys_expectSuccess() {
        Map<String, FObject> template = new Map<String, FObject>(template1());
        List<String> keys = new List<String>{
            'Ones', 'Twos'
        };

        Test.startTest();
        FObject.setDmlOptimizer(true);
        FObject.insertRecordsFromTemplateWithKeys(template, true, keys);
        Test.stopTest();

        Integer errors = 0;
        if (template.containsKey('Ones') || template.containsKey('Twos')) {
            errors += 1;
        }
        if (!template.containsKey('Threes') || !template.containsKey('FObjectTwos')) {
            errors += 2;
        }
        System.assertEquals(0, errors, 'insertRecordsFromTemplate - errors found');
    }

    @IsTest
    private static void insertRecordsFromTemplateWithKeysOptimised_noErrorsAllOrNoneTrue_expectSuccess() {
        Map<String, FObject> template = new Map<String, FObject>(template1());
        Integer numRecordsA1 = template.get('Ones').getNumberOfRecords();
        Integer numRecordsA2 = template.get('Twos').getNumberOfRecords();
        Integer numRecordsA3 = template.get('Threes').getNumberOfRecords();
        List<String> keys = new List<String>{
            'Ones', 'Twos', 'Threes'
        };

        Test.startTest();
        FObject.setDmlOptimizer(true);
        FObject.insertRecordsFromTemplateWithKeys(template, true, keys);
        Integer dmlStatements = Limits.getDmlStatements();
        Test.stopTest();

        Integer errors = 0;
        if (FObject.getInsertedRecords(FObjectOne__c.SObjectType).size() != (numRecordsA1 + numRecordsA2 + numRecordsA3)) {
            errors += 1;
        }
        if (FObject.getInsertedGroupRecords(FObjectOne__c.SObjectType, 'Group2').size() != numRecordsA2) {
            errors += 2;
        }
        if (!FObject.getInsertedRecords(FObjectTwo__c.SObjectType).isEmpty()) {
            errors += 4;
        }
        if (dmlStatements != 1) {
            errors += 8;
        }
        System.assertEquals(0, errors, 'insertRecordsFromTemplate - errors found');
    }

    @IsTest
    private static void insertRecordsFromTemplateWithKeysOptimised_noErrorsAllOrNoneFalse_expectSuccess() {
        Map<String, FObject> template = new Map<String, FObject>(template1());
        Integer numRecordsA1 = template.get('Ones').getNumberOfRecords();
        Integer numRecordsA2 = template.get('Twos').getNumberOfRecords();
        Integer numRecordsA3 = template.get('Threes').getNumberOfRecords();
        List<String> keys = new List<String>{
            'Ones', 'Twos', 'Threes'
        };

        Test.startTest();
        FObject.setDmlOptimizer(true);
        FObject.insertRecordsFromTemplateWithKeys(template, true, keys);
        Integer dmlStatements = Limits.getDmlStatements();
        Test.stopTest();

        Integer errors = 0;
        if (FObject.getInsertedRecords(FObjectOne__c.SObjectType).size() != (numRecordsA1 + numRecordsA2 + numRecordsA3)) {
            errors += 1;
        }
        if (FObject.getInsertedGroupRecords(FObjectOne__c.SObjectType, 'Group2').size() != numRecordsA2) {
            errors += 2;
        }
        if (!FObject.getInsertedRecords(FObjectTwo__c.SObjectType).isEmpty()) {
            errors += 4;
        }
        if (dmlStatements != 1) {
            errors += 8;
        }
        System.assertEquals(0, errors, 'insertRecordsFromTemplate - errors found');
    }

    @IsTest
    private static void insertRecordsFromTemplateWithKeysOptimised_errorsAllOrNoneTrue_expectFailure() {
        Map<String, FObject> template = new Map<String, FObject>(template1());
        template.get('Twos')
            .setDefinition(FObjectOne__c.TestIntegerUnique__c, 'static value(1)');
        List<String> keys = new List<String>{
            'Ones', 'Twos', 'Threes'
        };

        Test.startTest();
        String errorMessage = '';
        try {
            FObject.setDmlOptimizer(true);
            FObject.insertRecordsFromTemplateWithKeys(template, true, keys);
        } catch (Exception ex) {
            errorMessage = ex.getMessage();
        }
        Integer dmlStatements = Limits.getDmlStatements();
        Test.stopTest();

        Integer errors = 0;
        if (String.isBlank(errorMessage)) {
            errors += 1;
        }
        if (FObject.getInsertedRecords(FObjectOne__c.SObjectType).size() != 0) {
            errors += 2;
        }
        if (FObject.getInsertedRecords(FObjectTwo__c.SObjectType).size() != 0) {
            errors += 4;
        }
        if (dmlStatements != 1) {
            errors += 8;
        }
        System.assertEquals(0, errors, 'insertRecordsFromTemplate - errors found');
    }

    @IsTest
    private static void insertRecordsFromTemplateWithKeysOptimised_errorsAllOrNoneFalse_expectSuccess() {
        Map<String, FObject> template = new Map<String, FObject>(template1());
        Integer numRecordsA2 = template.get('Twos').getNumberOfRecords();
        Integer numRecordsA3 = template.get('Threes').getNumberOfRecords();
        template.get('Twos')
            .setDefinition(FObjectOne__c.TestIntegerUnique__c, 'static value(1)');
        List<String> keys = new List<String>{
            'Ones', 'Twos', 'Threes'
        };

        Test.startTest();
        FObject.setDmlOptimizer(true);
        Map<String, List<Database.SaveResult>> saveResults =
            FObject.insertRecordsFromTemplateWithKeys(template, false, keys);
        Integer dmlStatements = Limits.getDmlStatements();
        Test.stopTest();

        Integer errors = 0;
        if (FObject.getInsertedRecords(FObjectOne__c.SObjectType).size() != numRecordsA2 + numRecordsA3) {
            errors += 1;
        }
        if (FObject.getInsertedRecords(FObjectTwo__c.SObjectType).size() != 0) {
            errors += 2;
        }
        if (dmlStatements != 1) {
            errors += 4;
        }
        if (!saveResults.containsKey('Ones') || !saveResults.containsKey('Twos') || !saveResults.containsKey('Threes')) {
            errors += 8;
        }
        if (!saveResults.get('Ones').get(0).isSuccess()) {
            errors += 16;
        }
        if (!saveResults.get('Twos').get(0).isSuccess() || saveResults.get('Twos').get(1).isSuccess()) {
            errors += 32;
        }
        if (!saveResults.get('Threes').get(3).isSuccess()) {
            errors += 64;
        }
        System.assertEquals(0, errors, 'insertRecordsFromTemplate - errors found');
    }

    @IsTest
    private static void insertRecordsFromTemplateWithKeysOptimisedInstance_noErrorsAllOrNoneTrue_expectSuccess() {
        Map<String, FObject> template = new Map<String, FObject>();
        template.putAll(template1());
        template.putAll(template2());

        FObject objA1 = template.get('Ones');
        FObject objA2 = template.get('Twos');
        FObject objA3 = template.get('Threes');

        Integer numRecordsA1 = objA1.getNumberOfRecords();
        Integer numRecordsA2 = objA2.getNumberOfRecords();
        Integer numRecordsA3 = objA3.getNumberOfRecords();

        List<String> keys = new List<String>{
            'Ones', 'Twos', 'Threes'
        };

        Test.startTest();
        FObject.setDmlOptimizer(true);
        FObject.insertRecordsFromTemplateWithKeys(template, true, keys);
        Integer dmlStatements = Limits.getDmlStatements();
        Test.stopTest();

        Integer errors = 0;
        if (objA1.getInsertedRecords().size() != numRecordsA1 ||
            objA2.getInsertedRecords().size() != numRecordsA2 ||
            objA3.getInsertedRecords().size() != numRecordsA3) {
            errors += 1;
        }
        if (objA1.getInsertedGroupRecords('').size() != numRecordsA1 ||
            objA2.getInsertedGroupRecords('group2').size() != numRecordsA2 ||
            objA3.getInsertedGroupRecords('').size() != numRecordsA3) {
            errors += 2;
        }
        if (dmlStatements != 1) {
            errors += 4;
        }
        System.assertEquals(0, errors, 'insertRecordsFromTemplate - errors found');
    }

    @IsTest
    private static void insertRecordsFromTemplateWithKeysOptimisedInstance_errorsAllOrNoneFalse_expectSuccess() {
        Map<String, FObject> template = new Map<String, FObject>();
        template.putAll(template1());
        template.putAll(template2());

        FObject objA1 = template.get('Ones');
        FObject objA2 = template.get('Twos');
        FObject objA3 = template.get('Threes');

        Integer numRecordsA1 = objA1.getNumberOfRecords();
        Integer numRecordsA3 = objA3.getNumberOfRecords();

        template.get('Twos')
            .setDefinition(FObjectOne__c.TestIntegerUnique__c, 'static value(1)');
        List<String> keys = new List<String>{
            'Ones', 'Twos', 'Threes'
        };

        Test.startTest();
        FObject.setDmlOptimizer(true);
        Map<String, List<Database.SaveResult>> saveResults =
            FObject.insertRecordsFromTemplateWithKeys(template, false, keys);
        Integer dmlStatements = Limits.getDmlStatements();
        Test.stopTest();

        Integer errors = 0;
        if (objA1.getInsertedRecords().size() != numRecordsA1 ||
            objA2.getInsertedRecords().size() != 1 ||
            objA3.getInsertedRecords().size() != numRecordsA3) {
            errors += 1;
        }
        if (objA1.getInsertedGroupRecords('').size() != numRecordsA1 ||
            objA2.getInsertedGroupRecords('group2').size() != 1 ||
            objA3.getInsertedGroupRecords('').size() != numRecordsA3) {
            errors += 2;
        }
        if (dmlStatements != 1) {
            errors += 4;
        }
        if (!saveResults.containsKey('Ones') || !saveResults.containsKey('Twos') || !saveResults.containsKey('Threes')) {
            errors += 8;
        }
        if (!saveResults.get('Ones').get(0).isSuccess() || saveResults.get('Twos').get(2).isSuccess()) {
            errors += 16;
        }
        System.assertEquals(0, errors, 'insertRecordsFromTemplate - errors found');
    }

    @IsTest
    private static void insertRecordsFromTemplateWithoutKeys_removedKeys_expectSuccess() {
        Map<String, FObject> template = new Map<String, FObject>(template1());
        List<String> keys = new List<String>{
            'Ones', 'Twos'
        };

        Test.startTest();
        FObject.insertRecordsFromTemplateWithoutKeys(template, true, keys);
        Test.stopTest();

        Integer errors = 0;
        if (template.containsKey('FObjectTwos') || template.containsKey('Threes')) {
            errors += 1;
        }
        if (!template.containsKey('Ones') || !template.containsKey('Twos')) {
            errors += 2;
        }
        System.assertEquals(0, errors, 'insertRecordsFromTemplate - errors found');
    }

    @IsTest
    private static void insertRecordsFromTemplateBeforeKey_removedKeys_expectSuccess() {
        Map<String, FObject> template = new Map<String, FObject>(template1());

        Test.startTest();
        FObject.insertRecordsFromTemplateBeforeKey(template, true, 'Twos');
        Test.stopTest();

        Integer errors = 0;
        if (template.containsKey('FObjectTwos') || template.containsKey('Ones')) {
            errors += 1;
        }
        if (!template.containsKey('Twos') || !template.containsKey('Threes')) {
            errors += 2;
        }
        System.assertEquals(0, errors, 'insertRecordsFromTemplate - errors found');
    }

    @IsTest
    private static void insertRecordsFromTemplateBeforeKey_noErrorsAllOrNoneTrue_expectSuccess() {
        Map<String, FObject> template = new Map<String, FObject>(template1());
        Map<String, FObject> initialTemplate = template.clone();
        Integer numRecordsA1 = template.get('Ones').getNumberOfRecords();
        Integer numRecordsA2 = template.get('Twos').getNumberOfRecords();
        Integer numRecordsB = template.get('FObjectTwos').getNumberOfRecords();
        String key = 'Threes';

        Test.startTest();
        FObject.setDmlOptimizer(false);
        FObject.insertRecordsFromTemplateBeforeKey(template, true, key);
        Integer dmlStatements = Limits.getDmlStatements();
        Test.stopTest();

        Integer errors = 0;
        if (FObject.getInsertedRecords(FObjectOne__c.SObjectType).size() != (numRecordsA1 + numRecordsA2)) {
            errors += 1;
        }
        if (FObject.getInsertedGroupRecords(FObjectOne__c.SObjectType, 'Group2').size() != numRecordsA2) {
            errors += 2;
        }
        if (FObject.getInsertedRecords(FObjectTwo__c.SObjectType).size() != numRecordsB) {
            errors += 4;
        }
        if (dmlStatements != 3) {
            errors += 8;
        }
        if (!templateHasAllKeysBeforeKey(initialTemplate, template, key)) {
            errors += 16;
        }
        System.assertEquals(0, errors, 'insertRecordsFromTemplateBeforeKey - errors found');
    }

    @IsTest
    private static void insertRecordsFromTemplateBeforeKey_noErrorsAllOrNoneFalse_expectSuccess() {
        Map<String, FObject> template = new Map<String, FObject>(template1());
        Map<String, FObject> initialTemplate = template.clone();
        Integer numRecordsA1 = template.get('Ones').getNumberOfRecords();
        Integer numRecordsA2 = template.get('Twos').getNumberOfRecords();
        Integer numRecordsB = template.get('FObjectTwos').getNumberOfRecords();
        String key = 'Threes';

        Test.startTest();
        FObject.setDmlOptimizer(false);
        FObject.insertRecordsFromTemplateBeforeKey(template, true, key);
        Integer dmlStatements = Limits.getDmlStatements();
        Test.stopTest();

        Integer errors = 0;
        if (FObject.getInsertedRecords(FObjectOne__c.SObjectType).size() != (numRecordsA1 + numRecordsA2)) {
            errors += 1;
        }
        if (FObject.getInsertedGroupRecords(FObjectOne__c.SObjectType, 'Group2').size() != numRecordsA2) {
            errors += 2;
        }
        if (FObject.getInsertedRecords(FObjectTwo__c.SObjectType).size() != numRecordsB) {
            errors += 4;
        }
        if (dmlStatements != 3) {
            errors += 8;
        }
        if (!templateHasAllKeysBeforeKey(initialTemplate, template, key)) {
            errors += 16;
        }
        System.assertEquals(0, errors, 'insertRecordsFromTemplateBeforeKey - errors found');
    }

    @IsTest
    private static void insertRecordsFromTemplateBeforeKey_errorsAllOrNoneTrue_expectFailure() {
        Map<String, FObject> template = new Map<String, FObject>(template1());
        Map<String, FObject> initialTemplate = template.clone();
        Integer numRecordsB = template.get('FObjectTwos').getNumberOfRecords();
        template.get('Ones')
            .setDefinition(FObjectOne__c.TestIntegerUnique__c, 'static value(1)');
        String key = 'Threes';

        Test.startTest();
        String errorMessage = '';
        try {
            FObject.insertRecordsFromTemplateBeforeKey(template, true, key);
        } catch (Exception ex) {
            errorMessage = ex.getMessage();
        }
        Integer dmlStatements = Limits.getDmlStatements();
        Test.stopTest();

        Integer errors = 0;
        if (String.isBlank(errorMessage)) {
            errors += 1;
        }
        if (!FObject.getInsertedRecords(FObjectOne__c.SObjectType).isEmpty()) {
            errors += 2;
        }
        if (FObject.getInsertedRecords(FObjectTwo__c.SObjectType).size() != numRecordsB) {
            errors += 4;
        }
        if (dmlStatements != 2) {
            errors += 8;
        }
        if (!templateHasAllKeysBeforeKey(initialTemplate, template, key)) {
            errors += 16;
        }
        System.assertEquals(0, errors, 'insertRecordsFromTemplateBeforeKey - errors found');
    }

    @IsTest
    private static void insertRecordsFromTemplateBeforeKey_errorsAllOrNoneFalse_expectSuccess() {
        Map<String, FObject> template = new Map<String, FObject>(template1());
        Map<String, FObject> initialTemplate = template.clone();
        Integer numRecordsA2 = template.get('Twos').getNumberOfRecords();
        Integer numRecordsB = template.get('FObjectTwos').getNumberOfRecords();
        template.get('Ones')
            .setDefinition(FObjectOne__c.TestIntegerUnique__c, 'static value(1)');
        String key = 'Threes';

        Test.startTest();
        Map<String, List<Database.SaveResult>> saveResults =
            FObject.insertRecordsFromTemplateBeforeKey(template, false, key);
        Integer dmlStatements = Limits.getDmlStatements();
        Test.stopTest();

        Integer errors = 0;
        if (FObject.getInsertedRecords(FObjectOne__c.SObjectType).size() != 1 + numRecordsA2) {
            errors += 1;
        }
        if (FObject.getInsertedRecords(FObjectTwo__c.SObjectType).size() != numRecordsB) {
            errors += 2;
        }
        if (dmlStatements != 3) {
            errors += 4;
        }
        if (!saveResults.get('Ones').get(0).isSuccess() || saveResults.get('Ones').get(1).isSuccess()) {
            errors += 8;
        }
        if (!saveResults.get('Twos').get(0).isSuccess() || !saveResults.get('Twos').get(2).isSuccess()) {
            errors += 16;
        }
        if (!templateHasAllKeysBeforeKey(initialTemplate, template, key)) {
            errors += 16;
        }
        System.assertEquals(0, errors, 'insertRecordsFromTemplateBeforeKey - errors found');
    }

    @IsTest
    private static void insertRecordsFromTemplateBeforeKey_emptyTemplate_expectSuccess() {
        Map<String, FObject> template = new Map<String, FObject>();

        Test.startTest();
        Map<String, List<Database.SaveResult>> results =
            FObject.insertRecordsFromTemplateBeforeKey(template, false, 'Twos');
        Test.stopTest();

        System.assert(results.isEmpty(), 'insertRecordsFromTemplateBeforeKey - errors found');
    }

    @IsTest
    private static void insertRecordsFromTemplateBeforeKey_nullAllOrNone_expectSuccess() {
        Map<String, FObject> template = new Map<String, FObject>();

        Test.startTest();
        Map<String, List<Database.SaveResult>> results =
            FObject.insertRecordsFromTemplateBeforeKey(template, null, 'Twos');
        Test.stopTest();

        System.assert(results.isEmpty(), 'insertRecordsFromTemplateBeforeKey - errors found');
    }

    @IsTest
    private static void insertRecordsFromTemplateBeforeKey_emptyKey_expectSuccess() {
        Map<String, FObject> template = new Map<String, FObject>(template1());

        Test.startTest();
        Map<String, List<Database.SaveResult>> saveResults =
            FObject.insertRecordsFromTemplateBeforeKey(template, false, '');
        Test.stopTest();

        System.assert(saveResults.isEmpty(), 'insertRecordsFromTemplateBeforeKey - errors found');
    }

    @IsTest
    private static void insertRecordsFromTemplateBeforeKey_invalidKey_expectSuccess() {
        Map<String, FObject> template = new Map<String, FObject>(template1());

        Test.startTest();
        Map<String, List<Database.SaveResult>> saveResults =
            FObject.insertRecordsFromTemplateBeforeKey(template, false, 'xyz');
        Test.stopTest();

        System.assert(saveResults.isEmpty(), 'insertRecordsFromTemplateBeforeKey - errors found');
    }

    @IsTest
    private static void insertRecordsFromTemplateBeforeKeyInstance_noErrorsAllOrNoneTrue_expectSuccess() {
        Map<String, FObject> template = new Map<String, FObject>();
        template.putAll(template1());
        template.putAll(template2());

        FObject objA1 = template.get('Ones');
        FObject objA2 = template.get('Twos');
        FObject objB = template.get('FObjectTwos');

        Integer numRecordsA1 = objA1.getNumberOfRecords();
        Integer numRecordsA2 = objA2.getNumberOfRecords();
        Integer numRecordsB = objB.getNumberOfRecords();
        String key = 'Threes';

        Test.startTest();
        FObject.setDmlOptimizer(false);
        FObject.insertRecordsFromTemplateBeforeKey(template, true, key);
        Integer dmlStatements = Limits.getDmlStatements();
        Test.stopTest();

        Integer errors = 0;
        if (objA1.getInsertedRecords().size() != numRecordsA1 ||
            objA2.getInsertedRecords().size() != numRecordsA2) {
            errors += 1;
        }
        if (objA1.getInsertedGroupRecords('').size() != numRecordsA1 ||
            objA2.getInsertedGroupRecords('group2').size() != numRecordsA2) {
            errors += 2;
        }
        if (objB.getInsertedRecords().size() != numRecordsB ||
            objB.getInsertedGroupRecords('').size() != numRecordsB) {
            errors += 4;
        }
        if (dmlStatements != 3) {
            errors += 8;
        }
        System.assertEquals(0, errors, 'insertRecordsFromTemplateBeforeKey - errors found');
    }

    @IsTest
    private static void insertRecordsFromTemplateBeforeKeyInstance_errorsAllOrNoneFalse_expectSuccess() {
        Map<String, FObject> template = new Map<String, FObject>();
        template.putAll(template1());
        template.putAll(template2());

        template.get('Twos')
            .setDefinition(FObjectOne__c.TestIntegerUnique__c, 'static value(1)');
        String key = 'Threes';

        FObject objA1 = template.get('Ones');
        FObject objA2 = template.get('Twos');
        FObject objB = template.get('FObjectTwos');

        Integer numRecordsA1 = objA1.getNumberOfRecords();
        Integer numRecordsB = objB.getNumberOfRecords();

        Test.startTest();
        Map<String, List<Database.SaveResult>> saveResults =
            FObject.insertRecordsFromTemplateBeforeKey(template, false, key);
        Integer dmlStatements = Limits.getDmlStatements();
        Test.stopTest();

        Integer errors = 0;
        if (objA1.getInsertedRecords().size() != numRecordsA1 ||
            objA2.getInsertedRecords().size() != 1) {
            errors += 1;
        }
        if (objA1.getInsertedGroupRecords('').size() != numRecordsA1 ||
            objA2.getInsertedGroupRecords('group2').size() != 1) {
            errors += 2;
        }
        if (objB.getInsertedRecords().size() != numRecordsB ||
            objB.getInsertedGroupRecords('').size() != numRecordsB) {
            errors += 4;
        }
        if (dmlStatements != 3) {
            errors += 8;
        }
        if (!saveResults.get('Ones').get(0).isSuccess() || !saveResults.get('Ones').get(1).isSuccess()) {
            errors += 16;
        }
        if (!saveResults.get('Twos').get(0).isSuccess() || saveResults.get('Twos').get(2).isSuccess()) {
            errors += 128;
        }
        System.assertEquals(0, errors, 'insertRecordsFromTemplateBeforeKey - errors found');
    }

    @IsTest
    private static void updateRecords_integerValues_expectSuccess() {
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestInteger__c, 'random type(number) from(1) to(100) scale(0)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj.insertRecords(true);

        Test.startTest();
        obj
            .setDefinitionForUpdate(FObjectOne__c.TestInteger__c, 'serial type(number) from(1) step(1) scale(0)')
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
        System.assert(errors == 0, 'updateRecords - errors found');
    }

    @IsTest
    private static void updateRecords_decimalValues_expectSuccess() {
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestDecimal__c, 'random type(number) from(1) to(100) scale(2)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
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
        System.assert(errors == 0, 'updateRecords - errors found');
    }

    @IsTest
    private static void updateRecords_dateValues_expectSuccess() {
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestDate__c, 'random type(date) from(2020-01-01) to(2020-12-31)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
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
        System.assert(errors == 0, 'updateRecords - errors found');
    }

    @IsTest
    private static void updateRecords_datetimeValues_expectSuccess() {
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestDatetime__c, 'random type(datetime) from(2020-01-01) to(2020-12-31)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
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
        System.assert(errors == 0, 'updateRecords - errors found');
    }

    @IsTest
    private static void updateRecords_stringValues_expectSuccess() {
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(test)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
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
        System.assert(errors == 0, 'updateRecords - errors found');
    }

    @IsTest
    private static void updateRecords_create0Def_forUpdate0Def_noUpdate_expectSuccess() {
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
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
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
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
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
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
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
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
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(one)')
            .createRecords();

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
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(one)')
            .createRecords();

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
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(one)')
            .createRecords();

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
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(one)')
            .createRecords();

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
    private static void updateRecords_insert1Def_forUpdate0Def_noUpdate_expectSuccess() {
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(one)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
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
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(number) from(1) step(1) scale(0)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
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
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(one)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
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
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(one)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj.insertRecords(true);

        Test.startTest();
        String updatedValue = 'two';
        obj
            .setNumberOfRecords(1)
            .setDefinitionForUpdate(FObjectOne__c.TestText__c, 'static value(' + updatedValue + ')')
            .updateFields()
            .updateRecords(true);
        Test.stopTest();

        System.assert(ForceeaUtilityTest.updateIsValidForInsertedRecords('', updatedValue), 'updateRecords - errors found');
    }

    @IsTest
    private static void updateRecords_insert1Def_forUpdate2Def_update_expectSuccess() {
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(one)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
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

        System.assert(ForceeaUtilityTest.updateIsValidForInsertedRecords('', updatedValue), 'updateRecords - errors found');
    }

    @IsTest
    private static void updateRecords_virtualField_expectSuccess() {
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestInteger__c, 'random type(number) from(1) to(100) scale(0)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj.insertRecords(true, 'MyGroup');

        Test.startTest();
        obj.setNumberOfRecords(1)
            .setNumberOfNextRecord(1)
            .setDefinition(FObjectOne__c.TestPicklistA__c, 'random type(picklist)')
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
        System.assert(errors == 0, 'updateRecords - errors found');
    }

    @IsTest
    private static void updateRecords_externalRecord_expectSuccess() {
        FObjectOne__c recordToInsert = new FObjectOne__c(TestTextRequired__c = 'Test');
        insert recordToInsert;
        FObject obj = new FObject(recordToInsert);

        Test.startTest();
        obj.setNumberOfRecords(1)
            .setDefinition(FObjectOne__c.TestText__c, 'random type(list) value(a,b,c)')
            .setDefinitionForUpdate('$SerialValues', 'serial type(number) from(1) step(1) scale(0)')
            .setDefinitionForUpdate(FObjectOne__c.TestInteger__c, 'copy field($SerialValues)')
            .setDefinitionForUpdate(FObjectOne__c.TestTextRequired__c, 'copy field($SerialValues)')
            .updateFields('')
            .updateRecords(true);
        Test.stopTest();

        Integer errors = 0;
        Integer counter = 1;
        for (FObjectOne__c record : (List<FObjectOne__c>) obj.getUpdatedRecords()) {
            if (record.TestInteger__c != counter && record.TestTextRequired__c != String.valueOf(counter)) {
                errors++;
            }
            counter++;
        }
        if (obj.getUpdatedRecords().size() != 1) {
            errors++;
        }
        System.assert(errors == 0, 'updateRecords - errors found');
    }

    @IsTest
    private static void updateRecords_externalRecordGroup_expectSuccess() {
        FObjectOne__c recordToInsert = new FObjectOne__c(TestTextRequired__c = 'Test');
        insert recordToInsert;
        FObject obj = new FObject(recordToInsert, 'group1');

        Test.startTest();
        obj.setNumberOfRecords(1)
            .setDefinition(FObjectOne__c.TestText__c, 'random type(list) value(a,b,c)')
            .setDefinitionForUpdate('$SerialValues', 'serial type(number) from(1) step(1) scale(0)')
            .setDefinitionForUpdate(FObjectOne__c.TestInteger__c, 'copy field($SerialValues)')
            .setDefinitionForUpdate(FObjectOne__c.TestTextRequired__c, 'copy field($SerialValues)')
            .updateFields('group1')
            .updateRecords(true);
        Test.stopTest();

        Integer errors = 0;
        Integer counter = 1;
        for (FObjectOne__c record : (List<FObjectOne__c>) obj.getUpdatedRecords()) {
            if (record.TestInteger__c != counter && record.TestTextRequired__c != String.valueOf(counter)) {
                errors++;
            }
            counter++;
        }
        if (obj.getUpdatedRecords().size() != 1) {
            errors++;
        }
        System.assert(errors == 0, 'updateRecords - errors found');
    }

    @IsTest
    private static void updateRecords_externalRecords_expectSuccess() {
        List<FObjectOne__c> recordsToInsert = new List<FObjectOne__c>();
        for (Integer counter = 1; counter <= 10; counter++) {
            recordsToInsert.add(new FObjectOne__c(TestTextRequired__c = 'Test' + String.valueOf(counter)));
        }
        insert recordsToInsert;
        FObject obj = new FObject(recordsToInsert);

        Test.startTest();
        obj.setNumberOfRecords(1)
            .setDefinition(FObjectOne__c.TestText__c, 'random type(list) value(a,b,c)')
            .setDefinitionForUpdate('$SerialValues', 'serial type(number) from(1) step(1) scale(0)')
            .setDefinitionForUpdate(FObjectOne__c.TestInteger__c, 'copy field($SerialValues)')
            .setDefinitionForUpdate(FObjectOne__c.TestTextRequired__c, 'copy field($SerialValues)')
            .updateFields('')
            .updateRecords(true);
        Test.stopTest();

        Integer errors = 0;
        Integer counter = 1;
        for (FObjectOne__c record : (List<FObjectOne__c>) obj.getUpdatedRecords()) {
            if (record.TestInteger__c != counter && record.TestTextRequired__c != String.valueOf(counter)) {
                errors++;
            }
            counter++;
        }
        if (obj.getUpdatedRecords().size() != 10) {
            errors++;
        }
        System.assert(errors == 0, 'updateRecords - errors found');
    }

    @IsTest
    private static void updateRecords_externalRecordsGroup_expectSuccess() {
        List<FObjectOne__c> recordsToInsert = new List<FObjectOne__c>();
        for (Integer counter = 1; counter <= 10; counter++) {
            recordsToInsert.add(new FObjectOne__c(TestTextRequired__c = 'Test' + String.valueOf(counter)));
        }
        insert recordsToInsert;
        FObject obj = new FObject(recordsToInsert, 'group1');

        Test.startTest();
        obj.setNumberOfRecords(1)
            .setDefinition(FObjectOne__c.TestText__c, 'random type(list) value(a,b,c)')
            .setDefinitionForUpdate('$SerialValues', 'serial type(number) from(1) step(1) scale(0)')
            .setDefinitionForUpdate(FObjectOne__c.TestInteger__c, 'copy field($SerialValues)')
            .setDefinitionForUpdate(FObjectOne__c.TestTextRequired__c, 'copy field($SerialValues)')
            .updateFields('group1')
            .updateRecords(true);
        Test.stopTest();

        Integer errors = 0;
        Integer counter = 1;
        for (FObjectOne__c record : (List<FObjectOne__c>) obj.getUpdatedRecords()) {
            if (record.TestInteger__c != counter && record.TestTextRequired__c != String.valueOf(counter)) {
                errors++;
            }
            counter++;
        }
        if (obj.getUpdatedRecords().size() != 10) {
            errors++;
        }
        System.assert(errors == 0, 'updateRecords - errors found');
    }

    /* TEMPLATES */

    public static Map<String, FObject> template1() {
        Map<String, FObject> template = new Map<String, FObject>();

        template.put('FObjectTwos', new FObject(FObjectTwo__c.SObjectType, 1)
            .setDefinition(FObjectTwo__c.TestText__c, 'random type(number) from(10) to(100) scale(0)')
            .setDefinition(FObjectTwo__c.TestTextUnique__c, 'serial type(number) from(1) step(1) scale(0)')
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)')
        );

        template.put('Ones', new FObject(FObjectOne__c.SObjectType, 2)
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(number) from(1) step(1) scale(0)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(1)')
        );

        template.put('Twos', new FObject('FObjectOne__c', 3)
            .setGroupName('Group2')
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(number) from(1) step(1) scale(0)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(2)')
        );

        template.put('Threes', new FObject(FObjectOne__c.SObjectType, 4)
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(number) from(1) step(1) scale(0)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(3)')
        );

        return template;
    }

    public static Map<String, FObject> template2() {
        Map<String, FObject> template = new Map<String, FObject>();

        template.put('B4', new FObject(FObjectTwo__c.SObjectType, 1)
            .setDefinition(FObjectTwo__c.TestText__c, 'random type(number) from(10) to(100) scale(0)')
            .setDefinition(FObjectTwo__c.TestTextUnique__c, 'serial type(number) from(1) step(1) scale(0)')
            .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)')
        );

        template.put('B1', new FObject(FObjectOne__c.SObjectType, 2)
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(number) from(1) step(1) scale(0)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(1)')
        );

        template.put('B2', new FObject('FObjectOne__c', 3)
            .setGroupName('Group2')
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(number) from(1) step(1) scale(0)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(2)')
        );

        template.put('B3', new FObject(FObjectOne__c.SObjectType, 4)
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(number) from(1) step(1) scale(0)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(3)')
        );

        return template;
    }

    public static Map<String, FObject> template3() {
        Map<String, FObject> template = new Map<String, FObject>();

        template.put('FoursA', new FObject(FObjectFour__c.SObjectType, 10)
            .setDefinition(FObjectFour__c.TestDecimal__c, 'random type(number) from(10) to(100) scale(2)')
            .setDefinition(FObjectFour__c.TestLookupSelf__c, 'random lookup(FObjectFour__c) source(salesforce)')
        );

        template.put('FoursB', new FObject(FObjectFour__c.SObjectType, 10)
            .setDefinition(FObjectFour__c.TestDecimal__c, 'random type(number) from(10) to(100) scale(2)')
        );

        return template;
    }

    /* METHODS */

    private static Boolean templateHasAllKeysBeforeKey(
        Map<String, FObject> template, Map<String, FObject> modifiedTemplate, String key) {
        List<String> modifiedTemplateKeys = new List<String>();
        for (String modifiedTemplateKey : modifiedTemplate.keySet()) {
            modifiedTemplateKeys.add(modifiedTemplateKey);
        }

        Boolean isOk = false;
        Set<String> keys = new Set<String>();
        for (String templateKey : template.keySet()) {
            if (!isOk && templateKey == key) {
                isOk = true;
            }
            if (isOk) {
                keys.add(templateKey);
            }
        }

        return (keys.hashCode() == modifiedTemplate.keySet().hashCode());
    }

    private static Boolean templateHasAllKeysExcludingKeys(Map<String, FObject> template, List<String> keys) {
        for (String templateKey : template.keySet()) {
            if (keys.contains(templateKey)) {
                return false;
            }
        }

        return true;
    }

}
