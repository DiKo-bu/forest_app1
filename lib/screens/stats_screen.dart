import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/forest_task.dart';
import '../utils/storage_helper.dart';
import '../utils/app_localization.dart';

class StatsScreen extends StatelessWidget {
  final String lang;
  const StatsScreen({super.key, required this.lang});

  // ------------------ Настройки Telegram ------------------
  static const String botToken = '8945344488:AAEnDBNXE9XcrznkIscioaLNRiRTMsqdyjA';
  static const int chatId = 2012874307;
  // --------------------------------------------------------

  String _tr(String key) => AppLocalization.tr(lang, key);

  void _exportReport(BuildContext context, List<ForestTask> tasks) {
    final completed = tasks.where((t) => t.isDone).toList();
    if (completed.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(lang == 'ru' ? 'Нет данных для отчета' : 'Есеп үшін деректер жоқ')),
      );
      return;
    }

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
        // дополнительные поля
        if (t.plantingQuantity != null) 'plantingQuantity': t.plantingQuantity,
        if (t.plantingArea != null) 'plantingArea': t.plantingArea,
        if (t.sowingQuantityKg != null) 'sowingQuantityKg': t.sowingQuantityKg,
        if (t.sowingAreaHa != null) 'sowingAreaHa': t.sowingAreaHa,
        if (t.selectiveCuttingVolume != null) 'cuttingVolume': t.selectiveCuttingVolume,
        if (t.selectiveCuttingArea != null) 'cuttingArea': t.selectiveCuttingArea,
        if (t.clearCuttingVolume != null) 'clearCuttingVolume': t.clearCuttingVolume,
        if (t.clearCuttingArea != null) 'clearCuttingArea': t.clearCuttingArea,
        if (t.clearingVolume != null) 'clearingVolume': t.clearingVolume,
        if (t.clearingArea != null) 'clearingArea': t.clearingArea,
        if (t.panelsQuantity != null) 'panelsQuantity': t.panelsQuantity,
      };
    }
    final jsonStr = jsonEncode(report);
    await Share.share(jsonStr, subject: 'Отчет лесничества');
  }

  Future<void> _sendReportToTelegram(List<ForestTask> tasks, BuildContext context) async {
    final Map<String, dynamic> report = {};
    for (var t in tasks) {
      report[t.title] = {
        'completed': t.isDone,
        if (t.isDone) 'actual': t.actualDuration ?? 0,
        if (t.actualEndDate != null) 'actualEndDate': t.actualEndDate!.toIso8601String(),
        if (t.plantingQuantity != null) 'plantingQuantity': t.plantingQuantity,
        if (t.plantingArea != null) 'plantingArea': t.plantingArea,
        if (t.sowingQuantityKg != null) 'sowingQuantityKg': t.sowingQuantityKg,
        if (t.sowingAreaHa != null) 'sowingAreaHa': t.sowingAreaHa,
        if (t.selectiveCuttingVolume != null) 'cuttingVolume': t.selectiveCuttingVolume,
        if (t.selectiveCuttingArea != null) 'cuttingArea': t.selectiveCuttingArea,
        if (t.clearCuttingVolume != null) 'clearCuttingVolume': t.clearCuttingVolume,
        if (t.clearCuttingArea != null) 'clearCuttingArea': t.clearCuttingArea,
        if (t.clearingVolume != null) 'clearingVolume': t.clearingVolume,
        if (t.clearingArea != null) 'clearingArea': t.clearingArea,
        if (t.panelsQuantity != null) 'panelsQuantity': t.panelsQuantity,
      };
    }
    final jsonStr = jsonEncode(report);
    try {
      final url = Uri.https('api.telegram.org', '/bot$botToken/sendMessage', {
        'chat_id': '$chatId',
        'text': jsonStr,
      });
      final response = await http.get(url);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Отчёт отправлен в Telegram')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка отправки: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка сети: $e')),
      );
    }
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
                icon: const Icon(Icons.telegram, color: Colors.blue),
                tooltip: 'Отправить отчёт в Telegram',
                onPressed: () => _sendReportToTelegram(allTasks, context),
              ),
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
