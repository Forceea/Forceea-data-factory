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
public class FObjectDmlTest {

	@IsTest
	private static void deleteRecords_whereClauseIsBlank_expectSuccess() {
		Test.startTest();
		FObject obj = new FObject('FObjectOne__c', 10);
		obj.setDefinition('TestPicklistA__c', 'random type(picklist)');
		obj.insertRecords(true);
		obj.deleteRecords('');
		Test.stopTest();

		List<FObjectOne__c> recordsAfterDelete = [SELECT Id FROM FObjectOne__c LIMIT 1000];
		Set<Id> recordIdsAfterDeleteSet = (new Map<Id, FObjectOne__c>(recordsAfterDelete)).keySet();
		Integer errors = 0;
		for (FObjectOne__c objRecord : (List<FObjectOne__c>) obj.getInsertedRecords()) {
			if (!recordIdsAfterDeleteSet.contains(objRecord.Id)) {
				errors++;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'deleteRecords - errors found');
	}

	@IsTest
	private static void deleteRecords_whereClauseIsValid_expectSuccess() {
		Test.startTest();
		FObject obj = new FObject('FObjectOne__c', 10);
		obj.setDefinition('TestPicklistA__c', 'random type(picklist)');
		obj.insertRecords(true);
		obj.deleteRecords('TestPicklistA__c = \'a1\'');
		Test.stopTest();

		List<FObjectOne__c> recordsAfterDelete = [SELECT Id FROM FObjectOne__c LIMIT 1000];
		Set<Id> recordIdsAfterDeleteSet = (new Map<Id, FObjectOne__c>(recordsAfterDelete)).keySet();
		Integer errors = 0;
		for (FObjectOne__c objRecord : (List<FObjectOne__c>) obj.getInsertedRecords()) {
			if (!recordIdsAfterDeleteSet.contains(objRecord.Id)) {
				errors++;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'deleteRecords - errors found');
	}

	@IsTest
	private static void deleteRecords_recordGroup_expectSuccess() {
		Test.startTest();
		FObject obj = new FObject('FObjectOne__c', 10);
		obj.setDefinition('TestPicklistA__c', 'random type(picklist)');
		obj.insertRecords(true, 'Group1');
		obj.deleteRecords('TestPicklistA__c = \'a1\'');
		Test.stopTest();

		List<FObjectOne__c> recordsAfterDelete1 = [SELECT Id FROM FObjectOne__c LIMIT 1000];
		Set<Id> recordIdsAfterDelete1Set = (new Map<Id, FObjectOne__c>(recordsAfterDelete1)).keySet();
		Integer hash1 = recordIdsAfterDelete1Set.hashCode();
		List<FObjectOne__c> recordsAfterDelete2 = obj.getInsertedRecords();
		Set<Id> recordIdsAfterDelete2Set = (new Map<Id, FObjectOne__c>(recordsAfterDelete2)).keySet();
		Integer hash2 = recordIdsAfterDelete2Set.hashCode();
		List<FObjectOne__c> recordsAfterDelete3 = obj.getInsertedGroupRecords('GROUP1');
		Set<Id> recordIdsAfterDelete3Set = (new Map<Id, FObjectOne__c>(recordsAfterDelete3)).keySet();
		Integer hash3 = recordIdsAfterDelete3Set.hashCode();

		Integer errors = 0;
		for (FObjectOne__c objRecord : (List<FObjectOne__c>) obj.getInsertedRecords()) {
			if (!recordIdsAfterDelete1Set.contains(objRecord.Id)) {
				errors += 1;
				break;
			}
		}
		if (hash1 != hash2) {
			errors += 2;
		}
		if (hash2 != hash3) {
			errors += 4;
		}
		if (!FObject.processIsValid()) {
			errors += 8;
		}
		System.assertEquals(0, errors, 'deleteRecords - errors found');
	}

	@IsTest
	private static void deleteRecords_noRecordsFound_expectSuccess() {
		Test.startTest();
		FObject obj = new FObject('FObjectOne__c', 10);
		obj.setDefinition('TestPicklistA__c', 'random type(picklist)');
		obj.insertRecords(false, 'Group1');
		List<FObjectOne__c> recordsBeforeDelete = obj.getInsertedGroupRecords('GROUP1');
		Set<Id> recordIdsBeforeDeleteSet = (new Map<Id, FObjectOne__c>(recordsBeforeDelete)).keySet();
		Integer hash = recordIdsBeforeDeleteSet.hashCode();
		obj.deleteRecords('TestPicklistA__c = \'a5\'');
		Test.stopTest();

		List<FObjectOne__c> recordsAfterDelete1 = [SELECT Id FROM FObjectOne__c LIMIT 1000];
		Set<Id> recordIdsAfterDelete1Set = (new Map<Id, FObjectOne__c>(recordsAfterDelete1)).keySet();
		Integer hash1 = recordIdsAfterDelete1Set.hashCode();
		List<FObjectOne__c> recordsAfterDelete2 = obj.getInsertedRecords();
		Set<Id> recordIdsAfterDelete2Set = (new Map<Id, FObjectOne__c>(recordsAfterDelete2)).keySet();
		Integer hash2 = recordIdsAfterDelete2Set.hashCode();
		List<FObjectOne__c> recordsAfterDelete3 = obj.getInsertedGroupRecords('GROUP1');
		Set<Id> recordIdsAfterDelete3Set = (new Map<Id, FObjectOne__c>(recordsAfterDelete3)).keySet();
		Integer hash3 = recordIdsAfterDelete3Set.hashCode();

		Integer errors = 0;
		for (FObjectOne__c objRecord : (List<FObjectOne__c>) obj.getInsertedRecords()) {
			if (!recordIdsAfterDelete1Set.contains(objRecord.Id)) {
				errors += 1;
				break;
			}
		}
		if (hash != hash1) {
			errors += 2;
		}
		if (hash1 != hash2) {
			errors += 4;
		}
		if (hash2 != hash3) {
			errors += 8;
		}
		if (!FObject.processIsValid()) {
			errors += 16;
		}
		System.assertEquals(0, errors, 'deleteRecords - errors found');
	}

	@IsTest
	private static void deleteRecords_whereClauseIsInvalid_expectFailure() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		obj.setDefinition('TestPicklistA__c', 'random type(picklist)');
		obj.insertRecords(true);
		obj.deleteRecords('TestPicklistA__c == a1');
		Test.stopTest();

		String expectedResult = 'Found errors selecting records of [FObjectOne__c]';
		String actualResult = obj.getErrors().get('FObjectOne__c').get(0);
		Boolean result = actualResult.startsWith(expectedResult);
		System.assertEquals(true, result, 'deleteRecords - errors found');
	}

	@IsTest
	private static void deleteRecords_deleteException_expectFailure() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		obj.setDefinition('TestPicklistA__c', 'random type(picklist)');
		obj.insertRecords(true);

		Test.setReadOnlyApplicationMode(true);
		Database.DeleteResult[] deleteResults = obj.deleteRecords('TestPicklistA__c = \'a1\'');
		Test.stopTest();

		Integer errors = 0;
		for (Database.DeleteResult dr : deleteResults) {
			if (dr.isSuccess()) {
				errors++;
			}
		}
		if (FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'deleteRecords - errors found');
	}

