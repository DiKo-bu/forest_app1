import 'package:flutter/material.dart';
import '../../utils/storage_helper.dart';
import 'task_service.dart';

Future<void> showExecutorDialog(BuildContext context) {
  final controller = TextEditingController();
  return showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Исполнитель'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(hintText: 'Введите ID исполнителя'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ОТМЕНА')),
        ElevatedButton(
          onPressed: () {
            final id = controller.text.trim();
            if (id.isNotEmpty) {
              StorageHelper.saveExecutorId(id);
              Navigator.pop(ctx);
            }
          },
          child: const Text('СОХРАНИТЬ'),
        ),
      ],
    ),
  );
}
