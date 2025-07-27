import 'package:flutter/material.dart';
import 'package:sous_chef/screens/dish_screen.dart';

/// A widget that shows the DishScreen in a modal dialog for tablet view
class DishPopupDialog extends StatefulWidget {
  final String? heroTag;
  final String? dishId;
  final bool isEditable;
  final bool isNew;
  final bool isSpecial;
  final Function(bool)? onAvailabilityChanged;

  // Popup proportions relative to the smallest screen dimension
  static const double widthFactor = 0.75;
  static const double heightFactor = 0.90;

  const DishPopupDialog({
    super.key,
    this.heroTag,
    required this.isEditable,
    this.dishId,
    this.isNew = false,
    this.isSpecial = false,
    this.onAvailabilityChanged,
  });

  @override
  State<DishPopupDialog> createState() => _DishPopupDialogState();
}

class _DishPopupDialogState extends State<DishPopupDialog> {
  // Initialize with default values
  double _dialogWidth = 0;
  double _dialogHeight = 0;
  bool _dimensionsCalculated = false;

  @override
  void initState() {
    super.initState();
    // Calculate dimensions once at initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateFixedSize();
    });
  }

  void _calculateFixedSize() {
    // Get the smallest dimension of the screen (same for vertical and horizontal)
    final screenSize = MediaQuery.of(context).size;
    final minDimension = screenSize.shortestSide;

    // Calculate dimensions based on defined factors
    setState(() {
      _dialogWidth = minDimension * DishPopupDialog.widthFactor;
      _dialogHeight = minDimension * DishPopupDialog.heightFactor;
      _dimensionsCalculated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // If dimensions are not yet calculated, use temporary percentage dimensions
    final screenSize = MediaQuery.of(context).size;
    final width = _dimensionsCalculated ? _dialogWidth : screenSize.width * 0.8;
    final height = _dimensionsCalculated ? _dialogHeight : screenSize.height * 0.8;
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        // Use calculated (or temporary) dimensions
        width: width,
        height: height,
        constraints: BoxConstraints(
          // Max dimensions based on screen size to ensure it fits well
          maxWidth: screenSize.width * 0.95,
          maxHeight: screenSize.height * 0.95,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: isDarkMode
              ? Border.all(
                  color: colorScheme.surfaceContainerHighest,
                  width: 2.0,
                )
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: DishScreen(
            heroTag: widget.heroTag,
            dishId: widget.dishId,
            isEditable: widget.isEditable,
            isNew: widget.isNew,
            isSpecial: widget.isSpecial,
            onAvailabilityChanged: widget.onAvailabilityChanged,
          ),
        ),
      ),
    );
  }
}
