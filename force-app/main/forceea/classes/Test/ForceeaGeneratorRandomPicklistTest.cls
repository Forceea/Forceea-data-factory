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
public class ForceeaGeneratorRandomPicklistTest {

    @IsTest
    private static void randomPicklist_independentPicklistField_expectSuccess() {
        List<String> arguments = new List<String>{
            'a0', 'a1', 'a2', 'a3'
        };

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType)
            .setDefinition(FObjectOne__c.TestPicklistA__c, 'random type(picklist)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Boolean expectedResult = true;
        Boolean actualResult = ForceeaUtilityTest.isValidDistribution('TestPicklistA__c', arguments, records);
        System.assertEquals(expectedResult, actualResult, 'random picklist - errors found');
    }

    @IsTest
    private static void randomPicklist_dependentPicklistField_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestPicklistC__c, 'random type(picklist)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj.insertRecords(true);
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
        Set<String> picklistB0Mapping = new Set<String>{
            ''
        };
        Set<String> picklistB1Mapping = new Set<String>{
            'c1'
        };
        Set<String> picklistB2Mapping = new Set<String>{
            'c1', 'c2'
        };
        Set<String> picklistB3Mapping = new Set<String>{
            'c1', 'c2', 'c3'
        };

        // get created field values
        List<String> picklistAValues = new List<String>();
        List<String> picklistBValues = new List<String>();
        List<String> picklistCValues = new List<String>();
        for (FObjectOne__c objRecord : records) {
            picklistAValues.add(objRecord.TestPicklistA__c);
            picklistBValues.add(objRecord.TestPicklistB__c);
            picklistCValues.add(objRecord.TestPicklistC__c);
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

            if (picklistBValues[counter] == 'b0' && !picklistB0Mapping.contains(picklistCValues[counter])) {
                errors++;
            } else if (picklistBValues[counter] == 'b1' && !picklistB1Mapping.contains(picklistCValues[counter])) {
                errors++;
            } else if (picklistBValues[counter] == 'b2' && !picklistB2Mapping.contains(picklistCValues[counter])) {
                errors++;
            } else if (picklistBValues[counter] == 'b3' && !picklistB3Mapping.contains(picklistCValues[counter])) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'random picklist - errors found');
    }

    @IsTest
    private static void randomPicklist_controllingFieldAfterDependentField_expectSuccess() {
        FObject.setGlobalVerbose('info'); // DO NOT REMOVE

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestPicklistB__c, 'random type(picklist)')
            .setDefinition(FObjectOne__c.TestPicklistA__c, 'random type(picklist)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj.insertRecords(true);
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
        String movedFieldLogMessage = 'Moved definition of controlling field [TestPicklistA__c] ' +
            'before definition of its dependent field [TestPicklistB__c].';
        if (!FObject.getGlobalDebugLogs().contains(movedFieldLogMessage)) {
            errors++;
        }
        System.assertEquals(0, errors, 'random picklist - errors found');
    }

    @IsTest
    private static void randomPicklist_definitionsOfDependentPicklists_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestPicklistC__c, 'random type(picklist)')
            .setDefinition(FObjectOne__c.RecordTypeId, 'static value(RecordTypeA)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj.insertRecords(true);
        Test.stopTest();

        List<String> picklistADefinitions = obj.getAllDefinitions().get('TestPicklistA__c');
        List<String> picklistBDefinitions = obj.getAllDefinitions().get('TestPicklistB__c');

        Integer errors = 0;
        if (picklistADefinitions[0] != 'random type(picklist)') {
            errors += 1;
        }
        if (picklistBDefinitions[0] != 'random type(picklist)') {
            errors += 2;
        }
        System.assertEquals(0, errors, 'random picklist - errors found');
    }

    @IsTest
    private static void randomPicklist_oneRecordType_expectSuccess() {
        Map<Id, Schema.RecordTypeInfo> recordTypesMap = Schema.SObjectType.FObjectThree__c.getRecordTypeInfosById();
        List<Id> keys = new List<Id>(recordTypesMap.keySet());

        Test.startTest();
        FObject obj = new FObject(FObjectThree__c.SObjectType, 10)
            .setDefinition(FObjectThree__c.RecordTypeId, 'random type(picklist)');
        Test.stopTest();

        Integer errors = 0;
        for (FObjectThree__c objRecord : (List<FObjectThree__c>) obj.getRecords()) {
            if (objRecord.RecordTypeId != keys.get(0)) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'random picklist - errors found');
    }

    @IsTest
    private static void randomPicklist_manyRecordTypes_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType)
            .setDefinition('RecordTypeId', 'random type(picklist)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Map<Id, Schema.RecordTypeInfo> recordTypesMap = Schema.SObjectType.FObjectOne__c.getRecordTypeInfosById();
        Set<Id> keySet = recordTypesMap.keySet();

        Integer errors = 0;
        for (FObjectOne__c objRecord : records) {
            if (!keySet.contains(objRecord.RecordTypeId)) {
                errors++;
            }
        }

        List<RecordType> recordTypes = [
            SELECT Id
            FROM RecordType
            WHERE SObjectType = 'FObjectOne__c' AND IsActive = TRUE
            LIMIT 1000
        ];
        Set<Id> valuesSet = (new Map<Id, RecordType>(recordTypes)).keySet();
        List<Id> values = new List<Id>(valuesSet);
        if (!ForceeaUtilityTest.isValidDistribution('RecordTypeId', values, records)) {
            errors++;
        }
        System.assertEquals(0, errors, 'random picklist - errors found');
    }

    @IsTest
    private static void randomPicklistVirtualField_valid_expectFailure() {
        FObject.setExceptionHandling('continue');

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition('$Test', 'random type(picklist)')
            .setDefinition(FObjectOne__c.TestPicklistA__c, 'copy field($Test)');
        obj.insertRecords(true);
        Test.stopTest();

        Integer errors = 0;
        String errorMessage = 'Invalid definition [random type(picklist)] of virtual field [$Test]';
        if (obj.getErrors().isEmpty() || obj.getErrors().get('$Test').get(0) != errorMessage) {
            errors ++;
        }
        System.assertEquals(0, errors, 'random picklist - errors found');
    }

    @IsTest
    private static void randomPicklistExcept_independentPicklistField_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType)
            .setDefinition(FObjectOne__c.TestPicklistA__c, 'random type(picklist) except(A1)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Set<String> picklistValuesSet = new Set<String>{
            'a0', 'a2', 'a3'
        };
        for (Integer counter = 0; counter < records.size(); counter++) {
            if (!picklistValuesSet.contains(records[counter].TestPicklistA__c)) {
                errors++;
            }
        }
        List<String> values = new List<String>(picklistValuesSet);
        if (!ForceeaUtilityTest.isValidDistribution('TestPicklistA__c', values, records)) {
            errors++;
        }
        System.assertEquals(0, errors, 'random picklist except - errors found');
    }

    @IsTest
    private static void randomPicklistExcept_dependentPicklistField_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(FObjectOne__c.TestPicklistC__c, 'random type(picklist) except(c1)');
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
        Set<String> picklistB0Mapping = new Set<String>{
            null
        };
        Set<String> picklistB1Mapping = new Set<String>{
            null
        };
        Set<String> picklistB2Mapping = new Set<String>{
            'c2'
        };
        Set<String> picklistB3Mapping = new Set<String>{
            'c2', 'c3'
        };

        // get created field values
        List<String> picklistAValues = new List<String>();
        List<String> picklistBValues = new List<String>();
        List<String> picklistCValues = new List<String>();
        for (FObjectOne__c objRecord : records) {
            picklistAValues.add(objRecord.TestPicklistA__c);
            picklistBValues.add(objRecord.TestPicklistB__c);
            picklistCValues.add(objRecord.TestPicklistC__c);
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

            if (picklistBValues[counter] == 'b0' && !picklistB0Mapping.contains(picklistCValues[counter])) {
                errors++;
            } else if (picklistBValues[counter] == 'b1' && !picklistB1Mapping.contains(picklistCValues[counter])) {
                errors++;
            } else if (picklistBValues[counter] == 'b2' && !picklistB2Mapping.contains(picklistCValues[counter])) {
                errors++;
            } else if (picklistBValues[counter] == 'b3' && !picklistB3Mapping.contains(picklistCValues[counter])) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'random picklist except - error found');
    }

    @IsTest
    private static void randomPicklistExcept_checkDefinitionsOfDependentPicklists_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(FObjectOne__c.RecordTypeId, 'static value(RecordTypeA)');
        obj.setDefinition(FObjectOne__c.TestPicklistC__c, 'random type(picklist) except(c1)');
        Test.stopTest();

        List<String> picklistADefinitions = obj.getAllDefinitions().get('TestPicklistA__c');
        List<String> picklistBDefinitions = obj.getAllDefinitions().get('TestPicklistB__c');

        Integer errors = 0;
        if (picklistADefinitions[0] != 'random type(picklist)') {
            errors += 1;
        }
        if (picklistBDefinitions[0] != 'random type(picklist)') {
            errors += 2;
        }
        System.assertEquals(0, errors, 'random picklist except - errors found');
    }

    @IsTest
    private static void randomPicklistExcept_noPicklistValues_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(FObjectOne__c.TestPicklistA__c, 'random type(picklist) except(a0,a1,a2,a3)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Set<String> picklistValuesSet = new Set<String>{
            'a0', 'a1', 'a2', 'a3'
        };
        for (Integer counter = 0; counter < records.size(); counter++) {
            if (picklistValuesSet.contains(records[counter].TestPicklistA__c)) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'random picklist except - error found');
    }

    @IsTest
    private static void randomPicklistExcept_onePicklistValue_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition(FObjectOne__c.TestPicklistA__c, 'random type(picklist) except(a0,a2,a3)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Set<String> picklistValuesSet = new Set<String>{
            'a1'
        };
        for (Integer counter = 0; counter < records.size(); counter++) {
            if (!picklistValuesSet.contains(records[counter].TestPicklistA__c)) {
                errors++;
            }
        }
        List<String> values = new List<String>(picklistValuesSet);
        if (!ForceeaUtilityTest.isValidDistribution('TestPicklistA__c', values, records)) {
            errors++;
        }
        System.assertEquals(0, errors, 'random picklist except - error found');
    }

    @IsTest
    private static void randomPicklistExcept_controllingFieldIsCheckbox_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestCheckbox__c, 'static value(true)')
            .setDefinition(FObjectOne__c.TestpicklistD__c, 'random type(picklist) except(d0, d1)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');

        List<Database.SaveResult> saveResults = obj.insertRecords(false);
        Test.stopTest();

        Integer errors = 0;
        for (Database.SaveResult sr : saveResults) {
            if (!sr.isSuccess()) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'random picklist except - errors found');
    }

    @IsTest
    private static void randomPicklistExcept_noRecordType_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition(FObjectOne__c.RecordTypeId,
            'random type(picklist) except(RecordTypeA, RecordTypeB, RecordTypeC)');

        String errorMessage = '';
        try {
            obj.insertRecords(true);
        } catch (Exception exp) {
            errorMessage = exp.getMessage();
        }
        Test.stopTest();

        Integer errors = 0;
        if (!errorMessage.contains('INVALID_CROSS_REFERENCE_KEY')) {
            errors++;
        }
        System.assertEquals(0, errors, 'random picklist except - errors found');
    }

    @IsTest
    private static void randomPicklistExcept_oneRecordType_expectSuccess() {
        Id recordTypeId =
            Schema.SObjectType.FObjectOne__c.getRecordTypeInfosByName().get('Record Type C').getRecordTypeId();

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition('RecordTypeId', 'random type(picklist) except(RecordTypeA, RecordTypeB)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        List<Database.SaveResult> saveResults = obj.insertRecords(false);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (Database.SaveResult sr : saveResults) {
            if (!sr.isSuccess()) {
                errors++;
            }
        }
        for (FObjectOne__c objRecord : records) {
            if (objRecord.RecordTypeId != recordTypeId) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'random picklist except - errors found');
    }

    @IsTest
    private static void randomPicklistExcept_manyRecordTypes_expectSuccess() {
        Id recordTypeId1 =
            Schema.SObjectType.FObjectOne__c.getRecordTypeInfosByName().get('Record Type A').getRecordTypeId();
        Id recordTypeId2 =
            Schema.SObjectType.FObjectOne__c.getRecordTypeInfosByName().get('Record Type B').getRecordTypeId();
        List<Id> arguments = new List<String>{
            recordTypeId1, recordTypeId2
        };
        Set<Id> recordTypeIdsSet = new Set<Id>(arguments);

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition('RecordTypeId', 'random type(picklist) except(RecordTypeC)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c objRecord : records) {
            if (!recordTypeIdsSet.contains(objRecord.RecordTypeId)) {
                errors++;
            }
        }
        if (!ForceeaUtilityTest.isValidDistribution('RecordTypeId', arguments, records)) {
            errors++;
        }
        System.assertEquals(0, errors, 'random picklist except - errors found');
    }

    @IsTest
    private static void itShouldInsertRtWithoutExceptions() {
        // GIVEN A template with FObjectOne__c and FObjectTwo__c
        String rtDevName2 = 'RecordTypeA';
        Forceea.Template template = getTemplateWithoutExceptions(rtDevName2);

        // WHEN We insert the template
        Test.startTest();
        template.insertRecords(true);
        Test.stopTest();

        // THEN The inserted records have the correct record type
        ForceeaUtilityTest.checkIfRt1IsAnyValid(template);
        ForceeaUtilityTest.checkIfRt2IsValid(template, rtDevName2);
    }

    @IsTest
    private static void itShouldInsertRtWithExceptions() {
        // GIVEN A template with FObjectOne__c and FObjectTwo__c
        String rtDevName2 = 'RecordTypeA';
        Forceea.Template template = getTemplateWithExceptions(rtDevName2);

        // WHEN We insert the template
        Test.startTest();
        template.insertRecords(true);
        Test.stopTest();

        // THEN The inserted records have the correct record type
        ForceeaUtilityTest.checkIfRt1IsAnyValid(template, new Set<String> { 'RecordTypeA', 'RecordTypeB' });
        ForceeaUtilityTest.checkIfRt2IsValid(template, rtDevName2);
    }

    /* HELPER METHODS */

    private static Forceea.Template getTemplateWithoutExceptions(String rtDevName2) {
        Forceea.Template result = ForceeaUtilityTest.getTemplate('rtDevName1', rtDevName2);

        result.getFObject(ForceeaUtilityTest.FOBJECT1)
            .setDefinition(FObjectOne__c.RecordTypeId, 'random type(picklist)');
        result.getFObject(ForceeaUtilityTest.FOBJECT2)
            .setDefinition(FObjectTwo__c.RecordTypeId, 'static value({@rtDevName2})');

        return result;
    }

    private static Forceea.Template getTemplateWithExceptions(String rtDevName2) {
        Forceea.Template result = ForceeaUtilityTest.getTemplate('rtDevName1', rtDevName2);

        result.getFObject(ForceeaUtilityTest.FOBJECT1)
            .setDefinition(FObjectOne__c.RecordTypeId, 'random type(picklist) except(RecordTypeC)');
        result.getFObject(ForceeaUtilityTest.FOBJECT2)
            .setDefinition(FObjectTwo__c.RecordTypeId, 'static value({@rtDevName2})');

        return result;
    }

}