import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/forest_task.dart';
import '../utils/app_localization.dart';

class TaskDialog extends StatefulWidget {
  final ForestTask? task;
  final String lang;

  const TaskDialog({super.key, this.task, required this.lang});

  @override
  State<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  late String title;
  late String type;
  late DateTime startDate;
  late DateTime endDate;
  late bool isDone;
  late double actualDuration;
  late DateTime actualEndDate;

  // Посадка
  int? plantingQty;
  double? plantingArea;
  String? cultureType;
  String? plantingType;

  // Посев
  String? sowingBreed;
  double? sowingQuantityKg;
  double? sowingAreaHa;

  // Выборочная санрубка
  double? selectiveCuttingArea;
  double? selectiveCuttingVolume;

  // Сплошная санрубка
  double? clearCuttingArea;
  double? clearCuttingVolume;

  // Уборка захламленности
  double? clearingArea;
  double? clearingVolume;

  // Установка панно и аншлагов
  double? panelsQuantity;

  String? location;
  String? quarter;
  String? allotment;

  String _tr(String key) => AppLocalization.tr(widget.lang, key);

  @override
  void initState() {
    super.initState();
    title = widget.task?.title ?? '';
    type = widget.task?.type ?? 'Посадка';
    startDate = widget.task?.startDate ?? DateTime.now();
    endDate = widget.task?.endDate ?? DateTime.now().add(const Duration(days: 1));
    isDone = widget.task?.isDone ?? false;
    actualDuration = widget.task?.actualDuration ?? 0;
    actualEndDate = widget.task?.actualEndDate ?? endDate;

    plantingQty = widget.task?.plantingQuantity;
    plantingArea = widget.task?.plantingArea;
    cultureType = widget.task?.cultureType ?? 'ильмовые';
    plantingType = widget.task?.plantingType ?? 'сеянцы';

    sowingBreed = widget.task?.sowingBreed;
    sowingQuantityKg = widget.task?.sowingQuantityKg;
    sowingAreaHa = widget.task?.sowingAreaHa;

    selectiveCuttingArea = widget.task?.selectiveCuttingArea;
    selectiveCuttingVolume = widget.task?.selectiveCuttingVolume;

    clearCuttingArea = widget.task?.clearCuttingArea;
    clearCuttingVolume = widget.task?.clearCuttingVolume;

    clearingArea = widget.task?.clearingArea;
    clearingVolume = widget.task?.clearingVolume;

    panelsQuantity = widget.task?.panelsQuantity;

    location = widget.task?.location;
    quarter = widget.task?.quarter;
    allotment = widget.task?.allotment;
  }

