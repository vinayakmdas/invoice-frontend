enum LoginStatus { success, pendingApproval, invalidCredentials, error }

class LoginResult {
  final LoginStatus status;
  final String message;
  final String? role;
  final String? username;
  final int? userId;
  LoginResult({
    required this.status,
    required this.message,
    this.role,
    this.username,
    this.userId,
  });
}
