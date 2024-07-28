import 'dart:async';
import 'dart:convert';

import 'package:akai/secret_contants.dart';
import 'package:akai/utils/constants/sizes.dart';
import 'package:akai/utils/global_functions.dart';
import 'package:akai/utils/texts.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:http/http.dart' as http;

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  // TextEditingControllers for input fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _rePasswordController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  // FocusNodes for input fields
  final FocusNode _firstNameFocusNode = FocusNode();
  final FocusNode _lastNameFocusNode = FocusNode();
  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _phoneNumberFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _rePasswordFocusNode = FocusNode();
  final FocusNode _idFocusNode = FocusNode();

  // Flags to track if fields have been clicked first time
  bool _firstNameTouched = false;
  bool _lastNameTouched = false;
  bool _usernameTouched = false;
  bool _emailTouched = false;
  bool _phoneNumberTouched = false;
  bool _passwordTouched = false;
  bool _rePasswordTouched = false;
  bool _idTouched = false;

  // Password visibility flags
  bool _passwordVisible = false;
  bool _rePasswordVisible = false;

  //state to track focus on each input field
  @override
  void initState() {
    super.initState();
    // Default values ==============
    // _firstNameController.text = "ExampleName";
    // _lastNameController.text = "ExampleSurname";
    // _emailController.text = "altonmaseko1000@gmail.com";
    // _phoneNumberController.text = "0677716689";
    // _passwordController.text = "Password123**";
    // _rePasswordController.text = "Password123**";
    // _idController.text = "0310240640089";

    // Default values ====================
    _firstNameFocusNode
        .addListener(() => _handleFocusChange(_firstNameFocusNode, () {
              setState(() {
                _firstNameTouched = true;
              });
            }));
    _lastNameFocusNode
        .addListener(() => _handleFocusChange(_lastNameFocusNode, () {
              setState(() {
                _lastNameTouched = true;
              });
            }));
    _usernameFocusNode
        .addListener(() => _handleFocusChange(_usernameFocusNode, () {
              setState(() {
                _usernameTouched = true;
              });
            }));
    _emailFocusNode.addListener(() => _handleFocusChange(_emailFocusNode, () {
          setState(() {
            _emailTouched = true;
          });
        }));
    _phoneNumberFocusNode
        .addListener(() => _handleFocusChange(_phoneNumberFocusNode, () {
              setState(() {
                _phoneNumberTouched = true;
              });
            }));
    _passwordFocusNode
        .addListener(() => _handleFocusChange(_passwordFocusNode, () {
              setState(() {
                _passwordTouched = true;
              });
            }));
    _rePasswordFocusNode
        .addListener(() => _handleFocusChange(_rePasswordFocusNode, () {
              setState(() {
                _rePasswordTouched = true;
              });
            }));
    _idFocusNode.addListener(() => _handleFocusChange(_idFocusNode, () {
          setState(() {
            _idTouched = true;
          });
        }));
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _passwordController.dispose();
    _rePasswordController.dispose();
    _idController.dispose();
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _usernameFocusNode.dispose();
    _emailFocusNode.dispose();
    _phoneNumberFocusNode.dispose();
    _passwordFocusNode.dispose();
    _rePasswordFocusNode.dispose();
    _idFocusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange(FocusNode focusNode, VoidCallback callback) {
    if (focusNode.hasFocus) {
      callback();
    }
  }

  //for eye slash icon and password chars
  void _togglePasswordVisibility() {
    setState(() {
      _passwordVisible = !_passwordVisible;
    });
  }

  void _toggleRePasswordVisibility() {
    setState(() {
      _rePasswordVisible = !_rePasswordVisible;
    });
  }

  // field validation
  String? _validateFirstName(String? value) {
    if (!_firstNameTouched) return null;
    if (value == null || value.isEmpty) {
      return Texts.firstNameEmptyError;
    }
    return null;
  }

  String? _validateLastName(String? value) {
    if (!_lastNameTouched) return null;
    if (value == null || value.isEmpty) {
      return Texts.lastNameEmptyError;
    }
    return null;
  }

  String? _validateUsername(String? value) {
    if (!_usernameTouched) return null;
    if (value == null || value.isEmpty) {
      return Texts.userNameEmptyError;
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (!_emailTouched) return null;
    if (value == null || value.isEmpty) {
      return Texts.emailEmptyError;
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return Texts.emailInvalidError;
    }
    return null;
  }

  String? _validatePhoneNumber(String? value) {
    if (!_phoneNumberTouched) return null;
    if (value == null || value.isEmpty) {
      return Texts.phoneNumberEmptyError;
    }
    if (!(value.length == 10)) {
      return Texts.phoneNumberLengthError;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (!_passwordTouched) return null;
    if (value == null || value.isEmpty) {
      return Texts.passwordEmptyError;
    }
    if (value.length < 6) {
      return Texts.passwordLengthError;
    }
    if (!RegExp(
            r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*?&_])[A-Za-z\d@$!%*?&_]{6,}$')
        .hasMatch(value)) {
      return Texts.passwordInvalidError;
    }
    return null;
  }

  String? _validateRePassword(String? value) {
    if (!_rePasswordTouched) return null;
    if (value == null || value.isEmpty) {
      return Texts.reEnterPasswordEmptyError;
    }
    if (value != _passwordController.text) {
      return Texts.reEnterPasswordInvalidError;
    }
    return null;
  }

  String? _validateID(String? value) {
    if (!_idTouched) return null;
    if (value == null || value.isEmpty) {
      return Texts.idEmptyError;
    }
    if (value.length != 13) {
      return Texts.idLengthError;
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return Texts.idInvalidError;
    }
    if (!_isValidLuhn(value)) {
      return Texts.idInvalidError;
    }
    return null;
  }

  bool _isValidLuhn(String idNumber) {
    int sum = 0;
    bool isDouble = false;
    for (int i = idNumber.length - 1; i >= 0; i--) {
      int digit = int.parse(idNumber[i]);
      if (isDouble) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }
      sum += digit;
      isDouble = !isDouble;
    }
    return sum % 10 == 0;
  }

  int fakeId = 03102406400889;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              // Title
              Text(
                Texts.signUpTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(
                height: TSizes.spaceBtwInputFieds,
              ),
              // Input Fields
              Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  children: [
                    // First Name and Last Name
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _firstNameController,
                            focusNode: _firstNameFocusNode,
                            decoration: const InputDecoration(
                              labelText: Texts.firstName,
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: _validateFirstName,
                          ),
                        ),
                        const SizedBox(
                          width: TSizes.spaceBtwInputFieds,
                        ),
                        Expanded(
                          child: TextFormField(
                            controller: _lastNameController,
                            focusNode: _lastNameFocusNode,
                            decoration: const InputDecoration(
                              labelText: Texts.lastName,
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: _validateLastName,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: TSizes.spaceBtwInputFieds,
                    ),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      decoration: const InputDecoration(
                        labelText: Texts.email,
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: _validateEmail,
                    ),
                    const SizedBox(
                      height: TSizes.spaceBtwInputFieds,
                    ),

                    // Phone Number
                    TextFormField(
                      // initialValue: '0677716689',
                      controller: _phoneNumberController,
                      focusNode: _phoneNumberFocusNode,
                      decoration: const InputDecoration(
                        labelText: Texts.phoneNumber,
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      validator: _validatePhoneNumber,
                    ),
                    const SizedBox(
                      height: TSizes.spaceBtwInputFieds,
                    ),

                    // Password
                    TextFormField(
                      // initialValue: "Password123**",
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      obscureText: !_passwordVisible,
                      decoration: InputDecoration(
                        labelText: Texts.password,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisible ? Iconsax.eye : Iconsax.eye_slash,
                          ),
                          onPressed: _togglePasswordVisibility,
                        ),
                        prefixIcon: const Icon(Iconsax.password_check),
                      ),
                      validator: _validatePassword,
                    ),
                    const SizedBox(
                      height: TSizes.spaceBtwInputFieds,
                    ),

                    // Re-Password
                    TextFormField(
                      controller: _rePasswordController,
                      focusNode: _rePasswordFocusNode,
                      obscureText: !_rePasswordVisible,
                      decoration: InputDecoration(
                        labelText: "Re-enter " + Texts.password,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _rePasswordVisible
                                ? Iconsax.eye
                                : Iconsax.eye_slash,
                          ),
                          onPressed: _toggleRePasswordVisibility,
                        ),
                        prefixIcon: const Icon(Iconsax.password_check),
                      ),
                      validator: _validateRePassword,
                    ),
                    const SizedBox(
                      height: TSizes.spaceBtwInputFieds,
                    ),

                    // ID number
                    TextFormField(
                      controller: _idController,
                      focusNode: _idFocusNode,
                      decoration: const InputDecoration(
                        labelText: Texts.id,
                        prefixIcon: Icon(Iconsax.finger_scan),
                      ),
                      validator: _validateID,
                    ),
                    const SizedBox(
                      height: TSizes.spaceBtwInputFieds * 2,
                    ),

                    // Signup button
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState?.validate() == false) {
                          return;
                        }
                        registerButton();
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 20),
                      ),
                      child: const Text(Texts.CreateAcc),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // SIGN UP

  Future<void> registerPart1() async {
    final client = http.Client();
    showBottomMessage([CircularProgressIndicator()]);

    print("Sending registration request");

    String url = baseUrl + "api/auth/register";
    final uri = Uri.parse(url);
    var body = {
      "email": _emailController.text,
      "phone": _phoneNumberController.text,
      "id": _idController.text,
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
    if (response.statusCode == 200) {
      // show popup to check email
      Navigator.of(context).pop(); // remove loading

      showVerifyEmailBottomSheet();
    } else if (response.statusCode == 409) {
      // user already exists
      Navigator.of(context).pop(); // remove loading
      showBottomMessage([
        Text("User already exists"),
      ]);
    } else {
      // something went wrong, try again later
      Navigator.of(context).pop(); // remove loading
      showBottomMessage([
        Text(
          "Sorry, something went wrong. Please try again later.",
          textAlign: TextAlign.center,
        )
      ]);
    }
  }

  Future<void> registerPart2(String code) async {
    showBottomMessage([CircularProgressIndicator()]);

    String url = baseUrl + "api/auth/register/${code}";
    final uri = Uri.parse(url);
    var body = {
      "firstname": _firstNameController.text,
      "lastname": _lastNameController.text,
      "email": _emailController.text,
      "phone": _phoneNumberController.text,
      "password": _passwordController.text,
      "id": _idController.text,
    };
    final response = await http.post(uri, body: body);

    print(response);
    if (response.statusCode == 201) {
      Navigator.of(context).pop(); // remove loading
      showBottomMessage([
        Text("User successfully created"),
        SizedBox(
          height: 10,
        ),
        ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // remove current
              Navigator.of(context).pop(); // remove code verifier
              Navigator.pushNamed((context), 'loginpage');
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 40, right: 40),
              child: Text("Continue"),
            )),
      ]);
    } else if (response.statusCode == 409) {
      Navigator.of(context).pop(); // remove loading
      showBottomMessage([Text("User already exists")]);
    } else if (response.statusCode == 404) {
      Navigator.of(context).pop(); // remove loading
      showBottomMessage([
        Text(
          "Invalid code, please re-enter",
        )
      ]);
    } else {
      Navigator.of(context).pop(); // remove loading
      showBottomMessage([Text("Sorry, something went wrong")]);
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

  void showVerifyEmailBottomSheet() {
    showPopUp(context, height: 300, widgets: [
      Text("Please enter the code sent to your email"),
      SizedBox(
        height: 20,
      ),
      TextField(
        controller: _codeController,
        decoration: InputDecoration(hintText: "verification code"),
      ),
      SizedBox(
        height: 20,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: verifyCodeButton,
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Text("Verify Code"),
            ),
          ),
          SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Text("Cancel"),
            ),
          ),
        ],
      )
    ]);
    return;
    showModalBottomSheet(
        isDismissible: false,
        context: context,
        builder: (context) {
          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.only(
                  top: 40,
                  left: 60,
                  right: 60,
                  bottom: 100 + MediaQuery.of(context).viewInsets.bottom),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Almost done..."),
                  SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: _codeController,
                    decoration: InputDecoration(
                        hintText: "Enter code sent to your email"),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: verifyCodeButton,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Text("Verify Code"),
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Text("Cancel"),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  //

  Future<void> registerButton() async {
    // Verify passwords match
    if (_passwordController.text != _rePasswordController.text) {
      showBottomMessage([Text("Please enter valid password")]);
      return;
    }

    await registerPart1();
  }

  Future<void> verifyCodeButton() async {
    await registerPart2(_codeController.text);
  }
}
