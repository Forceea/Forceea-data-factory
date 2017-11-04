/**
 * @description FObject Test Class
 * @version 1.1
 */
@isTest
public class FObjectTest {
  private static Set<String> fFirstNames;
  private static Set<String> fLastNames;
  private static Set<String> mFirstNames;
  private static Set<String> mLastNames;

  @isTest
  private static void deleteAllDefinitions_declareSomeDefinitions_expectSuccess() {
    Test.startTest();
    FObject acc = new FObject('Account', 100);
    acc.SetRequiredFields = true;
    acc.setDefinition('Name', 'static value(TestName_)');
    acc.setDefinition('Name', 'random type(number) from(1) to(100) scale(0)');
    acc.setDefinition('Rating', 'random type(picklist)');
    acc.setDefinition('Industry', 'random type(picklist)');
    acc.deleteAllDefinitions();
    Test.stopTest();
    
    System.assertEquals(true, acc.getFieldDefinitions('Name').isEmpty(),
      'Delete all definitions: errors found');
    System.assertEquals(true, acc.getFieldDefinitions('Rating').isEmpty(),
      'Delete all definitions: errors found');
    System.assertEquals(true, acc.getFieldDefinitions('Industry').isEmpty(),
      'Delete all definitions: errors found');
  }

  @isTest
  private static void deleteAllDefinitions_declareNoDefinitions_expectSuccess() {
    Test.startTest();
    FObject acc = new FObject('Account', 100);
    acc.deleteAllDefinitions();
    Test.stopTest();

    System.assertEquals(true, acc.getAllDefinitions().isEmpty(),
      'Delete all definitions: errors found');
  }

  @isTest
  private static void deleteFieldDefinitions_declareSomeDefinitions_expectSuccess() {
    Test.startTest();
    FObject acc = new FObject('Account', 100);
    acc.SetRequiredFields = true;
    acc.setDefinition('Name', 'static value(TestName_)');
    acc.setDefinition('Name', 'random type(number) from(1) to(100) scale(0)');
    acc.setDefinition('Rating', 'random type(picklist)');
    acc.deleteFieldDefinitions('Name');
    Test.stopTest();

    List<String> fieldDefinitions = acc.getFieldDefinitions('Name');
    Map<String, List<String>> allDefinitions = acc.getAllDefinitions();
    System.assertEquals(true, fieldDefinitions.isEmpty(), 'Delete field definitions: errors found');
  }

  @isTest
  private static void deleteFieldDefinitions_declareNoDefinitions_expectSuccess() {
    Test.startTest();
    FObject acc = new FObject('Account', 100);
    List<Account> accounts = (List<Account>)acc.getRecords();
    acc.deleteFieldDefinitions('Name');
    
    List<String> fieldDefinitions = acc.getFieldDefinitions('Name');
    Test.stopTest();
    
    System.assertEquals(true, fieldDefinitions.isEmpty(), 'Delete field definitions: errors found');
  }

  @isTest
  private static void deleteFieldDefinitions_invalidField_expectFailure() {
    Test.startTest();
    FObject acc = new FObject('Account', 100);
    acc.SetRequiredFields = true;
    acc.setDefinition('Name', 'static value(TestName_)');
    acc.setDefinition('Name', 'random type(number) from(1) to(100) scale(0)');
    acc.setDefinition('Rating', 'random type(picklist)');
    
    acc.deleteFieldDefinitions('NameX');
    Test.stopTest();
    
    System.assertEquals('Invalid field [NameX]', acc.getErrors().get('Account').get(0),
      'Delete field definitions: errors found');
  }

  @isTest
  private static void deleteRecords_whereFieldHasSpecificValue_expectSuccess() {
    Test.startTest();
    FObject acc = new FObject('Account', 50);
    acc.SetRequiredFields = true;
    acc.setDefinition('rating', 'random type(picklist)');
    Database.SaveResult[] saveResults = acc.insertRecords();
    List<Account> newAccounts = (List<Account>)acc.getRecords();
    Test.stopTest();

    // count records to be deleted
    Integer numRecordsToDelete = 0;
    for (Account ac : newAccounts) {
      if (ac.Rating == 'Hot') {
        numRecordsToDelete++;
      }
    }
    
    // count records left
    Integer acountsNotDeleted = newAccounts.size() - numRecordsToDelete;
    
    // delete all accounts WHERE Rating = 'Hot'
    acc.deleteRecords('Rating = \'Hot\'');


    // get accounts after delete
    List<Account> accountsAfterDelete = (List<Account>)acc.getRecords();


    // assert results
    System.assertEquals(acountsNotDeleted, accountsAfterDelete.size(), 'deleteRecords: errors found');
  }

