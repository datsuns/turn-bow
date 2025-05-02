import 'dart:convert';
import 'package:http/http.dart' as http;
import 'sheet_data.dart';

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

  static Future<SheetData> fetchSheetData(String sheetName) async {
    final response = await http.get(
      Uri.parse('$baseUrl?action=get&sheetName=$sheetName'),
    );
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return SheetData.fromJson(jsonData);
    } else {
      throw Exception('シートデータの取得に失敗しました');
    }
  }

  static Future<void> postYearlyData(
    String sheetName,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('$baseUrl?action=add&sheetName=$sheetName');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    // GASがリダイレクトしようとしてくる。が、データは追加できてる
    // 302がどうにも回避できないのでいったん許容して進めることとする
    //if (response.statusCode != 200 || response.body.trim() != '追加完了') {
    if (response.statusCode != 200 && response.statusCode != 302) {
      throw Exception('データの追加に失敗しました: ${response.body}');
    }
  }

  static Future<void> updateFixedValue(
    String sheetName,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('$baseUrl?action=updateFixed&sheetName=$sheetName');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    // GASがリダイレクトしようとしてくる。が、データは追加できてる
    // 302がどうにも回避できないのでいったん許容して進めることとする
    //if (response.statusCode != 200 || response.body.trim() != '修正完了') {
    if (response.statusCode != 200 && response.statusCode != 302) {
      throw Exception('修正に失敗しました: ${response.body}');
    }
  }

  static Future<void> updateYearlyData(
    String sheetName,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('$baseUrl?action=updateYearly&sheetName=$sheetName');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    // 302がどうにも回避できないのでいったん許容して進めることとする
    //if (response.statusCode != 200 || response.body.trim() != '更新完了') {
    if (response.statusCode != 200 && response.statusCode != 302) {
      throw Exception('更新に失敗しました: ${response.body}');
    }
  }

  static Future<void> deleteYearlyData(String sheetName, String year) async {
    final url = Uri.parse('$baseUrl?action=deleteYearly&sheetName=$sheetName');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'年': year}),
    );
    // 302がどうにも回避できないのでいったん許容して進めることとする
    //if (response.statusCode != 200 || response.body.trim() != '削除完了') {
    if (response.statusCode != 200 && response.statusCode != 302) {
      throw Exception('削除に失敗しました: ${response.body}');
    }
  }

  static Future<void> createSheet({
    required String sheetName,
    required List<String> fixedKeys,
    required List<String> yearlyKeys,
  }) async {
    final url = Uri.parse('$baseUrl?action=createSheet&sheetName=$sheetName');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'fixedKeys': fixedKeys, 'yearlyKeys': yearlyKeys}),
    );
    if (response.statusCode != 200 || response.body.trim() != '作成完了') {
      throw Exception('シート作成に失敗しました: \${response.body}');
    }
  }
}
