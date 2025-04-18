import 'dart:convert';

import 'package:Bucoride_Driver/helpers/screen_navigation.dart';
import 'package:Bucoride_Driver/models/credentials.dart';
import 'package:Bucoride_Driver/screens/home.dart';
import 'package:Bucoride_Driver/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../helpers/constants.dart';
import '../../providers/app_provider.dart';
import '../../providers/user.dart';
import '../../utils/app_constants.dart';
import '../../utils/dimensions.dart';
import '../../utils/images.dart';
import '../../widgets/app_bar/app_bar.dart';
import '../../widgets/loading_location.dart';

class Paywall extends StatefulWidget {
  final bool isRenewal;

  const Paywall({super.key, required this.isRenewal});
  @override
  State<Paywall> createState() => _PaywallState();
}

class _PaywallState extends State<Paywall> {
  bool isLoading = false;
  late double amountToPay = 0;
  @override
  void initState() {
    super.initState();
    UserProvider _user = Provider.of<UserProvider>(context, listen: false);

    _user.mpesaNumberController.text = _user.userModel!.phone;
    EvaluatePrice(_user.vehicleTypeController);
  }

  EvaluatePrice(TextEditingController controller) {
    UserProvider _user = Provider.of<UserProvider>(context, listen: false);
    if (widget.isRenewal) {
      if (_user.userModel?.vehicleType == "Motorbike") {
        amountToPay = 249;
      } else {
        amountToPay = 549;
      }
    } else {
      if (controller.text == "Motorbike") {
        amountToPay = 249; //249
      } else {
        amountToPay = 549; //549
      }
    }
  }

