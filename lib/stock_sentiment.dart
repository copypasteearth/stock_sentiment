library stock_sentiment;

import 'package:html/dom.dart';
import 'package:intl/intl.dart';
import 'package:sentiment_dart/sentiment_dart.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';

/// Headline class
/// date: the date of the headline
/// text: the text of the headline
/// link: the link to the article of the headline
class Headline {
  late DateTime date;
  late String text;
  late String extract;
  late String link;
  Headline(DateTime date, String text, String link, String extract) {
    this.date = date;
    this.text = text;
    this.link = link;
    this.extract = extract;
  }

  @override
  String toString() {
    return 'Headline{date: $date, text: $text, link: $link}';
  }
}

/// SentimentResult class
/// average: the average of headlines sentiment for the day
/// positive: how many positive sentiments for the day
/// negative: how many negative sentiments for the day
/// neutral: how many neutral sentiments for the day
class SentimentResult {
  late double average;
  late int positive;
  late int negative;
  late int neutral;
  SentimentResult(double average, int positive, int negative, int neutral) {
    this.average = average;
    this.positive = positive;
    this.negative = negative;
    this.neutral = neutral;
  }

  @override
  String toString() {
    return 'SentimentResult{average: $average, positive: $positive, negative: $negative, neutral: $neutral}';
  }
}

/// StockSentiment class initialized with String ticker
/// ticker is a space seperated string with different stock tickers
class StockSentiment {
  late String tickers;

  StockSentiment(String tickers) {
    this.tickers = tickers;
  }

  /// getHeadlines method
  /// gets all of the headlines for the given tickers
  /// returns null if any of the tickers are invalid
  Future<Map<String, List<Headline>>?> getHeadlines(int days) async {
    var now = DateTime.now();
    var earliest = now.subtract(new Duration(days: days));

    var ticks = tickers.split(" ");
    Map<String, List<Headline>> map = new Map();
    for (String tick in ticks) {
      //print(tick);
      List<Headline> list = [];
      var url = Uri.parse('https://finviz.com/quote.ashx?t=' + tick);
      var response = await http.get(url);
      //print('Response status: ${response.statusCode}');
      //print('Response body: ${response.body}');
      var doc = parse(response.body);
      var element = doc.getElementById("news-table");
      if (element == null) {
        continue;
      }
      //print(element!.outerHtml);
      var trs = element.getElementsByTagName("tr");
      var done = false;
      var dateprefix = '';
      var date = DateTime.now();
      for (Element ele in trs) {
        String headline = "";
        String link = "";
        String extract = "";
        for (Element td in ele.getElementsByTagName("td")) {
          //print(td.text);
          var tex = td.text;
          var sp = tex.split(' ');
          //print(sp.length);
          if (sp.length == 1) {
            date =
                DateFormat('MMM-dd-yy hh:mma').parse(dateprefix + " " + sp[0]);
          } else {
            date = DateFormat('MMM-dd-yy hh:mma').parse(sp[0] + " " + sp[1]);
            dateprefix = sp[0];
            if (earliest.isAfter(date)) {
              done = true;
              break;
            }
          }

          //headline += td.text + "--";
          break;
        }
        if (done) {
          break;
        }
        for (Element a in ele.getElementsByTagName("a")) {
          //print("a : " + a.text);
          link = a.attributes['href'] as String;
          print("actual headline: " + a.text);
          var content = await getArticleContent(link);
          if (content.isNotEmpty) {
            extract = content;
          } else {
            extract = a.text;
          }

          headline += a.text;
        }
        list.add(new Headline(date, headline, link, extract));
      }
      map[tick] = list;
    }

    return map;
  }

  /// getArticleContent
  /// gets the actual articles content unless status code is not 200
  Future<String> getArticleContent(String url) async {
    var response = await http.get(Uri.parse(url));
    var code = response.statusCode;
    if (code != 200) {
      return "";
    }
    var doc = parse(response.body);
    var p = doc.getElementsByTagName("p");
    var description = "";
    for (var para in p) {
      description += para.text;
    }

    return description;
  }

  /// getDailySentiment method
  /// returns a sentiment result for each day worth of headlines
  Map<String, Map<DateTime, SentimentResult>>? getDailySentiment(
      Map<String, List<Headline>> map) {
    final sentiment = Sentiment();
    var mapResult = new Map<String, Map<DateTime, SentimentResult>>();
    map.forEach((key, value) {
      var singleMap = new Map<DateTime, SentimentResult>();
      int result = 0;
      int average = 0;
      int positive = 0;
      int negative = 0;
      int neutral = 0;
      DateTime currentDate = value[0].date;
      for (Headline headline in value) {
        DateTime now = headline.date;
        if (now.day != currentDate.day) {
          var avgscore = result / average;
          singleMap[currentDate] =
              new SentimentResult(avgscore, positive, negative, neutral);
          neutral = 0;
          positive = 0;
          negative = 0;
          result = 0;
          average = 0;
          currentDate = now;
        }
        var sent = sentiment.analysis(headline.extract);
        var score = sent["score"] as int;
        if (score == 0) {
          neutral++;
        } else if (score > 0) {
          positive++;
        } else {
          negative++;
        }
        //print(sent);
        result += score;
        average++;
      }
      var avgscore = result / average;
      singleMap[currentDate] =
          new SentimentResult(avgscore, positive, negative, neutral);
      mapResult[key] = singleMap;
    });
    return mapResult;
  }

  /// getSingleSentiment
  /// takes a String of text to have sentiment analysis ran on
  /// returns score and other mapped data about the sentiment
  Map<String, dynamic> getSingleSentiment(String text) {
    final sentiment = Sentiment();
    var result = sentiment.analysis(text);
    return result;
  }
}
