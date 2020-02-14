<img alt="Forceea Logo"
       src="https://github.com/nmitrakis/Forceea/blob/master/Forceea-logo.PNG">
# Forceea v1.3.1

### What is Forceea?
Forceea (forsèa) is a data factory framework for Salesforce, using the data generation language
 [Dadela](https://github.com/nmitrakis/Dadela).
 The framework was created with the following objectives:
* allow developers to easily create SObject records for any Test Method
* facilitate administrators to populate any Developer/Sandbox Org with SObject records for testing or demonstration purposes

### How can you deploy it?
You can deploy Forceea in your org with an unlocked package using this link:

<a href="https://nmitrakis.com/DeployForceea">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/src/main/webapp/resources/img/deploy.png"">
</a>
                                                                                                                       
**NOTE** If you deploy to a sandbox, replace `login.salesforce.com` with `test.salesforce.com`
                                                                                                                       
You may also use the Salesforce CLI command
```
sfdx force:package:install -w 10 -b 10 -p 04t4I000000kpOsQAI -r -u YourOrg
```

### What can Forceea do?
The following list describes framework's main capabilities:
* creates records for standard or custom objects, for any standard or custom field
* automatically definines the required fields
* creates static or random data for fields of any data type: Integer, Currency, Double,
Date, Datetime, Time, Boolean, String, TextArea, Percent, Reference, Email, Phone, URL, Base64 (BLOB), Picklist and MultiPicklist
* creates real random first and last names
* creates real random addresses with street, zip code, city, region/state and country
* creates serial data for date, datetime, integer, decimal, currency and percent
* can copy data from another field of the same record or a lookup record
* can create the same random data, using a pseudo-random number generator
* handles record types and field dependencies (dependent picklists)
* supports record groups for inserting and deleting records
* validates the definitions based on the field data type
* provides many methods to get/insert the created records, add/delete field definitions, get the errors,
configure the amount of information returned during run-time (debug log) and more
* includes an extended error messaging system

### How can you find more information?
To get familiar with Forceea, you can
* find details in the [User Guide](https://nmitrakis.com/Forceea131-user-guide) 
* see [examples](https://gist.github.com/nmitrakis/01ab40f74991ec9c61529bec3fcfa097) to find out how you can create data
for standard objects and custom objects
* read the article [How to create an Apex reusable Data Factory Library using Forceea Templates](https://passionforsalesforce.com/2019/08/26/how-to-create-an-apex-data-factory-library-using-forceea-templates/)
* read the article [Populate your Salesforce org with data using Forceea and Salesforce CLI: a step-by-step guide](https://passionforsalesforce.com/2018/10/23/populate-your-salesforce-org-with-data-using-forceea-and-salesforce-cli)
* visit [passion-for-salesforce.com](https://passionforsalesforce.com/forceea) to see all posted articles
---

### Give you opinion about Forceea by completing this [Survey](https://www.surveymonkey.co.uk/r/M6BJMKT)
