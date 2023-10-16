import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_manager_app_dev_flutter/models/user_model.dart';

class UserProvider extends ChangeNotifier {
  var _userData = UserModel();
  int _noOfStudents = 0;
  int _noOfUpcomingPayments = 0;
  String _currency = '₹';
  String _currencyName = 'INR';
  bool _isFirstLaunch = true;
  bool _isNewOpen = true;
  bool _fetchNoOfStudents = true;

  UserModel get userData => _userData;
  int get noOfUPayments => _noOfStudents;
  int get noOfUpcomingPayments => _noOfUpcomingPayments;
  String get currency => _currency;
  String get currencyName => _currencyName;
  bool get isFirstLaunch => _isFirstLaunch;
  bool get isNewOpen => _isNewOpen;
  bool get fetchNoOfStudents => _fetchNoOfStudents;

  UserProvider() {
    _initializeDataFromPrefs();
  }

  setIsNewOpen(bool value) {
    _isNewOpen = value;
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

  setNoOfStudents(int value) async {
    _noOfStudents = value;
    _fetchNoOfStudents = false;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('noOfStudents', value);
    await prefs.setBool('fetchNoOfStudents', false);
  }

  setNoOfUpcomingPayments(int value) {
    _noOfUpcomingPayments = value;
  }

  setUserData(UserModel user) {
    _userData = user;
  }

  Future<void> _initializeDataFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? currency = prefs.getString('currency');
    String? currencyName = prefs.getString('currencyName');
    bool? isFirstLaunch = prefs.getBool('firstLaunch');
    int? noOfStudents = prefs.getInt('noOfStudents');
    bool? fetchNoOfStudents = prefs.getBool('fetchNoOfStudents');

    if (currency != null) {
      _currency = currency;
    }

    if (currencyName != null) {
      _currencyName = currencyName;
    }

    if (isFirstLaunch != null) {
      _isFirstLaunch = isFirstLaunch;
    }

    if (noOfStudents != null) {
      _noOfStudents = noOfStudents;
    }

    if (fetchNoOfStudents != null) {
      _fetchNoOfStudents = fetchNoOfStudents;
    }

    notifyListeners();
  }
}
