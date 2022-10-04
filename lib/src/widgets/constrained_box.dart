import 'dart:html';

import 'package:jetter/jetter.dart';

class ConstrainedBox extends StatelessWidget {
  final Widget child;
  final BoxConstraints constraints;

  ConstrainedBox({required this.child, this.constraints = BoxConstraints.none});

  @override
  Widget build(BuildContext context) =>
      El(div, style: constraints.asStyle, child: child);
}

class BoxConstraints {
  static const none = BoxConstraints();
  final double? maxWidth;

  const BoxConstraints({this.maxWidth});

  CssStyleDeclaration get asStyle => style..maxWidth = maxWidth?.px;
}
