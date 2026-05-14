import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_vhandar/core/providers/layout_provider.dart';

class LayoutToggleButton extends ConsumerWidget {
  const LayoutToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isVertical = ref.watch(appLayoutProvider);

    return IconButton(
      icon: Icon(
        isVertical ? Icons.view_sidebar_rounded : Icons.view_headline_rounded,
        color: Colors.black,
      ),
      onPressed: () {
        ref.read(appLayoutProvider.notifier).toggleLayout();
      },
      tooltip: isVertical ? 'Switch to horizontal' : 'Switch to vertical',
    );
  }
}
