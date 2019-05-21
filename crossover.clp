/*
* Contains all the rules and functions related to solving the problem using the moving average crossover strategy.
*
* The moving average crossover strategy is viable if the 20-period and 5-period moving averages have crossed.
* Using this, it compares the 5-period and 20-moving averages to the current value of the 30-period moving average to
* determine whether the user can buy or sell, or if the system is inconclusive.
* 
* Finn Frankis
* May 18, 2019
*/

(do-backward-chaining movingAverage5Crossed20)
(do-backward-chaining movingAverage5)
(do-backward-chaining movingAverage20)
(do-backward-chaining movingAverage30)

(defglobal ?*CROSSOVER_GAP_FACTOR* = 2) ; the factor of the difference between the 20- and 30-period moving average from the price after which you should take a profit

/*
* Compares the 5-period moving average to the 20-period moving average and the 20-period moving average to the 30-period moving average
* and asserts the comparisons as facts.
*/
(defrule equateMovingAveragesCrossover "Equates the stock price as well as the 13-period, 21-period, and 34-period moving averages with one another."
   (movingAverage5Crossed20 yes)
   (movingAverage5 ?ma5)
   (movingAverage20 ?ma20)
   (movingAverage30 ?ma30)
   => 
   (assertComparison movingAverage5vs20 ?ma5 ?ma20)
   (assertComparison movingAverage20vs30 ?ma20 ?ma30)
)

/*
* Fires when the user should buy at the current price using the crossover strategy.
*
* If the 20-period moving average has crossed below the 5-period moving average and the 30-period moving average is below
* the 20-period moving average, then the user can buy at the current price. 
*
* The user's stop loss will be the absolute difference between the 20-period and 30-period moving average below the current price;
* the user's profit will be double that absolute difference above the current price.
*/
(defrule crossoverBuy "Only fires if the user should buy based on the crossover method."
   (movingAverage5Crossed20 yes)
   (price ?p)
   (movingAverage5 ?ma5)
   (movingAverage20 ?ma20)
   (movingAverage30 ?ma30)
   (movingAverage5vs20 greater)
   (movingAverage20vs30 greater)
   =>
   (printSolution "moving average crossover" "buy" ?p (- ?p (- ?ma20 ?ma30)) (+ ?p (* ?*CROSSOVER_GAP_FACTOR* (- ?ma20 ?ma30))))
)

/*
* Fires when the user should sell at the current price using the crossover strategy.
*
* If the 20-period moving average has crossed above the 5-period moving average and the 30-period moving average is above
* the 20-period moving average, then the user can sell at the current price. 
*
* The user's stop loss will be the absolute difference between the 20-period and 30-period moving average above the current price;
* the user's profit will be double that absolute difference below the current price.
*/
(defrule crossoverSell "Only fires if the user should sell based on the crossover method."
   (movingAverage5Crossed20 yes)
   (price ?p)
   (movingAverage5 ?ma5)
   (movingAverage20 ?ma20)
   (movingAverage30 ?ma30)
   (movingAverage5vs20 lesser)
   (movingAverage20vs30 lesser)
   =>
   (printSolution "moving average crossover" "sell" ?p (+ ?p (- ?ma20 ?ma30)) (- ?p (* ?*CROSSOVER_GAP_FACTOR* (- ?ma20 ?ma30))))
)

/*
* Fires when the crossover method is inviable, allowing any future strategies to be executed.
* The crossover method is inviable if the 20-period and 5-period moving averages did not cross or if 
* they crossed but the 20 and 30 averages are not in the correct direction.
*/
(defrule crossoverInviable "Only fires if the crossover is an inviable strategy."
   (or 
      (movingAverage5Crossed20 no)
      (and 
         (movingAverage5vs20 ?ma5v20)
         (movingAverage20vs30 ?ma20v30)
         (test (not (or (and (eq ?ma5v20 lesser) (eq ?ma20v30 lesser)) (and (eq ?ma5v20 greater) (eq ?ma20v30 greater)))))
      )
   )
   =>
   (printline "The crossover failed as a viable strategy. Let's move onto the momentum strategy.")
   (batch finalproject/momentum.clp)
)

(defrule askMovingAverage5Crossed20 "Asks the user whether the 5-period moving average has crossed the 20-period moving average."
   (need-movingAverage5Crossed20 ?)
   =>
   (assert (movingAverage5Crossed20 (askForYesNo "Did the 5-period moving average and the 20-period moving average cross")))
)

(defrule askMovingAverage5 "Asks about the current moving average based on the last 5 readings."
   (need-movingAverage5 ?)
   =>
   (assert (movingAverage5 (askMovingAverage 5)))
)

(defrule askMovingAverage20 "Asks about the current moving average based on the last 20 readings."
   (need-movingAverage20 ?)
   =>
   (assert (movingAverage20 (askMovingAverage 20)))
)

(defrule askMovingAverage30 "Asks about the current moving average based on the last 30 readings."
   (need-movingAverage30 ?)
   =>
   (assert (movingAverage30 (askMovingAverage 30)))
)