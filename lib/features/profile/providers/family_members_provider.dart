import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_vhandar/core/utils/result.dart';
import 'package:lets_vhandar/di/service_locator.dart';
import 'package:lets_vhandar/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:lets_vhandar/features/auth/login/providers/login_provider.dart';
import 'package:lets_vhandar/widgets/custom_snackbar.dart';

const kFamilyRelations = [
  'Father',
  'Mother',
  'Sister',
  'Brother',
  'Others',
];

class FamilyMembersState {
  // Data
  final bool isLoadingData;
  final List<Map<String, dynamic>> members;
  final List<Map<String, dynamic>> pendingRequests;
  final String? loadError;

  // Search (add-member sheet)
  final bool isSearching;
  final Map<String, dynamic>? foundUser;
  final String? searchError;
  final String selectedRelation;

  // Operations
  final bool isSending;
  final bool isActioning;

  const FamilyMembersState({
    this.isLoadingData = false,
    this.members = const [],
    this.pendingRequests = const [],
    this.loadError,
    this.isSearching = false,
    this.foundUser,
    this.searchError,
    this.selectedRelation = 'Others',
    this.isSending = false,
    this.isActioning = false,
  });

  FamilyMembersState copyWith({
    bool? isLoadingData,
    List<Map<String, dynamic>>? members,
    List<Map<String, dynamic>>? pendingRequests,
    String? loadError,
    bool clearLoadError = false,
    bool? isSearching,
    Map<String, dynamic>? foundUser,
    bool clearFoundUser = false,
    String? searchError,
    bool clearSearchError = false,
    String? selectedRelation,
    bool? isSending,
    bool? isActioning,
  }) {
    return FamilyMembersState(
      isLoadingData: isLoadingData ?? this.isLoadingData,
      members: members ?? this.members,
      pendingRequests: pendingRequests ?? this.pendingRequests,
      loadError: clearLoadError ? null : (loadError ?? this.loadError),
      isSearching: isSearching ?? this.isSearching,
      foundUser: clearFoundUser ? null : (foundUser ?? this.foundUser),
      searchError:
          clearSearchError ? null : (searchError ?? this.searchError),
      selectedRelation: selectedRelation ?? this.selectedRelation,
      isSending: isSending ?? this.isSending,
      isActioning: isActioning ?? this.isActioning,
    );
  }
}

final familyMembersProvider =
    StateNotifierProvider<FamilyMembersNotifier, FamilyMembersState>((ref) {
  return FamilyMembersNotifier(locator<AuthRepositoryImpl>(), ref);
});

class FamilyMembersNotifier extends StateNotifier<FamilyMembersState> {
  final AuthRepositoryImpl _repo;
  final Ref _ref;

  FamilyMembersNotifier(this._repo, this._ref)
      : super(const FamilyMembersState());

  // ── Data Loading ────────────────────────────────────────────────────────────

  Future<void> loadData() async {
    final userId = _ref.read(loginProvider).user?.id;
    if (userId == null) return;
    state = state.copyWith(isLoadingData: true, clearLoadError: true);

    final membersResult = await _repo.getFamilyMembers(userId);
    final requestsResult = await _repo.getPendingFamilyRequests(userId);

    state = state.copyWith(
      isLoadingData: false,
      members: switch (membersResult) {
        Success(value: final v) => v,
        Error() => state.members,
      },
      pendingRequests: switch (requestsResult) {
        Success(value: final v) => v,
        Error() => state.pendingRequests,
      },
    );
  }

  // ── Search ──────────────────────────────────────────────────────────────────

  void resetSearch() {
    state = state.copyWith(
      clearFoundUser: true,
      clearSearchError: true,
      selectedRelation: 'Others',
    );
  }

  Future<void> searchByPhone(String phone) async {
    if (phone.trim().isEmpty) return;
    state = state.copyWith(
      isSearching: true,
      clearFoundUser: true,
      clearSearchError: true,
    );
    final result = await _repo.searchUserByPhone(phone.trim());
    switch (result) {
      case Success(value: final user):
        if (user == null) {
          state = state.copyWith(
            isSearching: false,
            searchError: 'No user found with this number',
            clearFoundUser: true,
          );
        } else {
          state = state.copyWith(
            isSearching: false,
            foundUser: user,
            clearSearchError: true,
          );
        }
      case Error(failure: final f):
        state = state.copyWith(
          isSearching: false,
          searchError: f.message,
          clearFoundUser: true,
        );
    }
  }

  void setRelation(String relation) {
    state = state.copyWith(selectedRelation: relation);
  }

  // ── Send Invite ─────────────────────────────────────────────────────────────

  Future<bool> sendRequest(BuildContext context) async {
    final me = _ref.read(loginProvider).user;
    final found = state.foundUser;
    if (me == null || found == null) return false;

    final myId = me.id!;
    final memberId = (found['_id'] as String?) ?? '';
    if (memberId.isEmpty) return false;

    state = state.copyWith(isSending: true);
    final result = await _repo.sendFamilyRequest(
      memberId: memberId,
      familyIds: [myId, memberId],
      requestedBy: myId,
      relation: state.selectedRelation,
    );
    switch (result) {
      case Success():
        state = state.copyWith(isSending: false);
        await loadData();
        if (context.mounted) {
          CustomSnackbar.success(context, message: 'Family request sent!');
        }
        return true;
      case Error(failure: final f):
        state = state.copyWith(isSending: false);
        if (context.mounted) {
          CustomSnackbar.error(context, message: f.message);
        }
        return false;
    }
  }

  // ── Accept ──────────────────────────────────────────────────────────────────

  Future<void> acceptRequest(
      BuildContext context, String requestId, String relation) async {
    state = state.copyWith(isActioning: true);
    final result = await _repo.acceptFamilyRequest(requestId, relation);
    switch (result) {
      case Success():
        await loadData();
        if (context.mounted) {
          CustomSnackbar.success(context, message: 'Request accepted!');
        }
      case Error(failure: final f):
        if (context.mounted) {
          CustomSnackbar.error(context, message: f.message);
        }
    }
    state = state.copyWith(isActioning: false);
  }

  // ── Remove / Reject ──────────────────────────────────────────────────────────

  Future<void> removeMember(BuildContext context, String requestId) async {
    state = state.copyWith(isActioning: true);
    final result = await _repo.removeFamilyMember(requestId);
    switch (result) {
      case Success():
        await loadData();
        if (context.mounted) {
          CustomSnackbar.success(context, message: 'Removed successfully.');
        }
      case Error(failure: final f):
        if (context.mounted) {
          CustomSnackbar.error(context, message: f.message);
        }
    }
    state = state.copyWith(isActioning: false);
  }
}
