import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../utils/dns_helper.dart';

class TaskService {
  static const String serverHost = 'testing-worlds-boost-absolutely.trycloudflare.com';

  static Future<String?> fetchPlan(String executorId) async {
    if (executorId.isEmpty) return null;
    final ip = await resolveHost(serverHost);
    final url = Uri.http(ip, '/plan/$executorId');
    final response = await http.get(url, headers: {'Host': serverHost});
    if (response.statusCode == 200 && response.body.isNotEmpty && response.body != '{}') {
      return response.body;
    }
    return null;
  }
}
