/*
* Determines whether the user should buy, sell, or wait based on the current state of the market. If a decision is
* determined, tells the user when they should exit the market with a profit and when they should accept a stop loss and
* exit the market before things get too bad.
*
* Applies four distinct strategies after asking the user several questions to determine the user's optimal
* path.
* 
* Finn Frankis
* April 2, 2019
*/

(clear)
(reset)

(batch util/utilities.clp)

(defglobal ?*INVALID_NUMBER_INPUT_MESSAGE* = "Your input must be a number. Please try again.")
(defglobal ?*INVALID_YESNO_INPUT_MESSAGE* = "Your input must be either \"yes\" or \"no\". Please try again.")
(defglobal ?*VALID_YES_CHARACTER* = "y") ; will accept any string starting with this as indicating "yes"
(defglobal ?*VALID_NO_CHARACTER* = "n") ; will accept any string starting with this as indicating "no"
(defglobal ?*DEFAULT_NUMBER_BASE* = 10.0) ; all numbers will be in base-10 unless specified; used for successsful truncation
(defglobal ?*DEFAULT_TRUNCATION_DECIMAL_PLACES* = 5) ; all displayed numbers will be truncated to five decimal places
(defglobal ?*STARTUP_RULE_SALIENCE* = 100)
(defglobal ?*NO_OPTIONS_RULE_SALIENCE* = -100)

/*
* Starts up the system and explains to the user how to use it.
*/
(defrule startup "Starts up the system and provides basic instructions to the user."
   (declare (salience ?*STARTUP_RULE_SALIENCE*)) ; guarantees that this rule will be run before all others by giving it a very high weight
   =>
   (printline "Welcome to the trading assistant.")
   (printline "Our first strategy will be to study the recent moving averages using the Fibonacci sequence.")
   (printline "Find a chart comparing the US Dollar to the Canadian Dollar over the past 10 minutes.")
   (printline "Display three Fibonacci moving averages (13, 21, and 34) and answer the following questions.")
   (printline "")
   (batch finalproject/movingaverage.clp)
)

/*
* Fires, using backward chaining, when the system needs to know the current price of the market.
*/
(defrule askPrice "Asks about the current price."
   (need-price ?)
   =>
   (assert (price (askForNumber "What is the current price of stock")))
)

/*
* Fires when the system has no more questions to ask the user and a final solution has not yet been reached - 
* this indicates they should wait and return to the market some time later.
*/
(defrule outOfOptions "Fires when no options remain."
   (declare (salience ?*NO_OPTIONS_RULE_SALIENCE*)) ; guarantees that this rule will be run after all others by giving it a low high weight
   (not (solutionFound))
   =>
   (printline "")
   (printline "After analysis using the system's primary strategies, it has been determined that there are no viable options.")
   (printline "It is recommended that you wait for the market to shift and return to the system after that occurs.")
)

/*
* Asks the user to input a number. If they input a valid number (either an integer or a decimal value), will return this value.
* If they do not input a valid number, will warn the user and ask again. Once a valid number is reached, it will return this value.
*/
(deffunction askForNumber (?question)
   (bind ?returnVal (askQuestion ?question))

   (while (not (numberp ?returnVal)) ; while the input is invalid, continually asks for new input until it becomes valid
      (printline ?*INVALID_NUMBER_INPUT_MESSAGE*)
      (bind ?returnVal (askQuestion ?question))
   )

   (return ?returnVal)
)

/*
* Requests the user for a response (either yes or no) to a given question. If the input starts with either "y" or "n," not case-sensitive,
* returns the starting character. Otherwise returns FALSE.
*/
(deffunction requestValidatedYesNo (?questionVal)
   (bind ?returnVal FALSE) ; returns FALSE if the input is invalid
   (bind ?userInput (askQuestion ?questionVal))
   (bind ?firstCharacter (lowcase (sub-string 1 1 ?userInput))) ; extracts the first character from the user's response

   (bind ?isYesChar (eq ?firstCharacter ?*VALID_YES_CHARACTER*))
   (bind ?isNoChar (eq ?firstCharacter ?*VALID_NO_CHARACTER*))

   (if ?isYesChar then (bind ?returnVal yes)
    elif ?isNoChar then (bind ?returnVal no)
   )

   (return ?returnVal)
) ; requestValidatedYesNo (?questionVal)

