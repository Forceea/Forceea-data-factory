/*
  Forceea data factory (v2.9.1)
  Copyright (C) 2024 Nikos Mitrakis

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
 * @description Handles the SOQL queries.
 */
@SuppressWarnings('PMD.FieldDeclarationsShouldBeAtStart')
public with sharing class ForceeaSelector {

    private static final String SELECT_SPACE = 'SELECT ';
    private static final String SPACE_AND_SPACE = ' AND ';
    private static final String SPACE_FROM_SPACE = ' FROM ';
    private static final String SPACE_LIMIT_SPACE = ' LIMIT ';
    private static final String SPACE_WHERE_SPACE = ' WHERE ';

    /* COLLECTIONS */

    private List<String> fields { get; set; }

    /* VARIABLES & PROPERTIES */

    private final FObject fObj { get; set; }
    private final String fromString {
        get {
            return SPACE_FROM_SPACE + String.escapeSingleQuotes(this.sObjectApiName);
        }
        set;
    }
    private Boolean isActiveFieldExists { get; set; }
    private Integer queryLimit {
        get {
            if (queryLimit == null) {
                return fObj.getGlobalQueryLimit();
            }
            return queryLimit;
        }
        set;
    }
    private final String queryLimitString {
        get {
            return SPACE_LIMIT_SPACE + String.escapeSingleQuotes(String.valueOf(this.queryLimit));
        }
        set;
    }
    private final String queryString {
        get {
            return this.selectString + this.fromString + this.whereString + this.queryLimitString;
        }
        set;
    }
    private final String selectString {
        get {
            if (this.fields.isEmpty()) {
                this.fields.add('Id');
            }
            String fieldsString = ForceeaService.getStringFromList(this.fields, ', ');
            return SELECT_SPACE + String.escapeSingleQuotes(fieldsString);
        }
        set;
    }
    private Boolean shouldExcludeInactive { get; set; }
    private final Boolean shouldAddIsActiveInWhereClauseElements {
        get {
            return this.shouldExcludeInactive && this.isActiveFieldExists;
        }
    }
    private String sObjectApiName = '';
    private final String whereString {
        get {
            List<String> whereClauseElements = new List<String>();
            if (String.isNotBlank(this.whereClause)) {
                whereClauseElements.add(this.whereClause);
            }
            if (this.shouldAddIsActiveInWhereClauseElements) {
                whereClauseElements.add('IsActive = TRUE');
            }

            return (whereClauseElements.isEmpty())
                ? ''
                : SPACE_WHERE_SPACE + getWhereString(whereClauseElements);
        }
        set;
    }
    private String whereClause = '';

    /* CONSTRUCTORS */

    /**
     * @description The constructor for the class.
     */
    public ForceeaSelector() {
        initialize();
    }

    /**
     * @description The constructor for the class.
     * @param fObj An FObject object.
     */
    public ForceeaSelector(FObject fObj) {
        this();

        this.fObj = fObj;
        this.sObjectApiName = fObj.getSObjectApiName();
        this.queryLimit = fObj.getQueryLimit();
        if (String.isNotBlank(fObj.bigObjectIndexFieldsString)) {
            this.fields = fObj.bigObjectIndexFieldsString.split(',');
        }
    }

    /* METHODS */

    /**
     * @description It excludes the inactive records.
     * @param condition If true, the inactive records will be excluded.
     * @return The current instance.
     */
    public ForceeaSelector excludeInactive(Boolean condition) {
        this.shouldExcludeInactive = condition;
        return this;
    }

    /**
     * @description Retrieves the query string.
     * @return The query string.
     */
    public String getQueryString() {
        return this.queryString;
    }

    /**
     * @description Validates and returns the SOQL query LIMIT.
     * @param queryLimit The SOQL query LIMIT.
     * @return The validated query LIMIT.
     */
    public Integer getValidatedQueryLimit(Integer queryLimit) {
        Integer result = queryLimit;

        if (queryLimit < 1) {
            result = 1;
        } else if (queryLimit > 50000) {
            result = 50000;
        }

        return result;
    }

    /**
     * @description Retrieves the WHERE clause string.
     * @param whereClauseItems The WHERE clause items.
     * @return A WHERE string.
     */
    private String getWhereString(List<String> whereClauseItems) {
        return String.join(whereClauseItems, SPACE_AND_SPACE);
    }

    private void initialize() {
        this.fields = new List<String>();
        this.isActiveFieldExists = false;
        this.shouldExcludeInactive = false;
    }

    /**
     * @description Checks if the IsActive standard field exists.
     * @param condition If true, the IsActive field exists.
     * @return The current instance.
     */
    public ForceeaSelector isActiveFieldExists(Boolean condition) {
        this.isActiveFieldExists = condition;
        return this;
    }

    /**
     * @description Retrieves all records.
     * @return A list of SObject records.
     */
    public List<SObject> selectAll() {
        return Database.query(getQueryString());
    }

    /**
     * @description Retrieves ForceeaSetting custom metadata records.
     * @return A list of ForceeaSetting records.
     */
    public List<ForceeaSetting__mdt> selectCustomMetadataSettings() {
        setFields(new List<String>{
            'DeveloperName', 'DebugLogClass__c', 'DebugLogMethod__c',
            'RecordsToCreate__c', 'RecordsToDisplay__c',
            'MaxErrorRecordsToDisplay__c', 'UserMessage__c'
        });
        setFrom('ForceeaSetting__mdt');
        setLimit(100);
        return Database.query(getQueryString());
    }

    /**
     * @description Retrieves the asynchronous jobs with specific statuses.
     * @param statuses A set of statuses.
     * @return A list of AsyncApexJob records.
     */
    public List<AsyncApexJob> selectAsyncJobsByStatus(Set<String> statuses) {
        setFrom('AsyncApexJob');
        setWhere(
            'ApexClassId = \'' + String.valueOf(ForceeaService.getQueueableClassId()) + '\' AND Status IN :statuses');
        setLimit(100);
        return Database.query(getQueryString());
    }

    /**
     * @description Retrieves lookup records.
     * @param fields The fields to retrieve.
     * @param lookupSObjectApiName The lookup SObject API name.
     * @param lookupIdsSet A set of lookup IDs.
     * @param queryLimit The LIMIT value.
     * @return A list of SObject records.
     */
    public List<SObject> selectLookupRecords(
        List<String> fields, String lookupSObjectApiName, Set<String> lookupIdsSet, Integer queryLimit) {
        setFields(fields);
        setFrom(lookupSObjectApiName);
        setWhere('Id IN :lookupIdsSet');
        setLimit(queryLimit);
        return Database.query(getQueryString());
    }

    /**
     * @description Retrieves an Organization object.
     * @return An Organization record.
     */
    public Organization selectOrganization() {
        setFields(new List<String>{
            'IsSandbox,OrganizationType,TrialExpirationDate'
        });
        setFrom('Organization');
        setWhere('Id = \'' + UserInfo.getOrganizationId() + '\'');
        setLimit(1);
        return Database.query(getQueryString());
    }

    /**
     * @description Retrieves an Apex class object.
     * @param className The class identifier.
     * @return An Apex class record.
     */
    public ApexClass selectQueueableClassByName(String className) {
        setFrom('ApexClass');
        setWhere('Name = \'' + String.escapeSingleQuotes(className) + '\'');
        setLimit(1);
        return Database.query(getQueryString());
    }

    /**
     * @description Retrieves the standard price book.
     * @return A Pricebook2 record.
     */
    public Pricebook2 selectStandardPriceBook() {
        setFrom('Pricebook2');
        setWhere('IsStandard = TRUE');
        setLimit(1);

        List<Pricebook2> priceBooks = Database.query(getQueryString());
        if (priceBooks.isEmpty()) {
            return null;
        }

        return priceBooks.get(0);
    }

    /**
     * @description Retrieves a list of SObject records for asynchronous processing.
     * @param selectString The SELECT string.
     * @param sObjectApiName The SObject API name.
     * @param whereClause The WHERE string.
     * @param queryLimitClause The LIMIT value.
     * @return A list of SObjects.
     */
    public List<SObject> selectToUpdateOrDeleteAsync(
        String selectString, String sObjectApiName, String whereClause, Integer queryLimitClause) {
        setFields(new List<String>{
            selectString
        });
        setFrom(sObjectApiName);
        setWhere(whereClause);
        setLimit(queryLimitClause);

        return Database.query(getQueryString());
    }

    /**
     * @description Defines a field to retrieve.
     * @param fieldApiName The field API name.
     * @return The current instance.
     */
    public ForceeaSelector setField(String fieldApiName) {
        if (String.isNotBlank(fieldApiName)) {
            this.fields.add(fieldApiName);
        }
        return this;
    }

    /**
     * @description Defines the fields to retrieve.
     * @param fields A list of fields API names.
     * @return The current instance.
     */
    private ForceeaSelector setFields(List<String> fields) {
        this.fields.addAll(fields);
        return this;
    }

    /**
     * @description Defines the selection SObject.
     * @param sObjectApiName The SObject API name.
     * @return The current instance.
     */
    public ForceeaSelector setFrom(String sObjectApiName) {
        this.sObjectApiName = sObjectApiName;
        return this;
    }

    /**
     * @description Defines the LIMIT value.
     * @param queryLimit The LIMIT value.
     * @return The current instance.
     */
    public ForceeaSelector setLimit(Integer queryLimit) {
        this.queryLimit = queryLimit;
        return this;
    }

    /**
     * @description Defines the WHERE clause.
     * @param whereClause The WHERE clause string.
     * @return The current instance.
     */
    public ForceeaSelector setWhere(String whereClause) {
        this.whereClause = whereClause;
        return this;
    }

}