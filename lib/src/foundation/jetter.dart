import 'dart:async';
import 'dart:html';

import 'package:meta/meta.dart';

mixin BuildContext {
  T? find<T>({bool listen = true});
}

abstract class StatefulWidget extends Widget {
  State get state;
  @override
  Element get element => StatefulElement(this);
}

class StatefulElement<S extends State<StatefulWidget>>
    extends ComponentElement {
  final State state;

  @override
  void drop() {
    state.dispose(this);
    super.drop();
  }

  StatefulElement(StatefulWidget statefulWidget)
      : state = statefulWidget.state,
        super(statefulWidget) {
    state
      .._element = this
      ..initState(this);
  }

  @override
  Widget build() => state.build(this);
}

abstract class ComponentElement extends Element {
  Element? child;

  ComponentElement(super.widget);

  @override
  visitChildren(Function(Element element) visitor) {
    final child = this.child;
    if (child != null) {
      visitor(child);
    }
  }

  @override
  void mount(Element? parent) {
    super.mount(parent);
    rebuild();
  }

  @override
  void update(covariant Widget newWidget) {
    super.update(newWidget);
    rebuild();
  }

  @override
  void performRebuild() {
    child = updateChild(child, build());
  }

  @protected
  Widget build();
}

mixin Key {}

abstract class Widget {
  final Key? key;
  const Widget({this.key});
  Element get element;
}

mixin DebugInfo {
  dynamic get info;
  String get infoString => [runtimeType, info].toString();
}

abstract class Element with BuildContext implements BuildContext {
  Widget widget;
  Element(this.widget);
  Element? _parent;
  final List<Function()> cleanups = [];

  @override
  T? find<T>({bool listen = true}) {
    Element? parent = this;
    while (parent is! StashElement<T> && parent != null) {
      parent = parent._parent;
    }
    if (parent == null) {
      return null;
    }
    final stash = parent as StashElement<T>;
    if (listen) {
      stash.add(this);
    }
    return stash.data;
  }

  HtmlElementRenderObject? get renderObject => this is RenderObjectElement
      ? (this as RenderObjectElement)._renderObject
      : _parent?.renderObject;

  Element? get root => isRoot ? this : _parent?.root;

  bool get isRoot => _parent == null;

  @mustCallSuper
  void mount(Element? parent) {
    _parent = parent;
  }

  void rebuild() {
    ['rb', widget.runtimeType].join(' ').log;
    performRebuild();
  }

  void performRebuild();

  @mustCallSuper
  Element? updateChild(Element? child, Widget? newWidget) {
    if (newWidget == null) {
      if (child != null) {
        child.drop();
      }
      return null;
    }
    if (child == null) {
      return inflateWidget(newWidget);
    }
    if (child.widget.runtimeType == newWidget.runtimeType) {
      if (child.widget != newWidget) {
        child.update(newWidget);
      }
      return child;
    }
    child.drop();
    return inflateWidget(newWidget);
  }

  @mustCallSuper
  update(Widget newWidget) {
    widget = newWidget;
  }

  @mustCallSuper
  Element inflateWidget(Widget newWidget) {
    return (newWidget.element)..mount(this);
  }

  @mustCallSuper
  void drop() {
    for (var cleanup in cleanups) {
      cleanup();
    }
    visitChildren((c) => c.drop());
  }

  visitChildren(Function(Element element) visitor) {}
}

abstract class State<T extends StatefulWidget> {
  late Element _element;

  BuildContext get context => _element;

  T get widget => _element.widget as T;

  @mustCallSuper
  void initState(BuildContext context) {}

  @mustCallSuper
  void dispose(BuildContext context) {}

  Widget build(BuildContext context);

  S setState<S>(S Function() stateSetter) {
    final value = stateSetter();
    _element.rebuild();
    return value;
  }
}

typedef El = HtmlElementWidget;

DivElement get div => DivElement();

abstract class StatelessWidget extends Widget {
  const StatelessWidget({super.key});
  @override
  Element get element => StatelessElement(this);

  Widget build(BuildContext context);
}

class StatelessElement extends ComponentElement {
  StatelessElement(super.widget);

  @override
  Widget build() => (widget as StatelessWidget).build(this);
}

typedef OnClick = void Function();

class HtmlElementWidget extends RenderObjectWidget {
  final HtmlElement htmlElement;
  final String? text;
  final OnClick? onTap;
  final CssStyleDeclaration? style;
  final Set<String> classes;

  HtmlElementWidget(this.htmlElement,
      {this.text,
      this.onTap,
      this.style,
      this.classes = const {},
      List<Widget> children = const [],
      Widget? child})
      : super(children: [...children, if (child != null) child]);

  @override
  HtmlElementRenderObject createRenderObject(BuildContext context) {
    final object = HtmlElementRenderObject(htmlElement);
    updateRenderObject(context, object);
    return object;
  }

  @override
  void updateRenderObject(
          BuildContext context, HtmlElementRenderObject renderObject) =>
      renderObject.update(this);
}

abstract class RenderObjectWidget extends Widget {
  final Iterable<Widget> children;

