import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_manager_app_dev_flutter/models/user_model.dart';

class UserProvider extends ChangeNotifier {
  var _userData = UserModel();

  UserModel get userData => _userData;

  setUserData(UserModel user) {
    _userData = user;
  }

  updateUserData(UserModel user) {
    _userData = user;
    notifyListeners();
  }
}
