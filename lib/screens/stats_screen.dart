import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
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

    // агрегация как раньше (сокращённо)
    StringBuffer sb = StringBuffer();
    sb.writeln('🌳 ОТЧЕТ О ВЫПОЛНЕННЫХ РАБОТАХ');
    sb.writeln('Дата: ${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now())}');
    sb.writeln('--------------------------------');
    for (var t in completed) {
      sb.writeln('${t.title} (${t.type}): ${t.actualEndDate != null ? DateFormat('dd.MM.yy').format(t.actualEndDate!) : "?"}');
    }
    Share.share(sb.toString(), subject: 'Отчет лесничества');
  }

  void _exportJsonReport(BuildContext context, List<ForestTask> tasks) {
    final Map<String, dynamic> report = {};
    for (var t in tasks) {
      report[t.title] = {
        'completed': t.isDone,
        if (t.isDone) 'actual': t.actualDuration ?? 0,
        if (t.actualEndDate != null) 'actualEndDate': t.actualEndDate!.toIso8601String(),
        // добавляем фактические объёмы
        if (t.type == 'Посадка' && t.plantingQuantity != null) 'plantingQuantity': t.plantingQuantity,
        if (t.type == 'Посадка' && t.plantingArea != null) 'plantingArea': t.plantingArea,
        if (t.type == 'Посев' && t.sowingQuantityKg != null) 'sowingQuantityKg': t.sowingQuantityKg,
        if (t.type == 'Посев' && t.sowingAreaHa != null) 'sowingAreaHa': t.sowingAreaHa,
        if (t.type == 'Выборочная санитарная рубка' && t.selectiveCuttingVolume != null) 'cuttingVolume': t.selectiveCuttingVolume,
        if (t.type == 'Выборочная санитарная рубка' && t.selectiveCuttingArea != null) 'cuttingArea': t.selectiveCuttingArea,
        if (t.type == 'Сплошная санитарная рубка' && t.clearCuttingVolume != null) 'clearCuttingVolume': t.clearCuttingVolume,
        if (t.type == 'Сплошная санитарная рубка' && t.clearCuttingArea != null) 'clearCuttingArea': t.clearCuttingArea,
        if (t.type == 'Уборка захламленности' && t.clearingVolume != null) 'clearingVolume': t.clearingVolume,
        if (t.type == 'Уборка захламленности' && t.clearingArea != null) 'clearingArea': t.clearingArea,
        if (t.type == 'Установка панно и аншлагов' && t.panelsQuantity != null) 'panelsQuantity': t.panelsQuantity,
      };
    }
    final jsonStr = jsonEncode(report);
    Clipboard.setData(ClipboardData(text: jsonStr));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_tr('json_export') + ' скопирован в буфер')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ForestTask>>(
      future: StorageHelper.loadTasks(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final allTasks = snapshot.data!;
        // краткая статистика
        return Scaffold(
          appBar: AppBar(
            title: Text(_tr('stats')),
            backgroundColor: Colors.green.shade700,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.code),
                tooltip: _tr('json_export'),
                onPressed: () => _exportJsonReport(context, allTasks),
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
              // можно добавить детализацию
            ],
          ),
        );
      },
    );
  }
}
