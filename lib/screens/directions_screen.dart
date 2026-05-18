import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../models/restaurant.dart';
import '../services/location_service.dart';

class DirectionsScreen extends StatefulWidget {
  final Restaurant restaurant;
  final Position? currentPosition;

  const DirectionsScreen({
    super.key,
    required this.restaurant,
    this.currentPosition,
  });

  @override
  State<DirectionsScreen> createState() => _DirectionsScreenState();
}

class _DirectionsScreenState extends State<DirectionsScreen> {
  final MapController _mapController = MapController();

  Position? _position;
  List<LatLng> _routePoints = [];
  bool _loadingRoute = true;
  String? _error;

  double? _distanceKm;
  String? _durationText;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final pos = widget.currentPosition ??
          await LocationService.getCurrentPosition();
          print("LOCATION: ${pos.latitude}, ${pos.longitude}"); // ADD THIS


      setState(() => _position = pos);

      _distanceKm = LocationService.distanceBetween(
        pos.latitude,
        pos.longitude,
        widget.restaurant.latitude,
        widget.restaurant.longitude,
      );
      print("RESTAURANT COORDS: ${widget.restaurant.latitude}, ${widget.restaurant.longitude}");

      await _fetchRoute(pos);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loadingRoute = false;
      });
    }
  }

  Future<void> _fetchRoute(Position from) async {
      print("FETCHING ROUTE FROM: ${from.latitude},${from.longitude} TO: ${widget.restaurant.latitude},${widget.restaurant.longitude}"); // ADD THIS

    final url =
        'https://router.project-osrm.org/route/v1/driving/'
        '${from.longitude},${from.latitude};'
        '${widget.restaurant.longitude},${widget.restaurant.latitude}'
        '?overview=full&geometries=geojson';

    try {
      final response = await http.get(Uri.parse(url));

      print("OSRM RESPONSE: ${response.body}");

      if (response.statusCode != 200) {
        _fallback(from);
        return;
      }

      final data = json.decode(response.body);

      if (data['routes'] == null || data['routes'].isEmpty) {
        _fallback(from);
        return;
      }

      final route = data['routes'][0];

      final meters = (route['distance'] as num).toDouble();
      final seconds = (route['duration'] as num).toInt();

      _distanceKm = meters / 1000;
      _durationText = seconds < 3600
          ? '${(seconds / 60).ceil()} min'
          : '${(seconds / 3600).toStringAsFixed(1)} hr';

      final coords = route['geometry']['coordinates'] as List;

      final points = coords.map<LatLng>((c) {
        return LatLng(
          (c[1] as num).toDouble(),
          (c[0] as num).toDouble(),
        );
      }).toList();

      setState(() {
        _routePoints = points;
        _loadingRoute = false;
      });

      print("ROUTE POINTS COUNT: ${_routePoints.length}");

      _fitMap(from);
    } catch (e) {
      print("ROUTE ERROR: $e");
      _fallback(from);
    }
  }

  void _fallback(Position from) {
    setState(() {
      _routePoints = [
        LatLng(from.latitude, from.longitude),
        LatLng(widget.restaurant.latitude, widget.restaurant.longitude),
      ];
      _durationText = "N/A";
      _loadingRoute = false;
    });

    _fitMap(from);
  }

  void _fitMap(Position from) {
    final bounds = LatLngBounds.fromPoints([
      LatLng(from.latitude, from.longitude),
      LatLng(widget.restaurant.latitude, widget.restaurant.longitude),
    ]);

    Future.delayed(const Duration(milliseconds: 300), () {
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(60),
        ),
      );
    });
  }

  Future<void> _openGoogleMaps() async {
    if (_position == null) return;

    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&origin=${_position!.latitude},${_position!.longitude}'
      '&destination=${widget.restaurant.latitude},${widget.restaurant.longitude}'
      '&travelmode=driving',
    );

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final destination = LatLng(
      widget.restaurant.latitude,
      widget.restaurant.longitude,
    );

    final markers = <Marker>[
      Marker(
        point: destination,
        width: 50,
        height: 60,
        child: const Icon(Icons.restaurant, color: Colors.red, size: 30),
      ),
    ];

    if (_position != null) {
      markers.add(
        Marker(
          point: LatLng(_position!.latitude, _position!.longitude),
          width: 40,
          height: 40,
          child: const Icon(Icons.my_location, color: Colors.blue),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.restaurant.name),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Row(
              children: [
                Text(
                  _distanceKm == null
                      ? "..."
                      : "${_distanceKm!.toStringAsFixed(2)} km",
                ),
                const Spacer(),
                Text(_durationText ?? "..."),
                const Spacer(),
                ElevatedButton(
                  onPressed: _openGoogleMaps,
                  child: const Text("Navigate"),
                ),
              ],
            ),
          ),

          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: destination,
                    initialZoom: 13,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                      userAgentPackageName: "app",
                      tileProvider:
                          CancellableNetworkTileProvider(),
                    ),

                    if (_routePoints.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _routePoints,
                            strokeWidth: 8,
                            color: Colors.red,
                          ),
                        ],
                      ),

                    MarkerLayer(markers: markers),
                  ],
                ),

                if (_loadingRoute)
                  const Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 10),
                            Text("Loading route..."),
                          ],
                        ),
                      ),
                    ),
                  ),

                if (_error != null)
                  Center(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}