  Future<void> initiateMpesaPayment(AppStateProvider appState) async {
    setState(() => isLoading = true);
    UserProvider _user = Provider.of<UserProvider>(context, listen: false);

    try {
      // Step 1: Get Access Token
      String accessToken = await getMpesaAccessToken();

      // Step 2: Make STK Push Payment Request
      String? phoneNumber = _user.userModel?.phone;
      String result = await sendStkPush(phoneNumber!, amountToPay, accessToken);

      appState.paymentRequest(context, _user.userModel!.id);
      // Show waiting message
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentInProgressScreen(
            isSuccess: false,
            message: "A payment request was sent. Waiting for confirmation...",
          ),
        ),
      );
    } catch (e) {
      // Navigate to Failure Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentResultScreen(
            isSuccess: false,
            message: "Payment failed, Try again.",
          ),
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<String> getMpesaAccessToken() async {
    UserProvider _user = Provider.of<UserProvider>(context, listen: false);
    Credentials? credentials = await _user.getCredentials();

    String? consumerKey = credentials?.consumerKey;
    String? consumerSecret = credentials?.consumerSecret;
    String authKey = base64Encode(utf8.encode("$consumerKey:$consumerSecret"));

    print("consumer key: = ${consumerKey}");
    print("consumer Secret: = ${consumerSecret}");
    final response = await http.get(
      Uri.parse(
          "https://api.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials"),
      headers: {"Authorization": "Basic $authKey"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["access_token"];
    } else {
      throw Exception("Failed to get access token");
    }
  }

  String generateMpesaPassword(String businessShortCode, String passkey) {
    String timestamp = DateTime.now()
        .toUtc()
        .toString()
        .replaceAll(RegExp(r'\D'), '')
        .substring(0, 14);
    String dataToEncode = businessShortCode + passkey + timestamp;
    String password = base64.encode(utf8.encode(dataToEncode));
    return password;
  }

  Future<String> sendStkPush(
      String phone, double amount, String accessToken) async {
    String formatPhoneNumber(String phone) {
      if (phone.startsWith('0')) {
        return '254' + phone.substring(1);
      } else if (phone.startsWith('254')) {
        return phone;
      } else {
        throw Exception('Invalid phone number format');
      }
    }

    UserProvider _user = Provider.of<UserProvider>(context, listen: false);
    String formattedPhone = formatPhoneNumber(phone);

    final password = generateMpesaPassword("4086809",
        "53beb23ef8b57ee44ef9b74349847a2909bbc169227e434067f36a711f2681a9");
    print(formattedPhone);
    final response = await http.post(
      Uri.parse("https://api.safaricom.co.ke/mpesa/stkpush/v1/processrequest"),
      headers: {
        "Authorization": "Bearer $accessToken",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "BusinessShortCode": "4086809",
        "Password": password,
        "Timestamp": DateTime.now()
            .toUtc()
            .toString()
            .replaceAll(RegExp(r'\D'), '')
            .substring(0, 14),
        "TransactionType": "CustomerPayBillOnline",
        "Amount": amount,
        "PartyA": formattedPhone,
        "PartyB": "4086809",
        "PhoneNumber": formattedPhone,
        "CallBackURL":
            "https://us-central1-buricode-6e54c.cloudfunctions.net/handleMpesaCallback",
        "AccountReference": "${_user.user?.uid}",
        "TransactionDesc": "Payment for BucoRide vehicle registration",
      }),
    );

    if (response.statusCode == 200) {
      return "Payment request sent. Check your M-Pesa.";
    } else {
      throw Exception("Payment failed: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    UserProvider _user = Provider.of<UserProvider>(context, listen: false);
    AppStateProvider appState =
        Provider.of<AppStateProvider>(context, listen: false);

    return Scaffold(
      appBar: CustomAppBar(
        title: "Pay with Mpesa",
        showNavBack: false,
        centerTitle: true,
      ),
      body: isLoading
          ? LoadingLocationScreen()
          : Padding(
              padding: EdgeInsets.all(Dimensions.paddingSize),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      Images.mpesaIcon,
                      width: 100,
                    ),
                    SizedBox(
                      height: Dimensions.paddingSizeSmall,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "You will be required to pay $amountToPay. \n "
                          "This amount is will renewed monthly.",
                          style: TextStyle(
                            fontSize: Dimensions.fontSizeDefault,
                            color: Colors.black,
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: Dimensions.paddingSize),
                    _buildTextField(
                      "Mpesa Number",
                      _user.mpesaNumberController,
                      Icons.phone,
                      isNumber: true,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => initiateMpesaPayment(appState),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.lightPrimary,
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(border_radius),
                        ),
                      ),
                      child: Text(
                        "Pay with M-Pesa",
                        style: TextStyle(
                          fontSize: Dimensions.fontSizeDefault,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, IconData icon,
      {required bool isNumber}) {
    return Padding(
      padding: EdgeInsets.only(bottom: Dimensions.paddingSize),
      child: TextFormField(
        style: TextStyle(fontSize: Dimensions.fontSizeSmall),
        controller: controller,
        readOnly: controller.text.isNotEmpty,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: Dimensions.fontSizeSmall),
          prefixIcon: Icon(icon, color: Colors.black54),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(border_radius)),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: (value) => value!.isEmpty ? "Required" : null,
      ),
    );
  }
}

/// Payment Success/Failure Screen
class PaymentResultScreen extends StatelessWidget {
  final bool isSuccess;
  final String message;

  const PaymentResultScreen({required this.isSuccess, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: AppConstants.lightPrimary,
          title: Text(isSuccess ? "Payment waiting" : "Payment")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                color: isSuccess ? Colors.green : Colors.red,
                size: 100,
              ),
            ),
            SizedBox(height: Dimensions.paddingSize),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: Dimensions.fontSizeSmall),
            ),
            SizedBox(height: Dimensions.paddingSize),
            ElevatedButton(
              onPressed: () {
                changeScreenReplacement(
                    context, HomePage()); // Go back to the payment page
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.lightPrimary,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(border_radius),
                ),
              ),
              child: Text("Start receiving Trip requests.",
                  style: TextStyle(fontSize: Dimensions.fontSizeSmall)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Payment Success/Failure Screen
class PaymentInProgressScreen extends StatelessWidget {
  final bool isSuccess;
  final String message;

  const PaymentInProgressScreen(
      {required this.isSuccess, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: AppConstants.lightPrimary,
          title: Text(isSuccess ? "Payment waiting" : "Payment Waiting")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Loading(),
            ),
            SizedBox(height: Dimensions.paddingSize),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: Dimensions.fontSizeSmall),
            ),
            SizedBox(height: Dimensions.paddingSize),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Go back to the payment page
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.lightPrimary,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(border_radius),
                ),
              ),
              child: Text("Go Back",
                  style: TextStyle(fontSize: Dimensions.fontSizeSmall)),
            ),
          ],
        ),
      ),
    );
  }
}
