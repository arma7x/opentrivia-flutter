import 'dart:core';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Api {

  static const String baseUrl = 'opentdb.com';
  static const String api = 'api.php';
  static const String apiToken = 'api_token.php';
  static const String apiCategory = 'api_category.php';

  static Future getToken() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('TOKEN');
      int? timestamp = prefs.getInt('TIMESTAMP');
      if (timestamp == null) {
        Map<String, String> query = {'command': 'request'};
        final response = await http.get(Uri.https(baseUrl, apiToken, query));
        if (response.statusCode == 200) {
          final responseBody = json.decode(response.body);
          await prefs.setString('TOKEN', responseBody['token']);
          await prefs.setInt('TIMESTAMP', DateTime.now().millisecondsSinceEpoch);
          return await Future<String>.value(responseBody['token']);
        } else {
          return await Future<void>.value(null);
        }
      } else if (DateTime.now().millisecondsSinceEpoch - timestamp >= 18000000) {
        Map<String, String> query = {'command': 'reset', 'token': token!};
        final response = await http.get(Uri.https(baseUrl, apiToken, query));
        if (response.statusCode == 200) {
          await prefs.setInt('TIMESTAMP', DateTime.now().millisecondsSinceEpoch);
          return await Future<String>.value(token);
        } else {
          return await Future<void>.value(null);
        }
      }
      return await Future<String>.value(token);
    } on Exception {
      return await Future<void>.value(null);
    }
  }

  static Uri makeUrl(String url) {
    Map<String, String> query = {'url': url};
    return Uri.https('kaios.tri1.workers.dev', '', query);
  }
  
  static Future getCategory() async {
    final url = Uri.https(baseUrl, apiCategory);
    return await http.get(makeUrl(url.toString()));
  }

  static Future generateQuiz(int amount, {String? category, String? type, String? difficulty, String? token}) async {
    Map<String, String> query = {};
    query['amount'] = amount.toString();
    if (category != null) {
      query['category'] = category;
    }
    if (type != null) {
      query['type'] = type;
    }
    if (difficulty != null) {
      query['difficulty'] = difficulty;
    }
    if (token != null) {
      query['token'] = token;
    }
    //query['encode'] = 'base64';
    final url = Uri.https(baseUrl, api, query);
    return await http.get(makeUrl(url.toString()));
  }
}
