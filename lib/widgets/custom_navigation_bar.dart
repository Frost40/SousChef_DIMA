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
          selectedIcon: Icon(Icons.home_rounded, color:colorTheme.primary),
        ),
        BottomBarItem(
          icon: const Icon(Icons.receipt_long_rounded),
          title: Text('Orders', style: TextStyle(color: colorTheme.primary)),
          backgroundColor: colorTheme.surfaceContainerHighest,
          selectedIcon: Icon(Icons.receipt_long_rounded, color: colorTheme.primary),
        ),
        if (widget.restaurantOwner)
          BottomBarItem(
            icon: const Icon(Icons.restaurant_menu_rounded),
            title: Text('Restaurant', style: TextStyle(color: colorTheme.primary)),
            backgroundColor: colorTheme.surfaceContainerHighest,
            selectedIcon: Icon(Icons.restaurant_menu_rounded, color: colorTheme.primary),
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
        setState(() {
          _selectedIndex = index;
        });
        widget.onTap(index);
      },
      backgroundColor: Theme.of(context).colorScheme.surface,
    );
  }
}