import 'package:jetter/jetter.dart';

class Container extends StatelessWidget {
  final Widget? child;

  Container({this.child});

  @override
  Widget build(BuildContext context) => El(div, child: child);
}
