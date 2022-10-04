import '../foundation/jetter.dart';

class Flex extends StatelessWidget {
  final List<Widget> children;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final FlexDirection flexDirection;

  Flex({
    required this.children,
    required this.flexDirection,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
  });

  @override
  Widget build(BuildContext context) => El(div,
      style: style
        ..display = 'flex'
        ..flexWrap = 'nowrap'
        ..width = mainAxisSize.width
        ..height = mainAxisSize.height
        ..flexDirection = flexDirection.name.cssify
        ..justifyContent = mainAxisAlignment.name.cssify
        ..alignItems = crossAxisAlignment.name.cssify,
      children: children);
}

enum CrossAxisAlignment { center, start }

enum MainAxisAlignment { start, spaceBetween, center }

enum MainAxisSize { min, max }

enum FlexDirection { row, column }

extension on String {
  String get cssify => replaceAllMapped(
      RegExp(r'([A-Z])'), (m) => '-${m.group(0)?.toLowerCase() ?? ""}');
}

extension on MainAxisSize {
  String? get width => this == MainAxisSize.max ? '100%' : null;
  String? get height => width;
}
