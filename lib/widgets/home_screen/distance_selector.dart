import 'package:flutter/material.dart';

/// Widget per selezionare il raggio massimo di distanza in km
/// L'utente può aumentare o diminuire la distanza con i pulsanti freccia
class DistanceSelector extends StatefulWidget {
  final ValueChanged<int> onDistanceChanged;
  final int initialDistance;

  const DistanceSelector({
    super.key,
    this.initialDistance = 3,
    required this.onDistanceChanged,
  });

  @override
  State<DistanceSelector> createState() => _DistanceSelectorState();
}

class _DistanceSelectorState extends State<DistanceSelector> {
  late int _distance;

  @override
  void initState() {
    super.initState();
    _distance = widget.initialDistance;
  }

  void _increaseDistance() {
    setState(() {
      _distance++;
    });
    widget.onDistanceChanged(_distance);
  }

  void _decreaseDistance() {
    if (_distance > 1) {
      setState(() {
        _distance--;
      });
      widget.onDistanceChanged(_distance);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Label
          Text(
            'Max distance:',
            style: TextStyle(
              fontSize: 11,
              color: colorScheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          // Buttons e valore distanza
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Pulsante freccia giu (sinistra)
              InkWell(
                onTap: _decreaseDistance,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color:
                        _distance > 1
                            ? colorScheme.primary
                            : colorScheme.onSurface.withOpacity(0.3),
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 2),
              // Valore distanza
              SizedBox(
                width: 45,
                child: Text(
                  '$_distance km',
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 2),
              // Pulsante freccia su (destra)
              InkWell(
                onTap: _increaseDistance,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    Icons.keyboard_arrow_up,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