	@IsTest
	private static void getInsertedRecords_twoInstancesOfSameObject_expectSuccess() {
		Integer size1 = 10;
		Integer size2 = 5;

		Test.startTest();
		FObject obj1 = new FObject('FObjectOne__c', size1)
			.setDefinition(FObjectOne__c.TestText__c, 'static value(a1)');
		obj1.insertRecords(true);

		FObject obj2 = new FObject('FObjectOne__c', size2)
			.setDefinition(FObjectOne__c.TestText__c, 'static value(a1)');
		obj2.insertRecords(true);
		Test.stopTest();

		List<FObjectOne__c> records1 = ((List<FObjectOne__c>) obj1.getInsertedRecords());
		List<FObjectOne__c> records2 = ((List<FObjectOne__c>) obj2.getInsertedRecords());
		System.assert(records1.size() == size1 && records2.size() == size2, 'getInsertedRecords - errors found');
	}

	@IsTest
	private static void getInsertedRecords_twoInsertionsAllOrNoneTrue_expectSuccess() {
		List<FObjectOne__c> records1 = new List<FObjectOne__c>();
		List<FObjectOne__c> records2 = new List<FObjectOne__c>();

		Test.startTest();
		FObject obj = new FObject('FObjectOne__c', 10)
			.setDefinition('TestText__c', 'static value(a1)');
		obj.insertRecords(true);
		records1.addAll((List<FObjectOne__c>) obj.getRecords());

		obj.deleteAllDefinitions();

		obj.setDefinition('TestText__c', 'static value(a2)')
			.insertRecords(true);
		records1.addAll((List<FObjectOne__c>) obj.getRecords());
		Test.stopTest();

		records2 = (List<FObjectOne__c>) obj.getInsertedRecords();

		Integer hash1 = records1.hashCode();
		Integer hash2 = records2.hashCode();
		System.assertEquals(hash1, hash2, 'getInsertedRecords - errors found');
	}

	@IsTest
	private static void getInsertedRecords_twoInsertionsAllOrNoneFalse_expectSuccess() {
		List<FObjectOne__c> records1 = new List<FObjectOne__c>();
		List<FObjectOne__c> records2 = new List<FObjectOne__c>();

		Test.startTest();
		FObject obj = new FObject('FObjectOne__c', 100);
		obj.setDefinition('TestText__c', 'static value(a1)');
		obj.insertRecords(false);
		records1.addAll((List<FObjectOne__c>) obj.getRecords());

		obj.deleteAllDefinitions();

		obj.setDefinition('TestText__c', 'static value(a2)');
		obj.insertRecords(false);
		records1.addAll((List<FObjectOne__c>) obj.getRecords());
		Test.stopTest();

		records2 = (List<FObjectOne__c>) obj.getInsertedRecords();

		Integer hash1 = records1.hashCode();
		Integer hash2 = records2.hashCode();
		System.assertEquals(hash1, hash2, 'getInsertedRecords - errors found');
	}

	@IsTest
	private static void getInsertedGroupRecords_sameInstance_expectSuccess() {
		String group1 = 'GroupA';
		String group2 = 'GroupB';

		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition(FObjectOne__c.TestIntegerUnique__c, 'serial type(number) from(1) step(1) scale(0)');
		obj.insertRecords(true, group1);

		obj.deleteDefinitions(FObjectOne__c.TestIntegerUnique__c)
			.setDefinition(FObjectOne__c.TestIntegerUnique__c, 'serial type(number) from(1) step(1) scale(0)');
		obj.insertRecords(true, group2);
		Test.stopTest();

		System.assert(ForceeaUtilityTest.insertedGroupRecordsAreValidForSameInstance(obj, group1, group2), 'getInsertedGroupRecords - errors found');
	}

	@IsTest
	private static void getInsertedGroupRecords_differentInstances_expectSuccess() {
		String group1 = 'GroupA';
		String group2 = 'GroupB';

		Test.startTest();
		FObject.setSeed(1);
		FObject obj1 = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition(FObjectOne__c.Id, 'mock type(id)')
			.setDefinition(FObjectOne__c.TestText__c, 'serial type(number) from(1) step(1) scale(0)');
		obj1.insertRecords(true, group1);

		FObject.setSeed(1);
		FObject obj2 = new FObject(FObjectOne__c.SObjectType, 10)
			.setNumberOfNextRecord(1)
			.setDefinition(FObjectOne__c.Id, 'mock type(id)')
			.setDefinition(FObjectOne__c.TestText__c, 'serial type(number) from(1) step(1) scale(0)');
		obj2.insertRecords(true, group2);
		Test.stopTest();

		System.assert(ForceeaUtilityTest.insertedGroupRecordsAreValidForDifferentInstances(obj1, obj2, group1, group2),
			'getInsertedGroupRecords - errors found');
	}

	@IsTest
	private static void getInsertedRecordsStatic_invalidObject_expectFailure() {
		Test.startTest();
		FObject obj = new FObject('FObjectOne__c', 10)
			.setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) source(forceea)');
		obj.insertRecords(true);
		Test.stopTest();

