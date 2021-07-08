# stock_sentiment

A package to get stock sentiment from headlines.

## Getting Started

## code quick example
```dart
import 'package:stock_sentiment/stock_sentiment.dart';

void main(){
//tickers have to be seperated by space
  var sentiment = StockSentiment("GOOG");
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

}
```

## functions
```dart

Future<Map<String,List<Headline>>> getHeadlines(int days) async
Map<String,Map<DateTime,SentimentResult>>? getDailySentiment(Map<String,List<Headline>> map)
Map<String,dynamic> getSingleSentiment(String text)

```

## classes
```dart
//a stock sentiment with String tickers, each seperated with space.
StockSentiment(String tickers)
//average sentiment, number of positive, negative, and neutral headlines
SentimentResult(double average, int positive,int negative,int neutral)
//Headline date, text, and link
Headline(DateTime date, String text, String link)



## uses and licenses
## Buckthorn Dev sentiment_dart: ^0.0.4 (MIT)
## the Dart project authors. http: ^0.13.3 (BSD)
## the Dart project authors. intl: ^0.17.0 (BSD)
## html: ^0.15.0 (MIT)
## html Contributors:

James Graham - jg307@cam.ac.uk

Anne van Kesteren - annevankesteren@gmail.com

Lachlan Hunt - lachlan.hunt@lachy.id.au

Matt McDonald - kanashii@kanashii.ca

Sam Ruby - rubys@intertwingly.net

Ian Hickson (Google) - ian@hixie.ch

Thomas Broyer - t.broyer@ltgt.net

Jacques Distler - distler@golem.ph.utexas.edu

Henri Sivonen - hsivonen@iki.fi

Adam Barth - abarth@webkit.org

Eric Seidel - eric@webkit.org

The Mozilla Foundation (contributions from Henri Sivonen since 2008)

David Flanagan (Mozilla) - dflanagan@mozilla.com

Google Inc. (contributed the Dart port) - misc@dartlang.org


