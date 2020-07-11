/*
  Forceea data factory (v2.1.0)
  Copyright (C) 2020 Nikos Mitrakis

  This program is free software: you can redistribute it and/or modify it under the terms
  of the GNU General Public License as published by the Free Software Foundation,
  either version 3 of the License, or any later version.

  This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
  without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  See the GNU General Public License for more details.

  You can find a copy of the GNU General Public License at
  https://github.com/nmitrakis/Forceea/blob/master/LICENSE
*/
@IsTest
public class ForceeaUtilityTest {

    public static Set<String> femaleFirstNames;
    public static Set<String> femaleLastNames;
    public static Set<String> maleFirstNames;
    public static Set<String> maleLastNames;

    /**
     * @description Validates the field definitions.
     * @param obj The FObject.
     * @param fieldApiName The field API name.
     * @param validDefinitions The list of valid definitions.
     * @param invalidDefinitions The list of invalid definitions.
     * @return A boolean value.
     */
    public static Boolean definitionsAreValid(
        FObject obj, String fieldApiName, List<String> validDefinitions, List<String> invalidDefinitions) {
        List<String> definitions = new List<String>(validDefinitions);
        definitions.addAll(invalidDefinitions);
        for (String definition : definitions) {
            obj.setDefinition(fieldApiName, definition);
        }

        obj.getRecords();

        String expectedResult = '';
        Integer counter = 0;
        Integer errors = 0;
        for (String actualResult : obj.getErrors().get(fieldApiName)) {
            if (!actualResult.startsWith('Invalid definition [') || !actualResult.contains('for the data type of field')) {
                continue;
            }
            expectedResult = 'Invalid definition [' + invalidDefinitions.get(counter) +
                '] for the data type of field [' + fieldApiName + ']';
            if (expectedResult == actualResult) {
                counter++;
            }
        }

        if (counter != invalidDefinitions.size()) {
            errors += 1;
        }
        if (!FObject.processIsValid()) {
            errors += 2;
        }
        return (errors == 0) ? true : false;
    }

    public static List<Id> getLookupIds(FObject obj) {
        List<Id> results = new List<Id>();

        for (FObjectTwo__c objRecord : (List<FObjectTwo__c>) obj.getInsertedRecords()) {
            results.add(objRecord.Id);
        }

        return results;
    }

    public static List<Id> getLookupIds(FObject obj, List<String> valuesToInclude) {
        List<Id> results = new List<Id>();

        for (FObjectTwo__c objRecord : (List<FObjectTwo__c>) obj.getInsertedRecords()) {
            if (valuesToInclude.contains(objRecord.TestText__c)) {
                results.add(objRecord.Id);
            }
        }

        return results;
    }

    public static List<Id> getLookupIdsFromIntegerUnique(FObject obj) {
        List<Id> results = new List<Id>();

        for (FObjectTwo__c objRecord : (List<FObjectTwo__c>) obj.getInsertedRecords()) {
            if (objRecord.TestIntegerUnique__c < 6) {
                results.add(objRecord.Id);
            }
        }

        return results;
    }

