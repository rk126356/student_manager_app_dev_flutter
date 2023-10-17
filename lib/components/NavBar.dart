import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_manager_app_dev_flutter/providers/user_provider.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserProvider>(context, listen: false).userData;
    var data = Provider.of<UserProvider>(context, listen: false);

    return Drawer(
      child: ListView(
        // Remove padding
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user.name!),
            accountEmail: Text(user.email!),
            currentAccountPicture: CachedNetworkImage(
              height: 90,
              width: 90,
              imageUrl: user.avatarUrl!,
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle, // Makes it a circle (Avatar-like)
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover, // You can use other BoxFit values
                  ),
                ),
              ),
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
            decoration: const BoxDecoration(
              color: Colors.blue,
              image: DecorationImage(
                  fit: BoxFit.fill,
                  image: AssetImage('assets/images/profile-bg3.jpg')),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/home', (route) => false);
            },
          ),
          ListTile(
            leading: const Icon(Icons.school),
            title: const Text('Batches'),
            onTap: () => Navigator.pushNamed(context, '/batches'),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Students'),
            onTap: () => Navigator.pushNamed(context, '/students'),
            trailing: ClipOval(
              child: Container(
                color: Colors.red,
                width: data.noOfUPayments >= 1000
                    ? 40
                    : data.noOfUPayments >= 100
                        ? 30
                        : 20,
                height: data.noOfUPayments >= 1000
                    ? 40
                    : data.noOfUPayments >= 100
                        ? 30
                        : 20,
                child: Center(
                  child: Text(
                    data.noOfUPayments.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.payments),
            title: const Text('Payments'),
            onTap: () => Navigator.pushNamed(context, '/payments'),
          ),
          ListTile(
            leading: const Icon(Icons.av_timer),
            title: const Text('Upcoming Payments'),
            onTap: () => Navigator.pushNamed(context, '/upcoming-payments'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('Reports'),
            onTap: () => Navigator.pushNamed(context, '/reports'),
          ),
          // ListTile(
          //   leading: const Icon(Icons.file_upload),
          //   title: const Text('Export CSV'),
          //   onTap: () => Navigator.pushNamed(context, '/exports'),
          // ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () => Navigator.pushNamed(context, '/settings'),
          ),
          const Divider(),
          // ListTile(
          //   leading: const Icon(Icons.diamond),
          //   title: const Text('Premium'),
          //   onTap: () => Navigator.pushNamed(context, '/premium'),
          // ),
          ListTile(
            title: const Text('Logout'),
            leading: const Icon(Icons.logout),
            onTap: () async {
              await GoogleSignIn().signOut();
              FirebaseAuth.instance.signOut();
              SharedPreferences preferences =
                  await SharedPreferences.getInstance();
              await preferences.clear();
              Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (route) => false);
            },
          ),
        ],
      ),
    );
  }
}
