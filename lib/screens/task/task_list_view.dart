import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/forest_task.dart';
import '../../utils/app_localization.dart';

class TaskListView extends StatelessWidget {
  final List<ForestTask> tasks;
  final String currentLang;
  final String currentFilter;
  final Function(String) onFilterChanged;
  final Function(int) onDelete;
  final Function(int, bool?) onToggleDone;
  final Function(ForestTask) onSaveTask;
  final Function({int? editIndex}) onShowDialog;

  const TaskListView({
    super.key,
    required this.tasks,
    required this.currentLang,
    required this.currentFilter,
    required this.onFilterChanged,
    required this.onDelete,
    required this.onToggleDone,
    required this.onSaveTask,
    required this.onShowDialog,
  });

  String _tr(String key) => AppLocalization.tr(currentLang, key);

  @override
  Widget build(BuildContext context) {
    final allTypes = tasks.map((t) => t.type).toSet().toList()..sort();
    final filters = ['Все', ...allTypes.where((t) => t != 'Все')];
    final displayTasks = currentFilter == 'Все'
        ? tasks
        : tasks.where((t) => t.type == currentFilter).toList();

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: filters.map((filter) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(_tr(filter)),
                  selected: currentFilter == filter,
                  selectedColor: Colors.green.shade200,
                  onSelected: (_) => onFilterChanged(filter),
                ),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: displayTasks.isEmpty
              ? Center(child: Text(_tr('no_tasks')))
              : ListView.builder(
                  itemCount: displayTasks.length,
                  itemBuilder: (context, index) {
                    final task = displayTasks[index];
                    String dateStr = '${DateFormat('dd.MM').format(task.startDate)} - ${DateFormat('dd.MM').format(task.endDate)}';
                    String subtitleText = '${task.sector} • $dateStr';
                    // детализация по типам
                    if (task.type == 'Посадка') {
                      subtitleText += '\n${_tr(task.cultureType ?? '')} • ${task.plantingQuantity ?? 0} ${_tr('pcs')} • ${task.plantingArea ?? 0} ${_tr('ha')}';
                      if (task.location != null) subtitleText += ' • ${task.location}';
                    } else if (task.type == 'Посев') {
                      subtitleText += '\n${task.sowingBreed ?? ''} • ${task.sowingQuantityKg ?? 0} кг • ${task.sowingAreaHa ?? 0} га';
                      if (task.location != null) subtitleText += ' • ${task.location}';
                    } else if (task.type == 'Выборочная санитарная рубка') {
                      subtitleText += '\nПлощадь: ${task.selectiveCuttingArea ?? 0} га, Объём: ${task.selectiveCuttingVolume ?? 0} м³';
                      if (task.quarter != null) subtitleText += ' • Кв. ${task.quarter}';
                      if (task.allotment != null) subtitleText += ' • Выд. ${task.allotment}';
                    } else if (task.type == 'Сплошная санитарная рубка') {
                      subtitleText += '\nПлощадь: ${task.clearCuttingArea ?? 0} га, Объём: ${task.clearCuttingVolume ?? 0} м³';
                      if (task.quarter != null) subtitleText += ' • Кв. ${task.quarter}';
                      if (task.allotment != null) subtitleText += ' • Выд. ${task.allotment}';
                    } else if (task.type == 'Уборка захламленности') {
                      subtitleText += '\nПлощадь: ${task.clearingArea ?? 0} га, Объём: ${task.clearingVolume ?? 0} м³';
                      if (task.quarter != null) subtitleText += ' • Кв. ${task.quarter}';
                      if (task.allotment != null) subtitleText += ' • Выд. ${task.allotment}';
                    } else if (task.type == 'Установка панно и аншлагов') {
                      subtitleText += '\nШтук: ${task.panelsQuantity ?? 0}';
                      if (task.quarter != null) subtitleText += ' • Кв. ${task.quarter}';
                      if (task.allotment != null) subtitleText += ' • Выд. ${task.allotment}';
                    } else if (task.type == 'Охрана') {
                      if (task.guardLength != null) subtitleText += '\n${task.guardLength} ${_tr('km')}';
                      if (task.guardQuantity != null) subtitleText += ' • ${task.guardQuantity} ${_tr('pcs')}';
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        onTap: () => onShowDialog(editIndex: index),
                        leading: CircleAvatar(
                          backgroundColor: task.isDone ? Colors.grey : Colors.green.shade100,
                          child: Icon(
                            task.type == 'Посадка' ? Icons.park :
                            (task.type == 'Посев' ? Icons.grain :
                            (task.type == 'Выборочная санитарная рубка' || task.type == 'Сплошная санитарная рубка' ? Icons.content_cut :
                            (task.type == 'Уборка захламленности' ? Icons.cleaning_services :
                            (task.type == 'Установка панно и аншлагов' ? Icons.shield :
                            Icons.assignment)))),
                            color: Colors.green.shade800,
                          ),
                        ),
                        title: Text(task.title, style: TextStyle(decoration: task.isDone ? TextDecoration.lineThrough : null)),
                        subtitle: Text(subtitleText),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              activeColor: Colors.green,
                              value: task.isDone,
                              onChanged: (val) => onToggleDone(index, val),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () => onDelete(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
