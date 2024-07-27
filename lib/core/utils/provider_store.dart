// import 'package:celestria/feature/auth/birth_detail/providers/birth_detail_post_provider.dart';
// import 'package:celestria/feature/auth/sign_up/providers/sign_up_provider.dart';
// import 'package:celestria/feature/change_password/providers/change_password_provider.dart';
// import 'package:celestria/feature/chat/providers/chat_provider.dart';
// import 'package:celestria/feature/natal_chart/providers/natal_chart_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:provider/single_child_widget.dart';

// import '../../feature/auth/birth_detail/providers/birth_detail_get_provider.dart';
// import '../../feature/auth/forgot_reset_password/providers/forgot_reset_password_provider.dart';
// import '../../feature/auth/login/general/providers/login_provider.dart';
// import '../../feature/landing/providers/landing_provider.dart';

// class ProviderStore extends MultiProvider {
//   ProviderStore({Key? key, required Widget child})
//       : super(key: key, providers: _ProviderStoreList.list, child: child);
// }

// class _ProviderStoreList {
//   static List<SingleChildWidget> list = [
//     ChangeNotifierProvider(create: (context) => LoginProvider()),
//     ChangeNotifierProvider(create: (context) => SignUpProvider()),
//     ChangeNotifierProvider(create: (context) => ChangePasswordProvider()),
//     ChangeNotifierProvider(create: (context) => ForgotResetPasswordProvider()),
//     ChangeNotifierProvider(create: (context) => BirthDetailProviderPost()),
//     ChangeNotifierProvider(create: (context) => BirthDetailProviderGet()),
//     ChangeNotifierProvider(create: (context) => ChatProvider()),
//     ChangeNotifierProvider(create: (context) => NatalChartProvider()),
//     ChangeNotifierProvider(create: (context) => LandingProvider()),
//   ];
// }
