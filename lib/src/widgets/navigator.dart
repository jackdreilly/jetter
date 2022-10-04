import '../foundation/jetter.dart';
import 'jet.dart';

class Navigator extends StatefulWidget {
  final Widget child;

  Navigator(this.child);
  @override
  State<StatefulWidget> get state => NavigatorState();
}

class NavigatorState extends State<Navigator> {
  final List<Widget> stack = [];

  @override
  void initState(BuildContext context) {
    super.initState(context);
    stack.add(widget.child);
  }

  @override
  Widget build(BuildContext context) => Jet(
      child:
          stack.isEmpty ? El(div, text: "error - empty navigator") : stack.last,
      create: (_) => this);

  push(Widget widget) => setState(() => stack.add(widget));

  pop() => setState(() => stack.removeLast());
}

extension NavigatorContext on BuildContext {
  push(Widget widget) => n.push(widget);
  pop() => n.pop();
  NavigatorState get navState => jet()!.value;
}

extension on BuildContext {
  NavigatorState get n => jet(listen: false)!.value;
}
