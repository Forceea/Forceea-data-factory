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
public class FObjectFieldsTest {

    private static final String ONE = 'one';
    private static final String TWO = 'two';
    private static final String THREE = 'three';

    private static final String FOBJECT_ONES = 'FObjectOnes';
    private static final String FIELD_TEXT = 'TestText__c';
    private static final String INVALID_ID = 'xyz';

    private static final String DEF1 = 'random type(number) from(1) to(100) scale(0)';
    private static final String DEF2 = 'static value(test-)';
    private static final String DEF3 = 'serial type(number) from(1) step(1) scale(0)';
    private static final String DEF4 = 'random type(picklist)';
    private static final String DEF5 = 'static value(-)';
    private static final String DEF6 = 'static value(test)';
    private static final String DEF7 = 'static value(1234)';
    private static final String DEF8 = 'static value(xyz)';

    @IsTest
    private static void appendDefinitionsAfterId_invalidId_expectSuccess() {
        Forceea.Template template = template3();

        Test.startTest();

        template.getFObject(FOBJECT_ONES)
            .appendDefinitionsAfterId(INVALID_ID)
            .setDefinition(FObjectOne__c.TestText__c, DEF5);

        Test.stopTest();

        List<String> initialDefs = new List<String>();
        initialDefs.add('0 TestDecimal__c random type(number) from(1) to(100) scale(0)');
        initialDefs.add('1 TestText__c static value(test-)');
        initialDefs.add('2 TestText__c serial type(number) from(1) step(1) scale(0)');
        initialDefs.add('3 TestPicklistA__c random type(picklist)');
        initialDefs.add('4 TestText__c static value(-)');

        Assert.isTrue(defsAreValid(initialDefs, template), 'appendDefinition - errors found');
    }

    @IsTest
    private static void appendDefinitionsAfterId_afterNoDef_expectSuccess() {
        Forceea.Template template = template3();
        String signature = getSignature(2, FIELD_TEXT, DEF3);
        String defId = getDefIdFromSignature(template, FOBJECT_ONES, signature);

        Test.startTest();

        template.getFObject(FOBJECT_ONES)
            .appendDefinitionsAfterId(defId);

        Test.stopTest();

        List<String> initialDefs = new List<String>();
        initialDefs.add('0 TestDecimal__c random type(number) from(1) to(100) scale(0)');
        initialDefs.add('1 TestText__c static value(test-)');
        initialDefs.add('2 TestText__c serial type(number) from(1) step(1) scale(0)');
        initialDefs.add('3 TestPicklistA__c random type(picklist)');

        Assert.isTrue(defsAreValid(initialDefs, template), 'appendDefinition - errors found');
    }

    @IsTest
    private static void appendDefinitionsAfterId_after1Def_expectSuccess() {
        Forceea.Template template = template3();
        String signature = getSignature(2, FIELD_TEXT, DEF3);
        String defId = getDefIdFromSignature(template, FOBJECT_ONES, signature);

        Test.startTest();

        template.getFObject(FOBJECT_ONES)
            .appendDefinitionsAfterId(defId)
            .setDefinition(FObjectOne__c.TestText__c, DEF5);

        Test.stopTest();

        List<String> initialDefs = new List<String>();
        initialDefs.add('0 TestDecimal__c random type(number) from(1) to(100) scale(0)');
        initialDefs.add('1 TestText__c static value(test-)');
        initialDefs.add('2 TestText__c serial type(number) from(1) step(1) scale(0)');
        initialDefs.add('3 TestText__c static value(-)');
        initialDefs.add('4 TestPicklistA__c random type(picklist)');

        Assert.isTrue(defsAreValid(initialDefs, template), 'appendDefinition - errors found');
    }

    @IsTest
    private static void appendDefinitionsAfterId_after2Defs_expectSuccess() {
        Forceea.Template template = template3();
        String signature = getSignature(2, FIELD_TEXT, DEF3);
        String defId = getDefIdFromSignature(template, FOBJECT_ONES, signature);

        Test.startTest();

        template.getFObject(FOBJECT_ONES)
            .appendDefinitionsAfterId(defId)
            .setDefinition(FObjectOne__c.TestText__c, DEF5)
            .setDefinition(FObjectOne__c.TestText__c, DEF6);

        Test.stopTest();

        List<String> initialDefs = new List<String>();
        initialDefs.add('0 TestDecimal__c random type(number) from(1) to(100) scale(0)');
        initialDefs.add('1 TestText__c static value(test-)');
        initialDefs.add('2 TestText__c serial type(number) from(1) step(1) scale(0)');
        initialDefs.add('3 TestText__c static value(-)');
        initialDefs.add('4 TestText__c static value(test)');
        initialDefs.add('5 TestPicklistA__c random type(picklist)');

        Assert.isTrue(defsAreValid(initialDefs, template), 'appendDefinition - errors found');
    }

    @IsTest
    private static void appendDefinitions_withoutNewDef_expectSuccess() {
        Forceea.Template template = template3();

        Test.startTest();

        template.getFObject(FOBJECT_ONES)
            .replaceDefinitions(FObjectOne__c.TestText__c)
            .setDefinition(FObjectOne__c.TestText__c, DEF5)
            .setDefinition(FObjectOne__c.TestText__c, DEF6)
            .appendDefinitions(FIELD_TEXT)
            .setDefinition(FObjectOne__c.TestDate__c, 'random type(date) from(2021-12-1) to(2021-12-31)');

        Test.stopTest();

        List<String> initialDefs = new List<String>();
        initialDefs.add('0 TestDecimal__c ' + DEF1);
        initialDefs.add('1 TestText__c ' + DEF5);
        initialDefs.add('2 TestText__c ' + DEF6);
        initialDefs.add('3 TestPicklistA__c ' + DEF4);
        initialDefs.add('4 TestDate__c random type(date) from(2021-12-1) to(2021-12-31)');

        Assert.isTrue(defsAreValid(initialDefs, template), 'appendDefinition - errors found');
    }

