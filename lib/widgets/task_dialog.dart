// lib/widgets/task_dialog.dart

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
  late String sector;
  late String type;
  late DateTime startDate;
  late DateTime endDate;
  
  int? plantingQty;
  double? plantingArea;
  String? cultureType;
  double? cuttingVol;
  double? cuttingArea;
  
  // Новые переменные охраны
  double? guardLength;
  int? guardQty;

  String _tr(String key) => AppLocalization.tr(widget.lang, key);

  @override
  void initState() {
    super.initState();
    title = widget.task?.title ?? '';
    sector = widget.task?.sector ?? '';
    type = widget.task?.type ?? 'Обход';
    startDate = widget.task?.startDate ?? DateTime.now();
    endDate = widget.task?.endDate ?? DateTime.now().add(const Duration(days: 1));
    
    plantingQty = widget.task?.plantingQuantity;
    plantingArea = widget.task?.plantingArea;
    cultureType = widget.task?.cultureType ?? 'ильмовые';
    
    cuttingVol = widget.task?.cuttingVolume;
    cuttingArea = widget.task?.cuttingArea;
    
    guardLength = widget.task?.guardLength;
    guardQty = widget.task?.guardQuantity;
  }

  void _saveAndClose() {
    if (title.isEmpty) return;

    final resultTask = ForestTask(
      title: title,
      sector: sector,
      startDate: startDate,
      endDate: endDate,
      type: type,
      isDone: widget.task?.isDone ?? false,
      plantingQuantity: type == 'Посадка' ? plantingQty : null,
      plantingArea: type == 'Посадка' ? plantingArea : null,
      cultureType: type == 'Посадка' ? cultureType : null,
      cuttingVolume: type == 'Вырубка' ? cuttingVol : null,
      cuttingArea: type == 'Вырубка' ? cuttingArea : null,
      guardLength: type == 'Охрана' ? guardLength : null,
      guardQuantity: type == 'Охрана' ? guardQty : null,
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
            // 1. Поле "Что сделать" (меняется в зависимости от типа)
            if (type == 'Охрана')
              DropdownButtonFormField<String>(
                value: ['min_polosy', 'uhod_polosy', 'anshlagi', 'patrul'].contains(title) ? title : null,
                decoration: InputDecoration(labelText: _tr('what')),
                items: ['min_polosy', 'uhod_polosy', 'anshlagi', 'patrul']
                    .map((e) => DropdownMenuItem(value: e, child: Text(_tr(e)))).toList(),
                onChanged: (v) => setState(() {
                  title = v!;
                  guardLength = null;
                  guardQty = null;
                }),
              )
            else
              TextFormField(
                initialValue: title,
                decoration: InputDecoration(labelText: _tr('what')), 
                onChanged: (v) => title = v
              ),
            const SizedBox(height: 16),

            // 2. Участок
            TextFormField(
              initialValue: sector,
              decoration: InputDecoration(labelText: _tr('sector')), 
              onChanged: (v) => sector = v
            ),
            const SizedBox(height: 16),

            // 3. Тип задачи
            DropdownButtonFormField<String>(
              value: type,
              items: ['Обход', 'Посадка', 'Вырубка', 'Охрана'].map((e) => DropdownMenuItem(value: e, child: Text(_tr(e)))).toList(),
              onChanged: (v) => setState(() {
                type = v!;
                // Если меняем тип на Охрану, сбрасываем title, чтобы не висел старый текст
                if (type == 'Охрана' && !['min_polosy', 'uhod_polosy', 'anshlagi', 'patrul'].contains(title)) {
                  title = 'min_polosy';
                }
              }),
            ),
            const SizedBox(height: 16),

            // --- БЛОК ПОСАДКИ ---
            if (type == 'Посадка') ...[
              DropdownButtonFormField<String>(
                value: cultureType,
                decoration: InputDecoration(labelText: _tr('culture_type')),
                items: ['ильмовые', 'клен', 'ясень', 'лох', 'смородина', 'тополь']
                    .map((e) => DropdownMenuItem(value: e, child: Text(_tr(e)))).toList(),
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
              const SizedBox(height: 16),
            ],

            // --- БЛОК ВЫРУБКИ ---
            if (type == 'Вырубка') ...[
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: cuttingVol?.toString() ?? '',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: _tr('cutting_vol')),
                      onChanged: (v) => cuttingVol = double.tryParse(v.replaceAll(',', '.')),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      initialValue: cuttingArea?.toString() ?? '',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: _tr('cutting_area')),
                      onChanged: (v) => cuttingArea = double.tryParse(v.replaceAll(',', '.')),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // --- БЛОК ОХРАНЫ (ДИНАМИЧЕСКИЙ) ---
            if (type == 'Охрана') ...[
              if (title == 'min_polosy' || title == 'uhod_polosy') ...[
                TextFormField(
                  initialValue: guardLength?.toString() ?? '',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: _tr('guard_km')),
                  onChanged: (v) => guardLength = double.tryParse(v.replaceAll(',', '.')),
                ),
                const SizedBox(height: 16),
              ],
              if (title == 'anshlagi') ...[
                TextFormField(
                  initialValue: guardQty?.toString() ?? '',
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: _tr('guard_qty')),
                  onChanged: (v) => guardQty = int.tryParse(v),
                ),
                const SizedBox(height: 16),
              ],
            ],

            // --- ВЫБОР ДАТЫ ---
            Row(
              children: [
                const Icon(Icons.date_range, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(alignment: Alignment.centerLeft),
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
          child: Text(isEdit ? _tr('save') : _tr('add'), style: const TextStyle(color: Colors.green))
        ),
      ],
    );
  }
}
