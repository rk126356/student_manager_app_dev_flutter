import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_manager_app_dev_flutter/models/user_model.dart';
import 'package:student_manager_app_dev_flutter/providers/user_provider.dart';
import 'package:student_manager_app_dev_flutter/screens/onBoardingScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

late final User _user;

class _LoginScreenState extends State<LoginScreen> {
  void checkIsFristLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isFirstLaunch = prefs.getBool('firstLaunch');
    if (isFirstLaunch == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OnBoarding(),
        ),
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    checkIsFristLaunch();
    super.initState();
  }

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    Future<void> signInWithGoogle() async {
      setState(() {
        isLoading = true;
      });
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      try {
        UserCredential authResult =
            await FirebaseAuth.instance.signInWithCredential(credential);
        final User? user = authResult.user;
        _user = user!;

        Provider.of<UserProvider>(context, listen: false).setUserData(UserModel(
            uid: _user.uid,
            email: _user.email,
            name: _user.displayName,
            avatarUrl: _user.photoURL));

        // Check if the user data already exists in Firestore
        final userDoc =
            FirebaseFirestore.instance.collection('users').doc(user.uid);
        final userDocSnapshot = await userDoc.get();

        if (userDocSnapshot.exists) {
          // If the document exists, update its data
          await userDoc.update({
            'displayName': user.displayName,
            'email': user.email,
            'uid': user.uid,
            'avatarUrl': user.photoURL,
            'currency':
                Provider.of<UserProvider>(context, listen: false).currency,
            'currencyName':
                Provider.of<UserProvider>(context, listen: false).currencyName
          });
        } else {
          // If the document doesn't exist, create it
          await userDoc.set({
            'displayName': user.displayName,
            'email': user.email,
            'uid': user.uid,
            'avatarUrl': user.photoURL,
            'isPremium': false,
            'currency':
                Provider.of<UserProvider>(context, listen: false).currency,
            'currencyName':
                Provider.of<UserProvider>(context, listen: false).currencyName
          });
        }

        print('User data stored in Firestore');

        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);

        setState(() {
          isLoading = false;
        });
      } catch (error) {
        print('Error signing in with Google: $error');
        setState(() {
          isLoading = false;
        });
      }
    }

    var currency = Provider.of<UserProvider>(context);

    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  colors: [Colors.deepPurple, Colors.purple],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/student_manager_logo.png',
                      height: 250,
                      width: 250,
                    ),
                    // const SizedBox(height: 20),
                    // const Text(
                    //   "Student Manager",
                    //   textAlign: TextAlign.center,
                    //   style: TextStyle(
                    //     fontSize: 32,
                    //     fontWeight: FontWeight.bold,
                    //     color: Colors.white,
                    //   ),
                    // ),
                    const SizedBox(height: 30),
                    Text(
                      "Currency: ${currency.currency}${currency.currencyName}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.green.shade700,
                        ),
                      ),
                      onPressed: () {
                        showCurrencyPicker(
                            context: context,
                            theme: CurrencyPickerThemeData(
                              flagSize: 25,
                              titleTextStyle: const TextStyle(fontSize: 17),
                              subtitleTextStyle: TextStyle(
                                  fontSize: 15,
                                  color: Theme.of(context).hintColor),
                              bottomSheetHeight:
                                  MediaQuery.of(context).size.height / 2,
                            ),
                            onSelect: (Currency data) {
                              currency.setCurrency(data.symbol);
                              currency.setCurrencyName(data.code);
                            });
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.change_circle),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            "Change Currency",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 50),
                    ElevatedButton(
                      onPressed: () {
                        signInWithGoogle();
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/google-logo.png',
                            height: 30,
                            width: 30,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Sign in with Google",
                            style: TextStyle(
                              fontSize: 22,
                              color: Colors.black,
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
  }
}