  @isTest
  private static void getAllDefinitions_definitionsWithSpacesAndCase_expectSuccess() {
    Test.startTest();
    FObject acc = new FObject('Account');
    acc.setDefinition('AnnualRevenue', 'Random from( 100) to(1000000 ) scale(3)');
    acc.setDefinition('name', ' static value(Company)');
    acc.setDefinition('name', ' Serial from (1) step (1) scale (0) ');
    acc.setDefinition('numberOfEmployees', 'RANDOM type(number) from(10) to(1000) scale(0)');
    acc.setDefinition(' rating', 'random Type( picklist) except(Hot)');
    acc.setDefinition('industry', 'Random  type(picklist )');
    acc.setDefinition('typeX ', ' random type(list) value(Other,Prospect, Instalaltion Partner)');

    Map<String, List<String>> definitions = acc.getAllDefinitions();
    Test.stopTest();

    // get a list of definition fields (keys)
    List<String> fields = new List<String>(definitions.keySet());
    // get all definitions list
    List<List<String>> definitionValues = definitions.values();
    // get the definitions of NumberOfEmployees field
    List<String> definitionOfFieldName = definitionValues[1]; 

    String errorMessage = 'Method getAllDefinitions: errors found';
    // check how many definitons are inserted - the last one should not
    System.assertEquals(5, definitions.size(), errorMessage);
    // check if the field Rating definition is inserted in the correct index
    System.assertEquals('Rating', fields[3], errorMessage);
    // check if the field Name definition is inserted in the correct index
    System.assertEquals('Serial from (1) step (1) scale (0)', definitionOfFieldName[1], errorMessage);
  }

  @isTest
  private static void getDefaultRecords_lessThan10Records_expectSuccess() {
    Test.startTest();
    Integer records = 9;
    FObject cont = new FObject('Contact', records);
    cont.SetRequiredFields = true;
    cont.setDefinition('accountId', 'random lookup(account) source(forceea)');
    List<Contact> contacts = (List<Contact>)cont.getRecords();
    Test.stopTest();

    List<Account> accounts = new List<Account>([SELECT Id FROM Account]);
    System.assertEquals(records, accounts.size(), 'Method getDefaultRecords: errors found');
  }

  @isTest
  private static void getDefaultRecords_moreThan10Records_expectSuccess() {
    Test.startTest();
    Integer records = 100;
    FObject cont = new FObject('Contact', records);
    cont.SetRequiredFields = true;
    cont.setDefinition('accountId', 'random lookup(account) source(forceea)');
    List<Contact> contacts = (List<Contact>)cont.getRecords();
    Test.stopTest();

    List<Account> accounts = new List<Account>([SELECT Id FROM Account]);
    System.assertEquals(10 + 0.1 * records, accounts.size(), 'Method getDefaultRecords: errors found');
  }

  @isTest
  private static void getFieldDefinitions_definitionsWithSpacesAndCase_expectSuccess() {
    Test.startTest();
    FObject acc = new FObject('Account');
    acc.setDefinition('AnnualRevenue', 'Random from( 100) to(1000000 ) scale(3)');
    acc.setDefinition('Name', ' Serial from (1) step (1) scale (0) ');
    acc.setDefinition('NumberOfEmployees', 'RANDOM type(number) from(10) to(1000) scale(0)');
    acc.setDefinition(' rating', 'random Type( picklist) except(Hot)');
    acc.setDefinition('Industry', 'Random  type(picklist )');
    acc.setDefinition('Type ', ' random type(list) value(Other,Prospect, Instalaltion Partner)');
    List<Account> Accounts = (List<Account>)acc.getRecords();
    List<String> annualRevenueDefinitions = acc.getFieldDefinitions('AnnualRevenue');
    Test.stopTest();
    
    System.assertEquals('Random from( 100) to(1000000 ) scale(3)',
      annualRevenueDefinitions[0], 'AnnualRevenue definition: errors found');
  }

  @isTest
  private static void getRandomDomains_negativeSyllables_excpectSuccess() {
  }

  @isTest
  private static void getRecords_invalidObject_expectFailure() {
    Test.startTest();
    FObject acc = new FObject('AccountX');
    Database.SaveResult[] saveResults = acc.insertRecords();
    Test.stopTest();
    
    System.assertEquals('Invalid object [AccountX]', acc.getErrors().get('AccountX').get(0),
      'Invalid object: error message is wrong');
  }

  @isTest
  private static void getRecords_invalidField_expectFailure() {
    Test.startTest();
    FObject acc = new FObject('Account');
    acc.setDefinition('NameX', 'Static Value(Company)');
    List<Account> accounts = (List<Account>)acc.getRecords();
    Test.stopTest();
    
    System.assertEquals('Invalid field [namex] in definition [Static Value(Company)]',
      acc.getErrors().get('Account').get(0), 'Invalid field: error message is wrong');
  }

  @isTest
  private static void  getRecords_invalidCommand_expectFailure() {
    Test.startTest();
    FObject acc = new FObject('account');
    acc.setDefinition('name', 'staticX  Value(Company) ');
    List<Account> accounts = (List<Account>)acc.getRecords();
    Test.stopTest();
    
    System.assertEquals('Invalid command [staticx] in definition [staticX  Value(Company)]',
      acc.getErrors().get('Name').get(0), 'Invalid command: error message is wrong');
  }

  @isTest
  private static void getRecords_invalidParameter_expectFailure() {
    Test.startTest();
    FObject acc = new FObject('Account');
    acc.SetRequiredFields = true;
    acc.setDefinition('Name', 'static valueX(Company)');
    List<Account> accounts = (List<Account>)acc.getRecords();
    Test.stopTest();
    
    System.assertEquals('Invalid parameter for cluster [valueX(Company)]',
      acc.getErrors().get('Name').get(0), 'Invalid parameter: wrong error message');
  }

 
  @isTest
  private static void  getRecords_noOpeningParenthesis_expectFailure() {
    Test.startTest();
    FObject acc = new FObject('Account');
    acc.setDefinition('Rating', 'random type picklist)');
    List<Account> accounts = (List<Account>)acc.getRecords();
    Test.stopTest();

    System.assertEquals('There is no opening parenthesis for cluster [type picklist)]',
      acc.getErrors().get('Rating').get(0), 'No opening parenthesis: wrong error message');
  }

