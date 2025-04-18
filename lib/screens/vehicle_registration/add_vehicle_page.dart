import 'package:Bucoride_Driver/helpers/constants.dart';
import 'package:Bucoride_Driver/helpers/screen_navigation.dart';
import 'package:Bucoride_Driver/providers/user.dart';
import 'package:Bucoride_Driver/screens/Paywall/Paywall.dart';
import 'package:Bucoride_Driver/screens/terms_and_condition.dart';
import 'package:Bucoride_Driver/utils/app_constants.dart';
import 'package:Bucoride_Driver/utils/dimensions.dart';
import 'package:Bucoride_Driver/widgets/app_bar/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../providers/app_provider.dart';
import '../../utils/images.dart';

class AddVehiclePage extends StatefulWidget {
  @override
  _AddVehiclePageState createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends State<AddVehiclePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> updateUserData(Map<String, dynamic> data) async {
    setState(() => _isLoading = true);
    UserProvider _user = Provider.of<UserProvider>(context, listen: false);
    _user.updateUserData(data);
    await _user.reloadUserModel();
    setState(() => _isLoading = false);
    changeScreenReplacement(
        context,
        Paywall(
          isRenewal: false,
        ));
  }

  Map<String, dynamic> gatherFormData() {
    UserProvider _user = Provider.of<UserProvider>(context, listen: false);
    return {
      'id': _user.userModel?.id,
      'vehicleType': _user.vehicleTypeController.text,
      'model': _user.modelController.text,
      'brand': _user.brandController.text,
      'weightCapacity': _user.weightCapacityController.text,
      'licensePlate': _user.licensePlateController.text,
      'expiryDate': _user.expiryDateController.text,
      'fuelType': _user.fuelTypeController.text,
      'vehicleType': _user.vehicleTypeController.text,
      'hasVehicle': false, //
    };
  }

  @override
  Widget build(BuildContext context) {
    UserProvider _user = Provider.of<UserProvider>(context, listen: true);
    AppStateProvider appState =
        Provider.of<AppStateProvider>(context, listen: true);
    return Scaffold(
      appBar: CustomAppBar(
          title: "Add Vehicle", showNavBack: true, centerTitle: false),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  Images.car,
                  width: 222,
                  height: 222,
                ),
              ),
              Center(
                child: _buildSectionTitle("Vehicle Information"),
              ),
              SizedBox(
                height: Dimensions.paddingSizeSmall,
              ),
              _buildSubTitle(
                  "Fill in your details to get approved by the admin."),
              _buildSubTitle(
                  "A small fee is required to complete registration."),
              SizedBox(height: Dimensions.paddingSizeLarge),
              _buildDropdownField(
                "Vehicle Type",
                _user.vehicleTypeController,
                FaIcon(FontAwesomeIcons.gamepad),
                {
                  "Motorbike": FaIcon(FontAwesomeIcons.motorcycle),
                  "Sedan": FaIcon(FontAwesomeIcons.car),
                  "Van": FaIcon(FontAwesomeIcons.vanShuttle),
                  "Tuk-Tuk": FaIcon(FontAwesomeIcons.car),
                },
              ),
              _buildTextField("Vehicle Model", _user.modelController,
                  Icons.car_crash_outlined,
                  isNumber: false),
              _buildTextField("Brand", _user.brandController, Icons.factory,
                  isNumber: false),
              _buildTextField("Weight Capacity (KG)",
                  _user.weightCapacityController, Icons.scale,
                  isNumber: true),
              _buildTextField("License Plate", _user.licensePlateController,
                  Icons.confirmation_number,
                  isNumber: false),
              _buildDatePickerField(
                  "License Issue", _user.expiryDateController),
              _buildDropdownField(
                "Fuel Type",
                _user.fuelTypeController,
                FaIcon(FontAwesomeIcons.gasPump),
                {
                  "Petrol": FaIcon(FontAwesomeIcons.gasPump),
                  "Diesel": FaIcon(FontAwesomeIcons.gasPump),
                  "Electric": FaIcon(FontAwesomeIcons.gasPump)
                },
              ),
              Center(
                child: _isLoading
                    ? SpinKitFoldingCube(
                        color: AppConstants.lightPrimary, size: 50)
                    : ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            updateUserData(gatherFormData());
                            appState.showCustomSnackBar(
                                context,
                                "Vehicle submitted successfully! Waiting for verification. You will be redirected to pay Screen",
                                Colors.green);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.lightPrimary,
                          padding: EdgeInsets.symmetric(
                              horizontal: 40, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(border_radius)),
                        ),
                        child: Text("Submit",
                            style: TextStyle(
                                fontSize: Dimensions.fontSizeDefault,
                                color: Colors.white)),
                      ),
              ),
              SizedBox(height: Dimensions.paddingSize),
              Center(
                child: TextButton(
                  onPressed: () {
                    changeScreen(context, TermsScreen());
                  },
                  child: Text(
                    'Terms & Conditions',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      color: Colors.black,
                      fontSize: Dimensions.fontSizeDefault,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: AppConstants.lightPrimary,
        fontSize: Dimensions.fontSizeExtraLarge,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSubTitle(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.black,
        fontSize: Dimensions.fontSizeDefault,
      ),
    );
  }

  Widget _buildDropdownField(String labelText, TextEditingController controller,
      FaIcon icon, Map<String, FaIcon> items) {
    return Padding(
      padding: EdgeInsets.only(bottom: Dimensions.paddingSize),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            labelText,
            style: TextStyle(fontSize: Dimensions.fontSizeSmall),
          ),
          SizedBox(height: Dimensions.paddingSizeSmall),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(border_radius),
              border: Border.all(color: Colors.grey.shade400),
              color: Colors.white,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonFormField<String>(
                value: items.keys.contains(controller.text)
                    ? controller.text
                    : null, // ✅ Fix
                decoration: InputDecoration(
                  border: InputBorder.none,
                ),
                dropdownColor: Colors.white,
                onChanged: (String? newValue) {
                  setState(() {
                    controller.text = newValue!;
                  });
                },
                items: items.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Row(
                      children: [
                        Icon(entry.value.icon,
                            size: 20, color: Colors.black54), // ✅ Show icon
                        SizedBox(width: 10),
                        Text(entry.key,
                            style:
                                TextStyle(fontSize: Dimensions.fontSizeSmall)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
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

  Widget _buildDatePickerField(String label, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.only(bottom: Dimensions.paddingSize),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(Icons.calendar_today, color: Colors.black54),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(border_radius)),
          filled: true,
          fillColor: Colors.white,
        ),
        onTap: () async {
          FocusScope.of(context).requestFocus(FocusNode());
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (pickedDate != null) {
            setState(() {
              controller.text = "${pickedDate.toLocal()}".split(' ')[0];
            });
          }
        },
        validator: (value) => value!.isEmpty ? "Required" : null,
      ),
    );
  }
}
