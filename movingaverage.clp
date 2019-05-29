/*
* Contains all the rules and functions related to solving the problem using the moving average Fibonacci strategy.
* 
* The moving average Fibonacci strategy compares the price with the 13-period, 21-period, and 34-period moving averages. The user can
* buy using this strategy if, in the order above, each one is greater than the next. The user can sell if, in the order above,
* each one is less than the next.
* 
* Finn Frankis
* May 17, 2019
*/

(do-backward-chaining movingAverage13)
(do-backward-chaining movingAverage21)
(do-backward-chaining movingAverage34)

/*
* The factor of the difference between the 20-period and the 30-period moving average either above or below the price 
* at which the user should take a profit.
*/ 
(defglobal ?*MOVING_AVERAGE_PROFIT_GAP_FACTOR* = 2)

/*
* Compares the price to the 13-period moving average, the 21-period moving average to the 13-period moving average, and the 34-period
* moving average to the 21-period moving average, asserting these comparisons as facts.
*/
(defrule equatePriceAndMovingAveragesFib "Equates the stock price as well as the 13-period, 21-period, and 34-period moving averages with one another."
   (price ?p)
   (movingAverage13 ?ma13)
   (movingAverage21 ?ma21)
   (movingAverage34 ?ma34)
   => 
   (assertComparison movingAverage13vsStockPrice ?ma13 ?p)
   (assertComparison movingAverage21vs13 ?ma21 ?ma13)
   (assertComparison movingAverage34vs21 ?ma34 ?ma21)
)

/*
* Fires when the user should buy using the moving average strategy.
*
* If the 34-period moving average is below the 21-period moving average, the 21-period moving average is below the 
* 13-period moving average, and the 13-period moving average is below the stock price, this is indicative that the market
* is in a down-trend and thus the user should buy because it is likely to come back up (stabilize) soon.
*
* The stop loss will be when the price crosses the 34-period moving average.
* The profit is twice the distance between the 13-period moving average and the 34-period moving average.
*/
(defrule movingAverageFibBuy "Only fires if the user should buy based on the moving average method."
   (not (movingAverageFib inviable)) ; this rule cannot fire if the moving average Fibonacci strategy has already been deemed inviable
   (movingAverage13vsStockPrice lesser)
   (movingAverage21vs13 lesser)
   (movingAverage34vs21 lesser)
   (price ?p)
   (movingAverage13 ?ma13)
   (movingAverage34 ?ma34)
   =>
   (printSolution "moving average Fibonacci" "buy" ?p ?ma34 (+ ?p (* ?*MOVING_AVERAGE_PROFIT_GAP_FACTOR* (- ?ma13 ?ma34))))
) ; movingAverageFibBuy

/*
* Fires when the user should sell using the moving average strategy.
*
* If the 34-period moving average is above the 21-period moving average, the 21-period moving average is above the 
* 13-period moving average, and the 13-period moving average is above the stock price, this is indicative that the market
* is in an up-trend and thus the user should sell because it is likely to come back down (stabilize) soon.
*
* The stop loss will be when the price crosses the 34-period moving average. 
* The profit is twice the distance between the 13-period moving average and the 34-period moving average.
*/
(defrule movingAverageFibSell "Only fires if the user should sell based on the moving average method."
   (not (movingAverageFib inviable)) ; this rule cannot fire if the moving average Fibonacci strategy has already been deemed inviable
   (movingAverage13vsStockPrice greater)
   (movingAverage21vs13 greater)
   (movingAverage34vs21 greater)
   (price ?p)
   (movingAverage13 ?ma13)
   (movingAverage34 ?ma34)
   =>
   (printSolution "moving average Fibonacci" "sell" ?p ?ma34 (- ?p (* ?*MOVING_AVERAGE_PROFIT_GAP_FACTOR* (- ?ma34 ?ma13))))
) ; movingAverageFibSell

/*
* Fires when the moving average method is inviable, allowing any future strategies to be executed.
* The moving average method is only inviable if the three relevant comparisons of moving averages and price (listed in the
* file header) are not either all lesser or all greater.
*/
(defrule movingAverageFibInviable "Fires if the moving average cannot determine a plan of action."
   (not (movingAverageFib inviable)) ; this rule cannot fire if the moving average Fibonacci strategy has already been deemed inviable
   (movingAverage13vsStockPrice ?x) 
   (movingAverage21vs13 ?y) 
   (movingAverage34vs21 ?z)
   (test (not (or (and (eq ?x lesser) (eq ?y lesser) (eq ?z lesser)) (and (eq ?x greater) (eq ?y greater) (eq ?z greater)))))
   =>
   (printline "The moving average failed as a viable strategy. Let's move onto the Bollinger Band strategy.")
   (assert (movingAverageFib inviable))    ; asserts inviability so that no future moving average rules can be fired
   (batch finalproject/bollingerbands.clp) ; move onto the Bollinger Band strategy
) ; movingAverageFibInviable

/*
* Asks the user for the moving average based on a given number of readings ?readingNum, represented as string.
* Returns the numeric result of this request.
*/
(deffunction askMovingAverage (?readingNum)
   (return (askForNumber (str-cat "What is the current moving average based on the last " ?readingNum " readings")))
)

/*
* The following rules are all backward-chained and ask the user about a given piece of market information based on the moving 
* average strategy when it is necessary to determine whether a rule can fire. They assert the data given into the factbase.
*/

(defrule askMovingAverage13 "Asks about the current moving average based on the last 13 readings."
   (need-movingAverage13 ?)
   =>
   (assert (movingAverage13 (askMovingAverage "13")))
)

(defrule askMovingAverage21 "Asks about the current moving average based on the last 21 readings."
   (need-movingAverage21 ?)
   =>
   (assert (movingAverage21 (askMovingAverage "21")))
)

(defrule askMovingAverage34 "Asks about the current moving average based on the last 34 readings."
   (need-movingAverage34 ?)
   =>
   (assert (movingAverage34 (askMovingAverage "34")))
)