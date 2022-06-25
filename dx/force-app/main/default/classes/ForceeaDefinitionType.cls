/*
  Forceea data factory (v2.5)
  Copyright (C) 2022 Nikos Mitrakis

  This program is free software: you can redistribute it and/or modify it under the terms
  of the GNU General Public License as published by the Free Software Foundation,
  either version 3 of the License, or any later version.

  This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
  without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  See the GNU General Public License for more details.

  You can find a copy of the GNU General Public License at
  https://github.com/Forceea/Forceea-data-factory/blob/master/LICENSE
*/
/**
 * @description A template for a valid definition.
 */
public with sharing class ForceeaDefinitionType {

    /* COLLECTIONS */

    public List<Forceea.ClusterType> clusterTypes = new List<Forceea.ClusterType>();

    /* VARIABLES & PROPERTIES */

    public ForceeaService.DefinitionTypeId id { get; set; } // e.g. RANDOM_STREET
    public String description { get; set; } // e.g. RandomStreet
    public String command { get; set; } // e.g. random

    /* CONSTRUCTORS */

    public ForceeaDefinitionType(ForceeaService.DefinitionTypeId id, String description, String command) {
        this.id = id;
        this.description = description;
        this.command = command;
    }

    public ForceeaDefinitionType() {
        this.id = null;
        this.description = null;
        this.command = null;
    }

    /* METHODS */

    /**
    * @description Declares all definition types.
    */
    public static void setDefinitionTypes() {
        ForceeaDefinitionType.setDefinitionTypesOfStatic();
        ForceeaDefinitionType.setDefinitionTypesOfRandomText();
        ForceeaDefinitionType.setDefinitionTypesOfSerial();
        ForceeaDefinitionType.setDefinitionTypesOfSerialLookup();
        ForceeaDefinitionType.setDefinitionTypesOfRandomList();
        ForceeaDefinitionType.setDefinitionTypesOfMock();
        ForceeaDefinitionType.setDefinitionTypesOfRandomLookup();
        ForceeaDefinitionType.setDefinitionTypesOfRandomPrimitives();
        ForceeaDefinitionType.setDefinitionTypesOfRandomPicklist();
        ForceeaDefinitionType.setDefinitionTypesOfRandomDetails();
        ForceeaDefinitionType.setDefinitionTypesOfCopy();
        ForceeaDefinitionType.setDefinitionTypesOfFunction();
        ForceeaDefinitionType.setDefinitionTypesOfRandomNames();
        ForceeaDefinitionType.setDefinitionTypesOfRandomAddress();
        ForceeaDefinitionType.setDefinitionTypesOfStaticLookup();
    }

    /**
     * @description Sets the definition types of copy.
     */
    private static void setDefinitionTypesOfCopy() {
        ForceeaDefinitionType dt = new ForceeaDefinitionType();

        // example: copy field(Rating)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.COPY_FIELD, 'CopyField', ForceeaService.COMMAND_COPY);
        dt.clusterTypes.add(new Forceea.ClusterType('field', ForceeaService.ValueType.TYPE_STRING, null, false));
        FObject.definitionTypes.add(dt);

        // example: copy field(AccountId) from(Account.Rating)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.COPY_LOOKUP, 'CopyLookupField', ForceeaService.COMMAND_COPY);
        dt.clusterTypes.add(new Forceea.ClusterType('field', ForceeaService.ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('from', ForceeaService.ValueType.TYPE_STRING, null, false));
        FObject.definitionTypes.add(dt);
    }

    /**
     * @description Sets the definition types of function.
     */
    private static void setDefinitionTypesOfFunction() {
        ForceeaDefinitionType dt = new ForceeaDefinitionType();

        // example: function-add type(number) field(MyField)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.FUNCTION_ADD, 'FunctionAdd', ForceeaService.COMMAND_FUNCTION_ADD);
        dt.clusterTypes.add(new Forceea.ClusterType('field', ForceeaService.ValueType.TYPE_STRING, null, false));
        FObject.definitionTypes.add(dt);

        // example: function-convert to(lower)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.FUNCTION_CONVERT, 'FunctionConvert', ForceeaService.COMMAND_FUNCTION_CONVERT);
        dt.clusterTypes.add(new Forceea.ClusterType('to', ForceeaService.ValueType.TYPE_STRING, null, false));
        FObject.definitionTypes.add(dt);
    }

    /**
     * @description Sets the definition types of mocking.
     */
    private static void setDefinitionTypesOfMock() {
        ForceeaDefinitionType dt = new ForceeaDefinitionType();

        // example: mock type(id)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.MOCK_ID, 'MockId', 'mock');
        dt.clusterTypes.add(new Forceea.ClusterType('type', ForceeaService.ValueType.TYPE_STRING, null, false));
        FObject.definitionTypes.add(dt);
    }

    /**
     * @description Sets the definition types of random addresses.
     */
    private static void setDefinitionTypesOfRandomAddress() {
        ForceeaDefinitionType dt = new ForceeaDefinitionType();

        // example: random type(street) group(billing)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.RANDOM_STREET, 'RandomStreet', ForceeaService.COMMAND_RANDOM);
        dt.clusterTypes.add(new Forceea.ClusterType('type', ForceeaService.ValueType.TYPE_STRING, 'street', false));
        dt.clusterTypes.add(new Forceea.ClusterType('group', ForceeaService.ValueType.TYPE_STRING, null, false));
        FObject.definitionTypes.add(dt);

        // example: random type(postalCode) group(billing)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.RANDOM_POSTALCODE, 'RandomPostalCode', ForceeaService.COMMAND_RANDOM);
        dt.clusterTypes.add(new Forceea.ClusterType('type', ForceeaService.ValueType.TYPE_STRING, 'postalcode', false));
        dt.clusterTypes.add(new Forceea.ClusterType('group', ForceeaService.ValueType.TYPE_STRING, null, false));
        FObject.definitionTypes.add(dt);

        // example: random type(city) group(billing)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.RANDOM_CITY, 'RandomCity', ForceeaService.COMMAND_RANDOM);
        dt.clusterTypes.add(new Forceea.ClusterType('type', ForceeaService.ValueType.TYPE_STRING, 'city', false));
        dt.clusterTypes.add(new Forceea.ClusterType('group', ForceeaService.ValueType.TYPE_STRING, null, false));
        FObject.definitionTypes.add(dt);

        // example: random type(state) group(billing)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.RANDOM_STATE, 'RandomState', ForceeaService.COMMAND_RANDOM);
        dt.clusterTypes.add(new Forceea.ClusterType('type', ForceeaService.ValueType.TYPE_STRING, 'state', false));
        dt.clusterTypes.add(new Forceea.ClusterType('group', ForceeaService.ValueType.TYPE_STRING, null, false));
        FObject.definitionTypes.add(dt);

        // example: random type(country) group(billing)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.RANDOM_COUNTRY, 'RandomCountry', ForceeaService.COMMAND_RANDOM);
        dt.clusterTypes.add(new Forceea.ClusterType('type', ForceeaService.ValueType.TYPE_STRING, 'country', false));
        dt.clusterTypes.add(new Forceea.ClusterType('group', ForceeaService.ValueType.TYPE_STRING, null, false));
        FObject.definitionTypes.add(dt);
    }

    /**
     * @description Sets the definition types of random details.
     */
    private static void setDefinitionTypesOfRandomDetails() {
        ForceeaDefinitionType dt = new ForceeaDefinitionType();

        // example: random type(email)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.RANDOM_EMAIL, 'RandomEmail', ForceeaService.COMMAND_RANDOM);
        dt.clusterTypes.add(new Forceea.ClusterType('type', ForceeaService.ValueType.TYPE_STRING, 'email', false));
        FObject.definitionTypes.add(dt);

        // example: random type(url)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.RANDOM_URL, 'RandomUrl', ForceeaService.COMMAND_RANDOM);
        dt.clusterTypes.add(new Forceea.ClusterType('type', ForceeaService.ValueType.TYPE_STRING, 'url', false));
        FObject.definitionTypes.add(dt);

        // example: random type(phone) format("(353) dd dd ddd")
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.RANDOM_PHONE, 'RandomPhone', ForceeaService.COMMAND_RANDOM);
        dt.clusterTypes.add(new Forceea.ClusterType('type', ForceeaService.ValueType.TYPE_STRING, 'phone', false));
        dt.clusterTypes.add(new Forceea.ClusterType('format', ForceeaService.ValueType.TYPE_STRING, null, false));
        FObject.definitionTypes.add(dt);
    }

    /**
     * @description Sets the definition types of random lists.
     */
    private static void setDefinitionTypesOfRandomList() {
        ForceeaDefinitionType dt = new ForceeaDefinitionType();

        // example: random type(list) value(1, 2, 3)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.RANDOM_LIST_INTEGER, 'RandomListInteger', ForceeaService.COMMAND_RANDOM);
        dt.clusterTypes.add(new Forceea.ClusterType('type', ForceeaService.ValueType.TYPE_STRING, 'list', false));
        dt.clusterTypes.add(new Forceea.ClusterType('value', ForceeaService.ValueType.TYPE_INTEGER, null, true));
        FObject.definitionTypes.add(dt);

        // example: random type(list) value(1.1, 2.2, 3.3)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.RANDOM_LIST_DECIMAL, 'RandomListDecimal', ForceeaService.COMMAND_RANDOM);
        dt.clusterTypes.add(new Forceea.ClusterType('type', ForceeaService.ValueType.TYPE_STRING, 'list', false));
        dt.clusterTypes.add(new Forceea.ClusterType('value', ForceeaService.ValueType.TYPE_DECIMAL, null, true));
        FObject.definitionTypes.add(dt);

        // example: random type(list) value(2017-1-1 01:01:01, 2017-2-2 02:02:02, 2017-3-3 03:03:03)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.RANDOM_LIST_DATETIME, 'RandomListDatetime', ForceeaService.COMMAND_RANDOM);
        dt.clusterTypes.add(new Forceea.ClusterType('type', ForceeaService.ValueType.TYPE_STRING, 'list', false));
        dt.clusterTypes.add(new Forceea.ClusterType('value', ForceeaService.ValueType.TYPE_DATETIME, null, true));
        FObject.definitionTypes.add(dt);

        // example: random type(list) value(01:01:01, 02:02:02, 03:03:03)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.RANDOM_LIST_TIME, 'RandomListTime', ForceeaService.COMMAND_RANDOM);
        dt.clusterTypes.add(new Forceea.ClusterType('type', ForceeaService.ValueType.TYPE_STRING, 'list', false));
        dt.clusterTypes.add(new Forceea.ClusterType('value', ForceeaService.ValueType.TYPE_TIME, null, true));
        FObject.definitionTypes.add(dt);

        // example: random type(list) value(2017-1-1, 2017-2-2, 2017-3-3)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.RANDOM_LIST_DATE, 'RandomListDate', ForceeaService.COMMAND_RANDOM);
        dt.clusterTypes.add(new Forceea.ClusterType('type', ForceeaService.ValueType.TYPE_STRING, 'list', false));
        dt.clusterTypes.add(new Forceea.ClusterType('value', ForceeaService.ValueType.TYPE_DATE, null, true));
        FObject.definitionTypes.add(dt);

        // example: random type(list) value(One, Two, Three)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.RANDOM_LIST_STRING, 'RandomListString', ForceeaService.COMMAND_RANDOM);
        dt.clusterTypes.add(new Forceea.ClusterType('type', ForceeaService.ValueType.TYPE_STRING, 'list', false));
        dt.clusterTypes.add(new Forceea.ClusterType('value', ForceeaService.ValueType.TYPE_STRING, null, true));
        FObject.definitionTypes.add(dt);
    }

    /**
     * @description Sets the definition types of random lookups.
     */
    private static void setDefinitionTypesOfRandomLookup() {
        ForceeaDefinitionType dt = new ForceeaDefinitionType();

        // example: random lookup(Account) source(forceea)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.RANDOM_LOOKUP, 'RandomLookup', ForceeaService.COMMAND_RANDOM);
        dt.clusterTypes.add(new Forceea.ClusterType('lookup', ForceeaService.ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('source', ForceeaService.ValueType.TYPE_STRING, null, false));
        FObject.definitionTypes.add(dt);

        // example: random lookup(Account) group(one) source(forceea)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.RANDOM_LOOKUP, 'RandomLookupGroup', ForceeaService.COMMAND_RANDOM);
        dt.clusterTypes.add(new Forceea.ClusterType('lookup', ForceeaService.ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('group', ForceeaService.ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('source', ForceeaService.ValueType.TYPE_STRING, 'forceea', false));
        FObject.definitionTypes.add(dt);

        // example: random lookup(Account) field(Name) value(Company XYZ) source(forceea)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.RANDOM_LOOKUP, 'RandomLookupField', ForceeaService.COMMAND_RANDOM);
        dt.clusterTypes.add(new Forceea.ClusterType('lookup', ForceeaService.ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('field', ForceeaService.ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('value', ForceeaService.ValueType.TYPE_STRING, null, true));
        dt.clusterTypes.add(new Forceea.ClusterType('source', ForceeaService.ValueType.TYPE_STRING, null, false));
        FObject.definitionTypes.add(dt);

        // example: random lookup(Account) field(Name) value(Company XYZ) group(one) source(forceea)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.RANDOM_LOOKUP, 'RandomLookupFieldGroup', ForceeaService.COMMAND_RANDOM);
        dt.clusterTypes.add(new Forceea.ClusterType('lookup', ForceeaService.ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('field', ForceeaService.ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('value', ForceeaService.ValueType.TYPE_STRING, null, true));
        dt.clusterTypes.add(new Forceea.ClusterType('group', ForceeaService.ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('source', ForceeaService.ValueType.TYPE_STRING, 'forceea', false));
        FObject.definitionTypes.add(dt);

        // example: random lookup(Account) field(Name) except(Company XYZ) source(salesforce)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.RANDOM_LOOKUP, 'RandomLookupFieldExcept', ForceeaService.COMMAND_RANDOM);
        dt.clusterTypes.add(new Forceea.ClusterType('lookup', ForceeaService.ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('field', ForceeaService.ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('except', ForceeaService.ValueType.TYPE_STRING, null, true));
        dt.clusterTypes.add(new Forceea.ClusterType('source', ForceeaService.ValueType.TYPE_STRING, null, false));
        FObject.definitionTypes.add(dt);

        // example: random lookup(Account) field(Name) except(Company XYZ) group(one) source(forceea)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.RANDOM_LOOKUP, 'RandomLookupFieldExceptGroup', ForceeaService.COMMAND_RANDOM);
        dt.clusterTypes.add(new Forceea.ClusterType('lookup', ForceeaService.ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('field', ForceeaService.ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('except', ForceeaService.ValueType.TYPE_STRING, null, true));
        dt.clusterTypes.add(new Forceea.ClusterType('group', ForceeaService.ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('source', ForceeaService.ValueType.TYPE_STRING, 'forceea', false));
        FObject.definitionTypes.add(dt);

        // example: random lookup(Account) where(Rating = 'Hot') source(salesforce)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.RANDOM_LOOKUP_WHERE, 'RandomLookupWhereSalesforce', ForceeaService.COMMAND_RANDOM);
        dt.clusterTypes.add(new Forceea.ClusterType('lookup', ForceeaService.ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('where', ForceeaService.ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('source', ForceeaService.ValueType.TYPE_STRING, 'salesforce', false));
        FObject.definitionTypes.add(dt);
    }

    /**
     * @description Sets the definition types of random names.
     */
    private static void setDefinitionTypesOfRandomNames() {
        ForceeaDefinitionType dt = new ForceeaDefinitionType();

        // example: random type(firstname) group(billing)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.RANDOM_FIRSTNAME, 'RandomFirstName', ForceeaService.COMMAND_RANDOM);
        dt.clusterTypes.add(new Forceea.ClusterType('type', ForceeaService.ValueType.TYPE_STRING, 'firstname', false));
        dt.clusterTypes.add(new Forceea.ClusterType('group', ForceeaService.ValueType.TYPE_STRING, null, false));
        FObject.definitionTypes.add(dt);

        // example: random type(lastname) group(billing)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.RANDOM_LASTNAME, 'RandomLastName', ForceeaService.COMMAND_RANDOM);
        dt.clusterTypes.add(new Forceea.ClusterType('type', ForceeaService.ValueType.TYPE_STRING, 'lastname', false));
        dt.clusterTypes.add(new Forceea.ClusterType('group', ForceeaService.ValueType.TYPE_STRING, null, false));
        FObject.definitionTypes.add(dt);
    }

    /**
     * @description Sets the definition types of random primitives.
     */
    private static void setDefinitionTypesOfRandomPrimitives() {
        ForceeaDefinitionType dt = new ForceeaDefinitionType();

        // example: random type(boolean)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.RANDOM_BOOLEAN, 'RandomBoolean', ForceeaService.COMMAND_RANDOM);
        dt.clusterTypes.add(new Forceea.ClusterType('type', ForceeaService.ValueType.TYPE_STRING, 'boolean', false));
        FObject.definitionTypes.add(dt);

        // example: random type(number) from(10) to(100) scale(0)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.RANDOM_NUMBER, 'RandomNumber', ForceeaService.COMMAND_RANDOM);
        dt.clusterTypes.add(new Forceea.ClusterType('type', ForceeaService.ValueType.TYPE_STRING, 'number', false));
        dt.clusterTypes.add(new Forceea.ClusterType('from', ForceeaService.ValueType.TYPE_DECIMAL, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('to', ForceeaService.ValueType.TYPE_DECIMAL, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('scale', ForceeaService.ValueType.TYPE_INTEGER, null, false));
        FObject.definitionTypes.add(dt);

        // example: random type(date) from(2010-01-01) to(2015-12-31)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.RANDOM_DATE, 'RandomDate', ForceeaService.COMMAND_RANDOM);
        dt.clusterTypes.add(new Forceea.ClusterType('type', ForceeaService.ValueType.TYPE_STRING, 'date', false));
        dt.clusterTypes.add(new Forceea.ClusterType('from', ForceeaService.ValueType.TYPE_DATE, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('to', ForceeaService.ValueType.TYPE_DATE, null, false));
        FObject.definitionTypes.add(dt);

        // example: random type(datetime) from(2010-01-01) to(2015-12-31)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.RANDOM_DATETIME, 'RandomDatetimeDateDate', ForceeaService.COMMAND_RANDOM);
        dt.clusterTypes.add(new Forceea.ClusterType('type', ForceeaService.ValueType.TYPE_STRING, 'datetime', false));
        dt.clusterTypes.add(new Forceea.ClusterType('from', ForceeaService.ValueType.TYPE_DATE, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('to', ForceeaService.ValueType.TYPE_DATE, null, false));
        FObject.definitionTypes.add(dt);

        // example: random type(datetime) from(2010-01-01) to(2015-12-31 01:01:01)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.RANDOM_DATETIME, 'RandomDatetimeDateDatetime', ForceeaService.COMMAND_RANDOM);
        dt.clusterTypes.add(new Forceea.ClusterType('type', ForceeaService.ValueType.TYPE_STRING, 'datetime', false));
        dt.clusterTypes.add(new Forceea.ClusterType('from', ForceeaService.ValueType.TYPE_DATE, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('to', ForceeaService.ValueType.TYPE_DATETIME, null, false));
        FObject.definitionTypes.add(dt);

        // example: random type(datetime) from(2010-01-01 01:01:01) to(2015-12-31 01:01:01)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.RANDOM_DATETIME, 'RandomDatetimeDatetimeDate', ForceeaService.COMMAND_RANDOM);
        dt.clusterTypes.add(new Forceea.ClusterType('type', ForceeaService.ValueType.TYPE_STRING, 'datetime', false));
        dt.clusterTypes.add(new Forceea.ClusterType('from', ForceeaService.ValueType.TYPE_DATETIME, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('to', ForceeaService.ValueType.TYPE_DATE, null, false));
        FObject.definitionTypes.add(dt);

        // example: random type(datetime) from(2010-01-01 01:01:01) to(2015-12-31)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.RANDOM_DATETIME, 'RandomDatetimeDatetimeDatetime', ForceeaService.COMMAND_RANDOM);
        dt.clusterTypes.add(new Forceea.ClusterType('type', ForceeaService.ValueType.TYPE_STRING, 'datetime', false));
        dt.clusterTypes.add(new Forceea.ClusterType('from', ForceeaService.ValueType.TYPE_DATETIME, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('to', ForceeaService.ValueType.TYPE_DATETIME, null, false));
        FObject.definitionTypes.add(dt);

        // example: random type(time) from(01:01:01) to(12:01:01)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.RANDOM_TIME, 'RandomTime', ForceeaService.COMMAND_RANDOM);
        dt.clusterTypes.add(new Forceea.ClusterType('type', ForceeaService.ValueType.TYPE_STRING, 'time', false));
        dt.clusterTypes.add(new Forceea.ClusterType('from', ForceeaService.ValueType.TYPE_TIME, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('to', ForceeaService.ValueType.TYPE_TIME, null, false));
        FObject.definitionTypes.add(dt);
    }

    /**
     * @description Sets the definition types of random picklists.
     */
    private static void setDefinitionTypesOfRandomPicklist() {
        ForceeaDefinitionType dt = new ForceeaDefinitionType();

        // example: random type(picklist)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.RANDOM_PICKLIST, 'RandomPicklist', ForceeaService.COMMAND_RANDOM);
        dt.clusterTypes.add(new Forceea.ClusterType('type', ForceeaService.ValueType.TYPE_STRING, 'picklist', false));
        FObject.definitionTypes.add(dt);

        // example: random type(picklist) except(a,b,c)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.RANDOM_PICKLIST_EXCEPT, 'RandomPicklistExcept', ForceeaService.COMMAND_RANDOM);
        dt.clusterTypes.add(new Forceea.ClusterType('type', ForceeaService.ValueType.TYPE_STRING, 'picklist', false));
        dt.clusterTypes.add(new Forceea.ClusterType('except', ForceeaService.ValueType.TYPE_STRING, null, true));
        FObject.definitionTypes.add(dt);
    }

    /**
     * @description Sets the definition types of random texts.
     */
    private static void setDefinitionTypesOfRandomText() {
        ForceeaDefinitionType dt = new ForceeaDefinitionType();

        // example: random type(string)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.RANDOM_STRING, 'RandomString', ForceeaService.COMMAND_RANDOM);
        dt.clusterTypes.add(new Forceea.ClusterType('type', ForceeaService.ValueType.TYPE_STRING, 'string', false));
        dt.clusterTypes.add(new Forceea.ClusterType('minlength', ForceeaService.ValueType.TYPE_INTEGER, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('maxlength', ForceeaService.ValueType.TYPE_INTEGER, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('startwith', ForceeaService.ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('include', ForceeaService.ValueType.TYPE_STRING, null, true));
        FObject.definitionTypes.add(dt);

        // example: random type(text) minlength(20) maxlength(40)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.RANDOM_TEXT, 'RandomText', ForceeaService.COMMAND_RANDOM);
        dt.clusterTypes.add(new Forceea.ClusterType('type', ForceeaService.ValueType.TYPE_STRING, 'text', false));
        dt.clusterTypes.add(new Forceea.ClusterType('minlength', ForceeaService.ValueType.TYPE_INTEGER, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('maxlength', ForceeaService.ValueType.TYPE_INTEGER, null, false));
        FObject.definitionTypes.add(dt);
    }

    /**
     * @description Sets the definition types of serials.
     */
    private static void setDefinitionTypesOfSerial() {
        ForceeaDefinitionType dt = new ForceeaDefinitionType();

        // example: serial type(number) from(10.2) step(1.2) scale(2)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.SERIAL_NUMBER, 'SerialNumber', 'serial');
        dt.clusterTypes.add(new Forceea.ClusterType('type', ForceeaService.ValueType.TYPE_STRING, 'number', false));
        dt.clusterTypes.add(new Forceea.ClusterType('from', ForceeaService.ValueType.TYPE_DECIMAL, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('step', ForceeaService.ValueType.TYPE_DECIMAL, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('scale', ForceeaService.ValueType.TYPE_INTEGER, null, false));
        FObject.definitionTypes.add(dt);

        // example: serial type(date) from(2017-01-01) step(1)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.SERIAL_DATE, 'SerialDate', 'serial');
        dt.clusterTypes.add(new Forceea.ClusterType('type', ForceeaService.ValueType.TYPE_STRING, 'date', false));
        dt.clusterTypes.add(new Forceea.ClusterType('from', ForceeaService.ValueType.TYPE_DATE, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('step', ForceeaService.ValueType.TYPE_INTEGER, null, false));
        FObject.definitionTypes.add(dt);

        // example: serial type(datetime) from(2017-01-01) step(1.2)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.SERIAL_DATETIME, 'SerialDatetimeFromDate', 'serial');
        dt.clusterTypes.add(new Forceea.ClusterType('type', ForceeaService.ValueType.TYPE_STRING, 'datetime', false));
        dt.clusterTypes.add(new Forceea.ClusterType('from', ForceeaService.ValueType.TYPE_DATE, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('step', ForceeaService.ValueType.TYPE_DECIMAL, null, false));
        FObject.definitionTypes.add(dt);

        // example: serial type(datetime) from(2017-01-01 01:01:01) step(1.2)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.SERIAL_DATETIME, 'SerialDatetimeFromDatetime', 'serial');
        dt.clusterTypes.add(new Forceea.ClusterType('type', ForceeaService.ValueType.TYPE_STRING, 'datetime', false));
        dt.clusterTypes.add(new Forceea.ClusterType('from', ForceeaService.ValueType.TYPE_DATETIME, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('step', ForceeaService.ValueType.TYPE_DECIMAL, null, false));
        FObject.definitionTypes.add(dt);

        // example: serial type(picklist) mode(cyclical)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.SERIAL_PICKLIST, 'SerialPicklist', 'serial');
        dt.clusterTypes.add(new Forceea.ClusterType('type', ForceeaService.ValueType.TYPE_STRING, 'picklist', false));
        dt.clusterTypes.add(new Forceea.ClusterType('mode', ForceeaService.ValueType.TYPE_STRING, null, false));
        FObject.definitionTypes.add(dt);

        // example: serial type(picklist) except(one) mode(cyclical)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.SERIAL_PICKLIST, 'SerialPicklistExcept', 'serial');
        dt.clusterTypes.add(new Forceea.ClusterType('type', ForceeaService.ValueType.TYPE_STRING, 'picklist', false));
        dt.clusterTypes.add(new Forceea.ClusterType('except', ForceeaService.ValueType.TYPE_STRING, null, true));
        dt.clusterTypes.add(new Forceea.ClusterType('mode', ForceeaService.ValueType.TYPE_STRING, null, false));
        FObject.definitionTypes.add(dt);

        // example: serial type(list) value(1,2,3) mode(cyclical)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.SERIAL_LIST_INTEGER, 'SerialListInteger', 'serial');
        dt.clusterTypes.add(new Forceea.ClusterType('type', ForceeaService.ValueType.TYPE_STRING, 'list', false));
        dt.clusterTypes.add(new Forceea.ClusterType('value', ForceeaService.ValueType.TYPE_INTEGER, null, true));
        dt.clusterTypes.add(new Forceea.ClusterType('mode', ForceeaService.ValueType.TYPE_STRING, null, false));
        FObject.definitionTypes.add(dt);

        // example: serial type(list) value(1,2.2,3.3) mode(cyclical)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.SERIAL_LIST_DECIMAL, 'SerialListDecimal', 'serial');
        dt.clusterTypes.add(new Forceea.ClusterType('type', ForceeaService.ValueType.TYPE_STRING, 'list', false));
        dt.clusterTypes.add(new Forceea.ClusterType('value', ForceeaService.ValueType.TYPE_DECIMAL, null, true));
        dt.clusterTypes.add(new Forceea.ClusterType('mode', ForceeaService.ValueType.TYPE_STRING, null, false));
        FObject.definitionTypes.add(dt);

        // IMPORTANT: The SERIAL_LIST_DATETIME should be before SERIAL_LIST_DATE

        // example: serial type(list) value(2020-01-01 01:02:03,2020-03-01 01:02:03,2020-02-01 01:02:03) mode(cyclical)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.SERIAL_LIST_DATETIME, 'SerialListDatetime', 'serial');
        dt.clusterTypes.add(new Forceea.ClusterType('type', ForceeaService.ValueType.TYPE_STRING, 'list', false));
        dt.clusterTypes.add(new Forceea.ClusterType('value', ForceeaService.ValueType.TYPE_DATETIME, null, true));
        dt.clusterTypes.add(new Forceea.ClusterType('mode', ForceeaService.ValueType.TYPE_STRING, null, false));
        FObject.definitionTypes.add(dt);

        // example: serial type(list) value(2020-01-01,2020-03-01,2020-02-01) mode(cyclical)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.SERIAL_LIST_DATE, 'SerialListDate', 'serial');
        dt.clusterTypes.add(new Forceea.ClusterType('type', ForceeaService.ValueType.TYPE_STRING, 'list', false));
        dt.clusterTypes.add(new Forceea.ClusterType('value', ForceeaService.ValueType.TYPE_DATE, null, true));
        dt.clusterTypes.add(new Forceea.ClusterType('mode', ForceeaService.ValueType.TYPE_STRING, null, false));
        FObject.definitionTypes.add(dt);

        // example: serial type(list) value(01:01:01,02:02:02,03:03:03) mode(cyclical)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.SERIAL_LIST_TIME, 'SerialListTime', 'serial');
        dt.clusterTypes.add(new Forceea.ClusterType('type', ForceeaService.ValueType.TYPE_STRING, 'list', false));
        dt.clusterTypes.add(new Forceea.ClusterType('value', ForceeaService.ValueType.TYPE_TIME, null, true));
        dt.clusterTypes.add(new Forceea.ClusterType('mode', ForceeaService.ValueType.TYPE_STRING, null, false));
        FObject.definitionTypes.add(dt);

        // example: serial type(list) value(a,b,c) mode(cyclical)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.SERIAL_LIST_STRING, 'SerialListString', 'serial');
        dt.clusterTypes.add(new Forceea.ClusterType('type', ForceeaService.ValueType.TYPE_STRING, 'list', false));
        dt.clusterTypes.add(new Forceea.ClusterType('value', ForceeaService.ValueType.TYPE_STRING, null, true));
        dt.clusterTypes.add(new Forceea.ClusterType('mode', ForceeaService.ValueType.TYPE_STRING, null, false));
        FObject.definitionTypes.add(dt);
    }

    /**
     * @description Sets the definition types of serial lookups.
     */
    private static void setDefinitionTypesOfSerialLookup() {
        ForceeaDefinitionType dt = new ForceeaDefinitionType();

        // example: serial lookup(Account) mode(cyclical) source(salesforce)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.SERIAL_LOOKUP, 'SerialLookup', 'serial');
        dt.clusterTypes.add(new Forceea.ClusterType('lookup', ForceeaService.ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('mode', ForceeaService.ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('source', ForceeaService.ValueType.TYPE_STRING, null, false));
        FObject.definitionTypes.add(dt);

        // example: serial lookup(Account) mode(cyclical) group(one) source(forceea)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.SERIAL_LOOKUP, 'SerialLookupGroup', 'serial');
        dt.clusterTypes.add(new Forceea.ClusterType('lookup', ForceeaService.ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('mode', ForceeaService.ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('group', ForceeaService.ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('source', ForceeaService.ValueType.TYPE_STRING, 'forceea', false));
        FObject.definitionTypes.add(dt);

        // example: serial lookup(Account) field(Industry) value(Services,Banking) mode(permutation) source(salesforce)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.SERIAL_LOOKUP, 'SerialLookupField', 'serial');
        dt.clusterTypes.add(new Forceea.ClusterType('lookup', ForceeaService.ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('field', ForceeaService.ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('value', ForceeaService.ValueType.TYPE_STRING, null, true));
        dt.clusterTypes.add(new Forceea.ClusterType('mode', ForceeaService.ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('source', ForceeaService.ValueType.TYPE_STRING, null, false));
        FObject.definitionTypes.add(dt);

        // example: serial lookup(Account) field(Industry) value(Services,Banking) mode(permutation) group(one) source(forceea)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.SERIAL_LOOKUP, 'SerialLookupFieldGroup', 'serial');
        dt.clusterTypes.add(new Forceea.ClusterType('lookup', ForceeaService.ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('field', ForceeaService.ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('value', ForceeaService.ValueType.TYPE_STRING, null, true));
        dt.clusterTypes.add(new Forceea.ClusterType('mode', ForceeaService.ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('group', ForceeaService.ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('source', ForceeaService.ValueType.TYPE_STRING, 'forceea', false));
        FObject.definitionTypes.add(dt);

        // example: serial lookup(Account) field(Industry) except(Services,Banking) mode(permutation) source(salesforce)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.SERIAL_LOOKUP, 'SerialLookupFieldExcept', 'serial');
        dt.clusterTypes.add(new Forceea.ClusterType('lookup', ForceeaService.ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('field', ForceeaService.ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('except', ForceeaService.ValueType.TYPE_STRING, null, true));
        dt.clusterTypes.add(new Forceea.ClusterType('mode', ForceeaService.ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('source', ForceeaService.ValueType.TYPE_STRING, null, false));
        FObject.definitionTypes.add(dt);

        // example: serial lookup(Account) field(Industry) except(Services,Banking) mode(permutation) group(one) source(salesforce)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.SERIAL_LOOKUP, 'SerialLookupFieldExceptGroup', 'serial');
        dt.clusterTypes.add(new Forceea.ClusterType('lookup', ForceeaService.ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('field', ForceeaService.ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('except', ForceeaService.ValueType.TYPE_STRING, null, true));
        dt.clusterTypes.add(new Forceea.ClusterType('mode', ForceeaService.ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('group', ForceeaService.ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('source', ForceeaService.ValueType.TYPE_STRING, 'forceea', false));
        FObject.definitionTypes.add(dt);

        // example: serial lookup(Account) where(Industry = \'Services\' mode(cyclical) source(salesforce)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.SERIAL_LOOKUP, 'SerialLookupWhere', 'serial');
        dt.clusterTypes.add(new Forceea.ClusterType('lookup', ForceeaService.ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('where', ForceeaService.ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('mode', ForceeaService.ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('source', ForceeaService.ValueType.TYPE_STRING, 'salesforce', false));
        FObject.definitionTypes.add(dt);
    }

    /**
     * @description Sets the definition types of statics.
     */
    private static void setDefinitionTypesOfStatic() {
        ForceeaDefinitionType dt = new ForceeaDefinitionType();

        // example: static value("")
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.STATIC_BLANK, 'StaticBlank', ForceeaService.COMMAND_STATIC);
        dt.clusterTypes.add(new Forceea.ClusterType('value', ForceeaService.ValueType.TYPE_BLANK, '', false));
        FObject.definitionTypes.add(dt);

        // example: static value(10)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.STATIC_INTEGER, 'StaticInteger', ForceeaService.COMMAND_STATIC);
        dt.clusterTypes.add(new Forceea.ClusterType('value', ForceeaService.ValueType.TYPE_INTEGER, null, false));
        FObject.definitionTypes.add(dt);

        // example: static value(10.2)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.STATIC_DECIMAL, 'StaticDecimal', ForceeaService.COMMAND_STATIC);
        dt.clusterTypes.add(new Forceea.ClusterType('value', ForceeaService.ValueType.TYPE_DECIMAL, null, false));
        FObject.definitionTypes.add(dt);

        // example: static value(2017-1-1 01:01:01)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.STATIC_DATETIME, 'StaticDatetime', ForceeaService.COMMAND_STATIC);
        dt.clusterTypes.add(new Forceea.ClusterType('value', ForceeaService.ValueType.TYPE_DATETIME, null, false));
        FObject.definitionTypes.add(dt);

        // example: static value(2017-1-1)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.STATIC_DATE, 'StaticDate', ForceeaService.COMMAND_STATIC);
        dt.clusterTypes.add(new Forceea.ClusterType('value', ForceeaService.ValueType.TYPE_DATE, null, false));
        FObject.definitionTypes.add(dt);

        // example: static value(01:01:01)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.STATIC_TIME, 'StaticTime', ForceeaService.COMMAND_STATIC);
        dt.clusterTypes.add(new Forceea.ClusterType('value', ForceeaService.ValueType.TYPE_TIME, null, false));
        FObject.definitionTypes.add(dt);

        // StaticString should always be last, after all other static definitions
        // example: static value(abc)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.STATIC_STRING, 'StaticString', ForceeaService.COMMAND_STATIC);
        dt.clusterTypes.add(new Forceea.ClusterType('value', ForceeaService.ValueType.TYPE_STRING, null, false));
        FObject.definitionTypes.add(dt);
    }

    /**
     * @description Sets the definition types of statics.
     */
    public static void setDefinitionTypesOfStaticLookup() {
        ForceeaDefinitionType dt = new ForceeaDefinitionType();

        // example: static lookup(Account) source(salesforce)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.STATIC_LOOKUP, 'StaticLookup', ForceeaService.COMMAND_STATIC);
        dt.clusterTypes.add(new Forceea.ClusterType('lookup', ForceeaService.ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('source', ForceeaService.ValueType.TYPE_STRING, null, false));
        FObject.definitionTypes.add(dt);

        // example: static lookup(Account) group(one) source(forceea)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.STATIC_LOOKUP, 'StaticLookupGroup', ForceeaService.COMMAND_STATIC);
        dt.clusterTypes.add(new Forceea.ClusterType('lookup', ForceeaService.ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('group', ForceeaService.ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('source', ForceeaService.ValueType.TYPE_STRING, 'forceea', false));
        FObject.definitionTypes.add(dt);

        // example: static lookup(Account) field(Name) value(Company XYZ) source(salesforce)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.STATIC_LOOKUP, 'StaticLookupField', ForceeaService.COMMAND_STATIC);
        dt.clusterTypes.add(new Forceea.ClusterType('lookup', ForceeaService.ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('field', ForceeaService.ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('value', ForceeaService.ValueType.TYPE_STRING, null, true));
        dt.clusterTypes.add(new Forceea.ClusterType('source', ForceeaService.ValueType.TYPE_STRING, null, false));
        FObject.definitionTypes.add(dt);

        // example: static lookup(Account) field(Name) value(Company XYZ) group(one) source(forceea)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.STATIC_LOOKUP, 'StaticLookupFieldGroup', ForceeaService.COMMAND_STATIC);
        dt.clusterTypes.add(new Forceea.ClusterType('lookup', ForceeaService.ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('field', ForceeaService.ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('value', ForceeaService.ValueType.TYPE_STRING, null, true));
        dt.clusterTypes.add(new Forceea.ClusterType('group', ForceeaService.ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('source', ForceeaService.ValueType.TYPE_STRING, 'forceea', false));
        FObject.definitionTypes.add(dt);

        // example: static lookup(Account) field(Name) except(Company XYZ) source(salesforce)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.STATIC_LOOKUP, 'StaticLookupExcept', ForceeaService.COMMAND_STATIC);
        dt.clusterTypes.add(new Forceea.ClusterType('lookup', ForceeaService.ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('field', ForceeaService.ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('except', ForceeaService.ValueType.TYPE_STRING, null, true));
        dt.clusterTypes.add(new Forceea.ClusterType('source', ForceeaService.ValueType.TYPE_STRING, null, false));
        FObject.definitionTypes.add(dt);

        // example: static lookup(Account) field(Name) except(Company XYZ) group(one) source(forceea)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.STATIC_LOOKUP, 'StaticLookupExceptGroup', ForceeaService.COMMAND_STATIC);
        dt.clusterTypes.add(new Forceea.ClusterType('lookup', ForceeaService.ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('field', ForceeaService.ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('except', ForceeaService.ValueType.TYPE_STRING, null, true));
        dt.clusterTypes.add(new Forceea.ClusterType('group', ForceeaService.ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('source', ForceeaService.ValueType.TYPE_STRING, 'forceea', false));
        FObject.definitionTypes.add(dt);

        // example: static lookup(Account) where(...) source(salesforce)
        dt = new ForceeaDefinitionType(ForceeaService.DefinitionTypeId.STATIC_LOOKUP, 'StaticLookupWhere', ForceeaService.COMMAND_STATIC);
        dt.clusterTypes.add(new Forceea.ClusterType('lookup', ForceeaService.ValueType.TYPE_STRING, null, false));
        dt.clusterTypes.add(new Forceea.ClusterType('where', ForceeaService.ValueType.TYPE_STRING, null, true));
        dt.clusterTypes.add(new Forceea.ClusterType('source', ForceeaService.ValueType.TYPE_STRING, 'salesforce', false));
        FObject.definitionTypes.add(dt);
    }

}
