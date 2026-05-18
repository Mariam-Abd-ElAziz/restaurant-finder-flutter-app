import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:ui' as ui;
import '../models/restaurant.dart';
import '../services/location_service.dart';
import 'directions_screen.dart';

/// Feature 6.3 — Map view of all restaurants/cafes that provide a selected product.
/// Feature 7  — Tap a marker to view distance & directions.
class MapViewScreen extends StatefulWidget {
  final String productName;
  final List<Restaurant> restaurants;

  const MapViewScreen({
    super.key,
    required this.productName,
    required this.restaurants,
  });

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  final MapController _mapController = MapController();

  Position? _currentPosition;
  bool _loadingLocation = true;
  String? _locationError;

  Restaurant? _selectedRestaurant;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    try {
      final position = await LocationService.getCurrentPosition();
      setState(() {
        _currentPosition = position;
        _loadingLocation = false;
      });
      // Center map on user's location
      _mapController.move(
        LatLng(position.latitude, position.longitude),
        13.0,
      );
    } catch (e) {
      setState(() {
        _locationError = e.toString();
        _loadingLocation = false;
      });
    }
  }

  /// Build a pin marker for each restaurant
  List<Marker> _buildRestaurantMarkers() {
    return widget.restaurants.map((restaurant) {
      final isSelected = _selectedRestaurant?.id == restaurant.id;
      return Marker(
        point: LatLng(restaurant.latitude, restaurant.longitude),
        width: 48,
        height: 56,
        child: GestureDetector(
          onTap: () => _onMarkerTapped(restaurant),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: isSelected ? Colors.orange : Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.restaurant,
                  color: Colors.white,
                  size: isSelected ? 22 : 18,
                ),
              ),
              // Triangle pointer
              CustomPaint(
                size: const Size(12, 6),
                painter: _TrianglePainter(
                    isSelected ? Colors.orange : Colors.red),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  /// Build a blue dot for the current user location
  Marker? _buildCurrentLocationMarker() {
    if (_currentPosition == null) return null;
    return Marker(
      point:
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      width: 30,
      height: 30,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.3),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.blue, width: 2),
        ),
        child: const Center(
          child: Icon(Icons.my_location, color: Colors.blue, size: 16),
        ),
      ),
    );
  }

  void _onMarkerTapped(Restaurant restaurant) {
    setState(() => _selectedRestaurant = restaurant);

    // Animate camera to the selected marker
    _mapController.move(
      LatLng(restaurant.latitude, restaurant.longitude),
      15.0,
    );

    // Show bottom sheet with distance + directions button
    _showRestaurantBottomSheet(restaurant);
  }

  void _showRestaurantBottomSheet(Restaurant restaurant) {
    String distanceText = 'Calculating...';
    if (_currentPosition != null) {
      final km = LocationService.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        restaurant.latitude,
        restaurant.longitude,
      );
      distanceText =
          km < 1 ? '${(km * 1000).toStringAsFixed(0)} m away' : '${km.toStringAsFixed(2)} km away';
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.restaurant, color: Colors.red, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          restaurant.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          restaurant.address,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.near_me, color: Colors.blue, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    _currentPosition == null
                        ? 'Location unavailable'
                        : distanceText,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context); // close sheet
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DirectionsScreen(
                          restaurant: restaurant,
                          currentPosition: _currentPosition,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.directions),
                  label: const Text('Get Directions'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ).whenComplete(() {
      // Deselect marker when sheet closes
      setState(() => _selectedRestaurant = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final markers = _buildRestaurantMarkers();
    final myLocationMarker = _buildCurrentLocationMarker();
    if (myLocationMarker != null) markers.add(myLocationMarker);

    // Default center: first restaurant or Cairo fallback
    final defaultCenter = widget.restaurants.isNotEmpty
        ? LatLng(
            widget.restaurants.first.latitude,
            widget.restaurants.first.longitude,
          )
        : const LatLng(30.0444, 31.2357); // Cairo

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Map View', style: TextStyle(fontSize: 16)),
            Text(
              widget.productName,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'My Location',
            icon: const Icon(Icons.my_location),
            onPressed: () {
              if (_currentPosition != null) {
                _mapController.move(
                  LatLng(
                    _currentPosition!.latitude,
                    _currentPosition!.longitude,
                  ),
                  14.0,
                );
              } else {
                _fetchLocation();
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: defaultCenter,
              initialZoom: 12.0,
              onTap: (_, __) => setState(() => _selectedRestaurant = null),
            ),
            children: [
              // OpenStreetMap tile layer (free, no API key needed)
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.restaurant_app',
              ),
              MarkerLayer(markers: markers),
            ],
          ),

          // Loading / error overlay
          if (_loadingLocation)
            Positioned(
              bottom: 20,
              left: 16,
              child: _InfoChip(
                icon: Icons.location_searching,
                label: 'Getting your location...',
                color: Colors.blue,
              ),
            ),
          if (_locationError != null)
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: _InfoChip(
                icon: Icons.location_off,
                label: 'Location unavailable',
                color: Colors.red,
              ),
            ),

          // Restaurant count badge
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.restaurant,
                      color: Colors.red, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.restaurants.length} places',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Helper Widgets ──────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(label,
              style:
                  const TextStyle(color: Colors.white, fontSize: 13)),
        ],
      ),
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