import 'dart:developer';

import 'package:lets_vhandar/core/api/api_client.dart';
import 'package:lets_vhandar/core/config/api_endpoints.dart';
import 'package:lets_vhandar/core/error/failure.dart';
import 'package:lets_vhandar/core/utils/result.dart';

class ReferredUser {
  final String id;
  final DateTime createdAt;
  final String name;
  final String phoneCode;
  final String phoneNumber;
  final String? photoURL;

  const ReferredUser({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.phoneCode,
    required this.phoneNumber,
    this.photoURL,
  });

  factory ReferredUser.fromMap(Map<String, dynamic> map) {
    final referredTo = map['referredTo'] as Map<String, dynamic>? ?? {};
    return ReferredUser(
      id: map['_id'] as String? ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      name: referredTo['name'] as String? ?? 'Unknown',
      phoneCode: referredTo['phoneCode'] as String? ?? '+977',
      phoneNumber: referredTo['phoneNumber'] as String? ?? '',
      photoURL: referredTo['photoURL'] as String?,
    );
  }
}

class ReferralRepository {
  final ApiClient _apiClient;

  ReferralRepository(this._apiClient);

  Future<Result<List<ReferredUser>, Failure>> fetchReferrals() async {
    try {
      final result = await _apiClient.get(ApiUrl.referalUsers);
      switch (result) {
        case Success(value: final data):
          final raw = data['data'];
          final List<dynamic> items;
          if (raw is List) {
            items = raw;
          } else {
            log('[ReferralRepo] unexpected shape: $raw');
            items = [];
          }
          return Success(
            items
                .map((e) => ReferredUser.fromMap(Map<String, dynamic>.from(e)))
                .toList(),
          );
        case Error(failure: final f):
          throw f;
      }
    } on Failure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }
}
