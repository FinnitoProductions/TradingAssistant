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

(defglobal ?*MINIMUM_MOMENTUM_SELL* = 0.00025)
(defglobal ?*MAXIMUM_MOMENTUM_BUY* = -0.00025)
(defglobal ?*MOMENTUM_PROFIT_RANGE* = 0.0002) ; the amount above or below the price after which the user should take a profit
(defglobal ?*MOMENTUM_STOPLOSS_RANGE* = 0.0002) ; the amount above or below the price after which the user should take a loss

/*
* Fires when the user should buy using the momentum strategy - if the momentum is extremely negative (less than -0.0025), 
* the market is likely to stabilize soon and increase, so buying is a reasonable choice.
*
* The stop-loss and profit will both be 0.002.
*/
(defrule momentumBuy "Only fires when the user should buy based on the momentum strategy."
   (not (momentumStrategy inviable)) ; this rule cannot fire if the momentum strategy has already been deemed inviable
   (price ?p)
   (momentum ?m)
   (test (< ?m ?*MAXIMUM_MOMENTUM_BUY*)) ; the momentum is an extremely negative number, symbolizing volatility
   =>
   (printSolution "momentum" "buy" ?p (- ?p ?*MOMENTUM_STOPLOSS_RANGE*) (+ ?p ?*MOMENTUM_PROFIT_RANGE*))
)

/*
* Fires when the user should sell using the momentum strategy - if the momentum is extremely positive (greater than 0.0025), 
* the market is likely to stabilize soon and decrease, so selling is a reasonable choice.
*
* The stop-loss and profit will both be 0.002.
*/
(defrule momentumSell "Only fires when the user should sell based on the momentum strategy."
   (not (momentumStrategy inviable)) ; this rule cannot fire if the momentum strategy has already been deemed inviable
   (price ?p)
   (momentum ?m)
   (test (> ?m ?*MINIMUM_MOMENTUM_SELL*)) ; the momentum is an extremely positive number
   =>
   (printSolution "momentum" "sell" ?p (+ ?p ?*MOMENTUM_STOPLOSS_RANGE*) (- ?p ?*MOMENTUM_PROFIT_RANGE*))
)

/*
* Fires when the momentum strategy is inviable, meaning the market is relatively non-volatile (the momentum is between -0.0025 and 0.0025).
*/
(defrule momentumInviable "Fires if the momentum cannot be used to determine a strategy."
   (not (momentumStrategy inviable)) ; this rule cannot fire if the momentum strategy has already been deemed inviable
   (momentum ?m)
   (test (and (< ?m ?*MINIMUM_MOMENTUM_SELL*) (> ?m ?*MAXIMUM_MOMENTUM_BUY*)))
   =>
   (printline "The momentum failed as a viable strategy.")
   (assert (momentumStrategy inviable))
)

/*
* Applies backward-chaining to ask the user about the current market momentum when it is needed for the execution of a rule.
*/
(defrule askMomentum "Asks about the current momentum (rate of change) of the market."
   (need-momentum ?)
   =>
   (assert (momentum (askForNumber "What is the current momentum of the market")))
)