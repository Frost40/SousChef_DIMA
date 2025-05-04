import 'package:flutter/material.dart';
import 'package:sous_chef/themes/theme_extensions.dart';

class NavigationTabbar extends StatefulWidget {
  /// Number of elements in the tab bar
  final int tabCount;

  /// Labels to display for each tab
  final List<String> tabLabels;

  /// Height of the tab bar
  final double height;

  /// Horizontal margin from the parent
  final EdgeInsets margin;

  /// Corner radius
  final double radius;

  /// Callback function when a tab is selected
  final Function(int)? onTabSelected;

  /// Initially selected tab index
  final int initialIndex;

  const NavigationTabbar({
    super.key,
    this.tabCount = 3,
    this.tabLabels = const ['Tab', 'Tab', 'Tab'],
    this.height = 50.0,
    this.margin = EdgeInsets.zero,
    this.radius = 25.0,
    this.onTabSelected,
    this.initialIndex = 0,
  }) : assert(tabCount == tabLabels.length, 'The number of tabs must match the number of labels');

  @override
  State<NavigationTabbar> createState() => _NavigationTabbarState();
}

class _NavigationTabbarState extends State<NavigationTabbar> {
  late TabController _tabController;

  void _handleTabSelection() {
    if (!_tabController.indexIsChanging && widget.onTabSelected != null) {
      widget.onTabSelected!(_tabController.index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: widget.tabCount,
      initialIndex: widget.initialIndex,
      child: Builder(
        builder: (context) {
          _tabController = DefaultTabController.of(context);

          // Remove listener to avoid multiple calls
          _tabController.removeListener(_handleTabSelection);
          _tabController.addListener(_handleTabSelection);

          return Container(
            margin: widget.margin,
            child: PrimaryContainer(
              radius: widget.radius,
              height: widget.height,
              // Use surface color for the container background
              color: colorScheme.darkGrayBackground,
              // Add border in dark mode using surfaceContainerHighest
              border: isDarkMode ? Border.all(
                color: colorScheme.surfaceContainerHighest,
                width: 0.5,
              ) : null,
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorColor: Colors.transparent,
                dividerColor: Colors.transparent,
                // Use onSurface color for unselected text
                unselectedLabelColor: colorScheme.onSurface,
                // Keep default white text for selected tab since background is darker
                labelColor: colorScheme.onPrimary,
                indicator: BoxDecoration(
                  // Use primary for the selected tab background
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(widget.radius),
                ),
                tabs: List.generate(
                  widget.tabCount,
                  (index) => Tab(
                    text: widget.tabLabels[index],
                    height: widget.height - 10,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    // Remove the listener when the widget is destroyed
    _tabController.removeListener(_handleTabSelection);
    super.dispose();
  }
}

// dart
class PrimaryContainer extends StatelessWidget {
  final Widget child;
  final double? radius;
  final double? height;
  final Color? color;
  final BoxBorder? border;

  const PrimaryContainer({
    super.key,
    this.radius,
    this.color,
    this.height,
    this.border,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Material(
        elevation: 2,
        color: color ?? colorScheme.darkGrayBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius ?? 30),
        ),
        clipBehavior: Clip.none,
        child: SizedBox(
          height: height,
          child: child,
        ),
      ),
    );
  }
}