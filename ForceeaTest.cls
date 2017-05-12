/* Forceea Data Factory Framework
 * v1.0.0.4
 * Developer: Nikos Mitrakis
 */

@isTest
public class ForceeaTest {
	// create a user with a standard profile
	private testmethod static void testCreateUserWithProfile() {	
		System.debug('Testing: create a user with a standard profile');

		FObject userSObj = new FObject('User', 1);
		userSObj.setRequiredFields = true;
		userSObj.setDefinition('ProfileId', 'static lookup(Profile) field(Name) value(System Administrator) source(salesforce)');
		userSObj.setDefinition('Title', 'Static Value(ForceeaDeveloper)');  
		Database.SaveResult[] saveResults = userSObj.insertRecords();

		Integer errors = 0;
		for (Database.SaveResult sr: saveResults) {
			if (sr.isSuccess()) {
				System.debug('Successfully inserted user with ID: ' + sr.getId());
			}
			else {errors++;}
		}

		// assert results
		System.assertEquals(0, errors);
	}

	// create records with lookup field
	private testmethod static void testCreateRecordsWithLookup() {
		System.debug('Testing: create Opportunies');

		// create contacts
		FObject accSObj = new FObject('Account', 10);
		accSObj.setRequiredFields = true;
		Database.SaveResult[] saveResults = accSObj.insertRecords();

		// create opportunies
		FObject oppSObj = new FObject('Opportunity', 50);
		oppSObj.setRequiredFields = true;
		oppSObj.setDefinition('AccountId', 'random lookup(Account) source(forceea)');
		saveResults = oppSObj.insertRecords();

		// assert results
		List<Opportunity> newOpps = new List<Opportunity>(
				[SELECT Id FROM Opportunity LIMIT 50]);
		System.assertEquals(50, newOpps.size());
	}

	// create records as a specific user
	private testmethod static void testCreateRecordsWithUser() {
		Integer errors = 0;
		System.debug('Testing: create 1 user and accounts with this user');

		// declare SObject
		FObject userSObj = new FObject('User', 1);
		userSObj.setRequiredFields = true;
		userSObj.setDefinition('Title', 'Static Value(ForceeaDeveloper)');
		Database.SaveResult[] saveResults = userSObj.insertRecords();
		List<User> users = (List<User>)userSObj.getRecords();  

		// assert results
		List<User> newUsers =  new List<User>([SELECT Id FROM User WHERE Title = 'ForceeaDeveloper']);
		System.assertEquals(1, newUsers.size());

		// create accounts using this user	
		System.runAs(users[0]) {
			// declare SObject
			FObject accSObj = new FObject('Account', 10);
			accSObj.setDefinition('Name', 'static value(Company)');
			accSObj.setDefinition('Name', 'serial from (1) step(1) scale(0)');
			accSObj.setDefinition('NumberOfEmployees', 'random from(10 ) to(1000) scale(0)');
			accSObj.setDefinition('Industry', ' random type(picklist)');
			saveResults = accSObj.insertRecords();

			// assert results
			List<Account> newAccounts =  new List<Account>([SELECT Id FROM Account]);
			System.assertEquals(10, newAccounts.size());
		}
	}

	// declare fields with spaces or lowercae/uppercase in command/parameters/value
	private testmethod static void testDefinitionsWithSpaces() {
		System.debug('Testing: space in definitions');

		// declare SObject
		FObject accSObj = new FObject('Account');
		accSObj.setDefinition('AnnualRevenue', 'Random from( 100) to(1000000 ) scale(3)');
		accSObj.setDefinition('Name', ' Serial from (1) step (1) scale (0) ');
		accSObj.setDefinition('NumberOfEmployees', 'RANDOM from(10) to(1000) scale(0)');
		accSObj.setDefinition(' rating', 'random Type( picklist) except(Hot)');
		accSObj.setDefinition('Industry', 'Random  type(picklist )');
		accSObj.setDefinition('Type ', ' random type(list) value(Other,Prospect, Instalaltion Partner)');
		List<Account> Accounts = (List<Account>)accSObj.getRecords();

		// assert results
		System.assertEquals(0, accSObj.getErrors().size());
	}

