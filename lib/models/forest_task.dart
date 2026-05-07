class ForestTask {
  String title;
  String sector;
  DateTime startDate;
  DateTime endDate;
  bool isDone;
  String type;

  // Посадка (старые поля)
  int? plantingQuantity;
  double? plantingArea;
  String? cultureType;
  String? plantingType;   // сеянцы/саженцы/черенки

  // Вырубка (старые)
  double? cuttingVolume;
  double? cuttingArea;

  // Охрана (старые)
  double? guardLength;
  int? guardQuantity;

  // Посев
  String? sowingBreed;
  double? sowingQuantityKg;
  double? sowingAreaHa;

  // Выборочная санитарная рубка
  double? selectiveCuttingArea;   // cuttingArea
  double? selectiveCuttingVolume; // cuttingVolume

  // Сплошная санитарная рубка
  double? clearCuttingArea;
  double? clearCuttingVolume;

  // Уборка захламленности
  double? clearingArea;
  double? clearingVolume;

  // Установка панно и аншлагов
  double? panelsQuantity;

  // Общие
  String? location;   // "Где?" (для Посадки/Посева)
  String? quarter;    // Квартал
  String? allotment;  // Выдел

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
    this.plantingType,
    this.cuttingVolume,
    this.cuttingArea,
    this.guardLength,
    this.guardQuantity,
    this.sowingBreed,
    this.sowingQuantityKg,
    this.sowingAreaHa,
    this.selectiveCuttingArea,
    this.selectiveCuttingVolume,
    this.clearCuttingArea,
    this.clearCuttingVolume,
    this.clearingArea,
    this.clearingVolume,
    this.panelsQuantity,
    this.location,
    this.quarter,
    this.allotment,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'sector': sector,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'isDone': isDone,
    'type': type,
    if (plantingQuantity != null) 'plantingQuantity': plantingQuantity,
    if (plantingArea != null) 'plantingArea': plantingArea,
    if (cultureType != null) 'cultureType': cultureType,
    if (plantingType != null) 'plantingType': plantingType,
    if (cuttingVolume != null) 'cuttingVolume': cuttingVolume,
    if (cuttingArea != null) 'cuttingArea': cuttingArea,
    if (guardLength != null) 'guardLength': guardLength,
    if (guardQuantity != null) 'guardQuantity': guardQuantity,
    if (sowingBreed != null) 'sowingBreed': sowingBreed,
    if (sowingQuantityKg != null) 'sowingQuantityKg': sowingQuantityKg,
    if (sowingAreaHa != null) 'sowingAreaHa': sowingAreaHa,
    if (selectiveCuttingArea != null) 'selectiveCuttingArea': selectiveCuttingArea,
    if (selectiveCuttingVolume != null) 'selectiveCuttingVolume': selectiveCuttingVolume,
    if (clearCuttingArea != null) 'clearCuttingArea': clearCuttingArea,
    if (clearCuttingVolume != null) 'clearCuttingVolume': clearCuttingVolume,
    if (clearingArea != null) 'clearingArea': clearingArea,
    if (clearingVolume != null) 'clearingVolume': clearingVolume,
    if (panelsQuantity != null) 'panelsQuantity': panelsQuantity,
    if (location != null) 'location': location,
    if (quarter != null) 'quarter': quarter,
    if (allotment != null) 'allotment': allotment,
  };

  factory ForestTask.fromJson(Map<String, dynamic> json) => ForestTask(
    title: json['title'] ?? '',
    sector: json['sector'] ?? '',
    startDate: DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String()),
    endDate: DateTime.parse(json['endDate'] ?? DateTime.now().add(const Duration(days: 1)).toIso8601String()),
    isDone: json['isDone'] ?? false,
    type: json['type'] ?? 'Обход',
    plantingQuantity: json['plantingQuantity'],
    plantingArea: json['plantingArea']?.toDouble(),
    cultureType: json['cultureType'],
    plantingType: json['plantingType'],
    cuttingVolume: json['cuttingVolume']?.toDouble(),
    cuttingArea: json['cuttingArea']?.toDouble(),
    guardLength: json['guardLength']?.toDouble(),
    guardQuantity: json['guardQuantity'],
    sowingBreed: json['sowingBreed'],
    sowingQuantityKg: json['sowingQuantityKg']?.toDouble(),
    sowingAreaHa: json['sowingAreaHa']?.toDouble(),
    selectiveCuttingArea: json['selectiveCuttingArea']?.toDouble(),
    selectiveCuttingVolume: json['selectiveCuttingVolume']?.toDouble(),
    clearCuttingArea: json['clearCuttingArea']?.toDouble(),
    clearCuttingVolume: json['clearCuttingVolume']?.toDouble(),
    clearingArea: json['clearingArea']?.toDouble(),
    clearingVolume: json['clearingVolume']?.toDouble(),
    panelsQuantity: json['panelsQuantity']?.toDouble(),
    location: json['location'],
    quarter: json['quarter'],
    allotment: json['allotment'],
  );
}
