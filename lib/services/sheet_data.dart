class SheetData {
  final Map<String, String> fixedValues;
  final List<String> yearlyHeaders;
  final List<Map<String, String>> yearlyRows;

  SheetData({required this.fixedValues, required this.yearlyHeaders, required this.yearlyRows});

  factory SheetData.fromJson(Map<String, dynamic> json) {
    final fixed = Map<String, String>.fromEntries(
      (json['fixedValues'] as Map).entries.map((e) => MapEntry(e.key.toString(), e.value.toString())),
    );

    final headers = List<String>.from(json['yearlyData'].first['header']);
    final rows =
        json['yearlyData'].skip(1).map<Map<String, String>>((e) {
          final data = (e['data'] as List).map((v) => v.toString()).toList();
          return Map.fromIterables(headers, data);
        }).toList();

    return SheetData(fixedValues: fixed, yearlyHeaders: headers, yearlyRows: rows);
  }
}
