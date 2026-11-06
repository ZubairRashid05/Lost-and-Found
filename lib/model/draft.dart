import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RequestDraft {
  const RequestDraft({
    required this.id,
    required this.title,
    required this.description,
    this.category,
    this.subcategory,
    this.location,
    this.imagePath,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String description;
  final String? category;
  final String? subcategory;
  final String? location;
  final String? imagePath;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'subcategory': subcategory,
    'location': location,
    'imagePath': imagePath,
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory RequestDraft.fromJson(Map<String, dynamic> json) => RequestDraft(
    id: json['id'] as String,
    title: json['title'] as String? ?? '',
    description: json['description'] as String? ?? '',
    category: json['category'] as String?,
    subcategory: json['subcategory'] as String?,
    location: json['location'] as String?,
    imagePath: json['imagePath'] as String?,
    updatedAt:
        DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0),
  );
}

class DraftStorage {
  static String get _userStorageKey {
    final userId = Supabase.instance.client.auth.currentUser?.id ?? 'guest';
    return 'request_drafts_$userId';
  }

  static const _guestStorageKey = 'request_drafts_guest';

  static Future<List<RequestDraft>> load() async {
    final prefs = SharedPreferencesAsync();
    var raw = await prefs.getString(_userStorageKey);

    // Drafts created before the Auth session was restored were saved as guest.
    if ((raw == null || raw.isEmpty) && _userStorageKey != _guestStorageKey) {
      raw = await prefs.getString(_guestStorageKey);
    }

    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw) as List<dynamic>;
    final drafts = decoded
        .map((item) => RequestDraft.fromJson(item as Map<String, dynamic>))
        .toList();
    drafts.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return drafts;
  }

  static Future<void> save(RequestDraft draft) async {
    final drafts = await load();
    final index = drafts.indexWhere((item) => item.id == draft.id);
    if (index == -1) {
      drafts.insert(0, draft);
    } else {
      drafts[index] = draft;
    }

    final prefs = SharedPreferencesAsync();
    await prefs.setString(
      _userStorageKey,
      jsonEncode(drafts.map((item) => item.toJson()).toList()),
    );
  }

  static Future<void> delete(String id) async {
    final drafts = await load();
    drafts.removeWhere((draft) => draft.id == id);
    final prefs = SharedPreferencesAsync();
    await prefs.setString(
      _userStorageKey,
      jsonEncode(drafts.map((item) => item.toJson()).toList()),
    );
  }
}
