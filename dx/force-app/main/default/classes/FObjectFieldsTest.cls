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
public class FObjectFieldsTest {

    @IsTest
    private static void deleteAllDefinitions_declareNoDefinitions_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.deleteAllDefinitions();
        Test.stopTest();

        System.assertEquals(true, obj.getAllDefinitions().isEmpty(), 'deleteAllDefinitions - errors found');
    }

    @IsTest
    private static void deleteAllDefinitions_declareSomeDefinitions_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('TestText__c', 'static value(TestName_)')
            .setDefinition('TestDecimal__c', 'random type(number) from(1) to(100) scale(0)')
            .setDefinition('TestPicklistA__c', 'random type(picklist)')
            .setDefinition('TestPicklistB__c', 'random type(picklist)')
            .deleteAllDefinitions();
        Test.stopTest();

        System.assertEquals(true, obj.getAllDefinitions().isEmpty(), 'deleteAllDefinitions - errors found');
    }

    @IsTest
    private static void deleteAllDefinitions_recordsAreClearedAfterNewDefinition_expectSuccess() {
        Test.startTest();

        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('TestText__c', 'static value(TestName_)');
        obj.setDefinition('TestText__c', 'random type(number) from(1) to(100) scale(0)');
        obj.setDefinition('TestPicklistA__c', 'random type(picklist)');
        obj.setDefinition('TestPicklistB__c', 'random type(picklist)');
        List<FObjectOne__c> objRecords1 = obj.getRecords();
        Integer hash1 = objRecords1.hashCode();

        obj.deleteAllDefinitions();

        obj.setDefinition('TestText__c', 'static value(TestName_)');
        obj.setDefinition('TestText__c', 'random type(number) from(1) to(100) scale(0)');
        obj.setDefinition('TestPicklistA__c', 'random type(picklist)');
        obj.setDefinition('TestPicklistB__c', 'random type(picklist)');
        List<FObjectOne__c> objRecords2 = obj.getRecords();
        Integer hash2 = objRecords2.hashCode();

        Test.stopTest();

        System.assertNotEquals(hash1, hash2, 'deleteAllDefinitions - errors found');
    }

    @IsTest
    private static void deleteDefinitions_declareNoDefinitions_expectSuccess() {
        Test.startTest();

        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('TestDecimal__c', 'random type(number) from(1) to(100) scale(0)')
            .setDefinition('TestPicklistA__c', 'random type(picklist)')
            .setDefinition('TestPicklistB__c', 'random type(picklist)')
            .deleteDefinitions(FObjectOne__c.TestText__c);

        Test.stopTest();

        Boolean expectedResult = true;
        Boolean actualResult = obj.getDefinitions(FObjectOne__c.TestText__c).isEmpty();
        System.assertEquals(expectedResult, actualResult, 'deleteDefinitions - errors found');
    }

    @IsTest
    private static void deleteDefinitions_declareSomeDefinitions_expectSuccess() {
        Test.startTest();

        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('TestDecimal__c', 'random type(number) from(1) to(100) scale(0)');
        obj.setDefinition('TestText__c', 'static value(TestName_)');
        obj.setDefinition('TestText__c', 'random type(number) from(1) to(100) scale(0)');
        obj.setDefinition('TestPicklistA__c', 'random type(picklist)');
        obj.setDefinition('TestPicklistB__c', 'random type(picklist)');
        obj.deleteDefinitions(FObjectOne__c.TestText__c);

        Test.stopTest();

        Integer errors = 0;
        if (!obj.getDefinitions('TestText__c').isEmpty()) {
            errors += 1;
        }
        if (obj.getDefinitions('TestDecimal__c').size() != 1) {
            errors += 2;
        }
        if (obj.getDefinitions('TestPicklistA__c').size() != 1) {
            errors += 4;
        }
        if (obj.getDefinitions('TestPicklistB__c').size() != 1) {
            errors += 8;
        }
        System.assertEquals(0, errors, 'deleteDefinitions - errors found');
    }

    @IsTest
    private static void deleteDefinitions_invalidField_expectFailure() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition('TestText__c', 'static value(TestName_)');
        obj.setDefinition('TestText__c', 'random type(number) from(1) to(100) scale(0)');
        obj.setDefinition('TestDecimal__c', 'random type(number) from(1) to(100) scale(0)');
        obj.deleteDefinitions('TestTextX__c');
        Test.stopTest();

        System.assertEquals('Invalid field [TestTextX__c] in method deleteDefinitions',
            obj.getErrors().get('FObjectOne__c').get(0), 'deleteDefinitions - wrong error message for invalid field');
    }

    @IsTest
    private static void deleteDefinitions_blankField_expectFailure() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition('TestText__c', 'static value(TestName_)');
        obj.setDefinition('TestText__c', 'random type(number) from(1) to(100) scale(0)');
        obj.setDefinition('TestDecimal__c', 'random type(number) from(1) to(100) scale(0)');
        obj.deleteDefinitions(' ');
        Test.stopTest();

        System.assertEquals('Invalid field [] in method deleteDefinitions',
            obj.getErrors().get('FObjectOne__c').get(0), 'deleteDefinitions - wrong error message for invalid field');
    }

    @IsTest
    private static void deleteDefinitions_recordsAreClearedAfterNewDefinition_expectSuccess() {
        Test.startTest();

        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('TestText__c', 'static value(TestName_)');
        obj.setDefinition('TestText__c', 'random type(number) from(1) to(100) scale(0)');
        obj.setDefinition('TestDecimal__c', 'random type(number) from(1) to(100) scale(0)');

        List<FObjectOne__c> objRecords1 = obj.getRecords();
        Integer hash1 = objRecords1.hashCode();

        obj.deleteDefinitions(FObjectOne__c.TestText__c);

        obj.setDefinition('TestText__c', 'static value(TestName_)');
        obj.setDefinition('TestText__c', 'random type(number) from(1) to(100) scale(0)');

        List<FObjectOne__c> objRecords2 = obj.getRecords();
        Integer hash2 = objRecords2.hashCode();

        Test.stopTest();

        System.assertNotEquals(hash1, hash2, 'deleteDefinitions - errors found');
    }

    @IsTest
    private static void getAllDefinitions_multipleChecks_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('TestText__c', 'Random type(date) From(2017-01-01) To(2017-12-31)');
        obj.setDefinition('TestText__c', 'static value(One)');
        obj.setDefinition('TestDatetime__c', 'Random type(datetime) From(2017-01-01) To(2017-12-31)');
        obj.setDefinition('TestDecimal__c', 'random type(number) From(1) To(100) Scale(0)');
        obj.setDefinition('TestEmail__c', 'Random type(email)');
        Map<String, List<String>> definitions = obj.getAllDefinitions();
        Test.stopTest();

        List<String> fields = new List<String>(definitions.keySet());

        Integer errors = 0;
        if (definitions.size() != 4 || definitions.get('TestText__c').size() != 2) {
            errors += 1;
        }
        if (fields.size() != 4) {
            errors += 2;
        }
        if (fields[3] != 'TestEmail__c') {
            errors += 4;
        }
        if (definitions.get('TestText__c').get(1) != 'static value(One)') {
            errors += 8;
        }
        System.assertEquals(0, errors, 'getAllDefinitions - errors found');
    }

    @IsTest
    private static void getPartitionFieldName_inInsert_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 20)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(test)')
            .setPartitionFieldName(FObjectOne__c.ForceeaPartition__c);
        Test.stopTest();

        System.assert(obj.getPartitionFieldName() == 'ForceeaPartition__c', 'getPartitionFieldName - errors found');
    }

    @IsTest
    private static void updateFields_create1Def_forUpdate0Def_updateCreated_expectSuccess() {
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(one)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();

        Test.startTest();
        obj
            .setNumberOfRecords(1)
            .updateFields();
        Test.stopTest();

        System.assert(ForceeaUtilityTest.updateIsValidForCreatedRecords(records, 'one'), 'updateFields - errors found');
    }

    @IsTest
    private static void updateFields_create1Def_forUpdate1Def_updateCreated_expectSuccess() {
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(one)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();

        Test.startTest();
        String updatedValue = 'two';
        obj
            .setNumberOfRecords(1)
            .setDefinitionForUpdate(FObjectOne__c.TestText__c, 'static value(' + updatedValue + ')')
            .updateFields();
        Test.stopTest();

        System.assert(ForceeaUtilityTest.updateIsValidForCreatedRecords(records, updatedValue), 'updateFields - errors found');
    }

    @IsTest
    private static void updateFields_create1Def_forUpdate2Def_updateCreated_expectSuccess() {
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(one)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();

        Test.startTest();
        String updatedValue = 'two';
        obj
            .setNumberOfRecords(1)
            .setNumberOfNextRecord(1)
            .setDefinitionForUpdate(FObjectOne__c.TestText__c, 'static value(' + updatedValue + ')')
            .setDefinitionForUpdate(FObjectOne__c.TestText__c, 'serial type(number) from(1) step(1) scale(0)')
            .updateFields();
        Test.stopTest();

        System.assert(ForceeaUtilityTest.updateIsValidForCreatedRecords(records, updatedValue), 'updateFields - errors found');
    }

    @IsTest
    private static void updateFields_insert1Def_forUpdate0Def_updateGlobal_expectSuccess() {
        String groupName = '';

        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(one)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj.insertRecords(true, groupName);

        Test.startTest();
        obj
            .setNumberOfRecords(1)
            .updateFields(groupName);
        Test.stopTest();

        System.assert(ForceeaUtilityTest.updateIsValidForInsertedRecords(groupName, 'one'), 'updateFields - errors found');
    }

    @IsTest
    private static void updateFields_insert1Def_forUpdate0Def_updateGroup_expectSuccess() {
        String groupName = 'MyGroup';

        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(one)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj.insertRecords(true, groupName);

        Test.startTest();
        obj
            .setNumberOfRecords(1)
            .updateFields(groupName);
        Test.stopTest();

        System.assert(ForceeaUtilityTest.updateIsValidForInsertedRecords(groupName, 'one'), 'updateFields - errors found');
    }

    @IsTest
    private static void updateFields_insert1Def_forUpdate1Def_updateGlobal_expectSuccess() {
        String groupName = '';

        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(one)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj.insertRecords(true, groupName);

        Test.startTest();
        String updatedValue = 'two';
        obj
            .setNumberOfRecords(1)
            .setDefinitionForUpdate(FObjectOne__c.TestText__c, 'static value(' + updatedValue + ')')
            .updateFields(groupName);
        Test.stopTest();

        System.assert(ForceeaUtilityTest.updateIsValidForInsertedRecords(groupName, updatedValue), 'updateFields - errors found');
    }

    @IsTest
    private static void updateFields_insert1Def_forUpdate1Def_updateGroup_expectSuccess() {
        String groupName = 'MyGroup';

        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(one)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj.insertRecords(true, groupName);

        Test.startTest();
        String updatedValue = 'two';
        obj
            .setNumberOfRecords(1)
            .setDefinitionForUpdate(FObjectOne__c.TestText__c, 'static value(' + updatedValue + ')')
            .updateFields(groupName);
        Test.stopTest();

        System.assert(ForceeaUtilityTest.updateIsValidForInsertedRecords(groupName, updatedValue), 'updateFields - errors found');
    }

    @IsTest
    private static void updateFields_insert1Def_forUpdate2Def_updateGlobal_expectSuccess() {
        String groupName;

        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(one)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj.insertRecords(true, groupName);

        Test.startTest();
        String updatedValue = 'two';
        obj
            .setNumberOfRecords(1)
            .setNumberOfNextRecord(1)
            .setDefinitionForUpdate(FObjectOne__c.TestText__c, 'static value(' + updatedValue + ')')
            .setDefinitionForUpdate(FObjectOne__c.TestText__c, 'serial type(number) from(1) step(1) scale(0)')
            .updateFields(groupName);
        Test.stopTest();

        System.assert(ForceeaUtilityTest.updateIsValidForInsertedRecords(groupName, updatedValue), 'updateFields - errors found');
    }

    @IsTest
    private static void updateFields_insert1Def_forUpdate2Def_updateGroup_expectSuccess() {
        String groupName = 'MyGroup';

        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(one)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj.insertRecords(true, groupName);

        Test.startTest();
        String updatedValue = 'two';
        obj
            .setNumberOfRecords(1)
            .setNumberOfNextRecord(1)
            .setDefinitionForUpdate(FObjectOne__c.TestText__c, 'static value(' + updatedValue + ')')
            .setDefinitionForUpdate(FObjectOne__c.TestText__c, 'serial type(number) from(1) step(1) scale(0)')
            .updateFields(groupName);
        Test.stopTest();

        System.assert(ForceeaUtilityTest.updateIsValidForInsertedRecords(groupName, updatedValue), 'updateFields - errors found');
    }

    @IsTest
    private static void updateFields_insert1Def_forUpdate2Updates_updateGlobal_expectSuccess() {
        String groupName = '';

        String updatedValue = 'one';
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(' + updatedValue + ')')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj.insertRecords(true, groupName);

        Test.startTest();
        updatedValue = 'two';
        obj
            .setNumberOfRecords(1)
            .setNumberOfNextRecord(1)
            .setDefinitionForUpdate(FObjectOne__c.TestText__c, 'static value(' + updatedValue + ')')
            .setDefinitionForUpdate(FObjectOne__c.TestInteger__c, 'serial type(number) from(1) step(1) scale(0)')
            .updateFields(groupName);
        updatedValue = 'three';
        obj
            .setDefinitionForUpdate(FObjectOne__c.TestText__c, 'static value(' + updatedValue + ')')
            .setDefinitionForUpdate(FObjectOne__c.TestInteger__c, 'serial type(number) from(1) step(1) scale(0)')
            .updateFields(groupName);
        Test.stopTest();

        System.assert(ForceeaUtilityTest.updateIsValidForInsertedRecords(groupName, updatedValue), 'updateFields - errors found');
    }

    @IsTest
    private static void updateFields_insert1Def_forUpdate2Updates_updateGroup_expectSuccess() {
        String groupName = 'MyGroup';

        String updatedValue = 'one';
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(' + updatedValue + ')')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj.insertRecords(true, groupName);

        Test.startTest();
        updatedValue = 'two';
        obj
            .setNumberOfRecords(1)
            .setNumberOfNextRecord(1)
            .setDefinitionForUpdate(FObjectOne__c.TestText__c, 'static value(' + updatedValue + ')')
            .setDefinitionForUpdate(FObjectOne__c.TestInteger__c, 'serial type(number) from(1) step(1) scale(0)')
            .updateFields(groupName);
        updatedValue = 'three';
        obj
            .setDefinitionForUpdate(FObjectOne__c.TestText__c, 'static value(' + updatedValue + ')')
            .setDefinitionForUpdate(FObjectOne__c.TestInteger__c, 'serial type(number) from(1) step(1) scale(0)')
            .updateFields(groupName);
        Test.stopTest();

        System.assert(ForceeaUtilityTest.updateIsValidForInsertedRecords(groupName, updatedValue), 'updateFields - errors found');
    }

    @IsTest
    private static void updateFields_insert1Def_forUpdateCopyExistingField_updateGroup_expectSuccess() {
        String groupName = 'MyGroup';

        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(number) from(1) step(1) scale(0)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj.insertRecords(true, groupName);

        Test.startTest();
        obj
            .setDefinitionForUpdate(FObjectOne__c.TestInteger__c, 'copy field(TestText__c)')
            .updateFields(groupName);
        Test.stopTest();

        Integer errors = 0;
        Integer counter = 1;
        for (FObjectOne__c record : (List<FObjectOne__c>) obj.getRecords()) {
            if (record.TestInteger__c != counter) {
                errors++;
            }
            counter++;
        }
        System.assertEquals(0, errors, 'updateFields - errors found');
    }

    @IsTest
    private static void updateFields_insert1Def_forUpdate1DefVirtualField_updateGlobal_expectSuccess() {
        String groupName = '';
        String updatedValue = 'one';

        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(' + updatedValue + ')')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj.insertRecords(true, groupName);

        Test.startTest();
        obj
            .setNumberOfRecords(1)
            .setNumberOfNextRecord(1)
            .setDefinitionForUpdate('$TestText', 'copy field(TestText__c)')
            .setDefinitionForUpdate(FObjectOne__c.TestText__c, 'copy field($TestText)')
            .setDefinitionForUpdate(FObjectOne__c.TestText__c, 'serial type(number) from(1) step(1) scale(0)')
            .updateFields(groupName);
        Test.stopTest();

        System.assert(ForceeaUtilityTest.updateIsValidForInsertedRecords(groupName, updatedValue), 'updateFields - errors found');
    }

    @IsTest
    private static void updateFields_dependentPicklistWithoutControlling_expectSuccess() {
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestPicklistA__c, 'static value(a2)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj.insertRecords(true);

        Test.startTest();
        obj
            .setDefinitionForUpdate(FObjectOne__c.TestPicklistB__c, 'random type(list) value(b1,b2)')
            .updateFields()
            .updateRecords(true);
        Test.stopTest();

        Integer errors = 0;
        List<String> values = new List<String>{
            'b1', 'b2'
        };
        for (FObjectOne__c record : [SELECT TestPicklistA__c, TestPicklistB__c FROM FObjectOne__c]) {
            if (record.TestPicklistA__c != 'a1' && !values.contains(record.TestPicklistB__c)) {
                errors++;
                break;
            }
        }
        System.assertEquals(0, errors, 'updateFields - errors found');
    }

    @IsTest
    private static void updateFields_dependentPicklistExceptWithoutControlling_expectSuccess() {
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestPicklistA__c, 'static value(a2)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj.insertRecords(true);

        Test.startTest();
        obj
            .setDefinitionForUpdate(FObjectOne__c.TestPicklistB__c, 'random type(picklist) except(b0,b3)')
            .updateFields()
            .updateRecords(true);
        Test.stopTest();

        Integer errors = 0;
        List<String> values = new List<String>{
            'b1', 'b2'
        };
        for (FObjectOne__c record : [SELECT TestPicklistA__c, TestPicklistB__c FROM FObjectOne__c]) {
            if (record.TestPicklistA__c != 'a1' && !values.contains(record.TestPicklistB__c)) {
                errors++;
                break;
            }
        }
        System.assertEquals(0, errors, 'updateFields - errors found');
    }

    @IsTest
    private static void updateFields_dependentPicklist_expectFailure() {
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(one)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj.insertRecords(true);

        Test.startTest();
        obj
            .setNumberOfRecords(1) // should be ignored
            .setNumberOfNextRecord(1)
            .setVariable('updatedValue', 'two')

            .setDefinitionForUpdate(FObjectOne__c.TestText__c, 'static value({@updatedValue})')
            .setDefinitionForUpdate(FObjectOne__c.TestText__c, 'serial type(number) from(1) step(1) scale(0)')
            .setDefinitionForUpdate(FObjectOne__c.TestPicklistB__c, 'random type(picklist)')
            .updateFields();

        String errorMessage = '';
        try {
            obj.updateRecords(true);
        } catch (Exception exp) {
            errorMessage = exp.getMessage();
        }
        Test.stopTest();

        Integer errors = 0;
        if (!errorMessage.contains('INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST')) {
            errors++;
        }
        System.assertEquals(0, errors, 'updateFields - errors found');
    }

    @IsTest
    private static void virtualFieldIsValid_firstCharIsNotDollar_expectFailure() {
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);

        Test.startTest();
        Boolean isValid = obj.virtualFieldIsValid('TestTest');
        Test.stopTest();

        System.assert(isValid == false, 'virtualField - errors found');
    }

    @IsTest
    private static void virtualFieldIsValid_isBlank_expectFailure() {
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);

        Test.startTest();
        Boolean isValid = obj.virtualFieldIsValid(' ');
        Test.stopTest();

        System.assert(isValid == false, 'virtualField - errors found');
    }

    @IsTest
    private static void virtualFieldIsValid_containsWhiteSpace_expectFailure() {
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);

        Test.startTest();
        Boolean isValid = obj.virtualFieldIsValid('$Test test');
        Test.stopTest();

        System.assert(isValid == false, 'virtualField - errors found');
    }

    @IsTest
    private static void virtualFieldIsValid_hasIllegalCharacters_expectFailure() {
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);

        Test.startTest();
        Boolean isValid = obj.virtualFieldIsValid('$Test2test');
        Test.stopTest();

        System.assert(isValid == false, 'virtualField - errors found');
    }

}
