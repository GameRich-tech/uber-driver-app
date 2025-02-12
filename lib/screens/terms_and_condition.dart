import 'package:Bucoride_Driver/utils/app_constants.dart';
import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Terms and Conditions",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppConstants.fontFamily,
            fontSize: AppConstants.defaultTextSize,
            fontWeight: AppConstants.defaultWeight,
          ),
        ),
        backgroundColor: AppConstants.lightPrimary,
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome to Buco Driver!",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.darkPrimary,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "These Terms and Conditions govern your use of the Buco Driver app. By using our app, you agree to comply with these terms.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              Text(
                "1. Acceptance of Terms",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.darkPrimary,
                ),
              ),
              const Text(
                "By accessing and using this app, you accept and agree to be bound by these Terms and Conditions.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 15),
              Text(
                "2. User Responsibilities",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.darkPrimary,
                ),
              ),
              const Text(
                "You are responsible for maintaining the confidentiality of your account and for all activities that occur under your account.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 15),
              Text(
                "3. Prohibited Activities",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.darkPrimary,
                ),
              ),
              const Text(
                "You agree not to engage in any unlawful activities, including but not limited to fraud, harassment, or misuse of the app.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 15),
              Text(
                "4. Limitation of Liability",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.darkPrimary,
                ),
              ),
              const Text(
                "Buco Driver is not liable for any damages resulting from the use of this app, including direct, indirect, or consequential losses.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 15),
              Text(
                "5. Changes to Terms",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.darkPrimary,
                ),
              ),
              const Text(
                "We reserve the right to modify these terms at any time. Continued use of the app constitutes acceptance of the revised terms.",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),

              /*Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.lightPrimary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Agree & Continue",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),*/
            ],
          ),
        ),
      ),
    );
  }
}
