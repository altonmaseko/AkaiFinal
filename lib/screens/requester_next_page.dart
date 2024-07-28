import 'package:akai/app.dart';
import 'package:akai/secret_contants.dart';
import 'package:akai/utils/constants/colors.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:url_launcher/url_launcher_string.dart';

class RequesterNextPage extends StatefulWidget {
  const RequesterNextPage({super.key});

  @override
  State<RequesterNextPage> createState() => _RequesterNextPageState();
}

final secureStorage = FlutterSecureStorage();

final _myBox = Hive.box('myBox');

final _firebaseMessaging = FirebaseMessaging.instance;

class _RequesterNextPageState extends State<RequesterNextPage> {
  List<Widget> people = [
    Container(
      margin: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
      color: TColors.lilac,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              Text("Alton Maseko"),
              Text("0123456789"),
            ],
          ),
          IconButton(
              onPressed: () async {
                var phoneNumber = "02342934234";
                String requesterPhoneNumber = phoneNumber;
                if (phoneNumber.startsWith('0')) {
                  // Replace the first occurrence of '0' with '+27'
                  requesterPhoneNumber = phoneNumber.replaceFirst('0', '+27');
                }
                // END: FORMAT PHONENUMBER =========================

                final whatsappUrl =
                    "whatsapp://send?phone=${requesterPhoneNumber}";

                if (await canLaunchUrlString(whatsappUrl)) {
                  await launchUrlString(whatsappUrl);
                } else {
                  print("Could not open WhatsApp");
                }
              },
              icon: Icon(FontAwesomeIcons.whatsapp))
        ],
      ),
    )
  ];
  void openWhatsApp() {}

  Future initPushNotifications() async {
    // event listener for when app is currently being displayed
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // [WORKING]
      debugPrint(
          'NOTIFICATION [App in FOREGROUND]: ${message.notification!.body}');

      // Access the data payload
      String firstname = message.data['firstname'];
      String lastname = message.data['lastname'];
      String phoneNumber = message.data['phonenumber'];

      String name = "${firstname} ${lastname}";

      setState(() {
        people.add(getPerson(name: name, phone: phoneNumber));
      });
    });

    // Background message
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("People nearby"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Please wait for people to respond..."),
            SizedBox(
              height: 20,
            ),
            Column(
              children: [...people],
            ),
          ],
        ),
      ),
    );
  }

  void _launchWhatsApp(String phoneNumber) async {
    // FORMAT PHONENUMBER
    String requesterPhoneNumber = phoneNumber;
    if (phoneNumber.startsWith('0')) {
      // Replace the first occurrence of '0' with '+27'
      requesterPhoneNumber = phoneNumber.replaceFirst('0', '+27');
    }
    // END: FORMAT PHONENUMBER =========================

    final whatsappUrl = "whatsapp://send?phone=${requesterPhoneNumber}";

    if (await canLaunchUrlString(whatsappUrl)) {
      await launchUrlString(whatsappUrl);
    } else {
      print("Could not open WhatsApp");
    }
  }

  Widget getPerson({required String name, required String phone}) {
    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
      color: TColors.lilac,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              Text(name),
              Text(phone),
            ],
          ),
          IconButton(
              onPressed: () async {
                var phoneNumber = phone;
                String requesterPhoneNumber = phoneNumber;
                if (phoneNumber.startsWith('0')) {
                  // Replace the first occurrence of '0' with '+27'
                  requesterPhoneNumber = phoneNumber.replaceFirst('0', '+27');
                }
                // END: FORMAT PHONENUMBER =========================

                final whatsappUrl =
                    "whatsapp://send?phone=${requesterPhoneNumber}";

                if (await canLaunchUrlString(whatsappUrl)) {
                  await launchUrlString(whatsappUrl);
                } else {
                  print("Could not open WhatsApp");
                }
              },
              icon: Icon(FontAwesomeIcons.whatsapp))
        ],
      ),
    );
  }
}

// NOTIFICATION MESSAGING

// handle background settings

