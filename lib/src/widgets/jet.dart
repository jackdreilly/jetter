import 'package:jetter/jetter.dart';

typedef Callback = Function();
mixin Listener {
  Callback subscribe(Function() callback);
}

class Notifier implements Listener {
  final List<Callback> callbacks = [];
  @override
  Callback subscribe(Callback callback) {
    callbacks.add(callback);
    return () => callbacks.remove(callback);
  }

  // ignore: avoid_function_literals_in_foreach_calls
  get notify => callbacks.forEach((element) => element());
}

class Jet<T> extends StatefulWidget {
  final Widget child;
  final T Function(BuildContext context) create;
  final Function(BuildContext context, T item)? dispose;

  Jet({required this.child, required this.create, this.dispose});

  @override
  JetState<T> get state => JetState();
}

class JetState<T> extends State<Jet<T>> {
  late T value;

  late JetStash<T> stash;

  @override
  void initState(BuildContext context) {
    super.initState(context);
    value = widget.create(context);
    assert(value is! Listener || this is ListenerJetState);
    updateStash;
  }

  @override
  void dispose(BuildContext context) {
    widget.dispose?.call(context, value);
    super.dispose(context);
  }

  get updateStash => stash = JetStash(this);

  get trigger => setState(() => updateStash);

  @override
  Widget build(BuildContext context) => Stash(stash, widget.child);
}

extension JetBuildContext on BuildContext {
  JetStash<T>? jet<T>({bool listen = true}) =>
      find<JetStash<T>>(listen: listen);
}

class JetStash<T> {
  final JetState<T> state;
  T get value => state.value;
  get trigger => state.trigger;
  JetStash(this.state);
}

class ListenerJet<T extends Listener> extends Jet<T> {
  ListenerJet({required super.child, required super.create, super.dispose});

  @override
  ListenerJetState<T> get state => ListenerJetState();
}

class ListenerJetState<T extends Listener> extends JetState<T> {
  late Callback canceller;

  @override
  void initState(BuildContext context) {
    super.initState(context);
    canceller = value.subscribe(() => trigger);
  }

  @override
  void dispose(BuildContext context) {
    canceller();
    super.dispose(context);
  }
}
