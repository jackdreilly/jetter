import 'dart:html';

import 'package:jetter/jetter.dart';

class Padding extends StatelessWidget {
  final EdgeInsets padding;
  final Widget child;

  Padding({required this.padding, required this.child});
  @override
  Widget build(BuildContext context) =>
      El(div, style: padding.asStyle, children: [child]);
}

class EdgeInsets {
  final double top;
  final double bottom;
  final double left;
  final double right;

  CssStyleDeclaration get asStyle => style
    ..width = 'inherit'
    ..height = 'inherit'
    ..paddingTop = top.px
    ..paddingBottom = bottom.px
    ..paddingLeft = left.px
    ..paddingRight = right.px;

  const EdgeInsets(
      {this.top = 0, this.bottom = 0, this.left = 0, this.right = 0});

  const EdgeInsets.all(double value)
      : top = value,
        bottom = value,
        left = value,
        right = value;
  const EdgeInsets.symmetric({double horizontal = 0, double vertical = 0})
      : top = vertical,
        bottom = vertical,
        left = horizontal,
        right = horizontal;
}
