import 'package:supabase_flutter/supabase_flutter.dart';

/// Global accessor for the Supabase client.
/// Use this instead of Supabase.instance.client directly in non-Riverpod code.
class SupabaseService {
  SupabaseService._();

  static SupabaseClient get client => Supabase.instance.client;
  static User? get currentUser => client.auth.currentUser;
  static Session? get currentSession => client.auth.currentSession;
  static bool get isLoggedIn => currentSession != null;

  static Future<Session> requireValidSession({
    bool forceRefresh = false,
  }) async {
    var session = client.auth.currentSession;
    if (session == null) {
      throw AuthSessionMissingException(
        'Your session has ended. Please sign in again.',
      );
    }

    if (forceRefresh || session.isExpired) {
      try {
        final refreshed = await client.auth.refreshSession();
        session = refreshed.session ?? client.auth.currentSession;
      } catch (_) {
        await client.auth.signOut();
        throw AuthSessionMissingException(
          'Your session has expired. Please sign in again.',
        );
      }
    }

    if (session == null || session.accessToken.isEmpty) {
      await client.auth.signOut();
      throw AuthSessionMissingException(
        'Your session is invalid. Please sign in again.',
      );
    }

    return session;
  }

  static Future<FunctionResponse> invokeAuthedFunction(
    String functionName, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    await requireValidSession();

    try {
      return await client.functions.invoke(
        functionName,
        headers: headers,
        body: body,
      );
    } on FunctionException catch (error) {
      if (error.status != 401) rethrow;

      await requireValidSession(forceRefresh: true);
      return client.functions.invoke(
        functionName,
        headers: headers,
        body: body,
      );
    }
  }

  /// Maps low-level backend/auth/function errors to stable user-safe messages.
  static String toUserMessage(
    Object error, {
    String fallback = 'Something went wrong. Please try again.',
  }) {
    if (error is AuthSessionMissingException) {
      return error.message;
    }
    if (error is AuthException) {
      return error.message;
    }
    if (error is FunctionException) {
      if (error.status == 401) {
        return 'Your session expired. Please sign in again.';
      }
      if (error.status == 403) {
        return 'You are not allowed to perform this action.';
      }
      return error.details?.toString().trim().isNotEmpty == true
          ? error.details.toString()
          : fallback;
    }
    if (error is PostgrestException) {
      if (error.code == '23505') {
        return 'This record already exists.';
      }
      if (error.code == '42501') {
        return 'You are not allowed to perform this action.';
      }
      return error.message.trim().isNotEmpty ? error.message : fallback;
    }
    if (error is String && error.trim().isNotEmpty) {
      return error;
    }
    return fallback;
  }
}
