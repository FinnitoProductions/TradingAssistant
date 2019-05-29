/*
* Contains all the rules and functions related to solving the problem using the Bollinger Band strategy.
* 
* The Bollinger Band strategy succeeds if the upper or lower Bollinger Band is within 0.01% of the current price.
* If the upper Bollinger Band is within 0.01% of the current price, you should sell; if the lower Bollinger Band is within
* 0.01% of the current price, you should buy. Bollinger Bands are the lines plotted two standard deviations above and below
* the 20-period moving average.
*
* Finn Frankis
* May 17, 2019
*/

(do-backward-chaining upperBollingerBand)
(do-backward-chaining lowerBollingerBand)
(do-backward-chaining midBollingerBand)

(defglobal ?*BOLLINGER_BAND_LOSS_GAP_FACTOR* = 0.5) ; the factor either above or below the top Bollinger band at which you should take a loss

/*
* The factor away from the price that the upper or lower Bollinger Band can be to be considered equal to the current price (0.01%).
*/
(defglobal ?*BOLLINGER_BAND_EQUALITY_GAP_FACTOR* = 0.0001)

/*
* Determines whether the price can be considered equal to either the upper or lower Bollinger Bands.
*/
(defrule equatePriceWithUpperandLowerBollingerBands "Determines whether or not the price is equal to the upper or lower Bollinger Band."
   (price ?p)
   (upperBollingerBand ?upperBB)
   (lowerBollingerBand ?lowerBB)
   =>
   (bind ?upperBBPriceError (abs (/ (- ?p ?upperBB) ?p))) ; determine how close the upper and lower BB are to the current price
   (bind ?lowerBBPriceError (abs (/ (- ?p ?lowerBB) ?p)))

   (if (< ?upperBBPriceError ?*BOLLINGER_BAND_EQUALITY_GAP_FACTOR*) then (assert (priceEqualsUpperBB yes))
    else (assert (priceEqualsUpperBB no))
   )

   (if (< ?lowerBBPriceError ?*BOLLINGER_BAND_EQUALITY_GAP_FACTOR*) then (assert (priceEqualsLowerBB yes))
    else (assert (priceEqualsLowerBB no))
   )

   /*
   * Because the upper and lower Bollinger Bands are defined to be equidistant from the 20-period moving average,
   * the 20-period moving average is equal to the average of the upper and lower Bollinger Bands.
   */
   (bind ?movingAverage20 (/ (+ ?upperBB ?lowerBB) 2))
   (assert (midBollingerBand ?movingAverage20))
   (assert (movingAverage20 ?movingAverage20))
) ; equatePriceWithUpperAndLowerBollingerBands

/*
* Fires when the user should buy with a certain amount and lets them know when they should stop and when they should pull 
* out of the market, using the Bollinger Band method.
*
* If the price is approximately equal to the lower Bollinger Band, the user should buy with a profit equal to the mid-Bollinger Band
* and a stop-loss equal to half the distance between the mid and lower Bollinger Band.
*/
(defrule bollingerBandBuy "Only fires when the user should buy with the Bollinger Band method."
   (not (bollingerBand inviable)) ; this rule cannot fire if the Bollinger Band strategy has already been deemed inviable
   (priceEqualsLowerBB yes)
   (price ?p)
   (lowerBollingerBand ?lowerBB)
   (midBollingerBand ?midBB)
   =>
   (bind ?stopLoss (- ?p (* ?*BOLLINGER_BAND_LOSS_GAP_FACTOR* (- ?midBB ?lowerBB))))
   (printSolution "Bollinger Band" "buy" ?p ?stopLoss ?midBB)
)

/*
* Fires when the user should sell with a certain amount and lets them know when they should stop and when they should pull 
* out of the market, using the Bollinger band method.
*
* If the price is approximately equal to the upper Bollinger Band, the user should sell with a profit equal to the mid-Bollinger Band
* and a stop-loss equal to half the distance between the upper and mid Bollinger Band.
*/
(defrule bollingerBandSell "Only fires when the user should sell with the Bollinger Band method."
   (not (bollingerBand inviable)) ; this rule cannot fire if the Bollinger Band strategy has already been deemed inviable
   (priceEqualsUpperBB yes)
   (price ?p)
   (upperBollingerBand ?upperBB)
   (midBollingerBand ?midBB)
   =>
   (bind ?stopLoss (+ ?p (* ?*BOLLINGER_BAND_LOSS_GAP_FACTOR* (- ?upperBB ?midBB))))
   (printSolution "Bollinger Band" "sell" ?p ?stopLoss ?midBB)
)

/*
* Fires when the Bollinger Band method is inviable, allowing any future strategies to be executed.
*
* The Bollinger Band method is only inviable if the price is not approximately equal to either the upper or lower Bollinger Band.
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
* Asks the user for the Bollinger band of a given location ?location (mid, upper, or lower). Returns the numerical
* result of this query.
*/
(deffunction askBollingerBand (?location)
   (return (askForNumber (str-cat "What is the current value of the " ?location "-Bollinger Band")))
)

/*
* The following rules are all backward-chained and ask the user about a given piece of market information based on the Bollinger
* Band strategy when it is necessary to determine whether a rule can fire.
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