  @isTest
  private static void insertRecords_createRecordsAsUser_expectSuccess() {
    Test.startTest();
    FObject usr = new FObject('User', 1);
    usr.SetRequiredFields = true;
    usr.setDefinition('Title', 'static value(Developer)');
    Database.SaveResult[] saveResults = usr.insertRecords();
   
    Integer errors = 0;
    for (Database.SaveResult sr : saveResults) {
      if (!sr.isSuccess()) {
        errors++;
      }
    }

    if (errors == 0) { // user was created successfully
      List<User> users = (List<User>)usr.getRecords();
      // insert  accounts using this user
      System.runAs(users[0]) {
        FObject acc = new FObject('Account', 10);
        acc.SetRequiredFields = true;
        acc.setDefinition('Name', 'static value(Company)');
        acc.setDefinition('Name', 'serial from (1) step(1) scale(0)');
        acc.setDefinition('NumberOfEmployees', 'random type(number) from(10) to(1000) scale(0)');
        acc.setDefinition('Industry', ' random type(picklist)');
        saveResults = acc.insertRecords();
      }
    }
    Test.stopTest();

    errors = 0;
    for (Database.SaveResult sr : saveResults) {
      if (!sr.isSuccess()) {
        errors++;
      }
    }

    System.assertEquals(0, errors, 'Create accounts: errors found');
  }

  @isTest
  private static void  insertRecords_missingRequiredFields_expectFailure() {
    Test.startTest();
    FObject acc = new FObject('Account', 10);
    
    Database.SaveResult[] saveResults = acc.insertRecords();
    Integer errors = 0;
    for (Database.SaveResult sr : saveResults) {
      if (!sr.isSuccess()) {
        errors++;
      }
    }
    Test.stopTest();
    
    System.assertEquals(10, errors,  'insertRecords: wrong number of errors');
  }

  @isTest
  private static void insertRecords_recordsWithForceeaLookup_expectSuccess() {
    Test.startTest();
    FObject acc = new FObject('Account', 10);
    acc.SetRequiredFields = true;
    Database.SaveResult[] saveResults = acc.insertRecords();
    
    FObject opp = new FObject('Opportunity', 50);
    opp.SetRequiredFields = true;
    opp.setDefinition('AccountId', 'random lookup(Account) source(forceea)');
    saveResults = opp.insertRecords();
    Test.stopTest();

    Integer errors = 0;
    for (Database.SaveResult sr : saveResults) {
      if (!sr.isSuccess()) {
        errors++;
      }
    }
   
    System.assertEquals(0, errors, 'Create records with Forceea lookup field: errors found');
  }

  @isTest
  private static void insertRecords_userWithProfile_expectSuccess() {
    Test.startTest();
    FObject usr = new FObject('User', 1);
    usr.SetRequiredFields = true;
    usr.setDefinition('ProfileId', 'static lookup(Profile) field(Name) value(System Administrator) source(salesforce)');
    usr.setDefinition('Title', 'static value(Forceea Developer)');
   
    Database.SaveResult[] saveResults = usr.insertRecords();
    Test.stopTest();

    Integer errors = 0;
    for (Database.SaveResult sr : saveResults) {
      if (!sr.isSuccess()) {
        errors++;
      }
    }
    
    System.assertEquals(0, errors, 'Create user with profile: errors found');
  }
  
  @isTest
  private static void loadAddressesFromGreeceInGreek_correctLanguageAndLocality_expectSuccess() {
    Test.startTest();
    FObject cont = new FObject('Contact', 100);
    cont.SetRequiredFields = true;
    FObject.Language = 'Greek';
    FObject.Locality = 'Greece';
    cont.setDefinition('MailingStreet', 'random type(street) group(mailing)');
    cont.setDefinition('MailingPostalCode', 'random type(postalcode) group(mailing)');
    cont.setDefinition('MailingCity', 'random type(city) group(mailing)');
    cont.setDefinition('MailingState', 'random type(state) group(mailing)');
    cont.setDefinition('MailingCountry', 'random type(country) group(mailing)');
    Database.SaveResult[] saveResults = cont.insertRecords();
    Test.stopTest();
  
    List<Contact> data = new List<Contact>([SELECT Id FROM Contact WHERE MailingCountry = 'Ελλάδα']);

    System.assertEquals(100, data.size(), 'Method loadNamesFromGreeceInGreek: errors found');
  }

 @isTest
  private static void loadNames_incorrectLanguageAndLocality_expectSuccess() {
    Integer records = 200;
    loadNamesFromUnitesStatesInEnglish();

    Test.startTest();
    FObject cont = new FObject('Contact', records);
    cont.SetRequiredFields = true;
    FObject.Language = 'Language';
    FObject.Locality = 'Locality';
    cont.setDefinition('FirstName', 'random type(firstname) group(a)');
    cont.setDefinition('LastName', 'random type(lastname) group(a)');

    Database.SaveResult[] saveResults = cont.insertRecords();
    Test.stopTest();
  
    Integer countNames = 0;
    for (Contact cnt : [SELECT Id, LastName FROM Contact]) {
      if (fLastNames.contains(cnt.LastName) || mLastNames.contains(cnt.LastName)) {
        countNames++;
      }
    }
    System.assertEquals(records, countNames, 'Method loadNamesFromUnitedStatesInEnglish: errors found');
  }

