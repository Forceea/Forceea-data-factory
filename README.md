<img alt="Forceea Logo"
       src="https://github.com/nmitrakis/Forceea/blob/master/Forceea-logo.PNG" width="400">
# Forceea 2.0

### What is Forceea?
Forceea (forsi:a) is a data factory for Salesforce based on [Dadela](https://github.com/Forceea/Dadela) data generation language, and
* allows developers to easily create SObject records for test methods.
* facilitates administrators or business users to populate any org with SObject records for testing or demonstration purposes.

### How can you deploy it?
You can deploy Forceea with an unlocked package using this link for **Production/Developer** orgs:

<a href="https://nmitrakis.com/LoginInstallForceea200">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/src/main/webapp/resources/img/deploy.png"">
</a>

or this link for **Sandboxes**:

<a href="https://nmitrakis.com/TestInstallForceea200">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/src/main/webapp/resources/img/deploy.png"">
</a>
                                                                                                                       
You may also use the Salesforce CLI command
```
sfdx force:package:install -w 10 -b 10 -p 04t4I000000lF7VQAU -r -u YourOrgAlias
```

### What can Forceea do?
* Creates records for standard or custom SObjects, for any standard or custom field.
* Can insert/update records synchronously (for test methods) or insert/delete records asynchronously (for populating your org with millions of records).
* Has an easy way to define data.
* Automatically defines required fields.
* Can create data for fields of (almost) every data type: Integer, Currency, Double, Date, Datetime, Time, Boolean, String, TextArea, Percent, Reference, Email, Phone, URL, Base64, Picklist and MultiPicklist.
* Handles Record Types and field dependencies (dependent picklists).
* Supports record groups for inserting and deleting records.
* Validates the definitions based on the field data type.
* Has more than 50 static/instance methods.
* Has an extended error messaging system.

### How can you find more information?
* Read the [User Guide](https://nmitrakis.com/Forceea20-user-guide)
* Visit [passion-for-salesforce.com](https://passionforsalesforce.com/forceea)
---

### Give you opinion about Forceea by completing this [Survey](https://www.surveymonkey.co.uk/r/M6BJMKT)
