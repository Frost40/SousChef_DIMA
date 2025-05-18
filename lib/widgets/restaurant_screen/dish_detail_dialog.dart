import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sous_chef/models/dish.dart';
import 'package:sous_chef/themes/theme_extensions.dart';
import 'package:sous_chef/widgets/circular_button.dart';
import 'package:sous_chef/widgets/custom_dropdown_menu.dart';
import 'package:sous_chef/widgets/restaurant_screen/price_tag.dart';

import '../image_upload_button.dart';
import 'dish_availability_button.dart';

class DishDetailDialog extends StatefulWidget {
  final String? heroTag;
  final String dishName;
  final String description;
  final String? imageUrl;
  final bool isEditable;
  final VoidCallback? onDelete;
  final double? price;
  final bool initialAvailability;
  final Course? course;
  final Cuisine? cuisine;
  final bool isNew;
  final Function(String, String, double, Course, Cuisine, {String? imageUrl, File? imageFile, bool? isAvailable})? onSave;
  final Function(bool)? onAvailabilityChanged;


  const DishDetailDialog({
    super.key,
    this.heroTag,
    this.dishName = '',
    this.description = '',
    this.imageUrl,
    required this.isEditable,
    this.onDelete,
    this.price,
    this.initialAvailability = false,
    required this.onSave,
    this.onAvailabilityChanged,
    this.isNew = false,
    this.course,
    this.cuisine,
  });

  @override
  State<DishDetailDialog> createState() => _DishDetailDialogState();
}

