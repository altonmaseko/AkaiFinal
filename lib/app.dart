import 'dart:convert';
import 'dart:io';

import 'package:akai/screens/akai_chat.dart';
import 'package:akai/screens/map_receiver.dart';
import 'package:akai/screens/map_receiver_accept_page.dart';
import 'package:akai/screens/map_start_page.dart';
import 'package:akai/screens/no_internet.dart';
import 'package:akai/screens/old_map_page.dart';
import 'package:akai/screens/requester_next_page.dart';
import 'package:akai/screens/signup.dart';
import 'package:akai/secret_contants.dart';
import 'package:akai/utils/constants/colors.dart';
import 'package:akai/utils/global_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:iconsax/iconsax.dart';
import 'package:location/location.dart';
import 'utils/theme/theme.dart';
import 'screens/login.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'screens/calendar.dart';
import 'screens/links.dart';
import 'screens/profile.dart';
import 'screens/tester.dart';
import 'screens/maps_page.dart';
import 'package:http/http.dart' as http;

final navigatorKey = GlobalKey<NavigatorState>();

final _myBox = Hive.box('myBox');

final secureStorage = FlutterSecureStorage();

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  Key _appKey = UniqueKey();

  void rebuildApp() {
    setState(() {
      _appKey = UniqueKey();
    });
    Navigator.of(context).pushNamedAndRemoveUntil('app', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      key: _appKey,
      routes: {
        'loginpage': (context) => const Login(),
        'signuppage': (context) => const SignupScreen(),
        'calendarpage': (context) => const Calendar(),
        'mapspage': (context) => MapStartPage(),
        'oldmapspage': (context) => const OldGoogleMapPage(),
        'app': (context) => MyHomePage(),
        'mapreceiver': (context) => MapReceiverPage(),
        'requesternextpage': (context) => RequesterNextPage(),
        'chatpage': (context) => Chat()
      },
      navigatorKey: navigatorKey,
      themeMode: ThemeMode.system,
      theme: TAppTheme.lightTheme,
      darkTheme: TAppTheme.darkTheme,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  // const MyHomePage({super.key, required this.onSignOut});
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// def to index 1 (Calendar)

// selectedIndex IS MOVED TO another class

class _MyHomePageState extends State<MyHomePage> {
  final List<Widget> _pages = [
    MapStartPage(),
    Calendar(),
    HelpfulLinks(),
    Login(),
  ];

  Future<void> setPages() async {
    final token = await secureStorage.read(key: 'token');

    final isConnected = await hasInternet();
    setState(() {
      if (!isConnected) {
        // no internet
        _pages[0] = NoInternet(title: 'Pad System');
        _pages[3] = NoInternet(title: 'Get Started');
        return;
      } else {
        // has internet
        _pages[0] = MapStartPage();
        _pages[3] = token == null ? Login() : Profile();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  bool _isInitialized = false;

  Future<void> _initializeApp() async {
    try {
      debugPrint("app.dart InitState");

      await setPages();
      print("SET PAGES DONE");

      await checkInternet(context, setState);
      print("CHECK INTERNET DONE");

      await _fetchInitialLocationAndSend();
      print("FETCH INITIAL LOCATION DONE");
    } catch (e) {
      debugPrint("ERROR DURING INITIALIZATION");
    }
    setState(() {
      _isInitialized = true;
    }); // Trigger a rebuild after initialization
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: _pages[selectedIndex], // Display the selected page
      bottomNavigationBar: CurvedNavigationBar(
        items: const [
          //Locator
          Icon(
            Iconsax.location,
            size: 30,
            color: Colors.white,
          ),

          //Calendar
          Icon(
            Iconsax.calendar,
            size: 30,
            color: Colors.white,
          ),

          //Helpful Links
          Icon(
            Iconsax.link,
            size: 30,
            color: Colors.white,
          ),

          //Profile
          Icon(
            Iconsax.profile_circle,
            size: 30,
            color: Colors.white,
          ),
        ],
        index: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        animationDuration: const Duration(milliseconds: 300),
        backgroundColor: Colors.transparent,
        color: TColors.rosePink,
      ),
    );
  }

  Future<void> _fetchInitialLocationAndSend() async {
    final secureStorage = FlutterSecureStorage();
    final token = await secureStorage.read(key: 'token');

    if (token == null) return; // not logged in

    final Location _locationController = Location();

    // Request location permission
    bool serviceEnabled = await _locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationController.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted =
        await _locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    // Get the current location
    final locationData = await _locationController.getLocation();

    // Store in hive
    _myBox.put('location', [locationData.longitude, locationData.latitude]);
    _myBox.put('longitude', locationData.longitude);
    _myBox.put('latitude', locationData.latitude);
    // var retrievedDoubleList = _myBox.get('location') as List<double>; // how to retreive

    if (locationData.latitude != null && locationData.longitude != null) {
      // Send request to server with current location
      await _sendLocationAndFcmToServer(
          locationData.longitude!, locationData.latitude!);
    }
  }

  Future<void> _sendLocationAndFcmToServer(
      double longitude, double latitude) async {
    String url = baseUrl + "api/notifications/sendlocationfcmdata";
    final uri = Uri.parse(url);

    final headers = {
      'Content-Type': 'application/json',
      'Authorization':
          'Bearer ${await secureStorage.read(key: 'token')}', // Include the Bearer token here
    };

    var body = {
      "location": [longitude, latitude],
      "FCMToken": _myBox.get('fcm')
    };

    // Send the POST request with the headers and body
    print("reached try block");
    try {
      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );
      print("Status code from fcm location: ${response.statusCode}");
      print('response body: ${response.body}');
    } catch (e) {
      print("something went wrong when sending location and fcm");
    }
  }
}
