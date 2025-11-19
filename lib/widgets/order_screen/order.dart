import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sous_chef/models/order.dart';
import 'package:sous_chef/themes/theme_extensions.dart';
import 'package:sous_chef/widgets/restaurant_screen/price_tag.dart';

class OrderTile extends StatefulWidget {
  final String restaurantName;
  final String restaurantId;
  final List<OrderItem> dishes;
  final DateTime dateTime;
  final double price;
  final Widget? pageSpecificWidget;
  final bool initiallyExpanded;
  final String? restaurantAddress;

  const OrderTile({
    super.key,
    required this.restaurantName,
    required this.restaurantId,
    required this.dishes,
    required this.dateTime,
    required this.price,
    this.pageSpecificWidget,
    this.initiallyExpanded = false,
    this.restaurantAddress,
  });

  @override
  State<OrderTile> createState() => _OrderTileState();
}

class _OrderTileState extends State<OrderTile>
    with SingleTickerProviderStateMixin {
  late bool isExpanded;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    if (isExpanded) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      isExpanded = !isExpanded;
      if (isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      color: colorScheme.darkGrayBackground,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: InkWell(
        onTap: _toggleExpand,
        borderRadius: BorderRadius.circular(25),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Restaurant Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              '/restaurant',
                              arguments: {'restaurantId': widget.restaurantId},
                            );
                          },
                          child: Text(
                            widget.restaurantName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              decorationColor: colorScheme.primary,
                              color: colorScheme.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Pickup • ${DateFormat('MMM d, yyyy').format(widget.dateTime.toLocal())} at ${DateFormat('HH:mm').format(widget.dateTime.toLocal())}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            fontStyle: FontStyle.italic,
                            color: colorScheme.onSurface,
                          ),
                        ),

                        if (widget.restaurantAddress != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Address • ${widget.restaurantAddress!}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                              color: colorScheme.onSurface,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Custom or Default Button
                  if (widget.pageSpecificWidget != null)
                    widget.pageSpecificWidget!,
                ],
              ),

              const SizedBox(height: 8),
              Divider(height: 1, thickness: 1, color: colorScheme.onSurface),

              // Expandable Dish List
              SizeTransition(
                sizeFactor: _expandAnimation,
                axisAlignment: -1.0,
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 85,
                      child:
                          widget.dishes.length <= 3
                              ? Column(
                                children:
                                    widget.dishes.map((dish) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 4.0,
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              '${dish.quantity}x',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                dish.name,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Text(
                                              '€${dish.price.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                              )
                              : ListView.builder(
                                shrinkWrap: true,
                                itemCount: widget.dishes.length,
                                itemBuilder: (context, index) {
                                  final dish = widget.dishes[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4.0,
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          '${dish.quantity}x',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            dish.name,
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          '€${dish.price.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),

              Divider(height: 1, thickness: 1, color: colorScheme.onSurface),
              const SizedBox(height: 8),

              // Total Price Row (always visible)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  PriceTag(price: widget.price),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