  void _saveAndClose() {
    if (title.isEmpty) return;

    final resultTask = ForestTask(
      title: title,
      sector: widget.task?.sector ?? '',
      startDate: startDate,
      endDate: endDate,
      type: type,
      isDone: isDone,
      actualDuration: isDone ? actualDuration : null,
      actualEndDate: isDone ? actualEndDate : null,
      plantingQuantity: type == 'Посадка' ? plantingQty : null,
      plantingArea: type == 'Посадка' ? plantingArea : null,
      cultureType: type == 'Посадка' ? cultureType : null,
      plantingType: type == 'Посадка' ? plantingType : null,
      sowingBreed: type == 'Посев' ? sowingBreed : null,
      sowingQuantityKg: type == 'Посев' ? sowingQuantityKg : null,
      sowingAreaHa: type == 'Посев' ? sowingAreaHa : null,
      selectiveCuttingArea: type == 'Выборочная санитарная рубка' ? selectiveCuttingArea : null,
      selectiveCuttingVolume: type == 'Выборочная санитарная рубка' ? selectiveCuttingVolume : null,
      clearCuttingArea: type == 'Сплошная санитарная рубка' ? clearCuttingArea : null,
      clearCuttingVolume: type == 'Сплошная санитарная рубка' ? clearCuttingVolume : null,
      clearingArea: type == 'Уборка захламленности' ? clearingArea : null,
      clearingVolume: type == 'Уборка захламленности' ? clearingVolume : null,
      panelsQuantity: type == 'Установка панно и аншлагов' ? panelsQuantity : null,
      location: (type == 'Посадка' || type == 'Посев') ? location : null,
      quarter: (type == 'Выборочная санитарная рубка' || type == 'Сплошная санитарная рубка' || type == 'Уборка захламленности' || type == 'Установка панно и аншлагов') ? quarter : null,
      allotment: (type == 'Выборочная санитарная рубка' || type == 'Сплошная санитарная рубка' || type == 'Уборка захламленности' || type == 'Установка панно и аншлагов') ? allotment : null,
    );

    Navigator.pop(context, resultTask);
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.task != null;

    return AlertDialog(
      title: Text(isEdit ? _tr('edit_task') : _tr('new_task')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Тип (не редактируется)
            Text(
              _tr(type),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 16),

            // ---------- ПОЛЯ ПОСАДКИ ----------
            if (type == 'Посадка') ...[
              TextFormField(
                initialValue: plantingType ?? '',
                decoration: const InputDecoration(labelText: 'Вид'),
                onChanged: (v) => setState(() => plantingType = v),
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: cultureType ?? '',
                decoration: const InputDecoration(labelText: 'Культура'),
                onChanged: (v) => setState(() => cultureType = v),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: plantingQty?.toString() ?? '',
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: _tr('planting_qty')),
                      onChanged: (v) => plantingQty = int.tryParse(v),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      initialValue: plantingArea?.toString() ?? '',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: _tr('planting_area')),
                      onChanged: (v) => plantingArea = double.tryParse(v.replaceAll(',', '.')),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: location ?? '',
                decoration: const InputDecoration(labelText: 'Где?'),
                onChanged: (v) => location = v,
              ),
            ],

            // ---------- ПОЛЯ ДЛЯ ПОСЕВА ----------
            if (type == 'Посев') ...[
              DropdownButtonFormField<String>(
                value: sowingBreed,
                decoration: const InputDecoration(labelText: 'Порода'),
                items: ['ильмовые', 'клён', 'ясень', 'акация', 'смородина', 'лох', 'шиповник', 'плодово-косточковые', 'плодово-семечковые', 'прочие']
                    .map((e) => DropdownMenuItem(value: e, child: Text(_tr(e)))).toList(),
                onChanged: (v) => setState(() => sowingBreed = v),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: sowingQuantityKg?.toString() ?? '',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Кол-во, кг'),
                      onChanged: (v) => sowingQuantityKg = double.tryParse(v.replaceAll(',', '.')),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      initialValue: sowingAreaHa?.toString() ?? '',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Площадь, га'),
                      onChanged: (v) => sowingAreaHa = double.tryParse(v.replaceAll(',', '.')),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: location ?? '',
                decoration: const InputDecoration(labelText: 'Где?'),
                onChanged: (v) => location = v,
              ),
            ],

            // ---------- ДРУГИЕ ТИПЫ (как раньше) ----------
            if (type == 'Выборочная санитарная рубка') ...[
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: selectiveCuttingArea?.toString() ?? '',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Площадь, га'),
                      onChanged: (v) => selectiveCuttingArea = double.tryParse(v.replaceAll(',', '.')),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      initialValue: selectiveCuttingVolume?.toString() ?? '',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Объём, м³'),
                      onChanged: (v) => selectiveCuttingVolume = double.tryParse(v.replaceAll(',', '.')),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: quarter ?? '',
                      decoration: const InputDecoration(labelText: 'Квартал'),
                      onChanged: (v) => quarter = v,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      initialValue: allotment ?? '',
                      decoration: const InputDecoration(labelText: 'Выдел'),
                      onChanged: (v) => allotment = v,
                    ),
                  ),
                ],
              ),
            ],

            if (type == 'Сплошная санитарная рубка') ...[
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: clearCuttingArea?.toString() ?? '',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Площадь, га'),
                      onChanged: (v) => clearCuttingArea = double.tryParse(v.replaceAll(',', '.')),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      initialValue: clearCuttingVolume?.toString() ?? '',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Объём, м³'),
                      onChanged: (v) => clearCuttingVolume = double.tryParse(v.replaceAll(',', '.')),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: quarter ?? '',
                      decoration: const InputDecoration(labelText: 'Квартал'),
                      onChanged: (v) => quarter = v,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      initialValue: allotment ?? '',
                      decoration: const InputDecoration(labelText: 'Выдел'),
                      onChanged: (v) => allotment = v,
                    ),
                  ),
                ],
              ),
            ],

            if (type == 'Уборка захламленности') ...[
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: clearingArea?.toString() ?? '',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Площадь, га'),
                      onChanged: (v) => clearingArea = double.tryParse(v.replaceAll(',', '.')),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      initialValue: clearingVolume?.toString() ?? '',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Объём, м³'),
                      onChanged: (v) => clearingVolume = double.tryParse(v.replaceAll(',', '.')),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: quarter ?? '',
                      decoration: const InputDecoration(labelText: 'Квартал'),
                      onChanged: (v) => quarter = v,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      initialValue: allotment ?? '',
                      decoration: const InputDecoration(labelText: 'Выдел'),
                      onChanged: (v) => allotment = v,
                    ),
                  ),
                ],
              ),
            ],

            if (type == 'Установка панно и аншлагов') ...[
              TextFormField(
                initialValue: panelsQuantity?.toString() ?? '',
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Штуки'),
                onChanged: (v) => panelsQuantity = double.tryParse(v.replaceAll(',', '.')),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: quarter ?? '',
                      decoration: const InputDecoration(labelText: 'Квартал'),
                      onChanged: (v) => quarter = v,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      initialValue: allotment ?? '',
                      decoration: const InputDecoration(labelText: 'Выдел'),
                      onChanged: (v) => allotment = v,
                    ),
                  ),
                ],
              ),
            ],

            // --- БЛОК ЗАВЕРШЕНИЯ ---
            CheckboxListTile(
              title: const Text("Завершено"),
              value: isDone,
              onChanged: (v) => setState(() {
                isDone = v!;
                if (isDone) {
                  actualDuration = actualDuration > 0 ? actualDuration : 1;
                  actualEndDate = endDate; // по умолчанию плановая дата
                }
              }),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            if (isDone) ...[
              TextFormField(
                initialValue: actualDuration.toString().replaceAll(RegExp(r'\.0$'), ''),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Факт. дней'),
                onChanged: (v) => actualDuration = double.tryParse(v.replaceAll(',', '.')) ?? 0,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Факт. дата окончания: '),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: actualEndDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setState(() => actualEndDate = picked);
                      }
                    },
                    child: Text(DateFormat('dd.MM.yy').format(actualEndDate)),
                  ),
                ],
              ),
            ],

            // --- ДАТЫ ПЛАНОВЫЕ ---
            Row(
              children: [
                const Icon(Icons.date_range, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      final picked = await showDateRangePicker(
                        context: context,
                        locale: Locale(widget.lang),
                        initialDateRange: DateTimeRange(start: startDate, end: endDate),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                        builder: (context, child) => Theme(
                          data: Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: Colors.green.shade700)),
                          child: child!,
                        ),
                      );
                      if (picked != null) {
                        setState(() {
                          startDate = picked.start;
                          endDate = picked.end;
                          if (isDone) {
                            actualEndDate = endDate; // обновим по умолчанию
                          }
                        });
                      }
                    },
                    child: Text(
                      '${DateFormat('dd.MM.yy').format(startDate)} - ${DateFormat('dd.MM.yy').format(endDate)}',
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(_tr('cancel'), style: const TextStyle(color: Colors.green))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade50),
          onPressed: _saveAndClose,
          child: Text(isEdit ? _tr('save') : _tr('add'), style: const TextStyle(color: Colors.green)),
        ),
      ],
    );
  }
}
