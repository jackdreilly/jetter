import '../foundation/jetter.dart';
import 'proxy_widget.dart';

class Expanded extends ProxyWidget {
  final double flex;
  Expanded({required super.child, this.flex = 1});

  @override
  Widget build(BuildContext context) =>
      El(div, style: style..flexGrow = flex.toString(), child: child);
}