  @isTest
  private static void loadNamesFromGreeceInGreek_correctLanguageAndLocalityForFirstNames_expectSuccess() {
    Integer records = 200;
    loadNamesFromGreeceInGreek();

    Test.startTest();
    FObject cont = new FObject('Contact', records);
    FObject.Language = 'Greek';
    FObject.Locality = 'Greece';
    cont.SetRequiredFields = true;
    cont.setDefinition('FirstName', 'random type(firstname) group(a)');
    cont.setDefinition('LastName', 'random type(lastname) group(a)');
    Database.SaveResult[] saveResults = cont.insertRecords();
    Test.stopTest();
  
    Integer countNames = 0;
    for (Contact cnt : [SELECT Id, FirstName FROM Contact]) {
      if (fFirstNames.contains(cnt.FirstName) || mFirstNames.contains(cnt.FirstName)) {
        countNames++;
      }
    }
    System.assertEquals(records, countNames, 'Method loadNamesFromGreeceInGreek: errors found');
  }

  @isTest
  private static void loadNamesFromGreeceInGreek_correctLanguageAndLocalityForLastNames_expectSuccess() {
    Integer records = 200;
    loadNamesFromGreeceInGreek();

    Test.startTest();
    FObject cont = new FObject('Contact', records);
    FObject.Language = 'Greek';
    FObject.Locality = 'Greece';
    cont.SetRequiredFields = true;
    cont.setDefinition('FirstName', 'random type(firstname) group(a)');
    cont.setDefinition('LastName', 'random type(lastname) group(a)');
    Database.SaveResult[] saveResults = cont.insertRecords();
    Test.stopTest();
  
    Integer countNames = 0;
    for (Contact cnt : [SELECT Id, LastName FROM Contact]) {
      if (fLastNames.contains(cnt.LastName) || mLastNames.contains(cnt.LastName)) {
        countNames++;
      }
    }
    System.assertEquals(records, countNames, 'Method loadNamesFromGreeceInGreek: errors found');
  }

  @isTest
  private static void loadNamesFromUnitedStatesInEnglish_correctLanguageAndLocalityForFirstName_expectSuccess() {
    Integer records = 200;
    loadNamesFromUnitesStatesInEnglish();

    Test.startTest();
    FObject cont = new FObject('Contact', records);
    FObject.Language = 'English';
    FObject.Locality = 'United States';
    cont.SetRequiredFields = true;
    cont.setDefinition('FirstName', 'random type(firstname) group(a)');
    cont.setDefinition('LastName', 'random type(lastname) group(a)');
    Database.SaveResult[] saveResults = cont.insertRecords();
    Test.stopTest();
  
    Integer countNames = 0;
    for (Contact cnt : [SELECT Id, FirstName FROM Contact]) {
      if (fFirstNames.contains(cnt.FirstName) || mFirstNames.contains(cnt.FirstName)) {
        countNames++;
      }
    }
    System.assertEquals(records, countNames, 'Method loadNamesFromUnitedStatesInEnglish: errors found');
  }

  @isTest
  private static void loadNamesFromUnitedStatesInEnglish_correctLanguageAndLocalityForLastName_expectSuccess() {
    Integer records = 200;
    loadNamesFromUnitesStatesInEnglish();

    Test.startTest();
    FObject cont = new FObject('Contact', records);
    FObject.Language = 'English';
    FObject.Locality = 'United States';
    cont.SetRequiredFields = true;
    cont.setDefinition('FirstName', 'random type(firstname) group(a)');
    cont.setDefinition('LastName', 'random type(lastname) group(a)');
    Database.SaveResult[] saveResults = cont.insertRecords();
    Test.stopTest();
  
    Integer countNames = 0;
    for (Contact cnt : [SELECT Id, LastName FROM Contact]) {
      if (fLastNames.contains(cnt.LastName) || mLastNames.contains(cnt.LastName)) {
        countNames++;
      }
    }
    System.assertEquals(records, countNames, 'Method loadNamesFromUnitedStatesInEnglish: errors found');
  }

