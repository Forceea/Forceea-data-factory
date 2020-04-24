public with sharing class DataFactory {

    /* IMPORTANT NOTE
       The following Templates are for demo purposes and should not be used as is, because
        - they contain more fields than it's required based on best practice
        - they don't have an optimized structure for your particular needs
     */

    // accounts with real addresses
    public static Map<String, FObject> templateAccounts() {
        return new Map<String, FObject>{
            'Accounts' => new FObject('Account', 100)
                // if you have record types, you can use the following definition
                // .setDefinition(Name.RecordTypeId', 'static value(MyRecordTypeApiName)')
                // define account fields
                .setDefinition(Account.Name,
                    'static value("Company ")')
                .setDefinition(Account.Name,
                    'serial type(number) from(100) step(1) scale(0)')
                .setDefinition(Account.NumberOfEmployees,
                    'random type(number) from(10) to(1000) scale(-1)')
                .setDefinition(Account.AnnualRevenue, 'random type(number) from(10000000) to(100000000) scale(3)')
                .setDefinition(Account.Rating,
                    'random type(picklist) except(Hot)')
                .setDefinition(Account.Phone,
                    'random type(phone) format("(30) 210 dD-00-DD")')
                .setDefinition(Account.Industry,
                    'random type(picklist)')
                .setDefinition(Account.Type,
                    'random type(list) value(Prospect, Customer - Direct, Customer - Channel)')
                .setDefinition(Account.Site,
                    'random type(url)')
                .setDefinition(Account.ShippingStreet,
                    'random type(street) group(shipping)')
                .setDefinition(Account.ShippingPostalCode,
                    'random type(postalcode) group(shipping)')
                .setDefinition(Account.ShippingCity,
                    'random type(city) group(shipping)')
                .setDefinition(Account.ShippingState,
                    'random type(state) group(shipping)')
                .setDefinition(Account.ShippingCountry,
                    'random type(country) group(shipping)')
                .setDefinition(Account.BillingStreet,
                    'copy field(ShippingStreet)')
                .setDefinition(Account.BillingPostalCode,
                    'copy field(ShippingPostalCode)')
                .setDefinition(Account.BillingCity,
                    'copy field(ShippingCity)')
                .setDefinition(Account.BillingState,
                    'copy field(ShippingState)')
                .setDefinition(Account.BillingCountry,
                    'copy field(ShippingCountry)')
        };
    }

    // attachments of email messages
    public static Map<String, FObject> templateAttachments() {
        return new Map<String, FObject>{
            'Attachments' => new FObject('Attachment', 100)
                .setDefinition(Attachment.Name,
                    'static value(Attachment)')
                .setDefinition(Attachment.Name,
                    'serial type(number) from(1) step(1) scale(0)')
                .setDefinition(Attachment.Body,
                    'random type(text) minLength(30) maxLength(100)')
        };
    }

    public static Map<String, FObject> templateAttachmentsWithEmails() {
        Map<String, FObject> results = new Map<String, FObject>();

        results.putAll(templateAttachments());
        results.get('Attachments')
            .setDefinition(Attachment.ParentId,
            'random lookup(EmailMessage) source(forceea)');

        return results;
    }

    // cases related to accounts and contacts
    public static Map<String, FObject> templateCases() {
        return new Map<String, FObject>{
            'Cases' => new FObject('Case', 100)
                .setDefinition(Case.AccountId,
                    'random lookup(Account) source(salesforce)')
                .setDefinition(Case.ContactId,
                    'random lookup(Contact) source(salesforce)')
                .setDefinition(Case.Origin,
                    'random type(picklist)')
                .setDefinition(Case.Type,
                    'random type(picklist)')
                .setDefinition(Case.Status,
                    'static value(Working)')
                .setDefinition(Case.Subject,
                    'random type(text) minLength(50) maxLength(200)')
                .setDefinition(Case.Reason,
                    'random type(picklist)')
                .setDefinition(Case.Description,
                    'random type(text) minLength(50) maxLength(200)')
        };
    }

    // contacts with real first/last names and addresses related to accounts
    public static Map<String, FObject> templateContacts() {
        return new Map<String, FObject>{
            'Contacts' => new FObject('Contact', 100)
                .setDefinition(Contact.FirstName,
                    'random type(firstname) group(name)')
                .setDefinition(Contact.LastName,
                    'random type(lastname) group(name)')
                .setDefinition(Contact.Email,
                    'random type(email)')
                .setDefinition(Contact.LeadSource,
                    'random type(picklist)')
                .setDefinition(Contact.Birthdate,
                    'random type(date) from(1950-1-1) to(1982-12-31)')
                .setDefinition(Contact.Title,
                    'random type(list) value(Developer, CFO, Account Manager, CEO, Logistics Manager)')
                .setDefinition(Contact.Department,
                    'random type(list) value(Sales, Marketing, Accounting, Management)')
                .setDefinition(Contact.AccountId,
                    'random lookup(Account) source(salesforce)')
                .setDefinition(Contact.Phone,
                    'copy field(AccountId) from(Account.Phone)')
                .setDefinition(Contact.MailingStreet,
                    'copy field(AccountId) from(Account.ShippingStreet)')
                .setDefinition(Contact.MailingPostalCode,
                    'copy field(AccountId) from(Account.ShippingPostalCode)')
                .setDefinition(Contact.MailingCity,
                    'copy field(AccountId) from(Account.ShippingCity)')
                .setDefinition(Contact.MailingState,
                    'copy field(AccountId) from(Account.ShippingState)')
                .setDefinition(Contact.MailingCountry,
                    'copy field(AccountId) from(Account.ShippingCountry)')
        };
    }

    // email messages related to cases
    public static Map<String, FObject> templateEmailMessages() {
        return new Map<String, FObject>{
            'EmailMessages' => new FObject('EmailMessage', 100)
                .setDefinition(EmailMessage.Subject,
                    'static value(Email)')
                .setDefinition(EmailMessage.Subject,
                    'serial type(number) from(1) step(1) scale(0)')
                .setDefinition(EmailMessage.TextBody,
                    'copy field(Subject)')
                .setDefinition(EmailMessage.Incoming,
                    'static value(true)')
                .setDefinition(EmailMessage.Status,
                    'static value(0)')
                .setDefinition(EmailMessage.ParentId,
                    'random lookup(Case) source(salesforce)')
        };
    }

    // events related to contacts
    public static Map<String, FObject> templateEvents() {
        return new Map<String, FObject>{
            'Events' => new FObject('Event', 100)
                .setDefinition(Event.Subject,
                    'random type(picklist)')
                .setDefinition(Event.Type,
                    'random type(picklist)')
                .setDefinition(Event.WhoId,
                    'random lookup(Contact) source(salesforce)')
                .setDefinition(Event.ActivityDatetime,
                    'random type(datetime) from(2018-1-1) to(2018-12-31)')
                .setDefinition(Event.DurationInMinutes,
                    'random type(number) from(1) to(10) scale(0)')
        };
    }

    // chatter feeds related to contacts
    public static Map<String, FObject> templateFeedItems() {
        return new Map<String, FObject>{
            'FeedItem' => new FObject('FeedItem', 100)
                .setDefinition(FeedItem.Body,
                    'random type(text) minLength(50) maxLength(500)')
                .setDefinition(FeedItem.ParentId,
                    'random lookup(Contact) source(forceea)')
                .setDefinition(FeedItem.Status,
                    'static value(Published)')
                .setDefinition(FeedItem.Type,
                    'static value(TextPost)')
                .setDefinition(FeedItem.Title,
                    'random type(text) minLength(50) maxLength(250)')
        };
    }

    // FObjectOnes
    public static Map<String, FObject> templateFObjectOnes() {
        return new Map<String, FObject>{
            'FObjectOnes' => new FObject('FObjectOne__c', 100)
                .setDefinition(FObjectOne__c.TestCheckbox__c,
                    'static value(true)')
                .setDefinition(FObjectOne__c.TestCurrency__c,
                    'random type(number) from(1) to(100) scale(0)')
                .setDefinition(FObjectOne__c.TestDate__c,
                    'random type(date) from(2017-1-1) to(2017-12-31)')
                .setDefinition(FObjectOne__c.TestDatetime__c,
                    'random type(datetime) from(2017-1-1) to(2017-12-31)')
                .setDefinition(FObjectOne__c.TestDecimal__c,
                    'random type(number) from(1) to(100) scale(3)')
                .setDefinition(FObjectOne__c.TestEmail__c,
                    'random type(email)')
                .setDefinition(FObjectOne__c.TestInteger__c,
                    'random type(number) from(1) to(100) scale(0)')
                .setDefinition(FObjectOne__c.TestLookup__c,
                    'random lookup(FObjectTwo__c) source(salesforce)')
                .setDefinition(FObjectOne__c.TestMultiPicklistA__c,
                    'random type(picklist)')
                .setDefinition(FObjectOne__c.TestPercent__c,
                    'random type(number) from(1) to(100) scale(1)')
                .setDefinition(FObjectOne__c.TestPhone__c,
                    'static value(2102525125)')
                .setDefinition(FObjectOne__c.TestPicklistA__c,
                    'random type(picklist) except(a0)')
                .setDefinition(FObjectOne__c.TestPicklistB__c,
                    'random type(picklist)')
                .setDefinition(FObjectOne__c.TestPicklistC__c,
                    'random type(picklist)')
                .setDefinition(FObjectOne__c.TestPicklistD__c,
                    'random type(picklist) except (d0,d1)')
                .setDefinition(FObjectOne__c.TestText__c,
                    'random type(string) minLength(10) maxLength(30) startWith(lower) include(lower,upper,digit)')
                .setDefinition(FObjectOne__c.TestTextArea__c,
                    'random type(string) minLength(10) maxLength(30) startWith(lower) include(lower,upper,digit)')
                .setDefinition(FObjectOne__c.TestTextAreaLong__c,
                    'random type(string) minLength(50) maxLength(200) startWith(lower) include(lower,upper,digit)')
                .setDefinition(FObjectOne__c.TestTextAreaRich__c,
                    'random type(string) minLength(50) maxLength(200) startWith(lower) include(lower,upper,digit)')
                .setDefinition(FObjectOne__c.TestTextRequired__c,
                    'random type(string) minLength(10) maxLength(20) startWith(upper) include(lower,upper)')
                .setDefinition(FObjectOne__c.TestTime__c,
                    'static value(22:10:05)')
                .setDefinition(FObjectOne__c.TestUrl__c,
                    'random type(url)')
        };
    }

    // leads with real first/last names and addresses
    public static Map<String, FObject> templateLeads() {
        return new Map<String, FObject>{
            'Leads' => new FObject('Lead', 100)
                .setDefinition(Lead.FirstName,
                    'random type(firstname) group(name)')
                .setDefinition(Lead.LastName,
                    'random type(lastname) group(name)')
                .setDefinition(Lead.Email,
                    'random type(email)')
                .setDefinition(Lead.Title,
                    'random type(list) value(Developer, CFO, Account Manager, CEO, Logistics Manager)')
                .setDefinition(Lead.Company,
                    'static value("Company ")')
                .setDefinition(Lead.Company,
                    'serial type(number) from(100) step(1) scale(0)')
                .setDefinition(Lead.AnnualRevenue,
                    'random type(number) from(1000000) to(10000000) scale(-3)')
                .setDefinition(Lead.NumberOfEmployees,
                    'random type(list) value(10,20,30)')
                .setDefinition(Lead.Industry,
                    'random type(picklist)')
                .setDefinition(Lead.Status,
                    'static value(Open)')
                .setDefinition(Lead.Street,
                    'random type(street) group(other)')
                .setDefinition(Lead.PostalCode,
                    'random type(postalcode) group(other)')
                .setDefinition(Lead.City,
                    'random type(city) group(other)')
                .setDefinition(Lead.State,
                    'random type(state) group(other)')
                .setDefinition(Lead.Country,
                    'random type(country) group(other)')
        };
    }

    // opportunities related to accounts
    public static Map<String, FObject> templateOpportunities() {
        return new Map<String, FObject>{
            'Opportunities' => new FObject('Opportunity', 100)
                .setDefinition(Opportunity.Name,
                    'static value(Opp)')
                .setDefinition(Opportunity.Name,
                    'serial type(number) from(1) step(1) scale(0)')
                .setDefinition(Opportunity.AccountId,
                    'random lookup(Account) field(Industry) value(Chemicals,Construction) source(forceea)')
                .setDefinition(Opportunity.Amount,
                    'random type(number) from(1000000) to(10000000) scale(-3)')
                .setDefinition(Opportunity.StageName,
                    'random type(picklist)')
                .setDefinition(Opportunity.CloseDate,
                    'random type(date) from(2017-01-01) to(2018-12-31)')
        };
    }

    // tasks related to templateAccounts
    public static Map<String, FObject> templateTasks() {
        return new Map<String, FObject>{
            'Tasks' => new FObject('Task', 100)
                .setDefinition(Task.Subject, 'random type(picklist)')
                .setDefinition(Task.Priority, 'random type(picklist)')
                .setDefinition(Task.Status, 'random type(picklist)')
                .setDefinition(Task.Type, 'random type(picklist)')
                .setDefinition(Task.WhatId, 'random lookup(Account) source(salesforce)')
                .setDefinition(Task.ActivityDate, 'random type(date) from(2018-10-1) to(2018-12-31)')
        };
    }

    //  users with specific Profile and Role
    public static Map<String, FObject> templateUsers() {
        return new Map<String, FObject>{
            'Users' => new FObject('User', 1)
                .canInsertUsers(true) // required when not testing
                .setDefinition(User.ProfileId,
                    'static lookup(Profile) field(Name) value(System Administrator) source(salesforce)')
                .setDefinition(User.UserRoleId,
                    'static lookup(UserRole) field(Name) value(CEO) source(salesforce)')
        };
    }

}