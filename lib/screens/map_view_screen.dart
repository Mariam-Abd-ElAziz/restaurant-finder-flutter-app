import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import '../models/restaurant.dart';
import '../services/location_service.dart';
import '../theme/app_colors.dart';
import 'directions_screen.dart';

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
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      final pos = await LocationService.getCurrentPosition();
      setState(() {
        _currentPosition = pos;
        _loadingLocation = false;
      });
      _moveTo(pos.latitude, pos.longitude);
    } catch (e) {
      setState(() {
        _locationError = e.toString();
        _loadingLocation = false;
      });
      // fallback to first valid restaurant
      _focusFirstRestaurant();
    }
  }

  void _focusFirstRestaurant() {
    final valid = widget.restaurants
        .where((r) => r.hasValidLocation)
        .toList();
    if (valid.isNotEmpty) {
      _moveTo(valid.first.latitude, valid.first.longitude);
    }
  }

  void _moveTo(double lat, double lng, {double zoom = 13}) {
    try {
      _mapController.move(LatLng(lat, lng), zoom);
    } catch (_) {}
  }

  List<Marker> _buildMarkers() {
    final markers = <Marker>[];

    // Restaurant markers
    for (final r in widget.restaurants) {
      if (!r.hasValidLocation) continue;

      final isSelected = _selectedRestaurant?.id == r.id;

      markers.add(
        Marker(
          point: LatLng(r.latitude, r.longitude),
          width: 50,
          height: 50,
          child: GestureDetector(
            onTap: () => _onTapRestaurant(r),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    r.name,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.location_pin,
                  size: isSelected ? 32 : 26,
                  color: isSelected
                      ? AppColors.primary
                      : Colors.red,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // User location marker
    if (_currentPosition != null) {
      markers.add(
        Marker(
          point: LatLng(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
          ),
          width: 44,
          height: 44,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blue, width: 2),
            ),
            child: const Icon(
              Icons.my_location,
              color: Colors.blue,
              size: 22,
            ),
          ),
        ),
      );
    }

    return markers;
  }

  void _onTapRestaurant(Restaurant r) {
    setState(() => _selectedRestaurant = r);
    _moveTo(r.latitude, r.longitude, zoom: 15);
    _showBottomSheet(r);
  }

  void _showBottomSheet(Restaurant r) {
    double? distance;
    if (_currentPosition != null) {
      distance = LocationService.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        r.latitude,
        r.longitude,
      );
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0D9CF),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // name
            Text(
              r.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),

            // address
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 14, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    r.address,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // distance
            if (distance != null)
              Row(
                children: [
                  const Icon(Icons.directions_walk,
                      size: 14, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text(
                    distance < 1
                        ? '${(distance * 1000).toStringAsFixed(0)} m away'
                        : '${distance.toStringAsFixed(2)} km away',
                    style: const TextStyle(
                        fontSize: 13, color: Colors.blue),
                  ),
                ],
              ),

            const SizedBox(height: 16),

            // button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DirectionsScreen(
                        restaurant: r,
                        currentPosition: _currentPosition,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.directions_rounded, size: 18),
                label: const Text('Get Directions'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ).whenComplete(() {
      if (mounted) setState(() => _selectedRestaurant = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final validRestaurants =
        widget.restaurants.where((r) => r.hasValidLocation).toList();

    final center = _currentPosition != null
        ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
        : validRestaurants.isNotEmpty
            ? LatLng(validRestaurants.first.latitude,
                validRestaurants.first.longitude)
            : const LatLng(30.0444, 31.2357); // fallback Cairo

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 12,
              onTap: (_, __) {
                if (_selectedRestaurant != null) {
                  setState(() => _selectedRestaurant = null);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.restaurant_app',
              ),
              MarkerLayer(markers: _buildMarkers()),
            ],
          ),

          // loading chip
          if (_loadingLocation)
            const Positioned(
              bottom: 20,
              left: 20,
              child: Chip(
                label: Text('Getting location…'),
                avatar: SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),

          // error chip
          if (_locationError != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Chip(
                label: Text(
                  'Location unavailable — showing all restaurants',
                  style: const TextStyle(fontSize: 12),
                ),
                backgroundColor: Colors.orange.shade100,
              ),
            ),

          // my location FAB
          if (_currentPosition != null)
            Positioned(
              bottom: 24,
              right: 16,
              child: FloatingActionButton.small(
                onPressed: () => _moveTo(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                  zoom: 15,
                ),
                backgroundColor: Colors.white,
                child: const Icon(Icons.my_location,
                    color: Colors.blue),
              ),
            ),
        ],
      ),
    );
  }
}