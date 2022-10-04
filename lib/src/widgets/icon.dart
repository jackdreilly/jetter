import 'dart:html';

import 'package:jetter/jetter.dart';

class Icon extends StatelessWidget {
  final IconData icon;

  final double size;

  Icon(this.icon, {this.size = 10});

  @override
  Widget build(BuildContext context) =>
      El(SpanElement(), style: style..fontSize = '${size}px', text: icon);
}

typedef IconData = String;

class Icons {
  static const check = '✓';

  static const backspace = '🔙';
}
