/*
  FORCEEA data factory framework (version 1.3.1)
  Copyright (C) 2018 Nikos Mitrakis

  This program is free software: you can redistribute it and/or modify it under the terms
  of the GNU General Public License as published by the Free Software Foundation,
  either version 3 of the License, or any later version.

  This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
  without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  See the GNU General Public License for more details.

  You can find a copy of the GNU General Public License at
  https://github.com/nmitrakis/Forceea/blob/master/LICENSE
*/

/**
 * @description FObject Test Class
 * @version 1.3.1
 */
@IsTest
public class FObjectTest {
  private static Set<String> femaleFirstNames;
  private static Set<String> femaleLastNames;
  private static Set<String> maleFirstNames;
  private static Set<String> maleLastNames;

  /* createRecords */

  @IsTest
  private static void createRecords_getRecordsBeforeInsertRecords_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestInteger__c', 'serial type(number) from(1) step(1) scale(0)');
    obj.createRecords();
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    obj.insertRecords(true);
    Test.stopTest();

    Integer errors = 0;
    Set<Id> recordIdsSet = (new Map<Id, SObject>(records)).keySet();
    for (FObjectOne__c objRecord : [SELECT Id FROM FObjectOne__c LIMIT 1000]) {
      if (!recordIdsSet.contains(objRecord.Id)) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'createRecords - errors found');
  }

  @IsTest
  private static void createRecords_insertRecordsBeforeGetRecords_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestInteger__c', 'serial type(number) from(1) step(1) scale(0)');
    obj.createRecords();
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    Integer errors = 0;
    Set<Id> recordIdsSet = (new Map<Id, SObject>(records)).keySet();
    for (FObjectOne__c objRecord : [SELECT Id FROM FObjectOne__c LIMIT 1000]) {
      if (!recordIdsSet.contains(objRecord.Id)) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'createRecords - errors found');
  }

  @IsTest
  private static void createRecords_callOnceAfterInsertRecords_expectSuccess() {
    Integer size1 = 201;
    Integer size2 = 100;
    FObject.setGlobalVerbose('debug');

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c', size1);
    obj.setDefinition('TestInteger__c', 'serial type(number) from(1) step(1) scale(0)');
    obj.createRecords();
    obj.insertRecords(true);

    obj.records = size2;
    obj.createRecords();
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    List<FObjectOne__c> insertedRecords = [SELECT Id, TestInteger__c FROM FObjectOne__c LIMIT 1000];
    Integer errors = 0;
    if (insertedRecords.size() != size1) {
      errors += 1;
    }
    if (records[size2 - 1].TestInteger__c != (size1 + size2)) {
      errors += 2;
    }
    if (!FObject.processIsValid) {
      errors += 4;
    }
    System.assertEquals(0, errors, 'createRecords - errors found');
  }

  @IsTest
  private static void createRecords_callTwiceAfterInsertRecords_expectSuccess() {
    Integer size1 = 201;
    Integer size2 = 100;
    Integer size3 = 50;

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c', size1);
    obj.setDefinition('TestInteger__c', 'serial type(number) from(1) step(1) scale(0)');
    obj.createRecords();
    Database.SaveResult[] saveResults1 = obj.insertRecords(true);

    obj.records = size2;
    obj.createRecords();

    obj.records = size3;
    obj.createRecords();
    Database.SaveResult[] saveResults2 = obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    List<FObjectOne__c> insertedRecords = [SELECT Id, TestInteger__c FROM FObjectOne__c LIMIT 1000];
    Integer errors = 0;
    if (saveResults1.size() != size1) {
      errors += 1;
    }
    if (saveResults2.size() != (size2 + size3)) {
      errors += 2;
    }
    if (insertedRecords.size() != (size1 + size2 + size3)) {
      errors += 4;
    }
    if (records[size3 - 1].TestInteger__c != (size1 + size2 + size3)) {
      errors += 8;
    }
    if (!FObject.processIsValid) {
      errors += 16;
    }
    System.assertEquals(0, errors, 'createRecords - errors found');
  }

  @IsTest
  private static void createRecords_discontinuousRecordNumber_expectSuccess() {
    Integer size1 = 201;
    Integer size2 = 100;

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c', size1);
    obj.setDefinition('TestInteger__c', 'serial type(number) from(1) step(1) scale(0)');
    obj.createRecords();
    List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj.getRecords();
    obj.records = size2;
    obj.createRecords(size1 + 2);
    List<FObjectOne__c> records2 = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    records2.addAll(records1);
    Integer errors = 0;
    for (FObjectOne__c objRecord : records2) {
      if (objRecord.TestInteger__c == size1 + 1) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'createRecords - errors found');
  }

  @IsTest
  private static void createRecords_noDefinitions_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.createRecords();
    Database.SaveResult[] saveResults = obj.insertRecords(true);
    Test.stopTest();

    Integer errors = 0;
    for (Database.SaveResult sr : saveResults) {
      if (!sr.isSuccess()) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'insertRecords - errors found');
  }

  @IsTest
  private static void createRecords_validRecordNumber_expectSuccess() {
    Integer size1 = 201;
    Integer size2 = 100;

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c', size1);
    obj.setDefinition('TestInteger__c', 'serial type(number) from(1) step(1) scale(0)');
    obj.createRecords();
    obj.records = size2;
    obj.createRecords(size1 + 1);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    Integer errors = 0;
    if (records[size2 - 1].TestInteger__c != (size1 + size2)) {
      errors++;
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'createRecords - errors found');
  }

  @IsTest
  private static void createRecords_invalidRecordNumber_expectfailure() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestInteger__c', 'serial type(number) from(1) step(1) scale(0)');
    obj.createRecords(-1);
    Test.stopTest();

    String expectedResult = 'Invalid record number in method createRecords';
    String actualResult = obj.getErrors().get('FObjectOne__c').get(0);

    System.assertEquals(expectedResult, actualResult, 'createRecords - errors found');
  }

  /* definitionIsValidForFieldDataType */

  @IsTest
  private static void definitionIsValidForFieldDataType_base64_expectFailure() {
    String fieldApiName = 'Body';

    List<String> validDefinitions = new List<String>();
    validDefinitions.add('Copy Field(TestPicklistD__c)');
    validDefinitions.add('Copy Field(TestLookup__c) From(FObjectTwo__c.TestText__c)');
    validDefinitions.add('Random Type(Boolean)');
    validDefinitions.add('Random Type(City) Group(one)');
    validDefinitions.add('Random Type(Country) Group(one)');
    validDefinitions.add('Random Type(Date) From(2017-01-01) To(2017-12-31)');
    validDefinitions.add('Random Type(Datetime) From(2017-01-01) To(2017-12-31)');
    validDefinitions.add('Random Type(Email)');
    validDefinitions.add('Random Type(Phone) Format(30 210 dD DD ddD)');
    validDefinitions.add('Random Type(FirstName) Group(one)');
    validDefinitions.add('Random Type(LastName) Group(one)');
    validDefinitions.add('Random Type(List) Value(1, 2, 3)');
    validDefinitions.add('Random Type(List) Value(1.1, 2.2, 3.3)');
    validDefinitions.add('Random Type(List) Value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
    validDefinitions.add('Random Type(List) Value(2017-01-01, 2017-02-02, 2017-03-03)');
    validDefinitions.add('Random Type(List) Value(One, Two, Three)');
    validDefinitions.add('Random Type(Number) From(1) To(100) Scale(0)');
    validDefinitions.add('Random Type(Postalcode) Group(one)');
    validDefinitions.add('Random Type(State) Group(one)');
    validDefinitions.add('Random Type(Street) Group(one)');
    validDefinitions.add('Random Type(String) Minlength(10) Maxlength(30) Startwith(Lower) Include(Lower,Upper,Digit)');
    validDefinitions.add('Random Type(Text) Minlength(10) Maxlength(30)');
    validDefinitions.add('Random Type(Url)');
    validDefinitions.add('Serial Type(Date) From(2017-01-01) Step(2)');
    validDefinitions.add('Serial Type(Datetime) From(2017-01-01 02:02:02) Step(2.2)');
    validDefinitions.add('Serial Type(Number) From(10.2) Step(1.2) Scale(2)');
    validDefinitions.add('Static Value(01:01:01)');
    validDefinitions.add('Static Value(10.1)');
    validDefinitions.add('Static Value(10)');
    validDefinitions.add('Static Value(2017-01-01 01:01:01)');
    validDefinitions.add('Static Value(2017-01-01)');
    validDefinitions.add('Static Value(One)');
    List<String> invalidDefinitions = new List<String>();
    invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Except(One,Two,Three) Source(Forceea)');
    invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Value(One,Two,Three) Source(Forceea)');
    invalidDefinitions.add('Random Lookup(Account) Source(Forceea)');
    invalidDefinitions.add('Random lookup(Account) Where(Rating = \'Hot\') source(salesforce)');
    invalidDefinitions.add('Random Type(Picklist) Except(One,Two)');
    invalidDefinitions.add('Random Type(Picklist)');
    invalidDefinitions.add('Static Lookup(Account) Field(FieldOne) Value(One) Source(Forceea)');

    Test.startTest();
    Boolean expectedResult = false;
    Boolean actualResult = checkMultipleDefinitions(
      new FObject('Attachment'), fieldApiName, validDefinitions, invalidDefinitions);
    Test.stopTest();

    System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
  }

  @IsTest
  private static void definitionIsValidForFieldDataType_boolean_expectFailure() {
    String fieldApiName = 'TestCheckbox__c';

    List<String> validDefinitions = new List<String>();
    validDefinitions.add('Copy Field(TestPicklistD__c)');
    validDefinitions.add('Copy Field(TestLookup__c) From(FObjectTwo__c.TestText__c)');
    validDefinitions.add('Random Type(Boolean)');
    validDefinitions.add('Random Type(List) Value(One, Two, Three)');
    validDefinitions.add('Static Value(One)');
    List<String> invalidDefinitions = new List<String>();
    invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Except(One,Two,Three) Source(Forceea)');
    invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Value(One,Two,Three) Source(Forceea)');
    invalidDefinitions.add('Random Lookup(Account) Source(Forceea)');
    invalidDefinitions.add('Random lookup(Account) Where(Rating = \'Hot\') source(salesforce)');
    invalidDefinitions.add('Random Type(City) Group(one)');
    invalidDefinitions.add('Random Type(Country) Group(one)');
    invalidDefinitions.add('Random Type(Date) From(2017-01-01) To(2017-12-31)');
    invalidDefinitions.add('Random Type(Datetime) From(2017-01-01) To(2017-12-31)');
    invalidDefinitions.add('Random Type(Email)');
    invalidDefinitions.add('Random Type(Phone) Format(30 210 dD DD ddD)');
    invalidDefinitions.add('Random Type(FirstName) Group(one)');
    invalidDefinitions.add('Random Type(LastName) Group(one)');
    invalidDefinitions.add('Random Type(List) Value(1, 2, 3)');
    invalidDefinitions.add('Random Type(List) Value(1.1, 2.2, 3.3)');
    invalidDefinitions.add('Random Type(List) Value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
    invalidDefinitions.add('Random Type(List) Value(2017-01-01, 2017-02-02, 2017-03-03)');
    invalidDefinitions.add('Random Type(Picklist) Except(One,Two)');
    invalidDefinitions.add('Random Type(Picklist)');
    invalidDefinitions.add('Random Type(Postalcode) Group(one)');
    invalidDefinitions.add('Random Type(State) Group(one)');
    invalidDefinitions.add('Random Type(Street) Group(one)');
    invalidDefinitions.add('Random Type(String) Minlength(10) Maxlength(30) Startwith(Lower) Include(Lower,Upper,Digit)');
    invalidDefinitions.add('Random Type(Text) Minlength(10) Maxlength(30)');
    invalidDefinitions.add('Random Type(Url)');
    invalidDefinitions.add('Serial Type(Date) From(2017-01-01) Step(2)');
    invalidDefinitions.add('Serial Type(Datetime) From(2017-01-01 02:02:02) Step(2.2)');
    invalidDefinitions.add('Serial Type(Number) From(10.2) Step(1.2) Scale(2)');
    invalidDefinitions.add('Static Lookup(Account) Field(FieldOne) Value(One) Source(Forceea)');
    invalidDefinitions.add('Static Value(01:01:01)');
    invalidDefinitions.add('Static Value(10.1)');
    invalidDefinitions.add('Static Value(10)');
    invalidDefinitions.add('Static Value(2017-01-01 01:01:01)');
    invalidDefinitions.add('Static Value(2017-01-01)');
    invalidDefinitions.add('Random Type(Number) From(1) To(100) Scale(0)');

    Test.startTest();
    Boolean expectedResult = false;
    Boolean actualResult = checkMultipleDefinitions(
      new FObject('FObjectOne__c'), fieldApiName, validDefinitions, invalidDefinitions);
    Test.stopTest();

    System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
  }

  @IsTest
  private static void definitionIsValidForFieldDataType_combobox_expectFailure() {
    String fieldApiName = 'Subject';

    List<String> validDefinitions = new List<String>();
    validDefinitions.add('Copy Field(WhoId)');
    validDefinitions.add('Random Type(Boolean)');
    validDefinitions.add('Random Type(City) Group(one)');
    validDefinitions.add('Random Type(Country) Group(one)');
    validDefinitions.add('Random Type(Date) From(2017-01-01) To(2017-12-31)');
    validDefinitions.add('Random Type(Datetime) From(2017-01-01) To(2017-12-31)');
    validDefinitions.add('Random Type(Email)');
    validDefinitions.add('Random Type(Phone) Format(30 210 dD DD ddD)');
    validDefinitions.add('Random Type(FirstName) Group(one)');
    validDefinitions.add('Random Type(LastName) Group(one)');
    validDefinitions.add('Random Type(List) Value(1, 2, 3)');
    validDefinitions.add('Random Type(List) Value(1.1, 2.2, 3.3)');
    validDefinitions.add('Random Type(List) Value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
    validDefinitions.add('Random Type(List) Value(2017-01-01, 2017-02-02, 2017-03-03)');
    validDefinitions.add('Random Type(List) Value(One, Two, Three)');
    validDefinitions.add('Random Type(Number) From(1) To(100) Scale(0)');
    validDefinitions.add('random type(picklist) except(One,Two)');
    validDefinitions.add('Random Type(Picklist)');
    validDefinitions.add('Random Type(Postalcode) Group(one)');
    validDefinitions.add('Random Type(State) Group(one)');
    validDefinitions.add('Random Type(Street) Group(one)');
    validDefinitions.add('Random Type(String) Minlength(10) Maxlength(30) Startwith(Lower) Include(Lower,Upper,Digit)');
    validDefinitions.add('Random Type(Text) Minlength(10) Maxlength(30)');
    validDefinitions.add('Random Type(Url)');
    validDefinitions.add('Serial Type(Date) From(2017-01-01) Step(2)');
    validDefinitions.add('Serial Type(Datetime) From(2017-01-01 02:02:02) Step(2.2)');
    validDefinitions.add('Serial Type(Number) From(10.2) Step(1.2) Scale(2)');
    validDefinitions.add('Static Value(01:01:01)');
    validDefinitions.add('Static Value(10.1)');
    validDefinitions.add('Static Value(10)');
    validDefinitions.add('Static Value(2017-01-01 01:01:01)');
    validDefinitions.add('Static Value(2017-01-01)');
    validDefinitions.add('Static Value(One)');
    List<String> invalidDefinitions = new List<String>();
    invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Except(One,Two,Three) Source(Forceea)');
    invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Value(One,Two,Three) Source(Forceea)');
    invalidDefinitions.add('Random Lookup(Account) Source(Forceea)');
    invalidDefinitions.add('Random lookup(Account) Where(Rating = \'Hot\') source(salesforce)');
    invalidDefinitions.add('Static Lookup(Account) Field(FieldOne) Value(One) Source(Forceea)');

    Test.startTest();
    Boolean expectedResult = false;
    Boolean actualResult = checkMultipleDefinitions(
      new FObject('Event'), fieldApiname, validDefinitions, invalidDefinitions);
    Test.stopTest();

    System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
  }

  @IsTest
  private static void definitionIsValidForFieldDataType_currency_expectFailure() {
    String fieldApiName = 'TestCurrency__c';

    List<String> validDefinitions = new List<String>();
    validDefinitions.add('Copy Field(TestPicklistD__c)');
    validDefinitions.add('Copy Field(TestLookup__c) From(FObjectTwo__c.TestText__c)');
    validDefinitions.add('Random Type(List) Value(1, 2, 3)');
    validDefinitions.add('Random Type(List) Value(1.1, 2.2, 3.3)');
    validDefinitions.add('Random Type(Number) From(1) To(100) Scale(0)');
    validDefinitions.add('Serial Type(Number) From(10.2) Step(1.2) Scale(2)');
    validDefinitions.add('Static Value(10.1)');
    validDefinitions.add('Static Value(10)');
    List<String> invalidDefinitions = new List<String>();
    invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Except(One,Two,Three) Source(Forceea)');
    invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Value(One,Two,Three) Source(Forceea)');
    invalidDefinitions.add('Random Lookup(Account) Source(Forceea)');
    invalidDefinitions.add('Random lookup(Account) Where(Rating = \'Hot\') source(salesforce)');
    invalidDefinitions.add('Random Type(Boolean)');
    invalidDefinitions.add('Random Type(City) Group(one)');
    invalidDefinitions.add('Random Type(Country) Group(one)');
    invalidDefinitions.add('Random Type(Date) From(2017-01-01) To(2017-12-31)');
    invalidDefinitions.add('Random Type(Datetime) From(2017-01-01) To(2017-12-31)');
    invalidDefinitions.add('Random Type(Email)');
    invalidDefinitions.add('Random Type(Phone) Format(30 210 dD DD ddD)');
    invalidDefinitions.add('Random Type(FirstName) Group(one)');
    invalidDefinitions.add('Random Type(LastName) Group(one)');
    invalidDefinitions.add('Random Type(List) Value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
    invalidDefinitions.add('Random Type(List) Value(2017-01-01, 2017-02-02, 2017-03-03)');
    invalidDefinitions.add('Random Type(List) Value(One, Two, Three)');
    invalidDefinitions.add('Random Type(Picklist) Except(One,Two)');
    invalidDefinitions.add('Random Type(Picklist)');
    invalidDefinitions.add('Random Type(Postalcode) Group(one)');
    invalidDefinitions.add('Random Type(State) Group(one)');
    invalidDefinitions.add('Random Type(Street) Group(one)');
    invalidDefinitions.add('Random Type(String) Minlength(10) Maxlength(30) Startwith(Lower) Include(Lower,Upper,Digit)');
    invalidDefinitions.add('Random Type(Text) Minlength(10) Maxlength(30)');
    invalidDefinitions.add('Random Type(Url)');
    invalidDefinitions.add('Serial Type(Date) From(2017-01-01) Step(2)');
    invalidDefinitions.add('Serial Type(Datetime) From(2017-01-01 02:02:02) Step(2.2)');
    invalidDefinitions.add('Static Lookup(Account) Field(FieldOne) Value(One) Source(Forceea)');
    invalidDefinitions.add('Static Value(01:01:01)');
    invalidDefinitions.add('Static Value(2017-01-01 01:01:01)');
    invalidDefinitions.add('Static Value(2017-01-01)');
    invalidDefinitions.add('Static Value(One)');

    Test.startTest();
    Boolean expectedResult = false;
    Boolean actualResult = checkMultipleDefinitions(
      new FObject('FObjectOne__c'), fieldApiname, validDefinitions, invalidDefinitions);
    Test.stopTest();

    System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
  }

  @IsTest
  private static void definitionIsValidForFieldDataType_date_expectFailure() {
    String fieldApiName = 'TestDate__c';

    List<String> validDefinitions = new List<String>();
    validDefinitions.add('Copy Field(TestPicklistD__c)');
    validDefinitions.add('Copy Field(TestLookup__c) From(FObjectTwo__c.TestText__c)');
    validDefinitions.add('Random Type(Date) From(2017-01-01) To(2017-12-31)');
    validDefinitions.add('Random Type(List) Value(2017-01-01, 2017-02-02, 2017-03-03)');
    validDefinitions.add('Serial Type(Date) From(2017-01-01) Step(2)');
    validDefinitions.add('Static Value(2017-01-01)');
    List<String> invalidDefinitions = new List<String>();
    invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Except(One,Two,Three) Source(Forceea)');
    invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Value(One,Two,Three) Source(Forceea)');
    invalidDefinitions.add('Random Lookup(Account) Source(Forceea)');
    invalidDefinitions.add('Random lookup(Account) Where(Rating = \'Hot\') source(salesforce)');
    invalidDefinitions.add('Random Type(Boolean)');
    invalidDefinitions.add('Random Type(City) Group(one)');
    invalidDefinitions.add('Random Type(Country) Group(one)');
    invalidDefinitions.add('Random Type(Datetime) From(2017-01-01) To(2017-12-31)');
    invalidDefinitions.add('Random Type(Email)');
    invalidDefinitions.add('Random Type(Phone) Format(30 210 dD DD ddD)');
    invalidDefinitions.add('Random Type(FirstName) Group(one)');
    invalidDefinitions.add('Random Type(LastName) Group(one)');
    invalidDefinitions.add('Random Type(List) Value(1, 2, 3)');
    invalidDefinitions.add('Random Type(List) Value(1.1, 2.2, 3.3)');
    invalidDefinitions.add('Random Type(List) Value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
    invalidDefinitions.add('Random Type(List) Value(One, Two, Three)');
    invalidDefinitions.add('Random Type(Number) From(1) To(100) Scale(0)');
    invalidDefinitions.add('Random Type(Picklist) Except(One,Two)');
    invalidDefinitions.add('Random Type(Picklist)');
    invalidDefinitions.add('Random Type(Postalcode) Group(one)');
    invalidDefinitions.add('Random Type(State) Group(one)');
    invalidDefinitions.add('Random Type(Street) Group(one)');
    invalidDefinitions.add('Random Type(String) Minlength(10) Maxlength(30) Startwith(Lower) Include(Lower,Upper,Digit)');
    invalidDefinitions.add('Random Type(Text) Minlength(10) Maxlength(30)');
    invalidDefinitions.add('Random Type(Url)');
    invalidDefinitions.add('Serial Type(Datetime) From(2017-01-01 02:02:02) Step(2.2)');
    invalidDefinitions.add('Serial Type(Number) From(10.2) Step(1.2) Scale(2)');
    invalidDefinitions.add('Static Lookup(Account) Field(FieldOne) Value(One) Source(Forceea)');
    invalidDefinitions.add('Static Value(01:01:01)');
    invalidDefinitions.add('Static Value(10.1)');
    invalidDefinitions.add('Static Value(10)');
    invalidDefinitions.add('Static Value(2017-01-01 01:01:01)');
    invalidDefinitions.add('Static Value(One)');

    Test.startTest();
    Boolean expectedResult = false;
    Boolean actualResult = checkMultipleDefinitions(
      new FObject('FObjectOne__c'), fieldApiname, validDefinitions, invalidDefinitions);
    Test.stopTest();

    System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
  }

  @IsTest
  private static void definitionIsValidForFieldDataType_datetime_expectFailure() {
    String fieldApiName = 'TestDatetime__c';

    List<String> validDefinitions = new List<String>();
    validDefinitions.add('Copy Field(TestPicklistD__c)');
    validDefinitions.add('Copy Field(TestLookup__c) From(FObjectTwo__c.TestText__c)');
    validDefinitions.add('Random Type(Datetime) From(2017-01-01) To(2017-12-31)');
    validDefinitions.add('Random Type(List) Value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
    validDefinitions.add('Random Type(List) Value(2017-01-01, 2017-02-02, 2017-03-03)');
    validDefinitions.add('Serial Type(Date) From(2017-01-01) Step(2)');
    validDefinitions.add('Serial Type(Datetime) From(2017-01-01 02:02:02) Step(2.2)');
    validDefinitions.add('Static Value(2017-01-01 01:01:01)');
    List<String> invalidDefinitions = new List<String>();
    invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Except(One,Two,Three) Source(Forceea)');
    invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Value(One,Two,Three) Source(Forceea)');
    invalidDefinitions.add('Random Lookup(Account) Source(Forceea)');
    invalidDefinitions.add('Random lookup(Account) Where(Rating = \'Hot\') source(salesforce)');
    invalidDefinitions.add('Random Type(Boolean)');
    invalidDefinitions.add('Random Type(City) Group(one)');
    invalidDefinitions.add('Random Type(Country) Group(one)');
    invalidDefinitions.add('Random Type(Date) From(2017-01-01) To(2017-12-31)');
    invalidDefinitions.add('Random Type(Email)');
    invalidDefinitions.add('Random Type(Phone) Format(30 210 dD DD ddD)');
    invalidDefinitions.add('Random Type(FirstName) Group(one)');
    invalidDefinitions.add('Random Type(LastName) Group(one)');
    invalidDefinitions.add('Random Type(List) Value(1, 2, 3)');
    invalidDefinitions.add('Random Type(List) Value(1.1, 2.2, 3.3)');
    invalidDefinitions.add('Random Type(List) Value(One, Two, Three)');
    invalidDefinitions.add('Random Type(Number) From(1) To(100) Scale(0)');
    invalidDefinitions.add('Random Type(Picklist) Except(One,Two)');
    invalidDefinitions.add('Random Type(Picklist)');
    invalidDefinitions.add('Random Type(Postalcode) Group(one)');
    invalidDefinitions.add('Random Type(State) Group(one)');
    invalidDefinitions.add('Random Type(Street) Group(one)');
    invalidDefinitions.add('Random Type(String) Minlength(10) Maxlength(30) Startwith(Lower) Include(Lower,Upper,Digit)');
    invalidDefinitions.add('Random Type(Text) Minlength(10) Maxlength(30)');
    invalidDefinitions.add('Random Type(Url)');
    invalidDefinitions.add('Serial Type(Number) From(10.2) Step(1.2) Scale(2)');
    invalidDefinitions.add('Static Lookup(Account) Field(FieldOne) Value(One) Source(Forceea)');
    invalidDefinitions.add('Static Value(01:01:01)');
    invalidDefinitions.add('Static Value(10.1)');
    invalidDefinitions.add('Static Value(10)');
    invalidDefinitions.add('Static Value(2017-01-01)');
    invalidDefinitions.add('Static Value(One)');

    Test.startTest();
    Boolean expectedResult = false;
    Boolean actualResult = checkMultipleDefinitions(
      new FObject('FObjectOne__c'), fieldApiname, validDefinitions, invalidDefinitions);
    Test.stopTest();

    System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
  }

  @IsTest
  private static void definitionIsValidForFieldDataType_double_expectFailure() {
    String fieldApiName = 'TestDecimal__c';

    List<String> validDefinitions = new List<String>();
    validDefinitions.add('Copy Field(TestPicklistD__c)');
    validDefinitions.add('Copy Field(TestLookup__c) From(FObjectTwo__c.TestText__c)');
    validDefinitions.add('Random Type(List) Value(1, 2, 3)');
    validDefinitions.add('Random Type(List) Value(1.1, 2.2, 3.3)');
    validDefinitions.add('Random Type(Number) From(1) To(100) Scale(0)');
    validDefinitions.add('Serial Type(Number) From(10.2) Step(1.2) Scale(2)');
    validDefinitions.add('Static Value(10.1)');
    validDefinitions.add('Static Value(10)');
    List<String> invalidDefinitions = new List<String>();
    invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Except(One,Two,Three) Source(Forceea)');
    invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Value(One,Two,Three) Source(Forceea)');
    invalidDefinitions.add('Random Lookup(Account) Source(Forceea)');
    invalidDefinitions.add('Random lookup(Account) Where(Rating = \'Hot\') source(salesforce)');
    invalidDefinitions.add('Random Type(Boolean)');
    invalidDefinitions.add('Random Type(City) Group(one)');
    invalidDefinitions.add('Random Type(Country) Group(one)');
    invalidDefinitions.add('Random Type(Date) From(2017-01-01) To(2017-12-31)');
    invalidDefinitions.add('Random Type(Datetime) From(2017-01-01) To(2017-12-31)');
    invalidDefinitions.add('Random Type(Email)');
    invalidDefinitions.add('Random Type(Phone) Format(30 210 dD DD ddD)');
    invalidDefinitions.add('Random Type(FirstName) Group(one)');
    invalidDefinitions.add('Random Type(LastName) Group(one)');
    invalidDefinitions.add('Random Type(List) Value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
    invalidDefinitions.add('Random Type(List) Value(2017-01-01, 2017-02-02, 2017-03-03)');
    invalidDefinitions.add('Random Type(List) Value(One, Two, Three)');
    invalidDefinitions.add('Random Type(Picklist) Except(One,Two)');
    invalidDefinitions.add('Random Type(Picklist)');
    invalidDefinitions.add('Random Type(Postalcode) Group(one)');
    invalidDefinitions.add('Random Type(State) Group(one)');
    invalidDefinitions.add('Random Type(Street) Group(one)');
    invalidDefinitions.add('Random Type(String) Minlength(10) Maxlength(30) Startwith(Lower) Include(Lower,Upper,Digit)');
    invalidDefinitions.add('Random Type(Text) Minlength(10) Maxlength(30)');
    invalidDefinitions.add('Random Type(Url)');
    invalidDefinitions.add('Serial Type(Date) From(2017-01-01) Step(2)');
    invalidDefinitions.add('Serial Type(Datetime) From(2017-01-01 02:02:02) Step(2.2)');
    invalidDefinitions.add('Static Lookup(Account) Field(FieldOne) Value(One) Source(Forceea)');
    invalidDefinitions.add('Static Value(01:01:01)');
    invalidDefinitions.add('Static Value(2017-01-01 01:01:01)');
    invalidDefinitions.add('Static Value(2017-01-01)');
    invalidDefinitions.add('Static Value(One)');

    Test.startTest();
    Boolean expectedResult = false;
    Boolean actualResult = checkMultipleDefinitions(
      new FObject('FObjectOne__c'), fieldApiname, validDefinitions, invalidDefinitions);
    Test.stopTest();

    System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
  }

  @IsTest
  private static void definitionIsValidForFieldDataType_email_expectFailure() {
    String fieldApiName = 'TestEmail__c';

    List<String> validDefinitions = new List<String>();
    validDefinitions.add('Copy Field(TestPicklistD__c)');
    validDefinitions.add('Copy Field(TestLookup__c) From(FObjectTwo__c.TestText__c)');
    validDefinitions.add('Random Type(Boolean)');
    validDefinitions.add('Random Type(Email)');
    validDefinitions.add('Random Type(List) Value(1, 2, 3)');
    validDefinitions.add('Random Type(List) Value(One, Two, Three)');
    validDefinitions.add('Random Type(Number) From(1) To(100) Scale(0)');
    validDefinitions.add('Random Type(String) Minlength(10) Maxlength(30) Startwith(Lower) Include(Lower,Upper,Digit)');
    validDefinitions.add('Serial Type(Number) From(10.2) Step(1.2) Scale(2)');
    validDefinitions.add('Static Value(10)');
    validDefinitions.add('Static Value(One)');
    List<String> invalidDefinitions = new List<String>();
    invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Except(One,Two,Three) Source(Forceea)');
    invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Value(One,Two,Three) Source(Forceea)');
    invalidDefinitions.add('Random Lookup(Account) Source(Forceea)');
    invalidDefinitions.add('Random lookup(Account) Where(Rating = \'Hot\') source(salesforce)');
    invalidDefinitions.add('Random Type(City) Group(one)');
    invalidDefinitions.add('Random Type(Country) Group(one)');
    invalidDefinitions.add('Random Type(Date) From(2017-01-01) To(2017-12-31)');
    invalidDefinitions.add('Random Type(Datetime) From(2017-01-01) To(2017-12-31)');
    invalidDefinitions.add('Random Type(Phone) Format(30 210 dD DD ddD)');
    invalidDefinitions.add('Random Type(FirstName) Group(one)');
    invalidDefinitions.add('Random Type(LastName) Group(one)');
    invalidDefinitions.add('Random Type(List) Value(1.1, 2.2, 3.3)');
    invalidDefinitions.add('Random Type(List) Value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
    invalidDefinitions.add('Random Type(List) Value(2017-01-01, 2017-02-02, 2017-03-03)');
    invalidDefinitions.add('Random Type(Picklist) Except(One,Two)');
    invalidDefinitions.add('Random Type(Picklist)');
    invalidDefinitions.add('Random Type(Postalcode) Group(one)');
    invalidDefinitions.add('Random Type(State) Group(one)');
    invalidDefinitions.add('Random Type(Street) Group(one)');
    invalidDefinitions.add('Random Type(Text) Minlength(10) Maxlength(30)');
    invalidDefinitions.add('Random Type(Url)');
    invalidDefinitions.add('Serial Type(Date) From(2017-01-01) Step(2)');
    invalidDefinitions.add('Serial Type(Datetime) From(2017-01-01 02:02:02) Step(2.2)');
    invalidDefinitions.add('Static Lookup(Account) Field(FieldOne) Value(One) Source(Forceea)');
    invalidDefinitions.add('Static Value(01:01:01)');
    invalidDefinitions.add('Static Value(10.1)');
    invalidDefinitions.add('Static Value(2017-01-01 01:01:01)');
    invalidDefinitions.add('Static Value(2017-01-01)');

    Test.startTest();
    Boolean expectedResult = false;
    Boolean actualResult = checkMultipleDefinitions(
      new FObject('FObjectOne__c'), fieldApiname, validDefinitions, invalidDefinitions);
    Test.stopTest();

    System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
  }

  @IsTest
  private static void definitionIsValidForFieldDataType_multiPicklist_expectFailure() {
    String fieldApiName = 'TestMultiPicklistA__c';

    List<String> validDefinitions = new List<String>();
    validDefinitions.add('Copy Field(TestPicklistD__c)');
    validDefinitions.add('Copy Field(TestLookup__c) From(FObjectTwo__c.TestText__c)');
    validDefinitions.add('Random Type(Boolean)');
    validDefinitions.add('Random Type(City) Group(one)');
    validDefinitions.add('Random Type(Country) Group(one)');
    validDefinitions.add('Random Type(Date) From(2017-01-01) To(2017-12-31)');
    validDefinitions.add('Random Type(Datetime) From(2017-01-01) To(2017-12-31)');
    validDefinitions.add('Random Type(Email)');
    validDefinitions.add('Random Type(Phone) Format(30 210 dD DD ddD)');
    validDefinitions.add('Random Type(FirstName) Group(one)');
    validDefinitions.add('Random Type(LastName) Group(one)');
    validDefinitions.add('Random Type(List) Value(1, 2, 3)');
    validDefinitions.add('Random Type(List) Value(1.1, 2.2, 3.3)');
    validDefinitions.add('Random Type(List) Value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
    validDefinitions.add('Random Type(List) Value(2017-01-01, 2017-02-02, 2017-03-03)');
    validDefinitions.add('Random Type(List) Value(One, Two, Three)');
    validDefinitions.add('random type(picklist) except(One,Two)');
    validDefinitions.add('Random Type(Picklist)');
    validDefinitions.add('Random Type(Postalcode) Group(one)');
    validDefinitions.add('Random Type(State) Group(one)');
    validDefinitions.add('Random Type(Street) Group(one)');
    validDefinitions.add('Random Type(String) Minlength(10) Maxlength(30) Startwith(Lower) Include(Lower,Upper,Digit)');
    validDefinitions.add('Random Type(Text) Minlength(10) Maxlength(30)');
    validDefinitions.add('Random Type(Url)');
    validDefinitions.add('Serial Type(Date) From(2017-01-01) Step(2)');
    validDefinitions.add('Serial Type(Datetime) From(2017-01-01 02:02:02) Step(2.2)');
    validDefinitions.add('Serial Type(Number) From(10.2) Step(1.2) Scale(2)');
    validDefinitions.add('Static Value(01:01:01)');
    validDefinitions.add('Static Value(10.1)');
    validDefinitions.add('Static Value(10)');
    validDefinitions.add('Static Value(2017-01-01 01:01:01)');
    validDefinitions.add('Static Value(2017-01-01)');
    validDefinitions.add('Static Value(One)');
    validDefinitions.add('Random Type(Number) From(1) To(100) Scale(0)');
    List<String> invalidDefinitions = new List<String>();
    invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Except(One,Two,Three) Source(Forceea)');
    invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Value(One,Two,Three) Source(Forceea)');
    invalidDefinitions.add('Random Lookup(Account) Source(Forceea)');
    invalidDefinitions.add('Random Lookup(Account) Where(Rating = \'Hot\') source(salesforce)');
    invalidDefinitions.add('Static Lookup(Account) Field(FieldOne) Value(One) Source(Forceea)');

    Test.startTest();
    Boolean expectedResult = false;
    Boolean actualResult = checkMultipleDefinitions(
      new FObject('FObjectOne__c'), fieldApiname, validDefinitions, invalidDefinitions);
    Test.stopTest();

    System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
  }

  @IsTest
  private static void definitionIsValidForFieldDataType_percent_expectFailure() {
    String fieldApiName = 'TestPercent__c';

    List<String> validDefinitions = new List<String>();
    validDefinitions.add('Copy Field(TestPicklistD__c)');
    validDefinitions.add('Copy Field(TestLookup__c) From(FObjectTwo__c.TestText__c)');
    validDefinitions.add('Random Type(List) Value(1, 2, 3)');
    validDefinitions.add('Random Type(List) Value(1.1, 2.2, 3.3)');
    validDefinitions.add('Random Type(Number) From(1) To(100) Scale(0)');
    validDefinitions.add('Serial Type(Number) From(10.2) Step(1.2) Scale(2)');
    validDefinitions.add('Static Value(10.1)');
    List<String> invalidDefinitions = new List<String>();
    invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Except(One,Two,Three) Source(Forceea)');
    invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Value(One,Two,Three) Source(Forceea)');
    invalidDefinitions.add('Random Lookup(Account) Source(Forceea)');
    invalidDefinitions.add('Random lookup(Account) Where(Rating = \'Hot\') source(salesforce)');
    invalidDefinitions.add('Random Type(Boolean)');
    invalidDefinitions.add('Random Type(City) Group(one)');
    invalidDefinitions.add('Random Type(Country) Group(one)');
    invalidDefinitions.add('Random Type(Date) From(2017-01-01) To(2017-12-31)');
    invalidDefinitions.add('Random Type(Datetime) From(2017-01-01) To(2017-12-31)');
    invalidDefinitions.add('Random Type(Email)');
    invalidDefinitions.add('Random Type(Phone) Format(30 210 dD DD ddD)');
    invalidDefinitions.add('Random Type(FirstName) Group(one)');
    invalidDefinitions.add('Random Type(LastName) Group(one)');
    invalidDefinitions.add('Random Type(List) Value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
    invalidDefinitions.add('Random Type(List) Value(2017-01-01, 2017-02-02, 2017-03-03)');
    invalidDefinitions.add('Random Type(List) Value(One, Two, Three)');
    invalidDefinitions.add('Random Type(Picklist) Except(One,Two)');
    invalidDefinitions.add('Random Type(Picklist)');
    invalidDefinitions.add('Random Type(Postalcode) Group(one)');
    invalidDefinitions.add('Random Type(State) Group(one)');
    invalidDefinitions.add('Random Type(Street) Group(one)');
    invalidDefinitions.add('Random Type(String) Minlength(10) Maxlength(30) Startwith(Lower) Include(Lower,Upper,Digit)');
    invalidDefinitions.add('Random Type(Text) Minlength(10) Maxlength(30)');
    invalidDefinitions.add('Random Type(Url)');
    invalidDefinitions.add('Serial Type(Date) From(2017-01-01) Step(2)');
    invalidDefinitions.add('Serial Type(Datetime) From(2017-01-01 02:02:02) Step(2.2)');
    invalidDefinitions.add('Static Lookup(Account) Field(FieldOne) Value(One) Source(Forceea)');
    invalidDefinitions.add('Static Value(01:01:01)');
    invalidDefinitions.add('Static Value(10)');
    invalidDefinitions.add('Static Value(2017-01-01 01:01:01)');
    invalidDefinitions.add('Static Value(2017-01-01)');
    invalidDefinitions.add('Static Value(One)');

    Test.startTest();
    Boolean expectedResult = false;
    Boolean actualResult = checkMultipleDefinitions(
      new FObject('FObjectOne__c'), fieldApiname, validDefinitions, invalidDefinitions);
    Test.stopTest();

    System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
  }

  @IsTest
  private static void definitionIsValidForFieldDataType_picklist_expectFailure() {
    String fieldApiName = 'TestPicklistC__c';

    List<String> validDefinitions = new List<String>();
    validDefinitions.add('Copy Field(TestPicklistD__c)');
    validDefinitions.add('Copy Field(TestLookup__c) From(FObjectTwo__c.TestText__c)');
    validDefinitions.add('Random Type(Boolean)');
    validDefinitions.add('Random Type(City) Group(one)');
    validDefinitions.add('Random Type(Country) Group(one)');
    validDefinitions.add('Random Type(Date) From(2017-01-01) To(2017-12-31)');
    validDefinitions.add('Random Type(Datetime) From(2017-01-01) To(2017-12-31)');
    validDefinitions.add('Random Type(Email)');
    validDefinitions.add('Random Type(Phone) Format(30 210 dD DD ddD)');
    validDefinitions.add('Random Type(FirstName) Group(one)');
    validDefinitions.add('Random Type(LastName) Group(one)');
    validDefinitions.add('Random Type(List) Value(1, 2, 3)');
    validDefinitions.add('Random Type(List) Value(1.1, 2.2, 3.3)');
    validDefinitions.add('Random Type(List) Value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
    validDefinitions.add('Random Type(List) Value(2017-01-01, 2017-02-02, 2017-03-03)');
    validDefinitions.add('Random Type(List) Value(One, Two, Three)');
    validDefinitions.add('Random Type(Number) From(1) To(100) Scale(0)');
    validDefinitions.add('random type(picklist) except(One,Two)');
    validDefinitions.add('Random Type(Picklist)');
    validDefinitions.add('Random Type(Postalcode) Group(one)');
    validDefinitions.add('Random Type(State) Group(one)');
    validDefinitions.add('Random Type(Street) Group(one)');
    validDefinitions.add('Random Type(String) Minlength(10) Maxlength(30) Startwith(Lower) Include(Lower,Upper,Digit)');
    validDefinitions.add('Random Type(Text) Minlength(10) Maxlength(30)');
    validDefinitions.add('Random Type(Url)');
    validDefinitions.add('Serial Type(Date) From(2017-01-01) Step(2)');
    validDefinitions.add('Serial Type(Datetime) From(2017-01-01 02:02:02) Step(2.2)');
    validDefinitions.add('Serial Type(Number) From(10.2) Step(1.2) Scale(2)');
    validDefinitions.add('Static Value(01:01:01)');
    validDefinitions.add('Static Value(10.1)');
    validDefinitions.add('Static Value(10)');
    validDefinitions.add('Static Value(2017-01-01 01:01:01)');
    validDefinitions.add('Static Value(2017-01-01)');
    validDefinitions.add('Static Value(One)');
    List<String> invalidDefinitions = new List<String>();
    invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Except(One,Two,Three) Source(Forceea)');
    invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Value(One,Two,Three) Source(Forceea)');
    invalidDefinitions.add('Random Lookup(Account) Source(Forceea)');
    invalidDefinitions.add('Random Lookup(Account) Where(Rating = \'Hot\') source(salesforce)');
    invalidDefinitions.add('Static Lookup(Account) Field(FieldOne) Value(One) Source(Forceea)');

    Test.startTest();
    Boolean expectedResult = false;
    Boolean actualResult = checkMultipleDefinitions(
      new FObject('FObjectOne__c'), fieldApiname, validDefinitions, invalidDefinitions);
    Test.stopTest();

    System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
  }

  @IsTest
  private static void definitionIsValidForFieldDataType_phone_expectFailure() {
    String fieldApiName = 'TestPhone__c';

    List<String> validDefinitions = new List<String>();
    validDefinitions.add('Copy Field(TestPicklistD__c)');
    validDefinitions.add('Copy Field(TestLookup__c) From(FObjectTwo__c.TestText__c)');
    validDefinitions.add('Random Type(Phone) Format(30 210 dD DD ddD)');
    validDefinitions.add('Random Type(List) Value(One, Two, Three)');
    validDefinitions.add('Random Type(Number) From(1) To(100) Scale(0)');
    validDefinitions.add('Serial Type(Number) From(10.2) Step(1.2) Scale(2)');
    validDefinitions.add('Static Value(10)');
    validDefinitions.add('Static Value(One)');
    List<String> invalidDefinitions = new List<String>();
    invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Except(One,Two,Three) Source(Forceea)');
    invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Value(One,Two,Three) Source(Forceea)');
    invalidDefinitions.add('Random Lookup(Account) Source(Forceea)');
    invalidDefinitions.add('Random lookup(Account) Where(Rating = \'Hot\') source(salesforce)');
    invalidDefinitions.add('Random Type(Boolean)');
    invalidDefinitions.add('Random Type(City) Group(one)');
    invalidDefinitions.add('Random Type(Country) Group(one)');
    invalidDefinitions.add('Random Type(Date) From(2017-01-01) To(2017-12-31)');
    invalidDefinitions.add('Random Type(Datetime) From(2017-01-01) To(2017-12-31)');
    invalidDefinitions.add('Random Type(Email)');
    invalidDefinitions.add('Random Type(FirstName) Group(one)');
    invalidDefinitions.add('Random Type(LastName) Group(one)');
    invalidDefinitions.add('Random Type(List) Value(1, 2, 3)');
    invalidDefinitions.add('Random Type(List) Value(1.1, 2.2, 3.3)');
    invalidDefinitions.add('Random Type(List) Value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
    invalidDefinitions.add('Random Type(List) Value(2017-01-01, 2017-02-02, 2017-03-03)');
    invalidDefinitions.add('Random Type(Picklist) Except(One,Two)');
    invalidDefinitions.add('Random Type(Picklist)');
    invalidDefinitions.add('Random Type(Postalcode) Group(one)');
    invalidDefinitions.add('Random Type(State) Group(one)');
    invalidDefinitions.add('Random Type(Street) Group(one)');
    invalidDefinitions.add('Random Type(String) Minlength(10) Maxlength(30) Startwith(Lower) Include(Lower,Upper,Digit)');
    invalidDefinitions.add('Random Type(Text) Minlength(10) Maxlength(30)');
    invalidDefinitions.add('Random Type(Url)');
    invalidDefinitions.add('Serial Type(Date) From(2017-01-01) Step(2)');
    invalidDefinitions.add('Serial Type(Datetime) From(2017-01-01 02:02:02) Step(2.2)');
    invalidDefinitions.add('Static Lookup(Account) Field(FieldOne) Value(One) Source(Forceea)');
    invalidDefinitions.add('Static Value(01:01:01)');
    invalidDefinitions.add('Static Value(10.1)');
    invalidDefinitions.add('Static Value(2017-01-01 01:01:01)');
    invalidDefinitions.add('Static Value(2017-01-01)');

    Test.startTest();
    Boolean expectedResult = false;
    Boolean actualResult = checkMultipleDefinitions(
      new FObject('FObjectOne__c'), fieldApiname, validDefinitions, invalidDefinitions);
    Test.stopTest();

    System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
  }

  @IsTest
  private static void definitionIsValidForFieldDataType_recordType_expectFailure() {
    String fieldApiName = 'RecordTypeId';

    List<String> validDefinitions = new List<String>();
    validDefinitions.add('Random Type(List) Value(One, Two, Three)');
    validDefinitions.add('random type(picklist) except(One,Two)');
    validDefinitions.add('Random Type(Picklist)');
    validDefinitions.add('Static Value(One)');
    List<String> invalidDefinitions = new List<String>();
    invalidDefinitions.add('Copy Field(TestPicklistD__c)');
    invalidDefinitions.add('Copy Field(TestLookup__c) From(FObjectTwo__c.TestText__c)');
    invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Except(One,Two,Three) Source(Forceea)');
    invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Value(One,Two,Three) Source(Forceea)');
    invalidDefinitions.add('Random Lookup(Account) Source(Forceea)');
    invalidDefinitions.add('Random lookup(Account) Where(Rating = \'Hot\') source(salesforce)');
    invalidDefinitions.add('Random Type(Boolean)');
    invalidDefinitions.add('Random Type(City) Group(one)');
    invalidDefinitions.add('Random Type(Country) Group(one)');
    invalidDefinitions.add('Random Type(Date) From(2017-01-01) To(2017-12-31)');
    invalidDefinitions.add('Random Type(Datetime) From(2017-01-01) To(2017-12-31)');
    invalidDefinitions.add('Random Type(Email)');
    invalidDefinitions.add('Random Type(Phone) Format(30 210 dD DD ddD)');
    invalidDefinitions.add('Random Type(FirstName) Group(one)');
    invalidDefinitions.add('Random Type(LastName) Group(one)');
    invalidDefinitions.add('Random Type(List) Value(1, 2, 3)');
    invalidDefinitions.add('Random Type(List) Value(1.1, 2.2, 3.3)');
    invalidDefinitions.add('Random Type(List) Value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
    invalidDefinitions.add('Random Type(List) Value(2017-01-01, 2017-02-02, 2017-03-03)');
    invalidDefinitions.add('Random Type(Number) From(1) To(100) Scale(0)');
    invalidDefinitions.add('Random Type(Postalcode) Group(one)');
    invalidDefinitions.add('Random Type(State) Group(one)');
    invalidDefinitions.add('Random Type(Street) Group(one)');
    invalidDefinitions.add('Random Type(String) Minlength(10) Maxlength(30) Startwith(Lower) Include(Lower,Upper,Digit)');
    invalidDefinitions.add('Random Type(Text) Minlength(10) Maxlength(30)');
    invalidDefinitions.add('Random Type(Url)');
    invalidDefinitions.add('Serial Type(Date) From(2017-01-01) Step(2)');
    invalidDefinitions.add('Serial Type(Datetime) From(2017-01-01 02:02:02) Step(2.2)');
    invalidDefinitions.add('Serial Type(Number) From(10.2) Step(1.2) Scale(2)');
    invalidDefinitions.add('Static Lookup(Account) Field(FieldOne) Value(One) Source(Forceea)');
    invalidDefinitions.add('Static Value(01:01:01)');
    invalidDefinitions.add('Static Value(10.1)');
    invalidDefinitions.add('Static Value(10)');
    invalidDefinitions.add('Static Value(2017-01-01 01:01:01)');
    invalidDefinitions.add('Static Value(2017-01-01)');

    Test.startTest();
    Boolean expectedResult = false;
    Boolean actualResult = checkMultipleDefinitions(
      new FObject('FObjectOne__c'), fieldApiname, validDefinitions, invalidDefinitions);
    Test.stopTest();

    System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
  }

  @IsTest
  private static void definitionIsValidForFieldDataType_reference_expectFailure() {
    String fieldApiName = 'TestLookup__c';

    List<String> validDefinitions = new List<String>();
    validDefinitions.add('Random Lookup(Account) Field(FieldOne) Except(One,Two,Three) Source(Forceea)');
    validDefinitions.add('Random Lookup(Account) Field(FieldOne) Value(One,Two,Three) Source(Forceea)');
    validDefinitions.add('Random Lookup(Account) Source(Forceea)');
    validDefinitions.add('Random lookup(Account) Where(Rating = \'Hot\') source(salesforce)');
    validDefinitions.add('Static Lookup(Account) Field(FieldOne) Value(One) Source(Forceea)');
    List<String> invalidDefinitions = new List<String>();
    invalidDefinitions.add('Copy Field(TestPicklistD__c)');
    invalidDefinitions.add('Copy Field(TestLookup__c) From(FObjectTwo__c.TestText__c)');
    invalidDefinitions.add('Random Type(Boolean)');
    invalidDefinitions.add('Random Type(City) Group(one)');
    invalidDefinitions.add('Random Type(Country) Group(one)');
    invalidDefinitions.add('Random Type(Date) From(2017-01-01) To(2017-12-31)');
    invalidDefinitions.add('Random Type(Datetime) From(2017-01-01) To(2017-12-31)');
    invalidDefinitions.add('Random Type(Email)');
    invalidDefinitions.add('Random Type(Phone) Format(30 210 dD DD ddD)');
    invalidDefinitions.add('Random Type(FirstName) Group(one)');
    invalidDefinitions.add('Random Type(LastName) Group(one)');
    invalidDefinitions.add('Random Type(List) Value(1, 2, 3)');
    invalidDefinitions.add('Random Type(List) Value(1.1, 2.2, 3.3)');
    invalidDefinitions.add('Random Type(List) Value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
    invalidDefinitions.add('Random Type(List) Value(2017-01-01, 2017-02-02, 2017-03-03)');
    invalidDefinitions.add('Random Type(List) Value(One, Two, Three)');
    invalidDefinitions.add('Random Type(Number) From(1) To(100) Scale(0)');
    invalidDefinitions.add('Random Type(Picklist) Except(One,Two)');
    invalidDefinitions.add('Random Type(Picklist)');
    invalidDefinitions.add('Random Type(Postalcode) Group(one)');
    invalidDefinitions.add('Random Type(State) Group(one)');
    invalidDefinitions.add('Random Type(Street) Group(one)');
    invalidDefinitions.add('Random Type(String) Minlength(10) Maxlength(30) Startwith(Lower) Include(Lower,Upper,Digit)');
    invalidDefinitions.add('Random Type(Text) Minlength(10) Maxlength(30)');
    invalidDefinitions.add('Random Type(Url)');
    invalidDefinitions.add('Serial Type(Date) From(2017-01-01) Step(2)');
    invalidDefinitions.add('Serial Type(Datetime) From(2017-01-01 02:02:02) Step(2.2)');
    invalidDefinitions.add('Serial Type(Number) From(10.2) Step(1.2) Scale(2)');
    invalidDefinitions.add('Static Value(01:01:01)');
    invalidDefinitions.add('Static Value(10.1)');
    invalidDefinitions.add('Static Value(10)');
    invalidDefinitions.add('Static Value(2017-01-01 01:01:01)');
    invalidDefinitions.add('Static Value(2017-01-01)');
    invalidDefinitions.add('Static Value(One)');

    Test.startTest();
    Boolean expectedResult = false;
    Boolean actualResult = checkMultipleDefinitions(
      new FObject('FObjectOne__c'), fieldApiname, validDefinitions, invalidDefinitions);
    Test.stopTest();

    System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
  }

  @IsTest
  private static void definitionIsValidForFieldDataType_string_expectFailure() {
    String fieldApiName = 'TestText__c';

    List<String> validDefinitions = new List<String>();
    validDefinitions.add('Copy Field(TestPicklistD__c)');
    validDefinitions.add('Copy Field(TestLookup__c) From(FObjectTwo__c.TestText__c)');
    validDefinitions.add('Random Type(Boolean)');
    validDefinitions.add('Random Type(City) Group(one)');
    validDefinitions.add('Random Type(Country) Group(one)');
    validDefinitions.add('Random Type(Date) From(2017-01-01) To(2017-12-31)');
    validDefinitions.add('Random Type(Datetime) From(2017-01-01) To(2017-12-31)');
    validDefinitions.add('Random Type(Email)');
    validDefinitions.add('Random Type(Phone) Format(30 210 dD DD ddD)');
    validDefinitions.add('Random Type(FirstName) Group(one)');
    validDefinitions.add('Random Type(LastName) Group(one)');
    validDefinitions.add('Random Type(List) Value(1, 2, 3)');
    validDefinitions.add('Random Type(List) Value(1.1, 2.2, 3.3)');
    validDefinitions.add('Random Type(List) Value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
    validDefinitions.add('Random Type(List) Value(2017-01-01, 2017-02-02, 2017-03-03)');
    validDefinitions.add('Random Type(List) Value(One, Two, Three)');
    validDefinitions.add('Random Type(Number) From(1) To(100) Scale(0)');
    validDefinitions.add('Random Type(Postalcode) Group(one)');
    validDefinitions.add('Random Type(State) Group(one)');
    validDefinitions.add('Random Type(Street) Group(one)');
    validDefinitions.add('Random Type(String) Minlength(10) Maxlength(30) Startwith(Lower) Include(Lower,Upper,Digit)');
    validDefinitions.add('Random Type(Text) Minlength(10) Maxlength(30)');
    validDefinitions.add('Random Type(Url)');
    validDefinitions.add('Serial Type(Date) From(2017-01-01) Step(2)');
    validDefinitions.add('Serial Type(Datetime) From(2017-01-01 02:02:02) Step(2.2)');
    validDefinitions.add('Serial Type(Number) From(10.2) Step(1.2) Scale(2)');
    validDefinitions.add('Static Value(01:01:01)');
    validDefinitions.add('Static Value(10.1)');
    validDefinitions.add('Static Value(10)');
    validDefinitions.add('Static Value(2017-01-01 01:01:01)');
    validDefinitions.add('Static Value(2017-01-01)');
    validDefinitions.add('Static Value(One)');
    List<String> invalidDefinitions = new List<String>();
    invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Except(One,Two,Three) Source(Forceea)');
    invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Value(One,Two,Three) Source(Forceea)');
    invalidDefinitions.add('Random Lookup(Account) Source(Forceea)');
    invalidDefinitions.add('Random lookup(Account) Where(Rating = \'Hot\') source(salesforce)');
    invalidDefinitions.add('Random Type(Picklist) Except(One,Two)');
    invalidDefinitions.add('Random Type(Picklist)');
    invalidDefinitions.add('Static Lookup(Account) Field(FieldOne) Value(One) Source(Forceea)');

    Test.startTest();
    Boolean expectedResult = false;
    Boolean actualResult = checkMultipleDefinitions(
      new FObject('FObjectOne__c'), fieldApiname, validDefinitions, invalidDefinitions);
    Test.stopTest();

    System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
  }

  @IsTest
  private static void definitionIsValidForFieldDataType_textArea_expectFailure() {
    String fieldApiName = 'TestText__c';
    List<String> validDefinitions = new List<String>();
    validDefinitions.add('Copy Field(TestPicklistD__c)');
    validDefinitions.add('Copy Field(TestLookup__c) From(FObjectTwo__c.TestText__c)');
    validDefinitions.add('Random Type(Boolean)');
    validDefinitions.add('Random Type(City) Group(one)');
    validDefinitions.add('Random Type(Country) Group(one)');
    validDefinitions.add('Random Type(Date) From(2017-01-01) To(2017-12-31)');
    validDefinitions.add('Random Type(Datetime) From(2017-01-01) To(2017-12-31)');
    validDefinitions.add('Random Type(Email)');
    validDefinitions.add('Random Type(Phone) Format(30 210 dD DD ddD)');
    validDefinitions.add('Random Type(FirstName) Group(one)');
    validDefinitions.add('Random Type(LastName) Group(one)');
    validDefinitions.add('Random Type(List) Value(1, 2, 3)');
    validDefinitions.add('Random Type(List) Value(1.1, 2.2, 3.3)');
    validDefinitions.add('Random Type(List) Value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
    validDefinitions.add('Random Type(List) Value(2017-01-01, 2017-02-02, 2017-03-03)');
    validDefinitions.add('Random Type(List) Value(One, Two, Three)');
    validDefinitions.add('Random Type(Number) From(1) To(100) Scale(0)');
    validDefinitions.add('Random Type(Postalcode) Group(one)');
    validDefinitions.add('Random Type(State) Group(one)');
    validDefinitions.add('Random Type(Street) Group(one)');
    validDefinitions.add('Random Type(String) Minlength(10) Maxlength(30) Startwith(Lower) Include(Lower,Upper,Digit)');
    validDefinitions.add('Random Type(Text) Minlength(10) Maxlength(30)');
    validDefinitions.add('Random Type(Url)');
    validDefinitions.add('Serial Type(Date) From(2017-01-01) Step(2)');
    validDefinitions.add('Serial Type(Datetime) From(2017-01-01 02:02:02) Step(2.2)');
    validDefinitions.add('Serial Type(Number) From(10.2) Step(1.2) Scale(2)');
    validDefinitions.add('Static Value(01:01:01)');
    validDefinitions.add('Static Value(10.1)');
    validDefinitions.add('Static Value(10)');
    validDefinitions.add('Static Value(2017-01-01 01:01:01)');
    validDefinitions.add('Static Value(2017-01-01)');
    validDefinitions.add('Static Value(One)');
    List<String> invalidDefinitions = new List<String>();
    invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Except(One,Two,Three) Source(Forceea)');
    invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Value(One,Two,Three) Source(Forceea)');
    invalidDefinitions.add('Random Lookup(Account) Source(Forceea)');
    invalidDefinitions.add('Random lookup(Account) Where(Rating = \'Hot\') source(salesforce)');
    invalidDefinitions.add('Random Type(Picklist) Except(One,Two)');
    invalidDefinitions.add('Random Type(Picklist)');
    invalidDefinitions.add('Static Lookup(Account) Field(FieldOne) Value(One) Source(Forceea)');

    Test.startTest();
    Boolean expectedResult = false;
    Boolean actualResult = checkMultipleDefinitions(
      new FObject('FObjectOne__c'), fieldApiname, validDefinitions, invalidDefinitions);
    Test.stopTest();

    System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
  }

  @IsTest
  private static void definitionIsValidForFieldDataType_time_expectSuccess() {
    String fieldApiName = 'TestTime__c';

    List<String> validDefinitions = new List<String>();
    validDefinitions.add('Static Value(01:01:01)');
    validDefinitions.add('Random Type(List) Value(01:01:01, 02:02:02, 03:03:03)');
    validDefinitions.add('Copy Field(TestPicklistD__c)');

    List<String> invalidDefinitions = new List<String>();
    invalidDefinitions.add('Copy Field(TestLookup__c) From(FObjectTwo__c.TestText__c)');
    invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Except(One,Two,Three) Source(Forceea)');
    invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Value(One,Two,Three) Source(Forceea)');
    invalidDefinitions.add('Random Lookup(Account) Source(Forceea)');
    invalidDefinitions.add('Random lookup(Account) Where(Rating = \'Hot\') source(salesforce)');
    invalidDefinitions.add('Random Type(Boolean)');
    invalidDefinitions.add('Random Type(City) Group(one)');
    invalidDefinitions.add('Random Type(Country) Group(one)');
    invalidDefinitions.add('Random Type(Date) From(2017-01-01) To(2017-12-31)');
    invalidDefinitions.add('Random Type(Datetime) From(2017-01-01) To(2017-12-31)');
    invalidDefinitions.add('Random Type(Email)');
    invalidDefinitions.add('Random Type(Phone) Format(30 210 dD DD ddD)');
    invalidDefinitions.add('Random Type(FirstName) Group(one)');
    invalidDefinitions.add('Random Type(LastName) Group(one)');
    invalidDefinitions.add('Random Type(List) Value(1, 2, 3)');
    invalidDefinitions.add('Random Type(List) Value(1.1, 2.2, 3.3)');
    invalidDefinitions.add('Random Type(List) Value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
    invalidDefinitions.add('Random Type(List) Value(2017-01-01, 2017-02-02, 2017-03-03)');
    invalidDefinitions.add('Random Type(List) Value(One, Two, Three)');
    invalidDefinitions.add('Random Type(Number) From(1) To(100) Scale(0)');
    invalidDefinitions.add('Random Type(Picklist) Except(One,Two)');
    invalidDefinitions.add('Random Type(Picklist)');
    invalidDefinitions.add('Random Type(Postalcode) Group(one)');
    invalidDefinitions.add('Random Type(State) Group(one)');
    invalidDefinitions.add('Random Type(Street) Group(one)');
    invalidDefinitions.add('Random Type(String) Minlength(10) Maxlength(30) Startwith(Lower) Include(Lower,Upper,Digit)');
    invalidDefinitions.add('Random Type(Text) Minlength(10) Maxlength(30)');
    invalidDefinitions.add('Random Type(Url)');
    invalidDefinitions.add('Serial Type(Date) From(2017-01-01) Step(2)');
    invalidDefinitions.add('Serial Type(Datetime) From(2017-01-01 02:02:02) Step(2.2)');
    invalidDefinitions.add('Serial Type(Number) From(10.2) Step(1.2) Scale(2)');
    invalidDefinitions.add('Static Lookup(Account) Field(FieldOne) Value(One) Source(Forceea)');
    invalidDefinitions.add('Static Value(10.1)');
    invalidDefinitions.add('Static Value(10)');
    invalidDefinitions.add('Static Value(2017-01-01 01:01:01)');
    invalidDefinitions.add('Static Value(2017-01-01)');
    invalidDefinitions.add('Static Value(One)');

    Test.startTest();
    Boolean expectedResult = false;
    Boolean actualResult = checkMultipleDefinitions(
      new FObject('FObjectOne__c'), fieldApiname, validDefinitions, invalidDefinitions);
    Test.stopTest();

    System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
  }

  @IsTest
  private static void definitionIsValidForFieldDataType_url_expectFailure() {
    String fieldApiName = 'TestUrl__c';

    List<String> validDefinitions = new List<String>();
    validDefinitions.add('Copy Field(TestPicklistD__c)');
    validDefinitions.add('Copy Field(TestLookup__c) From(FObjectTwo__c.TestText__c)');
    validDefinitions.add('Random Type(List) Value(1, 2, 3)');
    validDefinitions.add('Random Type(List) Value(One, Two, Three)');
    validDefinitions.add('Random Type(Number) From(1) To(100) Scale(0)');
    validDefinitions.add('Random Type(String) Minlength(10) Maxlength(30) Startwith(Lower) Include(Lower,Upper,Digit)');
    validDefinitions.add('Random Type(Url)');
    validDefinitions.add('Serial Type(Number) From(10.2) Step(1.2) Scale(2)');
    validDefinitions.add('Static Value(10)');
    validDefinitions.add('Static Value(One)');
    List<String> invalidDefinitions = new List<String>();
    invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Except(One,Two,Three) Source(Forceea)');
    invalidDefinitions.add('Random Lookup(Account) Field(FieldOne) Value(One,Two,Three) Source(Forceea)');
    invalidDefinitions.add('Random Lookup(Account) Source(Forceea)');
    invalidDefinitions.add('Random lookup(Account) Where(Rating = \'Hot\') source(salesforce)');
    invalidDefinitions.add('Random Type(Boolean)');
    invalidDefinitions.add('Random Type(City) Group(one)');
    invalidDefinitions.add('Random Type(Country) Group(one)');
    invalidDefinitions.add('Random Type(Date) From(2017-01-01) To(2017-12-31)');
    invalidDefinitions.add('Random Type(Datetime) From(2017-01-01) To(2017-12-31)');
    invalidDefinitions.add('Random Type(Email)');
    invalidDefinitions.add('Random Type(Phone) Format(30 210 dD DD ddD)');
    invalidDefinitions.add('Random Type(FirstName) Group(one)');
    invalidDefinitions.add('Random Type(LastName) Group(one)');
    invalidDefinitions.add('Random Type(List) Value(1.1, 2.2, 3.3)');
    invalidDefinitions.add('Random Type(List) Value(2017-01-01 01:01:01, 2017-02-02 02:02:02, 2017-03-03 03:03:03)');
    invalidDefinitions.add('Random Type(List) Value(2017-01-01, 2017-02-02, 2017-03-03)');
    invalidDefinitions.add('Random Type(Picklist) Except(One,Two)');
    invalidDefinitions.add('Random Type(Picklist)');
    invalidDefinitions.add('Random Type(Postalcode) Group(one)');
    invalidDefinitions.add('Random Type(State) Group(one)');
    invalidDefinitions.add('Random Type(Street) Group(one)');
    invalidDefinitions.add('Random Type(Text) Minlength(10) Maxlength(30)');
    invalidDefinitions.add('Serial Type(Date) From(2017-01-01) Step(2)');
    invalidDefinitions.add('Serial Type(Datetime) From(2017-01-01 02:02:02) Step(2.2)');
    invalidDefinitions.add('Static Lookup(Account) Field(FieldOne) Value(One) Source(Forceea)');
    invalidDefinitions.add('Static Value(01:01:01)');
    invalidDefinitions.add('Static Value(10.1)');
    invalidDefinitions.add('Static Value(2017-01-01 01:01:01)');
    invalidDefinitions.add('Static Value(2017-01-01)');

    Test.startTest();
    Boolean expectedResult = false;
    Boolean actualResult = checkMultipleDefinitions(
      new FObject('FObjectOne__c'), fieldApiname, validDefinitions, invalidDefinitions);
    Test.stopTest();

    System.assertEquals(expectedResult, actualResult, 'definitionIsValidForFieldDataType - errors found');
  }

  @IsTest
  private static void definitionIsValidForFieldDataType_valid_expectSucccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestCheckbox__c', 'Random Type(Boolean)');
    obj.setDefinition('TestCurrency__c', 'Random Type(Number) From(1) To(100) Scale(0)');
    obj.setDefinition('TestDate__c', 'Random Type(Date) From(2017-01-01) To(2017-12-31)');
    obj.setDefinition('TestDatetime__c', 'Random Type(Datetime) From(2017-01-01) To(2017-12-31)');
    obj.setDefinition('TestDecimal__c', 'Random Type(Number) From(1) To(100) Scale(0)');
    obj.setDefinition('TestEmail__c', 'Random Type(Email)');
    obj.setDefinition('TestLookup__c', 'Random lookup(FObjectTwo__c) source(Salesforce)');
    obj.setDefinition('TestMultiPicklistA__c', 'Random Type(Picklist)');
    obj.setDefinition('TestPercent__c', 'Random Type(Number) From(0) To(1) Scale(2)');
    obj.setDefinition('TestPhone__c', 'Random Type(Phone) Format(30 210 dD DD ddD)');
    obj.setDefinition('TestPicklistC__c', 'Random type(Picklist)');
    obj.setDefinition('TestText__c', 'Copy Field(TestPicklistC__c)');
    obj.setDefinition('TestText__c', 'Random Type(String) Minlength(10) Maxlength(30) Startwith(Lower) Include(Lower,Upper,Digit)');
    obj.setDefinition('TestTextArea__c', 'Random Type(String) Minlength(10) Maxlength(30) Startwith(Lower) Include(Lower,Upper,Digit)');
    obj.setDefinition('TestTextAreaLong__c', 'Random Type(String) Minlength(10) Maxlength(30) Startwith(Lower) Include(Lower,Upper,Digit)');
    obj.setDefinition('TestTextAreaRich__c', 'Random Type(String) Minlength(10) Maxlength(30) Startwith(Lower) Include(Lower,Upper,Digit)');
    obj.setDefinition('TestTime__c', 'Static value(02:02:02)');
    obj.setDefinition('TestUrl__c', 'Random Type(Url)');
    obj.insertRecords(true);
    Test.stopTest();

    System.assertEquals(true, obj.getErrors().isEmpty(), 'definitionIsValidForFieldDataType - errors found');
  }

  /* deleteAllDefinitions */

  @IsTest
  private static void deleteAllDefinitions_declareNoDefinitions_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.deleteAllDefinitions();
    Test.stopTest();

    System.assertEquals(true, obj.getAllDefinitions().isEmpty(), 'deleteAllDefinitions - errors found');
  }

  @IsTest
  private static void deleteAllDefinitions_declareSomeDefinitions_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestText__c', 'static value(TestName_)');
    obj.setDefinition('TestDecimal__c', 'random type(number) from(1) to(100) scale(0)');
    obj.setDefinition('TestPicklistA__c', 'random type(picklist)');
    obj.setDefinition('TestPicklistB__c', 'random type(picklist)');
    obj.deleteAllDefinitions();
    Test.stopTest();

    System.assertEquals(true, obj.getAllDefinitions().isEmpty(), 'deleteAllDefinitions - errors found');
  }

  @IsTest
  private static void deleteAllDefinitions_recordsAreClearedAfterNewDefinition_expectSuccess() {
    Test.startTest();

    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestText__c', 'static value(TestName_)');
    obj.setDefinition('TestText__c', 'random type(number) from(1) to(100) scale(0)');
    obj.setDefinition('TestPicklistA__c', 'random type(picklist)');
    obj.setDefinition('TestPicklistB__c', 'random type(picklist)');

    List<FObjectOne__c> objRecords1 = obj.getRecords();
    Integer hash1 = objRecords1.hashCode();

    obj.deleteAllDefinitions();

    obj.setDefinition('TestText__c', 'static value(TestName_)');
    obj.setDefinition('TestText__c', 'random type(number) from(1) to(100) scale(0)');
    obj.setDefinition('TestPicklistA__c', 'random type(picklist)');
    obj.setDefinition('TestPicklistB__c', 'random type(picklist)');

    List<FObjectOne__c> objRecords2 = obj.getRecords();
    Integer hash2 = objRecords2.hashCode();

    Test.stopTest();

    System.assertNotEquals(hash1, hash2, 'deleteAllDefinitions - errors found');
  }

  /* deleteFieldDefinitions */

  @IsTest
  private static void deleteFieldDefinitions_declareNoDefinitions_expectSuccess() {
    Test.startTest();

    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestDecimal__c', 'random type(number) from(1) to(100) scale(0)');
    obj.setDefinition('TestPicklistA__c', 'random type(picklist)');
    obj.setDefinition('TestPicklistB__c', 'random type(picklist)');
    obj.deleteFieldDefinitions('TestText__c');

    Test.stopTest();

    Boolean expectedResult = true;
    Boolean actualResult = obj.getFieldDefinitions('TestText__c').isEmpty();
    System.assertEquals(expectedResult, actualResult, 'deleteFieldDefinitions - errors found');
  }

  @IsTest
  private static void deleteFieldDefinitions_declareSomeDefinitions_expectSuccess() {
    Test.startTest();

    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestDecimal__c', 'random type(number) from(1) to(100) scale(0)');
    obj.setDefinition('TestText__c', 'static value(TestName_)');
    obj.setDefinition('TestText__c', 'random type(number) from(1) to(100) scale(0)');
    obj.setDefinition('TestPicklistA__c', 'random type(picklist)');
    obj.setDefinition('TestPicklistB__c', 'random type(picklist)');
    obj.deleteFieldDefinitions('TestText__c');

    Test.stopTest();

    Integer errors = 0;
    if (!obj.getFieldDefinitions('TestText__c').isEmpty()) {
      errors += 1;
    }
    if (obj.getFieldDefinitions('TestDecimal__c').size() != 1) {
      errors += 2;
    }
    if (obj.getFieldDefinitions('TestPicklistA__c').size() != 1) {
      errors += 4;
    }
    if (obj.getFieldDefinitions('TestPicklistB__c').size() != 1) {
      errors += 8;
    }
    System.assertEquals(0, errors, 'deleteFieldDefinitions - errors found');
  }

  @IsTest
  private static void deleteFieldDefinitions_invalidField_expectFailure() {
    Test.startTest();

    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestText__c', 'static value(TestName_)');
    obj.setDefinition('TestText__c', 'random type(number) from(1) to(100) scale(0)');
    obj.setDefinition('TestDecimal__c', 'random type(number) from(1) to(100) scale(0)');
    obj.deleteFieldDefinitions('TestTextX__c');

    Test.stopTest();

    System.assertEquals('Invalid field [TestTextX__c] in method deleteFieldDefinitions',
      obj.getErrors().get('FObjectOne__c').get(0),
      'deleteFieldDefinitions - wrong error message for invalid field');
  }

  @IsTest
  private static void deleteFieldDefinitions_recordsAreClearedAfterNewDefinition_expectSuccess() {
    Test.startTest();

    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestText__c', 'static value(TestName_)');
    obj.setDefinition('TestText__c', 'random type(number) from(1) to(100) scale(0)');
    obj.setDefinition('TestDecimal__c', 'random type(number) from(1) to(100) scale(0)');

    List<FObjectOne__c> objRecords1 = obj.getRecords();
    Integer hash1 = objRecords1.hashCode();

    obj.deleteFieldDefinitions('TestText__c');

    obj.setDefinition('TestText__c', 'static value(TestName_)');
    obj.setDefinition('TestText__c', 'random type(number) from(1) to(100) scale(0)');

    List<FObjectOne__c> objRecords2 = obj.getRecords();
    Integer hash2 = objRecords2.hashCode();

    Test.stopTest();

    System.assertNotEquals(hash1, hash2, 'deleteFieldDefinitions - errors found');
  }

  /* deleteRecords */

  @IsTest
  private static void deleteRecords_whereClauseIsBlank_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
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
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'deleteRecords - errors found');
  }

  @IsTest
  private static void deleteRecords_whereClauseIsValid_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
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
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'deleteRecords - errors found');
  }

  @IsTest
  private static void deleteRecords_recordGroup_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
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
    if (!FObject.processIsValid) {
      errors += 8;
    }
    System.assertEquals(0, errors, 'deleteRecords - errors found');
  }

  @IsTest
  private static void deleteRecords_noRecordsFound_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
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
    if (!FObject.processIsValid) {
      errors += 16;
    }
    System.assertEquals(0, errors, 'deleteRecords - errors found');
  }

  @IsTest
  private static void deleteRecords_whereClauseIsInvalid_expectFailure() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestPicklistA__c', 'random type(picklist)');
    obj.insertRecords(true);
    obj.deleteRecords('TestPicklistA__c == a1');
    Test.stopTest();

    String expectedResult = 'Found errors selecting records of object [FObjectOne__c]';
    String actualResult = obj.getErrors().get('FObjectOne__c').get(0);
    Boolean result = actualResult.startsWith(expectedResult);
    System.assertEquals(true, result, 'deleteRecords - errors found');
  }

  @IsTest
  private static void deleteRecords_deleteException_expectFailure() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
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
    if (FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'deleteRecords - errors found');
  }

  /* FObject */

  @IsTest
  private static void fObject_invalidObject_expectFailure() {
    Test.startTest();
    FObject obj = new FObject(' FObjectOneX__c ');
    Test.stopTest();

    String expectedResult = 'Invalid object [FObjectOneX__c]';
    String actualResult = obj.getErrors().get('FObjectOneX__c').get(0);
    System.assertEquals(expectedResult, actualResult, 'FObject constructor - errors found');
  }

  @IsTest
  private static void fObject_blankObject_expectFailure() {
    Test.startTest();
    FObject obj = new FObject('');
    Test.stopTest();

    String expectedResult = 'Invalid object []';
    String actualResult = obj.getErrors().get('').get(0);
    System.assertEquals(expectedResult, actualResult, 'FObject constructor - errors found');
  }

  @IsTest
  private static void fObject_constructorWithDefaultRecords_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject(' FObjectOne__c ');
    obj.setDefinition(' TestDecimal__c ', ' Random type(number ) from( 100) to(1000000 ) scale(3) ');
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    System.assertEquals(201, records.size(), 'FObject constructor - errors found');
  }

  @IsTest
  private static void fObject_constructorWithRecords_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c', 100);
    obj.setDefinition('TestDecimal__c', 'Random Type (number ) from( 100) to(1000000 ) scale(3)');
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    System.assertEquals(100, records.size(), 'FObject constructor - errors found');
  }

  /* forceeaDebug */

  @IsTest
  private static void forceeaDebug_valid_expectSuccess() {
    FObject.showDebugLog = false;

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setVerbose('debug');
    obj.setDefinition('TestText__c', 'Static Value(Test)');
    obj.insertRecords(true);
    Test.stopTest();

    System.assertEquals(false, FObject.showDebugLog, 'forceeaDebug - errors found');
  }

  /* getAllDefinitions */

  @IsTest
  private static void getAllDefinitions_multipleChecks_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestText__c', 'Random Type(Date) From(2017-01-01) To(2017-12-31)');
    obj.setDefinition('TestText__c', 'static value(One)');
    obj.setDefinition('TestDatetime__c', 'Random Type(Datetime) From(2017-01-01) To(2017-12-31)');
    obj.setDefinition('TestDecimal__c', 'Random Type(Number) From(1) To(100) Scale(0)');
    obj.setDefinition('TestEmail__c', 'Random Type(Email)');
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
    if (!FObject.processIsValid) {
      errors += 16;
    }
    System.assertEquals(0, errors, 'getAllDefinitions - errors found');
  }

  /* getDefaultRecords */

  @IsTest
  private static void getDefaultRecords_lessThan11Records_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c', 10);
    obj.setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) source(forceea)');
    obj.insertRecords(true);
    Test.stopTest();

    List<FObjectTwo__c> lookupRecords = [SELECT Id FROM FObjectTwo__c LIMIT 1000];
    Integer expectedResult = 10;
    Integer actualResult = lookupRecords.size();
    System.assertEquals(expectedResult, actualResult, 'getDefaultRecords - errors found');
  }

  @IsTest
  private static void getDefaultRecords_moreThan10Records_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c', 20);
    obj.setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) source(forceea)');
    obj.insertRecords(true);
    Test.stopTest();

    List<FObjectTwo__c> lookupRecords = [SELECT Id FROM FObjectTwo__c LIMIT 1000];
    Integer expectedResult = 12;
    Integer actualResult = lookupRecords.size();
    System.assertEquals(expectedResult, actualResult, 'getDefaultRecords - errors found');
  }

  /* getInsertedGroupRecords */

  @IsTest
  private static void getInsertedGroupRecords_instanceAndStatic_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestText__c', 'random type(list) value(v1,v2)');
    obj.insertRecords(true, 'GroupA');
    obj.deleteFieldDefinitions('TestText__c');
    obj.setDefinition('TestText__c', 'random type(list) value(v3,v4)');
    obj.insertRecords(true, 'GroupB');
    Test.stopTest();

    List<FObjectOne__c> recordsA1 = (List<FObjectOne__c>) obj.getInsertedGroupRecords('GROUPA');
    List<FObjectOne__c> recordsA2 = (List<FObjectOne__c>) FObject.getInsertedGroupRecords('FObjectOne__c', 'GROUPA');
    List<FObjectOne__c> recordsB1 = (List<FObjectOne__c>) obj.getInsertedGroupRecords('GROUPB');
    List<FObjectOne__c> recordsB2 = (List<FObjectOne__c>) FObject.getInsertedGroupRecords('FObjectOne__c', 'GROUPB');
    List<FObjectOne__c> recordsBlank1 = (List<FObjectOne__c>) obj.getInsertedGroupRecords('');
    List<FObjectOne__c> recordsBlank2 = (List<FObjectOne__c>) obj.getInsertedGroupRecords(' ');
    List<FObjectOne__c> recordsBlank3 = (List<FObjectOne__c>) obj.getInsertedGroupRecords('GroupC');

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
    if (!FObject.processIsValid) {
      errors += 8;
    }
    System.assertEquals(0, errors, 'getInsertedGroupRecords - errors found');
  }

  @IsTest
  private static void getInsertedGroupRecords_insertSameGroupTwice_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestText__c', 'random type(list) value(v1,v2)');
    obj.insertRecords(true, 'GroupA');
    obj.deleteAllDefinitions();
    obj.setDefinition('TestDecimal__c', 'random type(list) value(1,2,3)');
    obj.insertRecords(true, 'GroupA');
    Test.stopTest();

    Integer errors = 0;
    Integer blankTexts = 0;
    Integer blankDecimals = 0;
    for (FObjectOne__c objRecord : (List<FObjectOne__c>) obj.getInsertedGroupRecords('GROUPA')) {
      if (String.isBlank(objRecord.TestText__c)) {
        blankTexts++;
      }
      if (objRecord.TestDecimal__c == null) {
        blankDecimals++;
      }
    }
    if (blankTexts != 201) {
      errors += 1;
    }
    if (blankDecimals != 201) {
      errors += 2;
    }
    if (!FObject.processIsValid) {
      errors += 4;
    }
    System.assertEquals(0, errors, 'getInsertedGroupRecords - errors found');
  }

  @IsTest
  private static void getInsertedGroupRecordsStatic_valid_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestText__c', 'random type(list) value(v1,v2)');
    obj.insertRecords(true, 'GroupA');
    obj.deleteFieldDefinitions('TestText__c');
    obj.setDefinition('TestText__c', 'random type(list) value(v3,v4)');
    obj.insertRecords(true, 'GroupB');
    Test.stopTest();

    List<FObjectOne__c> recordsA1 = (List<FObjectOne__c>) obj.getInsertedGroupRecords('GROUPA');
    List<FObjectOne__c> recordsA2 = (List<FObjectOne__c>) FObject.getInsertedGroupRecords('FObjectOne__c', 'GROUPA');
    List<FObjectOne__c> recordsB1 = (List<FObjectOne__c>) obj.getInsertedGroupRecords('GROUPB');
    List<FObjectOne__c> recordsB2 = (List<FObjectOne__c>) FObject.getInsertedGroupRecords('FObjectOne__c', 'GROUPB');
    List<FObjectOne__c> recordsBlank1 = (List<FObjectOne__c>) obj.getInsertedGroupRecords('');
    List<FObjectOne__c> recordsBlank2 = (List<FObjectOne__c>) obj.getInsertedGroupRecords(' ');
    List<FObjectOne__c> recordsBlank3 = (List<FObjectOne__c>) obj.getInsertedGroupRecords('GroupC');

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
    if (!FObject.processIsValid) {
      errors += 8;
    }
    System.assertEquals(0, errors, 'getInsertedGroupRecords - errors found');
  }

  @IsTest
  private static void getInsertedGroupRecordsStatic_invalidObject_expectFailure() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) source(forceea)');
    obj.insertRecords(true, 'One');
    Test.stopTest();

    List<FObjectTwo__c> lookupRecords = (List<FObjectTwo__c>) FObject.getInsertedGroupRecords('FObjectTwoX__c', 'One');
    Boolean expectedResult = false;
    Boolean actualResult = FObject.processIsValid;
    System.assertEquals(expectedResult, actualResult, 'getInsertedGroupRecords - errors found');
  }

  /* getInsertedRecords */

  @IsTest
  private static void getInsertedRecords_twoInsertionsAllOrNoneTrue_expectSuccess() {
    List<FObjectOne__c> records1 = new List<FObjectOne__c>();
    List<FObjectOne__c> records2 = new List<FObjectOne__c>();

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c', 100);
    obj.setDefinition('TestText__c', 'static value(a1)');
    obj.insertRecords(true);
    records1.addAll((List<FObjectOne__c>) obj.getRecords());

    obj.deleteAllDefinitions();

    obj.setDefinition('TestText__c', 'static value(a2)');
    obj.insertRecords(true);
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
  private static void getInsertedRecordsStatic_lookupRecords_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) source(forceea)');
    obj.insertRecords(true);
    Test.stopTest();

    List<FObjectTwo__c> lookupRecords = (List<FObjectTwo__c>) FObject.getInsertedRecords('FObjectTwo__c');
    Integer expectedResult = lookupRecords.hashCode();
    Integer actualResult = [SELECT TestPicklistDRequired__c FROM FObjectTwo__c LIMIT 1000].hashCode();
    System.assertEquals(expectedResult, actualResult, 'getInsertedRecords - errors found');
  }

  @IsTest
  private static void getInsertedRecordsStatic_invalidObject_expectFailure() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) source(forceea)');
    obj.insertRecords(true);
    Test.stopTest();

    List<FObjectTwo__c> lookupRecords = (List<FObjectTwo__c>) FObject.getInsertedRecords('FObjectTwoX__c');
    Boolean expectedResult = false;
    Boolean actualResult = FObject.processIsValid;
    System.assertEquals(expectedResult, actualResult, 'getInsertedRecords - errors found');
  }

  /* getRecords */

  @IsTest
  private static void getRecords_withoutNewDefinitions_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestText__c', 'static value(sample)');
    List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj.getRecords();
    Integer hash1 = records1.hashCode();

    obj.records = 100;
    List<FObjectOne__c> records2 = (List<FObjectOne__c>) obj.getRecords();
    Integer hash2 = records2.hashCode();
    Test.stopTest();

    Boolean expectedResult = true;
    Boolean actualResult = (records1.size() == records2.size()) && (hash1 == hash2);
    System.assertEquals(expectedResult, actualResult, 'getRecords - errors found');
  }

  @IsTest
  private static void getRecords_insertRecordsAfterNewDefinitions_expectSuccess() {
    Integer size1 = 201;
    Integer size2 = 100;

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c', size1);
    obj.setDefinition('TestInteger__c', 'serial type(number) from(1) step(1) scale(0)');
    List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj.getRecords();

    obj.records = size2;
    obj.deleteFieldDefinitions('TestInteger__c');
    obj.setDefinition('TestInteger__c', 'serial type(number) from(1) step(1) scale(0)');
    List<FObjectOne__c> records2 = (List<FObjectOne__c>) obj.getRecords();
    obj.insertRecords(true);
    Test.stopTest();

    List<FObjectOne__c> insertedRecords = [SELECT Id, TestInteger__c FROM FObjectOne__c LIMIT 1000];
    Integer errors = 0;
    if (records1.size() + records2.size() != insertedRecords.size()) {
      errors++;
    }
    if (records2[records2.size() - 1].TestInteger__c != (size1 + size2)) {
      errors++;
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'getRecords - errors found');
  }

  @IsTest
  private static void getRecords_insertRecordsBeforeGetRecords_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestText__c', 'static value(sample)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = obj.getRecords();
    Test.stopTest();

    Integer errors = 0;
    Set<Id> recordIdsSet = (new Map<Id, SObject>(records)).keySet();
    for (FObjectOne__c objRecord : [SELECT Id FROM FObjectOne__c LIMIT 1000]) {
      if (!recordIdsSet.contains(objRecord.Id)) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'getRecords - errors found');
  }

  @IsTest
  private static void getRecords_insertRecordsTwice_expectSuccess() {
    Integer size1 = 201;
    Integer size2 = 100;

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c', size1);
    obj.setDefinition('TestInteger__c', 'serial type(number) from(1) step(1) scale(0)');
    List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj.getRecords();
    obj.insertRecords(true);

    obj.records = size2;
    obj.insertRecords(true);
    List<FObjectOne__c> records2 = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    List<FObjectOne__c> insertedRecords = [SELECT Id, TestInteger__c FROM FObjectOne__c LIMIT 1000];
    Integer errors = 0;
    if (records1.size() + records2.size() != insertedRecords.size()) {
      errors++;
    }
    if (records2[records2.size() - 1].TestInteger__c != (size1 + size2)) {
      errors++;
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'getRecords - errors found');
  }

  @IsTest
  private static void getRecords_afterRecordsAreDeleted_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestText__c', 'random type(list) value(v1,v2,v3)');
    List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj.getRecords();
    obj.insertRecords(true);
    obj.deleteRecords('TestText__c = \'v1\'');
    Test.stopTest();

    Boolean condition1 = true;
    for (FObjectOne__c objRecord : [SELECT TestText__c FROM FObjectOne__c LIMIT 1000]) {
      if (objRecord.TestText__c == 'v1') {
        condition1 = false;
        break;
      }
    }
    List<FObjectOne__c> records2 = (List<FObjectOne__c>) obj.getRecords();
    Boolean expectedResult = true;
    Boolean condition2 = (records1.size() == records2.size());
    Boolean actualResult = condition1 && condition2;
    System.assertEquals(expectedResult, actualResult, 'getRecords - errors found');
  }

  @IsTest
  private static void getRecords_amendFieldValues_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestDecimal__c', 'random type(number) from(1) to(100) scale(0)');

    for (FObjectOne__c objRecord : (List<FObjectOne__c>) obj.getRecords()) {
      objRecord.TestDecimal__c = objRecord.TestDecimal__c * 0.1;
    }
    obj.createRecords();
    for (FObjectOne__c objRecord : (List<FObjectOne__c>) obj.getRecords()) {
      objRecord.TestDecimal__c = 100;
    }
    obj.insertRecords(true);
    Test.stopTest();

    Integer errors = 0;
    for (FObjectOne__c objRecord : [SELECT TestDecimal__c FROM FObjectOne__c LIMIT 1000]) {
      if (objRecord.TestDecimal__c > 10 && objRecord.TestDecimal__c < 100) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'getRecords - errors found');
  }

  /* insertRecords */

  @IsTest
  private static void insertRecords_allOrNoneTrue_expectFailure() {
    Boolean hasErrors = false;

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setRequiredFields = false;

    obj.setDefinition('TestPicklistC__c', 'static value(a1)');
    try {
      obj.insertRecords(true);
    } catch (DmlException ex) {
      hasErrors = true;
    }
    Test.stopTest();

    System.assertEquals(true, hasErrors, 'insertRecords - errors found');
  }

  @IsTest
  private static void insertRecords_allOrNoneFalse_expectFailure() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setRequiredFields = false;
    obj.setDefinition('TestPicklistC__c', 'static value(a1)');
    Database.SaveResult[] saveResults = obj.insertRecords(false);
    Test.stopTest();

    Integer errors = 0;
    for (Database.SaveResult sr : saveResults) {
      if (sr.isSuccess()) {
        errors++;
      }
    }
    System.assertEquals(0, errors, 'insertRecords - errors found');
  }

  @IsTest
  private static void insertRecords_attachments_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('Attachment');
    obj.setDefinition('Name', 'static value(Attachment)');
    obj.setDefinition('Name', 'serial type(number) from(1) step(1) scale(0)');
    obj.setDefinition('Body', 'random type(number) from(1) to(100) scale(2)');
    obj.insertRecords(true);
    Test.stopTest();

    Decimal value = 0;
    Integer errors = 0;
    for (Attachment objRecord : [SELECT Body FROM Attachment LIMIT 1000]) {
      value = Decimal.valueOf(objRecord.Body.toString());
      if (value < 1 || value > 100) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'insertRecords - errors found');
  }

  @IsTest
  private static void insertRecords_createRecordsAsUser_expectSuccess() {
    Test.startTest();
    FObject userObj = new FObject('User', 1);
    userObj.setDefinition('Title', 'static value(Developer)');
    userObj.setDefinition('ProfileId', 'static lookup(Profile) field(Name) value(System Administrator) source(salesforce)');
    Database.SaveResult[] saveResults = userObj.insertRecords(true);

    if (saveResults[0].isSuccess()) {
      List<User> users = (List<User>) userObj.getRecords();
      System.runAs(users[0]) {
        FObject obj = new FObject('FObjectOne__c');
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
    if (!FObject.processIsValid) {
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

    String expectedResult = 'Invalid number of records for object [FObjectOne__c]';
    String actualResult = obj.getErrors().get('FObjectOne__c').get(0);
    System.assertEquals(expectedResult, actualResult, 'insertRecords - errors found');
  }

  @IsTest
  private static void insertRecords_userWithProfile_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('User', 1);
    obj.setDefinition('ProfileId', 'static lookup(Profile) field(Name) value(System Administrator) source(salesforce)');
    obj.setDefinition('Title', 'static value(Forceea Developer)');
    Database.SaveResult[] saveResults = obj.insertRecords(false);
    Test.stopTest();

    Integer errors = 0;
    for (Database.SaveResult sr : saveResults) {
      if (!sr.isSuccess()) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'insertRecords - errors found');
  }

  @IsTest
  private static void insertRecords_noDefinitions_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    Database.SaveResult[] saveResults = obj.insertRecords(false);
    Test.stopTest();

    Integer errors = 0;
    for (Database.SaveResult sr : saveResults) {
      if (!sr.isSuccess()) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'insertRecords - errors found');
  }

  @IsTest
  private static void insertRecords_missingRequiredFields_expectFailure() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setRequiredFields = false;
    Database.SaveResult[] saveResults = obj.insertRecords(false);
    Test.stopTest();

    Integer errors = 0;
    for (Database.SaveResult sr : saveResults) {
      if (sr.isSuccess()) {
        errors++;
      }
    }
    System.assertEquals(0, errors, 'insertRecords - errors found');
  }

  @IsTest
  private static void insertRecords_comboboxWithSddlPicklist_expectSuccess() {
    FObject obj = new FObject('Event');
    obj.setDefinition('Subject', 'random type(picklist)');
    obj.setDefinition('Type', 'random type(picklist)');
    obj.setDefinition('WhoId', 'random lookup(Contact) source(forceea)');
    obj.setDefinition('ActivityDatetime', 'random type(datetime) from(2017-10-1) to(2017-12-31)');
    obj.setDefinition('DurationInMinutes', 'random type(number) from(1) to(10) scale(0)');
    Database.SaveResult[] saveResults = obj.insertRecords(false);

    Integer errors = 0;
    for (Database.SaveResult sr : saveResults) {
      if (!sr.isSuccess()) {
        errors++;
      }
    }
    System.assertEquals(0, errors, 'insertRecords - errors found');
  }

  @IsTest
  private static void insertRecords_comboboxWithSddlPicklistExcept_expectSuccess() {
    FObject obj = new FObject('Event');
    obj.setDefinition('Subject', 'random type(picklist) except(Call, Email)');
    obj.setDefinition('Type', 'random type(picklist)');
    obj.setDefinition('WhoId', 'random lookup(Contact) source(forceea)');
    obj.setDefinition('ActivityDatetime', 'random type(datetime) from(2017-10-1) to(2017-12-31)');
    obj.setDefinition('DurationInMinutes', 'random type(number) from(1) to(10) scale(0)');
    Database.SaveResult[] saveResults = obj.insertRecords(false);

    Integer errors = 0;
    for (Database.SaveResult sr : saveResults) {
      if (!sr.isSuccess()) {
        errors++;
      }
    }
    System.assertEquals(0, errors, 'insertRecords - errors found');
  }

  @IsTest
  private static void insertRecords_comboboxWithSddList_expectSuccess() {
    FObject obj = new FObject('Event');
    obj.setDefinition('Subject', 'random type(list) value(Call, Email)');
    obj.setDefinition('Type', 'random type(picklist)');
    obj.setDefinition('WhoId', 'random lookup(Contact) source(forceea)');
    obj.setDefinition('ActivityDatetime', 'random type(datetime) from(2017-10-1) to(2017-12-31)');
    obj.setDefinition('DurationInMinutes', 'random type(number) from(1) to(10) scale(0)');
    Database.SaveResult[] saveResults = obj.insertRecords(false);

    Integer errors = 0;
    for (Database.SaveResult sr : saveResults) {
      if (!sr.isSuccess()) {
        errors++;
      }
    }
    System.assertEquals(0, errors, 'insertRecords - errors found');
  }

  @IsTest
  private static void insertRecords_comboboxWithSddStaticExistingValue_expectSuccess() {
    FObject obj = new FObject('Event');
    obj.setDefinition('Subject', 'static value(Call)');
    obj.setDefinition('Type', 'random type(picklist)');
    obj.setDefinition('WhoId', 'random lookup(Contact) source(forceea)');
    obj.setDefinition('ActivityDatetime', 'random type(datetime) from(2017-10-1) to(2017-12-31)');
    obj.setDefinition('DurationInMinutes', 'random type(number) from(1) to(10) scale(0)');
    Database.SaveResult[] saveResults = obj.insertRecords(false);

    Integer errors = 0;
    for (Database.SaveResult sr : saveResults) {
      if (!sr.isSuccess()) {
        errors++;
      }
    }
    System.assertEquals(0, errors, 'insertRecords - errors found');
  }

  @IsTest
  private static void insertRecords_comboboxWithSddStaticNewValue_expectSuccess() {
    FObject obj = new FObject('Event');
    obj.setDefinition('Subject', 'static value(CallX)');
    obj.setDefinition('Type', 'random type(picklist)');
    obj.setDefinition('WhoId', 'random lookup(Contact) source(forceea)');
    obj.setDefinition('ActivityDatetime', 'random type(datetime) from(2017-10-1) to(2017-12-31)');
    obj.setDefinition('DurationInMinutes', 'random type(number) from(1) to(10) scale(0)');
    Database.SaveResult[] saveResults = obj.insertRecords(false);

    Integer errors = 0;
    for (Database.SaveResult sr : saveResults) {
      if (!sr.isSuccess()) {
        errors++;
      }
    }
    System.assertEquals(0, errors, 'insertRecords - errors found');
  }

  /* Pseudo-random Number Generator */

  @IsTest
  private static void prng_checkGenerator_expectSuccess() {
    Test.startTest();
    FObject obj1 = new FObject('FObjectOne__c');
    FObject.seed = 19660805;
    obj1.setDefinition('TestInteger__c', 'random type(number) from(1) to(100) scale(0)');
    obj1.createRecords();
    List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();

    FObject obj2 = new FObject('FObjectOne__c');
    FObject.seed = 19660805;
    obj2.setDefinition('TestInteger__c', 'random type(number) from(1) to(100) scale(0)');
    obj2.createRecords();
    List<FObjectOne__c> records2 = (List<FObjectOne__c>) obj2.getRecords();
    Test.stopTest();

    Integer errors = 0;
    for (Integer counter = 0; counter < 100; counter++) {
      if (records1.get(counter).TestInteger__c != records2.get(counter).TestInteger__c ||
        records1.get(counter).TestTextRequired__c != records2.get(counter).TestTextRequired__c) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'PRNG - errors found');
  }

  /* SDDL definitions */

  @IsTest
  private static void sddlCopyField_valid_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestDecimal__c', 'random type(number) from(" 1") to(" 100 ") scale(0)');
    obj.setDefinition('TestText__c', 'copy field(TestDecimal__c)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    Integer errors = 0;
    for (FObjectOne__c objRecord : records) {
      if (objRecord.TestDecimal__c.intValue() != Integer.valueOf(objRecord.TestText__c)) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'copy field - errors found');
  }

  @IsTest
  private static void sddlCopyField_invalidField_expectFailure() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestDecimal__c', 'random type(number) from(1) to(100) scale(0)');
    obj.setDefinition('TestText__c', 'copy field(TestDecimalX__c)');
    obj.insertRecords(true);
    Test.stopTest();

    String expectedResult = 'Invalid field [TestDecimalX__c] in definition ' +
      '[copy field(TestDecimalX__c)]';
    String actualResult = obj.getErrors().get('TestText__c').get(0);
    System.assertEquals(expectedResult, actualResult, 'copy field - errors found');
  }

  @IsTest
  private static void sddlCopyField_fieldEqualsDefinitionField_expectFailure() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestDecimal__c', 'random type(number) from(1) to(100) scale(0)');
    obj.setDefinition('TestText__c', 'copy field(testText__c)');
    obj.insertRecords(true);
    Test.stopTest();

    String expectedResult = 'The field [TestText__c] cannot be the same as the definition field ' +
      'in definition [copy field(testText__c)]';
    String actualResult = obj.getErrors().get('TestText__c').get(0);
    System.assertEquals(expectedResult, actualResult, 'copy field - errors found');
  }

  @IsTest
  private static void sddlCopyLookupField_fromText_expectSuccess() {
    Test.startTest();
    FObject obj2 = new FObject('FObjectTwo__c');
    obj2.setDefinition('TestpicklistA__c', 'random type(picklist)');
    obj2.insertRecords(true);
    List<FObjectTwo__c> records2 = (List<FObjectTwo__c>) obj2.getRecords();
    Map<Id, FObjectTwo__c> lookupRecordsMap = new Map<Id, FObjectTwo__c>(records2);

    FObject obj1 = new FObject('FObjectOne__c');
    obj1.setDefinition('Testlookup__c', 'random lookup(FObjectTwo__c) source(forceea)');
    obj1.setDefinition('Testtext__c', 'copy field(Testlookup__c) from(FObjectTwo__c.TestpicklistA__c)');
    obj1.insertRecords(true);
    List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
    Test.stopTest();

    Integer errors = 0;
    for (Integer counter = 0; counter < records1.size(); counter++) {
      Id lookupId = records1.get(counter).TestLookup__c;
      if (records1.get(counter).TestText__c != null &&
        records1.get(counter).TestText__c != lookupRecordsMap.get(lookupId).TestPicklistA__c) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'copy lookup field - errors found');
  }

  @IsTest
  private static void sddlCopyLookupField_fromDate_expectSuccess() {
    Test.startTest();

    FObject obj2 = new FObject('FObjectTwo__c');
    obj2.setDefinition('Testdate__c', 'random type(date) from(2018-01-01) to(2018-12-31)');
    obj2.insertRecords(true);
    List<FObjectTwo__c> records2 = (List<FObjectTwo__c>) obj2.getRecords();
    Map<Id, FObjectTwo__c> lookupRecordsMap = new Map<Id, FObjectTwo__c>(records2);

    FObject obj1 = new FObject('FObjectOne__c');
    obj1.setDefinition('Testlookup__c', 'random lookup(FObjectTwo__c) source(forceea)');
    obj1.setDefinition('Testdate__c', 'copy field(Testlookup__c) from(FObjectTwo__c.Testdate__c)');
    obj1.insertRecords(true);
    List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();

    Test.stopTest();

    Integer errors = 0;
    for (Integer counter = 0; counter < records1.size(); counter++) {
      Id lookupId = records1.get(counter).TestLookup__c;
      if (records1.get(counter).TestDate__c != null &&
        records1.get(counter).TestDate__c != lookupRecordsMap.get(lookupId).TestDate__c) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'copy lookup field - errors found');
  }

  @IsTest
  private static void sddlCopyLookupField_fromDatetimeToDatetime_expectSuccess() {
    FObject.setGlobalVerbose('debug');

    Test.startTest();

    FObject obj2 = new FObject('FObjectTwo__c');
    obj2.setDefinition('Testdatetime__c', 'random type(datetime) from(2018-01-01) to(2018-12-31)');
    obj2.insertRecords(true);
    List<FObjectTwo__c> records2 = (List<FObjectTwo__c>) obj2.getInsertedRecords();
    Map<Id, FObjectTwo__c> lookupRecordsMap = new Map<Id, FObjectTwo__c>(records2);

    FObject obj1 = new FObject('FObjectOne__c');
    obj1.setDefinition('Testlookup__c', 'random lookup(FObjectTwo__c) source(forceea)');
    obj1.setDefinition('Testdatetime__c', 'copy field(Testlookup__c) from(FObjectTwo__c.Testdatetime__c)');
    obj1.insertRecords(true);
    List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();

    Test.stopTest();

    Integer errors = 0;
    for (Integer counter = 0; counter < records1.size(); counter++) {
      Id lookupId = records1.get(counter).TestLookup__c;
      if (String.valueOf(lookupRecordsMap.get(lookupId).TestDatetime__c) !=
        String.valueOf(records1.get(counter).TestDatetime__c)) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'copy lookup field - errors found');
  }

  @IsTest
  private static void sddlCopyLookupField_fromDatetimeToText_expectSuccess() {
    Test.startTest();

    FObject obj2 = new FObject('FObjectTwo__c', 20);
    obj2.setDefinition('Testdatetime__c', 'random type(datetime) from(2018-01-01) to(2018-12-31)');
    obj2.insertRecords(true);
    List<FObjectTwo__c> records2 = (List<FObjectTwo__c>) obj2.getInsertedRecords();
    Map<Id, FObjectTwo__c> lookupRecordsMap = new Map<Id, FObjectTwo__c>(records2);

    FObject obj1 = new FObject('FObjectOne__c');
    obj1.setDefinition('Testlookup__c', 'random lookup(FObjectTwo__c) source(forceea)');
    obj1.setDefinition('TestText__c', 'copy field(Testlookup__c) from(FObjectTwo__c.Testdatetime__c)');
    obj1.insertRecords(true);
    List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();

    Test.stopTest();

    Integer errors = 0;
    for (Integer counter = 0; counter < records1.size(); counter++) {
      Id lookupId = records1.get(counter).TestLookup__c;
      Datetime dt = lookupRecordsMap.get(lookupId).TestDatetime__c;
      if (String.valueOfGmt(dt) != records1.get(counter).TestText__c) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'copy lookup field - errors found');
  }

  @IsTest
  private static void sddlCopyLookupField_fromTime_expectSuccess() {
    Test.startTest();
    FObject obj2 = new FObject('FObjectTwo__c');
    obj2.setDefinition('Testtime__c', 'static value(23:59:59)');
    obj2.insertRecords(true);
    List<FObjectTwo__c> records2 = (List<FObjectTwo__c>) obj2.getRecords();
    Map<Id, FObjectTwo__c> lookupRecordsMap = new Map<Id, FObjectTwo__c>(records2);

    FObject obj1 = new FObject('FObjectOne__c');
    obj1.setDefinition('Testlookup__c', 'random lookup(FObjectTwo__c) source(forceea)');
    obj1.setDefinition('Testtime__c', 'copy field(Testlookup__c) from(FObjectTwo__c.Testtime__c)');
    obj1.insertRecords(true);
    List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
    Test.stopTest();

    Integer errors = 0;
    for (Integer counter = 0; counter < records1.size(); counter++) {
      Id lookupId = records1.get(counter).TestLookup__c;
      if (records1.get(counter).TestTime__c != null &&
        records1.get(counter).TestTime__c != lookupRecordsMap.get(lookupId).TestTime__c) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'copy lookup field - errors found');
  }

  @IsTest
  private static void sddlCopyLookupField_fromCurrency_expectSuccess() {
    Test.startTest();
    FObject obj2 = new FObject('FObjectTwo__c');
    obj2.setDefinition('TestCurrency__c', 'random type(number) from(1) to(100) scale(2)');
    obj2.insertRecords(true);
    List<FObjectTwo__c> records2 = (List<FObjectTwo__c>) obj2.getRecords();
    Map<Id, FObjectTwo__c> lookupRecordsMap = new Map<Id, FObjectTwo__c>(records2);

    FObject obj1 = new FObject('FObjectOne__c');
    obj1.setDefinition('Testlookup__c', 'random lookup(FObjectTwo__c) source(forceea)');
    obj1.setDefinition('TestCurrency__c', 'copy field(Testlookup__c) from(FObjectTwo__c.TestCurrency__c)');
    obj1.insertRecords(true);
    List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
    Test.stopTest();

    Integer errors = 0;
    for (Integer counter = 0; counter < records1.size(); counter++) {
      Id lookupId = records1.get(counter).TestLookup__c;
      if (records1.get(counter).TestCurrency__c != null &&
        records1.get(counter).TestCurrency__c != lookupRecordsMap.get(lookupId).TestCurrency__c) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'copy lookup field - errors found');
  }

  @IsTest
  private static void sddlCopyLookupField_fromCheckbox_expectSuccess() {
    Test.startTest();
    FObject obj2 = new FObject('FObjectTwo__c');
    obj2.setDefinition('TestCheckbox__c', 'random type(boolean)');
    obj2.insertRecords(true);
    List<FObjectTwo__c> records2 = (List<FObjectTwo__c>) obj2.getRecords();
    Map<Id, FObjectTwo__c> lookupRecordsMap = new Map<Id, FObjectTwo__c>(records2);

    FObject obj1 = new FObject('FObjectOne__c');
    obj1.setDefinition('Testlookup__c', 'random lookup(FObjectTwo__c) source(forceea)');
    obj1.setDefinition('TestCheckbox__c', 'copy field(Testlookup__c) from(FObjectTwo__c.TestCheckbox__c)');
    obj1.insertRecords(true);
    List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
    Test.stopTest();

    Integer errors = 0;
    for (Integer counter = 0; counter < records1.size(); counter++) {
      Id lookupId = records1.get(counter).TestLookup__c;
      if (records1.get(counter).TestCheckbox__c != null &&
        records1.get(counter).TestCheckbox__c != lookupRecordsMap.get(lookupId).TestCheckbox__c) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'copy lookup field - errors found');
  }

  @IsTest
  private static void sddlCopyLookupField_fromUrl_expectSuccess() {
    Test.startTest();
    FObject obj2 = new FObject('FObjectTwo__c');
    obj2.setDefinition('TestUrl__c', 'random type(url)');
    obj2.insertRecords(true);
    List<FObjectTwo__c> records2 = (List<FObjectTwo__c>) obj2.getRecords();
    Map<Id, FObjectTwo__c> lookupRecordsMap = new Map<Id, FObjectTwo__c>(records2);

    FObject obj1 = new FObject('FObjectOne__c');
    obj1.setDefinition('Testlookup__c', 'random lookup(FObjectTwo__c) source(forceea)');
    obj1.setDefinition('TestUrl__c', 'copy field(Testlookup__c) from(FObjectTwo__c.TestUrl__c)');
    obj1.insertRecords(true);
    List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
    Test.stopTest();

    Integer errors = 0;
    for (Integer counter = 0; counter < records1.size(); counter++) {
      Id lookupId = records1.get(counter).TestLookup__c;
      if (records1.get(counter).TestUrl__c != null &&
        records1.get(counter).TestUrl__c != lookupRecordsMap.get(lookupId).TestUrl__c) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'copy lookup field - errors found');
  }

  @IsTest
  private static void sddlCopyLookupField_invalidField_expectFailure() {
    String definitionString = 'copy field(TestlookupX__c) from(FObjectTwo__c.TestpicklistA__c)';

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('Testlookup__c', 'random lookup(FObjectTwo__c) source(forceea)');
    obj.setDefinition('Testtext__c', definitionString);
    obj.insertRecords(true);
    Test.stopTest();

    String expectedResult = 'Invalid field [TestlookupX__c] in definition [' + definitionString + ']';
    String actualResult = obj.getErrors().get('TestText__c').get(0);
    System.assertEquals(expectedResult, actualResult, 'copy lookup field - errors found');
  }

  @IsTest
  private static void sddlCopyLookupField_invalidLookupObject_expectFailure() {
    String definitionString = 'copy field(Testlookup__c) from(FObjecttwoX__c.TestpicklistA__c)';

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('Testlookup__c', 'random lookup(FObjectTwo__c) source(forceea)');
    obj.setDefinition('Testtext__c', definitionString);
    obj.insertRecords(true);
    Test.stopTest();

    String expectedResult = 'Invalid lookup object [FObjecttwoX__c] in definition [' + definitionString + ']';
    String actualResult = obj.getErrors().get('TestText__c').get(0);
    System.assertEquals(expectedResult, actualResult, 'copy lookup field - errors found');
  }

  @IsTest
  private static void sddlCopyLookupField_invalidLookupField_expectFailure() {
    String definitionString = 'copy field(Testlookup__c) from(FObjectTwo__c.TestpicklistX__c)';

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('Testlookup__c', 'random lookup(FObjectTwo__c) source(forceea)');
    obj.setDefinition('Testtext__c', definitionString);
    obj.insertRecords(true);
    Test.stopTest();

    String expectedResult = 'Invalid lookup field [TestpicklistX__c] in definition [' + definitionString + ']';
    String actualResult = obj.getErrors().get('TestText__c').get(0);
    System.assertEquals(expectedResult, actualResult, 'copy lookup field - errors found');
  }

  @IsTest
  private static void sddlCopyLookupField_lookupFieldEqualsDefinitionField_expectFailure() {
    String definitionString = 'copy field(TestText__c) from(FObjectTwo__c.TestpicklistA__c)';

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('Testlookup__c', 'random lookup(FObjectTwo__c) source(forceea)');
    obj.setDefinition('Testtext__c', definitionString);
    obj.insertRecords(true);
    Test.stopTest();

    String expectedResult = 'The field [TestText__c] cannot be the same as the definition field ' +
      'in definition [' + definitionString + ']';
    String actualResult = obj.getErrors().get('TestText__c').get(0);
    System.assertEquals(expectedResult, actualResult, 'copy lookup field - errors found');
  }

  @IsTest
  private static void sddlRandomLookupForceea_valid_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c', 500);
    obj.setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) source(Forceea)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    Integer errors = 0;
    Set<Id> refObjectIdsSet =
      (new Map<Id, FObjectTwo__c>([SELECT Id FROM FObjectTwo__c LIMIT 1000])).keySet();
    for (FObjectOne__c objRecord : records) {
      if (!refObjectIdsSet.contains(objRecord.TestLookup__c)) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random lookup forceea - errors found');
  }

  @IsTest
  private static void sddlRandomLookupForceea_isActiveUser_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectFour__c');
    obj.setDefinition('TestLookupUser__c', 'random lookup(User) source(forceea)');
    obj.insertRecords(true);
    List<User> users = obj.getInsertedRecords();
    Test.stopTest();

    Integer errors = 0;
    Set<Id> recordIdsSet = (new Map<Id, User>(users)).keySet();
    List<FObjectFour__c> records = [
      SELECT TestLookupUser__r.IsActive
      FROM FObjectFour__c
      WHERE Id IN :recordIdsSet
      LIMIT 100
    ];
    for (FObjectFour__c objRecord : records) {
      if (objRecord.TestLookupUser__r.IsActive == false) {
        errors += 1;
        break;
      }
    }
    if (!FObject.processIsValid) {
      errors += 2;
    }
    System.assertEquals(0, errors, 'random lookup forceea - errors found');
  }

  @IsTest
  private static void sddlRandomLookupSalesforce_noRecords_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) source(Salesforce)');
    obj.insertRecords(false);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    Integer errors = 0;
    for (FObjectOne__c objRecord : records) {
      if (String.isNotBlank(objRecord.TestLookup__c)) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random lookup salesforce - errors found');
  }

  @IsTest
  private static void sddlRandomLookupSalesforce_oneRecord_expectSuccess() {
    Test.startTest();
    FObject obj1 = new FObject('FObjectTwo__c', 1);
    obj1.insertRecords(true);
    List<FObjectTwo__c> records1 = (List<FObjectTwo__c>) obj1.getRecords();

    FObject obj2 = new FObject('FObjectOne__c');
    obj2.setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) source(Salesforce)');
    obj2.insertRecords(true);
    List<FObjectOne__c> records2 = (List<FObjectOne__c>) obj2.getRecords();
    Test.stopTest();

    Integer errors = 0;
    for (FObjectOne__c objRecord : records2) {
      if (objRecord.TestLookup__c != records1[0].Id) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random lookup salesforce - errors found');
  }

  @IsTest
  private static void sddlRandomLookupSalesforce_manyRecords_expectSuccess() {
    Test.startTest();
    FObject obj1 = new FObject('FObjectTwo__c', 20);
    obj1.insertRecords(true);

    FObject obj2 = new FObject('FObjectOne__c');
    obj2.setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) source(Salesforce)');
    obj2.insertRecords(true);
    List<FObjectOne__c> records2 = (List<FObjectOne__c>) obj2.getRecords();
    Test.stopTest();

    Integer errors = 0;
    for (FObjectOne__c objRecord : records2) {
      if (String.isBlank(objRecord.TestLookup__c)) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random lookup salesforce - errors found');
  }

  @IsTest
  private static void sddlRandomLookupSalesforce_isActiveUser_expectSuccess() {
    FObject.setGlobalVerbose('debug');
    Test.startTest();
    FObject obj1 = new FObject('User', 10);
    obj1.setDefinition('IsActive', 'random type(boolean)');
    obj1.insertRecords(true);

    FObject obj2 = new FObject('FObjectFour__c');
    obj2.setDefinition('TestLookupUser__c', 'random lookup(User) source(salesforce)');
    obj2.insertRecords(true);
    Test.stopTest();

    Integer errors = 0;
    for (FObjectFour__c objRecord : [SELECT TestLookupUser__r.IsActive FROM FObjectFour__c LIMIT 1000]) {
      if (objRecord.TestLookupUser__r.IsActive == false) {
        errors += 1;
        break;
      }
    }
    if (!FObject.processIsValid) {
      errors += 2;
    }
    System.assertEquals(0, errors, 'random lookup salesforce - errors found');
  }

  @IsTest
  private static void sddlRandomLookup_invalidObject_expectFailure() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestLookup__c', 'random lookup(InvalidObject) source(Forceea)');
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    String expectedResult = 'Invalid lookup object [InvalidObject] in definition ' +
      '[random lookup(InvalidObject) source(Forceea)]';
    String actualResult = obj.getErrors().get('TestLookup__c').get(0);
    System.assertEquals(expectedResult, actualResult, 'random lookup - errors found');
  }

  @IsTest
  private static void sddlRandomLookup_nullObject_expectFailure() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestLookup__c', 'random lookup() source(Forceea)');
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    String expectedResult = 'Invalid syntax in definition [random lookup() source(Forceea)] of field [TestLookup__c]';
    String actualResult = obj.getErrors().get('TestLookup__c').get(0);
    System.assertEquals(expectedResult, actualResult, 'random lookup - errors found');
  }

  @IsTest
  private static void sddlRandomLookup_invalidSource_expectFailure() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) source(ForceeaX)');
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    String expectedResult = 'Invalid definition [random lookup(FObjectTwo__c) source(ForceeaX)] of field [TestLookup__c]';
    String actualResult = obj.getErrors().get('TestLookup__c').get(0);
    System.assertEquals(expectedResult, actualResult, 'random lookup - errors found');
  }

  @IsTest
  private static void sddlRandomLookup_nullSource_expectFailure() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) source()');
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    String expectedResult = 'Invalid syntax in definition [random lookup(FObjectTwo__c) source()] of field [TestLookup__c]';
    String actualResult = obj.getErrors().get('TestLookup__c').get(0);
    System.assertEquals(expectedResult, actualResult, 'random lookup - errors found');
  }

  @IsTest
  private static void sddlRandomLookupGroupForceea_insertedGroupRecords_expectSuccess() {
    Test.startTest();
    // insert FObjectTwo__c records for group B
    FObject objB1 = new FObject('FObjectTwo__c', 5);
    objB1.insertRecords(true, 'B');
    List<FObjectTwo__c> recordsB1 = (List<FObjectTwo__c>) objB1.getRecords();
    Set<Id> recordIdsSetB1 = (new Map<Id, FObjectTwo__c>(recordsB1)).keySet();
    // insert FObjectTwo__c records without group
    FObject objB2 = new FObject('FObjectTwo__c', 5);
    objB2.insertRecords(true);
    List<FObjectTwo__c> recordsB2 = (List<FObjectTwo__c>) objB2.getRecords();
    Set<Id> recordIdsSetB2 = (new Map<Id, FObjectTwo__c>(recordsB2)).keySet();
    // insert FObjectOne__c records
    FObject objA = new FObject('FObjectOne__c', 300);
    objA.setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) source(Forceea)');
    objA.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) objA.getRecords();
    Test.stopTest();

    Set<Id> recordIdsSet = (new Map<Id, SObject>(FObject.getInsertedRecords('FObjectTwo__c'))).keySet();
    Integer errors = 0;
    for (FObjectOne__c objRecord : records) {
      if (!recordIdsSet.contains(objRecord.TestLookup__c)) {
        errors = 1;
        break;
      }
    }
    if (!isValidDistribution('TestLookup__c', new List<Id>(recordIdsSet), records)) {
      errors += 2;
    }
    if (!FObject.processIsValid) {
      errors += 4;
    }
    System.assertEquals(0, errors, 'random lookup forceea - errors found');
  }

  @IsTest
  private static void sddlRandomLookupGroupForceea_insertTwoGroupsValidGroupName_expectSuccess() {
    Test.startTest();
    // insert FObjectTwo__c records for group B1
    FObject objB1 = new FObject('FObjectTwo__c', 20);
    objB1.insertRecords(true, 'B1');
    List<FObjectTwo__c> records1 = (List<FObjectTwo__c>) objB1.getRecords();
    Set<Id> recordIdsSet = (new Map<Id, FObjectTwo__c>(records1)).keySet();
    // insert FObjectTwo__c records for group B2
    FObject objB2 = new FObject('FObjectTwo__c', 30);
    objB2.insertRecords(true, 'B2');
    // insert FObjectTwo__c records without for group
    FObject objB3 = new FObject('FObjectTwo__c', 40);
    objB3.insertRecords(true);
    // insert FObjectOne__c records
    FObject objA = new FObject('FObjectOne__c');
    objA.setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) group(B1) source(Forceea)');
    objA.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) objA.getRecords();
    Test.stopTest();

    Integer errors = 0;
    for (FObjectOne__c objRecord : records) {
      if (!recordIdsSet.contains(objRecord.TestLookup__c)) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'sddlRandomLookupGroup - errors found');
  }

  @IsTest
  private static void sddlRandomLookupGroupForceea_blankGroupName_expectFailure() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) group() source(Forceea)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    String expectedResult = 'Invalid syntax in definition [random lookup(FObjectTwo__c) group() ' +
      'source(Forceea)] of field [TestLookup__c]';
    String actualResult = obj.getErrors().get('TestLookup__c').get(0);
    System.assertEquals(expectedResult, actualResult, 'sddlRandomLookupGroup - errors found');
  }

  @IsTest
  private static void sddlRandomLookupGroupForceea_groupNotExists_expectSuccess() {
    Test.startTest();
    // insert FObjectTwo__c records
    FObject objB = new FObject('FObjectTwo__c', 20);
    objB.insertRecords(true, 'GroupB');
    // insert FObjectOne__c records
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) group(One) source(Forceea)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    List<FObjectTwo__c> lookupRecords1 = (List<FObjectTwo__c>) FObject.getInsertedRecords('FObjectTwo__c');
    Set<Id> recordIdsSet = (new Map<Id, FObjectTwo__c>(lookupRecords1)).keySet();
    List<FObjectTwo__c> lookupRecords2 = (List<FObjectTwo__c>) FObject.getInsertedGroupRecords('FObjectTwo__c', 'One');

    Integer errors = 0;
    for (FObjectOne__c objRecord : records) {
      if (!recordIdsSet.contains(objRecord.TestLookup__c)) {
        errors = 1;
        break;
      }
    }
    if (lookupRecords1.hashCode() == lookupRecords2.hashCode()) {
      errors += 2;
    }
    if (!FObject.processIsValid) {
      errors += 4;
    }
    System.assertEquals(0, errors, 'sddlRandomLookupGroup - errors found');
  }

  @IsTest
  private static void sddlRandomLookupValueForceea_lookupRecordsExist_expectSuccess() {
    // Tests the creation of records with a lookup definition
    // when the lookup object has previously been created by Forceea
    Test.startTest();
    FObject obj1 = new FObject('FObjectTwo__c');
    obj1.setDefinition('TestPicklistA__c', 'random type(picklist)');
    obj1.insertRecords(true);

    FObject obj2 = new FObject('FObjectOne__c');
    obj2.setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) field(TestPicklistA__c) value(A1) source(Forceea)');
    obj2.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj2.getRecords();
    Test.stopTest();

    // get the set of FObjectOne__c.TestLookup__c values
    Set<Id> lookupFieldIdsSet = new Set<Id>();
    for (FObjectOne__c objRecord : records) {
      lookupFieldIdsSet.add(objRecord.TestLookup__c);
    }

    // get the set of FObjectTwo__c IDs
    List<FObjectTwo__c> lookupObjectRecords = new List<FObjectTwo__c>([
      SELECT Id, testPicklistA__c
      FROM FObjectTwo__c
      WHERE Id IN :lookupFieldIdsSet
      LIMIT 1000
    ]);

    Integer errors = 0;
    for (FObjectTwo__c objRecord : lookupObjectRecords) {
      if (objRecord.testPicklistA__c != 'a1') {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random lookup forceea - errors found');
  }

  @IsTest
  private static void sddlRandomLookupValueForceea_lookupRecordsDontExist_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) field(TestpicklistA__c) value(a1) source(Forceea)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    // get the set of FObjectOne__c.TestLookup__c values
    Set<Id> lookupFieldIdsSet = new Set<Id>();
    for (FObjectOne__c objRecord : records) {
      lookupFieldIdsSet.add(objRecord.TestLookup__c);
    }

    // get the set of FObjectTwo__c IDs
    List<FObjectTwo__c> lookupObjectRecords = new List<FObjectTwo__c>([
      SELECT Id, testPicklistA__c
      FROM FObjectTwo__c
      WHERE Id IN :lookupFieldIdsSet
      LIMIT 1000
    ]);

    Integer errors = 0;
    for (FObjectTwo__c objRecord : lookupObjectRecords) {
      if (objRecord.testPicklistA__c != 'a1') {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random lookup forceea - errors found');
  }

  @IsTest
  private static void sddlRandomLookupValueForceea_insertedGroupRecords_expectSuccess() {
    Test.startTest();
    // insert FObjectTwo__c records for group B
    FObject objB1 = new FObject('FObjectTwo__c', 5);
    objB1.setDefinition('TestPicklistA__c', 'static value(a0)');
    objB1.insertRecords(true, 'B');
    // insert FObjectTwo__c records without group
    FObject objB2 = new FObject('FObjectTwo__c', 5);
    objB2.setDefinition('TestPicklistA__c', 'random type(list) value(a1, a2, a3)');
    objB2.insertRecords(true);
    // insert FObjectOne__c records
    FObject objA = new FObject('FObjectOne__c');
    objA.setDefinition('TestLookup__c',
      'random lookup(FObjectTwo__c) field(TestPicklistA__c) value(a0) source(Forceea)');
    objA.insertRecords(true);
    Test.stopTest();

    Integer errors = 0;
    for (FObjectOne__c objRecord : [SELECT TestLookup__r.TestPicklistA__c FROM FObjectOne__c LIMIT 1000]) {
      if (objRecord.TestLookup__r.TestPicklistA__c != 'a0') {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random lookup forceea - errors found');
  }

  @IsTest
  private static void sddlRandomLookupValueSalesforce_lookupRecordsExist_expectSuccess() {
    Test.startTest();
    FObject.setGlobalVerbose('debug');

    FObject objB = new FObject('FObjectTwo__c');
    objB.setDefinition('testPicklistB__c', 'random type(picklist)');
    objB.insertRecords(true);

    FObject objA = new FObject('FObjectOne__c');
    objA.setDefinition('TestLookup__c',
      'random lookup(FObjectTwo__c) field(TestPicklistB__c) value(b3) source(Salesforce)');
    objA.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) objA.getInsertedRecords();
    Test.stopTest();

    Integer errors = 0;
    Set<Id> refObjectIdsSet = (new Map<Id, FObjectTwo__c>(
    [SELECT Id FROM FObjectTwo__c WHERE TestPicklistB__c = 'b3' LIMIT 1000])).keySet();

    for (FObjectOne__c objRecord : records) {
      if (!refObjectIdsSet.contains(objRecord.TestLookup__c)) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random lookup salesforce - errors found');
  }

  @IsTest
  private static void sddlRandomLookupValueSalesforce_lookupRecordsDontExist_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestLookup__c',
      'random lookup(FObjectTwo__c) field(TestPicklistB__c) value(b3) source(Salesforce)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    Integer errors = 0;
    for (FObjectOne__c objRecord : records) {
      if (String.isNotBlank(objRecord.TestLookup__c)) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random lookup salesforce - errors found');
  }

  @IsTest
  private static void sddlRandomLookupValue_invalidField_expectFailure() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition(
      'TestLookup__c', 'random lookup(FObjectTwo__c) field(FieldX) value(Hot) source(Forceea)');
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    String expectedResult = 'Invalid lookup field [FieldX] in definition ' +
      '[random lookup(FObjectTwo__c) field(FieldX) value(Hot) source(Forceea)]';
    String actualResult = obj.getErrors().get('TestLookup__c').get(0);
    System.assertEquals(expectedResult, actualResult, 'random lookup - errors found');
  }

  @IsTest
  private static void sddlRandomLookupExceptForceea_validPicklistArguments_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) ' +
      'field(TestPicklistDRequired__c) except(d0,d1) source(Forceea)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    // get FObjectOne__c.TestLookup__c IDs
    Set<Id> lookupIdsSet = new Set<Id>();
    for (FObjectOne__c objRecord : records) {
      lookupIdsSet.add(objRecord.TestLookup__c);
    }

    // get FObjectTwo__c IDs
    List<String> exclusions = new List<String>{
      'd0', 'd1'
    };
    Set<Id> lookupObjectIdsSet =
      (new Map<Id, FObjectTwo__c>([
        SELECT Id
        FROM FObjectTwo__c
        WHERE TestPicklistDRequired__c NOT IN :exclusions
        LIMIT 1000
      ])).keySet();

    Integer errors = 0;
    for (Id lookupId : lookupIdsSet) {
      if (!lookupObjectIdsSet.contains(lookupId)) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random lookup except - errors found');
  }

  @IsTest
  private static void sddlRandomLookupExceptForceea_validAndInvalidPicklistArguments_expectSuccess() {
    Test.startTest();
    // create FObjectOne records
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) ' +
      'field(TestPicklistDRequired__c) except(d0,d1,s1) source(Forceea)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();
    // get FObjectOne__c.TestLookup__c IDs
    Set<Id> lookupIdsSet = new Set<Id>();
    for (FObjectOne__c objRecord : records) {
      lookupIdsSet.add(objRecord.TestLookup__c);
    }
    // get FObjectTwo__c IDs
    List<String> exclusions = new List<String>{
      'd0', 'd1'
    };
    Set<Id> lookupObjectIdsSet =
      (new Map<Id, FObjectTwo__c>([
        SELECT Id
        FROM FObjectTwo__c
        WHERE TestPicklistDRequired__c NOT IN :exclusions
        LIMIT 1000
      ])).keySet();

    Integer errors = 0;
    for (Id lookupId : lookupIdsSet) {
      if (!lookupObjectIdsSet.contains(lookupId)) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random lookup except - errors found');
  }

  @IsTest
  private static void sddlRandomLookupExceptForceea_invalidPicklistArguments_expectSuccess() {
    Test.startTest();
    // create FObjectOne records
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) ' +
      'field(TestPicklistDRequired__c) except(s1,s2) source(Forceea)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();
    // get FObjectOne__c.TestLookup__c IDs
    Set<Id> lookupIdsSet = new Set<Id>();
    for (FObjectOne__c objRecord : records) {
      lookupIdsSet.add(objRecord.TestLookup__c);
    }
    // get FObjectTwo__c IDs
    Set<Id> lookupObjectIdsSet = (new Map<Id, FObjectTwo__c>([SELECT Id FROM FObjectTwo__c LIMIT 1000])).keySet();
    Integer errors = 0;
    for (Id lookupId : lookupIdsSet) {
      if (!lookupObjectIdsSet.contains(lookupId)) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random lookup except - errors found');
  }

  @IsTest
  private static void sddlRandomLookupExceptSalesforce_validPicklistArguments_expectSuccess() {
    Test.startTest();
    // create FObjectTwo records
    FObject obj1 = new FObject('FObjectTwo__c');
    obj1.setDefinition('TestPicklistA__c', 'random type(list) value(a2,a3)');
    obj1.insertRecords(true);
    List<FObjectTwo__c> records1 = (List<FObjectTwo__c>) obj1.getRecords();
    // create FObjectOne records
    FObject obj2 = new FObject('FObjectOne__c');
    obj2.setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) ' +
      'field(TestPicklistA__c) except(a1,a2) source(Salesforce)');
    obj2.insertRecords(true);
    List<FObjectOne__c> records2 = (List<FObjectOne__c>) obj2.getRecords();
    Test.stopTest();
    // get FObjectOne__c.TestLookup__c IDs
    Set<Id> lookupIdsSet = new Set<Id>();
    for (FObjectOne__c objRecord : records2) {
      lookupIdsSet.add(objRecord.TestLookup__c);
    }
    // get FObjectTwo__c IDs
    List<String> exclusions = new List<String>{
      'a1', 'a2'
    };
    Set<Id> lookupObjectIdsSet =
      (new Map<Id, FObjectTwo__c>([
        SELECT Id
        FROM FObjectTwo__c
        WHERE TestPicklistA__c NOT IN :exclusions
        LIMIT 1000
      ])).keySet();

    Integer errors = 0;
    for (Id lookupId : lookupIdsSet) {
      if (!lookupObjectIdsSet.contains(lookupId)) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random lookup except - errors found');
  }

  @IsTest
  private static void sddlRandomLookupExceptSalesforce_validAndInvalidPicklistArguments_expectSuccess() {
    Test.startTest();
    // create FObjectTwo records
    FObject obj1 = new FObject('FObjectTwo__c');
    obj1.setDefinition('TestPicklistA__c', 'random type(list) value(a2,a3,s1)');
    obj1.insertRecords(true);
    List<FObjectTwo__c> records1 = (List<FObjectTwo__c>) obj1.getRecords();
    // create FObjectOne records
    FObject obj2 = new FObject('FObjectOne__c');
    obj2.setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) ' +
      'field(TestPicklistA__c) except(a1,a2) source(Salesforce)');
    obj2.insertRecords(true);
    List<FObjectOne__c> records2 = (List<FObjectOne__c>) obj2.getRecords();
    Test.stopTest();
    // get FObjectOne__c.TestLookup__c IDs
    Set<Id> lookupIdsSet = new Set<Id>();
    for (FObjectOne__c objRecord : records2) {
      lookupIdsSet.add(objRecord.TestLookup__c);
    }
    // get FObjectTwo__c IDs
    List<String> exclusions = new List<String>{
      'a1', 'a2'
    };
    Set<Id> lookupObjectIdsSet =
      (new Map<Id, FObjectTwo__c>([
        SELECT Id
        FROM FObjectTwo__c
        WHERE TestPicklistA__c NOT IN :exclusions
        LIMIT 1000
      ])).keySet();

    Integer errors = 0;
    for (Id lookupId : lookupIdsSet) {
      if (!lookupObjectIdsSet.contains(lookupId)) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random lookup except - errors found');
  }

  @IsTest
  private static void sddlRandomLookupExceptSalesforce_createLookupRecordsWithBlankPicklistValues_expectSuccess() {
    Test.startTest();
    // create FObjectTwo records
    FObject obj1 = new FObject('FObjectTwo__c');
    obj1.setDefinition('TestPicklistA__c', 'random type(list) value(s1,s2)');
    obj1.insertRecords(true);
    List<FObjectTwo__c> records1 = (List<FObjectTwo__c>) obj1.getRecords();
    // create FObjectOne records
    FObject obj2 = new FObject('FObjectOne__c');
    obj2.setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) ' +
      'field(TestPicklistA__c) except(a1,a2) source(Salesforce)');
    obj2.insertRecords(true);
    List<FObjectOne__c> records2 = (List<FObjectOne__c>) obj2.getRecords();
    Test.stopTest();
    // get FObjectOne__c.TestLookup__c IDs
    Set<Id> lookupIdsSet = new Set<Id>();
    for (FObjectOne__c objRecord : records2) {
      lookupIdsSet.add(objRecord.TestLookup__c);
    }
    // get FObjectTwo__c IDs
    Set<Id> lookupObjectIdsSet = (new Map<Id, FObjectTwo__c>([SELECT Id FROM FObjectTwo__c LIMIT 1000])).keySet();

    Integer errors = 0;
    for (Id lookupId : lookupIdsSet) {
      if (String.isNotBlank(lookupId)) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random lookup except - errors found');
  }

  @IsTest
  private static void sddlRandomLookupExceptGroup_insertedGroupRecords_expectSuccess() {
    Test.startTest();
    // insert FObjectTwo__c records for group B
    FObject objB1 = new FObject('FObjectTwo__c', 5);
    objB1.setDefinition('TestPicklistA__c', 'static value(a0)');
    objB1.insertRecords(true, 'B');
    Set<Id> recordIds1Set = (new Map<Id, SObject>(objB1.getRecords())).keySet();
    // insert FObjectTwo__c records without group
    FObject objB2 = new FObject('FObjectTwo__c', 5);
    objB2.setDefinition('TestPicklistA__c', 'random type(list) value(a1, a2)');
    objB2.insertRecords(true);
    Set<Id> recordIds2Set = (new Map<Id, SObject>(objB2.getRecords())).keySet();
    // insert FObjectOne__c records
    FObject objA = new FObject('FObjectOne__c');
    objA.setDefinition('TestLookup__c',
      'random lookup(FObjectTwo__c) field(TestPicklistA__c) except(a0, a1, a2) group(One) source(Forceea)');
    objA.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) objA.getRecords();
    Test.stopTest();

    Integer errors = 0;
    for (FObjectOne__c objRecord : records) {
      if (recordIds1Set.contains(objRecord.TestLookup__c) || recordIds2Set.contains(objRecord.TestLookup__c)) {
        errors += 1;
      }
    }
    for (FObjectOne__c objRecord : [SELECT TestLookup__r.TestPicklistA__c FROM FObjectOne__c LIMIT 1000]) {
      if (objRecord.TestLookup__r.TestPicklistA__c != 'a3') {
        errors += 2;
        break;
      }
    }
    List<FObjectTwo__c> lookupRecords1 =
      (List<FObjectTwo__c>) FObject.getInsertedGroupRecords('FObjectTwo__c', 'ONE');
    Set<Id> lookupRecordIdsSet1 = (new Map<Id, FObjectTwo__c>(lookupRecords1)).keySet();
    for (FObjectOne__c objRecord : records) {
      if (!lookupRecordIdsSet1.contains(objRecord.TestLookup__c)) {
        errors += 4;
        break;
      }
    }
    List<FObjectTwo__c> lookupRecords2 =
      (List<FObjectTwo__c>) objB1.getInsertedGroupRecords('one');
    Set<Id> lookupRecordIdsSet2 = (new Map<Id, FObjectTwo__c>(lookupRecords2)).keySet();
    if (lookupRecordIdsSet1.hashCode() != lookupRecordIdsSet2.hashCode()) {
      errors += 8;
    }
    if (!FObject.processIsValid) {
      errors += 16;
    }
    System.assertEquals(0, errors, 'random lookup except group - errors found');
  }

  @IsTest
  private static void sddlRandomLookupExceptGroup_blankGroupName_expectFailure() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestLookup__c',
      'random lookup(FObjectTwo__c) field(TestPicklistA__c) except(a1, a2, a3) group() source(Forceea)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    String expectedResult = 'Invalid syntax in definition [random lookup(FObjectTwo__c) field(TestPicklistA__c) ' +
      'except(a1, a2, a3) group() source(Forceea)] of field [TestLookup__c]';
    String actualResult = obj.getErrors().get('TestLookup__c').get(0);
    System.assertEquals(expectedResult, actualResult, 'random lookup except group - errors found');
  }

  @IsTest
  private static void sddlRandomLookupExceptGroup_groupNotExists_expectSuccess() {
    Test.startTest();
    // insert FObjectTwo__c records for group B
    FObject objB1 = new FObject('FObjectTwo__c', 5);
    objB1.setDefinition('TestPicklistA__c', 'static value(a0)');
    objB1.insertRecords(true, 'B');
    Set<Id> recordIdsSet1 = (new Map<Id, SObject>(objB1.getRecords())).keySet();
    // insert FObjectTwo__c records without group
    FObject objB2 = new FObject('FObjectTwo__c', 5);
    objB2.setDefinition('TestPicklistA__c', 'random type(list) value(a1, a2, a3)');
    objB2.insertRecords(true);
    Set<Id> recordIdsSet2 = (new Map<Id, SObject>(objB2.getRecords())).keySet();
    // insert FObjectOne__c records
    FObject objA = new FObject('FObjectOne__c');
    objA.setDefinition('TestLookup__c',
      'random lookup(FObjectTwo__c) field(TestPicklistA__c) except(a1, a2, a3) group(One) source(Forceea)');
    objA.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) objA.getRecords();
    Test.stopTest();

    Integer errors = 0;
    for (FObjectOne__c objRecord : records) {
      if (recordIdsSet1.contains(objRecord.TestLookup__c) || recordIdsSet2.contains(objRecord.TestLookup__c)) {
        errors = 1;
        break;
      }
    }
    for (FObjectOne__c objRecord : [SELECT TestLookup__r.TestPicklistA__c FROM FObjectOne__c LIMIT 1000]) {
      if (objRecord.TestLookup__r.TestPicklistA__c != 'a0') {
        errors += 2;
        break;
      }
    }
    if (!FObject.processIsValid) {
      errors += 4;
    }
    System.assertEquals(0, errors, 'random lookup except group - errors found');
  }

  @IsTest
  private static void sddlRandomLookupWhere_noLookupRecordsCreatedByForceeaOrUser_expectSuccess() {
    Test.startTest();
    // create FObjectOne records
    FObject obj = new FObject('FObjectOne__c');
    String whereClause = 'TestPicklistDRequired__c = \'d1\' AND TestPicklistEUnrestricted__c != \'s1\'';
    obj.setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) where(' + whereClause + ') source(salesforce)');
    obj.insertRecords(true);
    Test.stopTest();

    Integer errors = 0;
    List<FObjectTwo__c> lookupRecords = [SELECT Id FROM FObjectTwo__c LIMIT 1000];
    if (!lookupRecords.isEmpty()) {
      errors += 1;
    }
    for (SObject objRecord : obj.getRecords()) {
      if (String.isNotBlank((String) objRecord.get('TestLookup__c'))) {
        errors += 2;
        break;
      }
    }
    if (!obj.getErrors().isEmpty()) {
      errors += 4;
    }
    if (!FObject.processIsValid) {
      errors += 8;
    }
    System.assertEquals(0, errors, 'random lookup where - errors found');
  }

  @IsTest
  private static void sddlRandomLookupWhere_lookupRecordsAlreadyCreatedByForceea_expectSuccess() {
    Test.startTest();
    // create FObjectTwo records
    FObject obj1 = new FObject('FObjectTwo__c');
    obj1.setDefinition('TestPicklistDRequired__c', 'random type(list) value(d1,d2)');
    obj1.setDefinition('TestPicklistEUnrestricted__c', 'random type(list) value(s1,s2,s3)');
    obj1.insertRecords(true);
    // create FObjectOne records
    FObject obj2 = new FObject('FObjectOne__c');
    String whereClause = 'TestPicklistDRequired__c = \'d1\' AND TestPicklistEUnrestricted__c != \'s1\'';
    obj2.setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) where(' + whereClause + ') source(salesforce)');
    obj2.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj2.getRecords();
    Test.stopTest();
    // get FObjectOne.TestLookup__c IDs
    List<Id> lookupIds = new List<Id>();
    for (FObjectOne__c objRecord : records) {
      lookupIds.add(objRecord.TestLookup__c);
    }
    // get FObjectTwo inserted records
    List<FObjectTwo__c> lookupRecords = [
      SELECT TestPicklistDRequired__c, TestPicklistEUnrestricted__c
      FROM FObjectTwo__c
      WHERE Id IN :lookupIds
      LIMIT 1000
    ];

    Integer errors = 0;
    if (!obj2.getErrors().isEmpty()) {
      errors++;
    }
    for (FObjectTwo__c objRecord : lookupRecords) {
      if (objRecord.TestPicklistDRequired__c != 'd1' && objRecord.TestPicklistEUnrestricted__c == 's1') {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random lookup where - errors found');
  }

  @IsTest
  private static void sddlRandomLookupWhere_lookupRecordsAlreadyCreatedByUser_expectSuccess() {
    Test.startTest();
    // create FObjectTwo records
    List<FObjectTwo__c> newLookupRecords = new List<FObjectTwo__c>();
    List<String> values1 = new List<String>{
      'd1', 'd2'
    };
    List<String> values2 = new List<String>{
      's1', 's2', 's3'
    };
    Integer rnd1 = 0;
    Integer rnd2 = 0;
    for (Integer counter = 1; counter <= 100; counter++) {
      FObjectTwo__c obj = new FObjectTwo__c();
      rnd1 = (Math.random() * values1.size()).intValue();
      obj.TestPicklistDRequired__c = values1[rnd1];
      rnd2 = (Math.random() * values2.size()).intValue();
      obj.TestPicklistEUnrestricted__c = values2[rnd2];
      newLookupRecords.add(obj);
    }
    insert newLookupRecords;
    // create FObjectOne records
    FObject obj2 = new FObject('FObjectOne__c');
    String whereClause = 'TestPicklistDRequired__c = \'d1\' AND TestPicklistEUnrestricted__c != \'s1\'';
    obj2.setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) where(' + whereClause + ') source(salesforce)');
    obj2.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj2.getRecords();
    Test.stopTest();
    // get FObjectOne.TestLookup__c IDs
    List<Id> lookupIds = new List<Id>();
    for (FObjectOne__c objRecord : records) {
      lookupIds.add(objRecord.TestLookup__c);
    }
    // get FObjectTwo inserted records
    List<FObjectTwo__c> lookupRecords = [
      SELECT TestPicklistDRequired__c, TestPicklistEUnrestricted__c
      FROM FObjectTwo__c
      WHERE Id IN :lookupIds
      LIMIT 1000
    ];

    Integer errors = 0;
    for (FObjectTwo__c objRecord : lookupRecords) {
      if (objRecord.TestPicklistDRequired__c != 'd1' || objRecord.TestPicklistEUnrestricted__c == 's1') {
        errors++;
      }
    }
    if (!obj2.getErrors().isEmpty()) {
      errors++;
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random lookup where - errors found');
  }

  @IsTest
  private static void sddlRandomLookupWhere_invalidWhereClause_expectFailure() {
    Test.startTest();
    // create FObjectTwo records
    FObject obj1 = new FObject('FObjectTwo__c');
    obj1.setDefinition('TestPicklistDRequired__c', 'random type(list) value(d1,d2)');
    obj1.setDefinition('TestPicklistEUnrestricted__c', 'random type(list) value(s1,s2,s3)');
    obj1.insertRecords(true);
    // create FObjectOne records
    FObject obj2 = new FObject('FObjectOne__c');
    String whereClause = 'TestPicklistDRequired__c = \'d1\' AND wrongField != \'s1\'';
    obj2.setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) where(' +
      whereClause + ') source(salesforce)');
    obj2.insertRecords(true);
    Test.stopTest();

    String expectedResult = 'Found errors selecting records from the lookup object [FObjectTwo__c]' +
      ' for object [FObjectOne__c]';
    String actualResult = obj2.getErrors().get('TestLookup__c').get(0);
    Boolean result = actualResult.startsWith(expectedResult);
    System.assertEquals(true, result, 'random lookup where - errors found');
  }

  @IsTest
  private static void sddlRandomDate_fromLessThanTo_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestDate__c', 'random type("date ") from(2018-01-01) to(2018-01-10)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    Integer errors = 0;
    Date fromDate = Date.newInstance(2018, 1, 1);
    Date toDate = Date.newInstance(2018, 1, 10);
    for (FObjectOne__c objRecord : records) {
      if (objRecord.TestDate__c < fromDate || objRecord.TestDate__c > toDate) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random date - errors found');
  }

  @IsTest
  private static void sddlRandomDate_fromEqualsTo_expectFailure() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestDate__c', 'random type(date) from(2018-01-01) to(2018-1-1)');
    obj.insertRecords(true);

    String expectedResult = 'The [from] date is greater than or equal to the [to] date in definition [' +
      'random type(date) from(2018-01-01) to(2018-1-1)]';
    String actualResult = obj.getErrors().get('TestDate__c').get(0);
    System.assertEquals(expectedResult, actualResult, 'random date - errors found');
  }

  @IsTest
  private static void sddlRandomDate_fromGreaterThanTo_expectFailure() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestDate__c', 'random type(date) from(2018-1-10) to(2018-01-01)');
    obj.insertRecords(true);
    Test.stopTest();

    String expectedResult = 'The [from] date is greater than or equal to the [to] date in definition [' +
      'random type(date) from(2018-1-10) to(2018-01-01)]';
    String actualResult = obj.getErrors().get('TestDate__c').get(0);
    System.assertEquals(expectedResult, actualResult, 'random date - errors found');
  }

  @IsTest
  private static void sddlRandomDatetime_fromDatetimeLessThanToDatetimeSameDay_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestDatetime__c', 'random type("datetime") from(2018-01-01 01:01:01) to(2018-01-01 02:02:02)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    Integer errors = 0;
    Long dtFrom = DateTime.newInstance(2018, 1, 1, 1, 1, 1).getTime();
    Long dtTo = DateTime.newInstance(2018, 1, 1, 2, 2, 2).getTime();
    for (FObjectOne__c objRecord : records) {
      if (objRecord.TestDatetime__c.getTime() < dtFrom || objRecord.TestDatetime__c.getTime() > dtTo) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random datetime - errors found');
  }

  @IsTest
  private static void sddlRandomDatetime_fromDatetimeLessThanToDatetimeDifferentDay_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestDatetime__c', 'random type(datetime) from(" 2018-01-01 01:01:01") to(2018-01-02 02:02:02)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    Integer errors = 0;
    Long dtFrom = DateTime.newInstance(2018, 1, 1, 1, 1, 1).getTime();
    Long dtTo = DateTime.newInstance(2018, 1, 2, 2, 2, 2).getTime();
    for (FObjectOne__c objRecord : records) {
      if (objRecord.TestDatetime__c.getTime() < dtFrom || objRecord.TestDatetime__c.getTime() > dtTo) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random datetime - errors found');
  }

  @IsTest
  private static void sddlRandomDatetime_fromDatetimeLessThanToDateSameDay_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestDatetime__c', 'random type(datetime) from(2018-01-01 01:01:01) to(2018-01-01)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    Integer errors = 0;
    Long dtFrom = DateTime.newInstance(2018, 1, 1, 1, 1, 1).getTime();
    Long dtTo = DateTime.newInstance(2018, 1, 1, 23, 59, 59).getTime();
    for (FObjectOne__c objRecord : records) {
      if (objRecord.TestDatetime__c.getTime() < dtFrom || objRecord.TestDatetime__c.getTime() > dtTo) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random datetime - errors found');
  }

  @IsTest
  private static void sddlRandomDatetime_fromDatetimeLessThanToDateDifferentDay_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestDatetime__c', 'random type(datetime) from(2018-01-01 01:01:01) to(2018-01-05)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    Integer errors = 0;
    Long dtFrom = DateTime.newInstance(2018, 1, 1, 1, 1, 1).getTime();
    Long dtTo = DateTime.newInstance(2018, 1, 5, 23, 59, 59).getTime();
    for (FObjectOne__c objRecord : records) {
      if (objRecord.TestDatetime__c.getTime() < dtFrom || objRecord.TestDatetime__c.getTime() > dtTo) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random datetime - errors found');
  }

  @IsTest
  private static void sddlRandomDatetime_fromDateLessThanToDatetimeSameDay_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestDatetime__c', 'random type(datetime) from(2018-01-01) to(2018-01-01 01:01:01)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    Integer errors = 0;
    Long dtFrom = DateTime.newInstance(2018, 1, 1, 0, 0, 0).getTime();
    Long dtTo = DateTime.newInstance(2018, 1, 1, 1, 1, 1).getTime();
    for (FObjectOne__c objRecord : records) {
      if (objRecord.TestDatetime__c.getTime() < dtFrom || objRecord.TestDatetime__c.getTime() > dtTo) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random datetime - errors found');
  }

  @IsTest
  private static void sddlRandomDatetime_fromDateLessThanToDatetimeDifferentDay_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestDatetime__c', 'random type(datetime) from(2018-01-01) to(2018-01-05 01:01:01)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    Integer errors = 0;
    Long dtFrom = DateTime.newInstance(2018, 1, 1, 0, 0, 0).getTime();
    Long dtTo = DateTime.newInstance(2018, 1, 5, 1, 1, 1).getTime();
    for (FObjectOne__c objRecord : records) {
      if (objRecord.TestDatetime__c.getTime() < dtFrom || objRecord.TestDatetime__c.getTime() > dtTo) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random datetime - errors found');
  }

  @IsTest
  private static void sddlRandomDatetime_fromDateLessThanToDate_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestDatetime__c', 'random type(datetime) from(2018-1-1) to(2018-1-5)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    Integer errors = 0;
    Long dtFrom = DateTime.newInstance(2018, 1, 1, 0, 0, 0).getTime();
    Long dtTo = DateTime.newInstance(2018, 1, 5, 0, 0, 0).getTime();
    for (FObjectOne__c objRecord : records) {
      if (objRecord.TestDatetime__c.getTime() < dtFrom || objRecord.TestDatetime__c.getTime() > dtTo) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random datetime - errors found');
  }

  @IsTest
  private static void sddlRandomDatetime_fromDateEqualsToDate_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestDatetime__c', 'random type(datetime) from(2018-1-1) to(2018-1-1)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    Integer errors = 0;
    Long dtFrom = DateTime.newInstance(2018, 1, 1, 0, 0, 0).getTime();
    Long dtTo = DateTime.newInstance(2018, 1, 1, 23, 59, 59).getTime();
    for (FObjectOne__c objRecord : records) {
      if (objRecord.TestDatetime__c.getTime() < dtFrom || objRecord.TestDatetime__c.getTime() > dtTo) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random datetime - errors found');
  }

  @IsTest
  private static void sddlRandomDatetime_fromDatetimeEqualsToDatetime_expectFailure() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestDatetime__c', 'random type(datetime) from(2018-01-01 01:01:01) to(2018-01-01 01:01:01)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    String expectedResult = 'The [from] datetime is greater than or equal to the [to] datetime in definition ' +
      '[random type(datetime) from(2018-01-01 01:01:01) to(2018-01-01 01:01:01)]';
    String actualResult = obj.getErrors().get('TestDatetime__c').get(0);
    System.assertEquals(expectedResult, actualResult, 'random datetime - errors found');
  }

  @IsTest
  private static void sddlRandomDatetime_fromDatetimeGreaterThanToDatetime_expectFailure() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestDatetime__c', 'random type(datetime) from(2018-01-01 02:02:02) to(2018-01-01 01:01:01)');
    obj.insertRecords(true);
    Test.stopTest();

    String expectedResult = 'The [from] datetime is greater than or equal to the [to] datetime in definition ' +
      '[random type(datetime) from(2018-01-01 02:02:02) to(2018-01-01 01:01:01)]';
    String actualResult = obj.getErrors().get('TestDatetime__c').get(0);
    System.assertEquals(expectedResult, actualResult, 'random datetime - errors found');
  }

  @IsTest
  private static void sddlRandomDatetime_fromDatetimeGreaterThanToDate_expectFailure() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestDatetime__c', 'random type(datetime) from(2018-01-02 01:01:01) to(2018-01-01)');
    obj.insertRecords(true);
    Test.stopTest();

    String expectedResult = 'The [from] datetime is greater than or equal to the [to] datetime in definition ' +
      '[random type(datetime) from(2018-01-02 01:01:01) to(2018-01-01)]';
    String actualResult = obj.getErrors().get('TestDatetime__c').get(0);
    System.assertEquals(expectedResult, actualResult, 'random datetime - errors found');
  }

  @IsTest
  private static void sddlRandomDatetime_fromDateGreaterThanToDatetime_expectFailure() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestDatetime__c', 'random type(datetime) from(2018-01-02) to(2018-01-01 01:01:01)');
    obj.insertRecords(true);
    Test.stopTest();

    String expectedResult = 'The [from] datetime is greater than or equal to the [to] datetime in definition ' +
      '[random type(datetime) from(2018-01-02) to(2018-01-01 01:01:01)]';
    String actualResult = obj.getErrors().get('TestDatetime__c').get(0);
    System.assertEquals(expectedResult, actualResult, 'random datetime - errors found');
  }

  @IsTest
  private static void sddlRandomFirstName_incorrectLanguageAndLocality_expectSuccess() {
    loadNamesFromUnitesStatesInEnglish();

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    FObject.Language = 'Language';
    FObject.Locality = 'Locality';
    obj.setDefinition('TestText__c', 'random type(firstname) group(a)');
    List<FObjectOne__c> records = obj.getRecords();
    Test.stopTest();

    Integer errors = 0;
    for (FObjectOne__c objRecord : records) {
      if (!femaleFirstNames.contains(objRecord.TestText__c) && !maleFirstNames.contains(objRecord.TestText__c)) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random name errors found');
  }

  @IsTest
  private static void sddlRandomLastName_incorrectLanguageAndLocality_expectSuccess() {
    loadNamesFromUnitesStatesInEnglish();

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    FObject.Language = 'Language';
    FObject.Locality = 'Locality';
    obj.setDefinition('TestText__c', 'random type(lastname) group(a)');
    List<FObjectOne__c> records = obj.getRecords();
    Test.stopTest();

    Integer errors = 0;
    for (FObjectOne__c objRecord : records) {
      if (!femaleLastNames.contains(objRecord.TestText__c) && !maleLastNames.contains(objRecord.TestText__c)) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random nameerrors found');
  }

  @IsTest
  private static void sddlRandomFirstLastName_fromGreeceInGreek_expectSuccess() {
    loadNamesFromGreeceInGreek();

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    FObject.Language = 'Greek';
    FObject.Locality = 'Greece';
    obj.setDefinition('TestText__c', 'random type(firstname) group(a)');
    obj.setDefinition('TestTextArea__c', 'random type(lastname) group(a)');
    List<FObjectOne__c> records = obj.getRecords();
    Test.stopTest();

    Integer errors = 0;
    for (FObjectOne__c objRecord : records) {
      if (!femaleFirstNames.contains(objRecord.TestText__c) && !maleFirstNames.contains(objRecord.TestText__c)) {
        errors++;
      }
      if (!femaleLastNames.contains(objRecord.TestTextArea__c) && !maleLastNames.contains(objRecord.TestTextArea__c)) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random name - errors found');
  }

  @IsTest
  private static void sddlRandomFirstLastName_fromUnitedStatesInEnglish_expectSuccess() {
    loadNamesFromUnitesStatesInEnglish();

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    FObject.Language = 'English';
    FObject.Locality = 'United States';
    obj.setDefinition('TestText__c', 'random type(firstname) group(a)');
    obj.setDefinition('TestTextArea__c', 'random type(lastname) group(a)');
    List<FObjectOne__c> records = obj.getRecords();
    Test.stopTest();

    Integer errors = 0;
    for (FObjectOne__c objRecord : records) {
      if (!femaleFirstNames.contains(objRecord.TestText__c) && !maleFirstNames.contains(objRecord.TestText__c)) {
        errors++;
      }
      if (!femaleLastNames.contains(objRecord.TestTextArea__c) && !maleLastNames.contains(objRecord.TestTextArea__c)) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random name - errors found');
  }

  @IsTest
  private static void sddlRandomStreet_fromUnitedStatesInEnglish_expectSuccess() {
    FObject.Language = 'English';
    FObject.Locality = 'United States';
    FObject.loadAddresses();
    List<String> values = new List<String>();
    Set<String> valuesSet = new Set<String>();
    for (FObject.FAddress address : FObject.addressesLibrary) {
      values.add(address.street);
      valuesSet.add(address.street);
    }

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c', 1000);
    obj.setDefinition('TestText__c', 'random type(street) group(shipping)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    Integer errors = 0;
    String value = '';
    for (FObjectOne__c objRecord : records) {
      value = objRecord.TestText__c.substringAfter(' ');
      if (!valuesSet.contains(value)) {
        errors++;
      }
    }
    for (FObjectOne__c objRecord : records) {
      objRecord.TestText__c = objRecord.TestText__c.substringAfter(' ');
    }
    if (!isValidDistribution('TestText__c', values, records)) {
      errors++;
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random street - errors found');
  }

  @IsTest
  private static void sddlRandomStreet_fromGreeceInGreek_expectSuccess() {
    FObject.Language = 'Greek';
    FObject.Locality = 'Greece';
    FObject.loadAddresses();
    List<String> values = new List<String>();
    Set<String> valuesSet = new Set<String>();
    for (FObject.FAddress address : FObject.addressesLibrary) {
      values.add(address.street);
      valuesSet.add(address.street);
    }

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c', 1000);
    obj.setDefinition('TestText__c', 'random type(street) group(shipping)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    Integer errors = 0;
    String value = '';
    for (FObjectOne__c objRecord : records) {
      value = objRecord.TestText__c.substringBeforeLast(' ');
      if (!valuesSet.contains(value)) {
        errors++;
      }
    }
    for (FObjectOne__c objRecord : records) {
      objRecord.TestText__c = objRecord.TestText__c.substringBeforeLast(' ');
    }
    if (!isValidDistribution('TestText__c', values, records)) {
      errors++;
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random street - errors found');
  }

  @IsTest
  private static void sddlRandomCity_fromUnitedStatesInEnglish_expectSuccess() {
    FObject.Language = 'English';
    FObject.Locality = 'United States';
    FObject.loadAddresses();
    List<String> values = new List<String>();
    Set<String> valuesSet = new Set<String>();
    for (FObject.FAddress address : FObject.addressesLibrary) {
      values.add(address.city);
      valuesSet.add(address.city);
    }

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c', 1000);
    obj.setDefinition('TestText__c', 'random type(city) group(shipping)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    Integer errors = 0;
    String value = '';
    for (FObjectOne__c objRecord : records) {
      value = objRecord.TestText__c;
      if (!valuesSet.contains(value)) {
        errors++;
      }
    }
    for (FObjectOne__c objRecord : records) {
      objRecord.TestText__c = objRecord.TestText__c;
    }
    if (!isValidDistribution('TestText__c', values, records)) {
      errors++;
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random city - errors found');
  }

  @IsTest
  private static void sddlRandomCity_fromGreeceInGreek_expectSuccess() {
    FObject.Language = 'Greek';
    FObject.Locality = 'Greece';
    FObject.loadAddresses();
    List<String> values = new List<String>();
    Set<String> valuesSet = new Set<String>();
    for (FObject.FAddress address : FObject.addressesLibrary) {
      values.add(address.city);
      valuesSet.add(address.city);
    }

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c', 1000);
    obj.setDefinition('TestText__c', 'random type(city) group(shipping)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    Integer errors = 0;
    String value = '';
    for (FObjectOne__c objRecord : records) {
      value = objRecord.TestText__c;
      if (!valuesSet.contains(value)) {
        errors++;
      }
    }
    if (!isValidDistribution('TestText__c', values, records)) {
      errors++;
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random city - errors found');
  }

  @IsTest
  private static void sddlRandomPostalCode_fromUnitedStatesInEnglish_expectSuccess() {
    FObject.Language = 'English';
    FObject.Locality = 'United States';
    FObject.loadAddresses();
    List<String> values = new List<String>();
    Set<String> valuesSet = new Set<String>();
    for (FObject.FAddress address : FObject.addressesLibrary) {
      values.add(address.postalcode);
      valuesSet.add(address.postalcode);
    }

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c', 1000);
    obj.setDefinition('TestText__c', 'random type(postalcode) group(shipping)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    Integer errors = 0;
    String value = '';
    for (FObjectOne__c objRecord : records) {
      value = objRecord.TestText__c;
      if (!valuesSet.contains(value)) {
        errors++;
      }
    }
    for (FObjectOne__c objRecord : records) {
      objRecord.TestText__c = objRecord.TestText__c;
    }
    if (!isValidDistribution('TestText__c', values, records)) {
      errors++;
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random postalcode - errors found');
  }

  @IsTest
  private static void sddlRandomPostalCode_fromGreeceInGreek_expectSuccess() {
    FObject.Language = 'Greek';
    FObject.Locality = 'Greece';
    FObject.loadAddresses();
    List<String> values = new List<String>();
    Set<String> valuesSet = new Set<String>();
    for (FObject.FAddress address : FObject.addressesLibrary) {
      values.add(address.postalcode);
      valuesSet.add(address.postalcode);
    }

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c', 1000);
    obj.setDefinition('TestText__c', 'random type(postalcode) group(shipping)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    Integer errors = 0;
    String value = '';
    for (FObjectOne__c objRecord : records) {
      value = objRecord.TestText__c;
      if (!valuesSet.contains(value)) {
        errors++;
      }
    }
    for (FObjectOne__c objRecord : records) {
      objRecord.TestText__c = objRecord.TestText__c;
    }
    if (!isValidDistribution('TestText__c', values, records)) {
      errors++;
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random postalcode - errors found');
  }

  @IsTest
  private static void sddlRandomState_fromUnitedStatesInEnglish_expectSuccess() {
    FObject.Language = 'English';
    FObject.Locality = 'United States';
    FObject.loadAddresses();
    List<String> values = new List<String>();
    Set<String> valuesSet = new Set<String>();
    for (FObject.FAddress address : FObject.addressesLibrary) {
      values.add(address.state);
      valuesSet.add(address.state);
    }

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c', 1000);
    obj.setDefinition('TestText__c', 'random type(state) group(shipping)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    Integer errors = 0;
    String value = '';
    for (FObjectOne__c objRecord : records) {
      value = objRecord.TestText__c;
      if (!valuesSet.contains(value)) {
        errors++;
      }
    }
    for (FObjectOne__c objRecord : records) {
      objRecord.TestText__c = objRecord.TestText__c;
    }
    if (!isValidDistribution('TestText__c', values, records)) {
      errors++;
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random state - errors found');
  }

  @IsTest
  private static void sddlRandomCountry_fromUnitedStatesInEnglish_expectSuccess() {
    FObject.Language = 'English';
    FObject.Locality = 'United States';
    FObject.loadAddresses();
    List<String> values = new List<String>();
    Set<String> valuesSet = new Set<String>();
    for (FObject.FAddress address : FObject.addressesLibrary) {
      values.add(address.country);
      valuesSet.add(address.country);
    }

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c', 1000);
    obj.setDefinition('TestText__c', 'random type(country) group(shipping)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    Integer errors = 0;
    String value = '';
    for (FObjectOne__c objRecord : records) {
      value = objRecord.TestText__c;
      if (!valuesSet.contains(value)) {
        errors++;
      }
    }
    for (FObjectOne__c objRecord : records) {
      objRecord.TestText__c = objRecord.TestText__c;
    }
    if (!isValidDistribution('TestText__c', values, records)) {
      errors++;
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random country - errors found');
  }

  @IsTest
  private static void sddlRandomCountry_fromGreeceInGreek_expectSuccess() {
    FObject.Language = 'Greek';
    FObject.Locality = 'Greece';
    FObject.loadAddresses();
    List<String> values = new List<String>();
    Set<String> valuesSet = new Set<String>();
    for (FObject.FAddress address : FObject.addressesLibrary) {
      values.add(address.country);
      valuesSet.add(address.country);
    }

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c', 1000);
    obj.setDefinition('TestText__c', 'random type(country) group(shipping)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    Integer errors = 0;
    String value = '';
    for (FObjectOne__c objRecord : records) {
      value = objRecord.TestText__c;
      if (!valuesSet.contains(value)) {
        errors++;
      }
    }
    for (FObjectOne__c objRecord : records) {
      objRecord.TestText__c = objRecord.TestText__c;
    }
    if (!isValidDistribution('TestText__c', values, records)) {
      errors++;
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random country - errors found');
  }

  @IsTest
  private static void sddlRandomList_integerArguments_expectSuccess() {
    List<String> arguments = new List<String>{
      '1.0', '2.0', '3.0', '0.0'
    };

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestInteger__c', 'random type(list) value(1, 2, 3, 0)');
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    obj.insertRecords(true);
    Test.stopTest();

    Boolean expectedResult = true;
    Boolean actualResult = isValidDistribution('TestInteger__c', arguments, records);
    System.assertEquals(expectedResult, actualResult, 'random list - errors found');
  }

  @IsTest
  private static void sddlRandomList_decimalArguments_expectSuccess() {
    List<String> arguments = new List<String>{
      '1.0', '2.22', '0.0', '3.0'
    };

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestDecimal__c', 'random type(list) value(1, 2.22, 0.0, 3)');
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    obj.insertRecords(true);
    Test.stopTest();

    Boolean expectedResult = true;
    Boolean actualResult = isValidDistribution('TestDecimal__c', arguments, records);
    System.assertEquals(expectedResult, actualResult, 'random list - errors found');
  }

  @IsTest
  private static void sddlRandomList_dateArguments_expectSuccess() {
    List<String> arguments = new List<String>{
      '2018-01-01 00:00:00', '2017-01-01 00:00:00', '2016-01-01 00:00:00', '2015-01-01 00:00:00'
    };

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestDate__c', 'random type(list) value(2018-01-01, 2017-01-01, 2016-01-01, 2015-01-01)');
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    obj.insertRecords(true);
    Test.stopTest();

    Boolean expectedResult = true;
    Boolean actualResult = isValidDistribution('TestDate__c', arguments, records);
    System.assertEquals(expectedResult, actualResult, 'random list - errors found');
  }

  @IsTest
  private static void sddlRandomList_datetimeArguments_expectSuccess() {
    List<Datetime> arguments = new List<Datetime>();
    arguments.add(Datetime.newInstance(2018, 1, 1, 0, 0, 0));
    arguments.add(Datetime.newInstance(2017, 1, 1, 1, 1, 1));
    arguments.add(Datetime.newInstance(2016, 1, 1, 2, 2, 2));
    arguments.add(Datetime.newInstance(2015, 1, 1, 3, 3, 3));

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestDateTime__c', 'random type(list) value(2018-01-01 00:00:00, 2017-01-01 01:01:01, 2016-01-01 02:02:02, 2015-01-01 03:03:03)');
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    obj.insertRecords(true);
    Test.stopTest();

    Boolean expectedResult = true;
    Boolean actualResult = isValidDistribution('TestDateTime__c', arguments, records);
    System.assertEquals(expectedResult, actualResult, 'random list - errors found');
  }

  @IsTest
  private static void sddlRandomList_timeArguments_expectSuccess() {
    List<String> arguments = new List<String>{
      '01:01:01.000Z', '02:02:02.000Z', '03:03:03.000Z', '04:04:04.000Z'
    };

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestTime__c', 'random type(list) value(01:01:01, 02:02:02, 03:03:03, 04:04:04)');
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    obj.insertRecords(true);
    Test.stopTest();

    Boolean expectedResult = true;
    Boolean actualResult = isValidDistribution('TestTime__c', arguments, records);
    System.assertEquals(expectedResult, actualResult, 'random list - errors found');
  }

  @IsTest
  private static void sddlRandomList_stringArguments_expectSuccess() {
    List<String> arguments = new List<String>{
      'One', 'Two', 'Three', 'Twenty One'
    };

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestText__c', 'random type(list) value(One,Two,Three,Twenty One)');
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    obj.insertRecords(true);
    Test.stopTest();

    Boolean expectedResult = true;
    Boolean actualResult = isValidDistribution('TestText__c', arguments, records);
    System.assertEquals(expectedResult, actualResult, 'random list - errors found');
  }

  @IsTest
  private static void sddlRandomList_restrictedIndependentPicklistField_expectSuccess() {
    List<String> arguments = new List<String>{
      'a0', 'a1', 'a2'
    };

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestPicklistA__c', 'random type(list) value(a0, a1, a2, a4)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    Boolean expectedResult = true;
    Boolean actualResult = isValidDistribution('TestPicklistA__c', arguments, records);
    System.assertEquals(expectedResult, actualResult, 'random list - errors found');
  }

  @IsTest
  private static void sddlRandomList_restrictedDependentPicklistField_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestPicklistB__c', 'random type(list) value(b0, b1, b2, b4, b5)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    // set mapping
    Set<String> picklistA0Mapping = new Set<String>{
      ''
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
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random picklist - errors found');
  }

  @IsTest
  private static void sddlRandomList_unrestrictedIndependentPicklistField_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectTwo__c');
    obj.setDefinition('TestPicklistEUnrestricted__c', 'random type(list) value(e1, e4, e5, d1, d2)');
    obj.insertRecords(true);
    List<FObjectTwo__c> records = (List<FObjectTwo__c>) obj.getRecords();
    Test.stopTest();

    Boolean expectedResult = true;
    List<String> arguments = new List<String>{
      'e1', 'e4', 'e5', 'd1', 'd2'
    };
    Boolean actualResult = isValidDistribution('TestPicklistEUnrestricted__c', arguments, records);
    System.assertEquals(expectedResult, actualResult, 'random list - errors found');
  }

  @IsTest
  private static void sddlRandomList_unrestrictedDependentPicklistField_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectTwo__c');
    obj.setDefinition('TestPicklistFUnrestricted__c', 'random type(list) value(f0, f1, f4, f5, e1, e2)');
    Database.SaveResult[] saveResults = obj.insertRecords(false);
    List<FObjectTwo__c> records = (List<FObjectTwo__c>) obj.getRecords();
    Test.stopTest();

    Integer errors = 0;
    for (Database.SaveResult sr : saveResults) {
      if (!sr.isSuccess()) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random list - errors found');
  }

  @IsTest
  private static void sddlRandomList_controllingFieldIsCheckbox_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestCheckbox__c', 'static value(true)');
    obj.setDefinition('TestpicklistD__c', 'random type(list) value(d2, d3)');
    Database.SaveResult[] saveResults = obj.insertRecords(false);
    Test.stopTest();

    Integer errors = 0;
    for (Database.SaveResult sr : saveResults) {
      if (!sr.isSuccess()) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random list - errors found');
  }

  @IsTest
  private static void sddlRandomList_oneRecordType_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('RecordTypeId', 'random type(list) value(RecordTypeA)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    Boolean expectedResult = true;
    Id recordType1Id = Schema.SObjectType.FObjectOne__c.getRecordTypeInfosByName().get('Record Type A').getRecordTypeId();
    List<String> arguments = new List<String>{
      recordType1Id
    };
    Boolean actualResult = isValidDistribution('RecordTypeId', arguments, records);
    System.assertEquals(expectedResult, actualResult, 'random list - errors found');
  }

  @IsTest
  private static void sddlRandomList_manyRecordTypes_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('RecordTypeId', 'random type(list) value(RecordTypeA, RecordTypeB)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    Boolean expectedResult = true;
    Id recordType1Id = Schema.SObjectType.FObjectOne__c.getRecordTypeInfosByName().get('Record Type A').getRecordTypeId();
    Id recordType2Id = Schema.SObjectType.FObjectOne__c.getRecordTypeInfosByName().get('Record Type B').getRecordTypeId();
    List<String> arguments = new List<String>{
      recordType1Id, recordType2Id
    };
    Boolean actualResult = isValidDistribution('RecordTypeId', arguments, records);
    System.assertEquals(expectedResult, actualResult, 'random list - errors found');
  }

  @IsTest
  private static void sddlRandomList_doubleQuotes_expectSuccess() {
    List<String> arguments = new List<String>{
      'v1xyz', 'v2 xyz', 'v3xyz', 'v4 xyz'
    };

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestText__c', 'random type(" list ") value(v1, "v2 ", " v3", " v4 ")');
    obj.setDefinition('TestText__c', 'static value(xyz)');
    obj.insertRecords(true);
    Test.stopTest();

    List<FObjectOne__c> records = [SELECT TestText__c FROM FObjectOne__c LIMIT 1000];
    Boolean expectedResult = true;
    Boolean actualResult = isValidDistribution('TestText__c', arguments, records);
    System.assertEquals(expectedResult, actualResult, 'random list - errors found');
  }

  @IsTest
  private static void sddlRandomList_invalidRecordType_expectFailure() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('RecordTypeId', 'random type(list) value(RecordTypeX)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    String expectedResult = 'Invalid record type [RecordTypeX] for definition [random type(list) value(RecordTypeX)]';
    String actualResult = obj.getErrors().get('RecordTypeId').get(0);
    System.assertEquals(expectedResult, actualResult, 'random list - errors found');
  }

  @IsTest
  private static void sddlRandomNumber_integerArgument_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('Account'); // should use the Account object
    obj.setDefinition('NumberOfEmployees', 'random type(number) from(1) to(100) scale(0)');
    List<Account> records = (List<Account>) obj.getRecords();
    Test.stopTest();

    Integer errors = 0;
    for (Account objRecord : records) {
      if (objRecord.NumberOfEmployees < 1 || objRecord.NumberOfEmployees > 100) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random number - errors found');
  }

  @IsTest
  private static void sddlRandomNumber_decimalArgument_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestDecimal__c', 'random type(number) from(1) to(50.12) scale(2)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    Integer errors = 0;
    for (FObjectOne__c objRecord : records) {
      if (objRecord.testDecimal__c < 1 || objRecord.testDecimal__c > 50.12) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random number - errors found');
  }

  @IsTest
  private static void sddlRandomNumber_fromEqualsTo_expectFailure() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestDecimal__c', 'random type(number) from(10) to(10) scale(2)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    String expectedResult = 'The [from] number is greater than or equal to the [to] number ' +
      'in definition [random type(number) from(10) to(10) scale(2)]';
    String actualResult = obj.getErrors().get('TestDecimal__c').get(0);
    System.assertEquals(expectedResult, actualResult, 'random number - errors found');
  }

  @IsTest
  private static void sddlRandomNumber_fromGreaterThanTo_expectFailure() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestDecimal__c', 'random type(number) from(12) to(10) scale(2)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    String expectedResult = 'The [from] number is greater than or equal to the [to] number ' +
      'in definition [random type(number) from(12) to(10) scale(2)]';
    String actualResult = obj.getErrors().get('TestDecimal__c').get(0);
    System.assertEquals(expectedResult, actualResult, 'random number - errors found');
  }

  @IsTest
  private static void sddlRandomPhone_independentPicklistField_expectSuccess() {
    String formatString = '(30) 210 dd-11-1DD';

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestPhone__c', 'random type(phone) format("' + formatString + '")');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getInsertedRecords();
    Test.stopTest();

    Integer value = 0;
    Integer errors = 0;
    List<String> formatChars = formatString.split('');

    for (FObjectOne__c objRecord : records) {
      List<Integer> charValues = objRecord.TestPhone__c.getChars();
      List<String> phoneChars = objRecord.TestPhone__c.split('');

      for (Integer counter = 0; counter < formatChars.size(); counter++) {
        value = charValues[counter] - 48;
        if (formatChars[counter] == 'd') {
          if (value < 1 || value > 9) {
            errors++;
          }
        } else if (formatChars[counter] == 'D') {
          value = charValues[counter] - 48;
          if (value < 0 || value > 9) {
            errors++;
          }
        } else if (formatChars[counter] != phoneChars[counter]) {
          errors++;
        }
      }
    }

    System.assertEquals(0, errors, 'random phone number - errors found');
  }

  @IsTest
  private static void sddlRandomPicklist_independentPicklistField_expectSuccess() {
    List<String> arguments = new List<String>{
      'a0', 'a1', 'a2', 'a3'
    };

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestPicklistA__c', 'random type(picklist)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    Boolean expectedResult = true;
    Boolean actualResult = isValidDistribution('TestPicklistA__c', arguments, records);
    System.assertEquals(expectedResult, actualResult, 'random picklist - errors found');
  }

  @IsTest
  private static void sddlRandomPicklist_dependentPicklistField_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestPicklistC__c', 'random type(picklist)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    // set mapping
    Set<String> picklistA0Mapping = new Set<String>{
      ''
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
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random picklist - errors found');
  }

  @IsTest
  private static void sddlRandomPicklist_controllingFieldAfterDependentField_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestPicklistB__c', 'random type(picklist)');
    obj.setDefinition('TestPicklistA__c', 'random type(picklist)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    // set mapping
    Set<String> picklistA0Mapping = new Set<String>{''};
    Set<String> picklistA1Mapping = new Set<String>{'b1'};
    Set<String> picklistA2Mapping = new Set<String>{'b1', 'b2'};
    Set<String> picklistA3Mapping = new Set<String>{'b1', 'b2', 'b3'};

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
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random picklist - errors found');
  }

  @IsTest
  private static void sddlRandomPicklist_controllingFieldIsCheckbox_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestCheckbox__c', 'static value(true)');
    obj.setDefinition('TestPicklistD__c', 'random type(picklist)');
    obj.insertRecords(false);
    Test.stopTest();

    Boolean expectedResult = false;
    Boolean actualResult = obj.getErrors().isEmpty();
    System.assertEquals(expectedResult, actualResult, 'random picklist - errors found');
  }

  @IsTest
  private static void sddlRandomPicklist_definitionsOfDependentPicklists_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestPicklistC__c', 'random type(picklist)');
    obj.setDefinition('RecordTypeId', 'static value(RecordTypeA)');
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
    if (!FObject.processIsValid) {
      errors += 4;
    }
    System.assertEquals(0, errors, 'random picklist - errors found');
  }

  @IsTest
  private static void sddlRandomPicklist_oneRecordType_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectThree__c');
    obj.setDefinition('RecordTypeId', 'random type(picklist)');
    obj.insertRecords(true);
    List<FObjectThree__c> records = (List<FObjectThree__c>) obj.getRecords();
    Test.stopTest();

    Map<Id, Schema.RecordTypeInfo> recordTypesMap = Schema.SObjectType.FObjectThree__c.getRecordTypeInfosById();
    List<Id> keys = new List<Id>(recordTypesMap.keySet());

    Integer errors = 0;
    for (FObjectThree__c objRecord : records) {
      if (objRecord.RecordTypeId != keys[0]) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random picklist - errors found');
  }

  @IsTest
  private static void sddlRandomPicklist_manyRecordTypes_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('RecordTypeId', 'random type(picklist)');
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
      WHERE sObjectType = 'FObjectOne__c' AND IsActive = TRUE
      LIMIT 1000
    ];
    Set<Id> valuesSet = (new Map<Id, RecordType>(recordTypes)).keySet();
    List<Id> values = new List<Id>(valuesSet);
    if (!isValidDistribution('RecordTypeId', values, records)) {
      errors++;
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random picklist - errors found');
  }

  @IsTest
  private static void sddlRandomPicklistExcept_independentPicklistField_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestPicklistA__c', 'random type(picklist) except(a1)');
    obj.insertRecords(true);
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
    if (!isValidDistribution('TestPicklistA__c', values, records)) {
      errors++;
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random picklist except - errors found');
  }

  @IsTest
  private static void sddlRandomPicklistExcept_dependentPicklistField_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestPicklistC__c', 'random type(picklist) except(c1)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    // set mapping
    Set<String> picklistA0Mapping = new Set<String>{''};
    Set<String> picklistA1Mapping = new Set<String>{'b1'};
    Set<String> picklistA2Mapping = new Set<String>{'b1', 'b2'};
    Set<String> picklistA3Mapping = new Set<String>{'b1', 'b2', 'b3'};
    Set<String> picklistB0Mapping = new Set<String>{''};
    Set<String> picklistB1Mapping = new Set<String>{''};
    Set<String> picklistB2Mapping = new Set<String>{'c2'};
    Set<String> picklistB3Mapping = new Set<String>{'c2', 'c3'};

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

      if (picklistBValues[counter] == 'b0' && !picklistB1Mapping.contains(picklistCValues[counter])) {
        errors++;
      } else if (picklistBValues[counter] == 'b1' && !picklistB1Mapping.contains(picklistCValues[counter])) {
        errors++;
      } else if (picklistBValues[counter] == 'b2' && !picklistB2Mapping.contains(picklistCValues[counter])) {
        errors++;
      } else if (picklistBValues[counter] == 'b3' && !picklistB3Mapping.contains(picklistCValues[counter])) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random picklist except - error found');
  }

  @IsTest
  private static void sddlRandomPicklistExcept_checkDefinitionsOfDependentPicklists_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('RecordTypeId', 'static value(RecordTypeA)');
    obj.setDefinition('TestPicklistC__c', 'random type(picklist) except(c1)');
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
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random picklist except - errors found');
  }

  @IsTest
  private static void sddlRandomPicklistExcept_noPicklistValues_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestPicklistA__c', 'random type(picklist) except(a0,a1,a2,a3)');
    obj.insertRecords(true);
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
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random picklist except - error found');
  }

  @IsTest
  private static void sddlRandomPicklistExcept_onePicklistValue_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestPicklistA__c', 'random type(picklist) except(a0,a2,a3)');
    obj.insertRecords(true);
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
    if (!isValidDistribution('TestPicklistA__c', values, records)) {
      errors++;
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random picklist except - error found');
  }

  @IsTest
  private static void sddlRandomPicklistExcept_controllingFieldIsCheckbox_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestCheckbox__c', 'static value(true)');
    obj.setDefinition('TestpicklistD__c', 'random type(picklist) except(d0, d1)');
    Database.SaveResult[] saveResults = obj.insertRecords(false);
    Test.stopTest();

    Integer errors = 0;
    for (Database.SaveResult sr : saveResults) {
      if (!sr.isSuccess()) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random picklist except - errors found');
  }

  @IsTest
  private static void sddlRandomPicklistExcept_noRecordType_expectFailure() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('RecordTypeId',
      'random type(picklist) except(RecordTypeA, RecordTypeB, RecordTypeC)');
    Database.SaveResult[] saveResults = obj.insertRecords(false);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    Integer errors = 0;
    for (Database.SaveResult sr : saveResults) {
      if (sr.isSuccess()) {
        errors++;
      }
    }
    for (FObjectOne__c objRecord : records) {
      if (String.isNotBlank(objRecord.RecordTypeId)) {
        errors++;
      }
    }
    if (FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random picklist except - errors found');
  }

  @IsTest
  private static void sddlRandomPicklistExcept_oneRecordType_expectSuccess() {
    Id recordTypeId =
      Schema.SObjectType.FObjectOne__c.getRecordTypeInfosByName().get('Record Type C').getRecordTypeId();

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('RecordTypeId', 'random type(picklist) except(RecordTypeA, RecordTypeB)');
    Database.SaveResult[] saveResults = obj.insertRecords(false);
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
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random picklist except - errors found');
  }

  @IsTest
  private static void sddlRandomPicklistExcept_manyRecordTypes_expectSuccess() {
    Id recordTypeId1 =
      Schema.SObjectType.FObjectOne__c.getRecordTypeInfosByName().get('Record Type A').getRecordTypeId();
    Id recordTypeId2 =
      Schema.SObjectType.FObjectOne__c.getRecordTypeInfosByName().get('Record Type B').getRecordTypeId();
    List<Id> arguments = new List<String>{
      recordTypeId1, recordTypeId2
    };
    Set<Id> recordTypeIdsSet = new Set<Id>(arguments);

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('RecordTypeId', 'random type(picklist) except(RecordTypeC)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    Integer errors = 0;
    for (FObjectOne__c objRecord : records) {
      if (!recordTypeIdsSet.contains(objRecord.RecordTypeId)) {
        errors++;
      }
    }
    if (!isValidDistribution('RecordTypeId', arguments, records)) {
      errors++;
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random picklist except - errors found');
  }

  @IsTest
  private static void sddlRandomString_includeOnlyDigits_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestText__c', 'random type(string) Minlength(5) Maxlength(10) ' +
      'startwith(Lower) include(Digit)');
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    String result = '';
    Integer errors = 0;
    Integer len = 0;
    for (FObjectOne__c objRecord : records) {
      len = objRecord.TestText__c.length();
      result = objRecord.TestText__c.right(len - 1);
      if (!result.isNumeric()) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random string - errors found');
  }

  @IsTest
  private static void sddlRandomString_includeOnlyLowercase_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestText__c', 'random type(string) Minlength(5) Maxlength(10) ' +
      'startwith(Upper) include(Lower)');
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    String result = '';
    Integer errors = 0;
    Integer len = 0;
    for (FObjectOne__c objRecord : records) {
      len = objRecord.TestText__c.length();
      result = objRecord.TestText__c.right(len - 1);
      if (!result.isAllLowerCase()) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random string - errors found');
  }

  @IsTest
  private static void sddlRandomString_includeOnlyUppercase_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestText__c', 'random type(string) Minlength(5) Maxlength(10) ' +
      'startwith(Lower) include(Upper)');
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    String result = '';
    Integer errors = 0;
    Integer len = 0;
    for (FObjectOne__c objRecord : records) {
      len = objRecord.TestText__c.length();
      result = objRecord.TestText__c.right(len - 1);
      if (!result.isAllUpperCase()) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random string - errors found');
  }

  @IsTest
  private static void sddlRandomString_startWithLower_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestText__c', 'random type(string) Minlength(5) Maxlength(10) ' +
      'startwith(Lower) include(Lower,Upper)');
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    Integer errors = 0;
    for (FObjectOne__c objRecord : records) {
      if (!objRecord.TestText__c.left(1).isAllLowerCase()) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random string - errors found');
  }

  @IsTest
  private static void sddlRandomString_startWithUpper_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestText__c', 'random type(string) Minlength(5) Maxlength(10) ' +
      'startwith(Upper) include(Lower, Upper)');
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    Integer errors = 0;
    for (FObjectOne__c objRecord : records) {
      if (!objRecord.TestText__c.left(1).isAllUpperCase()) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random string - errors found');
  }

  @IsTest
  private static void sddlRandomString_startWithDigit_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestText__c', 'random type(string) Minlength(5) Maxlength(10) ' +
      'startwith(Digit) include(Lower, Upper)');
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    Integer errors = 0;
    for (FObjectOne__c objRecord : records) {
      if (!objRecord.TestText__c.left(1).isNumeric()) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random string - errors found');
  }

  @IsTest
  private static void sddlRandomString_minEqualsZero_expectFailure() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestText__c', 'Random Type(string) Minlength(0) Maxlength(5) ' +
      'Startwith(Upper) Include(Lower,Upper)');
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    String expectedResult = 'The minimum length should be greater than or equal to 1 ' +
      'in definition [Random Type(string) Minlength(0) Maxlength(5) Startwith(Upper) Include(Lower,Upper)]';
    String actualResult = obj.getErrors().get('TestText__c').get(0);
    System.assertEquals(expectedResult, actualResult, 'random string - error found');
  }

  @IsTest
  private static void sddlRandomString_minLessThanZero_expectFailure() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestText__c', 'Random Type(string) Minlength(-1) Maxlength(5) ' +
      'Startwith(Upper) Include(Lower,Upper)');
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    String expectedResult = 'The minimum length should be greater than or equal to 1 ' +
      'in definition [Random Type(string) Minlength(-1) Maxlength(5) Startwith(Upper) Include(Lower,Upper)]';
    String actualResult = obj.getErrors().get('TestText__c').get(0);
    System.assertEquals(expectedResult, actualResult, 'random string - error found');
  }

  @IsTest
  private static void sddlRandomString_minGreaterThanMax_expectFailure() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestText__c', 'Random Type(string) Minlength(10) Maxlength(5) ' +
      'Startwith(Upper) Include(Lower,Upper)');
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    String expectedResult = 'The minimum length should be less than or equal to the maximum length ' +
      'in definition [Random Type(string) Minlength(10) Maxlength(5) Startwith(Upper) Include(Lower,Upper)]';
    String actualResult = obj.getErrors().get('TestText__c').get(0);
    System.assertEquals(expectedResult, actualResult, 'random string - errors found');
  }

  @IsTest
  private static void sddlRandomText_validWords_expectSuccess() {
    List<String> words = new List<String>{
      'lorem', 'ipsum', 'dolor', 'sit', 'amet', 'tempor', 'aboreant',
      'instructor', 'eu', 'nos', 'a', 'quo', 'magna', 'primis', 'labore', 'usi', 'virtute', 'fabellas', 'vis', 'duis',
      'scripta', 'salutandi', 'laudem', 'commune', 'nam', 'laoreet', 'propriae', 'corrumpit', 'ea', 'partem',
      'inermis', 'conclusion', 'ius', 'sint', 'impedit', 'deterruis', 'eam', 'elit', 'nusquam'
    };

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestText__c', 'Random Type(Text) Minlength(20) Maxlength(50)');
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    Integer errors = 0;
    String text = '';
    for (FObjectOne__c objRecord : records) {
      text = objRecord.TestText__c;
      for (String word : words) {
        text = text.remove(word);
      }
      if (String.isBlank(text)) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random text - errors found');
  }

  @IsTest
  private static void sddlRandomText_minEqualsMaxPlus1_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestText__c', 'Random Type(Text) Minlength(20) Maxlength(21)');
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    Integer errors = 0;
    Integer textSize = 0;
    for (FObjectOne__c objRecord : records) {
      textSize = objRecord.TestText__c.length();
      if (textSize < 20 || textSize > 21) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random text - errors found');
  }

  @IsTest
  private static void sddlRandomText_minEqualsMaxPlus10_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c', 1000);
    obj.setDefinition('TestText__c', 'Random Type(Text) Minlength(20) Maxlength(30)');
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    Integer errors = 0;
    Integer textSize = 0;
    for (FObjectOne__c objRecord : records) {
      textSize = objRecord.TestText__c.length();
      if (textSize < 20 || textSize > 30) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random text - errors found');
  }

  @IsTest
  private static void sddlRandomText_minEqualsMax_expectFailure() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestText__c', 'Random Type(Text) Minlength(20) Maxlength(20)');
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    String expectedResult = 'The minimum length should be less than the maximum length ' +
      'in definition [Random Type(Text) Minlength(20) Maxlength(20)]';
    String actualResult = obj.getErrors().get('TestText__c').get(0);
    System.assertEquals(expectedResult, actualResult, 'random text - error found');
  }

  @IsTest
  private static void sddlRandomText_minEqualsZero_expectFailure() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestText__c', 'Random Type(Text) Minlength(0) Maxlength(20)');
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    String expectedResult = 'The minimum length should be greater than or equal to 1 ' +
      'in definition [Random Type(Text) Minlength(0) Maxlength(20)]';
    String actualResult = obj.getErrors().get('TestText__c').get(0);
    System.assertEquals(expectedResult, actualResult, 'random text - error found');
  }

  @IsTest
  private static void sddlRandomText_minLessThanZero_expectFailure() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestText__c', 'Random Type(Text) Minlength(-1) Maxlength(20)');
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    String expectedResult = 'The minimum length should be greater than or equal to 1 ' +
      'in definition [Random Type(Text) Minlength(-1) Maxlength(20)]';
    String actualResult = obj.getErrors().get('TestText__c').get(0);
    System.assertEquals(expectedResult, actualResult, 'random text - error found');
  }

  @IsTest
  private static void sddlRandomUrl_valid_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestUrl__c', 'random type(url)');
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    obj.insertRecords(true);
    Test.stopTest();

    List<String> notes = new List<String>{
      'do', 're', 'mi', 'fa', 'sol', 'la', 'si'
    };
    Integer errors = 0;
    String url = '';
    for (FObjectOne__c objRecord : records) {
      url = objRecord.TestUrl__c;
      for (String note : notes) {
        url = url.remove(note);
      }
      if (url != 'http://www..com') {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random url - errors found');
  }

  @IsTest
  private static void sddlSerialNumber_positiveIntegerStep_expectSuccess() {
    Integer numOfRecords = 201;
    Decimal fromValue = 10;
    Decimal stepValue = 2;

    Test.startTest();
    FObject obj = new FObject('Account'); // should use the Account object
    obj.setDefinition('NumberOfEmployees', 'Serial Type(Number) From(10) Step(2) Scale(0)');
    obj.insertRecords(true);
    List<Account> records = (List<Account>) obj.getRecords();
    Test.stopTest();

    Decimal expectedResult = fromValue + (numOfRecords - 1) * stepValue;
    Decimal actualResult = records[numOfRecords - 1].NumberOfEmployees;
    System.assertEquals(expectedResult, actualResult, 'serial number - errors found');
  }

  @IsTest
  private static void sddlSerialNumber_negativeIntegerStep_expectSuccess() {
    Integer numOfRecords = 201;
    Decimal fromValue = 0;
    Decimal stepValue = -2;

    Test.startTest();
    FObject obj = new FObject('Account'); // should use the Account object
    obj.setDefinition('NumberOfEmployees', 'Serial Type(Number) From(0) Step(-2) Scale(2)');
    obj.insertRecords(true);
    List<Account> records = (List<Account>) obj.getRecords();
    Test.stopTest();

    Decimal expectedResult = fromValue + (numOfRecords - 1) * stepValue;
    Decimal actualResult = records[numOfRecords - 1].NumberOfEmployees;
    System.assertEquals(expectedResult, actualResult, 'serial number - errors found');
  }

  @IsTest
  private static void sddlSerialNumber_positiveDecimalStep_expectSuccess() {
    Integer numOfRecords = 201;
    Decimal fromValue = 10;
    Decimal stepValue = 1.52;

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c', numOfRecords);
    obj.setDefinition('TestDecimal__c', 'Serial Type(Number) From(10) Step(1.52) Scale(2)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    Decimal expectedResult = fromValue + (numOfRecords - 1) * stepValue;
    Decimal actualResult = records[numOfRecords - 1].TestDecimal__c;
    System.assertEquals(expectedResult, actualResult, 'serial number - errors found');
  }

  @IsTest
  private static void sddlSerialNumber_negativeDecimalStep_expectSuccess() {
    Integer numOfRecords = 201;
    Decimal fromValue = 10;
    Decimal stepValue = -1.52;

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c', numOfRecords);
    obj.setDefinition('TestDecimal__c', 'Serial Type(Number) From(10) Step(-1.52) Scale(2)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    Decimal expectedResult = fromValue + (numOfRecords - 1) * stepValue;
    Decimal actualResult = records[numOfRecords - 1].TestDecimal__c;
    System.assertEquals(expectedResult, actualResult, 'serial number - errors found');
  }

  @IsTest
  private static void sddlSerialDate_positiveStep_expectSuccess() {
    Integer numOfRecords = 100;
    Date fromValue = Date.newInstance(2018, 1, 1);
    Integer stepValue = 5;

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c', numOfRecords);
    obj.setDefinition('TestDate__c', 'Serial Type(Date) From(2018-01-01) Step(5)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    Date expectedResult = fromValue.addDays((numOfRecords - 1) * stepValue);
    Date actualResult = records[numOfRecords - 1].TestDate__c;
    System.assertEquals(expectedResult, actualResult, 'serial date - errors found');
  }

  @IsTest
  private static void sddlSerialDate_negativeStep_expectSuccess() {
    Integer numOfRecords = 100;
    Date fromValue = Date.newInstance(2018, 1, 1);
    Integer stepValue = -5;

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c', numOfRecords);
    obj.setDefinition('TestDate__c', 'Serial Type(Date) From(2018-01-01) Step(-5)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    Date expectedResult = fromValue.addDays((numOfRecords - 1) * stepValue);
    Date actualResult = records[numOfRecords - 1].TestDate__c;
    System.assertEquals(expectedResult, actualResult, 'serial date - errors found');
  }

  @IsTest
  private static void sddlSerialDate_fromDatetime_expectSuccess() {
    Integer numOfRecords = 100;
    Date fromValue = Date.newInstance(2018, 1, 1);
    Integer stepValue = 2;

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c', numOfRecords);
    obj.setDefinition('TestDate__c', 'Serial Type(Date) From(2018-01-01 02:02:02) Step(2)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    Date expectedResult = fromValue.addDays((numOfRecords - 1) * stepValue);
    Date actualResult = records[numOfRecords - 1].TestDate__c;
    System.assertEquals(expectedResult, actualResult, 'serial date - errors found');
  }

  @IsTest
  private static void sddlSerialDate_decimalStep_expectFailure() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestDate__c', 'Serial Type(Date) From(2018-01-01) Step(2.2)');
    obj.insertRecords(true);
    Test.stopTest();

    String expectedResult = 'Invalid definition [Serial Type(Date) ' +
      'From(2018-01-01) Step(2.2)] of field [TestDate__c]';
    String actualResult = obj.getErrors().get('TestDate__c').get(0);
    System.assertEquals(expectedResult, actualResult, 'serial date - errors found');
  }

  @IsTest
  private static void sddlSerialDatetime_fromDatetPositiveIntegerStep_expectSuccess() {
    Integer numOfRecords = 100;
    Datetime fromValue = Datetime.newInstance(2018, 1, 1);
    Decimal stepValue = 2;

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c', numOfRecords);
    obj.setDefinition('TestDatetime__c', 'Serial Type(Datetime) From(2018-01-01) Step(2)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    Datetime expectedResult = fromValue.addDays((numOfRecords - 1) * 2);
    Datetime actualResult = records[numOfRecords - 1].TestDatetime__c;
    System.assertEquals(expectedResult, actualResult, 'serial datetime - errors found');
  }

  @IsTest
  private static void sddlSerialDatetime_fromDateNegativeIntegerStep_expectSuccess() {
    Integer numOfRecords = 100;
    Datetime fromValue = Datetime.newInstance(2018, 1, 1);

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c', numOfRecords);
    obj.setDefinition('TestDatetime__c', 'Serial Type(Datetime) From(2018-01-01) Step(-2)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    Datetime expectedResult = fromValue.addDays((numOfRecords - 1) * (-2));
    Datetime actualResult = records[numOfRecords - 1].TestDatetime__c;
    System.assertEquals(expectedResult, actualResult, 'serial datetime - errors found');
  }

  @IsTest
  private static void sddlSerialDatetime_fromDatePositiveDecimalStep_expectSuccess() {
    Integer numOfRecords = 100;
    Datetime fromValue = Datetime.newInstance(2018, 1, 1);

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c', numOfRecords);
    obj.setDefinition('TestDatetime__c', 'Serial Type(Datetime) From(2018-01-01) Step(2.2)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    Datetime expectedResult = fromValue.addDays((numOfRecords - 1) * 2);
    expectedResult = expectedResult.addHours((numOfRecords - 1) * 4);
    expectedResult = expectedResult.addMinutes((numOfRecords - 1) * 48);
    Datetime actualResult = records[numOfRecords - 1].TestDatetime__c;
    System.assertEquals(expectedResult, actualResult, 'serial datetime - errors found');
  }

  @IsTest
  private static void sddlSerialDatetime_fromDatetNegativeDecimalStep_expectSuccess() {
    Integer numOfRecords = 100;
    Datetime fromValue = Datetime.newInstance(2018, 1, 1);

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c', numOfRecords);
    obj.setDefinition('TestDatetime__c', 'Serial Type(Datetime) From(2018-01-01) Step(-2.2)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    Datetime expectedResult = fromValue.addDays((numOfRecords - 1) * (-2));
    expectedResult = expectedResult.addHours((numOfRecords - 1) * (-4));
    expectedResult = expectedResult.addMinutes((numOfRecords - 1) * (-48));
    Datetime actualResult = records[numOfRecords - 1].TestDatetime__c;
    System.assertEquals(expectedResult, actualResult, 'serial datetime - errors found');
  }

  @IsTest
  private static void sddlSerialDatetime_fromDatetimePositiveIntegerStep_expectSuccess() {
    Integer numOfRecords = 100;
    Datetime fromValue = Datetime.newInstance(2018, 1, 1, 2, 2, 2);

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c', numOfRecords);
    obj.setDefinition('TestDatetime__c', 'Serial Type(Datetime) From(2018-01-01 02:02:02) Step(2)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    Datetime expectedResult = fromValue.addDays((numOfRecords - 1) * 2);
    Datetime actualResult = records[numOfRecords - 1].TestDatetime__c;
    System.assertEquals(expectedResult, actualResult, 'serial datetime - errors found');
  }

  @IsTest
  private static void sddlSerialDatetime_fromDatetimeNegativeIntegerStep_expectSuccess() {
    Integer numOfRecords = 100;
    Datetime fromValue = Datetime.newInstance(2018, 1, 1, 2, 2, 2);

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c', numOfRecords);
    obj.setDefinition('TestDatetime__c', 'Serial Type(Datetime) From(2018-01-01 02:02:02) Step(-2)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    Datetime expectedResult = fromValue.addDays((numOfRecords - 1) * (-2));
    Datetime actualResult = records[numOfRecords - 1].TestDatetime__c;
    System.assertEquals(expectedResult, actualResult, 'serial datetime - errors found');
  }

  @IsTest
  private static void sddlSerialDatetime_fromDatetimePositiveDecimalStep_expectSuccess() {
    Integer numOfRecords = 100;
    Datetime fromValue = Datetime.newInstance(2018, 1, 1, 2, 2, 2);

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c', numOfRecords);
    obj.setDefinition('TestDatetime__c', 'Serial Type(Datetime) From(2018-01-01 02:02:02) Step(2.2)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    Datetime expectedResult = fromValue.addDays((numOfRecords - 1) * 2);
    expectedResult = expectedResult.addHours((numOfRecords - 1) * 4);
    expectedResult = expectedResult.addMinutes((numOfRecords - 1) * 48);
    Datetime actualResult = records[numOfRecords - 1].TestDatetime__c;
    System.assertEquals(expectedResult, actualResult, 'serial datetime - errors found');
  }

  @IsTest
  private static void sddlSerialDatetime_fromDatetimeNegativeDecimalStep_expectSuccess() {
    Integer numOfRecords = 100;
    Datetime fromValue = Datetime.newInstance(2018, 1, 1, 2, 2, 2);

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c', numOfRecords);
    obj.setDefinition('TestDatetime__c', 'Serial Type(Datetime) From(2018-01-01 02:02:02) Step(-2.2)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    Datetime expectedResult = fromValue.addDays((numOfRecords - 1) * (-2));
    expectedResult = expectedResult.addHours((numOfRecords - 1) * (-4));
    expectedResult = expectedResult.addMinutes((numOfRecords - 1) * (-48));
    Datetime actualResult = records[numOfRecords - 1].TestDatetime__c;
    System.assertEquals(expectedResult, actualResult, 'serial datetime - errors found');
  }

  @IsTest
  private static void sddlStaticLookupForceea_createLookupRecords_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestLookup__c', 'static lookup(FObjectTwo__c) ' +
      'field(TestPicklistA__c) value(a1) source(Forceea)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    // get the TestLookup__c of the first FObjectOne__c record
    Id lookupId = records.get(0).TestLookup__c;

    // check if the lookupId exists in every record of FObjectOne__c
    Integer errors = 0;
    for (FObjectOne__c objRecord : records) {
      if (objRecord.TestLookup__c != lookupId) {
        errors++;
      }
    }

    // verify that the FObjectTwo__c record of lookupId has TestText__c = 'a1'
    FObjectTwo__c refObjectRecord = [
      SELECT Id, TestPicklistA__c
      FROM FObjectTwo__c
      WHERE Id = :lookupId
      LIMIT 1
    ];
    if (refObjectRecord.TestPicklistA__c != 'a1') {
      errors++;
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'static lookup - errors found');
  }

  @IsTest
  private static void sddlStaticLookupForceea_lookupRecordsExist_expectSuccess() {
    String whereValue = 'Hot';
    Integer errors = 0;

    Test.startTest();
    FObject obj1 = new FObject('FObjectTwo__c');
    obj1.setDefinition('TestText__c', 'static value(' + whereValue + ')');
    List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
    obj1.insertRecords(true);

    FObject obj2 = new FObject('FObjectOne__c');
    obj2.setDefinition('TestLookup__c', 'static lookup(FObjectTwo__c) ' +
      'field(TestText__c) value(' + whereValue + ') source(Forceea)');
    obj2.insertRecords(true);
    List<FObjectOne__c> records2 = (List<FObjectOne__c>) obj2.getRecords();
    Test.stopTest();

    // get the TestLookup__c of the first FObjectOne__c record
    Id lookupId = records2.get(0).TestLookup__c;

    // check if the lookupid exists in every record of FObjectOne__c
    for (FObjectOne__c objRecord : records2) {
      if (objRecord.TestLookup__c != lookupId) {
        errors++;
      }
    }

    // verify that the FObjectTwo__c record of lookupId has TestText__c = 'Hot'
    FObjectTwo__c refObjectRecord = [
      SELECT Id, TestText__c
      FROM FObjectTwo__c
      WHERE Id = :lookupId
      LIMIT 1
    ];
    if (refObjectRecord.TestText__c != whereValue) {
      errors++;
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'static lookup - errors found');
  }

  @IsTest
  private static void sddlStaticLookupSalesforce_valid_expectSuccess() {
    String whereValue = 'Hot';
    Integer errors = 0;

    Test.startTest();
    FObject obj1 = new FObject('FObjectTwo__c');
    obj1.setDefinition('TestText__c', 'static value(' + whereValue + ')');
    List<FObjectOne__c> records1 = (List<FObjectOne__c>) obj1.getRecords();
    obj1.insertRecords(true);

    FObject obj2 = new FObject('FObjectOne__c');
    obj2.setDefinition('TestLookup__c', 'static lookup(FObjectTwo__c) ' +
      'field(TestText__c) value(' + whereValue + ') source(Salesforce)');
    obj2.insertRecords(true);
    List<FObjectOne__c> records2 = (List<FObjectOne__c>) obj2.getRecords();
    Test.stopTest();

    // get the TestLookup__c of the first FObjectOne__c record
    Id lookupId = records2.get(0).TestLookup__c;

    // check if the lookupid exists in every record of FObjectOne__c
    for (FObjectOne__c objRecord : records2) {
      if (objRecord.TestLookup__c != lookupId) {
        errors++;
      }
    }

    // verify that the FObjectTwo__c record of lookupId has TestText__c = 'Hot'
    FObjectTwo__c refObjectRecord = [
      SELECT Id, TestText__c
      FROM FObjectTwo__c
      WHERE Id = :lookupId
      LIMIT 1
    ];
    if (refObjectRecord.TestText__c != whereValue) {
      errors++;
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'static lookup - errors found');
  }

  @IsTest
  private static void sddlStaticLookup_insertedGroupRecords_expectSuccess() {
    Test.startTest();
    // insert FObjectTwo__c records for group B
    FObject objB1 = new FObject('FObjectTwo__c', 5);
    objB1.setDefinition('TestPicklistA__c', 'static value(a0)');
    objB1.insertRecords(true, 'B');
    // insert FObjectTwo__c records without group
    FObject objB2 = new FObject('FObjectTwo__c', 5);
    objB2.setDefinition('TestPicklistA__c', 'random type(list) value(a1, a2, a3)');
    objB2.insertRecords(true);
    // insert FObjectOne__c records
    FObject objA = new FObject('FObjectOne__c');
    objA.setDefinition('TestLookup__c',
      'static lookup(FObjectTwo__c) field(TestPicklistA__c) value(a0) source(Forceea)');
    objA.insertRecords(true);
    Test.stopTest();

    Integer errors = 0;
    for (FObjectOne__c objRecord : [SELECT TestLookup__r.TestPicklistA__c FROM FObjectOne__c LIMIT 1000]) {
      if (objRecord.TestLookup__r.TestPicklistA__c != 'a0') {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'static lookup - errors found');
  }

  @IsTest
  private static void sddlStaticLookup_invalidLookup_expectFailure() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestLookup__c', 'static lookup(FObjectTwo) ' +
      'field(TestPicklistA__c) value(a1) source(forceea)');
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    String expectedResult = 'Invalid lookup object [FObjectTwo] in definition [static lookup(FObjectTwo) ' +
      'field(TestPicklistA__c) value(a1) source(forceea)]';
    String actualResult = obj.getErrors().get('TestLookup__c').get(0);
    System.assertEquals(expectedResult, actualResult, 'static lookup - errors found');
  }

  @IsTest
  private static void sddlStaticLookup_nullLookup_expectFailure() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestLookup__c', 'static lookup() field(TestPicklistA__c) value(a1) source(forceea)');
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    String expectedResult = 'Invalid syntax in definition [static lookup() field(TestPicklistA__c) value(a1) ' +
      'source(forceea)] of field [TestLookup__c]';
    String actualResult = obj.getErrors().get('TestLookup__c').get(0);
    System.assertEquals(expectedResult, actualResult, 'static lookup - errors found');
  }

  @IsTest
  private static void sddlStatic_recordType_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('RecordTypeId', 'static value(RecordTypeA)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    // get the record type ID of the first record
    Id recordTypeId = records.get(0).recordTypeId;

    // check if the record type ID exists in every record
    Integer errors = 0;
    for (FObjectOne__c objRecord : records) {
      if (objRecord.recordTypeId != recordTypeId) {
        errors++;
      }
    }

    // verify the name of the record type
    Map<Id, Schema.RecordTypeInfo> recordTypesMap = Schema.SObjectType.FObjectOne__c.getRecordTypeInfosById();
    String recordTypeName = recordTypesMap.get(recordTypeId).getName();
    if (recordTypeName != 'Record Type A') {
      errors++;
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'static value - errors found');
  }

  @IsTest
  private static void sddlStatic_boolean_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestCheckbox__c', 'static value(true)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    Integer errors = 0;
    for (FObjectOne__c objRecord : records) {
      if (objRecord.TestCheckbox__c == false) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'static value - errors found');
  }

  @IsTest
  private static void sddlStatic_date_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestDate__c', 'static value(2018-10-01)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    Integer errors = 0;
    Date dt = Date.newInstance(2018, 10, 1);
    for (FObjectOne__c objRecord : records) {
      if (objRecord.TestDate__c != dt) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'static value - errors found');
  }

  @IsTest
  private static void sddlStatic_datetime_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestDatetime__c', 'static value(2018-10-01 01:01:01)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    Integer errors = 0;
    Datetime dt = Datetime.newInstance(2018, 10, 1, 1, 1, 1);
    for (FObjectOne__c objRecord : records) {
      if (objRecord.TestDatetime__c != dt) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'static value - errors found');
  }

  @IsTest
  private static void sddlStatic_decimal_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestDecimal__c', 'static value(100000.11)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    Integer errors = 0;
    for (FObjectOne__c objRecord : records) {
      if (objRecord.TestDecimal__c != 100000.11) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'static value - errors found');
  }

  @IsTest
  private static void sddlStatic_integer_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestInteger__c', 'static value(10)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    Integer errors = 0;
    for (FObjectOne__c objRecord : records) {
      if (objRecord.TestInteger__c != 10) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'static value - errors found');
  }

  @IsTest
  private static void sddlStatic_stringForTextField_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('testText__c', 'static value(Sales)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    Integer errors = 0;
    for (FObjectOne__c objRecord : records) {
      if (objRecord.TestText__c != 'Sales') {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'static value - errors found');
  }

  @IsTest
  private static void sddlStatic_validValueForRestrictedIndependentPicklistField_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestPicklistA__c', 'static value(a1)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    Integer errors = 0;
    for (FObjectOne__c objRecord : records) {
      if (objRecord.TestPicklistA__c != 'a1') {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'static value - errors found');
  }

  @IsTest
  private static void sddlStatic_invalidValueForRestrictedIndependentPicklistField_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestPicklistA__c', 'static value(a10)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    Integer errors = 0;
    for (FObjectOne__c objRecord : records) {
      if (String.isNotBlank(objRecord.TestPicklistA__c)) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'static value - errors found');
  }

  @IsTest
  private static void sddlStatic_validValueForRestrictedDependentPicklistField_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestPicklistB__c', 'static value(b2)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    Integer errors = 0;
    for (FObjectOne__c objRecord : records) {
      if (!(String.isBlank(objRecord.TestPicklistB__c) || objRecord.TestPicklistB__c == 'b2')) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'static value - errors found');
  }

  @IsTest
  private static void sddlStatic_invalidValueForRestrictedDependentPicklistField_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestPicklistB__c', 'static value(b10)');
    obj.insertRecords(true);
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    Integer errors = 0;
    for (FObjectOne__c objRecord : records) {
      if (String.isNotBlank(objRecord.TestPicklistB__c)) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'static value - errors found');
  }

  @IsTest
  private static void sddlStatic_validValueForUnrestrictedIndependentPicklistField_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectTwo__c');
    obj.setDefinition('TestPicklistEUnrestricted__c', 'static value(e1)');
    obj.insertRecords(true);
    List<FObjectTwo__c> records = (List<FObjectTwo__c>) obj.getRecords();
    Test.stopTest();

    Integer errors = 0;
    for (FObjectTwo__c objRecord : records) {
      if (objRecord.TestPicklistEUnrestricted__c != 'e1') {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'static value - errors found');
  }

  @IsTest
  private static void sddlStatic_invalidValueForUnrestrictedIndependentPicklistField_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectTwo__c');
    obj.setDefinition('TestPicklistEUnrestricted__c', 'static value(a10)');
    obj.insertRecords(true);
    List<FObjectTwo__c> records = (List<FObjectTwo__c>) obj.getRecords();
    Test.stopTest();

    Integer errors = 0;
    for (FObjectTwo__c objRecord : records) {
      if (objRecord.TestPicklistEUnrestricted__c != 'a10') {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'static value - errors found');
  }

  @IsTest
  private static void sddlStatic_validValueForUnrestrictedDependentPicklistField_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectTwo__c');
    obj.setDefinition('TestPicklistFUnrestricted__c', 'static value(f2)');
    obj.insertRecords(true);
    List<FObjectTwo__c> records = (List<FObjectTwo__c>) obj.getRecords();
    Test.stopTest();

    Integer errors = 0;
    for (FObjectTwo__c objRecord : records) {
      if (!(String.isBlank(objRecord.TestPicklistFUnrestricted__c) || objRecord.TestPicklistFUnrestricted__c == 'f2')) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'static value - errors found');
  }

  @IsTest
  private static void sddlStatic_invalidValueForUnrestrictedDependentPicklistField_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectTwo__c');
    obj.setDefinition('TestPicklistFUnrestricted__c', 'static value(a10)');
    obj.insertRecords(true);
    List<FObjectTwo__c> records = (List<FObjectTwo__c>) obj.getRecords();
    Test.stopTest();

    Integer errors = 0;
    for (FObjectTwo__c objRecord : records) {
      if (String.isNotBlank(objRecord.TestPicklistFUnrestricted__c)) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'static value - errors found');
  }

  @IsTest
  private static void sddlStatic_controllingFieldIsCheckbox_expectSuccess() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('testCheckbox__c', 'static value(true)');
    obj.setDefinition('testpicklistD__c', 'static value(d2)');
    Database.SaveResult[] saveResults = obj.insertRecords(false);
    Test.stopTest();

    Integer errors = 0;
    for (Database.SaveResult sr : saveResults) {
      if (!sr.isSuccess()) {
        errors++;
      }
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    if (!FObject.processIsValid) {
      errors++;
    }
    System.assertEquals(0, errors, 'random static - errors found');
  }

  @IsTest
  private static void sddlStatic_invalidRecordType_expectFailure() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('RecordTypeId', 'static value(RecordTypeAX)');
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    String expectedResult = 'Invalid record type [RecordTypeAX] for definition [static value(RecordTypeAX)]';
    String actualResult = obj.getErrors().get('RecordTypeId').get(0);
    System.assertEquals(expectedResult, actualResult, 'static value - errors found');
  }

  @IsTest
  private static void sddlStatic_twoArguments_expectFailure() {
    Test.startTest();
    FObject obj = new FObject(' FObjectOne__c ');
    obj.setDefinition('testtext__c', 'Static Value(One, "Two and Three")');
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    String expectedResult = 'Invalid definition [Static Value(One, "Two and Three")] of field [TestText__c]';
    String actualResult = obj.getErrors().get('TestText__c').get(0);
    System.assertEquals(expectedResult, actualResult, 'sddlStatic - errors found');
  }

  /* method setDefinition */

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
    obj.insertRecords(true);
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
    if (!FObject.processIsValid) {
      errors += 32;
    }
    System.assertEquals(0, errors, 'setDefinition - errors found');
  }

  @IsTest
  private static void setDefinition_missingOpeningParenthesis1_expectFailure() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestText__c', 'Static Value arg1) ');
    obj.insertRecords(true);
    Test.stopTest();

    String expectedResult = 'Invalid syntax in definition [Static Value arg1)] of field [TestText__c]';
    String actualResult = obj.getErrors().get('TestText__c').get(0);
    System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
  }

  @IsTest
  private static void setDefinition_missingOpeningParenthesis2_expectFailure() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestText__c', 'Static Value "arg1")');
    obj.insertRecords(true);
    Test.stopTest();

    String expectedResult = 'Invalid syntax in definition [Static Value "arg1")] of field [TestText__c]';
    String actualResult = obj.getErrors().get('TestText__c').get(0);
    System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
  }

  @IsTest
  private static void setDefinition_missingOpeningParenthesis3_expectFailure() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestText__c', 'Static Value arg1, arg2) ');
    obj.insertRecords(true);
    Test.stopTest();

    String expectedResult = 'Invalid syntax in definition [Static Value arg1, arg2)] of field [TestText__c]';
    String actualResult = obj.getErrors().get('TestText__c').get(0);
    System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
  }

  @IsTest
  private static void setDefinition_missingOpeningParenthesis4_expectFailure() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestText__c', 'Static Value "arg1", arg2)');
    obj.insertRecords(true);
    Test.stopTest();

    String expectedResult = 'Invalid syntax in definition [Static Value "arg1", arg2)] of field [TestText__c]';
    String actualResult = obj.getErrors().get('TestText__c').get(0);
    System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
  }

  @IsTest
  private static void setDefinition_missingClosingParenthesis1_expectFailure() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestText__c', 'Static Value(arg1');
    obj.insertRecords(true);
    Test.stopTest();

    String expectedResult = 'Invalid syntax in definition [Static Value(arg1] of field [TestText__c]';
    String actualResult = obj.getErrors().get('TestText__c').get(0);
    System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
  }

  @IsTest
  private static void setDefinition_missingClosingParenthesis2_expectFailure() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestText__c', ' Static  Value("arg1" ');
    obj.insertRecords(true);
    Test.stopTest();

    String expectedResult = 'Invalid syntax in definition [Static  Value("arg1"] of field [TestText__c]';
    String actualResult = obj.getErrors().get('TestText__c').get(0);
    System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
  }

  @IsTest
  private static void setDefinition_missingClosingParenthesis3_expectFailure() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestText__c', 'Static Value(arg1, arg2');
    obj.insertRecords(true);
    Test.stopTest();

    String expectedResult = 'Invalid syntax in definition [Static Value(arg1, arg2] of field [TestText__c]';
    String actualResult = obj.getErrors().get('TestText__c').get(0);
    System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
  }

  @IsTest
  private static void setDefinition_missingClosingParenthesis4_expectFailure() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestText__c', 'Static Value("arg1", arg2');
    obj.insertRecords(true);
    Test.stopTest();

    String expectedResult = 'Invalid syntax in definition [Static Value("arg1", arg2] of field [TestText__c]';
    String actualResult = obj.getErrors().get('TestText__c').get(0);
    System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
  }

  @IsTest
  private static void setDefinition_missingComma1_expectFailure() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestText__c', 'Static Value("arg1" arg2)');
    obj.insertRecords(true);
    Test.stopTest();

    String expectedResult = 'Invalid syntax in definition [Static Value("arg1" arg2)] of field [TestText__c]';
    String actualResult = obj.getErrors().get('TestText__c').get(0);
    System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
  }

  @IsTest
  private static void setDefinition_missingComma2_expectFailure() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestText__c', 'Random Type(List) Value(arg1 "arg2")');
    obj.insertRecords(true);
    Test.stopTest();

    String expectedResult = 'Invalid syntax in definition [Random Type(List) Value(arg1 "arg2")] of field [TestText__c]';
    String actualResult = obj.getErrors().get('TestText__c').get(0);
    System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
  }

  @IsTest
  private static void setDefinition_missingOpeningingDoubleQuotes1_expectFailure() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestText__c', 'Static Value(arg1")');
    obj.insertRecords(true);
    Test.stopTest();

    String expectedResult = 'Invalid syntax in definition [Static Value(arg1")] of field [TestText__c]';
    String actualResult = obj.getErrors().get('TestText__c').get(0);
    System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
  }

  @IsTest
  private static void setDefinition_missingOpeningingDoubleQuotes2_expectFailure() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestText__c', 'Random Type(List) Value(arg1, arg2")');
    obj.insertRecords(true);
    Test.stopTest();

    String expectedResult = 'Invalid syntax in definition [Random Type(List) Value(arg1, arg2")] of field [TestText__c]';
    String actualResult = obj.getErrors().get('TestText__c').get(0);
    System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
  }

  @IsTest
  private static void setDefinition_missingOpeningingDoubleQuotes3_expectFailure() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestText__c', 'Random Type(List) Value(arg1", "arg2")');
    obj.insertRecords(true);
    Test.stopTest();

    String expectedResult = 'Invalid syntax in definition [Random Type(List) Value(arg1", "arg2")] of field [TestText__c]';
    String actualResult = obj.getErrors().get('TestText__c').get(0);
    System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
  }

  @IsTest
  private static void setDefinition_missingClosingDoubleQuotes1_expectFailure() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestText__c', 'Static Value("arg1)');
    obj.insertRecords(true);
    Test.stopTest();

    String expectedResult = 'Invalid syntax in definition [Static Value("arg1)] of field [TestText__c]';
    String actualResult = obj.getErrors().get('TestText__c').get(0);
    System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
  }

  @IsTest
  private static void setDefinition_missingClosingDoubleQuotes2_expectFailure() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestText__c', 'Random Type(List) Value(arg1, "arg2)');
    obj.insertRecords(true);
    Test.stopTest();

    String expectedResult = 'Invalid syntax in definition [Random Type(List) Value(arg1, "arg2)] of field [TestText__c]';
    String actualResult = obj.getErrors().get('TestText__c').get(0);
    System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
  }

  @IsTest
  private static void setDefinition_missingClosingDoubleQuotes3_expectFailure() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestText__c', 'Random Type(List) Value("arg1, arg2)');
    obj.insertRecords(true);
    Test.stopTest();

    String expectedResult = 'Invalid syntax in definition [Random Type(List) Value("arg1, arg2)] of field [TestText__c]';
    String actualResult = obj.getErrors().get('TestText__c').get(0);
    System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
  }

  @IsTest
  private static void setDefinition_invalidComma_expectFailure() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
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
    FObject obj = new FObject('FObjectOne__c');
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
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestText__c', 'Random Type(List) Value" (arg1, "arg2")');
    obj.insertRecords(true);
    Test.stopTest();

    String expectedResult = 'Invalid parameter [Value"] in definition [Random Type(List) Value" (arg1, "arg2")]';
    String actualResult = obj.getErrors().get('TestText__c').get(0);
    System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
  }

  @IsTest
  private static void setDefinition_invalidDoubleQuotes3_expectFailure() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestText__c', 'Random Type(List) Value(ar"g1, "arg2")');
    obj.insertRecords(true);
    Test.stopTest();

    String expectedResult = 'Invalid syntax in definition [Random Type(List) Value(ar"g1, "arg2")] of field [TestText__c]';
    String actualResult = obj.getErrors().get('TestText__c').get(0);
    System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
  }

  @IsTest
  private static void setDefinition_invalidDoubleQuotes4_expectFailure() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestText__c', 'Random Type(List) Value(arg1, ""arg2")');
    obj.insertRecords(true);
    Test.stopTest();

    String expectedResult = 'Invalid syntax in definition [Random Type(List) Value(arg1, ""arg2")] of field [TestText__c]';
    String actualResult = obj.getErrors().get('TestText__c').get(0);
    System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
  }

  @IsTest
  private static void setDefinition_invalidDoubleQuotes5_expectFailure() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestText__c', 'Random Type(List) Value(arg1, "arg2"")');
    obj.insertRecords(true);
    Test.stopTest();

    String expectedResult = 'Invalid syntax in definition [Random Type(List) Value(arg1, "arg2"")] of field [TestText__c]';
    String actualResult = obj.getErrors().get('TestText__c').get(0);
    System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
  }

  @IsTest
  private static void setDefinition_invalidDoubleQuotes6_expectFailure() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestText__c', 'Random Type(List) Value(arg1, "arg2")"');
    obj.insertRecords(true);
    Test.stopTest();

    String expectedResult = 'Invalid syntax in definition [Random Type(List) Value(arg1, "arg2")"] of field [TestText__c]';
    String actualResult = obj.getErrors().get('TestText__c').get(0);
    System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
  }

  @IsTest
  private static void setDefinition_fieldIsBlank_expectFailure() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('', 'Static Value(Company)');
    obj.insertRecords(true);
    Test.stopTest();

    String expectedResult = 'Invalid field [] for definition [Static Value(Company)]';
    String actualResult = obj.getErrors().get('FObjectOne__c').get(0);
    System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
  }

  @IsTest
  private static void setDefinition_fieldIsInvalid_expectFailure() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestTextX__c', 'Static Value(Company)');
    obj.insertRecords(true);
    Test.stopTest();

    String expectedResult = 'Invalid field [TestTextX__c] for definition [Static Value(Company)]';
    String actualResult = obj.getErrors().get('FObjectOne__c').get(0);
    System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
  }

  @IsTest
  private static void setDefinition_invalidCommand_expectFailure() {
    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
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
    FObject obj = new FObject('FObjectOne__c');
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
    FObject obj = new FObject('FObjectOne__c');
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
    FObject obj = new FObject('FObjectOne__c');
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
    FObject obj = new FObject('FObjectOne__c');
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
    FObject obj = new FObject('FObjectOne__c');
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
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestText__c', 'Static "(Company)');
    obj.insertRecords(true);
    Test.stopTest();

    String expectedResult = 'Invalid parameter ["] in definition [Static "(Company)]';
    String actualResult = obj.getErrors().get('TestText__c').get(0);
    System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
  }

  @IsTest
  private static void setDefinition_multipleDefinitionsForCheckbox_expectFailure() {
    String fieldApiName = 'TestCheckbox__c';

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition(fieldApiName, 'random type(boolean)');
    obj.setDefinition(fieldApiName, 'static value(true)');
    obj.insertRecords(true);
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
    obj.insertRecords(true);
    Test.stopTest();

    System.assertEquals(true, obj.getErrors().isEmpty(), 'setDefinition - errors found');
  }


  @IsTest
  private static void setDefinition_multipleDefinitionsForCurrency_expectFailure() {
    String fieldApiName = 'TestCurrency__c';

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
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
    FObject obj = new FObject('FObjectOne__c');
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
    FObject obj = new FObject('FObjectOne__c');
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
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition(fieldApiName, 'static value(myname@)');
    obj.setDefinition(fieldApiName, 'static value(company.com)');
    obj.insertRecords(true);
    Test.stopTest();

    System.assertEquals(true, obj.getErrors().isEmpty(), 'setDefinition - errors found');
  }

  @IsTest
  private static void setDefinition_multipleDefinitionsForLookup_expectFailure() {
    String fieldApiName = 'TestLookup__c';

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
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
    FObject obj = new FObject('FObjectOne__c');
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
    FObject obj = new FObject('FObjectOne__c');
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
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition(fieldApiName, 'random type(number) from(0) to (1) scale(2)');
    obj.setDefinition(fieldApiName, 'static value(0.2)');
    obj.insertRecords(true);
    Test.stopTest();

    String expectedResult = 'Field [' + fieldApiName + '] does not accept multiple definitions';
    String actualResult = obj.getErrors().get(fieldApiName).get(0);
    System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
  }

  @IsTest
  private static void setDefinition_multipleDefinitionsForPhone_expectSuccess() {
    String fieldApiName = 'TestPhone__c';

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition(fieldApiName, 'static value(210)');
    obj.setDefinition(fieldApiName, 'random type(number) from(111111) to (999999) scale(0)');
    obj.insertRecords(true);
    Test.stopTest();

    System.assertEquals(true, obj.getErrors().isEmpty(), 'setDefinition - errors found');
  }

  @IsTest
  private static void setDefinition_multipleDefinitionsForPicklist_expectFailure() {
    String fieldApiName = 'TestPicklistA__c';

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition(fieldApiName, 'static value(a1)');
    obj.setDefinition(fieldApiName, 'random type(list) value(a0,a1,a2,a3)');
    obj.insertRecords(true);
    Test.stopTest();

    String expectedResult = 'Field [' + fieldApiName + '] does not accept multiple definitions';
    String actualResult = obj.getErrors().get(fieldApiName).get(0);
    System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
  }

  @IsTest
  private static void setDefinition_multipleDefinitionsForText_expectSuccess() {
    String fieldApiName = 'TestText__c';

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition(fieldApiName, 'static value(Company1)');
    obj.setDefinition(fieldApiName, 'static value(Company2)');
    obj.insertRecords(true);
    Test.stopTest();

    System.assertEquals(true, obj.getErrors().isEmpty(), 'setDefinition - errors found');
  }

  @IsTest
  private static void setDefinition_multipleDefinitionsForTextArea_expectSuccess() {
    String fieldApiName = 'TestTextArea__c';

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition(fieldApiName, 'static value(Company1)');
    obj.setDefinition(fieldApiName, 'static value(Company2)');
    obj.insertRecords(true);
    Test.stopTest();

    System.assertEquals(true, obj.getErrors().isEmpty(), 'setDefinition - errors found');
  }

  @IsTest
  private static void setDefinition_multipleDefinitionsForTextAreaLong_expectSuccess() {
    String fieldApiName = 'TestTextAreaLong__c';

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition(fieldApiName, 'static value(Company1)');
    obj.setDefinition(fieldApiName, 'static value(Company2)');
    obj.insertRecords(true);
    Test.stopTest();

    System.assertEquals(true, obj.getErrors().isEmpty(), 'setDefinition - errors found');
  }

  @IsTest
  private static void setDefinition_multipleDefinitionsForTextAreaRich_expectSuccess() {
    String fieldApiName = 'TestTextAreaRich__c';

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition(fieldApiName, 'static value(Company1)');
    obj.setDefinition(fieldApiName, 'static value(Company2)');
    obj.insertRecords(true);
    Test.stopTest();

    System.assertEquals(true, obj.getErrors().isEmpty(), 'setDefinition - errors found');
  }

  @IsTest
  private static void setDefinition_multipleDefinitionsForTime_expectFailure() {
    String fieldApiName = 'TestTime__c';

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition(fieldApiName, 'static value(10:10:10)');
    obj.setDefinition(fieldApiName, 'static value(11:11:11)');
    obj.insertRecords(true);
    Test.stopTest();

    String expectedResult = 'Field [' + fieldApiName + '] does not accept multiple definitions';
    String actualResult = obj.getErrors().get(fieldApiName).get(0);
    System.assertEquals(expectedResult, actualResult, 'setDefinition - errors found');
  }

  @IsTest
  private static void setDefinition_multipleDefinitionsForUrl_expectSuccess() {
    String fieldApiName = 'TestUrl__c';

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition(fieldApiName, 'static value(http:///www.company)');
    obj.setDefinition(fieldApiName, 'serial type(number) from(1) step(1) scale(0)');
    obj.setDefinition(fieldApiName, 'static value(.com)');
    obj.insertRecords(true);
    Test.stopTest();

    System.assertEquals(true, obj.getErrors().isEmpty(), 'setDefinition - errors found');
  }

  /* method setDefinitionFromField */

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

    List<String> definitions = obj.getFieldDefinitions('Name');
    String expectedResult = 'static value(Company) random type(number) from(1) to(10000) scale(0)';
    String actualResult = definitions[0] + ' ' + definitions[1];
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

    String expectedResult = 'random type(firstname) group(name)';
    String actualResult = obj.getFieldDefinitions(fieldApiName).get(0);
    System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
  }

  //@isTest
  //private static void setDefinitionFromField_firstAndLastHaveSameGroup_expectSuccess() {
  //  // check that the auto-generated definition for names has the group argument
  //  // of the first "pair" name
  //  String fieldApiName = 'FirstName';

  //  Test.startTest();
  //  FObject obj = new FObject('Contact');
  //  FObject.Field field = new FObject.Field();
  //  field.fieldName = fieldApiName;
  //  field.fieldApiName = fieldApiName;
  //  obj.setDefinitionFromField(field);
  //  Test.stopTest();

  //  String expectedResult = 'random type(firstname) group(name)';
  //  String actualResult = obj.getFieldDefinitions(fieldApiName).get(0);
  //  System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
  //}

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

    String expectedResult = 'random type(lastname) group(name)';
    String actualResult = obj.getFieldDefinitions(fieldApiName).get(0);
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

    List<String> definitions = obj.getFieldDefinitions(fieldApiName);
    String expectedResult = 'static value(Company) random type(number) from(1) to(10000) scale(0)';
    String actualResult = definitions[0] + ' ' + definitions[1];
    System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
  }

  @IsTest
  private static void setDefinitionFromField_leadFirstName_expectSuccess() {
    String fieldApiName = 'FirstName';

    Test.startTest();
    FObject obj = new FObject('Lead');
    FObject.Field field = new FObject.Field();
    field.fieldName = fieldApiName;
    field.fieldApiName = fieldApiName;
    obj.setDefinitionFromField(field);
    Test.stopTest();

    String expectedResult = 'random type(firstname) group(name)';
    String actualResult = obj.getFieldDefinitions(fieldApiName).get(0);
    System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
  }

  @IsTest
  private static void setDefinitionFromField_leadLastName_expectSuccess() {
    String fieldApiName = 'LastName';

    Test.startTest();
    FObject obj = new FObject('Lead');
    FObject.Field field = new FObject.Field();
    field.fieldName = fieldApiName;
    field.fieldApiName = fieldApiName;
    obj.setDefinitionFromField(field);
    Test.stopTest();

    String expectedResult = 'random type(lastname) group(name)';
    String actualResult = obj.getFieldDefinitions(fieldApiName).get(0);
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

    List<String> definitions = obj.getFieldDefinitions(fieldApiName);
    String expectedResult = 'static value(Opportunity-) serial type(number) from(1) step(1) scale(0)';
    String actualResult = definitions[0] + ' ' + definitions[1];
    System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
  }

  @IsTest
  private static void setDefinitionFromField_boolean_expectSuccess() {
    String fieldApiName = 'TestCheckbox__c';

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    FObject.Field field = new FObject.Field();
    field.fieldName = fieldApiName;
    field.fieldApiName = fieldApiName;
    field.dataType = Schema.DisplayType.Boolean;
    obj.setDefinitionFromField(field);
    Test.stopTest();

    String expectedResult = 'random type(boolean)';
    String actualResult = obj.getFieldDefinitions(fieldApiName).get(0);
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
    String actualResult = obj.getFieldDefinitions(fieldApiName).get(0);
    System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
  }

  @IsTest
  private static void setDefinitionFromField_currency_expectSuccess() {
    String fieldApiName = 'TestCurrency__c';

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    FObject.Field field = new FObject.Field();
    field.fieldName = fieldApiName;
    field.fieldApiName = fieldApiName;
    field.dataType = Schema.DisplayType.Currency;
    obj.setDefinitionFromField(field);
    Test.stopTest();

    String expectedResult = 'random type(number) from(1000) to(10000) scale(2)';
    String actualResult = obj.getFieldDefinitions(fieldApiName).get(0);
    System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
  }

  @IsTest
  private static void setDefinitionFromField_date_expectSuccess() {
    String fieldApiName = 'TestDate__c';

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
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
    String actualResult = obj.getFieldDefinitions(fieldApiName).get(0);
    System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
  }

  @IsTest
  private static void setDefinitionFromField_datetime_expectSuccess() {
    String fieldApiName = 'TestDatetime__c';

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    FObject.Field field = new FObject.Field();
    field.fieldName = fieldApiName;
    field.fieldApiName = fieldApiName;
    field.dataType = Schema.DisplayType.DateTime;
    obj.setDefinitionFromField(field);
    Test.stopTest();

    Integer thisYear = Date.today().year();
    String fromDate = String.valueOf(thisYear - 1) + '-01-01';
    String toDate = String.valueOf(thisYear + 1) + '-12-31';

    String expectedResult = 'random type(datetime) from(' + fromDate + ') to(' + toDate + ')';
    String actualResult = obj.getFieldDefinitions(fieldApiName).get(0);
    System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
  }

  @IsTest
  private static void setDefinitionFromField_double_expectSuccess() {
    String fieldApiName = 'TestDecimal__c';

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    FObject.Field field = new FObject.Field();
    field.fieldName = fieldApiName;
    field.fieldApiName = fieldApiName;
    field.dataType = Schema.DisplayType.Double;
    obj.setDefinitionFromField(field);
    Test.stopTest();

    String expectedResult = 'random type(number) from(1000) to(10000) scale(3)';
    String actualResult = obj.getFieldDefinitions(fieldApiName).get(0);
    System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
  }

  @IsTest
  private static void setDefinitionFromField_email_expectSuccess() {
    String fieldApiName = 'TestEmail__c';

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    FObject.Field field = new FObject.Field();
    field.fieldName = fieldApiName;
    field.fieldApiName = fieldApiName;
    field.dataType = Schema.DisplayType.Email;
    obj.setDefinitionFromField(field);
    Test.stopTest();

    String expectedResult = 'random type(email)';
    String actualResult = obj.getFieldDefinitions(fieldApiName).get(0);
    System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
  }

  @IsTest
  private static void setDefinitionFromField_integer_expectSuccess() {
    String fieldApiName = 'TestInteger__c';

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    FObject.Field field = new FObject.Field();
    field.fieldName = fieldApiName;
    field.fieldApiName = fieldApiName;
    field.dataType = Schema.DisplayType.Integer;
    obj.setDefinitionFromField(field);
    Test.stopTest();

    String expectedResult = 'random type(number) from(1) to(100) scale(0)';
    String actualResult = obj.getFieldDefinitions(fieldApiName).get(0);
    System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
  }

  @IsTest
  private static void setDefinitionFromField_multiPicklist_expectSuccess() {
    String fieldApiName = 'TestMultiPicklistA__c';

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    FObject.Field field = new FObject.Field();
    field.fieldName = fieldApiName;
    field.fieldApiName = fieldApiName;
    field.dataType = Schema.DisplayType.MultiPicklist;
    obj.setDefinitionFromField(field);
    Test.stopTest();

    String expectedResult = 'random type(picklist)';
    String actualResult = obj.getFieldDefinitions(fieldApiName).get(0);
    System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
  }

  @IsTest
  private static void setDefinitionFromField_percent_expectSuccess() {
    String fieldApiName = 'TestPercent__c';

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    FObject.Field field = new FObject.Field();
    field.fieldName = fieldApiName;
    field.fieldApiName = fieldApiName;
    field.dataType = Schema.DisplayType.Percent;
    obj.setDefinitionFromField(field);
    Test.stopTest();

    String expectedResult = 'random type(number) from(0) to(100) scale(2)';
    String actualResult = obj.getFieldDefinitions(fieldApiName).get(0);
    System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
  }

  @IsTest
  private static void setDefinitionFromField_phone_expectSuccess() {
    String fieldApiName = 'TestPhone__c';

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    FObject.Field field = new FObject.Field();
    field.fieldName = fieldApiName;
    field.fieldApiName = fieldApiName;
    field.dataType = Schema.DisplayType.Phone;
    obj.setDefinitionFromField(field);
    Test.stopTest();

    String expectedResult = 'static value(21011) random type(number) from(11111) to(99999) scale(0)';
    String actualResult = obj.getFieldDefinitions(fieldApiName).get(0) + ' ' +
      obj.getFieldDefinitions(fieldApiName).get(1);
    System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
  }

  @IsTest
  private static void setDefinitionFromField_picklist_expectSuccess() {
    String fieldApiName = 'TestPicklistA__c';

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    FObject.Field field = new FObject.Field();
    field.fieldName = fieldApiName;
    field.fieldApiName = fieldApiName;
    field.dataType = Schema.DisplayType.MultiPicklist;
    obj.setDefinitionFromField(field);
    Test.stopTest();

    String expectedResult = 'random type(picklist)';
    String actualResult = obj.getFieldDefinitions(fieldApiName).get(0);
    System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
  }

  @IsTest
  private static void setDefinitionFromField_reference_expectSuccess() {
    String fieldApiName = 'TestLookup__c';
    Schema.sObjectType parentType = Schema.FObjectTwo__c.getSObjectType();
    List<Schema.sObjectType> parents = new List<Schema.sObjectType>{
      parentType
    };

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    FObject.Field field = new FObject.Field();
    field.fieldName = fieldApiName;
    field.fieldApiName = fieldApiName;
    field.dataType = Schema.DisplayType.Reference;
    field.parents = parents;
    obj.setDefinitionFromField(field);
    Test.stopTest();

    String expectedResult = 'random lookup(FObjectTwo__c) source(forceea)';
    String actualResult = obj.getFieldDefinitions(fieldApiName).get(0);
    System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
  }

  @IsTest
  private static void setDefinitionFromField_string_expectSuccess() {
    String fieldApiName = 'TestText__c';

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    FObject.Field field = new FObject.Field();
    field.fieldName = fieldApiName;
    field.fieldApiName = fieldApiName;
    field.length = 20;
    field.dataType = Schema.DisplayType.String;
    obj.setDefinitionFromField(field);
    Test.stopTest();

    String expectedResult = 'random type(string) minlength(5) maxlength(20) startwith(upper) include(lower,upper)';
    String actualResult = obj.getFieldDefinitions(fieldApiName).get(0);
    System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
  }

  @IsTest
  private static void setDefinitionFromField_textArea_expectSuccess() {
    String fieldApiName = 'TestTextArea__c';

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    FObject.Field field = new FObject.Field();
    field.fieldName = fieldApiName;
    field.fieldApiName = fieldApiName;
    field.dataType = Schema.DisplayType.TextArea;
    obj.setDefinitionFromField(field);
    Test.stopTest();

    String expectedResult = 'random type(text) minlength(30) maxlength(100)';
    String actualResult = obj.getFieldDefinitions(fieldApiName).get(0);
    System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
  }

  @IsTest
  private static void setDefinitionFromField_time_expectSuccess() {
    String fieldApiName = 'TestTime__c';

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    FObject.Field field = new FObject.Field();
    field.fieldName = fieldApiName;
    field.fieldApiName = fieldApiName;
    field.dataType = Schema.DisplayType.Time;
    obj.setDefinitionFromField(field);
    Test.stopTest();

    String expectedResult = 'static value(12:00:00)';
    String actualResult = obj.getFieldDefinitions(fieldApiName).get(0);
    System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
  }

  @IsTest
  private static void setDefinitionFromField_url_expectSuccess() {
    String fieldApiName = 'TestUrl__c';

    Test.startTest();
    FObject obj = new FObject('FObjectOne__c');
    FObject.Field field = new FObject.Field();
    field.fieldName = fieldApiName;
    field.fieldApiName = fieldApiName;
    field.dataType = Schema.DisplayType.Url;
    obj.setDefinitionFromField(field);
    Test.stopTest();

    String expectedResult = 'random type(url)';
    String actualResult = obj.getFieldDefinitions(fieldApiName).get(0);
    System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField - errors found');
  }

  @IsTest
  private static void setVerbose_valid_expectSuccess() {
    Test.startTest();
    FObject.setGlobalVerbose('none');
    FObject obj = new FObject('FObjectOne__c', 10);
    obj.setVerbose('none');
    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();

    FObject.setGlobalVerbose('info');
    obj = new FObject('FObjectOne__c', 10);
    obj.setVerbose('info');
    records = (List<FObjectOne__c>) obj.getRecords();

    FObject.setGlobalVerbose('debug');
    obj = new FObject('FObjectOne__c', 10);
    obj.setVerbose('debug');
    records = (List<FObjectOne__c>) obj.getRecords();
    Test.stopTest();

    System.assertEquals(true, obj.getErrors().isEmpty(), 'setDefinition - errors found for multiple definitions');
  }

  /* HELPER METHODS */

  //private static List<Database.SaveResult> insertRecords(
  //    String objectApiName, Integer numRecords, List<String> definitions, Boolean allOrNone) {
  //  String fieldApiName = '';
  //  String definitionString = '';
  //  FObject obj = new FObject(objectApiName, numRecords);

  //  for (String definition : definitions) {
  //    fieldApiName = definition.substringBefore('@').trim();
  //    definitionString = definition.substringAfter('@').trim();
  //    obj.setDefinition(fieldApiName, definitionString);
  //  }
  //  Database.SaveResult[] results = obj.insertRecords(allOrNone);
  //  return results;
  //}

  /**
   * @description Validates the distribution of a field based on a specific list of String values.
   * @param obj The FObject.
   * @param fieldApiName The field API name.
   * @param validDefinitions The list of valid definitions.
   * @param invalidDefinitions The list of invalid definitions.
   * @return Returns a boolean value.
   */
  private static Boolean checkMultipleDefinitions(
    FObject obj, String fieldApiName, List<String> validDefinitions, List<String> invalidDefinitions) {
    Boolean result = true;

    for (String definition : validDefinitions) {
      obj.setDefinition(fieldApiName, definition);
    }
    for (String definition : invalidDefinitions) {
      obj.setDefinition(fieldApiName, definition);
    }
    obj.getRecords();

    String expectedResult = '';
    Integer counter = 0;
    Integer errors = 0;
    for (String actualResult : obj.getErrors().get(fieldApiName)) {
      if (!actualResult.startsWith('Invalid definition [')) {
        continue;
      }
      expectedResult = 'Invalid definition [' + invalidDefinitions[counter] + '] for the data type of field [' +
        fieldApiName + ']';
      if (expectedResult != actualResult) {
        errors++;
      }
      counter++;
    }

    if (errors != invalidDefinitions.size()) {
      result = false;
    }

    return result;
  }

  /**
   * @description Validates the distribution of a field based on a specific list of String values.
   * @param fieldName The API name of the field.
   * @param values The assessed field values of type String.
   * @param records The list of SObject records to assess.
   * @return Returns a boolean value.
   */
  private static Boolean isValidDistribution(String fieldName, List<String> values, List<SObject> records) {
    if (values.isEmpty() || records.isEmpty()) {
      return false;
    }

    Boolean result = true;
    Set<String> valuesSet = new Set<String>(values);

    // the number of times each unique item was found in the values list
    Map<String, Integer> frequenciesMap = new Map<String, Integer>();
    // the expected average of each unique item of the values list
    Map<String, Decimal> expectedAveragesMap = new Map<String, Decimal>();
    // the number of times each unique item of the values list was found in the records list
    Map<String, Integer> occurrenciesMap = new Map<String, Integer>();

    // initialize maps
    for (String value : valuesSet) {
      frequenciesMap.put(value, 0);
      expectedAveragesMap.put(value, 0);
      occurrenciesMap.put(value, 0);
    }

    // populate frequencies map
    for (String value : values) {
      frequenciesMap.put(value, frequenciesMap.get(value) + 1);
    }

    // populate expected averages map
    Decimal val = 0;
    for (String value : valuesSet) {
      val = Decimal.valueOf(frequenciesMap.get(value)) / values.size();
      expectedAveragesMap.put(value, val);
    }

    // populate occurrencies map
    String valueToString = '';
    for (SObject record : records) {
      valueToString = String.valueOf(record.get(fieldName));
      if (valuesSet.contains(valueToString)) {
        occurrenciesMap.put(valueToString, occurrenciesMap.get(valueToString) + 1);
      }
    }

    // assess any deviations
    if (valuesSet.size() == 1) {
      if (occurrenciesMap.get(values[0]) != records.size()) {
        result = false;
      }
    } else {
      Decimal expectedAverage = 0;
      Decimal actualAverage = 0;
      for (String value : valuesSet) {
        expectedAverage = expectedAveragesMap.get(value);
        actualAverage = Decimal.valueOf(occurrenciesMap.get(value)) / records.size();
        if (actualAverage < (0.25 * expectedAverage) || actualAverage > (1.75 * expectedAverage)) {
          result = false;
          break;
        }
      }
    }

    return result;
  }

  /**
   * @description Validates the distribution of a field based on a specific list of String values.
   * @param fieldName The API name of the field.
   * @param values The assessed field values of type Datetime.
   * @param records The list of SObject records to assess.
   * @return Returns a boolean value.
   */
  private static Boolean isValidDistribution(String fieldName, List<Datetime> values, List<SObject> records) {
    if (values.isEmpty() || records.isEmpty()) {
      return false;
    }

    Boolean result = true;
    Set<Datetime> valuesSet = new Set<Datetime>(values);

    // the number of times each unique item was found in the values list
    Map<Datetime, Integer> frequenciesMap = new Map<Datetime, Integer>();
    // the expected average of each unique item of the values list
    Map<Datetime, Decimal> expectedAveragesMap = new Map<Datetime, Decimal>();
    // the number of times each unique item of the values list was found in the records list
    Map<Datetime, Integer> occurrenciesMap = new Map<Datetime, Integer>();

    // initialize maps
    for (Datetime value : valuesSet) {
      frequenciesMap.put(value, 0);
      expectedAveragesMap.put(value, 0);
      occurrenciesMap.put(value, 0);
    }

    // populate frequencies map
    for (Datetime value : values) {
      frequenciesMap.put(value, frequenciesMap.get(value) + 1);
    }

    // populate expected averages map
    Decimal val = 0;
    for (Datetime value : valuesSet) {
      val = Decimal.valueOf(frequenciesMap.get(value)) / values.size();
      expectedAveragesMap.put(value, val);
    }

    // populate occurrencies map
    Datetime valueToDatetime;
    for (SObject record : records) {
      valueToDatetime = (Datetime) record.get(fieldName);
      if (valuesSet.contains(valueToDatetime)) {
        occurrenciesMap.put(valueToDatetime, occurrenciesMap.get(valueToDatetime) + 1);
      }
    }

    // assess any deviations
    if (valuesSet.size() == 1) {
      if (occurrenciesMap.get(values[0]) != records.size()) {
        result = false;
      }
    } else {
      Decimal expectedAverage = 0;
      Decimal actualAverage = 0;
      for (Datetime value : valuesSet) {
        expectedAverage = expectedAveragesMap.get(value);
        actualAverage = Decimal.valueOf(occurrenciesMap.get(value)) / records.size();
        if (actualAverage < (0.25 * expectedAverage) || actualAverage > (1.75 * expectedAverage)) {
          result = false;
          break;
        }
      }
    }

    return result;
  }

  /**
   * @description Validates the distribution of a field based on a specific list of Integer values.
   * @param fieldName The API name of the field.
   * @param values The assessed field values of type Integer.
   * @param records The list of SObject records to assess.
   * @return Returns a boolean value.
   */
  private static Boolean isValidDistribution(String fieldName, List<Integer> values, List<SObject> records) {
    List<String> valuesToString = new List<String>();

    for (Integer value : values) {
      valuesToString.add(String.valueOf(value));
    }

    return isValidDistribution(fieldName, valuesToString, records);
  }

  /**
   * @description Validates the distribution of a field based on a specific list of Integer values.
   * @param fieldName The API name of the field.
   * @param values The assessed field values of type Id.
   * @param records The list of SObject records to assess.
   * @return Returns a boolean value.
   */
  private static Boolean isValidDistribution(String fieldName, List<Id> values, List<SObject> records) {
    List<String> valuesToString = new List<String>();

    for (Id value : values) {
      valuesToString.add(String.valueOf(value));
    }

    return isValidDistribution(fieldName, valuesToString, records);
  }

  private static void loadNamesFromGreeceInGreek() {
    femaleFirstNames = new Set<String>{
      'Νάντια', 'Διονυσία', 'Τάνια', 'Αδαμαντία', 'Αλίκη', 'Βασιλική', 'Φανή', 'Καίτη', 'Χρύσα', 'Μάγδα', 'Ηλιάνα',
      'Όλγα', 'Γεωργία', 'Μαριάνθη', 'Άρτεμις', 'Άντζελα', 'Στέλλα', 'Ζωή', 'Ανθή', 'Ευθυμία', 'Αγγελική', 'Τόνια',
      'Ντίνα', 'Ρίτα', 'Ντόρα', 'Αλεξία', 'Παυλίνα', 'Ρένα', 'Σοφία', 'Στεφανία', 'Λένα', 'Τζίνα', 'Γιούλη', 'Νεκταρία',
      'Ρέα', 'Γιώτα', 'Λίζα', 'Ελένη', 'Άννα', 'Έλενα', 'Αικατερίνη', 'Ρούλα', 'Παναγιώτα',
      'Ευγενία', 'Εμμανουέλα', 'Μαριέττα', 'Μυρσίνη', 'Μαρκέλλα', 'Τριανταφυλλιά', 'Αφροδίτη'
    };
    femaleLastNames = new Set<String>{
      'Βαλαέτη', 'Σφακάκη', 'Καλογιάννη', 'Παυλίδου', 'Οικονόμου', 'Ανέστου', 'Κολάρου', 'Θανασούλια', 'Μωραίτη',
      'Κανατούλα', 'Τσιλιδέλου', 'Ανάγνου', 'Μαρινέα', 'Πατέρου', 'Μυρτσίδου', 'Μποτονάκη', 'Μυλωνάκη', 'Αρβανίτη',
      'Κυριαζή', 'Πασχαλίδη', 'Καμηλιέρη', 'Παπαμιχάλη', 'Σούρτζη', 'Κωφοτόλη', 'Μακρίδου', 'Γιαννιού', 'Λεοτσάκου',
      'Ζακυνθινού', 'Τσιγαρίδα', 'Σαββάκη', 'Καρτσιώτου', 'Μπενάκη', 'Γκυτάκου', 'Πολυζώη', 'Σταθάκου', 'Κουμουτσέα',
      'Πανίτσα', 'Κυριακάκου', 'Αναγνώστου', 'Πουρναράκη', 'Μαυρωνά', 'Μητακίδου', 'Γρηγοράτου', 'Στεφανάκη',
      'Κορνελάτου', 'Καλλινίκου', 'Καρανάσου', 'Τσιντέα', 'Τζεβελέκου', 'Γεωργίου', 'Δημουλά', 'Ξηρουχάκη', 'Λουκανίδου',
      'Κυνηγαλάκη', 'Κιοβρέκη', 'Μιαούλη', 'Σαραμπάλου', 'Μεταλλίδου', 'Κατσαρού', 'Απιδιανάκη', 'Κολέτου', 'Μανανδράκη',
      'Βαφειάδου', 'Αξιάρχου', 'Κωσταλούπη', 'Αλεξιάδου', 'Αντωνένα', 'Νικολαϊδου', 'Ιγγλέζου', 'Δημοπούλου', 'Πελεκάνου',
      'Θεοδωράκη', 'Πορτίδου', 'Γιαννακού', 'Νανοπούλου', 'Θεριανού', 'Σουσώνη', 'Τσακμακλή', 'Τριλιούρη', 'Πιτσιλαδή',
      'Τσαχάκη', 'Τραγάκη', 'Θεολογίτη', 'Αλεβίζου', 'Γιαννακάκη', 'Κοπάνου', 'Ζωγράφου', 'Αναστάση', 'Μαλλιάπη',
      'Τσουμπρή', 'Πιτσίκα', 'Τζουμάκα', 'Αδριανή', 'Αλλιζώτη', 'Καραμάνου', 'Συκινιώτη', 'Κοτσίρη', 'Γιαλαμά', 'Τσιτσινάκη',
      'Τσαβάλου', 'Σκοτίδη', 'Σταύρου', 'Ανδρέου', 'Ζορμπάνου', 'Ζηνοπούλου', 'Κοροσίδου', 'Σκαλάτη', 'Λογοθέτη',
      'Ιακωβίδου', 'Βαρζακάκου', 'Αμπατζή', 'Γκιουλέα', 'Κουταβά', 'Μερκουρίου', 'Κυρίτση', 'Καζεπίδου', 'Μαμιδάκη',
      'Κουμπούρη', 'Ελευθεράκη', 'Αντωνιάδου', 'Φωτακέλη', 'Χριστοφίλη', 'Κομηνέα', 'Καφετζή', 'Πολεμίτου', 'Λαλιώτη',
      'Γεωργούση', 'Γιόκαλα', 'Ορφανού', 'Αφαντίτη', 'Κασιμάτη', 'Καψουλάκη', 'Κωτσοβού', 'Παντάκη', 'Ραπτάκη', 'Κουτσιάφτη',
      'Καλλέργη', 'Μπορμπιλά', 'Φρέντζα', 'Τσισκάκη', 'Ιωάννου', 'Βιλλιώτη', 'Καλογερά', 'Λαμπρίδου', 'Βολιώτου',
      'Φουσέκη', 'Βαρσάμη', 'Πίκουλα', 'Καμπουρίδη', 'Χανιώτη', 'Κληρονόμου', 'Σούλτου', 'Αποστολου', 'Νεράντζη', 'Μπαμίχα',
      'Μαρίνου', 'Χαμπέρη', 'Γαλάτουλα', 'Αλεξάτου', 'Καραμιχάλη', 'Λαζάρου', 'Αργυράκη', 'Παπασπύρου', 'Καταξένου',
      'Γιαβριμη', 'Δαλέκου', 'Ρεμαντά', 'Ελσούκαρη', 'Μαυροζούμη', 'Τσεκούρα', 'Τρουπάκη', 'Βλασσιάδου', 'Παρλάντζα',
      'Αμπαριώτη', 'Βερικάκη', 'Παπακώστα', 'Διαμαντή', 'Θεοδώρου', 'Κυριακίδου', 'Κανέλλη', 'Μπετέκου', 'Νταουντάκη',
      'Ανδρεαδάκη', 'Κουτσοκέρη', 'Πούλιου', 'Παπατρύφων', 'Πιεράτου', 'Νεκταρίου', 'Μπάμπαλη', 'Κλωθάκη', 'Νταλάκα',
      'Πανέτσου', 'Φράνγκου', 'Χρυσάνη', 'Αλιφραγκή', 'Μητρέλλου', 'Μηλιώνη', 'Αθανασίου', 'Ριζούδη', 'Τζανετή'
    };
    maleFirstNames = new Set<String>{
      'Αδάμ', 'Ευγένιος', 'Αλέκος', 'Νώντας', 'Φάνης', 'Αργύρης', 'Άλκης', 'Διαμαντής', 'Θάνος', 'Παύλος', 'Φίλιππος', 'Αλέξης', 'Γιώργος', 'Κώστας',
      'Μάρκος', 'Θωμάς', 'Νίκος', 'Δήμος', 'Θεοδόσης', 'Στάθης', 'Φώτης', 'Κυριάκος', 'Χάρης', 'Λάμπρος', 'Άγγελος', 'Πέτρος', 'Στράτος', 'Γρηγόρης',
      'Μανώλης', 'Τάσος', 'Μιχάλης', 'Αντώνης', 'Ανδρέας', 'Δημήτρης', 'Γιάννης', 'Βαγγέλης', 'Νικήτας', 'Ηλίας', 'Αχιλλέας', 'Σταύρος',
      'Παναγιώτης', 'Φαίδων', 'Σάββας', 'Βασίλης', 'Ορέστης', 'Νεκτάριος', 'Πάνος', 'Στέφανος', 'Θεόφιλος', 'Στέλιος'
    };
    maleLastNames = new Set<String>{
      'Ψαλτήρας', 'Κονδύλης', 'Μοσχοβής', 'Κολώνιας', 'Μουρίκης', 'Μερτύκας', 'Χαρατσής', 'Μανιάτης', 'Τσιλίκης', 'Ταπάκης', 'Μανίκας', 'Χάλαρης',
      'Πούρνος', 'Κυρίδης', 'Ρέμπελος', 'Θανασάς', 'Τρυφέρης', 'Παράσχος', 'Κουρελάς', 'Νταλάκας', 'Μπίλιας', 'Σκαφίδας', 'Ψυράκης', 'Πανούσης',
      'Χαλικάς', 'Προβατάς', 'Λουκέρης', 'Καρλάκης', 'Τσαμάτης', 'Σέρτσος', 'Πλυμένος', 'Κολόνιας', 'Ηλιάδης', 'Σουλελές', 'Μαγουλάς', 'Λαζάρου',
      'Ταμβάκης', 'Δαμίγος', 'Ρομπότης', 'Σιγάλας', 'Μαλούχος', 'Περωτής', 'Μπούρας', 'Ταλούμης', 'Κρικώνης', 'Στάνιος', 'Γεράκης', 'Δούσσης',
      'Ντότσιας', 'Απέργης', 'Μπουζούμης', 'Ντάλλας', 'Πασσάκος', 'Μονιώδης', 'Βίλλιος', 'Μασσώνος', 'Γαβριήλ', 'Μάκαρης', 'Γαρμπής', 'Κοφινάς',
      'Μεγρέμης', 'Τομάζος', 'Λυριτζής', 'Τζαβάρας', 'Μπογρής', 'Λούτσος', 'Μπαδήμας', 'Κούμενος', 'Μύταρος', 'Μοσχάκης', 'Ντούλιας', 'Μπολάκης',
      'Δουλφής', 'Πατρώνας', 'Χαραμής', 'Παριάρος', 'Περβανάς', 'Κοσμίδης', 'Γκρέκος', 'Κόκκορης', 'Αρματάς', 'Μικέδης', 'Βιδάκης', 'Κυράνης',
      'Γόγωλος', 'Σαγκρής', 'Σκιαδάς', 'Γκίλλας', 'Σπανάκος', 'Τσιγάρας', 'Μικέλης', 'Πούμπρος', 'Φασόλης', 'Περράκης', 'Μπατζής', 'Ζαμάνης',
      'Κεχαγιάς', 'Δάουλας', 'Χαλιώτης', 'Γκιόκας', 'Μούρτζης', 'Ζαφύρης', 'Χρυσοχός', 'Λιόλιος', 'Μαρκάζος', 'Δόμινος', 'Παπαδιάς', 'Κοκότσης',
      'Τζώρτζης', 'Μαρουλής', 'Γατζίας', 'Φιορέτος', 'Μεϊδάνης', 'Χαιρέτης', 'Τομαράς', 'Λιάππης', 'Κεράνης', 'Μαμουνάς', 'Χασόγιας', 'Ντόκορος',
      'Κρασσάς', 'Σεραφείμ', 'Σκορδάς', 'Τεκέδης', 'Μανάφας', 'Γκλαβάς', 'Μπονίκος', 'Κάτσικας', 'Μπάκνης', 'Λέτσιος', 'Μαγιάτης', 'Ζιούβας',
      'Αχτίδας', 'Κλωνάρης', 'Τσότσος', 'Ριζάκης', 'Σιούλας', 'Παρμαξής', 'Κωλέτας', 'Στεφανής', 'Πανάγος', 'Πουλάκος', 'Λιούνης', 'Τραυλός',
      'Χαλικιάς', 'Σακέτος', 'Σοκόλης', 'Τσομώκος', 'Φωτίδας', 'Κούσκος', 'Καραβάς', 'Κρεμύδας', 'Δελόνας', 'Κιούπης', 'Ζαράνης', 'Φινδάνης',
      'Δαβιλάς', 'Λακιώτης', 'Σκόδρας', 'Κατσώλης', 'Κορκολής', 'Γρίτσης', 'Μπουρνής', 'Ντάφλος', 'Κολλιός', 'Μπολάνης', 'Αγγέλου', 'Καστανάς',
      'Λεμονής', 'Μπόκτορ', 'Μαργώνης', 'Καράπας', 'Περλεπές', 'Κούβαρης', 'Κιτσάκης', 'Πανoύσης', 'Καραλής', 'Καβύρης', 'Μωρέλας', 'Διβόλης',
      'Φραντζής', 'Κούκιας', 'Λελάκης', 'Δρούγας', 'Ζαρίφης', 'Στασινός', 'Φυλακτός', 'Ζερεφός', 'Κοντάκος', 'Αρμύρος', 'Μπαλλής', 'Μυλωνάς',
      'Παΐσιος', 'Χαλμπές', 'Καψάλας', 'Τσιόγκας', 'Στεφάνου', 'Τσούμπας', 'Σμυρνής', 'Συράκος'
    };
  }

  private static void loadNamesFromUnitesStatesInEnglish() {
    femaleFirstNames = new Set<String>{
      'Tracey', 'Amelia', 'Leah', 'Nicola', 'Theresa', 'Sophie', 'Olivia', 'Sally', 'Wendy', 'Fiona',
      'Deirdre', 'Jane', 'Lillian', 'Abigail', 'Ella', 'Claire', 'Lauren', 'Bernadette', 'Karen', 'Vanessa',
      'Grace', 'Alison', 'Rachel', 'Heather', 'Ava', 'Wanda', 'Natalie', 'Victoria', 'Joan', 'Dorothy',
      'Una', 'Rebecca', 'Donna', 'Emma', 'Sarah', 'Sonia', 'Samantha', 'Lily', 'Bella', 'Penelope', 'Julia',
      'Caroline', 'Felicity', 'Anne', 'Faith', 'Diane', 'Sue', 'Joanne', 'Kylie', 'Jasmine'
    };
    femaleLastNames = new Set<String>{
      'Smith', 'Johnson', 'Williams', 'Jones', 'Brown', 'Davis', 'Miller', 'Wilson', 'Moore', 'Taylor',
      'Anderson', 'Thomas', 'Jackson', 'White', 'Harris', 'Martin', 'Thompson', 'Garcia', 'Martinez',
      'Robinson', 'Clark', 'Rodriguez', 'Lewis', 'Lee', 'Walker', 'Hall', 'Allen', 'Young', 'Hernandez',
      'King', 'Wright', 'Lopez', 'Hill', 'Scott', 'Green', 'Adams', 'Baker', 'Gonzalez', 'Nelson', 'Carter',
      'Mitchell', 'Perez', 'Roberts', 'Turner', 'Phillips', 'Campbell', 'Parker', 'Evans', 'Edwards',
      'Collins', 'Stewart', 'Sanchez', 'Morris', 'Rogers', 'Reed', 'Cook', 'Morgan', 'Bell', 'Murphy',
      'Bailey', 'Rivera', 'Cooper', 'Richardson', 'Cox', 'Howard', 'Ward', 'Torres', 'Peterson', 'Gray',
      'Ramirez', 'James', 'Watson', 'Brooks', 'Kelly', 'Sanders', 'Price', 'Bennett', 'Wood', 'Barnes',
      'Ross', 'Henderson', 'Coleman', 'Jenkins', 'Perry', 'Powell', 'Long', 'Patterson', 'Hughes', 'Flores',
      'Washington', 'Butler', 'Simmons', 'Foster', 'Gonzales', 'Bryant', 'Alexander', 'Russell', 'Griffin',
      'Diaz', 'Hayes', 'Myers', 'Ford', 'Hamilton', 'Graham', 'Sullivan', 'Wallace', 'Woods', 'Cole', 'West',
      'Jordan', 'Owens', 'Reynolds', 'Fisher', 'Ellis', 'Harrison', 'Gibson', 'Mcdonald', 'Cruz', 'Marshall',
      'Ortiz', 'Gomez', 'Murray', 'Freeman', 'Wells', 'Webb', 'Simpson', 'Stevens', 'Tucker', 'Porter',
      'Hunter', 'Hicks', 'Crawford', 'Henry', 'Boyd', 'Mason', 'Morales', 'Kennedy', 'Warren', 'Dixon',
      'Ramos', 'Reyes', 'Burns', 'Gordon', 'Shaw', 'Holmes', 'Rice', 'Robertson', 'Hunt', 'Black', 'Daniels',
      'Palmer', 'Mills', 'Nichols', 'Grant', 'Knight', 'Ferguson', 'Rose', 'Stone', 'Hawkins', 'Dunn',
      'Perkins', 'Hudson', 'Spencer', 'Gardner', 'Stephens', 'Payne', 'Pierce', 'Berry', 'Matthews', 'Arnold',
      'Wagner', 'Willis', 'Ray', 'Watkins', 'Olson', 'Carroll', 'Duncan', 'Snyder', 'Hart', 'Cunningham',
      'Bradley', 'Lane', 'Andrews', 'Ruiz', 'Harper', 'Fox', 'Riley', 'Armstrong', 'Carpenter', 'Weaver',
      'Greene', 'Lawrence', 'Elliott', 'Chavez', 'Sims', 'Austin', 'Peters', 'Kelley', 'Franklin', 'Lawson'
    };
    maleFirstNames = new Set<String>{
      'Sebastian', 'Boris', 'Andrew', 'Paul', 'Jake', 'Edward', 'Neil', 'Ryan', 'Christian', 'Ian', 'Max',
      'Gavin', 'Matt', 'Jonathan', 'Nicholas', 'Adam', 'Frank', 'Brandon', 'Julian', 'Richard', 'Steven',
      'Colin', 'James', 'Trevor', 'Anthony', 'Victor', 'Nathan', 'Adrian', 'John', 'Joshua', 'Stewart',
      'Kevin', 'David', 'Austin', 'Tim', 'Dominic', 'Robert', 'Jason', 'Connor', 'Evan', 'Joe', 'Sam',
      'Blake', 'Liam', 'Stephen', 'Thomas', 'Phil', 'Christopher', 'Lucas', 'Isaac'
    };
    maleLastNames = new Set<String>(femaleLastNames);
  }
}