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
 * @description Handles the Record Types.
 */
@SuppressWarnings('PMD.FieldDeclarationsShouldBeAtStart')
public with sharing class ForceeaRecordTypeHandler {

    /* STATIC COLLECTIONS */

    /**
     * @description The record types of this SObject - key: DeveloperName, value: Id)
     */
    private static Map<String, Id> recordTypeIdsByDeveloperName = new Map<String, Id>();
    /**
     * @description The map with key: SObject Type and value: list of Record Type Infos.
     */
    private static Map<SObjectType, List<RecordTypeInfo>> recordTypeInfosBySObject =
        new Map<SObjectType, List<RecordTypeInfo>>();

    /* INSTANCE VARIABLES & PROPERTIES */

    private final ForceeaDefinition def { get; set; }
    private final FObject fObj;

    /* CONSTRUCTORS */

    /**
     * @description The constructor for the class.
     */
    public ForceeaRecordTypeHandler() { // NOPMD
    }

    /**
     * @description The constructor for the class.
     * @param fObj An FObject object.
     */
    public ForceeaRecordTypeHandler(FObject fObj) {
        this.fObj = fObj;
    }

    /**
     * @description The constructor for the class.
     * @param fObj An FObject object.
     * @param def A ForceeaDefinition object.
     */
    public ForceeaRecordTypeHandler(FObject fObj, ForceeaDefinition def) {
        this.fObj = fObj;
        this.def = def;
    }

    /* METHODS */

    private String getKey(String devName) {
        return this.fObj.getSObjectApiName().toLowerCase() + '.' + devName.toLowerCase();
    }

    private void setRecordTypeIdsByDeveloperName() {
        for (RecordTypeInfo rti : recordTypeInfosBySObject.get(this.fObj.sObjType)) {
            recordTypeIdsByDeveloperName.put(getKey(rti.getDeveloperName()), rti.getRecordTypeId());
        }
    }

    /**
     * @description Retrieves the Record Type IDs, excluding exceptions of Developer Names.
     * @param clusterArguments The list of cluster arguments.
     * @return A list of Record Type IDs.
     */
    public List<String> getRecordTypeIdsExcludingExceptions(List<String> clusterArguments) {
        List<String> results = new List<String>();
        List<String> exceptions = ForceeaService.convertListToLowercase(clusterArguments);
        String sObjectApiName = this.fObj.getSObjectApiName().toLowerCase();

        for (String key : recordTypeIdsByDeveloperName.keySet()) {
            if (sObjectIsFound(key, sObjectApiName)) {
                String rtApiName = key.substringAfter('.');
                if (exceptions.isEmpty() || !exceptions.contains(rtApiName)) {
                    results.add(recordTypeIdsByDeveloperName.get(key));
                }
            }
        }

        return results;
    }

    /**
     * @description Retrieves the Record Type IDs related to case-insensitive developer names.
     * @param developerNames A list of Record Type developer names.
     * @return A list of Record Type IDs.
     */
    public List<String> getRecordTypeIdsFromDeveloperNames(List<String> developerNames) {
        List<String> results = new List<String>();

        for (String devName : developerNames) {
            String key = getKey(devName);
            if (recordTypeIdsByDeveloperName.containsKey(key)) {
                results.add(recordTypeIdsByDeveloperName.get(key));
            } else {
                this.fObj.addError(this.def.fieldApiName,
                    'Invalid record type [' + devName + '] in definition [' + this.def.definitionString + ']');
            }
        }

        return results;
    }

    private List<RecordTypeInfo> getRecordTypeInfos(SObjectType sObjType) {
        List<RecordTypeInfo> results = new List<RecordTypeInfo>();

        for (RecordTypeInfo rti : sObjType.getDescribe().getRecordTypeInfos()) {
            if (!rti.isMaster() && rti.isActive()) {
                results.add(rti);
            }
        }

        return results;
    }

    private void setRecordTypeInfosBySObject() {
        SObjectType sObjType = this.fObj.sObjType;
        if (recordTypeInfosBySObject.containsKey(sObjType)) {
            return;
        }

        recordTypeInfosBySObject.put(sObjType, getRecordTypeInfos(sObjType));
    }

    /**
     * @description Sets the Record Types.
     */
    public void setRecordTypes() {
        if (this.fObj.isBigObject) {
            return;
        }
        setRecordTypeInfosBySObject();
        setRecordTypeIdsByDeveloperName();
    }

    private Boolean sObjectIsFound(String key, String sObjectApiName) {
        return key.substringBefore('.') == sObjectApiName;
    }

}