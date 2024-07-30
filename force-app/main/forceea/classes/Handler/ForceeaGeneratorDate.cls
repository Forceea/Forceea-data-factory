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
 * @description Generates Date values.
 */
public with sharing class ForceeaGeneratorDate {

    /* CONSTANTS */

    private Date fromDate { get; set; }
    private Datetime fromDatetime { get; set; }
    private Long fromDatetimePoint { get; set; }
    private Boolean fromIsDate { get; set; }
    private Date toDate { get; set; }
    private Datetime toDatetime { get; set; }
    private Long toDatetimePoint { get; set; }
    private Boolean toIsDate { get; set; }

    /* COLLECTIONS */

    private List<String> results { get; set; }

    /* INSTANCE VARIABLES & PROPERTIES */

    private ForceeaDefinition def { get; set; }
    private FObject fObj { get; set; }

    /* CONSTRUCTORS */

    /**
     * @description The constructor for the class.
     * @param def A ForceeaDefinition object.
     */
    public ForceeaGeneratorDate(ForceeaDefinition def) {
        this.def = def;
        this.fObj = def.fObj;
        this.results = new List<String>();
    }

    /* METHODS */

    /**
     * @description Adds 24h - 1s to toDatetime
     */
    private void add24hInToDate() {
        this.toDatetime = this.toDatetime.addSeconds(86399);
    }

    private Boolean dateArgumentsAreValid() {
        if (this.fromDate < this.toDate) {
            return true;
        }

        this.fObj.addError(this.def.fieldApiName,
            'The [from] date is greater than or equal to ' +
            'the [to] date in definition [' + this.def.definitionString + ']');
        return false;
    }

    private Boolean dateTimeArgumentsAreValid() {
        if (this.fromDatetimePoint < this.toDatetimePoint) {
            return true;
        }

        this.fObj.addError(this.def.fieldApiName,
            'The [from] datetime is greater than or equal to ' +
            'the [to] datetime in definition [' + this.def.definitionString + ']');
        return false;
    }

    private Boolean fromIsNotDateAndToIsDate() {
        return !this.fromIsDate && this.toIsDate;
    }

    /**
     * @description Creates random dates.
     * @param fromDate The minimum date.
     * @param toDate The maximum date.
     * @return A list of string values.
     */
    public List<String> getRandomValues(Date fromDate, Date toDate) {
        initializeDateParameters(fromDate, toDate);

        if (!dateArgumentsAreValid()) {
            return this.results;
        }

        setRandomDateValues();

        return this.results;
    }

    /**
     * @description Creates random datetimes.
     * @param fromDatetime The minimum datetime.
     * @param toDatetime The maximum datetime.
     * @return A list of string values.
     */
    public List<String> getRandomValues(Datetime fromDatetime, Datetime toDatetime) {
        initializeDatetimeParameters(fromDatetime, toDatetime);
        setFromAndToParameters();
        setDatetimePoints();

        if (!dateTimeArgumentsAreValid()) {
            return this.results;
        }
        setRandomDatetimeValues();

        return this.results;
    }

    private void initializeDateParameters(Date fromDate, Date toDate) {
        this.fromDate = fromDate;
        this.toDate = toDate;
    }

    private void initializeDatetimeParameters(Datetime fromDatetime, Datetime toDatetime) {
        this.fromDatetime = fromDatetime;
        this.toDatetime = toDatetime;
    }

    private Boolean isFromEqualToAndBothAreDates() {
        return this.fromIsDate &&
            this.toIsDate &&
            this.fromDatetime == this.toDatetime;
    }

    private void setDatetimePoints() {
        this.fromDatetimePoint = this.fromDatetime.getTime();
        this.toDatetimePoint = this.toDatetime.getTime();
    }

    private void setFromAndToParameters() {
        setFromIsDate();
        setToIsDate();

        if (isFromEqualToAndBothAreDates() || fromIsNotDateAndToIsDate()) {
            add24hInToDate();
        }
    }

    private void setFromIsDate() {
        this.fromIsDate = false;

        if (this.fromDatetime.hour() == 0 &&
            this.fromDatetime.minute() == 0 &&
            this.fromDatetime.second() == 0
        ) {
            this.fromIsDate = true;
        }
    }

    private void setRandomDateValues() {
        Integer range = this.fromDate.daysBetween(this.toDate) + 1;

        for (Integer counter = 0; counter < this.fObj.getNumberOfRecords(); counter++) {
            Integer days = (FObject.random * range).intValue();
            this.results.add(String.valueOf(fromDate.addDays(days)));
        }
    }

    private void setRandomDatetimeValues() {
        Long range = this.toDatetimePoint - this.fromDatetimePoint;

        for (Integer counter = 0; counter < this.fObj.getNumberOfRecords(); counter++) {
            Long randomPoint = this.fromDatetimePoint + (FObject.random * range).longValue();
            this.results.add(String.valueOf(Datetime.newInstance(randomPoint)));
        }
    }

    private void setToIsDate() {
        this.toIsDate = false;

        if (this.toDatetime.hour() == 0 &&
            this.toDatetime.minute() == 0 &&
            this.toDatetime.second() == 0
        ) {
            this.toIsDate = true;
        }
    }

}