  RenderObjectWidget({this.children = const []});
  @override
  Element get element => RenderObjectElement(this);
  void updateRenderObject(
      BuildContext context, covariant HtmlElementRenderObject renderObject);
  HtmlElementRenderObject createRenderObject(BuildContext context);
}

class HtmlElementRenderObject with DebugInfo {
  final HtmlElement htmlElement;
  final Text text = Text("");

  StreamSubscription<MouseEvent>? subscription;

  HtmlElementRenderObject(this.htmlElement);
  @override
  Map get info => {'div': htmlElement};

  void update(Widget widget) {
    final div = widget as HtmlElementWidget;
    final divText = div.text;
    final firstChild = htmlElement.firstChild;
    if (divText != null) {
      if (firstChild != text) {
        htmlElement.insertBefore(text, htmlElement.firstChild);
      }
      firstChild?.text = divText;
    } else {
      if (firstChild == text) {
        htmlElement.children.remove(firstChild);
      }
    }

    subscription?.cancel();
    subscription = null;
    if (widget.onTap != null) {
      subscription = htmlElement.onClick.listen((element) {
        widget.onTap?.call();
      });
    }
    htmlElement.style.cssText = div.style?.cssText ?? "";
    htmlElement.classes = div.classes;
  }
}

class RenderObjectElement extends Element {
  HtmlElementRenderObject? _renderObject;

  List<Element?> oldChildren = [];
  RenderObjectElement(super.widget);
  RenderObjectWidget get renderObjectWidget => widget as RenderObjectWidget;
  @override
  visitChildren(Function(Element element) visitor) {
    oldChildren.where((e) => e != null).forEach((element) => visitor(element!));
  }

  @override
  void drop() {
    _renderObject?.htmlElement.remove();
    super.drop();
  }

  RenderObjectElement? get ancestor {
    Element? parent = _parent;
    while (parent != null) {
      if (parent is RenderObjectElement) {
        return parent;
      }
      parent = parent._parent;
    }
    return null;
  }

  @override
  void mount(Element? parent) {
    super.mount(parent);
    final object = renderObjectWidget.createRenderObject(this);
    _renderObject = object;
    ancestor?._renderObject?.htmlElement.append(object.htmlElement);
    oldChildren =
        renderObjectWidget.children.map((e) => updateChild(null, e)).toList();
    rebuild();
  }

  @override
  void performRebuild() {
    renderObject?.update(widget);
  }

  @override
  void update(Widget newWidget) {
    super.update(newWidget);
    rebuild();
    oldChildren
        .skip(renderObjectWidget.children.length)
        .forEach((element) => element?.drop());
    oldChildren = (newWidget as RenderObjectWidget)
        .children
        .nullZipWith(oldChildren, (n, o) => updateChild(o, n))
        .toList();
  }
}

typedef Builder = Widget Function(BuildContext context);

class Stash<T> extends Widget {
  final Widget child;
  final T data;

  Stash(this.data, this.child);
  @override
  Element get element => StashElement<T>(this);
}

class StashElement<T> extends ComponentElement {
  StashElement(super.widget);
  final dependencies = <Element>{};

  T get data => stash.data;
  Stash<T> get stash => widget as Stash<T>;

  @override
  void update(Stash<T> newWidget) {
    final oldWidgetData = data;
    super.update(newWidget);
    if (oldWidgetData != newWidget.data) {
      for (var element in dependencies) {
        element.rebuild();
      }
    }
  }

  @override
  Widget build() => (widget as Stash).child;

  void add(Element element) {
    dependencies.add(this);
    // element.cleanups.add(() => dependencies.remove(this));
  }
}

void runApp(Widget app) =>
    El(document.body!, children: [app]).element.mount(null);

extension Logger<T> on T {
  T get log {
    window.console.log(this);
    return this;
  }
}

extension<T> on Iterable<T> {
  Iterable<V> zipWith<U, V>(Iterable<U> us, V Function(T t, U u) fn) sync* {
    final itT = iterator;
    final itU = us.iterator;
    while (itT.moveNext() && itU.moveNext()) {
      yield fn(itT.current, itU.current);
    }
  }

  Iterable<V> nullZipWith<U, V>(
      Iterable<U> us, V Function(T t, U? u) fn) sync* {
    final itT = iterator;
    final itU = us.iterator;
    while (itT.moveNext()) {
      final u = itU.moveNext() ? itU.current : null;
      final t = itT.current;
      yield fn(t, u);
    }
  }
}

CssStyleDeclaration get style => CssStyleDeclaration();

extension StyleString<T extends num> on T {
  String get px => '${this}px';
}

extension SpacedList<T> on List<T> {
  List<T> spaced(T t) => isEmpty
      ? this
      : zipWith(t.repeat, (t, u) => [t, u])
          .flatten
          .take(length * 2 - 1)
          .toList();
}

extension<T> on T {
  Iterable<T> get repeat sync* {
    yield this;
    yield* repeat;
  }
}

extension<V> on Iterable<Iterable<V>> {
  Iterable<V> get flatten => expand(id);
}

T id<T>(T t) => t;
