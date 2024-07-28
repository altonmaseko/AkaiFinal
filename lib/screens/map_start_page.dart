import 'dart:convert';

import 'package:akai/secret_contants.dart';
import 'package:akai/utils/global_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';

import 'package:http/http.dart' as http;

final secureStorage = FlutterSecureStorage();

class MapStartPage extends StatefulWidget {
  MapStartPage({super.key});

  @override
  State<MapStartPage> createState() => _MapStartPageState();
}

class _MapStartPageState extends State<MapStartPage> {
  var _myBox = Hive.box("myBox");

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkInternet(context, setState);

    // _checkLocalStorageAndShowPopup();
    // setState(() {});

    // if (_myBox.get("show-map-pop-up") == "true") {
    //   showPopUp(context,
    //       height: 300, widgets: [Text("Someone requested a pad from you!")]);

    //   _myBox.put("show-map-pop-up", "false");
    // }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      return;
      if (showMapPopUp) {
        // this is working
        print("showMapPopUp is TRUE");
        showPopUp(context,
            height: 200, widgets: [Text("You were asked for a pad")]);
        showMapPopUp = false;
      } else {
        print("showMapPopUp is FALSE");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // putting showPopUp here causes an error
    return Scaffold(
      appBar: AppBar(
        title: Text("Pad System"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    askForPadsButton();
                  },
                  child: Text("Ask for pads"),
                ),
              ),
              SizedBox(
                height: 40,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('mapreceiver');
                  },
                  child: Text("Receiver demo"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> askForPadsButton() async {
    String url = baseUrl + "api/notifications/sendnotification";
    final uri = Uri.parse(url);

    var longitude = _myBox.get('longitude');
    var latitude = _myBox.get('latitude');

    var body = {
      "location": [longitude, latitude],
      "FCMToken": _myBox.get('fcm'),
    };

    final headers = {
      'Content-Type': 'application/json',
      'Authorization':
          'Bearer ${await secureStorage.read(key: 'token')}', // Include the Bearer token here
    };

    var response;
    try {
      response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        Navigator.of(context).pushNamed('requesternextpage');
      } else {
        showPopUp(context,
            height: 200, widgets: [Text("Sorry could not contact people")]);
      }
    } catch (e) {
      print("Something went wrong requesting pads");
      showPopUp(context,
          height: 200,
          widgets: [Text("Sorry, something went wrong int the server")]);
    }
  }
}