    @IsTest
    private static void appendDefinitions_afterOtherDef_expectSuccess() {
        Forceea.Template template = template3();

        Test.startTest();

        template.getFObject(FOBJECT_ONES)
            .replaceDefinitions(FObjectOne__c.TestText__c)
            .setDefinition(FObjectOne__c.TestText__c, DEF5)
            .setDefinition(FObjectOne__c.TestText__c, DEF6)
            .appendDefinitions(FIELD_TEXT)
            .setDefinition(FObjectOne__c.TestDate__c, 'random type(date) from(2021-12-1) to(2021-12-31)')
            .setDefinition(FObjectOne__c.TestText__c, DEF7);

        Test.stopTest();

        List<String> initialDefs = new List<String>();
        initialDefs.add('0 TestDecimal__c ' + DEF1);
        initialDefs.add('1 TestText__c ' + DEF5);
        initialDefs.add('2 TestText__c ' + DEF6);
        initialDefs.add('3 TestPicklistA__c ' + DEF4);
        initialDefs.add('4 TestDate__c random type(date) from(2021-12-1) to(2021-12-31)');
        initialDefs.add('5 TestText__c ' + DEF7);

        Assert.isTrue(defsAreValid(initialDefs, template), 'appendDefinition - errors found');
    }

    @IsTest
    private static void appendDefinitions_1Field1Def_expectSuccess() {
        Forceea.Template template = template3();

        Test.startTest();

        template.getFObject(FOBJECT_ONES)
            .replaceDefinitions(FObjectOne__c.TestText__c)
            .setDefinition(FObjectOne__c.TestText__c, DEF5)
            .setDefinition(FObjectOne__c.TestText__c, DEF6)
            .appendDefinitions(FObjectOne__c.TestText__c)
            .setDefinition(FObjectOne__c.TestText__c, DEF7);

        Test.stopTest();

        List<String> initialDefs = new List<String>();
        initialDefs.add('0 TestDecimal__c ' + DEF1);
        initialDefs.add('1 TestText__c ' + DEF5);
        initialDefs.add('2 TestText__c ' + DEF6);
        initialDefs.add('3 TestText__c ' + DEF7);
        initialDefs.add('4 TestPicklistA__c ' + DEF4);

        Assert.isTrue(defsAreValid(initialDefs, template), 'appendDefinition - errors found');
    }

    @IsTest
    private static void appendDefinitions_1Fields2Defs_expectSuccess() {
        Forceea.Template template = template3();

        Test.startTest();

        template.getFObject(FOBJECT_ONES)
            .appendDefinitions(FIELD_TEXT)
            .setDefinition(FObjectOne__c.TestText__c, DEF7)
            .setDefinition(FObjectOne__c.TestText__c, DEF8);

        Test.stopTest();

        List<String> initialDefs = new List<String>();
        initialDefs.add('0 TestDecimal__c ' + DEF1);
        initialDefs.add('1 TestText__c ' + DEF2);
        initialDefs.add('2 TestText__c ' + DEF3);
        initialDefs.add('3 TestText__c ' + DEF7);
        initialDefs.add('4 TestText__c ' + DEF8);
        initialDefs.add('5 TestPicklistA__c ' + DEF4);

        Assert.isTrue(defsAreValid(initialDefs, template), 'appendDefinition - errors found');
    }

    @IsTest
    private static void removeAllDefinitions_declareNoDefinitions_expectSuccess() {
        Test.startTest();

        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.removeAllDefinitions();

        Test.stopTest();

        Assert.isTrue(obj.getAllDefinitions().isEmpty(), 'removeAllDefinitions - errors found');
    }

    @IsTest
    private static void removeAllDefinitions_declareSomeDefinitions_expectSuccess() {
        Test.startTest();

        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition(FObjectOne__c.TestText__c, DEF2)
            .setDefinition(FObjectOne__c.TestDecimal__c, DEF1)
            .setDefinition(FObjectOne__c.TestPicklistA__c, DEF4)
            .setDefinition(FObjectOne__c.TestPicklistB__c, DEF4)
            .removeAllDefinitions();

        Test.stopTest();

        Assert.isTrue(obj.getAllDefinitions().isEmpty(), 'removeAllDefinitions - errors found');
    }

    @IsTest
    private static void removeAllDefinitions_recordsAreClearedAfterNewDefinition_expectSuccess() {
        Forceea.Template template = template3();
        FObject obj = template.getFObject(FOBJECT_ONES);

        Test.startTest();

        Integer hash1 = obj.getRecords().hashCode();
        obj.removeAllDefinitions();
        obj = template3().getFObject(FOBJECT_ONES);
        Integer hash2 = obj.getRecords().hashCode();

        Test.stopTest();

        Assert.areNotEqual(hash1, hash2, 'removeAllDefinitions - errors found');
    }

    @IsTest
    private static void removeDefinitionWithId_invalidId_expectSuccess() {
        Forceea.Template template = template3();

        Test.startTest();

        template.getFObject(FOBJECT_ONES)
            .removeDefinitionWithId(INVALID_ID);

        Test.stopTest();

        List<String> initialDefs = new List<String>();
        initialDefs.add('0 TestDecimal__c ' + DEF1);
        initialDefs.add('1 TestText__c ' + DEF2);
        initialDefs.add('2 TestText__c ' + DEF3);
        initialDefs.add('3 TestPicklistA__c ' + DEF4);

        Assert.isTrue(defsAreValid(initialDefs, template), 'removeDefinitionWithId - errors found');
    }

