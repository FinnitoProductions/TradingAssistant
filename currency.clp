/*
* Determines whether the user should buy, sell, or wait based on the current state of the market.
* 
* Finn Frankis
* April 2, 2019
*/

(clear)
(reset)

(batch util/utilities.clp)

(do-backward-chaining price)
(do-backward-chaining movingAverage13)
(do-backward-chaining movingAverage21)
(do-backward-chaining movingAverage34)
(do-backward-chaining upperBollingerBand)
(do-backward-chaining lowerBollingerBand)
(do-backward-chaining midBollingerBand)

(defglobal ?*INVALID_NUMBER_INPUT_MESSAGE* = "Your input must be a number. Please try again.")
(defglobal ?*BOLLINGER_BAND_GAP_PERCENT* = 0.5) ; the percent either above or below the top Bollinger band at which you should take a profit or a loss

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
* If they do not input a valid number, will warn the user and return FALSE.
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
