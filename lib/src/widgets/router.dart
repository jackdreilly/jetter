import 'dart:html';

import '../foundation/jetter.dart';
import 'jet.dart';

typedef Resolver = Widget? Function(BuildContext context, String path);

class Router extends StatefulWidget {
  final Resolver resolver;

  Router({required this.resolver});

  @override
  State<StatefulWidget> get state => RouterState();
}

class RouterState extends State<Router> {
  @override
  void initState(BuildContext context) {
    if (!window.location.href.contains('#/')) {
      window.history.pushState({}, 'Home', '/#/');
    }
    super.initState(context);
  }

  @override
  Widget build(BuildContext context) => Jet(
      child: widget.resolver(context, window.location.href.hashPath) ??
          El(div, text: "missing"),
      create: (_) => this);

  _link(String path) =>
      setState(() => window.history.pushState({}, path, path));
}

class Link extends StatelessWidget {
  final String text;
  final String path;

  Link({required this.text, required this.path});

  @override
  Widget build(BuildContext context) =>
      El(AnchorElement(), text: text, onTap: () => context.link(path.linkify));
}

extension LinkBuildContext on BuildContext {
  link(String path) => jet<RouterState>(listen: false)?.value._link(path);
}

extension on String {
  String get linkify => startsWith('/')
      ? startsWith('/#')
          ? this
          : ('/#$this')
      : this;
}

extension on String {
  String get hashPath => contains('#/')
      ? endsWith('#/')
          ? ''
          : split('#/').last
      : split('/').skip(1).join('/');
}
