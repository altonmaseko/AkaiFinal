// Before keep alive
import 'package:akai/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:akai/secret_contants.dart';

class OldGoogleMapPage extends StatefulWidget {
  const OldGoogleMapPage({Key? key}) : super(key: key);

  @override
  State<OldGoogleMapPage> createState() => _OldGoogleMapPageState();
}

class _OldGoogleMapPageState extends State<OldGoogleMapPage> {
  final Location _locationController = Location();
  late GoogleMapController _mapController;

  // Google Plex
  static LatLng _initialLocation = LatLng(37.4223, -122.0848);

  // Mountain View
  // static const LatLng _destinationLocation = LatLng(37.3861, -122.0839);

  // Gold Reef City
  static const LatLng _destinationLocation = LatLng(-26.2350, 28.0073);

  LatLng? _currentPosition;
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};

  final double mapHeight = 400;

  @override
  void initState() {
    super.initState();
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
        title: Text('Pad Locator',
            style: Theme.of(context).textTheme.headlineSmall),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: TColors.rosePink,
        onPressed: _launchGoogleMaps,
        tooltip: "Open Google Maps",
        child: const Icon(
          Icons.map_outlined,
          size: 30,
          color: Colors.white,
        ),
      ),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.antiAlias,
          margin: const EdgeInsets.all(20),
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
        markerId: MarkerId('sourceLocation'),
        position: _initialLocation,
      ),
      const Marker(
        markerId: MarkerId('destinationLocation'),
        position: _destinationLocation,
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
}
