import 'dart:html';

import '../foundation/jetter.dart';
import 'builder.dart';
import 'jet.dart';

mixin MediaQueryHandle {
  Size get size;
}

class MediaQuery extends StatefulWidget {
  final Widget child;

  MediaQuery({required this.child});

  @override
  MediaQueryState get state => MediaQueryState();
  static MediaQueryHandle of(BuildContext context, {bool listen = true}) =>
      context.jet<MediaQueryState>(listen: listen)?.value ?? topLevelHandle;
}

class MediaQueryState extends State<MediaQuery> implements MediaQueryHandle {
  @override
  Size get size => MediaQuery.of(context, listen: false).size - mySize;
  Size get mySize => Size.zero;
  Widget get child => widget.child;
  Size get topSize => window.size;

  @override
  Widget build(BuildContext context) => Jet(
      child: BuilderWidget(
        (context) => Jet(
          child: child,
          create: (c) => window.onResize.listen(
              (event) => c.jet<MediaQueryState>(listen: false)?.trigger),
          dispose: (context, item) => item.cancel(),
        ),
      ),
      create: (_) => this);
}

class Size {
  final double width;
  final double height;

  static const zero = Size(width: 0, height: 0);

  const Size({required this.width, required this.height});

  operator -(Size other) =>
      Size(width: width - other.width, height: height - other.height);
}

extension on Window {
  Size get size => Size(
      height: (innerHeight ?? outerHeight).toDouble(),
      width: (innerWidth ?? outerWidth).toDouble());
}

TopLevelHandle get topLevelHandle => TopLevelHandle();

class TopLevelHandle implements MediaQueryHandle {
  @override
  Size get size => window.size;
}
