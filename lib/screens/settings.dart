import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_manager_app_dev_flutter/providers/user_provider.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var currency = Provider.of<UserProvider>(context);

    var user = Provider.of<UserProvider>(context, listen: false).userData;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        backgroundColor:
            Colors.deepPurple, // Change the app bar color to your preference
      ),
      body: Container(
        color: Colors
            .grey.shade200, // Change the background color to your preference
        child: ListView(
          children: <Widget>[
            const SizedBox(
              height: 5,
            ),
            _buildSettingItem(
              leadingIcon: Icons.description,
              title: 'Privacy Policy',
              subtitle: 'Read our privacy policy',
            ),
            _buildSettingItem(
              leadingIcon: Icons.security,
              title: 'Terms and Conditions',
              subtitle: 'Read our terms and conditions',
            ),
            _buildSettingItem(
              leadingIcon: Icons.info,
              title: 'About',
              subtitle: 'Learn more about the app',
            ),
            Card(
              margin: const EdgeInsets.all(8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: ListTile(
                leading: const Icon(
                  Icons.change_circle,
                  color: Colors.deepPurple,
                ),
                title: Text(
                  'Currency: ${currency.currency}${currency.currencyName}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Change your Currency'),
                trailing: const Icon(Icons.keyboard_arrow_right,
                    color: Colors.deepPurple),
                onTap: () {
                  showCurrencyPicker(
                      context: context,
                      theme: CurrencyPickerThemeData(
                        flagSize: 25,
                        titleTextStyle: const TextStyle(fontSize: 17),
                        subtitleTextStyle: TextStyle(
                            fontSize: 15, color: Theme.of(context).hintColor),
                        bottomSheetHeight:
                            MediaQuery.of(context).size.height / 2,
                      ),
                      onSelect: (Currency data) async {
                        currency.setCurrency(data.symbol);
                        currency.setCurrencyName(data.code);

                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .update({
                          'currency': data.symbol,
                          'currencyName': data.code
                        });
                      });
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData leadingIcon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: ListTile(
        leading: Icon(
          leadingIcon,
          color: Colors.deepPurple,
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing:
            const Icon(Icons.keyboard_arrow_right, color: Colors.deepPurple),
        onTap: () {
          // Handle the tap on the setting
        },
      ),
    );
  }
}
