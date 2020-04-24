public with sharing class ForceeaExamples {
  // For all these examples, insert records using: obj.insertRecords();

  // To see the details (Debug Log) of all the phases of the record creation process,
  // add the following statement after FObject obj = new..
  // .setVerbose('debug')

  public static void accounts() {
    // create accounts with real addresses
    FObject obj = new FObject('Account', 100)
      // if you have record types, you can use the following definition
      // .setDefinition('RecordTypeId', 'static value(MyRecordTypeApiName)')
      // define account fields
        .setDefinition('Name', 'static value("Company ")')
        .setDefinition('Name', 'serial type(number) from(100) step(1) scale(0)')
        .setDefinition('NumberOfEmployees', 'random type(number) from(10) to(1000) scale(-1)')
        .setDefinition('AnnualRevenue', 'random type(number) from(10000000) to(100000000) scale(3)')
        .setDefinition('Rating', 'random type(picklist) except(Hot)')
        .setDefinition('Phone', 'random type(phone) format("(30) 210 dD-00-DD")')
        .setDefinition('Industry', 'random type(picklist)')
        .setDefinition('Type', 'random type(list) value(Prospect, Customer - Direct, Customer - Channel)')
        .setDefinition('Site', 'random type(url)')
        .setDefinition('ShippingStreet', 'random type(street) group(shipping)')
        .setDefinition('ShippingPostalCode', 'random type(postalcode) group(shipping)')
        .setDefinition('ShippingCity', 'random type(city) group(shipping)')
        .setDefinition('ShippingState', 'random type(state) group(shipping)')
        .setDefinition('ShippingCountry', 'random type(country) group(shipping)')
        .setDefinition('BillingStreet', 'copy field(ShippingStreet)')
        .setDefinition('BillingPostalCode', 'copy field(ShippingPostalCode)')
        .setDefinition('BillingCity', 'copy field(ShippingCity)')
        .setDefinition('BillingState', 'copy field(ShippingState)')
        .setDefinition('BillingCountry', 'copy field(ShippingCountry)');

    // use the following definitions if you enable "Set Audit Fields upon Record Creation"
    // .setDefinition('createdDate', 'random type(datetime) from(2010-01-01) to(2015-12-31)')
    // .setDefinition('createdById', 'random lookup(User) source(salesforce)');

    List<Account> records = (List<Account>) obj.getRecords();
  }

  public static void attachments() {
    // create attachments of email messages
    FObject obj = new FObject('Attachment')
        .setDefinition('Name', 'static value(Attachment)')
        .setDefinition('Name', 'serial type(number) from(1) step(1) scale(0)')
        .setDefinition('Body', 'random type(text) minLength(30) maxLength(100)')
        .setDefinition('ParentId', 'random lookup(EmailMessage) source(forceea)');

    List<Attachment> records = (List<Attachment>) obj.getRecords();
  }

  public static void cases() {
    // create cases related to accounts and contacts
    FObject obj = new FObject('Case')
        .setNumberOfRecords(100)
        .setDefinition('AccountId', 'random lookup(Account) source(salesforce)')
        .setDefinition('ContactId', 'random lookup(Contact) source(salesforce)')
        .setDefinition('Origin', 'random type(picklist)')
        .setDefinition('Type', 'random type(picklist)')
        .setDefinition('Status', 'static value(Working)')
        .setDefinition('Subject', 'random type(text) minLength(50) maxLength(200)')
        .setDefinition('Reason', 'random type(picklist)')
        .setDefinition('Description', 'random type(text) minLength(50) maxLength(200)');

    List<Case> records = (List<Case>) obj.getRecords();
  }

  public static void feedItems() {
    // create chatter feeds related to contacts
    FObject obj = new FObject('FeedItem')
        .setDefinition('Body', 'random type(text) minLength(50) maxLength(500)')
        .setDefinition('ParentId', 'random lookup(Contact) source(forceea)')
        .setDefinition('Status', 'static value(Published)')
        .setDefinition('Type', 'static value(TextPost)')
        .setDefinition('Title', 'random type(text) minLength(50) maxLength(250)');

    List<FeedItem> records = (List<FeedItem>) obj.getRecords();
  }

  public static void contacts() {
    // create contacts with real first/last names and addresses related to accounts
    FObject obj = new FObject('Contact', 200)
        .setDefinition('FirstName', 'random type(firstname) group(name)')
        .setDefinition('LastName', 'random type(lastname) group(name)')
        .setDefinition('Email', 'random type(email)')
        .setDefinition('LeadSource', 'random type(picklist)')
        .setDefinition('Birthdate', 'random type(date) from(1950-1-1) to(1982-12-31)')
        .setDefinition('Title', 'random type(list) value(Developer, CFO, Account Manager, CEO, Logistics Manager)')
        .setDefinition('Department', 'random type(list) value(Sales, Marketing, Accounting, Management)')
        .setDefinition('AccountId', 'random lookup(Account) source(salesforce)')
        .setDefinition('Phone', 'copy field(AccountId) from(Account.Phone)')
        .setDefinition('MailingStreet', 'copy field(AccountId) from(Account.ShippingStreet)')
        .setDefinition('MailingPostalCode', 'copy field(AccountId) from(Account.ShippingPostalCode)')
        .setDefinition('MailingCity', 'copy field(AccountId) from(Account.ShippingCity)')
        .setDefinition('MailingState', 'copy field(AccountId) from(Account.ShippingState)')
        .setDefinition('MailingCountry', 'copy field(AccountId) from(Account.ShippingCountry)');

    List<Contact> records = (List<Contact>) obj.getRecords();
  }

  public static void emailMessages() {
    // create email messages related to cases
    FObject obj = new FObject('EmailMessage')
        .setDefinition('Subject', 'static value(Email)')
        .setDefinition('Subject', 'serial type(number) from(1) step(1) scale(0)')
        .setDefinition('TextBody', 'copy field(Subject)')
        .setDefinition('Incoming', 'static value(true)')
        .setDefinition('Status', 'static value(0)')
        .setDefinition('ParentId', 'random lookup(Case) source(salesforce)');

    List<EmailMessage> records = (List<EmailMessage>) obj.getRecords();
  }

  public static void events() {
    // create events related to contacts
    FObject obj = new FObject('Event')
        .setDefinition('Subject', 'random type(picklist)')
        .setDefinition('Type', 'random type(picklist)')
        .setDefinition('WhoId', 'random lookup(Contact) source(salesforce)')
        .setDefinition('ActivityDatetime', 'random type(datetime) from(2018-1-1) to(2018-12-31)')
        .setDefinition('DurationInMinutes', 'random type(number) from(1) to(10) scale(0)');

    List<Event> records = (List<Event>) obj.getRecords();
  }

  public static void fObjectOnes() {
    FObject obj = new FObject('FObjectOne__c')
        .setDefinition('TestCheckbox__c', 'static value(true)')
        .setDefinition('TestCurrency__c', 'random type(number) from(1) to(100) scale(0)')
        .setDefinition('TestDate__c', 'random type(date) from(2017-1-1) to(2017-12-31)')
        .setDefinition('TestDatetime__c', 'random type(datetime) from(2017-1-1) to(2017-12-31)')
        .setDefinition('TestDecimal__c', 'random type(number) from(1) to(100) scale(3)')
        .setDefinition('TestEmail__c', 'random type(email)')
        .setDefinition('TestInteger__c', 'random type(number) from(1) to(100) scale(0)')
        .setDefinition('TestLookup__c', 'random lookup(FobjectTwo__c) source(salesforce)')
        .setDefinition('TestMultiPicklistA__c', 'random type(picklist)')
        .setDefinition('TestPercent__c', 'random type(number) from(1) to(100) scale(1)')
        .setDefinition('TestPhone__c', 'static value(2102525125)')
        .setDefinition('TestPicklistA__c', 'random type(picklist) except(a0)')
        .setDefinition('TestPicklistB__c', 'random type(picklist)')
        .setDefinition('TestPicklistC__c', 'random type(picklist)')
        .setDefinition('TestPicklistD__c', 'random type(picklist) except (d0,d1)')
        .setDefinition('TestText__c', 'random type(string) minLength(10) maxLength(30) startWith(lower) include(lower,upper,digit)')
        .setDefinition('TestTextArea__c', 'random type(string) minLength(10) maxLength(30) startWith(lower) include(lower,upper,digit)')
        .setDefinition('TestTextAreaLong__c', 'random type(string) minLength(50) maxLength(200) startWith(lower) include(lower,upper,digit)')
        .setDefinition('TestTextAreaRich__c', 'random type(string) minLength(50) maxLength(200) startWith(lower) include(lower,upper,digit)')
        .setDefinition('TestTextRequired__c', 'random type(string) minLength(10) maxLength(20) startWith(upper) include(lower,upper)')
        .setDefinition('TestTime__c', 'static value(22:10:05)')
        .setDefinition('TestUrl__c', 'random type(url)');

    List<FObjectOne__c> records = (List<FObjectOne__c>) obj.getRecords();
  }

  public static void leads() {
    // create leads with real first/last names and addresses
    FObject obj = new FObject('Lead')
        .setDefinition('FirstName', 'random type(firstname) group(name)')
        .setDefinition('LastName', 'random type(lastname) group(name)')
        .setDefinition('Email', 'random type(email)')
        .setDefinition('Title', 'random type(list) value(Developer, CFO, Account Manager, CEO, Logistics Manager)')
        .setDefinition('Company', 'static value("Company ")')
        .setDefinition('Company', 'serial type(number) from(100) step(1) scale(0)')
        .setDefinition('AnnualRevenue', 'random type(number) from(1000000) to(10000000) scale(-3)')
        .setDefinition('NumberOfEmployees', 'random type(list) value(10,20,30)')
        .setDefinition('Industry', 'random type(picklist)')
        .setDefinition('Status', 'static value(Open)')
        .setDefinition('Street', 'random type(street) group(other)')
        .setDefinition('PostalCode', 'random type(postalcode) group(other)')
        .setDefinition('City', 'random type(city) group(other)')
        .setDefinition('State', 'random type(state) group(other)')
        .setDefinition('Country', 'random type(country) group(other)');

    List<Lead> records = (List<Lead>) obj.getRecords();
  }

  public static void opportunities() {
    // create opportunities related to accounts
    FObject obj = new FObject('Opportunity', 100)
        .setDefinition('Name', 'static value(Opp)')
        .setDefinition('Name', 'serial type(number) from(1) step(1) scale(0)')
        .setDefinition('AccountId', 'random lookup(Account) field(Industry) value(Chemicals,Construction) source(forceea)')
        .setDefinition('Amount', 'random type(number) from(1000000) to(10000000) scale(-3)')
        .setDefinition('StageName', 'random type(picklist)')
        .setDefinition('CloseDate', 'random type(date) from(2017-01-01) to(2018-12-31)');

    List<Opportunity> records = (List<Opportunity>) obj.getRecords();
  }

  public static void tasks() {
    // create tasks related to accounts
    FObject obj = new FObject('Task')
        .setDefinition('Subject', 'random type(picklist)')
        .setDefinition('Priority', 'random type(picklist)')
        .setDefinition('Status', 'random type(picklist)')
        .setDefinition('Type', 'random type(picklist)')
        .setDefinition('WhatId', 'random lookup(Account) source(salesforce)')
        .setDefinition('ActivityDate', 'random type(date) from(2018-10-1) to(2018-12-31)');

    List<Task> records = (List<Task>) obj.getRecords();
  }

  public static void users() {
    //  create users with specific Profile and Role
    FObject obj = new FObject('User', 1)
        .setDefinition('ProfileId',
            'static lookup(Profile) field(Name) value(System Administrator) source(salesforce)')
        .setDefinition('UserRoleId',
            'static lookup(UserRole) field(Name) value(CEO) source(salesforce)');

    List<User> records = (List<User>) obj.getRecords();
  }

}