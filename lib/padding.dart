import 'dart:html';

import 'package:jetter/jetter.dart';

class Padding extends StatelessWidget {
  final int padding;
  final Widget child;

  Padding(this.padding, this.child);
  @override
  Widget build(BuildContext context) => El(div,
      style: CssStyleDeclaration()..padding = '${padding}px',
      children: [child]);
}
