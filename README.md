<img alt="Forceea Logo"
       src="https://github.com/nmitrakis/Forceea/blob/master/Forceea-logo.PNG" width="400">
       
# Forceea 2.5.2

### What is Forceea?
Forceea (forsi:a) is a powerful data factory for Salesforce, it's based on [Dadela](https://github.com/Forceea/Dadela) data generation language, and
* allows developers to easily create SObject records for test methods.
* facilitates administrators or business users to populate any org with SObject or Big Object records for testing or demonstration purposes.

### Forceea Sponsors
<a href="http://www.acmantics.gr">
       <img src="https://drive.google.com/uc?export=view&id=1MfhGuNh6Dr5emTjREZl0o_F8aUQr4JA3" style="width: auto; height: auto"/>
<a href="http://cloudjedi.com">
       <img src="https://drive.google.com/uc?export=view&id=1N5ZHASB4Yu4fqIjulXnrWaCG4vF_SUmn" style="width: auto; height: auto"/>
<a href="https://www.netugroup.com/our-services/business-solutions/salesforce">
       <img src="https://drive.google.com/uc?export=view&id=1N21fjGxnDhwgcTG7hlPGbwyGJE8nnW6K" style="width: auto; height: auto"/>
<a href="https://organizer.solutions/gopro.html">
       <img src="https://drive.google.com/uc?export=view&id=1MqiScMbxT85xBMQ1xrTTAt5KT2maDYDy" style="width: auto; height: auto"/>
<a href="https://bit.ly/36DOqn0">
       <img src="https://drive.google.com/uc?export=view&id=1VnOJEMjTUk1TMuRtJPWUjKipZX4zN4gi" style="width: auto; height: auto"/>       
<a href="https://robinconsulting.gr">
       <img src="https://drive.google.com/uc?export=view&id=1N1gdPSeNe9QIS-g-uH3LiN92G8MGiQov" style="width: auto; height: auto"/>
       
### How can you deploy it?
You can deploy Forceea with an unlocked package using this link for **Production/Developer** orgs:

<a href="https://rebrand.ly/8g3jl">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/src/main/webapp/resources/img/deploy.png">
</a>

or this link for **Sandboxes**:

<a href="https://rebrand.ly/cxfgy">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/src/main/webapp/resources/img/deploy.png">
</a>
                                                                                                                       
You may also use the Salesforce CLI command
```
sfdx force:package:install -w 10 -b 10 -p 04t4I000000YtHJQA0 -r -u <UsernameOrOrgAlias>
```

### What can Forceea do?
* Inserts, updates and deletes records for standard or custom SObjects, synchronously (for test methods) or asynchronously (for populating your org with millions of records).
* Inserts, updates and deletes records for standard or custom Big Objects, synchronously or asynchronously.
* Supports all field data types of any standard or custom field.
* Supports Dadela data generation language for field definitions.
* Can automatically define the required fields.
* Handles Record Types and field dependencies (dependent picklists).
* Supports record groups for inserting and deleting records.
* Provides Templates for constructing a DataFactory class that can be used for flexible data generation.
* Uses DML Optimizer to reduce the number of insert statements with Templates.
* Supports variables and functions.
* Validates the definitions based on the field data type.
* Has an extended error messaging system.

### How can you find more information?
* Read [Forceea Success Guide](https://rebrand.ly/cgh14)
* Visit [forceea.com](https://www.forceea.com)
---

### Are you a Forceea user? Join our [LinkedIn](https://www.linkedin.com/groups/8943965) group!
#### Give you opinion about Forceea by completing this [Survey](https://www.surveymonkey.co.uk/r/M6BJMKT)
