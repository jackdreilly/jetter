import 'package:jetter/jetter.dart';
export 'flex.dart';
export 'column.dart';
export 'row.dart';

class SizedBox extends StatelessWidget {
  final double height;
  final double width;

  const SizedBox({this.height = 0, this.width = 0});

  @override
  Widget build(BuildContext context) => El(div,
      style: style
        ..height = height.px
        ..width = width.px);
}
