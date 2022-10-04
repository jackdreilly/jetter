import '../foundation/jetter.dart';
import 'flex.dart';
import 'proxy_widget.dart';
import 'row.dart';

class Center extends ProxyWidget {
  Center({required super.child});

  @override
  Widget build(BuildContext context) => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [child]);
}
