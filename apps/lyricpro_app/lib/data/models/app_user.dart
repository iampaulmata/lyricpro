import 'package:meta/meta.dart';

@immutable
class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.avatarUrl,
  });

  final String id;
  final String? email;
  final String? name;
  final String? avatarUrl;

  factory AppUser.fromSupabase(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String? ?? '',
      email: json['email'] as String?,
      name: json['user_metadata']?['full_name'] as String?,
      avatarUrl: json['user_metadata']?['avatar_url'] as String?,
    );
  }

  AppUser copyWith({
    String? id,
    String? email,
    String? name,
    String? avatarUrl,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
