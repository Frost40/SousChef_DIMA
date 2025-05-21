import 'package:flutter/material.dart';
import 'package:sous_chef/themes/theme_extensions.dart';

class CustomDropdownMenu<T> extends StatefulWidget {
  final List<T> items;
  final T? selectedItem;
  final bool isEditable;
  final ValueChanged<T> onChanged;
  final String? hint;
  final VoidCallback? onTap;
  final bool isFocused;

  const CustomDropdownMenu({
    super.key,
    required this.items,
    required this.isEditable,
    required this.onChanged,
    this.selectedItem,
    this.hint,
    this.onTap,
    this.isFocused = false,
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
          padding: EdgeInsets.zero,
          child: InkWell(
            onTap: () => Navigator.of(context).pop(value),
            splashColor: colorScheme.primary.withOpacity(0.12),
            highlightColor: colorScheme.primary.withOpacity(0.1),
            child: Container(
              width: size.width,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      elevation: 4,
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

    // Qui sta la chiave: quando il menu si chiude, rimuoviamo il focus
    // indipendentemente da cosa ha causato la chiusura
    if (selected != null) {
      setState(() {
        _selectedItem = selected;
      });
      widget.onChanged(selected);
    } else {
      // Se l'utente ha toccato fuori dal menu, rimuoviamo il focus
      // chiamando onChanged con il valore attuale per ripristinare lo stato
      if (widget.isFocused) {
        // Aggiungiamo un breve ritardo per far coincidere la rimozione del focus
        // con la chiusura dell'animazione del menu
        Future.delayed(const Duration(milliseconds: 300), () {
          widget.onChanged(_selectedItem as T);
        });
      }
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
          color: widget.isFocused ? colorScheme.primary : Colors.transparent,
          width: 1
        ),
        boxShadow: widget.isFocused ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 1.5,
            spreadRadius: 0,
            offset: const Offset(0, 1),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 3,
            spreadRadius: -0.5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: widget.isEditable ? () {
          widget.onTap?.call(); // Chiama onTap prima di mostrare il menu
          _showCustomMenu();
        } : null,
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