/// The caller's profile row (GET/PATCH /api/profile).

library;

class UserProfile {
  const UserProfile({
    required this.id,
    this.displayName = 'User',
    this.langPref = 'en',
  });

  final String id;
  final String displayName;
  final String langPref;

  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
        id: (j['id'] ?? '').toString(),
        displayName: (j['display_name'] ?? 'User').toString(),
        langPref: (j['lang_pref'] ?? 'en').toString(),
      );

  UserProfile copyWith({String? displayName, String? langPref}) => UserProfile(
        id: id,
        displayName: displayName ?? this.displayName,
        langPref: langPref ?? this.langPref,
      );
}