	// delete records
	private testmethod static void testDeleteRecords() {
		System.debug('Testing: delete records');

		// declare SObject
		FObject accSObj = new FObject('Account', 10);
		accSObj.setRequiredFields = true;
		accSObj.setDefinition('Rating', 'random type(picklist)');

		// insert accounts
		Database.SaveResult[] saveResults = accSObj.insertRecords();
		List<Account> newAccounts = accSObj.getRecords();

		// count accounts to be deleted
		Integer numRecordsToDelete = 0;
		for (Account acc: newAccounts) {
			if (acc.Rating == 'Hot')
				numRecordsToDelete++;
		}
		//count accounts left
		Integer acountsNotDeleted = newAccounts.size() - numRecordsToDelete;

		//delete some accounts, WHERE Rating = 'Hot'
		accSObj.deleteRecords('Rating = \'Hot\'');


		// get accounts after delete
		List<Account> accountsAfterDelete = accSObj.getRecords();

		// assert results
		System.assertEquals(acountsNotDeleted, accountsAfterDelete.size());
	}

	// SObject API name is invalid
	private testmethod static void testInvalidObject() {
		System.debug('Testing: invalid Object');

		FObject accSObj = new FObject('AccountX');
		List<Account> accounts = (List<Account>)accSObj.getRecords();

		// assert results
		System.assertEquals('Invalid SObject [AccountX]', accSObj.getError('AccountX'));
	}

	// Field API name is invalid
	private testmethod static void testInvalidField() {
		System.debug('Testing: invalid Field');

		FObject accSObj = new FObject('Account');
		accSObj.setDefinition('NameX', 'Static Value(Company)');
		List<Account> accounts = (List<Account>)accSObj.getRecords();

		// assert results
		System.assertEquals('Invalid field [namex] on definition [Static Value(Company)]', accSObj.getError('NameX'));
	}

	// Command in field definition is invalid
	private testmethod static void testInvalidCommand() {
		System.debug('Testing: invalid Command');

		FObject accSObj = new FObject('Account');
		accSObj.setDefinition('Name', 'StaticX Value(Company)');
		List<Account> accounts = (List<Account>)accSObj.getRecords();

		// assert results
		System.assertEquals('Invalid command [staticx] on definition [StaticX Value(Company)]', accSObj.getError('StaticX'));
	}
	
	// Parameter in a cluster is invalid
	private testmethod static void testInvalidParameter() {
		System.debug('Testing: invalid Parameter');

		FObject accSObj = new FObject('Account');
		accSObj.setDefinition('Name', 'static valueX(Company)');
		List<Account> accounts = (List<Account>)accSObj.getRecords();

		// assert results
		System.assertEquals('Invalid parameter for cluster [valueX(Company)]', accSObj.getError('valueX(Company)'));
	}

	// No Closing Parenthesis in a Cluster
	private testmethod static void testNoClosingParenthesis() {
		System.debug('Testing: No Closing Parenthesis in a Cluster');

		FObject accSObj = new FObject('Account');
		accSObj.setDefinition('Rating', 'random type(picklist');
		List<Account> accounts = (List<Account>)accSObj.getRecords();

		// assert results
		System.assertEquals('There is no closing parenthesis for cluster [type(picklist]', accSObj.getError('type(picklist'));
	}

	// No Opening Parenthesis in a Cluster
	private testmethod static void testNoOpeningParenthesis() {
		System.debug('Testing: No Opening Parenthesis in a Cluster');

		FObject accSObj = new FObject('Account');
		accSObj.setDefinition('Rating', 'random type picklist)');
		List<Account> accounts = (List<Account>)accSObj.getRecords();

		// assert results
		System.assertEquals('There is no opening parenthesis for cluster [type picklist)]', accSObj.getError('type picklist)'));
	}

	// There are no required fields
	private testmethod static void testRequiredFields() {
		System.debug('Testing: required fields');

		FObject sObj = new FObject('Account', 10);
		Database.SaveResult[] saveResults = sObj.insertRecords();

		Integer errors = 0;
		for (Database.SaveResult sr : saveResults) {
			if (sr.isSuccess()) {
				System.debug('Successfully inserted account with ID: ' + sr.getId());
			}
			else {errors++;}
		}

		// assert results
		System.assertEquals(10, errors);
	}
}
