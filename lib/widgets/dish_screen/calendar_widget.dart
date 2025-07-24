import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sous_chef/themes/theme_extensions.dart';

import '../animated_button.dart';
import '../personalized_button.dart';

class DateTimePickerWidget extends StatefulWidget {
  final int maxDateDays;
  final void Function(DateTime selectedDateTime) onDateTimeSelected;

  const DateTimePickerWidget({
    super.key,
    required this.maxDateDays,
    required this.onDateTimeSelected,
  });

  @override
  State<DateTimePickerWidget> createState() => _DateTimePickerWidgetState();
}

class _DateTimePickerWidgetState extends State<DateTimePickerWidget> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  final FocusNode _focusNode = FocusNode();
  bool _hasFocus = false;
  bool _isSelecting = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _hasFocus = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  bool get hasSelection => selectedDate != null && selectedTime != null;

  List<TimeOfDay> _generateAvailableTimes(DateTime date) {
    final now = DateTime.now();
    final List<TimeOfDay> times = [];

    int startHour = 0;
    int startMinute = 0;

    if (_isToday(date)) {
      startHour = now.hour;
      startMinute = now.minute;
      if (startMinute >= 30) {
        startHour += 1;
        startMinute = 0;
      } else {
        startMinute = 30;
      }
    }

    for (int hour = startHour; hour < 24; hour++) {
      for (int minute in [0, 30]) {
        if (hour == startHour && minute < startMinute) continue;
        times.add(TimeOfDay(hour: hour, minute: minute));
      }
    }

    return times;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  void _showDatePicker() async {
    setState(() {
      _isSelecting = true;
    });
    _focusNode.requestFocus();

    DateTime now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(Duration(days: widget.maxDateDays)),
      builder: (context, child) {
        final colorScheme = Theme.of(context).colorScheme;
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: colorScheme.copyWith(
              primary: colorScheme.primary,
              onPrimary: colorScheme.onPrimary,
              onSurface: colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        selectedTime = null;
      });
      _showTimePicker(_generateAvailableTimes(picked));
    } else {
      setState(() {
        _isSelecting = false;
        _focusNode.unfocus();
      });
    }
  }

  void _showTimePicker(List<TimeOfDay> times) {
    if (times.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nessun orario disponibile per questa data")),
      );
      setState(() {
        _isSelecting = false;
        _focusNode.unfocus();
      });
      return;
    }

    int initialIndex = 0;
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;

        TimeOfDay tempTime = times.first;
        return Container(
          height: 300,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 40,
                  scrollController:
                  FixedExtentScrollController(initialItem: initialIndex),
                  onSelectedItemChanged: (index) {
                    tempTime = times[index];
                  },
                  children: times
                      .map((t) =>
                        Center(child: Text("${t.hour}:${t.minute.toString().padLeft(2, '0')}",
                        style: TextStyle(color: colorScheme.onSurface)))
                      ).toList(),
                ),
              ),
              AnimatedButton(
                onTap: () {
                  Navigator.of(context).pop();
                  setState(() {
                    selectedTime = tempTime;
                    _focusNode.unfocus();
                    _isSelecting = false;
                  });
                  final dt = DateTime(
                    selectedDate!.year,
                    selectedDate!.month,
                    selectedDate!.day,
                    tempTime.hour,
                    tempTime.minute,
                  );
                  widget.onDateTimeSelected(dt);
                },
                child: PersonalizedButton(
                  text: "Confirm Time",
                  onPressed: null, // Button press is handled by AnimatedButton
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    ).then((_) {
      if (selectedTime == null) {
        setState(() {
          _isSelecting = false;
          _focusNode.unfocus();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Focus(
      focusNode: _focusNode,
      child: GestureDetector(
        onTap: () {
          _focusNode.requestFocus();
          _showDatePicker();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: colorScheme.darkGrayBackground,
            border: (_hasFocus || _isSelecting)
                ? Border.all(color: colorScheme.primary, width: 2)
                : null,
            boxShadow: (_hasFocus || _isSelecting) ? null : [
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                hasSelection
                    ? '${DateFormat.yMMMd().format(selectedDate!)} alle ${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}'
                    : "Select Date & Time",
                style: TextStyle(color: colorScheme.onSurface),
              ),
              Icon(Icons.calendar_today, size: 20, color: colorScheme.onSurface),
            ],
          ),
        ),
      ),
    );
  }
}