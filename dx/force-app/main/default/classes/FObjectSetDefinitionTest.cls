/*
  Forceea data factory (v2.1.2)
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
public class FObjectSetDefinitionTest {

	@IsTest
	private static void isValidForFieldDataType_base64_expectFailure() {
		String fieldApiName = 'Body';

		List<String> validDefinitions = new List<String>();
		validDefinitions.add('copy field(TestPicklistD__c)');
		validDefinitions.add('copy field(TestLookup__c) from(FObjectTwo__c.TestText__c)');
		validDefinitions.add('random type(boolean)');
		validDefinitions.add('random type(city) group(one)');
		validDefinitions.add('random type(country) group(one)');
		validDefinitions.add('random type(date) From(2017-01-01) To(2017-12-31)');
		validDefinitions.add('random type(datetime) From(2017-01-01) To(2017-12-31)');
		validDefinitions.add('random type(time) from(05:15:21) to(17:18:22)');
		validDefinitions.add('random type(email)');
		validDefinitions.add('random type(phone) Format(30 210 dD DD ddD)');
		validDefinitions.add('random type(firstName) Group(one)');
		validDefinitions.add('random type(lastName) group(one)');
		validDefinitions.add('random type(list) value(1, 2, 3)');
		validDefinitions.add('random type(list) value(1.1, 2.2, 3.3)');
		validDefinitions.add('random type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
		validDefinitions.add('random type(list) value(2017-01-01, 2017-02-02, 2017-03-03)');
		validDefinitions.add('random type(list) value(One, Two, Three)');
		validDefinitions.add('random type(number) from(1) to(100) scale(0)');
		validDefinitions.add('random type(postalCode) group(one)');
		validDefinitions.add('random type(state) group(one)');
		validDefinitions.add('random type(street) group(one)');
		validDefinitions.add('random type(string) minLength(10) maxLength(30) startWith(lower) include(lower,upper,digit)');
		validDefinitions.add('random type(text) minLength(10) maxlength(30)');
		validDefinitions.add('random type(url)');
		validDefinitions.add('serial type(date) from(2017-01-01) Step(2)');
		validDefinitions.add('serial type(datetime) from(2017-01-01 02:02:02) step(2.2)');
		validDefinitions.add('serial type(list) value(One,Two,Three) mode(cyclical)');
		validDefinitions.add('serial type(number) from(10.2) step(1.2) scale(2)');
		validDefinitions.add('static value(01:01:01)');
		validDefinitions.add('static value(10.1)');
		validDefinitions.add('static value(10)');
		validDefinitions.add('static value(2017-01-01 01:01:01)');
		validDefinitions.add('static value(2017-01-01)');
		validDefinitions.add('static value(One)');
		validDefinitions.add('static value("")');

		List<String> invalidDefinitions = new List<String>();
		invalidDefinitions.add('mock type(id)');
		invalidDefinitions.add('random lookup(Account) field(FieldOne) except(One,Two,Three) source(forceea)');
		invalidDefinitions.add('random lookup(Account) field(FieldOne) value(One,Two,Three) source(forceea)');
		invalidDefinitions.add('random lookup(Account) source(forceea)');
		invalidDefinitions.add('random lookup(Account) where(Rating = \'Hot\') source(salesforce)');
		invalidDefinitions.add('random type(picklist)');
		invalidDefinitions.add('random type(picklist) except(One,Two)');
		invalidDefinitions.add('serial lookup(Account) mode(cyclical) source(forceea)');
		invalidDefinitions.add('static lookup(Account) field(FieldOne) value(one) source(forceea)');

		Test.startTest();
		Boolean expectedResult = false;
		Boolean actualResult = ForceeaUtilityTest.definitionsAreValid(
			new FObject('Attachment'), fieldApiName, validDefinitions, invalidDefinitions);
		Test.stopTest();

		System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
	}

	@IsTest
	private static void isValidForFieldDataType_boolean_expectFailure() {
		String fieldApiName = 'TestCheckbox__c';

		List<String> validDefinitions = new List<String>();
		validDefinitions.add('copy field(TestPicklistD__c)');
		validDefinitions.add('copy field(TestLookup__c) from(FObjectTwo__c.TestText__c)');
		validDefinitions.add('random type(boolean)');
		validDefinitions.add('random type(list) value(true, true, false)');
		validDefinitions.add('static value(true)');

		List<String> invalidDefinitions = new List<String>();
		invalidDefinitions.add('mock type(id)');
		invalidDefinitions.add('random lookup(Account) field(FieldOne) except(One,Two,Three) source(forceea)');
		invalidDefinitions.add('random lookup(Account) field(FieldOne) value(One,Two,Three) source(forceea)');
		invalidDefinitions.add('random lookup(Account) source(forceea)');
		invalidDefinitions.add('random lookup(Account) where(Rating = \'Hot\') source(salesforce)');
		invalidDefinitions.add('random type(city) group(one)');
		invalidDefinitions.add('random type(country) group(one)');
		invalidDefinitions.add('random type(date) From(2017-01-01) To(2017-12-31)');
		invalidDefinitions.add('random type(datetime) From(2017-01-01) To(2017-12-31)');
		invalidDefinitions.add('random type(time) from(05:15:21) to(17:18:22)');
		invalidDefinitions.add('random type(email)');
		invalidDefinitions.add('random type(phone) Format(30 210 dD DD ddD)');
		invalidDefinitions.add('random type(firstName) Group(one)');
		invalidDefinitions.add('random type(lastName) group(one)');
		invalidDefinitions.add('random type(list) value(1, 2, 3)');
		invalidDefinitions.add('random type(list) value(1.1, 2.2, 3.3)');
		invalidDefinitions.add('random type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
		invalidDefinitions.add('random type(list) value(2017-01-01, 2017-02-02, 2017-03-03)');
		invalidDefinitions.add('random type(picklist) except(One,Two)');
		invalidDefinitions.add('random type(picklist)');
		invalidDefinitions.add('random type(postalCode) group(one)');
		invalidDefinitions.add('random type(state) group(one)');
		invalidDefinitions.add('random type(street) group(one)');
		invalidDefinitions.add('random type(string) minLength(10) maxLength(30) startWith(lower) include(lower,upper,digit)');
		invalidDefinitions.add('random type(text) minLength(10) maxlength(30)');
		invalidDefinitions.add('random type(url)');
		invalidDefinitions.add('serial lookup(Account) mode(cyclical) source(forceea)');
		invalidDefinitions.add('serial type(date) from(2017-01-01) Step(2)');
		invalidDefinitions.add('serial type(datetime) from(2017-01-01 02:02:02) step(2.2)');
		invalidDefinitions.add('serial type(list) value(One,Two,Three) mode(cyclical)');
		invalidDefinitions.add('serial type(picklist) mode(cyclical)');
		invalidDefinitions.add('serial type(number) from(10.2) step(1.2) scale(2)');
		invalidDefinitions.add('static lookup(Account) field(FieldOne) value(one) source(forceea)');
		invalidDefinitions.add('static value(01:01:01)');
		invalidDefinitions.add('static value(10.1)');
		invalidDefinitions.add('static value(10)');
		invalidDefinitions.add('static value(2017-01-01 01:01:01)');
		invalidDefinitions.add('static value(2017-01-01)');
		invalidDefinitions.add('static value("")');
		invalidDefinitions.add('random type(number) from(1) to(100) scale(0)');

		Test.startTest();
		Boolean expectedResult = false;
		Boolean actualResult = ForceeaUtilityTest.definitionsAreValid(
			new FObject(FObjectOne__c.SObjectType), fieldApiName, validDefinitions, invalidDefinitions);
		Test.stopTest();

		System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
	}

	@IsTest
	private static void isValidForFieldDataType_combobox_expectFailure() {
		String fieldApiName = 'Subject';

		List<String> validDefinitions = new List<String>();
		validDefinitions.add('copy field(WhoId)');
		validDefinitions.add('random type(boolean)');
		validDefinitions.add('random type(city) group(one)');
		validDefinitions.add('random type(country) group(one)');
		validDefinitions.add('random type(date) From(2017-01-01) To(2017-12-31)');
		validDefinitions.add('random type(datetime) From(2017-01-01) To(2017-12-31)');
		validDefinitions.add('random type(time) from(05:15:21) to(17:18:22)');
		validDefinitions.add('random type(email)');
		validDefinitions.add('random type(phone) Format(30 210 dD DD ddD)');
		validDefinitions.add('random type(firstName) Group(one)');
		validDefinitions.add('random type(lastName) group(one)');
		validDefinitions.add('random type(list) value(1, 2, 3)');
		validDefinitions.add('random type(list) value(1.1, 2.2, 3.3)');
		validDefinitions.add('random type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
		validDefinitions.add('random type(list) value(2017-01-01, 2017-02-02, 2017-03-03)');
		validDefinitions.add('random type(list) value(One, Two, Three)');
		validDefinitions.add('random type(number) from(1) to(100) scale(0)');
		validDefinitions.add('random type(picklist) except(One,Two)');
		validDefinitions.add('random type(picklist)');
		validDefinitions.add('random type(postalCode) group(one)');
		validDefinitions.add('random type(state) group(one)');
		validDefinitions.add('random type(street) group(one)');
		validDefinitions.add('random type(string) minLength(10) maxLength(30) startWith(lower) include(lower,upper,digit)');
		validDefinitions.add('random type(text) minLength(10) maxlength(30)');
		validDefinitions.add('random type(url)');
		validDefinitions.add('serial type(date) from(2017-01-01) Step(2)');
		validDefinitions.add('serial type(datetime) from(2017-01-01 02:02:02) step(2.2)');
		validDefinitions.add('serial type(list) value(One,Two,Three) mode(cyclical)');
		validDefinitions.add('serial type(picklist) mode(cyclical)');
		validDefinitions.add('serial type(number) from(10.2) step(1.2) scale(2)');
		validDefinitions.add('static value(01:01:01)');
		validDefinitions.add('static value(10.1)');
		validDefinitions.add('static value(10)');
		validDefinitions.add('static value(2017-01-01 01:01:01)');
		validDefinitions.add('static value(2017-01-01)');
		validDefinitions.add('static value(One)');
		validDefinitions.add('static value("")');

		List<String> invalidDefinitions = new List<String>();
		invalidDefinitions.add('mock type(id)');
		invalidDefinitions.add('random lookup(Account) field(FieldOne) except(One,Two,Three) source(forceea)');
		invalidDefinitions.add('random lookup(Account) field(FieldOne) value(One,Two,Three) source(forceea)');
		invalidDefinitions.add('random lookup(Account) source(forceea)');
		invalidDefinitions.add('random lookup(Account) where(Rating = \'Hot\') source(salesforce)');
		invalidDefinitions.add('serial lookup(Account) mode(cyclical) source(forceea)');
		invalidDefinitions.add('static lookup(Account) field(FieldOne) value(one) source(forceea)');

		Test.startTest();
		Boolean expectedResult = false;
		Boolean actualResult = ForceeaUtilityTest.definitionsAreValid(
			new FObject(Event.SObjectType), fieldApiName, validDefinitions, invalidDefinitions);
		Test.stopTest();

		System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
	}

	@IsTest
	private static void isValidForFieldDataType_currency_expectFailure() {
		String fieldApiName = 'TestCurrency__c';

		List<String> validDefinitions = new List<String>();
		validDefinitions.add('copy field(TestPicklistD__c)');
		validDefinitions.add('copy field(TestLookup__c) from(FObjectTwo__c.TestText__c)');
		validDefinitions.add('random type(list) value(1, 2, 3)');
		validDefinitions.add('random type(list) value(1.1, 2.2, 3.3)');
		validDefinitions.add('random type(number) from(1) to(100) scale(0)');
		validDefinitions.add('serial type(number) from(10.2) step(1.2) scale(2)');
		validDefinitions.add('static value(10.1)');
		validDefinitions.add('static value(10)');
		validDefinitions.add('static value("")');

		List<String> invalidDefinitions = new List<String>();
		invalidDefinitions.add('mock type(id)');
		invalidDefinitions.add('random lookup(Account) field(FieldOne) except(One,Two,Three) source(forceea)');
		invalidDefinitions.add('random lookup(Account) field(FieldOne) value(One,Two,Three) source(forceea)');
		invalidDefinitions.add('random lookup(Account) source(forceea)');
		invalidDefinitions.add('random lookup(Account) where(Rating = \'Hot\') source(salesforce)');
		invalidDefinitions.add('random type(boolean)');
		invalidDefinitions.add('random type(city) group(one)');
		invalidDefinitions.add('random type(country) group(one)');
		invalidDefinitions.add('random type(date) From(2017-01-01) To(2017-12-31)');
		invalidDefinitions.add('random type(datetime) From(2017-01-01) To(2017-12-31)');
		invalidDefinitions.add('random type(time) from(05:15:21) to(17:18:22)');
		invalidDefinitions.add('random type(email)');
		invalidDefinitions.add('random type(phone) Format(30 210 dD DD ddD)');
		invalidDefinitions.add('random type(firstName) Group(one)');
		invalidDefinitions.add('random type(lastName) group(one)');
		invalidDefinitions.add('random type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
		invalidDefinitions.add('random type(list) value(2017-01-01, 2017-02-02, 2017-03-03)');
		invalidDefinitions.add('random type(list) value(One, Two, Three)');
		invalidDefinitions.add('random type(picklist) except(One,Two)');
		invalidDefinitions.add('random type(picklist)');
		invalidDefinitions.add('random type(postalCode) group(one)');
		invalidDefinitions.add('random type(state) group(one)');
		invalidDefinitions.add('random type(street) group(one)');
		invalidDefinitions.add('random type(string) minLength(10) maxLength(30) startWith(lower) include(lower,upper,digit)');
		invalidDefinitions.add('random type(text) minLength(10) maxlength(30)');
		invalidDefinitions.add('random type(url)');
		invalidDefinitions.add('serial lookup(Account) mode(cyclical) source(forceea)');
		invalidDefinitions.add('serial type(date) from(2017-01-01) Step(2)');
		invalidDefinitions.add('serial type(datetime) from(2017-01-01 02:02:02) step(2.2)');
		invalidDefinitions.add('serial type(list) value(One,Two,Three) mode(cyclical)');
		invalidDefinitions.add('serial type(picklist) mode(cyclical)');
		invalidDefinitions.add('static lookup(Account) field(FieldOne) value(one) source(forceea)');
		invalidDefinitions.add('static value(01:01:01)');
		invalidDefinitions.add('static value(2017-01-01 01:01:01)');
		invalidDefinitions.add('static value(2017-01-01)');
		invalidDefinitions.add('static value(One)');

		Test.startTest();
		Boolean expectedResult = false;
		Boolean actualResult = ForceeaUtilityTest.definitionsAreValid(
			new FObject(FObjectOne__c.SObjectType), fieldApiName, validDefinitions, invalidDefinitions);
		Test.stopTest();

		System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
	}

	@IsTest
	private static void isValidForFieldDataType_date_expectFailure() {
		String fieldApiName = 'TestDate__c';

		List<String> validDefinitions = new List<String>();
		validDefinitions.add('copy field(TestPicklistD__c)');
		validDefinitions.add('copy field(TestLookup__c) from(FObjectTwo__c.TestText__c)');
		validDefinitions.add('random type(date) From(2017-01-01) To(2017-12-31)');
		validDefinitions.add('random type(list) value(2017-01-01, 2017-02-02, 2017-03-03)');
		validDefinitions.add('serial type(date) from(2017-01-01) Step(2)');
		validDefinitions.add('static value(2017-01-01)');
		validDefinitions.add('static value("")');

		List<String> invalidDefinitions = new List<String>();
		invalidDefinitions.add('mock type(id)');
		invalidDefinitions.add('random lookup(Account) field(FieldOne) except(One,Two,Three) source(forceea)');
		invalidDefinitions.add('random lookup(Account) field(FieldOne) value(One,Two,Three) source(forceea)');
		invalidDefinitions.add('random lookup(Account) source(forceea)');
		invalidDefinitions.add('random lookup(Account) where(Rating = \'Hot\') source(salesforce)');
		invalidDefinitions.add('random type(boolean)');
		invalidDefinitions.add('random type(city) group(one)');
		invalidDefinitions.add('random type(country) group(one)');
		invalidDefinitions.add('random type(datetime) From(2017-01-01) To(2017-12-31)');
		invalidDefinitions.add('random type(time) from(05:15:21) to(17:18:22)');
		invalidDefinitions.add('random type(email)');
		invalidDefinitions.add('random type(phone) Format(30 210 dD DD ddD)');
		invalidDefinitions.add('random type(firstName) Group(one)');
		invalidDefinitions.add('random type(lastName) group(one)');
		invalidDefinitions.add('random type(list) value(1, 2, 3)');
		invalidDefinitions.add('random type(list) value(1.1, 2.2, 3.3)');
		invalidDefinitions.add('random type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
		invalidDefinitions.add('random type(list) value(One, Two, Three)');
		invalidDefinitions.add('random type(number) from(1) to(100) scale(0)');
		invalidDefinitions.add('random type(picklist) except(One,Two)');
		invalidDefinitions.add('random type(picklist)');
		invalidDefinitions.add('random type(postalCode) group(one)');
		invalidDefinitions.add('random type(state) group(one)');
		invalidDefinitions.add('random type(street) group(one)');
		invalidDefinitions.add('random type(string) minLength(10) maxLength(30) startWith(lower) include(lower,upper,digit)');
		invalidDefinitions.add('random type(text) minLength(10) maxlength(30)');
		invalidDefinitions.add('random type(url)');
		invalidDefinitions.add('serial lookup(Account) mode(cyclical) source(forceea)');
		invalidDefinitions.add('serial type(datetime) from(2017-01-01 02:02:02) step(2.2)');
		invalidDefinitions.add('serial type(list) value(One,Two,Three) mode(cyclical)');
		invalidDefinitions.add('serial type(picklist) mode(cyclical)');
		invalidDefinitions.add('serial type(number) from(10.2) step(1.2) scale(2)');
		invalidDefinitions.add('static lookup(Account) field(FieldOne) value(one) source(forceea)');
		invalidDefinitions.add('static value(01:01:01)');
		invalidDefinitions.add('static value(10.1)');
		invalidDefinitions.add('static value(10)');
		invalidDefinitions.add('static value(2017-01-01 01:01:01)');
		invalidDefinitions.add('static value(One)');

		Test.startTest();
		Boolean expectedResult = false;
		Boolean actualResult = ForceeaUtilityTest.definitionsAreValid(
			new FObject(FObjectOne__c.SObjectType), fieldApiName, validDefinitions, invalidDefinitions);
		Test.stopTest();

		System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
	}

	@IsTest
	private static void isValidForFieldDataType_datetime_expectFailure() {
		String fieldApiName = 'TestDatetime__c';

		List<String> validDefinitions = new List<String>();
		validDefinitions.add('copy field(TestPicklistD__c)');
		validDefinitions.add('copy field(TestLookup__c) from(FObjectTwo__c.TestText__c)');
		validDefinitions.add('random type(datetime) From(2017-01-01) To(2017-12-31)');
		validDefinitions.add('random type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
		validDefinitions.add('random type(list) value(2017-01-01, 2017-02-02, 2017-03-03)');
		validDefinitions.add('serial type(date) from(2017-01-01) Step(2)');
		validDefinitions.add('serial type(datetime) from(2017-01-01 02:02:02) step(2.2)');
		validDefinitions.add('static value(2017-01-01 01:01:01)');
		validDefinitions.add('static value("")');

		List<String> invalidDefinitions = new List<String>();
		invalidDefinitions.add('mock type(id)');
		invalidDefinitions.add('random lookup(Account) field(FieldOne) except(One,Two,Three) source(forceea)');
		invalidDefinitions.add('random lookup(Account) field(FieldOne) value(One,Two,Three) source(forceea)');
		invalidDefinitions.add('random lookup(Account) source(forceea)');
		invalidDefinitions.add('random lookup(Account) where(Rating = \'Hot\') source(salesforce)');
		invalidDefinitions.add('random type(boolean)');
		invalidDefinitions.add('random type(city) group(one)');
		invalidDefinitions.add('random type(country) group(one)');
		invalidDefinitions.add('random type(date) From(2017-01-01) To(2017-12-31)');
		invalidDefinitions.add('random type(time) from(05:15:21) to(17:18:22)');
		invalidDefinitions.add('random type(email)');
		invalidDefinitions.add('random type(phone) Format(30 210 dD DD ddD)');
		invalidDefinitions.add('random type(firstName) Group(one)');
		invalidDefinitions.add('random type(lastName) group(one)');
		invalidDefinitions.add('random type(list) value(1, 2, 3)');
		invalidDefinitions.add('random type(list) value(1.1, 2.2, 3.3)');
		invalidDefinitions.add('random type(list) value(One, Two, Three)');
		invalidDefinitions.add('random type(number) from(1) to(100) scale(0)');
		invalidDefinitions.add('random type(picklist) except(One,Two)');
		invalidDefinitions.add('random type(picklist)');
		invalidDefinitions.add('random type(postalCode) group(one)');
		invalidDefinitions.add('random type(state) group(one)');
		invalidDefinitions.add('random type(street) group(one)');
		invalidDefinitions.add('random type(string) minLength(10) maxLength(30) startWith(lower) include(lower,upper,digit)');
		invalidDefinitions.add('random type(text) minLength(10) maxlength(30)');
		invalidDefinitions.add('random type(url)');
		invalidDefinitions.add('serial lookup(Account) mode(cyclical) source(forceea)');
		invalidDefinitions.add('serial type(number) from(10.2) step(1.2) scale(2)');
		invalidDefinitions.add('serial type(list) value(One,Two,Three) mode(cyclical)');
		invalidDefinitions.add('serial type(picklist) mode(cyclical)');
		invalidDefinitions.add('static lookup(Account) field(FieldOne) value(one) source(forceea)');
		invalidDefinitions.add('static value(01:01:01)');
		invalidDefinitions.add('static value(10.1)');
		invalidDefinitions.add('static value(10)');
		invalidDefinitions.add('static value(2017-01-01)');
		invalidDefinitions.add('static value(One)');

		Test.startTest();
		Boolean expectedResult = false;
		Boolean actualResult = ForceeaUtilityTest.definitionsAreValid(
			new FObject(FObjectOne__c.SObjectType), fieldApiName, validDefinitions, invalidDefinitions);
		Test.stopTest();

		System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
	}

	@IsTest
	private static void isValidForFieldDataType_time_expectFailure() {
		String fieldApiName = 'TestTime__c';

		List<String> validDefinitions = new List<String>();
		validDefinitions.add('copy field(TestPicklistD__c)');
		validDefinitions.add('copy field(TestLookup__c) from(FObjectTwo__c.TestText__c)');
		validDefinitions.add('random type(datetime) From(2017-01-01) To(2017-12-31)');
		validDefinitions.add('random type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
		validDefinitions.add('random type(list) value(2017-01-01, 2017-02-02, 2017-03-03)');
		validDefinitions.add('serial type(date) from(2017-01-01) Step(2)');
		validDefinitions.add('serial type(datetime) from(2017-01-01 02:02:02) step(2.2)');
		validDefinitions.add('static value(01:01:01)');
		validDefinitions.add('static value("")');

		List<String> invalidDefinitions = new List<String>();
		invalidDefinitions.add('mock type(id)');
		invalidDefinitions.add('random lookup(Account) field(FieldOne) except(One,Two,Three) source(forceea)');
		invalidDefinitions.add('random lookup(Account) field(FieldOne) value(One,Two,Three) source(forceea)');
		invalidDefinitions.add('random lookup(Account) source(forceea)');
		invalidDefinitions.add('random lookup(Account) where(Rating = \'Hot\') source(salesforce)');
		invalidDefinitions.add('random type(boolean)');
		invalidDefinitions.add('random type(city) group(one)');
		invalidDefinitions.add('random type(country) group(one)');
		invalidDefinitions.add('random type(date) From(2017-01-01) To(2017-12-31)');
		invalidDefinitions.add('random type(time) from(05:15:21) to(17:18:22)');
		invalidDefinitions.add('random type(email)');
		invalidDefinitions.add('random type(phone) Format(30 210 dD DD ddD)');
		invalidDefinitions.add('random type(firstName) Group(one)');
		invalidDefinitions.add('random type(lastName) group(one)');
		invalidDefinitions.add('random type(list) value(1, 2, 3)');
		invalidDefinitions.add('random type(list) value(1.1, 2.2, 3.3)');
		invalidDefinitions.add('random type(list) value(One, Two, Three)');
		invalidDefinitions.add('random type(number) from(1) to(100) scale(0)');
		invalidDefinitions.add('random type(picklist) except(One,Two)');
		invalidDefinitions.add('random type(picklist)');
		invalidDefinitions.add('random type(postalCode) group(one)');
		invalidDefinitions.add('random type(state) group(one)');
		invalidDefinitions.add('random type(street) group(one)');
		invalidDefinitions.add('random type(string) minLength(10) maxLength(30) startWith(lower) include(lower,upper,digit)');
		invalidDefinitions.add('random type(text) minLength(10) maxlength(30)');
		invalidDefinitions.add('random type(url)');
		invalidDefinitions.add('serial lookup(Account) mode(cyclical) source(forceea)');
		invalidDefinitions.add('serial type(number) from(10.2) step(1.2) scale(2)');
		invalidDefinitions.add('serial type(list) value(One,Two,Three) mode(cyclical)');
		invalidDefinitions.add('serial type(picklist) mode(cyclical)');
		invalidDefinitions.add('static lookup(Account) field(FieldOne) value(one) source(forceea)');
		invalidDefinitions.add('static value(10.1)');
		invalidDefinitions.add('static value(10)');
		invalidDefinitions.add('static value(2017-01-01)');
		invalidDefinitions.add('static value(2017-01-01 01:01:01)');
		invalidDefinitions.add('static value(One)');

		Test.startTest();
		Boolean expectedResult = false;
		Boolean actualResult = ForceeaUtilityTest.definitionsAreValid(
			new FObject(FObjectOne__c.SObjectType), fieldApiName, validDefinitions, invalidDefinitions);
		Test.stopTest();

		System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
	}

	@IsTest
	private static void isValidForFieldDataType_decimal_expectFailure() {
		String fieldApiName = 'TestDecimal__c';

		List<String> validDefinitions = new List<String>();
		validDefinitions.add('copy field(TestPicklistD__c)');
		validDefinitions.add('copy field(TestLookup__c) from(FObjectTwo__c.TestText__c)');
		validDefinitions.add('random type(list) value(1, 2, 3)');
		validDefinitions.add('random type(list) value(1.1, 2.2, 3.3)');
		validDefinitions.add('random type(number) from(1) to(100) scale(0)');
		validDefinitions.add('serial type(number) from(10.2) step(1.2) scale(2)');
		validDefinitions.add('static value(10.1)');
		validDefinitions.add('static value(10)');
		validDefinitions.add('static value("")');

		List<String> invalidDefinitions = new List<String>();
		invalidDefinitions.add('mock type(id)');
		invalidDefinitions.add('random lookup(Account) field(FieldOne) except(One,Two,Three) source(forceea)');
		invalidDefinitions.add('random lookup(Account) field(FieldOne) value(One,Two,Three) source(forceea)');
		invalidDefinitions.add('random lookup(Account) source(forceea)');
		invalidDefinitions.add('random lookup(Account) where(Rating = \'Hot\') source(salesforce)');
		invalidDefinitions.add('random type(boolean)');
		invalidDefinitions.add('random type(city) group(one)');
		invalidDefinitions.add('random type(country) group(one)');
		invalidDefinitions.add('random type(date) From(2017-01-01) To(2017-12-31)');
		invalidDefinitions.add('random type(datetime) From(2017-01-01) To(2017-12-31)');
		invalidDefinitions.add('random type(time) from(05:15:21) to(17:18:22)');
		invalidDefinitions.add('random type(email)');
		invalidDefinitions.add('random type(phone) Format(30 210 dD DD ddD)');
		invalidDefinitions.add('random type(firstName) Group(one)');
		invalidDefinitions.add('random type(lastName) group(one)');
		invalidDefinitions.add('random type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
		invalidDefinitions.add('random type(list) value(2017-01-01, 2017-02-02, 2017-03-03)');
		invalidDefinitions.add('random type(list) value(One, Two, Three)');
		invalidDefinitions.add('random type(picklist) except(One,Two)');
		invalidDefinitions.add('random type(picklist)');
		invalidDefinitions.add('random type(postalCode) group(one)');
		invalidDefinitions.add('random type(state) group(one)');
		invalidDefinitions.add('random type(street) group(one)');
		invalidDefinitions.add('random type(string) minLength(10) maxLength(30) startWith(lower) include(lower,upper,digit)');
		invalidDefinitions.add('random type(text) minLength(10) maxlength(30)');
		invalidDefinitions.add('random type(url)');
		invalidDefinitions.add('serial lookup(Account) mode(cyclical) source(forceea)');
		invalidDefinitions.add('serial type(date) from(2017-01-01) Step(2)');
		invalidDefinitions.add('serial type(datetime) from(2017-01-01 02:02:02) step(2.2)');
		invalidDefinitions.add('serial type(list) value(One,Two,Three) mode(cyclical)');
		invalidDefinitions.add('serial type(picklist) mode(cyclical)');
		invalidDefinitions.add('static lookup(Account) field(FieldOne) value(one) source(forceea)');
		invalidDefinitions.add('static value(01:01:01)');
		invalidDefinitions.add('static value(2017-01-01 01:01:01)');
		invalidDefinitions.add('static value(2017-01-01)');
		invalidDefinitions.add('static value(One)');

		Test.startTest();
		Boolean expectedResult = false;
		Boolean actualResult = ForceeaUtilityTest.definitionsAreValid(
			new FObject(FObjectOne__c.SObjectType), fieldApiName, validDefinitions, invalidDefinitions);
		Test.stopTest();

		System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
	}

	@IsTest
	private static void isValidForFieldDataType_email_expectFailure() {
		String fieldApiName = 'TestEmail__c';

		List<String> validDefinitions = new List<String>();
		validDefinitions.add('copy field(TestPicklistD__c)');
		validDefinitions.add('copy field(TestLookup__c) from(FObjectTwo__c.TestText__c)');
		validDefinitions.add('random type(boolean)');
		validDefinitions.add('random type(email)');
		validDefinitions.add('random type(time) from(05:15:21) to(17:18:22)');
		validDefinitions.add('random type(list) value(1, 2, 3)');
		validDefinitions.add('random type(list) value(One, Two, Three)');
		validDefinitions.add('random type(number) from(1) to(100) scale(0)');
		validDefinitions.add('random type(string) minLength(10) maxLength(30) startWith(lower) include(lower,upper,digit)');
		validDefinitions.add('serial type(list) value(One,Two,Three) mode(cyclical)');
		validDefinitions.add('serial type(number) from(10.2) step(1.2) scale(2)');
		validDefinitions.add('static value(10)');
		validDefinitions.add('static value(One)');
		validDefinitions.add('static value("")');

		List<String> invalidDefinitions = new List<String>();
		invalidDefinitions.add('mock type(id)');
		invalidDefinitions.add('random lookup(Account) field(FieldOne) except(One,Two,Three) source(forceea)');
		invalidDefinitions.add('random lookup(Account) field(FieldOne) value(One,Two,Three) source(forceea)');
		invalidDefinitions.add('random lookup(Account) source(forceea)');
		invalidDefinitions.add('random lookup(Account) where(Rating = \'Hot\') source(salesforce)');
		invalidDefinitions.add('random type(city) group(one)');
		invalidDefinitions.add('random type(country) group(one)');
		invalidDefinitions.add('random type(date) From(2017-01-01) To(2017-12-31)');
		invalidDefinitions.add('random type(datetime) From(2017-01-01) To(2017-12-31)');
		invalidDefinitions.add('random type(phone) Format(30 210 dD DD ddD)');
		invalidDefinitions.add('random type(firstName) Group(one)');
		invalidDefinitions.add('random type(lastName) group(one)');
		invalidDefinitions.add('random type(list) value(1.1, 2.2, 3.3)');
		invalidDefinitions.add('random type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
		invalidDefinitions.add('random type(list) value(2017-01-01, 2017-02-02, 2017-03-03)');
		invalidDefinitions.add('random type(picklist) except(One,Two)');
		invalidDefinitions.add('random type(picklist)');
		invalidDefinitions.add('random type(postalCode) group(one)');
		invalidDefinitions.add('random type(state) group(one)');
		invalidDefinitions.add('random type(street) group(one)');
		invalidDefinitions.add('random type(text) minLength(10) maxlength(30)');
		invalidDefinitions.add('random type(url)');
		invalidDefinitions.add('serial lookup(Account) mode(cyclical) source(forceea)');
		invalidDefinitions.add('serial type(date) from(2017-01-01) Step(2)');
		invalidDefinitions.add('serial type(datetime) from(2017-01-01 02:02:02) step(2.2)');
		invalidDefinitions.add('serial type(picklist) mode(cyclical)');
		invalidDefinitions.add('static lookup(Account) field(FieldOne) value(one) source(forceea)');
		invalidDefinitions.add('static value(01:01:01)');
		invalidDefinitions.add('static value(10.1)');
		invalidDefinitions.add('static value(2017-01-01 01:01:01)');
		invalidDefinitions.add('static value(2017-01-01)');

		Test.startTest();
		Boolean expectedResult = false;
		Boolean actualResult = ForceeaUtilityTest.definitionsAreValid(
			new FObject(FObjectOne__c.SObjectType), fieldApiName, validDefinitions, invalidDefinitions);
		Test.stopTest();

		System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
	}

	@IsTest
	private static void isValidForFieldDataType_id_expectFailure() {
		String fieldApiName = 'Id';

		List<String> validDefinitions = new List<String>();
		validDefinitions.add('Mock type(id)');

		List<String> invalidDefinitions = new List<String>();
		invalidDefinitions.add('copy field(TestPicklistD__c)');
		invalidDefinitions.add('copy field(TestLookup__c) from(FObjectTwo__c.TestText__c)');
		invalidDefinitions.add('random type(list) value(1, 2, 3)');
		invalidDefinitions.add('random type(list) value(One, Two, Three)');
		invalidDefinitions.add('random type(number) from(1) to(100) scale(0)');
		invalidDefinitions.add('random type(string) minLength(10) maxLength(30) startWith(lower) include(lower,upper,digit)');
		invalidDefinitions.add('random type(url)');
		invalidDefinitions.add('random lookup(Account) field(FieldOne) except(One,Two,Three) source(forceea)');
		invalidDefinitions.add('random lookup(Account) field(FieldOne) value(One,Two,Three) source(forceea)');
		invalidDefinitions.add('random lookup(Account) source(forceea)');
		invalidDefinitions.add('random lookup(Account) where(Rating = \'Hot\') source(salesforce)');
		invalidDefinitions.add('random type(boolean)');
		invalidDefinitions.add('random type(city) group(one)');
		invalidDefinitions.add('random type(country) group(one)');
		invalidDefinitions.add('random type(date) From(2017-01-01) To(2017-12-31)');
		invalidDefinitions.add('random type(datetime) From(2017-01-01) To(2017-12-31)');
		invalidDefinitions.add('random type(time) from(05:15:21) to(17:18:22)');
		invalidDefinitions.add('random type(email)');
		invalidDefinitions.add('random type(phone) Format(30 210 dD DD ddD)');
		invalidDefinitions.add('random type(firstName) Group(one)');
		invalidDefinitions.add('random type(lastName) group(one)');
		invalidDefinitions.add('random type(list) value(1.1, 2.2, 3.3)');
		invalidDefinitions.add('random type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
		invalidDefinitions.add('random type(list) value(2017-01-01, 2017-02-02, 2017-03-03)');
		invalidDefinitions.add('random type(picklist) except(One,Two)');
		invalidDefinitions.add('random type(picklist)');
		invalidDefinitions.add('random type(postalCode) group(one)');
		invalidDefinitions.add('random type(state) group(one)');
		invalidDefinitions.add('random type(street) group(one)');
		invalidDefinitions.add('random type(text) minLength(10) maxlength(30)');
		invalidDefinitions.add('serial lookup(Account) mode(cyclical) source(forceea)');
		invalidDefinitions.add('serial type(list) value(One,Two,Three) mode(cyclical)');
		invalidDefinitions.add('serial type(picklist) mode(cyclical)');
		invalidDefinitions.add('serial type(number) from(10.2) step(1.2) scale(2)');
		invalidDefinitions.add('serial type(date) from(2017-01-01) Step(2)');
		invalidDefinitions.add('serial type(datetime) from(2017-01-01 02:02:02) step(2.2)');
		invalidDefinitions.add('static lookup(Account) field(FieldOne) value(one) source(forceea)');
		invalidDefinitions.add('static value(10)');
		invalidDefinitions.add('static value(One)');
		invalidDefinitions.add('static value(01:01:01)');
		invalidDefinitions.add('static value(10.1)');
		invalidDefinitions.add('static value(2017-01-01 01:01:01)');
		invalidDefinitions.add('static value(2017-01-01)');
		invalidDefinitions.add('static value("")');

		Test.startTest();
		Boolean expectedResult = false;
		Boolean actualResult = ForceeaUtilityTest.definitionsAreValid(
			new FObject(FObjectOne__c.SObjectType), fieldApiName, validDefinitions, invalidDefinitions);
		Test.stopTest();

		System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
	}

	@IsTest
	private static void isValidForFieldDataType_integer_expectFailure() {
		String fieldApiName = 'TestInteger__c';

		List<String> validDefinitions = new List<String>();
		validDefinitions.add('copy field(TestPicklistD__c)');
		validDefinitions.add('copy field(TestLookup__c) from(FObjectTwo__c.TestText__c)');
		validDefinitions.add('random type(list) value(1, 2, 3)');
		validDefinitions.add('random type(number) from(1) to(100) scale(0)');
		validDefinitions.add('static value(10.1)');
		validDefinitions.add('static value(10)');
		validDefinitions.add('static value("")');

		List<String> invalidDefinitions = new List<String>();
		invalidDefinitions.add('mock type(id)');
		invalidDefinitions.add('random lookup(Account) field(FieldOne) except(One,Two,Three) source(forceea)');
		invalidDefinitions.add('random lookup(Account) field(FieldOne) value(One,Two,Three) source(forceea)');
		invalidDefinitions.add('random lookup(Account) source(forceea)');
		invalidDefinitions.add('random lookup(Account) where(Rating = \'Hot\') source(salesforce)');
		invalidDefinitions.add('random type(boolean)');
		invalidDefinitions.add('random type(city) group(one)');
		invalidDefinitions.add('random type(country) group(one)');
		invalidDefinitions.add('random type(date) From(2017-01-01) To(2017-12-31)');
		invalidDefinitions.add('random type(datetime) From(2017-01-01) To(2017-12-31)');
		invalidDefinitions.add('random type(time) from(05:15:21) to(17:18:22)');
		invalidDefinitions.add('random type(email)');
		invalidDefinitions.add('random type(list) value(1.1, 2.2, 3.3)');
		invalidDefinitions.add('random type(phone) Format(30 210 dD DD ddD)');
		invalidDefinitions.add('random type(firstName) Group(one)');
		invalidDefinitions.add('random type(lastName) group(one)');
		invalidDefinitions.add('random type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
		invalidDefinitions.add('random type(list) value(2017-01-01, 2017-02-02, 2017-03-03)');
		invalidDefinitions.add('random type(list) value(One, Two, Three)');
		invalidDefinitions.add('random type(picklist) except(One,Two)');
		invalidDefinitions.add('random type(picklist)');
		invalidDefinitions.add('random type(postalCode) group(one)');
		invalidDefinitions.add('random type(state) group(one)');
		invalidDefinitions.add('random type(street) group(one)');
		invalidDefinitions.add('random type(string) minLength(10) maxLength(30) startWith(lower) include(lower,upper,digit)');
		invalidDefinitions.add('random type(text) minLength(10) maxlength(30)');
		invalidDefinitions.add('random type(url)');
		invalidDefinitions.add('serial lookup(Account) mode(cyclical) source(forceea)');
		invalidDefinitions.add('serial type(date) from(2017-01-01) Step(2)');
		invalidDefinitions.add('serial type(datetime) from(2017-01-01 02:02:02) step(2.2)');
		invalidDefinitions.add('serial type(list) value(One,Two,Three) mode(cyclical)');
		invalidDefinitions.add('serial type(picklist) mode(cyclical)');
		invalidDefinitions.add('serial type(number) from(10.2) step(1.2) scale(2)');
		invalidDefinitions.add('static lookup(Account) field(FieldOne) value(one) source(forceea)');
		invalidDefinitions.add('static value(01:01:01)');
		invalidDefinitions.add('static value(2017-01-01 01:01:01)');
		invalidDefinitions.add('static value(2017-01-01)');
		invalidDefinitions.add('static value(One)');

		Test.startTest();
		Boolean expectedResult = false;
		Boolean actualResult = ForceeaUtilityTest.definitionsAreValid(
			new FObject(FObjectOne__c.SObjectType), fieldApiName, validDefinitions, invalidDefinitions);
		Test.stopTest();

		System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
	}

	@IsTest
	private static void isValidForFieldDataType_multiPicklist_expectFailure() {
		String fieldApiName = 'TestMultiPicklistA__c';

		List<String> validDefinitions = new List<String>();
		validDefinitions.add('copy field(TestPicklistD__c)');
		validDefinitions.add('copy field(TestLookup__c) from(FObjectTwo__c.TestText__c)');
		validDefinitions.add('random type(boolean)');
		validDefinitions.add('random type(city) group(one)');
		validDefinitions.add('random type(country) group(one)');
		validDefinitions.add('random type(date) From(2017-01-01) To(2017-12-31)');
		validDefinitions.add('random type(datetime) From(2017-01-01) To(2017-12-31)');
		validDefinitions.add('random type(datetime) From(2017-01-01) To(2017-12-31)');
		validDefinitions.add('random type(time) from(05:15:21) to(17:18:22)');
		validDefinitions.add('random type(email)');
		validDefinitions.add('random type(phone) Format(30 210 dD DD ddD)');
		validDefinitions.add('random type(firstName) Group(one)');
		validDefinitions.add('random type(lastName) group(one)');
		validDefinitions.add('random type(list) value(1, 2, 3)');
		validDefinitions.add('random type(list) value(1.1, 2.2, 3.3)');
		validDefinitions.add('random type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
		validDefinitions.add('random type(list) value(2017-01-01, 2017-02-02, 2017-03-03)');
		validDefinitions.add('random type(list) value(One, Two, Three)');
		validDefinitions.add('random type(number) from(1) to(100) scale(0)');
		validDefinitions.add('random type(picklist) except(One,Two)');
		validDefinitions.add('random type(picklist)');
		validDefinitions.add('random type(postalCode) group(one)');
		validDefinitions.add('random type(state) group(one)');
		validDefinitions.add('random type(street) group(one)');
		validDefinitions.add('random type(string) minLength(10) maxLength(30) startWith(lower) include(lower,upper,digit)');
		validDefinitions.add('random type(text) minLength(10) maxlength(30)');
		validDefinitions.add('random type(url)');
		validDefinitions.add('serial type(date) from(2017-01-01) Step(2)');
		validDefinitions.add('serial type(datetime) from(2017-01-01 02:02:02) step(2.2)');
		validDefinitions.add('serial type(list) value(One,Two,Three) mode(cyclical)');
		validDefinitions.add('serial type(picklist) mode(cyclical)');
		validDefinitions.add('serial type(number) from(10.2) step(1.2) scale(2)');
		validDefinitions.add('static value(01:01:01)');
		validDefinitions.add('static value(10.1)');
		validDefinitions.add('static value(10)');
		validDefinitions.add('static value(2017-01-01 01:01:01)');
		validDefinitions.add('static value(2017-01-01)');
		validDefinitions.add('static value(One)');
		validDefinitions.add('static value("")');

		List<String> invalidDefinitions = new List<String>();
		invalidDefinitions.add('mock type(id)');
		invalidDefinitions.add('random lookup(Account) field(FieldOne) except(One,Two,Three) source(forceea)');
		invalidDefinitions.add('random lookup(Account) field(FieldOne) value(One,Two,Three) source(forceea)');
		invalidDefinitions.add('random lookup(Account) source(forceea)');
		invalidDefinitions.add('random lookup(Account) where(Rating = \'Hot\') source(salesforce)');
		invalidDefinitions.add('serial lookup(Account) mode(cyclical) source(forceea)');
		invalidDefinitions.add('static lookup(Account) field(FieldOne) value(one) source(forceea)');

		Test.startTest();
		Boolean expectedResult = false;
		Boolean actualResult = ForceeaUtilityTest.definitionsAreValid(
			new FObject(FObjectOne__c.SObjectType), fieldApiName, validDefinitions, invalidDefinitions);
		Test.stopTest();

		System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
	}

	@IsTest
	private static void isValidForFieldDataType_percent_expectFailure() {
		String fieldApiName = 'TestPercent__c';

		List<String> validDefinitions = new List<String>();
		validDefinitions.add('copy field(TestPicklistD__c)');
		validDefinitions.add('copy field(TestLookup__c) from(FObjectTwo__c.TestText__c)');
		validDefinitions.add('random type(list) value(1, 2, 3)');
		validDefinitions.add('random type(list) value(1.1, 2.2, 3.3)');
		validDefinitions.add('random type(number) from(1) to(100) scale(0)');
		validDefinitions.add('serial type(number) from(10.2) step(1.2) scale(2)');
		validDefinitions.add('static value(10.1)');
		validDefinitions.add('static value("")');

		List<String> invalidDefinitions = new List<String>();
		invalidDefinitions.add('mock type(id)');
		invalidDefinitions.add('random lookup(Account) field(FieldOne) except(One,Two,Three) source(forceea)');
		invalidDefinitions.add('random lookup(Account) field(FieldOne) value(One,Two,Three) source(forceea)');
		invalidDefinitions.add('random lookup(Account) source(forceea)');
		invalidDefinitions.add('random lookup(Account) where(Rating = \'Hot\') source(salesforce)');
		invalidDefinitions.add('random type(boolean)');
		invalidDefinitions.add('random type(city) group(one)');
		invalidDefinitions.add('random type(country) group(one)');
		invalidDefinitions.add('random type(date) From(2017-01-01) To(2017-12-31)');
		invalidDefinitions.add('random type(datetime) From(2017-01-01) To(2017-12-31)');
		invalidDefinitions.add('random type(time) from(05:15:21) to(17:18:22)');
		invalidDefinitions.add('random type(email)');
		invalidDefinitions.add('random type(phone) Format(30 210 dD DD ddD)');
		invalidDefinitions.add('random type(firstName) Group(one)');
		invalidDefinitions.add('random type(lastName) group(one)');
		invalidDefinitions.add('random type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
		invalidDefinitions.add('random type(list) value(2017-01-01, 2017-02-02, 2017-03-03)');
		invalidDefinitions.add('random type(list) value(One, Two, Three)');
		invalidDefinitions.add('random type(picklist) except(One,Two)');
		invalidDefinitions.add('random type(picklist)');
		invalidDefinitions.add('random type(postalCode) group(one)');
		invalidDefinitions.add('random type(state) group(one)');
		invalidDefinitions.add('random type(street) group(one)');
		invalidDefinitions.add('random type(string) minLength(10) maxLength(30) startWith(lower) include(lower,upper,digit)');
		invalidDefinitions.add('random type(text) minLength(10) maxlength(30)');
		invalidDefinitions.add('random type(url)');
		invalidDefinitions.add('serial lookup(Account) mode(cyclical) source(forceea)');
		invalidDefinitions.add('serial type(date) from(2017-01-01) Step(2)');
		invalidDefinitions.add('serial type(datetime) from(2017-01-01 02:02:02) step(2.2)');
		invalidDefinitions.add('serial type(list) value(One,Two,Three) mode(cyclical)');
		invalidDefinitions.add('serial type(picklist) mode(cyclical)');
		invalidDefinitions.add('static lookup(Account) field(FieldOne) value(one) source(forceea)');
		invalidDefinitions.add('static value(01:01:01)');
		invalidDefinitions.add('static value(10)');
		invalidDefinitions.add('static value(2017-01-01 01:01:01)');
		invalidDefinitions.add('static value(2017-01-01)');
		invalidDefinitions.add('static value(One)');

		Test.startTest();
		Boolean expectedResult = false;
		Boolean actualResult = ForceeaUtilityTest.definitionsAreValid(
			new FObject(FObjectOne__c.SObjectType), fieldApiName, validDefinitions, invalidDefinitions);
		Test.stopTest();

		System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
	}

	@IsTest
	private static void isValidForFieldDataType_picklist_expectFailure() {
		String fieldApiName = 'TestPicklistC__c';

		List<String> validDefinitions = new List<String>();
		validDefinitions.add('copy field(TestPicklistD__c)');
		validDefinitions.add('copy field(TestLookup__c) from(FObjectTwo__c.TestText__c)');
		validDefinitions.add('random type(boolean)');
		validDefinitions.add('random type(city) group(one)');
		validDefinitions.add('random type(country) group(one)');
		validDefinitions.add('random type(date) From(2017-01-01) To(2017-12-31)');
		validDefinitions.add('random type(datetime) From(2017-01-01) To(2017-12-31)');
		validDefinitions.add('random type(time) from(05:15:21) to(17:18:22)');
		validDefinitions.add('random type(email)');
		validDefinitions.add('random type(phone) Format(30 210 dD DD ddD)');
		validDefinitions.add('random type(firstName) Group(one)');
		validDefinitions.add('random type(lastName) group(one)');
		validDefinitions.add('random type(list) value(1, 2, 3)');
		validDefinitions.add('random type(list) value(1.1, 2.2, 3.3)');
		validDefinitions.add('random type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
		validDefinitions.add('random type(list) value(2017-01-01, 2017-02-02, 2017-03-03)');
		validDefinitions.add('random type(list) value(One, Two, Three)');
		validDefinitions.add('random type(number) from(1) to(100) scale(0)');
		validDefinitions.add('random type(picklist) except(One,Two)');
		validDefinitions.add('random type(picklist)');
		validDefinitions.add('random type(postalCode) group(one)');
		validDefinitions.add('random type(state) group(one)');
		validDefinitions.add('random type(street) group(one)');
		validDefinitions.add('random type(string) minLength(10) maxLength(30) startWith(lower) include(lower,upper,digit)');
		validDefinitions.add('random type(text) minLength(10) maxlength(30)');
		validDefinitions.add('random type(url)');
		validDefinitions.add('serial type(date) from(2017-01-01) Step(2)');
		validDefinitions.add('serial type(datetime) from(2017-01-01 02:02:02) step(2.2)');
		validDefinitions.add('serial type(list) value(One,Two,Three) mode(cyclical)');
		validDefinitions.add('serial type(picklist) mode(cyclical)');
		validDefinitions.add('serial type(number) from(10.2) step(1.2) scale(2)');
		validDefinitions.add('static value(01:01:01)');
		validDefinitions.add('static value(10.1)');
		validDefinitions.add('static value(10)');
		validDefinitions.add('static value(2017-01-01 01:01:01)');
		validDefinitions.add('static value(2017-01-01)');
		validDefinitions.add('static value(One)');
		validDefinitions.add('static value("")');

		List<String> invalidDefinitions = new List<String>();
		invalidDefinitions.add('mock type(id)');
		invalidDefinitions.add('random lookup(Account) field(FieldOne) except(One,Two,Three) source(forceea)');
		invalidDefinitions.add('random lookup(Account) field(FieldOne) value(One,Two,Three) source(forceea)');
		invalidDefinitions.add('random lookup(Account) source(forceea)');
		invalidDefinitions.add('random lookup(Account) where(Rating = \'Hot\') source(salesforce)');
		invalidDefinitions.add('serial lookup(Account) mode(cyclical) source(forceea)');
		invalidDefinitions.add('static lookup(Account) field(FieldOne) value(one) source(forceea)');

		Test.startTest();
		Boolean expectedResult = false;
		Boolean actualResult = ForceeaUtilityTest.definitionsAreValid(
			new FObject(FObjectOne__c.SObjectType), fieldApiName, validDefinitions, invalidDefinitions);
		Test.stopTest();

		System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
	}

	@IsTest
	private static void isValidForFieldDataType_phone_expectFailure() {
		String fieldApiName = 'TestPhone__c';

		List<String> validDefinitions = new List<String>();
		validDefinitions.add('copy field(TestPicklistD__c)');
		validDefinitions.add('copy field(TestLookup__c) from(FObjectTwo__c.TestText__c)');
		validDefinitions.add('random type(phone) Format(30 210 dD DD ddD)');
		validDefinitions.add('random type(list) value(One, Two, Three)');
		validDefinitions.add('random type(number) from(1) to(100) scale(0)');
		validDefinitions.add('serial type(list) value(One,Two,Three) mode(cyclical)');
		validDefinitions.add('serial type(number) from(10.2) step(1.2) scale(2)');
		validDefinitions.add('static value(10)');
		validDefinitions.add('static value(One)');
		validDefinitions.add('static value("")');

		List<String> invalidDefinitions = new List<String>();
		invalidDefinitions.add('mock type(id)');
		invalidDefinitions.add('random lookup(Account) field(FieldOne) except(One,Two,Three) source(forceea)');
		invalidDefinitions.add('random lookup(Account) field(FieldOne) value(One,Two,Three) source(forceea)');
		invalidDefinitions.add('random lookup(Account) source(forceea)');
		invalidDefinitions.add('random lookup(Account) where(Rating = \'Hot\') source(salesforce)');
		invalidDefinitions.add('random type(boolean)');
		invalidDefinitions.add('random type(city) group(one)');
		invalidDefinitions.add('random type(country) group(one)');
		invalidDefinitions.add('random type(date) From(2017-01-01) To(2017-12-31)');
		invalidDefinitions.add('random type(datetime) From(2017-01-01) To(2017-12-31)');
		invalidDefinitions.add('random type(time) from(05:15:21) to(17:18:22)');
		invalidDefinitions.add('random type(email)');
		invalidDefinitions.add('random type(firstName) Group(one)');
		invalidDefinitions.add('random type(lastName) group(one)');
		invalidDefinitions.add('random type(list) value(1, 2, 3)');
		invalidDefinitions.add('random type(list) value(1.1, 2.2, 3.3)');
		invalidDefinitions.add('random type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
		invalidDefinitions.add('random type(list) value(2017-01-01, 2017-02-02, 2017-03-03)');
		invalidDefinitions.add('random type(picklist) except(One,Two)');
		invalidDefinitions.add('random type(picklist)');
		invalidDefinitions.add('random type(postalCode) group(one)');
		invalidDefinitions.add('random type(state) group(one)');
		invalidDefinitions.add('random type(street) group(one)');
		invalidDefinitions.add('random type(string) minLength(10) maxLength(30) startWith(lower) include(lower,upper,digit)');
		invalidDefinitions.add('random type(text) minLength(10) maxlength(30)');
		invalidDefinitions.add('random type(url)');
		invalidDefinitions.add('serial lookup(Account) mode(cyclical) source(forceea)');
		invalidDefinitions.add('serial type(date) from(2017-01-01) Step(2)');
		invalidDefinitions.add('serial type(datetime) from(2017-01-01 02:02:02) step(2.2)');
		invalidDefinitions.add('serial type(picklist) mode(cyclical)');
		invalidDefinitions.add('static lookup(Account) field(FieldOne) value(one) source(forceea)');
		invalidDefinitions.add('static value(01:01:01)');
		invalidDefinitions.add('static value(10.1)');
		invalidDefinitions.add('static value(2017-01-01 01:01:01)');
		invalidDefinitions.add('static value(2017-01-01)');

		Test.startTest();
		Boolean expectedResult = false;
		Boolean actualResult = ForceeaUtilityTest.definitionsAreValid(
			new FObject(FObjectOne__c.SObjectType), fieldApiName, validDefinitions, invalidDefinitions);
		Test.stopTest();

		System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
	}

	@IsTest
	private static void isValidForFieldDataType_recordType_expectFailure() {
		String fieldApiName = 'RecordTypeId';

		List<String> validDefinitions = new List<String>();
		validDefinitions.add('copy field(TestPicklistD__c)');
		validDefinitions.add('copy field(TestLookup__c) from(FObjectTwo__c.TestText__c)');
		validDefinitions.add('random type(list) value(One, Two, Three)');
		validDefinitions.add('random type(picklist) except(One,Two)');
		validDefinitions.add('random type(picklist)');
		validDefinitions.add('serial type(list) value(One,Two,Three) mode(cyclical)');
		validDefinitions.add('serial type(picklist) mode(cyclical)');
		validDefinitions.add('static value(One)');

		List<String> invalidDefinitions = new List<String>();
		invalidDefinitions.add('mock type(id)');
		invalidDefinitions.add('random lookup(Account) field(FieldOne) except(One,Two,Three) source(forceea)');
		invalidDefinitions.add('random lookup(Account) field(FieldOne) value(One,Two,Three) source(forceea)');
		invalidDefinitions.add('random lookup(Account) source(forceea)');
		invalidDefinitions.add('random lookup(Account) where(Rating = \'Hot\') source(salesforce)');
		invalidDefinitions.add('random type(boolean)');
		invalidDefinitions.add('random type(city) group(one)');
		invalidDefinitions.add('random type(country) group(one)');
		invalidDefinitions.add('random type(date) From(2017-01-01) To(2017-12-31)');
		invalidDefinitions.add('random type(datetime) From(2017-01-01) To(2017-12-31)');
		invalidDefinitions.add('random type(time) from(05:15:21) to(17:18:22)');
		invalidDefinitions.add('random type(email)');
		invalidDefinitions.add('random type(phone) Format(30 210 dD DD ddD)');
		invalidDefinitions.add('random type(firstName) Group(one)');
		invalidDefinitions.add('random type(lastName) group(one)');
		invalidDefinitions.add('random type(list) value(1, 2, 3)');
		invalidDefinitions.add('random type(list) value(1.1, 2.2, 3.3)');
		invalidDefinitions.add('random type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
		invalidDefinitions.add('random type(list) value(2017-01-01, 2017-02-02, 2017-03-03)');
		invalidDefinitions.add('random type(number) from(1) to(100) scale(0)');
		invalidDefinitions.add('random type(postalCode) group(one)');
		invalidDefinitions.add('random type(state) group(one)');
		invalidDefinitions.add('random type(street) group(one)');
		invalidDefinitions.add('random type(string) minLength(10) maxLength(30) startWith(lower) include(lower,upper,digit)');
		invalidDefinitions.add('random type(text) minLength(10) maxlength(30)');
		invalidDefinitions.add('random type(url)');
		invalidDefinitions.add('serial lookup(Account) mode(cyclical) source(forceea)');
		invalidDefinitions.add('serial type(date) from(2017-01-01) Step(2)');
		invalidDefinitions.add('serial type(datetime) from(2017-01-01 02:02:02) step(2.2)');
		invalidDefinitions.add('serial type(number) from(10.2) step(1.2) scale(2)');
		invalidDefinitions.add('static lookup(Account) field(FieldOne) value(one) source(forceea)');
		invalidDefinitions.add('static value(01:01:01)');
		invalidDefinitions.add('static value(10.1)');
		invalidDefinitions.add('static value(10)');
		invalidDefinitions.add('static value(2017-01-01 01:01:01)');
		invalidDefinitions.add('static value(2017-01-01)');
		invalidDefinitions.add('static value("")');

		Test.startTest();
		Boolean expectedResult = false;
		Boolean actualResult = ForceeaUtilityTest.definitionsAreValid(
			new FObject(FObjectOne__c.SObjectType), fieldApiName, validDefinitions, invalidDefinitions);
		Test.stopTest();

		System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
	}

	@IsTest
	private static void isValidForFieldDataType_reference_expectFailure() {
		String fieldApiName = 'TestLookup__c';

		List<String> validDefinitions = new List<String>();
		validDefinitions.add('random lookup(Account) field(FieldOne) except(One,Two,Three) source(forceea)');
		validDefinitions.add('random lookup(Account) field(FieldOne) value(One,Two,Three) source(forceea)');
		validDefinitions.add('random lookup(Account) source(forceea)');
		validDefinitions.add('random lookup(Account) where(Rating = \'Hot\') source(salesforce)');
		validDefinitions.add('serial lookup(Account) mode(cyclical) source(forceea)');
		validDefinitions.add('static lookup(Account) field(FieldOne) value(one) source(forceea)');

		List<String> invalidDefinitions = new List<String>();
		invalidDefinitions.add('copy field(TestPicklistD__c)');
		invalidDefinitions.add('copy field(TestLookup__c) from(FObjectTwo__c.TestText__c)');
		invalidDefinitions.add('mock type(id)');
		invalidDefinitions.add('random type(boolean)');
		invalidDefinitions.add('random type(city) group(one)');
		invalidDefinitions.add('random type(country) group(one)');
		invalidDefinitions.add('random type(date) From(2017-01-01) To(2017-12-31)');
		invalidDefinitions.add('random type(datetime) From(2017-01-01) To(2017-12-31)');
		invalidDefinitions.add('random type(time) from(05:15:21) to(17:18:22)');
		invalidDefinitions.add('random type(email)');
		invalidDefinitions.add('random type(phone) Format(30 210 dD DD ddD)');
		invalidDefinitions.add('random type(firstName) Group(one)');
		invalidDefinitions.add('random type(lastName) group(one)');
		invalidDefinitions.add('random type(list) value(1, 2, 3)');
		invalidDefinitions.add('random type(list) value(1.1, 2.2, 3.3)');
		invalidDefinitions.add('random type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
		invalidDefinitions.add('random type(list) value(2017-01-01, 2017-02-02, 2017-03-03)');
		invalidDefinitions.add('random type(list) value(One, Two, Three)');
		invalidDefinitions.add('random type(number) from(1) to(100) scale(0)');
		invalidDefinitions.add('random type(picklist) except(One,Two)');
		invalidDefinitions.add('random type(picklist)');
		invalidDefinitions.add('random type(postalCode) group(one)');
		invalidDefinitions.add('random type(state) group(one)');
		invalidDefinitions.add('random type(street) group(one)');
		invalidDefinitions.add('random type(string) minLength(10) maxLength(30) startWith(lower) include(lower,upper,digit)');
		invalidDefinitions.add('random type(text) minLength(10) maxlength(30)');
		invalidDefinitions.add('random type(url)');
		invalidDefinitions.add('serial type(date) from(2017-01-01) Step(2)');
		invalidDefinitions.add('serial type(datetime) from(2017-01-01 02:02:02) step(2.2)');
		invalidDefinitions.add('serial type(list) value(One,Two,Three) mode(cyclical)');
		invalidDefinitions.add('serial type(picklist) mode(cyclical)');
		invalidDefinitions.add('serial type(number) from(10.2) step(1.2) scale(2)');
		invalidDefinitions.add('static value(01:01:01)');
		invalidDefinitions.add('static value(10.1)');
		invalidDefinitions.add('static value(10)');
		invalidDefinitions.add('static value(2017-01-01 01:01:01)');
		invalidDefinitions.add('static value(2017-01-01)');
		invalidDefinitions.add('static value(One)');
		invalidDefinitions.add('static value("")');

		Test.startTest();
		Boolean expectedResult = false;
		Boolean actualResult = ForceeaUtilityTest.definitionsAreValid(
			new FObject(FObjectOne__c.SObjectType), fieldApiName, validDefinitions, invalidDefinitions);
		Test.stopTest();

		System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
	}

	@IsTest
	private static void isValidForFieldDataType_string_expectFailure() {
		String fieldApiName = 'TestText__c';

		List<String> validDefinitions = new List<String>();
		validDefinitions.add('copy field(TestPicklistD__c)');
		validDefinitions.add('copy field(TestLookup__c) from(FObjectTwo__c.TestText__c)');
		validDefinitions.add('random type(boolean)');
		validDefinitions.add('random type(city) group(one)');
		validDefinitions.add('random type(country) group(one)');
		validDefinitions.add('random type(date) From(2017-01-01) To(2017-12-31)');
		validDefinitions.add('random type(datetime) From(2017-01-01) To(2017-12-31)');
		validDefinitions.add('random type(time) from(05:15:21) to(17:18:22)');
		validDefinitions.add('random type(email)');
		validDefinitions.add('random type(phone) Format(30 210 dD DD ddD)');
		validDefinitions.add('random type(firstName) Group(one)');
		validDefinitions.add('random type(lastName) group(one)');
		validDefinitions.add('random type(list) value(1, 2, 3)');
		validDefinitions.add('random type(list) value(1.1, 2.2, 3.3)');
		validDefinitions.add('random type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
		validDefinitions.add('random type(list) value(2017-01-01, 2017-02-02, 2017-03-03)');
		validDefinitions.add('random type(list) value(One, Two, Three)');
		validDefinitions.add('random type(number) from(1) to(100) scale(0)');
		validDefinitions.add('random type(postalCode) group(one)');
		validDefinitions.add('random type(state) group(one)');
		validDefinitions.add('random type(street) group(one)');
		validDefinitions.add('random type(string) minLength(10) maxLength(30) startWith(lower) include(lower,upper,digit)');
		validDefinitions.add('random type(text) minLength(10) maxlength(30)');
		validDefinitions.add('random type(url)');
		validDefinitions.add('serial type(date) from(2017-01-01) Step(2)');
		validDefinitions.add('serial type(datetime) from(2017-01-01 02:02:02) step(2.2)');
		validDefinitions.add('serial type(list) value(One,Two,Three) mode(cyclical)');
		validDefinitions.add('serial type(number) from(10.2) step(1.2) scale(2)');
		validDefinitions.add('static value(01:01:01)');
		validDefinitions.add('static value(10.1)');
		validDefinitions.add('static value(10)');
		validDefinitions.add('static value(2017-01-01 01:01:01)');
		validDefinitions.add('static value(2017-01-01)');
		validDefinitions.add('static value(One)');
		validDefinitions.add('static value("")');

		List<String> invalidDefinitions = new List<String>();
		invalidDefinitions.add('mock type(id)');
		invalidDefinitions.add('random lookup(Account) field(FieldOne) except(One,Two,Three) source(forceea)');
		invalidDefinitions.add('random lookup(Account) field(FieldOne) value(One,Two,Three) source(forceea)');
		invalidDefinitions.add('random lookup(Account) source(forceea)');
		invalidDefinitions.add('random lookup(Account) where(Rating = \'Hot\') source(salesforce)');
		invalidDefinitions.add('random type(picklist) except(One,Two)');
		invalidDefinitions.add('random type(picklist)');
		invalidDefinitions.add('serial type(picklist) mode(cyclical)');
		invalidDefinitions.add('serial lookup(Account) mode(cyclical) source(forceea)');
		invalidDefinitions.add('static lookup(Account) field(FieldOne) value(one) source(forceea)');

		Test.startTest();
		Boolean expectedResult = false;
		Boolean actualResult = ForceeaUtilityTest.definitionsAreValid(
			new FObject(FObjectOne__c.SObjectType), fieldApiName, validDefinitions, invalidDefinitions);
		Test.stopTest();

		System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
	}

	@IsTest
	private static void isValidForFieldDataType_textArea_expectFailure() {
		String fieldApiName = 'TestTextArea__c';

		List<String> validDefinitions = new List<String>();
		validDefinitions.add('copy field(TestPicklistD__c)');
		validDefinitions.add('copy field(TestLookup__c) from(FObjectTwo__c.TestText__c)');
		validDefinitions.add('random type(boolean)');
		validDefinitions.add('random type(city) group(one)');
		validDefinitions.add('random type(country) group(one)');
		validDefinitions.add('random type(date) From(2017-01-01) To(2017-12-31)');
		validDefinitions.add('random type(datetime) From(2017-01-01) To(2017-12-31)');
		validDefinitions.add('random type(time) from(05:15:21) to(17:18:22)');
		validDefinitions.add('random type(email)');
		validDefinitions.add('random type(phone) Format(30 210 dD DD ddD)');
		validDefinitions.add('random type(firstName) Group(one)');
		validDefinitions.add('random type(lastName) group(one)');
		validDefinitions.add('random type(list) value(1, 2, 3)');
		validDefinitions.add('random type(list) value(1.1, 2.2, 3.3)');
		validDefinitions.add('random type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
		validDefinitions.add('random type(list) value(2017-01-01, 2017-02-02, 2017-03-03)');
		validDefinitions.add('random type(list) value(One, Two, Three)');
		validDefinitions.add('random type(number) from(1) to(100) scale(0)');
		validDefinitions.add('random type(postalCode) group(one)');
		validDefinitions.add('random type(state) group(one)');
		validDefinitions.add('random type(street) group(one)');
		validDefinitions.add('random type(string) minLength(10) maxLength(30) startWith(lower) include(lower,upper,digit)');
		validDefinitions.add('random type(text) minLength(10) maxlength(30)');
		validDefinitions.add('random type(url)');
		validDefinitions.add('serial type(date) from(2017-01-01) Step(2)');
		validDefinitions.add('serial type(datetime) from(2017-01-01 02:02:02) step(2.2)');
		validDefinitions.add('serial type(list) value(One,Two,Three) mode(cyclical)');
		validDefinitions.add('serial type(number) from(10.2) step(1.2) scale(2)');
		validDefinitions.add('static value(01:01:01)');
		validDefinitions.add('static value(10.1)');
		validDefinitions.add('static value(10)');
		validDefinitions.add('static value(2017-01-01 01:01:01)');
		validDefinitions.add('static value(2017-01-01)');
		validDefinitions.add('static value(One)');
		validDefinitions.add('static value("")');

		List<String> invalidDefinitions = new List<String>();
		invalidDefinitions.add('mock type(id)');
		invalidDefinitions.add('random lookup(Account) field(FieldOne) except(One,Two,Three) source(forceea)');
		invalidDefinitions.add('random lookup(Account) field(FieldOne) value(One,Two,Three) source(forceea)');
		invalidDefinitions.add('random lookup(Account) source(forceea)');
		invalidDefinitions.add('random lookup(Account) where(Rating = \'Hot\') source(salesforce)');
		invalidDefinitions.add('random type(picklist) except(One,Two)');
		invalidDefinitions.add('random type(picklist)');
		invalidDefinitions.add('serial type(picklist) mode(cyclical)');
		invalidDefinitions.add('serial lookup(Account) mode(cyclical) source(forceea)');
		invalidDefinitions.add('static lookup(Account) field(FieldOne) value(one) source(forceea)');

		Test.startTest();
		Boolean expectedResult = false;
		Boolean actualResult = ForceeaUtilityTest.definitionsAreValid(
			new FObject(FObjectOne__c.SObjectType), fieldApiName, validDefinitions, invalidDefinitions);
		Test.stopTest();

		System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
	}

	@IsTest
	private static void isValidForFieldDataType_textAreaLong_expectFailure() {
		String fieldApiName = 'TestTextAreaLong__c';

		List<String> validDefinitions = new List<String>();
		validDefinitions.add('copy field(TestPicklistD__c)');
		validDefinitions.add('copy field(TestLookup__c) from(FObjectTwo__c.TestText__c)');
		validDefinitions.add('random type(boolean)');
		validDefinitions.add('random type(city) group(one)');
		validDefinitions.add('random type(country) group(one)');
		validDefinitions.add('random type(date) From(2017-01-01) To(2017-12-31)');
		validDefinitions.add('random type(datetime) From(2017-01-01) To(2017-12-31)');
		validDefinitions.add('random type(time) from(05:15:21) to(17:18:22)');
		validDefinitions.add('random type(email)');
		validDefinitions.add('random type(phone) Format(30 210 dD DD ddD)');
		validDefinitions.add('random type(firstName) Group(one)');
		validDefinitions.add('random type(lastName) group(one)');
		validDefinitions.add('random type(list) value(1, 2, 3)');
		validDefinitions.add('random type(list) value(1.1, 2.2, 3.3)');
		validDefinitions.add('random type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
		validDefinitions.add('random type(list) value(2017-01-01, 2017-02-02, 2017-03-03)');
		validDefinitions.add('random type(list) value(One, Two, Three)');
		validDefinitions.add('random type(number) from(1) to(100) scale(0)');
		validDefinitions.add('random type(postalCode) group(one)');
		validDefinitions.add('random type(state) group(one)');
		validDefinitions.add('random type(street) group(one)');
		validDefinitions.add('random type(string) minLength(10) maxLength(30) startWith(lower) include(lower,upper,digit)');
		validDefinitions.add('random type(text) minLength(10) maxlength(30)');
		validDefinitions.add('random type(url)');
		validDefinitions.add('serial type(date) from(2017-01-01) Step(2)');
		validDefinitions.add('serial type(datetime) from(2017-01-01 02:02:02) step(2.2)');
		validDefinitions.add('serial type(list) value(One,Two,Three) mode(cyclical)');
		validDefinitions.add('serial type(number) from(10.2) step(1.2) scale(2)');
		validDefinitions.add('static value(01:01:01)');
		validDefinitions.add('static value(10.1)');
		validDefinitions.add('static value(10)');
		validDefinitions.add('static value(2017-01-01 01:01:01)');
		validDefinitions.add('static value(2017-01-01)');
		validDefinitions.add('static value(One)');
		validDefinitions.add('static value("")');

		List<String> invalidDefinitions = new List<String>();
		invalidDefinitions.add('mock type(id)');
		invalidDefinitions.add('random lookup(Account) field(FieldOne) except(One,Two,Three) source(forceea)');
		invalidDefinitions.add('random lookup(Account) field(FieldOne) value(One,Two,Three) source(forceea)');
		invalidDefinitions.add('random lookup(Account) source(forceea)');
		invalidDefinitions.add('random lookup(Account) where(Rating = \'Hot\') source(salesforce)');
		invalidDefinitions.add('random type(picklist) except(One,Two)');
		invalidDefinitions.add('random type(picklist)');
		invalidDefinitions.add('serial type(picklist) mode(cyclical)');
		invalidDefinitions.add('serial lookup(Account) mode(cyclical) source(forceea)');
		invalidDefinitions.add('static lookup(Account) field(FieldOne) value(one) source(forceea)');

		Test.startTest();
		Boolean expectedResult = false;
		Boolean actualResult = ForceeaUtilityTest.definitionsAreValid(
			new FObject(FObjectOne__c.SObjectType), fieldApiName, validDefinitions, invalidDefinitions);
		Test.stopTest();

		System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
	}

	@IsTest
	private static void isValidForFieldDataType_textAreaRich_expectFailure() {
		String fieldApiName = 'TestTextAreaRich__c';

		List<String> validDefinitions = new List<String>();
		validDefinitions.add('copy field(TestPicklistD__c)');
		validDefinitions.add('copy field(TestLookup__c) from(FObjectTwo__c.TestText__c)');
		validDefinitions.add('random type(boolean)');
		validDefinitions.add('random type(city) group(one)');
		validDefinitions.add('random type(country) group(one)');
		validDefinitions.add('random type(date) From(2017-01-01) To(2017-12-31)');
		validDefinitions.add('random type(datetime) From(2017-01-01) To(2017-12-31)');
		validDefinitions.add('random type(time) from(05:15:21) to(17:18:22)');
		validDefinitions.add('random type(email)');
		validDefinitions.add('random type(phone) Format(30 210 dD DD ddD)');
		validDefinitions.add('random type(firstName) Group(one)');
		validDefinitions.add('random type(lastName) group(one)');
		validDefinitions.add('random type(list) value(1, 2, 3)');
		validDefinitions.add('random type(list) value(1.1, 2.2, 3.3)');
		validDefinitions.add('random type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
		validDefinitions.add('random type(list) value(2017-01-01, 2017-02-02, 2017-03-03)');
		validDefinitions.add('random type(list) value(One, Two, Three)');
		validDefinitions.add('random type(number) from(1) to(100) scale(0)');
		validDefinitions.add('random type(postalCode) group(one)');
		validDefinitions.add('random type(state) group(one)');
		validDefinitions.add('random type(street) group(one)');
		validDefinitions.add('random type(string) minLength(10) maxLength(30) startWith(lower) include(lower,upper,digit)');
		validDefinitions.add('random type(text) minLength(10) maxlength(30)');
		validDefinitions.add('random type(url)');
		validDefinitions.add('serial type(date) from(2017-01-01) Step(2)');
		validDefinitions.add('serial type(datetime) from(2017-01-01 02:02:02) step(2.2)');
		validDefinitions.add('serial type(list) value(One,Two,Three) mode(cyclical)');
		validDefinitions.add('serial type(number) from(10.2) step(1.2) scale(2)');
		validDefinitions.add('static value(01:01:01)');
		validDefinitions.add('static value(10.1)');
		validDefinitions.add('static value(10)');
		validDefinitions.add('static value(2017-01-01 01:01:01)');
		validDefinitions.add('static value(2017-01-01)');
		validDefinitions.add('static value(One)');
		validDefinitions.add('static value("")');

		List<String> invalidDefinitions = new List<String>();
		invalidDefinitions.add('mock type(id)');
		invalidDefinitions.add('random lookup(Account) field(FieldOne) except(One,Two,Three) source(forceea)');
		invalidDefinitions.add('random lookup(Account) field(FieldOne) value(One,Two,Three) source(forceea)');
		invalidDefinitions.add('random lookup(Account) source(forceea)');
		invalidDefinitions.add('random lookup(Account) where(Rating = \'Hot\') source(salesforce)');
		invalidDefinitions.add('random type(picklist) except(One,Two)');
		invalidDefinitions.add('random type(picklist)');
		invalidDefinitions.add('serial type(picklist) mode(cyclical)');
		invalidDefinitions.add('serial lookup(Account) mode(cyclical) source(forceea)');
		invalidDefinitions.add('static lookup(Account) field(FieldOne) value(one) source(forceea)');

		Test.startTest();
		Boolean expectedResult = false;
		Boolean actualResult = ForceeaUtilityTest.definitionsAreValid(
			new FObject(FObjectOne__c.SObjectType), fieldApiName, validDefinitions, invalidDefinitions);
		Test.stopTest();

		System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
	}

	@IsTest
	private static void isValidForFieldDataType_time_expectSuccess() {
		String fieldApiName = 'TestTime__c';

		List<String> validDefinitions = new List<String>();
		validDefinitions.add('static value(01:01:01)');
		validDefinitions.add('random type(time) from(05:15:21) to(17:18:22)');
		validDefinitions.add('random type(list) value(01:01:01, 02:02:02, 03:03:03)');
		validDefinitions.add('serial type(list) value(One,Two,Three) mode(cyclical)');
		validDefinitions.add('copy field(TestPicklistD__c)');

		List<String> invalidDefinitions = new List<String>();
		invalidDefinitions.add('copy field(TestLookup__c) from(FObjectTwo__c.TestText__c)');
		invalidDefinitions.add('mock type(id)');
		invalidDefinitions.add('random lookup(Account) field(FieldOne) except(One,Two,Three) source(forceea)');
		invalidDefinitions.add('random lookup(Account) field(FieldOne) value(One,Two,Three) source(forceea)');
		invalidDefinitions.add('random lookup(Account) source(forceea)');
		invalidDefinitions.add('random lookup(Account) where(Rating = \'Hot\') source(salesforce)');
		invalidDefinitions.add('random type(boolean)');
		invalidDefinitions.add('random type(city) group(one)');
		invalidDefinitions.add('random type(country) group(one)');
		invalidDefinitions.add('random type(date) From(2017-01-01) To(2017-12-31)');
		invalidDefinitions.add('random type(datetime) From(2017-01-01) To(2017-12-31)');
		invalidDefinitions.add('random type(email)');
		invalidDefinitions.add('random type(phone) Format(30 210 dD DD ddD)');
		invalidDefinitions.add('random type(firstName) Group(one)');
		invalidDefinitions.add('random type(lastName) group(one)');
		invalidDefinitions.add('random type(list) value(1, 2, 3)');
		invalidDefinitions.add('random type(list) value(1.1, 2.2, 3.3)');
		invalidDefinitions.add('random type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
		invalidDefinitions.add('random type(list) value(2017-01-01, 2017-02-02, 2017-03-03)');
		invalidDefinitions.add('random type(list) value(One, Two, Three)');
		invalidDefinitions.add('random type(number) from(1) to(100) scale(0)');
		invalidDefinitions.add('random type(picklist) except(One,Two)');
		invalidDefinitions.add('random type(picklist)');
		invalidDefinitions.add('random type(postalCode) group(one)');
		invalidDefinitions.add('random type(state) group(one)');
		invalidDefinitions.add('random type(street) group(one)');
		invalidDefinitions.add('random type(string) minLength(10) maxLength(30) startWith(lower) include(lower,upper,digit)');
		invalidDefinitions.add('random type(text) minLength(10) maxlength(30)');
		invalidDefinitions.add('random type(url)');
		invalidDefinitions.add('serial lookup(Account) mode(cyclical) source(forceea)');
		invalidDefinitions.add('serial type(date) from(2017-01-01) Step(2)');
		invalidDefinitions.add('serial type(datetime) from(2017-01-01 02:02:02) step(2.2)');
		invalidDefinitions.add('serial type(picklist) mode(cyclical)');
		invalidDefinitions.add('serial type(number) from(10.2) step(1.2) scale(2)');
		invalidDefinitions.add('static lookup(Account) field(FieldOne) value(one) source(forceea)');
		invalidDefinitions.add('static value(10.1)');
		invalidDefinitions.add('static value(10)');
		invalidDefinitions.add('static value(2017-01-01 01:01:01)');
		invalidDefinitions.add('static value(2017-01-01)');
		invalidDefinitions.add('static value(One)');
		validDefinitions.add('static value("")');

		Test.startTest();
		Boolean expectedResult = false;
		Boolean actualResult = ForceeaUtilityTest.definitionsAreValid(
			new FObject(FObjectOne__c.SObjectType), fieldApiName, validDefinitions, invalidDefinitions);
		Test.stopTest();

		System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
	}

	@IsTest
	private static void isValidForFieldDataType_url_expectFailure() {
		String fieldApiName = 'TestUrl__c';

		List<String> validDefinitions = new List<String>();
		validDefinitions.add('copy field(TestPicklistD__c)');
		validDefinitions.add('copy field(TestLookup__c) from(FObjectTwo__c.TestText__c)');
		validDefinitions.add('random type(list) value(1, 2, 3)');
		validDefinitions.add('random type(list) value(One, Two, Three)');
		validDefinitions.add('random type(number) from(1) to(100) scale(0)');
		validDefinitions.add('random type(string) minLength(10) maxLength(30) startWith(lower) include(lower,upper,digit)');
		validDefinitions.add('random type(url)');
		validDefinitions.add('serial type(number) from(10.2) step(1.2) scale(2)');
		validDefinitions.add('static value(10)');
		validDefinitions.add('static value(One)');
		validDefinitions.add('static value("")');

		List<String> invalidDefinitions = new List<String>();
		invalidDefinitions.add('mock type(id)');
		invalidDefinitions.add('random lookup(Account) field(FieldOne) except(One,Two,Three) source(forceea)');
		invalidDefinitions.add('random lookup(Account) field(FieldOne) value(One,Two,Three) source(forceea)');
		invalidDefinitions.add('random lookup(Account) source(forceea)');
		invalidDefinitions.add('random lookup(Account) where(Rating = \'Hot\') source(salesforce)');
		invalidDefinitions.add('random type(boolean)');
		invalidDefinitions.add('random type(city) group(one)');
		invalidDefinitions.add('random type(country) group(one)');
		invalidDefinitions.add('random type(date) From(2017-01-01) To(2017-12-31)');
		invalidDefinitions.add('random type(datetime) From(2017-01-01) To(2017-12-31)');
		invalidDefinitions.add('random type(time) from(05:15:21) to(17:18:22)');
		invalidDefinitions.add('random type(email)');
		invalidDefinitions.add('random type(phone) Format(30 210 dD DD ddD)');
		invalidDefinitions.add('random type(firstName) Group(one)');
		invalidDefinitions.add('random type(lastName) group(one)');
		invalidDefinitions.add('random type(list) value(1.1, 2.2, 3.3)');
		invalidDefinitions.add('random type(list) value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
		invalidDefinitions.add('random type(list) value(2017-01-01, 2017-02-02, 2017-03-03)');
		invalidDefinitions.add('random type(picklist) except(One,Two)');
		invalidDefinitions.add('random type(picklist)');
		invalidDefinitions.add('random type(postalCode) group(one)');
		invalidDefinitions.add('random type(state) group(one)');
		invalidDefinitions.add('random type(street) group(one)');
		invalidDefinitions.add('random type(text) minLength(10) maxlength(30)');
		invalidDefinitions.add('serial lookup(Account) mode(cyclical) source(forceea)');
		invalidDefinitions.add('serial type(date) from(2017-01-01) Step(2)');
		invalidDefinitions.add('serial type(datetime) from(2017-01-01 02:02:02) step(2.2)');
		invalidDefinitions.add('serial type(list) value(One,Two,Three) mode(cyclical)');
		invalidDefinitions.add('serial type(picklist) mode(cyclical)');
		invalidDefinitions.add('static lookup(Account) field(FieldOne) value(one) source(forceea)');
		invalidDefinitions.add('static value(01:01:01)');
		invalidDefinitions.add('static value(10.1)');
		invalidDefinitions.add('static value(2017-01-01 01:01:01)');
		invalidDefinitions.add('static value(2017-01-01)');

		Test.startTest();
		Boolean expectedResult = false;
		Boolean actualResult = ForceeaUtilityTest.definitionsAreValid(
			new FObject(FObjectOne__c.SObjectType), fieldApiName, validDefinitions, invalidDefinitions);
		Test.stopTest();

		System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
	}

	@IsTest
	private static void isValidForFieldDataType_valid_expectSuccess() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10);
		obj.setDefinition(FObjectOne__c.Id, 'Mock type(id)')
			.setDefinition(FObjectOne__c.TestCheckbox__c, 'Random type(boolean)')
			.setDefinition(FObjectOne__c.TestCurrency__c, 'random type(number) From(1) To(100) Scale(0)')
			.setDefinition(FObjectOne__c.TestDate__c, 'Random type(date) From(2017-01-01) To(2017-12-31)')
			.setDefinition(FObjectOne__c.TestDatetime__c, 'Random type(datetime) From(2017-01-01) To(2017-12-31)')
			.setDefinition(FObjectOne__c.TestDecimal__c, 'random type(number) From(1) To(100) Scale(0)')
			.setDefinition(FObjectOne__c.TestEmail__c, 'Random type(email)')
			.setDefinition(FObjectOne__c.TestLookup__c, 'Random lookup(FObjectTwo__c) source(Salesforce)')
			.setDefinition(FObjectOne__c.TestMultiPicklistA__c, 'Random type(picklist)')
			.setDefinition(FObjectOne__c.TestPercent__c, 'random type(number) From(0) To(1) Scale(2)')
			.setDefinition(FObjectOne__c.TestPhone__c, 'Random type(phone) Format(30 210 dD DD ddD)')
			.setDefinition(FObjectOne__c.TestPicklistC__c, 'Random type(picklist)')
			.setDefinition(FObjectOne__c.TestText__c, 'copy field(TestPicklistC__c)')
			.setDefinition(FObjectOne__c.TestText__c,
				'random type(string) minLength(10) maxLength(30) startWith(lower) include(lower,upper,digit)')
			.setDefinition(FObjectOne__c.TestTextArea__c,
				'random type(string) minLength(10) maxLength(30) startWith(lower) include(lower,upper,digit)')
			.setDefinition(FObjectOne__c.TestTextAreaLong__c,
				'random type(string) minLength(10) maxLength(30) startWith(lower) include(lower,upper,digit)')
			.setDefinition(FObjectOne__c.TestTextAreaRich__c,
				'random type(string) minLength(10) maxLength(30) startWith(lower) include(lower,upper,digit)')
			.setDefinition(FObjectOne__c.TestTime__c, 'Static value(02:02:02)')
			.setDefinition(FObjectOne__c.TestUrl__c, 'Random Type(Url)')
			.getRecords();
		Test.stopTest();

		System.assert(obj.getErrors().isEmpty(), 'definitionIsValidForFieldDataType - errors found');
	}
	
	@IsTest
	private static void setDefinition_scriptIsBlank_expectFailure() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		obj.setDefinition('TestText__c', '');
		obj.insertRecords(true);
		Test.stopTest();

		String expectedResult= 'Invalid command [] in definition []';
		String actualResult = obj.getErrors().get('TestText__c').get(0);
		System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
	}

	@IsTest
	private static void setDefinition_definitionsWithSpacesAndCase_expectSuccess() {
		String field1 = 'TestDecimal__c';
		String field2 = 'TestText__c';
		String field3 = 'TestPicklistA__c';
		String field4 = 'TestPicklistC__c';
		String field5 = 'TestPicklistB__c ';
		String definition1 = 'Random from( 100)  Type("number" ) to( "1000000" ) scale(3 )';
		String definition2 = 'Serial Type(Number) from (1) scale (0)  step (1) ';
		String definition3 = 'random except( a1,  "a2") Type ( "picklist")  ';
		String definition4 = ' random value( c1,c2 ) type ( list )';
		String definition5 = ' Random  type( picklist ) ';

		Test.startTest();
		FObject obj = new FObject(' FObjectOne__c ');
		obj.setDefinition(field1, definition1);
		obj.setDefinition(field2, definition2);
		obj.setDefinition(field3, definition3);
		obj.setDefinition(field4, definition4);
		obj.setDefinition(field5, definition5);
		List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
		Test.stopTest();

		Integer errors = 0;
		if (obj.getErrors().containsKey(field1)) {
			errors += 1;
		}
		if (obj.getErrors().containsKey(field2)) {
			errors += 2;
		}
		if (obj.getErrors().containsKey(field3)) {
			errors += 4;
		}
		if (obj.getErrors().containsKey(field4)) {
			errors += 8;
		}
		if (obj.getErrors().containsKey(field5)) {
			errors += 16;
		}
		if (!FObject.processIsValid()) {
			errors += 32;
		}
		System.assertEquals(0, errors, 'setDefinition - errors found');
	}

	@IsTest
	private static void setDefinition_missingOpeningParenthesis1_expectFailure() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		obj.setDefinition('TestText__c', 'Static Value arg1) ');
		obj.insertRecords(true);
		Test.stopTest();

		String expectedResult = 'Invalid definition [Static Value arg1)] of field [TestText__c]';
		String actualResult = obj.getErrors().get('TestText__c').get(0);
		System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
	}

	@IsTest
	private static void setDefinition_missingOpeningParenthesis2_expectFailure() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		obj.setDefinition('TestText__c', 'Static Value "arg1")');
		obj.insertRecords(true);
		Test.stopTest();

		String expectedResult = 'Invalid definition [Static Value "arg1")] of field [TestText__c]';
		String actualResult = obj.getErrors().get('TestText__c').get(0);
		System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
	}

	@IsTest
	private static void setDefinition_missingOpeningParenthesis3_expectFailure() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		obj.setDefinition('TestText__c', 'Static Value arg1, arg2) ');
		obj.insertRecords(true);
		Test.stopTest();

		String expectedResult = 'Invalid definition [Static Value arg1, arg2)] of field [TestText__c]';
		String actualResult = obj.getErrors().get('TestText__c').get(0);
		System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
	}

	@IsTest
	private static void setDefinition_missingOpeningParenthesis4_expectFailure() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		obj.setDefinition('TestText__c', 'Static Value "arg1", arg2)');
		obj.insertRecords(true);
		Test.stopTest();

		String expectedResult = 'Invalid definition [Static Value "arg1", arg2)] of field [TestText__c]';
		String actualResult = obj.getErrors().get('TestText__c').get(0);
		System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
	}

	@IsTest
	private static void setDefinition_missingClosingParenthesis1_expectFailure() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		obj.setDefinition('TestText__c', 'Static Value(arg1');
		obj.insertRecords(true);
		Test.stopTest();

		String expectedResult = 'Invalid definition [Static Value(arg1] of field [TestText__c]';
		String actualResult = obj.getErrors().get('TestText__c').get(0);
		System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
	}

	@IsTest
	private static void setDefinition_missingClosingParenthesis2_expectFailure() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		obj.setDefinition('TestText__c', ' Static  Value("arg1" ');
		obj.insertRecords(true);
		Test.stopTest();

		String expectedResult = 'Invalid definition [Static  Value("arg1"] of field [TestText__c]';
		String actualResult = obj.getErrors().get('TestText__c').get(0);
		System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
	}

	@IsTest
	private static void setDefinition_missingClosingParenthesis3_expectFailure() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		obj.setDefinition('TestText__c', 'Static Value(arg1, arg2');
		obj.insertRecords(true);
		Test.stopTest();

		String expectedResult = 'Invalid definition [Static Value(arg1, arg2] of field [TestText__c]';
		String actualResult = obj.getErrors().get('TestText__c').get(0);
		System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
	}

	@IsTest
	private static void setDefinition_missingClosingParenthesis4_expectFailure() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		obj.setDefinition('TestText__c', 'Static Value("arg1", arg2');
		obj.insertRecords(true);
		Test.stopTest();

		String expectedResult = 'Invalid definition [Static Value("arg1", arg2] of field [TestText__c]';
		String actualResult = obj.getErrors().get('TestText__c').get(0);
		System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
	}

	@IsTest
	private static void setDefinition_missingClosingDoubleQuotes1_expectFailure() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		obj.setDefinition('TestText__c', 'Static Value("arg1)');
		obj.insertRecords(true);
		Test.stopTest();

		String expectedResult = 'Invalid definition [Static Value("arg1)] of field [TestText__c]';
		String actualResult = obj.getErrors().get('TestText__c').get(0);
		System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
	}

	@IsTest
	private static void setDefinition_missingClosingDoubleQuotes2_expectFailure() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		obj.setDefinition('TestText__c', 'Random type(list) value(arg1, "arg2)');
		obj.insertRecords(true);
		Test.stopTest();

		String expectedResult = 'Invalid definition [Random type(list) value(arg1, "arg2)] of field [TestText__c]';
		String actualResult = obj.getErrors().get('TestText__c').get(0);
		System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
	}

	@IsTest
	private static void setDefinition_missingClosingDoubleQuotes3_expectFailure() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		obj.setDefinition('TestText__c', 'Random type(list) value("arg1, arg2)');
		obj.insertRecords(true);
		Test.stopTest();

		String expectedResult = 'Invalid definition [Random type(list) value("arg1, arg2)] of field [TestText__c]';
		String actualResult = obj.getErrors().get('TestText__c').get(0);
		System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
	}

	@IsTest
	private static void setDefinition_invalidComma_expectFailure() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		obj.setDefinition('TestText__c', 'Random Type(List) ,Value(arg1, "arg2")');
		obj.insertRecords(true);
		Test.stopTest();

		String expectedResult = 'Invalid parameter [,Value] in definition [Random Type(List) ,Value(arg1, "arg2")]';
		String actualResult = obj.getErrors().get('TestText__c').get(0);
		System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
	}

	@IsTest
	private static void setDefinition_invalidDoubleQuotes1_expectFailure() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		obj.setDefinition('TestText__c', 'Random Type(List) "Value(arg1, "arg2")');
		obj.insertRecords(true);
		Test.stopTest();

		String expectedResult = 'Invalid parameter ["Value] in definition [Random Type(List) "Value(arg1, "arg2")]';
		String actualResult = obj.getErrors().get('TestText__c').get(0);
		System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
	}

	@IsTest
	private static void setDefinition_invalidDoubleQuotes2_expectFailure() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		obj.setDefinition('TestText__c', 'random type(list) value" (arg1, "arg2")');
		obj.insertRecords(true);
		Test.stopTest();

		String expectedResult = 'Invalid parameter [value"] in definition [random type(list) value" (arg1, "arg2")]';
		String actualResult = obj.getErrors().get('TestText__c').get(0);
		System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
	}

	@IsTest
	private static void setDefinition_invalidDoubleQuotes4_expectFailure() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		obj.setDefinition('TestText__c', 'Random type(list) value(arg1, ""arg2")');
		obj.insertRecords(true);
		Test.stopTest();

		String expectedResult = 'Invalid definition [Random type(list) value(arg1, ""arg2")] of field [TestText__c]';
		String actualResult = obj.getErrors().get('TestText__c').get(0);
		System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
	}

	@IsTest
	private static void setDefinition_invalidDoubleQuotes5_expectFailure() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		obj.setDefinition('TestText__c', 'Random type(list) value(arg1, "arg2"")');
		obj.insertRecords(true);
		Test.stopTest();

		String expectedResult = 'Invalid definition [Random type(list) value(arg1, "arg2"")] of field [TestText__c]';
		String actualResult = obj.getErrors().get('TestText__c').get(0);
		System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
	}

	@IsTest
	private static void setDefinition_invalidDoubleQuotes6_expectFailure() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		obj.setDefinition('TestText__c', 'Random type(list) value(arg1, "arg2")"');
		obj.insertRecords(true);
		Test.stopTest();

		String expectedResult = 'Invalid definition [Random type(list) value(arg1, "arg2")"] of field [TestText__c]';
		String actualResult = obj.getErrors().get('TestText__c').get(0);
		System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
	}

	@IsTest
	private static void setDefinition_fieldIsBlank_expectFailure() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		obj.setDefinition('', 'Static Value(Company)');
		obj.insertRecords(true);
		Test.stopTest();

		String expectedResult = 'Invalid field [] in definition [Static Value(Company)]';
		String actualResult = obj.getErrors().get('FObjectOne__c').get(0);
		System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
	}

	@IsTest
	private static void setDefinition_fieldIsInvalid_expectFailure() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		obj.setDefinition('TestTextX__c', 'Static Value(Company)');
		obj.insertRecords(true);
		Test.stopTest();

		String expectedResult = 'Invalid field [TestTextX__c] in definition [Static Value(Company)]';
		String actualResult = obj.getErrors().get('FObjectOne__c').get(0);
		System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
	}

	@IsTest
	private static void setDefinition_fieldBelongsToAnotherSObject_expectFailure() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType)
			.setDefinition(FObjectOne__c.TestText__c, 'static value(test1-)')
			.setDefinition(FObjectTwo__c.TestText__c, 'static value(test2)');
		obj.insertRecords(true);
		Test.stopTest();

		String expectedResult = 'Invalid field [TestText__c] for SObject [FObjectOne__c]';
		String actualResult = obj.getErrors().get('FObjectOne__c').get(0);
		System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
	}

	@IsTest
	private static void setDefinition_invalidCommand_expectFailure() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		obj.setDefinition('TestText__c', 'StaticX Value(Company)');
		obj.insertRecords(true);
		Test.stopTest();

		String expectedResult = 'Invalid command [StaticX] in definition [StaticX Value(Company)]';
		String actualResult = obj.getErrors().get('TestText__c').get(0);
		System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
	}

	@IsTest
	private static void setDefinition_invalidParameter1_expectFailure() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		obj.setDefinition('TestText__c', 'Static ValueX(Company) ');
		obj.insertRecords(true);
		Test.stopTest();

		String expectedResult = 'Invalid parameter [ValueX] in definition [Static ValueX(Company)]';
		String actualResult = obj.getErrors().get('TestText__c').get(0);
		System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
	}

	@IsTest
	private static void setDefinition_invalidParameter2_expectFailure() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		obj.setDefinition('TestText__c', 'Static (Company)');
		obj.insertRecords(true);
		Test.stopTest();

		String expectedResult = 'Invalid parameter [] in definition [Static (Company)]';
		String actualResult = obj.getErrors().get('TestText__c').get(0);
		System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
	}

	@IsTest
	private static void setDefinition_invalidParameter3_expectFailure() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		obj.setDefinition('TestText__c', 'Static abc)(Company)');
		obj.insertRecords(true);
		Test.stopTest();

		String expectedResult = 'Invalid parameter [abc)] in definition [Static abc)(Company)]';
		String actualResult = obj.getErrors().get('TestText__c').get(0);
		System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
	}

	@IsTest
	private static void setDefinition_invalidParameter4_expectFailure() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		obj.setDefinition('TestText__c', 'Static )(Company)');
		obj.insertRecords(true);
		Test.stopTest();

		String expectedResult = 'Invalid parameter [)] in definition [Static )(Company)]';
		String actualResult = obj.getErrors().get('TestText__c').get(0);
		System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
	}

	@IsTest
	private static void setDefinition_invalidParameter5_expectFailure() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		obj.setDefinition('TestText__c', 'Static abc"(Company)');
		obj.insertRecords(true);
		Test.stopTest();

		String expectedResult = 'Invalid parameter [abc"] in definition [Static abc"(Company)]';
		String actualResult = obj.getErrors().get('TestText__c').get(0);
		System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
	}

	@IsTest
	private static void setDefinition_invalidParameter6_expectFailure() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		obj.setDefinition('TestText__c', 'Static "(Company)');
		obj.insertRecords(true);
		Test.stopTest();

		String expectedResult = 'Invalid parameter ["] in definition [Static "(Company)]';
		String actualResult = obj.getErrors().get('TestText__c').get(0);
		System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
	}

	@IsTest
	private static void setDefinition_multipleDefinitionsForId_expectFailure() {
		String fieldApiName = 'Id';

		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		obj.setDefinition(fieldApiName, 'mock type(id)');
		obj.setDefinition(fieldApiName, 'static value(one)');
		List<FObjectOne__c> records = obj.getRecords();
		Test.stopTest();

		String expectedResult = 'Field [' + fieldApiName + '] does not accept multiple definitions';
		String actualResult = obj.getErrors().get(fieldApiName).get(0);
		System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
	}

	@IsTest
	private static void setDefinition_multipleDefinitionsForCheckbox_expectFailure() {
		String fieldApiName = 'TestCheckbox__c';

		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		obj.setDefinition(fieldApiName, 'random type(boolean)');
		obj.setDefinition(fieldApiName, 'static value(true)');
		List<FObjectOne__c> records = obj.getRecords();
		Test.stopTest();

		String expectedResult = 'Field [' + fieldApiName + '] does not accept multiple definitions';
		String actualResult = obj.getErrors().get(fieldApiName).get(0);
		System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
	}

	@IsTest
	private static void setDefinition_multipleDefinitionsForCombobox_expectSuccess() {
		String fieldApiName = 'Subject';

		Test.startTest();
		FObject obj = new FObject('Event');
		obj.setDefinition(fieldApiName, 'random type(picklist)');
		obj.setDefinition(fieldApiName, 'static value(One)');
		obj.setDefinition('Type', 'random type(picklist)');
		obj.setDefinition('WhoId', 'random lookup(Contact) source(forceea)');
		obj.setDefinition('ActivityDatetime', 'random type(datetime) from(2017-10-1) to(2017-12-31)');
		obj.setDefinition('DurationInMinutes', 'random type(number) from(1) to(10) scale(0)');
		List<FObjectOne__c> records = obj.getRecords();
		Test.stopTest();

		System.assert(obj.getErrors().isEmpty(), 'setDefinition - errors found');
	}

	@IsTest
	private static void setDefinition_multipleDefinitionsForCurrency_expectFailure() {
		String fieldApiName = 'TestCurrency__c';

		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		obj.setDefinition(fieldApiName, 'random type(number) from(1) to(10) scale(2)');
		obj.setDefinition(fieldApiName, 'random type(number) from(1) to(10) scale(2)');
		obj.insertRecords(true);
		Test.stopTest();

		String expectedResult = 'Field [' + fieldApiName + '] does not accept multiple definitions';
		String actualResult = obj.getErrors().get(fieldApiName).get(0);
		System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
	}

	@IsTest
	private static void setDefinition_multipleDefinitionsForDate_expectFailure() {
		String fieldApiName = 'TestDate__c';

		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		obj.setDefinition(fieldApiName, 'random type(date) from(2018-1-1) to(2018-2-1)');
		obj.setDefinition(fieldApiName, 'static value(2018-1-1)');
		obj.insertRecords(true);
		Test.stopTest();

		String expectedResult = 'Field [' + fieldApiName + '] does not accept multiple definitions';
		String actualResult = obj.getErrors().get(fieldApiName).get(0);
		System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
	}

	@IsTest
	private static void setDefinition_multipleDefinitionsForDatetime_expectFailure() {
		String fieldApiName = 'TestDatetime__c';

		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		obj.setDefinition(fieldApiName, 'random type(date) from(2018-1-1) to(2018-2-1)');
		obj.setDefinition(fieldApiName, 'static value(2018-1-1 01:01:01)');
		obj.insertRecords(true);
		Test.stopTest();

		String expectedResult = 'Field [' + fieldApiName + '] does not accept multiple definitions';
		String actualResult = obj.getErrors().get(fieldApiName).get(0);
		System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
	}

	@IsTest
	private static void setDefinition_multipleDefinitionsForEmail_expectSuccess() {
		String fieldApiName = 'TestEmail__c';

		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		obj.setDefinition(fieldApiName, 'static value(myname@)');
		obj.setDefinition(fieldApiName, 'static value(company.com)');
		List<FObjectOne__c> records = obj.getRecords();
		Test.stopTest();

		System.assert(obj.getErrors().isEmpty(), 'setDefinition - errors found');
	}

	@IsTest
	private static void setDefinition_multipleDefinitionsForLookup_expectFailure() {
		String fieldApiName = 'TestLookup__c';

		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		obj.setDefinition(fieldApiName, 'random lookup(FObjectTwo__c) source(salesforce)');
		obj.setDefinition(fieldApiName, 'random lookup(FObjectTwo__c) source(salesforce)');
		obj.insertRecords(true);
		Test.stopTest();

		String expectedResult = 'Field [' + fieldApiName + '] does not accept multiple definitions';
		String actualResult = obj.getErrors().get(fieldApiName).get(0);
		System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
	}

	@IsTest
	private static void setDefinition_multipleDefinitionsForMultiPicklist_expectFailure() {
		String fieldApiName = 'TestMultiPicklistA__c';

		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		obj.setDefinition(fieldApiName, 'static value(a1)');
		obj.setDefinition(fieldApiName, 'random type(list) value(a0,a1,a2,a3)');
		obj.insertRecords(true);
		Test.stopTest();

		String expectedResult = 'Field [' + fieldApiName + '] does not accept multiple definitions';
		String actualResult = obj.getErrors().get(fieldApiName).get(0);
		System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
	}

	@IsTest
	private static void setDefinition_multipleDefinitionsForNumber_expectFailure() {
		String fieldApiName = 'TestDecimal__c';

		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		obj.setDefinition(fieldApiName, 'random type(number) from(1) to (10) scale(2)');
		obj.setDefinition(fieldApiName, 'static value(10)');
		obj.insertRecords(true);
		Test.stopTest();

		String expectedResult = 'Field [' + fieldApiName + '] does not accept multiple definitions';
		String actualResult = obj.getErrors().get(fieldApiName).get(0);
		System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
	}

	@IsTest
	private static void setDefinition_multipleDefinitionsForPercent_expectFailure() {
		String fieldApiName = 'TestPercent__c';

		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		obj.setDefinition(fieldApiName, 'random type(number) from(0) to (1) scale(2)');
		obj.setDefinition(fieldApiName, 'static value(0.2)');
		List<FObjectOne__c> records = obj.getRecords();
		Test.stopTest();

		String expectedResult = 'Field [' + fieldApiName + '] does not accept multiple definitions';
		String actualResult = obj.getErrors().get(fieldApiName).get(0);
		System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
	}

	@IsTest
	private static void setDefinition_multipleDefinitionsForPhone_expectSuccess() {
		String fieldApiName = 'TestPhone__c';

		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		obj.setDefinition(fieldApiName, 'static value(210)');
		obj.setDefinition(fieldApiName, 'random type(number) from(111111) to (999999) scale(0)');
		List<FObjectOne__c> records = obj.getRecords();
		Test.stopTest();

		System.assert(obj.getErrors().isEmpty(), 'setDefinition - errors found');
	}

	@IsTest
	private static void setDefinition_multipleDefinitionsForPicklist_expectFailure() {
		String fieldApiName = 'TestPicklistA__c';

		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		obj.setDefinition(fieldApiName, 'static value(a1)');
		obj.setDefinition(fieldApiName, 'random type(list) value(a0,a1,a2,a3)');
		List<FObjectOne__c> records = obj.getRecords();
		Test.stopTest();

		String expectedResult = 'Field [' + fieldApiName + '] does not accept multiple definitions';
		String actualResult = obj.getErrors().get(fieldApiName).get(0);
		System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
	}

	@IsTest
	private static void setDefinition_multipleDefinitionsForText_expectSuccess() {
		String fieldApiName = 'TestText__c';

		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		obj.setDefinition(fieldApiName, 'static value(Company1)');
		obj.setDefinition(fieldApiName, 'static value(Company2)');
		List<FObjectOne__c> records = obj.getRecords();
		Test.stopTest();

		System.assert(obj.getErrors().isEmpty(), 'setDefinition - errors found');
	}

	@IsTest
	private static void setDefinition_multipleDefinitionsForTextArea_expectSuccess() {
		String fieldApiName = 'TestTextArea__c';

		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		obj.setDefinition(fieldApiName, 'static value(Company1)');
		obj.setDefinition(fieldApiName, 'static value(Company2)');
		List<FObjectOne__c> records = obj.getRecords();
		Test.stopTest();

		System.assert(obj.getErrors().isEmpty(), 'setDefinition - errors found');
	}

	@IsTest
	private static void setDefinition_multipleDefinitionsForTextAreaLong_expectSuccess() {
		String fieldApiName = 'TestTextAreaLong__c';

		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		obj.setDefinition(fieldApiName, 'static value(Company1)');
		obj.setDefinition(fieldApiName, 'static value(Company2)');
		List<FObjectOne__c> records = obj.getRecords();
		Test.stopTest();

		System.assert(obj.getErrors().isEmpty(), 'setDefinition - errors found');
	}

	@IsTest
	private static void setDefinition_multipleDefinitionsForTextAreaRich_expectSuccess() {
		String fieldApiName = 'TestTextAreaRich__c';

		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		obj.setDefinition(fieldApiName, 'static value(Company1)');
		obj.setDefinition(fieldApiName, 'static value(Company2)');
		List<FObjectOne__c> records = obj.getRecords();
		Test.stopTest();

		System.assert(obj.getErrors().isEmpty(), 'setDefinition - errors found');
	}

	@IsTest
	private static void setDefinition_multipleDefinitionsForTime_expectFailure() {
		String fieldApiName = 'TestTime__c';

		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		obj.setDefinition(fieldApiName, 'static value(10:10:10)');
		obj.setDefinition(fieldApiName, 'static value(11:11:11)');
		List<FObjectOne__c> records = obj.getRecords();
		Test.stopTest();

		String expectedResult = 'Field [' + fieldApiName + '] does not accept multiple definitions';
		String actualResult = obj.getErrors().get(fieldApiName).get(0);
		System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
	}

	@IsTest
	private static void setDefinition_multipleDefinitionsForUrl_expectSuccess() {
		String fieldApiName = 'TestUrl__c';

		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		obj.setDefinition(fieldApiName, 'static value(http:///www.company)');
		obj.setDefinition(fieldApiName, 'serial type(number) from(1) step(1) scale(0)');
		obj.setDefinition(fieldApiName, 'static value(.com)');
		List<FObjectOne__c> records = obj.getRecords();
		Test.stopTest();

		System.assert(obj.getErrors().isEmpty(), 'setDefinition - errors found');
	}

	@IsTest
	private static void setDefinitionFromField_accountName_expectSuccess() {
		String fieldApiName = 'Name';

		Test.startTest();
		FObject obj = new FObject('Account');
		FObject.Field field = new FObject.Field();
		field.fieldName = fieldApiName;
		field.fieldApiName = fieldApiName;
		obj.setDefinitionFromField(field);
		Test.stopTest();

		List<String> definitions = obj.getDefinitions(Account.Name);
		String expectedResult = 'static value(Company-) serial type(number) from(1) step(1) scale(0)';
		String actualResult = definitions.get(0) + ' ' + definitions.get(1);
		System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
	}

	@IsTest
	private static void setDefinitionFromField_contactFirstName_expectSuccess() {
		String fieldApiName = 'FirstName';

		Test.startTest();
		FObject obj = new FObject('Contact');
		FObject.Field field = new FObject.Field();
		field.fieldName = fieldApiName;
		field.fieldApiName = fieldApiName;
		obj.setDefinitionFromField(field);
		Test.stopTest();

		String expectedResult = 'random type(firstName) group(name)';
		String actualResult = obj.getDefinitions(Contact.FirstName).get(0);
		System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
	}

	@IsTest
	private static void setDefinitionFromField_firstAndLastHaveSameGroup_expectSuccess() {
		// check that the auto-generated definition for names has the group argument of the first "pair" name
		String fieldApiName = 'FirstName';

		Test.startTest();
		FObject obj = new FObject('Contact');
		FObject.Field field = new FObject.Field();
		field.fieldName = fieldApiName;
		field.fieldApiName = fieldApiName;
		obj.setDefinitionFromField(field);
		Test.stopTest();

		String expectedResult = 'random type(firstName) group(name)';
		String actualResult = obj.getDefinitions(fieldApiName).get(0);
		System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
	}

	@IsTest
	private static void setDefinitionFromField_contactLastName_expectSuccess() {
		String fieldApiName = 'LastName';

		Test.startTest();
		FObject obj = new FObject('Contact');
		FObject.Field field = new FObject.Field();
		field.fieldName = fieldApiName;
		field.fieldApiName = fieldApiName;
		obj.setDefinitionFromField(field);
		Test.stopTest();

		String expectedResult = 'random type(lastName) group(name)';
		String actualResult = obj.getDefinitions(fieldApiName).get(0);
		System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
	}

	@IsTest
	private static void setDefinitionFromField_leadCompany_expectSuccess() {
		String fieldApiName = 'Company';

		Test.startTest();
		FObject obj = new FObject('Lead');
		FObject.Field field = new FObject.Field();
		field.fieldName = fieldApiName;
		field.fieldApiName = fieldApiName;
		obj.setDefinitionFromField(field);
		Test.stopTest();

		List<String> definitions = obj.getDefinitions(fieldApiName);
		String expectedResult = 'static value(Company-) serial type(number) from(1) step(1) scale(0)';
		String actualResult = definitions[0] + ' ' + definitions[1];
		System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
	}

	@IsTest
	private static void setDefinitionFromField_leadfirstName_expectSuccess() {
		String fieldApiName = 'firstName';

		Test.startTest();
		FObject obj = new FObject('Lead');
		FObject.Field field = new FObject.Field();
		field.fieldName = fieldApiName;
		field.fieldApiName = fieldApiName;
		obj.setDefinitionFromField(field);
		Test.stopTest();

		String expectedResult = 'random type(firstName) group(name)';
		String actualResult = obj.getDefinitions(fieldApiName).get(0);
		System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
	}

	@IsTest
	private static void setDefinitionFromField_leadlastName_expectSuccess() {
		String fieldApiName = 'lastName';

		Test.startTest();
		FObject obj = new FObject('Lead');
		FObject.Field field = new FObject.Field();
		field.fieldName = fieldApiName;
		field.fieldApiName = fieldApiName;
		obj.setDefinitionFromField(field);
		Test.stopTest();

		String expectedResult = 'random type(lastName) group(name)';
		String actualResult = obj.getDefinitions(fieldApiName).get(0);
		System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
	}

	@IsTest
	private static void setDefinitionFromField_opportunityName_expectSuccess() {
		String fieldApiName = 'Name';

		Test.startTest();
		FObject obj = new FObject('Opportunity');
		FObject.Field field = new FObject.Field();
		field.fieldName = fieldApiName;
		field.fieldApiName = fieldApiName;
		obj.setDefinitionFromField(field);
		Test.stopTest();

		List<String> definitions = obj.getDefinitions(fieldApiName);
		String expectedResult = 'static value(Opportunity-) serial type(number) from(1) step(1) scale(0)';
		String actualResult = definitions[0] + ' ' + definitions[1];
		System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
	}

	@IsTest
	private static void setDefinitionFromField_boolean_expectSuccess() {
		String fieldApiName = 'TestCheckbox__c';

		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		FObject.Field field = new FObject.Field();
		field.fieldName = fieldApiName;
		field.fieldApiName = fieldApiName;
		field.dataType = Schema.DisplayType.BOOLEAN;
		obj.setDefinitionFromField(field);
		Test.stopTest();

		String expectedResult = 'random type(boolean)';
		String actualResult = obj.getDefinitions(fieldApiName).get(0);
		System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
	}

	@IsTest
	private static void setDefinitionFromField_combobox_expectSuccess() {
		String fieldApiName = 'Subject';

		Test.startTest();
		FObject obj = new FObject('Event');
		FObject.Field field = new FObject.Field();
		field.fieldName = fieldApiName;
		field.fieldApiName = fieldApiName;
		field.dataType = Schema.DisplayType.Combobox;
		obj.setDefinitionFromField(field);
		Test.stopTest();

		String expectedResult = 'random type(picklist)';
		String actualResult = obj.getDefinitions(fieldApiName).get(0);
		System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
	}

	@IsTest
	private static void setDefinitionFromField_currency_expectSuccess() {
		String fieldApiName = 'TestCurrency__c';

		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		FObject.Field field = new FObject.Field();
		field.fieldName = fieldApiName;
		field.fieldApiName = fieldApiName;
		field.dataType = Schema.DisplayType.Currency;
		obj.setDefinitionFromField(field);
		Test.stopTest();

		String expectedResult = 'random type(number) from(1000) to(10000) scale(2)';
		String actualResult = obj.getDefinitions(fieldApiName).get(0);
		System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
	}

	@IsTest
	private static void setDefinitionFromField_date_expectSuccess() {
		String fieldApiName = 'TestDate__c';

		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		FObject.Field field = new FObject.Field();
		field.fieldName = fieldApiName;
		field.fieldApiName = fieldApiName;
		field.dataType = Schema.DisplayType.Date;
		obj.setDefinitionFromField(field);
		Test.stopTest();

		Integer thisYear = Date.today().year();
		String fromDate = String.valueOf(thisYear - 1) + '-01-01';
		String toDate = String.valueOf(thisYear + 1) + '-12-31';

		String expectedResult = 'random type(date) from(' + fromDate + ') to(' + toDate + ')';
		String actualResult = obj.getDefinitions(fieldApiName).get(0);
		System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
	}

	@IsTest
	private static void setDefinitionFromField_datetime_expectSuccess() {
		String fieldApiName = 'TestDatetime__c';

		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		FObject.Field field = new FObject.Field();
		field.fieldName = fieldApiName;
		field.fieldApiName = fieldApiName;
		field.dataType = Schema.DisplayType.Datetime;
		obj.setDefinitionFromField(field);
		Test.stopTest();

		Integer thisYear = Date.today().year();
		String fromDate = String.valueOf(thisYear - 1) + '-01-01';
		String toDate = String.valueOf(thisYear + 1) + '-12-31';

		String expectedResult = 'random type(datetime) from(' + fromDate + ') to(' + toDate + ')';
		String actualResult = obj.getDefinitions(fieldApiName).get(0);
		System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
	}

	@IsTest
	private static void setDefinitionFromField_time_expectSuccess() {
		String fieldApiName = 'TestTime__c';

		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		FObject.Field field = new FObject.Field();
		field.fieldName = fieldApiName;
		field.fieldApiName = fieldApiName;
		field.dataType = Schema.DisplayType.Time;
		obj.setDefinitionFromField(field);
		Test.stopTest();

		String expectedResult = 'random type(time) from(00:00:00) to(23:59:59)';
		String actualResult = obj.getDefinitions(fieldApiName).get(0);
		System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
	}

	@IsTest
	private static void setDefinitionFromField_double_expectSuccess() {
		String fieldApiName = 'TestDecimal__c';

		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		FObject.Field field = new FObject.Field();
		field.fieldName = fieldApiName;
		field.fieldApiName = fieldApiName;
		field.dataType = Schema.DisplayType.Double;
		obj.setDefinitionFromField(field);
		Test.stopTest();

		String expectedResult = 'random type(number) from(1000) to(10000) scale(3)';
		String actualResult = obj.getDefinitions(fieldApiName).get(0);
		System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
	}

	@IsTest
	private static void setDefinitionFromField_email_expectSuccess() {
		String fieldApiName = 'TestEmail__c';

		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		FObject.Field field = new FObject.Field();
		field.fieldName = fieldApiName;
		field.fieldApiName = fieldApiName;
		field.dataType = Schema.DisplayType.EMAIL;
		obj.setDefinitionFromField(field);
		Test.stopTest();

		String expectedResult = 'random type(email)';
		String actualResult = obj.getDefinitions(fieldApiName).get(0);
		System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
	}

	@IsTest
	private static void setDefinitionFromField_integer_expectSuccess() {
		String fieldApiName = 'TestInteger__c';

		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		FObject.Field field = new FObject.Field();
		field.fieldName = fieldApiName;
		field.fieldApiName = fieldApiName;
		field.dataType = Schema.DisplayType.Integer;
		obj.setDefinitionFromField(field);
		Test.stopTest();

		String expectedResult = 'random type(number) from(1) to(100) scale(0)';
		String actualResult = obj.getDefinitions(fieldApiName).get(0);
		System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
	}

	@IsTest
	private static void setDefinitionFromField_multiPicklist_expectSuccess() {
		String fieldApiName = 'TestMultiPicklistA__c';

		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		FObject.Field field = new FObject.Field();
		field.fieldName = fieldApiName;
		field.fieldApiName = fieldApiName;
		field.dataType = Schema.DisplayType.MultiPicklist;
		obj.setDefinitionFromField(field);
		Test.stopTest();

		String expectedResult = 'random type(picklist)';
		String actualResult = obj.getDefinitions(fieldApiName).get(0);
		System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
	}

	@IsTest
	private static void setDefinitionFromField_percent_expectSuccess() {
		String fieldApiName = 'TestPercent__c';

		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		FObject.Field field = new FObject.Field();
		field.fieldName = fieldApiName;
		field.fieldApiName = fieldApiName;
		field.dataType = Schema.DisplayType.Percent;
		obj.setDefinitionFromField(field);
		Test.stopTest();

		String expectedResult = 'random type(number) from(0) to(100) scale(2)';
		String actualResult = obj.getDefinitions(fieldApiName).get(0);
		System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
	}

	@IsTest
	private static void setDefinitionFromField_picklist_expectSuccess() {
		String fieldApiName = 'TestPicklistA__c';

		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		FObject.Field field = new FObject.Field();
		field.fieldName = fieldApiName;
		field.fieldApiName = fieldApiName;
		field.dataType = Schema.DisplayType.MultiPicklist;
		obj.setDefinitionFromField(field);
		Test.stopTest();

		String expectedResult = 'random type(picklist)';
		String actualResult = obj.getDefinitions(fieldApiName).get(0);
		System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
	}

	@IsTest
	private static void setDefinitionFromField_phone_expectSuccess() {
		String fieldApiName = 'TestPhone__c';

		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		FObject.Field field = new FObject.Field();
		field.fieldName = fieldApiName;
		field.fieldApiName = fieldApiName;
		field.dataType = Schema.DisplayType.Phone;
		obj.setDefinitionFromField(field);
		Test.stopTest();

		String expectedResult = 'random type(phone) format(DD dDD dd-DD-DDD)';
		String actualResult = obj.getDefinitions(fieldApiName).get(0);
		System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
	}

	@IsTest
	private static void setDefinitionFromField_reference_expectSuccess() {
		String fieldApiName = 'TestLookup__c';
		Schema.SobjectType parentType = Schema.FObjectTwo__c.getSObjectType();
		List<Schema.SobjectType> parents = new List<Schema.SobjectType>{
			parentType
		};

		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		FObject.Field field = new FObject.Field();
		field.fieldName = fieldApiName;
		field.fieldApiName = fieldApiName;
		field.dataType = Schema.DisplayType.Reference;
		field.parents = parents;
		obj.setDefinitionFromField(field);
		Test.stopTest();

		String expectedResult = 'random lookup(FObjectTwo__c) source(forceea)';
		String actualResult = obj.getDefinitions(fieldApiName).get(0);
		System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
	}

	@IsTest
	private static void setDefinitionFromField_string_expectSuccess() {
		String fieldApiName = 'TestText__c';

		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		FObject.Field field = new FObject.Field();
		field.fieldName = fieldApiName;
		field.fieldApiName = fieldApiName;
		field.length = 20;
		field.dataType = Schema.DisplayType.STRING;
		obj.setDefinitionFromField(field);
		Test.stopTest();

		String expectedResult = 'random type(string) minLength(5) maxLength(20) startWith(upper) include(lower,upper)';
		String actualResult = obj.getDefinitions(fieldApiName).get(0);
		System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
	}

	@IsTest
	private static void setDefinitionFromField_textArea_expectSuccess() {
		String fieldApiName = 'TestTextArea__c';

		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		FObject.Field field = new FObject.Field();
		field.fieldName = fieldApiName;
		field.fieldApiName = fieldApiName;
		field.dataType = Schema.DisplayType.TextArea;
		obj.setDefinitionFromField(field);
		Test.stopTest();

		String expectedResult = 'random type(text) minLength(30) maxLength(100)';
		String actualResult = obj.getDefinitions(fieldApiName).get(0);
		System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
	}

	@IsTest
	private static void setDefinitionFromField_url_expectSuccess() {
		String fieldApiName = 'TestUrl__c';

		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		FObject.Field field = new FObject.Field();
		field.fieldName = fieldApiName;
		field.fieldApiName = fieldApiName;
		field.dataType = Schema.DisplayType.URL;
		obj.setDefinitionFromField(field);
		Test.stopTest();

		String expectedResult = 'random type(url)';
		String actualResult = obj.getDefinitions(fieldApiName).get(0);
		System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
	}

	@IsTest
	private static void setDefinitionsOfRequiredFieldsForUser_withoutUserDefinitions_expectSuccess() {
		List<String> fields = new List<String>{
			'Alias', 'FirstName', 'LastName', 'Username', 'Email', 'EmailEncodingKey',
			'TimeZonesIdKey', 'LocalesIdKey', 'LanguageLocaleKey', 'ProfileId'
		};

		List<String> expectedDefinitions = new List<String>();
		expectedDefinitions.add('random type(string) minLength(8) maxLength(8) startWith(upper) include(lower)');
		expectedDefinitions.add('random type(firstName) group(name)');
		expectedDefinitions.add('random type(lastName) group(name)');
		expectedDefinitions.add('random type(email)');
		expectedDefinitions.add('copy field(Username)');
		expectedDefinitions.add('static value(UTF-8)');
		expectedDefinitions.add('static value(GMT)');
		expectedDefinitions.add('static value(en_US)');
		expectedDefinitions.add('static value(en_US)');
		expectedDefinitions.add('static lookup(profile) field(name) value(Standard User) source(salesforce)');

		Test.startTest();
		FObject obj = new FObject(User.SObjectType,1);
		List<User> users = obj.getRecords();
		Test.stopTest();

		List<String> actualDefinitions = new List<String>();
		for (String fieldApiName: fields) {
			actualDefinitions.add(obj.getDefinitions(fieldApiName).get(0));
		}

		Boolean isValid = actualDefinitions.hashCode() == expectedDefinitions.hashCode() && FObject.processIsValid();
		System.assert(isValid, 'setDefinitionsOfRequiredFieldsForUser - errors found');
	}

	@IsTest
	private static void setDefinitionsOfRequiredFieldsForUser_withUserDefinitions_expectSuccess() {
		List<String> fields = new List<String>{
			'Alias', 'FirstName', 'LastName', 'Username', 'Email', 'EmailEncodingKey',
			'TimeZonesIdKey', 'LocalesIdKey', 'LanguageLocaleKey', 'ProfileId'
		};

		List<String> expectedDefinitions = new List<String>();
		expectedDefinitions.add('static value(alias)');
		expectedDefinitions.add('static value(first)');
		expectedDefinitions.add('static value(last)');
		expectedDefinitions.add('static value(user@domain1.com)');
		expectedDefinitions.add('static value(user@domain2.com)');
		expectedDefinitions.add('static value(ISO-8859-1)');
		expectedDefinitions.add('static value(Australia/Sydney)');
		expectedDefinitions.add('static value(en_GB)');
		expectedDefinitions.add('static value(da)');
		expectedDefinitions.add('static lookup(profile) field(name) value(System Administrator) source(salesforce)');

		Test.startTest();
		FObject obj = new FObject(User.SObjectType,1);
		for (Integer counter = 0; counter < fields.size(); counter++) {
			obj.setDefinition(fields.get(counter), expectedDefinitions.get(counter));
		}
		obj.insertRecords(true);
		Test.stopTest();

		Integer errors = 0;
		List<String> actualDefinitions = new List<String>();
		for (String fieldApiName: fields) {
			actualDefinitions.add(obj.getDefinitions(fieldApiName).get(0));
			if (obj.getDefinitions(fieldApiName).size() > 1) {
				errors++;
			}
		}

		if (actualDefinitions.hashCode() != expectedDefinitions.hashCode()) {
			errors += 16;
		}
		if (!FObject.processIsValid()) {
			errors += 32;
		}
		System.assertEquals(0, errors, 'setDefinitionsOfRequiredFieldsForUser - errors found');
	}

}