import 'package:flutter/material.dart';
import 'package:invoice/features/auth/domain/entities/login_result.dart';
import 'package:invoice/features/auth/presentation/screens/register_Screen.dart';
import 'package:invoice/features/auth/presentation/viewmodels/login_view_model.dart';
import 'package:invoice/features/admin/presentation/views/admin_home_screen.dart';
import 'package:invoice/features/user/presentation/widget/usermoduleProvider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    // Colors matching the original UI theme
    const Color primaryBlue = Color(0xFF3557E9);
    const Color bgGradientStart = Color(0xFF3B5DF2);
    const Color bgGradientEnd = Color(0xFF2E4DDE);
    const Color backgroundColor = Color(0xFFF9FAFC);
    const Color mutedText = Color(0xFF717D96);
    const Color borderLineColor = Color(0xFFE2E8F0);

    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final viewModel = Provider.of<LoginViewModel>(context);

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40),
                        // Header App Logo Section
                        Row(
                          children: [
                            Container(
                              height: 44,
                              width: 44,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: const LinearGradient(
                                  colors: [bgGradientStart, bgGradientEnd],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryBlue.withOpacity(0.2),
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
                        // Titles
                        const Text(
                          'Welcome back',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Sign in to continue to your dashboard.',
                          style: TextStyle(color: mutedText, fontSize: 14),
                        ),
                        const SizedBox(height: 32),
                        // White Credentials Card Card Container
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: borderLineColor),
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
                              // Username Field
                              _buildInputFieldLabel('USERNAME'),
                              TextField(
                                onChanged: viewModel.updateUsername,
                                decoration: const InputDecoration(
                                  hintText: 'username',
                                  hintStyle: TextStyle(
                                    color: Colors.black38,
                                    fontSize: 15,
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: borderLineColor,
                                    ),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: primaryBlue,
                                      width: 1.5,
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24), // Password Field
                              _buildInputFieldLabel('PASSWORD'),
                              TextField(
                                onChanged: viewModel.updatePassword,
                                obscureText: !viewModel.showPassword,
                                obscuringCharacter: '•',
                                style: const TextStyle(letterSpacing: 2),
                                decoration: InputDecoration(
                                  hintText: '••••••••',
                                  hintStyle: const TextStyle(
                                    color: Colors.black38,
                                    letterSpacing: 2,
                                  ),
                                  enabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: borderLineColor,
                                    ),
                                  ),
                                  focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: primaryBlue,
                                      width: 1.5,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      viewModel.showPassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: mutedText,
                                      size: 20,
                                    ),
                                    onPressed:
                                        viewModel.togglePasswordVisibility,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Checkbox & Forgot Password Action Row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: Checkbox(
                                          value: viewModel.rememberMe,
                                          activeColor: primaryBlue,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          side: const BorderSide(
                                            color: borderLineColor,
                                            width: 1.5,
                                          ),
                                          onChanged: viewModel.toggleRememberMe,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Remember me',
                                        style: TextStyle(
                                          color: mutedText,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                  TextButton(
                                    onPressed: () {},
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                    ),
                                    child: const Text(
                                      'Forgot password?',
                                      style: TextStyle(
                                        color: primaryBlue,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Primary CTA Submission Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(
                                colors: [bgGradientStart, bgGradientEnd],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryBlue.withOpacity(0.25),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Consumer<LoginViewModel>(
                              builder: (_, vm, __) {
                                return SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: vm.isLoading
                                        ? null
                                        : () async {
                                            final result = await vm.login();

                                            switch (result.status) {
                                              case LoginStatus.success:
                                                final prefs =
                                                    await SharedPreferences.getInstance();
                                                await prefs.setString(
                                                  'username',
                                                  result.username!,
                                                );
                                                await prefs.setBool(
                                                  'isLoggedIn',
                                                  true,
                                                );
                                                await prefs.setString(
                                                  'role',
                                                  result.role ?? 'user',
                                                );
                                                await prefs.setString(
                                                  'userId',
                                                  result.userId.toString(),
                                                );

                                                print("login is working");
                                                if (result.role
                                                        ?.toLowerCase() ==
                                                    'admin') {
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder:
                                                          (
                                                            BuildContext
                                                            context,
                                                          ) =>
                                                              AdminHomeScreen(),
                                                    ),
                                                  );
                                                } else {
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) =>
                                                          UserModuleProviders(
                                                            child: UserModuleRoot(
                                                              userId: result
                                                                  .userId!, // from your LoginResult
                                                              userName: result
                                                                  .username!,
                                                            ),
                                                          ),
                                                    ),
                                                  );

                                                  ;
                                                }
                                                break;

                                              case LoginStatus.pendingApproval:
                                              case LoginStatus
                                                  .invalidCredentials:
                                              case LoginStatus.error:
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      result.message,
                                                    ),
                                                  ),
                                                );
                                                break;
                                            }
                                          },
                                    child: vm.isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text('Login'),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        // Security Badge Info
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shield_outlined,
                              size: 14,
                              color: mutedText,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Bank-grade encryption',
                              style: TextStyle(color: mutedText, fontSize: 12),
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Bottom Navigation Redirection Label
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: 24.0,
                            top: 20.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'New here? ',
                                style: TextStyle(
                                  color: mutedText,
                                  fontSize: 14,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => RegisterView(),
                                    ),
                                  );
                                }, // Navigate to register page
                                child: const Text(
                                  'Create an account',
                                  style: TextStyle(
                                    color: primaryBlue,
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

  // Component Helper for input field uppercase sub-labels
  Widget _buildInputFieldLabel(String labelText) {
    return Text(
      labelText,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Color(0xFF717D96),
        letterSpacing: 1.1,
      ),
    );
  }
}
