import 'dart:html';

import 'package:jetter/jetter.dart';

class Button extends StatelessWidget {
  final Function()? onTap;
  final String? text;
  final Widget? child;

  Button({this.onTap, this.text, this.child});

  @override
  Widget build(BuildContext context) => El(ButtonElement(),
      text: text, onTap: onTap, children: [if (child != null) child!]);
}
