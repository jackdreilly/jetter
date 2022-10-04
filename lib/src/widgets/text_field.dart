import 'dart:html';

import 'package:jetter/jetter.dart';

class TextField extends StatefulWidget {
  final Function(String?)? onChange;

  TextField({this.onChange});

  @override
  State<StatefulWidget> get state => TextFieldState();
}

class TextFieldState extends State<TextField> {
  @override
  Widget build(BuildContext context) => El(InputElement()
    ..inputMode = 'text'
    ..onInput.listen((event) =>
        widget.onChange?.call((event.target as InputElement?)?.value)));
}
