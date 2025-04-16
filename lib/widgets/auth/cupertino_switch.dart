import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomSwitch extends StatefulWidget {
  final bool? initialValue;
  final ValueChanged<bool>? onChanged;

  const CustomSwitch({super.key, this.initialValue, this.onChanged});

  @override
  State<CustomSwitch> createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch> {
  late bool _switchValue;

  @override
  void initState() {
    super.initState();
    // Se viene fornito un valore iniziale, usalo, altrimenti default a true
    _switchValue = widget.initialValue ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoSwitch(
      value: _switchValue,
      activeTrackColor: Theme.of(context).colorScheme.primary,
      onChanged: (value) {
        setState(() {
          _switchValue = value;
        });
        // Se è stato fornito un callback onChanged, chiamalo
        widget.onChanged?.call(value);
      },
    );
  }
}
