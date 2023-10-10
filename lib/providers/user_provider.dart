import 'package:flutter/material.dart';
import 'package:student_manager_app_dev_flutter/models/user_model.dart';

class UserProvider extends ChangeNotifier {
  var _userData = UserModel();
  int _noOfPayments = 0;
  int _noOfUpcomingPayments = 0;

  UserModel get userData => _userData;
  int get noOfUPayments => _noOfPayments;
  int get noOfUpcomingPayments => _noOfUpcomingPayments;

  setNoOfPayments(int value) {
    _noOfPayments = value;
  }

  setNoOfUpcomingPayments(int value) {
    _noOfUpcomingPayments = value;
  }

  setUserData(UserModel user) {
    _userData = user;
  }

  updateUserData(UserModel user) {
    _userData = user;
    notifyListeners();
  }
}
