import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Widget che mostra una mappa di Google Maps a schermo intero
/// Centrata su Milano per default
class MapViewer extends StatefulWidget {
  final double latitude;
  final double longitude;
  final double zoom;
  final String? markerTitle;

  const MapViewer({
    super.key,
    this.latitude = 45.4642, // Milano coordinates
    this.longitude = 9.1900,
    this.zoom = 12.0,
    this.markerTitle,
  });

  @override
  State<MapViewer> createState() => _MapViewerState();
}

class _MapViewerState extends State<MapViewer> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _initializeMarker();
  }

  void _initializeMarker() {
    if (widget.markerTitle != null) {
      _markers = {
        Marker(
          markerId: const MarkerId('center'),
          position: LatLng(widget.latitude, widget.longitude),
          infoWindow: InfoWindow(title: widget.markerTitle),
        ),
      };
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mappa'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Bottone per centrare la mappa su Milano
          IconButton(
            icon: const Icon(Icons.my_location),
            tooltip: 'Centra su Milano',
            onPressed: _centerOnMilan,
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.latitude, widget.longitude),
          zoom: widget.zoom,
        ),
        markers: _markers,
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
        myLocationButtonEnabled: false,
        zoomControlsEnabled: true,
        mapToolbarEnabled: false,
        compassEnabled: true,
        buildingsEnabled: true,
      ),
    );
  }

  /// Centra la mappa su Milano
  void _centerOnMilan() {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(widget.latitude, widget.longitude),
          zoom: widget.zoom,
        ),
      ),
    );
  }
}
