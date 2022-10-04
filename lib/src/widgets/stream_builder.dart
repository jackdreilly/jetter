import 'dart:async';

import 'package:jetter/jetter.dart';

class StreamBuilder<T> extends StatefulWidget {
  final Function(BuildContext context, T value) builder;
  final Stream<T> stream;
  final T initialValue;

  StreamBuilder(this.builder, this.stream, this.initialValue);
  @override
  StreamBuilderState<T> get state => StreamBuilderState();
}

class StreamBuilderState<T> extends State<StreamBuilder<T>> {
  late StreamSubscription? subscription;
  late T value;

  @override
  void initState(BuildContext context) {
    super.initState(context);
    value = widget.initialValue;
    subscription =
        widget.stream.listen((event) => setState(() => value = event));
  }

  @override
  void dispose(BuildContext context) {
    subscription?.cancel();
    super.dispose(context);
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, value);
}
