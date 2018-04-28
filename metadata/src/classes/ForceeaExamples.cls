/*
  FORCEEA data factory framework (version 1.2.1)
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
 * @description Example scripts
 *   The following methods are written as test methods, but they are not.
 *   It is possible some methods to fail because of duplicate rules, validation rules, triggers, etc
 */
@isTest
public class ForceeaExamples {
  @isTest
  private static void createAccounts() {
    FObject obj = new FObject('Account');
    //obj.setDefinition('RecordTypeId', 'static value(xyz)');
    obj.setDefinition('Name', 'static value(Company_)');
    obj.setDefinition('Name', 'serial from(1) step(1) scale(0)');
    obj.setDefinition('NumberOfEmployees', 'random type(number) from(10) to(1000) scale(0)');
    obj.setDefinition('AnnualRevenue', 'random type(number) from(10000000) to(100000000) scale(3)');
    obj.setDefinition('Rating', 'random type(picklist) except(Hot)');
    obj.setDefinition('Industry', 'random type(picklist)');
    obj.setDefinition('Type', 'random type(picklist)');
    obj.setDefinition('Phone', 'static value("(353) ")');
    obj.setDefinition('Phone', 'random type(number) from (1111111) to (9999999)');
    obj.setDefinition('Site', 'random type(url)');
    obj.setDefinition('ShippingStreet', 'random type(street) group(shipping)');
    obj.setDefinition('ShippingPostalCode', 'random type(postalcode) group(shipping)');
    obj.setDefinition('ShippingCity', 'random type(city) group(shipping)');
    obj.setDefinition('ShippingState', 'random type(state) group(shipping)');
    obj.setDefinition('ShippingCountry', 'random type(country) group(shipping)');
    //obj.setDefinition('CreatedDate', 'random type(datetime) from(2010-01-01) to(2015-12-31)');
    //obj.setDefinition('CreatedById', 'random lookup(User) source(salesforce)');
    obj.insertRecords(true);
  }

  @isTest
  private static void createCases() {
    FObject obj = new FObject('Case');
    obj.setDefinition('AccountId', 'random lookup(Account) source(salesforce)');
    obj.setDefinition('ContactId', 'random lookup(Contact) source(salesforce)');
    obj.setDefinition('Origin', 'random type(picklist)');
    obj.setDefinition('Type', 'random type(picklist)');
    obj.setDefinition('Status', 'static value(Working)');
    obj.setDefinition('Subject', 'random type(text) minlength(50) maxlength(200)');
    obj.setDefinition('Reason', 'random type(picklist)');
    obj.setDefinition('Description', 'random type(text) minlength(50) maxlength(200)');
    obj.insertRecords(true);
  }

  @isTest
  private static void createContacts() {
    FObject obj = new FObject('Contact');
    obj.setDefinition('FirstName', 'random type(firstname) group(name)');
    obj.setDefinition('LastName', 'random type(lastname) group(name)');
    obj.setDefinition('Email', 'random type(email)');
    obj.setDefinition('LeadSource', 'random type(picklist)');
    obj.setDefinition('Birthdate', 'random type(date) from(1950-1-1) to(1982-12-31)');
    obj.setDefinition('Title', 'random type(list) value(Developer, CFO, Account Manager, CEO, Logistics Manager)');
    obj.setDefinition('Department', 'random type(list) value(Sales, Marketing, Accounting, Management)');
    obj.setDefinition('AccountId', 'random lookup(Account) source(salesforce)');
    obj.setDefinition('MailingStreet', 'random type(street) group(mailing)');
    obj.setDefinition('MailingPostalCode', 'random type(postalcode) group(mailing)');
    obj.setDefinition('MailingCity', 'random type(city) group(mailing)');
    obj.setDefinition('MailingState', 'random type(state) group(mailing)');
    obj.setDefinition('MailingCountry', 'random type(country) group(mailing)');
    obj.insertRecords(true);
  }

  @isTest
  private static void createEmailMessages() {
    FObject obj = new FObject('EmailMessage');
    obj.setDefinition('Subject', 'static value(Email)');
    obj.setDefinition('Subject', 'serial type(number) from(1) step(1) scale(0)');
    obj.setDefinition('TextBody', 'copy field(Subject)');
    obj.setDefinition('Incoming', 'static value(true)');
    obj.setDefinition('Status', 'static value(0)');
    obj.setDefinition('ParentId', 'random lookup(Case) source(salesforce)');
    obj.insertRecords(true);
  }

  @isTest
  private static void createLeads() {
    FObject obj = new FObject('Lead');
    obj.setDefinition('FirstName', 'random type(firstname) group(name)');
    obj.setDefinition('LastName', 'random type(lastname) group(name)');
    obj.setDefinition('Email', 'random type(email)');
    obj.setDefinition('Birthdate', 'random type(date) from(1950-1-1) to(1982-12-31)');
    obj.setDefinition('Title', 'random type(list) value(Developer, CFO, Account Manager, CEO, Logistics Manager)');
    obj.setDefinition('Industry', 'random type(picklist)');
    obj.setDefinition('AnnualRevenue', 'random type(number) from(1000000) to(10000000) scale(-3)');
    obj.setDefinition('Status', 'static value(Open)');
    obj.setDefinition('NumberOfEmployees', 'random type(list) value(10,20,30)');
    obj.setDefinition('Street', 'random type(street) group(other)');
    obj.setDefinition('PostalCode', 'random type(postalcode) group(other)');
    obj.setDefinition('City', 'random type(city) group(other)');
    obj.setDefinition('State', 'random type(state) group(other)');
    obj.setDefinition('Country', 'random type(country) group(other)');
    obj.insertRecords(true);
  }

