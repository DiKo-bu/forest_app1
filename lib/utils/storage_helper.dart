import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/forest_task.dart';

class StorageHelper {
  static const _tasksKey = 'forest_tasks';
  static const _langKey = 'app_lang';
  static const _executorKey = 'executor_id';

  // Язык
  static Future<String> loadLang() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_langKey) ?? 'ru';
  }

  static Future<void> saveLang(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langKey, lang);
  }

  // Задачи
  static Future<List<ForestTask>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksString = prefs.getString(_tasksKey);
    if (tasksString != null) {
      final List<dynamic> decoded = jsonDecode(tasksString);
      return decoded.map((e) => ForestTask.fromJson(e)).toList();
    }
    return [];
  }

  static Future<void> saveTasks(List<ForestTask> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await prefs.setString(_tasksKey, encoded);
  }

  // ID исполнителя
  static Future<String> getExecutorId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_executorKey) ?? '';
  }

  static Future<void> saveExecutorId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_executorKey, id);
  }
}
