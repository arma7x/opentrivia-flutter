import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';

class QuizScreen extends StatefulWidget {

  final List<Map<String, dynamic>> questions;

  const QuizScreen(this.questions, {Key? key}) : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState(this.questions);
}

class _QuizScreenState extends State<QuizScreen> {

  final unescape = HtmlUnescape();
  final GlobalKey<ScaffoldState> ctx = new GlobalKey<ScaffoldState>();

  int _index = 0;
  int total = 0;
  int score = 0;
  bool finish = false;

  List<Map<String, dynamic>> questions = [];

  _QuizScreenState(this.questions) {
    total = this.questions.length;
    //print(questions);
  }

  void _submit() {
    List<int> miss = [];
    int _score = 0;
    for(var i=0;i<questions.length;i++){
      if (questions[i]['selected_answers'] == null) {
        miss.add(i+1);
      } else if (unescape.convert(questions[i]['selected_answers']) == unescape.convert(questions[i]['correct_answer'])) {
        _score++;
      }
    }
    if (miss.length > 0) {
      final snackBar = SnackBar(content: Text('Please answer questions ${miss.toString()}'));
      ctx.currentState?.showSnackBar(snackBar);
    } else {
      setState(() {
        _index = -1;
        score = _score;
        finish = true;
      });
      _showScore();
    }
  }

  void _showScore() {
    final snackBar = SnackBar(content: Text('Your Score is ${score}/${total}'));
    ctx.currentState?.showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: ctx,
      appBar: AppBar(
        title: Text(_index+1 == total ? 'Last Question' : "Question ${_index+1}"),
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(8.0),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    "Question:",
                    style: TextStyle(
                      fontSize: 16
                    )
                  ),
                  SizedBox(height: 5),
                  Text(
                    unescape.convert(questions[_index]['question']),
                    style: TextStyle(
                      fontSize: 20
                    )
                  ),
                  SizedBox(height: 20),
                  Text("Category: ${unescape.convert(questions[_index]['category'])}"),
                  SizedBox(height: 20),
                  Text("Difficulty: ${unescape.convert(questions[_index]['difficulty'])}"),
                  SizedBox(height: 20),
                  Text("Type:  ${unescape.convert(questions[_index]['type'])}"),
                  SizedBox(height: 20),
                  Text(
                    "Your Answer:  ${unescape.convert(questions[_index]['selected_answers'] ?? '-')}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: finish == false ? Colors.black : (unescape.convert(questions[_index]['selected_answers']) == unescape.convert(questions[_index]['correct_answer']) ? Colors.green : Colors.red)
                    ),
                  ),
                  SizedBox(height: 20),
                  finish == true
                  ? Text(
                    "Correct Answer:  ${unescape.convert(questions[_index]['correct_answer'] ?? '-')}",
                    style: TextStyle(
                      color: Colors.lightBlue,
                      fontWeight: FontWeight.bold,
                    )
                  ) : SizedBox(height: 0)
                ]
              ),
            ),
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
                      if (finish == false) {
                        showModalBottomSheet<void>(
                          context: context,
                          builder: (BuildContext context) {
                            return StatefulBuilder(
                              builder: (BuildContext context, StateSetter _setState) {
                                return Container(
                                  width: double.infinity,
                                  height: 43.0 * questions[_index]['incorrect_answers'].length.toDouble(),
                                  color: Colors.white,
                                  child: ListView.builder(
                                    itemCount: questions[_index]['incorrect_answers'].length,
                                    itemBuilder: (BuildContext context, int idx) {
                                      final String answer = unescape.convert('${questions[_index]['incorrect_answers'][idx]}');
                                      return SizedBox(
                                        height: 40,
                                        child: ListTile(
                                          title: Text(answer),
                                          leading: Radio<String>(
                                            value: answer,
                                            groupValue: questions[_index]['selected_answers'],
                                            onChanged: (String? value) {
                                              questions[_index]['selected_answers'] = value;
                                              setState(() { questions = questions; });
                                              _setState(() { questions = questions; });
                                              //Navigator.pop(context);
                                            },
                                          ),
                                        )
                                      );
                                    }
                                  ),
                                );
                            });
                          },
                        );
                      } else {
                        _showScore();
                      }
                    },
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                      ),
                      child: Text(
                        finish == false ? 'Answer' : 'SCORE',
                        style: TextStyle(color: Colors.white),
                      )
                    ),
                  )
                ),
                Expanded(
                  child:GestureDetector(
                    onTap: () {
                      if (_index == total-1 && finish == false) {
                        _submit();
                      }
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
                        finish == true ? 'Next' : (_index == total-1 ? 'SUBMIT' : 'Next'),
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
