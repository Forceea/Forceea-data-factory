/*
  Forceea data factory (v2.2.0)
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
public with sharing class ForceeaAddress {

    public String street { get; set; }
    public String postalCode { get; set; }
    public String city { get; set; }
    public String state { get; set; }
    public String country { get; set; }

    public ForceeaAddress(String street, String postalCode, String city, String state, String country) {
        this.street = street;
        this.city = city;
        this.postalCode = postalCode;
        this.state = state;
        this.country = country;
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
        if (!FObject.addressesLibrary.isEmpty()) {
            return;
        }

        FObject.streetNumberGoesAfterStreet = true;
        String country = 'Ελλάδα';

        FObject.addressesLibrary.add(
            new ForceeaAddress('Αγγελάκη', '54636', 'Θεσσαλονίκη', '', country));
        FObject.addressesLibrary.add(
            new ForceeaAddress('Αγίας Σοφίας', '54622', 'Θεσσαλονίκη', '', country));
        FObject.addressesLibrary.add(
            new ForceeaAddress('Αγίου Ανδρέα', '26221', 'Πάτρα', '', country));
        FObject.addressesLibrary.add(
            new ForceeaAddress('Ακαδημίας', '10671', 'Αθήνα', '', country));
        FObject.addressesLibrary.add(
            new ForceeaAddress('Βασιλέως Κωνσταντίνου', '15122', 'Αθήνα', '', country));
        FObject.addressesLibrary.add(
            new ForceeaAddress('Βησσαρίωνος', '10672', 'Αθήνα', '', country));
        FObject.addressesLibrary.add(
            new ForceeaAddress('Γεωργίου Κασιμάτη', '18531', 'Πειραιάς', '', country));
        FObject.addressesLibrary.add(
            new ForceeaAddress('Ερμού', '10551', 'Αθήνα', '', country));
        FObject.addressesLibrary.add(
            new ForceeaAddress('Ερμού', '15124', 'Μαρούσι', '', country));
        FObject.addressesLibrary.add(
            new ForceeaAddress('Ερμού', '26221', 'Πάτρα', '', country));
        FObject.addressesLibrary.add(
            new ForceeaAddress('Ερυθρού Σταυρού', '15123', 'Μαρούσι', '', country));
        FObject.addressesLibrary.add(
            new ForceeaAddress('Ηροδότου', '10673', 'Αθήνα', '', country));
        FObject.addressesLibrary.add(
            new ForceeaAddress('Ηρώων Πολυτεχνείου', '18536', 'Πειραιάς', '', country));
        FObject.addressesLibrary.add(
            new ForceeaAddress('Ιλισίων', '14564', 'Κηφισιά', '', country));
        FObject.addressesLibrary.add(
            new ForceeaAddress('Κολοκοτρώνη', '14562', 'Κηφισιά', '', country));
        FObject.addressesLibrary.add(
            new ForceeaAddress('Κομνηνών', '54624', 'Θεσσαλονίκη', '', country));
        FObject.addressesLibrary.add(
            new ForceeaAddress('Κομνηνών', '54624', 'Θεσσαλονίκη', '', country));
        FObject.addressesLibrary.add(
            new ForceeaAddress('Λεβίδου', '14562', 'Κηφισιά', '', country));
        FObject.addressesLibrary.add(
            new ForceeaAddress('Λεωφόρος Πεντέλης', '15235', 'Βριλήσσια', '', country));
        FObject.addressesLibrary.add(
            new ForceeaAddress('Μητροπόλεως', '10563', 'Αθήνα', '', country));
        FObject.addressesLibrary.add(
            new ForceeaAddress('Μητροπόλεως', '54624', 'Θεσσαλονίκη', '', country));
        FObject.addressesLibrary.add(
            new ForceeaAddress('Μιχαλακοπούλου', '26223', 'Πάτρα', '', country));
        FObject.addressesLibrary.add(
            new ForceeaAddress('Παύλου Μελά ', '54621', 'Θεσσαλονίκη', '', country));
        FObject.addressesLibrary.add(
            new ForceeaAddress('Πολυτεχνείου', '54626', 'Θεσσαλονίκη', '', country));
        FObject.addressesLibrary.add(
            new ForceeaAddress('Σοφοκλέους', '10235', 'Αθήνα', '', country));
        FObject.addressesLibrary.add(
            new ForceeaAddress('Σποράδων', '11361', 'Αθήνα', '', country));
        FObject.addressesLibrary.add(
            new ForceeaAddress('Σταδίου', '10252', 'Αθήνα', '', country));
        FObject.addressesLibrary.add(
            new ForceeaAddress('Στουρνάρα', '10432', 'Αθήνα', '', country));
        FObject.addressesLibrary.add(
            new ForceeaAddress('Τσιμισκή', '54623', 'Θεσσαλονίκη', '', country));
        FObject.addressesLibrary.add(
            new ForceeaAddress('Φιλικής Εταιρίας', '18539', 'Πειραιάς', '', country));

        FObject.forceeaStaticDebug(ForceeaService.INFO,
            ForceeaService.MESSAGE_ADDRESSES + 'Greece in the Greek language');
    }

    /**
     * @description Load addresses from United States in English.
     */
    private static void loadAddressesFromUnitedStatesInEnglish() {
        if (!FObject.addressesLibrary.isEmpty()) {
            return;
        }

        FObject.streetNumberGoesAfterStreet = false;
        String country = 'United States';

        FObject.addressesLibrary.add(
            new ForceeaAddress('N Main Ave', '10013', 'New York', 'NY', country));
        FObject.addressesLibrary.add(
            new ForceeaAddress('Lawton St', '10013', 'New York', 'NY', country));
        FObject.addressesLibrary.add(
            new ForceeaAddress('Broadway', '10007', 'New York', 'NY', country));
        FObject.addressesLibrary.add(
            new ForceeaAddress('Outwater Ln', '92126', 'San Diego', 'CA', country));
        FObject.addressesLibrary.add(
            new ForceeaAddress('Fenton Parkway', '92108', 'San Diego', 'CA', country));
        FObject.addressesLibrary.add(
            new ForceeaAddress('Metropolitan Dr', '90021', 'Los Angeles', 'CA', country));
        FObject.addressesLibrary.add(
            new ForceeaAddress('Hawthorne Street', '94105', 'San Francisco', 'CA', country));
        FObject.addressesLibrary.add(
            new ForceeaAddress('Delancey Pl', '19103', 'Philadelphia', 'PA', country));
        FObject.addressesLibrary.add(
            new ForceeaAddress('Spring Garden St', '19130', 'Philadelphia', 'PA', country));
        FObject.addressesLibrary.add(
            new ForceeaAddress('Pennsylvania Avenue N.W.', '20004', 'Washington', 'DC', country));
        FObject.addressesLibrary.add(
            new ForceeaAddress('West Jackson Boulevard', '60604', 'Chicago', 'IL', country));

        FObject.forceeaStaticDebug(ForceeaService.INFO,
            ForceeaService.MESSAGE_ADDRESSES + 'United States in the English language');
    }

}
