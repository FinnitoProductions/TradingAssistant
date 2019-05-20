/*
* Contains all the rules and functions related to solving the problem using the momentum strategy.
* 
* Finn Frankis
* May 19, 2019
*/

(do-backward-chaining momentum)

(defglobal ?*MINIMUM_MOMENTUM_SELL* = 0.0025)
(defglobal ?*MAXIMUM_MOMENTUM_BUY* = -0.0025)
(defglobal ?*MOMENTUM_PROFIT_RANGE* = 0.002) ; the amount above or below the price after which the user should take a profit
(defglobal ?*MOMENTUM_STOPLOSS_RANGE* = 0.002) ; the amount above or below the price after which the user should take a profit

(defrule momentumBuy "Only fires when the user should buy based on the momentum strategy."
   (price ?p)
   (momentum ?m)
   (test (< ?m ?*MAXIMUM_MOMENTUM_BUY*))
   =>
   (printSolution "momentum" "buy" ?p (- ?p ?*MOMENTUM_STOPLOSS_RANGE*) (+ ?p ?*MOMENTUM_PROFIT_RANGE*))
)

(defrule momentumSell "Only fires when the user should sell based on the momentum strategy."
   (price ?p)
   (momentum ?m)
   (test (> ?m ?*MINIMUM_MOMENTUM_SELL*))
   =>
   (printSolution "momentum" "sell" ?p (+ ?p ?*MOMENTUM_STOPLOSS_RANGE*) (- ?p ?*MOMENTUM_PROFIT_RANGE*))
)

(defrule askMomentum "Asks about the current momentum (rate of change) of the market."
   (need-momentum ?)
   =>
   (assert (momentum (askForNumber "What is the current momentum of the market")))
)