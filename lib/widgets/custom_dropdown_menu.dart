import 'package:flutter/material.dart';
import 'package:sous_chef/themes/theme_extensions.dart';

class CustomDropdownMenu<T> extends StatefulWidget {
  final List<T> items;
  final T? selectedItem;
  final bool isEditable;
  final ValueChanged<T> onChanged;
  final String? hint;

  const CustomDropdownMenu({
    super.key,
    required this.items,
    required this.isEditable,
    required this.onChanged,
    this.selectedItem,
    this.hint,
  });

  @override
  _CustomDropdownMenuState<T> createState() => _CustomDropdownMenuState<T>();
}

class _CustomDropdownMenuState<T> extends State<CustomDropdownMenu<T>> {
  late T? _selectedItem;
  final GlobalKey _actionKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.selectedItem;
  }

  void _showCustomMenu() async {
    final RenderBox renderBox = _actionKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final colorScheme = Theme.of(context).colorScheme;

    final T? selected = await showMenu<T>(
      context: context,
      position: RelativeRect.fromLTRB(
          offset.dx,
          offset.dy + size.height,
          offset.dx + size.width,
          offset.dy
      ),
      items: widget.items.map((T value) {
        return PopupMenuItem<T>(
          value: value,
          padding: EdgeInsets.zero, // Remove the default padding to adapt to the inkWell
          child: InkWell(
            onTap: () => Navigator.of(context).pop(value), // Close the menu and return the selected value
            splashColor: colorScheme.primary.withOpacity(0.12),
            highlightColor: colorScheme.primary.withOpacity(0.1),
            child: Container(
              width: size.width,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Internal padding for the text
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _getDisplayText(value),
                style: TextStyle(
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ),
        );
      }).toList(),
      constraints: BoxConstraints(
        maxHeight: 200,
        minWidth: size.width,
        maxWidth: size.width,
      ),
      elevation: 8,
      color: colorScheme.darkGrayBackground,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
    );

    if (selected != null) {
      setState(() {
        _selectedItem = selected;
      });
      widget.onChanged(selected);
    }
  }

  String _getDisplayText(T value) {
    if (value == null) return '';

    String valueStr = value.toString();

    if (valueStr.contains('.')) {
      return valueStr.split('.').last;
    }

    return valueStr;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      key: _actionKey,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.darkGrayBackground,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: colorScheme.surfaceContainerHighest,
          width: 1
        ),
      ),
      child: InkWell(
        onTap: widget.isEditable ? _showCustomMenu : null,
        child: Row(
          children: [
            Expanded(
              child: Text(
                _selectedItem != null ? _getDisplayText(_selectedItem!) : (widget.hint ?? ''),
                style: TextStyle(
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            if (widget.isEditable)
              Icon(
                Icons.arrow_drop_down,
                color: colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}