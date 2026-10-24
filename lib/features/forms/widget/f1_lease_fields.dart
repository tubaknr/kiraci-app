import 'package:flutter/material.dart';

class F1TextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? errorText;
  final TextInputType keyboardType;
  final int maxLines;

  const F1TextFormField({
    super.key,
    required this.controller,
    required this.label,
    this.errorText,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          errorText: errorText,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

class F1DateFormField extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final String? errorText;
  final VoidCallback onTap;

  const F1DateFormField({
    super.key,
    required this.label,
    required this.selectedDate,
    this.errorText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayText = selectedDate != null
        ? '${selectedDate!.day.toString().padLeft(2, '0')}.${selectedDate!.month.toString().padLeft(2, '0')}.${selectedDate!.year}'
        : 'Tarih seçin';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: onTap,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            errorText: errorText,
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          child: Text(displayText),
        ),
      ),
    );
  }
}
