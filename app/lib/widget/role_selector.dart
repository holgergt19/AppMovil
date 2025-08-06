import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Selector de rol con gradientes cromados rojo y amarillo
class RoleSelector extends StatefulWidget {
  final ValueChanged<String> onRoleSelected;
  const RoleSelector({Key? key, required this.onRoleSelected})
    : super(key: key);

  @override
  _RoleSelectorState createState() => _RoleSelectorState();
}

class _RoleSelectorState extends State<RoleSelector> {
  String _selected = 'user';
  final _options = [
    {'key': 'user', 'label': 'Pasajero'},
    {'key': 'driver', 'label': 'Conductor'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Gradientes cromados:
    final chromeRed = AppTheme.secondary;
    final chromeRedLight = chromeRed.withOpacity(0.7);
    final chromeYellow = theme.colorScheme.secondary;
    final chromeYellowLight = theme.colorScheme.secondaryContainer;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children:
          _options.map((opt) {
            final key = opt['key']!;
            final label = opt['label']!;
            final isSelected = _selected == key;

            final gradientColors =
                key == 'user'
                    ? [chromeRedLight, chromeRed] // Pasajero = rojo cromado
                    : [
                      chromeYellowLight,
                      chromeYellow,
                    ]; // Conductor = amarillo cromado

            return GestureDetector(
              onTap: () {
                setState(() => _selected = key);
                widget.onRoleSelected(key);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  gradient:
                      isSelected
                          ? LinearGradient(
                            colors: gradientColors,
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          )
                          : null,
                  color:
                      isSelected
                          ? null
                          : theme.colorScheme.surfaceVariant.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color:
                        isSelected
                            ? Colors.transparent
                            : theme.colorScheme.onSurface.withOpacity(0.3),
                    width: 1.2,
                  ),
                  boxShadow:
                      isSelected
                          ? [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                          : null,
                ),
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    color:
                        isSelected
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }
}
