import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/auth_repository.dart';
import '../data/models/farmer_profile.dart';

// ── Repository provider ───────────────────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(Supabase.instance.client);
});

// ── Auth state ────────────────────────────────────────────────────────────

final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final currentUserProvider = Provider<User?>((ref) {
  return Supabase.instance.client.auth.currentUser;
});

// ── Current farmer profile ────────────────────────────────────────────────

final farmerProfileProvider =
    FutureProvider.autoDispose<FarmerProfile?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  final repo = ref.watch(authRepositoryProvider);
  final result = await repo.getProfile(user.id);
  return result.fold((_) => null, (profile) => profile);
});

// ── Sign in notifier ──────────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AsyncValue<FarmerProfile?>> {
  final AuthRepository _repo;

  AuthNotifier(this._repo) : super(const AsyncValue.data(null));

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    final result = await _repo.signIn(email: email, password: password);
    result.fold(
      (error) => state = AsyncValue.error(error, StackTrace.current),
      (profile) => state = AsyncValue.data(profile),
    );
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required DateTime gdprConsentAt,
  }) async {
    state = const AsyncValue.loading();
    final result = await _repo.signUp(
      email: email,
      password: password,
      fullName: fullName,
      gdprConsentAt: gdprConsentAt,
    );
    result.fold(
      (error) => state = AsyncValue.error(error, StackTrace.current),
      (profile) => state = AsyncValue.data(profile),
    );
  }

  Future<void> signOut() async {
    await _repo.signOut();
    state = const AsyncValue.data(null);
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<FarmerProfile?>>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});
