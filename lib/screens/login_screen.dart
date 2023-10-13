import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:student_manager_app_dev_flutter/models/user_model.dart';
import 'package:student_manager_app_dev_flutter/providers/user_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

late final User _user;

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    Future<void> signInWithGoogle() async {
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

        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'displayName': user.displayName,
            'email': user.email,
            'uid': user.uid,
            'avatarUrl': user.photoURL
          });

          print('User data stored in Firestore');

          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        }
      } catch (error) {
        print('Error signing in with Google: $error');
      }
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [Colors.deepPurple, Colors.purple],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/google-logo.png', // Add your app logo asset
                height: 150, // Adjust the size as needed
                width: 150,
              ),
              const SizedBox(height: 20),
              const Text(
                "Welcome to Student Manager",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Organize your students and payments easily.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  signInWithGoogle();
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/google-logo.png', // Add your Google logo asset
                      height: 24,
                      width: 24,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "Sign in with Google",
                      style: TextStyle(
                        fontSize: 18,
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
