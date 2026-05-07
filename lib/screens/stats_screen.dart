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

    int totalPlantingQty = 0;
    double totalPlantingArea = 0;
    double totalCuttingVol = 0;
    double totalCuttingArea = 0;
    double totalGuardLength = 0;
    int totalGuardQty = 0;
    // Добавим агрегацию по новым типам
    double totalSowingKg = 0;
    double totalSowingArea = 0;
    double totalClearCuttingArea = 0;
    double totalClearCuttingVolume = 0;
    double totalClearingArea = 0;
    double totalClearingVolume = 0;
    int totalPanels = 0;

    for (var t in completed) {
      if (t.type == 'Посадка') {
        totalPlantingQty += (t.plantingQuantity ?? 0);
        totalPlantingArea += (t.plantingArea ?? 0);
      } else if (t.type == 'Посев') {
        totalSowingKg += (t.sowingQuantityKg ?? 0);
        totalSowingArea += (t.sowingAreaHa ?? 0);
      } else if (t.type == 'Выборочная санитарная рубка') {
        totalCuttingVol += (t.selectiveCuttingVolume ?? 0);
        totalCuttingArea += (t.selectiveCuttingArea ?? 0);
      } else if (t.type == 'Сплошная санитарная рубка') {
        totalClearCuttingVolume += (t.clearCuttingVolume ?? 0);
        totalClearCuttingArea += (t.clearCuttingArea ?? 0);
      } else if (t.type == 'Уборка захламленности') {
        totalClearingVolume += (t.clearingVolume ?? 0);
        totalClearingArea += (t.clearingArea ?? 0);
      } else if (t.type == 'Установка панно и аншлагов') {
        totalPanels += (t.panelsQuantity ?? 0).toInt();
      } else if (t.type == 'Охрана') {
        totalGuardLength += (t.guardLength ?? 0);
        totalGuardQty += (t.guardQuantity ?? 0);
      }
    }

    StringBuffer sb = StringBuffer();
    sb.writeln('🌳 ОТЧЕТ О ВЫПОЛНЕННЫХ РАБОТАХ');
    sb.writeln('Дата: ${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now())}');
    sb.writeln('--------------------------------');
    sb.writeln('ПОСАДКА: $totalPlantingQty шт, $totalPlantingArea га');
    sb.writeln('ПОСЕВ: ${totalSowingKg.toStringAsFixed(1)} кг, $totalSowingArea га');
    sb.writeln('ВЫБОРОЧНАЯ САНРУБКА: ${totalCuttingVol.toStringAsFixed(1)} м³, $totalCuttingArea га');
    sb.writeln('СПЛОШНАЯ САНРУБКА: ${totalClearCuttingVolume.toStringAsFixed(1)} м³, $totalClearCuttingArea га');
    sb.writeln('УБОРКА ЗАХЛАМЛЕННОСТИ: ${totalClearingVolume.toStringAsFixed(1)} м³, $totalClearingArea га');
    sb.writeln('ПАННО И АНШЛАГИ: $totalPanels шт');
    sb.writeln('ОХРАНА: ${totalGuardLength.toStringAsFixed(1)} км, $totalGuardQty шт');
    sb.writeln('--------------------------------\n');
    sb.writeln('ДЕТАЛИЗАЦИЯ:');
    for (int i = 0; i < completed.length; i++) {
      final t = completed[i];
      sb.write('${i + 1}. ${t.type} (${t.sector})');
      String dates = '${DateFormat('dd.MM').format(t.startDate)}-${DateFormat('dd.MM').format(t.endDate)}';
      sb.writeln(' | $dates');
    }

    Share.share(sb.toString(), subject: 'Отчет лесничества');
  }

  void _exportJsonReport(BuildContext context, List<ForestTask> tasks) {
    final Map<String, dynamic> report = {};
    for (var t in tasks) {
      report[t.title] = {
        'completed': t.isDone,
        if (t.isDone) 'actual': t.endDate.difference(t.startDate).inDays.toDouble(),
        // добавим фактические объёмы для отчёта в prognoz
        if (t.type == 'Посадка' && t.plantingQuantity != null) 'plantingQuantity': t.plantingQuantity,
        if (t.type == 'Посадка' && t.plantingArea != null) 'plantingArea': t.plantingArea,
        if (t.type == 'Посев' && t.sowingQuantityKg != null) 'sowingQuantityKg': t.sowingQuantityKg,
        if (t.type == 'Посев' && t.sowingAreaHa != null) 'sowingAreaHa': t.sowingAreaHa,
        if (t.type == 'Выборочная санитарная рубка' && t.selectiveCuttingArea != null) 'cuttingArea': t.selectiveCuttingArea,
        if (t.type == 'Выборочная санитарная рубка' && t.selectiveCuttingVolume != null) 'cuttingVolume': t.selectiveCuttingVolume,
        if (t.type == 'Сплошная санитарная рубка' && t.clearCuttingArea != null) 'clearCuttingArea': t.clearCuttingArea,
        if (t.type == 'Сплошная санитарная рубка' && t.clearCuttingVolume != null) 'clearCuttingVolume': t.clearCuttingVolume,
        if (t.type == 'Уборка захламленности' && t.clearingArea != null) 'clearingArea': t.clearingArea,
        if (t.type == 'Уборка захламленности' && t.clearingVolume != null) 'clearingVolume': t.clearingVolume,
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
        final completed = allTasks.where((t) => t.isDone).toList();

        int totalPlantingQty = 0;
        double totalPlantingArea = 0;
        double totalCuttingVol = 0;
        double totalCuttingArea = 0;
        double totalGuardLength = 0;
        int totalGuardQty = 0;
        double totalSowingKg = 0;
        double totalSowingArea = 0;
        double totalClearCuttingVol = 0;
        double totalClearCuttingArea = 0;
        double totalClearingVol = 0;
        double totalClearingArea = 0;
        int totalPanels = 0;

        for (var t in completed) {
          if (t.type == 'Посадка') {
            totalPlantingQty += (t.plantingQuantity ?? 0);
            totalPlantingArea += (t.plantingArea ?? 0);
          } else if (t.type == 'Посев') {
            totalSowingKg += (t.sowingQuantityKg ?? 0);
            totalSowingArea += (t.sowingAreaHa ?? 0);
          } else if (t.type == 'Выборочная санитарная рубка') {
            totalCuttingVol += (t.selectiveCuttingVolume ?? 0);
            totalCuttingArea += (t.selectiveCuttingArea ?? 0);
          } else if (t.type == 'Сплошная санитарная рубка') {
            totalClearCuttingVol += (t.clearCuttingVolume ?? 0);
            totalClearCuttingArea += (t.clearCuttingArea ?? 0);
          } else if (t.type == 'Уборка захламленности') {
            totalClearingVol += (t.clearingVolume ?? 0);
            totalClearingArea += (t.clearingArea ?? 0);
          } else if (t.type == 'Установка панно и аншлагов') {
            totalPanels += (t.panelsQuantity ?? 0).toInt();
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
              _card('Саженцев', '$totalPlantingQty шт', Icons.park, Colors.green),
              _card('Площадь', '${totalPlantingArea.toStringAsFixed(1)} га', Icons.map, Colors.green),
              const SizedBox(height: 12),
              const Divider(),
              Text('🌾 ПОСЕВ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.brown.shade800)),
              _card('Масса', '${totalSowingKg.toStringAsFixed(1)} кг', Icons.scale, Colors.brown),
              _card('Площадь', '${totalSowingArea.toStringAsFixed(1)} га', Icons.map, Colors.brown),
              const SizedBox(height: 12),
              const Divider(),
              Text('🪓 ВЫБОРОЧНАЯ САНРУБКА', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.orange.shade800)),
              _card('Объём', '${totalCuttingVol.toStringAsFixed(1)} м³', Icons.content_cut, Colors.orange),
              _card('Площадь', '${totalCuttingArea.toStringAsFixed(1)} га', Icons.map, Colors.orange),
              const SizedBox(height: 12),
              const Divider(),
              Text('🪓 СПЛОШНАЯ САНРУБКА', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.deepOrange.shade800)),
              _card('Объём', '${totalClearCuttingVol.toStringAsFixed(1)} м³', Icons.content_cut, Colors.deepOrange),
              _card('Площадь', '${totalClearCuttingArea.toStringAsFixed(1)} га', Icons.map, Colors.deepOrange),
              const SizedBox(height: 12),
              const Divider(),
              Text('🧹 УБОРКА ЗАХЛАМЛЕННОСТИ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.teal.shade800)),
              _card('Объём', '${totalClearingVol.toStringAsFixed(1)} м³', Icons.cleaning_services, Colors.teal),
              _card('Площадь', '${totalClearingArea.toStringAsFixed(1)} га', Icons.map, Colors.teal),
              const SizedBox(height: 12),
              const Divider(),
              Text('🛡 ПАННО И АНШЛАГИ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
              _card('Штук', '$totalPanels', Icons.shield, Colors.blue),
              const SizedBox(height: 12),
              const Divider(),
              Text('🛡 ОХРАНА', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
              _card(_tr('guard_km'), '${totalGuardLength.toStringAsFixed(1)} ${_tr('km')}', Icons.route, Colors.blue),
              _card(_tr('guard_qty'), '$totalGuardQty ${_tr('pcs')}', Icons.shield, Colors.blue),
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
