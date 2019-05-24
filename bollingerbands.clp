/*
* Contains all the rules and functions related to solving the problem using the Bollinger Band strategy.
* 
* The Bollinger Band strategy succeeds if the upper or lower Bollinger Band is within 0.01% of the current price.
* If the upper Bollinger Band is within 0.01% of the current price, you should sell; if the lower Bollinger Band is within
* 0.01% of the current price, you should buy.
*
* Finn Frankis
* May 17, 2019
*/

(do-backward-chaining upperBollingerBand)
(do-backward-chaining lowerBollingerBand)
(do-backward-chaining midBollingerBand)

(defglobal ?*BOLLINGER_BAND_LOSS_GAP_FACTOR* = 0.5) ; the factor either above or below the top Bollinger band at which you should take a loss

/*
* The factor away from the price the upper or lower Bollinger Band can be to be considered equal to the current price. 
*/
(defglobal ?*BOLLINGER_BAND_EQUALITY_GAP_FACTOR* = 0.0001)

/*
* Determines whether the price can be considered equal to either the upper or lower Bollinger Band.
*/
(defrule equatePriceWithUpperandLowerBollingerBands "Determines whether or not the price is equal to the upper or lower Bollinger Band."
   (price ?p)
   (upperBollingerBand ?upperBB)
   (lowerBollingerBand ?lowerBB)
   =>
   (bind ?upperBBPriceError (abs (/ (- ?p ?upperBB) ?p)))
   (bind ?lowerBBPriceError (abs (/ (- ?p ?lowerBB) ?p)))

   (if (< ?upperBBPriceError ?*BOLLINGER_BAND_EQUALITY_GAP_FACTOR*) then (assert (priceEqualsUpperBB yes))
    else (assert (priceEqualsUpperBB no))
   )

   (if (< ?lowerBBPriceError ?*BOLLINGER_BAND_EQUALITY_GAP_FACTOR*) then (assert (priceEqualsLowerBB yes))
    else (assert (priceEqualsLowerBB no))
   )

   (bind ?movingAverage20 (/ (+ ?upperBB ?lowerBB) 2)) ; the upper and lower Bollinger Bands are defined to be equidistant from the 20-period moving average
   (assert (midBollingerBand ?movingAverage20))
   (assert (movingAverage20 ?movingAverage20))
)

/*
* Fires when the user should buy with a certain amount and lets them know when they should stop and when they should pull 
* out of the market, using the Bollinger Band method.
*
* The 
*/
(defrule bollingerBandBuy "Only fires when the user should buy with the Bollinger band method."
   (not (bollingerBand inviable)) ; this rule cannot fire if the Bollinger Band strategy has already been deemed inviable
   (priceEqualsLowerBB yes)
   (price ?p)
   (upperBollingerBand ?upperBB)
   (lowerBollingerBand ?lowerBB)
   (midBollingerBand ?midBB)
   =>
   (bind ?stopLoss (- ?p (* ?*BOLLINGER_BAND_LOSS_GAP_FACTOR* (- ?midBB ?lowerBB))))
   (printSolution "Bollinger Band" "buy" ?p ?stopLoss ?midBB)
)

/*
* Fires when the user should sell with a certain amount and lets them know when they should stop and when they should pull 
* out of the market, using the Bollinger band method.
*/
(defrule bollingerBandSell "Only fires when the user should sell with the Bollinger band method."
   (not (bollingerBand inviable)) ; this rule cannot fire if the Bollinger Band strategy has already been deemed inviable
   (priceEqualsUpperBB yes)
   (price ?p)
   (upperBollingerBand ?upperBB)
   (lowerBollingerBand ?lowerBB)
   (midBollingerBand ?midBB)
   =>
   (bind ?stopLoss (+ ?p (* ?*BOLLINGER_BAND_LOSS_GAP_FACTOR* (- ?upperBB ?midBB))))
   (printSolution "Bollinger Band" "sell" ?p ?stopLoss ?midBB)
)

/*
* Fires when the Bollinger Band method is inviable, allowing any future strategies to be executed.
*
* The Bollinger Band method is only inviable if the price is not within the Bollinger band,
* if the price is exactly equal to the mid-Bollinger band, or if the lower Bollinger band is above
* the upper Bollinger band.
*/
(defrule bollingerBandInviable "Fires if the Bollinger Band cannot determine a plan of action."
   (not (bollingerBand inviable)) ; this rule cannot fire if the Bollinger Band strategy has already been deemed inviable
   (and (priceEqualsUpperBB no) (priceEqualsLowerBB no))
   =>
   (printline "The Bollinger Band failed as a viable strategy. Let's move onto the crossover strategy.")
   (assert (bollingerBand inviable)) ; asserts inviability so that no future Bollinger Band rules can be fired
   (batch finalproject/crossover.clp)
)

/*
* Asks the user for the Bollinger band given the location (mid, upper, or lower).
*/
(deffunction askBollingerBand (?location)
   (return (askForNumber (str-cat "What is the current value of the " ?location "-Bollinger Band")))
)

/*
* The following rules are all backward-chained and ask the user about a given piece of market information when
* it is necessary to determine whether a rule can fire.
*/

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