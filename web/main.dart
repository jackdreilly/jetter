import 'dart:html';

import 'package:jetter/db.dart';
import 'package:jetter/jetter.dart';
import 'package:jetter/stream_builder.dart';

void main() {
  runApp(App());
}

class App extends StatefulWidget<AppState> {
  @override
  AppState get state => AppState(this);
}

class AppState extends State<App> {
  static final _db = db();
  int counter = _db.get("counter") ?? 0;
  AppState(super.widget);
  final Map<int, int> boost = {};

  @override
  Widget build(BuildContext context) {
    return El(
      div,
      text: counter.toString(),
      children: [
        El(div, children: [
          El(
            ButtonElement(),
            text: "Increment",
            style: CssStyleDeclaration()..backgroundColor = 'green',
            classes: {'neato', 'clickable'},
            onClick: () {
              setState(() => counter++);
              _db.set('counter', counter);
            },
          )
        ]),
        El(
          UListElement(),
          children: Iterable.generate(
            counter + 2,
            (index) => El(
              LIElement(),
              classes: {'clickable'},
              onClick: () =>
                  setState(() => boost[index] = (boost[index] ?? 0) + 1),
              text: (counter + index + index * index + (boost[index] ?? 0))
                  .toString(),
            ),
          ),
        ),
        StreamBuilder<DateTime>(
          (_, v) => El(div, text: v.toIso8601String()),
          timer(),
          DateTime.now(),
        )
      ],
    );
  }
}

Stream<DateTime> timer() async* {
  yield DateTime.now();
  await Future.delayed(1.seconds);
  yield* timer();
}

extension on int {
  Duration get seconds => Duration(seconds: this);
}
