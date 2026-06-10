import 'package:flutter/material.dart';

Future<T?> showAppSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = false,
  Color backgroundColor = Colors.transparent,
  ShapeBorder? shape,
  BoxConstraints? constraints,
  bool useRootNavigator = false,
  bool isDismissible = true,
  bool enableDrag = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: backgroundColor,
    shape: shape,
    constraints: constraints,
    useRootNavigator: useRootNavigator,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    builder: (ctx) => SafeArea(
      top: false,
      bottom: true,
      left: false,
      right: false,
      child: builder(ctx),
    ),
  );
}