    public static Boolean insertedGroupRecordsAreValidForSameInstance(FObject obj, String group1, String group2) {
        List<FObjectOne__c> recordsA1 =
            (List<FObjectOne__c>) obj.getInsertedGroupRecords(group1.toUpperCase());
        List<FObjectOne__c> recordsA2 =
            (List<FObjectOne__c>) FObject.getInsertedGroupRecords(FObjectOne__c.SObjectType, group1.toLowerCase());

        List<FObjectOne__c> recordsB1 =
            (List<FObjectOne__c>) obj.getInsertedGroupRecords(group2.toUpperCase());
        List<FObjectOne__c> recordsB2 =
            (List<FObjectOne__c>) FObject.getInsertedGroupRecords(FObjectOne__c.SObjectType, group2.toLowerCase());

        List<FObjectOne__c> recordsInstanceBlank1 = (List<FObjectOne__c>) obj.getInsertedGroupRecords('');
        List<FObjectOne__c> recordsInstanceBlank2 = (List<FObjectOne__c>) obj.getInsertedGroupRecords(' ');
        List<FObjectOne__c> recordsInstanceBlank3 = (List<FObjectOne__c>) obj.getInsertedGroupRecords(null);
        List<FObjectOne__c> recordsInstanceBlank4 = (List<FObjectOne__c>) obj.getInsertedRecords();

        List<FObjectOne__c> recordsStaticBlank1 =
            (List<FObjectOne__c>) FObject.getInsertedGroupRecords(FObjectOne__c.SObjectType, '');
        List<FObjectOne__c> recordsStaticBlank2 =
            (List<FObjectOne__c>) FObject.getInsertedGroupRecords(FObjectOne__c.SObjectType, ' ');
        List<FObjectOne__c> recordsStaticBlank3 =
            (List<FObjectOne__c>) FObject.getInsertedGroupRecords(FObjectOne__c.SObjectType, null);
        List<FObjectOne__c> recordsStaticBlank4 =
            (List<FObjectOne__c>) FObject.getInsertedRecords(FObjectOne__c.SObjectType);

        Integer errors = 0;
        if (recordsA1.hashCode() != recordsA2.hashCode()) {
            errors += 1;
        }
        if (recordsB1.hashCode() != recordsB2.hashCode()) {
            errors += 2;
        }
        if (recordsInstanceBlank1.hashCode() != recordsInstanceBlank2.hashCode() &&
            recordsInstanceBlank2.hashCode() != recordsInstanceBlank3.hashCode() &&
            recordsInstanceBlank3.hashCode() != recordsInstanceBlank4.hashCode()
            ) {
            errors += 4;
        }
        if (recordsStaticBlank1.hashCode() != recordsStaticBlank2.hashCode() &&
            recordsStaticBlank2.hashCode() != recordsStaticBlank3.hashCode() &&
            recordsStaticBlank3.hashCode() != recordsStaticBlank4.hashCode()
            ) {
            errors += 8;
        }
        Integer expectedSize = obj.getNumberOfRecords();
        if (recordsA1.size() != expectedSize && recordsB1.size() != expectedSize &&
            recordsInstanceBlank4.size() != 2 * expectedSize && recordsStaticBlank4.size() != 2 * expectedSize
            ) {
            errors += 16;
        }
        if (!FObject.processIsValid()) {
            errors += 32;
        }

        return errors == 0;
    }

    public static Boolean insertedGroupRecordsAreValidForDifferentInstances(
        FObject obj1, FObject obj2, String group1, String group2) {
        List<FObjectOne__c> recordsA1 =
            (List<FObjectOne__c>) obj1.getInsertedGroupRecords(group1.toUpperCase());
        List<FObjectOne__c> recordsA2 =
            (List<FObjectOne__c>) FObject.getInsertedGroupRecords('FObjectOne__c', group1.toLowerCase());

        List<FObjectOne__c> recordsB1 =
            (List<FObjectOne__c>) obj2.getInsertedGroupRecords(group2.toUpperCase());
        List<FObjectOne__c> recordsB2 =
            (List<FObjectOne__c>) FObject.getInsertedGroupRecords('FObjectOne__c', group2.toLowerCase());

        List<FObjectOne__c> recordsInstanceBlank1 = (List<FObjectOne__c>) obj1.getInsertedRecords();
        List<FObjectOne__c> recordsInstanceBlank2 = (List<FObjectOne__c>) obj2.getInsertedRecords();
        List<FObjectOne__c> recordsStatic =
            (List<FObjectOne__c>) FObject.getInsertedRecords('FObjectOne__c');

        Integer errors = 0;
        for (Integer counter = 0; counter < recordsA1.size(); counter++) {
            if (recordsA1.get(counter).TestText__c != recordsB1.get(counter).TestText__c &&
                recordsA2.get(counter).TestText__c != recordsB2.get(counter).TestText__c &&
                recordsInstanceBlank1.get(counter).TestText__c != recordsInstanceBlank2.get(counter).TestText__c
                ) {
                errors++;
            }
        }

        Integer expectedSize1 = obj1.getNumberOfRecords();
        Integer expectedSize2 = obj2.getNumberOfRecords();
        if (recordsA1.size() != expectedSize1 &&
            recordsB1.size() != expectedSize2 &&
            recordsStatic.size() != (expectedSize1 + expectedSize2)
            ) {
            errors += 512;
        }
        if (!FObject.processIsValid()) {
            errors += 1024;
        }

        return errors == 0;
    }

