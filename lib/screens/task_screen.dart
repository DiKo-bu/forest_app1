import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../models/forest_task.dart';
import '../utils/app_localization.dart';
import '../utils/storage_helper.dart';
import '../utils/server_api.dart';
import '../utils/plan_importer.dart';
import '../utils/task_filter.dart';
import 'stats_screen.dart';
import '../widgets/task_dialog.dart';
import '../widgets/confirm_delete_dialog.dart';
import '../widgets/executor_dialog.dart';

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

  Future<void> _fetchPlansFromServer() async {
    final executor = await StorageHelper.getExecutorId();
    if (executor.isEmpty) {
      final id = await showDialog<String>(
        context: context,
        builder: (_) => const ExecutorDialog(),
      );
      if (id == null || id.isEmpty) return;
      await StorageHelper.saveExecutorId(id);
      return _fetchPlansFromServer(); // рекурсивно, чтобы сразу загрузить план
    }
    final json = await fetchPlan(executor);
    if (json != null) {
      final newTasks = parsePlanFromJson(json);
      if (newTasks != null) {
        _tasks.addAll(newTasks);
        _saveTasks();
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_tr('import')}: загружено ${newTasks.length} задач')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Неверный формат плана')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('План для этого исполнителя не найден')),
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
            hintText: 'Вставьте JSON плана (или загрузите с сервера)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(_tr('cancel'))),
          ElevatedButton(
            onPressed: () {
              final newTasks = parsePlanFromJson(ctrl.text);
              if (newTasks != null) {
                _tasks.addAll(newTasks);
                _saveTasks();
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${_tr('import')}: загружено ${newTasks.length} задач')),
                );
              }
              Navigator.pop(ctx);
            },
            child: Text(_tr('import')),
          ),
        ],
      ),
    );
  }

  List<ForestTask> get _filteredAndSortedTasks => filterAndSortTasks(_tasks, _currentFilter);

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (_) => ConfirmDeleteDialog(
        lang: _currentLang,
        taskTitle: _filteredAndSortedTasks[index].title,
        onConfirm: () {
          final taskToRemove = _filteredAndSortedTasks[index];
          _tasks.remove(taskToRemove);
          _saveTasks();
          setState(() {});
        },
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
            icon: const Icon(Icons.cloud_download, color: Colors.blue),
            tooltip: 'Загрузить план с сервера',
            onPressed: _fetchPlansFromServer,
          ),
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
                          onTap: () => _showTaskDialog(editIndex: index),
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
