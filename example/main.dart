// @dart=2.9
import 'package:stock_sentiment/stock_sentiment.dart';
void main(){
  var sentiment = StockSentiment("GOO--");
  sentiment.getHeadlines(8).then((value){
    if(value != null){
      print(value);
      var stuff = sentiment.getDailySentiment(value);
      print(stuff);
      var single = sentiment.getSingleSentiment(value["GOOG"][0].text);
      print(single);
    }else{
      print("null ticker search or invalid ticker");
    }


  });

}