/*
* Contains all the rules and functions related to solving the problem using the moving average Fibonacci strategy.
* 
* The moving average Fibonacci strategy compares the price with the 13-period, 21-period, and 34-period moving averages. The user can
* sell using this strategy if, in the order above, each one is greater than the next. The user can sell if, in the order above
* each one is lesser than the next.
* 
* Finn Frankis
* May 17, 2019
*/

(do-backward-chaining price)
(do-backward-chaining movingAverage13)
(do-backward-chaining movingAverage21)
(do-backward-chaining movingAverage34)

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

(defrule movingAverageFibBuy "Only fires if the user should buy based on the moving average method."
   (price ?p)
   (movingAverage13 ?ma13)
   (movingAverage21 ?ma21)
   (movingAverage34 ?ma34)
   (movingAverage13vsStockPrice greater)
   (movingAverage21vs13 greater)
   (movingAverage34vs21 greater)
   =>
   (printSolution "moving average Fibonacci" "buy" ?ma13 ?ma34 (* (- ?ma34 ?ma13)))
)

(defrule movingAverageFibSell "Only fires if the user should sell based on the moving average method."
   (price ?p)
   (movingAverage13 ?ma13)
   (movingAverage21 ?ma21)
   (movingAverage34 ?ma34)
   (movingAverage13vsStockPrice lesser)
   (movingAverage21vs13 lesser)
   (movingAverage34vs21 lesser)
   =>
   (printSolution "moving average Fibonacci" "sell" ?ma13 ?ma34 (* (- ?ma13 ?ma34)))
)

/*
* Fires when the moving average method is inviable, allowing any future strategies to be executed.
* The average method is only inviable if the three relevant comparisons of moving averages and prices are not either
* all lesser or all greater.
*/
(defrule movingAverageFibInviable "Fires if the moving average cannot determine a plan of action."
   (movingAverage13vsStockPrice ?x) 
   (movingAverage21vs13 ?y) 
   (movingAverage34vs21 ?z)
   (test (not (or (and (eq ?x lesser) (eq ?y lesser) (eq ?z lesser)) (and (eq ?x lesser) (eq ?y lesser) (eq ?z lesser)))))
   =>
   (batch finalproject/bollingerbands.clp)
   (printline "The moving average failed as a viable strategy. Let's move onto the Bollinger Band strategy.")
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