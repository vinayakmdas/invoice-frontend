import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:invoice/features/auth/presentation/provider/register_model_provider.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/register_result.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  // ── Design tokens (identical to LoginView) ──────────────────────────────
  static const Color _primaryBlue = Color(0xFF3557E9);
  static const Color _bgGradientStart = Color(0xFF3B5DF2);
  static const Color _bgGradientEnd = Color(0xFF2E4DDE);
  static const Color _backgroundColor = Color(0xFFF9FAFC);
  static const Color _mutedText = Color(0xFF717D96);
  static const Color _borderLineColor = Color(0xFFE2E8F0);
  static const Color _errorColor = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterViewModel(),
      child: Scaffold(
        backgroundColor: _backgroundColor,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40),

                        // ── App Logo ───────────────────────────────────────
                        Row(
                          children: [
                            Container(
                              height: 44,
                              width: 44,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: const LinearGradient(
                                  colors: [_bgGradientStart, _bgGradientEnd],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _primaryBlue.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.description_outlined,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Invoice Manager',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),

                        // ── Heading ────────────────────────────────────────
                        const Text(
                          'Create account',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Fill in the details below to request access.',
                          style: TextStyle(color: _mutedText, fontSize: 14),
                        ),

                        const SizedBox(height: 32),

                        // ── Credentials Card ───────────────────────────────
                        Consumer<RegisterViewModel>(
                          builder: (_, vm, __) => Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: _borderLineColor),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Full Name
                                _buildLabel('FULL NAME'),
                                _buildTextField(
                                  hint: 'John Doe',
                                  onChanged: vm.updateName,
                                  errorText: vm.nameError,
                                  textCapitalization: TextCapitalization.words,
                                ),
                                const SizedBox(height: 22),

                                // Username
                                _buildLabel('USERNAME'),
                                _buildTextField(
                                  hint: 'johndoe',
                                  onChanged: vm.updateUsername,
                                  errorText: vm.usernameError,
                                ),
                                const SizedBox(height: 22),

                                // Email
                                _buildLabel('EMAIL'),
                                _buildTextField(
                                  hint: 'john@example.com',
                                  onChanged: vm.updateEmail,
                                  errorText: vm.emailError,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 22),

                                // Phone
                                _buildLabel('PHONE'),
                                _buildTextField(
                                  hint: '9876543210',
                                  onChanged: vm.updatePhone,
                                  errorText: vm.phoneError,
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(10),
                                  ],
                                ),
                                const SizedBox(height: 22),

                                // Password
                                _buildLabel('PASSWORD'),
                                _buildPasswordField(
                                  hint: '••••••••',
                                  onChanged: vm.updatePassword,
                                  obscureText: !vm.showPassword,
                                  onToggle: vm.togglePasswordVisibility,
                                  showingPassword: vm.showPassword,
                                  errorText: vm.passwordError,
                                ),
                                const SizedBox(height: 22),

                                // Confirm Password
                                _buildLabel('CONFIRM PASSWORD'),
                                _buildPasswordField(
                                  hint: '••••••••',
                                  onChanged: vm.updateConfirmPassword,
                                  obscureText: !vm.showConfirmPassword,
                                  onToggle: vm.toggleConfirmPasswordVisibility,
                                  showingPassword: vm.showConfirmPassword,
                                  errorText: vm.confirmPasswordError,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ── Approval Notice ────────────────────────────────
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: _primaryBlue.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _primaryBlue.withOpacity(0.15),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                size: 16,
                                color: _primaryBlue,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Your account will be reviewed by an admin before you can sign in.',
                                  style: TextStyle(
                                    color: _primaryBlue,
                                    fontSize: 12,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ── Submit Button ──────────────────────────────────
                        Consumer<RegisterViewModel>(
                          builder: (_, vm, __) => SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: const LinearGradient(
                                  colors: [_bgGradientStart, _bgGradientEnd],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _primaryBlue.withOpacity(0.25),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: vm.isLoading
                                    ? null
                                    : () async {
                                        final result = await vm.register();

                                        if (result.status ==
                                            RegisterStatus.success) {
                                          // Show success dialog then pop back to login
                                          if (context.mounted) {
                                            await showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (_) => AlertDialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                contentPadding:
                                                    const EdgeInsets.all(28),
                                                content: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      height: 56,
                                                      width: 56,
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                          0xFF22C55E,
                                                        ).withOpacity(0.1),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: const Icon(
                                                        Icons
                                                            .check_circle_outline_rounded,
                                                        color: Color(
                                                          0xFF22C55E,
                                                        ),
                                                        size: 30,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 16),
                                                    const Text(
                                                      'Request Submitted',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    const Text(
                                                      'Your account has been created and is pending admin approval. You\'ll be able to sign in once approved.',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: _mutedText,
                                                        fontSize: 13,
                                                        height: 1.5,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 24),
                                                    SizedBox(
                                                      width: double.infinity,
                                                      child: ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              _primaryBlue,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  12,
                                                                ),
                                                          ),
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                vertical: 14,
                                                              ),
                                                        ),
                                                        onPressed: () =>
                                                            Navigator.of(
                                                              context,
                                                            ).pop(),
                                                        child: const Text(
                                                          'Back to Login',
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                            if (context.mounted) {
                                              Navigator.of(context).pop();
                                            }
                                          }
                                        } else if (result.status ==
                                                RegisterStatus.error &&
                                            vm.nameError == null &&
                                            vm.usernameError == null &&
                                            vm.emailError == null &&
                                            vm.phoneError == null &&
                                            vm.passwordError == null &&
                                            vm.confirmPasswordError == null) {
                                          // Generic network/server error only
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(result.message),
                                              ),
                                            );
                                          }
                                        }
                                        // Uniqueness / validation errors are
                                        // shown inline via vm.*Error fields.
                                      },
                                child: vm.isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'Create Account',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // ── Security Badge ─────────────────────────────────
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shield_outlined,
                              size: 14,
                              color: _mutedText,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Bank-grade encryption',
                              style: TextStyle(color: _mutedText, fontSize: 12),
                            ),
                          ],
                        ),

                        const Spacer(),

                        // ── Back to Login ──────────────────────────────────
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: 24.0,
                            top: 20.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Already have an account? ',
                                style: TextStyle(
                                  color: _mutedText,
                                  fontSize: 14,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                child: const Text(
                                  'Sign in',
                                  style: TextStyle(
                                    color: _primaryBlue,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ── Shared widget helpers ──────────────────────────────────────────────────

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: _mutedText,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required ValueChanged<String> onChanged,
    String? errorText,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      onChanged: onChanged,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black38, fontSize: 15),
        errorText: errorText,
        errorStyle: const TextStyle(color: _errorColor, fontSize: 11),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: _borderLineColor),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: _primaryBlue, width: 1.5),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: _errorColor),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: _errorColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
      ),
    );
  }

  Widget _buildPasswordField({
    required String hint,
    required ValueChanged<String> onChanged,
    required bool obscureText,
    required VoidCallback onToggle,
    required bool showingPassword,
    String? errorText,
  }) {
    return TextField(
      onChanged: onChanged,
      obscureText: obscureText,
      obscuringCharacter: '•',
      style: const TextStyle(letterSpacing: 2),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black38, letterSpacing: 2),
        errorText: errorText,
        errorStyle: const TextStyle(color: _errorColor, fontSize: 11),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: _borderLineColor),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: _primaryBlue, width: 1.5),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: _errorColor),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: _errorColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
        suffixIcon: IconButton(
          icon: Icon(
            showingPassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: _mutedText,
            size: 20,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }
}
