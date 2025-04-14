import 'package:flutter/material.dart';
import 'package:sous_chef/themes/dark_mode.dart';

class AccountSettingField extends StatefulWidget {
  final String fieldName;
  final String initialValue;
  final Function(String) onValueChanged;
  final bool isPassword;
  final TextInputType keyboardType;

  const AccountSettingField({
    super.key,
    required this.fieldName,
    required this.initialValue,
    required this.onValueChanged,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
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
      setState(() {
        _isEditing = false;
        widget.onValueChanged(_currentValue);
      });
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
    var colorTheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25),
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(
          color: _isEditing
              ? colorTheme.primary
              : colorTheme.surfaceContainerHighest,
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
                                widget.onValueChanged(value);
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