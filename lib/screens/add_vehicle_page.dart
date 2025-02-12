import 'package:Bucoride_Driver/helpers/style.dart';
import 'package:Bucoride_Driver/utils/app_constants.dart';
import 'package:Bucoride_Driver/utils/dimensions.dart';
import 'package:Bucoride_Driver/utils/images.dart';
import 'package:flutter/material.dart';

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
  final TextEditingController fuelTypeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Add Vehicle",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: AppConstants.fontFamily,
            fontSize: AppConstants.defaultTextSize,
            fontWeight: AppConstants.defaultWeight,
          ),
        ),
        backgroundColor: AppConstants.lightPrimary,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Text(
                  'Vehicle Information',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppConstants.lightPrimary,
                      fontSize: Dimensions.fontSizeExtraLarge,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                child: Text(
                  'Add your info to send approval request to admin',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: Dimensions.fontSizeDefault),
                ),
              ),
              SizedBox(height: Dimensions.paddingSizeExtraLarge),
              Container(
                child: Text(
                  'Vehicle Brand',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black, fontSize: Dimensions.fontSizeLarge),
                ),
              ),
              SizedBox(height: Dimensions.paddingSize),
              TextFormField(
                controller: modelController,
                decoration: InputDecoration(
                    hintStyle: TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0))),
                    hintText: "Model",
                    icon: Icon(
                      Icons.car_crash_outlined,
                      color: Colors.black,
                    )),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: Dimensions.paddingSize),
              Container(
                child: Text(
                  'Brand',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black, fontSize: Dimensions.fontSizeLarge),
                ),
              ),
              SizedBox(height: Dimensions.paddingSize),
              TextFormField(
                controller: brandController,
                decoration: InputDecoration(
                    hintStyle: TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0))),
                    hintText: "Brand",
                    icon: Icon(
                      Icons.car_crash_outlined,
                      color: Colors.black,
                    )),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: Dimensions.paddingSize),
              Container(
                child: Text(
                  'Weight Capacity',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black, fontSize: Dimensions.fontSizeLarge),
                ),
              ),
              SizedBox(height: Dimensions.paddingSize),
              TextFormField(
                controller: weightCapacityController,
                decoration: InputDecoration(
                    hintStyle: TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0))),
                    hintText: "Weight Capacity (KG)",
                    icon: Icon(
                      Icons.car_crash_outlined,
                      color: Colors.black,
                    )),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: Dimensions.paddingSize),
              Container(
                child: Text(
                  'License Plate Number',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black, fontSize: Dimensions.fontSizeLarge),
                ),
              ),
              SizedBox(height: Dimensions.paddingSize),
              TextFormField(
                controller: licensePlateController,
                decoration: InputDecoration(
                    hintStyle: TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0))),
                    hintText: "KCZ 2**",
                    icon: Icon(
                      Icons.car_crash_outlined,
                      color: Colors.black,
                    )),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: Dimensions.paddingSize),
              Container(
                child: Text(
                  'License Expiry',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black, fontSize: Dimensions.fontSizeLarge),
                ),
              ),
              SizedBox(height: Dimensions.paddingSize),
              TextFormField(
                controller: expiryDateController,
                decoration: InputDecoration(
                    hintStyle: TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(25.0)),
                    ),
                    hintText: "yy-mm-dd",
                    icon: Image.asset(
                      Images.calenderIcon,
                      color: black,
                      width: Dimensions.iconSizeLarge,
                      height: Dimensions.iconSizeLarge,
                    )),
                validator: (value) => value!.isEmpty ? 'Required' : null,
                onTap: () async {
                  FocusScope.of(context)
                      .requestFocus(FocusNode()); // Hide keyboard
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      // Format the date and set it to the controller
                      expiryDateController.text =
                          "${pickedDate.toLocal()}".split(' ')[0];
                    });
                  }
                },
              ),
              SizedBox(height: Dimensions.paddingSize),
              Container(
                child: Text(
                  'Fuel Type',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black, fontSize: Dimensions.fontSizeLarge),
                ),
              ),
              SizedBox(height: Dimensions.paddingSize),
              TextFormField(
                controller: fuelTypeController,
                decoration: InputDecoration(
                    hintStyle: TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0))),
                    hintText: "Select FuelType",
                    icon: Icon(
                      Icons.car_repair,
                      color: Colors.black,
                    )),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Submit vehicle details to Firebase here
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Vehicle submitted successfully!')),
                    );
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
