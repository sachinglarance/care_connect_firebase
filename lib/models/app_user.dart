enum UserRole {
  caregiver('Caregiver'),
  family('Family member');

  const UserRole(this.label);
  final String label;
}

class AppUser {
  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) => AppUser(
    uid: uid,
    name: map['name'] as String? ?? '',
    email: map['email'] as String? ?? '',
    role: UserRole.values.asNameMap()[map['role']] ?? UserRole.family,
  );

  final String uid;
  final String name;
  final String email;
  final UserRole role;

  bool get isCaregiver => role == UserRole.caregiver;

  Map<String, dynamic> toMap() => {
    'name': name,
    'email': email.toLowerCase(),
    'role': role.name,
  };
}
