import 'package:flutter/material.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';

class CustomNavBar extends StatefulWidget {
  final int initialIndex;
  final bool restaurantOwner;
  final Function(int) onTap;

  const CustomNavBar({
    super.key,
    this.initialIndex = 0,
    required this.restaurantOwner,
    required this.onTap,
  });

  @override
  State<CustomNavBar> createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  void didUpdateWidget(CustomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When restaurantOwner status changes, validate the selected index
    final maxIndex = widget.restaurantOwner ? 4 : 3;
    if (_selectedIndex > maxIndex) {
      _selectedIndex = 0;
    }
    // Also update if initialIndex changed from parent
    if (widget.initialIndex != oldWidget.initialIndex) {
      _selectedIndex = widget.initialIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorTheme = Theme.of(context).colorScheme;

    return StylishBottomBar(
      option: AnimatedBarOptions(
        barAnimation: BarAnimation.fade,
        iconStyle: IconStyle.animated,
      ),
      items: [
        BottomBarItem(
          icon: const Icon(Icons.home_rounded),
          title: Text('Home', style: TextStyle(color: colorTheme.primary)),
          backgroundColor: colorTheme.surfaceContainerHighest,
          selectedIcon: Icon(Icons.home_rounded, color: colorTheme.primary),
        ),
        BottomBarItem(
          icon: const Icon(Icons.receipt_long_rounded),
          title: Text('Orders', style: TextStyle(color: colorTheme.primary)),
          backgroundColor: colorTheme.surfaceContainerHighest,
          selectedIcon: Icon(
            Icons.receipt_long_rounded,
            color: colorTheme.primary,
          ),
        ),
        if (widget.restaurantOwner)
          BottomBarItem(
            icon: const Icon(Icons.restaurant_menu_rounded),
            title: Text(
              'Restaurant',
              style: TextStyle(color: colorTheme.primary),
            ),
            backgroundColor: colorTheme.surfaceContainerHighest,
            selectedIcon: Icon(
              Icons.restaurant_menu_rounded,
              color: colorTheme.primary,
            ),
          ),
        BottomBarItem(
          icon: const Icon(Icons.favorite_rounded),
          title: Text('Favorites', style: TextStyle(color: colorTheme.primary)),
          backgroundColor: colorTheme.surfaceContainerHighest,
          selectedIcon: Icon(Icons.favorite_rounded, color: colorTheme.primary),
        ),
        BottomBarItem(
          icon: const Icon(Icons.person_rounded),
          title: Text('Account', style: TextStyle(color: colorTheme.primary)),
          backgroundColor: colorTheme.surfaceContainerHighest,
          selectedIcon: Icon(Icons.person_rounded, color: colorTheme.primary),
        ),
      ],
      currentIndex: _selectedIndex,
      onTap: (index) {
        widget.onTap(index);

        setState(() {
          _selectedIndex = index;
        });
      },
      backgroundColor: Theme.of(context).colorScheme.surface,
    );
  }
}
