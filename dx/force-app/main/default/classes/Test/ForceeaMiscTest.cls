/*
  Forceea data factory (2.7.0)
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
public class ForceeaMiscTest {

    @IsTest
    private static void excludeInactiveLookupRecords_true_expectSuccess() {
        // insert active users
        FObject objUser = new FObject('User', 5)
            .setRequiredFields(true);
        objUser.insertRecords(true, 'active');

        // insert inactive users
        objUser
            .setNumberOfRecords(5)
            .setDefinition(User.IsActive, 'static value(false)');
        objUser.insertRecords(true, 'inactive');

        Test.startTest();
        FObject obj = new FObject(FObjectFour__c.SObjectType, 10)
            .excludeInactiveLookupRecords(true)
            .setDefinition('TestLookupUser__c', 'random lookup(User) source(salesforce)');
        obj.insertRecords(true);
        Test.stopTest();

        Integer errors = 0;
        for (FObjectFour__c record : [SELECT TestLookupUser__r.IsActive FROM FObjectFour__c]) {
            if (!record.TestLookupUser__r.IsActive) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'excludeInactiveLookupRecords - errors found');
    }

    @IsTest
    private static void excludeInactiveLookupRecords_false_expectSuccess() {
        FObject.setSeed(1);

        // insert active users
        FObject objUser = new FObject('User', 5)
            .setRequiredFields(true);
        objUser.insertRecords(true, 'active');

        // insert inactive users
        objUser
            .setNumberOfRecords(5)
            .setDefinition(User.IsActive, 'static value(false)');
        objUser.insertRecords(true, 'inactive');

        Test.startTest();
        FObject obj = new FObject(FObjectFour__c.SObjectType, 100)
            .excludeInactiveLookupRecords(false)
            .setDefinition(FObjectFour__c.TestLookupUser__c, 'random lookup(User) source(forceea)');
        obj.insertRecords(true);
        Test.stopTest();

        Integer errors = 0;
        Integer count = 0;
        for (FObjectFour__c record : [SELECT TestLookupUser__r.IsActive FROM FObjectFour__c]) {
            if (record.TestLookupUser__r.IsActive) {
                count++;
            }
        }
        if (count == 0) {
            errors++;
        }
        System.assertEquals(0, errors, 'excludeInactiveLookupRecords - errors found');
    }

    @IsTest
    private static void insertRecords_createRecordsAsUser_expectSuccess() {
        Test.startTest();
        FObject userObj = new FObject('User', 1)
            .setRequiredFields(true)
            .setDefinition('Title', 'static value(Developer)')
            .setDefinition('ProfileId',
                'static lookup(Profile) field(Name) value(System Administrator) source(salesforce)');
        List<Database.SaveResult> saveResults = userObj.insertRecords(true);

        if (saveResults[0].isSuccess()) {
            List<User> users = (List<User>) userObj.getRecords();
            System.runAs(users[0]) {
                FObject obj = new FObject(FObjectOne__c.SObjectType)
                    .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
                saveResults = obj.insertRecords(false);
            }
        }
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
    private static void insertRecords_userWithProfile_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject('User', 1)
            .setRequiredFields(true)
            .setDefinition('ProfileId',
                'static lookup(Profile) field(Name) value(System Administrator) source(salesforce)')
            .setDefinition('Title', 'static value(Forceea Developer)');
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
    private static void insertRecordsFromTemplateOptimized_pricebookEntries_expectSuccess() {
        Map<String, FObject> template = new Map<String, FObject>();
        template.putAll(FObjectDmlTest.template1());
        template.putAll(FObjectDmlTest.template3());
        template.put('Products', new FObject(Product2.SObjectType, 10)
            .setRequiredFields(true)
            .setDefinition(Product2.Name, 'static value("Product-")')
            .setDefinition(Product2.Name, 'serial type(number) from(1) step(1) scale(0)')
            .setDefinition(Product2.Description, 'random type(text) minLength(25) maxLength(50)')
            .setDefinition('$StandardPrice', 'serial type(number) from(1) step(1) scale(0)')
            .setStandardPricebookEntries('$StandardPrice')
        );

        Integer numRecordsA1 = template.get('Ones').getNumberOfRecords();
        Integer numRecordsA2 = template.get('Twos').getNumberOfRecords();
        Integer numRecordsA3 = template.get('Threes').getNumberOfRecords();
        Integer numRecordsB = template.get('FObjectTwos').getNumberOfRecords();
        Integer numRecordsC1 = template.get('FoursA').getNumberOfRecords();
        Integer numRecordsC2 = template.get('FoursB').getNumberOfRecords();
        Integer numRecordsProd = template.get('Products').getNumberOfRecords();

        Test.startTest();
        FObject.setDmlOptimizer(true);
        Map<String, List<Database.SaveResult>> saveResults = FObject.insertRecordsFromTemplate(template, true);
        Integer dmlStatements = Limits.getDmlStatements();
        Test.stopTest();

        Integer errors = 0;
        if (template.get('FObjectTwos').getInsertedRecords().size() != numRecordsB ||
            template.get('Ones').getInsertedRecords().size() != numRecordsA1 ||
            template.get('Twos').getInsertedRecords().size() != numRecordsA2 ||
            template.get('Threes').getInsertedRecords().size() != numRecordsA3 ||
            template.get('FoursA').getInsertedRecords().size() != numRecordsC1 ||
            template.get('FoursB').getInsertedRecords().size() != numRecordsC2 ||
            template.get('Products').getInsertedRecords().size() != numRecordsProd) {
            errors += 1;
        }
        if (!saveResults.containsKey('Ones') || !saveResults.containsKey('Twos') || !saveResults.containsKey('Threes') ||
            !saveResults.containsKey('FObjectTwos') || !saveResults.containsKey('FObjectTwos') ||
            !saveResults.containsKey('FoursA') || !saveResults.containsKey('Products')) {
            errors += 2;
        }
        if (dmlStatements != 6) {
            errors += 4;
        }
        Integer counter = 1;
        for (PricebookEntry record : [SELECT UnitPrice FROM PricebookEntry]) {
            if (record.UnitPrice != counter) {
                errors += 8;
                break;
            }
            counter++;
        }

        System.assertEquals(0, errors, 'insertRecordsFromTemplate - errors found');
    }

    @IsTest
    private static void setStandardPricebookEntries_virtualFieldExists_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(Product2.SObjectType, 10)
            .setRequiredFields(true)
            .setDefinition(Product2.Name, 'static value("Product-")')
            .setDefinition(Product2.Name, 'serial type(number) from(1) step(1) scale(0)')
            .setDefinition(Product2.Description, 'random type(text) minLength(25) maxLength(50)')
            .setDefinition('$StandardPrice', 'serial type(number) from(1) step(1) scale(0)')
            .setStandardPricebookEntries('$StandardPrice');
        obj.insertRecords(true);
        Test.stopTest();

        Integer errors = 0;
        Integer counter = 1;
        for (PricebookEntry record : [SELECT UnitPrice FROM PricebookEntry]) {
            if (record.UnitPrice != counter) {
                errors++;
            }
            counter++;
        }

        System.assertEquals(0, errors, 'setStandardPricebookEntries - errors found');
    }

    @IsTest
    private static void setStandardPricebookEntries_getInsertedEntries_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(Product2.SObjectType, 10)
            .setRequiredFields(true)
            .setDefinition(Product2.Name, 'static value("Product-")')
            .setDefinition(Product2.Name, 'serial type(number) from(1) step(1) scale(0)')
            .setDefinition(Product2.Description, 'random type(text) minLength(25) maxLength(50)')
            .setDefinition('$StandardPrice', 'serial type(number) from(1) step(1) scale(0)')
            .setStandardPricebookEntries('$StandardPrice');
        obj.insertRecords(true);
        Test.stopTest();

        Integer errors = 0;
        Integer counter = 1;
        List<PricebookEntry> records = (List<PricebookEntry>) FObject.getInsertedRecords(PricebookEntry.SObjectType);

        for (PricebookEntry record : records) {
            if (record.UnitPrice != counter) {
                errors++;
            }
            counter++;
        }
        if (records.size() != obj.getNumberOfRecords()) {
            errors = +32;
        }

        System.assertEquals(0, errors, 'setStandardPricebookEntries - errors found');
    }

}