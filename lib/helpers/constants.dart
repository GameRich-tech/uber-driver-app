import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:googlemaps_flutter_webservices/places.dart';

//const GOOGLE_MAPS_API_KEY = "AIzaSyBqD2lxHfrvXS6DszBaG1w-dHAXnArbbPE";
const GOOGLE_MAPS_API_KEY = "AIzaSyAGDlcfxXtt2rmk_GrytWTVRGMHngzdHYM";
const COUNTRY = "country";
const positionUpdate = 25; //Stores the amount of seconds to update its position
late FirebaseMessaging fcm =
    FirebaseMessaging.instance; // Updated FirebaseMessaging initialization
final FirebaseFirestore firestore =
    FirebaseFirestore.instance; //firestore instance

GoogleMapsPlaces places = GoogleMapsPlaces(apiKey: GOOGLE_MAPS_API_KEY);
const user_global_location = null;
String? location_global_address = "Ke";

String country_global_key = "Kenya";
int selectedNavIndex = 0;
double border_radius = 25;
