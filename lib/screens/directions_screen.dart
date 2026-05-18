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

/// Feature 7 — Shows distance and directions between the user's location
/// and the selected restaurant/café on an interactive map with a route polyline.
class DirectionsScreen extends StatefulWidget {
  final Restaurant restaurant;
  final Position? currentPosition; // may already be available from MapViewScreen

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
    _initialize();
  }

  Future<void> _initialize() async {
    // Use already-fetched position or get a fresh one
    Position pos;
    if (widget.currentPosition != null) {
      pos = widget.currentPosition!;
    } else {
      try {
        pos = await LocationService.getCurrentPosition();
      } catch (e) {
        setState(() {
          _error = e.toString();
          _loadingRoute = false;
        });
        return;
      }
    }

    setState(() => _position = pos);

    // Calculate straight-line distance
    _distanceKm = LocationService.distanceBetween(
      pos.latitude,
      pos.longitude,
      widget.restaurant.latitude,
      widget.restaurant.longitude,
    );

    // Fetch route from OSRM (free, no API key required)
    await _fetchRoute(pos);
  }

  /// Fetches a driving route using the free OSRM public API.
  Future<void> _fetchRoute(Position from) async {
    final url =
        'https://router.project-osrm.org/route/v1/driving/'
        '${from.longitude},${from.latitude};'
        '${widget.restaurant.longitude},${widget.restaurant.latitude}'
        '?overview=full&geometries=geojson';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final route = data['routes'][0];

        // Extract duration
        final seconds = (route['duration'] as num).toInt();
        final minutes = (seconds / 60).ceil();
        _durationText = minutes < 60
            ? '$minutes min'
            : '${(minutes / 60).toStringAsFixed(1)} hr';

        // Use OSRM's reported distance if available
        final meters = (route['distance'] as num).toDouble();
        _distanceKm = meters / 1000;

        // Decode GeoJSON coordinates → LatLng list
        final coords = route['geometry']['coordinates'] as List;
        final points =
            coords.map((c) => LatLng(c[1] as double, c[0] as double)).toList();

        setState(() {
          _routePoints = points;
          _loadingRoute = false;
        });

        // Fit the map to show both endpoints
        _fitBounds(from);
      } else {
        _fallbackToStraightLine(from);
      }
    } catch (_) {
      _fallbackToStraightLine(from);
    }
  }

  /// If the OSRM request fails, draw a straight line as fallback.
  void _fallbackToStraightLine(Position from) {
    setState(() {
      _routePoints = [
        LatLng(from.latitude, from.longitude),
        LatLng(widget.restaurant.latitude, widget.restaurant.longitude),
      ];
      _durationText = 'N/A';
      _loadingRoute = false;
    });
    _fitBounds(from);
  }

  void _fitBounds(Position from) {
    final bounds = LatLngBounds(
      LatLng(from.latitude, from.longitude),
      LatLng(widget.restaurant.latitude, widget.restaurant.longitude),
    );
    // Move camera to show both points with padding
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(60),
        ),
      );
    });
  }

  /// Opens the route in Google Maps (or any installed map app).
  Future<void> _openInGoogleMaps() async {
    if (_position == null) return;
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&origin=${_position!.latitude},${_position!.longitude}'
      '&destination=${widget.restaurant.latitude},${widget.restaurant.longitude}'
      '&travelmode=driving',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Maps app.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final restaurantLatLng = LatLng(
      widget.restaurant.latitude,
      widget.restaurant.longitude,
    );

    final markers = <Marker>[
      // Destination marker (restaurant)
      Marker(
        point: restaurantLatLng,
        width: 50,
        height: 60,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))
                ],
              ),
              padding: const EdgeInsets.all(8),
              child:
                  const Icon(Icons.restaurant, color: Colors.white, size: 20),
            ),
            CustomPaint(
              size: const Size(12, 6),
              painter: _TrianglePainter(Colors.red),
            ),
          ],
        ),
      ),
    ];

    // Current location marker
    if (_position != null) {
      markers.add(
        Marker(
          point: LatLng(_position!.latitude, _position!.longitude),
          width: 36,
          height: 36,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.25),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blue, width: 2.5),
            ),
            child: const Icon(Icons.person_pin_circle,
                color: Colors.blue, size: 20),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.restaurant.name,
            style: const TextStyle(fontSize: 16)),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // ── Info Card ──────────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _StatTile(
                  icon: Icons.route,
                  label: 'Distance',
                  value: _distanceKm == null
                      ? '...'
                      : _distanceKm! < 1
                          ? '${(_distanceKm! * 1000).toStringAsFixed(0)} m'
                          : '${_distanceKm!.toStringAsFixed(2)} km',
                  color: Colors.blue,
                ),
                const SizedBox(width: 12),
                _StatTile(
                  icon: Icons.access_time,
                  label: 'Est. Drive',
                  value: _durationText ?? (_loadingRoute ? '...' : 'N/A'),
                  color: Colors.orange,
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _position == null ? null : _openInGoogleMaps,
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: const Text('Navigate'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // ── Map ────────────────────────────────────────────────────────
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: restaurantLatLng,
                    initialZoom: 13.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.restaurant_app',
                      tileProvider: CancellableNetworkTileProvider(),
                    ),
                    // Route polyline
                    if (_routePoints.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _routePoints,
                            strokeWidth: 5,
                            color: Colors.blue.withOpacity(0.8),
                            borderStrokeWidth: 2,
                            borderColor: Colors.white.withOpacity(0.5),
                          ),
                        ],
                      ),
                    MarkerLayer(markers: markers),
                  ],
                ),

                // Loading spinner overlay
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
                            Text('Finding route...'),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Error overlay
                if (_error != null)
                  Center(
                    child: Card(
                      color: Colors.red[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_off,
                                color: Colors.red, size: 32),
                            const SizedBox(height: 8),
                            Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // "My Location" FAB
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.white,
                    onPressed: () {
                      if (_position != null) {
                        _mapController.move(
                          LatLng(_position!.latitude, _position!.longitude),
                          15.0,
                        );
                      }
                    },
                    child: const Icon(Icons.my_location, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),

          // ── Address Footer ─────────────────────────────────────────────
          Container(
            width: double.infinity,
            color: Colors.grey[100],
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.location_on,
                    color: Colors.red, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.restaurant.address,
                    style: TextStyle(
                        color: Colors.grey[700], fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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

// ─── Helper Widgets ──────────────────────────────────────────────────────────

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TrianglePainter old) => old.color != color;
}