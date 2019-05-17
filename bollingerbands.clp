/*
* Contains all the rules and functions related to solving the problem using the Bollinger Band strategy.
* 
* Finn Frankis
* May 17, 2019
*/
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

/*
* Fires when the user should buy with a certain amount and lets them know when they should stop and when they should pull 
* out of the market, using the Bollinger band method.
*/
(defrule bollingerBandBuy "Only fires when the user should buy with the Bollinger band method."
   (movingAverage no)
   (price ?p)
   (upperBollingerBand ?upperBB)
   (lowerBollingerBand ?lowerBB)
   (midBollingerBand ?midBB)
   (priceBetweenUpperAndLowerBB yes)
   (test (< ?p ?midBB))
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
   (price ?p)
   (upperBollingerBand ?upperBB)
   (lowerBollingerBand ?lowerBB)
   (midBollingerBand ?midBB)
   (priceBetweenUpperAndLowerBB yes)
   (test (> ?p ?midBB))
   =>
   (bind ?stopLoss (+ ?upperBB (* ?*BOLLINGER_BAND_GAP_PERCENT* (- ?upperBB ?midBB))))
   (printSolution "bollinger band" "sell" ?upperBB ?stopLoss ?midBB)
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