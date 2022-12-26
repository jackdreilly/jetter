import 'dart:async';

import 'package:jetter/jetter.dart';

class StreamBuilder<T> extends StatefulWidget {
  final Function(BuildContext context, T value) builder;
  final Stream<T> Function(BuildContext context) create;
  final T initialValue;

  StreamBuilder(
      {required this.builder,
      required this.create,
      required this.initialValue});
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
        widget.create(context).listen((event) => setState(() => value = event));
  }

  @override
  void dispose(BuildContext context) {
    subscription?.cancel();
    super.dispose(context);
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, value);
}
