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
public with sharing class ForceeaName {

    public String FirstName { get; set; }
    public String LastName { get; set; }
    public String Gender { get; set; }

    public ForceeaName() {
        this.FirstName = '';
        this.LastName = '';
        this.Gender = '';
    }

    public ForceeaName(String firstName, String lastName, String gender) {
        this.FirstName = firstName;
        this.LastName = lastName;
        this.Gender = gender;
    }

    /* METHODS */

    /**
     * @description Loads names based on language and locality.
     */
    public static void loadNames() {
        String language = FObject.getGlobalLanguage().toLowerCase();
        String locality = FObject.getGlobalLocality().toLowerCase();

        if (locality == 'greece' && language == 'greek') {
            loadNamesFromGreeceInGreek();
        } else {
            loadNamesFromUnitedStatesInEnglish();
        }
    }

    /**
     * @description Load names from Greece in Greek.
     */
    private static void loadNamesFromGreeceInGreek() {
        String gender = '';

        // do nothing if it's already loaded
        if (!FObject.lastNamesLibraryByGender.isEmpty()) {
            return;
        }

        // female names
        gender = 'f';
        List<String> fFirstNames = new List<String>{ // add 50 first names
            'Νάντια', 'Διονυσία', 'Τάνια', 'Αδαμαντία', 'Αλίκη', 'Βασιλική', 'Φανή', 'Καίτη', 'Χρύσα', 'Μάγδα', 'Ηλιάνα',
            'Όλγα', 'Γεωργία', 'Μαριάνθη', 'Άρτεμις', 'Άντζελα', 'Στέλλα', 'Ζωή', 'Ανθή', 'Ευθυμία', 'Αγγελική', 'Τόνια',
            'Ντίνα', 'Ρίτα', 'Ντόρα', 'Αλεξία', 'Παυλίνα', 'Ρένα', 'Σοφία', 'Στεφανία', 'Λένα', 'Τζίνα', 'Γιούλη', 'Νεκταρία',
            'Ρέα', 'Γιώτα', 'Λίζα', 'Ελένη', 'Άννα', 'Έλενα', 'Αικατερίνη', 'Ρούλα', 'Παναγιώτα',
            'Ευγενία', 'Εμμανουέλα', 'Μαριέττα', 'Μυρσίνη', 'Μαρκέλλα', 'Τριανταφυλλιά', 'Αφροδίτη'
        };
        List<String> fLastNames = new List<String>{ // add 200 last names
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
        FObject.firstNamesLibraryByGender.put(gender, fFirstNames);
        FObject.lastNamesLibraryByGender.put(gender, fLastNames);

        // male names
        gender = 'm';
        List<String> mFirstNames = new List<String>{ // add 50 first names
            'Αδάμ', 'Ευγένιος', 'Αλέκος', 'Νώντας', 'Φάνης', 'Αργύρης', 'Άλκης', 'Διαμαντής', 'Θάνος', 'Παύλος', 'Φίλιππος', 'Αλέξης', 'Γιώργος', 'Κώστας',
            'Μάρκος', 'Θωμάς', 'Νίκος', 'Δήμος', 'Θεοδόσης', 'Στάθης', 'Φώτης', 'Κυριάκος', 'Χάρης', 'Λάμπρος', 'Άγγελος', 'Πέτρος', 'Στράτος', 'Γρηγόρης',
            'Μανώλης', 'Τάσος', 'Μιχάλης', 'Αντώνης', 'Ανδρέας', 'Δημήτρης', 'Γιάννης', 'Βαγγέλης', 'Νικήτας', 'Ηλίας', 'Αχιλλέας', 'Σταύρος',
            'Παναγιώτης', 'Φαίδων', 'Σάββας', 'Βασίλης', 'Ορέστης', 'Νεκτάριος', 'Πάνος', 'Στέφανος', 'Θεόφιλος', 'Στέλιος'
        };
        List<String> mLastNames = new List<String>{ // add 200 last names
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
        FObject.firstNamesLibraryByGender.put(gender, mFirstNames);
        FObject.lastNamesLibraryByGender.put(gender, mLastNames);

        FObject.forceeaStaticDebug(ForceeaService.INFO, ForceeaService.MESSAGE_NAMES + ' Greece in the Greek language');
    }

    /**
     * @description Load names from United States in English.
     */
    private static void loadNamesFromUnitedStatesInEnglish() {
        String gender = '';

        // do nothing if it's already loaded
        if (!FObject.lastNamesLibraryByGender.isEmpty()) {
            return;
        }

        // female names
        gender = 'f';
        List<String> fFirstNames = new List<String>{ // add 50 first names
            'Tracey', 'Amelia', 'Leah', 'Nicola', 'Theresa', 'Sophie', 'Olivia', 'Sally', 'Wendy', 'Fiona',
            'Deirdre', 'Jane', 'Lillian', 'Abigail', 'Ella', 'Claire', 'Lauren', 'Bernadette', 'Karen', 'Vanessa',
            'Grace', 'Alison', 'Rachel', 'Heather', 'Ava', 'Wanda', 'Natalie', 'Victoria', 'Joan', 'Dorothy',
            'Una', 'Rebecca', 'Donna', 'Emma', 'Sarah', 'Sonia', 'Samantha', 'Lily', 'Bella', 'Penelope', 'Julia',
            'Caroline', 'Felicity', 'Anne', 'Faith', 'Diane', 'Sue', 'Joanne', 'Kylie', 'Jasmine'
        };
        List<String> fLastNames = new List<String>{ // add 200 last names
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
        FObject.firstNamesLibraryByGender.put(gender, fFirstNames);
        FObject.lastNamesLibraryByGender.put(gender, fLastNames);

        // male names
        gender = 'm';
        List<String> mFirstNames = new List<String>{ // add 50 first names
            'Sebastian', 'Boris', 'Andrew', 'Paul', 'Jake', 'Edward', 'Neil', 'Ryan', 'Christian', 'Ian', 'Max',
            'Gavin', 'Matt', 'Jonathan', 'Nicholas', 'Adam', 'Frank', 'Brandon', 'Julian', 'Richard', 'Steven',
            'Colin', 'James', 'Trevor', 'Anthony', 'Victor', 'Nathan', 'Adrian', 'John', 'Joshua', 'Stewart',
            'Kevin', 'David', 'Austin', 'Tim', 'Dominic', 'Robert', 'Jason', 'Connor', 'Evan', 'Joe', 'Sam',
            'Blake', 'Liam', 'Stephen', 'Thomas', 'Phil', 'Christopher', 'Lucas', 'Isaac'
        };
        List<String> mLastNames = new List<String>(fLastNames); // add 200 last names
        FObject.firstNamesLibraryByGender.put(gender, mFirstNames);
        FObject.lastNamesLibraryByGender.put(gender, mLastNames);

        FObject.forceeaStaticDebug(ForceeaService.INFO, ForceeaService.MESSAGE_NAMES + ' United States in the English language');
    }

}