    @IsTest
    private static void removeDefinitionWithId_1Def_expectSuccess() {
        Forceea.Template template = template3();
        FObject obj = template.getFObject(FOBJECT_ONES);
        String defId = getDefId(obj, 1, 'TestText__c', DEF2);

        Test.startTest();

        obj.removeDefinitionWithId(defId);

        Test.stopTest();

        List<String> initialDefs = new List<String>();
        initialDefs.add('0 TestDecimal__c ' + DEF1);
        initialDefs.add('1 TestText__c ' + DEF3);
        initialDefs.add('2 TestPicklistA__c ' + DEF4);

        Assert.isTrue(defsAreValid(initialDefs, template), 'removeDefinitionWithId - errors found');
    }

    @IsTest
    private static void removeDefinitionWithId_2Defs_expectSuccess() {
        Forceea.Template template = template3();
        FObject obj = template.getFObject(FOBJECT_ONES);
        String defId1 = getDefId(obj, 1, 'TestText__c', DEF2);
        String defId2 = getDefId(obj, 3, 'TestPicklistA__c', DEF4);

        Test.startTest();

        obj
            .removeDefinitionWithId(defId1)
            .removeDefinitionWithId(defId2);

        Test.stopTest();

        List<String> initialDefs = new List<String>();
        initialDefs.add('0 TestDecimal__c ' + DEF1);
        initialDefs.add('1 TestText__c ' + DEF3);

        Assert.isTrue(defsAreValid(initialDefs, template), 'removeDefinitionWithId - errors found');
    }

    @IsTest
    private static void removeDefinitions_declareNoDefinitions_expectSuccess() {
        Test.startTest();

        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj
            .setDefinition(FObjectOne__c.TestDecimal__c, DEF1)
            .setDefinition(FObjectOne__c.TestPicklistA__c, DEF4)
            .setDefinition(FObjectOne__c.TestPicklistB__c, DEF4)
            .removeDefinitions(FObjectOne__c.TestText__c);

        Test.stopTest();

        Boolean expectedResult = true;
        Boolean actualResult = obj.getDefinitions(FObjectOne__c.TestText__c).isEmpty();
        Assert.areEqual(expectedResult, actualResult, 'removeDefinitions - errors found');
    }

    @IsTest
    private static void removeDefinitions_invalidField_expectFailure() {
        Forceea.Template template = template3();
        FObject obj = template.getFObject(FOBJECT_ONES);

        Test.startTest();

        obj.removeDefinitions('TestTextX__c');

        Test.stopTest();

        Assert.areEqual('Invalid field [TestTextX__c] in method [removeDefinitions]',
            obj.getErrors().get('FObjectOne__c').get(0),
            'removeDefinitions - wrong error message for invalid field');
    }

    @IsTest
    private static void removeDefinitions_blankField_expectFailure() {
        Forceea.Template template = template3();
        FObject obj = template.getFObject(FOBJECT_ONES);

        Test.startTest();

        obj.removeDefinitions(' ');

        Test.stopTest();

        Assert.areEqual('Invalid field [] in method [removeDefinitions]',
            obj.getErrors().get('FObjectOne__c').get(0),
            'removeDefinitions - wrong error message for invalid field');
    }

    @IsTest
    private static void removeDefinitions_recordsAreClearedAfterNewDefinition_expectSuccess() {
        Forceea.Template template = template3();
        FObject obj = template.getFObject(FOBJECT_ONES);

        Test.startTest();

        Integer hash1 = obj.getRecords().hashCode();
        obj.removeDefinitions(FObjectOne__c.TestText__c);
        obj = template3().getFObject(FOBJECT_ONES);
        Integer hash2 = obj.getRecords().hashCode();

        Test.stopTest();

        Assert.areNotEqual(hash1, hash2, 'removeDefinitions - errors found');
    }

    @IsTest
    private static void getAllDefinitions_multipleChecks_expectSuccess() {
        Test.startTest();

        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestText__c, 'Random type(date) From(2017-01-01) To(2017-12-31)')
            .setDefinition(FObjectOne__c.TestText__c, 'static value(One)')
            .setDefinition(FObjectOne__c.TestDatetime__c, 'Random type(datetime) From(2017-01-01) To(2017-12-31)')
            .setDefinition(FObjectOne__c.TestDecimal__c, 'random type(number) From(1) To(100) Scale(0)')
            .setDefinition(FObjectOne__c.TestEmail__c, 'Random type(email)');
        Map<String, List<String>> definitions = obj.getAllDefinitions();

        Test.stopTest();

        List<String> fields = new List<String>(definitions.keySet());

