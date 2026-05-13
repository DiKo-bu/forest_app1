import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import '../models/forest_task.dart';
import '../utils/storage_helper.dart';
import '../utils/app_localization.dart';

class StatsScreen extends StatelessWidget {
  final String lang;
  const StatsScreen({super.key, required this.lang});

  String _tr(String key) => AppLocalization.tr(lang, key);

  void _exportReport(BuildContext context, List<ForestTask> tasks) {
    final completed = tasks.where((t) => t.isDone).toList();
    if (completed.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(lang == 'ru' ? 'Нет данных для отчета' : 'Есеп үшін деректер жоқ')),
      );
      return;
    }

    // ... старый текстовый отчёт остаётся без изменений ...
    StringBuffer sb = StringBuffer();
    sb.writeln('🌳 ОТЧЕТ О ВЫПОЛНЕННЫХ РАБОТАХ');
    sb.writeln('Дата: ${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now())}');
    for (var t in completed) {
      sb.writeln('${t.title} (${t.type}): ${t.actualEndDate != null ? DateFormat('dd.MM.yy').format(t.actualEndDate!) : "?"}');
    }
    Share.share(sb.toString(), subject: 'Отчет лесничества');
  }

  void _shareJsonReport(List<ForestTask> tasks) async {
    final Map<String, dynamic> report = {};
    for (var t in tasks) {
      report[t.title] = {
        'completed': t.isDone,
        if (t.isDone) 'actual': t.actualDuration ?? 0,
        if (t.actualEndDate != null) 'actualEndDate': t.actualEndDate!.toIso8601String(),
        // ... (все поля как раньше, оставлены для краткости) ...
      };
    }
    final jsonStr = jsonEncode(report);
    // Просто делимся текстом (можно и файлом, но так проще)
    await Share.share(jsonStr, subject: 'Отчет лесничества');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ForestTask>>(
      future: StorageHelper.loadTasks(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final allTasks = snapshot.data!;
        return Scaffold(
          appBar: AppBar(
            title: Text(_tr('stats')),
            backgroundColor: Colors.green.shade700,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                tooltip: 'Поделиться JSON',
                onPressed: () => _shareJsonReport(allTasks),
              ),
              IconButton(
                icon: const Icon(Icons.ios_share),
                tooltip: 'Текстовый отчёт',
                onPressed: () => _exportReport(context, allTasks),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Выполнено задач: ${allTasks.where((t) => t.isDone).length}'),
            ],
          ),
        );
      },
    );
  }
}
