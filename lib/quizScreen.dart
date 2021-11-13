import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {

  final List<Map<String, dynamic>> questions;

  const QuizScreen(this.questions, {Key? key}) : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState(this.questions);
}

class _QuizScreenState extends State<QuizScreen> {

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
      } else if (Uri.decodeFull(questions[i]['selected_answers']) == Uri.decodeFull(questions[i]['correct_answer'])) {
        _score++;
      }
    }
    if (miss.length > 0) {
      final snackBar = SnackBar(content: Text('Please answer questions ${miss.toString()}'));
      ctx.currentState?.showSnackBar(snackBar);
    } else {
      setState(() {
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
                  const Text("Question:"),
                  Text(Uri.decodeFull(questions[_index]['question'])),
                  SizedBox(height: 20),
                  Text("Category: ${Uri.decodeFull(questions[_index]['category'])}"),
                  SizedBox(height: 20),
                  Text("Difficulty: ${Uri.decodeFull(questions[_index]['difficulty'])}"),
                  SizedBox(height: 20),
                  Text("Type:  ${Uri.decodeFull(questions[_index]['type'])}"),
                  SizedBox(height: 20),
                  Text(
                    "Your Answer:  ${Uri.decodeFull(questions[_index]['selected_answers'] ?? '-')}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: finish == false ? Colors.black : (Uri.decodeFull(questions[_index]['selected_answers']) == Uri.decodeFull(questions[_index]['correct_answer']) ? Colors.green : Colors.red)
                    ),
                  ),
                  SizedBox(height: 20),
                  finish == true
                  ? Text(
                    "Correct Answer:  ${Uri.decodeFull(questions[_index]['correct_answer'] ?? '-')}",
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
                            return Container(
                              height: 43.0 * questions[_index]['incorrect_answers'].length.toDouble(),
                              color: Colors.white,
                              child: ListView.builder(
                                itemCount: questions[_index]['incorrect_answers'].length,
                                itemBuilder: (BuildContext context, int idx) {
                                  final String answer = Uri.decodeFull('${questions[_index]['incorrect_answers'][idx]}');
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
                                          Navigator.pop(context);
                                        },
                                      ),
                                    )
                                  );
                                }
                              ),
                            );
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
