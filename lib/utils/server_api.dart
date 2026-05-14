import 'dart:convert';
import 'package:http/http.dart' as http;

// Хост вашего сервера Cloudflare
const String serverHost = 'dialogue-survivor-fairly-nhs.trycloudflare.com';
// Время ожидания ответа от сервера
const Duration requestTimeout = Duration(seconds: 15);

Future<String> _resolveHost(String host) async {
  try {
    final uri = Uri.https('cloudflare-dns.com', '/dns-query', {'name': host, 'type': 'A'});
    final response = await http.get(uri, headers: {'Accept': 'application/dns-json'}).timeout(Duration(seconds: 5));
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['Answer'] != null && (data['Answer'] as List).isNotEmpty) {
        // Извлекаем IP из ответа DNS
        return data['Answer'][0]['data'] as String;
      }
    }
  } catch (e) {
    print('DNS Resolve Error: $e');
  }
  return host; // Если не удалось разрешить, возвращаем исходный хост
}

/// Метод для получения плана (используется в forest_app)
Future<String?> fetchPlan(String executorId) async {
  try {
    final ip = await _resolveHost(serverHost);
    final url = Uri.http(ip, '/plan/$executorId');
    
    // Важно: передаем заголовок Host, чтобы Cloudflare понял, куда направить запрос
    final response = await http.get(
      url, 
      headers: {'Host': serverHost}
    ).timeout(requestTimeout);

    if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
      // ИСПРАВЛЕНИЕ: Декодируем байты в UTF-8 для корректной кириллицы
      return utf8.decode(response.bodyBytes);
    } else {
      print('Server returned: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching plan: $e');
  }
  return null;
}

/// Метод для отправки отчета (используется в forest_app для возврата данных в Прогноз)
Future<bool> sendReport(String executorId, Map<String, dynamic> reportData) async {
  try {
    final ip = await _resolveHost(serverHost);
    final url = Uri.http(ip, '/report');
    
    // Преобразуем Map в JSON-строку
    final String jsonStr = jsonEncode(reportData);

    final response = await http.post(
      url,
      headers: {
        'Host': serverHost, 
        'Content-Type': 'application/json; charset=utf-8' // Указываем кодировку при отправке
      },
      body: jsonStr,
    ).timeout(requestTimeout);

    return response.statusCode == 200;
  } catch (e) {
    print('Error sending report: $e');
    return false;
  }
}

/// Дополнительный метод для приложения "Прогноз" — отправка сформированного плана на сервер
Future<bool> uploadNewPlan(Map<String, dynamic> planData) async {
  try {
    final ip = await _resolveHost(serverHost);
    final url = Uri.http(ip, '/plan');
    
    final response = await http.post(
      url,
      headers: {
        'Host': serverHost,
        'Content-Type': 'application/json; charset=utf-8'
      },
      body: jsonEncode(planData),
    ).timeout(requestTimeout);

    return response.statusCode == 200;
  } catch (e) {
    print('Error uploading plan: $e');
    return false;
  }
}
