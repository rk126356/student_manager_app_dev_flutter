import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_onboarding_slider/flutter_onboarding_slider.dart';
import 'package:provider/provider.dart';
import 'package:student_manager_app_dev_flutter/providers/user_provider.dart';

class OnBoarding extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var currency = Provider.of<UserProvider>(context);

    return CupertinoApp(
      home: OnBoardingSlider(
        onFinish: () {
          currency.setFirstLaunch(false);
          Navigator.pushNamed(context, '/login');
        },
        centerBackground: true,
        headerBackgroundColor: Colors.deepPurple,
        finishButtonText: 'Continue',
        finishButtonStyle: const FinishButtonStyle(
          backgroundColor: Colors.black,
        ),
        skipTextButton: const Text(
          'Skip',
          style: TextStyle(color: Colors.white),
        ),
        trailing: const Text('Login'),
        background: [
          Image.asset(
            'assets/images/welcome.png',
          ),
          Image.asset(
            'assets/images/currency.png',
          ),
        ],
        totalPage: 2,
        speed: 1.8,
        pageBodies: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: const Column(
              children: <Widget>[
                SizedBox(
                  height: 420,
                ),
                Text(
                  "Welcome to StudentManager",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "With this app you will be able to manage your students and payments automatically.",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: <Widget>[
                const SizedBox(
                  height: 420,
                ),
                const Text(
                  "Select Your Currency",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Text(
                  "Currency: ${currency.currency}${currency.currencyName}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
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
                              fontSize: 15, color: Theme.of(context).hintColor),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
