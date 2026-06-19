import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/widgets/custom_snackbar.dart';

/// Shows a "please login" snackbar and then routes a guest to the login screen.
///
/// Used wherever a guest taps an action that needs an account (managing
/// addresses, adding to cart, …) so the prompt is consistent across the app.
/// The router is captured up-front so the navigation is safe even if the
/// tapped widget is gone by the time the delay fires.
void redirectGuestToLogin(
  BuildContext context, {
  required String message,
  Duration delay = const Duration(seconds: 1),
}) {
  CustomSnackbar.info(context, message: message);
  final router = GoRouter.of(context);
  Future.delayed(delay, () => router.go(LVRoute.loginScreen.route));
}
