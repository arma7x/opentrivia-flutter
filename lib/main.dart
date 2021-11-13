import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:opentrivia/api.dart';
import 'package:opentrivia/quizScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trivia Quiz',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Trivia Quiz'),
    );
  }
}

class MyHomePage extends StatefulWidget {

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  List<Map<String, dynamic>> categories = [{'id': 'any', 'name': 'Any Category'}];
  List<Map<String, String>> difficulties = [{'id': 'any', 'name': 'Any Difficulty'}, {'id': 'easy', 'name': 'Easy'}, {'id': 'medium', 'name': 'Medium'}, {'id': 'hard', 'name': 'Hard'}];
  List<Map<String, String>> types = [{'id': 'any', 'name': 'Any Type'}, {'id': 'multiple', 'name': 'Multiple Choice'}, {'id': 'boolean', 'name': 'True or False'}];

  final TextEditingController _amount = TextEditingController();
  Map<String, dynamic> category = {};
  Map<String, String> difficulty = {};
  Map<String, String> type = {};

  final _formKey = GlobalKey<FormState>();

  bool _loading = true;

  _MyHomePageState() {
    category = categories[0];
    difficulty = difficulties[0];
    type = types[0];
    getCategory();
  }

  void _loadingDialog(bool show) {
    if (show == true) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext _) {
          return AlertDialog(
            content: Container(child: new LinearProgressIndicator()),
          );
        },
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  void getCategory() async {
    try {
      final response = await Api.getCategory();
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        List<Map<String, dynamic>> _categories = [...categories];
        for (var i in responseBody['trivia_categories']) {
          _categories.add(Map<String, dynamic>.from(i));
        }
        setState(() {
          categories = _categories;
          _loading = false;
        });
        final snackBar = SnackBar(content: Text('Ready'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        setState(() {
          _loading = false;
        });
        final snackBar = SnackBar(content: Text('Server Error'));
        Scaffold.of(context).showSnackBar(snackBar);
      }
    } on Exception catch(e) {
      print(e);
      setState(() {
        _loading = false;
      });
      final snackBar = SnackBar(content: Text('Network Error'));
      Scaffold.of(context).showSnackBar(snackBar);
    }
  }

  void generateQuiz() async {
    _loadingDialog(true);
    try {
      final response = await Api.generateQuiz(
        int.parse(_amount.text),
        category: category['id'] == 'any' ? null : category['id'].toString(),
        difficulty: difficulty['id'] == 'any' ? null : difficulty['id'].toString(),
        type: type['id'] == 'any' ? null : type['id'].toString(),
      );
      final Map<String, dynamic> responseBody = json.decode(response.body);
      if (responseBody['results'].length > 0) {
        List<Map<String, dynamic>> _result = [];
        for (var i in responseBody['results']) {
          Map<String, dynamic> q = Map<String, dynamic>.from(i);
          q['incorrect_answers'].add(q['correct_answer']);
          q['incorrect_answers'].shuffle();
          _result.add(q);
        }
        _loadingDialog(false);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) {
            return QuizScreen(_result);
          }),
        );
      } else {
        _loadingDialog(false);
        final snackBar = SnackBar(content: Text('Adjust your requirement'));
        Scaffold.of(context).showSnackBar(snackBar);
      }
    } on Exception catch(e) {
      _loadingDialog(false);
      print(e);
      final snackBar = SnackBar(content: Text('Network Error'));
      Scaffold.of(context).showSnackBar(snackBar);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {},
              child: const Icon(
                  Icons.help
              ),
            )
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            _loading ? new LinearProgressIndicator(minHeight:5) : SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _amount,
                      decoration: const InputDecoration(
                        hintText: 'Please enter number of question',
                        labelText: 'Number Of Question',
                        contentPadding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (int.parse(value) > 50) {
                          return 'Maximum is 50 questions';
                        }
                        if (int.parse(value) <= 0) {
                          return 'Minimum is 1 question';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: 48,
                      child: DropdownButton<Map<String, dynamic>>(
                        isExpanded: true,
                        hint:  Text(category['name']),
                        value: null,
                        onChanged: (Map<String, dynamic>? value) {
                          setState(() {  category = value!; });
                        },
                        items: categories.map((Map<String, dynamic> value) {
                          return  DropdownMenuItem<Map<String, dynamic>>(
                            value: value,
                            child: Row(
                              children: <Widget>[
                                SizedBox(width: 10),
                                Text(
                                  value['name'],
                                  style: TextStyle(color: Colors.black),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(
                      height: 48,
                      child: DropdownButton<Map<String, String>>(
                        isExpanded: true,
                        hint:  Text(difficulty['name']!),
                        value: null,
                        onChanged: (Map<String, String>? value) {
                          setState(() { difficulty = value!; });
                        },
                        items: difficulties.map((Map<String, String> value) {
                          return  DropdownMenuItem<Map<String, String>>(
                            value: value,
                            child: Row(
                              children: <Widget>[
                                SizedBox(width: 10),
                                Text(
                                  value['name']!,
                                  style:  TextStyle(color: Colors.black),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(
                      height: 48,
                      child: DropdownButton<Map<String, String>>(
                        isExpanded: true,
                        hint:  Text(type['name']!),
                        value: null,
                        onChanged: (Map<String, String>? value) {
                          setState(() { type = value!; });
                        },
                        items: types.map((Map<String, String> value) {
                          return  DropdownMenuItem<Map<String, String>>(
                            value: value,
                            child: Row(
                              children: <Widget>[
                                SizedBox(width: 10),
                                Text(
                                  value['name']!,
                                  style:  TextStyle(color: Colors.black),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 48),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            generateQuiz();
                          }
                        },
                        child: const Text('GENERATE QUIZ'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
