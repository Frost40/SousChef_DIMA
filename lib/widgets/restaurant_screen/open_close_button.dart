import 'package:flutter/material.dart';

class OpenCloseButton extends StatefulWidget {
  final bool initialValue;
  final bool isEditable;
  final Function(bool)? onToggle;

  const OpenCloseButton({
    super.key,
    required this.initialValue,
    this.isEditable = false,
    this.onToggle,
  });

  @override
  State<OpenCloseButton> createState() => _OpenCloseButtonState();
}

class _OpenCloseButtonState extends State<OpenCloseButton> {
  late bool _isOpen;

  @override
  void initState() {
    super.initState();
    _isOpen = widget.initialValue;
  }

  @override
  void didUpdateWidget(OpenCloseButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      _isOpen = widget.initialValue;
    }
  }

  void _handleToggle() {
    if (!widget.isEditable) return;

    setState(() {
      _isOpen = !_isOpen;
    });

    if (widget.onToggle != null) {
      widget.onToggle!(_isOpen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isEditable ? _handleToggle : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _isOpen
              ? Colors.green.withOpacity(0.15)
              : Colors.red.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isOpen ? Colors.green : Colors.red,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isOpen ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              _isOpen ? 'Open' : 'Closed',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _isOpen ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}