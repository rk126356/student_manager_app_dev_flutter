import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_manager_app_dev_flutter/models/user_model.dart';

class UserProvider extends ChangeNotifier {
  var _userData = UserModel();
  int _noOfPayments = 0;
  int _noOfUpcomingPayments = 0;
  String _currency = '₹';
  String _currencyName = 'INR';
  bool _isFirstLaunch = true;

  UserModel get userData => _userData;
  int get noOfUPayments => _noOfPayments;
  int get noOfUpcomingPayments => _noOfUpcomingPayments;
  String get currency => _currency;
  String get currencyName => _currencyName;
  bool get isFirstLaunch => _isFirstLaunch;

  UserProvider() {
    print("Provider initialized");
    _initializeDataFromPrefs();
  }

  setFirstLaunch(bool data) async {
    _isFirstLaunch = data;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('firstLaunch', data);
  }

  setCurrencyName(String name) async {
    _currencyName = name;
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('currencyName', name);
  }

  setCurrency(String value) async {
    _currency = value;
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', value);
  }

  Future<void> _initializeDataFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? currency = prefs.getString('currency');
    String? currencyName = prefs.getString('currencyName');
    bool? isFirstLaunch = prefs.getBool('firstLaunch');

    print("Saved isFirstLaunch $isFirstLaunch");

    if (currency != null) {
      _currency = currency;
    }

    if (currencyName != null) {
      _currencyName = currencyName;
    }

    if (isFirstLaunch != null) {
      _isFirstLaunch = isFirstLaunch;
    }

    notifyListeners();
  }

  setNoOfPayments(int value) {
    _noOfPayments = value;
  }

  setNoOfUpcomingPayments(int value) {
    _noOfUpcomingPayments = value;
  }

  setUserData(UserModel user) {
    _userData = user;
  }

  updateUserCurrency(String data) {
    _userData.currency = data;
    notifyListeners();
  }
}
