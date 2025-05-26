import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CircularNumberInput extends StatefulWidget {
  final double size;
  final Function(int) onNumberSubmitted;
  final int? initialValue;

  const CircularNumberInput({
    super.key,
    required this.size,
    required this.onNumberSubmitted,
    this.initialValue,
  });

  @override
  State<CircularNumberInput> createState() => _CircularNumberInputState();
}

class _CircularNumberInputState extends State<CircularNumberInput> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _hasFocus = false;
  late final int? _initialValue;

  @override
  void initState() {
    super.initState();
    _initialValue = widget.initialValue;
    _controller = TextEditingController(
      text: _initialValue != null ? _initialValue.toString() : '',
    );
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _hasFocus = _focusNode.hasFocus;
    });

    if (!_focusNode.hasFocus) {
      if (_controller.text.isEmpty) {
        _controller.text = _initialValue != null ? _initialValue.toString() : '';
      } else {
        final number = int.tryParse(_controller.text);
        if (number == null || number > 99) {
          _controller.text = _initialValue != null ? _initialValue.toString() : '';
        }
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: _hasFocus ? colorScheme.primary : colorScheme.surfaceContainerHighest,
          width: 2.0,
        ),
      ),
      child: Center(
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 2,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(2),
          ],
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          style: TextStyle(
            fontSize: widget.size * 0.4,
            fontWeight: FontWeight.bold,
          ),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              final number = int.tryParse(value);
              if (number != null && number <= 99) {
                widget.onNumberSubmitted(number);
              } else {
                // Restore initial value if the input is invalid on submission
                _controller.text = _initialValue != null ? _initialValue.toString() : '';
              }
            } else {
              // Empty field, restore the initial value
              _controller.text = _initialValue != null ? _initialValue.toString() : '';
            }
          },
        ),
      ),
    );
  }
}