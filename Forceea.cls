/**
 * @description Example scripts
 * @version 1.1
 */
public class Forceea {

  public static void generateAccounts() {
    FObject acc = new FObject('Account');
    acc.SetRequiredFields = true;
    //FObject.Locality = 'Greece';
    //FObject.Language = 'Greek';
    
    /* basic fields */
    acc.setDefinition('Name', 'static value(Company_)');
    acc.setDefinition('Name', 'serial from(1) step(1) scale(0)');
    acc.setDefinition('NumberOfEmployees', 'random type(number) from(10) to(1000) scale(0)');
    acc.setDefinition('AnnualRevenue', 'random type(number) from(10000000) to(100000000) scale(3)');
    acc.setDefinition('Rating', 'random type(picklist) except(Hot)');
    acc.setDefinition('Industry', 'random type(picklist)');
    acc.setDefinition('Type', 'random type(picklist)');

    /* address fields */
    acc.setDefinition('ShippingStreet', 'random type(street) group(shipping)');
    acc.setDefinition('ShippingPostalCode', 'random type(postalcode) group(shipping)');
    acc.setDefinition('ShippingCity', 'random type(city) group(shipping)');
    acc.setDefinition('ShippingState', 'random type(state) group(shipping)');
    acc.setDefinition('ShippingCountry', 'random type(country) group(shipping)');
    acc.setDefinition('BillingStreet', 'random type(street) group(billing)');
    acc.setDefinition('BillingPostalCode', 'random type(postalcode) group(billing)');
    acc.setDefinition('BillingCity', 'random type(city) group(billing)');
    acc.setDefinition('BillingState', 'random type(state) group(billing)');
    acc.setDefinition('BillingCountry', 'random type(country) group(billing)');

    /* other fields */
    acc.setDefinition('Site', 'random type(url)');

    /* record type */
    // create records with a specific record type
    // acc.setDefinition('RecordTypeId', 'static value(Customer)'); // value parameter depends on your record types

    /* special fields */
    // acc.setDefinition('CreatedDate', 'random type(datetime) from(2010-01-01) to(2015-12-31)');
    // acc.setDefinition('CreatedById', 'random lookup(User) source(salesforce)');

    // generate records
    List<Account> accounts = (List<Account>)acc.getRecords();
    Database.SaveResult[] sr = acc.insertRecords();
  }
  
  public static void generateContacts() {
    FObject c = new FObject('Contact', 100);
    c.SetRequiredFields = true;
    //FObject.Locality = 'Greece';
    //FObject.Language = 'Greek';

    /* basic fields */
    c.setDefinition('FirstName', 'random type(firstname) group(name)');
    c.setDefinition('LastName', 'random type(lastname) group(name)');
    c.setDefinition('Email', 'random type(email)');
    c.setDefinition('LeadSource', 'random type(picklist)');
    c.setDefinition('Birthdate', 'random type(date) from(1950-1-1) to(1982-12-31)');                
    c.setDefinition('Title', 'random type(list) value(Developer, CFO, Account Manager, CEO, Logistics Manager)');

    /* address fields */
    c.setDefinition('OtherStreet', 'random type(street) group(other)');
    c.setDefinition('OtherPostalCode', 'random type(postalcode) group(other)');
    c.setDefinition('OtherCity', 'random type(city) group(other)');
    c.setDefinition('OtherState', 'random type(state) group(other)');
    c.setDefinition('OtherCountry', 'random type(country) group(other)');
    c.setDefinition('MailingStreet', 'random type(street) group(mailing)');
    c.setDefinition('MailingPostalCode', 'random type(postalcode) group(mailing)');
    c.setDefinition('MailingCity', 'random type(city) group(mailing)');
    c.setDefinition('MailingState', 'random type(state) group(mailing)');
    c.setDefinition('MailingCountry', 'random type(country) group(mailing)');

    /* other fields */
    c.setDefinition('Department', 'random type(list) value(Sales, Marketing, Accounting, Management)');
    //c.setDefinition('AccountId', 'random type(lookup) object(Account) source(forceea)');

    /* special fields */
    //a.setDefinition('CreatedDate', 'random type(datetime) from(2010-01-01) to(2015-12-31)');
    //a.setDefinition('CreatedById', 'random type(lookup) source(User)');

    // generate records
    List<Contact> contacts = (List<Contact>)c.getRecords();
    Database.SaveResult[] sr = c.insertRecords();
  }

