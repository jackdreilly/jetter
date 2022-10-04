import 'dart:async';

import 'package:jetter/jetter.dart';
import 'package:reidle_jetter/wordle.dart';

void main() {
  runApp(App());
}

class Game extends Notifier {
  DateTime now = DateTime.now();

  Game() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      now = DateTime.now();
      notify;
    });
  }
  dispose() {}
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ListenerJet(
        create: (context) => Game(),
        dispose: (context, item) => item.dispose(),
        child: MediaQuery(
            child: Center(
                child: El(div,
                    style: style..height = '100vh',
                    child: Padding(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(children: [
                                WordleWidget("jacks", ['howdy', 'josdw']),
                                WordleInput(),
                              ]),
                              WordleKeyboardWidget("jacks", ['howdy', 'josdw'],
                                  onPressed: print)
                            ].spaced(SizedBox(height: 10))),
                        padding: EdgeInsets(top: 10))))),
      );
}

class WordleInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Txt(context.jet<Game>()?.value.now.toIso8601String() ?? "missing");
}
