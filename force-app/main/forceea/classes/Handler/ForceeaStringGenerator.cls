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
 * @description Generates string values.
 */
public with sharing class ForceeaStringGenerator {

    /* CONSTANTS */

    private static final String DIGIT_CHARS = '0123456789';
    private static final String KEY_DIGIT = 'digit';
    private static final String KEY_LOWER = 'lower';
    private static final String KEY_UPPER = 'upper';
    private static final String LOWER_CHARS = 'abcdefghijklmnopqrstuvwxyz';
    private static final String UPPER_CHARS = 'ABCDEFGHIJKLMNOPQRSUVWXYZ';

    /* INSTANCE VARIABLES & PROPERTIES */

    private final ForceeaDefinition def { get; set; }
    private final FObject fObj { get; set; }
    /**
     * @description A list of strings with the included chars.
     */
    public List<String> includes { get; set; }
    /**
     * @description The min length of the generated strings.
     */
    public Integer minlength { get; set; }
    /**
     * @description The max length of the generated strings.
     */
    public Integer maxlength { get; set; }
    private Integer numRecords { get; set; }
    /**
     * @description
     */
    public String startsWith { get; set; }

    /* CONSTRUCTORS */

    /**
     * @description The constructor for the class.
     * @param def A ForceeaDefinition object.
     */
    public ForceeaStringGenerator(ForceeaDefinition def) {
        this.def = def;
        this.fObj = def.fObj;
        this.numRecords = def.fObj.getNumberOfRecords();
    }

    /* METHODS */

    /**
     * @description Retrieves a string with the chars to select from.
     * @return A string with the valid chars to select from.
     */
    private String getCharsToSelect() {
        String result = '';

        for (String item : ForceeaService.convertListToLowercase(this.includes)) {
            if (item == 'lower') {
                result += LOWER_CHARS;
            } else if (item == 'upper') {
                result += UPPER_CHARS;
            } else if (item == 'digit') {
                result += DIGIT_CHARS;
            }
        }

        return result;
    }

    /**
     * @description Creates random strings.
     * @return A list of string values.
     */
    public List<String> getRandomStrings() {
        List<String> results = new List<String>();

        validateArgumentsOfRandomStrings();
        String charsToSelect = getCharsToSelect();

        for (Integer counter1 = 0; counter1 < this.numRecords; counter1++) {
            String result = getResult(LOWER_CHARS, UPPER_CHARS, DIGIT_CHARS, charsToSelect);
            results.add(result);
        }

        return results;
    }

    private String getResult(String lowerChars, String upperChars, String digits, String charsToSelect) {
        Integer resultLength = this.minlength + (FObject.random * (this.maxlength - this.minlength + 1)).intValue();
        String selectionsForFirstChar = getSelectionsForFirstChar(lowerChars, upperChars, digits);

        Integer size = selectionsForFirstChar.length();
        Integer rnd = (FObject.random * size).intValue();
        String firstChar = selectionsForFirstChar.substring(rnd, rnd + 1);
        size = charsToSelect.length();

        String restChars = '';
        for (Integer counter2 = 1; counter2 < resultLength; counter2++) {
            rnd = (FObject.random * size).intValue();
            restChars += charsToSelect.substring(rnd, rnd + 1);
        }

        return firstChar + restChars;
    }

    /**
     * @description Retrieves the string of chars available for the first position.
     * @param lowerChars The lower-case chars.
     * @param upperChars The upper-case chars.
     * @param digits The digit chars.
     * @return A string of first position chars.
     */
    private String getSelectionsForFirstChar(String lowerChars, String upperChars, String digits) {
        String result = '';

        if (this.startsWith == KEY_LOWER) {
            result = lowerChars;
        } else if (this.startsWith == KEY_UPPER) {
            result = upperChars;
        } else if (this.startsWith == KEY_DIGIT) {
            result = digits;
        }

        return result;
    }

    private void validateArgumentsOfRandomStrings() {
        if (this.minlength <= 0) {
            this.fObj.addError(this.def.fieldApiName,
                'The minimum length should be greater than or equal to 1 in definition [' +
                this.def.definitionString + ']');
        }

        if (this.minlength > this.maxlength) {
            this.fObj.addError(this.def.fieldApiName,
                'The minimum length should be less than or equal to the maximum length in definition [' +
                this.def.definitionString + ']');
        }
    }

}