import 'package:flutter/foundation.dart';
import 'package:lost_and_found/model/user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  static final _supabase = Supabase.instance.client;

  static User? get authUser => _supabase.auth.currentUser;

  static UserProfile? get currentUser {
    final user = authUser;
    if (user == null) return null;

    return UserProfile(
      id: user.id,
      username: user.userMetadata?['username'] as String? ?? '',
      email: user.email ?? '',
    );
  }

  static Session? get currentSession => _supabase.auth.currentSession;

  static Future<List<UserProfile>> getAllUsers() async {
    final rows = await _supabase
        .from('users')
        .select('id, username, email')
        .order('username');

    return rows
        .map<UserProfile>(
          (row) => UserProfile.fromMap(Map<String, dynamic>.from(row)),
        )
        .toList();
  }

  static Future<UserProfile?> getUser(String userId) async {
    if (userId.trim().isEmpty) return null;

    try {
      final row = await _supabase
          .from('users')
          .select('id, username, email')
          .eq('id', userId.trim())
          .maybeSingle();

      if (row == null) {
        debugPrint('No user profile found for id: ${userId.trim()}');
        return null;
      }

      final profile = UserProfile.fromMap(Map<String, dynamic>.from(row));
      debugPrint('Loaded profile: ${profile.id} (${profile.username})');
      return profile;
    } catch (error, stackTrace) {
      debugPrint('Could not load user $userId: $error');
      debugPrintStack(stackTrace: stackTrace);
      return null;
    }
  }

  static Future<void> updateUsername(String username) async {
    final user = authUser;
    if (user == null) return;

    final response = await _supabase.auth.updateUser(
      UserAttributes(data: {'username': username}),
    );

    if (response.user != null) {
      await _supabase
          .from('users')
          .update({'username': username})
          .eq('id', response.user!.id);
    }
  }

  static Future<AuthResponse> createUser({
    required String email,
    required String username,
    required String password,
  }) {
    return _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'username': username},
    );
  }

  static Future<void> signOut() => _supabase.auth.signOut();
}
