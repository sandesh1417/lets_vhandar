import 'package:flutter/material.dart';

import '../core/constants/color_constant.dart';

class CustomScaffoldWrapper extends StatelessWidget {
  final Widget body;
  final double? horizontalPadding;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool isScrollable;
  final Color? backgroundColor;
  final bool extendBodyBehindAppBar;
  final bool extendBody;
  final bool? resizeToAvoidBottomInset;

  const CustomScaffoldWrapper({
    super.key,
    required this.body,
    this.appBar,
    this.horizontalPadding,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.isScrollable = true,
    this.backgroundColor,
    this.extendBodyBehindAppBar = false,
    this.extendBody = false,
    this.resizeToAvoidBottomInset,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? AppColor.white,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      extendBody: extendBody,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
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
