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
)


/*
* Fires when the user should buy with a certain amount and lets them know when they should stop and when they should pull 
* out of the market.
*/
(defrule movingAverageBuy "Only fires if the user should buy based on the moving average method."
   (price ?p)
   (movingAverage13 ?ma13)
   (movingAverage21 ?ma21)
   (movingAverage34 ?ma34)
   (test (> ?ma13 ?p))
   (test (> ?ma21 ?ma13))
   (test (> ?ma34 ?ma21))
   =>
   (printSolution "moving average" "buy" ?ma13 ?ma34 (* (- ?ma34 ?ma13)))
)

/*
* Fires when the user should sell with a certain amount and lets them know when they should stop and when they should pull 
* out of the market.
*/
(defrule movingAverageSell "Only fires if the user should sell based on the moving average method."
   (price ?p)
   (movingAverage13 ?ma13)
   (movingAverage21 ?ma21)
   (movingAverage34 ?ma34)
   (test (< ?ma13 ?p))
   (test (< ?ma21 ?ma13))
   (test (< ?ma34 ?ma21))
   =>
   (printSolution "moving average" "sell" ?ma13 ?ma34 (* (- ?ma13 ?ma34)))
)

/*
* Fires when the moving average method is inviable, allowing any future strategies to be executed.
* The average method is only inviable if the three relevant comparisons of moving averages and prices are not identical.
*/
(defrule movingAverageInviable "Fires if the moving average cannot determine a plan of action."
   (movingAverage13vsStockPrice ?x) ; ?x represents whether the 13-reading moving average was lesser or greater than the stock price
   (movingAverage21vs13 ?y) ; ?y represents whether the 21-reading moving average was lesser or greater than the 13-reading moving average
   (movingAverage34vs21 ?z &:(or (not (eq ?x ?y)) (not (eq ?y ?z) (not (eq ?x ?z))))) ; ?z represents whether the 34-reading moving average was lesser or greater than the 21-reading moving average
   =>
   (assert (movingAverage no))
   (printline "The moving average failed as a viable strategy. Let's move onto the Bollinger Band strategy.")
)

(defrule equatePriceWithUpperandLowerBollingerBands "Determines whether or not the price is between the two Bollinger bands."
   (movingAverage no)
   (price ?p)
   (upperBollingerBand ?upperBB)
   (lowerBollingerBand ?lowerBB)
   =>
   (if (and (> ?p ?lowerBB) (< ?p ?upperBB)) then (assert (priceBetweenUpperAndLowerBB yes))
    else (assert (priceBetweenUpperAndLowerBB no))
   )
)

(defrule equatePriceWithMidBollingerBand "Determines whether the price is above or below the mid Bollinger band."
   (movingAverage no)
   (priceBetweenUpperAndLowerBB ?)
   (price ?p)
   (midBollingerBand ?midBB)
   =>
   (if (> ?p ?midBB) then (assert (pricevsMidBB greater))
    else (assert (pricevsMidBB lesser))
   )
)

/*
* Fires when the user should buy with a certain amount and lets them know when they should stop and when they should pull 
* out of the market, using the Bollinger band method.
*/
(defrule bollingerBandBuy "Only fires when the user should buy with the Bollinger band method."
   (movingAverage no)
   (priceBetweenUpperAndLowerBB yes)
   (pricevsMidBB lesser)
   (price ?p)
   (upperBollingerBand ?upperBB)
   (lowerBollingerBand ?lowerBB)
   (midBollingerBand ?midBB)
   =>
   (bind ?stopLoss (- ?lowerBB (* ?*BOLLINGER_BAND_GAP_PERCENT* (- ?midBB ?lowerBB))))
   (printSolution "bollinger band" "buy" ?lowerBB ?stopLoss ?midBB)
)

/*
* Fires when the user should sell with a certain amount and lets them know when they should stop and when they should pull 
* out of the market, using the Bollinger band method.
*/
(defrule bollingerBandSell "Only fires when the user should sell with the Bollinger band method."
   (movingAverage no)
   (priceBetweenUpperAndLowerBB yes)
   (pricevsMidBB greater)
   (price ?p)
   (upperBollingerBand ?upperBB)
   (lowerBollingerBand ?lowerBB)
   (midBollingerBand ?midBB)
   =>
   (bind ?stopLoss (+ ?lowerBB (* ?*BOLLINGER_BAND_GAP_PERCENT* (- ?midBB ?lowerBB))))
   (printSolution "bollinger band" "buy" ?lowerBB ?stopLoss ?midBB)
)

/*
* The following rules are all backward-chained and ask the user about a given piece of market information when
* it is necessary to determine whether a rule can fire.
*/

(defrule askPrice "Asks about the current price."
   (need-price ?)
   =>
   (assert (price (askForNumber "What is the current price of stock")))
)

/*
* Asks the user for the moving average based on a given number of readings.
*/
(deffunction askMovingAverage (?readingNum)
   (return (askForNumber (str-cat "What is the current moving average based on the last " ?readingNum " readings")))
)

(defrule askMovingAverage13 "Asks about the current moving average based on the last 13 readings."
   (need-movingAverage13 ?)
   =>
   (assert (movingAverage13 (askMovingAverage 13)))
)

(defrule askMovingAverage21 "Asks about the current moving average based on the last 21 readings."
   (need-movingAverage21 ?)
   =>
   (assert (movingAverage21 (askMovingAverage 21)))
)

(defrule askMovingAverage34 "Asks about the current moving average based on the last 34 readings."
   (need-movingAverage34 ?)
   =>
   (assert (movingAverage34 (askMovingAverage 34)))
)

/*
* Asks the user for the Bollinger band given the location (mid, upper, or lower).
*/
(deffunction askBollingerBand (?location)
   (return (askForNumber (str-cat "What is the current value of the " ?location "-Bollinger Band")))
)

(defrule askMidBollingerBand "Asks about the mid-Bollinger band."
   (need-midBollingerBand ?)
   =>
   (assert (midBollingerBand (askBollingerBand "mid")))
)

(defrule askUpperBollingerBand "Asks about the upper-Bollinger band."
   (need-upperBollingerBand ?)
   =>
   (assert (upperBollingerBand (askBollingerBand "upper")))
)

(defrule askLowerBollingerBand "Asks about the lower-Bollinger band."
   (need-lowerBollingerBand ?)
   =>
   (assert (lowerBollingerBand (askBollingerBand "lower")))
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
