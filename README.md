# Forceea 1.2.1 #
Forceea (forˈsēa) is a data factory framework for Salesforce. The framework creates data using a descriptive language called Sample Data Definition Language (SDDL) to define the nature of the data.

Forceea was created with a double objective:
* Allow developers to easily create SObject records for any Test Method.
* Allow administrators to populate any Developer/Sandbox Org with SObject records for testing or demonstration purposes.

The following list describes the main capabilities of the framework. I encourage everyone to download the [User Guide](http://bit.ly/Forceea12_UserGuide), where you can find many examples and detailed information of the tools the framework offers. 
*	Creates records for standard or custom objects, for any standard or custom field.
*	Automatically definines the required fields.
*	Creates data for fields of any data type: Integer, Currency, Double, Date, Datetime, Time, Boolean, String, TextArea, Percent, Reference, Email, Phone, URL, Base64 (BLOB), Picklist and MultiPicklist.
* Can create static data for: any string, date, datetime, time, integer, decimal, currency, percent, reference (lookup or master-detail) and BLOB (attachment).
* Can create random data for: string, text(sentence), date, datetime, integer, decimal, currency, percent, email, URL, reference (lookup or master-detail) and BLOB (attachment).
* Can create real random first and last names.
* Can create real random addresses with street, zip code, city, region/state and country.
* Can create serial data for: date, datetime, integer, decimal, currency and percent.
* Can copy data from another field of the same record.
*	Handles record types and field dependencies (dependent picklists).
*	Supports record groups for inserting and deleting records.
*	Validates the definitions based on the field data type.
* Provides many methods to get/insert the created records, add/delete field definitions, get the errors, configure the amount of information returned during run-time (debug log) and more.
*	Has an extended error messaging system.
* Includes a Test Class with more than 300 test methods and a 99% test coverage.

The dx folder includes all Salesforce DX components.

This version fixes the method deleteFieldDefinitions (bug #74)