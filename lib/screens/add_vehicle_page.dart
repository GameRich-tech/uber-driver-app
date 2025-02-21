import 'package:Bucoride_Driver/helpers/screen_navigation.dart';
import 'package:Bucoride_Driver/providers/user.dart';
import 'package:Bucoride_Driver/screens/menu.dart';
import 'package:Bucoride_Driver/screens/terms_and_condition.dart';
import 'package:Bucoride_Driver/utils/app_constants.dart';
import 'package:Bucoride_Driver/utils/dimensions.dart';
import 'package:Bucoride_Driver/widgets/app_bar/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../utils/images.dart';

class AddVehiclePage extends StatefulWidget {
  @override
  _AddVehiclePageState createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends State<AddVehiclePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController modelController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController weightCapacityController =
      TextEditingController();
  final TextEditingController licensePlateController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();
  final TextEditingController fuelTypeController = TextEditingController(text: "Petrol");

  bool _isLoading = false;

  Future<void> updateUserData(Map<String, dynamic> data) async {
    setState(() => _isLoading = true);
    UserProvider _user = Provider.of<UserProvider>(context, listen: false);
    _user.updateUserData(data);
    await _user.reloadUserModel();
    setState(() => _isLoading = false);
    changeScreenReplacement(context, Menu());
  }

  Map<String, dynamic> gatherFormData() {
    UserProvider _user = Provider.of<UserProvider>(context, listen: false);
    return {
      'id': _user.userModel?.id,
      'model': modelController.text,
      'brand': brandController.text,
      'weightCapacity': weightCapacityController.text,
      'licensePlate': licensePlateController.text,
      'expiryDate': expiryDateController.text,
      'fuelType': fuelTypeController.text,
      'hasVehicle': true, //
    };
  }

  @override
  Widget build(BuildContext context) {
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
              _buildSubTitle("Add your info to send approval request to admin"),
              SizedBox(height: Dimensions.paddingSizeLarge),
              _buildTextField(
                  "Vehicle Model", modelController, Icons.car_crash_outlined, isNumber: false),
              _buildTextField("Brand", brandController, Icons.factory,isNumber: false),
              _buildTextField(
                  "Weight Capacity (KG)", weightCapacityController, Icons.scale,
                  isNumber: true),
              _buildTextField("License Plate", licensePlateController,
                  Icons.confirmation_number,isNumber: false ),
              
              
              _buildDatePickerField("License Issue", expiryDateController),
              _buildDropdownField(
                "Fuel Type", fuelTypeController, Icons.heat_pump ,["Petrol", "Diesel", "Electric"],
              ),
               

              
              Center(
                child: _isLoading
                    ? SpinKitFoldingCube(
                        color: AppConstants.lightPrimary, size: 50)
                    : ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            updateUserData(gatherFormData());
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Vehicle submitted successfully! Waiting for verification.'),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.lightPrimary,
                          padding: EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25)),
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

Widget _buildDropdownField(String labelText, TextEditingController controller, IconData icon, List<String> items) {
  return Padding(
    padding: EdgeInsets.only(bottom: Dimensions.paddingSize),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          labelText,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: Dimensions.fontSizeDefault),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade400),
            color: Colors.white,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonFormField<String>(
              value: controller.text,
              decoration: InputDecoration(
                border: InputBorder.none,
                prefixIcon: Icon(icon, color: Colors.black54),
              ),
              dropdownColor: Colors.white,
              onChanged: (String? newValue) {
                setState(() {
                  controller.text = newValue!;
                });
              },
              items: items.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: TextStyle(fontSize: Dimensions.fontSizeDefault)),
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
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.black54),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