/*
* Asks the user to input either yes or no (or anything starting with "y" or "n"). If they input anything starting with
* "y" or "n", will return either the symbol "yes" or "no" (as a symbol, not a string). 
* If the user does not input a valid input, will warn the user and ask again, returning the first valid input it receives.
*/
(deffunction askForYesNo (?question)
   (bind ?returnVal (requestValidatedYesNo ?question))

   (while (eq ?returnVal FALSE) ; while the input is invalid, continually asks for new input until it becomes valid
      (printline ?*INVALID_YESNO_INPUT_MESSAGE*) 
      (bind ?returnVal (requestValidatedYesNo ?question))
   )

   (return ?returnVal)
)

/*
* Compares two values and asserts the result into the factbase with the format (?factName lesser), (?factName greater),
* or (?factName equal). If ?firstVal is less than ?secondVal, will assert with "lesser"; if ?firstVal is greater than ?secondVal,
* will assert with "greater"; otherwise will assert with "equal".
*/
(deffunction assertComparison (?factName ?firstVal ?secondVal)
   (if (< ?firstVal ?secondVal) then (assert-string (str-cat "(" ?factName " lesser)"))
    elif (> ?firstVal ?secondVal) then (assert-string (str-cat "(" ?factName " greater)"))
    else (assert-string (str-cat "(" ?factName " equal)"))
   )

   (return)
)

/*
* Truncates a number (?num) to a given number of decimal places (?decimalPlaces). The number of decimal places must be
* nonnegative for the function to work as expected. Returns the truncated number.
*/
(deffunction truncateNum (?num ?decimalPlaces)
   (bind ?multiplyVal (** ?*DEFAULT_NUMBER_BASE* ?decimalPlaces))
   (return (/ (integer (* ?num ?multiplyVal)) ?multiplyVal))
)

/*
* Prints out the solution based on the type of calculation performed ?calculation (like moving average, Bollinger band, etc.), 
* the action that should be performed ?action (either buying or selling), the amount of money at which the user should either 
* buy or sell ?currentPrice, the amount of money after which the user should simply stop ?stopAmount, 
* and the amount of money after which the user should simply take a profit ?profitAmount.
*
* The three numerical values printed will always be truncated to 5 decimal places.
*/
(deffunction printSolution (?calculation ?action ?currentPrice ?stopAmount ?profitAmount)
   (printline "")
   (bind ?currentPrice (truncateNum ?currentPrice ?*DEFAULT_TRUNCATION_DECIMAL_PLACES*))
   (bind ?stopAmount (truncateNum ?stopAmount ?*DEFAULT_TRUNCATION_DECIMAL_PLACES*))
   (bind ?profitAmount (truncateNum ?profitAmount ?*DEFAULT_TRUNCATION_DECIMAL_PLACES*))

   (printline (str-cat "Based on the " ?calculation " calculation, you should " ?action " at " ?currentPrice " and either stop at " ?stopAmount " or take a profit at " ?profitAmount "."))
   (assert (solutionFound))
   (return)
)

/*
* Ends the system's operation by stopping the rule engine.
*/
(deffunction endSystem ()
   (halt) ; stops the rule engine from running to ensure no more questions are asked
   (return)
) ; endSystem ()

/*
* Begins the system by clearing out the rule engine and running it.
*/
(deffunction runSystem ()
   (clear) ; clear the JESS system to eliminate all knowledge islands
   (reset)
   (batch finalproject/currency.clp) ; batch in the main file again to begin again after the (clear)
   (run)
   (endSystem)
   (return)
) ; runSystem ()