        Integer errors = 0;
        if (definitions.size() != 4 || definitions.get(FIELD_TEXT).size() != 2) {
            errors += 1;
        }
        if (fields.size() != 4) {
            errors += 2;
        }
        if (fields[3] != 'TestEmail__c') {
            errors += 4;
        }
        if (definitions.get (FIELD_TEXT).get (1) != 'static value(One)') {
            errors += 8;
        }
        Assert.areEqual(0, errors, 'getAllDefinitions - errors found');
    }

    @IsTest
    private static void getPartitionFieldName_inInsert_expectSuccess() {
        Test.startTest();

        FObject obj = new FObject(FObjectOne__c.SObjectType, 20)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(test)')
            .setPartitionFieldName(FObjectOne__c.ForceeaPartition__c);

        Test.stopTest();

        Assert.areEqual(obj.getPartitionFieldName(), 'ForceeaPartition__c', 'getPartitionFieldName - errors found');
    }

    @IsTest
    private static void replaceDefinitions_noDefinitionsToReplace_expectSuccess() {
        Forceea.Template template = template1();
        List<String> initialDefs = getSignatures(FOBJECT_ONES, template);

        Test.startTest();

        template.getFObject(FOBJECT_ONES)
            .replaceDefinitions(FObjectOne__c.TestDate__c);

        Test.stopTest();

        List<String> finalDefs = getSignatures(FOBJECT_ONES, template);
        Assert.areEqual(initialDefs.hashCode(), finalDefs.hashCode(), 'replaceDefinitions - errors found');
    }

    @IsTest
    private static void replaceDefinitions_withoutNewDef_expectSuccess() {
        Forceea.Template template = template1();
        List<String> initialDefs = getSignatures(FOBJECT_ONES, template);

        Test.startTest();

        template.getFObject(FOBJECT_ONES)
            .replaceDefinitions(FObjectOne__c.TestLookup__c);

        Test.stopTest();

        List<String> finalDefs = getSignatures(FOBJECT_ONES, template);
        Assert.areEqual(initialDefs.hashCode(), finalDefs.hashCode(), 'replaceDefinitions - errors found');
    }

    @IsTest
    private static void replaceDefinitions_1Field1Def_expectSuccess() {
        Forceea.Template template = template1();
        List<String> initialDefs = getSignatures(FOBJECT_ONES, template);

        Test.startTest();

        template.getFObject(FOBJECT_ONES)
            .replaceDefinitions('TestLookup__c')
            .setDefinition(FObjectOne__c.TestLookup__c, 'serial lookup(FObjectTwo__c) mode(cyclical) source(forceea)')
            .setDefinition(FObjectOne__c.TestText__c, 'random type(number) from(1) to(100) scale(2)');

        Test.stopTest();

        List<String> finalDefs = getSignatures(FOBJECT_ONES, template);
        initialDefs.set (1, '1 TestLookup__c serial lookup(FObjectTwo__c) mode(cyclical) source(forceea)');
        initialDefs.add('4 TestText__c random type(number) from(1) to(100) scale(2)');

        Assert.areEqual(initialDefs.hashCode(), finalDefs.hashCode(), 'replaceDefinitions - errors found');
    }

    @IsTest
    private static void replaceDefinitions_1Field2Defs_expectSuccess() {
        Forceea.Template template = template1();
        List<String> initialDefs = getSignatures(FOBJECT_ONES, template);

        Test.startTest();

        template.getFObject(FOBJECT_ONES)
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(number) from(1) step(1) scale(0)')

            .replaceDefinitions(FObjectOne__c.TestTextRequired__c)
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test!)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'random type(number) from(1) to(100) scale(2)');

        Test.stopTest();

        List<String> finalDefs = getSignatures(FOBJECT_ONES, template);
        initialDefs.set (3, '3 TestTextRequired__c static value(test!)');
        initialDefs.add('4 TestTextRequired__c random type(number) from(1) to(100) scale(2)');
        initialDefs.add('5 TestText__c serial type(number) from(1) step(1) scale(0)');

        Assert.areEqual(initialDefs.hashCode(), finalDefs.hashCode(), 'replaceDefinitions - errors found');
    }

    @IsTest
    private static void replaceDefinitions_Field3Defs_expectSuccess() {
        Forceea.Template template = template1();
        List<String> initialDefs = getSignatures(FOBJECT_ONES, template);

        Test.startTest();

        template.getFObject(FOBJECT_ONES)
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(number) from(1) step(1) scale(0)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test1)')

            .replaceDefinitions(FObjectOne__c.TestTextRequired__c)
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test1)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'random type(number) from(1) to(100) scale(2)')

            .setDefinition(FObjectOne__c.TestText__c, 'random type(number) from(1) to(100) scale(2)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test2)');

        Test.stopTest();

        List<String> finalDefs = getSignatures(FOBJECT_ONES, template);
        initialDefs.set (3, '3 TestTextRequired__c static value(test1)');
        initialDefs.add('4 TestTextRequired__c random type(number) from(1) to(100) scale(2)');
        initialDefs.add('5 TestText__c serial type(number) from(1) step(1) scale(0)');
        initialDefs.add('6 TestText__c random type(number) from(1) to(100) scale(2)');
        initialDefs.add('7 TestTextRequired__c static value(test2)');

        Assert.areEqual(initialDefs.hashCode(), finalDefs.hashCode(), 'replaceDefinitions - errors found');
    }

    @IsTest
    private static void replaceDefinitions_2Fields2Defs_expectSuccess() {
        Forceea.Template template = template1();
        List<String> initialDefs = getSignatures(FOBJECT_ONES, template);

        Test.startTest();
        template.getFObject(FOBJECT_ONES)
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(number) from(1) step(1) scale(0)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test1)')

            .replaceDefinitions(FObjectOne__c.TestTextRequired__c)

            .replaceDefinitions(FObjectOne__c.TestText__c)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(test1)')
            .setDefinition(FObjectOne__c.TestText__c, 'static value(test2)')

            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test2)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test3)');
        Test.stopTest();

        List<String> finalDefs = getSignatures(FOBJECT_ONES, template);
        initialDefs.set (2, '2 TestText__c static value(test1)');
        initialDefs.set (3, '3 TestText__c static value(test2)');
        initialDefs.add('4 TestTextRequired__c static value(test)');
        initialDefs.add('5 TestTextRequired__c static value(test1)');
        initialDefs.add('6 TestTextRequired__c static value(test2)');
        initialDefs.add('7 TestTextRequired__c static value(test3)');

        Boolean conditionsAreValid = initialDefs.hashCode() == finalDefs.hashCode();
        Assert.isTrue(conditionsAreValid, 'replaceDefinitions - errors found');
    }

    @IsTest
    private static void replaceDefinitions_2FieldsOtherDef_expectSuccess() {
        Forceea.Template template = template1();
        List<String> initialDefs = getSignatures(FOBJECT_ONES, template);

        Test.startTest();
        template.getFObject(FOBJECT_ONES)
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(number) from(1) step(1) scale(0)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test1)')

            .replaceDefinitions(FObjectOne__c.TestTextRequired__c)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(test1)')

            .replaceDefinitions(FObjectOne__c.TestText__c)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(test2)')

            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test2)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test3)');
        Test.stopTest();

        List<String> finalDefs = getSignatures(FOBJECT_ONES, template);
        initialDefs.set (2, '2 TestText__c static value(test2)');
        initialDefs.set (3, '3 TestTextRequired__c static value(test)');
        initialDefs.add('4 TestTextRequired__c static value(test1)');
        initialDefs.add('5 TestTextRequired__c static value(test2)');
        initialDefs.add('6 TestTextRequired__c static value(test3)');

        Assert.areEqual(initialDefs.hashCode(), finalDefs.hashCode(), 'replaceDefinitions - errors found');
    }

    @IsTest
    private static void replaceDefinitions_2Fields4Defs_expectSuccess() {
        Forceea.Template template = template1();
        List<String> initialDefs = getSignatures(FOBJECT_ONES, template);

        Test.startTest();

        template.getFObject(FOBJECT_ONES)
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(number) from(1) step(1) scale(0)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test1)')

            .replaceDefinitions(FObjectOne__c.TestTextRequired__c)
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test1)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test2)')

            .replaceDefinitions(FObjectOne__c.TestText__c)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(test1)')
            .setDefinition(FObjectOne__c.TestText__c, 'static value(test2)');

        Test.stopTest();

        List<String> finalDefs = getSignatures(FOBJECT_ONES, template);
        initialDefs.set(2, '2 TestText__c static value(test1)');
        initialDefs.set(3, '3 TestText__c static value(test2)');
        initialDefs.add('4 TestTextRequired__c static value(test1)');
        initialDefs.add('5 TestTextRequired__c static value(test2)');

        Assert.areEqual(initialDefs.hashCode(), finalDefs.hashCode(), 'replaceDefinitions - errors found');
    }

    @IsTest
    private static void replaceDefinitions_simple_expectSuccess() {
        Forceea.Template template = template1();
        List<String> initialDefs = getSignatures(FOBJECT_ONES, template);

        Test.startTest();

        template.getFObject(FOBJECT_ONES)
            .replaceDefinitions(FObjectOne__c.TestText__c)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(test1)')
            .setDefinition(FObjectOne__c.TestText__c, 'static value(test2)');

        Test.stopTest();

        List<String> finalDefs = getSignatures(FOBJECT_ONES, template);
        initialDefs.set(2, '2 TestText__c static value(test1)');
        initialDefs.set(3, '3 TestText__c static value(test2)');
        initialDefs.add('4 TestTextRequired__c static value(test)');

        Assert.areEqual(initialDefs.hashCode(), finalDefs.hashCode(), 'replaceDefinitions - errors found');
    }

    @IsTest
    private static void replaceDefinitions_virtualField_expectSuccess() {
        Forceea.Template template = template1();
        List<String> initialDefs = getSignatures(FOBJECT_ONES, template);

        Test.startTest();

        template.getFObject(FOBJECT_ONES)
            .setDefinition('$MyVirtualField', 'static value(test)')
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(number) from(1) step(1) scale(0)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test1)')

            .replaceDefinitions(FObjectOne__c.TestTextRequired__c)

            .replaceDefinitions('$MyVirtualField')
            .setDefinition('$MyVirtualField', 'static value(virtual)')

            .replaceDefinitions(FObjectOne__c.TestText__c)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(test1)')
            .setDefinition(FObjectOne__c.TestText__c, 'static value(test2)')

            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test2)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test3)');

        Test.stopTest();

        List<String> finalDefs = getSignatures(FOBJECT_ONES, template);
        initialDefs.set(2, '2 TestText__c static value(test1)');
        initialDefs.set(3, '3 TestText__c static value(test2)');
        initialDefs.add('4 TestTextRequired__c static value(test)');
        initialDefs.add('5 $MyVirtualField static value(virtual)');
        initialDefs.add('6 TestTextRequired__c static value(test1)');
        initialDefs.add('7 TestTextRequired__c static value(test2)');
        initialDefs.add('8 TestTextRequired__c static value(test3)');

        Assert.areEqual(initialDefs.hashCode(), finalDefs.hashCode(), 'replaceDefinitions - errors found');
    }

    @IsTest
    private static void replaceDefinitionWithId_noDef_expectSuccess() {
        Forceea.Template template = template3();
        String signature = getSignature(2, FIELD_TEXT, DEF3);
        String defId = getDefIdFromSignature(template, FOBJECT_ONES, signature);

        Test.startTest();

        template.getFObject(FOBJECT_ONES)
            .replaceDefinitionWithId(defId);

        Test.stopTest();

        List<String> initialDefs = new List<String>();
        initialDefs.add('0 TestDecimal__c ' + DEF1);
        initialDefs.add('1 TestText__c ' + DEF2);
        initialDefs.add('2 TestText__c ' + DEF3);
        initialDefs.add('3 TestPicklistA__c ' + DEF4);

        Assert.isTrue(defsAreValid(initialDefs, template), 'replaceDefinitionWithId - errors found');
    }

    @IsTest
    private static void replaceDefinitionWithId_1Def_expectSuccess() {
        Forceea.Template template = template3();
        String signature = getSignature(2, FIELD_TEXT, DEF3);
        String defId = getDefIdFromSignature(template, FOBJECT_ONES, signature);

        Test.startTest();

        template.getFObject(FOBJECT_ONES)
            .replaceDefinitionWithId(defId)
            .setDefinition(FObjectOne__c.TestText__c, DEF5);

        Test.stopTest();

        List<String> initialDefs = new List<String>();
        initialDefs.add('0 TestDecimal__c ' + DEF1);
        initialDefs.add('1 TestText__c ' + DEF2);
        initialDefs.add('2 TestText__c ' + DEF5);
        initialDefs.add('3 TestPicklistA__c ' + DEF4);

        Assert.isTrue(defsAreValid(initialDefs, template), 'replaceDefinitionWithId - errors found');
    }

    @IsTest
    private static void replaceDefinitionWithId_1DefAfterOther_expectSuccess() {
        Forceea.Template template = template3();
        String signature = getSignature(2, FIELD_TEXT, DEF3);
        String defId = getDefIdFromSignature(template, FOBJECT_ONES, signature);

        Test.startTest();

        template.getFObject(FOBJECT_ONES)
            .replaceDefinitionWithId(defId)
            .setDefinition(FObjectOne__c.TestText__c, DEF4)
            .setDefinition(FObjectOne__c.TestTextRequired__c, DEF4)
            .setDefinition(FObjectOne__c.TestText__c, DEF2);

        Test.stopTest();

        List<String> initialDefs = new List<String>();
        initialDefs.add('0 TestDecimal__c ' + DEF1);
        initialDefs.add('1 TestText__c ' + DEF2);
        initialDefs.add('2 TestText__c ' + DEF4);
        initialDefs.add('3 TestPicklistA__c ' + DEF4);
        initialDefs.add('4 TestTextRequired__c ' + DEF4);
        initialDefs.add('5 TestText__c ' + DEF2);

        Assert.isTrue(defsAreValid(initialDefs, template), 'replaceDefinitionWithId - errors found');
    }

    @IsTest
    private static void replaceDefinitionWithId_2Defs_expectSuccess() {
        Forceea.Template template = template3();
        String signature = getSignature(2, FIELD_TEXT, DEF3);
        String defId = getDefIdFromSignature(template, FOBJECT_ONES, signature);

        Test.startTest();

        template.getFObject(FOBJECT_ONES)
            .replaceDefinitionWithId(defId)
            .setDefinition(FObjectOne__c.TestText__c, DEF5)
            .setDefinition(FObjectOne__c.TestText__c, DEF6);

        Test.stopTest();

        List<String> initialDefs = new List<String>();
        initialDefs.add('0 TestDecimal__c ' + DEF1);
        initialDefs.add('1 TestText__c ' + DEF2);
        initialDefs.add('2 TestText__c ' + DEF5);
        initialDefs.add('3 TestText__c ' + DEF6);
        initialDefs.add('4 TestPicklistA__c ' + DEF4);

        Assert.isTrue(defsAreValid(initialDefs, template), 'replaceDefinitionWithId - errors found');
    }

    @IsTest
    private static void replaceDefinitionWithId_simple_expectSuccess() {
        Forceea.Template template = template1();
        List<String> initialDefs = getSignatures(FOBJECT_ONES, template);

        Test.startTest();

        FObject obj = template.getFObject(FOBJECT_ONES);
        obj
            .setDefinition(FObjectOne__c.TestText__c, 'static value(test3)');

        String definitionId = getDefIdFromSignature(obj, initialDefs.get(2));

        obj
            .replaceDefinitionWithId(definitionId)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(test1)')
            .setDefinition(FObjectOne__c.TestText__c, 'static value(test2)');

        Test.stopTest();

        List<String> finalDefs = getSignatures(FOBJECT_ONES, template);
        initialDefs.set(2, '2 TestText__c static value(test1)');
        initialDefs.set(3, '3 TestText__c static value(test2)');
        initialDefs.add('4 TestTextRequired__c static value(test)');
        initialDefs.add('5 TestText__c static value(test3)');

        Assert.areEqual(initialDefs.hashCode(), finalDefs.hashCode(), 'replaceDefinitionWithId - errors found');
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

        Assert.isTrue(ForceeaUtilityTest.updateIsValidForCreatedRecords(records, ONE),
            'updateFields - errors found');
    }

    @IsTest
    private static void updateFields_create1Def_forUpdate1Def_updateCreated_expectSuccess() {
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(one)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();

        Test.startTest();

        String updatedValue = TWO;
        obj
            .setNumberOfRecords(1)
            .setDefinitionForUpdate(FObjectOne__c.TestText__c, 'static value(' + updatedValue + ')')
            .updateFields();

        Test.stopTest();

        Assert.isTrue(ForceeaUtilityTest.updateIsValidForCreatedRecords(records, updatedValue),
            'updateFields - errors found');
    }

    @IsTest
    private static void updateFields_create1Def_forUpdate2Def_updateCreated_expectSuccess() {
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(one)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();

        Test.startTest();

        String updatedValue = TWO;
        obj
            .setNumberOfRecords(1)
            .setNumberOfNextRecord(1)
            .setDefinitionForUpdate(FObjectOne__c.TestText__c, 'static value(' + updatedValue + ')')
            .setDefinitionForUpdate(FObjectOne__c.TestText__c, 'serial type(number) from(1) step(1) scale(0)')
            .updateFields();

        Test.stopTest();

        Assert.isTrue(ForceeaUtilityTest.updateIsValidForCreatedRecords(records, updatedValue),
            'updateFields - errors found');
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

        Assert.isTrue(ForceeaUtilityTest.updateIsValidForInsertedRecords(groupName, ONE),
            'updateFields - errors found');
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

        Assert.isTrue(ForceeaUtilityTest.updateIsValidForInsertedRecords(groupName, ONE),
            'updateFields - errors found');
    }

    @IsTest
    private static void updateFields_insert1Def_forUpdate1Def_updateGlobal_expectSuccess() {
        String groupName = '';

        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(one)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj.insertRecords(true, groupName);

        Test.startTest();

        String updatedValue = TWO;
        obj
            .setNumberOfRecords(1)
            .setDefinitionForUpdate(FObjectOne__c.TestText__c, 'static value(' + updatedValue + ')')
            .updateFields(groupName);

        Test.stopTest();

        Assert.isTrue(ForceeaUtilityTest.updateIsValidForInsertedRecords(groupName, updatedValue),
            'updateFields - errors found');
    }

    @IsTest
    private static void updateFields_insert1Def_forUpdate1Def_updateGroup_expectSuccess() {
        String groupName = 'MyGroup';

        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(one)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj.insertRecords(true, groupName);

        Test.startTest();

        String updatedValue = TWO;
        obj
            .setNumberOfRecords(1)
            .setDefinitionForUpdate(FObjectOne__c.TestText__c, 'static value(' + updatedValue + ')')
            .updateFields(groupName);

        Test.stopTest();

        Assert.isTrue(ForceeaUtilityTest.updateIsValidForInsertedRecords(groupName, updatedValue),
            'updateFields - errors found');
    }

    @IsTest
    private static void updateFields_insert1Def_forUpdate2Def_updateGlobal_expectSuccess() {
        String groupName;

        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(one)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj.insertRecords(true, groupName);

        Test.startTest();

        String updatedValue = TWO;
        obj
            .setNumberOfRecords(1)
            .setNumberOfNextRecord(1)
            .setDefinitionForUpdate(FObjectOne__c.TestText__c, 'static value(' + updatedValue + ')')
            .setDefinitionForUpdate(FObjectOne__c.TestText__c, 'serial type(number) from(1) step(1) scale(0)')
            .updateFields(groupName);

        Test.stopTest();

        Assert.isTrue(ForceeaUtilityTest.updateIsValidForInsertedRecords(groupName, updatedValue),
            'updateFields - errors found');
    }

    @IsTest
    private static void updateFields_insert1Def_forUpdate2Def_updateGroup_expectSuccess() {
        String groupName = 'MyGroup';

        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(one)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj.insertRecords(true, groupName);

        Test.startTest();

        String updatedValue = TWO;
        obj
            .setNumberOfRecords(1)
            .setNumberOfNextRecord(1)
            .setDefinitionForUpdate(FObjectOne__c.TestText__c, 'static value(' + updatedValue + ')')
            .setDefinitionForUpdate(FObjectOne__c.TestText__c, 'serial type(number) from(1) step(1) scale(0)')
            .updateFields(groupName);

        Test.stopTest();

        Assert.isTrue(ForceeaUtilityTest.updateIsValidForInsertedRecords(groupName, updatedValue),
            'updateFields - errors found');
    }

    @IsTest
    private static void updateFields_insert1Def_forUpdate2Updates_updateGlobal_expectSuccess() {
        String groupName = '';

        String updatedValue = ONE;
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(' + updatedValue + ')')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj.insertRecords(true, groupName);

        Test.startTest();

        updatedValue = TWO;
        obj
            .setNumberOfRecords(1)
            .setNumberOfNextRecord(1)
            .setDefinitionForUpdate(FObjectOne__c.TestText__c, 'static value(' + updatedValue + ')')
            .setDefinitionForUpdate(FObjectOne__c.TestInteger__c, 'serial type(number) from(1) step(1) scale(0)')
            .updateFields(groupName);
        updatedValue = THREE;
        obj
            .setDefinitionForUpdate(FObjectOne__c.TestText__c, 'static value(' + updatedValue + ')')
            .setDefinitionForUpdate(FObjectOne__c.TestInteger__c, 'serial type(number) from(1) step(1) scale(0)')
            .updateFields(groupName);

        Test.stopTest();

        Assert.isTrue(ForceeaUtilityTest.updateIsValidForInsertedRecords(groupName, updatedValue),
            'updateFields - errors found');
    }

    @IsTest
    private static void updateFields_insert1Def_forUpdate2Updates_updateGroup_expectSuccess() {
        String groupName = 'MyGroup';

        String updatedValue = ONE;
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(' + updatedValue + ')')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj.insertRecords(true, groupName);

        Test.startTest();

        updatedValue = TWO;
        obj
            .setNumberOfRecords(1)
            .setNumberOfNextRecord(1)
            .setDefinitionForUpdate(FObjectOne__c.TestText__c, 'static value(' + updatedValue + ')')
            .setDefinitionForUpdate(FObjectOne__c.TestInteger__c, 'serial type(number) from(1) step(1) scale(0)')
            .updateFields(groupName);
        updatedValue = THREE;
        obj
            .setDefinitionForUpdate(FObjectOne__c.TestText__c, 'static value(' + updatedValue + ')')
            .setDefinitionForUpdate(FObjectOne__c.TestInteger__c, 'serial type(number) from(1) step(1) scale(0)')
            .updateFields(groupName);

        Test.stopTest();

        Assert.isTrue(ForceeaUtilityTest.updateIsValidForInsertedRecords(groupName, updatedValue),
            'updateFields - errors found');
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

        Assert.areEqual(0, errors, 'updateFields - errors found');
    }

    @IsTest
    private static void updateFields_insert1Def_forUpdate1DefVirtualField_updateGlobal_expectSuccess() {
        String groupName = '';
        String updatedValue = ONE;

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

        Assert.isTrue(ForceeaUtilityTest.updateIsValidForInsertedRecords(groupName, updatedValue),
            'updateFields - errors found');
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

        Assert.areEqual(0, errors, 'updateFields - errors found');
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

        Assert.areEqual(0, errors, 'updateFields - errors found');
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
            .setVariable('updatedValue', TWO)

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

        Assert.areEqual(0, errors, 'updateFields - errors found');
    }

    @IsTest
    private static void virtualFieldIsValid_firstCharIsNotDollar_expectFailure() {
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);

        Test.startTest();

        Boolean isValid = obj.virtualFieldIsValid('TestTest');

        Test.stopTest();

        Assert.isFalse(isValid, 'virtualField - errors found');
    }

    @IsTest
    private static void virtualFieldIsValid_isBlank_expectFailure() {
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);

        Test.startTest();

        Boolean isValid = obj.virtualFieldIsValid(' ');

        Test.stopTest();

        Assert.isFalse(isValid, 'virtualField - errors found');
    }

    @IsTest
    private static void virtualFieldIsValid_containsWhiteSpace_expectFailure() {
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);

        Test.startTest();

        Boolean isValid = obj.virtualFieldIsValid('$Test test');

        Test.stopTest();

        Assert.isFalse(isValid, 'virtualField - errors found');
    }

    @IsTest
    private static void virtualFieldIsValid_hasIllegalCharacters_expectFailure() {
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);

        Test.startTest();

        Boolean isValid = obj.virtualFieldIsValid('$Test2test');

        Test.stopTest();

        Assert.isFalse(isValid, 'virtualField - errors found');
    }

    /* TEMPLATES */

    private static Forceea.Template template1() {
        return new Forceea.Template()
            .add(template2())
            .add(FOBJECT_ONES, new FObject(FObjectOne__c.SObjectType, 20)
                .setDefinition(FObjectOne__c.TestIntegerUnique__c, 'serial type(number) from(1) step(1) scale(0)')
                .setDefinition(FObjectOne__c.TestLookup__c, 'random lookup(FObjectTwo__c) source(forceea)')
                .setDefinition(FObjectOne__c.TestText__c,
                    'random type(string) minLength(10) maxLength(30) startWith(lower) include(lower,upper,digit)')
                .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            );
    }

    private static Forceea.Template template2() {
        return new Forceea.Template()
            .add('FObjectTwos', new FObject(FObjectTwo__c.SObjectType, 10)
                .setDefinition(FObjectTwo__c.TestText__c,
                    'random type(number) from(10) to(100) scale(0)')
                .setDefinition(FObjectTwo__c.TestTextUnique__c,
                    'serial type(number) from(1) step(1) scale(0)')
                .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)')
            );
    }

    private static Forceea.Template template3() {
        return new Forceea.Template()
            .add(FOBJECT_ONES, new FObject(FObjectOne__c.SObjectType, 10)
                .setDefinition(FObjectOne__c.TestDecimal__c, DEF1)
                .setDefinition(FObjectOne__c.TestText__c, DEF2)
                .setDefinition(FObjectOne__c.TestText__c, DEF3)
                .setDefinition(FObjectOne__c.TestPicklistA__c, DEF4)
            );
    }

    /* UTILITY METHODS */

    private static Boolean defsAreValid(List<String> initialDefs, Forceea.Template template) {
        return initialDefs.hashCode() == getSignatures(FOBJECT_ONES, template).hashCode();
    }

    private static String getDefId(
        FObject obj, Integer index, String fieldApiName, String defString) {
        String indexedDefString = getSignature(index, fieldApiName, defString);

        return getDefIdFromSignature(obj, indexedDefString);
    }

    private static String getDefIdFromSignature(Forceea.Template template, String key, String signature) {
        String result = '';

        Integer index = 0;
        for (ForceeaDefinition def : template.getFObject(key).definitions) {
            if (signature.equalsIgnoreCase(getSignature(index, def))) {
                result = def.definitionId;
                break;
            }
            index++;
        }

        return result;
    }

    private static String getDefIdFromSignature(FObject obj, String signature) {
        String result = '';

        Integer index = 0;
        for (ForceeaDefinition def : obj.definitions) {
            if (signature.equalsIgnoreCase(getSignature(index, def))) {
                result = def.definitionId;
                break;
            }
            index++;
        }

        return result;
    }

    private static String getSignature(Integer index, ForceeaDefinition def) {
        return String.valueOf(index) + ' ' + def.fieldApiName + ' ' + def.definitionString;
    }

    private static String getSignature(Integer index, String fieldApiName, String defString) {
        return String.valueOf(index) + ' ' + fieldApiName + ' ' + defString;
    }

    private static List<String> getSignatures(String key, Forceea.Template template) {
        List<String> results = new List<String>();

        Integer index = 0;
        for (ForceeaDefinition def : template.getFObject(key).definitions) {
            String definition = getSignature(index, def);
            results.add(definition);
            index++;
        }

        return results;
    }

}