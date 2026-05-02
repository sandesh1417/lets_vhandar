import 'package:flutter/material.dart';

class LayoutToggleButton extends StatelessWidget {
  final bool isVertical;
  final VoidCallback onToggle;

  const LayoutToggleButton({
    super.key,
    required this.isVertical,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isVertical ? Icons.view_sidebar_rounded : Icons.view_headline_rounded,
        color: Colors.black,
      ),
      onPressed: onToggle,
      tooltip: isVertical ? 'Switch to horizontal' : 'Switch to vertical',
    );
  }
}
