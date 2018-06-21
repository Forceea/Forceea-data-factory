# Forceeapp #
Forceeapp (forˈsēap) uses asynchronous processes (Queueable Apex) to insert many thousands of records. It is a managed package (not open source) and is currently in development phase. Forceeapp is based on (what else?) Forceea for the creation of records, so the SDDL commands and defintions are (almost) the same. For the moment it doesn't have a UI, so you have to execute the code in an Anonymous Window - a Lightning component is under developement.

If you need to create many many thousands of records and you'd like to try Forceeapp, please send me an email to mitrakisn@gmail.com to provide you the details for the package installation.

Here is an example to clarify how Forceeapp works (with some comments):

```
// forceea is the namespace of the managed package
forceea.FObjectAsync obj = new forceea.FObjectAsync();

// for accounts use obj.objectName = 'Account' (object's API name)
obj.objectName = 'forceea__FObjectTwo__c'; 

// you may create millions of records, limited by your org's storage
obj.records = 200000;

// giving a seed, you always get the same results
obj.seed = 1;

// for the moment you have to manually give the number of records of each job execution (batch)
// depending on your org, first try 1000 (default) and then increase it up to 5000
obj.batchSize = 2000;

// the default value is 20, but you may give any value from 1 to 50
obj.jobs = 30;

// your SDDL definitions are the same definitions of Forceea, with some exceptions, for example source(forceea) should be converted to source(salesforce)
obj.setDefinition('TestText__c', 'static value(Test)');
obj.setDefinition('TestText__c', 'serial type(number) from(100001) step(1) scale(0)');
obj.setDefinition('TestDecimal__c', 'serial type(number) from(1) step(1) scale(0)');
// more definitions..

// and finally insert the records
obj.insertRecords();
```
