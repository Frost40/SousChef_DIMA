import 'package:flutter/material.dart';
import '../../screens/address_search_screen.dart';

class AddressField extends StatefulWidget {
  final String? address;
  final bool isEditable;
  final Function(String)? onAddressChanged;
  final Function(String address, double latitude, double longitude)?
  onAddressWithCoordinatesChanged;
  final String emptyMessage;

  const AddressField({
    super.key,
    this.address,
    this.isEditable = false,
    this.onAddressChanged,
    this.onAddressWithCoordinatesChanged,
    this.emptyMessage = 'No current address',
  });

  @override
  State<AddressField> createState() => _AddressFieldState();
}

class _AddressFieldState extends State<AddressField> {
  late String _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.address ?? '';
  }

  @override
  void didUpdateWidget(AddressField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.address != oldWidget.address &&
        widget.address != _currentValue) {
      _currentValue = widget.address ?? '';
    }
  }

  /// Estrae la parte dell'indirizzo prima della seconda virgola
  String _extractAddressBeforeSecondComma(String address) {
    final parts = address.split(',');
    if (parts.length >= 2) {
      return '${parts[0]}, ${parts[1]}';
    }
    return address;
  }

  /// Naviga alla schermata di ricerca indirizzo
  Future<void> _navigateToAddressSearch() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (context) => const AddressSearchScreen(isForRestaurant: true),
      ),
    );

    // Se è stato selezionato un indirizzo, aggiorna il valore
    if (result != null && result['address'] != null) {
      final address = result['address'] as String;
      final latitude = result['latitude'] as double;
      final longitude = result['longitude'] as double;

      setState(() {
        _currentValue = address;
      });

      // Notifica il parent del cambiamento con le coordinate
      if (widget.onAddressWithCoordinatesChanged != null) {
        widget.onAddressWithCoordinatesChanged!(address, latitude, longitude);
      } else if (widget.onAddressChanged != null) {
        // Fallback al vecchio callback se non c'è quello con coordinate
        widget.onAddressChanged!(address);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final displayText =
        _currentValue.isNotEmpty
            ? _extractAddressBeforeSecondComma(_currentValue)
            : widget.emptyMessage;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 40),
          decoration: BoxDecoration(
            border: Border.all(
              color: colorScheme.surfaceContainerHighest,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(25.0),
          ),
          child: MouseRegion(
            cursor:
                widget.isEditable
                    ? SystemMouseCursors.click
                    : SystemMouseCursors.basic,
            child: GestureDetector(
              onTap: widget.isEditable ? _navigateToAddressSearch : null,
              behavior: HitTestBehavior.opaque,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      displayText,
                      style: TextStyle(
                        fontSize: 16,
                        color:
                            _currentValue.isNotEmpty
                                ? colorScheme.onSurface
                                : colorScheme.surfaceContainerHighest,
                        fontStyle:
                            _currentValue.isNotEmpty
                                ? FontStyle.normal
                                : FontStyle.italic,
                      ),
                      softWrap: true,
                    ),
                  ),
                  if (widget.isEditable) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.edit, size: 16, color: colorScheme.primary),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
