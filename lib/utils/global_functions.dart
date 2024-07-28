import 'dart:io';

import 'package:flutter/material.dart';

// Showing pop up that is dismissable by clicking outside
void showPopUp(BuildContext context,
    {required double height, required List<Widget> widgets}) {
  showDialog(
      context: context,
      builder: (context) => AlertDialog(
            content: Container(
                height: height,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [...widgets],
                  ),
                )),
          ));
}

// INTERNET CHECKING

Future<bool> hasInternet() async {
  try {
    final result = await InternetAddress.lookup('example.com');
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } on SocketException catch (_) {
    return false;
  }
}

Future<bool> checkInternet(BuildContext context, Function setState) async {
  bool isConnected = await hasInternet();
  setState(() {
    if (isConnected == false) {
      showPopUp(context,
          height: 200, widgets: [Text("Please connect to the internet")]);
      return false;
    }
  });

  return true;
}
