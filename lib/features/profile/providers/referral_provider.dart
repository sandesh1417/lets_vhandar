import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_vhandar/di/service_locator.dart';
import 'package:lets_vhandar/features/profile/data/referral_repository.dart';

final referralProvider =
    FutureProvider.autoDispose<List<ReferredUser>>((ref) async {
  final repo = locator<ReferralRepository>();
  final result = await repo.fetchReferrals();
  return result.when(
    success: (data) => data,
    failure: (f) => throw Exception(f.message),
  );
});
