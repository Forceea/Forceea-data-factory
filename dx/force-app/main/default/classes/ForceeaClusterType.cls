/*
  Forceea data factory (v2.5)
  Copyright (C) 2021 Nikos Mitrakis

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
 * @description A template for a valid cluster.
 *   Cluster Types are defined in static method setDefinitionTypes.
 */
public with sharing class ForceeaClusterType {

    public Boolean allowsMultipleArguments { get; set; } // true if the value allows multiple arguments
    public String parameter { get; set; } // the parameter, e.g. "from"
    public String value { get; set; } // the parameter value , e.g. "10"
    public ForceeaService.ValueType valueType { get; set; } // the parameter value type, e.g. TYPE_DECIMAL

    public ForceeaClusterType(String parameter, ForceeaService.ValueType valueType, String value, Boolean allowsMultipleArguments) {
        this.allowsMultipleArguments = allowsMultipleArguments;
        this.parameter = parameter;
        this.value = value;
        this.valueType = valueType;
    }

}
