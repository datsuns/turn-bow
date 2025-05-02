import 'package:flutter/material.dart';
import 'services/sheet_service.dart';
import 'services/sheet_data.dart';

void main() {
  runApp(const MaterialApp(home: SheetListScreen()));
}

class SheetListScreen extends StatefulWidget {
  const SheetListScreen({super.key});

  @override
  State<SheetListScreen> createState() => _SheetListScreenState();
}

class _SheetListScreenState extends State<SheetListScreen> {
  List<String> sheetNames_ = [];
  String? selectedSheet_;
  SheetData? sheetData_;
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

  void _showYearlyDataDialog() {
    final yearController = TextEditingController();
    final memoController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('年別データを追加'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: yearController,
                decoration: const InputDecoration(labelText: '年'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: memoController,
                decoration: const InputDecoration(labelText: 'メモ'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () async {
                final year = yearController.text.trim();
                final memo = memoController.text.trim();
                if (year.isEmpty) return;

                final data = {'年': year, 'メモ': memo};

                try {
                  await SheetService.postYearlyData(selectedSheet_!, data);
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                  _loadSheetData(selectedSheet_!);
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('追加に失敗: $e')));
                }
              },
              child: const Text('追加する'),
            ),
          ],
        );
      },
    );
  }

  void _showFixedValueEditDialog(String key, String currentValue) {
    final controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('「$key」の値を修正'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: '新しい値'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newValue = controller.text.trim();
                if (newValue.isEmpty) return;

                try {
                  await SheetService.updateFixedValue(selectedSheet_!, {
                    key: newValue,
                  });
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                  _loadSheetData(selectedSheet_!);
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('修正に失敗: $e')));
                }
              },
              child: const Text('修正する'),
            ),
          ],
        );
      },
    );
  }

  void _showEditYearlyDialog(Map<String, dynamic> rowData) {
    final controllers = <String, TextEditingController>{};
    for (final entry in rowData.entries) {
      controllers[entry.key] = TextEditingController(
        text: entry.value.toString(),
      );
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('年別データの編集'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  controllers.entries.map((entry) {
                    return TextField(
                      controller: entry.value,
                      decoration: InputDecoration(labelText: entry.key),
                    );
                  }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedData = {
                  for (final entry in controllers.entries)
                    entry.key: entry.value.text.trim(),
                };
                try {
                  await SheetService.updateYearlyData(
                    selectedSheet_!,
                    updatedData,
                  );
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                  _loadSheetData(selectedSheet_!);
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('更新失敗: $e')));
                }
              },
              child: const Text('保存'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteYearDialog() {
    final yearController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('年別データを削除'),
            content: TextField(
              controller: yearController,
              decoration: const InputDecoration(labelText: '削除する年'),
              keyboardType: TextInputType.number,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('キャンセル'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final year = yearController.text.trim();
                  if (year.isEmpty) return;

                  try {
                    await SheetService.deleteYearlyData(selectedSheet_!, year);
                    if (!context.mounted) return;
                    Navigator.of(context).pop();
                    _loadSheetData(selectedSheet_!);
                  } catch (e) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('削除失敗: $e')));
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('削除'),
              ),
            ],
          ),
    );
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
            items:
                sheetNames_.map((name) {
                  return DropdownMenuItem(value: name, child: Text(name));
                }).toList(),
            onChanged: (value) {
              if (value != null) {
                _loadSheetData(value);
              }
            },
          ),
          const Divider(),
          if (sheetData_ != null)
            Expanded(
              child: ListView(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      '🔒 固定値',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('項目')),
                        DataColumn(label: Text('値')),
                      ],
                      rows:
                          sheetData_!.fixedValues.entries.map<DataRow>((e) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(e.key),
                                  onLongPress:
                                      () => _showFixedValueEditDialog(
                                        e.key,
                                        e.value.toString(),
                                      ),
                                ),
                                DataCell(
                                  Text(e.value.toString()),
                                  onLongPress:
                                      () => _showFixedValueEditDialog(
                                        e.key,
                                        e.value.toString(),
                                      ),
                                ),
                              ],
                            );
                          }).toList(),
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '年別データ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _showYearlyDataDialog,
                          child: const Text('追加'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _showDeleteYearDialog,
                          icon: const Icon(Icons.delete),
                          label: const Text('削除'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (sheetData_!.yearlyRows.isNotEmpty)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns:
                            sheetData_!.yearlyHeaders
                                .map<DataColumn>(
                                  (col) =>
                                      DataColumn(label: Text(col.toString())),
                                )
                                .toList(),
                        rows:
                            sheetData_!.yearlyRows.map((row) {
                              return DataRow(
                                onLongPress: () => _showEditYearlyDialog(row),
                                cells:
                                    sheetData_!.yearlyHeaders.map((h) {
                                      return DataCell(Text(row[h] ?? ''));
                                    }).toList(),
                              );
                            }).toList(),
                      ),
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('年別データがまだありません'),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