		List<FObjectTwo__c> lookupRecords = (List<FObjectTwo__c>) FObject.getInsertedRecords('FObjectTwoX__c');
		System.assert(!FObject.processIsValid(), 'getInsertedRecords - errors found');
	}

	@IsTest
	private static void getInsertedRecordsStatic_lookupRecords_expectSuccess() {
		Integer size1 = 5;
		Integer size2 = 10;
		Integer size3 = 15;

		Test.startTest();
		FObject obj1 = new FObject('FObjectTwo__c', size1);
		obj1.setDefinition('TestText__c', 'serial type(number) from(1) step(1) scale(0)');
		obj1.insertRecords(true);
		List<FObjectOne__c> records1 = (List<FObjectOne__c>) FObject.getInsertedRecords('FObjectTwo__c');

		FObject obj2 = new FObject('FObjectOne__c', size2);
		obj2.setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) source(forceea)');
		obj2.insertRecords(true);
		List<FObjectOne__c> records2 = (List<FObjectOne__c>) FObject.getInsertedRecords('FObjectOne__c');

		FObject obj3 = new FObject('FObjectOne__c', size3);
		obj3.setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) source(forceea)');
		obj3.insertRecords(true);
		List<FObjectOne__c> records3 = (List<FObjectOne__c>) FObject.getInsertedRecords('FObjectOne__c');
		Test.stopTest();

		Integer errors = 0;
		if (records1.size() != size1) {
			errors += 1;
		}
		if (records2.size() != size2) {
			errors += 2;
		}
		if (records3.size() != (size2 + size3)) {
			errors += 4;
		}
		if (!FObject.processIsValid()) {
			errors += 8;
		}
		System.assertEquals(0, errors, 'getInsertedRecords - errors found');
	}

	@IsTest
	private static void getInsertedGroupRecordsStatic_valid_expectSuccess() {
		Integer size1 = 5;
		Integer size2 = 10;
		Integer size3 = 20;

		Test.startTest();
		FObject obj1 = new FObject('FObjectOne__c', size1);
		obj1.setDefinition('TestText__c', 'random type(list) value(v1,v2)');
		obj1.insertRecords(true, 'GroupA');

		obj1.deleteDefinitions('TestText__c')
			.setNumberOfRecords(size2)
			.setDefinition('TestText__c', 'random type(list) value(v3,v4)');
		obj1.insertRecords(true, 'GroupB');

		FObject obj2 = new FObject('FObjectOne__c', size3)
			.setDefinition('TestText__c', 'random type(list) value(v1,v2)');
		obj2.insertRecords(true);
		Test.stopTest();

		List<FObjectOne__c> recordsA1 = (List<FObjectOne__c>) obj1.getInsertedGroupRecords('GROUPA');
		List<FObjectOne__c> recordsA2 =
			(List<FObjectOne__c>) FObject.getInsertedGroupRecords('FObjectOne__c', 'GROUPA');

		List<FObjectOne__c> recordsB1 = (List<FObjectOne__c>) obj1.getInsertedGroupRecords('GROUPB');
		List<FObjectOne__c> recordsB2 =
			(List<FObjectOne__c>) FObject.getInsertedGroupRecords('FObjectOne__c', 'GROUPB');

		List<FObjectOne__c> recordsBlank1 = (List<FObjectOne__c>) obj1.getInsertedGroupRecords('');
		List<FObjectOne__c> recordsBlank2 = (List<FObjectOne__c>) obj1.getInsertedGroupRecords(null);
		List<FObjectOne__c> recordsBlank3 = (List<FObjectOne__c>) obj1.getInsertedRecords();
		List<FObjectOne__c> recordsC = (List<FObjectOne__c>) obj1.getInsertedGroupRecords('GroupC');

		Integer errors = 0;
		if (recordsA1.hashCode() != recordsA2.hashCode()) {
			errors += 1;
		}
		if (recordsB1.hashCode() != recordsB2.hashCode()) {
			errors += 2;
		}
		Integer hash1 = recordsBlank1.hashCode();
		Integer hash2 = recordsBlank2.hashCode();
		Integer hash3 = recordsBlank3.hashCode();
		if (hash1 != hash2 && hash2 != hash3) {
			errors += 4;
		}
		if (!recordsC.isEmpty()) {
			errors += 8;
		}
		if (!FObject.processIsValid()) {
			errors += 16;
		}
		System.assertEquals(0, errors, 'getInsertedGroupRecords - errors found');
	}

	@IsTest
	private static void getInsertedGroupRecordsStatic_invalidObject_expectFailure() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		obj.setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) source(forceea)');
		obj.insertRecords(true, 'One');
		Test.stopTest();

		List<FObjectTwo__c> lookupRecords = (List<FObjectTwo__c>) FObject.getInsertedGroupRecords('FObjectTwoX__c', 'One');
		Boolean expectedResult = false;
		Boolean actualResult = FObject.processIsValid();
		System.assertEquals(expectedResult, actualResult, 'getInsertedGroupRecords - errors found');
	}

	@IsTest
	private static void insertRecords_allOrNoneTrue_expectFailure() {
		Boolean hasErrors = false;

		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType)
			.setRequiredFields(false)
			.setDefinition(FObjectOne__c.TestPicklistC__c, 'static value(a1)');
		try {
			obj.insertRecords(true);
		} catch (DmlException ex) {
			hasErrors = true;
		}
		Test.stopTest();

		Integer errors = 0;
		if (!hasErrors) {
			errors += 1;
		}
		if (!FObject.processIsValid()) {
			errors += 2;
		}
		System.assertEquals(0, errors, 'insertRecords - errors found');
	}

	@IsTest
	private static void insertRecords_allOrNoneFalse_expectFailure() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setRequiredFields(false)
			.setDefinition(FObjectOne__c.TestPicklistC__c, 'static value(a1)');
		List<Database.SaveResult> saveResults = obj.insertRecords(false);
		Test.stopTest();

		Integer errors = 0;
		for (Database.SaveResult sr : saveResults) {
			if (sr.isSuccess()) {
				errors++;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'insertRecords - errors found');
	}

	@IsTest
	private static void insertRecords_attachments_expectSuccess() {
		Test.startTest();
		FObject obj = new FObject(Attachment.SObjectType, 10)
			.setDefinition(Attachment.Name, 'static value(Attachment-)')
			.setDefinition(Attachment.Name, 'serial type(number) from(1) step(1) scale(0)')
			.setDefinition(Attachment.Body, 'random type(number) from(1) to(100) scale(2)');
		Test.stopTest();

		Decimal value = 0;
		Integer errors = 0;
		for (Attachment objRecord : (List<Attachment>) obj.getRecords()) {
			value = Decimal.valueOf(objRecord.Body.toString());
			if (value < 1 || value > 100) {
				errors++;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'insertRecords - errors found');
	}

	@IsTest
	private static void insertRecords_createRecordsAsUser_expectSuccess() {
		Test.startTest();
		FObject userObj = new FObject('User', 1);
		userObj.setDefinition('Title', 'static value(Developer)');
		userObj.setDefinition('ProfileId',
			'static lookup(Profile) field(Name) value(System Administrator) source(salesforce)');
		List<Database.SaveResult> saveResults = userObj.insertRecords(true);

		if (saveResults[0].isSuccess()) {
			List<User> users = (List<User>) userObj.getRecords();
			System.runAs(users[0]) {
				FObject obj = new FObject(FObjectOne__c.SObjectType);
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
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'insertRecords - errors found');
	}

	@IsTest
	private static void insertRecords_negativeRecords_expectFailure() {
		Test.startTest();
		FObject obj = new FObject('FObjectOne__c', -1);
		obj.insertRecords(true);
		Test.stopTest();

		String expectedResult = 'Invalid number of records of [FObjectOne__c]';
		String actualResult = obj.getErrors().get('FObjectOne__c').get(0);
		System.assertEquals(expectedResult, actualResult, 'insertRecords - errors found');
	}

	@IsTest
	private static void insertRecords_userWithProfile_expectSuccess() {
		Test.startTest();
		FObject obj = new FObject('User', 1);
		obj.setDefinition('ProfileId', 'static lookup(Profile) field(Name) value(System Administrator) source(salesforce)');
		obj.setDefinition('Title', 'static value(Forceea Developer)');
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
		System.assertEquals(0, errors, 'insertRecords - errors found');
	}

	@IsTest
	private static void insertRecords_noDefinitions_expectSuccess() {
		Test.startTest();
		FObject obj = new FObject('FObjectOne__c', 10);
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
		System.assertEquals(0, errors, 'insertRecords - errors found');
	}

	@IsTest
	private static void insertRecords_missingRequiredFields_expectFailure() {
		Test.startTest();
		FObject obj = new FObject(FObjectOne__c.SObjectType);
		obj.setRequiredFields(false);
		List<Database.SaveResult> saveResults = obj.insertRecords(false);
		Test.stopTest();

		Integer errors = 0;
		for (Database.SaveResult sr : saveResults) {
			if (sr.isSuccess()) {
				errors++;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'insertRecords - errors found');
	}

	@IsTest
	private static void insertRecords_comboBoxWithPicklist_expectSuccess() {
		FObject obj = new FObject('Event', 10);
		obj.setDefinition('Subject', 'random type(picklist)');
		obj.setDefinition('Type', 'random type(picklist)');
		obj.setDefinition('WhoId', 'random lookup(Contact) source(forceea)');
		obj.setDefinition('ActivityDatetime', 'random type(datetime) from(2017-10-1) to(2017-12-31)');
		obj.setDefinition('DurationInMinutes', 'random type(number) from(1) to(10) scale(0)');
		List<Database.SaveResult> saveResults = obj.insertRecords(false);

		Integer errors = 0;
		for (Database.SaveResult sr : saveResults) {
			if (!sr.isSuccess()) {
				errors++;
			}
		}
		System.assertEquals(0, errors, 'insertRecords - errors found');
	}

	@IsTest
	private static void insertRecords_comboBoxWithPicklistExcept_expectSuccess() {
		FObject obj = new FObject('Event', 10);
		obj.setDefinition('Subject', 'random type(picklist) except(Call, Email)');
		obj.setDefinition('Type', 'random type(picklist)');
		obj.setDefinition('WhoId', 'random lookup(Contact) source(forceea)');
		obj.setDefinition('ActivityDatetime', 'random type(datetime) from(2017-10-1) to(2017-12-31)');
		obj.setDefinition('DurationInMinutes', 'random type(number) from(1) to(10) scale(0)');
		List<Database.SaveResult> saveResults = obj.insertRecords(false);

		Integer errors = 0;
		for (Database.SaveResult sr : saveResults) {
			if (!sr.isSuccess()) {
				errors++;
			}
		}
		System.assertEquals(0, errors, 'insertRecords - errors found');
	}

	@IsTest
	private static void insertRecords_comboBoxWithList_expectSuccess() {
		FObject obj = new FObject('Event', 10);
		obj.setDefinition('Subject', 'random type(list) value(Call, Email)');
		obj.setDefinition('Type', 'random type(picklist)');
		obj.setDefinition('WhoId', 'random lookup(Contact) source(forceea)');
		obj.setDefinition('ActivityDatetime', 'random type(datetime) from(2017-10-1) to(2017-12-31)');
		obj.setDefinition('DurationInMinutes', 'random type(number) from(1) to(10) scale(0)');
		List<Database.SaveResult> saveResults = obj.insertRecords(false);

		Integer errors = 0;
		for (Database.SaveResult sr : saveResults) {
			if (!sr.isSuccess()) {
				errors++;
			}
		}
		System.assertEquals(0, errors, 'insertRecords - errors found');
	}

	@IsTest
	private static void insertRecords_comboBoxWithStaticExistingValue_expectSuccess() {
		FObject obj = new FObject('Event', 10);
		obj.setDefinition('Subject', 'static value(Call)');
		obj.setDefinition('Type', 'random type(picklist)');
		obj.setDefinition('WhoId', 'random lookup(Contact) source(forceea)');
		obj.setDefinition('ActivityDatetime', 'random type(datetime) from(2017-10-1) to(2017-12-31)');
		obj.setDefinition('DurationInMinutes', 'random type(number) from(1) to(10) scale(0)');
		List<Database.SaveResult> saveResults = obj.insertRecords(false);

		Integer errors = 0;
		for (Database.SaveResult sr : saveResults) {
			if (!sr.isSuccess()) {
				errors++;
			}
		}
		System.assertEquals(0, errors, 'insertRecords - errors found');
	}

	@IsTest
	private static void insertRecords_comboBoxWithStaticNewValue_expectSuccess() {
		FObject obj = new FObject('Event', 10);
		obj.setDefinition('Subject', 'static value(CallX)');
		obj.setDefinition('Type', 'random type(picklist)');
		obj.setDefinition('WhoId', 'random lookup(Contact) source(forceea)');
		obj.setDefinition('ActivityDatetime', 'random type(datetime) from(2017-10-1) to(2017-12-31)');
		obj.setDefinition('DurationInMinutes', 'random type(number) from(1) to(10) scale(0)');
		List<Database.SaveResult> saveResults = obj.insertRecords(false);

		Integer errors = 0;
		for (Database.SaveResult sr : saveResults) {
			if (!sr.isSuccess()) {
				errors++;
			}
		}
		System.assertEquals(0, errors, 'insertRecords - errors found');
	}

	@IsTest
	private static void insertRecordsFromTemplate_noErrorsAllOrNoneTrue_expectSuccess() {
		Map<String, FObject> template = new Map<String, FObject>(FObjectAsyncTest.templatePartition());

		Test.startTest();
		Map<String, List<Database.SaveResult>> saveResults = FObject.insertRecordsFromTemplate(template, true);
		Test.stopTest();

		Integer errors = 0;
		for (Database.SaveResult sr : saveResults.get('FObjectOnes')) {
			if (!sr.isSuccess()) {
				errors++;
			}
		}
		for (Database.SaveResult sr : saveResults.get('FObjectTwos')) {
			if (!sr.isSuccess()) {
				errors++;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'insertRecordsFromTemplate - errors found');
	}

	@IsTest
	private static void insertRecordsFromTemplate_noErrorsAllOrNoneFalse_expectSuccess() {
		Map<String, FObject> template = new Map<String, FObject>(FObjectAsyncTest.templatePartition());

		Test.startTest();
		Map<String, List<Database.SaveResult>> saveResults = FObject.insertRecordsFromTemplate(template, false);
		Test.stopTest();

		Integer errors = 0;
		for (Database.SaveResult sr : saveResults.get('FObjectOnes')) {
			if (!sr.isSuccess()) {
				errors++;
			}
		}
		for (Database.SaveResult sr : saveResults.get('FObjectTwos')) {
			if (!sr.isSuccess()) {
				errors++;
			}
		}
		if (!FObject.processIsValid()) {
			errors++;
		}
		System.assertEquals(0, errors, 'insertRecordsFromTemplate - errors found');
	}

	@IsTest
	private static void insertRecordsFromTemplate_errorsAllOrNoneTrue_expectFailure() {
		Map<String, FObject> template = new Map<String, FObject>(FObjectAsyncTest.templatePartition());

		template.get('FObjectOnes')
			.deleteDefinitions(FObjectOne__c.TestIntegerUnique__c)
			.setDefinition(FObjectOne__c.TestIntegerUnique__c, 'static value(1)');

		Test.startTest();
		String errorMessage = '';
		try {
			FObject.insertRecordsFromTemplate(template, true);
		} catch (Exception ex) {
			errorMessage = ex.getMessage();
		}
		Test.stopTest();

		Integer errors = 0;
		if (String.isBlank(errorMessage)) {
			errors += 1;
		}
		if (!FObject.processIsValid()) {
			errors += 2;
		}
		System.assertEquals(0, errors, 'insertRecordsFromTemplate - errors found');
	}

	@IsTest
	private static void insertRecordsFromTemplate_errorsAllOrNoneFalse_expectFailure() {
		Map<String, FObject> template = new Map<String, FObject>(FObjectAsyncTest.templatePartition());

		template.get('FObjectOnes')
			.deleteDefinitions(FObjectOne__c.TestIntegerUnique__c)
			.setDefinition(FObjectOne__c.TestIntegerUnique__c, 'static value(1)');

		Test.startTest();
		Map<String, List<Database.SaveResult>> saveResults = FObject.insertRecordsFromTemplate(template, false);
		Test.stopTest();

		Integer errors = 0;
		for (Database.SaveResult sr : saveResults.get('FObjectTwos')) {
			if (!sr.isSuccess()) {
				errors += 1;
				break;
			}
		}
		if (!saveResults.get('FObjectOnes').get(0).isSuccess()) {
			errors += 2;
		}
		if (saveResults.get('FObjectOnes').get(1).isSuccess()) {
			errors += 4;
		}
		if (!FObject.processIsValid()) {
			errors += 8;
		}
		System.assertEquals(0, errors, 'insertRecordsFromTemplate - errors found');
	}

	@IsTest
	private static void updateRecords_integerValues_expectSuccess() {
		FObject obj = new FObject('FObjectOne__c', 10)
			.setDefinition(FObjectOne__c.TestInteger__c, 'random type(number) from(1) to(100) scale(0)');
		obj.insertRecords(true);

		Test.startTest();
		obj.setDefinitionForUpdate(FObjectOne__c.TestInteger__c, 'serial type(number) from(1) step(1) scale(0)')
			.setNumberOfRecords(1)
			.setNumberOfNextRecord(1)
			.updateFields()
			.updateRecords(true);
		Test.stopTest();

		Integer errors = 0;
		Integer counter = 1;
		for (FObjectOne__c record : (List<FObjectOne__c>) obj.getInsertedRecords()) {
			if (record.TestInteger__c != counter) {
				errors++;
			}
			counter++;
		}
		System.assert(FObject.processIsValid() && errors == 0, 'updateRecords - errors found');
	}

	@IsTest
	private static void updateRecords_decimalValues_expectSuccess() {
		FObject obj = new FObject('FObjectOne__c', 10)
			.setDefinition(FObjectOne__c.TestDecimal__c, 'random type(number) from(1) to(100) scale(2)');
		obj.insertRecords(true);

		Test.startTest();
		obj.setDefinitionForUpdate(FObjectOne__c.TestDecimal__c, 'serial type(number) from(1) step(1.52) scale(2)')
			.setNumberOfNextRecord(1)
			.setNumberOfRecords(1)
			.updateFields()
			.updateRecords(true);
		Test.stopTest();

		Integer errors = 0;
		Decimal counter = 1;
		for (FObjectOne__c record : (List<FObjectOne__c>) obj.getInsertedRecords()) {
			if (record.TestDecimal__c != counter) {
				errors++;
			}
			counter += 1.52;
		}
		System.assert(FObject.processIsValid() && errors == 0, 'updateRecords - errors found');
	}

	@IsTest
	private static void updateRecords_dateValues_expectSuccess() {
		FObject obj = new FObject('FObjectOne__c', 10)
			.setDefinition(FObjectOne__c.TestDate__c, 'random type(date) from(2020-01-01) to(2020-12-31)');
		obj.insertRecords(true);

		Test.startTest();
		obj.setDefinitionForUpdate(FObjectOne__c.TestDate__c, 'serial type(date) from(2020-01-01) step(1)')
			.setNumberOfNextRecord(1)
			.setNumberOfRecords(1)
			.updateFields()
			.updateRecords(true);
		Test.stopTest();

		Integer errors = 0;
		Date counter = Date.newInstance(2020, 1, 1);
		for (FObjectOne__c record : (List<FObjectOne__c>) obj.getInsertedRecords()) {
			if (record.TestDate__c != counter) {
				errors++;
			}
			counter = counter.addDays(1);
		}
		System.assert(FObject.processIsValid() && errors == 0, 'updateRecords - errors found');
	}

	@IsTest
	private static void updateRecords_datetimeValues_expectSuccess() {
		FObject obj = new FObject('FObjectOne__c', 10)
			.setDefinition(FObjectOne__c.TestDatetime__c,
				'random type(datetime) from(2020-01-01) to(2020-12-31)');
		obj.insertRecords(true);

		Test.startTest();
		obj.setDefinitionForUpdate(FObjectOne__c.TestDatetime__c,
			'serial type(datetime) from(2020-01-01) step(1)')
			.setNumberOfNextRecord(1)
			.setNumberOfRecords(1)
			.updateFields()
			.updateRecords(true);
		Test.stopTest();

		Integer errors = 0;
		Datetime counter = Datetime.newInstance(2020, 1, 1);
		for (FObjectOne__c record : (List<FObjectOne__c>) obj.getInsertedRecords()) {
			if (record.TestDatetime__c != counter) {
				errors++;
			}
			counter = counter.addDays(1);
		}
		System.assert(FObject.processIsValid() && errors == 0, 'updateRecords - errors found');
	}

	@IsTest
	private static void updateRecords_stringValues_expectSuccess() {
		FObject obj = new FObject('FObjectOne__c', 10)
			.setDefinition(FObjectOne__c.TestText__c, 'static value(test)');
		obj.insertRecords(true);

		Test.startTest();
		obj
			.setDefinitionForUpdate(FObjectOne__c.TestText__c, 'static value(test)')
			.setDefinitionForUpdate(FObjectOne__c.TestText__c, 'serial type(number) from(1) step(1) scale(0)')
			.setNumberOfNextRecord(1)
			.setNumberOfRecords(1)
			.updateFields()
			.updateRecords(true);
		Test.stopTest();

		Integer errors = 0;
		Integer counter = 1;
		for (FObjectOne__c record : (List<FObjectOne__c>) obj.getInsertedRecords()) {
			if (record.TestText__c != 'test' + String.valueOf(counter)) {
				errors++;
			}
			counter++;
		}
		System.assert(FObject.processIsValid() && errors == 0, 'updateRecords - errors found');
	}

	@IsTest
	private static void updateRecords_create0Def_forUpdate0Def_noUpdate_expectSuccess() {
		FObject obj = new FObject('FObjectOne__c', 10)
			.setDefinition(FObjectOne__c.TestText__c, 'static value(one)');

		Test.startTest();
		obj
			.setNumberOfRecords(1)
			.updateRecords(true);
		Test.stopTest();

		List<FObjectOne__c> updatedRecords = (List<FObjectOne__c>) obj.getUpdatedRecords();
		System.assert(updatedRecords.isEmpty(), 'updateRecords - errors found');
	}

	@IsTest
	private static void updateRecords_create0Def_forUpdate0Def_update_expectSuccess() {
		FObject obj = new FObject('FObjectOne__c', 10)
			.setDefinition(FObjectOne__c.TestText__c, 'static value(one)');

		Test.startTest();
		obj
			.setNumberOfRecords(1)
			.updateFields()
			.updateRecords(true);
		Test.stopTest();

		List<FObjectOne__c> updatedRecords = (List<FObjectOne__c>) obj.getUpdatedRecords();
		System.assert(updatedRecords.isEmpty(), 'updateRecords - errors found');
	}

	@IsTest
	private static void updateRecords_create0Def_forUpdate1Def_noUpdate_expectSuccess() {
		FObject obj = new FObject('FObjectOne__c', 10)
			.setDefinition(FObjectOne__c.TestText__c, 'static value(one)');

		Test.startTest();
		obj
			.setNumberOfRecords(1)
			.setDefinitionForUpdate(FObjectOne__c.TestText__c, 'static value(two)')
			.updateRecords(true);
		Test.stopTest();

		List<FObjectOne__c> updatedRecords = (List<FObjectOne__c>) obj.getUpdatedRecords();
		System.assert(updatedRecords.isEmpty(), 'updateRecords - errors found');
	}

	@IsTest
	private static void updateRecords_create0Def_forUpdate1Def_update_expectSuccess() {
		FObject obj = new FObject('FObjectOne__c', 10)
			.setDefinition(FObjectOne__c.TestText__c, 'static value(one)');

		Test.startTest();
		obj
			.setNumberOfRecords(1)
			.setDefinitionForUpdate(FObjectOne__c.TestText__c, 'static value(two)')
			.updateFields()
			.updateRecords(true);
		Test.stopTest();

		List<FObjectOne__c> updatedRecords = (List<FObjectOne__c>) obj.getUpdatedRecords();
		System.assert(updatedRecords.isEmpty(), 'updateRecords - errors found');
	}

	@IsTest
	private static void updateRecords_create1Def_forUpdate0Def_noUpdate_expectSuccess() {
		FObject obj = new FObject('FObjectOne__c', 10)
			.setDefinition(FObjectOne__c.TestText__c, 'static value(one)');
		List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();

		Test.startTest();
		obj
			.setNumberOfRecords(1)
			.updateRecords(true);
		Test.stopTest();

		List<FObjectOne__c> updatedRecords = (List<FObjectOne__c>) obj.getUpdatedRecords();
		System.assert(updatedRecords.isEmpty(), 'updateRecords - errors found');
	}

	@IsTest
	private static void updateRecords_create1Def_forUpdate0Def_update_expectSuccess() {
		FObject obj = new FObject('FObjectOne__c', 10)
			.setDefinition(FObjectOne__c.TestText__c, 'static value(one)');
		List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();

		Test.startTest();
		obj
			.setNumberOfRecords(1)
			.updateFields()
			.updateRecords(true);
		Test.stopTest();

		List<FObjectOne__c> updatedRecords = (List<FObjectOne__c>) obj.getUpdatedRecords();
		System.assert(updatedRecords.isEmpty(), 'updateRecords - errors found');
	}

	@IsTest
	private static void updateRecords_create1Def_forUpdate1Def_noUpdate_expectSuccess() {
		FObject obj = new FObject('FObjectOne__c', 10)
			.setDefinition(FObjectOne__c.TestText__c, 'static value(one)');
		List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();

		Test.startTest();
		obj
			.setNumberOfRecords(1)
			.setDefinitionForUpdate(FObjectOne__c.TestText__c, 'static value(two)')
			.updateRecords(true);
		Test.stopTest();

		List<FObjectOne__c> updatedRecords = (List<FObjectOne__c>) obj.getUpdatedRecords();
		System.assert(updatedRecords.isEmpty(), 'updateRecords - errors found');
	}

	@IsTest
	private static void updateRecords_create1Def_forUpdate1Def_update_expectSuccess() {
		FObject obj = new FObject('FObjectOne__c', 10)
			.setDefinition(FObjectOne__c.TestText__c, 'static value(one)');
		List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();

		Test.startTest();
		obj
			.setNumberOfRecords(1)
			.setDefinitionForUpdate(FObjectOne__c.TestText__c, 'static value(two)')
			.updateFields()
			.updateRecords(true);
		Test.stopTest();

		List<FObjectOne__c> updatedRecords = (List<FObjectOne__c>) obj.getUpdatedRecords();
		System.assert(updatedRecords.isEmpty(), 'updateRecords - errors found');
	}

	@IsTest
	private static void updateRecords_insert1Def_forUpdate0Def_noUpdate_expectSuccess() {
		FObject obj = new FObject('FObjectOne__c', 10)
			.setDefinition(FObjectOne__c.TestText__c, 'static value(one)');
		obj.insertRecords(true);

		Test.startTest();
		obj
			.setNumberOfRecords(1)
			.updateRecords(true);
		Test.stopTest();

		List<FObjectOne__c> updatedRecords = (List<FObjectOne__c>) obj.getUpdatedRecords();
		System.assert(updatedRecords.isEmpty(), 'updateRecords - errors found');
	}

	@IsTest
	private static void updateRecords_insert1Def_forUpdate0Def_update_expectSuccess() {
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition(FObjectOne__c.TestText__c, 'serial type(number) from(1) step(1) scale(0)');
		obj.insertRecords(true);

		Test.startTest();
		obj
			.setNumberOfRecords(1)
			.updateFields()
			.updateRecords(true);
		Test.stopTest();

		List<FObjectOne__c> updatedRecords = (List<FObjectOne__c>) obj.getUpdatedRecords();
		System.assert(updatedRecords.isEmpty(), 'updateRecords - errors found');
	}

	@IsTest
	private static void updateRecords_insert1Def_forUpdate1Def_noUpdate_expectSuccess() {
		FObject obj = new FObject('FObjectOne__c', 10)
			.setDefinition(FObjectOne__c.TestText__c, 'static value(one)');
		obj.insertRecords(true);

		Test.startTest();
		obj
			.setNumberOfRecords(1)
			.setDefinitionForUpdate(FObjectOne__c.TestText__c, 'static value(two)')
			.updateRecords(true);
		Test.stopTest();

		List<FObjectOne__c> updatedRecords = (List<FObjectOne__c>) obj.getUpdatedRecords();
		System.assert(updatedRecords.isEmpty(), 'updateRecords - errors found');
	}

	@IsTest
	private static void updateRecords_insert1Def_forUpdate1Def_update_expectSuccess() {
		FObject obj = new FObject('FObjectOne__c', 10)
			.setDefinition(FObjectOne__c.TestText__c, 'static value(one)');
		obj.insertRecords(true);

		Test.startTest();
		String updatedValue = 'two';
		obj
			.setNumberOfRecords(1)
			.setDefinitionForUpdate(FObjectOne__c.TestText__c, 'static value(' + updatedValue + ')')
			.updateFields()
			.updateRecords(true);
		Test.stopTest();

		System.assert(ForceeaUtilityTest.updateIsValidForInsertedRecords('', updatedValue), 'updateRecords - errors found');
	}

	@IsTest
	private static void updateRecords_insert1Def_forUpdate2Def_update_expectSuccess() {
		FObject obj = new FObject('FObjectOne__c', 10)
			.setDefinition(FObjectOne__c.TestText__c, 'static value(one)');
		obj.insertRecords(true);

		Test.startTest();
		String updatedValue = 'two';
		obj
			.setNumberOfRecords(1)
			.setNumberOfNextRecord(1)
			.setDefinitionForUpdate(FObjectOne__c.TestText__c, 'static value(' + updatedValue + ')')
			.setDefinitionForUpdate(FObjectOne__c.TestText__c, 'serial type(number) from(1) step(1) scale(0)')
			.updateFields()
			.updateRecords(true);
		Test.stopTest();

		System.assert(ForceeaUtilityTest.updateIsValidForInsertedRecords('', updatedValue), 'updateRecords - errors found');
	}

	@IsTest
	private static void updateRecords_virtualField_expectSuccess() {
		FObject obj = new FObject(FObjectOne__c.SObjectType, 10)
			.setDefinition(FObjectOne__c.TestInteger__c, 'random type(number) from(1) to(100) scale(0)');
		obj.insertRecords(true, 'MyGroup');

		Test.startTest();
		obj.setNumberOfRecords(1)
			.setNumberOfNextRecord(1)
			.setDefinition(FObjectOne__c.TestPicklistA__c, 'random type(picklist)')
			.setDefinitionForUpdate('$SerialValues', 'serial type(number) from(1) step(1) scale(0)')
			.setDefinitionForUpdate(FObjectOne__c.TestInteger__c, 'copy field($SerialValues)')
			.setDefinitionForUpdate(FObjectOne__c.TestIntegerUnique__c, 'copy field($SerialValues)')
			.updateFields()
			.updateRecords(true);
		Test.stopTest();

		Integer errors = 0;
		Integer counter = 1;
		for (FObjectOne__c record : (List<FObjectOne__c>) obj.getInsertedRecords()) {
			if (record.TestInteger__c != counter && record.TestIntegerUnique__c != counter) {
				errors++;
			}
			counter++;
		}
		System.assert(FObject.processIsValid() && errors == 0, 'updateRecords - errors found');
	}

	@IsTest
	private static void updateRecords_externalRecord_expectSuccess() {
		FObjectOne__c recordToInsert = new FObjectOne__c(TestTextRequired__c = 'Test');
		insert recordToInsert;
		FObject obj = new FObject(recordToInsert);

		Test.startTest();
		obj.setNumberOfRecords(1)
			.setDefinition(FObjectOne__c.TestText__c, 'random type(list) value(a,b,c)')
			.setDefinitionForUpdate('$SerialValues', 'serial type(number) from(1) step(1) scale(0)')
			.setDefinitionForUpdate(FObjectOne__c.TestInteger__c, 'copy field($SerialValues)')
			.setDefinitionForUpdate(FObjectOne__c.TestTextRequired__c, 'copy field($SerialValues)')
			.updateFields('')
			.updateRecords(true);
		Test.stopTest();

		Integer errors = 0;
		Integer counter = 1;
		for (FObjectOne__c record : (List<FObjectOne__c>) obj.getUpdatedRecords()) {
			if (record.TestInteger__c != counter && record.TestTextRequired__c != String.valueOf(counter)) {
				errors++;
			}
			counter++;
		}
		if (obj.getUpdatedRecords().size() != 1) {
			errors++;
		}
		System.assert(FObject.processIsValid() && errors == 0, 'updateRecords - errors found');
	}

	@IsTest
	private static void updateRecords_externalRecordGroup_expectSuccess() {
		FObjectOne__c recordToInsert = new FObjectOne__c(TestTextRequired__c = 'Test');
		insert recordToInsert;
		FObject obj = new FObject(recordToInsert, 'group1');

		Test.startTest();
		obj.setNumberOfRecords(1)
			.setDefinition(FObjectOne__c.TestText__c, 'random type(list) value(a,b,c)')
			.setDefinitionForUpdate('$SerialValues', 'serial type(number) from(1) step(1) scale(0)')
			.setDefinitionForUpdate(FObjectOne__c.TestInteger__c, 'copy field($SerialValues)')
			.setDefinitionForUpdate(FObjectOne__c.TestTextRequired__c, 'copy field($SerialValues)')
			.updateFields('group1')
			.updateRecords(true);
		Test.stopTest();

		Integer errors = 0;
		Integer counter = 1;
		for (FObjectOne__c record : (List<FObjectOne__c>) obj.getUpdatedRecords()) {
			if (record.TestInteger__c != counter && record.TestTextRequired__c != String.valueOf(counter)) {
				errors++;
			}
			counter++;
		}
		if (obj.getUpdatedRecords().size() != 1) {
			errors++;
		}
		System.assert(FObject.processIsValid() && errors == 0, 'updateRecords - errors found');
	}

	@IsTest
	private static void updateRecords_externalRecords_expectSuccess() {
		List<FObjectOne__c> recordsToInsert = new List<FObjectOne__c>();
		for (Integer counter = 1; counter <= 10; counter++) {
			recordsToInsert.add(new FObjectOne__c(TestTextRequired__c = 'Test' + String.valueOf(counter)));
		}
		insert recordsToInsert;
		FObject obj = new FObject(recordsToInsert);

		Test.startTest();
		obj.setNumberOfRecords(1)
			.setDefinition(FObjectOne__c.TestText__c, 'random type(list) value(a,b,c)')
			.setDefinitionForUpdate('$SerialValues', 'serial type(number) from(1) step(1) scale(0)')
			.setDefinitionForUpdate(FObjectOne__c.TestInteger__c, 'copy field($SerialValues)')
			.setDefinitionForUpdate(FObjectOne__c.TestTextRequired__c, 'copy field($SerialValues)')
			.updateFields('')
			.updateRecords(true);
		Test.stopTest();

		Integer errors = 0;
		Integer counter = 1;
		for (FObjectOne__c record : (List<FObjectOne__c>) obj.getUpdatedRecords()) {
			if (record.TestInteger__c != counter && record.TestTextRequired__c != String.valueOf(counter)) {
				errors++;
			}
			counter++;
		}
		if (obj.getUpdatedRecords().size() != 10) {
			errors++;
		}
		System.assert(FObject.processIsValid() && errors == 0, 'updateRecords - errors found');
	}

	@IsTest
	private static void updateRecords_externalRecordsGroup_expectSuccess() {
		List<FObjectOne__c> recordsToInsert = new List<FObjectOne__c>();
		for (Integer counter = 1; counter <= 10; counter++) {
			recordsToInsert.add(new FObjectOne__c(TestTextRequired__c = 'Test' + String.valueOf(counter)));
		}
		insert recordsToInsert;
		FObject obj = new FObject(recordsToInsert, 'group1');

		Test.startTest();
		obj.setNumberOfRecords(1)
			.setDefinition(FObjectOne__c.TestText__c, 'random type(list) value(a,b,c)')
			.setDefinitionForUpdate('$SerialValues', 'serial type(number) from(1) step(1) scale(0)')
			.setDefinitionForUpdate(FObjectOne__c.TestInteger__c, 'copy field($SerialValues)')
			.setDefinitionForUpdate(FObjectOne__c.TestTextRequired__c, 'copy field($SerialValues)')
			.updateFields('group1')
			.updateRecords(true);
		Test.stopTest();

		Integer errors = 0;
		Integer counter = 1;
		for (FObjectOne__c record : (List<FObjectOne__c>) obj.getUpdatedRecords()) {
			if (record.TestInteger__c != counter && record.TestTextRequired__c != String.valueOf(counter)) {
				errors++;
			}
			counter++;
		}
		if (obj.getUpdatedRecords().size() != 10) {
			errors++;
		}
		System.assert(FObject.processIsValid() && errors == 0, 'updateRecords - errors found');
	}
}
