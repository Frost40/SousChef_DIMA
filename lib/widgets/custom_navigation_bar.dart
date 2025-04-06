import 'package:flutter/material.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';

class CustomNavBar extends StatefulWidget {
  final int initialIndex;
  final Function(int) onTap;

  const CustomNavBar({
    super.key,
    this.initialIndex = 0,
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
    return StylishBottomBar(
      option: AnimatedBarOptions(
        barAnimation: BarAnimation.fade,
        iconStyle: IconStyle.animated,
      ),
      items: [
        BottomBarItem(
          icon: const Icon(Icons.home_rounded),
          title: Text('Home', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          selectedIcon: Icon(Icons.home_rounded, color: Theme.of(context).colorScheme.primary),
        ),
        BottomBarItem(
          icon: const Icon(Icons.receipt_long_rounded),
          title: Text('Orders', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          selectedIcon: Icon(Icons.receipt_long_rounded, color: Theme.of(context).colorScheme.primary),
        ),
        BottomBarItem(
          icon: const Icon(Icons.favorite_rounded),
          title: Text('Favorites', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          selectedIcon: Icon(Icons.favorite_rounded, color: Theme.of(context).colorScheme.primary),
        ),
        BottomBarItem(
          icon: const Icon(Icons.person_rounded),
          title: Text('Account', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          selectedIcon: Icon(Icons.person_rounded, color: Theme.of(context).colorScheme.primary),
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