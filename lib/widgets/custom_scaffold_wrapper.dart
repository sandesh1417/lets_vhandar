import 'package:flutter/material.dart';

import '../core/constants/color_constant.dart';

class CustomScaffoldWrapper extends StatelessWidget {
  final Widget body;
  final double? horizontalPadding;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool isScrollable;
  final Color? backgroundColor;

  const CustomScaffoldWrapper({
    super.key,
    required this.body,
    this.appBar,
    this.horizontalPadding,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.isScrollable = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? AppColor.white,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      body: SafeArea(
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1),
          ),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding ?? 0),
            child: isScrollable ? SingleChildScrollView(child: body) : body,
          ),
        ),
      ),
    );
  }
}
