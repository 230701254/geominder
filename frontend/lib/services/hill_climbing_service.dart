import 'dart:convert';
import 'package:http/http.dart' as http;

class HillClimbBackend {
  static const String baseUrl = "http://192.168.1.2:5000"; // Your backend IP + port

  static Future<bool> checkHillClimbTrigger(double distance) async {
    try {
      final url = Uri.parse('$baseUrl/check-trigger');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'distance': distance}),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        return result['trigger'] == true;
      } else {
        print('Error: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error connecting to backend: $e');
      return false;
    }
  }
}
