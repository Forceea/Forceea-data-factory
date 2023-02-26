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
public class ForceeaGeneratorFunctionTest {

    @IsTest
    private static void functionAdd_refTextField_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestInteger__c, 'random type(number) from(1) to(10) scale(0)')
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(date) from(2020-1-1) step(1)')
            .setDefinition(FObjectOne__c.TestText__c, 'function-add field(TestInteger__c)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        if (!FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'function - errors found');
    }

    @IsTest
    private static void functionAdd_refMixedField_expectSuccess() {
        Datetime now = Datetime.now();

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType)
            .setNumberOfRecords('auto')
            .setVariable('today', Date.today())
            .setVariable('now', now)
            .setDefinition('$Integer', 'static value(1)')
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(list) value(1,{@today},{@now},Test) mode(permutation)')
            .setDefinition(FObjectOne__c.TestText__c, 'function-add field($Integer)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        if (records.get(0).TestText__c != '2') {
            errors += 1;
        }
        if (records.get(1).TestText__c != String.valueOf(Date.today().addDays(1))) {
            errors += 2;
        }

        String actualDatetime = records.get(2).TestText__c;
        Decimal value = now.getTime() + 86400 * 1000;
        Datetime calculatedDatetime = Datetime.newInstance((Long) value);
        if (actualDatetime != String.valueOf(calculatedDatetime)) {
            errors += 4;
        }
        if (records.get(3).TestText__c != 'Test') {
            errors += 8;
        }
        System.assertEquals(0, errors, 'function - errors found');
    }

    @IsTest
    private static void functionAdd_refFromIntStepInt_fieldStepIntStepIntScale0_expectSuccess() {
        Decimal refFrom = 1000;
        Decimal refStep = 10;
        Integer refScale = 0;
        Decimal fieldFrom = 122;
        Decimal fieldStep = 15;
        Integer fieldScale = 0;

        Decimal calculatedValue = refFrom + fieldFrom;
        Decimal step = refStep + fieldStep;

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestDecimal__c, 'serial type(number) ' +
                'from(' + String.valueOf(refFrom) + ') ' +
                'step(' + String.valueOf(refStep) + ') ' +
                'scale(' + String.valueOf(refScale) + ')')
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(number) ' +
                'from(' + String.valueOf(fieldFrom) + ') ' +
                'step(' + String.valueOf(fieldStep) + ') ' +
                'scale(' + String.valueOf(fieldScale) + ')')
            .setDefinition(FObjectOne__c.TestText__c, 'function-add field(TestDecimal__c)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;

        for (FObjectOne__c objRecord : records) {
            Decimal actualValue = Decimal.valueOf(objRecord.TestText__c);
            if (actualValue != calculatedValue.setScale(fieldScale) || actualValue.scale() != fieldScale) {
                errors++;
            }
            calculatedValue += step;
        }
    }

    @IsTest
    private static void functionAdd_refFromIntStepInt_fieldStepDecStepIntScale1_expectSuccess() {
        Decimal refFrom = 1000;
        Decimal refStep = 10;
        Integer refScale = 0;
        Decimal fieldFrom = 122.1;
        Decimal fieldStep = 11;
        Integer fieldScale = 1;

        Decimal calculatedValue = refFrom + fieldFrom;
        Decimal step = refStep + fieldStep;

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestDecimal__c, 'serial type(number) ' +
                'from(' + String.valueOf(refFrom) + ') ' +
                'step(' + String.valueOf(refStep) + ') ' +
                'scale(' + String.valueOf(refScale) + ')')
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(number) ' +
                'from(' + String.valueOf(fieldFrom) + ') ' +
                'step(' + String.valueOf(fieldStep) + ') ' +
                'scale(' + String.valueOf(fieldScale) + ')')
            .setDefinition(FObjectOne__c.TestText__c, 'function-add field(TestDecimal__c)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;

        for (FObjectOne__c objRecord : records) {
            Decimal actualValue = Decimal.valueOf(objRecord.TestText__c);
            if (actualValue != calculatedValue.setScale(fieldScale) || actualValue.scale() != fieldScale) {
                errors++;
            }
            calculatedValue += step;
        }
        System.assertEquals(0, errors, 'function - errors found');
    }

    @IsTest
    private static void functionAdd_refFromIntStepInt_fieldStepDecStepDecScale2_expectSuccess() {
        Decimal refFrom = 1000;
        Decimal refStep = 10;
        Integer refScale = 0;
        Decimal fieldFrom = 122.1;
        Decimal fieldStep = 15.2;
        Integer fieldScale = 0;

        Decimal calculatedValue = refFrom + fieldFrom;
        Decimal step = refStep + fieldStep;

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestDecimal__c, 'serial type(number) ' +
                'from(' + String.valueOf(refFrom) + ') ' +
                'step(' + String.valueOf(refStep) + ') ' +
                'scale(' + String.valueOf(refScale) + ')')
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(number) ' +
                'from(' + String.valueOf(fieldFrom) + ') ' +
                'step(' + String.valueOf(fieldStep) + ') ' +
                'scale(' + String.valueOf(fieldScale) + ')')
            .setDefinition(FObjectOne__c.TestText__c, 'function-add field(TestDecimal__c)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;

        for (FObjectOne__c objRecord : records) {
            Decimal actualValue = Decimal.valueOf(objRecord.TestText__c);
            if (actualValue != calculatedValue.setScale(fieldScale) || actualValue.scale() != fieldScale) {
                errors++;
            }
            calculatedValue += step;
        }
        System.assertEquals(0, errors, 'function - errors found');
    }

    @IsTest
    private static void functionAdd_refFromDecStepDec_fieldStepIntStepIntScale0_expectSuccess() {
        Decimal refFrom = 100.2;
        Decimal refStep = 10.1;
        Integer refScale = 1;
        Decimal fieldFrom = 122;
        Decimal fieldStep = 15;
        Integer fieldScale = 0;

        Decimal calculatedValue = refFrom + fieldFrom;
        Decimal step = refStep + fieldStep;

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestDecimal__c, 'serial type(number) ' +
                'from(' + String.valueOf(refFrom) + ') ' +
                'step(' + String.valueOf(refStep) + ') ' +
                'scale(' + String.valueOf(refScale) + ')')
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(number) ' +
                'from(' + String.valueOf(fieldFrom) + ') ' +
                'step(' + String.valueOf(fieldStep) + ') ' +
                'scale(' + String.valueOf(fieldScale) + ')')
            .setDefinition(FObjectOne__c.TestText__c, 'function-add field(TestDecimal__c)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;

        for (FObjectOne__c objRecord : records) {
            Decimal actualValue = Decimal.valueOf(objRecord.TestText__c);
            if (actualValue != calculatedValue.setScale(fieldScale) || actualValue.scale() != fieldScale) {
                errors++;
            }
            calculatedValue += step;
        }
    }

    @IsTest
    private static void functionAdd_refFromDecStepDec_fieldStepDecStepIntScale1_expectSuccess() {
        Decimal refFrom = 100.2;
        Decimal refStep = 10.1;
        Integer refScale = 1;
        Decimal fieldFrom = 122.1;
        Decimal fieldStep = 11;
        Integer fieldScale = 1;

        Decimal calculatedValue = refFrom + fieldFrom;
        Decimal step = refStep + fieldStep;

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestDecimal__c, 'serial type(number) ' +
                'from(' + String.valueOf(refFrom) + ') ' +
                'step(' + String.valueOf(refStep) + ') ' +
                'scale(' + String.valueOf(refScale) + ')')
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(number) ' +
                'from(' + String.valueOf(fieldFrom) + ') ' +
                'step(' + String.valueOf(fieldStep) + ') ' +
                'scale(' + String.valueOf(fieldScale) + ')')
            .setDefinition(FObjectOne__c.TestText__c, 'function-add field(TestDecimal__c)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;

        for (FObjectOne__c objRecord : records) {
            Decimal actualValue = Decimal.valueOf(objRecord.TestText__c);
            if (actualValue != calculatedValue.setScale(fieldScale) || actualValue.scale() != fieldScale) {
                errors++;
            }
            calculatedValue += step;
        }
        System.assertEquals(0, errors, 'function - errors found');
    }

    @IsTest
    private static void functionAdd_refFromDecStepDec_fieldStepDecStepDecScale2_expectSuccess() {
        Decimal refFrom = 100.2;
        Decimal refStep = 10.1;
        Integer refScale = 1;
        Decimal fieldFrom = 122.1;
        Decimal fieldStep = 15.2;
        Integer fieldScale = 2;

        Decimal calculatedValue = refFrom + fieldFrom;
        Decimal step = refStep + fieldStep;

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestDecimal__c, 'serial type(number) ' +
                'from(' + String.valueOf(refFrom) + ') ' +
                'step(' + String.valueOf(refStep) + ') ' +
                'scale(' + String.valueOf(refScale) + ')')
            .setDefinition(FObjectOne__c.TestText__c, 'serial type(number) ' +
                'from(' + String.valueOf(fieldFrom) + ') ' +
                'step(' + String.valueOf(fieldStep) + ') ' +
                'scale(' + String.valueOf(fieldScale) + ')')
            .setDefinition(FObjectOne__c.TestText__c, 'function-add field(TestDecimal__c)');
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;

        for (FObjectOne__c objRecord : records) {
            Decimal actualValue = Decimal.valueOf(objRecord.TestText__c);
            if (actualValue != calculatedValue.setScale(fieldScale) || actualValue.scale() != fieldScale) {
                errors++;
            }
            calculatedValue += step;
        }
        System.assertEquals(0, errors, 'function - errors found');
    }

    @IsTest
    private static void functionAdd_daysValidForDate_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestInteger__c, 'serial type(number) from(1) step(1.8) scale(1)')
            .setDefinition(FObjectOne__c.TestDate__c, 'serial type(date) from(2020-1-1) step(1)')
            .setDefinition(FObjectOne__c.TestDate__c, 'function-add field(TestInteger__c)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        Decimal step = 1.8;
        Decimal daysToAddDecimal = 1;
        Integer daysToAddInteger = 1;
        Date serialDate = Date.newInstance(2020, 1, 1);
        Date calculatedDate = Date.newInstance(2020, 1, 1);

        for (FObjectOne__c objRecord : records) {
            Date actualDate = objRecord.TestDate__c;
            daysToAddInteger = (Integer) daysToAddDecimal.round(System.RoundingMode.HALF_DOWN);
            calculatedDate = serialDate.addDays(daysToAddInteger);

            if (actualDate != calculatedDate) {
                errors++;
            }
            daysToAddDecimal += step;
            serialDate = serialDate.addDays(1);
        }
        System.assertEquals(0, errors, 'function - errors found');
    }

    @IsTest
    private static void functionAdd_daysValidForDatetime_expectSuccess() {
        Datetime now = Datetime.newInstance(2020, 1, 1, 15, 12, 33);
        FObject.setGlobalVariable('now', now);
        Decimal step = 1.52;

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition('$Days', 'serial type(number) from(1) step(' + String.valueOf(step) + ') scale(2)')
            .setDefinition(FObjectOne__c.TestDatetime__c, 'static value({@now})')
            .setDefinition(FObjectOne__c.TestDatetime__c, 'function-add field($Days)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj.insertRecords(true);
        Test.stopTest();

        Integer errors = 0;
        Decimal daysToAdd = 1;
        Datetime calculatedDatetime = Datetime.now();

        for (FObjectOne__c objRecord : [SELECT TestDatetime__c FROM FObjectOne__c]) {
            Datetime actualDatetime = objRecord.TestDatetime__c;
            Decimal value = now.getTime() + daysToAdd * 86400 * 1000;
            calculatedDatetime = Datetime.newInstance((Long) value);

            if (actualDatetime != calculatedDatetime) {
                errors++;
            }
            daysToAdd += step;
        }
        System.assertEquals(0, errors, 'function - errors found');
    }

    @IsTest
    private static void functionAdd_daysInvalid_expectFailure() {
        FObject.setExceptionHandling('continue');

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestInteger__c, 'random type(number) from(10) to(5) scale(2)')
            .setDefinition(FObjectOne__c.TestDate__c, 'serial type(date) from(2020-1-1) step(1)')
            .setDefinition(FObjectOne__c.TestDate__c, 'function-add field(TestInteger__c)');
        obj.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        if (FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'function - errors found');
    }

    @IsTest
    private static void functionAdd_refFieldIsInvalid_expectFailure() {
        FObject.setExceptionHandling('continue');

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestInteger__c, 'random type(number) from(1) to(5) scale(2)')
            .setDefinition(FObjectOne__c.TestDate__c, 'serial type(date) from(2020-1-1) step(1)')
            .setDefinition(FObjectOne__c.TestDate__c, 'function-add field(TestInteger)');
        obj.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        if (FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'function - errors found');
    }

    @IsTest
    private static void functionAdd_refFieldIsNotNumber_expectFailure() {
        FObject.setExceptionHandling('continue');

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestInteger__c, 'random type(list) value(a,b,c)')
            .setDefinition(FObjectOne__c.TestDate__c, 'serial type(date) from(2020-1-1) step(1)')
            .setDefinition(FObjectOne__c.TestDate__c, 'function-add field(TestInteger)');
        obj.insertRecords(true);
        List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
        Test.stopTest();

        Integer errors = 0;
        if (FObject.processIsValid()) {
            errors++;
        }
        System.assertEquals(0, errors, 'function - errors found');
    }

    @IsTest
    private static void functionConvert_lowercase_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestText__c,
                'random type(string) minLength(20) maxLength(20) startWith(upper) include(lower,upper)')
            .setDefinition(FObjectOne__c.TestText__c, 'function-convert to(lower)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj.insertRecords(true);
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c record : (List<FObjectOne__c>) obj.getRecords()) {
            if (!record.TestText__c.isAllLowerCase()) {
                errors++;
                break;
            }
        }
        System.assertEquals(0, errors, 'function - errors found');
    }

    @IsTest
    private static void functionConvert_uppercase_expectSuccess() {
        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestText__c,
                'random type(string) minLength(20) maxLength(20) startWith(upper) include(lower,upper)')
            .setDefinition(FObjectOne__c.TestText__c, 'function-convert to(upper)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj.insertRecords(true);
        Test.stopTest();

        Integer errors = 0;
        for (FObjectOne__c record : (List<FObjectOne__c>) obj.getRecords()) {
            if (!record.TestText__c.isAllUpperCase()) {
                errors++;
                break;
            }
        }
        System.assertEquals(0, errors, 'function - errors found');
    }

    @IsTest
    private static void functionConvert_invalidArgument_expectFailure() {
        FObject.setExceptionHandling('continue');

        Test.startTest();
        FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
            .setDefinition(FObjectOne__c.TestText__c,
                'random type(string) minLength(20) maxLength(20) startWith(upper) include(lower,upper)')
            .setDefinition(FObjectOne__c.TestText__c, 'function-convert to(xyz)')
            .setDefinition(FObjectOne__c.TestTextRequired__c, 'static value(test)');
        obj.insertRecords(true);
        Test.stopTest();

        Integer errors = 0;
        for (String error : obj.getErrors().get('TestText__c')) {
            if (!error.contains('Invalid parameter [xyz] in definition [function-convert to(xyz)]')) {
                errors++;
            }
        }
        System.assertEquals(0, errors, 'function - errors found');
    }

}
