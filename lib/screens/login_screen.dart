import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:student_manager_app_dev_flutter/models/user_model.dart';
import 'package:student_manager_app_dev_flutter/providers/user_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

late final User _user;

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    Future<void> signInWithGoogle() async {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      try {
        // Sign in to Firebase Auth
        UserCredential authResult =
            await FirebaseAuth.instance.signInWithCredential(credential);

        // Access the user's data
        final User? user = authResult.user;

        _user = user!;

        Provider.of<UserProvider>(context, listen: false).setUserData(UserModel(
            uid: _user.uid,
            email: _user.email,
            name: _user.displayName,
            avatarUrl: _user.photoURL));

        // Store user data in Firestore
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'displayName': user.displayName,
            'email': user.email,
            'uid': user.uid
            // Add more user data fields as needed
          });

          print('User data stored in Firestore');
        }
      } catch (error) {
        print('Error signing in with Google: $error');
      }
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text("Login"),
        ),
        body: Column(
          children: [
            Text("Login Screen"),
            ElevatedButton(
                onPressed: () {
                  signInWithGoogle();
                },
                child: Text("Login"))
          ],
        ));
  }
}
