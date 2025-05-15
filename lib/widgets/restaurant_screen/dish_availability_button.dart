import 'package:flutter/material.dart';

      class DishAvailabilityButton extends StatefulWidget {
        final bool initialValue;
        final bool isEditable;
        final double size;
        final double symbolResize;
        final Function(bool)? onToggle;

        const DishAvailabilityButton({
          super.key,
          required this.initialValue,
          this.isEditable = true,
          this.size = 24,
          this.symbolResize = 0.8,
          this.onToggle,
        });

        @override
        State<DishAvailabilityButton> createState() => _DishAvailabilityButton();
      }

      class _DishAvailabilityButton extends State<DishAvailabilityButton> {
        late bool _isAvailable;

        @override
        void initState() {
          super.initState();
          _isAvailable = widget.initialValue;
        }

        @override
        void didUpdateWidget(DishAvailabilityButton oldWidget) {
          super.didUpdateWidget(oldWidget);
          if (widget.initialValue != oldWidget.initialValue) {
            _isAvailable = widget.initialValue;
          }
        }

        void _handleToggle() {
          if (!widget.isEditable) return;

          setState(() {
            _isAvailable = !_isAvailable;
          });

          if (widget.onToggle != null) {
            widget.onToggle!(_isAvailable);
          }
        }

        @override
        Widget build(BuildContext context) {
          return GestureDetector(
            onTap: _handleToggle,
            child: _isAvailable
              ? Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                  ),
                  width: widget.size,
                  height: widget.size,
                  child: Center(
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: widget.size * widget.symbolResize,
                    ),
                  ),
                )
              : Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                  width: widget.size,
                  height: widget.size,
                  child: Center(
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: widget.size * widget.symbolResize,
                    ),
                  ),
                ),
          );
        }
      }