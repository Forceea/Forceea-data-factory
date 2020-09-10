### Attention to all Forceea users: the automated generation of required fields is deactivated by default in v2.2.0.

This was undocumented in User Guide v2, but is now documented in **User Guide v3**.

If you have any methods which use this feature, the methods will fail. If so, you have 2 options:
- Temporarily use `setRequiredFields(true)`
- Set the definitions of all required fields that are missing (Tip: let Forceea generate the field definitions and then copy these definitions and manually set any changes required).

<img alt="Forceea Logo"
       src="https://github.com/nmitrakis/Forceea/blob/master/Forceea-logo.PNG" width="400">
# Forceea 2.2.0

### What is Forceea?
Forceea (forsi:a) is the most sophisticated and powerful data factory for Salesforce, it's based on [Dadela](https://github.com/Forceea/Dadela) data generation language, and
* allows developers to easily create SObject records for test methods.
* facilitates administrators or business users to populate any org with SObject records for testing or demonstration purposes.

### How can you deploy it?
You can deploy Forceea with an unlocked package using this link for **Production/Developer** orgs:

<a href="https://nmitrakis.com/ForceeaInstallProduction">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/src/main/webapp/resources/img/deploy.png">
</a>

or this link for **Sandboxes**:

<a href="https://nmitrakis.com/ForceeaInstallTest">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/src/main/webapp/resources/img/deploy.png">
</a>
                                                                                                                       
You may also use the Salesforce CLI command
```
sfdx force:package:install -w 10 -b 10 -p 04t4I000000gVbJQAU -r -u <UsernameOrOrgAlias>
```

### What can Forceea do?
* Creates records for standard or custom SObjects, for any standard or custom field.
* Can insert/update records synchronously (for test methods) or insert/delete records asynchronously (for populating your org with millions of records).
* Has an easy way to define data.
* Automatically defines required fields.
* Can create data for fields of the data types: Integer, Currency, Double, Date, Datetime, Time, Boolean, String, TextArea, Percent, Reference, Email, Phone, URL, Base64, Picklist and MultiPicklist.
* Handles Record Types and field dependencies (dependent picklists).
* Supports record groups for inserting and deleting records.
* Uses DML Optimizer to reduce the number of insert statements with Templates.
* Supports variables and functions.
* Validates the definitions based on the field data type.
* Has an extended error messaging system.

### How can you find more information?
* Read the [User Guide](https://nmitrakis.com/Forceea-UserGuide)
* Visit [passion-for-salesforce.com](https://passionforsalesforce.com/forceea)
---

### Give you opinion about Forceea by completing this [Survey](https://www.surveymonkey.co.uk/r/M6BJMKT)
### Are you a Forceea user? Join our [LinkedIn](https://www.linkedin.com/groups/8943965) group!
