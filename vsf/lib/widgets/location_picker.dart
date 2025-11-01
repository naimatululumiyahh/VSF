import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPicker extends StatefulWidget {
  final LatLng? initialLocation;
  final void Function(LatLng) onLocationPicked;
  
  const LocationPicker({
    super.key, 
    this.initialLocation,
    required this.onLocationPicked,
  });

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
  }

  void _handleMapTap(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
    widget.onLocationPicked(location);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: widget.initialLocation ?? 
              const LatLng(-6.200000, 106.816666), // Jakarta
            zoom: 11,
          ),
          onTap: _handleMapTap,
          markers: _selectedLocation != null ? {
            Marker(
              markerId: const MarkerId('selected_location'),
              position: _selectedLocation!,
            ),
          } : {},
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          zoomControlsEnabled: true,
          mapType: MapType.normal,
        ),
      ),
    );
  }
}