import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'screens/task_screen.dart';

class CustomHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.badCertificateCallback = (cert, host, port) => true;
    return client;
  }

  @override
  Future<InternetAddress> resolve(String host, {required bool followRedirects}) async {
    if (host == 'localhost' || host == '127.0.0.1' || host.startsWith('192.168.')) {
      return super.resolve(host, followRedirects: followRedirects);
    }
    try {
      final uri = Uri.https('cloudflare-dns.com', '/dns-query', {'name': host, 'type': 'A'});
      final response = await http.get(uri, headers: {'Accept': 'application/dns-json'});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['Answer'] != null && (data['Answer'] as List).isNotEmpty) {
          final ip = data['Answer'][0]['data'] as String;
          return InternetAddress(ip);
        }
      }
    } catch (_) {}
    return super.resolve(host, followRedirects: followRedirects);
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = CustomHttpOverrides();
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
