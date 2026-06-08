enum RegisterStatus { success, usernameTaken, emailTaken, phoneTaken, error }

class RegisterResult {
  final RegisterStatus status;
  final String message;

  const RegisterResult({required this.status, required this.message});
}
