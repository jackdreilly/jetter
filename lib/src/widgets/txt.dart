import 'package:jetter/jetter.dart';

class Txt extends StatelessWidget {
  final String text;

  Txt(this.text);

  @override
  Widget build(BuildContext context) => El(div, text: text);
}
