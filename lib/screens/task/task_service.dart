import 'dart:convert';
import 'package:http/http.dart' as http;

class TaskService {
  static const String serverHost = 'testing-worlds-boost-absolutely.trycloudflare.com';

  static Future<String?> fetchPlan(String executorId) async {
    if (executorId.isEmpty) return null;
    final url = Uri.https(serverHost, '/plan/$executorId');
    final response = await http.get(url);
    if (response.statusCode == 200 && response.body.isNotEmpty && response.body != '{}') {
      return response.body;
    }
    return null;
  }
}
