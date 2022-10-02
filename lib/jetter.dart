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
  Map get info => super.info..['child'] = child?.info;

  @override
  void mount(Element? parent) {
    super.mount(parent);
    rebuild();
  }

  @override
  void update(Widget newWidget) {
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

abstract class Widget with DebugInfo {
  Element get element;
  @override
  Map get info => {'element': element.info};
}

mixin DebugInfo {
  dynamic get info;
  String get infoString => [runtimeType, info].toString();
}

abstract class Element with BuildContext, DebugInfo implements BuildContext {
  Widget widget;
  Element(this.widget);
  Element? _parent;

  static final buildEvents = StreamController<String>();

  @override
  T? find<T>({bool listen = true}) {
    if (this is StashElement<T>) {
      return (widget as Stash<T>).data;
    }
    return _parent?.find<T>();
  }

  void get logHtml => rootHtml?.log;
  String? get rootHtml => root?.html;
  String? get html => renderObject?.htmlElement.text;

  HtmlElementRenderObject? get renderObject => this is RenderObjectElement
      ? (this as RenderObjectElement)._renderObject
      : _parent?.renderObject;

  Element? get root => isRoot ? this : _parent?.root;

  bool get isRoot => _parent == null;

  @override
  String toString() => infoString;

  @override
  Map get info => {'widget': widget, 'parent': _parent};

  @mustCallSuper
  void mount(Element? parent) {
    _parent = parent;
  }

  void rebuild() {
    buildEvents.add(widget.runtimeType.toString());
    performRebuild();
  }

  void performRebuild();

  @mustCallSuper
  Element? updateChild(Element? child, Widget newWidget) {
    return (child ??= inflateWidget(newWidget))..update(newWidget);
  }

  @mustCallSuper
  update(Widget newWidget) {
    widget = newWidget;
  }

  Element inflateWidget(Widget newWidget) {
    return (newWidget.element)..mount(this);
  }
}

abstract class State<T extends StatefulWidget> {
  Element? _element;

  T get widget => _element?.widget as T;

  @mustCallSuper
  void initState(BuildContext context) {}

  @mustCallSuper
  void dispose(BuildContext context) {}

  Widget build(BuildContext context);

  setState(Function() stateSetter) {
    stateSetter();
    _element?.rebuild();
  }
}

typedef El = HtmlElementWidget;

DivElement get div => DivElement();

abstract class StatelessWidget extends Widget {
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
  final OnClick? onClick;
  final CssStyleDeclaration? style;
  final Set<String> classes;
  HtmlElementWidget(
    this.htmlElement, {
    this.text,
    this.onClick,
    this.style,
    this.classes = const {},
    super.children,
  });

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
    if (widget.onClick != null) {
      subscription = htmlElement.onClick.listen((element) {
        widget.onClick?.call();
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
  Map get info => super.info..['renderObject'] = _renderObject?.info;

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
  }

  @override
  void performRebuild() {
    renderObject?.update(widget);
  }

  @override
  void update(Widget newWidget) {
    super.update(newWidget);
    rebuild();
    oldChildren = (newWidget as RenderObjectWidget)
        .children
        .nullZipWith(oldChildren, (n, o) => updateChild(o, n))
        .toList();
  }
}

typedef Builder = Widget Function(BuildContext context);

class Stash<T> extends Widget {
  final Builder builder;
  final T data;

  Stash(this.data, this.builder);
  @override
  Element get element => StashElement<T>(this);
}

class StashElement<T> extends ComponentElement {
  StashElement(super.widget);

  @override
  Widget build() => (widget as Stash).builder(this);
}

void runApp(Widget app) =>
    El(document.body!, children: [app]).element.mount(null);

extension on dynamic {
  get log => window.console.log(this);
}

extension<T> on Iterable<T> {
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
