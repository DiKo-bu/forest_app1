// lib/widgets/task_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/forest_task.dart';
import '../utils/app_localization.dart';

class TaskCard extends StatelessWidget {
  final ForestTask task;
  final String lang;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool?> onToggleDone;

  const TaskCard({
    super.key,
    required this.task,
    required this.lang,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleDone,
  });

  String _tr(String key) => AppLocalization.tr(lang, key);

  @override
  Widget build(BuildContext context) {
    String dateStr = '${DateFormat('dd.MM').format(task.startDate)} - ${DateFormat('dd.MM').format(task.endDate)}';
    String subtitleText = '${task.sector} • $dateStr';
    
    if (task.type == 'Посадка') {
      subtitleText += '\n${_tr(task.cultureType ?? "")} • ${task.plantingQuantity ?? 0} ${_tr('pcs')} • ${task.plantingArea ?? 0} ${_tr('ha')}';
    } else if (task.type == 'Вырубка') {
      subtitleText += '\n${task.cuttingVolume ?? 0} ${_tr('cubes')} • ${task.cuttingArea ?? 0} ${_tr('ha')}';
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        onTap: onEdit,
        leading: CircleAvatar(
          backgroundColor: task.isDone ? Colors.grey : Colors.green.shade100,
          child: Icon(
            task.type == 'Посадка' ? Icons.park : (task.type == 'Вырубка' ? Icons.content_cut : Icons.assignment), 
            color: Colors.green.shade800
          ),
        ),
        title: Text(task.title, style: TextStyle(decoration: task.isDone ? TextDecoration.lineThrough : null)),
        subtitle: Text(subtitleText), 
        isThreeLine: task.type == 'Посадка' || task.type == 'Вырубка', 
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              activeColor: Colors.green,
              value: task.isDone,
              onChanged: onToggleDone,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