  @isTest
  private static void createOpportunities() {
    FObject obj = new FObject('Opportunity');
    obj.setDefinition('Name', 'static value(Opp)');
    obj.setDefinition('Name', 'serial from(1) step(1) scale(0)');
    obj.setDefinition('Amount', 'random type(number) from(1000000) to(10000000) scale(-3)');
    obj.setDefinition('StageName',  'random type(picklist)');
    obj.setDefinition('CloseDate', 'random type(date) from(2017-01-01) to(2017-12-31)');
    obj.insertRecords(true);
  }

  @isTest
  private static void createTasks() {
    FObject obj = new FObject('Task');
    obj.setDefinition('Subject', 'random type(picklist)');
    obj.setDefinition('Priority', 'random type(picklist)');
    obj.setDefinition('Status', 'random type(picklist)');
    obj.setDefinition('Type', 'random type(picklist)');
    obj.setDefinition('WhatId', 'random lookup(Account) source(salesforce)');
    obj.setDefinition('ActivityDate', 'random type(date) from(2017-10-1) to(2017-12-31)');
    obj.insertRecords(true);
  }

  @isTest
  private static void createEvents() {
    FObject obj = new FObject('Event');
    obj.setDefinition('Subject', 'random type(picklist)');
    obj.setDefinition('Type', 'random type(picklist)');
    obj.setDefinition('WhoId', 'random lookup(Contact) source(salesforce)');
    obj.setDefinition('ActivityDatetime', 'random type(datetime) from(2017-10-1) to(2017-12-31)');
    obj.setDefinition('DurationInMinutes', 'random type(number) from(1) to(10) scale(0)');
    obj.insertRecords(true);
  }

  @isTest
  private static void createChatterFeeds() {
    FObject obj = new FObject('FeedItem');
    obj.setDefinition('Body', 'random type(text) minlength(50) maxlength(500)');
    obj.setDefinition('ParentId', 'random lookup(Contact) source(salesforce)');
    obj.setDefinition('Status', 'static value(Published)');
    obj.setDefinition('Type', 'static value(TextPost)');
    obj.setDefinition('Title', 'random type(text) minlength(50) maxlength(250)');
    obj.insertRecords(true);
  }

  @isTest
  private static void createtUsers() {
    FObject obj = new FObject('User', 1);
    obj.setDefinition('ProfileId', 'static lookup(Profile) field(Name) value(System Administrator) source(salesforce)');
    //obj.setDefinition('UserRoleId', 'static lookup(UserRole) field(Name) value(CEO) source(salesforce)');
    obj.insertRecords(false);
  }

  @isTest
  private static void createFObjectOneRecords() {
    FObject obj = new FObject('FObjectOne__c');
    obj.setDefinition('TestCheckbox__c', 'static value(true)');
    obj.setDefinition('TestCurrency__c', 'random type(number) from(1) to(100) scale(0)');
    obj.setDefinition('TestDate__c', 'random type(date) from(2017-1-1) to(2017-12-31)');
    obj.setDefinition('TestDatetime__c', 'random type(datetime) from(2017-1-1) to(2017-12-31)');
    obj.setDefinition('TestDecimal__c', 'random type(number) from(1) to(100) scale(3)');
    obj.setDefinition('TestEmail__c', 'random type(email)');
    obj.setDefinition('TestInteger__c', 'random type(number) from(1) to(100) scale(0)');
    obj.setDefinition('TestLookup__c', 'random lookup(FObjectTwo__c) source(salesforce)');
    obj.setDefinition('TestMultiPicklistA__c', 'random type(picklist)');
    obj.setDefinition('TestPercent__c', 'random type(number) from(1) to(100) scale(1)');
    obj.setDefinition('TestPhone__c', 'static value(2102525125)');
    obj.setDefinition('TestPicklistA__c', 'random type(picklist) except(a0)');
    obj.setDefinition('TestPicklistB__c', 'random type(picklist)');
    obj.setDefinition('TestPicklistC__c', 'random type(picklist)');
    obj.setDefinition('TestPicklistD__c', 'random type(picklist) except (d0,d1)');
    obj.setDefinition('TestText__c', 'random type(string) minlength(10) maxlength(30) startwith(lower) include(lower,upper,digit)');
    obj.setDefinition('TestTextArea__c', 'random type(string) minlength(10) maxlength(30) startwith(lower) include(lower,upper,digit)');
    obj.setDefinition('TestTextAreaLong__c', 'random type(string) minlength(50) maxlength(200) startwith(lower) include(lower,upper,digit)');
    obj.setDefinition('TestTextAreaRich__c', 'random type(string) minlength(50) maxlength(200) startwith(lower) include(lower,upper,digit)');
    obj.setDefinition('TestTextRequired__c', 'random type(string) minlength(10) maxlength(20) startwith(upper) include(lower,upper)');
    obj.setDefinition('TestTime__c', 'static value(22:10:05)');
    obj.setDefinition('TestUrl__c', 'random type(url)');
    obj.insertRecords(true);
  }
}