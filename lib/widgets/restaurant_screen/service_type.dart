import 'package:flutter/material.dart';

class ServiceType extends StatefulWidget {
  final String serviceType;
  final bool initialValue;  // true if the service is selected, false otherwise
  final bool isEditable;
  final Function(bool)? onToggle;

  const ServiceType({
    super.key,
    required this.initialValue,
    required this.serviceType,
    this.isEditable = false,
    this.onToggle,
  });

  @override
  State<ServiceType> createState() => _OpenCloseButtonState();
}

class _OpenCloseButtonState extends State<ServiceType> {
  late bool _isSelected;

  @override
  void initState() {
    super.initState();
    _isSelected = widget.initialValue;
  }

  @override
  void didUpdateWidget(ServiceType oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      _isSelected = widget.initialValue;
    }
  }

  void _handleToggle() {
    if (!widget.isEditable) return;

    setState(() {
      _isSelected = !_isSelected;
    });

    if (widget.onToggle != null) {
      widget.onToggle!(_isSelected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: widget.isEditable ? _handleToggle : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: _isSelected
              ? colorScheme.tertiary.withOpacity(0.15)
              : colorScheme.surface.withOpacity(0.15),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: _isSelected ? colorScheme.primary : colorScheme.surfaceContainerHighest,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            widget.serviceType,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}