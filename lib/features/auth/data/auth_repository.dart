import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dartz/dartz.dart';

import '../../../core/constants/supabase_constants.dart';
import 'avatar_service.dart';
import 'models/farmer_profile.dart';

/// Handles all authentication and profile operations via Supabase.
class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

  AvatarService get avatarService => AvatarService(_client);

  // ── Auth state ────────────────────────────────────────────────────────────

  Session? get currentSession => _client.auth.currentSession;
  User? get currentUser => _client.auth.currentUser;
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // ── Sign up ───────────────────────────────────────────────────────────────

  Future<Either<String, FarmerProfile>> signUp({
    required String email,
    required String password,
    required String fullName,
    required DateTime gdprConsentAt,
  }) async {
    try {
      // Pass gdpr_consent_at in metadata so the SECURITY DEFINER trigger
      // (handle_new_user) can write it — avoids RLS issues on the direct upsert
      // that would happen before the session JWT is established.
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'gdpr_consent_at': gdprConsentAt.toIso8601String(),
        },
      );

      if (response.user == null) {
        return const Left('Sign up failed — no user returned');
      }

      // Profile row is created by the DB trigger — return a local profile object.
      final profile = FarmerProfile(
        id: response.user!.id,
        email: email,
        fullName: fullName,
        gdprConsentAt: gdprConsentAt,
      );

      return Right(profile);
    } on AuthException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left(e.toString());
    }
  }

  // ── Sign in ───────────────────────────────────────────────────────────────

  Future<Either<String, FarmerProfile>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) return const Left('Login failed');

      return getProfile(response.user!.id);
    } on AuthException catch (e) {
      return Left(e.message);
    } catch (e) {
      return Left(e.toString());
    }
  }

  // ── Sign out ──────────────────────────────────────────────────────────────

  Future<void> signOut() async => _client.auth.signOut();

  // ── Profile CRUD ──────────────────────────────────────────────────────────

  Future<Either<String, FarmerProfile>> getProfile(String userId) async {
    try {
      final data = await _client
          .from(SupabaseConstants.profilesTable)
          .select()
          .eq('id', userId)
          .single();
      return Right(FarmerProfile.fromJson(data));
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, FarmerProfile>> updateProfile(
      FarmerProfile profile) async {
    try {
      final data = await _client
          .from(SupabaseConstants.profilesTable)
          .update(profile.toJson())
          .eq('id', profile.id)
          .select()
          .single();
      return Right(FarmerProfile.fromJson(data));
    } catch (e) {
      return Left(e.toString());
    }
  }

  // ── Password reset ────────────────────────────────────────────────────────

  Future<Either<String, void>> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(e.message);
    }
  }
}
