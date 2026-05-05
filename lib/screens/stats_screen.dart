import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';                              // НОВОЕ
import 'package:flutter/services.dart';             // НОВОЕ
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
    int totalPlantingQty = 0;
    double totalPlantingArea = 0;
    double totalCuttingVol = 0;
    double totalCuttingArea = 0;
    double totalGuardLength = 0;
    int totalGuardQty = 0;

    for (var t in completed) {
      if (t.type == 'Посадка') {
        totalPlantingQty += (t.plantingQuantity ?? 0);
        totalPlantingArea += (t.plantingArea ?? 0);
      } else if (t.type == 'Вырубка') {
        totalCuttingVol += (t.cuttingVolume ?? 0);
        totalCuttingArea += (t.cuttingArea ?? 0);
      } else if (t.type == 'Охрана') {
        totalGuardLength += (t.guardLength ?? 0);
        totalGuardQty += (t.guardQuantity ?? 0);
      }
    }

    StringBuffer sb = StringBuffer();
    sb.writeln('🌳 ОТЧЕТ О ВЫПОЛНЕННЫХ РАБОТАХ');
    sb.writeln('Дата: ${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now())}');
    sb.writeln('--------------------------------');
    sb.writeln('ПОСАДКА ЛЕСА:');
    sb.writeln('Высажено саженцев: $totalPlantingQty шт.');
    sb.writeln('Площадь посадок: ${totalPlantingArea.toStringAsFixed(1)} га.');
    sb.writeln('--------------------------------');
    sb.writeln('ВЫРУБКА И РАСЧИСТКА:');
    sb.writeln('Объем заготовки: ${totalCuttingVol.toStringAsFixed(1)} куб.м.');
    sb.writeln('Площадь вырубок: ${totalCuttingArea.toStringAsFixed(1)} га.');
    sb.writeln('--------------------------------');
    sb.writeln('ОХРАНА И ЗАЩИТА:');
    sb.writeln('Пройдено/обработано: ${totalGuardLength.toStringAsFixed(1)} км.');
    sb.writeln('Установлено/отремонтировано: $totalGuardQty шт.');
    sb.writeln('--------------------------------\n');
    sb.writeln('ДЕТАЛИЗАЦИЯ:');

    for (int i = 0; i < completed.length; i++) {
      final t = completed[i];
      sb.write('${i + 1}. ${_tr(t.type)} (${t.sector})');
      if (t.type == 'Посадка') {
        sb.write(' - ${_tr(t.cultureType ?? '')}, ${t.plantingQuantity} шт, ${t.plantingArea} га');
      } else if (t.type == 'Вырубка') {
        sb.write(' - ${t.cuttingVolume} куб.м, ${t.cuttingArea} га');
      } else if (t.type == 'Охрана') {
        sb.write(' - ${_tr(t.title)}');
        if (t.guardLength != null) sb.write(', ${t.guardLength} км');
        if (t.guardQuantity != null) sb.write(', ${t.guardQuantity} шт');
      }
      String dates = '${DateFormat('dd.MM').format(t.startDate)}-${DateFormat('dd.MM').format(t.endDate)}';
      sb.writeln(' | $dates');
    }

    Share.share(sb.toString(), subject: 'Отчет лесничества');
  }

  // НОВЫЙ МЕТОД: экспорт в JSON для Прогноза
  void _exportJsonReport(BuildContext context, List<ForestTask> tasks) {
    final Map<String, dynamic> report = {};
    for (var t in tasks) {
      // Используем title как ключ (позже можно заменить на planId)
      report[t.title] = {
        'completed': t.isDone,
        if (t.isDone)
          'actual': t.endDate.difference(t.startDate).inDays.toDouble(),
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
        final completed = allTasks.where((t) => t.isDone).toList();

        int totalPlantingQty = 0;
        double totalPlantingArea = 0;
        double totalCuttingVol = 0;
        double totalCuttingArea = 0;
        double totalGuardLength = 0;
        int totalGuardQty = 0;
        Map<String, int> cultures = {};

        for (var t in completed) {
          if (t.type == 'Посадка') {
            totalPlantingQty += (t.plantingQuantity ?? 0);
            totalPlantingArea += (t.plantingArea ?? 0);
            if (t.cultureType != null) {
              cultures[t.cultureType!] = (cultures[t.cultureType!] ?? 0) + (t.plantingQuantity ?? 0);
            }
          } else if (t.type == 'Вырубка') {
            totalCuttingVol += (t.cuttingVolume ?? 0);
            totalCuttingArea += (t.cuttingArea ?? 0);
          } else if (t.type == 'Охрана') {
            totalGuardLength += (t.guardLength ?? 0);
            totalGuardQty += (t.guardQuantity ?? 0);
          }
        }

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
              _card(_tr('completed'), completed.length.toString(), Icons.done_all, Colors.blue),
              const SizedBox(height: 12),
              const Divider(),
              Text('🟢 ПОСАДКА', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green.shade800)),
              const SizedBox(height: 8),
              _card(_tr('total_planting_qty'), '$totalPlantingQty', Icons.park, Colors.green),
              _card(_tr('total_planting_area'), '${totalPlantingArea.toStringAsFixed(1)} ${_tr('ha')}', Icons.map, Colors.green),
              const SizedBox(height: 12),
              const Divider(),
              Text('🪓 ВЫРУБКА', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.orange.shade800)),
              const SizedBox(height: 8),
              _card(_tr('total_cutting_vol'), '${totalCuttingVol.toStringAsFixed(1)} ${_tr('cubes')}', Icons.content_cut, Colors.orange),
              _card(_tr('total_cutting_area'), '${totalCuttingArea.toStringAsFixed(1)} ${_tr('ha')}', Icons.map, Colors.orange),
              const SizedBox(height: 12),
              const Divider(),
              Text('🛡 ОХРАНА И ЗАЩИТА', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
              const SizedBox(height: 8),
              _card(_tr('guard_km'), '${totalGuardLength.toStringAsFixed(1)} ${_tr('km')}', Icons.route, Colors.blue),
              _card(_tr('guard_qty'), '$totalGuardQty ${_tr('pcs')}', Icons.shield, Colors.blue),
              const SizedBox(height: 20),
              Text(_tr('by_cultures'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(),
              ...cultures.entries.map((e) => ListTile(
                    title: Text(_tr(e.key)),
                    trailing: Text('${e.value} ${_tr('pcs')}'),
                  )),
            ],
          ),
        );
      },
    );
  }

  Widget _card(String title, String val, IconData icon, Color col) => Card(
        child: ListTile(
          leading: Icon(icon, color: col, size: 30),
          title: Text(title),
          trailing: Text(val, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      );
}