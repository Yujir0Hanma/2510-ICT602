class AuthUser {
  final String uid;
  final String email;
  final String role;
  final String? studentId;
  final String? name;

  AuthUser({
    required this.uid,
    required this.email,
    required this.role,
    this.studentId,
    this.name,
  });
}
