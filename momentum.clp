/*
* Contains all the rules and functions related to solving the problem using the momentum strategy.
*
* The momentum strategy determines whether the current momentum (rate of change) of the market exceeds a given rate 
* in magnitude. If it exceeds this rate, the market is volatile and the user is ready to buy or sell.
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
   (not (momentum inviable)) ; this rule cannot fire if the momentum strategy has already been deemed inviable
   (price ?p)
   (momentum ?m)
   (test (< ?m ?*MAXIMUM_MOMENTUM_BUY*))
   =>
   (printSolution "momentum" "buy" ?p (- ?p ?*MOMENTUM_STOPLOSS_RANGE*) (+ ?p ?*MOMENTUM_PROFIT_RANGE*))
)

(defrule momentumSell "Only fires when the user should sell based on the momentum strategy."
   (not (momentum inviable)) ; this rule cannot fire if the momentum strategy has already been deemed inviable
   (price ?p)
   (momentum ?m)
   (test (> ?m ?*MINIMUM_MOMENTUM_SELL*))
   =>
   (printSolution "momentum" "sell" ?p (+ ?p ?*MOMENTUM_STOPLOSS_RANGE*) (- ?p ?*MOMENTUM_PROFIT_RANGE*))
)

(defrule momentumInviable "Fires if the momentum cannot be used to determine a strategy."
   (not (momentum inviable)) ; this rule cannot fire if the momentum strategy has already been deemed inviable
   (price ?p)
   (momentum ?m)
   (test (and (< ?m ?*MINIMUM_MOMENTUM_SELL*) (> ?m ?*MAXIMUM_MOMENTUM_BUY*)))
   =>
   (printline "The momentum failed as a viable strategy.")
   (assert (momentum inviable))
)

/*
* Applies backward-chaining to ask the user about the current market momentum when it is needed for the execution of a rule.
*/
(defrule askMomentum "Asks about the current momentum (rate of change) of the market."
   (need-momentum ?)
   =>
   (assert (momentum (askForNumber "What is the current momentum of the market")))
)