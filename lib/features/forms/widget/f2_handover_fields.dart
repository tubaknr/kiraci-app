import 'package:flutter/material.dart';
import '../models/f2_handover_data.dart';

class RoomConditionTile extends StatelessWidget {
  final RoomCondition room;
  final VoidCallback onRemove;

  const RoomConditionTile({
    super.key,
    required this.room,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          room.hasDamage ? Icons.warning_amber : Icons.check_circle_outline,
          color: room.hasDamage ? Colors.orange : Colors.green,
        ),
        title: Text(room.roomName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          '${room.conditionNote}${room.hasDamage ? " (Hasar/Kusur Var)" : ""}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: onRemove,
        ),
      ),
    );
  }
}

class MeterInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? errorText;
  final IconData icon;

  const MeterInputField({
    super.key,
    required this.controller,
    required this.label,
    this.errorText,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          errorText: errorText,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
