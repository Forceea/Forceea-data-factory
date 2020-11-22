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
 * @description A definition cluster <cluster> ::= <parameter>(<argument[,...n]>).
 */
public with sharing class ForceeaCluster {

    public List<String> arguments = new List<String>();
    public String parameter { get; set; }

    public ForceeaCluster(String parameter, List<String> arguments) {
        this.arguments = new List<String>(arguments);
        this.parameter = parameter;
    }

}
