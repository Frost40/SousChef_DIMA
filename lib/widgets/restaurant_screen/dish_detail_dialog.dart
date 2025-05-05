import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sous_chef/themes/theme_extensions.dart';

import 'dish_availability_button.dart';

class DishDetailDialog extends StatefulWidget {
  final String heroTag;
  final String dishName;
  final String description;
  final String? imageUrl;
  final bool isEditable;
  final VoidCallback? onDelete;
  final double? price;
  final Function(String, String, double)? onSave;

  const DishDetailDialog({
    super.key,
    required this.heroTag,
    required this.dishName,
    required this.description,
    this.imageUrl,
    required this.isEditable,
    this.onDelete,
    this.price,
    required this.onSave,
  });

  @override
  State<DishDetailDialog> createState() => _DishDetailDialogState();
}

class _DishDetailDialogState extends State<DishDetailDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _imageUrlController;

  late String _initialName;
  late String _initialDescription;
  late double? _initialPrice;
  late String? _initialImageUrl;

  bool _hasChanges = false;
  bool _hasValidationErrors = false;
  String? _nameError;
  String? _descriptionError;
  String? _priceError;
  String? _imageUrlError;
  bool availabilityStatus = true;

  String? _currentFocus; // può essere 'name', 'description', 'price', 'image'
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _descriptionFocus = FocusNode();
  final FocusNode _priceFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _initialName = widget.dishName;
    _initialDescription = widget.description;
    _initialPrice = widget.price;
    _initialImageUrl = widget.imageUrl;

    _nameController = TextEditingController(text: _initialName);
    _descriptionController = TextEditingController(text: _initialDescription);
    _priceController = TextEditingController(
        text: _initialPrice != null ? _initialPrice!.toString() : '');
    _imageUrlController = TextEditingController(text: _initialImageUrl ?? '');

    _nameController.addListener(_checkForChanges);
    _descriptionController.addListener(_checkForChanges);
    _priceController.addListener(_checkForChanges);
    _imageUrlController.addListener(_checkForChanges);

    _nameFocus.addListener(() {
      if (_nameFocus.hasFocus) {
        setState(() => _currentFocus = 'name');
      } else if (_currentFocus == 'name') {
        setState(() => _currentFocus = null);
      }
    });

    _descriptionFocus.addListener(() {
      if (_descriptionFocus.hasFocus) {
        setState(() => _currentFocus = 'description');
      } else if (_currentFocus == 'description') {
        setState(() => _currentFocus = null);
      }
    });

    _priceFocus.addListener(() {
      if (_priceFocus.hasFocus) {
        setState(() => _currentFocus = 'price');
      } else if (_currentFocus == 'price') {
        setState(() => _currentFocus = null);
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();

    _nameFocus.dispose();
    _descriptionFocus.dispose();
    _priceFocus.dispose();
    super.dispose();
  }

  void _resetCurrentField() {
    if (_currentFocus == 'name') {
      _nameController.text = _initialName;
      _nameFocus.unfocus();
    } else if (_currentFocus == 'description') {
      _descriptionController.text = _initialDescription;
      _descriptionFocus.unfocus();
    } else if (_currentFocus == 'price') {
      _priceController.text = _initialPrice != null ? _initialPrice!.toString() : '';
      _priceFocus.unfocus();
    } else if (_currentFocus == 'image') {
      _imageUrlController.text = _initialImageUrl ?? '';
      setState(() => _currentFocus = null);
    }

    _checkForChanges();
  }

  void _checkForChanges() {
    _validate();

    final nameChanged = _nameController.text != _initialName;
    final descriptionChanged = _descriptionController.text != _initialDescription;
    final priceChanged = _parsePrice() != _initialPrice;
    final imageUrlChanged = _imageUrlController.text != _initialImageUrl;

    setState(() {
      _hasChanges = (nameChanged || descriptionChanged || priceChanged || imageUrlChanged) && !_hasValidationErrors;
    });
  }

  double? _parsePrice() {
    if (_priceController.text.isEmpty) return null;
    try {
      return double.parse(_priceController.text.replaceAll(',', '.'));
    } catch (e) {
      return null;
    }
  }

  void _validate() {
    String? nameError;
    String? descriptionError;
    String? priceError;
    String? imageUrlError;

    // Name validation
    if (_nameController.text.trim().isEmpty) {
      nameError = 'Dish name is required';
    }

    // Description validation
    if (_descriptionController.text.trim().isEmpty) {
      descriptionError = 'Description is required';
    }

    // Price validation
    if (_priceController.text.isNotEmpty) {
      final price = _parsePrice();
      if (price == null) {
        priceError = 'Price format is invalid';
      } else if (price <= 0) {
        priceError = 'The price must be greater than 0';
      }
    }

    // Validazione URL immagine (opzionale)
    if (_imageUrlController.text.isNotEmpty &&
        !_imageUrlController.text.startsWith('http')) {
      imageUrlError = 'URL immagine non valido';
    }

    setState(() {
      _nameError = nameError;
      _descriptionError = descriptionError;
      _priceError = priceError;
      _imageUrlError = imageUrlError;
      _hasValidationErrors = nameError != null ||
                            descriptionError != null ||
                            priceError != null ||
                            imageUrlError != null;
    });
  }

  void _saveChanges() {
    if (_hasValidationErrors) return;

    final name = _nameController.text;
    final description = _descriptionController.text;
    final price = _parsePrice() ?? 0.0;

    widget.onSave?.call(name, description, price);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () {if (widget.isEditable && _currentFocus != null) {
          _resetCurrentField();
        }}, // Prevent closing the dialog when tapping inside
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.darkGrayBackground,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      color: colorScheme.surfaceContainerHighest,
                      padding: const EdgeInsets.symmetric(vertical: 25),
                      child: Center(
                        child: Hero(
                          tag: widget.heroTag,
                          child: widget.isEditable
                              ? _buildEditableImage(colorScheme)
                              : _buildImage(colorScheme),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          widget.isEditable
                              ? _buildEditableName(colorScheme)
                              : _buildName(colorScheme),
                          const SizedBox(height: 12),
                          widget.isEditable
                              ? _buildEditableDescription(colorScheme)
                              : _buildDescription(colorScheme),
                          const SizedBox(height: 20),
                          widget.isEditable
                              ? _buildEditablePrice(colorScheme)
                              : _buildPrice(colorScheme),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (widget.isEditable)
                                Row(
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        if (widget.onDelete != null) widget.onDelete!();
                                      },
                                      icon: Icon(Icons.delete, color: colorScheme.error),
                                      label: Text(
                                        'Delete',
                                        style: TextStyle(color: colorScheme.error),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: colorScheme.errorContainer.withOpacity(0.3),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                  ],
                                ),
                              Column(
                                children: [
                                  const Text('Availability'),
                                  const SizedBox(height: 4),
                                  DishAvailabilityButton(
                                    initialValue: availabilityStatus,
                                    isEditable: widget.isEditable,
                                    onToggle: (value) {
                                      setState(() {
                                        availabilityStatus = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.isEditable && _hasChanges)
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    icon: Icon(
                      Icons.save,
                      color: colorScheme.primary,
                    ),
                    onPressed: _saveChanges,
                  ),
                ),
              Positioned(
                top: 10,
                left: 10,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(ColorScheme colorScheme) {
    return CircleAvatar(
      radius: 60,
      backgroundColor: colorScheme.surface,
      child: widget.imageUrl != null && widget.imageUrl!.isNotEmpty
          ? ClipOval(
              child: Image.network(
                widget.imageUrl!,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.restaurant_menu,
                  size: 60,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            )
          : Icon(
              Icons.restaurant_menu,
              size: 60,
              color: colorScheme.primary,
            ),
    );
  }

  Widget _buildEditableImage(ColorScheme colorScheme) {
    return GestureDetector(
      onTap: () {
        // Qui potresti aprire un picker per l'immagine
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Inserisci URL immagine'),
            content: TextField(
              controller: _imageUrlController,
              decoration: InputDecoration(
                labelText: 'URL Immagine',
                errorText: _imageUrlError,
              ),
              onChanged: (_) => _checkForChanges(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Annulla'),
              ),
              TextButton(
                onPressed: () {
                  _checkForChanges();
                  Navigator.of(context).pop();
                },
                child: const Text('Conferma'),
              ),
            ],
          ),
        );
      },
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: colorScheme.surfaceVariant,
            child: _imageUrlController.text.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      _imageUrlController.text,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.restaurant_menu,
                        size: 60,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : Icon(
                    Icons.restaurant_menu,
                    size: 60,
                    color: colorScheme.primary,
                  ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              radius: 20,
              backgroundColor: colorScheme.primary,
              child: Icon(
                Icons.camera_alt,
                color: colorScheme.onPrimary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildName(ColorScheme colorScheme) {
    return Text(
      widget.dishName,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildEditableName(ColorScheme colorScheme) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _currentFocus == 'name' ? colorScheme.primary : Colors.transparent,
              width: 2,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: TextField(
            controller: _nameController,
            focusNode: _nameFocus,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: 'Dish name',
              hintStyle: TextStyle(
                fontSize: 22,
                fontStyle: FontStyle.italic,
                color: colorScheme.surfaceContainerHighest,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
        if (_nameError != null)
          Text(
            _nameError!,
            style: TextStyle(
              color: colorScheme.error,
              fontSize: 12,
            ),
          ),
      ],
    );
  }

  Widget _buildEditableDescription(ColorScheme colorScheme) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _currentFocus == 'description' ? colorScheme.primary : Colors.transparent,
              width: 2,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: TextField(
            controller: _descriptionController,
            focusNode: _descriptionFocus,
            textAlign: TextAlign.center,
            maxLines: 3,
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: 'Dish description',
              hintStyle: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: colorScheme.surfaceContainerHighest,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
        if (_descriptionError != null)
          Text(
            _descriptionError!,
            style: TextStyle(
              color: colorScheme.error,
              fontSize: 12,
            ),
          ),
      ],
    );
  }

  Widget _buildEditablePrice(ColorScheme colorScheme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: _currentFocus == 'price'
                ? colorScheme.primary.withOpacity(0.2)
                : colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '€',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              SizedBox(
                width: 80,
                child: TextField(
                  controller: _priceController,
                  focusNode: _priceFocus,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle: TextStyle(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      color: colorScheme.primary.withOpacity(0.5),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_priceError != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _priceError!,
              style: TextStyle(
                color: colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }


  Widget _buildDescription(ColorScheme colorScheme) {
    return Text(
      widget.description,
      style: TextStyle(
        fontSize: 16,
        color: colorScheme.onSurfaceVariant,
      ),
      textAlign: TextAlign.center,
    );
  }



  Widget _buildPrice(ColorScheme colorScheme) {
    if (widget.price == null) {
      return Text(
        'Price not set',
        style: TextStyle(
          fontSize: 18,
          fontStyle: FontStyle.italic,
          color: colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        '€${widget.price!.toStringAsFixed(2)}',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: colorScheme.primary,
        ),
      ),
    );
  }


}