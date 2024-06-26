import 'package:flutter/material.dart';

class DropdownListButton extends StatefulWidget {
  const DropdownListButton({
    super.key,
    required this.choices,
    required this.icons,
    required this.selected,
    required this.onChanged,
  });

  final List<String> choices;
  final List<IconData> icons;
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
      borderRadius: BorderRadius.circular(16),
      dropdownColor: Theme.of(context).colorScheme.onPrimary,
      alignment: Alignment.center,
      icon: const Icon(Icons.arrow_drop_down),
      elevation: 16,
      hint: const Text('Not selected'),
      style: const TextStyle(
        color: Colors.black,
        fontSize: 20,
      ),
      onChanged: widget.onChanged,
      items: widget.choices.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(widget.icons[widget.choices.indexOf(value)]),
              const SizedBox(
                width: 16,
              ),
              Text(
                value,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
