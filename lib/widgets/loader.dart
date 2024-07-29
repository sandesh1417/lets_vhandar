import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lets_vhandar/core/constants/color_constant.dart';

import '../../core/utils/navigator_services.dart';

class LoadingOverlay {
  LoadingOverlay();
  bool _dialogIsOpen = false;

  show(BuildContext context) {
    if (!_dialogIsOpen) {
      log("showing Loader");
      showDialog(
        barrierColor: Colors.black54.withOpacity(0.2),
        barrierDismissible: false,
        context: context,
        builder: (context) {
          _dialogIsOpen = true;
          return WillPopScope(
            onWillPop: () async {
              _dialogIsOpen = false;
              return true;
            },
            child: Center(
              child: Container(
                height: 150,
                width: 150,
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(15))),
                child: const SizedBox(
                  height: 150,
                  width: 150,
                  child: Center(
                      child: CupertinoActivityIndicator(
                    radius: 15,
                  )),
                ),
              ),
            ),
          );
        },
      );
    } else {
      hide(context);
    }
  }

  void hide(BuildContext context) {
    if (_dialogIsOpen) {
      _dialogIsOpen = false;
      popDialog(context: context);
    }
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