class _DishDetailDialogState extends State<DishDetailDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _imageUrlController;
  Course? _selectedCourse;
  Cuisine? _selectedCuisine;

  late String _initialName;
  late String _initialDescription;
  late double? _initialPrice;
  late String? _initialImageUrl;
  late bool _availabilityStatus;
  Course? _initialCourse;
  Cuisine? _initialCuisine;

  bool _hasChanges = false;
  bool _hasValidationErrors = false;
  String? _nameError;
  String? _descriptionError;
  String? _priceError;
  String? _imageUrlError;
  String? _courseError;
  String? _cuisineError;
  File? _imageFile;

  String? _currentFocus;
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _descriptionFocus = FocusNode();
  final FocusNode _priceFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    if (widget.isNew) {
      // Set default values for a new dish
      _initialName = '';
      _initialDescription = '';
      _initialPrice = 0.0;
      _initialImageUrl = null;
      _availabilityStatus = false;
      _initialCourse = null;
      _initialCuisine = null;
    } else {
      // Use passed values for an existing dish
      _initialName = widget.dishName;
      _initialDescription = widget.description;
      _initialPrice = widget.price;
      _initialImageUrl = widget.imageUrl;
      _availabilityStatus = widget.initialAvailability;
      _initialCourse = widget.course;
      _initialCuisine = widget.cuisine;
    }

    _nameController = TextEditingController(text: _initialName);
    _descriptionController = TextEditingController(text: _initialDescription);
    _priceController = TextEditingController(
        text: _initialPrice != null ? _initialPrice!.toString() : '');
    _imageUrlController = TextEditingController(text: _initialImageUrl ?? '');

    _nameController.addListener(_checkForChanges);
    _descriptionController.addListener(_checkForChanges);
    _priceController.addListener(_checkForChanges);
    _imageUrlController.addListener(_checkForChanges);

    _selectedCourse = _initialCourse;
    _selectedCuisine = _initialCuisine;

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
  void didUpdateWidget(DishDetailDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialAvailability != oldWidget.initialAvailability) {
      setState(() {
        _availabilityStatus = widget.initialAvailability;
      });
    }
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
    final courseChanged = _selectedCourse != _initialCourse;
    final cuisineChanged = _selectedCuisine != _initialCuisine;

    setState(() {
      _hasChanges = (nameChanged ||
          descriptionChanged ||
          priceChanged ||
          imageUrlChanged ||
          courseChanged ||
          cuisineChanged) &&
          !_hasValidationErrors;
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
    String? courseError;
    String? cuisineError;

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

    // Image URL validation (optional)
    if (_imageUrlController.text.isNotEmpty &&
        !_imageUrlController.text.startsWith('http')) {
      imageUrlError = 'Image URL not valid';
    }

    if (widget.isNew && _selectedCourse == null) {
      courseError = 'Please select a course';
    }

    if (widget.isNew && _selectedCuisine == null) {
      cuisineError = 'Please select a cuisine';
    }

    setState(() {
      _nameError = nameError;
      _descriptionError = descriptionError;
      _priceError = priceError;
      _imageUrlError = imageUrlError;
      _courseError = courseError;
      _cuisineError = cuisineError;
      _hasValidationErrors = nameError != null ||
                            descriptionError != null ||
                            priceError != null ||
                            imageUrlError != null ||
                            courseError != null ||
                            cuisineError != null;
    });
  }

  void _saveChanges() {
    if (_hasValidationErrors) return;

    final name = _nameController.text;
    final description = _descriptionController.text;
    final price = _parsePrice() ?? 0.0;
    final course = _selectedCourse ?? Course.other;
    final cuisine = _selectedCuisine ?? Cuisine.other;

    if (widget.isNew) {
      // Passa isAvailable solo se il piatto è nuovo
      widget.onSave?.call(
        name,
        description,
        price,
        course,
        cuisine,
        imageUrl: _imageFile == null ? _imageUrlController.text : null,
        imageFile: _imageFile,
        isAvailable: _availabilityStatus,
      );
    } else {
      // Per i piatti esistenti, non passare isAvailable
      widget.onSave?.call(
        name,
        description,
        price,
        course,
        cuisine,
        imageUrl: _imageFile == null ? _imageUrlController.text : null,
        imageFile: _imageFile,
      );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final String uniqueHeroTag = widget.heroTag ?? 'new_dish_${DateTime.now().millisecondsSinceEpoch}';

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
                        child: widget.heroTag != null
                            ? Hero(
                                tag: uniqueHeroTag,
                                child: widget.isEditable
                                    ? _buildEditableImage(colorScheme)
                                    : _buildImage(colorScheme),
                              )
                            : widget.isEditable
                              ? _buildEditableImage(colorScheme)
                              : _buildImage(colorScheme),
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
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomDropdownMenu<Course>(
                                      items: Course.values,
                                      selectedItem: _selectedCourse,
                                      isEditable: widget.isEditable,
                                      hint: "Select a course",
                                      onChanged: (item) {
                                        setState(() {
                                          _selectedCourse = item;
                                          _checkForChanges();
                                        });
                                      },
                                    ),
                                    if (_courseError != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4, left: 8),
                                        child: Text(
                                          _courseError!,
                                          style: TextStyle(
                                            color: colorScheme.error,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomDropdownMenu<Cuisine>(
                                      items: Cuisine.values,
                                      selectedItem: _selectedCuisine,
                                      isEditable: widget.isEditable,
                                      hint: "Select a cuisine",
                                      onChanged: (item) {
                                        setState(() {
                                          _selectedCuisine = item;
                                          _checkForChanges();
                                        });
                                      },
                                    ),
                                    if (_cuisineError != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4, left: 8),
                                        child: Text(
                                          _cuisineError!,
                                          style: TextStyle(
                                            color: colorScheme.error,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              widget.isEditable
                                  ? CircularButton(
                                      icon: Icons.delete,
                                      iconColor: colorScheme.error,
                                      backgroundColor: colorScheme.errorContainer.withOpacity(0.3),
                                      size: 50,
                                      bottomPadding: 0,
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        widget.onDelete?.call();
                                      },
                                    )
                                  : CircularButton(
                                      icon: Icons.add,
                                      iconColor: colorScheme.primary,
                                      backgroundColor: colorScheme.primaryContainer.withOpacity(0.3),
                                      size: 50,
                                      bottomPadding: 0,
                                      onPressed: () {

                                      },
                                    ),

                              const SizedBox(width: 20),

                              widget.isEditable
                                  ? _buildEditablePrice(colorScheme)
                                  : _buildPrice(colorScheme),
                              /*
                              Column(
                                children: [
                                  const Text('Availability'),
                                  const SizedBox(height: 4),
                                  DishAvailabilityButton(
                                    initialValue: _availabilityStatus,
                                    isEditable: widget.isEditable,
                                    onToggle: (value) {
                                      setState(() {
                                        _availabilityStatus = value;
                                      });

                                      // Immediately call the father to notify the change without triggering the save button
                                      widget.onAvailabilityChanged?.call(value);
                                    },
                                  ),
                                ],
                              ),

                               */
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
    return Stack(
      children: [
        CircleAvatar(
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
        ),

        // Availability button on the bottom-left corner
        Positioned(
          bottom: 0,
          left: 0,
          child: DishAvailabilityButton(
            initialValue: _availabilityStatus,
            isEditable: false, // Readonly in non-editable mode
            size: 40,
            symbolResize: 0.6,
            onToggle: null, // No toggle in non-editable mode
          ),
        ),
      ],
    );
  }

  Widget _buildEditableImage(ColorScheme colorScheme) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: colorScheme.surfaceVariant,
          child: _imageFile != null
              ? ClipOval(
            child: Image.file(
              _imageFile!,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
          )
              : _imageUrlController.text.isNotEmpty
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

        // Image upload button on the bottom-right corner
        Positioned(
          bottom: 0,
          right: 0,
          child: ImageUploadButton(
            size: 40,
            onImageSelected: (File? file) {
              setState(() {
                _imageFile = file;
                if (file != null) {
                  _imageUrlController.text = '';
                }
                _checkForChanges();
              });
            },
            onUrlSelected: (String url) {
              setState(() {
                _imageUrlController.text = url;
                _checkForChanges();
              });
            },
            currentImageUrl: _imageUrlController.text,
          ),
        ),

        // Availability button on the bottom-left corner
        Positioned(
          bottom: 0,
          left: 0,
          child: DishAvailabilityButton(
            initialValue: _availabilityStatus,
            isEditable: widget.isEditable,
            size: 40,
            symbolResize: 0.6,
            onToggle: (value) {
              setState(() {
                _availabilityStatus = value;
              });

              // Immediately call the father to notify the change without triggering the save button
              widget.onAvailabilityChanged?.call(value);
            },
          ),
        ),
      ],
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
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _nameFocus.unfocus(),
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
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _descriptionFocus.unfocus(),
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
            border: Border.all(
              color: _currentFocus == 'price' ? colorScheme.primary : Colors.transparent,
              width: 2,
            ),
            color: colorScheme.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(25),
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
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _priceFocus.unfocus(),
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

    return PriceTag(price: widget.price!);
  }
}