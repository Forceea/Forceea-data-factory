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
public class ForceeaMiscTest {

    @IsTest
    private static void excludeInactiveLookupRecords_true_expectSuccess() {
        Boolean isException = false;

        // insert active users
        FObject objUser = new FObject(User.SObjectType, 2)
            .setRequiredFields(true);
        try {
            objUser.insertRecords(true, 'active');
        } catch (Exception exp) {
            isException = true;
        }

        if (!isException) {
            isException = insertInactiveUsers(objUser);
        }

        Test.startTest();

        if (!isException) {
            isException = insertFromExcludedInactive(true);
        }

        Test.stopTest();

        Integer errors = 0;
        if (!isException) {
            for (FObjectFour__c record : [SELECT TestLookupUser__r.IsActive FROM FObjectFour__c]) {
                if (!record.TestLookupUser__r.IsActive) {
                    errors++;
                }
            }
        }

        Assert.areEqual(0, errors, 'excludeInactiveLookupRecords - errors found');
    }

    @IsTest
    private static void excludeInactiveLookupRecords_false_expectSuccess() {
        FObject.setSeed(1);
        Boolean isException = false;

        // insert active users
        FObject objUser = new FObject('User', 2)
            .setRequiredFields(true);
        try {
            objUser.insertRecords(true, 'active');
        } catch (Exception exp) {
            isException = true;
        }

        if (!isException) {
            isException = insertInactiveUsers(objUser);
        }

        Test.startTest();

        if (!isException) {
            isException = insertFromExcludedInactive(false);
        }

        Test.stopTest();

        Integer errors = 0;
        if (!isException) {
            Integer count = 0;
            for (FObjectFour__c record : [SELECT TestLookupUser__r.IsActive FROM FObjectFour__c]) {
                if (record.TestLookupUser__r.IsActive) {
                    count++;
                }
            }
            if (count == 0) {
                errors++;
            }
        }

        Assert.areEqual(0, errors, 'excludeInactiveLookupRecords - errors found');
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
        Integer errors = 0;

        Map<String, List<Database.SaveResult>> saveResults = new Map<String, List<Database.SaveResult>>();
        Boolean isException = false;

        try {
            saveResults = FObject.insertRecordsFromTemplate(template, true);
        } catch (Exception exp) {
            isException = true;
        }

        Integer dmlStatements = Limits.getDmlStatements();

        Test.stopTest();

        if (!isException) {

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
        }

        Assert.areEqual(0, errors, 'insertRecordsFromTemplate - errors found');
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

        Integer errors = 0;
        Integer dmlErrors = 0;
        try {
            obj.insertRecords(true);
            Integer counter = 1;
            for (PricebookEntry record : [SELECT UnitPrice FROM PricebookEntry]) {
                if (record.UnitPrice != counter) {
                    errors++;
                }
                counter++;
            }
        } catch (DmlException exp) {
            dmlErrors++;
        }

        Test.stopTest();

        Assert.areEqual(0, errors, 'setStandardPricebookEntries - errors found');
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

    /* UTILITY METHODS */

    private static Boolean insertInactiveUsers(FObject objUser) {
        Boolean isException = false;

        objUser
            .setNumberOfRecords(2)
            .setDefinition(User.IsActive, 'static value(false)');

        try {
            objUser.insertRecords(true, 'inactive');
        } catch (Exception exp) {
            isException = true;
        }

        return isException;
    }

    private static Boolean insertFromExcludedInactive(Boolean exclude) {
        Boolean isException = false;

        FObject obj = new FObject(FObjectFour__c.SObjectType, 10)
            .excludeInactiveLookupRecords(exclude)
            .setDefinition(FObjectFour__c.TestLookupUser__c, 'random lookup(User) source(salesforce)');

        try {
            obj.insertRecords(true);
        } catch (Exception exp) {
            isException = true;
        }

        return isException;
    }

}