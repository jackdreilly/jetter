import 'flex.dart';

class Row extends Flex {
  Row(
      {required super.children,
      super.crossAxisAlignment,
      super.mainAxisAlignment,
      super.mainAxisSize})
      : super(flexDirection: FlexDirection.row);
}
