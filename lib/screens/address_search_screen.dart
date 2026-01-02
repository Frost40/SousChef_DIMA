import 'package:flutter/material.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:provider/provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../providers/user_provider.dart';
import '../widgets/custom_alert_dialog.dart';
import '../services/orientation_manager.dart';

enum LayoutType { mobile, tabletVertical, tabletHorizontal }

/// Schermata di ricerca indirizzo con Google Places Autocomplete
/// Permette all'utente di cercare e selezionare un indirizzo
class AddressSearchScreen extends StatefulWidget {
  final bool isForRestaurant;

  const AddressSearchScreen({super.key, this.isForRestaurant = false});

  @override
  State<AddressSearchScreen> createState() => _AddressSearchScreenState();
}

class _AddressSearchScreenState extends State<AddressSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Focus automatico sulla barra di ricerca
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  LayoutType _getLayoutType(BuildContext context) {
    final orientationManager = OrientationManager();
    final isTablet = orientationManager.isTablet(context);
    if (!isTablet) return LayoutType.mobile;

    final orientation = MediaQuery.of(context).orientation;
    return orientation == Orientation.portrait
        ? LayoutType.tabletVertical
        : LayoutType.tabletHorizontal;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final layoutType = _getLayoutType(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Search for address',
          style: TextStyle(color: colorScheme.onSurface),
        ),
      ),
      body:
          layoutType == LayoutType.tabletHorizontal
              ? Align(
                alignment: Alignment.topCenter,
                child: SizedBox(width: 900, child: _buildContent(colorScheme)),
              )
              : _buildContent(colorScheme),
    );
  }

  Widget _buildContent(ColorScheme colorScheme) {
    return Column(
      children: [
        // Barra di ricerca
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: GooglePlaceAutoCompleteTextField(
            textEditingController: _searchController,
            googleAPIKey: dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '',
            inputDecoration: InputDecoration(
              hintText: 'Enter your address...',
              hintStyle: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.4),
              ),
              prefixIcon: Icon(Icons.search, color: colorScheme.primary),
              suffixIcon:
                  _searchController.text.isNotEmpty
                      ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                      : null,
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colorScheme.outline.withOpacity(0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
            ),
            focusNode: _searchFocusNode,
            debounceTime: 600,
            countries: const ["it"], // Solo indirizzi italiani
            isLatLngRequired: true,
            getPlaceDetailWithLatLng: (Prediction prediction) async {
              // Questo callback viene chiamato quando l'utente seleziona un indirizzo
              await _onAddressSelected(prediction);
            },
            itemClick: (Prediction prediction) {
              _searchController.text = prediction.description ?? '';
              _searchController.selection = TextSelection.fromPosition(
                TextPosition(offset: _searchController.text.length),
              );
            },
            itemBuilder: (context, index, Prediction prediction) {
              return _buildSuggestionItem(prediction);
            },
            seperatedBuilder: Divider(
              height: 1,
              color: colorScheme.outline.withOpacity(0.1),
            ),
            isCrossBtnShown: false,
          ),
        ),

        // Loading indicator
        if (_isLoading)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LoadingAnimationWidget.staggeredDotsWave(
                    color: colorScheme.primary,
                    size: 50,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Saving address...',
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          // Placeholder quando non ci sono risultati
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 64,
                    color: colorScheme.onSurface.withOpacity(0.2),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Start typing to search',
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.4),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  /// Widget per ogni suggerimento nella lista
  Widget _buildSuggestionItem(Prediction prediction) {
    if (!mounted) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(
            Icons.location_on_outlined,
            color: colorScheme.onSurface.withOpacity(0.6),
            size: 22,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prediction.structuredFormatting?.mainText ??
                      prediction.description ??
                      '',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
                if (prediction.structuredFormatting?.secondaryText != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    prediction.structuredFormatting!.secondaryText!,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: colorScheme.onSurface.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  /// Chiamato quando l'utente seleziona un indirizzo
  Future<void> _onAddressSelected(Prediction prediction) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final address = prediction.description ?? '';
      final lat = double.tryParse(prediction.lat ?? '0.0') ?? 0.0;
      final lng = double.tryParse(prediction.lng ?? '0.0') ?? 0.0;

      if (address.isEmpty) {
        throw Exception('Indirizzo non valido');
      }

      // Se è per il ristorante, ritorna indirizzo e coordinate
      if (widget.isForRestaurant) {
        if (lat == 0.0 || lng == 0.0) {
          throw Exception('Coordinate non valide');
        }

        if (mounted) {
          // Ritorna un Map con indirizzo e coordinate
          Navigator.pop(context, {
            'address': address,
            'latitude': lat,
            'longitude': lng,
          });
        }
        return;
      }

      // Altrimenti salva nel profilo utente
      if (lat == 0.0 || lng == 0.0) {
        throw Exception('Coordinate non valide');
      }

      // Salva l'indirizzo nel profilo utente
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.updateUserAddress(
        address: address,
        latitude: lat,
        longitude: lng,
      );

      if (mounted) {
        // Nascondi il loading
        setState(() {
          _isLoading = false;
        });

        // Mostra messaggio di successo
        await CustomAlertDialog.showInfoDialog(
          context: context,
          title: 'Address Saved',
          message: 'Your address has been saved successfully',
          buttonText: 'OK',
        );

        // Torna indietro alla home page dopo che l'utente ha premuto OK
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
