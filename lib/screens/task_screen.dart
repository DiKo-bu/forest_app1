import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/forest_task.dart';
import '../utils/app_localization.dart';
import '../utils/storage_helper.dart';
import 'stats_screen.dart';
import '../widgets/task_dialog.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});
  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  List<ForestTask> _tasks = [];
  String _currentLang = 'ru';
  String _currentFilter = 'Все';

  String _tr(String key) => AppLocalization.tr(_currentLang, key);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final lang = await StorageHelper.loadLang();
    final tasks = await StorageHelper.loadTasks();
    setState(() {
      _currentLang = lang;
      _tasks = tasks;
    });
  }

  Future<void> _saveTasks() async {
    await StorageHelper.saveTasks(_tasks);
  }

  void _toggleLanguage() async {
    setState(() {
      _currentLang = _currentLang == 'ru' ? 'kk' : 'ru';
    });
    await StorageHelper.saveLang(_currentLang);
  }

  void _importPlanFromJson(String jsonStr) {
    try {
      final List<dynamic> plan = jsonDecode(jsonStr);
      for (var item in plan) {
        String type = item['workType'] ?? 'Обход';
        int? plantingQty = (type == 'Посадка' && item['targetQuantity'] != null) ? (item['targetQuantity'] as num).toInt() : null;
        double? plantingArea = (type == 'Посадка' && item['targetArea'] != null) ? (item['targetArea'] as num).toDouble() : null;
        double? cuttingVol = (type == 'Вырубка' && item['targetQuantity'] != null) ? (item['targetQuantity'] as num).toDouble() : null;
        double? guardLength = (type == 'Охрана' && item['targetLength'] != null) ? (item['targetLength'] as num).toDouble() : null;
        int? guardQty = (type == 'Охрана' && item['targetQuantity'] != null) ? (item['targetQuantity'] as num).toInt() : null;

        final task = ForestTask(
          title: item['name'] ?? 'Без названия',
          sector: item['sector'] ?? '',
          startDate: DateTime.now(),
          endDate: DateTime.now().add(Duration(days: (item['likely'] ?? 1).toInt())),
          type: type,
          isDone: false,
          plantingQuantity: plantingQty,
          plantingArea: plantingArea,
          cultureType: item['cultureType'],
          cuttingVolume: cuttingVol,
          cuttingArea: (type == 'Вырубка' && item['targetArea'] != null) ? (item['targetArea'] as num).toDouble() : null,
          guardLength: guardLength,
          guardQuantity: guardQty,
        );
        _tasks.add(task);
      }
      _saveTasks();
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_tr('import')}: загружено ${plan.length} задач')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка импорта: ${e.toString()}')),
      );
    }
  }

  void _showImportDialog() {
    TextEditingController ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_tr('import_plan')),
        content: TextField(
          controller: ctrl,
          maxLines: 6,
          decoration: const InputDecoration(
            hintText: 'Вставьте JSON плана из Прогноза',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(_tr('cancel'))),
          ElevatedButton(
            onPressed: () {
              _importPlanFromJson(ctrl.text);
              Navigator.pop(ctx);
            },
            child: Text(_tr('import')),
          ),
        ],
      ),
    );
  }

  List<ForestTask> get _filteredAndSortedTasks {
    List<ForestTask> result = _tasks;
    if (_currentFilter != 'Все') {
      result = result.where((t) => t.type == _currentFilter).toList();
    }
    result.sort((a, b) {
      if (a.isDone == b.isDone) return a.startDate.compareTo(b.startDate);
      return a.isDone ? 1 : -1;
    });
    return result;
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_tr('del_title')),
        content: Text('${_tr('del_desc')} "${_tr(_filteredAndSortedTasks[index].title)}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(_tr('cancel'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                final taskToRemove = _filteredAndSortedTasks[index];
                _tasks.remove(taskToRemove);
              });
              _saveTasks();
              Navigator.pop(context);
            },
            child: Text(_tr('del_btn'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showTaskDialog({int? editIndex}) async {
    final taskToEdit = editIndex != null ? _filteredAndSortedTasks[editIndex] : null;
    final result = await showDialog<ForestTask>(
      context: context,
      builder: (context) => TaskDialog(task: taskToEdit, lang: _currentLang),
    );

    if (result != null) {
      setState(() {
        if (editIndex != null) {
          final originalTask = _filteredAndSortedTasks[editIndex];
          final realIndex = _tasks.indexOf(originalTask);
          _tasks[realIndex] = result;
        } else {
          _tasks.add(result);
        }
      });
      _saveTasks();
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayTasks = _filteredAndSortedTasks;

    // Динамические фильтры на основе имеющихся типов задач
    final allTypes = _tasks.map((t) => t.type).toSet().toList();
    allTypes.sort();
    final filters = ['Все', ...allTypes.where((t) => t != 'Все')];

    return Scaffold(
      appBar: AppBar(
        title: Text(_tr('app_title')),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: _tr('import_plan'),
            onPressed: _showImportDialog,
          ),
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => StatsScreen(lang: _currentLang)));
            },
          ),
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: _toggleLanguage,
            tooltip: _currentLang == 'ru' ? 'Қазақ тілі' : 'Русский язык',
          ),
        ],
      ),
      body: Column(
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
                    selected: _currentFilter == filter,
                    selectedColor: Colors.green.shade200,
                    onSelected: (selected) => setState(() => _currentFilter = filter),
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
                      if (task.type == 'Посадка') {
                        subtitleText += '\n${_tr(task.cultureType ?? '')} • ${task.plantingQuantity ?? 0} ${_tr('pcs')} • ${task.plantingArea ?? 0} ${_tr('ha')}';
                      } else if (task.type == 'Вырубка') {
                        subtitleText += '\n${task.cuttingVolume ?? 0} ${_tr('cubes')} • ${task.cuttingArea ?? 0} ${_tr('ha')}';
                      } else if (task.type == 'Охрана') {
                        if (task.guardLength != null) subtitleText += '\n${task.guardLength} ${_tr('km')}';
                        if (task.guardQuantity != null) subtitleText += '\n${task.guardQuantity} ${_tr('pcs')}';
                      }

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          onTap: () => _showTaskDialog(editIndex: index),
                          leading: CircleAvatar(
                            backgroundColor: task.isDone ? Colors.grey : Colors.green.shade100,
                            child: Icon(
                              task.type == 'Посадка'
                                  ? Icons.park
                                  : (task.type == 'Вырубка'
                                      ? Icons.content_cut
                                      : (task.type == 'Охрана' ? Icons.security : Icons.assignment)),
                              color: Colors.green.shade800,
                            ),
                          ),
                          title: Text(_tr(task.title), style: TextStyle(decoration: task.isDone ? TextDecoration.lineThrough : null)),
                          subtitle: Text(subtitleText),
                          isThreeLine: task.type == 'Посадка' || task.type == 'Вырубка' || task.type == 'Охрана',
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                activeColor: Colors.green,
                                value: task.isDone,
                                onChanged: (val) {
                                  setState(() => task.isDone = val!);
                                  _saveTasks();
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                onPressed: () => _confirmDelete(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskDialog(),
        backgroundColor: Colors.green.shade700,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
