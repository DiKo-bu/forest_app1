import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> resolveHost(String host) async {
  try {
    final uri = Uri.https('cloudflare-dns.com', '/dns-query', {'name': host, 'type': 'A'});
    final response = await http.get(uri, headers: {'Accept': 'application/dns-json'});
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['Answer'] != null && (data['Answer'] as List).isNotEmpty) {
        return data['Answer'][0]['data'] as String;
      }
    }
  } catch (_) {}
  return host;
}
