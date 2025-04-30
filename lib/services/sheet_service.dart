import 'dart:convert';
import 'package:http/http.dart' as http;

class SheetService {
  static final String baseUrl = const String.fromEnvironment('BASE_URL');

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

  static Future<void> postYearlyData(
    String sheetName,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('$baseUrl?action=add&sheetName=$sheetName');

    final client = http.Client();
    final request =
        http.Request('POST', url)
          ..headers['Content-Type'] = 'application/json'
          ..body = json.encode(data);

    final streamedResponse = await client.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    // GASがリダイレクトしようとしてくる。が、データは追加できてる
    // 302がどうにも回避できないのでいったん許容して進めることとする
    //if (response.statusCode != 200 || response.body.trim() != '追加完了') {
    if (response.statusCode != 200 && response.statusCode != 302) {
      throw Exception('データの追加に失敗しました: ${response.body}');
    }
  }
}
