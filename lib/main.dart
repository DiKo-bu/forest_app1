import 'package:flutter/material.dart';
import 'screens/task_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ForestApp());
}

class ForestApp extends StatelessWidget {
  const ForestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
      ),
      home: const TaskScreen(),
    );
  }
}
