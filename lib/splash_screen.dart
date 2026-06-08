import 'dart:async';

import 'package:flutter/material.dart';
import 'package:invoice/features/auth/presentation/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:invoice/features/admin/presentation/views/admin_home_screen.dart';
import 'package:invoice/features/user/presentation/widget/usermoduleProvider.dart';

class SplashScreen extends StatefulWidget {
  final SharedPreferences prefs;
  const SplashScreen({super.key, required this.prefs});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 2));

    final prefs = widget.prefs; //

    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final String role = prefs.getString('role') ?? 'user';
    final String username = prefs.getString('username') ?? '';

    if (!mounted) return;

    if (!isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginView()),
      );
      return;
    }

    if (role.toLowerCase() == 'admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AdminHomeScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => UserModuleProviders(
            child: UserModuleRoot(
              userId: int.parse(prefs.getString("userId") ?? "0"),
              userName: username,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Image.asset('asset/splashimage.png', fit: BoxFit.cover),
      ),
    );
  }
}
