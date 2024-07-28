import 'dart:async';
import 'dart:convert';

import 'package:akai/screens/signup.dart';
import 'package:akai/secret_contants.dart';
import 'package:akai/utils/constants/image_strings.dart';
import 'package:akai/utils/global_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:akai/utils/constants/sizes.dart';
import 'package:akai/utils/device_utils.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:iconsax/iconsax.dart';
import 'package:akai/utils/texts.dart';

import 'package:http/http.dart' as http;

var _myBox = Hive.box("myBox");

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // Password visibility flag
  bool _passwordVisible = false;

  void _togglePasswordVisibility() {
    setState(() {
      _passwordVisible = !_passwordVisible;
    });
  }

  void verifyEmail(String email) {}

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    checkInternet(context, setState);
  }

  @override
  Widget build(BuildContext context) {
    final mode = TDeviceUtils.isDarkMode(context);
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: TSizes.defaultSpace,
            left: TSizes.defaultSpace,
            right: TSizes.defaultSpace,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon on top
              Image(
                height: 150,
                image: AssetImage(
                  mode ? TImages.whiteLineWoman : TImages.blackLineWoman,
                ),
              ),

              // Welcome text
              Text(
                Texts.loginText,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 5),

              // Subtitle
              Text(
                Texts.loginSubtitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              Form(
                child: Column(
                  children: [
                    const SizedBox(height: 30),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Iconsax.direct_right),
                        labelText: 'Email:',
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_passwordVisible,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Iconsax.password_check),
                        labelText: 'Password:',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisible ? Iconsax.eye : Iconsax.eye_slash,
                          ),
                          onPressed: _togglePasswordVisibility,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Sign In Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          signInButton();
                        },
                        child: Text(Texts.SignIn),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Create Account Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, 'signuppage');
                        },
                        child: Text(Texts.CreateAcc),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> signInButton() async {
    // Verify input
    if (_emailController.text.trim() == "") {
      showBottomMessage([Text("Please enter your email.")]);
      return;
    }
    if (_passwordController.text.trim() == "") {
      showBottomMessage([Text("Please enter your password.")]);
      return;
    }
    // -------------------

    showBottomMessage([CircularProgressIndicator()]);

    print("Sending registration request");

    String url = baseUrl + "api/auth/login";
    final uri = Uri.parse(url);
    var body = {
      "email": _emailController.text,
      "password": _passwordController.text,
    };

    var response;
    try {
      response = await Future.any([
        http.post(uri, body: body),
        Future.delayed(Duration(seconds: 20),
            () => {throw TimeoutException("Request timed out")})
      ]);
    } on TimeoutException catch (e) {
      Navigator.of(context).pop(); // remove loading

      showBottomMessage([Text("Sorry, server took too long to respond")]);
      return;
    } catch (e) {
      Navigator.of(context).pop(); // remove loading

      showBottomMessage([Text("Something went wrong, please try again later")]);
      return;
    }

    print("RESPONSE: ${response}");
    print("Status Code: ${response.statusCode}");

    print("Status Code: ${jsonDecode(response.body)['token']}");

    if (response.statusCode == 401) {
      Navigator.of(context).pop(); // remove loading
      showBottomMessage([
        Text("Invalid email or password"),
      ]);
    } else if (response.statusCode == 200) {
      print("LOGIN SUCCESSFUL");
      storeToken(jsonDecode(response.body)['token']);
      // Navigator.of(context).pop();
      // Navigator.of(context).pushNamed('app');

// ===stpore
      _myBox.put('firstname', jsonDecode(response.body)['firstname']);
      _myBox.put('lastname', jsonDecode(response.body)['lastname']);
      _myBox.put('location', jsonDecode(response.body)['location']);
      _myBox.put('id', jsonDecode(response.body)['id']);
      _myBox.put('email', jsonDecode(response.body)['email']);
      _myBox.put('phone', jsonDecode(response.body)['phone']);
//====

      Navigator.of(context).pushNamedAndRemoveUntil('app', (route) => false);
    } else {
      // something went wrong, try again later
      Navigator.of(context).pop(); // remove loading
      showBottomMessage([Text("Sorry, something went wrong.")]);
    }
  }

  void showBottomMessage(List<Widget> widgets) {
    showModalBottomSheet(
        isScrollControlled: false,
        context: context,
        builder: (context) {
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(
                  top: 40,
                  left: 40,
                  right: 40,
                  bottom: 40 + MediaQuery.of(context).viewInsets.bottom),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ...widgets,
                  ],
                ),
              ),
            ),
          );
        });
  }

  Future<void> storeToken(String token) async {
    final secureStorage = FlutterSecureStorage();

    await secureStorage.write(key: "token", value: token);

    final t = await secureStorage.read(key: 'token');

    print("TOKEN: ${t}");
  }
}