    /**
        * @description Validates the distribution of a field based on a specific list of String values.
        * @param fieldName The API name of the field.
        * @param values The assessed field values of type String.
        * @param records The list of SObject records to assess.
        * @return A boolean value.
        */
    public static Boolean isValidDistribution(String fieldName, List<String> values, List<SObject> records) {
        if (values.isEmpty() || records.isEmpty()) {
            return false;
        }

        Boolean result = true;
        Set<String> valuesSet = new Set<String>(values);

        // the number of times each unique item was found in the values list
        Map<String, Integer> frequenciesMap = new Map<String, Integer>();
        // the expected average of each unique item of the values list
        Map<String, Decimal> expectedAveragesMap = new Map<String, Decimal>();
        // the number of times each unique item of the values list was found in the records list
        Map<String, Integer> occurrencesMap = new Map<String, Integer>();

        // initialize maps
        for (String value : valuesSet) {
            frequenciesMap.put(value, 0);
            expectedAveragesMap.put(value, 0);
            occurrencesMap.put(value, 0);
        }

        // populate frequencies map
        for (String value : values) {
            frequenciesMap.put(value, frequenciesMap.get(value) + 1);
        }

        // populate expected averages map
        Decimal val = 0;
        for (String value : valuesSet) {
            val = Decimal.valueOf(frequenciesMap.get(value)) / values.size();
            expectedAveragesMap.put(value, val);
        }

        // populate occurrences map
        String valueToString = '';
        for (SObject record : records) {
            valueToString = String.valueOf(record.get(fieldName));

            if (valuesSet.contains(valueToString)) {
                occurrencesMap.put(valueToString, occurrencesMap.get(valueToString) + 1);
            }
        }

        // assess any deviations
        if (valuesSet.size() == 1) {
            if (occurrencesMap.get(values[0]) != records.size()) {
                result = false;
            }
        } else {
            Decimal expectedAverage = 0;
            Decimal actualAverage = 0;
            for (String value : valuesSet) {
                expectedAverage = expectedAveragesMap.get(value);
                actualAverage = Decimal.valueOf(occurrencesMap.get(value)) / records.size();

                if (actualAverage < (0.10 * expectedAverage) || actualAverage > (2 * expectedAverage)) {
                    result = false;
                    break;
                }
            }
        }

        return result;
    }

    /**
     * @description Validates the distribution of a field based on a specific list of Datetime values.
     * @param fieldName The API name of the field.
     * @param values The assessed field values of type Datetime.
     * @param records The list of SObject records to assess.
     * @return A boolean value.
     */
    public static Boolean isValidDistribution(String fieldName, List<Datetime> values, List<SObject> records) {
        if (values.isEmpty() || records.isEmpty()) {
            return false;
        }

        Boolean result = true;
        Set<Datetime> valuesSet = new Set<Datetime>(values);

        // the number of times each unique item was found in the values list
        Map<Datetime, Integer> frequenciesMap = new Map<Datetime, Integer>();
        // the expected average of each unique item of the values list
        Map<Datetime, Decimal> expectedAveragesMap = new Map<Datetime, Decimal>();
        // the number of times each unique item of the values list was found in the records list
        Map<Datetime, Integer> occurrencesMap = new Map<Datetime, Integer>();

        // initialize maps
        for (Datetime value : valuesSet) {
            frequenciesMap.put(value, 0);
            expectedAveragesMap.put(value, 0);
            occurrencesMap.put(value, 0);
        }

        // populate frequencies map
        for (Datetime value : values) {
            frequenciesMap.put(value, frequenciesMap.get(value) + 1);
        }

        // populate expected averages map
        Decimal val = 0;
        for (Datetime value : valuesSet) {
            val = Decimal.valueOf(frequenciesMap.get(value)) / values.size();
            expectedAveragesMap.put(value, val);
        }

        // populate occurrences map
        Datetime valueToDatetime;
        for (SObject record : records) {
            valueToDatetime = (Datetime) record.get(fieldName);
            if (valuesSet.contains(valueToDatetime)) {
                occurrencesMap.put(valueToDatetime, occurrencesMap.get(valueToDatetime) + 1);
            }
        }

        // assess any deviations
        if (valuesSet.size() == 1) {
            if (occurrencesMap.get(values[0]) != records.size()) {
                result = false;
            }
        } else {
            Decimal expectedAverage = 0;
            Decimal actualAverage = 0;
            for (Datetime value : valuesSet) {
                expectedAverage = expectedAveragesMap.get(value);
                actualAverage = Decimal.valueOf(occurrencesMap.get(value)) / records.size();
                if (actualAverage < (0.1 * expectedAverage) || actualAverage > (2 * expectedAverage)) {
                    result = false;
                    break;
                }
            }
        }

        return result;
    }

