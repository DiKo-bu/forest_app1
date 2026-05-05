// lib/models/forest_task.dart

class ForestTask {
  String title;
  String sector;
  DateTime startDate;
  DateTime endDate;
  bool isDone;
  String type; 

  // СТРОГО ДЛЯ ПОСАДКИ
  int? plantingQuantity; 
  double? plantingArea;  
  String? cultureType;

  // СТРОГО ДЛЯ ВЫРУБКИ
  double? cuttingVolume; 
  double? cuttingArea;   

  // СТРОГО ДЛЯ ОХРАНЫ
  double? guardLength; // километры
  int? guardQuantity;  // штуки

  ForestTask({
    required this.title,
    required this.sector,
    required this.startDate,
    required this.endDate,
    this.isDone = false,
    required this.type,
    this.plantingQuantity,
    this.plantingArea,
    this.cultureType,
    this.cuttingVolume,
    this.cuttingArea,
    this.guardLength,
    this.guardQuantity,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'sector': sector,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'isDone': isDone,
    'type': type,
    'plantingQuantity': plantingQuantity,
    'plantingArea': plantingArea,
    'cultureType': cultureType,
    'cuttingVolume': cuttingVolume,
    'cuttingArea': cuttingArea,
    'guardLength': guardLength,
    'guardQuantity': guardQuantity,
  };

  factory ForestTask.fromJson(Map<String, dynamic> json) => ForestTask(
    title: json['title'],
    sector: json['sector'],
    startDate: DateTime.parse(json['startDate'] ?? json['date']),
    endDate: DateTime.parse(json['endDate'] ?? json['date']),
    isDone: json['isDone'],
    type: json['type'],
    plantingQuantity: json['plantingQuantity'] ?? (json['type'] == 'Посадка' ? json['quantity'] : null),
    plantingArea: json['plantingArea'] != null ? (json['plantingArea'] as num).toDouble() : (json['type'] == 'Посадка' && json['area'] != null ? (json['area'] as num).toDouble() : null),
    cultureType: json['cultureType'],
    cuttingVolume: json['cuttingVolume'] != null ? (json['cuttingVolume'] as num).toDouble() : null,
    cuttingArea: json['cuttingArea'] != null ? (json['cuttingArea'] as num).toDouble() : (json['type'] == 'Вырубка' && json['area'] != null ? (json['area'] as num).toDouble() : null),
    guardLength: json['guardLength'] != null ? (json['guardLength'] as num).toDouble() : null,
    guardQuantity: json['guardQuantity'] != null ? (json['guardQuantity'] as num).toInt() : null,
  );
}
