import 'package:flutter/material.dart';

class DishAvailabilityButton extends StatefulWidget {
  final bool initialValue;
  final bool isEditable;
  final Function(bool)? onToggle;

  const DishAvailabilityButton({
    super.key,
    required this.initialValue,
    this.isEditable = true,
    this.onToggle,
  });

  @override
  State<DishAvailabilityButton> createState() => _DishAvailabilityButton();
}

class _DishAvailabilityButton extends State<DishAvailabilityButton> {
  late bool _isAvailable;

  @override
  void initState() {
    super.initState();
    _isAvailable = widget.initialValue;
  }

  @override
  void didUpdateWidget(DishAvailabilityButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      _isAvailable = widget.initialValue;
    }
  }

  void _handleToggle() {
    if (!widget.isEditable) return;

    setState(() {
      _isAvailable = !_isAvailable;
    });

    if (widget.onToggle != null) {
      widget.onToggle!(_isAvailable);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isEditable ? _handleToggle : null,
      child: _isAvailable
          ? Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 24,
            )
          : Icon(
              Icons.cancel,
              color: Colors.red,
              size: 24,
            ),
    );
  }
}