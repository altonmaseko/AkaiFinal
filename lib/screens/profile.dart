import 'package:akai/app.dart';
import 'package:akai/utils/constants/image_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:akai/utils/device_utils.dart';
import 'package:akai/utils/boxContainer.dart';
import 'package:akai/utils/constants/colors.dart';
import 'package:akai/utils/constants/sizes.dart';
import 'package:akai/utils/theme/text_theme.dart';
import 'package:akai/screens/login.dart';
import 'package:akai/utils/texts.dart';
import 'package:akai/utils/theme/elevated_button_theme.dart';

var _myBox = Hive.box("myBox");

class Profile extends StatelessWidget {
  Profile();

  Future<void> logout(BuildContext context) async {
    final secureStorage = FlutterSecureStorage();

    await secureStorage.deleteAll();
    // onSignOut();
    Navigator.of(context).pushNamedAndRemoveUntil('app', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    String name = _myBox.get('firstname') ?? "Alton Maseko";
    String email = _myBox.get('email') ?? "altonmaseko1000@gmail.com";

    return Scaffold(
      appBar: AppBar(
        title:
            Text('Profile', style: Theme.of(context).textTheme.headlineSmall),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircleAvatar(
                    backgroundColor: TColors.rosePink,
                    backgroundImage: AssetImage(TImages.logo)),
              ),
              //Name
              Text(
                '${name}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                '${email}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(
                height: TSizes.defaultSpace,
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 20),
                ),
                label: Text("Sign Out"),
                icon: Icon(Iconsax.login),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Sign Out'),
                        content:
                            const Text('Are you sure you want to sign out?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the dialog
                              logout(context);
                            },
                            child: const Text(
                              'Yes',
                              style: TextStyle(
                                  color: TColors.rosePink,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the dialog
                            },
                            child: const Text('No',
                                style: TextStyle(
                                    color: TColors.rosePink,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      );
                    },
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
