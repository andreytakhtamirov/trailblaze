import 'package:flutter/material.dart';

class DropdownListButton extends StatefulWidget {
  const DropdownListButton({
    super.key,
    required this.choices,
    required this.selected,
    required this.onChanged,
  });

  final List<String> choices;
  final String? selected;
  final Function(String? value) onChanged;

  @override
  State<DropdownListButton> createState() => _DropdownListButtonState();
}

class _DropdownListButtonState extends State<DropdownListButton> {
  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: widget.selected,
      icon: const Icon(Icons.arrow_drop_down),
      elevation: 16,
      hint: const Text('Not selected'),
      style: const TextStyle(color: Colors.black, fontSize: 14),
      underline: Container(
        height: 2,
        color: Theme.of(context).colorScheme.primary,
      ),
      onChanged: widget.onChanged,
      items: widget.choices.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
