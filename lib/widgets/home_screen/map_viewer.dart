import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import '../../models/restaurant.dart';
import 'restaurant_list_tile.dart';

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
  Restaurant? _selectedRestaurant;

  @override
  void initState() {
    super.initState();
    _initializeMarkers();
  }

  @override
  void didUpdateWidget(MapViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Se la lista dei ristoranti è cambiata, reinizializza i marker
    if (oldWidget.nearbyRestaurants != widget.nearbyRestaurants) {
      _initializeMarkers();
    }
    // Se la posizione dell'utente è cambiata, anima la mappa alla nuova posizione
    if (oldWidget.latitude != widget.latitude ||
        oldWidget.longitude != widget.longitude) {
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(widget.latitude, widget.longitude),
              zoom: widget.zoom,
            ),
          ),
        );
      }
    }
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
            onTap: () {
              setState(() {
                _selectedRestaurant = restaurant;
              });
            },
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
    final restaurantCount = widget.nearbyRestaurants?.length ?? 0;
    final restaurantText = restaurantCount == 1 ? 'restaurant' : 'restaurants';

    return Scaffold(
      appBar: AppBar(
        title: Text('$restaurantCount $restaurantText found'),
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
      body: Stack(
        children: [
          // Mappa
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(widget.latitude, widget.longitude),
              zoom: widget.zoom,
            ),
            markers: _markers,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            onTap: (_) {
              // Chiudi la tile quando si clicca sulla mappa
              setState(() {
                _selectedRestaurant = null;
              });
            },
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
            mapToolbarEnabled: false,
            compassEnabled: true,
            buildingsEnabled: true,
          ),

          // Restaurant tile nella parte inferiore
          if (_selectedRestaurant != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Barra per chiudere
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                    // Restaurant tile
                    RestaurantListTile(restaurant: _selectedRestaurant!),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
        ],
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
