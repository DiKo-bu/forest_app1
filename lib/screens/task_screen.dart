import 'package:flutter/material.dart';
import '../utils/app_localization.dart';
import '../utils/storage_helper.dart';
import 'stats_screen.dart';
import '../widgets/task_dialog.dart';
import 'task/task_service.dart';
import 'task/plan_importer.dart';
import 'task/executor_dialog.dart';
import 'task/task_list_view.dart';

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
    setState(() => _currentLang = _currentLang == 'ru' ? 'kk' : 'ru');
    await StorageHelper.saveLang(_currentLang);
  }

  Future<void> _fetchPlan() async {
    final executor = await StorageHelper.getExecutorId();
    if (executor.isEmpty) {
      showExecutorDialog(context);
      return;
    }
    final json = await TaskService.fetchPlan(executor);
    if (json != null) {
      final newTasks = PlanImporter.import(json);
      setState(() => _tasks.addAll(newTasks));
      _saveTasks();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_tr('import')}: загружено ${newTasks.length} задач')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('План для этого исполнителя не найден')),
      );
    }
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_tr('del_title')),
        content: Text('${_tr('del_desc')} "${_tasks[index].title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(_tr('cancel'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() => _tasks.removeAt(index));
              _saveTasks();
              Navigator.pop(context);
            },
            child: Text(_tr('del_btn'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _toggleDone(int index, bool? val) {
    setState(() => _tasks[index].isDone = val!);
    _saveTasks();
  }

  void _showTaskDialog({int? editIndex}) async {
    final taskToEdit = editIndex != null ? _tasks[editIndex] : null;
    final result = await showDialog<ForestTask>(
      context: context,
      builder: (context) => TaskDialog(task: taskToEdit, lang: _currentLang),
    );
    if (result != null) {
      setState(() {
        if (editIndex != null) {
          _tasks[editIndex] = result;
        } else {
          _tasks.add(result);
        }
      });
      _saveTasks();
    }
  }

  void _showManualImport() {
    TextEditingController ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_tr('import_plan')),
        content: TextField(
          controller: ctrl,
          maxLines: 6,
          decoration: const InputDecoration(
            hintText: 'Вставьте JSON плана',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(_tr('cancel'))),
          ElevatedButton(
            onPressed: () {
              try {
                final newTasks = PlanImporter.import(ctrl.text);
                setState(() => _tasks.addAll(newTasks));
                _saveTasks();
                Navigator.pop(ctx);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ошибка импорта: $e')),
                );
              }
            },
            child: Text(_tr('import')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_tr('app_title')),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_download, color: Colors.blue),
            tooltip: 'Загрузить план с сервера',
            onPressed: _fetchPlan,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: _tr('import_plan'),
            onPressed: _showManualImport,
          ),
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => StatsScreen(lang: _currentLang)));
            },
          ),
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: _toggleLanguage,
            tooltip: _currentLang == 'ru' ? 'Қазақ тілі' : 'Русский язык',
          ),
        ],
      ),
      body: TaskListView(
        tasks: _tasks,
        currentLang: _currentLang,
        currentFilter: _currentFilter,
        onFilterChanged: (filter) => setState(() => _currentFilter = filter),
        onDelete: (index) => _confirmDelete(index),
        onToggleDone: (index, val) => _toggleDone(index, val),
        onSaveTask: (_) => _saveTasks(),
        onShowDialog: ({editIndex}) => _showTaskDialog(editIndex: editIndex),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskDialog(),
        backgroundColor: Colors.green.shade700,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
