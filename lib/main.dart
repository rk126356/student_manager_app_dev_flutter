import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_manager_app_dev_flutter/models/user_model.dart';
import 'package:student_manager_app_dev_flutter/providers/user_provider.dart';
import 'package:student_manager_app_dev_flutter/screens/batches_page.dart';
import 'package:student_manager_app_dev_flutter/screens/data_exports.dart';
import 'package:student_manager_app_dev_flutter/screens/home_page.dart';
import 'package:student_manager_app_dev_flutter/screens/login_screen.dart';
import 'package:student_manager_app_dev_flutter/screens/payments/search_payments_screen.dart';
import 'package:student_manager_app_dev_flutter/screens/payments_page.dart';
import 'package:student_manager_app_dev_flutter/screens/premium_screen.dart';
import 'package:student_manager_app_dev_flutter/screens/reports_page.dart';
import 'package:student_manager_app_dev_flutter/screens/search_screen.dart';
import 'package:student_manager_app_dev_flutter/screens/settings.dart';
import 'package:student_manager_app_dev_flutter/screens/students/student_form_screen.dart';
import 'package:student_manager_app_dev_flutter/screens/students_page.dart';
import 'package:student_manager_app_dev_flutter/screens/upcoming_payments_page.dart';
import 'package:student_manager_app_dev_flutter/screens/web/web_login.dart';

const bool kIsWeb = bool.fromEnvironment('dart.library.js_util');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Check if the app is running on the web
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyAwq9bw-uOlzTFg5gPhVdxuK9Gue9Trg-Q",
            authDomain: "student-manager-ac339.firebaseapp.com",
            projectId: "student-manager-ac339",
            storageBucket: "student-manager-ac339.appspot.com",
            messagingSenderId: "964688247482",
            appId: "1:964688247482:web:cef6be22fcce559a59a083",
            measurementId: "G-XNK2EPVP73"));
  } else {
    // Initialize Firebase for mobile
    await Firebase.initializeApp();
  }
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => UserProvider()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudentManager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.data == null) {
              if (kIsWeb) {
                return const SignInDemo();
              } else {
                return const LoginScreen();
              }
            } else {
              var user = FirebaseAuth.instance.currentUser!;
              Provider.of<UserProvider>(context, listen: false).setUserData(
                  UserModel(
                      uid: user.uid,
                      email: user.email,
                      name: user.displayName,
                      avatarUrl: user.photoURL));
              return const HomeScreen();
            }
          }

          if (kIsWeb) {
            return const SignInDemo();
          } else {
            return const LoginScreen();
          }
        },
      ),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/home':
            return MaterialPageRoute(builder: (context) => const HomeScreen());
          case '/login-web':
            return MaterialPageRoute(builder: (context) => const SignInDemo());
          case '/login':
            return MaterialPageRoute(builder: (context) => const LoginScreen());
          case '/batches':
            return MaterialPageRoute(
                builder: (context) => const BatchesScreen());
          case '/students':
            return MaterialPageRoute(
                builder: (context) => const StudentsScreen());
          case '/payments':
            return MaterialPageRoute(
                builder: (context) => const PaymentsScreen());
          case '/upcoming-payments':
            return MaterialPageRoute(
                builder: (context) => const UpcomingPaymentsScreen());
          case '/new-student':
            return MaterialPageRoute(
                builder: (context) => CreateStudentScreen());
          case '/search-student':
            return MaterialPageRoute(
                builder: (context) => const SearchScreen());
          case '/search-payments':
            return MaterialPageRoute(
                builder: (context) => const SearchPaymentsScreen());
          case '/reports':
            return MaterialPageRoute(builder: (context) => ReportsScreen());
          case '/settings':
            return MaterialPageRoute(builder: (context) => SettingsScreen());
          case '/premium':
            return MaterialPageRoute(
                builder: (context) => const PremiumScreen());
          case '/exports':
            return MaterialPageRoute(builder: (context) => DataExportsScreen());
          default:
            return null;
        }
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
