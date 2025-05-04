import 'package:flutter/material.dart';

    class AddressField extends StatefulWidget {
      final String? address;
      final bool isEditable;
      final Function(String)? onAddressChanged;
      final String emptyMessage;

      const AddressField({
        super.key,
        this.address,
        this.isEditable = false,
        this.onAddressChanged,
        this.emptyMessage = 'No current address',
      });

      @override
      State<AddressField> createState() => _AddressFieldState();
    }

    class _AddressFieldState extends State<AddressField> {
      late TextEditingController _controller;
      late String _currentValue;
      late FocusNode _focusNode;
      bool _isEditing = false;

      @override
      void initState() {
        super.initState();
        _currentValue = widget.address ?? '';
        _controller = TextEditingController(text: _currentValue);
        _focusNode = FocusNode();
        _focusNode.addListener(_onFocusChange);
      }

      @override
      void didUpdateWidget(AddressField oldWidget) {
        super.didUpdateWidget(oldWidget);
        if (widget.address != oldWidget.address && widget.address != _currentValue) {
          _currentValue = widget.address ?? '';
          _controller.text = _currentValue;
        }
      }

      void _onFocusChange() {
        if (!_focusNode.hasFocus && _isEditing) {
          setState(() {
            _isEditing = false;
            _controller.text = _currentValue;
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
        final colorScheme = Theme.of(context).colorScheme;

        return LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _isEditing
                      ? colorScheme.primary
                      : colorScheme.surfaceContainerHighest,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(25.0),
              ),
              child: MouseRegion(
                cursor: widget.isEditable ? SystemMouseCursors.text : SystemMouseCursors.basic,
                child: GestureDetector(
                  onTap: () {
                    if (!_isEditing && widget.isEditable) {
                      setState(() {
                        _isEditing = true;
                      });
                      Future.delayed(Duration.zero, () => _focusNode.requestFocus());
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _isEditing && widget.isEditable
                        ? TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        color: colorScheme.onSurface,
                      ),
                      textInputAction: TextInputAction.done,
                      maxLines: 1,
                      onSubmitted: (value) {
                        setState(() {
                          _isEditing = false;
                          _currentValue = value;
                          if (widget.onAddressChanged != null) {
                            widget.onAddressChanged!(value);
                          }
                        });
                      },
                    )
                        : Text(
                      _currentValue.isNotEmpty
                          ? _currentValue
                          : widget.emptyMessage,
                      style: TextStyle(
                        fontSize: 16,
                        color: _currentValue.isNotEmpty
                            ? colorScheme.onSurface
                            : colorScheme.surfaceContainerHighest,
                        fontStyle: _currentValue.isNotEmpty
                            ? FontStyle.normal
                            : FontStyle.italic,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }
    }