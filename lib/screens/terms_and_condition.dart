import 'package:Bucoride_Driver/utils/app_constants.dart';
import 'package:Bucoride_Driver/widgets/app_bar/app_bar.dart';
import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  Widget buildSection(String heading, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heading,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: "Terms and Conditions",
        showNavBack: true,
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Bucoride Driver App Terms and Conditions",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Effective Date: April 5, 2025",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),

              buildSection("1. Use of Bucoride Driver App",
                  "1.1 Bucoride allows you to accept ride and delivery requests within commercial areas, including but not limited to Bureti.\n\n"
                      "1.2 You must be at least 18 years old and possess a valid driver’s license to use the App.\n\n"
                      "1.3 You are required to possess and maintain all necessary documents for operating your vehicle commercially:\n"
                      "- A valid Driver’s License\n"
                      "- Vehicle Insurance\n"
                      "- Public Liability Insurance (where required)\n"
                      "- Vehicle Roadworthiness Certificate\n\n"
                      "1.4 You agree to operate your vehicle safely and in compliance with local traffic laws.\n\n"
                      "1.5 The App should only be used to provide rides and deliveries as requested through the App."
              ),

              buildSection("2. Account Registration",
                  "2.1 You must create an account and upload required documents during registration.\n"
                      "2.2 You are responsible for all activity under your account and must keep your login credentials secure."
              ),

              buildSection("3. Service Fees and Earnings",
                  "3.1 Fares are estimates. You and the client must agree on final prices before starting.\n"
                      "3.2 Gamerich reserves the right to adjust fees at any time."
              ),

              buildSection("4. Ride and Delivery Requests",
                  "4.1 You agree to promptly arrive and complete accepted requests.\n"
                      "4.2 We do not guarantee a steady flow of requests."
              ),

              buildSection("5. User Conduct",
                  "5.1 Drive safely, follow traffic laws, and treat users with respect.\n"
                      "5.2 Do not misuse the app or engage in prohibited activities like hacking, fraud, or soliciting users outside the app."
              ),

              buildSection("6. Payments and Earnings",
                  "6.1 Payments are processed through the App. Gamerich will deposit your earnings into your designated account.\n"
                      "6.2 Payments are non-refundable unless otherwise specified."
              ),

              buildSection("7. Privacy Policy",
                  "By using the App, you agree to our Privacy Policy which details how we collect, use, and protect your data."
              ),

              buildSection("8. Disclaimers and Limitation of Liability",
                  "8.1 Gamerich does not guarantee the availability or accuracy of services.\n"
                      "8.2 Gamerich is not liable for any damages arising from App use."
              ),

              buildSection("9. Termination",
                  "9.1 Gamerich may suspend or terminate your account for violations or missing documents.\n"
                      "9.2 You may terminate your account anytime through the App."
              ),

              buildSection("10. Changes to Terms",
                  "10.1 Gamerich can modify these Terms at any time. Continued use means acceptance of changes."
              ),

              buildSection("11. Governing Law",
                  "These Terms are governed by the laws of Kenya."
              ),

              buildSection("12. Contact Information",
                  "Email: gamerichladder@gmail.com\nPhone: +254 703 330 627"
              ),

              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.lightPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Agree & Continue",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