    /**
     * @description Validates the distribution of a field based on a specific list of Integer values.
     * @param fieldName The API name of the field.
     * @param values The assessed field values of type Id.
     * @param records The list of SObject records to assess.
     * @return A boolean value.
     */
    public static Boolean isValidDistribution(String fieldName, List<Id> values, List<SObject> records) {
        List<String> valuesToString = new List<String>();

        for (Id value : values) {
            valuesToString.add(String.valueOf(value));
        }

        return isValidDistribution(fieldName, valuesToString, records);
    }

    public static void loadNamesFromGreeceInGreek() {
        femaleFirstNames = new Set<String>{
            'Νάντια', 'Διονυσία', 'Τάνια', 'Αδαμαντία', 'Αλίκη', 'Βασιλική', 'Φανή', 'Καίτη', 'Χρύσα', 'Μάγδα', 'Ηλιάνα',
            'Όλγα', 'Γεωργία', 'Μαριάνθη', 'Άρτεμις', 'Άντζελα', 'Στέλλα', 'Ζωή', 'Ανθή', 'Ευθυμία', 'Αγγελική', 'Τόνια',
            'Ντίνα', 'Ρίτα', 'Ντόρα', 'Αλεξία', 'Παυλίνα', 'Ρένα', 'Σοφία', 'Στεφανία', 'Λένα', 'Τζίνα', 'Γιούλη', 'Νεκταρία',
            'Ρέα', 'Γιώτα', 'Λίζα', 'Ελένη', 'Άννα', 'Έλενα', 'Αικατερίνη', 'Ρούλα', 'Παναγιώτα',
            'Ευγενία', 'Εμμανουέλα', 'Μαριέττα', 'Μυρσίνη', 'Μαρκέλλα', 'Τριανταφυλλιά', 'Αφροδίτη'
        };
        femaleLastNames = new Set<String>{
            'Βαλαέτη', 'Σφακάκη', 'Καλογιάννη', 'Παυλίδου', 'Οικονόμου', 'Ανέστου', 'Κολάρου', 'Θανασούλια', 'Μωραίτη',
            'Κανατούλα', 'Τσιλιδέλου', 'Ανάγνου', 'Μαρινέα', 'Πατέρου', 'Μυρτσίδου', 'Μποτονάκη', 'Μυλωνάκη', 'Αρβανίτη',
            'Κυριαζή', 'Πασχαλίδη', 'Καμηλιέρη', 'Παπαμιχάλη', 'Σούρτζη', 'Κωφοτόλη', 'Μακρίδου', 'Γιαννιού', 'Λεοτσάκου',
            'Ζακυνθινού', 'Τσιγαρίδα', 'Σαββάκη', 'Καρτσιώτου', 'Μπενάκη', 'Γκυτάκου', 'Πολυζώη', 'Σταθάκου', 'Κουμουτσέα',
            'Πανίτσα', 'Κυριακάκου', 'Αναγνώστου', 'Πουρναράκη', 'Μαυρωνά', 'Μητακίδου', 'Γρηγοράτου', 'Στεφανάκη',
            'Κορνελάτου', 'Καλλινίκου', 'Καρανάσου', 'Τσιντέα', 'Τζεβελέκου', 'Γεωργίου', 'Δημουλά', 'Ξηρουχάκη', 'Λουκανίδου',
            'Κυνηγαλάκη', 'Κιοβρέκη', 'Μιαούλη', 'Σαραμπάλου', 'Μεταλλίδου', 'Κατσαρού', 'Απιδιανάκη', 'Κολέτου', 'Μανανδράκη',
            'Βαφειάδου', 'Αξιάρχου', 'Κωσταλούπη', 'Αλεξιάδου', 'Αντωνένα', 'Νικολαϊδου', 'Ιγγλέζου', 'Δημοπούλου', 'Πελεκάνου',
            'Θεοδωράκη', 'Πορτίδου', 'Γιαννακού', 'Νανοπούλου', 'Θεριανού', 'Σουσώνη', 'Τσακμακλή', 'Τριλιούρη', 'Πιτσιλαδή',
            'Τσαχάκη', 'Τραγάκη', 'Θεολογίτη', 'Αλεβίζου', 'Γιαννακάκη', 'Κοπάνου', 'Ζωγράφου', 'Αναστάση', 'Μαλλιάπη',
            'Τσουμπρή', 'Πιτσίκα', 'Τζουμάκα', 'Αδριανή', 'Αλλιζώτη', 'Καραμάνου', 'Συκινιώτη', 'Κοτσίρη', 'Γιαλαμά', 'Τσιτσινάκη',
            'Τσαβάλου', 'Σκοτίδη', 'Σταύρου', 'Ανδρέου', 'Ζορμπάνου', 'Ζηνοπούλου', 'Κοροσίδου', 'Σκαλάτη', 'Λογοθέτη',
            'Ιακωβίδου', 'Βαρζακάκου', 'Αμπατζή', 'Γκιουλέα', 'Κουταβά', 'Μερκουρίου', 'Κυρίτση', 'Καζεπίδου', 'Μαμιδάκη',
            'Κουμπούρη', 'Ελευθεράκη', 'Αντωνιάδου', 'Φωτακέλη', 'Χριστοφίλη', 'Κομηνέα', 'Καφετζή', 'Πολεμίτου', 'Λαλιώτη',
            'Γεωργούση', 'Γιόκαλα', 'Ορφανού', 'Αφαντίτη', 'Κασιμάτη', 'Καψουλάκη', 'Κωτσοβού', 'Παντάκη', 'Ραπτάκη', 'Κουτσιάφτη',
            'Καλλέργη', 'Μπορμπιλά', 'Φρέντζα', 'Τσισκάκη', 'Ιωάννου', 'Βιλλιώτη', 'Καλογερά', 'Λαμπρίδου', 'Βολιώτου',
            'Φουσέκη', 'Βαρσάμη', 'Πίκουλα', 'Καμπουρίδη', 'Χανιώτη', 'Κληρονόμου', 'Σούλτου', 'Αποστολου', 'Νεράντζη', 'Μπαμίχα',
            'Μαρίνου', 'Χαμπέρη', 'Γαλάτουλα', 'Αλεξάτου', 'Καραμιχάλη', 'Λαζάρου', 'Αργυράκη', 'Παπασπύρου', 'Καταξένου',
            'Γιαβριμη', 'Δαλέκου', 'Ρεμαντά', 'Ελσούκαρη', 'Μαυροζούμη', 'Τσεκούρα', 'Τρουπάκη', 'Βλασσιάδου', 'Παρλάντζα',
            'Αμπαριώτη', 'Βερικάκη', 'Παπακώστα', 'Διαμαντή', 'Θεοδώρου', 'Κυριακίδου', 'Κανέλλη', 'Μπετέκου', 'Νταουντάκη',
            'Ανδρεαδάκη', 'Κουτσοκέρη', 'Πούλιου', 'Παπατρύφων', 'Πιεράτου', 'Νεκταρίου', 'Μπάμπαλη', 'Κλωθάκη', 'Νταλάκα',
            'Πανέτσου', 'Φράνγκου', 'Χρυσάνη', 'Αλιφραγκή', 'Μητρέλλου', 'Μηλιώνη', 'Αθανασίου', 'Ριζούδη', 'Τζανετή'
        };
        maleFirstNames = new Set<String>{
            'Αδάμ', 'Ευγένιος', 'Αλέκος', 'Νώντας', 'Φάνης', 'Αργύρης', 'Άλκης', 'Διαμαντής', 'Θάνος', 'Παύλος', 'Φίλιππος', 'Αλέξης', 'Γιώργος', 'Κώστας',
            'Μάρκος', 'Θωμάς', 'Νίκος', 'Δήμος', 'Θεοδόσης', 'Στάθης', 'Φώτης', 'Κυριάκος', 'Χάρης', 'Λάμπρος', 'Άγγελος', 'Πέτρος', 'Στράτος', 'Γρηγόρης',
            'Μανώλης', 'Τάσος', 'Μιχάλης', 'Αντώνης', 'Ανδρέας', 'Δημήτρης', 'Γιάννης', 'Βαγγέλης', 'Νικήτας', 'Ηλίας', 'Αχιλλέας', 'Σταύρος',
            'Παναγιώτης', 'Φαίδων', 'Σάββας', 'Βασίλης', 'Ορέστης', 'Νεκτάριος', 'Πάνος', 'Στέφανος', 'Θεόφιλος', 'Στέλιος'
        };
        maleLastNames = new Set<String>{
            'Ψαλτήρας', 'Κονδύλης', 'Μοσχοβής', 'Κολώνιας', 'Μουρίκης', 'Μερτύκας', 'Χαρατσής', 'Μανιάτης', 'Τσιλίκης', 'Ταπάκης', 'Μανίκας', 'Χάλαρης',
            'Πούρνος', 'Κυρίδης', 'Ρέμπελος', 'Θανασάς', 'Τρυφέρης', 'Παράσχος', 'Κουρελάς', 'Νταλάκας', 'Μπίλιας', 'Σκαφίδας', 'Ψυράκης', 'Πανούσης',
            'Χαλικάς', 'Προβατάς', 'Λουκέρης', 'Καρλάκης', 'Τσαμάτης', 'Σέρτσος', 'Πλυμένος', 'Κολόνιας', 'Ηλιάδης', 'Σουλελές', 'Μαγουλάς', 'Λαζάρου',
            'Ταμβάκης', 'Δαμίγος', 'Ρομπότης', 'Σιγάλας', 'Μαλούχος', 'Περωτής', 'Μπούρας', 'Ταλούμης', 'Κρικώνης', 'Στάνιος', 'Γεράκης', 'Δούσσης',
            'Ντότσιας', 'Απέργης', 'Μπουζούμης', 'Ντάλλας', 'Πασσάκος', 'Μονιώδης', 'Βίλλιος', 'Μασσώνος', 'Γαβριήλ', 'Μάκαρης', 'Γαρμπής', 'Κοφινάς',
            'Μεγρέμης', 'Τομάζος', 'Λυριτζής', 'Τζαβάρας', 'Μπογρής', 'Λούτσος', 'Μπαδήμας', 'Κούμενος', 'Μύταρος', 'Μοσχάκης', 'Ντούλιας', 'Μπολάκης',
            'Δουλφής', 'Πατρώνας', 'Χαραμής', 'Παριάρος', 'Περβανάς', 'Κοσμίδης', 'Γκρέκος', 'Κόκκορης', 'Αρματάς', 'Μικέδης', 'Βιδάκης', 'Κυράνης',
            'Γόγωλος', 'Σαγκρής', 'Σκιαδάς', 'Γκίλλας', 'Σπανάκος', 'Τσιγάρας', 'Μικέλης', 'Πούμπρος', 'Φασόλης', 'Περράκης', 'Μπατζής', 'Ζαμάνης',
            'Κεχαγιάς', 'Δάουλας', 'Χαλιώτης', 'Γκιόκας', 'Μούρτζης', 'Ζαφύρης', 'Χρυσοχός', 'Λιόλιος', 'Μαρκάζος', 'Δόμινος', 'Παπαδιάς', 'Κοκότσης',
            'Τζώρτζης', 'Μαρουλής', 'Γατζίας', 'Φιορέτος', 'Μεϊδάνης', 'Χαιρέτης', 'Τομαράς', 'Λιάππης', 'Κεράνης', 'Μαμουνάς', 'Χασόγιας', 'Ντόκορος',
            'Κρασσάς', 'Σεραφείμ', 'Σκορδάς', 'Τεκέδης', 'Μανάφας', 'Γκλαβάς', 'Μπονίκος', 'Κάτσικας', 'Μπάκνης', 'Λέτσιος', 'Μαγιάτης', 'Ζιούβας',
            'Αχτίδας', 'Κλωνάρης', 'Τσότσος', 'Ριζάκης', 'Σιούλας', 'Παρμαξής', 'Κωλέτας', 'Στεφανής', 'Πανάγος', 'Πουλάκος', 'Λιούνης', 'Τραυλός',
            'Χαλικιάς', 'Σακέτος', 'Σοκόλης', 'Τσομώκος', 'Φωτίδας', 'Κούσκος', 'Καραβάς', 'Κρεμύδας', 'Δελόνας', 'Κιούπης', 'Ζαράνης', 'Φινδάνης',
            'Δαβιλάς', 'Λακιώτης', 'Σκόδρας', 'Κατσώλης', 'Κορκολής', 'Γρίτσης', 'Μπουρνής', 'Ντάφλος', 'Κολλιός', 'Μπολάνης', 'Αγγέλου', 'Καστανάς',
            'Λεμονής', 'Μπόκτορ', 'Μαργώνης', 'Καράπας', 'Περλεπές', 'Κούβαρης', 'Κιτσάκης', 'Πανoύσης', 'Καραλής', 'Καβύρης', 'Μωρέλας', 'Διβόλης',
            'Φραντζής', 'Κούκιας', 'Λελάκης', 'Δρούγας', 'Ζαρίφης', 'Στασινός', 'Φυλακτός', 'Ζερεφός', 'Κοντάκος', 'Αρμύρος', 'Μπαλλής', 'Μυλωνάς',
            'Παΐσιος', 'Χαλμπές', 'Καψάλας', 'Τσιόγκας', 'Στεφάνου', 'Τσούμπας', 'Σμυρνής', 'Συράκος'
        };
    }

