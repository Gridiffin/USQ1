// providers/authprovider.dart
import 'package:flutter/material.dart';
import '../models/usermodels.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;

  // Mock login method
  Future<void> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(Duration(seconds: 2));
    _user = UserModel(id: '1', name: 'John Doe', email: email);
    notifyListeners();
  }

  // Mock logout method
  void logout() {
    _user = null;
    notifyListeners();
  }
}
