/*
  Forceea data factory (v2.1.0)
  Copyright (C) 2020 Nikos Mitrakis

  This program is free software: you can redistribute it and/or modify it under the terms
  of the GNU General Public License as published by the Free Software Foundation,
  either version 3 of the License, or any later version.

  This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
  without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  See the GNU General Public License for more details.

  You can find a copy of the GNU General Public License at
  https://github.com/nmitrakis/Forceea/blob/master/LICENSE
*/
@IsTest
public class ForceeaGeneratorStaticTest {

	@IsTest
	private static void staticBoolean_valid_expectSuccess() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition(FObjectOne__c.TestCheckbox__c, 'static value(true)');
		List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
		Test.stopTest();

		Integer errors = 0;
		for (FObjectOne__c objRecord : records) {
			if (objRecord.TestCheckbox__c != true) {
				errors++;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

	@IsTest
	private static void staticBoolean_virtualField_expectSuccess() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition('$Test', 'static value(true)')
			.setDefinition(FObjectOne__c.TestCheckbox__c, 'copy field($Test)');
		List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
		Test.stopTest();

		Integer errors = 0;
		for (FObjectOne__c objRecord : records) {
			if (objRecord.TestCheckbox__c != true) {
				errors++;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

	@IsTest
	private static void staticBoolean_insertBlank_expectFailure() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition(FObjectOne__c.TestCheckbox__c, 'static value("")');
		List<FObjectOne__c> records = obj.getRecords();
		Test.stopTest();

		Integer errors = 0;
		String errorMessage = 'Invalid definition [static value("")] for the data type of field [TestCheckbox__c]';
		if (!obj.getErrors().get('TestCheckbox__c').isEmpty() &&
			!obj.getErrors().get('TestCheckbox__c').get(0).contains(errorMessage)) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

	@IsTest
	private static void staticBoolean_updateBlank_expectFailure() {
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition(FObjectOne__c.TestCheckbox__c, 'static value(true)');
		obj.insertRecords(true);

		Test.startTest();
		obj
			.setDefinitionForUpdate(FObjectOne__c.TestCheckbox__c, 'static value("")')
			.updateFields()
			.updateRecords(true);
		Test.stopTest();

		Integer errors = 0;
		String errorMessage = 'Invalid definition [static value("")] for the data type of field [TestCheckbox__c]';
		if (!obj.getErrors().get('TestCheckbox__c').isEmpty() &&
			!obj.getErrors().get('TestCheckbox__c').get(0).contains(errorMessage)) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

	@IsTest
	private static void staticCurrency_valid_expectSuccess() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition(FObjectOne__c.TestCurrency__c, 'static value(10.11)');
		List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
		Test.stopTest();

		Integer errors = 0;
		for (FObjectOne__c objRecord : records) {
			if (objRecord.TestCurrency__c != 10.11) {
				errors++;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

	@IsTest
	private static void staticCurrency_virtualField_expectSuccess() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition('$Test', 'static value(10.11)')
			.setDefinition(FObjectOne__c.TestCurrency__c, 'copy field($Test)');
		List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
		Test.stopTest();

		Integer errors = 0;
		for (FObjectOne__c objRecord : records) {
			if (objRecord.TestCurrency__c != 10.11) {
				errors++;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

	@IsTest
	private static void staticCurrency_insertBlank_expectSuccess() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition(FObjectOne__c.TestCurrency__c, 'static value("")');
		obj.insertRecords(true);
		Test.stopTest();

		Integer errors = 0;
		for (FObjectOne__c objRecord : [SELECT TestCurrency__c FROM FObjectOne__c]) {
			if (objRecord.TestCurrency__c != null) {
				errors++;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

	@IsTest
	private static void staticCurrency_updateBlank_expectSuccess() {
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition(FObjectOne__c.TestCurrency__c, 'static value(10.11)');
		obj.insertRecords(true);

		Test.startTest();
		obj
			.setDefinitionForUpdate(FObjectOne__c.TestCurrency__c, 'static value("")')
			.updateFields()
			.updateRecords(true);
		Test.stopTest();

		Integer errors = 0;
		for (FObjectOne__c objRecord : [SELECT TestCurrency__c FROM FObjectOne__c]) {
			if (objRecord.TestCurrency__c != null) {
				errors++;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

	@IsTest
	private static void staticDate_valid_expectSuccess() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition(FObjectOne__c.TestDate__c, 'static value(2018-10-01)');
		List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
		Test.stopTest();

		Integer errors = 0;
		Date dt = Date.newInstance(2018, 10, 1);
		for (FObjectOne__c objRecord : records) {
			if (objRecord.TestDate__c != dt) {
				errors++;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

	@IsTest
	private static void staticDate_virtualField_expectSuccess() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition('$Test', 'static value(2018-10-01)')
			.setDefinition(FObjectOne__c.TestDate__c, 'copy field($Test)');
		List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
		Test.stopTest();

		Integer errors = 0;
		Date dt = Date.newInstance(2018, 10, 1);
		for (FObjectOne__c objRecord : records) {
			if (objRecord.TestDate__c != dt) {
				errors++;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

	@IsTest
	private static void staticDate_insertBlank_expectSuccess() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition(FObjectOne__c.TestDate__c, 'static value("")');
		obj.insertRecords(true);
		Test.stopTest();

		Integer errors = 0;
		for (FObjectOne__c objRecord : [SELECT TestDate__c FROM FObjectOne__c]) {
			if (objRecord.TestDate__c != null) {
				errors++;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

	@IsTest
	private static void staticDate_updateBlank_expectSuccess() {
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition(FObjectOne__c.TestDate__c, 'static value(2018-10-01)');
		obj.insertRecords(true);

		Test.startTest();
		obj
			.setDefinitionForUpdate(FObjectOne__c.TestDate__c, 'static value("")')
			.updateFields()
			.updateRecords(true);
		Test.stopTest();

		Integer errors = 0;
		for (FObjectOne__c objRecord : [SELECT TestDate__c FROM FObjectOne__c]) {
			if (objRecord.TestDate__c != null) {
				errors++;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

	@IsTest
	private static void staticDatetime_valid_expectSuccess() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition(FObjectOne__c.TestDatetime__c, 'static value(2018-10-01 01:01:01)');
		List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
		Test.stopTest();

		Integer errors = 0;
		Datetime dt = Datetime.newInstance(2018, 10, 1, 1, 1, 1);
		for (FObjectOne__c objRecord : records) {
			if (objRecord.TestDatetime__c != dt) {
				errors++;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

	@IsTest
	private static void staticDatetime_virtualField_expectSuccess() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition('$Test', 'static value(2018-10-01 01:01:01)')
			.setDefinition(FObjectOne__c.TestDatetime__c, 'copy field($Test)');
		List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
		Test.stopTest();

		Integer errors = 0;
		Datetime dt = Datetime.newInstance(2018, 10, 1, 1, 1, 1);
		for (FObjectOne__c objRecord : records) {
			if (objRecord.TestDatetime__c != dt) {
				errors++;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

	@IsTest
	private static void staticDatetime_insertBlank_expectSuccess() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition(FObjectOne__c.TestDatetime__c, 'static value("")');
		obj.insertRecords(true);
		Test.stopTest();

		Integer errors = 0;
		for (FObjectOne__c objRecord : [SELECT TestDatetime__c FROM FObjectOne__c]) {
			if (objRecord.TestDatetime__c != null) {
				errors++;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

	@IsTest
	private static void staticDatetime_updateBlank_expectSuccess() {
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition(FObjectOne__c.TestDatetime__c, 'static value(2018-10-01 01:01:01)');
		obj.insertRecords(true);

		Test.startTest();
		obj
			.setDefinitionForUpdate(FObjectOne__c.TestDatetime__c, 'static value("")')
			.updateFields()
			.updateRecords(true);
		Test.stopTest();

		Integer errors = 0;
		for (FObjectOne__c objRecord : [SELECT TestDatetime__c FROM FObjectOne__c]) {
			if (objRecord.TestDatetime__c != null) {
				errors++;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

	@IsTest
	private static void staticTime_valid_expectSuccess() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition(FObjectOne__c.TestTime__c, 'static value(01:01:01)');
		List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
		Test.stopTest();

		Integer errors = 0;
		Time dt = Time.newInstance(1, 1, 1, 0);
		for (FObjectOne__c objRecord : records) {
			if (objRecord.TestTime__c != dt) {
				errors++;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

	@IsTest
	private static void staticTime_virtualField_expectSuccess() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition('$Test', 'static value(01:01:01)')
			.setDefinition(FObjectOne__c.TestTime__c, 'copy field($Test)');
		List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
		Test.stopTest();

		Integer errors = 0;
		Time dt = Time.newInstance(1, 1, 1, 0);
		for (FObjectOne__c objRecord : records) {
			if (objRecord.TestTime__c != dt) {
				errors++;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

	@IsTest
	private static void staticTime_insertBlank_expectSuccess() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition(FObjectOne__c.TestTime__c, 'static value("")');
		obj.insertRecords(true);
		Test.stopTest();

		Integer errors = 0;
		for (FObjectOne__c objRecord : [SELECT TestTime__c FROM FObjectOne__c]) {
			if (objRecord.TestTime__c != null) {
				errors++;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

	@IsTest
	private static void staticTime_updateBlank_expectSuccess() {
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition(FObjectOne__c.TestTime__c, 'static value(01:01:01)');
		obj.insertRecords(true);

		Test.startTest();
		obj
			.setDefinitionForUpdate(FObjectOne__c.TestTime__c, 'static value("")')
			.updateFields()
			.updateRecords(true);
		Test.stopTest();

		Integer errors = 0;
		for (FObjectOne__c objRecord : [SELECT TestTime__c FROM FObjectOne__c]) {
			if (objRecord.TestTime__c != null) {
				errors++;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

	@IsTest
	private static void staticDecimal_valid_expectSuccess() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition(FObjectOne__c.TestDecimal__c, 'static value(100000.11)');
		List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
		Test.stopTest();

		Integer errors = 0;
		for (FObjectOne__c objRecord : records) {
			if (objRecord.TestDecimal__c != 100000.11) {
				errors++;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

	@IsTest
	private static void staticDecimal_virtualField_expectSuccess() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition('$Test', 'static value(100000.11)')
			.setDefinition(FObjectOne__c.TestDecimal__c, 'copy field($Test)');
		List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
		Test.stopTest();

		Integer errors = 0;
		for (FObjectOne__c objRecord : records) {
			if (objRecord.TestDecimal__c != 100000.11) {
				errors++;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

	@IsTest
	private static void staticDecimal_insertBlank_expectSuccess() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition(FObjectOne__c.TestDecimal__c, 'static value("")');
		obj.insertRecords(true);
		Test.stopTest();

		Integer errors = 0;
		for (FObjectOne__c objRecord : [SELECT TestDecimal__c FROM FObjectOne__c]) {
			if (objRecord.TestDecimal__c != null) {
				errors++;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

	@IsTest
	private static void staticDecimal_updateBlank_expectSuccess() {
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition(FObjectOne__c.TestDecimal__c, 'static value(123)');
		obj.insertRecords(true);

		Test.startTest();
		obj
			.setDefinitionForUpdate(FObjectOne__c.TestDecimal__c, 'static value("")')
			.updateFields()
			.updateRecords(true);
		Test.stopTest();

		Integer errors = 0;
		for (FObjectOne__c objRecord : [SELECT TestDecimal__c FROM FObjectOne__c]) {
			if (objRecord.TestDecimal__c != null) {
				errors++;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

	@IsTest
	private static void staticEmail_valid_expectSuccess() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition(FObjectOne__c.TestEmail__c, 'static value(user@example.com)');
		List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
		Test.stopTest();

		Integer errors = 0;
		for (FObjectOne__c objRecord : records) {
			if (objRecord.TestEmail__c != 'user@example.com') {
				errors++;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

	@IsTest
	private static void staticEmail_virtualField_expectSuccess() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition('$Test', 'static value(user@example.com)')
			.setDefinition(FObjectOne__c.TestEmail__c, 'copy field($Test)');
		List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
		Test.stopTest();

		Integer errors = 0;
		for (FObjectOne__c objRecord : records) {
			if (objRecord.TestEmail__c != 'user@example.com') {
				errors++;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

	@IsTest
	private static void staticEmail_insertBlank_expectSuccess() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition(FObjectOne__c.TestEmail__c, 'static value("")');
		obj.insertRecords(true);
		Test.stopTest();

		Integer errors = 0;
		for (FObjectOne__c objRecord : [SELECT TestEmail__c FROM FObjectOne__c]) {
			if (String.isNotBlank(objRecord.TestEmail__c)) {
				errors++;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

	@IsTest
	private static void staticEmail_updateBlank_expectSuccess() {
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition(FObjectOne__c.TestEmail__c, 'static value(user@example.com)');
		obj.insertRecords(true);

		Test.startTest();
		obj
			.setDefinitionForUpdate(FObjectOne__c.TestEmail__c, 'static value("")')
			.updateFields()
			.updateRecords(true);
		Test.stopTest();

		Integer errors = 0;
		for (FObjectOne__c objRecord : [SELECT TestEmail__c FROM FObjectOne__c]) {
			if (String.isNotBlank(objRecord.TestEmail__c)) {
				errors++;
				break;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

	@IsTest
	private static void staticId_valid_expectFailure() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition(FObjectOne__c.Id, 'static value(a0F0E000009ICSaUAO)');
		List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
		Test.stopTest();

		String expectedResult = 'Invalid definition [static value(a0F0E000009ICSaUAO)] for the data type of field [Id]';
		String actualResult = obj.getErrors().get('Id').get(0);
		System.assertEquals(expectedResult, actualResult, 'static value - errors found');
	}

	@IsTest
	private static void staticId_virtualField_expectFailure() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition('$Test', 'static value(a0F0E000009ICSaUAO)')
			.setDefinition(FObjectOne__c.Id, 'copy field($Test)');
		List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
		Test.stopTest();

		String expectedResult = 'Invalid definition [copy field($Test)] for the data type of field [Id]';
		String actualResult = obj.getErrors().get('Id').get(0);
		System.assertEquals(expectedResult, actualResult, 'static value - errors found');
	}

	@IsTest
	private static void staticId_insertBlank_expectSuccess() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition(FObjectOne__c.Id, 'static value("")');
		List<FObjectOne__c> records = obj.getRecords();
		Test.stopTest();

		Integer errors = 0;
		String errorMessage = 'Invalid definition [static value("")] for the data type of field [Id]';
		if (!obj.getErrors().get('Id').isEmpty() && !obj.getErrors().get('Id').get(0).contains(errorMessage)) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

	@IsTest
	private static void staticId_updateBlank_expectSuccess() {
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
		obj.insertRecords(true);

		Test.startTest();
		obj
			.setDefinitionForUpdate(FObjectOne__c.Id, 'static value("")')
			.updateFields()
			.updateRecords(true);
		Test.stopTest();

		Integer errors = 0;
		String errorMessage = 'Invalid definition [static value("")] for the data type of field [Id]';
		if (!obj.getErrors().get('Id').isEmpty() && !obj.getErrors().get('Id').get(0).contains(errorMessage)) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

	@IsTest
	private static void staticInteger_valid_expectSuccess() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition(FObjectOne__c.TestInteger__c, 'static value(123)');
		List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
		Test.stopTest();

		Integer errors = 0;
		for (FObjectOne__c objRecord : records) {
			if (objRecord.TestInteger__c != 123) {
				errors++;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

	@IsTest
	private static void staticInteger_virtualField_expectSuccess() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition('$Test', 'static value(123)')
			.setDefinition(FObjectOne__c.TestInteger__c, 'copy field($Test)');
		List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
		Test.stopTest();

		Integer errors = 0;
		for (FObjectOne__c objRecord : records) {
			if (objRecord.TestInteger__c != 123) {
				errors++;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

	@IsTest
	private static void staticInteger_insertBlank_expectSuccess() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition(FObjectOne__c.TestInteger__c, 'static value("")');
		obj.insertRecords(true);
		Test.stopTest();

		Integer errors = 0;
		for (FObjectOne__c objRecord : [SELECT TestInteger__c FROM FObjectOne__c]) {
			if (objRecord.TestInteger__c != null) {
				errors++;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

	@IsTest
	private static void staticInteger_updateBlank_expectSuccess() {
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition(FObjectOne__c.TestInteger__c, 'static value(123)');
		obj.insertRecords(true);

		Test.startTest();
		obj
			.setDefinitionForUpdate(FObjectOne__c.TestInteger__c, 'static value("")')
			.updateFields()
			.updateRecords(true);
		Test.stopTest();

		Integer errors = 0;
		for (FObjectOne__c objRecord : [SELECT TestInteger__c FROM FObjectOne__c]) {
			if (objRecord.TestInteger__c != null) {
				errors++;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

	@IsTest
	private static void staticPercent_valid_expectSuccess() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition(FObjectOne__c.TestPercent__c, 'static value(10.11)');
		List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
		Test.stopTest();

		Integer errors = 0;
		for (FObjectOne__c objRecord : records) {
			if (objRecord.TestPercent__c != 10.11) {
				errors++;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

	@IsTest
	private static void staticPercent_virtualField_expectSuccess() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition('$Test', 'static value(10.11)')
			.setDefinition(FObjectOne__c.TestPercent__c, 'copy field($Test)');
		List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
		Test.stopTest();

		Integer errors = 0;
		for (FObjectOne__c objRecord : records) {
			if (objRecord.TestPercent__c != 10.11) {
				errors++;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

	@IsTest
	private static void staticPercent_insertBlank_expectSuccess() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition(FObjectOne__c.TestPercent__c, 'static value("")');
		obj.insertRecords(true);
		Test.stopTest();

		Integer errors = 0;
		for (FObjectOne__c objRecord : [SELECT TestPercent__c FROM FObjectOne__c]) {
			if (objRecord.TestPercent__c != null) {
				errors++;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

	@IsTest
	private static void staticPercent_updateBlank_expectSuccess() {
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition(FObjectOne__c.TestPercent__c, 'static value(10.11)');
		obj.insertRecords(true);

		Test.startTest();
		obj
			.setDefinitionForUpdate(FObjectOne__c.TestPercent__c, 'static value("")')
			.updateFields()
			.updateRecords(true);
		Test.stopTest();

		Integer errors = 0;
		for (FObjectOne__c objRecord : [SELECT TestPercent__c FROM FObjectOne__c]) {
			if (objRecord.TestPercent__c != null) {
				errors++;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

	@IsTest
	private static void staticPicklist_virtualField_expectSuccess() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition('$Test', 'static value(a1)')
			.setDefinition(FObjectOne__c.TestPicklistA__c, 'copy field($Test)');
		List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
		Test.stopTest();

		Integer errors = 0;
		for (FObjectOne__c objRecord : records) {
			if (objRecord.TestPicklistA__c != 'a1') {
				errors++;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

	@IsTest
	private static void staticPicklist_validValueForRestrictedIndependentPicklistField_expectSuccess() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition(FObjectOne__c.TestPicklistA__c, 'static value(A1)');
		List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
		Test.stopTest();

		Integer errors = 0;
		for (FObjectOne__c objRecord : records) {
			if (objRecord.TestPicklistA__c != 'a1') {
				errors++;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

	@IsTest
	private static void staticPicklist_invalidValueForRestrictedIndependentPicklistField_expectSuccess() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition(FObjectOne__c.TestPicklistA__c, 'static value(a10)');
		List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
		Test.stopTest();

		Integer errors = 0;
		for (FObjectOne__c objRecord : records) {
			if (String.isNotBlank(objRecord.TestPicklistA__c)) {
				errors++;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

	@IsTest
	private static void staticPicklist_validValueForRestrictedDependentPicklistField_expectSuccess() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition(FObjectOne__c.TestPicklistB__c, 'static value(B2)');
		List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
		Test.stopTest();

		Integer errors = 0;
		for (FObjectOne__c objRecord : records) {
			if (!(String.isBlank(objRecord.TestPicklistB__c) || objRecord.TestPicklistB__c == 'b2')) {
				errors++;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

	@IsTest
	private static void staticPicklist_invalidValueForRestrictedDependentPicklistField_expectSuccess() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition(FObjectOne__c.TestPicklistB__c, 'static value(b10)');
		List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
		Test.stopTest();

		Integer errors = 0;
		for (FObjectOne__c objRecord : records) {
			if (String.isNotBlank(objRecord.TestPicklistB__c)) {
				errors++;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

	@IsTest
	private static void staticPicklist_validValueForUnrestrictedIndependentPicklistField_expectSuccess() {
		Test.startTest();
		FObject obj = new FObject(FObjectTwo__c.SObjectType, 10)
			.setDefinition('TestPicklistEUnrestricted__c', 'static value(e1)');
		List<FObjectTwo__c> records = (List<FObjectTwo__c>) obj.getRecords();
		Test.stopTest();

		Integer errors = 0;
		for (FObjectTwo__c objRecord : records) {
			if (objRecord.TestPicklistEUnrestricted__c != 'e1') {
				errors++;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

	@IsTest
	private static void staticPicklist_invalidValueForUnrestrictedIndependentPicklistField_expectSuccess() {
		Test.startTest();
		FObject obj = new FObject(FObjectTwo__c.SObjectType, 10)
			.setDefinition('TestPicklistEUnrestricted__c', 'static value(a10)');
		List<FObjectTwo__c> records = (List<FObjectTwo__c>) obj.getRecords();
		Test.stopTest();

		Integer errors = 0;
		for (FObjectTwo__c objRecord : records) {
			if (objRecord.TestPicklistEUnrestricted__c != 'a10') {
				errors++;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

	@IsTest
	private static void staticPicklist_validValueForUnrestrictedDependentPicklistField_expectSuccess() {
		Test.startTest();
		FObject obj = new FObject(FObjectTwo__c.SObjectType, 10)
			.setDefinition('TestPicklistFUnrestricted__c', 'static value(f2)');
		List<FObjectTwo__c> records = (List<FObjectTwo__c>) obj.getRecords();
		Test.stopTest();

		Integer errors = 0;
		for (FObjectTwo__c objRecord : records) {
			if (!(String.isBlank(objRecord.TestPicklistFUnrestricted__c) || objRecord.TestPicklistFUnrestricted__c == 'f2')) {
				errors++;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

	@IsTest
	private static void staticPicklist_invalidValueForUnrestrictedDependentPicklistField_expectSuccess() {
		Test.startTest();
		FObject obj = new FObject(FObjectTwo__c.SObjectType, 10)
			.setDefinition('TestPicklistFUnrestricted__c', 'static value(a10)');
		List<FObjectTwo__c> records = (List<FObjectTwo__c>) obj.getRecords();
		Test.stopTest();

		Integer errors = 0;
		for (FObjectTwo__c objRecord : records) {
			if (String.isNotBlank(objRecord.TestPicklistFUnrestricted__c)) {
				errors++;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

	@IsTest
	private static void staticPicklist_controllingFieldIsCheckbox_expectSuccess() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition(FObjectOne__c.TestCheckbox__c, 'static value(true)')
			.setDefinition(FObjectOne__c.TestPicklistD__c, 'static value(d2)');
		List<Database.SaveResult> saveResults = obj.insertRecords(false);
		Test.stopTest();

		Integer errors = 0;
		for (Database.SaveResult sr : saveResults) {
			if (!sr.isSuccess()) {
				errors++;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'random static - errors found');
	}

	@IsTest
	private static void staticPicklist_insertBlank_expectSuccess() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition(FObjectOne__c.TestPicklistA__c, 'static value("")');
		obj.insertRecords(true);
		Test.stopTest();

		Integer errors = 0;
		for (FObjectOne__c objRecord : [SELECT TestPicklistA__c FROM FObjectOne__c]) {
			if (String.isNotBlank(objRecord.TestPicklistA__c)) {
				errors++;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

	@IsTest
	private static void staticPicklist_updateBlank_expectSuccess() {
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition(FObjectOne__c.TestPicklistA__c, 'static value(a1)');
		obj.insertRecords(true);

		Test.startTest();
		obj
			.setDefinitionForUpdate(FObjectOne__c.TestPicklistA__c, 'static value("")')
			.updateFields()
			.updateRecords(true);
		Test.stopTest();

		Integer errors = 0;
		for (FObjectOne__c objRecord : [SELECT TestPicklistA__c FROM FObjectOne__c]) {
			if (String.isNotBlank(objRecord.TestPicklistA__c)) {
				errors++;
				break;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

	@IsTest
	private static void staticPhone_valid_expectSuccess() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition(FObjectOne__c.TestPhone__c, 'static value(123 123 123)');
		List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
		Test.stopTest();

		Integer errors = 0;
		for (FObjectOne__c objRecord : records) {
			if (objRecord.TestPhone__c != '123 123 123') {
				errors++;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

	@IsTest
	private static void staticPhone_virtualField_expectSuccess() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition('$Test', 'static value(123 123 123)')
			.setDefinition(FObjectOne__c.TestPhone__c, 'copy field($Test)');
		List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
		Test.stopTest();

		Integer errors = 0;
		for (FObjectOne__c objRecord : records) {
			if (objRecord.TestPhone__c != '123 123 123') {
				errors++;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

	@IsTest
	private static void staticPhone_insertBlank_expectSuccess() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition(FObjectOne__c.TestPhone__c, 'static value("")');
		obj.insertRecords(true);
		Test.stopTest();

		Integer errors = 0;
		for (FObjectOne__c objRecord : [SELECT TestPhone__c FROM FObjectOne__c]) {
			if (String.isNotBlank(objRecord.TestPhone__c)) {
				errors++;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

	@IsTest
	private static void staticPhone_updateBlank_expectSuccess() {
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition(FObjectOne__c.TestPhone__c, 'static value(123 123 123)');
		obj.insertRecords(true);

		Test.startTest();
		obj
			.setDefinitionForUpdate(FObjectOne__c.TestPhone__c, 'static value("")')
			.updateFields()
			.updateRecords(true);
		Test.stopTest();

		Integer errors = 0;
		for (FObjectOne__c objRecord : [SELECT TestPhone__c FROM FObjectOne__c]) {
			if (String.isNotBlank(objRecord.TestPhone__c)) {
				errors++;
				break;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

	@IsTest
	private static void staticRecordType_valid_expectSuccess() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition(FObjectOne__c.RecordTypeId, 'static value(RecordTypeA)');
		List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
		Test.stopTest();

		// get the record type ID of the first record
		Id recordTypeId = records.get(0).RecordTypeId;

		// check if the record type ID exists in every record
		Integer errors = 0;
		for (FObjectOne__c objRecord : records) {
			if (objRecord.RecordTypeId != recordTypeId) {
				errors++;
			}
		}

		// verify the name of the record type
		Map<Id, Schema.RecordTypeInfo> recordTypesMap = Schema.SObjectType.FObjectOne__c.getRecordTypeInfosById();
		String recordTypeName = recordTypesMap.get(recordTypeId).getName();
		if (recordTypeName != 'Record Type A') {
			errors++;
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

	@IsTest
	private static void staticRecordType_invalid_expectFailure() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition(FObjectOne__c.RecordTypeId, 'static value(RecordTypeAX)');
		List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
		Test.stopTest();

		String expectedResult = 'Invalid record type [RecordTypeAX] for definition [static value(RecordTypeAX)]';
		String actualResult = obj.getErrors().get('RecordTypeId').get(0);
		System.assertEquals(expectedResult, actualResult, 'static value - errors found');
	}

	@IsTest
	private static void staticRecordType_insertBlank_expectFailure() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition(FObjectOne__c.RecordTypeId, 'static value("")');
		obj.insertRecords(true);
		Test.stopTest();

		String expectedResult = 'Invalid definition [static value("")] for the data type of field [RecordTypeId]';
		String actualResult = obj.getErrors().get('RecordTypeId').get(0);
		System.assertEquals(expectedResult, actualResult, 'static value - errors found');
	}

	@IsTest
	private static void staticRecordType_updateBlank_expectFailure() {
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition(FObjectOne__c.RecordTypeId, 'static value(RecordTypeA)');
		obj.insertRecords(true);

		Test.startTest();
		obj
			.setDefinitionForUpdate(FObjectOne__c.RecordTypeId, 'static value("")')
			.updateFields()
			.updateRecords(true);
		Test.stopTest();

		String expectedResult = 'Invalid definition [static value("")] for the data type of field [RecordTypeId]';
		String actualResult = obj.getErrors().get('RecordTypeId').get(0);
		System.assertEquals(expectedResult, actualResult, 'static value - errors found');
	}

	@IsTest
	private static void staticString_valid_expectSuccess() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition(FObjectOne__c.TestText__c, 'static value(Sales)');
		List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
		Test.stopTest();

		Integer errors = 0;
		for (FObjectOne__c objRecord : records) {
			if (objRecord.TestText__c != 'Sales') {
				errors++;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

	@IsTest
	private static void staticString_virtualField_expectSuccess() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition('$Test', 'static value(Sales)')
			.setDefinition(FObjectOne__c.TestText__c, 'copy field($Test)');
		List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
		Test.stopTest();

		Integer errors = 0;
		for (FObjectOne__c objRecord : records) {
			if (objRecord.TestText__c != 'Sales') {
				errors++;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

	@IsTest
	private static void staticString_insertBlank_expectSuccess() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition(FObjectOne__c.TestText__c, 'static value("")');
		obj.insertRecords(true);
		Test.stopTest();

		Integer errors = 0;
		for (FObjectOne__c objRecord : [SELECT TestText__c FROM FObjectOne__c]) {
			if (String.isNotBlank(objRecord.TestText__c)) {
				errors++;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

	@IsTest
	private static void staticString_updateBlank_expectSuccess() {
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition(FObjectOne__c.TestText__c, 'static value(test)');
		obj.insertRecords(true);

		Test.startTest();
		obj
			.setDefinitionForUpdate(FObjectOne__c.TestText__c, 'static value("")')
			.updateFields()
			.updateRecords(true);
		Test.stopTest();

		Integer errors = 0;
		for (FObjectOne__c objRecord : [SELECT TestText__c FROM FObjectOne__c]) {
			if (String.isNotBlank(objRecord.TestText__c)) {
				errors++;
				break;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

	@IsTest
	private static void staticString_twoArguments_expectFailure() {
		Test.startTest();
		FObject obj = new FObject(' FObjectOne__c ', 10);
		obj.setDefinition('testtext__c', 'Static Value(One, "Two and Three")');
		List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
		Test.stopTest();

		String expectedResult = 'Invalid definition [Static Value(One, "Two and Three")] of field [TestText__c]';
		String actualResult = obj.getErrors().get('TestText__c').get(0);
		System.assertEquals(expectedResult, actualResult, 'static value - errors found');
	}

	@IsTest
	private static void staticUrl_valid_expectSuccess() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition(FObjectOne__c.TestUrl__c, 'static value(www.example.com)');
		List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
		Test.stopTest();

		Integer errors = 0;
		for (FObjectOne__c objRecord : records) {
			if (objRecord.TestUrl__c != 'www.example.com') {
				errors++;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

	@IsTest
	private static void staticUrl_virtualField_expectSuccess() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition('$Test', 'static value(www.example.com)')
			.setDefinition(FObjectOne__c.TestUrl__c, 'copy field($Test)');
		List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
		Test.stopTest();

		Integer errors = 0;
		for (FObjectOne__c objRecord : records) {
			if (objRecord.TestUrl__c != 'www.example.com') {
				errors++;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

	@IsTest
	private static void staticUrl_insertBlank_expectSuccess() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition(FObjectOne__c.TestUrl__c, 'static value("")');
		obj.insertRecords(true);
		Test.stopTest();

		Integer errors = 0;
		for (FObjectOne__c objRecord : [SELECT TestUrl__c FROM FObjectOne__c]) {
			if (String.isNotBlank(objRecord.TestUrl__c)) {
				errors++;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

	@IsTest
	private static void staticUrl_updateBlank_expectSuccess() {
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition(FObjectOne__c.TestUrl__c, 'static value(www.example.com)');
		obj.insertRecords(true);

		Test.startTest();
		obj
			.setDefinitionForUpdate(FObjectOne__c.TestUrl__c, 'static value("")')
			.updateFields()
			.updateRecords(true);
		Test.stopTest();

		Integer errors = 0;
		for (FObjectOne__c objRecord : [SELECT TestUrl__c FROM FObjectOne__c]) {
			if (String.isNotBlank(objRecord.TestUrl__c)) {
				errors++;
				break;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'static value - errors found');
	}

}
