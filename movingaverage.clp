(defrule equatePriceWithMovingAverage13 "Determines the stock price and equates it with the moving average from the last 13 readings."
   (price ?p)
   (movingAverage13 ?ma13)
   (movingAverage21 ?ma21)
   (movingAverage34 ?ma34)
   => 
   (if (> ?ma13 ?p) then (assert (movingAverage13vsStockPrice greater))
    else (assert (movingAverage13vsStockPrice lesser))
   )

   (if (> ?ma21 ?ma13) then (assert (movingAverage21vs13 greater))
    else (assert (movingAverage21vs13 lesser))
   )

   (if (> ?ma34 ?ma21) then (assert (movingAverage34vs21 greater))
    else (assert (movingAverage34vs21 lesser))
   )
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
   (movingAverage13vsStockPrice greater)
   (movingAverage21vs13 greater)
   (movingAverage34vs21 greater)
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
   (movingAverage13vsStockPrice lesser)
   (movingAverage21vs13 lesser)
   (movingAverage34vs21 lesser)
   =>
   (printSolution "moving average" "sell" ?ma13 ?ma34 (* (- ?ma13 ?ma34)))
)

/*
* Fires when the moving average method is inviable, allowing any future strategies to be executed.
* The average method is only inviable if the three relevant comparisons of moving averages and prices are not identical.
*/
(defrule movingAverageInviable "Fires if the moving average cannot determine a plan of action."
   (movingAverage13vsStockPrice ?x) 
   (movingAverage21vs13 ?y) 
   (movingAverage34vs21 ?z &:(or (not (eq ?x ?y)) (not (eq ?y ?z) (not (eq ?x ?z))))) 
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