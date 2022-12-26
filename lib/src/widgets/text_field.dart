import 'dart:html';

import 'package:jetter/jetter.dart';

class TextField extends StatefulWidget {
  final Function(String?)? onChange;
  final Function(String?)? onSubmit;

  TextField({this.onChange, this.onSubmit});

  @override
  State<StatefulWidget> get state => TextFieldState();
}

class TextFieldState extends State<TextField> {
  @override
  Widget build(BuildContext context) => El(InputElement()
    ..inputMode = 'text'
    ..onInput.listen((event) =>
        widget.onChange?.call((event.target as InputElement?)?.value))
    ..onKeyDown.listen((event) {
      if (event.key == 'Enter') {
        widget.onSubmit?.call((event.log.target as InputElement?)?.value);
      }
    }));
}
