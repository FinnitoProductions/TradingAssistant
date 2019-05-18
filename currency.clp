/*
* Determines whether the user should buy, sell, or wait based on the current state of the market.
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

/*
* Starts up the system and explains to the user how to use it.
*/
(defrule startup "Starts up the system and provides basic instructions to the user."
   (declare (salience 100)) ; guarantees that this rule will be run before all others by giving it a very high weight
   =>
   (printline "Welcome to the stock market helper.")
   (printline "Our first strategy will be to study the recent moving averages using the Fibonacci sequence.")
   (printline "Find a chart indicating the past 10 minutes worth of moving averages and answer the following questions.")
   (printline "")
   (batch finalproject/movingaverage.clp)
)

/*
* Fires when the system has no more questions to ask the user - this indicates they should wait and return to the market
* some time later.
*/
(defrule outOfOptions "Fires when no options remain."
   (declare (salience -100))
   (not (solutionFound))
   =>
   (printline "")
   (printline "After analysis using the system's primary strategies, it has been determined that there are no viable options.")
   (printline "It is recommended that you wait for the market to shift and return to the system after that occurs.")
)

/*
* Asks the user to input a number. If they input a valid number (either an integer or a decimal value), will return this value.
* If they do not input a valid number, will warn the user and ask again.
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
* Requests the user for a response to a given question. If the input starts with either "y" or "n," not case-sensitive,
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
* "y" or "n", will return either the symbol "yes" or "no." If the user does not input a valid input, will warn the user
* and ask again.
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
* Asserts the result of a comparison between two values into the factbase with the format (?factName lesser), (?factName greater),
* or (?factName equal). If ?firstVal is less than ?secondVal, will assert with "lesser"; if ?firstVal is greater than ?secondVal,
* will assert with "greater".
*/
(deffunction assertComparison (?factName ?firstVal ?secondVal)
   (if (< ?firstVal ?secondVal) then (assert-string (str-cat "(" ?factName " lesser)"))
    elif (> ?firstVal ?secondVal) then (assert-string (str-cat "(" ?factName " greater)"))
    else (assert-string (str-cat "(" ?factName " equal)"))
   )

   (return)
)

/*
* Prints out the solution based on the type of calculation performed (like moving average or Bollinger band), the action that
* should be performed (either buying or selling), the amount of money which should be involved at this action, 
* the amount of money after which the user should simply stop, and the amount of money after which the user should simply
* take a profit.
*/
(deffunction printSolution (?calculation ?action ?actionAmount ?stopAmount ?profitAmount)
   (printline "")
   (printline (str-cat "Based on the " ?calculation " calculation, you should " ?action " at " ?actionAmount " and either stop at " ?stopAmount " or take a profit at " ?profitAmount "."))
   (assert (solutionFound))
   (return)
)

/*
* Ends the system's operation by resetting and stopping the rule engine.
*/
(deffunction endSystem ()
   (halt) ; stops the rule engine from running to ensure no more questions are asked
   (return)
) ; endSystem ()

/*
* Begins the system by clearing out the rule engine and running it.
*/
(deffunction runSystem ()
   (reset)
   (run)
   (endSystem)
   (return)
) ; runSystem ()

(runSystem)
