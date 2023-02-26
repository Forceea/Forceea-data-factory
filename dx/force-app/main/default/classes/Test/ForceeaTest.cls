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
public class ForceeaTest {

    @IsTest
    private static void add_fObject_expectSuccess() {
        Forceea.Template template = new Forceea.Template()
            .add('Ones', new FObject(FObjectOne__c.SObjectType, 10)
                .setDefinition(FObjectOne__c.TestInteger__c, 'serial type(number) from(1) step(1) scale(0)')
                .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            );

        Test.startTest();
        template.insertRecords(true);
        Test.stopTest();

        Integer expectedNumber = template.getFObject('Ones').getNumberOfRecords();
        Integer actualNumber = template.getFObject('Ones').getInsertedRecords().size();
        System.assertEquals(expectedNumber, actualNumber, 'Errors found');
    }

    @IsTest
    private static void add_map_expectSuccess() {
        Forceea.Template templateTwos = new Forceea.Template()
            .add('Twos', new FObject(FObjectTwo__c.SObjectType, 10)
                .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)')
            );

        Forceea.Template templateOnes = new Forceea.Template()
            .add(templateTwos.getMap())
            .add('Ones', new FObject(FObjectOne__c.SObjectType, 10)
                .setDefinition(FObjectOne__c.TestInteger__c, 'serial type(number) from(1) step(1) scale(0)')
                .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
                .setDefinition(FObjectOne__c.TestLookup__c,
                    'serial lookup(FObjectTwo__c) mode(cyclical) source(forceea)')
            );

        Test.startTest();
        templateOnes.insertRecords(true);
        Test.stopTest();

