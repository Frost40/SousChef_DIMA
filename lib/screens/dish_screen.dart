import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sous_chef/models/dish.dart';
import 'package:sous_chef/providers/dish_provider.dart';
import 'package:sous_chef/themes/theme_extensions.dart';
import 'package:sous_chef/widgets/account_settings_field.dart';
import 'package:sous_chef/widgets/circular_button.dart';
import 'package:sous_chef/widgets/custom_dropdown_menu.dart';
import 'package:sous_chef/widgets/dish_screen/calendar_widget.dart';
import 'package:sous_chef/widgets/restaurant_screen/price_tag.dart';
import 'package:sous_chef/widgets/responsive_layout.dart';

import 'package:sous_chef/widgets/image_upload_button.dart';
import 'package:sous_chef/widgets/restaurant_screen/dish_availability_button.dart';

import '../providers/order_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/circular_number_input.dart';
import '../widgets/custom_alert_dialog.dart';

class DishScreen extends StatefulWidget {
  final String? heroTag;
  final String? dishId;
  final bool isEditable;
  final bool isNew;
  final bool isSpecial;
  final Function(bool)? onAvailabilityChanged;

  const DishScreen({
    super.key,
    this.heroTag,
    required this.isEditable,
    this.dishId,
    this.isNew = false,
    this.isSpecial = false,
    this.onAvailabilityChanged,
  });

  @override
  State<DishScreen> createState() => _DishScreenState();
}

class _DishScreenState extends State<DishScreen> {
  Dish? _dish;
  DateTime? _selectedDateTime;
  bool get initialAvailability => _dish?.isAvailable ?? false;
  bool get isSpecial => _dish?.isSpecial ?? widget.isSpecial;
  String? get imageUrl => _dish?.imageUrl;
  String get dishName => _dish?.name ?? '';
  String get description => _dish?.description ?? '';
  double? get price => _dish?.price;
  int get minForewarningDays => _dish?.minForewarningDays ?? 0;

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
  late String _initialUsername;
  Course? _initialCourse;
  Cuisine? _initialCuisine;
  late int _initialMinForewarningDays;

  // Current values
  late String _currentName;
  late String _currentDescription;
  late double? _currentPrice;
  late String _currentUsername;
  late int _currentMinForewarningDays;

  bool _hasChanges = false;
  bool _hasValidationErrors = false;
  String? _nameError;
  String? _descriptionError;
  String? _priceError;
  String? _imageUrlError;
  String? _usernameError;
  String? _courseError;
  String? _cuisineError;
  File? _imageFile;

