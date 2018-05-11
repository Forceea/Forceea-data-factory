# Forceea 1.3 #
Forceea (forˈsēa) is a data factory framework for Salesforce. The framework creates data using a descriptive language called Sample Data Definition Language (SDDL) to define the nature of the data.

Forceea was created with a double objective:
* Allow developers to easily create SObject records for any Test Method.
* Allow administrators to populate any Developer/Sandbox Org with SObject records for testing or demonstration purposes.

The following list describes the main capabilities of the framework. I encourage everyone to download the [User Guide](http://bit.ly/Forceea13_UserGuide), where you can find many examples and detailed information of the tools the framework offers. 
*	Creates records for standard or custom objects, for any standard or custom field.
*	Automatically definines the required fields.
*	Creates static or random data for fields of any data type: Integer, Currency, Double, Date, Datetime, Time, Boolean, String, TextArea, Percent, Reference, Email, Phone, URL, Base64 (BLOB), Picklist and MultiPicklist.
* Creates real random first and last names.
* Creates real random addresses with street, zip code, city, region/state and country.
* Creates serial data for date, datetime, integer, decimal, currency and percent.
* Can copy data from another field of the same record or a lookup record.
* Can create the same random data, using a pseudo-random number generator.
*	Handles record types and field dependencies (dependent picklists).
*	Supports record groups for inserting and deleting records.
*	Validates the definitions based on the field data type.
* Provides many methods to get/insert the created records, add/delete field definitions, get the errors, configure the amount of information returned during run-time (debug log) and more.
*	Has an extended error messaging system.
* Includes a Test Class with 320 test methods.

Download [Forceea Examples](http://bit.ly/Forceea13_Examples) to see some examples of creating data for many standard objects.