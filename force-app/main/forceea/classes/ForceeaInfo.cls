/*
  Forceea data factory (v2.9.0)
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
/**
 * @description Provides Schema information for fields.
 */
public with sharing class ForceeaInfo {

    /* INSTANCE VARIABLES & PROPERTIES */

    private final FObject fObj;

    /* CLASSES */

    /**
     * @description A picklist info object.
     */
    public class PicklistInfo {
        public String validFor;
    }

    /* CONSTRUCTORS */

    /**
     * @description The constructor for the class.
     */
    public ForceeaInfo() { // NOPMD
    }

    /**
     * @description The constructor for the class.
     * @param fObj An FObject object.
     */
    public ForceeaInfo(FObject fObj) {
        this.fObj = fObj;
    }

    /* METHODS */

    private Boolean allowsMultipleDefinitions(Forceea.FieldInfo result) {
        switch on result.dataType {
            when STRING, EMAIL, URL, BASE64, PHONE, TEXTAREA, COMBOBOX {
                return true;
            } when else {
                return false;
            }
        }
    }

    private Boolean controllerFieldExists(DescribeFieldResult dfr) {
        return dfr.getController() != null;
    }

    /**
     * @description Informs if the field is required.
     * @param dfr The schema describe field result.
     * @return True, if the field is required.
     */
    private Boolean fieldIsRequired(DescribeFieldResult dfr) {
        if (dfr.isCreateable() && !dfr.isNillable() && !dfr.isDefaultedOnCreate()) {
            return true;
        } else {
            return false;
        }
    }

    /**
     * @description Retrieves a list of the controlling PicklistEntry values.
     * @param sObjectFieldsByName A map with key: SObject API field name, value: SObjectField.
     * @param controllingField The controlling field name.
     * @return A list of PicklistEntry values.
     */
    private List<PicklistEntry> getControllingValues(
        Map<String, SObjectField> sObjectFieldsByName, String controllingField
    ) {
        DescribeFieldResult controllingFieldInfo = sObjectFieldsByName.get(controllingField).getDescribe();
        return controllingFieldInfo.getPicklistValues();
    }

    /**
     * @description Retrieves a list of the dependent PicklistEntry values.
     * @param sObjectFieldsByName A map with key: SObject API field name, value: SObjectField.
     * @param dependentField The dependent field name.
     * @return A list of PicklistEntry values.
     */
    private List<PicklistEntry> getDependentValues(
        Map<String, SObjectField> sObjectFieldsByName, String dependentField
    ) {
        DescribeFieldResult dependentFieldInfo = sObjectFieldsByName.get(dependentField).getDescribe();
        return dependentFieldInfo.getPicklistValues();
    }

    /**
     * @description Retrieves the field dependencies mapping between a controlling field and a dependent field.
     *   https://salesforce.stackexchange.com/questions/4462/get-lists-of-dependent-picklist-options-in-apex/164491#164491
     * @param controllingField The API name of the controlling field.
     * @param dependentField The API name of the dependent field.
     * @return A map of the controlling field value and the dependent field values.
     * @author Suriya Soundrapandian.
     */
    public Map<String, Set<String>> getFieldDependenciesMap(String controllingField, String dependentField) {
        Map<String, SObjectField> sObjectFieldsByName = ForceeaService.getSObjectFieldsByName(this.fObj.getSObjectApiName());
        List<PicklistEntry> controllingValues = getControllingValues(sObjectFieldsByName, controllingField);
        List<PicklistEntry> dependentValues = getDependentValues(sObjectFieldsByName, dependentField);

        return getFieldDependenciesMapFromValues(controllingValues, dependentValues);
    }

    private Map<String, Set<String>> getFieldDependenciesMapFromValues(
        List<PicklistEntry> controllingValues,
        List<PicklistEntry> dependentValues
    ) {
        Map<String, Set<String>> results = getInitializedFieldDependenciesMap(controllingValues);

        for (PicklistEntry dependentValue : dependentValues) {
            String hexString = getHexString(dependentValue);
            Integer baseCount = 0;

            for (Integer chr : hexString.getChars()) {
                Integer val = getInitialValue(chr);

                String depValue = dependentValue.getValue();
                if ((val & 8) == 8) {
                    results.get(controllingValues[baseCount + 0].getValue()).add(depValue);
                }
                if ((val & 4) == 4) {
                    results.get(controllingValues[baseCount + 1].getValue()).add(depValue);
                }
                if ((val & 2) == 2) {
                    results.get(controllingValues[baseCount + 2].getValue()).add(depValue);
                }
                if ((val & 1) == 1) {
                    results.get(controllingValues[baseCount + 3].getValue()).add(depValue);
                }
                baseCount += 4;
            }
        }
        return results;
    }

    private Forceea.FieldInfo getFieldInfo(DescribeFieldResult dfr) {
        Forceea.FieldInfo result = new Forceea.FieldInfo();

        result.fieldName = dfr.getName().toLowerCase();
        result.fieldApiName = dfr.getName();
        result.label = dfr.getLabel();
        result.dataType = dfr.getType();
        result.isRestrictedPicklist = dfr.isRestrictedPicklist();
        result.canHaveMultipleTypesAsParents = dfr.isNamePointing();
        result.length = dfr.getLength();
        result.parents = dfr.getReferenceTo();
        result.isAccessible = dfr.isAccessible();
        result.isCreateable = dfr.isCreateable();

        return result;
    }

    /**
     * @description Retrieves the field details.
     * @param sObjectField The sObject field.
     * @return A Field object.
     */
    public Forceea.FieldInfo getFieldInfoFromSObjectField(Schema.SObjectField sObjectField) {
        DescribeFieldResult dfr = sObjectField.getDescribe();
        Forceea.FieldInfo result = getFieldInfo(dfr);

        result.isRequired = fieldIsRequired(dfr);
        result.allowsMultipleDefinitions = allowsMultipleDefinitions(result);
        updateSelectionProperties(result, dfr);

        return result;
    }

    private String getHexString(PicklistEntry dependentValue) {
        String jsonString = JSON.serialize(dependentValue);
        PicklistInfo info = (PicklistInfo) JSON.deserialize(jsonString, PicklistInfo.class);

        return EncodingUtil.convertToHex(EncodingUtil.base64Decode(info.validFor)).toUpperCase();
    }

    private Integer getInitialValue(Integer chr) {
        Integer result = 0;

        if (chr >= 65) {
            result = chr - 65 + 10;
        } else {
            result = chr - 48;
        }

        return result;
    }

    /**
     * @description Retrieves a map with key: controlling value, value: list of dependent values (Field Dependencies map).
     * @param controllingValues A list of controlling PicklistEntry values.
     * @return The Field Dependencies map.
     */
    private Map<String, Set<String>> getInitializedFieldDependenciesMap(List<PicklistEntry> controllingValues) {
        Map<String, Set<String>> results = new Map<String, Set<String>>();

        for (PicklistEntry ctrlValue : controllingValues) {
            results.put(ctrlValue.getValue(), new Set<String>());
        }

        return results;
    }

    private Boolean isSelectionField(DisplayType dt) {
        return (dt == DisplayType.PICKLIST || dt == DisplayType.MULTIPICKLIST || dt == DisplayType.COMBOBOX);
    }

    private void updateSelectionProperties(Forceea.FieldInfo result, DescribeFieldResult dfr) {
        if (!isSelectionField(result.dataType)) {
            return;
        }

        if (controllerFieldExists(dfr)) {
            result.controllingFieldApiName = dfr.getController().getDescribe().getName();
        }

        result.picklistValues = dfr.getPicklistValues();
    }

}