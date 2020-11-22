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
public with sharing class ForceeaVariable {

    public String name { get; set; }

    public Boolean booleanValue { get; set; }
    public Date dateValue { get; set; }
    public Datetime datetimeValue { get; set; }
    public Decimal decimalValue { get; set; }
    public Integer integerValue { get; set; }
    public String stringValue { get; set; }

    public Boolean isGlobalVariable { get; set; }

    public ForceeaVariable(String name, Boolean value, Boolean isGlobalVariable) {
        this.name = name;
        this.booleanValue = value;
        this.isGlobalVariable = isGlobalVariable;
    }

    public ForceeaVariable(String name, Date value, Boolean isGlobalVariable) { // TODO check usage
        this.name = name;
        this.dateValue = value;
        this.isGlobalVariable = isGlobalVariable;
    }

    public ForceeaVariable(String name, Datetime value, Boolean isGlobalVariable) {
        this.name = name;
        this.datetimeValue = value;
        this.isGlobalVariable = isGlobalVariable;
    }

    public ForceeaVariable(String name, Decimal value, Boolean isGlobalVariable) {
        this.name = name;
        this.decimalValue = value;
        this.isGlobalVariable = isGlobalVariable;
    }

    public ForceeaVariable(String name, Integer value, Boolean isGlobalVariable) { // TODO check usage
        this.name = name;
        this.integerValue = value;
        this.isGlobalVariable = isGlobalVariable;
    }

    public ForceeaVariable(String name, String value, Boolean isGlobalVariable) {
        this.name = name;
        this.stringValue = value;
        this.isGlobalVariable = isGlobalVariable;
    }

}
