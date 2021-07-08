// @dart=2.9
/// import the stock sentiment package
import 'package:stock_sentiment/stock_sentiment.dart';

/// main() example
void main() {
  var sentiment = StockSentiment("GOOG");
  /// get headlines for 8 days
  sentiment.getHeadlines(8).then((value) {
    if (value != null) {
      print(value);
      /// get the sentiment for each day
      var stuff = sentiment.getDailySentiment(value);
      print(stuff);
      /// get a single headline sentiment
      var single = sentiment.getSingleSentiment(value["GOOG"][0].text);
      print(single);
    } else {
      print("null ticker search or invalid ticker");
    }
  });
}
