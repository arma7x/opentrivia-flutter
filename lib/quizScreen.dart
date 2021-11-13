import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {

  final List<Map<String, dynamic>> questions;

  const QuizScreen(this.questions, {Key? key}) : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState(this.questions);
}

class _QuizScreenState extends State<QuizScreen> {

  int _index = 0;
  int total = 0;
  bool finish = false;

  List<Map<String, dynamic>> questions = [];

  _QuizScreenState(this.questions) {
    total = this.questions.length;
    //print(questions);
  }

  void _incrementCounter() {
    setState(() {
      _index++;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Question ${_index+1}"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(Uri.decodeFull(questions[_index]['question'])),
            Text(Uri.decodeFull(questions[_index]['category'])),
            Text(Uri.decodeFull(questions[_index]['difficulty'])),
            Row(
              children: <Widget>[
                Expanded(
                  child:GestureDetector(
                    onTap: () {
                      if (_index == 0) {
                        return;
                      }
                      setState(() { _index -= 1; });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.lightBlue,
                      ),
                      child: const Text(
                        'Prev',
                        style: TextStyle(color: Colors.white),
                      )
                    ),
                  )
                ),
                Expanded(
                  child:GestureDetector(
                    onTap: () {
                      if (_index == total-1) {
                        return;
                      }
                      setState(() { _index += 1; });
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.red,
                      ),
                      child: Text(
                        _index == total-1 ? 'Submit' : 'Next',
                        style: TextStyle(color: Colors.white),
                      )
                    ),
                  )
                ),
              ]
            )
          ],
        ),
      ),
    );
  }
}
