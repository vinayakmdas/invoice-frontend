import 'package:flutter/material.dart';

/// Holds the currently logged-in user's basic info.
/// Populate this after a successful login from your existing auth flow.
class UserSessionProvider extends ChangeNotifier {
  int _userId = 0;
  String _userName = '';

  int get userId => _userId;
  String get userName => _userName;

  void setUser({required int id, required String name}) {
    _userId = id;
    _userName = name;
    notifyListeners();
  }

  void clear() {
    _userId = 0;
    _userName = '';
    notifyListeners();
  }
}
