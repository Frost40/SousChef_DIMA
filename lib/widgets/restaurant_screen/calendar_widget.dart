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

        class _CalendarWidgetState extends State<CalendarWidget> {
          late DateTime _selectedDateTime;
          final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
          final DateFormat _timeFormat = DateFormat('HH:mm');

          @override
          void initState() {
            super.initState();
            _selectedDateTime = widget.initialDateTime;
          }

          Future<void> _selectDateTime() async {
            DateTime? date = await showDatePicker(
              context: context,
              initialDate: _selectedDateTime,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(Duration(days: widget.maxDays)),
            );
            if (date == null) return;

            TimeOfDay? time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
              initialEntryMode: TimePickerEntryMode.dial,
            );
            if (time == null) return;

            final newDateTime = DateTime(
              date.year,
              date.month,
              date.day,
              time.hour,
              time.minute,
            );

            setState(() {
              _selectedDateTime = newDateTime;
            });
            widget.onChanged?.call(newDateTime);
          }

          @override
          Widget build(BuildContext context) {
            final dateText = _dateFormat.format(_selectedDateTime);
            final timeText = _timeFormat.format(_selectedDateTime);

            return InkWell(
              onTap: widget.isEditable ? _selectDateTime : null,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$dateText - $timeText',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            );
          }
        }