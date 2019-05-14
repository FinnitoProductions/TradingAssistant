package finalproject;

/** 
* Retrieves currency data from the internet.
* 
* @author Finn Frankis
* @version April 2, 2019
*/
public class StockRetriever {
    private final String RETRIEVAL_URL;
    private double x = 4;

    public StockRetriever (String retrievalURL) {
        RETRIEVAL_URL = retrievalURL;
    }

    public double getStockData () {
        System.out.println(RETRIEVAL_URL);
        return x;
    }
}