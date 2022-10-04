import '../foundation/jetter.dart';
import 'stream_builder.dart';

class StreamProvider<T> extends StatelessWidget {
  final Widget child;

  final Stream stream;

  final T initialValue;

  StreamProvider(this.child, this.stream, this.initialValue);

  @override
  Widget build(BuildContext context) => StreamBuilder(
      (context, data) => Stash<T>(data, child), stream, initialValue);
}
