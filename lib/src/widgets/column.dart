import 'flex.dart';

class Column extends Flex {
  Column(
      {required super.children,
      super.crossAxisAlignment,
      super.mainAxisAlignment,
      super.mainAxisSize})
      : super(flexDirection: FlexDirection.column);
}
