
import 'package:flutter/material.dart';
import 'services/sheet_service.dart';

void main() {
  runApp(const MaterialApp(
    home: SheetListScreen(),
  ));
}

class SheetListScreen extends StatefulWidget {
  const SheetListScreen({super.key});

  @override
  State<SheetListScreen> createState() => _SheetListScreenState();
}

class _SheetListScreenState extends State<SheetListScreen> {
  List<String> sheetNames_ = [];
  String? selectedSheet_;
  Map<String, dynamic>? sheetData_;
  TextEditingController yearController_ = TextEditingController();
  TextEditingController memoController_ = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSheets();
  }

  Future<void> _loadSheets() async {
    final sheets = await SheetService.fetchSheetNames();
    setState(() {
      sheetNames_ = sheets;
    });
  }

  Future<void> _loadSheetData(String sheetName) async {
    final data = await SheetService.fetchSheetData(sheetName);
    setState(() {
      selectedSheet_ = sheetName;
      sheetData_ = data;
    });
  }

  Future<void> _submitYearlyData() async {
    if (selectedSheet_ == null) return;
    final data = {
      '年': yearController_.text,
      '収穫量': '310kg',
      '苗の量': '10袋',
      '肥料の量': '15kg',
      '殺虫剤の量': '3L',
      'メモ': memoController_.text,
    };
    await SheetService.postYearlyData(selectedSheet_!, data);
    await _loadSheetData(selectedSheet_!); // 反映
    yearController_.clear();
    memoController_.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('田んぼ・機材リスト')),
      body: Column(
        children: [
          DropdownButton<String>(
            hint: const Text('シートを選択'),
            value: selectedSheet_,
            items: sheetNames_.map((name) {
              return DropdownMenuItem(value: name, child: Text(name));
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                _loadSheetData(value);
              }
            },
          ),
          const Divider(),
          if (selectedSheet_ != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🆕 年別データ追加'),
                  TextField(
                    controller: yearController_,
                    decoration: const InputDecoration(labelText: '年'),
                  ),
                  TextField(
                    controller: memoController_,
                    decoration: const InputDecoration(labelText: 'メモ'),
                  ),
                  ElevatedButton(
                    onPressed: _submitYearlyData,
                    child: const Text('追加する'),
                  ),
                ],
              ),
            ),
          const Divider(),
          if (sheetData_ != null)
            Expanded(
              child: ListView(
                children: [
                  const Text('🔒 固定値'),
                  ...sheetData_!['fixedValues'].entries.map(
                    (e) => ListTile(
                      title: Text(e.key),
                      subtitle: Text(e.value.toString()),
                    ),
                  ),
                  const Divider(),
                  const Text('📅 年別データ'),
                  ...List.generate(
                    sheetData_!['yearlyData'].length - 1,
                    (i) {
                      final headers = sheetData_!['yearlyData'][0]['header'];
                      final row = sheetData_!['yearlyData'][i + 1]['data'];
                      return ListTile(
                        title: Text('${row[0]}年'),
                        subtitle: Text(
                          List.generate(
                            headers.length,
                            (j) => '${headers[j]}: ${row[j]}',
                          ).join('\n'),
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
        ],
      ),
    );
  }
}
