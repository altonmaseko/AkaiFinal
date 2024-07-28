import 'dart:convert';

import 'package:akai/screens/map_receiver_accept_page.dart';
import 'package:akai/screens/map_start_page.dart';
import 'package:akai/secret_contants.dart';
import 'package:akai/utils/global_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';

import 'package:http/http.dart' as http;

var _myBox = Hive.box("myBox");

class MapReceiverPage extends StatefulWidget {
  const MapReceiverPage({super.key});

  @override
  State<MapReceiverPage> createState() => _MapReceiverPageState();
}

class _MapReceiverPageState extends State<MapReceiverPage> {
  // {email: email, location: location,
  //FCMToken: FCMToken, firstname: user.firstname,
  //lastname: user.lastname, phonenumber: user.phonenumber,
  // id: user.id}

  Map<String, String> userInfo = {
    'firstname': "alton",
    'lastnamse': "maseko",
    'phonenumber': '0123456789',
    'distance': 'Near By'
  };

  var firstname = "alton";
  var phone = "0123456789";

  @override
  Widget build(BuildContext context) {
    // Retrieve the arguments which include the RemoteMessage
    final RemoteMessage message =
        ModalRoute.of(context)?.settings.arguments as RemoteMessage;

    // Access data from the message
    final Map<String, dynamic> data = message.data;

    firstname = data['firstname'];
    phone = data['phone'];

    return Scaffold(
      appBar: AppBar(
        title: Text("Help an Akai mate"),
      ),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
              border: Border.all()),
          margin: EdgeInsets.all(40),
          padding: EdgeInsets.all(20),
          height: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Akai mate in need", style: TextStyle(fontSize: 25)),
              SizedBox(
                height: 10,
              ),

              /// First Name
              Row(
                children: [
                  Text("First Name: "),
                  Flexible(child: Text(data['firstname'] ?? "First Name")),
                ],
              ),

              /// Last Name
              Row(
                children: [
                  Text("Last Name: "),
                  Flexible(child: Text(data['lastname'] ?? "Last Name")),
                ],
              ),

              /// Phone Number
              Row(
                children: [
                  Text("Phone: "),
                  Flexible(
                    child: Text(
                      data['phonenumber'] ?? "Phone Number",
                    ),
                  ),
                ],
              ),

              /// Distance
              Row(
                children: [
                  Text("Distance: "),
                  Flexible(child: Text(userInfo['distance']!)),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    acceptButton();
                  },
                  child: Text("Accept"),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    rejectButton();
                  },
                  child: Text("Not Available"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void acceptButton() async {
    //const LatLng requesterLocation =
    LatLng(-26.2350, 28.0073); // get requester information

    // OLS

    String requesterName = "Sweety Flowers";

    String requesterPhoneNumber = '0677716689';

// HTTP ==========
    String url = baseUrl + "api/notifications/sendacceptnotification";
    final uri = Uri.parse(url);

    final headers = {
      'Content-Type': 'application/json',
      'Authorization':
          'Bearer ${await secureStorage.read(key: 'token')}', // Include the Bearer token here
    };

    var body = {
      "firstname": _myBox.get('firstname'),
      "lastname": _myBox.get('lastname'),
      "location": [_myBox.get('longitude'), _myBox.get('latitude')],
      "id": _myBox.get('id'),
      "email": _myBox.get('email'),
      "phone": _myBox.get('phone'),
      "FCMToken": _myBox.get('fcm'),
    };

    try {
      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );
    } catch (e) {
      print("Error when trying to accept");
      showPopUp(context,
          height: 200, widgets: [Text("Sorry could not accept")]);
    }

    // HTTP ================
    double longitude = _myBox.get('longitude')!;
    double latitude = _myBox.get('latitude')!;

    LatLng requesterLocation = LatLng(latitude, longitude);

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => MapReceiverAcceptPage(
                accepted: true,
                requesterLocation: requesterLocation,
                requesterName: firstname,
                requesterPhoneNumber: phone)),
        (route) => false);
  }

  void rejectButton() {
    showPopUp(context, height: 300, widgets: [
      Text(
        "Thank you for your consideration :)",
        textAlign: TextAlign.center,
      ),
      SizedBox(
        height: 20,
      ),
      ElevatedButton(
          onPressed: () {
            Navigator.of(context)
                .pushNamedAndRemoveUntil('app', (route) => false);
          },
          child: Text("Home"))
    ]);
  }
}
