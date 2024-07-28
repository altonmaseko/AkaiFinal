import 'package:akai/secret_contants.dart';
import 'package:akai/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class MapReceiverAcceptPage extends StatefulWidget {
  final accepted;
  final LatLng requesterLocation;
  final String requesterName;
  final String requesterPhoneNumber;
  MapReceiverAcceptPage(
      {super.key,
      required this.accepted,
      required this.requesterLocation,
      required this.requesterName,
      required this.requesterPhoneNumber});

  @override
  State<MapReceiverAcceptPage> createState() => _MapReceiverAcceptPageState();
}

class _MapReceiverAcceptPageState extends State<MapReceiverAcceptPage> {
  final Location _locationController = Location();
  late GoogleMapController _mapController;

  // Google Plex
  static LatLng _initialLocation = LatLng(37.4223, -122.0848);

  // Mountain View
  // static const LatLng _destinationLocation = LatLng(37.3861, -122.0839);

  // Will be the requester location, Initialized the google plex
  LatLng _destinationLocation = LatLng(37.4223, -122.0848);

  LatLng? _currentPosition;
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};

  final double mapHeight = 400;

  @override
  void initState() {
    super.initState();
    _destinationLocation = widget.requesterLocation;
    _initializeMap();
  }

  // This is run once
  Future<void> _initializeMap() async {
    // Get permission to access device location
    await _requestLocationPermission();

    // Get initial location of user when map first loads
    await _fetchInitialLocation();

    // Draws the path
    await _fetchPolyline();

    // Update users location on the map
    // A listener is enabled and keeps on listening
    _startLocationUpdates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Get in touch',
            style: Theme.of(context).textTheme.headlineSmall),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Google map
              Container(
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(20),
                ),
                clipBehavior: Clip.antiAlias,
                height: mapHeight,
                child: _currentPosition == null
                    ? const Center(child: CircularProgressIndicator())
                    : GoogleMap(
                        initialCameraPosition:
                            CameraPosition(target: _initialLocation, zoom: 13),
                        markers: _markers,
                        polylines: _polylines,
                        onMapCreated: (GoogleMapController controller) {
                          _mapController = controller;
                        },
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                      ),
              ),

              /// Go to Whatsapp and Map buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {
                      _launchGoogleMaps();
                    },
                    iconSize: 65,
                    color: TColors.rosePink,
                    icon: Icon(Icons.map_outlined),
                  ),
                  IconButton(
                    onPressed: () {
                      _launchWhatsApp();
                    },
                    iconSize: 65,
                    color: TColors.rosePink,
                    icon: Icon(FontAwesomeIcons.whatsapp),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =====================================================

  Future<void> _requestLocationPermission() async {
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
  }

  Future<void> _fetchInitialLocation() async {
    final locationData = await _locationController.getLocation();
    setState(() {
      _currentPosition =
          LatLng(locationData.latitude!, locationData.longitude!);
      _updateMarkers();

      _initialLocation = _currentPosition!;
    });
  }

  void _startLocationUpdates() {
    _locationController.onLocationChanged.listen((locationData) {
      if (mounted &&
          locationData.latitude != null &&
          locationData.longitude != null) {
        setState(() {
          _currentPosition =
              LatLng(locationData.latitude!, locationData.longitude!);
          _updateMarkers();
        });
      }
    });
  }

  void _updateMarkers() {
    _markers = {
      if (_currentPosition != null)
        Marker(
          markerId: const MarkerId('currentLocation'),
          position: _currentPosition!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
        ),
      Marker(
        markerId: MarkerId('requesterLocation'),
        position: widget.requesterLocation,
        infoWindow: InfoWindow(
          title: widget.requesterName,
          snippet: 'Go here',
          onTap: () {
            // This will be called when the info window is tapped
            print('Info window tapped!');
          },
        ),
      ),
    };
  }

  Future<void> _fetchPolyline() async {
    PolylinePoints polylinePoints = PolylinePoints();

    final result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: googleMapsApiKey,
        request: PolylineRequest(
            origin: PointLatLng(
                _initialLocation.latitude, _initialLocation.longitude),
            destination: PointLatLng(
                _destinationLocation.latitude, _destinationLocation.longitude),
            mode: TravelMode.walking)

        // {
        //   googleMapsApiKey,
        //   PointLatLng(googlePlex.latitude, googlePlex.longitude),
        //   PointLatLng(mountainView.latitude, mountainView.longitude)
        // },
        );

    if (result.points.isNotEmpty) {
      List<LatLng> polylineCoordinates = result.points
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();

      setState(() {
        _polylines.add(Polyline(
          polylineId: const PolylineId('route'),
          color: Colors.blue,
          points: polylineCoordinates,
          width: 3,
        ));
      });
    }
  }

  Future<void> _launchGoogleMaps() async {
    final origin = '${_initialLocation.latitude},${_initialLocation.longitude}';
    final destination =
        '${_destinationLocation.latitude},${_destinationLocation.longitude}';
    final url =
        'https://www.google.com/maps/dir/?api=1&origin=$origin&destination=$destination&travelmode=driving';

    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch Google Maps')),
      );
    }
  }

  // Launch whatsapp
  void _launchWhatsApp() async {
    // FORMAT PHONENUMBER
    String requesterPhoneNumber = widget.requesterPhoneNumber;
    if (widget.requesterPhoneNumber.startsWith('0')) {
      // Replace the first occurrence of '0' with '+27'
      requesterPhoneNumber =
          widget.requesterPhoneNumber.replaceFirst('0', '+27');
    }
    // END: FORMAT PHONENUMBER =========================

    final whatsappUrl = "whatsapp://send?phone=${requesterPhoneNumber}";

    if (await canLaunchUrlString(whatsappUrl)) {
      await launchUrlString(whatsappUrl);
    } else {
      print("Could not open WhatsApp");
    }
  }
}
