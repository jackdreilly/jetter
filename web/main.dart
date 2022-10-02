import 'dart:html';

import 'package:jetter/build_events_widget.dart';
import 'package:jetter/db.dart';
import 'package:jetter/jetter.dart';
import 'package:jetter/padding.dart';
import 'package:jetter/stream_builder.dart';

void main() {
  runApp(App());
}

class App extends StatefulWidget {
  @override
  AppState get state => AppState();
}

class AppState extends State<App> {
  static final _db = db()..clear();
  int counter = _db.get("counter") ?? 0;

  @override
  Widget build(BuildContext context) {
    return Stash(
      42,
      (context) => El(
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
              (index) => Booster(index + counter),
            ),
          ),
          StreamBuilder(
            (_, v) => El(div, text: v.toIso8601String()),
            timer(),
            DateTime.now(),
          ),
          El(div, text: context.find<int>()?.toString() ?? "missing"),
          BuildEventsWidget(),
          Padding(10, El(div, text: "hi")),
        ],
      ),
    );
  }
}

class Booster extends StatefulWidget {
  final int index;
  Booster(this.index);

  @override
  State<StatefulWidget> get state => BoosterState();
}

class BoosterState extends State<Booster> {
  int boost = 0;

  @override
  Widget build(BuildContext context) => El(
        div,
        text: (boost + (widget.index)).toString(),
        onClick: () => setState(() => boost++),
      );
}

Stream<DateTime> timer() async* {
  yield DateTime.now();
  await Future.delayed(1.seconds);
  yield* timer();
}

extension on int {
  Duration get seconds => Duration(seconds: this);
}