  private static void loadNamesFromGreeceInGreek() {
    fFirstNames = new Set<String> {
      'Νάντια', 'Διονυσία', 'Τάνια', 'Αδαμαντία', 'Αλίκη', 'Βασιλική', 'Φανή', 'Καίτη', 'Χρύσα', 'Μάγδα', 'Ηλιάνα',
      'Όλγα', 'Γεωργία', 'Μαριάνθη', 'Άρτεμις', 'Άντζελα', 'Στέλλα', 'Ζωή', 'Ανθή', 'Ευθυμία', 'Αγγελική', 'Τόνια',
      'Ντίνα', 'Ρίτα', 'Ντόρα', 'Αλεξία', 'Παυλίνα', 'Ρένα', 'Σοφία', 'Στεφανία', 'Λένα', 'Τζίνα', 'Γιούλη', 'Νεκταρία',
      'Ρέα', 'Γιώτα', 'Λίζα', 'Ελένη', 'Άννα', 'Έλενα', 'Αικατερίνη', 'Ρούλα', 'Παναγιώτα',
      'Ευγενία', 'Εμμανουέλα', 'Μαριέττα', 'Μυρσίνη', 'Μαρκέλλα', 'Τριανταφυλλιά', 'Αφροδίτη'
    };
    fLastNames = new Set<String> {
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
    mFirstNames = new Set<String> {
      'Αδάμ', 'Ευγένιος', 'Αλέκος', 'Νώντας', 'Φάνης', 'Αργύρης', 'Άλκης', 'Διαμαντής', 'Θάνος', 'Παύλος', 'Φίλιππος', 'Αλέξης', 'Γιώργος', 'Κώστας',
      'Μάρκος', 'Θωμάς', 'Νίκος', 'Δήμος', 'Θεοδόσης', 'Στάθης', 'Φώτης', 'Κυριάκος', 'Χάρης', 'Λάμπρος', 'Άγγελος', 'Πέτρος', 'Στράτος', 'Γρηγόρης',
      'Μανώλης', 'Τάσος', 'Μιχάλης', 'Αντώνης', 'Ανδρέας', 'Δημήτρης', 'Γιάννης', 'Βαγγέλης', 'Νικήτας', 'Ηλίας', 'Αχιλλέας', 'Σταύρος',
      'Παναγιώτης', 'Φαίδων', 'Σάββας', 'Βασίλης', 'Ορέστης', 'Νεκτάριος', 'Πάνος', 'Στέφανος', 'Θεόφιλος', 'Στέλιος'
    };
    mLastNames = new Set<String> {
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
    fFirstNames = new Set<String> {
      'Tracey', 'Amelia', 'Leah', 'Nicola', 'Theresa', 'Sophie', 'Olivia', 'Sally', 'Wendy', 'Fiona',
      'Deirdre', 'Jane', 'Lillian', 'Abigail', 'Ella', 'Claire', 'Lauren', 'Bernadette', 'Karen', 'Vanessa',
      'Grace', 'Alison', 'Rachel', 'Heather', 'Ava', 'Wanda', 'Natalie', 'Victoria', 'Joan', 'Dorothy',
      'Una', 'Rebecca', 'Donna', 'Emma', 'Sarah', 'Sonia', 'Samantha', 'Lily', 'Bella', 'Penelope', 'Julia',
      'Caroline', 'Felicity', 'Anne', 'Faith', 'Diane', 'Sue', 'Joanne', 'Kylie', 'Jasmine'
    };
    fLastNames = new Set<String> {
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
    mFirstNames = new Set<String> {
      'Sebastian', 'Boris', 'Andrew', 'Paul', 'Jake', 'Edward', 'Neil', 'Ryan', 'Christian', 'Ian', 'Max',
      'Gavin', 'Matt', 'Jonathan', 'Nicholas', 'Adam', 'Frank', 'Brandon', 'Julian', 'Richard', 'Steven',
      'Colin', 'James', 'Trevor', 'Anthony', 'Victor', 'Nathan', 'Adrian', 'John', 'Joshua', 'Stewart',
      'Kevin', 'David', 'Austin', 'Tim', 'Dominic', 'Robert', 'Jason', 'Connor', 'Evan', 'Joe', 'Sam',
      'Blake', 'Liam', 'Stephen', 'Thomas', 'Phil', 'Christopher', 'Lucas', 'Isaac'
    };
    mLastNames = new Set<String>(fLastNames);
  }

  @isTest
  private static void sddlRandomLookupSource_valid_expectSuccessTODO() {
  }

  @isTest
  private static void sddlRandomLookupFieldExceptionSource_invalidObject_expectSuccessTODO() {
  }

  @isTest
  private static void sddlRandomLookupFieldExceptionSource_valid_expectSuccessTODO() {
  }

  @isTest
  private static void sddlRandomLookupFieldValueSource_valid_expectSuccessTODO() {
  }

  @isTest
  private static void sddlRandomTypeBoolean_SetRequiredFields_expectSuccess() {
    Test.startTest();
    FObject opp = new FObject('Opportunity');
    opp.SetRequiredFields = true;
    opp.setDefinition('IsPrivate', 'random type(boolean)');
    Database.SaveResult[] saveResults = opp.insertRecords();
    Test.stopTest();

    List<Opportunity> data = new List<Opportunity>([SELECT Id FROM Opportunity WHERE IsPrivate = false]);
    System.assertNotEquals(0, data.size(), 'Method getRandomBooleans: errors found');
  }

  @isTest
  private static void sddlRandomTypeDate_fromEqualsTo_expectFailure() {
    Test.startTest();
    FObject opp = new FObject('Opportunity', 200);
    opp.SetRequiredFields = true;
    opp.setDefinition('CloseDate', 'random type(date) from(2017-01-01) to(2017-01-01)');
    List<Opportunity> opps = opp.getRecords();

    List<String> errors = opp.getErrors().get('CloseDate');
    System.assertEquals('The [from] date is greater than or equal to the [to] date in definition [' +
      'random type(date) from(2017-01-01) to(2017-01-01)]', errors[0],
      'random type(date): errors found');
  }

  @isTest
  private static void sddlRandomTypeDate_fromLessThanTo_expectSuccess() {
    Test.startTest();
    FObject opp = new FObject('Opportunity', 200);
    opp.SetRequiredFields = true;
    opp.setDefinition('CloseDate', 'random type(date) from(2017-01-01) to(2017-01-10)');
    Database.SaveResult[] saveResults = opp.insertRecords();
    Test.stopTest();

    Integer count = 0;
    Long fromDatePoint = DateTime.newInstance(2017, 10, 1, 0, 0, 0).getTime();
    Long toDatePoint = DateTime.newInstance(2017, 10, 10, 59, 59, 0).getTime();
    for (Opportunity oppt : [SELECT Id, CloseDate FROM Opportunity]) {
      Datetime dt = oppt.CloseDate;
      Long fieldPoint = dt.getTime();
      if (fieldPoint < fromDatePoint || fieldPoint <> toDatePoint) {
        count++;
      }
    }
    System.assertNotEquals(0, count, 'random type(date) generated values out of range');
  }

  @isTest
  private static void sddlRandomTypeDate_fromGreaterThanTo_expectFailure() {
    Test.startTest();
    FObject opp = new FObject('Opportunity', 200);
    opp.SetRequiredFields = true;
    opp.setDefinition('CloseDate', 'random type(date) from(2017-10-01) to(2017-01-01)');
    Database.SaveResult[] saveResults = opp.insertRecords();
    Test.stopTest();

    List<String> errors = opp.getErrors().get('CloseDate');
    System.assertEquals('The [from] date is greater than or equal to the [to] date in definition [' +
      'random type(date) from(2017-10-01) to(2017-01-01)]', errors[0],
      'random type(date): errors found');
  }

  @isTest
  private static void sddlRandomTypeDatetime_fromEqualsTo_expectSuccessTODO() {
  }

  @isTest
  private static void sddlRandomTypeDatetime_fromGreaterThanTo_expectFailureTODO() {
  }

  @isTest
  private static void sddlRandomTypeCity_defaultLanguageLocality_expectSuccess() {
    Test.startTest();
    FObject acc = new FObject('Account');
    acc.setDefinition('Name', 'static value(Company_)');
    acc.setDefinition('Name', 'serial from(1) step(1) scale(0)');
    acc.setDefinition('ShippingCity', 'random type(city) group(shipping)');
    Database.SaveResult[] saveResults = acc.insertRecords();
    Test.stopTest();

    List<Account> data = new List<Account>([SELECT Id FROM Account WHERE ShippingCity = NULL]);
    System.assertEquals(0, data.size(), 'Method getRandomCities: error found');
  }

  @isTest
  private static void sddlRandomTypeCountry_defaultLanguageLocality_expectSuccess() {
    Test.startTest();
    FObject acc = new FObject('Account');
    acc.setDefinition('Name', 'static value(Company_)');
    acc.setDefinition('Name', 'serial from(1) step(1) scale(0)');
    acc.setDefinition('ShippingCountry', 'random type(country) group(shipping)');
    Database.SaveResult[] saveResults = acc.insertRecords();
    Test.stopTest();

    List<Account> data = new List<Account>([SELECT Id FROM Account WHERE ShippingCountry = NULL]);
    System.assertEquals(0, data.size(), 'Method getRandomCountries: error found');
  }

  @isTest
  private static void  sddlRandomTypeList_valid_expectSuccessTODO() {
  }

  @isTest
  private static void  sddlRandomTypePicklist_noClosingParenthesis_expectFailure() {
    Test.startTest();
    FObject acc = new FObject('Account');
    acc.setDefinition('Rating', 'random type(picklist');
    List<Account> accounts = (List<Account>)acc.getRecords();
    Test.stopTest();

    System.assertEquals('There is no closing parenthesis for cluster [type(picklist]',
      acc.getErrors().get('Rating').get(0), 'No closing parenthesis: wrong error message');
  }

  @isTest
  private static void sddlRandomTypePicklistExcept_valid_expectSuccessTODO() {
  }

  @isTest
  private static void sddlRandomTypePostalCode_defaultLanguageLocality_expectSuccess() {
    Test.startTest();
    FObject acc = new FObject('Account');
    acc.setDefinition('Name', 'static value(Company_)');
    acc.setDefinition('Name', 'serial from(1) step(1) scale(0)');
    acc.setDefinition('ShippingPostalCode', 'random type(postalcode) group(shipping)');
    Database.SaveResult[] saveResults = acc.insertRecords();
    Test.stopTest();

    List<Account> data = new List<Account>([SELECT Id FROM Account WHERE ShippingPostalCode = NULL]);
    System.assertEquals(0, data.size(), 'Method getRandomPostalCodes: error found');
  }

  @isTest
  private static void sddlRandomTypeState_defaultLanguageLocality_expectSuccess() {
    Test.startTest();
    FObject acc = new FObject('Account');
    acc.setDefinition('Name', 'static value(Company_)');
    acc.setDefinition('Name', 'serial from(1) step(1) scale(0)');
    acc.setDefinition('ShippingState', 'random type(state) group(shipping)');
    Database.SaveResult[] saveResults = acc.insertRecords();
    Test.stopTest();

    List<Account> data = new List<Account>([SELECT Id FROM Account WHERE ShippingState = NULL]);
    System.assertEquals(0, data.size(), 'Method getRandomStates: error found');
  }

  @isTest
  private static void sddlRandomTypeStreet_defaultLanguageLocality_expectSuccess() {
    Test.startTest();
    FObject acc = new FObject('Account');
    acc.setDefinition('Name', 'static value(Company_)');
    acc.setDefinition('Name', 'serial from(1) step(1) scale(0)');
    acc.setDefinition('ShippingStreet', 'random type(street) group(shipping)');
    Database.SaveResult[] saveResults = acc.insertRecords();
    Test.stopTest();

    List<Account> data = new List<Account>([SELECT Id FROM Account WHERE ShippingStreet = NULL]);
    System.assertEquals(0, data.size(), 'Method getRandomStreets: error found');
  }

  @isTest
  private static void sddlRandomTypeString_includeDigitOnly_expectSuccess() {
    Test.startTest();
    FObject acc = new FObject('Account', 100);
    acc.SetRequiredFields = true;
    acc.setDefinition('Description', 'random type(string) minlength(5) maxlength(10) ' +
      'startwith(lower) include(digit)');
    List<Account> accounts = (List<Account>)acc.getRecords();
    Test.stopTest();

    String result = '';
    Integer count = 0;
    Integer len = 0;
    for (Account accnt : accounts) {
      len =  accnt.Description.length();
      result = accnt.Description.right(len-1);
      if (result.isNumeric()) {
        count++;
      }
    }
    System.assertEquals(100, count, 'The characters of some strings are not all digits');
  }

  @isTest
  private static void sddlRandomTypeString_includeLowerOnly_expectSuccess() {
    Test.startTest();
    FObject acc = new FObject('Account', 100);
    acc.SetRequiredFields = true;
    acc.setDefinition('Description', 'random type(string) minlength(5) maxlength(10) ' +
      'startwith(lower) include(lower)');
    List<Account> accounts = (List<Account>)acc.getRecords();
    Test.stopTest();

    String result = '';
    Integer count = 0;
    Integer len = 0;
    for (Account accnt : accounts) {
      len =  accnt.Description.length();
      result = accnt.Description.right(len-1);
      if (result.isAllLowerCase()) {
        count++;
      }
    }
    System.assertEquals(100, count,
      'The characters of some strings are not all lowercase');
  }

  @isTest
  private static void sddlRandomTypeString_includeUpperOnly_expectSuccess() {
    Test.startTest();
    FObject acc = new FObject('Account', 100);
    acc.SetRequiredFields = true;
    acc.setDefinition('Description', 'random type(string) minlength(5) maxlength(10) ' +
      'startwith(lower) include(upper)');
    List<Account> accounts = (List<Account>)acc.getRecords();
    Test.stopTest();

    String result = '';
    Integer count = 0;
    Integer len = 0;
    for (Account accnt : accounts) {
      len =  accnt.Description.length();
      result = accnt.Description.right(len-1);
      if (result.isAllUpperCase()) {
        count++;
      }
    }
    System.assertEquals(100, count, 'The characters of some strings are not all uppercase');
  }

  @isTest
  private static void sddlRandomTypeString_startWithLower_expectSuccess() {
    Test.startTest();
    FObject acc = new FObject('Account', 100);
    acc.SetRequiredFields = true;
    acc.setDefinition('Description', 'random type(string) minlength(5) maxlength(10) ' +
        'startwith(lower) include(lower,upper)');
    List<Account> accounts = (List<Account>)acc.getRecords();
    Test.stopTest();

    String first = '';
    Integer count = 0;
    for (Account accnt : accounts) {
      first = accnt.Description.left(1);
      if (first.isAllLowerCase()) {
        count++;
      }
    }
    System.assertEquals(100, count, 'The first character of some strings are not uppercase');
  }

  @isTest
  private static void sddlRandomTypeString_startWithUpper_expectSuccess() {
    Test.startTest();
    FObject acc = new FObject('Account', 100);
    acc.SetRequiredFields = true;
    acc.setDefinition('Description', 'random type(string) minlength(5) maxlength(10) ' +
        'startwith(upper) include(lower,upper)');
    List<Account> accounts = (List<Account>)acc.getRecords();
    Test.stopTest();

    String first = '';
    Integer count = 0;
    for (Account accnt : accounts) {
      first = accnt.Description.left(1);
      if (first.isAllUpperCase()) {
        count++;
      }
    }
    System.assertEquals(100, count, 'The first character of some strings are not uppercase');
  }

  @isTest
  private static void sddlRandomTypeText_lengthOfRandomTypeText_expectSuccess() {
    Test.startTest();
    FObject acc = new FObject('Account', 201);
    acc.SetRequiredFields = true;
    acc.setDefinition('Description', 'random type(text) minlength(30) maxlength(50)');
    List<Account> accounts = (List<Account>)acc.getRecords();
    Test.stopTest();

    Integer count = 0;
    Boolean result = false;
    Integer textSize = 0;
    for (Account accnt : accounts) {
      count++;
      textSize = accnt.Description.length();
      result = (textSize >= 30 && textSize <= 50);
      System.assertEquals(true, result,
        'The length of text is not equals to the definition length for record #' + count);
    }
  }

  @isTest
  private static void sddlRandomTypeUrl_valid_expectSuccessTODO() {
  }

  @isTest
  private static void sddlSerial_integer_expectSuccessTODO() {
  }

  @isTest
  private static void sddlSerial_decimal_expectSuccessTODO() {
  }

  @isTest
  private static void sddlStaticValue_validDate_expectSuccess() {
    Test.startTest();
    FObject opp = new FObject('Opportunity', 10);
    opp.SetRequiredFields = true;
    opp.setDefinition('CloseDate', 'static value(2017-10-01)');
    Database.SaveResult[] saveResults = opp.insertRecords();
    List<Opportunity> opportunities = (List<Opportunity>)opp.getRecords();
    Test.stopTest();

    Integer count = 0;
    Date dt = Date.newInstance(2017, 10, 1);
    for (Opportunity oppty : opportunities) {
      if (oppty.CloseDate == dt) {
        count++;
      }
    }
    System.assertEquals(10, count,
      'The static value(DATE) script does not generate correct values');
  }

  @isTest
  private static void sddlStaticValue_validDatetime_expectSuccessTODO() {
  }

  @isTest
  private static void sddlStaticValue_validDecimal_expectSuccess() {
    Test.startTest();
    FObject acc = new FObject('Account', 10);
    acc.SetRequiredFields = true;
    acc.setDefinition('AnnualRevenue', 'static value(100000.11)');
    Database.SaveResult[] saveResults = acc.insertRecords();
    List<Account> accounts = (List<Account>)acc.getRecords();
    Test.stopTest();

    Integer count = 0;
    for (Account accnt : accounts) {
      if (accnt.AnnualRevenue == 100000.11) {
        count++;
      }
    }
    System.assertEquals(10, count,
      'The static value(DECIMAL) script does not generate correct values');
  }

  @isTest
  private static void sddlStaticValue_validInteger_expectSuccess() {
    Test.startTest();
    FObject acc = new FObject('Account', 10);
    acc.SetRequiredFields = true;
    acc.setDefinition('NumberOfEmployees', 'static value(10)');
    Database.SaveResult[] saveResults = acc.insertRecords();
    List<Account> accounts = (List<Account>)acc.getRecords();
    Test.stopTest();

    Integer count = 0;
    for (Account accnt : accounts) {
      if (accnt.NumberOfEmployees == 10) {
        count++;
      }
    }
    System.assertEquals(10, count,
      'The static value(INTEGER) script does not generate correct values');
  }

  @isTest
  private static void sddlStaticValue_string_expectSuccess() {
    Test.startTest();
    FObject acc = new FObject('Account', 10);
    acc.SetRequiredFields = true;
    acc.setDefinition('Description', 'static value(Sales)');
    List<Account> accounts = (List<Account>)acc.getRecords();
    Test.stopTest();

    Integer count = 0;
    for (Account accnt : accounts) {
      if (accnt.Description == 'Sales') {
        count++;
      }
    }
    System.assertEquals(10, count,
      'The static value(STRING) script does not generate correct values');
  }

  @isTest
  private static void setDefinitionFromField_accountName_expectSuccess() {
    Test.startTest();
    FObject acc = new FObject('Account');
    acc.SetRequiredFields = true;
    List<Account> accounts = (List<Account>)acc.getRecords();
    Test.stopTest();

    List<String> definitions = acc.getFieldDefinitions('Name');
    String expectedResult = 'static value(Company) random type(number) from(1) to(10000) scale(0)';
    String actualResult = definitions[0] + ' ' + definitions[1];
    System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField: errors found');
  }

  @isTest
  private static void setDefinitionFromField_contactFirstName_expectSuccess() {
    Test.startTest();
    FObject cont = new FObject('Contact');
    FObject.Field fld = new FObject.Field();
    fld.FieldApiName = 'FirstName';
    cont.setDefinitionFromField(fld);
    Test.stopTest();

    List<String> definitions = cont.getFieldDefinitions('FirstName');
    String expectedResult = 'random type(firstname) group(name)';
    String actualResult = definitions[0];
    System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField: errors found');
  }

  @isTest
  private static void setDefinitionFromField_contactLastName_expectSuccess() {
    Test.startTest();
    FObject cont = new FObject('Contact');
    cont.SetRequiredFields = true;
    List<Contact> contacts = (List<Contact>)cont.getRecords();
    Test.stopTest();

    List<String> definitions = cont.getFieldDefinitions('LastName');
    String expectedResult = 'random type(lastname) group(name)';
    String actualResult = definitions[0];
    System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField: errors found');
  }

  @isTest
  private static void setDefinitionFromField_leadCompany_expectSuccess() {
    Test.startTest();
    FObject ld = new FObject('Lead');
    ld.SetRequiredFields = true;
    List<Lead> leads = (List<Lead>)ld.getRecords();
    Test.stopTest();

    List<String> definitions = ld.getFieldDefinitions('Company');
    String expectedResult = 'static value(Company) random type(number) from(1) to(10000) scale(0)';
    String actualResult = definitions[0] + ' ' + definitions[1];
    System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField: errors found');
  }

  @isTest
  private static void setDefinitionFromField_leadFirstName_expectSuccess() {
    Test.startTest();
    FObject ld = new FObject('Lead');
    FObject.Field fld = new FObject.Field();
    fld.FieldApiName = 'FirstName';
    ld.setDefinitionFromField(fld);
    Test.stopTest();

    List<String> definitions = ld.getFieldDefinitions('FirstName');
    String expectedResult = 'random type(firstname) group(name)';
    String actualResult = definitions[0];
    System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField: errors found');
  }

  @isTest
  private static void setDefinitionFromField_leadLastName_expectSuccess() {
    Test.startTest();
    FObject ld = new FObject('Lead');
    ld.SetRequiredFields = true;
    List<Lead> leads = (List<Lead>)ld.getRecords();
    Test.stopTest();

    List<String> definitions = ld.getFieldDefinitions('LastName');
    String expectedResult = 'random type(lastname) group(name)';
    String actualResult = definitions[0];
    System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField: errors found');
  }

  @isTest
  private static void setDefinitionFromField_opportunityName_expectSuccess() {
    Test.startTest();
    FObject opp = new FObject('Opportunity');
    opp.SetRequiredFields = true;
    List<Lead> opportunities = (List<Lead>)opp.getRecords();
    Test.stopTest();

    List<String> definitions = opp.getFieldDefinitions('Name');
    String expectedResult = 'static value(Opportunity-) serial from(1) step(1) scale(0)';
    String actualResult = definitions[0] + ' ' + definitions[1];
    System.assertEquals(expectedResult, actualResult, 'setDefinitionFromField: errors found');
  }
}