  String? _currentFocus;
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _descriptionFocus = FocusNode();
  final FocusNode _priceFocus = FocusNode();
  final FocusNode _usernameFocus = FocusNode();
  bool _courseFocused = false;
  bool _cuisineFocused = false;

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
      _initialUsername = '';
      _initialMinForewarningDays = 0;
    } else {
      final dishProvider = Provider.of<DishProvider>(context, listen: false);
      _dish = dishProvider.getDishById(widget.dishId!);

      if (_dish != null) {
        _initialName = _dish!.name;
        _initialDescription = _dish!.description ?? '';
        _initialPrice = _dish!.price;
        _initialImageUrl = _dish!.imageUrl;
        _availabilityStatus = _dish!.isAvailable ?? false;
        _initialCourse = _dish!.course;
        _initialCuisine = _dish!.cuisine;
        _initialUsername = _dish!.userUsername ?? '';
        _initialMinForewarningDays = _dish!.minForewarningDays;
      }
    }

    // Initialize current values with initial values
    _currentName = _initialName;
    _currentDescription = _initialDescription;
    _currentPrice = _initialPrice;
    _currentUsername = _initialUsername;
    _currentMinForewarningDays = _initialMinForewarningDays;

    _nameController = TextEditingController(text: _initialName);
    _descriptionController = TextEditingController(text: _initialDescription);
    _priceController = TextEditingController(
      text: _initialPrice != null ? _initialPrice!.toString() : '',
    );
    _imageUrlController = TextEditingController(text: _initialImageUrl ?? '');

    _nameController.addListener(() {
      _currentName = _nameController.text;
      _checkForChanges();
    });

    _descriptionController.addListener(() {
      _currentDescription = _descriptionController.text;
      _checkForChanges();
    });

    _priceController.addListener(() {
      _currentPrice = _parsePrice();
      _checkForChanges();
    });

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
  void didUpdateWidget(DishScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
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

    _usernameFocus.dispose();
    super.dispose();
  }

  void _resetCurrentField() {
    if (_currentFocus == 'name') {
      _nameController.text = _currentName;
      _nameFocus.unfocus();
    } else if (_currentFocus == 'description') {
      _descriptionController.text = _currentDescription;
      _descriptionFocus.unfocus();
    } else if (_currentFocus == 'price') {
      _priceController.text =
          _currentPrice != null ? _currentPrice!.toString() : '';
      _priceFocus.unfocus();
    } else if (_currentFocus == 'image') {
      _imageUrlController.text = _initialImageUrl ?? '';
      setState(() => _currentFocus = null);
    }

    setState(() {
      _courseFocused = false;
      _cuisineFocused = false;
    });

    _checkForChanges();
  }

  void _checkForChanges() {
    _validate();

    final nameChanged = _currentName != _initialName;
    final descriptionChanged = _currentDescription != _initialDescription;
    final priceChanged = _currentPrice != _initialPrice;
    final usernameChanged = _currentUsername != _initialUsername;
    final String controllerText = _imageUrlController.text;
    final String? initialText = _initialImageUrl;
    final imageUrlChanged =
        (initialText == null && controllerText.isNotEmpty) ||
        (initialText != null && controllerText != initialText);
    final imageFileChanged =
        _imageFile != null; // Check if a new image file has been selected
    final courseChanged = _selectedCourse != _initialCourse;
    final cuisineChanged = _selectedCuisine != _initialCuisine;
    final minForewarningDaysChanged =
        _currentMinForewarningDays != _initialMinForewarningDays;

    setState(() {
      _hasChanges =
          (nameChanged ||
              descriptionChanged ||
              priceChanged ||
              usernameChanged ||
              imageUrlChanged ||
              imageFileChanged ||
              courseChanged ||
              cuisineChanged ||
              minForewarningDaysChanged) &&
          !_hasValidationErrors;
    });

    debugPrint(
      "Changes: name=$nameChanged, desc=$descriptionChanged, price=$priceChanged, "
              "user=$usernameChanged, img=$imageUrlChanged, imgFile=$imageFileChanged, course=$courseChanged, " +
          "cuisine=$cuisineChanged, hasChanges=$_hasChanges",
    );
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

    // Price validation
    if (_priceController.text.isEmpty) {
      priceError = 'Price is required';
    } else {
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
      _hasValidationErrors =
          nameError != null ||
          _usernameError != null ||
          priceError != null ||
          imageUrlError != null ||
          courseError != null ||
          cuisineError != null;
    });
  }

  void _saveChanges() {
    if (_hasValidationErrors) return;

    final dishProvider = Provider.of<DishProvider>(context, listen: false);
    final restaurantId = dishProvider.currentRestaurantId;

    if (restaurantId == null) {
      debugPrint("Error: No restaurant ID available");
      return;
    }

    final name = _currentName;
    final description = _currentDescription;
    final price = _currentPrice ?? 0.0;
    final course = _selectedCourse ?? Course.other;
    final cuisine = _selectedCuisine ?? Cuisine.other;
    final isAvailable = _availabilityStatus;
    final minForewarningDays = _currentMinForewarningDays;

    if (widget.isNew) {
      dishProvider.createDish(
        restaurantId: restaurantId,
        name: name,
        description: description,
        price: price,
        course: course,
        cuisine: cuisine,
        imageFile: _imageFile,
        imageUrl: _imageFile == null ? _imageUrlController.text : null,
        isAvailable: isAvailable,
        minForewarningDays: minForewarningDays,
        isSpecial: isSpecial,
        userUsername: isSpecial ? _currentUsername : '',
      );
    } else if (widget.dishId != null) {
      dishProvider.updateDish(
        restaurantId: restaurantId,
        dishId: widget.dishId!,
        name: name,
        description: description,
        price: price,
        course: course,
        cuisine: cuisine,
        imageFile: _imageFile,
        imageUrl: _imageFile == null ? _imageUrlController.text : null,
        minForewarningDays: minForewarningDays,
        userUsername: isSpecial ? _currentUsername : '',
      );
    }

    Navigator.of(context).pop();
  }

  void _deleteDish() {
    if (widget.dishId == null) return;

    final dishProvider = Provider.of<DishProvider>(context, listen: false);
    final restaurantId = dishProvider.currentRestaurantId;

    if (restaurantId == null) {
      debugPrint("Error: No restaurant ID available");
      return;
    }

    dishProvider.deleteDish(restaurantId, widget.dishId!);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final String uniqueHeroTag =
        widget.heroTag ?? 'new_dish_${DateTime.now().millisecondsSinceEpoch}';

    return ResponsiveLayout(
      builder: (context, isTablet) {
        return GestureDetector(
          onTap: () {
            if (widget.isEditable) {
              _resetCurrentField();

              // Remove focus from course and cuisine dropdowns
              if (_courseFocused || _cuisineFocused) {
                setState(() {
                  _courseFocused = false;
                  _cuisineFocused = false;
                });
              }
            }

            FocusScope.of(context).unfocus();
          },
          child: Scaffold(
            backgroundColor: colorScheme.surface,
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text(''),
              leading: IconButton(
                icon: Icon(isTablet ? Icons.close : Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                if (widget.isEditable && _hasChanges)
                  IconButton(
                    icon: Icon(Icons.save, color: colorScheme.primary),
                    onPressed: _saveChanges,
                  ),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    color: colorScheme.surfaceContainerHighest,
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 25,
                      bottom: 25,
                    ),
                    child: Center(
                      child:
                          widget.heroTag != null
                              ? Hero(
                                tag: uniqueHeroTag,
                                child:
                                    widget.isEditable
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
                        const SizedBox(height: 5),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              'Description:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),

                        Divider(
                          height: 1,
                          thickness: 1,
                          color: colorScheme.onSurface,
                        ),

                        const SizedBox(height: 5),

                        widget.isEditable
                            ? _buildEditableDescription(colorScheme)
                            : _buildDescription(colorScheme),

                        const SizedBox(height: 10),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              'Course & Cuisine:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),

                        Divider(
                          height: 1,
                          thickness: 1,
                          color: colorScheme.onSurface,
                        ),

                        const SizedBox(height: 15),

                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomDropdownMenu<Course>(
                                    key: const Key('course_dropdown'),
                                    items: Course.values,
                                    selectedItem: _selectedCourse,
                                    isEditable: widget.isEditable,
                                    hint: "Select a course",
                                    isFocused: _courseFocused,
                                    onTap: () {
                                      setState(() {
                                        _courseFocused = true;
                                        _cuisineFocused = false;
                                        _currentFocus = null;

                                        _nameFocus.unfocus();
                                        _descriptionFocus.unfocus();
                                        _priceFocus.unfocus();
                                      });
                                    },
                                    onChanged: (item) {
                                      setState(() {
                                        if (_selectedCourse != item) {
                                          _selectedCourse = item;
                                        }
                                        _courseFocused = false;
                                        _checkForChanges();
                                      });
                                    },
                                  ),
                                  if (_courseError != null)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 4,
                                        left: 8,
                                      ),
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
                                    key: const Key('cuisine_dropdown'),
                                    items: Cuisine.values,
                                    selectedItem: _selectedCuisine,
                                    isEditable: widget.isEditable,
                                    hint: "Select a cuisine",
                                    isFocused: _cuisineFocused,
                                    onTap: () {
                                      setState(() {
                                        _cuisineFocused = true;
                                        _courseFocused = false;
                                        _currentFocus = null;

                                        _nameFocus.unfocus();
                                        _descriptionFocus.unfocus();
                                        _priceFocus.unfocus();
                                      });
                                    },
                                    onChanged: (item) {
                                      setState(() {
                                        if (_selectedCuisine != item) {
                                          _selectedCuisine = item;
                                        }
                                        _cuisineFocused = false;
                                        _checkForChanges();
                                      });
                                    },
                                  ),
                                  if (_cuisineError != null)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 4,
                                        left: 8,
                                      ),
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

                        const SizedBox(height: 40),

                        // Username selection for special dishes
                        if (widget.isEditable && isSpecial)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Text(
                                    'Select the username:',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ),
                              Divider(
                                height: 1,
                                thickness: 1,
                                color: colorScheme.onSurface,
                              ),
                              const SizedBox(height: 10),
                              AccountSettingField(
                                fieldName: "Username",
                                initialValue: _initialUsername,
                                padding: 0,
                                asyncValidator: _validateUsername,
                                onValueChanged: (username, isModified) {
                                  setState(() {
                                    _currentUsername = username;
                                    _usernameFocus.unfocus();
                                    _checkForChanges();
                                  });
                                },
                                onValidationError: (error) {
                                  setState(() {
                                    _usernameError = error;
                                  });
                                },
                                onTextChanged: () {
                                  // Cleaning the error when the user starts typing
                                  setState(() {
                                    _usernameError = null;
                                  });
                                },
                              ),

                              if (_usernameError != null)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    top: 4,
                                    left: 8,
                                  ),
                                  child: Text(
                                    _usernameError!,
                                    style: TextStyle(
                                      color: colorScheme.error,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 10),

                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: colorScheme.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      "Enter the username of the user for whom the dish is created.",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),
                            ],
                          )
                        // Date and time selection for ordering a dish
                        else if (!widget.isEditable)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Text(
                                    'Select pickup date and time:',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ),
                              Divider(
                                height: 1,
                                thickness: 1,
                                color: colorScheme.onSurface,
                              ),
                              const SizedBox(height: 10),

                              DateTimePickerWidget(
                                maxDateDays: minForewarningDays,
                                onDateTimeSelected: (dateTime) {
                                  setState(() {
                                    _selectedDateTime = dateTime;
                                  });
                                  debugPrint(
                                    "Selected date and time: $_selectedDateTime",
                                  );
                                },
                              ),

                              const SizedBox(height: 40),
                            ],
                          ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (!widget.isNew)
                              widget.isEditable
                                  ? CircularButton(
                                    icon: Icons.delete,
                                    iconColor: colorScheme.error,
                                    backgroundColor: colorScheme.errorContainer
                                        .withOpacity(0.3),
                                    size: 50,
                                    bottomPadding: 0,
                                    onPressed: _deleteDish,
                                  )
                                  : CircularButton(
                                    icon: Icons.add,
                                    iconColor: colorScheme.onPrimary,
                                    backgroundColor: colorScheme.primary,
                                    size: 50,
                                    bottomPadding: 0,
                                    onPressed: () async {
                                      if (_selectedDateTime == null) {
                                        CustomAlertDialog.showInfoDialog(
                                          context: context,
                                          title: "Warning",
                                          message:
                                              "Select a date and time to proceed.",
                                          icon: Icon(
                                            Icons.warning_amber_rounded,
                                            color: colorScheme.error,
                                          ),
                                        );
                                        return;
                                      }

                                      if (_dish == null) return;

                                      // Fetch the latest dish data from Firebase to verify availability
                                      final dishProvider =
                                          Provider.of<DishProvider>(
                                            context,
                                            listen: false,
                                          );

                                      final restaurantId =
                                          dishProvider.currentRestaurantId;
                                      if (restaurantId == null) {
                                        CustomAlertDialog.showInfoDialog(
                                          context: context,
                                          title: "Error",
                                          message:
                                              "Restaurant information is missing.",
                                          icon: Icon(
                                            Icons.error_outline,
                                            color: colorScheme.error,
                                          ),
                                        );
                                        return;
                                      }

                                      await dishProvider.fetchDishes(
                                        restaurantId,
                                      );
                                      final latestDish = dishProvider
                                          .getDishById(_dish!.id);

                                      if (latestDish == null) {
                                        CustomAlertDialog.showInfoDialog(
                                          context: context,
                                          title: "Error",
                                          message:
                                              "The dish is no longer available.",
                                          icon: Icon(
                                            Icons.error_outline,
                                            color: colorScheme.error,
                                          ),
                                        );
                                        return;
                                      }

                                      // Check availability from Firebase data
                                      if (latestDish.isAvailable != true) {
                                        CustomAlertDialog.showInfoDialog(
                                          context: context,
                                          title: "Warning",
                                          message: "The dish is not available.",
                                          icon: Icon(
                                            Icons.warning_amber_rounded,
                                            color: colorScheme.error,
                                          ),
                                        );
                                        return;
                                      }

                                      final userProvider =
                                          Provider.of<UserProvider>(
                                            context,
                                            listen: false,
                                          );
                                      final orderProvider =
                                          Provider.of<OrderProvider>(
                                            context,
                                            listen: false,
                                          );

                                      orderProvider.setContext(context);

                                      orderProvider
                                          .addOrder(
                                            userId:
                                                userProvider.userData?.id ?? '',
                                            username:
                                                userProvider
                                                    .userData
                                                    ?.username ??
                                                '',
                                            dishId: latestDish.id,
                                            dishName: latestDish.name,
                                            dishPrice: latestDish.price,
                                            pickupDateTime: _selectedDateTime!,
                                          )
                                          .then((_) {
                                            CustomAlertDialog.showInfoDialog(
                                              context: context,
                                              title: "Dish sent to cart",
                                              message:
                                                  "The dish \"${latestDish.name}\" has been correctly added to your cart.",
                                              icon: Icon(
                                                Icons.check_circle,
                                                color: colorScheme.primary,
                                              ),
                                              buttonText: "OK",
                                            );
                                          })
                                          .catchError((error) {
                                            CustomAlertDialog.showInfoDialog(
                                              context: context,
                                              title: "Error",
                                              message:
                                                  orderProvider.errorMessage ??
                                                  "Something went wrong. Try again later.",
                                              icon: Icon(
                                                Icons.error_outline,
                                                color: colorScheme.error,
                                              ),
                                            );
                                          });
                                    },
                                  ),

                            const SizedBox(width: 20),

                            widget.isEditable
                                ? _buildEditablePrice(colorScheme)
                                : _buildPrice(colorScheme),

                            if (widget.isEditable)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(width: 20),

                                  CircularNumberInput(
                                    size: 50.0,
                                    initialValue: minForewarningDays,
                                    onNumberSubmitted: (value) {
                                      _currentMinForewarningDays = value;
                                      _checkForChanges();
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
          ),
        );
      },
    );
  }

  Widget _buildImage(ColorScheme colorScheme) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: colorScheme.surface,
          child:
              imageUrl != null && imageUrl!.isNotEmpty
                  ? ClipOval(
                    child: Image.network(
                      imageUrl!,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Icon(
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
            isEditable: false,
            size: 40,
            symbolResize: 0.6,
            onToggle: null,
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
          backgroundColor: colorScheme.surfaceContainerHighest,
          child:
              _imageFile != null
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
                      errorBuilder:
                          (context, error, stackTrace) => Icon(
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
              debugPrint("Availability changed: $value");
              setState(() {
                _availabilityStatus = value;
              });

              if (widget.dishId != null) {
                final dishProvider = Provider.of<DishProvider>(
                  context,
                  listen: false,
                );
                final restaurantId = dishProvider.currentRestaurantId;

                if (restaurantId != null) {
                  dishProvider.updateDishAvailability(
                    restaurantId,
                    widget.dishId!,
                    value,
                  );
                }
              }

              widget.onAvailabilityChanged?.call(value);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildName(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            dishName,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildEditableName(ColorScheme colorScheme) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color:
                  _currentFocus == 'name'
                      ? colorScheme.primary
                      : Colors.transparent,
              width: 2,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: TextField(
            controller: _nameController,
            focusNode: _nameFocus,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
            onSubmitted: (_) {
              _currentName = _nameController.text;
              _nameFocus.unfocus();
              _checkForChanges();
            },
          ),
        ),
        if (_nameError != null)
          Text(
            _nameError!,
            style: TextStyle(color: colorScheme.error, fontSize: 12),
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
              color:
                  _currentFocus == 'description'
                      ? colorScheme.primary
                      : Colors.transparent,
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: TextField(
            controller: _descriptionController,
            focusNode: _descriptionFocus,
            textAlign: TextAlign.left,
            maxLines: 4,
            style: TextStyle(fontSize: 16, color: colorScheme.onSurface),
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
            onSubmitted: (_) {
              _currentDescription = _descriptionController.text;
              _descriptionFocus.unfocus();
              _checkForChanges();
            },
          ),
        ),
        if (_descriptionError != null)
          Text(
            _descriptionError!,
            style: TextStyle(color: colorScheme.error, fontSize: 12),
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
              color:
                  _currentFocus == 'price'
                      ? colorScheme.primary
                      : Colors.transparent,
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
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
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
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) {
                    _currentPrice = _parsePrice();
                    _priceFocus.unfocus();
                    _checkForChanges();
                  },
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
              style: TextStyle(color: colorScheme.error, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildDescription(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            description,
            style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.left,
            maxLines: 4,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildPrice(ColorScheme colorScheme) {
    if (price == null) {
      return Text(
        'Price not set',
        style: TextStyle(
          fontSize: 18,
          fontStyle: FontStyle.italic,
          color: colorScheme.onSurfaceVariant,
        ),
      );
    }

    return PriceTag(price: price!, height: 60, width: 120);
  }

  Future<String?> _validateUsername(String value) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Control for emptiness
    if (value.isEmpty) {
      return "The username cannot be empty";
    }

    // Check for character types
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return "The username can only contain letters, numbers, and underscores";
    }

    // Verify uniqueness
    final isTaken = await userProvider.isUsernameTaken(value, notify: false);
    if (!isTaken) {
      return "No user found with this username";
    }

    return null;
  }
}
