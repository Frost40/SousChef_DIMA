import 'package:flutter/material.dart';
import 'package:sous_chef/themes/theme_extensions.dart';  // Add this import

class AccountSettingField extends StatefulWidget {
  final String fieldName;
  final String initialValue;
  final Function(String, bool) onValueChanged; // isModified parameter added to prevent unnecessary updates
  final Function(String?)? onValidationError;
  final bool isPassword;
  final TextInputType keyboardType;
  final Future<String?> Function(String)? asyncValidator;

  const AccountSettingField({
    super.key,
    required this.fieldName,
    required this.initialValue,
    required this.onValueChanged,
    this.onValidationError,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.asyncValidator,
  });

  @override
  State<AccountSettingField> createState() => _AccountSettingFieldState();
}

class _AccountSettingFieldState extends State<AccountSettingField> {
  late TextEditingController _controller;
  late String _currentValue;
  bool _isEditing = false;
  bool pwdVisibility = false;
  late FocusNode _focusNode;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && _isEditing) {
      if (mounted) {
        setState(() {
          _isEditing = false;
          _notifyValueChanged();
        });
      }
    }
  }

  // Method to handle value changes and notify the parent widget
  Future<void> _notifyValueChanged() async {
    if (!mounted) return; // Check if widget is still mounted before proceeding
    
    // Verify if the value has changed
    bool isModified = _currentValue != widget.initialValue;
    // Send the modified value to the parent widget together with the isModified flag
    if (isModified && widget.asyncValidator != null) {
      if (mounted) {
        setState(() {
          _validationError = null;
        });
      }

      final error = await widget.asyncValidator!(_currentValue);

      if (error != null && mounted) {
        setState(() {
          _validationError = error;
        });
        // Notify the parent widget about the validation error
        if (widget.onValidationError != null) {
          widget.onValidationError!(error);
        }
        widget.onValueChanged(_currentValue, false);
        return;
      }
    }

    widget.onValueChanged(_currentValue, isModified);
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
    var colorTheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(
          color: _validationError != null
              ? Theme.of(context).colorScheme.error
              : (_isEditing
              ? colorTheme.primary
              : colorTheme.surfaceContainerHighest),
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: Row(
        children: [
          Container(
            width: 120,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24.0),
                bottomLeft: Radius.circular(24.0),
              ),
              color: colorTheme.darkGrayBackground,
            ),
            child: Text(
              widget.fieldName,
              style: TextStyle(
                fontSize: 14,
                color: colorTheme.onSurface,
              ),
            ),
          ),

          Expanded(
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                GestureDetector(
                  onTap: () {
                    if (!_isEditing) {
                      setState(() {
                        _isEditing = true;
                      });
                      // Delayed focus request to ensure the widget is built
                      Future.delayed(Duration.zero, () => _focusNode.requestFocus());
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: double.infinity,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(
                      left: 15,
                      right: widget.isPassword ? 40 : 15,
                    ),
                    child: _isEditing
                        ? TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            keyboardType: widget.keyboardType,
                            autofocus: true,
                            obscureText: widget.isPassword && !pwdVisibility,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                            style: TextStyle(
                              fontSize: 16,
                              color: colorTheme.onSurface,
                              height: 1.0,
                            ),
                            onSubmitted: (value) {
                              setState(() {
                                _isEditing = false;
                                _currentValue = value;
                                _notifyValueChanged();
                              });
                            },
                          )
                        : Text(
                            widget.isPassword && !pwdVisibility
                                ? '•' * _currentValue.length
                                : _currentValue,
                            style: TextStyle(
                              fontSize: 14,
                              color: colorTheme.onSurface,
                              height: 1.0,
                            ),
                          ),
                  ),
                ),

                if (widget.isPassword)
                  Positioned(
                    right: 5,
                    child: InkWell(
                      onTap: () => setState(() => pwdVisibility = !pwdVisibility),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          pwdVisibility
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: colorTheme.surfaceContainerHighest,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}