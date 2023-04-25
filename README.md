<img alt="Forceea Logo"
       src="https://github.com/nmitrakis/Forceea/blob/master/Forceea-logo.PNG" width="400">
       
> Read the [Forceea Success Guide](https://rebrand.ly/cgh14)

> Read [Forceea articles](https://www.acmantix.com/forceea)

# Forceea 2.8.0

### What is Forceea?

Forceea (forsi:a) is the most advanced and sophisticated native open-source data factory framework for Salesforce, powered by [Dadela](https://github.com/Forceea/Dadela) data generation language. The framework allows developers to easily create records for test methods and facilitates administrators or business users to populate any org with records for testing or demonstration purposes.

### Forceea Sponsors

<a href="https://www.acmantix.com">Acmantix</a> | 
<a href="https://organizer.solutions/gopro.html">Organizer</a>
       
### How can you deploy it?
      
You can deploy Forceea with an unlocked package using this link for **Production/Developer** orgs:

<a href="https://rebrand.ly/Forceea28Production">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/src/main/webapp/resources/img/deploy.png">
</a>

or this link for **Sandboxes**:

<a href="https://rebrand.ly/Forceea28Sandbox">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/src/main/webapp/resources/img/deploy.png">
</a>
                                                                                                                       
You may also use the Salesforce CLI command (recommended):
```
sfdx package install -w 10 -b 10 -p 04t4I0000011V6UQAU -r -o <UsernameOrOrgAlias>
```

### What can Forceea do?

* Inserts, updates and deletes records for standard or custom SObjects, synchronously (for test methods) or asynchronously (for populating your org with millions of records).
* Inserts, updates and deletes records for standard or custom Big Objects, synchronously or asynchronously.
* Supports all field data types of any standard or custom field.
* Supports Dadela data generation language for field definitions.
* Can automatically define the required fields.
* Handles Record Types and field dependencies (dependent picklists).
* Supports record groups for inserting, updating and deleting records.
* Provides Templates for constructing a DataFactory class that can be used for flexible data generation.
* Uses DML Optimizer to reduce the number of insert statements with Templates.
* Supports variables and functions.
* Validates the definitions based on the field data type.
* Has an extended error messaging system.
