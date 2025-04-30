import 'dart:convert';
import 'package:http/http.dart' as http;

class SheetService {
  static const String baseUrl =
      const String.fromEnvironment('BASE_URL');

  static Future<List<String>> fetchSheetNames() async {
    final response = await http.get(Uri.parse('$baseUrl?action=list'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<String>.from(data['sheets']);
    } else {
      throw Exception('シート一覧の取得に失敗しました');
    }
  }

  static Future<Map<String, dynamic>> fetchSheetData(String sheetName) async {
    final response = await http.get(
      Uri.parse('$baseUrl?action=get&sheetName=$sheetName'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('シートデータの取得に失敗しました');
    }
  }
}