    public static void loadNamesFromUnitesStatesInEnglish() {
        femaleFirstNames = new Set<String>{
            'Tracey', 'Amelia', 'Leah', 'Nicola', 'Theresa', 'Sophie', 'Olivia', 'Sally', 'Wendy', 'Fiona',
            'Deirdre', 'Jane', 'Lillian', 'Abigail', 'Ella', 'Claire', 'Lauren', 'Bernadette', 'Karen', 'Vanessa',
            'Grace', 'Alison', 'Rachel', 'Heather', 'Ava', 'Wanda', 'Natalie', 'Victoria', 'Joan', 'Dorothy',
            'Una', 'Rebecca', 'Donna', 'Emma', 'Sarah', 'Sonia', 'Samantha', 'Lily', 'Bella', 'Penelope', 'Julia',
            'Caroline', 'Felicity', 'Anne', 'Faith', 'Diane', 'Sue', 'Joanne', 'Kylie', 'Jasmine'
        };
        femaleLastNames = new Set<String>{
            'Smith', 'Johnson', 'Williams', 'Jones', 'Brown', 'Davis', 'Miller', 'Wilson', 'Moore', 'Taylor',
            'Anderson', 'Thomas', 'Jackson', 'White', 'Harris', 'Martin', 'Thompson', 'Garcia', 'Martinez',
            'Robinson', 'Clark', 'Rodriguez', 'Lewis', 'Lee', 'Walker', 'Hall', 'Allen', 'Young', 'Hernandez',
            'King', 'Wright', 'Lopez', 'Hill', 'Scott', 'Green', 'Adams', 'Baker', 'Gonzalez', 'Nelson', 'Carter',
            'Mitchell', 'Perez', 'Roberts', 'Turner', 'Phillips', 'Campbell', 'Parker', 'Evans', 'Edwards',
            'Collins', 'Stewart', 'Sanchez', 'Morris', 'Rogers', 'Reed', 'Cook', 'Morgan', 'Bell', 'Murphy',
            'Bailey', 'Rivera', 'Cooper', 'Richardson', 'Cox', 'Howard', 'Ward', 'Torres', 'Peterson', 'Gray',
            'Ramirez', 'James', 'Watson', 'Brooks', 'Kelly', 'Sanders', 'Price', 'Bennett', 'Wood', 'Barnes',
            'Ross', 'Henderson', 'Coleman', 'Jenkins', 'Perry', 'Powell', 'Long', 'Patterson', 'Hughes', 'Flores',
            'Washington', 'Butler', 'Simmons', 'Foster', 'Gonzales', 'Bryant', 'Alexander', 'Russell', 'Griffin',
            'Diaz', 'Hayes', 'Myers', 'Ford', 'Hamilton', 'Graham', 'Sullivan', 'Wallace', 'Woods', 'Cole', 'West',
            'Jordan', 'Owens', 'Reynolds', 'Fisher', 'Ellis', 'Harrison', 'Gibson', 'Mcdonald', 'Cruz', 'Marshall',
            'Ortiz', 'Gomez', 'Murray', 'Freeman', 'Wells', 'Webb', 'Simpson', 'Stevens', 'Tucker', 'Porter',
            'Hunter', 'Hicks', 'Crawford', 'Henry', 'Boyd', 'Mason', 'Morales', 'Kennedy', 'Warren', 'Dixon',
            'Ramos', 'Reyes', 'Burns', 'Gordon', 'Shaw', 'Holmes', 'Rice', 'Robertson', 'Hunt', 'Black', 'Daniels',
            'Palmer', 'Mills', 'Nichols', 'Grant', 'Knight', 'Ferguson', 'Rose', 'Stone', 'Hawkins', 'Dunn',
            'Perkins', 'Hudson', 'Spencer', 'Gardner', 'Stephens', 'Payne', 'Pierce', 'Berry', 'Matthews', 'Arnold',
            'Wagner', 'Willis', 'Ray', 'Watkins', 'Olson', 'Carroll', 'Duncan', 'Snyder', 'Hart', 'Cunningham',
            'Bradley', 'Lane', 'Andrews', 'Ruiz', 'Harper', 'Fox', 'Riley', 'Armstrong', 'Carpenter', 'Weaver',
            'Greene', 'Lawrence', 'Elliott', 'Chavez', 'Sims', 'Austin', 'Peters', 'Kelley', 'Franklin', 'Lawson'
        };
        maleFirstNames = new Set<String>{
            'Sebastian', 'Boris', 'Andrew', 'Paul', 'Jake', 'Edward', 'Neil', 'Ryan', 'Christian', 'Ian', 'Max',
            'Gavin', 'Matt', 'Jonathan', 'Nicholas', 'Adam', 'Frank', 'Brandon', 'Julian', 'Richard', 'Steven',
            'Colin', 'James', 'Trevor', 'Anthony', 'Victor', 'Nathan', 'Adrian', 'John', 'Joshua', 'Stewart',
            'Kevin', 'David', 'Austin', 'Tim', 'Dominic', 'Robert', 'Jason', 'Connor', 'Evan', 'Joe', 'Sam',
            'Blake', 'Liam', 'Stephen', 'Thomas', 'Phil', 'Christopher', 'Lucas', 'Isaac'
        };
        maleLastNames = new Set<String>(femaleLastNames);
    }