  // create cases with fields
  public static void generateCases() {
    FObject c = new FObject('Case');
    c.SetRequiredFields = true;

    /* basic fields */
    c.setDefinition('AccountId', 'random lookup(Account) source(forceea)');    
    c.setDefinition('ContactId', 'random lookup(Contact) source(forceea)');   
    c.setDefinition('Origin', 'random type(picklist)');
    c.setDefinition('Type', 'random type(picklist)');
    c.setDefinition('Status', 'static value(Working)');
    c.setDefinition('Subject', 'random type(text) minlength(50) maxlength(200)');
    c.setDefinition('Reason', 'random type(picklist)');
    c.setDefinition('Description', 'random type(text) minlength(50) maxlength(200)');
    //c.setDefinition('CreatedDate ', 'random type(datetime) from(2010-01-01) to(2015-12-31)');
    //c.setDefinition('RecordTypeId', 'static value(xyz)');
    
    // generate records
    List<Case> cases = (List<Case>)c.getRecords();
    Database.SaveResult[] sr = c.insertRecords();
  }

  public static void generateLeads() {
    FObject ld = new FObject('Lead');
    ld.SetRequiredFields = true;
    //FObject.Locality = 'Greece';
    //FObject.Language = 'Greek';

    /* basic fields */
    ld.setDefinition('FirstName', 'random type(firstname) group(name)');
    ld.setDefinition('LastName', 'random type(lastname) group(name)');
    ld.setDefinition('Email', 'random type(email)');

    ld.setDefinition('Birthdate', 'random type(date) from(1950-1-1) to(1982-12-31)');                
    ld.setDefinition('Title', 'random type(list) value(Developer, CFO, Account Manager, CEO, Logistics Manager)');
    ld.setDefinition('Industry', 'random type(picklist)');
    ld.setDefinition('AnnualRevenue', 'random type(number) from(1000000) to(10000000) scale(-3)');
    ld.setDefinition('Status', 'static value(Open)');
    ld.setDefinition('NumberOfEmployees', 'random type(list) value(10,20,30)');
    //ld.setDefinition('CreatedDate ', 'random type(datetime) from(2010-01-01) to(2015-12-31)');
    
    /* address fields */
    ld.setDefinition('OtherStreet', 'random type(street) group(other)');
    ld.setDefinition('OtherPostalCode', 'random type(postalcode) group(other)');
    ld.setDefinition('OtherCity', 'random type(city) group(other)');
    ld.setDefinition('OtherState', 'random type(state) group(other)');
    ld.setDefinition('OtherCountry', 'random type(country) group(other)');
    ld.setDefinition('MailingStreet', 'random type(street) group(mailing)');
    ld.setDefinition('MailingPostalCode', 'random type(postalcode) group(mailing)');
    ld.setDefinition('MailingCity', 'random type(city) group(mailing)');
    ld.setDefinition('MailingState', 'random type(state) group(mailing)');
    ld.setDefinition('MailingCountry', 'random type(country) group(mailing)');

    // generate records
    List<lead> leads = (List<Lead>)ld.getRecords();
    Database.SaveResult[] sr = ld.insertRecords();
  }

public static void generateOpportunities() {
    FObject opp = new FObject('Opportunity');
    opp.SetRequiredFields = true;

    /* basic fields */                
    opp.setDefinition('Name', 'static value(Opp)');
    opp.setDefinition('Name', 'serial from(1) step(1) scale(0)');
    opp.setDefinition('Amount', 'random type(number) from(1000000) to(10000000) scale(-3)');
    opp.setDefinition('StageName',  'random type(picklist)');
    opp.setDefinition('CloseDate', 'random type(date) from(2017-01-01) to(2017-12-31)');  

    // generate records
    List<Opportunity> opps = (List<Opportunity>)opp.getRecords();
    Database.SaveResult[] sr = opp.insertRecords();
  }

  public static void testUser() {
    FObject u1 = new FObject('User', 1);
    u1.SetRequiredFields = true;
    u1.setDefinition('ProfileId', 'static lookup(Profile) field(Name) value(System Administrator) source(salesforce)');
    List<User> users1 = (List<User>) u1.getRecords();
    Database.SaveResult[] sr1 = u1.insertRecords();

    FObject u2 = new FObject('User', 1);
    u2.SetRequiredFields = true;
    u2.setDefinition('ProfileId', 'static lookup(profile) field(Name) value(Standard User) source(salesforce)');
    List<User> users2 = (List<User>) u2.getRecords();
    }
}