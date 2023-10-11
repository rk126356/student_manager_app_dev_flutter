import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_manager_app_dev_flutter/models/user_model.dart';
import 'package:student_manager_app_dev_flutter/providers/user_provider.dart';
import 'package:student_manager_app_dev_flutter/screens/batches_page.dart';
import 'package:student_manager_app_dev_flutter/screens/home_page.dart';
import 'package:student_manager_app_dev_flutter/screens/login_screen.dart';
import 'package:student_manager_app_dev_flutter/screens/payments/search_payments_screen.dart';
import 'package:student_manager_app_dev_flutter/screens/payments_page.dart';
import 'package:student_manager_app_dev_flutter/screens/reports_page.dart';
import 'package:student_manager_app_dev_flutter/screens/search_screen.dart';
import 'package:student_manager_app_dev_flutter/screens/students/edit_student_screen.dart';
import 'package:student_manager_app_dev_flutter/screens/students/student_form_screen.dart';
import 'package:student_manager_app_dev_flutter/screens/students_page.dart';
import 'package:student_manager_app_dev_flutter/screens/upcoming_payments_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => UserProvider()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.data == null) {
              return const LoginScreen();
            } else {
              var user = FirebaseAuth.instance.currentUser!;
              Provider.of<UserProvider>(context, listen: false).setUserData(
                  UserModel(
                      uid: user.uid,
                      email: user.email,
                      name: user.displayName,
                      avatarUrl: user.photoURL));
              return HomeScreen(
                myString: FirebaseAuth.instance.currentUser!.displayName!,
              );
            }
          }

          return const HomeScreen();
        },
      ),
      routes: <String, WidgetBuilder>{
        '/home': (BuildContext context) => const HomeScreen(),
        '/login': (BuildContext context) => const LoginScreen(),
        '/batches': (BuildContext context) => const BatchesScreen(),
        '/students': (BuildContext context) => const StudentsScreen(),
        '/payments': (BuildContext context) => const PaymentsScreen(),
        '/upcoming-payments': (BuildContext context) =>
            const UpcomingPaymentsScreen(),
        '/new-student': (BuildContext context) => CreateStudentScreen(),
        '/search-student': (BuildContext context) => const SearchScreen(),
        '/search-payments': (BuildContext context) =>
            const SearchPaymentsScreen(),
        '/reports': (BuildContext context) => ReportsScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
