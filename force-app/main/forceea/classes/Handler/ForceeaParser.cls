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
 * @description Parses a definition string
 */
@SuppressWarnings('PMD.FieldDeclarationsShouldBeAtStart')
public with sharing class ForceeaParser {

    /* CONSTANTS */

    private static final String LEFT_PARENTHESIS = '(';
    private static final String DOUBLE_QUOTES = '"';
    /**
     * @description The valid script commands
     */
    private static final List<String> COMMANDS = new List<String>{
        ForceeaService.COMMAND_COPY, ForceeaService.COMMAND_MOCK, ForceeaService.COMMAND_RANDOM,
        ForceeaService.COMMAND_SERIAL, ForceeaService.COMMAND_STATIC,
        ForceeaService.COMMAND_FUNCTION_ADD, ForceeaService.COMMAND_FUNCTION_CONVERT
    };

    /* INSTANCE VARIABLES & PROPERTIES */

    private Boolean commaExists { get; set; }
    private String ctrlFieldApiName { get; set; }
    private Integer ctrlFieldPosition { get; set; }
    private String dependentFieldApiName { get; set; }
    private Integer dependentFieldPosition { get; set; }
    private Integer doubleQuotesPosition { get; set; }
    private ForceeaDefinition def { get; set; }
    private final String errorMessage { get; set; }
    private final String fieldApiName { get; set; }
    private FObject fObj { get; set; }
    private Boolean hasError { get; set; }
    private Boolean mustContinue { get; set; }
    private String result { get; set; }

    /* STATIC COLLECTIONS */

    /**
     * @description the valid script parameters.
     */
    private static final Set<String> PARAMETERS = new Set<String>{
        'scale', 'except', 'field', 'format', 'from', 'group', 'include', 'lookup', 'maxlength', 'minlength', 'mode',
        'number', 'source', 'startwith', 'step', 'to', 'type', 'value', 'where'
    };

    /* INSTANCE COLLECTIONS */

    private List<String> arguments { get; set; }

    /* CONSTRUCTORS */

    /**
     * @description The constructor for the class.
     * @param fObj An FObject object.
     */
    public ForceeaParser(FObject fObj) {
        this.fObj = fObj;
        this.arguments = new List<String>();
        initializeVariables();
    }

    /**
     * @description The constructor for the class.
     * @param fObj An FObject object.
     * @param def A ForceeaDefinition object.
     */
    public ForceeaParser(FObject fObj, ForceeaDefinition def) {
        this(fObj);
        this.fieldApiName = def.fieldApiName;
        this.def = def;
        this.errorMessage = ForceeaService.MESSAGE_INVALID_DEFINITION + ' [' + this.def.definitionString + '] ' +
            'of field [' + this.fieldApiName + ']';
    }

    /* METHODS */

    private void addFieldInPosition(List<String> fields, String controllingFieldApiName, Integer position) {
        fields.add(position, controllingFieldApiName);
    }

    /**
     * @description Validates a definition command.
     * @param command The definition command.
     * @return A boolean value.
     */
    private Boolean commandIsValid(String command) {
        command = command.toLowerCase();

        for (String cmd : COMMANDS) {
            if (cmd == command) {
                return true;
            }
        }

        return false;
    }

    /**
     * @description Creates a new definition for the controlling field, before the definition of the dependent field.
     */
    private void createNewDefForContrFieldBeforeDefinitionOfDependent() {
        displayMessageWhenNotFoundDefForCtrlField();
        this.fObj.setDefinition(this.ctrlFieldApiName, null, true, this.fObj.isUpdate, 'random type(picklist)');
    }

    private Boolean ctrlFieldNotDefined() {
        return this.ctrlFieldPosition == -1;
    }

    private void displayMessageWhenCheckboxFieldNotSupported() {
        this.fObj.forceeaDebug(ForceeaService.WARN, 'The Checkbox field type is not supported ' +
            'for the controlling field of dependent field [' + this.dependentFieldApiName + ']');
    }

    private void displayMessageWhenDefIsValid() {
        if (def.isValid()) {
            this.fObj.forceeaDebug(ForceeaService.DEBUG, FObject.SYMBOL_SUCCESS + ' Definition [' + def.definitionString +
                '] of [' + def.fieldApiName + '] is valid with ID [' + def.definitionId + ']');
        }
    }

    private void displayMessageWhenDefWillBeValidated() {
        this.fObj.forceeaDebug(ForceeaService.DEBUG, FObject.MESSAGE_WILL_VALIDATE_FIELD_DEFINITIONS +
            ' of [' + this.fObj.sObjectApiName + ']');
    }

    private void displayMessageWhenMovedDefOfCtrlField() {
        this.fObj.forceeaDebug(ForceeaService.INFO, 'Moved definition of controlling field [' +
            this.ctrlFieldApiName + '] before definition of its dependent field [' +
            this.dependentFieldApiName + ']');
    }

    private void displayMessageWhenNotFoundDefForCtrlField() {
        this.fObj.forceeaDebug(ForceeaService.INFO, 'Did not find a definition for the controlling field [' +
            this.ctrlFieldApiName + '] of dependent field [' +
            this.dependentFieldApiName + '] and will generate a definition');
    }

    /**
     * @description Informs if the field has a controlling field.
     * @param field The System.LoggingLevel enum.
     * @return True, if the field has a controlling field.
     */
    private Boolean fieldHasControllingField(Forceea.FieldInfo field) {
        return String.isBlank(field.controllingFieldApiName);
    }

    private String getErrorMessageInvalidParameter(String parameter) {
        return 'Invalid parameter [' + getTrimmed(parameter) + '] in definition [' + this.def.definitionString + ']';
    }

    /**
     * @description Retrieves the fields to process, based on update.
     * @return An list of strings.
     */
    private List<String> getFieldsToProcess() {
        return (this.fObj.isUpdate) ? this.fObj.fieldsForUpdate : this.fObj.fields;
    }

    private String getFirstChar(String value) {
        return value.left(1);
    }

    private String getParameter() {
        String parameter = this.result.substringBefore(LEFT_PARENTHESIS);

        if (!parameterIsValid(parameter)) {
            this.fObj.addError(this.fieldApiName, getErrorMessageInvalidParameter(parameter));
            this.def.setValid(false);
            return '';
        }

        this.result = getScriptWithoutParameterAndLeftParenthesis(parameter);
        return getTrimmed(parameter);
    }

    /**
     * @description Parses a script cluster.
     * @param script The script.
     * @return Returns the script without the cluster.
     */
    private String getParsedCluster(String script) {
        this.result = getTrimmed(script);
        String argument = '';
        String chr = '';
        String parameter = '';

        if (thereIsNoStartingLeftParenthesis()) {
            return getParsedResultWhenNoStartingParentheses();
        }
        parameter = getParameter();

        do {
            this.result = getTrimmed(this.result);

            chr = getFirstChar(this.result);
            if (chr == DOUBLE_QUOTES) {
                this.result = this.result.removeStart(chr); // remove opening "
                this.doubleQuotesPosition = getPositionOfClosingQuotes(this.result); // get position of closing "

                if (this.doubleQuotesPosition == -1) {
                    // found no closing "
                    return getResultWhenNoClosingDoubleQuotes();
                } else {
                    // found closing "
                    argument = this.result.substringBefore(DOUBLE_QUOTES); // get argument
                    this.result = this.result.removeStart(argument + DOUBLE_QUOTES); // remove argument and " from script
                    this.result = getTrimmed(this.result);
                    // check if argument has leading or trailing white space characters
                    if (parameter.toLowerCase() == 'value' && (argument.startsWith(' ') || argument.endsWith(' '))) {
                        argument = DOUBLE_QUOTES + argument + DOUBLE_QUOTES;
                    } else {
                        argument = getTrimmed(argument);
                    }
                    this.arguments.add(argument);
                }

                chr = this.result.left(1); // get next char - it should be , or )
                if (chr == ')') {
                    // found (
                    this.result = getTrimmed(this.result.removeStart(chr)); // remove the )
                    this.mustContinue = false;
                } else if (chr == ',') {
                    // found ,
                    this.result = getTrimmed(this.result.removeStart(chr)); // remove the comma
                } else {
                    // found something else
                    this.fObj.addError(this.fieldApiName, this.errorMessage);
                    this.def.setValid(false);
                    return '';
                }
            } else if (chr.containsAny('(),')) {
                // invalid chars
                this.fObj.addError(this.fieldApiName, this.errorMessage);
                this.def.setValid(false);
                return '';
            } else {
                // an argument without double quotation marks
                // get the position of chars ( ) , "
                Integer commaPosition = result.indexOf(','); // get the position of next ,
                this.commaExists = (commaPosition != -1) ? true : false;
                this.doubleQuotesPosition = result.indexOf(DOUBLE_QUOTES); // get the position of next "

                Integer rightParenthesisPosition = result.indexOf(')'); // get the position of next )
                Boolean rightParenthesisExists = (rightParenthesisPosition != -1) ? true : false;

                // decide action based on next chars
                this.hasError = false;

                if (rightParenthesisExists && this.commaExists) {
                    if (rightParenthesisPosition < commaPosition) {
                        // found )
                        chr = ')';
                        this.mustContinue = false;
                    } else {
                        // found ,
                        chr = ',';
                        String textBeforeComma = getTrimmed(this.result.left(commaPosition));
                        if (textBeforeComma.right(1) == DOUBLE_QUOTES) {
                            this.hasError = true;
                        }
                    }
                } else if (rightParenthesisExists && !this.commaExists) {
                    // found )
                    chr = ')'; // found )
                    this.mustContinue = false;
                    String textBeforeParenthesis = getTrimmed(this.result.left(rightParenthesisPosition));
                    if (textBeforeParenthesis.right(1) == DOUBLE_QUOTES) {
                        this.hasError = true;
                    }
                } else {
                    this.hasError = true;
                }

                argument = this.result.substringBefore(chr);

                // if the argument has the invalid chars ( or is empty
                if (argument.contains(LEFT_PARENTHESIS) || String.isBlank(argument)) {
                    this.hasError = true;
                }

                if (this.hasError) {
                    this.fObj.addError(this.fieldApiName, this.errorMessage);
                    this.def.setValid(false);
                    return '';
                }

                this.result = this.result.removeStart(argument + chr); // remove argument and ) or , from script
                this.arguments.add(getTrimmed(argument));
            } // argument without double quotes
        } while (this.mustContinue);

        // add cluster to definition
        Forceea.Cluster newCluster = new Forceea.Cluster(parameter.toLowerCase(), this.arguments);
        this.def.clusters.add(newCluster);

        return this.result;
    }

    private String getParsedResultWhenNoStartingParentheses() {
        this.fObj.addError(this.fieldApiName, this.errorMessage);
        this.def.setValid(false);
        return '';
    }

    /**
     * @description Finds the position of the closing double quotes.
     * @param script The field definition script.
     * @return The integer position of the closing double quotes.
     */
    private Integer getPositionOfClosingQuotes(String script) {
        Integer result = -1;
        Integer index = 0;
        Boolean resultIsFound = false;

        do {
            result = script.indexOf(DOUBLE_QUOTES, index); // get position of next "
            String nextChar = script.mid(result + 1, 1);

            if (nextChar != DOUBLE_QUOTES) {
                // if next char is not "
                resultIsFound = true;
            }
            index = result + 2;
        } while (!resultIsFound);

        return result;
    }

    private String getResultWhenNoClosingDoubleQuotes() {
        this.fObj.addError(this.fieldApiName, this.errorMessage);
        this.def.setValid(false);
        return '';
    }

    private String getScriptWithoutParameterAndLeftParenthesis(String parameter) {
        return this.result.removeStart(parameter + LEFT_PARENTHESIS);
    }

    private String getTrimmed(String value) {
        return value.trim();
    }

    private void handleWhenCtrFieldNotDefined() {
        if (ctrlFieldNotDefined()) {
            createNewDefForContrFieldBeforeDefinitionOfDependent();
        }
    }

    private void handleWhenMustAddCtrlField(List<String> fields, Boolean mustAddControllingField) {
        if (!mustAddControllingField) {
            return;
        }

        if (this.dependentFieldPosition == 0) {
            addFieldInPosition(fields, this.ctrlFieldApiName, 0);
        } else {
            addFieldInPosition(fields, this.ctrlFieldApiName, this.dependentFieldPosition - 1);
        }
    }

    private void initializeVariables() {
        this.commaExists = false;
        this.ctrlFieldPosition = -1;
        this.ctrlFieldApiName = '';
        this.dependentFieldApiName = '';
        this.dependentFieldPosition = -1;
        this.doubleQuotesPosition = 0;
        this.hasError = false;
        this.mustContinue = true;
    }

    /**
     * @description Validates the parameter of a cluster.
     * @param parameter The parameter of a cluster.
     * @return A boolean value.
     */
    private Boolean parameterIsValid(String parameter) {
        if (!PARAMETERS.contains(getTrimmed(parameter).toLowerCase()) || String.isBlank(parameter)) {
            return false;
        } else {
            return true;
        }
    }

    /**
     * @description Parses a definition to its command and clusters.
     */
    private void parseDefinition() {
        String definitionString = def.definitionString.trim();
        String fieldApiName = def.fieldApiName;
        String script = '';

        // parse command
        String command = definitionString.substringBefore(' ').trim();
        if (!this.def.isSystemDeclared && !commandIsValid(command)) {
            this.fObj.addError(fieldApiName, 'Invalid command [' + command + '] in definition [' + definitionString + ']');
            this.def.setValid(false);
            return;
        }

        script = definitionString.removeStart(command + ' ');
        command = command.toLowerCase();
        this.def.command = command.toLowerCase();

        // parse script
        do {
            script = new ForceeaParser(this.fObj, this.def).getParsedCluster(script);
        } while (String.isNotEmpty(script));
    }

    /**
     * @description Sets if each definition is a function-x.
     */
    private void setDefinitionsAsFunctions() {
        for (ForceeaDefinition def : this.fObj.definitions) {
            if (def.definitionString.left(8).equalsIgnoreCase('function')) {
                def.isFunction = true;
            }
        }
    }

    /**
     * @description Sets the controlling fields' definition
     */
    private void setFieldDependency() {
        if (!FObject.processIsValid) {
            return;
        }

        Forceea.FieldInfo field = new Forceea.FieldInfo(); // the field details of the dependent field

        for (ForceeaDefinition def : new List<ForceeaDefinition>(this.fObj.definitions)) {
            if (def.isVirtualField || this.fObj.isUpdate) {
                continue;
            }

            this.dependentFieldApiName = def.fieldApiName;
            field = ForceeaService.getField(this.fObj.sObjectApiName, this.dependentFieldApiName);

            if (fieldHasControllingField(field)) {
                continue;
            } else {
                this.ctrlFieldApiName = field.controllingFieldApiName;
            }

            // the (dependent) field has a controlling field and it respects field dependencies
            this.ctrlFieldApiName = ForceeaService.getFieldApiNameFromKey(
                this.fObj.sObjectApiName, this.ctrlFieldApiName, null);
            Schema.DisplayType controllingFieldType =
                ForceeaService.getField(this.fObj.sObjectApiName, this.ctrlFieldApiName).dataType;

            // check the controlling field data type
            if (controllingFieldType == Schema.DisplayType.PICKLIST || controllingFieldType == Schema.DisplayType.MULTIPICKLIST) {
                // get the position of dependent/controlling field definitions
                this.dependentFieldPosition = this.fObj.fields.indexOf(this.dependentFieldApiName);
                this.ctrlFieldPosition = this.fObj.fields.indexOf(this.ctrlFieldApiName);
            } else if (controllingFieldType == Schema.DisplayType.BOOLEAN) {
                displayMessageWhenCheckboxFieldNotSupported();
                continue;
            }

            handleWhenCtrFieldNotDefined();
            upsertFieldBeforePosition();
        }

        validateDefinitions();
    }

    private Boolean thereIsNoStartingLeftParenthesis() {
        return this.result.indexOf(LEFT_PARENTHESIS) == -1;
    }

    /**
     * @description Inserts or moves a controlling field before a dependent field.
     *   If the field exists, it is moved before the position.
     *   If it doesn't exist, it is inserted before the position.
     */
    private void upsertFieldBeforePosition() {
        Boolean mustAddControllingField = false;
        List<String> fields = getFieldsToProcess();

        if (fields.contains(this.ctrlFieldApiName)) {
            Integer fieldPosition = fields.indexOf(this.ctrlFieldApiName);
            if (this.dependentFieldPosition < fieldPosition) {
                // field must be moved
                fields.remove(fieldPosition);
                mustAddControllingField = true;
                displayMessageWhenMovedDefOfCtrlField();
            }
        } else {
            mustAddControllingField = true;
        }

        handleWhenMustAddCtrlField(fields, mustAddControllingField);
    }

    /**
     * @description Validates the user-defined and system-defined definitions.
     */
    public void validateDefinitions() {
        if (this.fObj.definitionsAreValidated) {
            return;
        } else if (this.fObj.definitions.isEmpty()) {
            this.fObj.forceeaDebug(ForceeaService.DEBUG, 'Found no definitions to validate.');
            return;
        }

        displayMessageWhenDefWillBeValidated();
        setDefinitionsAsFunctions();
        validateDefsAndSetVariables();
        setFieldDependency();
    }

    private void validateDef(ForceeaDefinition def) {
        if (def.isValidated) {
            return;
        }

        this.def = def;
        parseDefinition();

        this.fObj.numValidatedDefinitions++;
        if (!def.isValid()) {
            return;
        }

        def.validate();
        displayMessageWhenDefIsValid();
    }

    private void validateDefsAndSetVariables() {
        this.fObj.numValidatedDefinitions = 0;
        for (ForceeaDefinition def : this.fObj.definitions) {
            validateDef(def);
        }
        this.fObj.definitionsAreValidated = true;
    }

}