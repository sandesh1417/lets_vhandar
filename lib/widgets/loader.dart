import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';

class LoadingOverlay {
  LoadingOverlay();
  bool _dialogIsOpen = false;

  void show(BuildContext context) {
    if (_dialogIsOpen) return;
    _dialogIsOpen = true;
    log("showing Loader");
    showDialog(
      barrierColor: Colors.black54.withValues(alpha: 0.2),
      barrierDismissible: false,
      context: context,
      builder: (context) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) _dialogIsOpen = false;
        },
        child: const Center(
          child: SizedBox(
            height: 150,
            width: 150,
            child: Center(child: CupertinoActivityIndicator(radius: 15)),
          ),
        ),
      ),
    ).whenComplete(() => _dialogIsOpen = false);
  }

  void hide(BuildContext context) {
    if (!_dialogIsOpen) return;
    _dialogIsOpen = false;
    context.pop();
  }
}

class CircularLoader extends StatelessWidget {
  const CircularLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: CupertinoActivityIndicator(
      color: AppColor.white,
    ));
  }
}
