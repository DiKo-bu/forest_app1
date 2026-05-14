import 'package:flutter/material.dart';

class ExecutorDialog extends StatefulWidget {
  const ExecutorDialog({super.key});

  @override
  State<ExecutorDialog> createState() => _ExecutorDialogState();
}

class _ExecutorDialogState extends State<ExecutorDialog> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Исполнитель'),
      content: TextField(controller: _controller, decoration: const InputDecoration(hintText: 'Введите ID исполнителя')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('ОТМЕНА')),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: const Text('СОХРАНИТЬ'),
        ),
      ],
    );
  }
}
