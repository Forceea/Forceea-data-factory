/*
  Forceea data factory (v2.8.0)
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
public class FObjectFieldsTest {

    @IsTest
    private static void appendDefinitionsAfterId_invalidId_expectSuccess() {
        Map<String, FObject> template = template1();
        List<String> initialDefs = getDefinitionPositions('FObjectOnes', template);

        Test.startTest();
        template.get('FObjectOnes')
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(number) from(1) step(1) scale(0)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test1)')

            .appendDefinitionsAfterId('nRdGs2')
            .setDefinition(FObjectOne__c.TestText__c, 'static value(test2)');
        Test.stopTest();

        List<String> finalDefs = getDefinitionPositions('FObjectOnes', template);
        initialDefs.add('4 TestText__c serial type(number) from(1) step(1) scale(0)');
        initialDefs.add('5 TestTextRequired__c static value(test1)');
        initialDefs.add('6 TestText__c static value(test2)');

        Boolean conditionsAreValid = initialDefs.hashCode() == finalDefs.hashCode();
        System.assert(conditionsAreValid, 'appendDefinition - errors found');
    }

    @IsTest
    private static void appendDefinitionsAfterId_afterNoDef_expectSuccess() {
        Map<String, FObject> template = template1();
        List<String> initialDefs = getDefinitionPositions('FObjectOnes', template);

        Test.startTest();
        template.get('FObjectOnes')
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(number) from(1) step(1) scale(0)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test1)')

            .appendDefinitionsAfterId('nRNOG1'); // the 1st TestText__c definition
        Test.stopTest();

        List<String> finalDefs = getDefinitionPositions('FObjectOnes', template);
        initialDefs.set(3, '3 TestTextRequired__c static value(test)');
        initialDefs.add('4 TestText__c serial type(number) from(1) step(1) scale(0)');
        initialDefs.add('5 TestTextRequired__c static value(test1)');

        Boolean conditionsAreValid = initialDefs.hashCode() == finalDefs.hashCode();
        System.assert(conditionsAreValid, 'appendDefinition - errors found');
    }

    @IsTest
    private static void appendDefinitionsAfterId_after1Def_expectSuccess() {
        Map<String, FObject> template = template1();
        List<String> initialDefs = getDefinitionPositions('FObjectOnes', template);

        Test.startTest();
        template.get('FObjectOnes')
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(number) from(1) step(1) scale(0)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test1)')

            .appendDefinitionsAfterId('nRNOG1') // the 1st TestText__c definition
            .setDefinition(FObjectOne__c.TestText__c, 'static value(test2)');
        Test.stopTest();

        List<String> finalDefs = getDefinitionPositions('FObjectOnes', template);
        initialDefs.set(3, '3 TestText__c static value(test2)');
        initialDefs.add('4 TestTextRequired__c static value(test)');
        initialDefs.add('5 TestText__c serial type(number) from(1) step(1) scale(0)');
        initialDefs.add('6 TestTextRequired__c static value(test1)');

        Boolean conditionsAreValid = initialDefs.hashCode() == finalDefs.hashCode();
        System.assert(conditionsAreValid, 'appendDefinition - errors found');
    }

    @IsTest
    private static void appendDefinitionsAfterId_after2Defs_expectSuccess() {
        Map<String, FObject> template = template1();
        List<String> initialDefs = getDefinitionPositions('FObjectOnes', template);

        Test.startTest();
        template.get('FObjectOnes')
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(number) from(1) step(1) scale(0)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test1)')

            .appendDefinitionsAfterId('nRNOG1') // the 1st TestText__c definition
            .setDefinition(FObjectOne__c.TestText__c, 'static value(test2)')
            .setDefinition(FObjectOne__c.TestText__c, 'static value(test3)');
        Test.stopTest();

        List<String> finalDefs = getDefinitionPositions('FObjectOnes', template);
        initialDefs.set(3, '3 TestText__c static value(test2)');
        initialDefs.add('4 TestText__c static value(test3)');
        initialDefs.add('5 TestTextRequired__c static value(test)');
        initialDefs.add('6 TestText__c serial type(number) from(1) step(1) scale(0)');
        initialDefs.add('7 TestTextRequired__c static value(test1)');

        Boolean conditionsAreValid = initialDefs.hashCode() == finalDefs.hashCode();
        System.assert(conditionsAreValid, 'appendDefinition - errors found');
    }

    @IsTest
    private static void appendDefinitions_withoutNewDef_expectSuccess() {
        Map<String, FObject> template = template1();
        List<String> initialDefs = getDefinitionPositions('FObjectOnes', template);

        Test.startTest();
        template.get('FObjectOnes')
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(number) from(1) step(1) scale(0)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test1)')

            .replaceDefinitions(FObjectOne__c.TestText__c)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(test1)')
            .setDefinition(FObjectOne__c.TestText__c, 'static value(test2)')

            .appendDefinitions('TestText__c')
            .setDefinition(FObjectOne__c.TestDate__c, 'random type(date) from(2021-12-1) to(2021-12-31)');
        Test.stopTest();

        List<String> finalDefs = getDefinitionPositions('FObjectOnes', template);
        initialDefs.set(2, '2 TestText__c static value(test1)');
        initialDefs.set(3, '3 TestText__c static value(test2)');
        initialDefs.add('4 TestTextRequired__c static value(test)');
        initialDefs.add('5 TestTextRequired__c static value(test1)');
        initialDefs.add('6 TestDate__c random type(date) from(2021-12-1) to(2021-12-31)');

        Boolean conditionsAreValid = initialDefs.hashCode() == finalDefs.hashCode();
        System.assert(conditionsAreValid, 'appendDefinitions - errors found');
    }

    @IsTest
    private static void appendDefinitions_afterOtherDef_expectSuccess() {
        Map<String, FObject> template = template1();
        List<String> initialDefs = getDefinitionPositions('FObjectOnes', template);

        Test.startTest();
        template.get('FObjectOnes')
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(number) from(1) step(1) scale(0)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test1)')

            .replaceDefinitions(FObjectOne__c.TestText__c)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(test1)')
            .setDefinition(FObjectOne__c.TestText__c, 'static value(test2)')

            .appendDefinitions(FObjectOne__c.TestText__c)
            .setDefinition(FObjectOne__c.TestDate__c, 'random type(date) from(2021-12-1) to(2021-12-31)')
            .setDefinition(FObjectOne__c.TestText__c, 'static value(test2)');
        Test.stopTest();

        List<String> finalDefs = getDefinitionPositions('FObjectOnes', template);
        initialDefs.set(2, '2 TestText__c static value(test1)');
        initialDefs.set(3, '3 TestText__c static value(test2)');
        initialDefs.add('4 TestTextRequired__c static value(test)');
        initialDefs.add('5 TestTextRequired__c static value(test1)');
        initialDefs.add('6 TestDate__c random type(date) from(2021-12-1) to(2021-12-31)');
        initialDefs.add('7 TestText__c static value(test2)');

        Boolean conditionsAreValid = initialDefs.hashCode() == finalDefs.hashCode();
        System.assert(conditionsAreValid, 'appendDefinitions - errors found');
    }

    @IsTest
    private static void appendDefinitions_1Fields1Def_expectSuccess() {
        Map<String, FObject> template = template1();
        List<String> initialDefs = getDefinitionPositions('FObjectOnes', template);

        Test.startTest();
        template.get('FObjectOnes')
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(number) from(1) step(1) scale(0)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test1)')

            .replaceDefinitions(FObjectOne__c.TestText__c)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(test1)')
            .setDefinition(FObjectOne__c.TestText__c, 'static value(test2)')

            .appendDefinitions(FObjectOne__c.TestText__c)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(test3)');
        Test.stopTest();

        List<String> finalDefs = getDefinitionPositions('FObjectOnes', template);
        initialDefs.set(2, '2 TestText__c static value(test1)');
        initialDefs.set(3, '3 TestText__c static value(test2)');
        initialDefs.add('4 TestText__c static value(test3)');
        initialDefs.add('5 TestTextRequired__c static value(test)');
        initialDefs.add('6 TestTextRequired__c static value(test1)');

        Boolean conditionsAreValid = initialDefs.hashCode() == finalDefs.hashCode();
        System.assert(conditionsAreValid, 'appendDefinitions - errors found');
    }

    @IsTest
    private static void appendDefinitions_1Fields2Defs_expectSuccess() {
        Map<String, FObject> template = template1();
        List<String> initialDefs = getDefinitionPositions('FObjectOnes', template);

        Test.startTest();
        template.get('FObjectOnes')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test1)')

            .appendDefinitions(FObjectOne__c.TestText__c)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(test1)')
            .setDefinition(FObjectOne__c.TestText__c, 'static value(test2)');
        Test.stopTest();

        List<String> finalDefs = getDefinitionPositions('FObjectOnes', template);
        initialDefs.set(2, '2 TestText__c random type(string) minLength(10) maxLength(30) startWith(lower) include(lower,upper,digit)');
        initialDefs.set(3, '3 TestText__c static value(test1)');
        initialDefs.add('4 TestText__c static value(test2)');
        initialDefs.add('5 TestTextRequired__c static value(test)');
        initialDefs.add('6 TestTextRequired__c static value(test1)');

        Boolean conditionsAreValid = initialDefs.hashCode() == finalDefs.hashCode();
        System.assert(conditionsAreValid, 'appendDefinitions - errors found');
    }

    @IsTest
    private static void appendDefinitions_simple_expectSuccess() {
        Map<String, FObject> template = template1();
        List<String> initialDefs = getDefinitionPositions('FObjectOnes', template);

        Test.startTest();
        template.get('FObjectOnes')
            .appendDefinitions(FObjectOne__c.TestText__c)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(test1)')
            .setDefinition(FObjectOne__c.TestText__c, 'static value(test2)');
        Test.stopTest();

        List<String> finalDefs = getDefinitionPositions('FObjectOnes', template);
        initialDefs.set(2, '2 TestText__c random type(string) minLength(10) maxLength(30) startWith(lower) include(lower,upper,digit)');
        initialDefs.set(3, '3 TestText__c static value(test1)');
        initialDefs.add('4 TestText__c static value(test2)');
        initialDefs.add('5 TestTextRequired__c static value(test)');

        Boolean conditionsAreValid = initialDefs.hashCode() == finalDefs.hashCode();
        System.assert(conditionsAreValid, 'appendDefinitions - errors found');
    }

    @IsTest
    private static void removeAllDefinitions_declareNoDefinitions_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.removeAllDefinitions();
        Test.stopTest();

        System.assertEquals(true, obj.getAllDefinitions().isEmpty(), 'removeAllDefinitions - errors found');
    }

    @IsTest
    private static void removeAllDefinitions_declareSomeDefinitions_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('TestText__c', 'static value(TestName_)')
            .setDefinition('TestDecimal__c', 'random type(number) from(1) to(100) scale(0)')
            .setDefinition('TestPicklistA__c', 'random type(picklist)')
            .setDefinition('TestPicklistB__c', 'random type(picklist)')
            .removeAllDefinitions();
        Test.stopTest();

        System.assertEquals(true, obj.getAllDefinitions().isEmpty(), 'removeAllDefinitions - errors found');
    }

    @IsTest
    private static void removeAllDefinitions_recordsAreClearedAfterNewDefinition_expectSuccess() {
        Test.startTest();

        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('TestText__c', 'static value(TestName_)');
        obj.setDefinition('TestText__c', 'random type(number) from(1) to(100) scale(0)');
        obj.setDefinition('TestPicklistA__c', 'random type(picklist)');
        obj.setDefinition('TestPicklistB__c', 'random type(picklist)');
        List<FObjectOne__c> objRecords1 = obj.getRecords();
        Integer hash1 = objRecords1.hashCode();

        obj.removeAllDefinitions();

        obj.setDefinition('TestText__c', 'static value(TestName_)');
        obj.setDefinition('TestText__c', 'random type(number) from(1) to(100) scale(0)');
        obj.setDefinition('TestPicklistA__c', 'random type(picklist)');
        obj.setDefinition('TestPicklistB__c', 'random type(picklist)');
        List<FObjectOne__c> objRecords2 = obj.getRecords();
        Integer hash2 = objRecords2.hashCode();

        Test.stopTest();

        System.assertNotEquals(hash1, hash2, 'removeAllDefinitions - errors found');
    }

    @IsTest
    private static void removeDefinitionWithId_invalidId_expectSuccess() {
        String def1 = 'random type(number) from(1) to(100) scale(0)';
        String def2 = 'random type(number) from(1) to(100) scale(0)';
        String def3 = 'Random TYPE(number) from(1) to(100) scale(0)';
        String def4 = 'random TYPE(number)  from(1) to(100) scale(0)';
        String def5 = 'random type(picklist)';

        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestDecimal__c, def1) // pbwMs1
            .setDefinition(FObjectOne__c.TestText__c, def2) // icLoR1
            .setDefinition(FObjectOne__c.TestText__c, def3) // icLoR2
            .setDefinition(FObjectOne__c.TestText__c, def4) // JgZwB1
            .setDefinition(FObjectOne__c.TestPicklistA__c, def5); // Htzod1

        Test.startTest();
        obj1.removeDefinitionWithId('icLFR1');
        FObject.setGlobalVerbose('debug'); // DO NOT REMOVE
        obj1.getRecords();
        Test.stopTest();

        Integer counter = 0;
        Integer errors = 0;
        for (String item : FObject.getGlobalDebugLogs()) {
            if (item.contains('Definition [' + def1 + '] of [TestDecimal__c] is valid with ID [pbwMs1]')) {
                counter++;
            } else if (item.contains('Definition [' + def2 + '] of [TestText__c] is valid with ID [icLoR1]')) {
                counter++;
            } else if (item.contains('Definition [' + def3 + '] of [TestText__c] is valid with ID [icLoR2]')) {
                counter++;
            } else if (item.contains('Definition [' + def4 + '] of [TestText__c] is valid with ID [JgZwB1]')) {
                counter++;
            } else if (item.contains('Definition [' + def5 + '] of [TestPicklistA__c] is valid with ID [Htzod1]')) {
                counter++;
            } else if (item.contains('Will delete the definition with ID [icLoR1]')) {
                errors++;
            }
        }

        System.assert(counter == 5 && errors == 0, 'removeDefinitionWithId - errors found');
    }

    @IsTest
    private static void removeDefinitionWithId_0Def_expectSuccess() {
        String def1 = 'random type(number) from(1) to(100) scale(0)';
        String def2 = 'random type(number) from(1) to(100) scale(0)';
        String def3 = 'Random TYPE(number) from(1) to(100) scale(0)';
        String def4 = 'random TYPE(number)  from(1) to(100) scale(0)';
        String def5 = 'random type(picklist)';

        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestDecimal__c, def1) // pbwMs1
            .setDefinition(FObjectOne__c.TestText__c, def2) // icLoR1
            .setDefinition(FObjectOne__c.TestText__c, def3) // icLoR2
            .setDefinition(FObjectOne__c.TestText__c, def4) // JgZwB1
            .setDefinition(FObjectOne__c.TestPicklistA__c, def5); // Htzod1

        Test.startTest();
        obj1.removeDefinitionWithId('icLoR1');
        FObject.setGlobalVerbose('debug'); // DO NOT REMOVE
        obj1.getRecords();
        Test.stopTest();

        Integer counter = 0;
        Integer errors = 0;
        for (String item : FObject.getGlobalDebugLogs()) {
            if (item.contains('Definition [' + def1 + '] of [TestDecimal__c] is valid with ID [pbwMs1]')) {
                counter++;
            } else if (item.contains('Definition [' + def2 + '] of [TestText__c] is valid with ID [icLoR1]')) {
                errors++;
            } else if (item.contains('Definition [' + def3 + '] of [TestText__c] is valid with ID [icLoR2]')) {
                counter++;
            } else if (item.contains('Definition [' + def4 + '] of [TestText__c] is valid with ID [JgZwB1]')) {
                counter++;
            } else if (item.contains('Definition [' + def5 + '] of [TestPicklistA__c] is valid with ID [Htzod1]')) {
                counter++;
            } else if (item.contains('Will delete the definition with ID [icLoR1]')) {
                errors++;
            }
        }

        System.assert(counter == 4 && errors == 0, 'removeDefinitionWithId - errors found');
    }

    @IsTest
    private static void removeDefinitionWithId_2Defs_expectSuccess() {
        FObject.setGlobalVerbose('debug'); // DO NOT REMOVE

        String def1 = 'random type(number) from(1) to(100) scale(0)';
        String def2 = 'random type(number) from(1) to(100) scale(0)';
        String def3 = 'Random TYPE(number) from(1) to(100) scale(0)';
        String def4 = 'random TYPE(number)  from(1) to(100) scale(0)';
        String def5 = 'random type(picklist)';

        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestDecimal__c, def1) // pbwMs1
            .setDefinition(FObjectOne__c.TestTextRequired__c, def2) // pPzqK1
            .setDefinition(FObjectOne__c.TestText__c, def2) // icLoR1
            .setDefinition(FObjectOne__c.TestText__c, def3) // icLoR2
            .setDefinition(FObjectOne__c.TestText__c, def4) // JgZwB1
            .setDefinition(FObjectOne__c.TestPicklistA__c, def5); // Htzod1

        Test.startTest();
        obj1.removeDefinitionWithId('icLoR1');
        obj1.removeDefinitionWithId('Htzod1');
        obj1.insertRecords(true);
        Test.stopTest();

        Integer counter = 0;
        Integer errors = 0;
        for (String item : FObject.getGlobalDebugLogs()) {
            if (item.contains('Definition [' + def1 + '] of [TestDecimal__c] is valid with ID [pbwMs1]')) {
                counter++;
            } else if (item.contains('Definition [' + def2 + '] of [TestText__c] is valid with ID [icLoR1]')) {
                errors++;
            } else if (item.contains('Definition [' + def3 + '] of [TestText__c] is valid with ID [icLoR2]')) {
                counter++;
            } else if (item.contains('Definition [' + def4 + '] of [TestText__c] is valid with ID [JgZwB1]')) {
                counter++;
            } else if (item.contains('Definition [' + def5 + '] of [TestPicklistA__c] is valid with ID [Htzod1]')) {
                errors++;
            } else if (item.contains('Will remove the definition with ID [icLoR1]')) {
                counter++;
            } else if (item.contains('Will remove the definition with ID [Htzod1]')) {
                counter++;
            }
        }

        System.assert(counter == 5 && errors == 0, 'removeDefinitionWithId - errors found');
    }

    @IsTest
    private static void removeDefinitions_declareNoDefinitions_expectSuccess() {
        Test.startTest();

        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('TestDecimal__c', 'random type(number) from(1) to(100) scale(0)')
            .setDefinition('TestPicklistA__c', 'random type(picklist)')
            .setDefinition('TestPicklistB__c', 'random type(picklist)')
            .removeDefinitions(FObjectOne__c.TestText__c);

        Test.stopTest();

        Boolean expectedResult = true;
        Boolean actualResult = obj.getDefinitions(FObjectOne__c.TestText__c).isEmpty();
        System.assertEquals(expectedResult, actualResult, 'removeDefinitions - errors found');
    }

    @IsTest
    private static void removeDefinitions_declareSomeDefinitions_expectSuccess() {
        Test.startTest();

        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('TestDecimal__c', 'random type(number) from(1) to(100) scale(0)');
        obj.setDefinition('TestText__c', 'static value(TestName_)');
        obj.setDefinition('TestText__c', 'random type(number) from(1) to(100) scale(0)');
        obj.setDefinition('TestPicklistA__c', 'random type(picklist)');
        obj.setDefinition('TestPicklistB__c', 'random type(picklist)');
        obj.removeDefinitions(FObjectOne__c.TestText__c);

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
        System.assertEquals(0, errors, 'removeDefinitions - errors found');
    }

    @IsTest
    private static void removeDefinitions_invalidField_expectFailure() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition('TestText__c', 'static value(TestName_)');
        obj.setDefinition('TestText__c', 'random type(number) from(1) to(100) scale(0)');
        obj.setDefinition('TestDecimal__c', 'random type(number) from(1) to(100) scale(0)');
        obj.removeDefinitions('TestTextX__c');
        Test.stopTest();

        System.assertEquals('Invalid field [TestTextX__c] in method [removeDefinitions]',
            obj.getErrors().get('FObjectOne__c').get(0), 'removeDefinitions - wrong error message for invalid field');
    }

    @IsTest
    private static void removeDefinitions_blankField_expectFailure() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType);
        obj.setDefinition('TestText__c', 'static value(TestName_)');
        obj.setDefinition('TestText__c', 'random type(number) from(1) to(100) scale(0)');
        obj.setDefinition('TestDecimal__c', 'random type(number) from(1) to(100) scale(0)');
        obj.removeDefinitions(' ');
        Test.stopTest();

        System.assertEquals('Invalid field [] in method [removeDefinitions]',
            obj.getErrors().get('FObjectOne__c').get(0), 'removeDefinitions - wrong error message for invalid field');
    }

    @IsTest
    private static void removeDefinitions_recordsAreClearedAfterNewDefinition_expectSuccess() {
        Test.startTest();

        FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
        obj.setDefinition('TestText__c', 'static value(TestName_)');
        obj.setDefinition('TestText__c', 'random type(number) from(1) to(100) scale(0)');
        obj.setDefinition('TestDecimal__c', 'random type(number) from(1) to(100) scale(0)');

        List<FObjectOne__c> objRecords1 = obj.getRecords();
        Integer hash1 = objRecords1.hashCode();

        obj.removeDefinitions(FObjectOne__c.TestText__c);

        obj.setDefinition('TestText__c', 'static value(TestName_)');
        obj.setDefinition('TestText__c', 'random type(number) from(1) to(100) scale(0)');

        List<FObjectOne__c> objRecords2 = obj.getRecords();
        Integer hash2 = objRecords2.hashCode();

        Test.stopTest();

        System.assertNotEquals(hash1, hash2, 'removeDefinitions - errors found');
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
    private static void replaceDefinitions_noDefinitionsToReplace_expectSuccess() {
        Map<String, FObject> template = template1();
        List<String> initialDefs = getDefinitionPositions('FObjectOnes', template);

        Test.startTest();
        template.get('FObjectOnes')
            .replaceDefinitions(FObjectOne__c.TestDate__c);
        Test.stopTest();

        List<String> finalDefs = getDefinitionPositions('FObjectOnes', template);

        Boolean conditionsAreValid = initialDefs.hashCode() == finalDefs.hashCode();
        System.assert(conditionsAreValid, 'replaceDefinitions - errors found');
    }

    @IsTest
    private static void replaceDefinitions_withoutNewDef_expectSuccess() {
        Map<String, FObject> template = template1();
        List<String> initialDefs = getDefinitionPositions('FObjectOnes', template);

        Test.startTest();
        template.get('FObjectOnes')
            .replaceDefinitions(FObjectOne__c.TestLookup__c);
        Test.stopTest();

        List<String> finalDefs = getDefinitionPositions('FObjectOnes', template);

        Boolean conditionsAreValid = initialDefs.hashCode() == finalDefs.hashCode();
        System.assert(conditionsAreValid, 'replaceDefinitions - errors found');
    }

    @IsTest
    private static void replaceDefinitions_1Field1Def_expectSuccess() {
        Map<String, FObject> template = template1();
        List<String> initialDefs = getDefinitionPositions('FObjectOnes', template);

        Test.startTest();
        template.get('FObjectOnes')
            .replaceDefinitions('TestLookup__c')
            .setDefinition(FObjectOne__c.TestLookup__c, 'serial lookup(FObjectTwo__c) mode(cyclical) source(forceea)')
            .setDefinition(FObjectOne__c.TestText__c, 'random type(number) from(1) to(100) scale(2)');
        Test.stopTest();

        List<String> finalDefs = getDefinitionPositions('FObjectOnes', template);
        initialDefs.set(1, '1 TestLookup__c serial lookup(FObjectTwo__c) mode(cyclical) source(forceea)');
        initialDefs.add('4 TestText__c random type(number) from(1) to(100) scale(2)');

        Boolean conditionsAreValid = initialDefs.hashCode() == finalDefs.hashCode();
        System.assert(conditionsAreValid, 'replaceDefinitions - errors found');
    }

    @IsTest
    private static void replaceDefinitions_1Field2Defs_expectSuccess() {
        Map<String, FObject> template = template1();
        List<String> initialDefs = getDefinitionPositions('FObjectOnes', template);

        Test.startTest();
        template.get('FObjectOnes')
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(number) from(1) step(1) scale(0)')

            .replaceDefinitions(FObjectOne__c.TestTextRequired__c)
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test!)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'random type(number) from(1) to(100) scale(2)');
        Test.stopTest();

        List<String> finalDefs = getDefinitionPositions('FObjectOnes', template);
        initialDefs.set(3, '3 TestTextRequired__c static value(test!)');
        initialDefs.add('4 TestTextRequired__c random type(number) from(1) to(100) scale(2)');
        initialDefs.add('5 TestText__c serial type(number) from(1) step(1) scale(0)');

        Boolean conditionsAreValid = initialDefs.hashCode() == finalDefs.hashCode();
        System.assert(conditionsAreValid, 'replaceDefinitions - errors found');
    }

    @IsTest
    private static void replaceDefinitions_Field3Defs_expectSuccess() {
        Map<String, FObject> template = template1();
        List<String> initialDefs = getDefinitionPositions('FObjectOnes', template);

        Test.startTest();
        template.get('FObjectOnes')
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(number) from(1) step(1) scale(0)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test1)')

            .replaceDefinitions(FObjectOne__c.TestTextRequired__c)
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test1)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'random type(number) from(1) to(100) scale(2)')

            .setDefinition(FObjectOne__c.TestText__c, 'random type(number) from(1) to(100) scale(2)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test2)');
        Test.stopTest();

        List<String> finalDefs = getDefinitionPositions('FObjectOnes', template);
        initialDefs.set(3, '3 TestTextRequired__c static value(test1)');
        initialDefs.add('4 TestTextRequired__c random type(number) from(1) to(100) scale(2)');
        initialDefs.add('5 TestText__c serial type(number) from(1) step(1) scale(0)');
        initialDefs.add('6 TestText__c random type(number) from(1) to(100) scale(2)');
        initialDefs.add('7 TestTextRequired__c static value(test2)');

        Boolean conditionsAreValid = initialDefs.hashCode() == finalDefs.hashCode();
        System.assert(conditionsAreValid, 'replaceDefinitions - errors found');
    }

    @IsTest
    private static void replaceDefinitions_2Fields2Defs_expectSuccess() {
        Map<String, FObject> template = template1();
        List<String> initialDefs = getDefinitionPositions('FObjectOnes', template);

        Test.startTest();
        template.get('FObjectOnes')
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(number) from(1) step(1) scale(0)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test1)')

            .replaceDefinitions(FObjectOne__c.TestTextRequired__c)

            .replaceDefinitions(FObjectOne__c.TestText__c)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(test1)')
            .setDefinition(FObjectOne__c.TestText__c, 'static value(test2)')

            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test2)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test3)');
        Test.stopTest();

        List<String> finalDefs = getDefinitionPositions('FObjectOnes', template);
        initialDefs.set(2, '2 TestText__c static value(test1)');
        initialDefs.set(3, '3 TestText__c static value(test2)');
        initialDefs.add('4 TestTextRequired__c static value(test)');
        initialDefs.add('5 TestTextRequired__c static value(test1)');
        initialDefs.add('6 TestTextRequired__c static value(test2)');
        initialDefs.add('7 TestTextRequired__c static value(test3)');

        Boolean conditionsAreValid = initialDefs.hashCode() == finalDefs.hashCode();
        System.assert(conditionsAreValid, 'replaceDefinitions - errors found');
    }

    @IsTest
    private static void replaceDefinitions_2FieldsOtherDef_expectSuccess() {
        Map<String, FObject> template = template1();
        List<String> initialDefs = getDefinitionPositions('FObjectOnes', template);

        Test.startTest();
        template.get('FObjectOnes')
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(number) from(1) step(1) scale(0)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test1)')

            .replaceDefinitions(FObjectOne__c.TestTextRequired__c)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(test1)')

            .replaceDefinitions(FObjectOne__c.TestText__c)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(test2)')

            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test2)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test3)');
        Test.stopTest();

        List<String> finalDefs = getDefinitionPositions('FObjectOnes', template);
        initialDefs.set(2, '2 TestText__c static value(test2)');
        initialDefs.set(3, '3 TestTextRequired__c static value(test)');
        initialDefs.add('4 TestTextRequired__c static value(test1)');
        initialDefs.add('5 TestTextRequired__c static value(test2)');
        initialDefs.add('6 TestTextRequired__c static value(test3)');

        Boolean conditionsAreValid = initialDefs.hashCode() == finalDefs.hashCode();
        System.assert(conditionsAreValid, 'replaceDefinitions - errors found');
    }

    @IsTest
    private static void replaceDefinitions_2Fields4Defs_expectSuccess() {
        Map<String, FObject> template = template1();
        List<String> initialDefs = getDefinitionPositions('FObjectOnes', template);

        Test.startTest();
        template.get('FObjectOnes')
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(number) from(1) step(1) scale(0)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test1)')

            .replaceDefinitions(FObjectOne__c.TestTextRequired__c)
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test1)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test2)')

            .replaceDefinitions(FObjectOne__c.TestText__c)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(test1)')
            .setDefinition(FObjectOne__c.TestText__c, 'static value(test2)');
        Test.stopTest();

        List<String> finalDefs = getDefinitionPositions('FObjectOnes', template);
        initialDefs.set(2, '2 TestText__c static value(test1)');
        initialDefs.set(3, '3 TestText__c static value(test2)');
        initialDefs.add('4 TestTextRequired__c static value(test1)');
        initialDefs.add('5 TestTextRequired__c static value(test2)');

        Boolean conditionsAreValid = initialDefs.hashCode() == finalDefs.hashCode();
        System.assert(conditionsAreValid, 'replaceDefinitions - errors found');
    }

    @IsTest
    private static void replaceDefinitions_simple_expectSuccess() {
        Map<String, FObject> template = template1();
        List<String> initialDefs = getDefinitionPositions('FObjectOnes', template);

        Test.startTest();
        template.get('FObjectOnes')
            .replaceDefinitions(FObjectOne__c.TestText__c)
            .setDefinition(FObjectOne__c.TestText__c, 'static value(test1)')
            .setDefinition(FObjectOne__c.TestText__c, 'static value(test2)');
        Test.stopTest();

        List<String> finalDefs = getDefinitionPositions('FObjectOnes', template);
        initialDefs.set(2, '2 TestText__c static value(test1)');
        initialDefs.set(3, '3 TestText__c static value(test2)');
        initialDefs.add('4 TestTextRequired__c static value(test)');

        Boolean conditionsAreValid = initialDefs.hashCode() == finalDefs.hashCode();
        System.assert(conditionsAreValid, 'replaceDefinitions - errors found');
    }

    @IsTest
    private static void replaceDefinitions_virtualField_expectSuccess() {
        Map<String, FObject> template = template1();
        List<String> initialDefs = getDefinitionPositions('FObjectOnes', template);

        Test.startTest();
        template.get('FObjectOnes')
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

        List<String> finalDefs = getDefinitionPositions('FObjectOnes', template);
        initialDefs.set(2, '2 TestText__c static value(test1)');
        initialDefs.set(3, '3 TestText__c static value(test2)');
        initialDefs.add('4 TestTextRequired__c static value(test)');
        initialDefs.add('5 $MyVirtualField static value(virtual)');
        initialDefs.add('6 TestTextRequired__c static value(test1)');
        initialDefs.add('7 TestTextRequired__c static value(test2)');
        initialDefs.add('8 TestTextRequired__c static value(test3)');

        Boolean conditionsAreValid = initialDefs.hashCode() == finalDefs.hashCode();
        System.assert(conditionsAreValid, 'replaceDefinitions - errors found');
    }

    @IsTest
    private static void replaceDefinitionWithId_noDef_expectSuccess() {
        String def1 = 'random type(number) from(1) to(100) scale(0)';
        String def2 = 'random type(number) from(1) to(100) scale(0)';
        String def3 = 'Random TYPE(number) from(1) to(100) scale(0)';
        String def4 = 'random TYPE(number)  from(1) to(100) scale(0)';
        String def5 = 'random type(picklist)';

        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestDecimal__c, def1) // pbwMs1
            .setDefinition(FObjectOne__c.TestText__c, def2) // icLoR1
            .setDefinition(FObjectOne__c.TestText__c, def3) // icLoR2
            .setDefinition(FObjectOne__c.TestText__c, def4) // JgZwB1
            .setDefinition(FObjectOne__c.TestPicklistA__c, def5); // Htzod1

        Test.startTest();
        obj1.replaceDefinitionWithId('icLoR1');
        FObject.setGlobalVerbose('debug'); // DO NOT REMOVE
        obj1.getRecords();
        Test.stopTest();

        Integer counter = 0;
        for (String item : FObject.getGlobalDebugLogs()) {
            if (item.contains('Definition [' + def1 + '] of [TestDecimal__c] is valid with ID [pbwMs1]')) {
                counter++;
            } else if (item.contains('Definition [' + def3 + '] of [TestText__c] is valid with ID [icLoR2]')) {
                counter++;
            } else if (item.contains('Definition [' + def4 + '] of [TestText__c] is valid with ID [JgZwB1]')) {
                counter++;
            } else if (item.contains('Definition [' + def5 + '] of [TestPicklistA__c] is valid with ID [Htzod1]')) {
                counter++;
            }
        }

        System.assertEquals(4, counter, 'replaceDefinitionWithId - errors found');
    }

    @IsTest
    private static void replaceDefinitionWithId_1Def_expectSuccess() {
        String def1 = 'random type(number) from(1) to(100) scale(0)';
        String def2 = 'random type(number) from(1) to(100) scale(0)';
        String def3 = 'Random TYPE(number) from(1) to(100) scale(0)';
        String def4 = 'random TYPE(number)  from(1) to(100) scale(0)';
        String def5 = 'random type(picklist)';

        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestDecimal__c, def1) // pbwMs1
            .setDefinition(FObjectOne__c.TestText__c, def2) // icLoR1
            .setDefinition(FObjectOne__c.TestText__c, def3) // icLoR2
            .setDefinition(FObjectOne__c.TestText__c, def4) // JgZwB1
            .setDefinition(FObjectOne__c.TestPicklistA__c, def5); // Htzod1

        Test.startTest();
        obj1.replaceDefinitionWithId('icLoR1')
            .setDefinition(FObjectOne__c.TestText__c, def4);
        FObject.setGlobalVerbose('debug'); // DO NOT REMOVE
        obj1.getRecords();
        Test.stopTest();

        Integer counter = 0;
        for (String item : FObject.getGlobalDebugLogs()) {
            if (item.contains('Definition [' + def1 + '] of [TestDecimal__c] is valid with ID [pbwMs1]')) {
                counter++;
            } else if (item.contains('Definition [' + def4 + '] of [TestText__c] is valid with ID [JgZwB2]')) {
                counter++;
            } else if (item.contains('Definition [' + def3 + '] of [TestText__c] is valid with ID [icLoR2]')) {
                counter++;
            } else if (item.contains('Definition [' + def4 + '] of [TestText__c] is valid with ID [JgZwB1]')) {
                counter++;
            } else if (item.contains('Definition [' + def5 + '] of [TestPicklistA__c] is valid with ID [Htzod1]')) {
                counter++;
            } else if (item.contains('Will replace the definition with ID [icLoR1]')) {
                counter++;
            }
        }

        System.assertEquals(5, counter, 'replaceDefinitionWithId - errors found');
    }

    @IsTest
    private static void replaceDefinitionWithId_1DefAfterOther_expectSuccess() {
        FObject.setGlobalVerbose('debug'); // DO NOT REMOVE

        String def1 = 'random type(number) from(1) to(100) scale(0)';
        String def2 = 'random type(number) from(1) to(100) scale(0)';
        String def3 = 'Random TYPE(number) from(1) to(100) scale(0)';
        String def4 = 'random TYPE(number)  from(1) to(100) scale(0)';
        String def5 = 'random type(picklist)';

        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestDecimal__c, def1) // pbwMs1
            .setDefinition(FObjectOne__c.TestText__c, def2) // icLoR1
            .setDefinition(FObjectOne__c.TestText__c, def3) // icLoR2
            .setDefinition(FObjectOne__c.TestText__c, def4) // JgZwB1
            .setDefinition(FObjectOne__c.TestPicklistA__c, def5); // Htzod1

        Test.startTest();
        obj1.replaceDefinitionWithId('icLoR1')
            .setDefinition(FObjectOne__c.TestText__c, def4)
            .setDefinition(FObjectOne__c.TestTextRequired__c, def4)
            .setDefinition(FObjectOne__c.TestText__c, def2);
        obj1.getRecords();
        Test.stopTest();

        Integer counter = 0;
        for (String item : FObject.getGlobalDebugLogs()) {
            if (item.contains('Definition [' + def1 + '] of [TestDecimal__c] is valid with ID [pbwMs1]')) {
                counter++;
            } else if (item.contains('Definition [' + def4 + '] of [TestText__c] is valid with ID [JgZwB2]')) {
                counter++;
            }  else if (item.contains('Definition [' + def2 + '] of [TestText__c] is valid with ID [icLoR3]')) {
                counter++;
            } else if (item.contains('Definition [' + def3 + '] of [TestText__c] is valid with ID [icLoR2]')) {
                counter++;
            } else if (item.contains('Definition [' + def4 + '] of [TestText__c] is valid with ID [JgZwB1]')) {
                counter++;
            } else if (item.contains('Definition [' + def5 + '] of [TestPicklistA__c] is valid with ID [Htzod1]')) {
                counter++;
            } else if (item.contains('Will replace the definition with ID [icLoR1]')) {
                counter++;
            }
        }

        System.assertEquals(7, counter, 'replaceDefinitionWithId - errors found');
    }

    @IsTest
    private static void replaceDefinitionWithId_2Defs_expectSuccess() {
        String def1 = 'random type(number) from(1) to(100) scale(0)';
        String def2 = 'random type(number) from(1) to(100) scale(0)';
        String def3 = 'Random TYPE(number) from(1) to(100) scale(0)';
        String def4 = 'random TYPE(number)  from(1) to(100) scale(0)';
        String def5 = 'random type(picklist)';

        FObject obj1 = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestDecimal__c, def1) // pbwMs1
            .setDefinition(FObjectOne__c.TestText__c, def2) // icLoR1
            .setDefinition(FObjectOne__c.TestText__c, def3) // icLoR2
            .setDefinition(FObjectOne__c.TestText__c, def4) // JgZwB1
            .setDefinition(FObjectOne__c.TestPicklistA__c, def5); // Htzod1

        Test.startTest();
        obj1.replaceDefinitionWithId('icLoR1')
            .setDefinition(FObjectOne__c.TestText__c, def4)
            .setDefinition(FObjectOne__c.TestText__c, def2);
        FObject.setGlobalVerbose('debug'); // DO NOT REMOVE
        obj1.getRecords();
        Test.stopTest();

        Integer counter = 0;
        for (String item : FObject.getGlobalDebugLogs()) {
            if (item.contains('Definition [' + def1 + '] of [TestDecimal__c] is valid with ID [pbwMs1]')) {
                counter++;
            } else if (item.contains('Definition [' + def4 + '] of [TestText__c] is valid with ID [JgZwB2]')) {
                counter++;
            } else if (item.contains('Definition [' + def2 + '] of [TestText__c] is valid with ID [icLoR3]')) {
                counter++;
            } else if (item.contains('Definition [' + def3 + '] of [TestText__c] is valid with ID [icLoR2]')) {
                counter++;
            } else if (item.contains('Definition [' + def4 + '] of [TestText__c] is valid with ID [JgZwB1]')) {
                counter++;
            } else if (item.contains('Definition [' + def5 + '] of [TestPicklistA__c] is valid with ID [Htzod1]')) {
                counter++;
            }
        }

        System.assertEquals(6, counter, 'replaceDefinitionWithId - errors found');
    }

    @IsTest
    private static void replaceDefinitionWithId_simple_expectSuccess() {
        Map<String, FObject> template = template1();
        List<String> initialDefs = getDefinitionPositions('FObjectOnes', template);

        Test.startTest();
        template.get('FObjectOnes')
            .setDefinition(FObjectOne__c.TestText__c, 'static value(test3)')

            .replaceDefinitionWithId('nRNOG1')
            .setDefinition(FObjectOne__c.TestText__c, 'static value(test1)')
            .setDefinition(FObjectOne__c.TestText__c, 'static value(test2)');
        Test.stopTest();

        List<String> finalDefs = getDefinitionPositions('FObjectOnes', template);
        initialDefs.set(2, '2 TestText__c static value(test1)');
        initialDefs.set(3, '3 TestText__c static value(test2)');
        initialDefs.add('4 TestTextRequired__c static value(test)');
        initialDefs.add('5 TestText__c static value(test3)');

        Boolean conditionsAreValid = initialDefs.hashCode() == finalDefs.hashCode();
        System.assert(conditionsAreValid, 'replaceDefinitionWithId - errors found');
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

    /* TEMPLATES */

    private static Map<String, FObject> template1() {
        Map<String, FObject> template = new Map<String, FObject>();

        template.putAll(template2());
        template.put('FObjectOnes', new FObject(FObjectOne__c.SObjectType, 20)
            .setDefinition(FObjectOne__c.TestIntegerUnique__c, 'serial type(number) from(1) step(1) scale(0)')
            .setDefinition(FObjectOne__c.TestLookup__c, 'random lookup(FObjectTwo__c) source(forceea)')
            .setDefinition(FObjectOne__c.TestText__c,
                'random type(string) minLength(10) maxLength(30) startWith(lower) include(lower,upper,digit)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
        );

        return template;
    }

    private static Map<String, FObject> template2() {
        return new Map<String, FObject>{
            'FObjectTwos' => new FObject(FObjectTwo__c.SObjectType, 10)
                .setDefinition(FObjectTwo__c.TestText__c, 'random type(number) from(10) to(100) scale(0)')
                .setDefinition(FObjectTwo__c.TestTextUnique__c, 'serial type(number) from(1) step(1) scale(0)')
                .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)')
        };
    }

    /* UTILITY METHODS */

    private static List<String> getDefinitionPositions(String key, Map<String, FObject> template) {
        List<String> results = new List<String>();
        Integer counter = 0;

        for (ForceeaDefinition def : template.get(key).definitions) {
            String str = counter + ' ' + def.fieldApiName + ' ' + def.definitionString;
            results.add(str);
            counter++;
        }

        return results;
    }

}
