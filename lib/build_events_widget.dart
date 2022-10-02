import 'dart:async';
import 'dart:html';

import 'package:jetter/jetter.dart';
import 'package:jetter/stream_builder.dart';

class BuildEventsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) => StreamBuilder(
        (_, events) => El(UListElement(),
            style: CssStyleDeclaration()
              ..border = "1px solid black"
              ..maxHeight = "100px"
              ..borderRadius = "10px",
            children: events.take(10).map((e) => El(LIElement(), text: e))),
        Element.buildEvents.stream.collected,
        [],
      );
}

extension<T> on Stream<T> {
  Stream<List<T>> get collected {
    final l = <T>[];
    return map((x) => l..add(x));
  }
}
