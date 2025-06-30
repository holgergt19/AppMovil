import 'package:flutter/material.dart';

class RoleSelector extends StatefulWidget {
  final ValueChanged<String> onRoleSelected;

  const RoleSelector({Key? key, required this.onRoleSelected})
    : super(key: key);

  @override
  _RoleSelectorState createState() => _RoleSelectorState();
}

class _RoleSelectorState extends State<RoleSelector> {
  String selected = 'user';

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ChoiceChip(
          label: const Text('Pasajero'),
          selected: selected == 'user',
          onSelected: (_) {
            setState(() => selected = 'user');
            widget.onRoleSelected('user');
          },
        ),
        ChoiceChip(
          label: const Text('Conductor'),
          selected: selected == 'driver',
          onSelected: (_) {
            setState(() => selected = 'driver');
            widget.onRoleSelected('driver');
          },
        ),
      ],
    );
  }
}
