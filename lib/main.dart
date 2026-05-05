// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // <-- ИМПОРТ ЛОКАЛИЗАЦИИ
import 'screens/task_screen.dart'; // Импорт главного экрана

void main() => runApp(const ForestApp());

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
      
      // --- НАСТРОЙКИ СИСТЕМНОГО ЯЗЫКА ДЛЯ КАЛЕНДАРЯ ---
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ru'), // Поддержка русского
        Locale('kk'), // Поддержка казахского
      ],
      // ------------------------------------------------
      
      home: const TaskScreen(), // Вызов выделенного модуля
    );
  }
}
