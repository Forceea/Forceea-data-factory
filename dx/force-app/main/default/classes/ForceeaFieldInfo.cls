/*
  Forceea data factory (v2.3.0)
  Copyright (C) 2020 Nikos Mitrakis

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
 * @description Represents the Field information.
 */
public with sharing class ForceeaFieldInfo {

    /* COLLECTIONS */

    public List<Schema.SObjectType> parents = new List<Schema.SObjectType>();
    public List<Schema.PicklistEntry> picklistValues = new List<Schema.PicklistEntry>();

    /* VARIABLES & PROPERTIES */

    public Boolean allowsMultipleDefinitions { get; set; }
    public Boolean canHaveMultipleTypesAsParents { get; set; }
    public String controllingFieldApiName { get; set; } // the API name of the controlling picklist field
    public Schema.DisplayType dataType { get; set; }

    public String fieldApiName { get; set; } // the field API name
    public String fieldName { get; set; } // the field API name in lowercase

    public Boolean isAccessible { get; set; } // the current user can see this field
    public Boolean isCreateable { get; set; } // can be created by the current user
    public Boolean isRequired { get; set; } // is required when inserting/updating a record
    public Boolean isRestrictedPicklist { get; set; }

    public String label { get; set; } // the text label that is displayed next to the field in the user interface
    public Integer length { get; set; } // for string fields, the maximum size

}
