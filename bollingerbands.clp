/*
* Contains all the rules and functions related to solving the problem using the Bollinger Band strategy.
* 
* The Bollinger Band strategy first determines whether the current price is between the upper and lower Bollinger Bands.
* If so, the user will buy if the price is below the mid (average Bollinger Band), and the user will sell if the price is 
* above the mid Bollinger Band. 
*
* Finn Frankis
* May 17, 2019
*/

(do-backward-chaining upperBollingerBand)
(do-backward-chaining lowerBollingerBand)
(do-backward-chaining midBollingerBand)

(defglobal ?*BOLLINGER_BAND_GAP_FACTOR* = 0.5) ; the factor either above or below the top Bollinger band at which you should take a loss

(defrule equatePriceWithUpperandLowerBollingerBands "Determines whether or not the price is between the two Bollinger bands."
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
   (priceBetweenUpperAndLowerBB yes)
   (price ?p)
   (upperBollingerBand ?upperBB)
   (lowerBollingerBand ?lowerBB)
   (midBollingerBand ?midBB)
   (test (< ?p ?midBB))
   =>
   (bind ?stopLoss (- ?lowerBB (* ?*BOLLINGER_BAND_GAP_FACTOR* (- ?midBB ?lowerBB))))
   (printSolution "bollinger band" "buy" ?lowerBB ?stopLoss ?midBB)
)

/*
* Fires when the user should sell with a certain amount and lets them know when they should stop and when they should pull 
* out of the market, using the Bollinger band method.
*/
(defrule bollingerBandSell "Only fires when the user should sell with the Bollinger band method."
   (priceBetweenUpperAndLowerBB yes)
   (price ?p)
   (upperBollingerBand ?upperBB)
   (lowerBollingerBand ?lowerBB)
   (midBollingerBand ?midBB)
   (test (> ?p ?midBB))
   =>
   (bind ?stopLoss (+ ?upperBB (* ?*BOLLINGER_BAND_GAP_FACTOR* (- ?upperBB ?midBB))))
   (printSolution "Bollinger Band" "sell" ?upperBB ?stopLoss ?midBB)
)

/*
* Fires when the Bollinger Band method is inviable, allowing any future strategies to be executed.
*
* The Bollinger Band method is only inviable if the price is not within the Bollinger band,
* if the price is exactly equal to the mid-Bollinger band, or if the lower Bollinger band is above
* the upper Bollinger band.
*/
(defrule bollingerBandInviable "Fires if the moving average cannot determine a plan of action."
   (price ?p)
   (upperBollingerBand ?upperBB)
   (lowerBollingerBand ?lowerBB)
   (midBollingerBand ?midBB)
   (or (priceBetweenUpperAndLowerBB no) (test (> ?lowerBB ?upperBB)) (test (eq ?p ?midBB)))
   =>
   (printline "The Bollinger Band failed as a viable strategy. Let's move onto the crossover strategy.")
   (batch finalproject/crossover.clp)
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