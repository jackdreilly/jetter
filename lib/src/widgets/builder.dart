import 'package:jetter/jetter.dart';

class BuilderWidget extends StatelessWidget {
  final Builder builder;

  BuilderWidget(this.builder);

  @override
  Widget build(BuildContext context) => builder(context);
}