        Integer expectedNumber = templateOnes.getFObject('Ones').getNumberOfRecords();
        Integer actualNumber = templateOnes.getFObject('Ones').getInsertedRecords().size();
        System.assertEquals(expectedNumber, actualNumber, 'Errors found');
    }

    @IsTest
    private static void add_template_expectSuccess() {
        Forceea.Template templateTwos = new Forceea.Template()
            .add('Twos', new FObject(FObjectTwo__c.SObjectType, 10)
                .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)')
            );

        Forceea.Template templateOnes = new Forceea.Template()
            .add(templateTwos)
            .add('Ones', new FObject(FObjectOne__c.SObjectType, 10)
                .setDefinition(FObjectOne__c.TestInteger__c, 'serial type(number) from(1) step(1) scale(0)')
                .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
                .setDefinition(FObjectOne__c.TestLookup__c,
                    'serial lookup(FObjectTwo__c) mode(cyclical) source(forceea)')
            );

        Test.startTest();
        templateOnes.insertRecords(true);
        Test.stopTest();

        Integer expectedNumber = templateOnes.getFObject('Ones').getNumberOfRecords();
        Integer actualNumber = templateOnes.getFObject('Ones').getInsertedRecords().size();
        System.assertEquals(expectedNumber, actualNumber, 'Errors found');
    }

    @IsTest
    private static void getFObject_keyExists_expectSuccess() {
        Forceea.Template template = new Forceea.Template()
            .add('Ones', new FObject(FObjectOne__c.SObjectType, 10)
                .setDefinition(FObjectOne__c.TestInteger__c, 'serial type(number) from(1) step(1) scale(0)')
                .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
                .setDefinition(FObjectOne__c.TestLookup__c,
                    'serial lookup(FObjectTwo__c) mode(cyclical) source(forceea)')
            );

        Test.startTest();
        FObject obj = template.getFObject('Ones');
        Test.stopTest();

        Integer expectedResult = 10;
        Integer actualResult = obj.getNumberOfRecords();
        System.assertEquals(expectedResult, actualResult, 'Method getFObject has errors');
    }

    @IsTest
    private static void getFObject_keyNotExists_expectSuccess() {
        Forceea.Template template = new Forceea.Template()
            .add('Ones', new FObject(FObjectOne__c.SObjectType, 10)
                .setDefinition(FObjectOne__c.TestInteger__c, 'serial type(number) from(1) step(1) scale(0)')
                .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
                .setDefinition(FObjectOne__c.TestLookup__c,
                    'serial lookup(FObjectTwo__c) mode(cyclical) source(forceea)')
            );

        Test.startTest();
        FObject obj = template.getFObject('Twos');
        Test.stopTest();

        System.assert(obj == null, 'Method getFObject has errors');
    }


    @IsTest
    private static void getInsertResults_template_expectSuccess() {
        Forceea.Template template = new Forceea.Template()
            .add('Ones', new FObject(FObjectOne__c.SObjectType, 10)
                .setDefinition(FObjectOne__c.TestInteger__c, 'serial type(number) from(1) step(1) scale(0)')
                .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
                .setDefinition(FObjectOne__c.TestLookup__c,
                    'serial lookup(FObjectTwo__c) mode(cyclical) source(forceea)')
            );

        Test.startTest();
        template.insertRecords(false);
        Test.stopTest();

        Integer expectedResult = FObject.getInsertedRecords(FObjectOne__c.SObjectType).size();
        Integer actualResult = template.getInsertResults().get('Ones').size();
        System.assertEquals(expectedResult, actualResult, 'Method getInsertResults has errors');
    }

    @IsTest
    private static void keep_key_expectSuccess() {
        Forceea.Template template = new Forceea.Template()
            .add('Twos', new FObject(FObjectTwo__c.SObjectType, 10)
                .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)')
            )
            .add('Ones', new FObject(FObjectOne__c.SObjectType, 10)
                .setDefinition(FObjectOne__c.TestInteger__c, 'serial type(number) from(1) step(1) scale(0)')
                .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
                .setDefinition(FObjectOne__c.TestLookup__c,
                    'serial lookup(FObjectTwo__c) mode(cyclical) source(forceea)')
            )
            .add('SecondOnes', new FObject(FObjectTwo__c.SObjectType, 10)
                .setDefinition(FObjectTwo__c.TestPicklistDRequired__c, 'random type(picklist)')
            );

        Test.startTest();
        template.keep('Ones');
        Test.stopTest();

        Boolean containsOnes = template.getMap().containsKey('Ones');
        Boolean containsTwos = template.getMap().containsKey('Twos');
        Boolean containsSecondOnes = template.getMap().containsKey('SecondOnes');
        System.assert(containsOnes && !containsTwos && !containsSecondOnes, 'Method keep has errors');
    }

    @IsTest
    private static void keep_keys_expectSuccess() {
        Forceea.Template template = new Forceea.Template()
            .add('Twos', new FObject(FObjectTwo__c.SObjectType))
            .add('Ones', new FObject(FObjectOne__c.SObjectType))
            .add('Threes', new FObject(FObjectThree__c.SObjectType));

        Test.startTest();
        List<String> keysToKeep = new List<String> {
            'Ones', 'Twos'
        };
        template.keep(keysToKeep);
        Test.stopTest();

        Boolean containsOnes = template.getMap().containsKey('Ones');
        Boolean containsTwos = template.getMap().containsKey('Twos');
        Boolean containsThrees = template.getMap().containsKey('Threes');
        System.assert(containsOnes && containsTwos && !containsThrees, 'Method keep has errors');
    }

    @IsTest
    private static void keepAfter_keyExists_expectSuccess() {
        Forceea.Template template = new Forceea.Template()
            .add('Twos', new FObject(FObjectTwo__c.SObjectType))
            .add('Ones', new FObject(FObjectOne__c.SObjectType))
            .add('Threes', new FObject(FObjectThree__c.SObjectType));

        Test.startTest();
        template.keepAfter('Twos');
        Test.stopTest();

        Boolean containsOnes = template.getMap().containsKey('Ones');
        Boolean containsTwos = template.getMap().containsKey('Twos');
        Boolean containsThrees = template.getMap().containsKey('Threes');
        System.assert(containsOnes && !containsTwos && containsThrees, 'Method keep has errors');
    }

    @IsTest
    private static void keepAfter_keyNotExists_expectSuccess() {
        Forceea.Template template = new Forceea.Template()
            .add('Twos', new FObject(FObjectTwo__c.SObjectType))
            .add('Ones', new FObject(FObjectOne__c.SObjectType))
            .add('Threes', new FObject(FObjectThree__c.SObjectType));

        Test.startTest();
        template.keepAfter('Fours');
        Test.stopTest();

        Boolean containsOnes = template.getMap().containsKey('Ones');
        Boolean containsTwos = template.getMap().containsKey('Twos');
        Boolean containsThrees = template.getMap().containsKey('Threes');
        System.assert(containsOnes && containsTwos && containsThrees, 'Method keep has errors');
    }

    @IsTest
    private static void keepBefore_keyExists_expectSuccess() {
        Forceea.Template template = new Forceea.Template()
            .add('Twos', new FObject(FObjectTwo__c.SObjectType))
            .add('Ones', new FObject(FObjectOne__c.SObjectType))
            .add('Threes', new FObject(FObjectThree__c.SObjectType));

        Test.startTest();
        template.keepBefore('Threes');
        Test.stopTest();

        Boolean containsOnes = template.getMap().containsKey('Ones');
        Boolean containsTwos = template.getMap().containsKey('Twos');
        Boolean containsThrees = template.getMap().containsKey('Threes');
        System.assert(containsOnes && containsTwos && !containsThrees, 'Method keep has errors');
    }

    @IsTest
    private static void keepBefore_keyNotExists_expectSuccess() {
        Forceea.Template template = new Forceea.Template()
            .add('Twos', new FObject(FObjectTwo__c.SObjectType))
            .add('Ones', new FObject(FObjectOne__c.SObjectType))
            .add('Threes', new FObject(FObjectThree__c.SObjectType));

        Test.startTest();
        template.keepBefore('Fours');
        Test.stopTest();

        Boolean containsOnes = template.getMap().containsKey('Ones');
        Boolean containsTwos = template.getMap().containsKey('Twos');
        Boolean containsThrees = template.getMap().containsKey('Threes');
        System.assert(containsOnes && containsTwos && containsThrees, 'Method keep has errors');
    }

    @IsTest
    private static void remove_keyExists_expectSuccess() {
        Forceea.Template template = new Forceea.Template()
            .add('Twos', new FObject(FObjectTwo__c.SObjectType))
            .add('Ones', new FObject(FObjectOne__c.SObjectType))
            .add('Threes', new FObject(FObjectThree__c.SObjectType));

        Test.startTest();
        template.remove('Ones');
        Test.stopTest();

        Boolean containsOnes = template.getMap().containsKey('Ones');
        Boolean containsTwos = template.getMap().containsKey('Twos');
        Boolean containsThrees = template.getMap().containsKey('Threes');
        System.assert(!containsOnes && containsTwos && containsThrees, 'Method remove has errors');
    }

    @IsTest
    private static void remove_keyNotExists_expectSuccess() {
        Forceea.Template template = new Forceea.Template()
            .add('Twos', new FObject(FObjectTwo__c.SObjectType))
            .add('Ones', new FObject(FObjectOne__c.SObjectType))
            .add('Threes', new FObject(FObjectThree__c.SObjectType));

        Test.startTest();
        template.remove('Fours');
        Test.stopTest();

        Boolean containsOnes = template.getMap().containsKey('Ones');
        Boolean containsTwos = template.getMap().containsKey('Twos');
        Boolean containsThrees = template.getMap().containsKey('Threes');
        System.assert(containsOnes && containsTwos && containsThrees, 'Method remove has errors');
    }

    @IsTest
    private static void removeAfter_keyExists_expectSuccess() {
        Forceea.Template template = new Forceea.Template()
            .add('Twos', new FObject(FObjectTwo__c.SObjectType))
            .add('Ones', new FObject(FObjectOne__c.SObjectType))
            .add('Threes', new FObject(FObjectThree__c.SObjectType));

        Test.startTest();
        template.removeAfter('Ones');
        Test.stopTest();

        Boolean containsOnes = template.getMap().containsKey('Ones');
        Boolean containsTwos = template.getMap().containsKey('Twos');
        Boolean containsThrees = template.getMap().containsKey('Threes');
        System.assert(containsOnes && containsTwos && !containsThrees, 'Method remove has errors');
    }

    @IsTest
    private static void removeAfter_keyNotExists_expectSuccess() {
        Forceea.Template template = new Forceea.Template()
            .add('Twos', new FObject(FObjectTwo__c.SObjectType))
            .add('Ones', new FObject(FObjectOne__c.SObjectType))
            .add('Threes', new FObject(FObjectThree__c.SObjectType));

        Test.startTest();
        template.removeAfter('Fours');
        Test.stopTest();

        Boolean containsOnes = template.getMap().containsKey('Ones');
        Boolean containsTwos = template.getMap().containsKey('Twos');
        Boolean containsThrees = template.getMap().containsKey('Threes');
        System.assert(containsOnes && containsTwos && containsThrees, 'Method remove has errors');
    }

    @IsTest
    private static void removeBefore_keyExists_expectSuccess() {
        Forceea.Template template = new Forceea.Template()
            .add('Twos', new FObject(FObjectTwo__c.SObjectType))
            .add('Ones', new FObject(FObjectOne__c.SObjectType))
            .add('Threes', new FObject(FObjectThree__c.SObjectType));

        Test.startTest();
        template.removeBefore('Threes');
        Test.stopTest();

        Boolean containsOnes = template.getMap().containsKey('Ones');
        Boolean containsTwos = template.getMap().containsKey('Twos');
        Boolean containsThrees = template.getMap().containsKey('Threes');
        System.assert(!containsOnes && !containsTwos && containsThrees, 'Method remove has errors');
    }

    @IsTest
    private static void removeBefore_keyNotExists_expectSuccess() {
        Forceea.Template template = new Forceea.Template()
            .add('Twos', new FObject(FObjectTwo__c.SObjectType))
            .add('Ones', new FObject(FObjectOne__c.SObjectType))
            .add('Threes', new FObject(FObjectThree__c.SObjectType));

        Test.startTest();
        template.removeBefore('Fours');
        Test.stopTest();

        Boolean containsOnes = template.getMap().containsKey('Ones');
        Boolean containsTwos = template.getMap().containsKey('Twos');
        Boolean containsThrees = template.getMap().containsKey('Threes');
        System.assert(containsOnes && containsTwos && containsThrees, 'Method remove has errors');
    }

    @IsTest
    private static void remove_keys_expectSuccess() {
        Forceea.Template template = new Forceea.Template()
            .add('Twos', new FObject(FObjectTwo__c.SObjectType))
            .add('Ones', new FObject(FObjectOne__c.SObjectType))
            .add('Threes', new FObject(FObjectThree__c.SObjectType));

        Test.startTest();
        List<String> keysToRemove = new List<String> {
            'Ones', 'Twos'
        };
        template.remove(keysToRemove);
        Test.stopTest();

        Boolean containsOnes = template.getMap().containsKey('Ones');
        Boolean containsTwos = template.getMap().containsKey('Twos');
        Boolean containsThrees = template.getMap().containsKey('Threes');
        System.assert(!containsOnes && !containsTwos && containsThrees, 'Method remove has errors');
    }


    @IsTest
    private static void template_constructorFObject_expectSuccess() {
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestInteger__c, 'serial type(number) from(1) step(1) scale(0)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');

        Test.startTest();
        Forceea.Template template = new Forceea.Template('Ones', obj)
            .insertRecords(true);
        Test.stopTest();

        Integer expectedNumber = template.getFObject('Ones').getNumberOfRecords();
        Integer actualNumber = template.getFObject('Ones').getInsertedRecords().size();
        System.assertEquals(expectedNumber, actualNumber, 'Errors found on constructor');
    }

    @IsTest
    private static void template_constructorMap_expectSuccess() {
        Map<String, FObject> fObjectsByKey = new Map<String, FObject> {
            'Ones' => new FObject(FObjectOne__c.SObjectType, 10)
                .setDefinition(FObjectOne__c.TestInteger__c, 'serial type(number) from(1) step(1) scale(0)')
                .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
        };

        Test.startTest();
        Forceea.Template template = new Forceea.Template(fObjectsByKey)
            .insertRecords(true);
        Test.stopTest();

        Integer expectedNumber = template.getFObject('Ones').getNumberOfRecords();
        Integer actualNumber = template.getFObject('Ones').getInsertedRecords().size();
        System.assertEquals(expectedNumber, actualNumber, 'Errors found on constructor');
    }

    @IsTest
    private static void template_constructorTemplate_expectSuccess() {
        Forceea.Template template1 = new Forceea.Template()
            .add('Ones', new FObject(FObjectOne__c.SObjectType, 10)
                .setDefinition(FObjectOne__c.TestInteger__c, 'serial type(number) from(1) step(1) scale(0)')
                .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)')
            );

        Test.startTest();
        Forceea.Template template2 = new Forceea.Template(template1)
            .insertRecords(true);
        Test.stopTest();

        Integer expectedNumber = template2.getFObject('Ones').getNumberOfRecords();
        Integer actualNumber = template2.getFObject('Ones').getInsertedRecords().size();
        System.assertEquals(expectedNumber, actualNumber, 'Errors found on constructor');
    }

}