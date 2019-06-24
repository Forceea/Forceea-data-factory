### Give you opinion about Forceea by completing this [Survey](https://www.surveymonkey.co.uk/r/M6BJMKT)

# Forceea v1.3.1
<a href="https://githubsfdeploy.herokuapp.com">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

If the "Deploy to Salesforce" tool doesn't work (returns an OAuth error),
you can install the unmanaged [package 18.2](https://login.salesforce.com/packaging/installPackage.apexp?p0=04t580000003QlE).
<br/><br/>

Forceea (forsèa) is a data factory framework for Salesforce, using the data generation language
 [Dadela](https://github.com/nmitrakis/Dadela).
 The framework was created with the following objectives:

* allow developers to easily create SObject records for any Test Method
* facilitate administrators to populate any Developer/Sandbox Org with SObject records for testing or demonstration purposes

To get familiar with Forceea, you can
* find many examples and detailed information in the [User Guide](https://nmitrakis.com/Forceea131-user-guide) 
* download [Forceea Examples](https://passionforsalesforce.com/forceea-examples) to see how you can create data
for various standard objects
* read the article [Populate your Salesforce org with data using Forceea and Salesforce CLI:a step-by-step guide](https://passionforsalesforce.com/2018/10/23/populate-your-salesforce-org-with-data-using-forceea-and-salesforce-cli)
* visit [acmantics.com](https://passionforsalesforce.com/forceea) to see all posted articles

The following list describes its main capabilities:
*	creates records for standard or custom objects, for any standard or custom field
*	automatically definines the required fields
*	creates static or random data for fields of any data type: Integer, Currency, Double,
Date, Datetime, Time, Boolean, String, TextArea, Percent, Reference, Email, Phone, URL, Base64 (BLOB), Picklist and MultiPicklist
* creates real random first and last names
* creates real random addresses with street, zip code, city, region/state and country
* creates serial data for date, datetime, integer, decimal, currency and percent
* can copy data from another field of the same record or a lookup record
* can create the same random data, using a pseudo-random number generator
*	handles record types and field dependencies (dependent picklists)
*	supports record groups for inserting and deleting records
*	validates the definitions based on the field data type
* provides many methods to get/insert the created records, add/delete field definitions, get the errors,
configure the amount of information returned during run-time (debug log) and more
*	includes an extended error messaging system
