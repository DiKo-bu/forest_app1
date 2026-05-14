import 'dart:convert';
import '../models/forest_task.dart';

/// Парсит JSON-строку и возвращает список задач ForestTask.
/// Если JSON некорректен, возвращает null.
List<ForestTask>? parsePlanFromJson(String jsonStr) {
  try {
    final List<dynamic> plan = jsonDecode(jsonStr);
    return plan.map((item) {
      String type = item['workType'] ?? 'Посадка';
      return ForestTask(
        title: item['name'] ?? '',
        sector: item['sector'] ?? '',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(Duration(days: (item['likely'] ?? 1).toInt())),
        type: type,
        isDone: false,
        plantingQuantity: (type == 'Посадка' && item['plantingQuantity'] != null) ? (item['plantingQuantity'] as num).toInt() : null,
        plantingArea: (type == 'Посадка' && item['plantingArea'] != null) ? (item['plantingArea'] as num).toDouble() : null,
        cultureType: item['culture'],
        plantingType: item['plantingType'],
        sowingBreed: (type == 'Посев') ? item['sowingBreed'] : null,
        sowingQuantityKg: (type == 'Посев' && item['sowingQuantityKg'] != null) ? (item['sowingQuantityKg'] as num).toDouble() : null,
        sowingAreaHa: (type == 'Посев' && item['sowingAreaHa'] != null) ? (item['sowingAreaHa'] as num).toDouble() : null,
        selectiveCuttingArea: (type == 'Выборочная санитарная рубка' && item['cuttingArea'] != null) ? (item['cuttingArea'] as num).toDouble() : null,
        selectiveCuttingVolume: (type == 'Выборочная санитарная рубка' && item['cuttingVolume'] != null) ? (item['cuttingVolume'] as num).toDouble() : null,
        clearCuttingArea: (type == 'Сплошная санитарная рубка' && item['clearCuttingArea'] != null) ? (item['clearCuttingArea'] as num).toDouble() : null,
        clearCuttingVolume: (type == 'Сплошная санитарная рубка' && item['clearCuttingVolume'] != null) ? (item['clearCuttingVolume'] as num).toDouble() : null,
        clearingArea: (type == 'Уборка захламленности' && item['clearingArea'] != null) ? (item['clearingArea'] as num).toDouble() : null,
        clearingVolume: (type == 'Уборка захламленности' && item['clearingVolume'] != null) ? (item['clearingVolume'] as num).toDouble() : null,
        panelsQuantity: (type == 'Установка панно и аншлагов' && item['panelsQuantity'] != null) ? (item['panelsQuantity'] as num).toDouble() : null,
        location: item['location'],
        quarter: item['quarter'],
        allotment: item['allotment'],
      );
    }).toList();
  } catch (_) {
    return null;
  }
}
