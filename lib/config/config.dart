

import 'package:google_maps_flutter/google_maps_flutter.dart';

class Config {
  final String appName = 'Travel Hour';
  final String mapAPIKey = 'AIzaSyA-fE7BtlehhXxsO_sWnHpayW**********';
  final String countryName = 'Bangladesh';
  final String splashIcon = 'assets/images/splash.png';
  final String supportEmail = 'mrblab24@gmail.com';
  final String privacyPolicyUrl = 'https://www.freeprivacypolicy.com/pri************';
  final String ourWebsiteUrl = 'https://codecanyon.net/user/mrblab24/portfolio';
  final String iOSAppId = '000000000';

  final String specialState1 = 'Sylhet';
  final String specialState2 = 'Chittagong';

  

  // your country lattidtue & logitude
  final CameraPosition initialCameraPosition = CameraPosition(
    target: LatLng(23.777176,90.399452),
    zoom: 10,
  );

  
  //google maps marker icons
  final String hotelIcon = 'assets/images/hotel.png';
  final String restaurantIcon = 'assets/images/restaurant.png';
  final String hotelPinIcon = 'assets/images/hotel_pin.png';
  final String restaurantPinIcon = 'assets/images/restaurant_pin.png';
  final String drivingMarkerIcon = 'assets/images/driving_pin.png';
  final String destinationMarkerIcon = 'assets/images/destination_map_marker.png';

  
  
  //Intro images
  final String introImage1 = 'assets/images/travel6.png';
  final String introImage2 = 'assets/images/travel1.png';
  final String introImage3 = 'assets/images/travel5.png';

  
  //Language Setup

  final List<String> languages = [
    'English',
    'Spanish'
  ];

  
  // Ads Setup

  final int userClicksAmountsToShowEachAd  = 5;

   //-- admob ads --
  final String admobAppId = 'ca-app-pub-3940256099942544~3347511713';
  final String admobInterstitialAdId = 'ca-app-pub-3940256099942544/1033173712';

  //fb ads
  final String fbInterstitalAdIDAndroid = '193186341991913_351138***********';
  //final String fbInterstitalAdIDiOS = '193186341991913_351139692863243';

  

  
}