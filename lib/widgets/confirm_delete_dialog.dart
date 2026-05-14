import 'package:flutter/material.dart';
import '../utils/app_localization.dart';

class ConfirmDeleteDialog extends StatelessWidget {
  final String lang;
  final String taskTitle;
  final VoidCallback onConfirm;

  const ConfirmDeleteDialog({
    super.key,
    required this.lang,
    required this.taskTitle,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    String tr(String key) => AppLocalization.tr(lang, key);
    return AlertDialog(
      title: Text(tr('del_title')),
      content: Text('${tr('del_desc')} "$taskTitle"?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(tr('cancel'))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () {
            onConfirm();
            Navigator.pop(context);
          },
          child: Text(tr('del_btn'), style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