    /**
     * @description Validates the update of created records.
     * @param records The updated records.
     * @param updatedValue The value of the updated field.
     * @return A boolean value.
     */
    public static Boolean updateIsValidForCreatedRecords(List<FObjectOne__c> records, String updatedValue) {
        Boolean result = false;
        Integer errors = 0;
        Integer counter = 1;

        for (FObjectOne__c record : records) {
            if ((record.TestText__c != updatedValue && record.TestText__c != updatedValue + String.valueOf(counter))
                || String.isEmpty(record.TestTextRequired__c)) {
                errors++;
            }
            counter++;
        }

        if (errors == 0 && FObject.processIsValid()) {
            result = true;
        }

        return result;
    }

    /**
     * @description Validates the update of inserted records.
     * @param groupName The group name.
     * @param updatedValue The value of the updated field.
     * @return A boolean value.
     */
    public static Boolean updateIsValidForInsertedRecords(String groupName, String updatedValue) {
        Boolean result = false;
        Integer errors = 0;
        Integer counter = 1;

        List<FObjectOne__c> records = (List<FObjectOne__c>) FObject.getInsertedGroupRecords(FObjectOne__c.SObjectType, groupName);
        for (FObjectOne__c record : records) {
            String updatedWithNumberValue = updatedValue + String.valueOf(counter);
            if ((record.TestText__c != updatedValue && record.TestText__c != updatedWithNumberValue) ||
                String.isEmpty(record.TestTextRequired__c)) {
                errors++;
            }
            counter++;
        }

        if (errors == 0 && FObject.processIsValid()) {
            result = true;
        }

        return result;
    }

}
