import 'dart:async';

import 'package:jetter/jetter.dart';

class StreamBuilder<T> extends StatefulWidget<StreamBuilderState<T>> {
  final Function(BuildContext context, T value) builder;
  final Stream<T> stream;
  final T initialValue;

  StreamBuilder(this.builder, this.stream, this.initialValue);

  @override
  StreamBuilderState<T> get state => StreamBuilderState(this);
}

class StreamBuilderState<T> extends State<StreamBuilder<T>> {
  StreamSubscription? subscription;
  StreamBuilderState(super.widget) : value = widget.initialValue {
    subscription =
        widget.stream.listen((event) => setState(() => value = event));
  }

  @override
  void initState(BuildContext context) {
    super.initState(context);
  }

  @override
  void dispose(BuildContext context) {
    subscription?.cancel();
    super.dispose(context);
  }

  T value;

  @override
  Widget build(BuildContext context) => widget.builder(context, value);
}
