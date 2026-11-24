class UserProfile {
  final String id;
  final String username;
  final String email;

  const UserProfile({
    required this.id,
    required this.username,
    required this.email,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      username: map['username'] as String? ?? 'Unknown user',
      email: map['email'] as String? ?? '',
    );
  }
}
