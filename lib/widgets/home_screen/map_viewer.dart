import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import '../../models/restaurant.dart';

/// Widget che mostra una mappa di Google Maps a schermo intero
/// Centrata su Milano per default
class MapViewer extends StatefulWidget {
  final double latitude;
  final double longitude;
  final double zoom;
  final String? markerTitle;
  final List<Restaurant>? nearbyRestaurants;

  const MapViewer({
    super.key,
    this.latitude = 45.4642, // Milano coordinates
    this.longitude = 9.1900,
    this.zoom = 12.0,
    this.markerTitle,
    this.nearbyRestaurants,
  });

  @override
  State<MapViewer> createState() => _MapViewerState();
}

class _MapViewerState extends State<MapViewer> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  BitmapDescriptor? _orangeMarkerIcon;

  @override
  void initState() {
    super.initState();
    _initializeMarkers();
  }

  /// Crea un marker personalizzato arancione
  Future<BitmapDescriptor> _createOrangeMarkerIcon() async {
    if (_orangeMarkerIcon != null) return _orangeMarkerIcon!;

    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint =
        Paint()..color = const Color(0xFFFF9800); // Arancione vivido

    // Disegna un cerchio
    canvas.drawCircle(const Offset(50, 50), 40, paint);

    // Disegna il contorno
    final Paint borderPaint =
        Paint()
          ..color = const Color(0xFFE65100) // Arancione scuro
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;
    canvas.drawCircle(const Offset(50, 50), 40, borderPaint);

    // Disegna un triangolo in basso (punta del marker)
    final Path path = Path();
    path.moveTo(30, 85);
    path.lineTo(50, 110);
    path.lineTo(70, 85);
    path.close();
    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);

    final ui.Image image = await pictureRecorder.endRecording().toImage(
      100,
      120,
    );
    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );

    _orangeMarkerIcon = BitmapDescriptor.fromBytes(
      byteData!.buffer.asUint8List(),
    );
    return _orangeMarkerIcon!;
  }

  void _initializeMarkers() async {
    Set<Marker> markers = {};

    // Add user location marker if title is provided
    if (widget.markerTitle != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: LatLng(widget.latitude, widget.longitude),
          infoWindow: InfoWindow(title: widget.markerTitle),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }

    // Add restaurant markers
    if (widget.nearbyRestaurants != null) {
      final orangeIcon = await _createOrangeMarkerIcon();
      for (var restaurant in widget.nearbyRestaurants!) {
        markers.add(
          Marker(
            markerId: MarkerId(restaurant.id),
            position: LatLng(
              restaurant.location.latitude,
              restaurant.location.longitude,
            ),
            infoWindow: InfoWindow(
              title: restaurant.name,
              snippet: restaurant.address,
            ),
            icon: orangeIcon,
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _markers = markers;
      });
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
        title: Text(
          widget.nearbyRestaurants != null &&
                  widget.nearbyRestaurants!.isNotEmpty
              ? 'Mappa - ${widget.nearbyRestaurants!.length} ristoranti'
              : 'Mappa',
        ),
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
