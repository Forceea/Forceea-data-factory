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
 * @description Handles the addresses.
 */
public with sharing class ForceeaAddress {

    /* CONSTANTS */

    private static final String MESSAGE_ADDRESSES = 'Loaded addresses from ';

    /* STATIC COLLECTIONS */

    /**
     * @description The library of addresses.
     */
    public static List<ForceeaAddress> addresses = new List<ForceeaAddress>();
    /**
     * @description The libraries for first names - key: gender, value: first names
     */
    public static Map<String, List<String>> firstNamesLibraryByGender = new Map<String, List<String>>();
    /**
     * @description The libraries for last names - key: gender, value: last names
     */
    public static Map<String, List<String>> lastNamesLibraryByGender = new Map<String, List<String>>();

    /* INSTANCE VARIABLES & PROPERTIES */

    /**
     * @description The address city.
     */
    public String city { get; set; }
    /**
     * @description The address country.
     */
    public String country { get; set; }
    /**
     * @description The address postal code.
     */
    public String postalCode { get; set; }
    /**
     * @description The address state.
     */
    public String state { get; set; }
    /**
     * @description The address street.
     */
    public String street { get; set; }

    /* CONSTRUCTORS */

    /**
     * @description The constructor for the class.
     * @param street The address street.
     * @param postalCode The address postal code.
     * @param city The address city.
     * @param state The address state.
     * @param country The address country.
     */
    public ForceeaAddress(String street, String postalCode, String city, String state, String country) {
        this.city = city;
        this.country = country;
        this.postalCode = postalCode;
        this.state = state;
        this.street = street;
    }

    /* METHODS */

    /**
     * @description Loads addresses based on language and locality.
     */
    public static void loadAddresses() {
        String language = FObject.getGlobalLanguage().toLowerCase();
        String locality = FObject.getGlobalLocality().toLowerCase();

        if (locality == 'greece' && language == 'greek') {
            loadAddressesFromGreeceInGreek();
        } else {
            loadAddressesFromUnitedStatesInEnglish();
        }
    }

    /**
     * @description Load addresses from Greece in Greek.
     */
    private static void loadAddressesFromGreeceInGreek() {
        if (!addresses.isEmpty()) {
            return;
        }

        FObject.streetNumberGoesAfterStreet = true;
        String country = 'Ελλάδα';

        addresses.add(
            new ForceeaAddress('Αγγελάκη', '54636', 'Θεσσαλονίκη', '', country));
        addresses.add(
            new ForceeaAddress('Αγίας Σοφίας', '54622', 'Θεσσαλονίκη', '', country));
        addresses.add(
            new ForceeaAddress('Αγίου Ανδρέα', '26221', 'Πάτρα', '', country));
        addresses.add(
            new ForceeaAddress('Ακαδημίας', '10671', 'Αθήνα', '', country));
        addresses.add(
            new ForceeaAddress('Βασιλέως Κωνσταντίνου', '15122', 'Αθήνα', '', country));
        addresses.add(
            new ForceeaAddress('Βησσαρίωνος', '10672', 'Αθήνα', '', country));
        addresses.add(
            new ForceeaAddress('Γεωργίου Κασιμάτη', '18531', 'Πειραιάς', '', country));
        addresses.add(
            new ForceeaAddress('Ερμού', '10551', 'Αθήνα', '', country));
        addresses.add(
            new ForceeaAddress('Ερμού', '15124', 'Μαρούσι', '', country));
        addresses.add(
            new ForceeaAddress('Ερμού', '26221', 'Πάτρα', '', country));
        addresses.add(
            new ForceeaAddress('Ερυθρού Σταυρού', '15123', 'Μαρούσι', '', country));
        addresses.add(
            new ForceeaAddress('Ηροδότου', '10673', 'Αθήνα', '', country));
        addresses.add(
            new ForceeaAddress('Ηρώων Πολυτεχνείου', '18536', 'Πειραιάς', '', country));
        addresses.add(
            new ForceeaAddress('Ιλισίων', '14564', 'Κηφισιά', '', country));
        addresses.add(
            new ForceeaAddress('Κολοκοτρώνη', '14562', 'Κηφισιά', '', country));
        addresses.add(
            new ForceeaAddress('Κομνηνών', '54624', 'Θεσσαλονίκη', '', country));
        addresses.add(
            new ForceeaAddress('Κομνηνών', '54624', 'Θεσσαλονίκη', '', country));
        addresses.add(
            new ForceeaAddress('Λεβίδου', '14562', 'Κηφισιά', '', country));
        addresses.add(
            new ForceeaAddress('Λεωφόρος Πεντέλης', '15235', 'Βριλήσσια', '', country));
        addresses.add(
            new ForceeaAddress('Μητροπόλεως', '10563', 'Αθήνα', '', country));
        addresses.add(
            new ForceeaAddress('Μητροπόλεως', '54624', 'Θεσσαλονίκη', '', country));
        addresses.add(
            new ForceeaAddress('Μιχαλακοπούλου', '26223', 'Πάτρα', '', country));
        addresses.add(
            new ForceeaAddress('Παύλου Μελά ', '54621', 'Θεσσαλονίκη', '', country));
        addresses.add(
            new ForceeaAddress('Πολυτεχνείου', '54626', 'Θεσσαλονίκη', '', country));
        addresses.add(
            new ForceeaAddress('Σοφοκλέους', '10235', 'Αθήνα', '', country));
        addresses.add(
            new ForceeaAddress('Σποράδων', '11361', 'Αθήνα', '', country));
        addresses.add(
            new ForceeaAddress('Σταδίου', '10252', 'Αθήνα', '', country));
        addresses.add(
            new ForceeaAddress('Στουρνάρα', '10432', 'Αθήνα', '', country));
        addresses.add(
            new ForceeaAddress('Τσιμισκή', '54623', 'Θεσσαλονίκη', '', country));
        addresses.add(
            new ForceeaAddress('Φιλικής Εταιρίας', '18539', 'Πειραιάς', '', country));

        FObject.forceeaDebugStatic(ForceeaService.INFO,
            MESSAGE_ADDRESSES + 'Greece in the Greek language');
    }

    /**
     * @description Load addresses from United States in English.
     */
    private static void loadAddressesFromUnitedStatesInEnglish() {
        if (!addresses.isEmpty()) {
            return;
        }

        FObject.streetNumberGoesAfterStreet = false;
        String country = 'United States';

        addresses.add(
            new ForceeaAddress('N Main Ave', '10013', 'New York', 'NY', country));
        addresses.add(
            new ForceeaAddress('Lawton St', '10013', 'New York', 'NY', country));
        addresses.add(
            new ForceeaAddress('Broadway', '10007', 'New York', 'NY', country));
        addresses.add(
            new ForceeaAddress('Outwater Ln', '92126', 'San Diego', 'CA', country));
        addresses.add(
            new ForceeaAddress('Fenton Parkway', '92108', 'San Diego', 'CA', country));
        addresses.add(
            new ForceeaAddress('Metropolitan Dr', '90021', 'Los Angeles', 'CA', country));
        addresses.add(
            new ForceeaAddress('Hawthorne Street', '94105', 'San Francisco', 'CA', country));
        addresses.add(
            new ForceeaAddress('Delancey Pl', '19103', 'Philadelphia', 'PA', country));
        addresses.add(
            new ForceeaAddress('Spring Garden St', '19130', 'Philadelphia', 'PA', country));
        addresses.add(
            new ForceeaAddress('Pennsylvania Avenue N.W.', '20004', 'Washington', 'DC', country));
        addresses.add(
            new ForceeaAddress('West Jackson Boulevard', '60604', 'Chicago', 'IL', country));

        FObject.forceeaDebugStatic(ForceeaService.INFO,
            MESSAGE_ADDRESSES + 'United States in the English language');
    }

}