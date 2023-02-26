/*
  Forceea data factory (v2.8.0)
  Copyright (C) 2023 Nikos Mitrakis

  This program is free software: you can redistribute it and/or modify it under the terms
  of the GNU General Public License as published by the Free Software Foundation,
  either version 3 of the License, or any later version.

  This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
  without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  See the GNU General Public License for more details.

  You can find a copy of the GNU General Public License at
  https://github.com/Forceea/Forceea-data-factory/blob/master/LICENSE
*/
public with sharing class ForceeaSelector {

    /* COLLECTIONS */

    private List<String> fields = new List<String>();

    /* VARIABLES & PROPERTIES */

    private FObject fObj { get; set; }
    private String fromString {
        get {
            return ' FROM ' + this.sObjectApiName;
        }
        set;
    }
    private Boolean isActiveFieldExists = false;
    private Integer queryLimit {
        get {
            if (queryLimit == null) {
                return fObj.getGlobalQueryLimit();
            }
            return queryLimit;
        }
        set;
    }
    private String queryLimitString {
        get {
            return ' LIMIT ' + String.valueOf(this.queryLimit);
        }
        set;
    }
    private String queryString {
        get {
            return this.selectString + this.fromString + this.whereString + this.queryLimitString;
        }
        set;
    }
    private String selectString {
        get {
            if (this.fields.isEmpty()) {
                this.fields.add('Id');
            }
            return 'SELECT ' + ForceeaService.getStringFromList(this.fields, ', ');
        }
        set;
    }
    private Boolean shouldExcludeInactive = false;
    private String sObjectApiName = '';
    private String whereString {
        get {
            List<String> whereClauseElements = new List<String>();
            if (String.isNotBlank(this.whereClause)) {
                whereClauseElements.add(this.whereClause);
            }
            if (this.shouldExcludeInactive && this.isActiveFieldExists) {
                whereClauseElements.add('IsActive = true');
            }

            return (whereClauseElements.isEmpty())
                ? ''
                : ' WHERE ' + getWhereString(whereClauseElements);
        }
        set;
    }
    private String whereClause = '';

    /* CONSTRUCTORS */

    public ForceeaSelector() {
    }

    public ForceeaSelector(FObject fObj) {
        this.fObj = fObj;
        this.sObjectApiName = fObj.getSObjectName();
        this.queryLimit = fObj.getQueryLimit();
        if (String.isNotBlank(fObj.bigObjectIndexFieldsString)) {
            this.fields = fObj.bigObjectIndexFieldsString.split(',');
        }
    }

    /* METHODS */

    public ForceeaSelector excludeInactive(Boolean condition) {
        this.shouldExcludeInactive = condition;
        return this;
    }

    public ForceeaSelector isActiveFieldExists(Boolean condition) {
        this.isActiveFieldExists = condition;
        return this;
    }

    public String getQueryString() {
        return this.queryString;
    }

    private String getWhereString(List<String> whereClauseElements) {
        return String.join(whereClauseElements, 'AND ')
            .trim()
            .removeStart('AND ')
            .removeEnd('AND');
    }

    public List<ForceeaSetting__mdt> selectCustomMetadataSettings() {
        setFields(new List<String>{
            'DeveloperName', 'RecordsToCreate__c', 'RecordsToDisplay__c',
            'MaxErrorRecordsToDisplay__c', 'UserMessage__c'
        });
        setLimit(100);
        setFrom('ForceeaSetting__mdt');
        return Database.query(getQueryString());
    }

    public List<AsyncApexJob> selectAsyncJobsByStatus(Set<String> statuses) {
        setFrom('AsyncApexJob');
        setWhere('ApexClassId = \'' + String.valueOf(ForceeaService.getQueueableClassId()) +
            '\' AND Status IN :statuses');
        setLimit(100);
        return Database.query(getQueryString());
    }

    public Organization selectOrganization() {
        setFields(new List<String>{
            'IsSandbox,OrganizationType,TrialExpirationDate'
        });
        setFrom('Organization');
        setWhere('Id = \'' + UserInfo.getOrganizationId() + '\'');
        setLimit(1);
        return Database.query(getQueryString());
    }

    public ApexClass selectQueueableClassByName(String className) {
        setFrom('ApexClass');
        setWhere('Name = \'' + className + '\'');
        setLimit(1);
        return Database.query(getQueryString());
    }

    public List<SObject> selectAll() {
        return Database.query(getQueryString());
    }

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

    public ForceeaSelector setField(String fieldApiName) {
        if (String.isNotBlank(fieldApiName)) {
            this.fields.add(fieldApiName);
        }
        return this;
    }

    public ForceeaSelector setFields(List<String> fields) {
        this.fields.addAll(fields);
        return this;
    }

    public ForceeaSelector setFrom(String sObjectApiName) {
        this.sObjectApiName = sObjectApiName;
        return this;
    }

    public ForceeaSelector setLimit(Integer queryLimit) {
        this.queryLimit = queryLimit;
        return this;
    }

    public ForceeaSelector setWhere(String whereClause) {
        this.whereClause = whereClause;
        return this;
    }

}
