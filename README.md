# Forceea 18.2 (v1.3.1) #
<a href="https://githubsfdeploy.herokuapp.com">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

If the "Deploy to Salesforce" tool doesn't work (returns an OAuth error), you can install the unmanaged [package 18.2](https://login.salesforce.com/packaging/installPackage.apexp?p0=04t580000003QlE).
<hr/>
Forceea (forsèa) is a data factory framework for Salesforce and it creates data using a descriptive language to define the "nature" of  data. The framework was created with a double objective:

* Allow developers to easily create SObject records for any Test Method.
* Allow administrators to populate any Developer/Sandbox Org with SObject records for testing or demonstration purposes.

The following list describes its main capabilities:
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

You can find many examples and detailed information of the tools the framework offers in the [User Guide](http://bit.ly/Forceea131_UserGuide) 

Download [Forceea Examples](http://bit.ly/Forceea131_Examples) to see some examples of creating data for variou standard objects.

Read the article [Populate your Salesforce org with data using Forceea and Salesforce CLI: a step-by-step guide](https://acmantics.com/2018/10/23/populate-your-salesforce-org-with-data-using-forceea-and-salesforce-cli)

Visit [acmantics.com](https://acmantics.com/forceea) to see all posted articles about Forceea.
