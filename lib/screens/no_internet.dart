import 'package:flutter/material.dart';

class NoInternet extends StatelessWidget {
  final String title;
  NoInternet({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(title),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wifi_off,
                size: 60,
              ),
              SizedBox(
                height: 40,
              ),
              Text("Please connect to the internet")
            ],
          ),
        ));
  }
}
