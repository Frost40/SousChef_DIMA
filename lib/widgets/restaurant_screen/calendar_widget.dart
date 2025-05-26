import 'package:flutter/cupertino.dart';
            import 'package:flutter/material.dart';
            import 'package:intl/intl.dart';

            class CalendarWidget extends StatefulWidget {
              final bool isEditable;
              final int maxDays;
              final DateTime initialDateTime;
              final ValueChanged<DateTime>? onChanged;

              const CalendarWidget({
                Key? key,
                this.isEditable = true,
                this.maxDays = 30,
                required this.initialDateTime,
                this.onChanged,
              }) : super(key: key);

              @override
              _CalendarWidgetState createState() => _CalendarWidgetState();
            }

            // dart
            class _CalendarWidgetState extends State<CalendarWidget> {
              late DateTime _selectedDateTime;
              late DateTime _minDate;
              final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

              @override
              void initState() {
                super.initState();
                final now = DateTime.now();
                _minDate = now;
                _selectedDateTime = widget.initialDateTime.isBefore(now) ? now : widget.initialDateTime;
              }

              void _selectDate() {
                if (!widget.isEditable) return;

                showCupertinoModalPopup(
                  context: context,
                  builder: (_) => Container(
                    height: 250,
                    color: Colors.white,
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      minimumDate: _minDate,
                      maximumDate: _minDate.add(Duration(days: widget.maxDays)),
                      initialDateTime: _selectedDateTime,
                      onDateTimeChanged: (DateTime newDate) {
                        setState(() {
                          _selectedDateTime = newDate;
                        });
                        widget.onChanged?.call(newDate);
                      },
                    ),
                  ),
                );
              }

              @override
              Widget build(BuildContext context) {
                final dateText = _dateFormat.format(_selectedDateTime);

                return GestureDetector(
                  onTap: widget.isEditable ? _selectDate : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        dateText,
                        style: const TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                    ),
                  ),
                );
              }
            }